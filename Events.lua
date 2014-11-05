-- Events.lua
-- June 2014

local H = Hekili

local FormatKey = H.Utils.FormatKey
local GetSpecializationInfo = H.Utils.GetSpecializationInfo


function Hekili:UPDATE_BINDINGS()
	self:RefreshBindings()
end


function Hekili:CacheDurableDisplayCriteria()
	
	self.DisplayVisible		= {}
	self.HookVisible	= {}
	self.ListVisible		= {}
	self.ActionVisible		= {}
	
	for i, display in ipairs( self.DB.profile.displays ) do
		self.DisplayVisible[ i ] = display.Enabled and ( display.Specialization == 0 or display.Specialization == self.Specialization ) and ( display['Talent Group'] == 0 or display['Talent Group'] == GetActiveSpecGroup() )

		for j, priority in ipairs( display.Queues ) do
			self.HookVisible[ i..':'..j ] = priority.Enabled and priority['Action List'] ~= 0
		end
	end
	
	for i, list in ipairs( self.DB.profile.actionLists ) do
		if list.Enabled == nil then list.Enabled = true end

		self.ListVisible[ i ] = list.Enabled and ( list.Specialization == 0 or list.Specialization == self.Specialization )
		
		for j, action in ipairs( list.Actions ) do
			self.ActionVisible[ i..':'..j ] = action.Enabled and action.Ability
		end
	end
	
end


function Hekili:PLAYER_ENTERING_WORLD()
	self.Class = select(2, UnitClass( 'player' ) )
	self.Specialization, self.SpecializationName = GetSpecializationInfo( GetSpecialization() )
	self.SpecializationKey = FormatKey( self.SpecializationName )
	self.GUID = UnitGUID("player")

	if self.SetClassModifiers then self:SetClassModifiers() end
	self:UpdateGlyphs()
	self:UpdateTalents()
	
	self:CacheDurableDisplayCriteria()

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
	
	self.Specialization, self.SpecializationName = GetSpecializationInfo( GetSpecialization() )
	self.SpecializationKey = FormatKey( self.SpecializationName )

	if self.SetClassModifiers then self:SetClassModifiers() end

	self:UpdateGlyphs()
	self:UpdateTalents()

	self:CacheDurableDisplayCriteria()
	
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

	for k,_ in pairs( self.State.talent ) do
		self.State.talent[k] = nil
	end
	
	local group = GetActiveSpecGroup()
	
	for i = 1, MAX_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			local _, name, _, enabled = GetTalentInfo( i, j, group )
		
			for k,v in pairs( self.Talents ) do
				if name == v.name then
					self.State.talent[ k ] = { enabled = enabled }
					break
				end
			end
		end
	end
	
	for k,_ in pairs( self.State.perk ) do
		self.State.perk[k] = nil
	end
	
	for k,v in pairs( self.Perks ) do
		if IsSpellKnown( v.id ) then
			self.State.perk[ k ] = { enabled = true }
		else
			self.State.perk[ k ] = { enabled = false }
		end
	end
	
end


function H:PLAYER_TALENT_UPDATE()

	H:UpdateTalents()

end


function H:UpdateGlyphs()

	for k,_ in pairs( self.State.glyph ) do
		self.State.glyph[k] = nil
	end
	
	for i=1, NUM_GLYPH_SLOTS do
		local enabled, _, _, gID = GetGlyphSocketInfo(i)
		
		for k,v in pairs( self.Glyphs ) do
			if gID == v.id then
				if enabled and v.name then
					self.State.glyph[ k ] = { enabled = true }
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
	self.Boss			= true
end


function H:ENCOUNTER_END()
	self.Boss			= false
end


local InitialGearUpdate = false
function H:UpdateGear()

	local self = self or Hekili

	for k,_ in pairs( self.State.set_bonus ) do
		self.State.set_bonus[k] = 0
	end
	
	for set_name, items in pairs( self.Gear ) do
		for item, _ in pairs( items ) do
			local iName = GetItemInfo( item )
			
			if IsEquippedItem(iName) then
				self.State.set_bonus[set_name] = self.State.set_bonus[set_name] + 1
			end
		end
	end

	local g1, g2, g3 = GetInventoryItemGems(1)
	if (g1 and self.MetaGem[g1]) or (g2 and self.MetaGem[g2]) or (g3 and self.MetaGem[g3]) then
		self.State.crit_meta = true
	else
		self.State.crit_meta = false
	end

	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE") 
	Hekili.Tooltip:ClearLines()
	
	local MH = GetInventoryItemLink( "player", 16 )
	
	if MH then
		Hekili.Tooltip:SetInventoryItem( "player", 16 )
		local lines = Hekili.Tooltip:NumLines()

		for i = 2, lines do
			line = _G["HekiliTooltipTextRight"..i]:GetText()

			if line then
				local speed = tonumber( line:match("%d[.,]%d+") )
				
				if speed then
					self.State.mainhand_speed = speed
					break
				end
			end
		end	
		
		InitialGearUpdate = true
	else
		self.State.mainhand_speed = 0
		
	end
	
	Hekili.Tooltip:ClearLines()
	
	if OffhandHasWeapon() then
		Hekili.Tooltip:SetInventoryItem( "player", 17 )
		local lines = Hekili.Tooltip:NumLines()

		for i = 2, lines do
			line = _G["HekiliTooltipTextRight"..i]:GetText()

			if line then
				local speed = tonumber( line:match("%d[.,]%d+") )
				
				if speed then
					self.State.offhand_speed = speed
					break
				end
			end
		end		
	else
		self.State.offhand_speed = 0
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


Hekili.Swing = {
	MH = 0,
	nextMH = 0,
	OH = 0,
	nextOH = 0
}

-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
function Hekili:COMBAT_LOG_EVENT_UNFILTERED(event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, _, interrupt, _, _, _, _, offhand, multistrike )

	if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' and self:KnownTarget( destGUID ) then
		self:Eliminate( destGUID )
		return
	end

	-- Hekili: v1 Tracking System
	if subtype == 'SPELL_SUMMON' and sourceGUID == self.GUID then
		self:UpdateMinion( destGUID, time )
		return
	end

	if sourceGUID ~= self.GUID and not self:IsMinion( sourceGUID ) then
		return
	end

	local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 )

	local time = GetTime()
	
	if self.Class == 'WARRIOR' and subtype:sub(1, 5) == 'SWING' and not multistrike then
		local mainhandSpeed, offhandSpeed = UnitAttackSpeed( 'player' )
		local Swing = self.Swing
		
		if offhand == false or self.State.offhand_speed == 0 then
			Swing.MH		= time
			Swing.nextMH	= time + mainhandSpeed
			Swing.last		= 'MH'
		else
			Swing.OH		= time
			Swing.nextOH	= time + offhandSpeed
			Swing.last		= 'OH'
		end
		
		return
	end
	
	
	-- Player/Minion Event
	if hostile and sourceGUID ~= destGUID then
		
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