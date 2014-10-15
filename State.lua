-- State.lua
-- June 2014

-- This is already subject to (another) revamp.  Currently, the addon is doing a better job of requesting only the data it needs regarding
-- the game state, instead of harvesting everything and iterating on it with every prediction.  However, we're flushing that data with each
-- display that gets processed, when I should be keeping the true information in .Snapshot and wiping only the predicted state.
--
-- This is good enough to get out to test.


local H, FormatKey, GetSpecializationID = Hekili, Hekili.Utils.FormatKey, Hekili.Utils.GetSpecializationID


-- This will be our environment table for local functions.
local state	= {}
state.H			= Hekili	-- Because we use the 'state' table as the environment for supporting functions, I'm currently giving this table
							-- access to everything.  Needs cleanup.

state.now		= 0
state.offset	= 0

state.mode_single	= 0
state.mode_cleave	= 1
state.mode_aoe		= 2

state.mainhand_speed	= 0
state.offhand_speed		= 0

-- Some player info.
state.player	= {}
state.race		= {}
state.race[ FormatKey( UnitRace('player') ) ] = 1
state.stat		= {}

state.perk		= {}
state.spec		= {}

-- Limited to totems for the moment.
state.pet		= {}

-- Toggles (keybinds) for activating/deactivating displays, queues, abilities.
state.toggle	= {}

-- Player buffs, talents, glyphs.
state.buff		= {}
state.talent	= {}
state.glyph		= {}

-- Your ability cooldowns.
state.cooldown	= {}

-- Info about a particular action, currently very incomplete.
state.action	= {}

-- Shaman (and presumably Monk, Druid) totems.
state.totem		= {}

-- Set bonuses from gear.
state.set_bonus = {}

-- Some target info.
state.target	= {}

-- (Your) debuffs applied to the target.
state.debuff	= {}

-- Your dots (subset of debuffs) applied.  Should gather some power info.
state.dot		= {}

-- Count how many of your dots are applied with active_dot.spell_name (wrapper for DebuffCount).
state.active_dot = {}


-- Outside commands.
state.max, state.min = max, min
state._G = {} -- block access to _G


-- Place an ability on cooldown in the simulated game state.
function H:SetCooldown( action, duration )

	self.state.cooldown[ action ]			= self.state.cooldown[ action ] or {}
	self.state.cooldown[ action ].start	= self.state.now + self.state.offset
	self.state.cooldown[ action ].duration	= duration
	self.state.cooldown[ action ].expires	= self.state.now + self.state.offset + duration
	
end


-- Apply a buff to the current game state.
function H:Buff( aura, duration, stacks, value )

	if duration == 0 then
		self.state.buff[ aura ].expires = 0
		self.state.buff[ aura ].count   = 0
		self.state.buff[ aura ].value   = 0
	else
		self.state.buff[ aura ]         = self.state.buff[ aura ] or {}
		self.state.buff[ aura ].expires = self.state.now + self.state.offset + ( duration or H.Auras[ aura ].duration )
		self.state.buff[ aura ].count   = stacks or 1
		self.state.buff[ aura ].value   = value or 0
	end

end


-- Apply stacks of a buff to the current game state.
-- Wraps around Buff() to check for an existing buff.
function H:AddStack( aura, duration, stacks, value )

	if self.state.buff[ aura ].up then
		self:Buff( aura, duration, self.state.buff[ aura ].count + stacks, value )
	else
		self:Buff( aura, duration, stacks, value )
	end

end


-- Add a debuff to the simulated game state.
-- Needs to actually use 'unit' !
function H:Debuff( unit, aura, duration, stacks, value )

	self.state.debuff[ aura ]			= self.state.debuff[ aura ] or {}
	self.state.debuff[ aura ].expires	= self.state.now + self.state.offset + duration
	self.state.debuff[ aura ].count	= stacks or 1
	self.state.debuff[ aura ].value	= value or 0

end
	
	
-- Remove a buff from the simulated game state.
function H:RemoveBuff( aura )

	self:Buff( aura, 0 )
	
end


function H:Interrupt( target )
	self.state[target].casting = false
end

