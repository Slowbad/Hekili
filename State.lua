-- State.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local formatKey = ns.formatKey
local getSpecializationID = ns.getSpecializationID
local tableCopy = ns.tableCopy


-- This will be our environment table for local functions.
local state = ns.state

state.iteration = 0

state.now = 0
state.offset = 0
state.mainhand_speed = 0
state.offhand_speed = 0

state.delay = 0
state.min_targets = 1

state.action = {}
state.active_dot = {}
state.buff = {}
state.cooldown = {}
state.debuff = {}
state.dot = state.debuff
state.glyph = {}
state.perk = {}
state.pet = {}
state.player = {
  lastcast = 'none',
  casttime = 0
}
state.purge = {}
state.race = {}
state.set_bonus = {}
state.spec = {}
state.stance = {}
state.stat = {}
state.talent = {}
state.target = {
  debuff = state.debuff,
  health = {}
}
state.toggle = {}
state.totem = {}
  
state.max = max
state.min = min

state.IsUsableSpell = IsUsableSpell
  
state.boss = false
state.combat = 0
state.faction = UnitFactionGroup( 'player' )
state.race[ formatKey( UnitRace('player') ) ] = true

state.class = ns.class
state.targets = ns.targets
  
state._G = 0


-- Place an ability on cooldown in the simulated game state.
local function setCooldown( action, duration )

	state.cooldown[ action ] = state.cooldown[ action ] or {}
	-- state.cooldown[ action ].start = state.now + state.offset
	state.cooldown[ action ].duration = duration
	state.cooldown[ action ].expires = state.now + state.offset + duration
	
end
state.setCooldown = setCooldown


-- Apply a buff to the current game state.
local function applyBuff( aura, duration, stacks, value )

	if duration == 0 then
		state.buff[ aura ].expires = 0
		state.buff[ aura ].count = 0
		state.buff[ aura ].value = 0
		state.buff[ aura ].start = 0
		state.buff[ aura ].caster = 'unknown'
	else
		state.buff[ aura ] = state.buff[ aura ] or {}
		state.buff[ aura ].expires = state.now + state.offset + ( duration or class.auras[ aura ].duration )
		state.buff[ aura ].start = state.now + state.offset
		state.buff[ aura ].count = stacks or 1
		state.buff[ aura ].value = value or 0
		state.buff[ aura ].caster = 'player'
	end

end
state.applyBuff = applyBuff


local function removeBuff( aura )

	applyBuff( aura, 0 )
	
end
state.removeBuff = removeBuff


-- Apply stacks of a buff to the current game state.
-- Wraps around Buff() to check for an existing buff.
local function addStack( aura, duration, stacks, value )

  local max_stacks = ( class.auras[ aura ] and class.auras[ aura ].max_stacks ) and class.auras[ aura ].max_stacks or 1

	if state.buff[ aura ].up then
		applyBuff( aura, duration, min( max_stacks, state.buff[ aura ].count + stacks ), value )
	else
		applyBuff( aura, duration, min( max_stacks, stacks ), value )
	end

end
state.addStack = addStack


local function removeStack( aura, stacks )

	if state.buff[ aura ].count > ( stacks or 1 ) then
		state.buff[ aura ].count = max( 0, state.buff[ aura ].count - ( stacks or 1 ) )
	else
		removeBuff( aura )
	end
end
state.removeStack = removeStack


-- Add a debuff to the simulated game state.
-- Needs to actually use 'unit' !
local function applyDebuff( unit, aura, duration, stacks, value )

	if duration == 0 then
		state.debuff[ aura ].expires = 0
		state.debuff[ aura ].count = 0
		state.debuff[ aura ].value = 0
		state.debuff[ aura ].start = 0
		state.debuff[ aura ].unit = unit
	else
    state.debuff[ aura ] = state.debuff[ aura ] or {}
    state.debuff[ aura ].expires = state.now + state.offset + duration
    state.debuff[ aura ].count = stacks or 1
    state.debuff[ aura ].value = value or 0
    state.debuff[ aura ].unit = unit or 'target'
  end

end
state.applyDebuff = applyDebuff


local function removeDebuff( unit, aura )

  applyDebuff( unit, aura, 0 )

end
state.removeDebuff = removeDebuff	


local function setStance( stance )
	for k in pairs( state.stance ) do
		state.stance[ k ] = false
	end
	state.stance[ stance ] = true
end
state.setStance = setStance


local function interrupt()
	state.target.casting = false
end
state.interrupt = interrupt


local function summonPet( name, duration )

  state.pet[ name ] = rawget( state.pet, name ) or {}
  state.pet[ name ].name = name
  state.pet[ name ].expires = state.now + state.offset + duration

end
state.summonPet = summonPet


local function summonTotem( name, elem, duration )

	state.totem[ elem ] = rawget( state.totem, elem ) or {}
	state.totem[ elem ].name = name
	state.totem[ elem ].expires = state.now + state.offset + duration
	
	state.pet[ elem ] = rawget( state.pet, elem ) or {}
	state.pet[ elem ].name = name
	state.pet[ elem ].expires = state.now + state.offset + duration
	
	state.pet[ name ] = rawget( state.pet, name ) or {}
	state.pet[ name ].name = name
	state.pet[ name ].expires = state.now + state.offset + duration

end
state.summonTotem = summonTotem


-- Useful for things like leap/charge/etc.
local function setDistance( minimum, maximum )
	state.target.minR = minimum
	state.target.maxR = maximum
end
state.setDistance = setDistance


local function gain( amount, resource )

  state[ resource ].actual = min( state[ resource ].max, state[ resource ].actual + amount )

end
state.gain = gain


local function spend( amount, resource )

	state[ resource ].actual = max( 0, state[ resource ].actual - amount )

end
state.spend = spend


--------------------------------------
-- UGLY METATABLES BELOW THIS POINT --
--------------------------------------
ns.metatables = {}
local metafunctions = {
  state = {},
  spec = {},
  stat = {},
  default_pet = {},
  pet = {},
  stance = {},
  toggle = {},
  target = {},
  target_health = {},
  default_cooldown = {},
  cooldown = {},
  resource = {},
  default_aura = {},
  buff = {},
  default_glyph = {},
  glyph = {},
  talent = {},
  perk = {},
  active_dot = {},
  default_totem = {},
  totem = {},
  set_bonus = {},
  default_debuff = {},
  debuff = {},
  default_action = {},
  action = {}
}

