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

-- Caching texture names reduces calls to the API...  And lets us inject some texture names for dynamic abilities that GetSpellTexture() hates by default.
Hekili.textureCache['Lava Beam'] = 'Interface\\Icons\\Spell_Fire_SoulBurn'
Hekili.textureCache['Stormblast'] = 'Interface\\Icons\\Spell_Lightning_LightningBolt01'
Hekili.textureCache['Virmen\'s Bite'] = 'Interface\\ICONS\\TRADE_ALCHEMY_POTIOND6'
Hekili.textureCache['Potion of the Jade Serpent'] = 'Interface\\Icons\\trade_alchemy_potiond4'

local function GetSpellTexture(a)
	return Hekili.textureCache[a]
end


-- Check for PvP.
local pvpZones = {
	arena = true,
	pvp = true,
}


-- Synapse Springs detection.
local synapse_springs		= GetSpellInfo(126731)
local gloveUpdate = 0

local iteration = 0

-- Priority DB.
function Hekili:ProcessPriorityList( id )

	local module = Hekili.Active
	
	local _, zoneType = IsInInstance()
	
	if ( not module or not module.enabled[id] ) or
		( self.DB.profile['Visibility'] == 'Show with Target' and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) or
		( self.DB.profile['Visibility'] == 'Show in Combat' and ( not UnitAffectingCombat('player') and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) ) or
		( self.DB.profile['PvP Visibility'] == false and pvpZones[zoneType] ) or
		( self.DB.profile['Single-Target Enabled'] == false and id == 'ST' ) or
		( self.DB.profile['Multi-Target Enabled'] == false and id == 'AE' ) or
		( UnitHasVehicleUI('player') ) then
		for i = 1, 5 do
			Hekili.UI.AButtons[id][i]:Hide()
		end
		return
	end

	local state = self.State
	-- table.wipe(state)

	module:RefreshState( state )

	local startTime = state.time

	if state.pCast > 0 and module.spells[ state.pCasting ] then
		module.spells[ state.pCasting ].handler( state, true )
		module:AdvanceState( state, state.pCast )
	end

	if state.items[synapse_springs] and state.time > gloveUpdate then
		local glovesID = GetInventoryItemID("player", 10)
		local gloves, gTexture

		if glovesID then
			gloves, _, _, _, _, _, _, _, _, gTexture = GetItemInfo(GetInventoryItemID("player", 10))
			self.textureCache[synapse_springs] = gTexture
			gloveUpdate = state.time
		end
	end


	-- Reset Actions
	for i = 1, 5 do
		if self.Actions[id][i] then
			for k,v in pairs( self.Actions[id][i] ) do
				self.Actions[id][i][k] = nil
			end
		end
	end
	
	
	-- BUILD ACTIONS TABLE.
	for i = 1, 5 do
		local useAction			= nil
		local useCaption		= nil
		local useCooldown		= 999

		if self.DB.profile[ 'Show Precombat' ] then
			for line, action in ipairs(module.actionList.precombat) do

				local ckAction, ckWait, ckHardcast, ckCooldown

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.profile['Show Hardcasts'] ) then
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

		if useCooldown > 0 and ( self.DB.profile[ 'Cooldown Enabled' ] and ( id == 'ST' or self.DB.profile[ 'Multi-Target Cooldowns' ] ) ) then
			for line, action in ipairs(module.actionList.cooldown) do

				local ckAction, ckWait, ckHardcast, ckCooldown

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction, true) and ( not ckHardcast or self.DB.profile['Show Hardcasts'] ) then
					
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

		if useCooldown > 0 and ( id == 'AE' or ( self.DB.profile[ 'Integration Enabled' ] and state.tCount >= self.DB.profile[ 'Multi-Target Integration' ] ) ) then
			for line, action in ipairs(module.actionList.aoe) do

				local ckAction, ckWait, ckHardcast, ckCooldown

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.profile['Show Hardcasts'] ) then
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

		if useCooldown > 0 and ( id == 'ST' and ( not self.DB.profile[ 'Integration Enabled' ] or state.tCount < self.DB.profile[ 'Multi-Target Integration' ] ) ) then
			for line, action in ipairs(module.actionList.single) do

				local ckAction, ckWait, ckHardcast, ckCooldown

				ckAction, ckWait, ckHardcast = action.check( state )

				if not ckWait then ckWait = 0 end
				if not ckHardcast then ckHardcast = false end

				if ckAction and not self:IsFiltered(ckAction) and ( not ckHardcast or self.DB.profile['Show Hardcasts'] ) then
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

		-- if not self.Actions[id][i] then self.Actions[id][i] = {} end

		if not useAction then break end

		if useCooldown > 0 then
			module:AdvanceState( state, useCooldown )
		end

		self.Actions[id][i].name 		= useAction
		self.Actions[id][i].cast		= module.spells[ useAction ].handler( state )
		self.Actions[id][i].offGCD		= module.spells[ useAction ].offGCD
		self.Actions[id][i].caption		= useCaption
		self.Actions[id][i].cooldown	= useCooldown
		self.Actions[id][i].start		= startTime
		self.Actions[id][i].time		= state.time
		self.Actions[id][i].offset		= state.time - startTime

		if i < 5 then module:AdvanceState( state, self.Actions[id][i].cast ) end
	end
	-- ACTIONS TABLE COMPLETE.
	
