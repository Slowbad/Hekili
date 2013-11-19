--	Core.lua
--	The actual engine of the addon.
--	Hekili @ Ner'zhul, 10/23/13


local SpellRange = LibStub("SpellRange-1.0")

function Hekili:ProcessPriorityList( id )

	local module = Hekili.ActiveModule
	
	if not module or not module.enabled[id] then
		for i = 1, 5 do
			Hekili.UI.AButtons[id][i]:Hide()
		end
		return
	end

	local state = module.state[id]

	module.RefreshState( state )

	local startTime = state.time

	local glovesID = GetInventoryItemID("player", 10)
	local gloves, gTexture

	if glovesID then
		gloves, _, _, _, _, _, _, _, _, gTexture = GetItemInfo(GetInventoryItemID("player", 10))
	end

	local startGCD, GCD = GetSpellCooldown("Lightning Shield")

	for i = 1, 5 do
		local Action		= nil
		local Description	= nil
		local Cooldown		= 999
		local cdThreshold	= 30

		if (Hekili.DB.char['Cooldown Enabled']) and id == 'ST' then
			for j,v in ipairs(module.state['CD'].actions) do
				local ckAbility, ckCooldown, ckWait

				-- Check can pass a second argument that equates to the SimC 'wait' value.  Third argument is 'true' if hardcasting.
				ckAbility, ckWait = v.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAbility and not (module.flags[ckAbility] and Hekili.Flagged(ckAbility)) then
					ckCooldown = state.cooldowns[ckAbility]

					-- May want to add some smoothing to this.
					if ckCooldown < (Cooldown + ckWait) then
						Action		= ckAbility
						Cooldown	= ckCooldown
						Description	= v.desc
					end
				end

				if Cooldown == 0 then
					break
				end
			end
		end
		
		for j,v in ipairs(state.actions) do
			local ckAbility, ckWait, ckHardcast
			local ckCooldown

			-- Check can pass a second argument that equates to the SimC 'wait' value.  Third arg is 'true' if hardcasting.
			ckAbility, ckWait, ckHardcast = v.check( state )

			if not ckWait or ckWait == GCD then ckWait = 0 end
			if not ckHardcast then ckHardcast = false end

			-- trying w/o this check
			if ckAbility and not (module.flags[ckAbility] and Hekili.Flagged(ckAbility)) and (Hekili.DB.char['Show Hardcasts'] or not ckHardcast) then
				ckCooldown = state.cooldowns[ckAbility]

				-- May want to add some smoothing to this.
				if ckCooldown < (Cooldown + ckWait) then
					Action		= ckAbility
					Cooldown	= ckCooldown
					Description	= v.desc
				end
			end
			
			if Cooldown == 0 then
				break
			end
		end
		
		if not Action or (Cooldown > cdThreshold and i > 1) then
			Hekili.UI.AButtons[id][i]:Hide()
		else
			Hekili.UI.AButtons[id][i]:Show()

			if Cooldown > 0 then
				module.AdvanceState( state, Cooldown )
			end

			if not Hekili.UseAbility then Hekili.UseAbility = {} end
			if not Hekili.UseAbility[id] then Hekili.UseAbility[id] = {} end
			if not Hekili.UseAbility[id][i] then Hekili.UseAbility[id][i] = {} end

			Hekili.UseAbility[id][i].name 			= Action
			Hekili.UseAbility[id][i].description	= Description
			Hekili.UseAbility[id][i].cast			= module.Execute[Action](state)
			Hekili.UseAbility[id][i].cooldown		= Cooldown
			Hekili.UseAbility[id][i].time			= state.time

			local start, duration = GetSpellCooldown(Action)

			-- Override for Virmen's Bite
			if not start and not duration then
				start, duration = GetItemCooldown(76089)
			end

			if i == 1 or (i > 1 and duration ~= GCD) then
				Hekili.UI.AButtons[id][i].Cooldown:SetCooldown(start, duration)
			else
				Hekili.UI.AButtons[id][i].Cooldown:SetCooldown(0, 0)
			end

			if Action == "Stormblast" then
				Hekili.UI.AButtons[id][i].Texture:SetTexture(GetSpellTexture(115356))
			elseif Action == "Virmen's Bite" then
				Hekili.UI.AButtons[id][i].Texture:SetTexture('Interface\\ICONS\\TRADE_ALCHEMY_POTIOND6')
			elseif Action == "Synapse Springs" then
				Hekili.UI.AButtons[id][i].Texture:SetTexture(gTexture)
			else
				Hekili.UI.AButtons[id][i].Texture:SetTexture(GetSpellTexture(Action))
			end		

			if Description then
				Hekili.UI.AButtons[id][i].btmText:SetText(Description)
			end

			--Hekili.UI.AButtons[id][i].topText:SetText( tostring( round(state.time - startTime, 1) ) )

			if i < 5 then module.AdvanceState( state, Hekili.UseAbility[id][i].cast ) end
		end
	end

	for i = 1, 5 do
		if i == 1 then
			Hekili.UI.AButtons[id][i].topText:SetText( tostring( round ( Hekili.UseAbility[id][i].time - startTime, 1 ) ) )
		else
			if module.offGCD[Hekili.UseAbility[id][i].name] then
				Hekili.UI.AButtons[id][i].topText:SetText( Hekili.UI.AButtons[id][i-1].topText:GetText() )
			else
				Hekili.UI.AButtons[id][i].topText:SetText( tostring( round ( Hekili.UseAbility[id][i].time - startTime, 1 ) ) )
			end
		end
	end

	if id == 'AE' then
		if state.tCount > 1 then
			ActionButton_ShowOverlayGlow(Hekili.UI.AButtons[id][1])
			Hekili.UI.AButtons[id][1].targets:SetText(state.fsCount .. ' (' .. state.tCount .. ')')
		else
			ActionButton_HideOverlayGlow(Hekili.UI.AButtons[id][1])
			Hekili.UI.AButtons[id][1].targets:SetText(nil)
		end
	end

	for i = 1, 5 do
		if (id == 'ST' and i > Hekili.DB.char['Single Target Icons Displayed']) or
			(id == 'AE' and i > Hekili.DB.char['Multi-Target Icons Displayed']) then
			Hekili.UI.AButtons[id][i]:Hide()
		end
		
		if SpellRange.IsSpellInRange(Hekili.UseAbility[id][i].name, 'target') == 0 then
			Hekili.UI.AButtons[id][i].Texture:SetVertexColor(1, 0, 0)
		else
			Hekili.UI.AButtons[id][i].Texture:SetVertexColor(1, 1, 1)
		end
	end