-- Add a totem to the simulated game state.
function H:AddTotem( name, elem, duration )

	self.state.totem[ elem ]			= rawget( self.state.totem, elem ) or {}
	self.state.totem[ elem ].name		= name
	self.state.totem[ elem ].expires	= self.state.now + self.state.offset + duration
	
	self.state.pet[ elem ]				= rawget( self.state.pet, elem ) or {}
	self.state.pet[ elem ].name		= name
	self.state.pet[ elem ].expires		= self.state.now + self.state.offset + duration
	
	self.state.pet[ name ]				= rawget( self.state.pet, name ) or {}
	self.state.pet[ name ].name		= name
	self.state.pet[ name ].expires		= self.state.now + self.state.offset + duration

end



--------------------------------------
-- UGLY METATABLES BELOW THIS POINT --
--------------------------------------
Hekili.MT = Hekili.MT or {}


-- Returns false instead of nil when a key is not found.
local mt_false = {
	__index = function(t, k)
		return false
	end
}
Hekili.MT.mt_false = mt_false


-- Gives calculated values for some state options in order to emulate SimC syntax.
local mt_state		= {
	__index = function(t, k)
		-- Handling these with metamethods allows us to emulate SimC syntax for the in-game editor.
		-- It also means if we actually assign a value, the related metamethod gets nuked.

		if k == 'this_action' then
			-- We haven't tested an ability yet.
			return 'wait'
			
		elseif k == 'time' then
			-- Calculate time in combat.
			if H.combat == 0 then return t.offset
			else return t.now + ( t.offset or 0 ) - H.combat end

		elseif k == 'time_to_die' then
			-- Harvest TTD calculation from Hekili.
			return H.GetTTD() - t.offset

		elseif k == 'moving' then
			return ( GetUnitSpeed('player') > 0 )
	
		elseif k == 'level' then
			return ( UnitLevel('player') or MAX_PLAYER_LEVEL )

		elseif k == 'active' then
			return false
			
		elseif k == 'active_flame_shock' then
			return H:DebuffCount( 'Flame Shock' )
			
		elseif k == 'active_enemies' then
			return max(1, H:NumTargets())
		
		elseif k == 'haste' or k == 'spell_haste' then
			return ( 1 / ( 1 + UnitSpellHaste('player') / 100 ) )

		elseif k == 'melee_haste' then
			return ( 1 / ( 1 + GetMeleeHaste('player') / 100 ) )
		
		elseif k == 'mastery_value' then
			return ( GetMastery() / 100 )
		
		-- These are all action-related keywords, use 'this_action' to reference the relevant action.
		elseif k == 'execute_time' then
			return max( t.gcd, H.Abilities[ t.this_action ].cast )
			
		elseif k == 'gcd' then
			-- return ( t.cooldown[ H.GCD ].remains or 0 )
			return max( 1.0, 1.5 * t.haste )
		
		elseif k == 'cast_time' then
			return ( H.Abilities[ t.this_action ].cast )

		elseif k == 'cooldown' then return 0
		
		elseif k == 'duration' then
			return ( H.Auras[ t.this_action ].duration )
		
		elseif k == 'ticking' then
			-- print ( "checking " .. t.this_action .. " ticking in mt_state: " .. tostring( t.dot[ t.this_action ].ticking ) )
			return ( t.dot[ t.this_action ].ticking )
			
		elseif k == 'ticks' then return 0
		
		elseif k == 'ticks_remain' then return 0
		
		elseif k == 'remains' then
			return t.dot[ t.this_action ].remains
			
		elseif k == 'tick_time' then return 0
		
		elseif k == 'travel_time' then return 0
		
		elseif k == 'miss_react' then
			return false
			
		elseif k == 'cooldown_react' then
			return t.cooldown[ t.this_action ].remains == 0
		
		elseif k == 'cast_delay' then return 0
		
		elseif k == 'single' then
			return ( t.toggle.mode == t.mode_single )
			
		elseif k == 'cleave' then
			return ( t.toggle.mode == t.mode_cleave )
			
		elseif k == 'aoe' then
			return ( t.toggle.mode == t.mode_aoe )
		
		else
			-- Check if this is a resource table pre-init.
			for i, key in pairs( H.Resources ) do
				if k == key then
					return nil
				end
			end
		
		end

		return error("UNK: " .. k)

	end,
	__newindex = function(t, k, v)
		rawset(t, k, v)
	end
}
Hekili.MT.mt_state = mt_state