end


function Hekili:DisplayActionButtons( id )

	if 	( self.DB.profile['Visibility'] == 'Show with Target' and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) or
		( self.DB.profile['Visibility'] == 'Show in Combat' and ( not UnitAffectingCombat('player') and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) ) or
		( self.DB.profile['PvP Visibility'] == false and pvpZones[zoneType] ) or
		( self.DB.profile['Single-Target Enabled'] == false and id == 'ST' ) or
		( self.DB.profile['Multi-Target Enabled'] == false and id == 'AE' ) or
		( UnitHasVehicleUI('player') ) then
		for i = 1, 5 do
			self.UI.AButtons[id][i]:Hide()
		end
		return
	end

	local module = self.Active
	local startGCD, GCD = GetSpellCooldown( module:GetGCD() )

	for i = 1, 5 do
		local action = self.Actions[id][i]

		if action.name then		
			if ( action.cooldown <= 30 or i == 1 ) and
				(	( self.DB.profile['Single Target Enabled'] and	id == 'ST' and	i <= self.DB.profile['Single Target Icons Displayed'] ) or
					( self.DB.profile['Multi-Target Enabled'] and	id == 'AE' and	i <= self.DB.profile['Multi-Target Icons Displayed'] )	) then

				self.UI.AButtons[id][i]:Show()

				local start, duration
				
				if module.spells[ action.name ].item then
					start, duration = GetItemCooldown( module.spells[ action.name ].id )
				else
					start, duration = GetSpellCooldown( action.name )
				end

				if not start or start == 0 then
					start = startGCD
					duration = GCD
				end

				-- fix GCD display when action is offGCD
				if	(i == 1 and (duration ~= GCD or not module.spells[ action.name ].offGCD)) or
					(duration ~= GCD) then
					self.UI.AButtons[id][i].Cooldown:SetCooldown(start, duration)
				else
					self.UI.AButtons[id][i].Cooldown:SetCooldown(0, 0)
				end

				self.UI.AButtons[id][i].Texture:SetTexture(GetSpellTexture( action.name ))
				self.UI.AButtons[id][i].btmText:SetText( action.caption )
				if id == 'ST' and i == 1 then Hekili.UI.AButtons[id][i].btmText:SetJustifyH("CENTER") end

				-- Out of Range.
				if self.UI.AButtons[id][i]:IsShown() then
					if SpellRange.IsSpellInRange(self.Actions[id][i].name, 'target') == 0 then
						self.UI.AButtons[id][i].Texture:SetVertexColor(1, 0, 0)
					else
						self.UI.AButtons[id][i].Texture:SetVertexColor(1, 1, 1)
					end
				end

				-- And now, update the text.
				if i == 1 then
					if not self.Active.spells[ self.Actions[id][1].name ].offGCD and self.Actions[id][1].offset ~= 0 then
						self.UI.AButtons[id][1].topText:SetText( string.format("%3.1f", self.Actions[id][1].offset) )
					else
						self.UI.AButtons[id][1].topText:SetText('0.0')
					end
					
					-- Special case for embedded tracker for stacks/targets.
					if id == 'ST' and self.DB.profile['Single Target Tracker'] ~= 'None' and self.Active.trackers[ self.DB.profile['Single Target Tracker'] ] then
						local track = self.Active.trackers[ self.DB.profile['Single Target Tracker'] ]

						local caption = track.caption

						local text = ''
						
						if caption == 'Stacks' then
							if track.unit then
								if not UnitCanAttack('player', track.unit) then
									text = select(4, UnitAura(track.unit, track.aura, nil, "HELPFUL|PLAYER"))

								else -- target or hostile focus
									text = select(4, UnitAura(track.unit, track.aura, nil, "HARMFUL|PLAYER"))

								end
								if not text then text = '' end
								
							end

						elseif caption == 'Targets' then
							if track.type == 'Aura' and self:IsAuraWatched( track.aura ) then
								text = self:AuraCount( track.aura ) .. '/' .. self:TargetCount()

							elseif track.type == 'Cooldown' and self:IsAuraWatched( track.ability ) then
								text = self:AuraCount( track.ability ) .. '/' .. self:TargetCount()

							else
								text = self:TargetCount()

							end
							if text == 0 then text = '' end

						end
						
						if text ~= '' then
							self.UI.AButtons[id][i].btmText:SetText(text)
							self.UI.AButtons[id][i].btmText:SetJustifyH("RIGHT")
						else
							self.UI.AButtons[id][i].btmText:SetText(self.Actions[id][i].caption)
							self.UI.AButtons[id][i].btmText:SetJustifyH("CENTER")
						end
					end					
					
				else
					if self.Actions[id][i].offGCD then
						self.UI.AButtons[id][i].topText:SetText( self.UI.AButtons[id][i-1].topText:GetText() )
					else
						self.UI.AButtons[id][i].topText:SetText( string.format("%3.1f", self.Actions[id][i].offset) )
					end
				end
				
			else
				self.UI.AButtons[id][i]:Hide()
				
			end
		else
			self.UI.AButtons[id][i]:Hide()
			
		end
	end
	

	
