-- Hekili.lua
-- April 2014

local H = Hekili

local SpellRange = LibStub("SpellRange-1.0")
local FormatKey, GetSpecializationID, GetResourceName, RunHandler = H.Utils.FormatKey, H.Utils.GetSpecializationID, H.Utils.GetResourceName, H.Utils.RunHandler
local strtrim = string.trim
local MT = Hekili.MT
local tblCopy = Hekili.Utils.tblCopy


-- OnInitialize()
-- Addon has been loaded by the WoW client (1x).
function H:OnInitialize()
	self.DB = LibStub("AceDB-3.0"):New("HekiliDB", self:GetDefaults())
	
	self.Options = self:GetOptions()
	self.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.DB)
	
	-- Add dual-spec support
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.DB, "Hekili")
	LibDualSpec:EnhanceOptions(self.Options.args.profiles, self.DB)

	self.DB.RegisterCallback(self, "OnProfileChanged",	"TotalRefresh")
	self.DB.RegisterCallback(self, "OnProfileCopied",	"TotalRefresh")
	self.DB.RegisterCallback(self, "OnProfileReset",	"TotalRefresh")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Hekili", self.Options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Hekili", "Hekili")
	self:RegisterChatCommand("hekili", "CmdLine")
	self:RegisterChatCommand("hek", "CmdLine")
	
	self.ACD = LibStub("AceConfigDialog-3.0")

	self.combat		= 0
	self.Boss		= false
	self.faction	= UnitFactionGroup('player')
	self.TTD		= {}
	self.Hardcasts	= true
	
	self:RefreshBindings()

	if not Hekili.DB.profile.Version or Hekili.DB.profile.Version < 2 then
		Hekili.DB:ResetDB()
	end
	
	self:RestoreDefaults()
	self:LoadScripts()
	self:BuildUI()
	self:UnregisterAllEvents()
end


-- Convert SimC syntax to Lua conditionals.
function SimToLua( str, assign )
	
	-- If no conditions were provided, function should return true.
	if not str or str == '' then return nil end
	
	-- Strip comments.
	str = str:gsub("^%-%-.-\n", "")
		
	-- Replace '%' for division with actual division operator '/'.
	str = str:gsub("%%", "/")
	
	-- Replace '&' with ' and '.
	str = str:gsub("&", " and ")
	
	-- Replace '|' with ' or '.
	str = str:gsub("||", " or "):gsub("|", " or ")
	
	-- Replace '!' with ' not '.
	str = str:gsub("!([^=])", " not %1")
	
	-- Condense whitespace.
	str = str:gsub("%s+", " ")
	
	-- Condense parenthetical spaces.
	str = str:gsub("[(][%s+]", "("):gsub("[%s+][)]", ")")

	if not assign then
		-- Replace assignment '=' with conditional '=='
		str = str:gsub("=", "==")
		
		-- Fix any conditional '==' that got impacted by previous.
		str = str:gsub("==+", "==")
		str = str:gsub(">=+", ">=")
		str = str:gsub("<=+", "<=")
		str = str:gsub("!=+", "~=")
		str = str:gsub("~=+", "~=")
	end
	
	return ( str )
end


function Hekili:ConvertScript( node, hasModifiers )
	local Translated		= SimToLua( node.Script )
	local sFunction, Error	= Translated and loadstring( 'return ' .. Translated ) or nil, nil
	local sElements		= Translated and self:ScriptElements( Translated ) or nil
	
	local Output			= {}
	
	if sFunction then
		setfenv( sFunction, self.State )
	end

	Output = {
		Conditions	= sFunction,
		Error		= Error,
		Elements	= sElements,
		Modifiers	= {},
		
		Lua			= Translated,
		SimC		= node.Script and strtrim( node.Script ) or nil
	}
	
	if hasModifiers and ( node.Args and node.Args ~= '' ) then
		local tModifiers	= SimToLua( node.Args, true )
		
		for m in tModifiers:gmatch("[^,|^$]+") do
			local Key, Value = m:match("(.-)=(.-)$")
			
			if Key and Value then
				local sFunction, Error = loadstring( 'return ' .. Value )
				
				if sFunction then
					setfenv( sFunction, self.State )
					Output.Modifiers[ Key ] = sFunction
				end
			end
		end
	end

	return Output
