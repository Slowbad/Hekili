-- Hekili.lua
-- April 2014

local H = Hekili

local SpellRange = LibStub("SpellRange-1.0")
local FormatKey, GetSpecializationID, GetResourceName, RunHandler = H.Utils.FormatKey, H.Utils.GetSpecializationID, H.Utils.GetResourceName, H.Utils.RunHandler
local mt_resource = Hekili.MT.mt_resource


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

	self.DB.RegisterCallback(self, "OnProfileChanged",	"RefreshOptions")
	self.DB.RegisterCallback(self, "OnProfileCopied",	"RefreshOptions")
	self.DB.RegisterCallback(self, "OnProfileReset",	"RefreshOptions")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Hekili", self.Options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Hekili", "Hekili")
	self:RegisterChatCommand("hekili", "CmdLine")
	self:RegisterChatCommand("hek", "CmdLine")
	
	self.ACD = LibStub("AceConfigDialog-3.0")

	self.combat		= 0
	self.boss		= false
	self.faction	= UnitFactionGroup('player')
	self.TTD		= {}
	self.Hardcasts	= true
	
	self:RefreshBindings()
	self:BuildUI()

	if not Hekili.DB.profile.Version or Hekili.DB.profile.Version < 2 then
		Hekili.DB:ResetDB()
	end
	
	self:CheckForActionLists()
	self:LoadScripts()
	self:UnregisterAllEvents()
end


-- Convert SimC syntax to Lua conditionals.
function SimToLua( str, assign )
	
	-- If no conditions were provided, function should return true.
	if not str or str == '' then return 'true' end
	
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


function H:LoadScripts()

	self.Scripts      = self.Scripts or {}
	self.Scripts['D'] = self.Scripts['D'] or {} -- displays
	self.Scripts['P'] = self.Scripts['P'] or {} -- priority queues
	self.Scripts['A'] = self.Scripts['A'] or {} -- actions
	
 	for i,v in ipairs( self.Scripts['D'] ) do
		table.wipe( self.Scripts['D'][i] )
	end
	for i,v in ipairs( self.Scripts['P'] ) do
		table.wipe( self.Scripts['P'][i] )
	end
	for k,v in pairs( self.Scripts['A'] ) do
		table.wipe( self.Scripts['A'][k] )
	end

	for i, display in ipairs( self.DB.profile.displays ) do

		local script_str	= SimToLua( display.Script )
		local script, err	= loadstring( 'return ' .. script_str )
		
		if script then setfenv( script, self.state ) end

		self.Scripts['D'][i] = {
			script		= script,
			str			= script_str,
			error		= err
		} 
		
		for q, priority in ipairs( display.Queues ) do
			local key			= 'D' .. i .. '-' .. q
			
			local script_str	= SimToLua( priority.Script )
			local script, err	= loadstring( 'return ' .. script_str )

			if script then setfenv( script, self.state ) end

			self.Scripts['P'][key] = {
				script		= script,
				error		= err,
				translated	= script_str ~= 'true' and script_str or nil,
				entered		= priority.Script ~= '' and priority.Script or nil,
			}
		end
	end

	for i, list in ipairs( self.DB.profile.actionLists ) do
		for a, action in ipairs( list.Actions ) do
			local key		= 'L' .. i .. '-' .. a
	
			local script_str	= SimToLua( action.Script )
			local script, err	= loadstring( 'return ' .. script_str )
			
			if script then setfenv( script, self.state ) end

			self.Scripts['A'][key] = {
				script		= script,
				error		= err,
				translated	= script_str ~= 'true' and script_str or nil,
				entered		= action.Script,
				mods		= {}
			}	

			if action.Args and action.Args ~= '' then
				local mods = self.Scripts['A'][key].mods
				
				local mod_str	= SimToLua( action.Args, true )
				for m in mod_str:gmatch("[^,|^$]+") do
					local var, val = m:match("(.-)=(.-)$")
					
					if var and val then
						local m_script, err = loadstring( 'return ' .. val )
						if m_script then setfenv( m_script, self.state ) end
					
						mods[var] = m_script
					end
				end
			end
		end
	end 
	
end


function StripScript( str, thorough )
	if not str then return 'true' end
	
	-- Remove the 'return ' that was added during conversion.
	str = str:gsub("return ", "")
	
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


