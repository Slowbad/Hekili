--	Core.lua
--	The actual engine of the addon.
--	Hekili @ Ner'zhul, 10/23/13


local SpellRange = LibStub("SpellRange-1.0")

-- Caching to hopefully improve performance.
Hekili.textureCache = setmetatable( {}, { __index =	function(t,v)
														local a = GetSpellTexture(v)
														if GetSpellTexture(v) then t[v] = a end
														return a
													end } )

Hekili.textureCache['Lava Beam'] = 'Interface\\Icons\\Spell_Fire_SoulBurn'
Hekili.textureCache['Stormblast'] = 'Interface\\Icons\\Spell_Lightning_LightningBolt01'
Hekili.textureCache['Virmen\'s Bite'] = 'Interface\\ICONS\\TRADE_ALCHEMY_POTIOND6'
Hekili.textureCache['Potion of the Jade Serpent'] = 'Interface\\Icons\\trade_alchemy_potiond4'

local function GetSpellTexture(a)
	return Hekili.textureCache[a]
end


-- Check for PvP
local pvpZones = {
	arena = true,
	pvp = true,
}


function Hekili:ProcessPriorityList( id )

	local module = Hekili.ActiveModule
	
	local _, zoneType = IsInInstance()
	
	if ( not module or not module.enabled[id] ) or
		( self.DB.char['Visibility'] == 'Show with Target' and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) or
		( self.DB.char['Visibility'] == 'Show in Combat' and ( not UnitAffectingCombat('player') and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) ) or
		( self.DB.char['PvP Visibility'] == false and pvpZones[zoneType] ) or
		( self.DB.char['Single-Target Enabled'] == false and id == 'ST' ) or
		( self.DB.char['Multi-Target Enabled'] == false and id == 'AE' ) or
		( UnitHasVehicleUI('player') ) then
		for i = 1, 5 do
			Hekili.UI.AButtons[id][i]:Hide()
		end
		return
	end

	local state = self.State[id]

	module.RefreshState( state )

	local startTime = state.time

	if state.pCast and state.pCast > 0 and module.spells[ state.pCasting ] then
		module.spells[ state.pCasting ].handler( state, true )
		module.AdvanceState( state, state.pCast )
	end

	local glovesID = GetInventoryItemID("player", 10)
	local gloves, gTexture

	if glovesID then
		gloves, _, _, _, _, _, _, _, _, gTexture = GetItemInfo(GetInventoryItemID("player", 10))
	end

	local startGCD, GCD = GetSpellCooldown("Lightning Shield")

	for i = 1, 5 do
		local useAction			= nil
		local useDescription	= nil
		local useCooldown		= 999
		local useCDThreshold	= 30

	--[[
			if ( action.type == 'precombat' and ( self.DB.char[ 'Show Precombat' ] or UnitAffectingCombat('player') ) ) or
			   ( action.type == 'cooldown' and ( self.DB.char[ 'Cooldown Enabled' ] and ( id == 'ST' or self.DB.char[ 'Multi-Target Cooldowns' ] ) ) ) or
			   ( action.type == 'aoe' and ( id == 'AE' or ( self.DB.char[ 'Multi-Target Integration' ] ~= 0 and state.tCount >= self.DB.char[ 'Multi-Target Integration' ] ) ) ) or
			   ( action.type == 'single' and ( id == 'ST' or ( self.DB.char[ 'Multi-Target Integration' ] == 0 or state.tCount < self.DB.char[ 'Multi-Target Integration' ] ) ) ) then
		]]	


		if self.DB.char[ 'Show Precombat' ] then
			for line, action in ipairs(module.actionList.precombat) do

				local ckAction, ckWait, ckHardcast, ckCooldown
				local skipped = false

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.char['Show Hardcasts'] ) then
					ckCooldown = state.cooldowns[ ckAction ]
					
					-- May want to add some smoothing to this.
					if ckCooldown < ( useCooldown + ckWait ) then
						useAction		= ckAction
						useCooldown		= ckCooldown
						useCaption		= action.caption
					end
				end

				if useCooldown == 0 then
					break
				end
			end
		end

		if useCooldown > 0 and ( self.DB.char[ 'Cooldown Enabled' ] and ( id == 'ST' or self.DB.char[ 'Multi-Target Cooldowns' ] ) ) then
			for line, action in ipairs(module.actionList.cooldown) do

				local ckAction, ckWait, ckHardcast, ckCooldown
				local skipped = false

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.char['Show Hardcasts'] ) then
					ckCooldown = state.cooldowns[ ckAction ]
					
					-- May want to add some smoothing to this.
					if ckCooldown < ( useCooldown + ckWait ) then
						useAction		= ckAction
						useCooldown		= ckCooldown
						useCaption		= action.caption
					end
				end

				if useCooldown == 0 then
					break
				end
			end
		end

		if useCooldown > 0 and ( id == 'AE' or ( self.DB.char[ 'Multi-Target Integration' ] ~= 0 and state.tCount >= self.DB.char[ 'Multi-Target Integration' ] ) ) then
			for line, action in ipairs(module.actionList.aoe) do

				local ckAction, ckWait, ckHardcast, ckCooldown
				local skipped = false

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.char['Show Hardcasts'] ) then
					ckCooldown = state.cooldowns[ ckAction ]
					
					-- May want to add some smoothing to this.
					if ckCooldown < ( useCooldown + ckWait ) then
						useAction		= ckAction
						useCooldown		= ckCooldown
						useCaption		= action.caption
					end
				end

				if useCooldown == 0 then
					break
				end
			end
		end

		if useCooldown > 0 and ( id == 'ST' ) then
			for line, action in ipairs(module.actionList.single) do

				local ckAction, ckWait, ckHardcast, ckCooldown
				local skipped = false

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.char['Show Hardcasts'] ) then
					ckCooldown = state.cooldowns[ ckAction ]
					
					-- May want to add some smoothing to this.
					if ckCooldown < ( useCooldown + ckWait ) then
						useAction		= ckAction
						useCooldown		= ckCooldown
						useCaption		= action.caption
					end
				end

				if useCooldown == 0 then
					break
				end
			end
		end
		
		if not useAction or (useCooldown > useCDThreshold and i > 1) then
			Hekili.UI.AButtons[id][i]:Hide()
		else
			if ( id == 'ST' and self.DB.char['Single Target Enabled'] and i <= self.DB.char['Single Target Icons Displayed'] ) or
				( id == 'AE' and self.DB.char['Multi-Target Enabled'] and i <= self.DB.char['Multi-Target Icons Displayed'] ) then
				Hekili.UI.AButtons[id][i]:Show()
			end

			if useCooldown > 0 then
				module.AdvanceState( state, useCooldown )
			end

			-- Just for behind the scenes info.
			if not Hekili.UseAbility then Hekili.UseAbility = {} end
			if not Hekili.UseAbility[id] then Hekili.UseAbility[id] = {} end
			if not Hekili.UseAbility[id][i] then Hekili.UseAbility[id][i] = {} end

			Hekili.UseAbility[id][i].name 			= useAction
			Hekili.UseAbility[id][i].caption		= useCaption
			Hekili.UseAbility[id][i].cast			= module.spells[ useAction ].handler( state ) or 0
			Hekili.UseAbility[id][i].cooldown		= useCooldown
			Hekili.UseAbility[id][i].time			= state.time
			Hekili.UseAbility[id][i].start			= startTime

			local start, duration

			if module.spells[ useAction ].item then
				start, duration = GetItemCooldown( module.spells[ useAction ].id )
			else
				start, duration = GetSpellCooldown(useAction)
			end

			if not start and not duration then
				start, duration = GetSpellCooldown("Lightning Shield")
			end

			if i == 1 or (i > 1 and duration ~= GCD) then
				Hekili.UI.AButtons[id][i].Cooldown:SetCooldown(start, duration)
			else
				Hekili.UI.AButtons[id][i].Cooldown:SetCooldown(0, 0)
			end

			if useAction == "Synapse Springs" then
				Hekili.UI.AButtons[id][i].Texture:SetTexture(gTexture)
			else
				Hekili.UI.AButtons[id][i].Texture:SetTexture(GetSpellTexture(useAction))
			end		

			if useCaption then
				Hekili.UI.AButtons[id][i].btmText:SetText(useCaption)
			end

			if i < 5 then module.AdvanceState( state, Hekili.UseAbility[id][i].cast ) end
		end
	end

	if id == 'AE' and self.DB.char['Multi-Target Enabled'] then
		if self.DB.char['Multi-Target Illumination'] > 0 and state.tCount >= self.DB.char['Multi-Target Illumination'] then
			ActionButton_ShowOverlayGlow(Hekili.UI.AButtons[id][1])
			Hekili.UI.AButtons[id][1].targets:SetText(state.fsCount .. ' (' .. state.tCount .. ')')
		else
			ActionButton_HideOverlayGlow(Hekili.UI.AButtons[id][1])
			Hekili.UI.AButtons[id][1].targets:SetText(nil)
		end
	end

	for i = 1, 5 do
		if (self.DB.char['Single Target Enabled'] and id == 'ST' and i > Hekili.DB.char['Single Target Icons Displayed']) or
			(self.DB.char['Multi-Target Enabled'] and id == 'AE' and i > Hekili.DB.char['Multi-Target Icons Displayed']) then
			Hekili.UI.AButtons[id][i]:Hide()
		end
		
		if Hekili.UI.AButtons[id][i]:IsShown() then
			if SpellRange.IsSpellInRange(Hekili.UseAbility[id][i].name, 'target') == 0 then
				Hekili.UI.AButtons[id][i].Texture:SetVertexColor(1, 0, 0)
			else
				Hekili.UI.AButtons[id][i].Texture:SetVertexColor(1, 1, 1)
			end
		end
	end