end


function Hekili:GatherValues( node )
	if not node.Elements then
		return nil
	end

	local Output = {}
	
	for k, v in pairs( node.Elements ) do
		_, Output[k] = pcall( v )
	end
	
	return Output
end


function Hekili:LoadScripts()
	self.Scripts	= self.Scripts or { D = {}, P = {}, A = {} }

	local Displays, Hookrities, Actions = self.Scripts.D, self.Scripts.P, self.Scripts.A
	local Profile = self.DB.profile
	
	for i, _ in ipairs( Displays ) do
		Displays[i] = nil
	end
	
	for k, _ in pairs( Hookrities ) do
		Hookrities[k] = nil
	end
	
	for k, _ in pairs( Actions ) do
		Actions[k] = nil
	end
	
	for i, display in ipairs( self.DB.profile.displays ) do
		Displays[ i ] = self:ConvertScript( display )
		
		for j, priority in ipairs( display.Queues ) do
			local pKey = i..':'..j
			Hookrities[ pKey ] = self:ConvertScript( priority )
		end
	end
	
	for i, list in ipairs( self.DB.profile.actionLists ) do
		for a, action in ipairs( list.Actions) do
			local aKey = i..':'..a
			Actions[ aKey ] = self:ConvertScript( action, true )
		end
	end
end


function StripScript( str, thorough )
	if not str then return 'true' end
	
	-- Remove the 'return ' that was added during conversion.
	str = str:gsub("^return ", "")
	
	-- Remove comments and parentheses.
	str = str:gsub("%-%-.-\n", ""):gsub("[()]", "")
	
	-- Remove conjunctions.
	str = str:gsub("[%s-]and[%s-]", " "):gsub("[%s-]or[%s-]", " "):gsub("%(-%s-not[%s-]", " ")
	
	if not thorough then
		-- Collapse whitespace around comparison operators.
		str = str:gsub("[%s-]==[%s-]", "=="):gsub("[%s-]>=[%s-]", ">="):gsub("[%s-]<=[%s-]", "<="):gsub("[%s-]~=[%s-]", "~="):gsub("[%s-]<[%s-]", "<"):gsub("[%s-]>[%s-]", ">")
	else
		str = str:gsub("[=+]", " "):gsub("[><~]", " "):gsub("[*//-+]", " ")
	end
	
	-- Collapse the rest of the whitespace.
	str = str:gsub("[%s+]", " ")
	
	return ( str )
end


function Hekili:ScriptElements( script )
	local Elements, Check = {}, StripScript( script, true )
	
	for i in Check:gmatch( "%S+" ) do
		if not Elements[i] and not tonumber(i) then
			local eFunction = loadstring( 'return '.. (i or true) )

			if eFunction then setfenv( eFunction, Hekili.State ) end

			local success, value = pcall( eFunction )
		
			Elements[i] = eFunction
		end
	end
	
	return Elements
end			
	


function Hekili:CheckScript( cat, key, action, override )
	
	if action then self.State.this_action = action end

	local tblScript = self.Scripts[ cat ][ key ]
	
	if not tblScript then
		return false
	
	elseif not tblScript.Conditions then
		return true

	else
		local success, value = pcall( tblScript.Conditions )
	
		if success then
			return value
		end
	end
	
	return false
	
end


function Hekili:GetModifiers( list, entry )

	local mods = {}
	
	if not self.Scripts['A'][list..':'..entry].Modifiers then return mods end
	
	for k,v in pairs( self.Scripts['A'][list..':'..entry].Modifiers ) do
		local success, value = pcall(v)
		if success then mods[k] = value end
	end

	return mods

end
	