ns.addMetaFunction = function( t, k, func )
  
  if metafunctions[ t ] then
    metafunctions[ t ][ k ] = setfenv( func, state )
    return
  end
  
  ns.Error( "addMetaFunction() - no such table '" .. t .. "' for key '" .. k .. "'." )

end


-- Returns false instead of nil when a key is not found.
local mt_false = {
	__index = function(t, k)
		return false
	end
}
ns.metatables.mt_false = mt_false


-- Gives calculated values for some state options in order to emulate SimC syntax.
local mt_state = {
	__index = function(t, k)
		-- Handling these with metamethods allows us to emulate SimC syntax for the in-game editor.
		-- It also means if we actually assign a value, the related metamethod gets nuked.

		if metafunctions.state[ k ] then
      return metafunctions.state[ k ]()
      
    elseif k == 'this_action' then
			-- We haven't tested an ability yet.
			return 'wait'
    
    elseif k == 'delay' then
      return 0
    
		elseif k == 'time' then
			-- Calculate time in combat.
			if t.combat == 0 and t.false_start == 0 then return 0
			else return t.now + ( t.offset or 0 ) - ( t.combat > 0 and t.combat or t.false_start ) end

		elseif k == 'time_to_die' then
			-- Harvest TTD calculation from Hekili.
			return ns.getTTD() - ( t.offset )

		elseif k == 'moving' then
			return ( GetUnitSpeed('player') > 0 )
    
    elseif k == 'group' then
      return IsInGroup()
	
		elseif k == 'level' then
			return ( UnitLevel('player') or MAX_PLAYER_LEVEL )

		elseif k == 'active' then
			return false
			
		elseif k == 'active_flame_shock' then
			return ns.numDebuffs( 'Flame Shock' )
			
		elseif k == 'active_enemies' then
			return max( t.min_targets, ns.numTargets() )
    
    elseif k == 'my_enemies' then
      return max( t.min_targets, ns.numMyTargets() )
		
		elseif k == 'haste' or k == 'spell_haste' then
			return ( 1 / ( 1 + UnitSpellHaste('player') / 100 ) )

		elseif k == 'melee_haste' then
			return ( 1 / ( 1 + GetMeleeHaste('player') / 100 ) )
		
		elseif k == 'mastery_value' then
			return ( GetMastery() / 100 )
		
		-- These are all action-related keywords, use 'this_action' to reference the relevant action.
		elseif k == 'execute_time' then
			return max( t.gcd, class.abilities[ t.this_action ].cast )
			
		elseif k == 'gcd' then
			local gcdType = class.abilities[ t.this_action ].gcdType

			if gcdType == 'spell' then return max( 1.0, 1.5 * t.haste )
			elseif gcdType == 'melee' then return max( 1.0, 1.5 * t.haste )
			elseif gcdType == 'totem' then return 1.0
			end
			
			return max( 1.0, 1.5 * t.haste )
		
		elseif k == 'cast_time' then
			return ( class.abilities[ t.this_action ].cast )

		elseif k == 'cooldown' then return 0
		
		elseif k == 'duration' then
			return ( class.auras[ t.this_action ].duration )
		
		elseif k == 'ticking' then
			if class.auras[ t.this_action ] then return ( t.dot[ t.this_action ].ticking ) end
			return false
			
		elseif k == 'ticks' then return 0
		
		elseif k == 'ticks_remain' then return 0
		
		elseif k == 'remains' then
			return t.dot[ t.this_action ].remains
			
		elseif k == 'tick_time' then return 0
		
		elseif k == 'travel_time' then return 0
		
		elseif k == 'miss_react' then
			return false
			
		elseif k == 'cooldown_react' or k == 'cooldown_up' then
			return t.cooldown[ t.this_action ].remains == 0
		
		elseif k == 'cast_delay' then return 0
		
		elseif k == 'single' then
			return t.toggle.mode == 0 or ( t.toggle.mode == 3 and active_enemies == 1 )
			
		elseif k == 'cleave' or k == 'auto' then
			return t.toggle.mode == 3
			
		elseif k == 'aoe' then
			return t.toggle.mode == 2

    elseif k == 'charges' then
      if class.abilities[ t.this_action ].charges then
        return t.cooldown[ t.this_action ].charges
      end
      return 0
    
    elseif k == 'recharge_time' then
      if class.abilities[ t.this_action ].charges then
        return t.cooldown[ t.this_action ].next_charge > t.now and ( t.cooldown[ t.this_action ].next_charge - ( t.now + t.offset ) ) or 0
      end
      return t.cooldown[ t.this_action ].remains
      
    elseif k:sub(1, 16) == 'incoming_damage_' then
      local remains = k:sub(17)
      local time = remains:match("^(%d+)[m]?s")
      
      if not time then return error("ERR: " .. remains) end
      
      time = tonumber( time )
      
      if time > 100 then
        t.k = ns.damageInLast( time / 1000 )
      else
        t.k = ns.damageInLast( min( 15, time ) )
      end
      
      table.insert( t.purge, k )
      return t.k
    
    elseif k == 'last_judgment_target' then
      return 'unknown'
      
		else
			-- Check if this is a resource table pre-init.
			for i, key in pairs( class.resources ) do
				if k == key then
					return nil
				end
			end
		
		end

		return error("UNK: " .. k )

	end, __newindex = function(t, k, v)
		rawset(t, k, v)
	end
}
ns.metatables.mt_state = mt_state


local mt_spec = {
	__index = function(t, k)
		return false
	end
}
ns.metatables.mt_spec = mt_spec


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
			return Hekili.State.mana and Hekili.State.mana.current or 0
		
		elseif k == 'maximum_mana' then
			return Hekili.State.mana and Hekili.State.mana.max or 0
		
		elseif k == 'rage' then
			return Hekili.State.rage and Hekili.State.rage.current or 0
		
		elseif k == 'maximum_rage' then
			return Hekili.State.rage and Hekili.State.rage.max or 0

		elseif k == 'energy' then
			return Hekili.State.energy and Hekili.State.energy.current or 0
		
		elseif k == 'maximum_energy' then
			return Hekili.State.energy and Hekili.State.energy.max or 0

		elseif k == 'focus' then
			return Hekili.State.focus and Hekili.State.focus.current or 0

		elseif k == 'maximum_focus' then
			return Hekili.State.focus and Hekili.State.focus.max or 0

		elseif k == 'runic' then
			return Hekili.State.runic_power and Hekili.State.runic_power.current or 0

		elseif k == 'maximum_runic' then
			return Hekili.State.runic_power and Hekili.State.runic_power.max
		
		elseif k == 'spell_power' then
			return GetSpellBonusPower(7)
		
		elseif k == 'mp5' then
			return t.mana and Hekili.State.mana.regen or 0
		
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
ns.metatables.mt_stat = mt_stat
	