local mt_spec = {
	__index = function(t, k)
		if k == FormatKey( select(2, GetSpecializationID() ) ) then
			return 1
		end
		return 0
	end
}
Hekili.MT.mt_spec = mt_spec


local mt_stat = {
	__index = function(t, k)
		if k == 'strength' then
			return UnitStat('player', 1)
			
		elseif k == 'agility' then
			return UnitStat('player', 2)
			
		elseif k == 'stamina' then
			return UnitStat('player', 3)
			
		elseif k == 'intellect' then
			return UnitStat('player', 4)
			
		elseif k == 'spirit' then
			return UnitStat('player', 5)
			
		elseif k == 'health' then
			return UnitHealth('player')
			
		elseif k == 'maximum_health' then
			return UnitHealthMax('player')
		
		elseif k == 'mana' then
			return Hekili.state.mana and Hekili.state.mana.current or 0
		
		elseif k == 'maximum_mana' then
			return Hekili.state.mana and Hekili.state.mana.max or 0
		
		elseif k == 'rage' then
			return Hekili.state.rage and Hekili.state.rage.current or 0
		
		elseif k == 'maximum_rage' then
			return Hekili.state.rage and Hekili.state.rage.max or 0

		elseif k == 'energy' then
			return Hekili.state.energy and Hekili.state.energy.current or 0
		
		elseif k == 'maximum_energy' then
			return Hekili.state.energy and Hekili.state.energy.max or 0

		elseif k == 'focus' then
			return Hekili.state.focus and Hekili.state.focus.current or 0

		elseif k == 'maximum_focus' then
			return Hekili.state.focus and Hekili.state.focus.max or 0

		elseif k == 'runic' then
			return Hekili.state.runic_power and Hekili.state.runic_power.current or 0

		elseif k == 'maximum_runic' then
			return Hekili.state.runic_power and Hekili.state.runic_power.max
		
		elseif k == 'spell_power' then
			return GetSpellBonusPower(7)
		
		elseif k == 'mp5' then
			return t.mana and Hekili.state.mana.regen or 0
		
		elseif k == 'attack_power' then
			return UnitAttackPower('player')
		
		elseif k == 'crit_rating' then
			return GetCombatRating(CR_CRIT_MELEE)
		
		elseif k == 'haste_rating' then
			return GetCombatRating(CR_HASTE_MELEE)
		
		elseif k == 'weapon_dps' then
			return error("NYI")
		
		elseif k == 'weapon_speed' then
			return error("NYI")
		
		elseif k == 'weapon_offhand_dps' then
			return error("NYI")
			-- return OffhandHasWeapon()
			
		elseif k == 'weapon_offhand_speed' then
			return error("NYI")
		
		elseif k == 'armor' then
			return error("NYI")
		
		elseif k == 'bonus_armor' then
			return UnitArmor('player')
		
		elseif k == 'resilience_rating' then
			return GetCombatRating(CR_CRIT_TAKEN_SPELL)
		
		elseif k == 'mastery_rating' then
			return GetCombatRating(CR_MASTERY)
		
		elseif k == 'mastery_value' then
			return GetMasteryEffect()
			
		elseif k == 'multistrike_rating' then
			return GetCombatRating(CR_MULTISTRIKE)
		
		elseif k == 'multistrike_pct' then
			return GetMultistrike()
		
		elseif k == 'spell_haste' then
			return ( UnitSpellHaste('player') / 100 )

		elseif k == 'melee_haste' then
			return ( GetMeleeHaste('player') / 100 )

			
		end
		
		return error("UNK: " .. k)
	end
}
Hekili.MT.mt_stat = mt_stat
		
	