function H:OnEnable()

	self:RefreshBindings()
	self:BuildUI()

	-- May want to refresh configuration options, key bindings.
	if self.DB.profile.Enabled then
		-- Combat Log (targets, debuffs).
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		
		-- Sanity checks, may want to just get this into the RefreshOptions() from profile handling.
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		
		-- Saving UI positions.
		self:RegisterEvent("PLAYER_LOGOUT")

		-- Grab some player data.
		self:PLAYER_ENTERING_WORLD()
		
		-- Combat time / boss fight status.
		self:RegisterEvent("ENCOUNTER_START")
		self:RegisterEvent("ENCOUNTER_END")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		self:RegisterEvent("GLYPH_ADDED")
		self:RegisterEvent("GLYPH_REMOVED")
		self:RegisterEvent("GLYPH_UPDATED")

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

		if self.MSQ and self.msqGroup then
			self.msqGroup:ReSkin()
		end
		
		for i = 1, #self.DB.profile.displays do
			Hekili:ProcessHooks( i )
		end
		C_Timer.After( 1 / self.DB.profile['Updates Per Second'], Hekili.UpdateDisplays )
		C_Timer.After( 1, Hekili.Audit )
	
	else
		self:Disable()

	end
	
end


function H:OnDisable()
	self.DB.profile.Enabled = false
end


-- Texture Caching, 
local s_textures = setmetatable( {},
	{
		__index = function(t, k)
			local a = _G[ 'GetSpellTexture' ](k)
			if a then t[k] = a end
			return (a)
		end
	} )

-- Insert textures that don't work well with predictions.@
s_textures[GetSpellInfo(115356)]	= 'Interface\\Icons\\ability_skyreach_four_wind'	-- Windstrike
s_textures[GetSpellInfo(114074)]	= 'Interface\\Icons\\Spell_Fire_SoulBurn'			-- Lava Beam
s_textures[GetSpellInfo(421)]		= 'Interface\\Icons\\Spell_Nature_ChainLightning'	-- Chain Lightning
	
local function GetSpellTexture( spell )
	return ( s_textures[ spell ] )
end


local z_PVP = {
	arena	= true,
	pvp		= true
}


function H:ResetState()

	self.State.now		= GetTime()
	self.State.offset	= 0

		
	self.State.active_dot	= setmetatable( {}, MT.mt_active_dot )
	self.State.buff			= setmetatable( { __fullscan = false }, MT.mt_buffs )
	self.State.cooldown		= setmetatable( {}, MT.mt_cooldowns )
	self.State.debuff		= setmetatable( {}, MT.mt_debuffs )
	self.State.dot			= setmetatable( {}, MT.mt_dots )
	self.State.pet			= setmetatable( {}, MT.mt_pets )
	self.State.stat			= setmetatable( {}, MT.mt_stat )
	self.State.target		= setmetatable( {}, MT.mt_target )
	self.State.toggle 		= setmetatable( {}, MT.mt_toggle )
	self.State.totem		= setmetatable( {}, MT.mt_totem )
	
	self.State.target.casting = nil
	
	for k,_ in pairs( H.Resources ) do
		local key = GetResourceName( k )
		
		self.State[ key ]			= rawget( self.State, key ) or setmetatable( {}, mt_resource )
		self.State[ key ].current	= UnitPower('player', k)
		self.State[ key ].max		= UnitPowerMax('player', k)
		
		if k == UnitPowerType('player') then
			local active, inactive = GetPowerRegen()
			
			if self.State.time > 0 then
				self.State[ key ].regen = active
			else
				self.State[ key ].regen = inactive
			end
		end
	end

	-- Special case spells that suck.
	if self.State.buff.ascendance.up then
		H:SetCooldown( 'ascendance', self.State.buff.ascendance.remains + 165 )
	end
	
	local cast_time, casting = 0, nil

	local spellcast, _, _, _, _, endCast = UnitCastingInfo('player')
	if endCast ~= nil then
		cast_time	= ( endCast / 1000) - GetTime()
		casting		= FormatKey( spellcast )
	end
	
	local spellcast, _, _, _, _, endCast = UnitChannelInfo('player')
	if endCast ~= nil then
		cast_time	= ( endCast / 1000) - GetTime()
		casting		= FormatKey( spellcast )
	end				
	
	if cast_time and casting then
		self:Advance( cast_time )
		if self.Abilities[ casting ] then
			self.State.cooldown[ casting ].expires = self.State.now + self.State.offset + self.Abilities[ casting ].cooldown
		end
		RunHandler( casting )
	end
	
	-- Delay to end of GCD.
	if self.State.cooldown[ self.GCD ].remains > 0 then
		self:Advance( self.State.cooldown[ self.GCD ].remains )
	end