-- Table of default handlers for specific pets/totems.
local mt_default_pet = {
	__index = function(t, k)
		if k == 'expires' then
			local present, name, start, duration = GetTotemInfo( t.totem )
			
			if present and name == class.abilities[ t.key ].name then
				t.expires = start + duration
			else
				t.expires = 0
			end
			
			return t[ k ]
			
		elseif k == 'remains' then
			if t.expires <= ( state.now + state.offset ) then return 0 end
			return ( t.expires - ( state.now + state.offset ) )
			
		elseif k == 'up' or k == 'active' then
			return ( t.expires > ( state.now + state.offset ) )
			
		end
		
		error("UNK: " .. k)
		
	end
}
ns.metatables.mt_default_pet = mt_default_pet


-- Table of pet data.
local mt_pets = {
	__index = function(t, k)
		-- Should probably add all totems, but holding off for now.
		if k == 'searing_totem' or k == 'magma_totem' or k == 'fire_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(1)
			
			if present and name == class.abilities[ k ].name then
				t[k] = {
					key = k, totem = 1, expires = start + duration
				}
			else
				t[k] = {
					key = k, totem = 1, expires = 0
				}
			
			end
			return t[k]
		
		elseif k == 'storm_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(4)
			
			if present and name == class.abilities[ k ].name then
				t[k] = {
					key = k, totem = 4, expires = start + duration
				}
			else
				t[k] = {
					key = k, totem = 4, expires = 0
				}
			
			end
			return t[k]
		
		elseif k == 'earth_elemental_totem' then
			local present, name, start, duration = GetTotemInfo(2)
			
			if present and name == class.abilities[ k ].name then
				t[k] = {
					key = k, totem = 2, expires = start + duration
				}
			else
				t[k] = {
					key = k, totem = 2, expires = 0
				}
			
			end
			return t[k]
		
		end
		
		error("UNK: " .. k)
	
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_pet ) )
	end
		
}
ns.metatables.mt_pets = mt_pets


local mt_stances = {
	__index = function( t, k )
    if not class.stances[ k ] then return false
    elseif not class.stances[ k ][ state.spec.key ] then return false
		elseif not GetShapeshiftFormInfo( class.stances[ k ][ state.spec.key ] ) then return false end
		rawset(t, k, select(3, GetShapeshiftFormInfo( class.stances[ k ][ state.spec.key ] ) ) )
		return t[k]
	end
}
ns.metatables.mt_stances = mt_stances

-- Table of supported toggles (via keybinding).
-- Need to add a commandline interface for these, but for some reason, I keep neglecting that.
local mt_toggle = {
	__index = function(t, k)
		if k == 'cooldowns' then
			return Hekili.DB.profile.Cooldowns or false
		
		elseif k == 'hardcasts' then
			return Hekili.DB.profile.Hardcasts or false
		
		elseif k == 'interrupts' then
			return Hekili.DB.profile.Interrupts or false
		
		elseif k == 'one' then
			return Hekili.DB.profile.Toggle_1 or false
		
		elseif k == 'two' then
			return Hekili.DB.profile.Toggle_2 or false
			
		elseif k == 'three' then
			return Hekili.DB.profile.Toggle_3 or false
		
		elseif k == 'four' then
			return Hekili.DB.profile.Toggle_4 or false
		
		elseif k == 'five' then
			return Hekili.DB.profile.Toggle_5 or false
			
		elseif k == 'mode' then
      return Hekili.DB.profile['Mode Status']
		
		else
			-- check custom names
			for i = 1, 5 do
				if k == Hekili.DB.profile['Toggle '..i..' Name'] then
					return Hekili.DB.profile['Toggle_'..i] or false
				end
			end
				
			return false
			
		end
	end
}
ns.metatables.mt_toggle = mt_toggle