end


function Hekili:UpdateGreenText()

	if self.ActiveModule == self.Modules[ '(none)' ] or not self.UseAbility then
		return
	end

	local simTime = GetTime()
	
	if self.DB.char['Single Target Enabled'] and self.UseAbility.ST and self.UseAbility.ST[1]  then

		if self.UseAbility.ST[1].time <= simTime then
			self.UI.AButtons.ST[1].topText:SetText( '0' )
			simTime = self.UseAbility.ST[1].time
		else
			self.UI.AButtons.ST[1].topText:SetText( tostring( round( self.UseAbility.ST[1].time - simTime, 1 ) ) )
		end

		for i = 2, self.DB.char['Single Target Icons Displayed'] do
			if self.UseAbility.ST[i] and self.UseAbility.ST[i].name then
				if self.ActiveModule.spells[ self.UseAbility.ST[i].name ].offGCD then
					self.UI.AButtons.ST[i].topText:SetText( self.UI.AButtons.ST[i-1].topText:GetText() )
				else
					self.UI.AButtons.ST[i].topText:SetText( tostring( round( self.UseAbility.ST[i].time - simTime, 1 ) ) )
				end
			end
		end

		simTime = GetTime()

	end

	if self.DB.char['Multi-Target Enabled'] and self.UseAbility.AE and self.UseAbility.AE[1] then

		if self.UseAbility.AE[1].time <= simTime then
			self.UI.AButtons.AE[1].topText:SetText( '0' )
			simTime = self.UseAbility.AE[1].time
		else
			self.UI.AButtons.AE[1].topText:SetText( tostring( round( self.UseAbility.AE[1].time - simTime, 1 ) ) )
		end

		for i = 2, self.DB.char['Multi-Target Icons Displayed'] do
			if self.UseAbility.AE[i] and self.UseAbility.AE[i].name then
				if self.ActiveModule.spells[ self.UseAbility.AE[i].name ].offGCD then
					self.UI.AButtons.AE[i].topText:SetText( self.UI.AButtons.AE[i-1].topText:GetText() )
				else
					self.UI.AButtons.AE[i].topText:SetText( tostring( round( self.UseAbility.AE[i].time - simTime, 1 ) ) )
				end
			end
		end

	end