-- Table of default handlers for specific pets/totems.
local mt_default_pet = {
	__index = function(t, k)
		if k == 'remains' then
			if t.expires <= ( state.now + state.offset) then return 0 end
			return ( t.expires - ( state.now + state.offset ) )
			
		elseif k == 'up' or k == 'active' then
			return ( t.expires > ( state.now + state.offset ) )
			
		end
		
		error("UNK: " .. k)
		
	end
}
Hekili.MT.mt_default_pet = mt_default_pet


-- Table of pet data.
local mt_pets = {
	__index = function(t, k)
		-- Should probably add all totems, but holding off for now.
		if k == 'searing_totem' or k == 'magma_totem' or k == 'fire_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(1)
			
			if present and name == H.Abilities[ k ].name then
				t[k] = {
					expires = start + duration
				}
			else
				t[k] = {
					expires = 0
				}
			
			end
			return t[k]
		
		elseif k == 'storm_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(4)
			
			if present and name == H.Abilities[ k ].name then
				t[k] = {
					expires = start + duration
				}
			else
				t[k] = {
					expires = 0
				}
			
			end
			return t[k]
		
		elseif k == 'earth_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(2)
			
			if present and name == H.Abilities[ k ].name then
				t[k] = {
					expires = start + duration
				}
			else
				t[k] = {
					expires = 0
				}
			
			end
			return t[k]
		
		end
		
		error("UNK: " .. k)
	
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_pet ) )
	end
		
}
Hekili.MT.mt_pets = mt_pets


-- Table of supported toggles (via keybinding).
-- Need to add a commandline interface for these, but for some reason, I keep neglecting that.
local mt_toggle = {
	__index = function(t, k)
		if k == 'cooldowns' then
			return H.DB.profile.Cooldowns or false
		
		elseif k == 'hardcasts' then
			return H.DB.profile.Hardcasts or false
		
		elseif k == 'interrupts' then
			return H.DB.profile.Interrupts or false
		
		elseif k == 'one' then
			return H.DB.profile.Toggle_1 or false
		
		elseif k == 'two' then
			return H.DB.profile.Toggle_2 or false
			
		elseif k == 'three' then
			return H.DB.profile.Toggle_3 or false
		
		elseif k == 'four' then
			return H.DB.profile.Toggle_4 or false
		
		elseif k == 'five' then
			return H.DB.profile.Toggle_5 or false
			
		elseif k == 'mode' then
			if H.DB.profile.Mode == nil then return 0
			elseif H.DB.profile.Mode == true then return 1
			elseif H.DB.profile.Mode == false then return 2
			end
		
		else
			-- check custom names
			for i = 1, 5 do
				if k == H.DB.profile['Toggle '..i..' Name'] then
					return H.DB.profile['Toggle_'..i]
				end
			end
				
			return error("UNK: " .. k)
			
		end
	end
}