-- Table of target attributes.  Needs to be expanded.
-- Needs review.
local mt_target = {
	__index = function(t, k)
		if k == 'level' then
			return UnitLevel('target') or UnitLevel('player')
    
    elseif k == 'unit' then
      return UnitGUID( 'target' ) or 'unknown'

		elseif k == 'time_to_die' then
			return ns.getTTD( UnitGUID( 'target' ) or 0 )
		
		elseif k == 'health_current' then
			return ( UnitHealth('target') > 0 and UnitHealth('target') or 50000 )
		
		elseif k == 'health_max' then
			return ( UnitHealthMax('target') > 0 and UnitHealthMax('target') or 50000 )
		
		elseif k == 'health_pct' then
			-- TBD: should health_pct use our time offset and TTD calculation to predict health?
			-- Currently deciding not to, as predicting that you can use something that you can't is
			-- probably worse than saying you can't use something that you can.  Right?
			return t.health_max ~= 0 and ( 100 * ( t.health_current / t.health_max ) ) or 0
		
		elseif k == 'adds' then
			-- Need to return # of active targets minus 1.
			return max(0, ns.numTargets() - 1)
		
		elseif k == 'distance' then
			-- Need to identify a couple of spells to roughly get the distance to an enemy.
			-- We'd probably use IsSpellInRange() on an individual action instead, so maybe not.
			return 5
		
		elseif k == 'moving' then
			return GetUnitSpeed( 'target' ) > 0
		
		elseif k == 'casting' then
			if UnitName("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
				local _, _, _, _, _, endCast, _, _, notInterruptible = UnitCastingInfo("target")
 
				if endCast ~= nil and not notInterruptible then
          t.k = (endCast / 1000) > state.now + state.offset
          return t.k
				end

				_, _, _, _, _, endCast, _, notInterruptible = UnitChannelInfo("target")

				if endCast ~= nil and not notInterruptible then
          t.k = (endCast / 1000) > state.now + state.offset
          return t.k
				end
			end
      t.k = false
			return t.k
			
		elseif k:sub(1, 6) == 'within' then
			local maxR = k:match( "^within(%d+)$" )
			
			if not maxR then error("UNK: " .. k) end
			
			return ( t.maxR <= tonumber( maxR ) )
			
		elseif k:sub(1, 7) == 'outside' then
			local minR = k:match( "^outside(%d+)$" )
			
			if not minR then error("UNK: " .. k) end
			
			return ( t.minR > tonumber( minR ) )
			
		elseif k:sub(1, 5) == 'range' then
			local minR, maxR = k:match( "^range(%d+)to(%d+)$" )

			if not minR or not maxR then error("UNK: " .. k) end
			
			return ( t.minR >= tonumber( minR ) and t.maxR <= tonumber( maxR ) )
		
		elseif k == 'minR' then
			local minR = ns.lib.RangeCheck:GetRange( 'target' )
			if minR then
				rawset( t, k, minR )
				return t[k]
			end
			return -1
		
		elseif k == 'maxR' then
			local maxR = select( 2, ns.lib.RangeCheck:GetRange( 'target' ) )
			if maxR then
				rawset( t, k, maxR )
				return t[k]
			end
			return -1
		
		else
			
			return error("UNK: " .. k)
		
		end
	end
}
ns.metatables.mt_target = mt_target


local mt_target_health = {
	__index = function(t, k)
		if k == 'current' then
			t.current = UnitCanAttack('player', 'target') and UnitHealth('target') or 0
			return t.current
		
		elseif k == 'max' then
			t.max = UnitCanAttack('player', 'target') and UnitHealthMax('target') or 0
			return t.max
			
		elseif k == 'pct' or k == 'percent' then
			return t.max ~= 0 and ( 100 * t.current / t.max ) or 100
		end
	end
}
ns.metatables.mt_target_health = mt_target_health


-- Table of default handlers for specific ability cooldowns.
local mt_default_cooldown = {
	__index = function(t, k)
		if k == 'duration' or k == 'expires' or k == 'next_charge' or k == 'charges' then
			-- Refresh the ID in case we changed specs and ability is spec dependent.
			t.id = class.abilities[ t.key ].id
		
			local start, duration = GetSpellCooldown( t.id )
			
			if t.key == 'ascendance' and state.buff.ascendance.up then
				start = state.buff.ascendance.expires - class.auras.ascendance.duration
				duration = class.abilities[ 'ascendance' ].cooldown
			end
			
			t.duration = duration or 0
			t.expires = start and ( start + duration ) or 0
      
    if class.abilities[ t.key ].charges then
      local charges, maxCharges, start, duration = GetSpellCharges( t.id )
      t.charges = charges or 0
      if charges and charges < class.abilities[ t.key ].charges then
        t.next_charge = start + duration
      else
        t.next_charge = 0
      end
    else
      t.charges = t.expires < state.now + state.offset and 1 or 0
      t.next_charge = t.expires
    end
			
			return t[k]
		
		elseif k == 'remains' then
      if t.expires <= ( state.now + state.offset ) then return 0 end
      return ( t.expires - ( state.now + state.offset ) )
	
    elseif k == 'recharge_time' then
      if class.abilities[ t.key ].charges then
        return t.next_charge > state.now and ( t.next_charge - ( t.now + t.offset ) ) or 0
      end
      return t.remains
        
		elseif k == 'up' then
			return ( t.remains == 0 )
			
		end
		
		error("UNK: " .. k )
		
	end
}
ns.metatables.mt_default_cooldown = mt_default_cooldown


-- Table for gathering cooldown information.  Some abilities with odd behavior are getting embedded here.
-- Probably need a better system that I can keep in the class modules.
-- Needs review.
local mt_cooldowns = {
	-- The action doesn't exist in our table so check the real game state, -- and copy it so we don't have to use the API next time.
	__index = function(t, k)
		if not class.abilities[ k ] then
			error( "UNK: " .. k )
			return
		end
		
		local ability = class.abilities[ k ].id
		
		local success, start, duration = pcall( GetSpellCooldown, ability )
		if not success then
			error( "FAIL: " .. k )
			return nil
		end

		if k == 'ascendance' and state.buff.ascendance.up then
			start = state.buff.ascendance.expires - class.auras[k].duration
			duration = class.abilities[k].cooldown
		end
			
		if start then
			t[k] = {
				key = k, name = class.abilities[ k ].name, id = ability, duration = duration, expires = (start + duration)
			}
		else
			t[k] = {
				key = k, name = class.abilities[ k ].name, id = ability, duration = 0, expires = 0
			}
		end
    
    if class.abilities[ k ].charges then
      local charges, maxCharges, start, duration = GetSpellCharges( t[k].name )
      t[ k ].charges = charges or 0
      if charges then
        if start + duration < state.now then
          t[ k ].next_charge = 0
        else
          t[ k ].next_charge = charges < class.abilities[ k ].charges and ( start + duration ) or 0
        end
      else
        t[ k ].next_charge = 0
      end
    else
      t[ k ].charges = t[ k ].expires < state.now + state.offset and 1 or 0
      t[ k ].next_charge = t[ k ].expires
    end
    
		return t[k]
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_cooldown ) )
	end
}
ns.metatables.mt_cooldowns = mt_cooldowns