end



function Hekili:HeartBeat()
	if not self:IsEnabled() then
		return
	end

	if self.ActiveModule.auditTrackers then self.ActiveModule.auditTrackers() end

	if self.DB.char['Single Target Enabled'] then	self:ProcessPriorityList( 'ST' ) end
	if self.DB.char['Multi-Target Enabled'] then	self:ProcessPriorityList( 'AE' ) end
	self:UpdateGreenText()
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

	self.lastCast		= {}
	self.lastCast.spell	= ''
	self.lastCast.time	= 0

	self.BossFight		= false
	self.CombatStart	= 0
	self.eqChanged		= GetTime()
	self.TTD			= {}
	
end



-- Borrowed TTD linear regression model from 'Nemo' by soulwhip (with permission).
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


--	SanityCheck()
--	Make sure modules are loaded correctly.
function Hekili:SanityCheck()

	local class = UnitClass("player")
	local specialization = select(2, GetSpecializationInfo(GetSpecialization()))
	local activeSpec = GetActiveSpecGroup()

	local pmod = self.DB.char['Primary Specialization Module']
	local smod = self.DB.char['Secondary Specialization Module']

	-- Check Primary Specialization table.
	if activeSpec == 1 then
		if pmod ~= '(none)' and self.Modules[ pmod ] then
			if self.Modules[pmod].class ~= class then
				self:Print("Module |cFFFF9900" .. pmod .. "|r is not appropriate for your class; unloading.")
				self.DB.char['Primary Specialization Module'] = '(none)'
				pmod = '(none)'
			elseif self.Modules[pmod].spec ~= specialization then
				self:Print("Module |cFFFF9900" .. pmod .. "|r is not appropriate for your specialization; unloading.")
				self.DB.char['Primary Specialization Module'] = '(none)'
				pmod = '(none)'
			end
		end
		self.ActiveModule = self.Modules[ pmod ]
		
	elseif activeSpec == 2 then
		if smod ~= '(none)' and self.Modules[ smod ] then
			if self.Modules[smod].class ~= class then
				self:Print("Module |cFFFF9900" .. smod .. "|r is not appropriate for your class; unloading.")
				self.DB.char['Secondary Specialization Module'] = '(none)'
				smod = '(none)'
			elseif self.Modules[smod].spec ~= specialization then
				self:Print("Module |cFFFF9900" .. smod .. "|r is not appropriate for your specialization; unloading.")
				self.DB.char['Secondary Specialization Module'] = '(none)'
				smod = '(none)'
			end
		end
		self.ActiveModule = self.Modules[ smod ]
	end	

end



-- 	OnEnable()
--	AddOn has been (re)enabled by the user.
function Hekili:OnEnable()

	if self.DB.char.enabled then
		-- Combat Log
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		-- Sanity checking.
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

		-- Saving positions.
		self:RegisterEvent("PLAYER_LOGOUT")

		-- Combat time / boss fight status.
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")

		-- Trigger additional refreshes and cache the last spell cast.
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

		-- Mainly for capturing changes to cooldowns from trinkets.
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

		-- Keybinding w/in Hekili options.
		self:RegisterEvent("UPDATE_BINDINGS")

		-- Time to die.
		self:RegisterEvent("UNIT_HEALTH")

		-- Make sure the module is appropriate for the character.
		self:SanityCheck()
		self:ApplyNameFilters()

		if self.LBF then
			self.stGroup:ReSkin()
			self.aeGroup:ReSkin()
		end
		
	else
		self:Disable()
	end
	
end


--	OnDisable()
--	AddOn has been disabled by the user.
function Hekili:OnDisable()
	
	for i = 1, 5 do
		self.UI.AButtons['ST'][i]:Hide()
		self.UI.AButtons['AE'][i]:Hide()
	end
	
end