end


function H:Advance( time )
	
	local s = self.State
	
	if time <= 0 then
		return
	end
	
	s.offset = s.offset + time
	
	for k,_ in pairs( self.Resources ) do
		local resKey = GetResourceName( k )
		local resource = self.State[ resKey ]

		if resource.regen ~= 0 then
			resource.current = min( resource.max, resource.current + ( resource.regen * time ) )
		end
	end

end


function HasRequiredResources( ability )

	local s, action = H.State, H.Abilities[ ability ]
	
	if not action then return false end
	
	local cost = action.cost
	
	if not action.cost then
		return true
	
	elseif type( action.cost ) == 'number' then
		local resource = action.resource or SPELL_POWER_MANA
		local resKey = GetResourceName( resource )
		local cost = action.cost
		
		if cost < 0 then
			cost = ( -1 * cost / 100 ) * s[ resKey ].max
		end
		
		if cost > 0 and cost > s[ resKey ].current then
			return false
		end
		
		return true
		
	elseif type( action.cost ) == 'table' then
		for k, aCost in pairs( action.cost ) do
			local resKey = GetResourceName( _G[k] )
			local cost
			
			if type(aCost) == 'function' then
				cost = aCost()
			else
				cost = aCost
			end

			-- If cost is negative, it's actually a gain from the ability.  Ignore it.
			if cost > 0 then
				if cost < 1 then
					-- It's a percentage.
					cost = s[ resKey ].max * cost
				end
				
				if cost > s[ resKey ].current then
					return false
				end
			end
		end
		
		return true
		
	end
	
	-- Should never reach this point.
	return false
	
end
Hekili.HRR = HasRequiredResources
	

function H:UpdateResources( ability )

	local action = H.Abilities[ ability ]
	
	if not action then return end
	
	if not action.cost then
		return
	
	elseif type(action.cost) == 'number' then
		-- This class module is using an early version of AddAbility().
		local resource = action.resource or SPELL_POWER_MANA
		local resKey = GetResourceName( resource )
		local cost = action.cost
		
		if action.cost < 0 then
			-- Number is a percentage.
			cost = ( -1 * cost / 100 ) * self.State[ resKey ].max
		end

		self.State[ resKey ].current = min( max(0, self.State[ resKey ].current - cost), self.State[ resKey ].max )
		
	elseif type(action.cost) == 'table' then
		-- Cost is a table of resource types and change deltas.
		for k, aCost in pairs( action.cost ) do
			local resKey = GetResourceName( _G[k] )
			local cost
			
			if type(aCost) == 'function' then
				cost = aCost()
			else
				cost = aCost
			end
			
			if cost > 0 and cost < 1 then
				-- It's a percentage.
				cost = cost * self.State[ resKey ].max
				
			end

			self.State[ resKey ].current = min( max(0, self.State[ resKey ].current - cost), self.State[ resKey ].max )
			
		end
		
	end
	
end


local function IsKnown( sID )

	if type(sID) ~= 'number' then sID = H.Abilities[ sID ].id end
	if not sID or sID < 0 then return false end

	local s = Hekili.State
	
	-- Check 'Primal Strike' for 'Stormblast' / 'Stormstrike'.
	if H.Specialization == 263 then
		if sID == 115356 then
			return ( s.buff.ascendance.up )
		
		elseif sID == 17364 then
			return ( not s.buff.ascendance.up )
			
		elseif sID == 165341 or sID == 165339 then
			return IsSpellKnown(114049)
			
		end

	elseif H.Specialization == 262 then
		-- Check 'Chain Lightning' for 'Lava Beam'.
		if sID == 114074 then
			return ( IsSpellKnown(421) and s.buff.ascendance.up )
		
		elseif sID == 51505 then
			return true
			
		end

	-- Check 'Spinning Crane Kick' for 'Rushing Jade Wind'.
	elseif sID == 116847 then return ( IsSpellKnown(101546) and s.talent.rushing_jade_wind.enabled )
	
	-- Paladin T90 spells aren't going in the spellbook for some reason.
	elseif sID == 114165 and s.talent.holy_prism.enabled then return true
	
	elseif sID == 114158 and s.talent.lights_hammer.enabled then return true
	
	elseif sID == 114157 and s.talent.execution_sentence.enabled then return true
	
	-- Warrior
	elseif sID == 12294 then return ( IsSpellKnown( 78 ) and H.Specialization == 71 )
	
	end

	-- if sID == 51505 then print( tostring(IsSpellKnown(sID) ) ) end	
	
	return ( IsSpellKnown( sID ) or IsSpellKnown( sID, true ) )