local mt_resource = {
	__index = function(t, k)
		if k == 'pct' then
			return 100 * ( t.current / t.max )
    
    elseif k == 'current' then
      -- This accommodates testing energy levels after a delay (i.e., use 'jab' in 3 seconds, conditions need to know energy at that time).
      if t.resource == 'energy' or t.resource == 'focus' then
        return min( t.max, t.actual + ( t.regen * state.delay ) )
      end
      return t.actual
		
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
ns.metatables.mt_resource = mt_resource


-- Table of default handlers for auras (buffs, debuffs).
local mt_default_aura = {
	__index = function(t, k)
		if k == 'name' then
			-- Check for raid buff.
			if class.auras[ t.key ].id < 0 then
				local name = GetRaidBuffTrayAuraInfo( -1 * class.auras[ t.key ].id )
				t.name = name
				return name
			end
			
			t.name = class.auras[ t.key ].name
			return class.auras[ t.key ].name
				
		elseif k == 'count' or k == 'expires' or k == 'caster' then
			
			if not t.name then
				t.count = 0
				t.expires = 0
				t.applied = 0
				t.caster = 'unknown'
				return t[k]
			end
      
      if t.key == 'liquid_magma' then
				t.count = state.cooldown.liquid_magma.remains > 34 and 1 or 0
				t.expires = state.cooldown.liquid_magma.expires - 34
        t.caster = 'player'
        return t[k]
      end

      if class.auras[ t.key ].fullscan then
        for i = 1, 40 do
          local name, _, _, count, _, duration, expires, caster, _, _, id = UnitBuff( 'player', i )
          
          if not name then
            break
          end
          
          if id == t.id then
            count = max(1, count)
            if expires == 0 then expires = state.now + 3600 end

            t.count = count or 0
            t.expires = expires or 0
            t.applied = expires and ( expires - duration ) or 0
            t.caster = caster or 'unknown'
            
            return t[ k ] 
          end
        end

      else

        local name, _, _, count, _, duration, expires, caster = UnitBuff( 'player', t.name )

        if name then
          count = max(1, count)
          if expires == 0 then expires = state.now + 3600 end
        end
        
        t.count = count or 0
        t.expires = expires or 0
        t.applied = expires and ( expires - duration ) or 0
        t.caster = caster or 'unknown'
        
        return t[k]
        
      end
      
      t.count = 0
      t.expires = 0
      t.applied = 0
      t.caster = 'unknown'
      
      return t[ k ]
	
		elseif k == 'up' then
			return ( t.count > 0 and t.expires > ( state.now + state.offset ) )
			
		elseif k == 'down' then
			return ( t.count == 0 or t.expires <= ( state.now + state.offset ) )
			
		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset ) then
				return ( t.expires - ( state.now + state.offset ) )
			else
				return 0
				
			end
		
		elseif k == 'cooldown_remains' then
			return state.cooldown[ t.key ].remains
		
		elseif k == 'duration' then
			return class.auras[ t.key ].duration
		
		elseif k == 'max_stack' then
			return class.auras[ t.key ].max_stack or 1
		
		elseif k == 'mine' then
			return t.caster == 'player'
		
		elseif k == 'stack' or k == 'stacks' or k == 'react' then
			if t.up then return ( t.count ) else return 0 end
			
		elseif k == 'stack_pct' then
			if t.up then return ( 100 * t.count / t.max_stack ) else return 0 end
		
			
		end
		
		error("UNK: " .. k)
		
	end
}
ns.metatables.mt_default_aura = mt_default_aura


-- This will currently accept any key and make an honest effort to find the buff on the player.
-- Unfortunately, that means a buff.dog_farts.up check will actually get a return value.

-- Fullscan definitely needs revamping, but it works for now.
local mt_buffs = {
	-- The action doesn't exist in our table so check the real game state, -- and copy it so we don't have to use the API next time.
	__index = function(t, k)
    
    if k == '__scanned' then
      return false
    end
  
		if not class.auras[ k ] then
			error( "UNK: " .. k )
			return
		end
		
		if class.auras[ k ].fullscan then
			local found = false
			
			for i = 1, 40 do
				local name, _, _, count, _, duration, expires, caster, _, _, id = UnitBuff( 'player', i )
				
				if not name then break end
				
        if class.auras[ k ].id == id then
          local key = class.auras[ id ].key

          count = max(1, count)
          if expires == 0 then expires = state.now + 3600 end
          if duration == 0 then duration = class.auras[ name ].duration end
				
					t[ key ] = {
						key = key, id = id, name = name, count = count or 0, expires = expires or 0, caster = caster or 'unknown', applied = expires - duration
					}
          
          found = true
          break
				end
			end
			
			if not found then 
				t[k] = {
					key = k, id = class.auras[ k ].id, name = name, count = 0, expires = 0, applied = 0, caster = 'unknown'
				}
			end
			
			return t[k]
		end
		
		if k == 'liquid_magma' then
			t[k] = {
				key = k, name = GetSpellInfo( class.auras[ 'liquid_magma' ].id ), count = state.cooldown.liquid_magma.remains > 34 and 1 or 0, expires = state.cooldown.liquid_magma.expires - 34
      }
			return t[k]
		
		elseif class.auras[ k ].id < 0 then
			local id = -1 * class.auras[ k ].id
			local name, _, _, duration, expires, spellID, slot = GetRaidBuffTrayAuraInfo( id )
      
			t[k] = {
				key = k, name = name, count = name and 1 or 0, expires = name and ( expires > 0 and expires or 3600 ) or 0
			}
			return t[k]
		
		end
		
		local name, _, _, count, _, _, expires, caster = UnitBuff( 'player', class.auras[ k ].name )

		if name then
			count = max(1, count)
			if expires == 0 then expires = state.now + 3600 end
		end
		
		t[k] = {
			key = k, name = name, count = count or 0, expires = expires or 0, caster = caster
		}
		return ( t[k] )
			
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_aura ) )
	end
}
ns.metatables.mt_buffs = mt_buffs


-- The empty glyph table.
local null_glyph = {
	enabled = false
}
ns.metatables.null_glyph = null_glyph


-- Table for checking if a glyph is active.
-- If the value wasn't specifically added by the addon, then it returns an empty glyph.
local mt_glyphs = {
	__index = function(t, k)
		return ( null_glyph )
	end
}
ns.metatables.mt_glyphs = mt_glyphs


-- Table for checking if a talent is active.  Conveniently reuses the glyph metatable.
-- If the value wasn't specifically added by the addon, then it returns an empty glyph.
local mt_talents = {
	__index = function(t, k)
		return ( null_glyph )
	end
}
ns.metatables.mt_talents = mt_talents


local mt_perks = {
	__index = function(t, k)
		return ( null_glyph )
	end
}
ns.metatables.mt_perks = mt_perks


-- Table for counting active dots.
local mt_active_dot = {
	__index = function(t, k)
		if class.auras[ k ] then
			return ns.numDebuffs( class.auras[ k ].name )
			
		else
			error("UNK: " .. k)
			
		end
	end
}
ns.metatables.mt_active_dot = mt_active_dot


-- Table of default handlers for a totem.  Under-implemented at the moment.
-- Needs review.
local mt_default_totem = {
	__index = function(t, k)
		if k == 'expires' then
			local _, name, start, duration = GetTotemInfo( t.totem )
			
			t.name = name
			t.expires = ( start or 0 ) + ( duration or 0 )
			
			return t[ k ]
			
		elseif k == 'up' or k == 'active' then
			return ( t.expires > ( state.now + state.offset ) )

		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset ) then
				return ( t.expires - ( state.now + state.offset ) )
			else
				return 0
			end

		end
		
		error("UNK: " .. k)
	end
}
Hekili.mt_default_totem = mt_default_totem