function ThoroughlyCheck( str )
	local err, found = nil, false

	local check = StripScript( str, true )
	
	for i in check:gmatch("%S+") do
		local test = loadstring( 'return ' .. ( i or true ) )
		
		if test then setfenv( test, Hekili.state ) end
			
		local success, out = pcall ( test )
		
		if tostring(out) ~= i then
			if success then
				if type(out) == 'number' then
					err = string.format("%s%s%s: %.2f", ( err or '' ), ( found and '\n   ' or '   ' ), i, out)
				else
					err = string.format("%s%s%s: %s", ( err or '' ), ( found and '\n   ' or '   ' ), i, tostring(out))
				end
			else
				err = ( err or '' ) .. ( found and '\n   ' or '   ') .. ( out:match("^.*: (.*)") or out )
			end
			found = true
		end
	end
	
	return err
end


function Hekili:ScriptElements( str )
	local found	= false
	local sElems 	= {}
	
	str = SimToLua(str)

	local check	= StripScript( str, true )
	
	for i in check:gmatch("%S+") do
		local test = loadstring( 'return ' .. ( i or true ) )
		
		if test then setfenv( test, Hekili.state ) end
		
		local success, out = pcall ( test )
		
		-- Rule out constants.
		if tostring(out) ~= i then
			local found = false
			for n = 1, #sElems, 2 do
				if sElems[n] == i then
					found = true
					break
				end
			end
			
			if not found then
				sElems[ #sElems + 1 ] = i
				if success then
					sElems[ #sElems + 1 ] = out
				else
					sElems[ #sElems + 1 ] = out:match("^.*: (.*)") or out
				end
			end
		end
	end
	
	return sElems
end
	


function H:CheckScript( cat, arg1, arg2, action )

	if action then self.state.this_action = action end

	local success, value
	local script = nil
	
	if cat == 'D' then -- Displays
		success, value = pcall( self.Scripts['D'][arg1].script )
		
	elseif cat == 'P' then -- Priority Queue
		success, value = pcall( self.Scripts['P']['D'..arg1..'-'..arg2].script )

		if success then
			local script = self.Scripts['P']['D'..arg1..'-'..arg2].entered
			local elements = self:ScriptElements( script )
			
			if script then script = string.trim(script) end
			return value, script, elements
		end
		
	elseif cat == 'A' then -- Action
		success, value = pcall( self.Scripts['A']['L'..arg1..'-'..arg2].script )
		
		if success then
			local script = self.Scripts['A']['L'..arg1..'-'..arg2].entered
			local elements = self:ScriptElements( script )
			
			if script then script = string.trim(script) end
			return value, script, elements
		end
		
	else
		return false
	
	end
	
	if not success then
		return false
	end
		
	return value
end


function H:GetModifiers( list, entry )

	local mods = {}
	
	if not self.Scripts['A']['L'..list..'-'..entry].mods then return mods end
	
	for k,v in pairs( self.Scripts['A']['L'..list..'-'..entry].mods ) do
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
	
	else
		self:Disable()

	end
	
end


function H:OnDisable()
	self.DB.profile.Enabled = false
end


function H.HeartBeat()
	-- Should probably check this in the pulse tool rather than here.
	H:ProcessActionLists()
	H:UpdateDisplays()
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
s_textures[GetSpellInfo(115356)] = 'Interface\\Icons\\ability_skyreach_four_wind'	-- Windstrike
s_textures[GetSpellInfo(114074)] = 'Interface\\Icons\\Spell_Fire_SoulBurn'			-- Lava Beam
s_textures[GetSpellInfo(421)] = 'Interface\\Icons\\Spell_Nature_ChainLightning'	-- Chain Lightning
	

	
	
	
local function GetSpellTexture( spell )
	return ( s_textures[ spell ] )
end


local z_PVP = {
	arena	= true,
	pvp		= true
}


function H:ResetState()

	self.state.now		= GetTime()
	self.state.offset	= 0

	for k,_ in pairs( self.state.cooldown ) do
		self.state.cooldown[k] = nil
	end
	
	for k,_ in pairs( self.state.pet ) do
		self.state.pet[k] = nil
	end
	
	for k,_ in pairs( self.state.totem ) do
		self.state.totem[k] = nil
	end
	
	for k,_ in pairs( self.state.dot ) do
		self.state.dot[k] = nil
	end
	
	for k,_ in pairs( self.state.buff ) do
		self.state.buff[k] = nil
	end
	rawset(self.state.buff, "__fullscan", false)
	
	for k,_ in pairs( self.state.debuff ) do
		self.state.debuff[k] = nil
	end
	
	for k,_ in pairs( self.state.action ) do
		self.state.action[k] = nil
	end
	
	self.state.target.casting = nil
	
	for k,_ in pairs( H.Resources ) do
		local key = GetResourceName( k )
		
		self.state[ key ]			= rawget( self.state, key ) or setmetatable( {}, mt_resource )
		self.state[ key ].current	= UnitPower('player', k)
		self.state[ key ].max		= UnitPowerMax('player', k)
		
		if k == UnitPowerType('player') then
			local active, inactive = GetPowerRegen()
			
			if self.state.time > 0 then
				self.state[ key ].regen = active
			else
				self.state[ key ].regen = inactive
			end
		end
	end

	-- Special case spells that suck.
	if self.state.buff.ascendance.up then
		H:SetCooldown( 'ascendance', self.state.buff.ascendance.remains + 165 )
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
		if self.Abilities[ casting] then
			self.state.cooldown[ casting ].expires = self.state.now + self.state.offset + self.Abilities[ casting ].cooldown
		end
		RunHandler( casting )
	end
	
	-- Delay to end of GCD.
	if self.state.cooldown[ self.GCD ].remains > 0 then
		self:Advance( self.state.cooldown[ self.GCD ].remains )
	end

end


function H:Advance( time )
	
	local s = self.state
	
	if time <= 0 then
		return
	end
	
	s.offset = s.offset + time
	
	for k,_ in pairs( self.Resources ) do
		local resKey = GetResourceName( k )
		local resource = self.state[ resKey ]

		if resource.regen ~= 0 then
			resource.current = min( resource.max, resource.current + ( resource.regen * time ) )
		end
	end

end


function HasRequiredResources( ability )

	local s, action = H.state, H.Abilities[ ability ]
	
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
			cost = ( -1 * cost / 100 ) * self.state[ resKey ].max
		end

		self.state[ resKey ].current = min( max(0, self.state[ resKey ].current - cost), self.state[ resKey ].max )
		
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
				cost = cost * self.state[ resKey ].max
				
			end

			self.state[ resKey ].current = min( max(0, self.state[ resKey ].current - cost), self.state[ resKey ].max )
			
		end
		
	end
	
end


local function IsKnown( sID )

	if type(sID) ~= 'number' then sID = H.Abilities[ sID ].id end
	if not sID or sID < 0 then return false end

	local s = Hekili.state
	
	-- Check 'Primal Strike' for 'Stormblast' / 'Stormstrike'.
	if H.Specialization == 263 then
		if sID == 115356 then
			return ( s.buff.ascendance.up )
		
		elseif sID == 17364 then
			return ( not s.buff.ascendance.up )
			
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

	local s = Hekili.state
	
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
	local delay = Hekili.state.cooldown[ action ].remains

	if action == 'ascendance' then
		if Hekili.state.buff.ascendance.up then
			delay = 180 - ( 15 - Hekili.state.buff.ascendance.remains )
		end
	end
	
	return max( delay, Hekili.state.cooldown[ Hekili.GCD ].remains ) 
end


Hekili.Queue = {}
function H:ProcessActionLists()

	if not self.DB.profile.Enabled or self.Pause then
		return
	end

	local s = self.state
	
	for dispID, display in ipairs(self.DB.profile.displays) do
	
		self.Queue[ dispID ] = self.Queue[ dispID ] or {}
		local Queue = self.Queue[ dispID ]

		for i = 1, #Queue do
			Queue[i] = nil
		end
		
		self:ResetState()
		
		if display.Enabled and ( display.Specialization == 0 or display.Specialization == GetSpecializationID() ) and ( self.Config or self:CheckScript( 'D', dispID )  ) then 
			for i = 1, display['Icons Shown'] do
				local chosen_action, chosen_caption
				local chosen_wait   = 999
				
				Queue[i] = {}
				
				for prioIdx, priority in ipairs( display.Queues ) do
					local PrioPassed, PrioCriteria, PrioElements = self:CheckScript( 'P', dispID, prioIdx )

					if priority.Enabled and priority['Action List'] ~= 0 and PrioPassed then
						local listIdx = priority['Action List']
						local list = self.DB.profile.actionLists[ listIdx ]
						
						-- Only action list criteria is whether it matches the spec.
						if list.Specialization == 0 or list.Specialization == self.Specialization then
							local n = 1
							while n <= #list.Actions do
								if chosen_wait == 0 then
									break
								end
								
								local entry	= list.Actions[ n ]
								s.this_action	= entry.Ability
								
								if entry.Enabled and entry.Ability then
									local CriteriaPassed, Criteria, Elements = self:CheckScript( 'A', listIdx, n )
								
									-- Check for commands before checking actual actions.
									if entry.Ability == 'wait' then
										if CriteriaPassed then
											local args = self:GetModifiers( listIdx, n )
											if not args.sec then args.sec = 1 end
											if args.sec > 0 then
												self:Advance( args.sec )
												n = 0
											end

										end
									
									elseif ( self.Abilities[ s.this_action ].cast == 0 or self.Hardcasts ) and IsKnown( s.this_action ) and IsUsable( s.this_action ) and HasRequiredResources( s.this_action ) and CriteriaPassed then
										local wait_time = WaitTime( s.this_action )
										
										if wait_time < chosen_wait then
											chosen_action	= s.this_action
											chosen_caption	= entry.Caption or ''
											chosen_wait		= wait_time

											Queue[i].display	= dispID
											Queue[i].button	= i

											Queue[i].action	= s.this_action
											
											Queue[i].action_list = list.Name
											Queue[i].entry		= n
											
											Queue[i].prioScript	= PrioCriteria
											Queue[i].prioElements	= PrioElements

											Queue[i].script	= Criteria
											Queue[i].elements	= Elements

											Queue[i].caption	= chosen_caption
											Queue[i].wait		= wait_time
										end
										
									end
								
								end
								
								n = n + 1
							
							end
							
						end -- end Action List

					end 
					
				end -- end Priority Queue
				
				-- Advance through the wait time.
				self:Advance( chosen_wait )
					
				Queue[i].time	= s.offset
				Queue[i].since = i > 1 and ( s.offset - Queue[i - 1].time ) or 0
				
				if chosen_action then
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
			self:ResetState()
			
		end

	end

end


function CheckDisplayCriteria( dispID )
	
	local display = Hekili.DB.profile.displays[ dispID ]
	local _, zoneType = IsInInstance()
	
	local pvpZones = {
		arena	= true,
		pvp		= true
	}
	
	if not display['Enabled'] then
		return false
		
	elseif display['Talent Group'] ~= 0 and display['Talent Group'] ~= GetActiveSpecGroup() then
		return false
		
	elseif display['Specialization'] ~= 0 and display['Specialization'] ~= GetSpecializationID() then
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
		
	elseif not H:CheckScript( 'D', dispID ) then
		return false
		
	end
	
	return true
end



function H:UpdateDisplays()

	if not self.DB.profile.Enabled then
		return
	end

	for dispID, display in pairs(self.DB.profile.displays) do
	
		if self.Pause then
			self.UI.Buttons[ dispID ][1].Overlay:SetTexture('Interface\\Addons\\Hekili\\Textures\\Pause.blp')
			self.UI.Buttons[ dispID ][1].Overlay:Show()

		else
			self.UI.Buttons[ dispID ][1].Overlay:Hide()
		
			if CheckDisplayCriteria( dispID ) and self.Queue[ dispID ] then
				local Queue = self.Queue[ dispID ]

				if Queue then
					local gcd_start, gcd_duration = GetSpellCooldown( self.Abilities[ self.GCD ].name )
					
					for i, button in ipairs( self.UI.Buttons[dispID] ) do
						if not Queue[i] and ( self.DB.profile.Enabled or self.Config ) then
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
						
						local aKey, caption = Queue[i].action, Queue[i].caption
					
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
											local name, _, _, count = UnitDebuff( 'target', display['Primary Caption Aura'], nil, 'PLAYER' )
											if name then
												button.Caption:SetText( H:DebuffCount( display['Primary Caption Aura'] ) .. ' / ' .. H:NumTargets() )
											else
												if self:NumTargets() > 0 then button.Caption:SetText( '0 / ' .. self:NumTargets() )
												else
													button.Caption:SetJustifyH('CENTER')
													button.Caption:SetText(caption)
												end
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
							
							local start, duration = GetSpellCooldown( self.Abilities[ aKey ].name )
							
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
						
				end
				
			else
				for i, button in ipairs(self.UI.Buttons[dispID]) do
					button:Hide()
					
				end
			end
		end
	end
end