end


function Hekili:MaintainActionLists()

	if self.DB.profile.Module == 'None' or not self.Actions or not self.Actions.ST[1].name then
		return
	end

	local now = GetTime()

	local id = 'ST'
	local module = Hekili.Active
	local abStart, abCD
	
	
	if self.Active.spells[ self.Actions[id][1].name ].item then
		abStart, abCD = GetItemCooldown( module.spells[ self.Actions[id][1].name ].id )
	else
		abStart, abCD = GetSpellCooldown( self.Actions[id][1].name )
	end
	
	local startOff

	if abStart and abStart > 0 then
		startOff = abStart + abCD - now
	else
		startOff = 0
	end
	
	self.Actions[id][1].start	= now
	self.Actions[id][1].time	= now + startOff
	self.Actions[id][1].offset	= startOff

	for i = 2, 5 do
		if not self.Actions[id][i].name then break end
		self.Actions[id][i].start	= self.Actions[id][i-1].start
		self.Actions[id][i].time	= self.Actions[id][i-1].time + self.Actions[id][i-1].cast + self.Actions[id][i].cooldown
		self.Actions[id][i].offset	= self.Actions[id][i].time - self.Actions[id][i].start
	end
	
	id = 'AE'

	if not self.Actions[id][1].name then
		return
	end

	local abStart, abCD = GetSpellCooldown( self.Actions[id][1].name )
	local startOff

	if abStart and abStart > 0 then
		startOff = abStart + abCD - now
	else
		startOff = 0
	end
	
	self.Actions[id][1].start	= now
	self.Actions[id][1].time	= now + startOff
	self.Actions[id][1].offset	= startOff

	for i = 2, 5 do
		if not self.Actions[id][i].name then return end
		self.Actions[id][i].start	= self.Actions[id][i-1].start
		self.Actions[id][i].time	= self.Actions[id][i-1].time + self.Actions[id][i-1].cast + self.Actions[id][i].cooldown
		self.Actions[id][i].offset	= self.Actions[id][i].time - self.Actions[id][i].start
	end
end


