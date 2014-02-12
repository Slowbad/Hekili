-- Events.lua

--------------------
-- EVENT HANDLING --

function Hekili:PLAYER_LOGOUT()
	self:SaveCoordinates()
end


-- Target time to die has to be handled by the AddOn itself.
function Hekili:UNIT_HEALTH( _, UID)

	if UID ~= "target" then
		return
	end
	
	if not Hekili.TTD then Hekili.InitTTD() end

	if ( Hekili.TTD.GUID ~= UnitGUID(UID) and not UnitIsFriend('player', UID) ) then
		Hekili.InitTTD()
	end
	
	if ( UnitHealth(UID) == UnitHealthMax(UID) ) then
		Hekili.InitTTD()
		return
	end

	local now = GetTime()
	
	if ( not Hekili.TTD.n ) then Hekili.InitTTD() end
	
	Hekili.TTD.n			= Hekili.TTD.n + 1
	Hekili.TTD.timeSum		= Hekili.TTD.timeSum + now
	Hekili.TTD.healthSum	= Hekili.TTD.healthSum + UnitHealth(UID)
	Hekili.TTD.healthMean	= Hekili.TTD.healthMean + (now * UnitHealth(UID))
	Hekili.TTD.timeMean		= Hekili.TTD.timeMean + (now * now)
	
	local difference	= (Hekili.TTD.healthSum * Hekili.TTD.timeMean - Hekili.TTD.healthMean * Hekili.TTD.timeSum)
	local projectedTTD	= nil
	
	if difference > 0 then
		projectedTTD = difference / (Hekili.TTD.healthSum * Hekili.TTD.timeSum - Hekili.TTD.healthMean * Hekili.TTD.n) - now
	end

	if not projectedTTD or projectedTTD < 0 or Hekili.TTD.n < 7 then
		return
	else
		projectedTTD = ceil(projectedTTD)
	end

	Hekili.TTD.sec = projectedTTD
end

function Hekili:PLAYER_TARGET_CHANGED( _ )
	self:UpdateTrackerCooldowns()
end


function Hekili:PLAYER_SPECIALIZATION_CHANGED()
	-- self:RefreshConfig()
end


function Hekili:ACTIVE_TALENT_GROUP_CHANGED()
	self:RefreshConfig()
	
	if self.Active then self:ProcessPriorityList( 'ST' ) end
	if self.Active then self:ProcessPriorityList( 'AE' ) end
end


function Hekili:ENCOUNTER_START(...)
	Hekili.BossCombat		= true
end


function Hekili:ENCOUNTER_END(...)
	Hekili.BossCombat		= false
end


function Hekili:PLAYER_EQUIPMENT_CHANGED()
	Hekili.eqChanged		= GetTime()
end


function Hekili:PLAYER_REGEN_DISABLED(...)
    Hekili.CombatStart		= GetTime()
end


function Hekili:PLAYER_REGEN_ENABLED(...)
	Hekili.CombatStart		= 0
end


function Hekili:COMBAT_LOG_EVENT_UNFILTERED(event, time, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, _, interrupt)

	if sourceGUID == UnitGUID('player') and (subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL') then
		for i = 1, 5 do
			if self.DB.profile['Tracker '..i..' Aura'] == spellName and UnitGUID(self.DB.profile['Tracker '..i..' Unit']) == destGUID then
				self:UpdateTrackerCooldowns()
			end
		end
	end

	-- Hekili: New Tracking System
	if subtype == 'SPELL_SUMMON' and sourceGUID == UnitGUID('player') then
		self:UpdateMinion( destGUID, GetTime() )
	end
	
	if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' then
		self:Eliminate( destGUID )
	end

	-- Player/Minion Event
	if sourceGUID == UnitGUID('player') or self:IsMinion( sourceGUID ) then
		
		-- Aura Tracking
		if self:IsAuraWatched( spellName ) then
			if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' or subtype == 'SPELL_DAMAGE' then
				self:UpdateAura( spellName, destGUID, GetTime() )
				self:UpdateTarget( destGUID, GetTime() )
			elseif subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
				self:UpdateAura( spellName, destGUID, nil )
			end
		end

		-- If you don't care about multiple targets, I don't!
		if self.DB.profile['Multi-Target Enabled'] == false and self.DB.profile['Integration Enabled'] == false then
			return true
		elseif subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
			self:UpdateTarget( destGUID, GetTime() )
		end

	end
					
	
end

function Hekili:UPDATE_BINDINGS()
	self:RefreshBindings()
end


-- Improve responsiveness when using the refresh rate is down.
function Hekili:UNIT_SPELLCAST_SUCCEEDED( _, UID, spell )
	
	if UID == 'player' then
		self.lastCast.spell = spell
		self.lastCast.time = GetTime()
		if self.UI.Engine.Delay > 0.05 then self.UI.Engine.Delay = 0 end
	end
	
end


-- EVENT HANDLING --
--------------------