end


function Hekili:HeartBeat()
	if not self:IsEnabled() then
		return
	end

	if self.ActiveModule and self.ActiveModule.auditTrackers then self.ActiveModule.auditTrackers() end

	if self.DB.char['Single Target Enabled'] then	self:ProcessPriorityList( 'ST' ) end
	if self.DB.char['Multi-Target Enabled'] then	self:ProcessPriorityList( 'AE' ) end
end


--	OnInitialize()
--	AddOn has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
	-- Chat Command is handled by AceOptions (for now).
	-- Hekili:RegisterChatCommand("hekili", "CommandProcessor")

	self.DB = LibStub("AceDB-3.0"):New("HekiliDB", self:GetDefaults())
	-- self.DB.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	-- self.DB.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	-- self.DB.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Hekili", self:GetOptions(), {"hekili", "kili"})
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Hekili")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.DB))
	self.optionsFrame.Profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles", "Profiles", "Hekili")

	-- Prepare graphical elements (and the engine frame).
	self:InitCoreUI()
	
	self:UnregisterAllEvents()

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("PLAYER_LOGOUT")

	-- Combat time / boss fight status.
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	-- self:RegisterEvent("PET_BATTLE_CLOSE")
	-- self:RegisterEvent("PET_BATTLE_OPENING_START")
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD")


	-- Will need this for time to die.
	self:RegisterEvent("UNIT_HEALTH")

	self.BossFight		= false
	self.CombatStart	= 0
	self.TTD			= {}
	
end