-- Visual Engine.
function Hekili:UpdateVisuals()

	if self.DB.profile.Module == 'None' or not self.Actions or not self.Actions.ST or not self.Actions.ST[1] then
		return
	end

	-- DISPLAY ALL THE THINGS.
	local module = self.Active
	local startGCD, GCD = GetSpellCooldown( module:GetGCD() )

	self:DisplayActionButtons( 'ST' )
	self:DisplayActionButtons( 'AE' )
	
	if 	( self.DB.profile['Visibility'] == 'Show with Target' and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) or
		( self.DB.profile['Visibility'] == 'Show in Combat' and ( not UnitAffectingCombat('player') and ( not UnitExists("target") or not UnitCanAttack("player", "target") ) ) ) or
		( self.DB.profile['PvP Visibility'] == false and pvpZones[zoneType] ) then
		for i = 1, 5 do
			self.UI.Trackers[i]:Hide()
		end
		return
	end

	-- Light up multi-target.
	if self.DB.profile['Multi-Target Enabled'] then
		if self.DB.profile['Multi-Target Illumination'] > 0 and self:TargetCount() >= self.DB.profile['Multi-Target Illumination'] then
			ActionButton_ShowOverlayGlow(Hekili.UI.AButtons['AE'][1])
		else
			ActionButton_HideOverlayGlow(Hekili.UI.AButtons['AE'][1])
		end
	end

	-- Hekili: FLAG FOR CLEANUP; this is cumbersome.
	for i = 1, 5 do
		if self.DB.profile['Tracker '..i..' Type'] ~= 'None' then
			local tType = self.DB.profile['Tracker '..i..' Type']
			local tShow = self.DB.profile['Tracker '..i..' Show']
			local tAura = self.DB.profile['Tracker '..i..' Aura']
			local tUnit = self.DB.profile['Tracker '..i..' Unit']
			local tName = self.DB.profile['Tracker '..i..' Totem Name']
			local tElement = self.DB.profile['Tracker '..i..' Element']
			local tAbility = self.DB.profile['Tracker '..i..' Ability']

			local text = ''
			local present = false

			if tType == 'Aura' then
				self.UI.Trackers[i].Texture:SetTexture(GetSpellTexture( tAura ) or 'Interface\\ICONS\\Spell_Nature_BloodLust')

				if not UnitCanAttack('player', tUnit) then
					if UnitAura(tUnit, tAura, nil, "HELPFUL|PLAYER") then present = true end
				else
					if UnitAura(tUnit, tAura, nil, "HARMFUL|PLAYER") then present = true end
				end

			elseif tType == 'Cooldown' then
				self.UI.Trackers[i].Texture:SetTexture(GetSpellTexture( tAbility ) or 'Interface\\ICONS\\Spell_Nature_BloodLust')

				local startCD, CD = GetSpellCooldown( tAbility )
				if not CD or (CD <= GCD) then present = true end

			elseif tType == 'Totem' then
				local hasTotem, ttmName, _, _, ttmTexture = GetTotemInfo( totems[tElement] )
				
				if hasTotem and (tName == '' or tName == ttmName) then present = true end
				
				self.UI.Trackers[i].Texture:SetTexture(ttmTexture or 'Interface\\ICONS\\Spell_Nature_BloodLust')
				
			else
				self.UI.Trackers[i].Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')
				
			end
				
			if not self.UI.Trackers[i].Texture:GetTexture() then self.UI.Trackers[i].Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust') end

			if tShow == 'Show Always' or (tShow == 'Present' and present) or (tShow == 'Absent' and not present) then
				self.UI.Trackers[i]:Show()

				local tCaption
				
				if tType == 'Totem' then
					tCaption = self.DB.profile['Tracker '..i..' Totem Caption']
				else
					tCaption = self.DB.profile['Tracker '..i..' Caption']
				end

				if tCaption == 'Stacks' then
					if tUnit then
						if not UnitCanAttack('player', tUnit) then
							text = select(4, UnitAura(tUnit, tAura, nil, "HELPFUL|PLAYER"))

						else -- target or hostile focus
							text = select(4, UnitAura(tUnit, tAura, nil, "HARMFUL|PLAYER"))

						end
					end

				elseif tCaption == 'Targets' then
					if tType == 'Aura' and self:IsAuraWatched( tAura ) then
						text = self:AuraCount( tAura ) .. '/' .. self:TargetCount()

					elseif tType == 'Cooldown' and self:IsAuraWatched( tAbility ) then
						text = self:AuraCount( tAbility ) .. '/' .. self:TargetCount()

					else
						text = self:TargetCount()

					end
				
				end
			else
				self.UI.Trackers[i]:Hide()
				
			end

			self.UI.Trackers[i].btmText:SetText(text)
		else
			self.UI.Trackers[i]:Hide()
		end
	end
	
	self:UpdateTrackerCooldowns()
		
end


function Hekili:UpdateTrackerCooldowns()
	
	for i = 1, 5 do
		if self.DB.profile['Tracker '..i..' Type'] ~= 'None' then
			local tType = self.DB.profile['Tracker '..i..' Type']
			local tCD	= self.DB.profile['Tracker '..i..' Timer']
			
			if tCD == nil then tCD = true end
			
			if not tCD then
				self.UI.Trackers[i].Cooldown:SetCooldown(0, 0)

			elseif tType == 'Cooldown' then
				local tAbility = self.DB.profile['Tracker '..i..' Ability']				

				if tAbility ~= '' then
					local start, duration = GetSpellCooldown(tAbility)
					self.UI.Trackers[i].Cooldown:SetCooldown(start, duration)
					self.UI.Trackers[i].Cooldown:SetReverse(false)
				end
				
			elseif tType == 'Aura' then
				local tAura = self.DB.profile['Tracker '..i..' Aura']
				local tUnit = self.DB.profile['Tracker '..i..' Unit']

				local duration, expires

				if UnitCanAttack('player', tUnit) then
					_, _, _, _, _, duration, expires = UnitAura(tUnit, tAura, nil, "HARMFUL|PLAYER")
				else
					_, _, _, _, _, duration, expires = UnitAura(tUnit, tAura, nil, "HELPFUL|PLAYER")
				end

				if not duration then duration = 0 end
				if not expires then expires = 0 end

				self.UI.Trackers[i].Cooldown:SetCooldown(expires - duration, duration)
				self.UI.Trackers[i].Cooldown:SetReverse(true)

			elseif tType == 'Totem' then
				local tElement = self.DB.profile['Tracker '..i..' Element']

				local present, ttmName, ttmStart, ttmDuration = GetTotemInfo( totems[tElement] )
				
				self.UI.Trackers[i].Cooldown:SetCooldown(ttmStart, ttmDuration)
				self.UI.Trackers[i].Cooldown:SetReverse(true)
			end
				
		else
			self.UI.Trackers[i].Cooldown:SetCooldown(0, 0)
		end
	end

