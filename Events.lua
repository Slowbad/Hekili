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


function Hekili:ACTIVE_TALENT_GROUP_CHANGED()
	table.wipe(self.UseAbility)
	table.wipe(self.State.ST)
	table.wipe(self.State.AE)
	self:SanityCheck()
	self:ApplyNameFilters()
end


function Hekili:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	Hekili.BossCombat		= true
end


function Hekili:PLAYER_EQUIPMENT_CHANGED()
	Hekili.eqChanged		= GetTime()
end


function Hekili:PLAYER_REGEN_DISABLED(...)
    Hekili.CombatStart		= GetTime()
end


function Hekili:PLAYER_REGEN_ENABLED(...)
	Hekili.BossCombat		= false
	Hekili.CombatStart		= 0
end

function Hekili:COMBAT_LOG_EVENT_UNFILTERED(...)

	if self.ActiveModule and self.ActiveModule.CLEU then
		self.ActiveModule:CLEU(self, ...)
	end

end

function Hekili:UPDATE_BINDINGS()
	self.DB.char['Cooldown Hotkey'] = GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") or ''
	self.DB.char['Hardcast Hotkey'] = GetBindingKey("HEKILI_TOGGLE_HARDCASTS") or ''
end


-- Improve responsiveness when using the refresh rate is down.
function Hekili:UNIT_SPELLCAST_SUCCEEDED( _, UID, spell )
	
	if UID == 'player' then
		self.lastCast.spell = spell
		self.lastCast.time = GetTime()
	end
	
	--[[ if UID == 'player' then
		if self.UI.Engine.Delay > 0.05 then self.UI.Engine.Delay = 0.05 end
		if self.UI.Engine.TextDelay > 0.05 then self.UI.Engine.TextDelay = 0.05 end
	end ]]
	
end


-- EVENT HANDLING --
--------------------