-- Borrowed TTD logic from 'Nemo' by soulwhip.
function Hekili.InitTTD()
	Hekili.TTD.n			= 1
	Hekili.TTD.timeSum		= GetTime()
	Hekili.TTD.healthSum	= UnitHealth("target") or 0
	Hekili.TTD.timeMean		= Hekili.TTD.timeSum * Hekili.TTD.timeSum
	Hekili.TTD.healthMean	= Hekili.TTD.timeSum * Hekili.TTD.healthSum
	Hekili.TTD.GUID			= UnitGUID("target") or nil
	Hekili.TTD.sec			= 300
end


function Hekili.GetTTD()
	if Hekili.TTD.sec then
		return Hekili.TTD.sec
	else
		return 300
	end
end


function Hekili:SanityCheck()

	local class = UnitClass("player")
	local specialization = select(2, GetSpecializationInfo(GetSpecialization()))
	local activeSpec = GetActiveSpecGroup()

	local pMod = self.DB.char['Primary Specialization Module']
	local sMod = self.DB.char['Secondary Specialization Module']

	-- Check Primary Specialization table.
	if activeSpec == 1 then
		if pMod ~= '(none)' and self.Modules[ pMod ] then
			if self.Modules[pMod].class ~= class then
				self:Print("Module |cFFFF9900" .. pMod .. "|r is not appropriate for your class; unloading.")
				self.DB.char['Primary Specialization Module'] = '(none)'
				pMod = '(none)'
			elseif self.Modules[pMod].spec ~= specialization then
				self:Print("Module |cFFFF9900" .. pMod .. "|r is not appropriate for your specialization; unloading.")
				self.DB.char['Primary Specialization Module'] = '(none)'
				pMod = '(none)'
			end
		end
		self.ActiveModule = self.Modules[ pMod ]
		
	elseif activeSpec == 2 then
		if sMod ~= '(none)' and self.Modules[ sMod ] then
			if self.Modules[sMod].class ~= class then
				self:Print("Module |cFFFF9900" .. sMod .. "|r is not appropriate for your class; unloading.")
				self.DB.char['Secondary Specialization Module'] = '(none)'
				sMod = '(none)'
			elseif self.Modules[sMod].spec ~= specialization then
				self:Print("Module |cFFFF9900" .. sMod .. "|r is not appropriate for your specialization; unloading.")
				self.DB.char['Secondary Specialization Module'] = '(none)'
				sMod = '(none)'
			end
		end
		self.ActiveModule = self.Modules[ sMod ]
	end	

end



-- 	OnEnable()
--	AddOn has been (re)enabled by the user.
function Hekili:OnEnable()
	if Hekili.DB.char.enabled then
		-- Class specific (re)loading stuff should probably go here.
		for k,v in pairs(Hekili.Modules) do
			Hekili:Print("Module |cFFFF9900" .. k .. "|r is loaded (" .. tostring(v) .. ").")
		end

		-- Make sure the module is appropriate for the character.
		self:SanityCheck()

		if Hekili.LBF then
			Hekili.stGroup:ReSkin()
			Hekili.aeGroup:ReSkin()
		end
	else
		Hekili:Disable()
	end
end


--	OnDisable()
--	AddOn has been disabled by the user.
function Hekili:OnDisable()

	Hekili.ActiveModule = nil
	
	for i = 1, 5 do
		Hekili.UI.AButtons['ST'][i]:Hide()
		Hekili.UI.AButtons['AE'][i]:Hide()
	end
	
	-- Hekili.UI.Engine:SetScript("OnUpdate", nil)
end


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
	self:SanityCheck()
end


function Hekili:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	Hekili.BossCombat		= true
	Hekili.CombatStart		= GetTime()
end


function Hekili:PLAYER_REGEN_DISABLED(...)
    Hekili.CombatStart		= GetTime()
end


function Hekili:PLAYER_REGEN_ENABLED(...)
	Hekili.BossCombat	= false
	Hekili.CombatStart	= 0
end

function Hekili:COMBAT_LOG_EVENT_UNFILTERED(...)

	if self.ActiveModule and self.ActiveModule.CLEU then
		self.ActiveModule:CLEU(self, ...)
	end

end