-- Table of totems.  Currently Shaman-centric.
-- Needs review.
local mt_totem = {
	__index = function(t, k)
		if k == 'fire' then
			local _, name, start, duration = GetTotemInfo(1)
			
			t[k] = {
				key = k, totem = 1, name = name, expires = (start + duration) or 0, }
			return t[k]
			
		elseif k == 'earth' then
			local _, name, start, duration = GetTotemInfo(2)
			
			t[k] = {
				key = k, totem = 2, name = name, expires = (start + duration) or 0, }
			return t[k]
			
		elseif k == 'water' then
			local _, name, start, duration = GetTotemInfo(3)
			
			t[k] = {
				key = k, totem = 3, name = name, expires = (start + duration) or 0, }
			return t[k]
			
		elseif k == 'air' then
			local _, name, start, duration = GetTotemInfo(4)
			
			t[k] = {
				key = k, totem = 4, name = name, expires = (start + duration) or 0, }
			return t[k]
		end
		
		error( "UNK: " .. k )
		
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_totem ) )
	end
}
ns.metatables.mt_totem = mt_totem


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
				return true
			end
		end 
		
		return false

	end
}
ns.metatables.mt_set_bonuses = mt_set_bonuses


-- Table of default handlers for debuffs.
-- Needs review.
local mt_default_debuff = {
	__index = function(t, k)
		if k == 'count' or k == 'expires' or k == 'v1' or k == 'v2' or k == 'v3' then
      local unit = rawget( t, unit ) or 'target'
			local name, _, _, count, _, _, expires, _, _, _, _, _, _, _, v1, v2, v3 = UnitDebuff( unit, class.auras[ t.key ].name, nil, 'PLAYER' )
			
			if name then
				count = max(1, count)
				if expires == 0 then expires = state.now + 3600 end
			end
			
			t.count = count or 0
			t.expires = expires or 0
      t.v1 = v1 or 0
      t.v2 = v2 or 0
      t.v3 = v3 or 0
			
			return t[ k ]
			
		elseif k == 'up' then
			return ( t.count > 0 and t.expires > ( state.now + state.offset ) )
		
		elseif k == 'down' then
			return ( t.count == 0 or t.expires <= ( state.now + state.offset ) )
		
		elseif k == 'remains' then
			if t.expires > ( state.now + state.offset ) then
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
ns.metatables.mt_default_debuff = mt_default_debuff


-- Table of debuffs applied to the target by the player.
-- Needs review.
local mt_debuffs = {
	-- The debuff/ doesn't exist in our table so check the real game state, -- and copy it so we don't have to use the API next time.
	__index = function(t, k)

		if k == 'bloodlust' then -- check for whole list.
		
		elseif not class.auras[ k ] then
			error( "UNK: " .. k)
		
		else
      local unit = class.auras[ k ].unit or 'target'
			local name, _, _, count, _, _, expires, _, _, _, _, _, _, _, v1, v2, v3 = UnitDebuff( unit, class.auras[ k ].name, nil, 'PLAYER' )

			if name then
				count = max(1, count)
				if expires == 0 then expires = state.now + 3600 end
			end
			
			t[k] = {
				key = k,
        id = class.auras[ k ].id,
        count = count or 0,
        expires = expires or 0,
        unit = unit,
        v1 = v1,
        v2 = v2,
        v3 = v3
			}
			return ( t[k] )
			
		end
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_debuff ) )
	end
}
ns.metatables.mt_debuffs = mt_debuffs


