-- Events.lua
-- June 2014

local H = Hekili

local GetSpecializationInfo = H.Utils.GetSpecializationInfo


function Hekili:UPDATE_BINDINGS()
	self:RefreshBindings()
end


function H:PLAYER_ENTERING_WORLD()
	self.Specialization = GetSpecializationInfo( GetSpecialization() )

	if self.SetClassModifiers then self:SetClassModifiers() end
	self:UpdateGlyphs()
	self:UpdateTalents()
	
	self:UpdateGear()
	
	if not InitialGearUpdate then
		C_Timer.After( 3, Hekili.UpdateGear )
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end


function H:PLAYER_LOGOUT()
	--
end


-- Was used to force a refresh on trackers.
-- Trackers not planned for v2.  Use WeakAuras!
function H:PLAYER_TARGET_CHANGED( _ )
	--
end


function H:ACTIVE_TALENT_GROUP_CHANGED()
	
	self.Specialization = GetSpecializationInfo( GetSpecialization() )
	self:SetClassModifiers()
	
	for k,v in pairs( self.Queue ) do
		for i = 1, #v do
			self.Queue[k][i] = nil
		end
		self.Queue[k] = nil
	end
	
end


function H:PLAYER_SPECIALIZATION_CHANGED( _, unit )
	
	if unit == 'player' then
		H:ACTIVE_TALENT_GROUP_CHANGED()
	end

end


function H:UpdateTalents()

	for k,_ in pairs( self.state.talent ) do
		self.state.talent[k] = nil
	end
	
	local group = GetActiveSpecGroup()
	
	for i = 1, MAX_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			local _, name, _, enabled = GetTalentInfo( i, j, group )
		
			for k,v in pairs( self.Talents ) do
				if name == v.name then
					self.state.talent[ k ] = { enabled = enabled }
					break
				end
			end
		end
	end
	
	for k,_ in pairs( self.state.perk ) do
		self.state.perk[k] = nil
	end
	
	for k,v in pairs( self.Perks ) do
		if IsSpellKnown( v.id ) then
			self.state.perk[ k ] = { enabled = true }
		else
			self.state.perk[ k ] = { enabled = false }
		end
	end
	
end


function H:PLAYER_TALENT_UPDATE()

	H:UpdateTalents()

end


function H:UpdateGlyphs()

	for k,_ in pairs( self.state.glyph ) do
		self.state.glyph[k] = nil
	end
	
	for i=1, NUM_GLYPH_SLOTS do
		local enabled, _, _, gID = GetGlyphSocketInfo(i)
		
		for k,v in pairs( self.Glyphs ) do
			if gID == v.id then
				if enabled and v.name then
					self.state.glyph[ k ] = { enabled = true }
					break
				end
			end
		end
	end

end


function H:GLYPH_ADDED()
	self:UpdateGlyphs()
end
H.GLYPH_REMOVED = H.GLYPH_ADDED
H.GLYPH_UPDATED = H.GLYPH_ADDED


function H:ENCOUNTER_START()
	self.boss			= true
end


function H:ENCOUNTER_END()
	self.boss			= false
end


local InitialGearUpdate = false
function H:UpdateGear()

	local self = self or Hekili

	for k,_ in pairs( self.state.set_bonus ) do
		self.state.set_bonus[k] = 0
	end
	
	for set_name, items in pairs( self.Gear ) do
		for item, _ in pairs( items ) do
			local iName = GetItemInfo( item )
			
			if IsEquippedItem(iName) then
				self.state.set_bonus[set_name] = self.state.set_bonus[set_name] + 1
			end
		end
	end

	local g1, g2, g3 = GetInventoryItemGems(1)
	if (g1 and self.MetaGem[g1]) or (g2 and self.MetaGem[g2]) or (g3 and self.MetaGem[g3]) then
		self.state.crit_meta = true
	else
		self.state.crit_meta = false
	end

	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE") 
	Hekili.Tooltip:ClearLines()
	
	local MH = GetInventoryItemLink( "player", 16 )
	
	if MH then
		Hekili.Tooltip:SetInventoryItem( "player", 16 )
		
		local WS = _G["HekiliTooltipTextRight5"]:GetText()
		if WS then
			self.state.mainhand_speed = tonumber( WS:match("%d[.,]%d+") )
		end
		
		InitialGearUpdate = true
	else
		self.state.mainhand_speed = 0
		
	end
	
	Hekili.Tooltip:ClearLines()
	
	if OffhandHasWeapon() then
		Hekili.Tooltip:SetInventoryItem( "player", 17 )
		
		local WS = _G["HekiliTooltipTextRight5"]:GetText()
		if WS then
			self.state.offhand_speed = tonumber( WS:match("%d[.,]%d+") )
		end
	else
		self.state.offhand_speed = 0
	end
	
	Hekili.Tooltip:Hide()

end


function H:PLAYER_EQUIPMENT_CHANGED()
	-- (NYI) we want to update any cached info about our gear.
	H:UpdateGear()
end


function H:PLAYER_REGEN_DISABLED()
	self.combat			= GetTime()
end


function H:PLAYER_REGEN_ENABLED()
	self.combat			= 0
end


function H:UPDATE_BINDINGS()
	self:RefreshBindings()
	-- (NYI) Save keybindings from the configuration interface.
end