-- Table of target attributes.  Needs to be expanded.
-- Needs review.
local mt_target = {
	__index = function(t, k)
		if k == 'level' then
			return UnitLevel('target') or UnitLevel('player')

		elseif k == 'time_to_die' then
			return H.GetTTD()

		elseif k == 'health' then
			return ( UnitHealth('target') > 0 and UnitHealth('target') or 50000 )
		
		elseif k == 'health_max' then
			return ( UnitHealthMax('target') > 0 and UnitHealthMax('target') or 50000 )
		
		elseif k == 'health_pct' then
			-- TBD: should health_pct use our time offset and TTD calculation to predict health?
			-- Currently deciding not to, as predicting that you can use something that you can't is
			-- probably worse than saying you can't use something that you can.  Right?
			return 100 * ( t.health / t.health_max )
		
		elseif k == 'adds' then
			-- Need to return # of active targets minus 1.
			return max(0, H:NumTargets() - 1)
		
		elseif k == 'distance' then
			-- Need to identify a couple of spells to roughly get the distance to an enemy.
			-- We'd probably use IsSpellInRange() on an individual action instead, so maybe not.
			return 5
		
		elseif k == 'casting' then
			if UnitName("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
				local _, _, _, _, _, endCast, _, _, notInterruptible = UnitCastingInfo("target")

				if endCast ~= nil and not notInterruptible then
					return (endCast / 1000) > H.state.now + H.state.offset
				end

				_, _, _, _, _, endCast, _, notInterruptible = UnitChannelInfo("target")

				if endCast ~= nil and not notInterruptible then
					return (endCast / 1000) > H.state.now + H.state.offset
				end
			end
			return false
			
		else
			return error("UNK: " .. k)
		
		end
	end
}


-- Table of default handlers for specific ability cooldowns.
local mt_default_cooldown = {
	__index = function(t, k)
		if k == 'remains' then
			if t.expires <= ( state.now + state.offset) then return 0 end
			return ( t.expires - ( state.now + state.offset ) )
			
		elseif k == 'up' then
			return ( t.start == 0 or t.remains == 0 )
			
		end
		
		error("UNK: " .. k)
		
	end
}


-- Table for gathering cooldown information.  Some abilities with odd behavior are getting embedded here.
-- Probably need a better system that I can keep in the class modules.
-- Needs review.
local mt_cooldowns	= {
	-- The action doesn't exist in our table so check the real game state,
	-- and copy it so we don't have to use the API next time.
	__index = function(t, k)
		if not H.Abilities[ k ] then
			error( "UNK: " .. k)
			return
		end
		
		local ability = H.Abilities[ k ].name
		
		local success, start, duration = pcall( GetSpellCooldown, ability )
		if not success then
			error( "FAIL: " .. k )
			return nil
		end

		local start, duration = GetSpellCooldown( ability )

		if k == 'ascendance' and H.state.buff.ascendance.up then
			start = H.state.buff.ascendance.expires - H.Auras[k].duration
			duration = H.Abilities[k].cooldown
		end
			
		if start then
			t[k] = {
				duration = duration,
				expires = (start + duration)
			}
		else
			t[k] = {
				duration = 0,
				expires = 0
			}
		end
		
		return t[k]
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_cooldown ) )
	end
}


local mt_resource = {
	__index = function(t, k)
		if k == 'pct' then
			return 100 * ( t.current / t.max )
		
		elseif k == 'deficit' then
			return t.max - t.current
		
		elseif k == 'max_nonproc' then
			return t.max -- need to accommodate buffs that increase mana, etc.
		
		elseif k == 'time_to_max' then
			if not t.regen or t.regen <= 0 then return 0 end
			return ( t.max - t.current ) / t.regen
			
		elseif k == 'regen' then
			-- Not a regenerating resource.
			return 0
		
		end
		
		error("UNK: " .. k)
	end
}
Hekili.MT.mt_resource = mt_resource
			

-- Table of default handlers for auras (buffs, debuffs).
local mt_default_aura = {
	__index = function(t, k)
		if k == 'up' then
			return ( t.count > 0 and t.expires > ( state.now + state.offset ) )
			
		elseif k == 'down' then
			return ( t.count == 0 or t.expires <= ( state.now + state.offset ) )
			
		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset) then
				return ( t.expires - ( state.now + state.offset ) )
				
			else
				return 0
				
			end
		
		elseif k == 'cooldown_remains' then
			return state.cooldown[ t.key ].remains
		
		elseif k == 'duration' then
			return H.Auras[ t.key ].duration
		
		elseif k == 'max_stack' then
			return H.Auras[ t.key ].max_stack or 1
		
		elseif k == 'stack' or k == 'stacks' or k == 'react' then
			if t.up then return ( t.count ) else return 0 end
			
		elseif k == 'stack_pct' then
			if t.up then return ( 100 * t.count / t.count ) else return 0 end
			
		end
		
		error("UNK: " .. k)
		
	end
}


-- This will currently accept any key and make an honest effort to find the buff on the player.
-- Unfortunately, that means a buff.dog_farts.up check will actually get a return value.