end


function Hekili:HeartBeat()
	if not self:IsEnabled() then
		return
	end

	if self.DB.profile['Single Target Enabled'] then	self:ProcessPriorityList( 'ST' ) end
	if self.DB.profile['Multi-Target Enabled'] then		self:ProcessPriorityList( 'AE' ) end
	
	if self.DB.profile['Module'] == 'None' then
		for i = 1, 5 do
			self.UI.Trackers[i]:Hide()
		end
	end
	
end


function Hekili:RefreshConfig()
	if self.State then table.wipe(self.State) end

	self:ClearAuras()
	self:LoadAuras()

	self:RefreshUI()
	self:LockAllButtons( self.DB.profile.locked )

	self:RefreshBindings()

	self:SanityCheck()
	self:ApplyNameFilters()
end



--	OnInitialize()
--	AddOn has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
	self.DB = LibStub("AceDB-3.0"):New("HekiliDB", self:GetDefaults())
	
	local options = self:GetOptions()
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.DB)
	
	-- Add dual-spec support
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.DB, "Hekili")
	LibDualSpec:EnhanceOptions(options.args.profiles, self.DB)

	self.DB.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.DB.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.DB.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Hekili", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Hekili")
	Hekili:RegisterChatCommand("hekili", function() InterfaceOptionsFrame_OpenToCategory(Hekili.optionsFrame) end)

	self.lastCast		= {}
	self.lastCast.spell	= ''
	self.lastCast.time	= 0

	self.BossFight		= false
	self.CombatStart	= 0
	self.eqChanged		= GetTime()
	self.TTD			= {}
	
	-- Prepare graphical elements (and the engine frame).
	self:InitCoreUI()
	self:UnregisterAllEvents()
end


--	SanityCheck()
--	Make sure modules are loaded correctly.
function Hekili:SanityCheck()

	local class = UnitClass("player")
	
	local specialization = 'none'
	if GetSpecialization() then
		specialization = GetSpecializationInfo(GetSpecialization())
	end

	local mod = self.DB.profile['Module']

	if mod == 'None' then
		-- do nothing
	elseif self.Modules[ mod ] then
		if self.Modules[mod].spec ~= specialization then
			self:Print("Module |cFFFF9900" .. mod .. "|r is not appropriate for your class or specialization; unloading.")
			self.DB.profile['Module'] = 'None'
			mod = 'None'
		end
	else -- mod is not real
		self:Print("Module |cFFFF9900" .. mod .. "|r was not loaded or its name may have changed; unloading.")
		self.DB.profile['Module'] = 'None'
		mod = 'None'
	end
	self.Active = self.Modules[ mod ]

end



-- 	OnEnable()
--	AddOn has been (re)enabled by the user.
function Hekili:OnEnable()

	self:RefreshBindings()
	self:RefreshUI()

	if self.DB.profile.enabled then
		-- Combat Log
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		-- Sanity checking.
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

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

		-- Trackers
		self:RegisterEvent("PLAYER_TARGET_CHANGED")

		-- Keybinding w/in Hekili options.
		self:RegisterEvent("UPDATE_BINDINGS")

		-- Time to die.
		self:RegisterEvent("UNIT_HEALTH")

		-- Make sure the module is appropriate for the character.
		self:SanityCheck()
		self:ApplyNameFilters()
		self:UpdateTrackerCooldowns()
		self:LoadAuras()
		
		if self.LBF then
			self.stGroup:ReSkin()
			self.aeGroup:ReSkin()
			self.trGroup:ReSkin()
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
		self.UI.Trackers[i]:Hide()
	end
	
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