function H:UNIT_SPELLCAST_SUCCEEDED( _, UID, spell )

	if UID == 'player' then
		self.Cast			= self.Cast or {}
		self.Cast.spell		= spell
		self.Cast.time		= GetTime()
		
		-- (NYI) v1 would accelerate the engine in these cases.
		-- We may not need that now.
	end

end


local swing = {}

Hekili.SwingInfo = {
	['MH'] = 0,
	['next_MH'] = 4,
	['OH'] = 0,
	['next_OH'] = 4
}

-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
function H:COMBAT_LOG_EVENT_UNFILTERED(event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, _, interrupt)

	local time = GetTime()
	
	local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 )

	-- Hekili: v1 Tracking System
	if subtype == 'SPELL_SUMMON' and sourceGUID == UnitGUID('player') then
		self:UpdateMinion( destGUID, GetTime() )
	end
	
	if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' then
		self:Eliminate( destGUID )
	end

	--[[  DW Swing Logic, save for warrior implementation.
	if sourceGUID == UnitGUID('player') and subtype:sub(1, 5) == "SWING" then
		local speed = {}
		speed.MH, speed.OH = UnitAttackSpeed("player")
		if (#swing == 5) then
			table.remove(swing, 1)
		end

		-- Figure out if this was MH or OH, if possible.
		local closest, difference, hand = 0, 10, nil
		for i,v in ipairs(swing) do
			local MH_diff, OH_diff = abs(time - (v.MH or 0)), abs(time - (v.OH or 0))
			
			if MH_diff < OH_diff and MH_diff < difference then
				closest = i
				difference = MH_diff
				hand = "MH"
			elseif OH_diff < MH_diff and OH_diff < difference then
				closest = i
				difference = OH_diff
				hand = "OH"
			end
		end
		
		swing[ #swing + 1 ] = {}
		swing[ #swing ].time = time
		swing[ #swing ].MH, swing[ #swing ].OH = UnitAttackSpeed("player")
		swing[ #swing ].MH = time + swing[ #swing ].MH
		if swing[#swing].OH then swing[ #swing ].OH = time + swing[ #swing ].OH end
		
		if difference < 0.100 then
			SwingInfo[hand] = time
			SwingInfo['next_'..hand] = speed[hand]
		end
		
	end ]]
	
	-- Player/Minion Event
	if hostile and ( sourceGUID == UnitGUID('player') or self:IsMinion( sourceGUID ) ) and sourceGUID ~= destGUID then
		
		-- Aura Tracking
		if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' then
			self:TrackDebuff( spellName, destGUID, time, true )
			self:UpdateTarget( destGUID, time )
		elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
			self:TrackDebuff( spellName, destGUID, time )
			self:UpdateTarget( destGUID, time )
		elseif subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_MISSED' then
			self:UpdateTarget( destGUID, time )
		elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
			self:TrackDebuff( spellName, destGUID )
		end

		-- If you don't care about multiple targets, I don't!
		if subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
			self:UpdateTarget( destGUID, time )
		end

	end
					
	
end



-- Borrowed TTD linear regression model from 'Nemo' by soulwhip (with permission).
function H.InitTTD()
	H.TTD				= H.TTD or {}
	H.TTD.n				= 1
	H.TTD.timeSum		= GetTime()
	H.TTD.healthSum		= UnitHealth("target") or 0
	H.TTD.timeMean		= H.TTD.timeSum * H.TTD.timeSum
	H.TTD.healthMean	= H.TTD.timeSum * H.TTD.healthSum
	H.TTD.GUID			= UnitGUID("target") or nil
	H.TTD.sec			= 300
end


function H.GetTTD()
	if not H.TTD then H.InitTTD() end

	if H.TTD.sec then
		return H.TTD.sec
	else
		return 300
	end
end


-- Time to die calculations.
function H:UNIT_HEALTH( _, UID )

	if UID ~= "target" then
		return
	end
	
	if not H.TTD then H.InitTTD() end

	if ( H.TTD.GUID ~= UnitGUID(UID) and not UnitIsFriend('player', UID) ) then
		H.InitTTD()
	end
	
	if ( UnitHealth(UID) == UnitHealthMax(UID) ) then
		H.InitTTD()
		return
	end

	local now = GetTime()
	
	if ( not H.TTD.n ) then H.InitTTD() end
	
	H.TTD.n				= H.TTD.n + 1
	H.TTD.timeSum		= H.TTD.timeSum + now
	H.TTD.healthSum		= H.TTD.healthSum + UnitHealth(UID)
	H.TTD.healthMean	= H.TTD.healthMean + (now * UnitHealth(UID))
	H.TTD.timeMean		= H.TTD.timeMean + (now * now)
	
	local difference	= (H.TTD.healthSum * H.TTD.timeMean - H.TTD.healthMean * H.TTD.timeSum)
	local projectedTTD	= nil
	
	if difference > 0 then
		local divisor = (H.TTD.healthSum * H.TTD.timeSum - H.TTD.healthMean * H.TTD.n) - now
		if divisor == 0 then divisor = 1 end
		projectedTTD = difference / divisor
	end

	if not projectedTTD or projectedTTD < 0 or H.TTD.n < 7 then
		return
	else
		projectedTTD = ceil(projectedTTD)
	end

	H.TTD.sec = projectedTTD
end