-- Fullscan definitely needs revamping, but it works for now.
local mt_buffs	= {
	-- The action doesn't exist in our table so check the real game state,
	-- and copy it so we don't have to use the API next time.
	__index = function(t, k)
		if not H.Auras[k] then
			error( "UNK: " .. k )
			return
		end
		
		if H.Auras[ k ].fullscan and not t.__fullscan then
			local found = false
			
			for i = 1, 40 do
				local name, _, _, count, _, _, expires, _, _, _, id = UnitBuff( 'player', i )
				
				if not name then break end
				
				local key = H.Auras[ id ].key
				
				if H.Auras[ id ] then
					t[ key ] = {
						key		= key,
						count	= count or 0,
						expires	= expires or 0
					}
				end
				
				if key == k then found = true end
			end
			
			if not found then 
				t[k] = {
					key		= k,
					count	= 0,
					expires	= 0
				}
			end
			
			rawset(t, __fullscan, true)
			return t[k]
		end
		
		if k == 'liquid_magma' then
			t[k] = {
				key		= k,
				count	= H.state.cooldown.liquid_magma.remains > 34.5 and 1 or 0,
				expires = H.state.cooldown.liquid_magma.expires - 34.5
			}
			return t[k]
		end
				
		local name, _, _, count, _, _, expires = UnitBuff( 'player', H.Auras[ k ].name )

		if name then
			count = max(1, count)
			if expires == 0 then expires = state.now + 3600 end
		end
		
		t[k] = {
			key		= k,
			count	= count or 0,
			expires	= expires or 0
		}
		return ( t[k] )
			
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_aura ) )
	end
}


-- The empty glyph table.
local null_glyph = {
	enabled = false
}


-- Table for checking if a glyph is active.
-- If the value wasn't specifically added by the addon, then it returns an empty glyph.
local mt_glyphs = {
	__index = function(t, k)
		return ( null_glyph )
	end
}


-- Table for checking if a talent is active.  Conveniently reuses the glyph metatable.
-- If the value wasn't specifically added by the addon, then it returns an empty glyph.
local mt_talents = {
	__index = function(t, k)
		return ( null_glyph )
	end
}


local mt_perks = {
	__index = function(t, k)
		return ( null_glyph )
	end
}


-- Table for counting active dots.
local mt_active_dot = {
	__index = function(t, k)
		if H.Auras[ k ] then
			return H:DebuffCount( H.Auras[ k ].name )
			
		else
			error("UNK: " .. k)
			
		end
	end
}


-- Table of default handlers for a totem.  Under-implemented at the moment.
-- Needs review.
local mt_default_totem = {
	__index = function(t, k)
		if k == 'up' or k == 'active' then
			return ( t.expires > ( state.now + state.offset ) )

		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset) then
				return ( t.expires - ( state.now + state.offset ) )
			else
				return 0
			end

		end
		
		error("UNK: " .. k)
	end
}


-- Table of totems.  Currently Shaman-centric.
-- Needs review.
local mt_totem = {
	__index = function(t, k)
		if k == 'fire' then
			local _, name, start, duration = GetTotemInfo(1)
			
			t[k] = {
				name	= name or nil,
				expires	= (start + duration) or 0,
			}
			return t[k]
			
		elseif k == 'earth' then
			local _, name, start, duration = GetTotemInfo(2)
			
			t[k] = {
				name	= name or nil,
				expires	= (start + duration) or 0,
			}
			return t[k]
			
		elseif k == 'water' then
			local _, name, start, duration = GetTotemInfo(3)
			
			t[k] = {
				name	= name or nil,
				expires	= (start + duration) or 0,
			}
			return t[k]
			
		elseif k == 'air' then
			local _, name, start, duration = GetTotemInfo(4)
			
			t[k] = {
				name	= name or nil,
				expires	= (start + duration) or 0,
			}
			return t[k]
		end
		
		error("'" .. k "' is not a supported totem.")
		
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_totem ) )
	end
}


-- Table of set bonuses.  Some string manipulation to honor the SimC syntax.
-- Currently returns 1 for true, 0 for false to be consistent with SimC conditionals.
-- Won't catch fake set names.  Should revise.
local mt_set_bonuses = {
	__index = function(t, k)
		local set, pieces, class = k:match("^(.-)_"), tonumber( k:match("_(%d+)pc") ), k:match("pc(.-)$")

		if not pieces or not set then
			-- This wasn't a tier set bonus.
			return 0
		
		else
			if class then set = set .. class end

			if t[set] >= pieces then
				return 1
			end
		end 
		
		return 0

	end
}