-- Table of default handlers for actions.
-- Needs review.
local mt_default_action = {
	__index = function(t, k)
		if k == 'gcd' then
			if t.gcdType == 'offGCD' then return 0
			elseif t.gcdType == 'spell' then return max( 1.0, 1.5 * state.haste )
			-- This needs a class/spec check to confirm GCD is reduced by haste.
			elseif t.gcdType == 'melee' then return max( 1.0, 1.5 * state.haste )
			elseif t.gcdType == 'totem' then return 1
			else return 1.5 end
			
		elseif k == 'execute_time' then
			return max( t.gcd, t.cast )
	
    elseif k == 'ready_time' then
      return ns.isUsable( t.action ) and ns.timeToReady( t.action ) or 999
    
    elseif k == 'ready' then
      return ns.isUsable( t.action ) and ns.timeToReady( t.action ) == 0
  
		elseif k == 'cast_time' then
			return class.abilities[ t.action ].cast
    
    elseif k == 'cooldown' then
      return class.abilities[ t.action ].cooldown
		
		elseif k == 'ticking' then
			return ( state.dot[ state.this_action ].ticking )
			
		elseif k == 'ticks' then
			return ( state.dot[ t.action ].ticks )
			
		elseif k == 'ticks_remain' then
			return ( state.dot[ t.action ].ticks_remain )
			
		elseif k == 'remains' then
			return ( state.dot[ t.action ].remains )
			
		elseif k == 'tick_time' then
			if IsWatchedDoT( t.action ) then
				return ( GetWatchedDoT( t.action ).tick_time * state.haste )
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
ns.metatables.mt_default_action = mt_default_action


-- mt_actions: provides action information for display/priority queue/action criteria.
-- NYI.
local mt_actions = {
	__index = function(t, k)
	
		local action = class.abilities[ k ]
		
		-- Need a null_action table.
		if not action then return nil end
		
		t[k] = {
			action = k, name = action.name, base_cast = action.elem.cast, gcdType = action.gcdType
		}
		
		return ( t[k] )
	end, __newindex = function(t, k, v)
		rawset( t, k, setmetatable( v, mt_default_action ) )
	end
}
ns.metatables.mt_actions = mt_actions


setmetatable( state, mt_state )
setmetatable( state.action, mt_actions )
setmetatable( state.active_dot, mt_active_dot )
setmetatable( state.buff, mt_buffs )
setmetatable( state.cooldown, mt_cooldowns )
setmetatable( state.debuff, mt_debuffs )
setmetatable( state.glyph, mt_glyphs )
setmetatable( state.perk, mt_perks )
setmetatable( state.pet, mt_pets )
setmetatable( state.race, mt_false )
setmetatable( state.set_bonus, mt_set_bonuses )
setmetatable( state.spec, mt_spec )
setmetatable( state.stance, mt_stances )
setmetatable( state.stat, mt_stat )
setmetatable( state.talent, mt_talents )
setmetatable( state.target, mt_target )
setmetatable( state.target.health, mt_target_health )
setmetatable( state.toggle, mt_toggle )
setmetatable( state.totem, mt_totem )


state.reset = function()

  state.now = GetTime()
	state.offset = 0
  state.delay = 0
	state.cast_start = 0
	state.false_start = 0
  state.min_targets = 1
  
  for i = #state.purge, 1, -1 do
    state[ state.purge[ i ] ] = nil
    table.remove( state.purge, i )
  end
	
	-- A decent start, but assumes our first ability is always aggressive.  Not necessarily true...
  -- FIX: MOVE THIS TO A HOOK!
	if state.class.file == 'WARRIOR' then
		state.nextMH = ( state.combat ~= 0 and state.nextMH > state.now ) and state.nextMH or -1
		state.nextOH = ( state.combat ~= 0 and state.nextOH > state.now ) and state.nextOH or -1
	end
	
	for k in pairs( state.buff ) do
		if class.auras[ k ].id < 0 then
			state.buff[ k ].name = nil
		end
		state.buff[ k ].caster = nil
		state.buff[ k ].count = nil
		state.buff[ k ].expires = nil
		state.buff[ k ].applied = nil
	end

	for k in pairs( state.cooldown ) do
		state.cooldown[ k ].duration = nil
		state.cooldown[ k ].expires = nil
    state.cooldown[ k ].charges = nil
    state.cooldown[ k ].next_charge = nil
	end
	
	for k in pairs( state.debuff ) do
		state.debuff[ k ].count = nil
		state.debuff[ k ].expires = nil
    state.debuff[ k ].v1 = nil
    state.debuff[ k ].v2 = nil
    state.debuff[ k ].v3 = nil
    state.debuff[ k ].unit = class.auras[ k ].unit or nil
	end
	
	for k in pairs( state.pet ) do
		state.pet[ k ].expires = nil
	end

	for k in pairs( state.stance ) do
		state.stance[ k ] = nil
	end
	
	for k in pairs( state.totem ) do
		state.totem[ k ].expires = nil
	end
	
	state.target.health.current = nil
	state.target.health.max = nil
	
	-- range checks
	state.target.minR = nil
	state.target.maxR = nil
	
	-- interrupts
	state.target.casting = nil
	
	for k, _ in pairs( class.resources ) do
		
		state[ k ] = rawget( state, k ) or setmetatable( { resource = key }, mt_resource )
		state[ k ].actual = UnitPower( 'player', ns.getResourceID( k ) )
		state[ k ].max = UnitPowerMax( 'player', ns.getResourceID( k ) )
    state[ k ].resource = k
		
		if ns.getResourceID( k ) == UnitPowerType('player') then
			local active, inactive = GetPowerRegen()
			
			if state.time > 0 then
				state[ k ].regen = active
			else
				state[ k ].regen = inactive
			end
		end
	end
	
	state.health = rawget( state, 'health' ) or setmetatable( { resource = 'health' }, mt_resource )
	state.health.actual = UnitHealth( 'player' )
	state.health.max = UnitHealthMax( 'player' )
	
	-- Special case spells that suck.
	if class.abilities[ 'ascendance' ] and state.buff.ascendance.up then
		setCooldown( 'ascendance', state.buff.ascendance.remains + 165 )
	end
	
	local cast_time, casting = 0, nil

	local spellcast, _, _, _, startCast, endCast = UnitCastingInfo('player')
	if endCast ~= nil then
		state.cast_start = startCast / 1000
		cast_time = ( endCast / 1000 ) - GetTime()
		casting = formatKey( spellcast )
	end
	
	local spellcast, _, _, _, startCast, endCast = UnitChannelInfo('player')
	if endCast ~= nil then
		state.cast_start = startCast / 1000
		cast_time = ( endCast / 1000) - GetTime()
		casting = formatKey( spellcast )
	end				
  
	if cast_time and casting then
		state.advance( cast_time )
		if class.abilities[ casting ] then
			state.cooldown[ casting ].expires = state.now + state.offset + class.abilities[ casting ].cooldown
		end
		ns.runHandler( casting )
	end
	
	-- Delay to end of GCD.
  local delay = state.cooldown[ class.gcd ].remains
  
  delay = ns.callHook( "reset", delay ) or delay
  
	if delay > 0 then
		state.advance( delay )
	end

end


state.advance = function( time )
	
	if time <= 0 then
		return
	end
	
	state.offset = state.offset + time
  state.delay = 0
  
  for k, cd in pairs( state.cooldown ) do
    if class.abilities[ k ].charges and cd.next_charge > 0 and cd.next_charge < state.now + state.offset then
      cd.charges = cd.charges + 1
      if cd.charges < class.abilities[ k ].charges then
        cd.next_charge = cd.next_charge + class.abilities[ k ].elem.cooldown
      end
    end
  end
	
	for k, _ in pairs( class.resources ) do
		local resource = state[ k ]

    -- MOVE TO WARRIOR MODULE
		if k == 'rage' and state.target.within5 then
			local MH, OH = UnitAttackSpeed( 'player' )

			while ( MH and state.nextMH > 0 and state.nextMH < state.now + state.offset ) do
				local gain = floor( 35 * state.mainhand_speed ) / 10
				if self.Specialization == 71 then gain = gain * 2 end
				
				resource.actual = min( resource.max, resource.actual + gain )
				
				state.nextMH = state.nextMH + MH
			end
			
			while ( OH and state.nextOH > 0 and state.nextOH < state.now + state.offset ) do
				local gain = floor( 35 * state.offhand_speed * 0.5 ) / 10
				
				resource.actual = min( resource.max, resource.actual + gain )

				state.nextOH = state.nextOH + OH
			end
		
		elseif resource.regen and resource.regen ~= 0 then
			resource.actual = min( resource.max, resource.actual + ( resource.regen * time ) )
		end
	end

end


ns.hasRequiredResources = function( ability )

	local action = class.abilities[ ability ]
	
	if not action then return end
	
	-- First, spend resources.
	if action.spend then
		local spend, resource
		
		if type( action.spend ) == 'number' then
			spend = action.spend
			resource = action.spend_type or Hekili.ClassResource
		elseif type( action.spend ) == 'function' then
			spend, resource = action.spend()
		end

    if resource == 'focus' or resource == 'energy' then
      -- Thought: We've already delayed CD based on time to get energy/focus.
      -- So let's leave it alone.
      return true
    end
		
    -- It's a percentage.
		if spend > 0 and spend < 1 then
			spend = ( spend * state[ resource ].max )
		end
		
    if spend > 0 then
      return ( state[ resource ].current >= spend )
    end
	end
	
	return true
	
end


ns.resourceType = function( ability )
  
  local action = class.abilities[ ability ]
  
  if not action then return end
  
  if action.spend then
    if type( action.spend ) == 'number' then
      return action.spend_type or class.primaryResource
    
    elseif type( action.spend ) == 'function' then
      return select( 2, action.spend() )
      
    end
  end
  
  return nil

end
  
  
ns.spendResources = function( ability )

	local action = class.abilities[ ability ]
	
	if not action then return end

	-- First, spend resources.
	if action.spend then
		local spend, resource
		
		if type( action.spend ) == 'number' then
			spend = action.spend
			resource = action.spend_type or class.primaryResource
		elseif type( action.spend ) == 'function' then
			spend, resource = action.spend()
		end

		if spend > 0 and spend < 1 then
			spend = ( spend * state[ resource ].max )
		end
		
    if spend > 0 then
      state[ resource ].actual = min( max(0, state[ resource ].actual - spend ), state[ resource ].max )
    end
	end
	
end


ns.isKnown = function( sID )

	if type(sID) ~= 'number' then sID = class.abilities[ sID ].id or nil end
  
  if not sID then return false -- no ability
  elseif sID < 0 then return true end -- fake ability (i.e., wait)
	
	local ability = class.abilities[ sID ]
  
  if not ability then
    ns.Error( "isKnown() - " .. sID .. " not found in abilities table." )
    return false
  end
	
	if ability.known then
		if type( ability.known ) == 'number' then
			return IsSpellKnown( ability.known )
		else
			return ability.known()
		end
	end
	
	return ( IsSpellKnown( sID ) or IsSpellKnown( sID, true ) )

end


-- Filter out non-resource driven issues with abilities.
ns.isUsable = function( spell )

	local ability = class.abilities[ spell ]
	
	if ability.usable then
		if type( ability.usable ) == 'number' then return IsUsableSpell( ability.usable )
		elseif type( ability.usable ) == 'function' then return ability.usable() end
	end
	
	return true
	
end
	

--[[ How long before I can use this action (based on CD and resource availability).
-- returns 999 if you lack resources and they don't regenerate.
ns.timeToReady = function( action )

  -- Need to ignore the delay for this part.
	local delay = max( 0, state.cooldown[ action ].expires - ( state.now + state.offset ) )

  delay = ns.callHook( "timeToReady", action, delay ) or delay
  
  local ability = class.abilities[ action ]

  if ability.spend then
    local spend, resource
    
    if type( ability.spend ) == 'number' then
      spend = ability.spend
      resource = ability.spend_type or class.primaryResource
    elseif type( ability.spend ) == 'function' then
      spend, resource = ability.spend()
    end
    
		if spend > 0 and spend < 1 then
			spend = ( spend * state[ resource ].max )
		end
		
    if spend > state[ resource ].actual then
      if resource == 'focus' or resource == 'energy' then
        delay = max( delay, 0.25 + ( ( spend - state[ resource ].actual ) / state[ resource ].regen ) )
      else
        delay = 999
      end
    end
  end

	return delay
end ]]--


ns.hasRequiredResources = function( ability )

	local action = class.abilities[ ability ]
	
	if not action then return end
	
	-- First, spend resources.
	if action.spend then
		local spend, resource
		
		if type( action.spend ) == 'number' then
			spend = action.spend
			resource = action.spend_type or class.primaryResource
		elseif type( action.spend ) == 'function' then
			spend, resource = action.spend()
		end
    
    if resource == 'focus' or resource == 'energy' then
      -- Thought: We'll already delay CD based on time to get energy/focus.
      -- So let's leave it alone.
      return true
    end
		
		if spend > 0 and spend < 1 then
			spend = ( spend * state[ resource ].max )
		end
		
    if spend > 0 then
      return ( state[ resource ].current >= spend )
    end
	end
	
	return true
	
end


-- Needs to be expanded to handle energy regen before Rogue, Monk, Druid will work.
ns.timeToReady = function( action )

  -- Need to ignore the delay for this part.
	local delay = state.cooldown[ action ].remains

	if action == 'ascendance' then
		if state.buff.ascendance.up then
			delay = 180 - ( 15 - state.buff.ascendance.remains )
		end
	end
  
  local ability = class.abilities[ action ]
  
  if ability.spend then
    local spend, resource
    
    if type( ability.spend ) == 'number' then
      spend = ability.spend
      resource = ability.spend_type or class.primaryResource
    elseif type( ability.spend ) == 'function' then
      spend, resource = ability.spend()
    end
    
    if resource == 'energy' then Hekili.lastenergy = action end
   
    if spend > state[ resource ].current then
      if resource == 'focus' or resource == 'energy' then
        delay = max( delay, 0.1 + ( ( spend - state[ resource ].current ) / state[ resource ].regen ) )
      else
        delay = 999
      end
    end
  end

	return delay
  
end


for k, v in pairs( state ) do
  ns.commitKey( k )
end

ns.attr = { "serenity", "active", "active_enemies", "my_enemies", "active_flame_shock", "adds", "agility", "air", "armor", "attack_power", "bonus_armor", "cast_delay", "cast_time", "casting", "cooldown_react", "cooldown_remains", "cooldown_up", "crit_rating", "deficit", "distance", "down", "duration", "earth", "enabled", "energy", "execute_time", "fire", "five", "focus", "four", "gcd", "hardcasts", "haste", "haste_rating", "health", "health_max", "health_pct", "intellect", "level", "mana", "mastery_rating", "mastery_value", "max_nonproc", "max_stack", "maximum_energy", "maximum_focus", "maximum_health", "maximum_mana", "maximum_rage", "maximum_runic", "melee_haste", "miss_react", "moving", "mp5", "multistrike_pct", "multistrike_rating", "one", "pct", "rage", "react", "regen", "remains", "remains", "resilience_rating", "runic", "seal", "spell_haste", "spell_power", "spirit", "stack", "stack_pct", "stacks", "stamina", "strength", "this_action", "three", "tick_damage", "tick_dmg", "tick_time", "ticking", "ticks", "ticks_remain", "time", "time_to_die", "time_to_max", "travel_time", "two", "up", "water", "weapon_dps", "weapon_offhand_dps", "weapon_offhand_speed", "weapon_speed", "single", "aoe", "cleave", "percent", "last_judgment_target", "unit", "ready" }

--[[ for k, v in pairs( attr ) do
  ns.commitKey( k )
end

attr = nil ]]