end
Hekili.IsKnown = IsKnown


-- Filter out non-resource driven issues with abilities.
local function IsUsable( spell )

	local s = Hekili.State
	
	-- Hammer of Wrath
	if spell == 'hammer_of_wrath' then
		if IsSpellKnown( 157496 ) then
			return ( s.target.health_pct <= 35 or s.buff.avenging_wrath.up )
		else
			return ( s.target.health_pct <= 20 or s.buff.avenging_wrath.up )
		end
	
	elseif spell == 'execute' then
		return ( s.target.health_pct <= 20 )
	
	end
	
	return true
	
end
Hekili.IsUsable = IsUsable
	

-- Needs to be expanded to handle energy regen before Rogue, Monk, Druid will work.
function WaitTime( action )
	-- Do a basic check before 
	local delay = Hekili.State.cooldown[ action ].remains

	if action == 'ascendance' then
		if Hekili.State.buff.ascendance.up then
			delay = 180 - ( 15 - Hekili.State.buff.ascendance.remains )
		end
	end
	
	return max( delay, Hekili.State.cooldown[ Hekili.GCD ].remains ) 
end


Hekili.Queue = {}
function Hekili:ProcessHooks( dispID )

	if self.DB.profile.Enabled and not self.Pause then
		local s = self.State
		local display = self.DB.profile.displays[ dispID ]
	
		self.Queue[ dispID ] = self.Queue[ dispID ] or {}
		local Queue = self.Queue[ dispID ]

		for i = 1, #Queue do
			Queue[i] = nil
		end
		
		if display and self.DisplayVisible[ dispID ] then
		
			self:ResetState()
			
			if ( self.Config or self:CheckScript( 'D', dispID )  ) then 
			
				for i = 1, display['Icons Shown'] do

					local chosen_action, chosen_caption
					local chosen_wait   = 999
					
					for hookID, hook in ipairs( display.Queues ) do

						if self.HookVisible[ dispID..':'..hookID ] then
							
							local HookPassed = self:CheckScript( 'P', dispID..':'..hookID )
							
							if HookPassed then

								local listID = hook['Action List']
								local list = self.DB.profile.actionLists[ listID ]
								
								-- Only action list criteria is whether it matches the spec.
								if self.ListVisible[ listID ] then

									local actID = 1
									while actID <= #list.Actions do
										if chosen_wait == 0 then
											break
										end
										
										local entry	= list.Actions[ actID ]
										s.this_action	= entry.Ability
										local wait_time = WaitTime( s.this_action )
										
										if self.ActionVisible[ listID..':'..actID ] then
											-- Check for commands before checking actual actions.
											if entry.Ability == 'wait' then
												if self:CheckScript( 'A', listID..':'..actID ) then
													local args = self:GetModifiers( listID, actID )
													if not args.sec then args.sec = 1 end
													if args.sec > 0 then
														self:Advance( args.sec )
														actID = 0
													end

												end
											
											elseif IsKnown( s.this_action ) and IsUsable( s.this_action ) and wait_time < chosen_wait and HasRequiredResources( s.this_action ) and ( self.Abilities[ s.this_action ].cast == 0 or self.DB.profile.Hardcasts ) and self:CheckScript( 'A', listID..':'..actID ) then
												chosen_action	= s.this_action
												chosen_caption	= entry.Caption
												chosen_wait		= wait_time

												Queue[i] = {
													display		= dispID,
													button		= i,
													
													hook		= hookID,
													
													actionlist	= listID,
													action		= actID,
													
													alName		= list.Name,
													actName		= s.this_action,
													
													caption		= chosen_caption,
													wait		= wait_time,
												}
												
											end
										
										end
										
										actID = actID + 1
									
									end
									
								end -- end Action List

							end
							
						end 
						
					end -- end Hookrity Queue
					
					if Queue[i] then
						-- We have our actual action, so let's get the script values if we're debugging.
						if self.DB.profile.Debug then
							local scrHook = self.Scripts.P[ Queue[i].display..':'..Queue[i].hook ]
							Queue[i].HookScript = scrHook.SimC
							Queue[i].HookElements = self:GatherValues( scrHook )
							
							local scrAction = self.Scripts.A[ Queue[i].actionlist..':'..Queue[i].action ]
							Queue[i].ActScript = scrAction.SimC
							Queue[i].ActElements = self:GatherValues( scrAction )
						end
					
						-- Advance through the wait time.
						self:Advance( chosen_wait )
							
						Queue[i].time	= s.offset
						Queue[i].since = i > 1 and ( s.offset - Queue[i - 1].time ) or 0
					
						local action = self.Abilities[ chosen_action ]

						-- We really need to make the timing more sophisticated.
						-- Need to differentiate between abilities being hardcast, abilities off GCD, and GCD instants.
						local gcd = 0
						
						if action.gcdType == 'totem' then
							gcd = 1.0
						elseif action.gcdType == 'spell' then
							gcd = max( 1.0, ( 1.5 * s.spell_haste ) )
						elseif action.gcdType == 'melee' then
							gcd = max( 1.0, ( 1.5 * s.melee_haste ) )
						end
						
						-- Start the GCD.
						s.cooldown[ self.GCD ].expires = s.now + s.offset + gcd
						
						-- Advance the clock by cast_time.
						self:Advance( action.cast )
						
						-- Put the action on cooldown.  (It's slightly premature, but addresses CD resets like Echo of the Elements.)
						s.cooldown[ chosen_action ].expires = s.now + s.offset + action.cooldown
						
						-- Perform the action.
						RunHandler( chosen_action )
						
						-- Spend/gain resources.
						self:UpdateResources( chosen_action )

						-- Move the clock forward if the GCD hasn't expired.
						if s.cooldown[ self.GCD ].expires > s.now + s.offset then
							self:Advance( s.cooldown[ self.GCD ].expires - ( s.now + s.offset ) )
						end
						
					else
						for n = i, display['Icons Shown'] do
							Queue[n] = nil
						end
						break
					end	
					
				end
				
				self.Queue[ dispID ] = Queue
				
			end

		end
		
	end

	if self.DB.profile.Enabled and self.DB.profile.displays[ dispID ] then
		C_Timer.After( 1 / self.DB.profile['Updates Per Second'], function() Hekili:ProcessHooks( dispID ) end )
	end
	
end


function CheckDisplayCriteria( dispID )
	
	local display = Hekili.DB.profile.displays[ dispID ]
	local _, zoneType = IsInInstance()
	
	local pvpZones = {
		arena	= true,
		pvp		= true
	}
	
	if not Hekili.DisplayVisible[ dispID ] then
		return false
		
	elseif not pvpZones[ zoneType ] and display['PvE Visibility'] ~= 'always' then
		if display['PvE Visibility'] == 'combat' and ( not UnitAffectingCombat('player') and not UnitCanAttack('player', 'target') ) then
			return false
			
		elseif display['PvE Visibility'] == 'target' and not UnitCanAttack('player', 'target') then
			return false
			
		elseif display['PvE Visibility'] == 'zzz' and not pvpZones[ zoneType ] then
			return false
			
		end
	
	elseif pvpZones[ zoneType ] and display['PvP Visibility'] ~= 'always' then
		if display['PvP Visibility'] == 'combat' and ( not UnitAffectingCombat('player') and not UnitCanAttack('player', 'target') ) then
			return false
			
		elseif display['PvP Visibility'] == 'target' and not UnitCanAttack('player', 'target') then
			return false
		
		elseif display['PvP Visibility'] == 'zzz' then
			return false
			
		end
		
	elseif not Hekili.Config and not Hekili.Queue[ dispID ] then
		return false
		
	end
	
	return true
end



local lastDisplay = {}

function H:UpdateDisplays()

	local self = Hekili

	if not self.DB.profile.Enabled then
		return
	end

	for dispID, display in pairs(self.DB.profile.displays) do
	
		if self.Pause then
			self.UI.Buttons[ dispID ][1].Overlay:SetTexture('Interface\\Addons\\Hekili\\Textures\\Pause.blp')
			self.UI.Buttons[ dispID ][1].Overlay:Show()

		else
			self.UI.Buttons[ dispID ][1].Overlay:Hide()
		
			if CheckDisplayCriteria( dispID ) then
				local Queue = self.Queue[ dispID ]

				local gcd_start, gcd_duration = GetSpellCooldown( self.Abilities[ self.GCD ].id )
				
				for i, button in ipairs( self.UI.Buttons[dispID] ) do
					if not Queue or not Queue[i] and ( self.DB.profile.Enabled or self.Config ) then
						for n = i, display['Icons Shown'] do
							self.UI.Buttons[dispID][n].Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')
							self.UI.Buttons[dispID][n].Texture:SetVertexColor(1, 1, 1)
							self.UI.Buttons[dispID][n].Caption:SetText(nil)
							if not self.Config then
								self.UI.Buttons[dispID][n]:Hide()
							else
								self.UI.Buttons[dispID][n]:Show()
							end
						end
						break
					end
					
					local aKey, caption = Queue[i].actName, Queue[i].caption
				
					if aKey then
						button:Show()
						button.Texture:SetTexture( GetSpellTexture( self.Abilities[ aKey ].name ) )
						button.Texture:Show()
						
						if display['Action Captions'] then
							if i == 1 then
								button.Caption:SetJustifyH('RIGHT')
								-- check for special captions.
								if display['Primary Caption'] == 'targets' and self:NumTargets() > 1 then
									button.Caption:SetText( self:NumTargets() )

								elseif display['Primary Caption'] == 'buff' then
									if display['Primary Caption Aura'] then
										local name, _, _, count, _, _, expires = UnitBuff( 'player', display['Primary Caption Aura'] )
										if name then button.Caption:SetText( count or 1 )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
									end

								elseif display['Primary Caption'] == 'debuff' then
									if display['Primary Caption Aura'] then
										local name, _, _, count = UnitDebuff( 'target', display['Primary Caption Aura'] )
										if name then button.Caption:SetText( count or 1 )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
									end

								elseif display['Primary Caption'] == 'ratio' then
									if display['Primary Caption Aura'] then
										if H:DebuffCount( display['Primary Caption Aura'] ) > 0 or H:NumTargets() > 1 then
											button.Caption:SetText( H:DebuffCount( display['Primary Caption Aura'] ) .. ' / ' .. H:NumTargets() )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
									end

								else
									button.Caption:SetJustifyH('CENTER')
									button.Caption:SetText(caption)
									
								end
							else
								button.Caption:SetJustifyH('CENTER')
								button.Caption:SetText(caption)
							
							end
						else
							button.Caption:SetJustifyH('CENTER')
							button.Caption:SetText(nil)

						end
						
						local start, duration = GetSpellCooldown( self.Abilities[ aKey ].id )
						
						if not start or start == 0 or duration < gcd_duration then
							start		= gcd_start
							duration	= gcd_duration
						end
						
						if i == 1 then
							if H.Abilities[ aKey ].gcdType == 'off' then
								button.Cooldown:SetCooldown( 0, 0 )
							else
								button.Cooldown:SetCooldown( start, duration )
							end
							
						else
							if ( start + duration > gcd_start + gcd_duration ) then
								button.Cooldown:SetCooldown( start, duration )
							else
								button.Cooldown:SetCooldown( 0, 0 )
							end
						end

						if SpellRange.IsSpellInRange( self.Abilities[ aKey ].name, 'target') == 0 then
							self.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
						elseif i == 1 and select(2, IsUsableSpell( self.Abilities[ aKey ].name )) then
							self.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
						else
							self.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
						end
						

					else
						self.UI.Buttons[dispID][i].Texture:SetTexture( nil )
						self.UI.Buttons[dispID][i].Cooldown:SetCooldown( 0, 0 )
						self.UI.Buttons[dispID][i]:Hide()
					
					end

				end
				
			else
				for i, button in ipairs(self.UI.Buttons[dispID]) do
					button:Hide()
					
				end
			end
		end
	end
	
	if self.DB.profile.Enabled then
		C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self.UpdateDisplays )
	end
	
end