local default_dot = {
	duration		= 0,
	expires			= 0,
	modifier		= 0,
	remains			= 0,
	ticking			= false,
	ticks_added		= 0,
	tick_dmg		= 0,
	ticks_remain	= 0,
	spell_power		= 0,
	attack_power	= 0,
	multiplier		= 0,
	haste_pct		= 0,
	current_ticks	= 0,
	ticks			= 0,
	crit_pct		= 0,
	crit_dmg		= 0
}


-- Table of default handlers for dots.
-- Needs review.
local mt_default_dot = {
	__index = function(t, k)
		if k == 'remains' then
			return max(0, t.expires - ( H.state.now + H.state.offset ) )
		
		elseif k == 'tick_dmg' or k == 'tick_damage' then
			return H.debuffs[ H.Auras[ H.state.this_action ].name ].tick_dmg or 0
		
		elseif k == 'ticking' then
			-- print( "checking ticking: " .. tostring( t.remains > 0 ) )
			return ( t.remains > 0 )
		
		end
		
		error("UNK: " .. k)
		
	end
			
}


-- Table for dots.
-- Needs review.
local mt_dots = {
	__index = function(t, k)
		return Hekili.state.debuff[k]
	
		--[[ Check the tracked spells to see what's been applied to the target.
		local _, _, _, _, _, duration, expires, _, _, _, _, _, v1, v2, v3 = UnitDebuff( 'target', H.Auras[ k ] and H.Auras[ k ].name or 'nothing', nil, 'PLAYER' )
		t[k] = {
			duration	= duration or 0,
			expires		= expires or 0,
			v1			= v1 or 0,
			v2			= v2 or 0,
			v3			= v3 or 0
		}
		return ( t[k] ) ]]
	end,
	__newindex = function(t, k, v)
		rawset(t, k, setmetatable(v,  mt_default_dot))
	end
}


-- Table of default handlers for debuffs.
-- Needs review.
local mt_default_debuff = {
	__index = function(t, k)
		if k == 'up' then
			return ( t.count > 0 and t.expires > ( state.now + state.offset ) )
		
		elseif k == 'down' then
			return ( t.count == 0 or t.expires <= ( state.now + state.offset ) )
		
		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset) then
				return ( t.expires - ( state.now + state.offset ) )
		
			else
				return 0
			
			end
		
		elseif k == 'stack' or k == 'react' then
			if t.up then return ( t.count ) else return 0 end
		
		elseif k == 'stack_pct' then
			if t.up then return ( 100 * t.count / t.count ) else return 0 end
		
		elseif k == 'ticking' then
			return t.up
		
		end
		
		error ("UNK: " .. k)
		
	end
}


-- Table of debuffs applied to the target by the player.
-- Needs review.
local mt_debuffs	= {
	-- The debuff/ doesn't exist in our table so check the real game state,
	-- and copy it so we don't have to use the API next time.
	__index = function(t, k)

		if k == 'bloodlust' then -- check for whole list.
		
		elseif not H.Auras[ k ] then
			error( "UNK: " .. k)
		
		else
			local name, _, _, count, _, _, expires = UnitDebuff( 'target', H.Auras[ k ].name, nil, 'PLAYER' )
			if name then count = max(1, count) end
			t[k] = {
				count	= count or 0,
				expires	= expires or 0
			}
			return ( t[k] )
			
		end
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_debuff ) )
	end
}


-- Table of default handlers for actions.
-- Needs review.
local mt_default_action	= {
	__index = function(t, k)
		local s = Hekili.state
	
		if k == 'gcd' then
			if t.gcdType == 'offGCD' then return 0
			elseif t.gcdType == 'spell' then return max( 1.0, 1.5 * s.haste )
			-- This needs a class/spec check to confirm GCD is reduced by haste.
			elseif t.gcdType == 'melee' then return max( 1.0, 1.5 * s.haste )
			elseif t.gcdType == 'totem' then return 1
			else return 1.5 end
			
		elseif k == 'execute_time' then
			return max( t.gcd, t.base_cast * s.haste )
			
		elseif k == 'cast_time' then
			return t.base_cast
		
		elseif k == 'ticking' then
			-- print("checking " .. s.this_action .. " ticking in mt_default_action: " .. tostring( s.dot[ s.this_action ].ticking ) )
			return ( s.dot[ s.this_action ].ticking )
			
		elseif k == 'ticks' then
			return ( s.dot[ t.action ].ticks )
			
		elseif k == 'ticks_remain' then
			return ( s.dot[ t.action ].ticks_remain )
			
		elseif k == 'remains' then
			return ( s.dot[ t.action ].remains )
			
		elseif k == 'tick_time' then
			if IsWatchedDoT( t.action ) then
				return ( GetWatchedDoT( t.action ).tick_time * s.haste )
			end
			return 0
			
		elseif k == 'tick_damage' then
			if IsWatchedDoT( t.action ) then
				return select(2, GetWatchedDoT( t.action ).handler() )
			end
			return 0
			
		elseif k == 'travel_time' then
			-- NYI: maybe capture the last travel time for the spell and use that?
			return 0
			
		elseif k == 'miss_react' then
			return false
			
		elseif k == 'cooldown_react' then
			return false
			
		elseif k == 'cast_delay' then
			return 0
			
		end
		
		return 0
	end
}


-- mt_actions: provides action information for display/priority queue/action criteria.
-- NYI.
local mt_actions = {
	__index = function(t, k)
	
		local action = H.Abilities[ k ]
		
		-- Need a null_action table.
		if not action then return nil end
		
		t[k] = {
			action		= k,
			base_cast	= action.cast,
			cooldown	= action.cooldown,
			gcdType		= action.gcdType
		}
		
		return ( t[k] )
	end,
	__newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_action ) )
	end
}
		


setmetatable( state,				mt_state )
setmetatable( state.pet,			mt_pets )
setmetatable( state.stat,		mt_stat )
setmetatable( state.toggle,		mt_toggle )
setmetatable( state.buff,		mt_buffs )
setmetatable( state.race,		mt_false )
setmetatable( state.spec,		mt_spec )
setmetatable( state.perk,		mt_perks )
setmetatable( state.glyph,		mt_glyphs )
setmetatable( state.talent,		mt_talents )
setmetatable( state.totem,		mt_totem )
setmetatable( state.set_bonus,	mt_set_bonuses )
setmetatable( state.target,		mt_target )
setmetatable( state.debuff,		mt_debuffs )
setmetatable( state.dot,			mt_dots )
setmetatable( state.cooldown,	mt_cooldowns )
setmetatable( state.action,		mt_actions )
setmetatable( state.active_dot,	mt_active_dot )


Hekili.Tables = { "pet", "stat", "toggle", "buff", "race", "spec", "glyph", "talent", "totem", "set_bonus", "target", "debuff", "dot", "cooldown", "action", "active_dot" }
Hekili.Values = { "active", "active_enemies", "active_flame_shock", "adds", "agility", "air", "armor", "attack_power", "bonus_armor", "cast_delay", "cast_time", "casting", "cooldown_react", "cooldown_remains", "crit_rating", "deficit", "distance", "down", "duration", "earth", "enabled", "energy", "execute_time", "fire", "five", "focus", "four", "gcd", "hardcasts", "haste", "haste_rating", "health", "health_max", "health_pct", "intellect", "level", "mana", "mastery_rating", "mastery_value", "max_nonproc", "max_stack", "maximum_energy", "maximum_focus", "maximum_health", "maximum_mana", "maximum_rage", "maximum_runic", "melee_haste", "miss_react", "moving", "mp5", "multistrike_pct", "multistrike_rating", "one", "pct", "rage", "react", "regen", "remains", "remains", "resilience_rating", "runic", "spell_haste", "spell_power", "spirit", "stack", "stack_pct", "stacks", "stamina", "strength", "this_action", "three", "tick_damage", "tick_dmg", "tick_time", "ticking", "ticks", "ticks_remain", "time", "time_to_die", "time_to_max", "travel_time", "two", "up", "water", "weapon_dps", "weapon_offhand_dps", "weapon_offhand_speed", "weapon_speed", "single", "aoe", "cleave" }

Hekili.state = state