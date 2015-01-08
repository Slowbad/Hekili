-- Classes.lua
-- July 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local getResourceID = ns.getResourceID
local getSpecializationKey = ns.getSpecializationKey



ns.initializeClassModule = function()
  -- do nothing, overwrite this stub with a class module.
end


ns.addHook = function( hook, func )

  class.hooks[ hook ] = func

end


ns.callHook = function( hook, ... )

  if class.hooks[ hook ] then
    class.hooks[ hook ] ( ... )
  end

end


-- Metatable to return modified information about an ability, if available.
local mt_modifiers = {
	__index = function(t, k)
		if not t.mods[ k ] then
			return t.elem[ k ]
		else
			return t.mods[ k ] ( t.elem[ k ] )
		end
	end
}


ns.setClass = function( name ) class.file = name end


local function storeAbilityElements( key, values )

  local ability = class.abilities[ key ]
	
	if not ability then
    ns.Error( "storeAbilityElements( " .. key .. " ) - no such ability in abilities table." )
    return
  end
	
  for k, v in pairs( values ) do
    ability.elem[ k ] = type( v ) == 'function' and setfenv( v, state ) or v
	end

end
ns.storeAbilityElements = storeAbilityElements


local function modifyElement( t, k, elem, value )
	
  local entry = class[ t ][ k ]
  
  if not entry then
    ns.Error( "modifyElement() - no such key '" .. k .. "' in '" .. t .. "' table." )
    return
  end

  if type( value ) == 'function' then
    entry.mods[ elem ] = setfenv( value, ns.state )
  else
    entry.elem[ elem ] = value
  end

end
ns.modifyElement = modifyElement


-- Wrapper for the ability table.
local function modifyAbility( k, elem, value )
  
  modifyElement( 'abilities', k, elem, value )

end
ns.modifyAbility = modifyAbility


local function addAbility( key, values, ... )
	
  if not values.id then
    ns.Error( "addAbility( " .. key .. " ) - values table is missing 'id' element." )
    return
  end
  
	local name = GetSpellInfo( values.id )
	if not name and values.id > 0 then
    ns.Error( "addAbility( " .. key .. " ) - unable to get name of spell #" .. values.id .. "." )
    return
  end
	
  class.abilities[ key ] = setmetatable( {
		name	= name,
		elem	= {}, -- storage for each attribute
		mods	= {}  -- storage for attribute modifiers
	}, mt_modifiers )
	
  class.abilities[ values.id ] = class.abilities[ key ]
  
  for i = 1, select( "#", ... ) do
    class.abilities[ select( i, ... ) ] = class.abilities[ key ]
  end


  ns.commitKey( key )

  storeAbilityElements( key, values )

  class.searchAbilities[ key ] = '|T' .. ( GetSpellTexture( values.id ) or 'Interface\\ICONS\\Spell_Nature_BloodLust' ) .. ':O|t ' .. class.abilities[ key ].name
	
end
ns.addAbility = addAbility


local storeAuraElements = function( key, ... )

  local aura = class.auras[ key ]
  
  if not aura then
    ns.Error( "storeAuraElements() - no aura '" .. key .. "' in auras table." )
    return
  end

  for i = 1, select( "#", ... ), 2 do
    local k, v = select( i, ... ), select( i+1, ... )
    
    if k and v then
      if k == 'id' then aura[k] = v
      else aura.elem[k] = v end
    end
  end

end
ns.storeAuraElements = storeAuraElements


local function modifyAura( key, elem, func )

	modifyElement( 'auras', key, elem, func )

end
ns.modifyAura = modifyAura


local function addAura( key, id, ... )

  local name = GetSpellInfo( id )
  
  class.auras[ key ] = setmetatable( {
		id		= id,
		key		= key,
		name	= name,
		elem	= {},
		mods	= {}
	}, mt_modifiers )
  
  ns.commitKey( key )
	
	-- Allow reference by ID as well.
  class.auras[ id ] = class.auras[ key ]
	
	-- Add the elements, front-loading defaults and just overriding them if something else is specified.
  storeAuraElements( key, 'duration', 30, 'max_stacks', 1, ... )
	
end
ns.addAura = addAura


local function addGlyph( key, id )

  local name = GetSpellInfo( id )

  if not name then
    ns.Error( "addGlyph() - unable to get glyph name from id#" .. id .. "." )
    return
  end
  
  class.glyphs[ key ] = {
    id = id,
    name = name
  }
  
  ns.commitKey( key )

end
ns.addGlyph = addGlyph  


local function addPerk( key, id )

  local name = GetSpellInfo( id )
  
  if not name then
    ns.Error( "addPerk( " .. key .. " ) - unable to get perk name from id#" .. id .. "." )
    return
  end
  
  class.perks[ key ] = {
    id = id,
    key = key,
    name = name
  }

  ns.commitKey( key )

end
ns.addPerk = addPerk


local function addTalent( key, id, ... )
	
  local name = GetSpellInfo( id )
	
	if not name then
    ns.Error( "addTalent() - unable to get talent name from id #" .. id .. "." )
    return
  end

  class.talents[ key ] = {
		id		= id,
		name	= name
	}
  
  ns.commitKey( key )

end
ns.addTalent = addTalent


local function addResource( resource, primary )

  class.resources[ resource ] = true
  
  if primary or #class.resources == 1 then class.primaryResource = resource end
  
  ns.commitKey( resource )
	
end
ns.addResource = addResource


local function removeResource( resource )

  class.resources[ resource ] = nil
  if class.primaryResource == resource then class.primaryResource = nil end

end
ns.removeResource = removeResource


local function addGearSet( name, ... )

  class.gearsets[ name ] = class.gearsets[ name ] or {}
  
  for i = 1, select( '#', ... ) do
    class.gearsets[ name ][ select( i, ... ) ] = 1
  end
  
  ns.commitKey( name )

end
ns.addGearSet = addGearSet


local function setGCD( key )

  class.gcd = key

end
ns.setGCD = setGCD


local function addHandler( key, func )

  local ability = class.abilities[ key ]
  
  if not ability then
    ns.Error( "addHandler() attempting to store handler for non-existant ability '" .. key .. "'." )
    return
  end
  
  ability.elem[ 'handler' ] = setfenv( func, state )

end
ns.addHandler = addHandler


local function runHandler( key )

  local ability = class.abilities[ key ]
  
  if not ability then
    -- ns.Error( "runHandler() attempting to run handler for non-existant ability '" .. key .. "'." )
    return
  end
  
	if ability.elem[ 'handler' ] then
		ability.elem[ 'handler' ] ()
	end
	
  if not ability.passive and state.time == 0 then
    state.false_start = state.now + state.offset
  end
  
	state.cast_start = 0
  
  ns.callHook( 'runHandler', key )

end
ns.runHandler = runHandler


local function addStance( key, ... )
  
  class.stances[ key ] = class.stances[ key ] or {}
  
  for i = 1, select( '#', ... ), 2 do
    class.stances[ key ][ select( i, ... ) ] = select( i + 1, ... )
  end
  
  ns.commitKey( key )
  
end
ns.addStance = addStance


ns.specializationChanged = function()

	for k, _ in pairs( state.spec ) do
		state.spec[ k ] = nil
	end

  state.spec.id, state.spec.name = GetSpecializationInfo( GetSpecialization() )
  state.spec.key = getSpecializationKey( state.spec.id )
	state.spec[ state.spec.key ] = true
  
  state.GUID = UnitGUID( 'player' )

	ns.updateGlyphs()
	ns.updateTalents()
	ns.updateGear()
	
  ns.callHook( 'specializationChanged' )
	ns.cacheCriteria()

  for i, v in ipairs( ns.queue ) do
    for j = 1, #v do
      ns.queue[i][j] = nil
    end
    ns.queue[i] = nil
  end

end



------------------------------
-- SHARED SPELLS/BUFFS/ETC. --
------------------------------

-- Bloodlust.
addAura( 'ancient_hysteria', 90355, 'duration', 40 )
addAura( 'bloodlust', 2825 , 'duration', 40 )
addAura( 'heroism', 32182, 'duration', 40 )
addAura( 'time_warp', 80353, 'duration', 40 )

-- Sated.
addAura( 'exhaustion', 57723, 'duration', 600 )
addAura( 'insanity', 95809, 'duration', 600 )
addAura( 'sated', 57724, 'duration', 600 )
addAura( 'temporal_displacement', 80354, 'duration', 600 )

-- Enchants.
addAura( 'dancing_steel', 104434, 'duration', 12, 'max_stacks', 2 )

-- Potions.
addAura( 'jade_serpent_potion', 105702, 'duration', 25 )
addAura( 'mogu_power_potion', 105706, 'duration', 25 )
addAura( 'virmens_bite_potion', 105697, 'duration', 25 )

-- Trinkets.
addAura( 'dextrous', 146308, 'duration', 20 )
addAura( 'vicious', 148903, 'duration', 10 )


-- Raid Buffs
addAura( 'attack_power_multiplier', -3, 'duration', 3600 )
addAura( 'critical_strike', -6, 'duration', 3600 )
addAura( 'haste', -4, 'duration', 3600 )
addAura( 'mastery', -7, 'duration', 3600 )
addAura( 'multistrike', -8, 'duration', 3600 )
addAura( 'spell_power_multiplier', -5, 'duration', 3600 )
addAura( 'stamina', -2, 'duration', 3600 )
addAura( 'str_agi_int', -1, 'duration', 3600 )
addAura( 'versatility', -9, 'duration', 3600 )


-- Racials.
-- AddSpell( 26297,	"berserking",	10 )
addAbility( 'berserking',
			{
        id = 26297,
				spend = 0,
				cast = 0,
				gcdType = 'off',
				cooldown = 180
			} )

addHandler( 'berserking', function ()
	applyBuff( 'berserking' )
end )

addAura( 'berserking', 26297, 'duration', 10 )


-- AddSpell( 20572,	"blood_fury",	15 )
addAbility( 'blood_fury',
			{
        id = 20572,
				spend = 0,
				cast = 0,
				gcdType = 'off',
				cooldown = 120
			} )
			
addHandler( 'blood_fury', function ()
	applyBuff( 'blood_fury', 15 )
end )

addAura( 'blood_fury', 20572, 'duration', 15 )


addAbility( 'arcane_torrent', {
    id = 28730,
    spend = 0,
    cast = 0,
    gcdType = 'spell',
    cooldown = 120
  }, 50613, 80483, 129597, 155145, 25046, 69179 )

addHandler( 'arcane_torrent', function ()

  if mana then gain( 0.03 * mana.max, "mana" ) end
  interrupt()
  
  if class.death_knight then gain( 20, "runic_power" )
  elseif class.hunter then gain( 15, "focus" )
  elseif class.monk then gain( 1, "chi" )
  elseif class.paladin then gain( 1, "holy_power" )
  elseif class.rogue then gain( 15, "energy" )
  elseif class.warrior then gain( 15, "rage" ) end
  
end )


-- Special Instructions
addAbility( 'wait', {
    id = -1,
    name = 'Wait',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 0
  } )



-- DEFAULTS

ns.storeDefault = function( name, category, version, import )
	
	if not ( name and category and version and import ) then
		return
	end
	
  class.defaults[ #class.defaults + 1 ] = {
		name	= name,
		type	= category,
		version = version,
		import	= import:gsub("([^|])|([^|])", "%1||%2")
	}
  
end


ns.restoreDefaults = function( category )

  local profile = Hekili.DB.profile
  
  -- By default, restore action lists.
  if not category or category == 'actionLists' then
    for i, default in ipairs( class.defaults ) do
      if default.type == 'actionLists' then
        local reload = true
        local index
        
        for j, list in ipairs( profile.actionLists ) do
          if list.Name == default.name then
            reload = list.Default and ( list.Release < default.version )
            index = j
            break
          end
        end
        
        if reload then
          local import = ns.deserializeActionList( default.import )
          
          if import and type( import ) == 'table' then
            import.Name = default.name
            import.Release = default.version
            import.Default = true
            if not index then index = #profile.actionLists + 1 end
            ns.Error( "rD() - putting " .. default.name .. " at index " .. index .. "." )
            profile.actionLists[ index ] = import
          else
            ns.Error( "restoreDefaults() - unable to import actionList " .. default.name .. "." )
          end
        end
			end
		end
	end
	
	
  if not category or category == 'displays' then
		for i, default in ipairs( class.defaults ) do
			if default.type == 'displays' then
				local reload = true
        local index
        
				for j, display in ipairs( profile.displays ) do
					if display.Name == default.name then
            index = j
            reload = display.Default and ( display.Release < default.version )
						break
					end
				end
				
				if reload then
          ns.Error( "restoreDefaults() - didn't find " .. default.name .. "." )
					local import = ns.deserializeDisplay( default.import )
					
					if import and type( import ) == 'table' then
            import.Name = default.name
            import.Release = default.version
            import.Default = true
            
            if index then
              local existing = profile.displays[index]
              import.Enabled = existing.Enabled
              import['Use SpellFlash'] = existing['Use SpellFlash']
              import['SpellFlash Color'] = existing['SpellFlash Color']
              import['PvE Visibility'] = existing['PvE Visibility']
              import['PvE Visibility'] = existing['PvE Visibility']
              import.x = existing.x
              import.y = existing.y
              import.rel = existing.rel
              import['Icons Shown'] = existing['Icons Shown']
              import['Spacing'] = existing['Spacing']
              import['Queue Direction'] = existing['Queue Direction']
              import['Primary Icon Size'] = existing['Primary Icon Size']
              import['Queued Icon Size'] = existing['Queued Icon Size']
              import['Font'] = existing['Font']
              import['Primary Font Size'] = existing['Primary Font Size']
              import['Queued Font Size'] = existing['Queued Font Size']
              import['Action Captions'] = existing['Action Captions']
              import['Primary Caption'] = existing['Primary Caption']
              import['Primary Caption Aura'] = existing['Primary Caption Aura']
            else
              index = #profile.displays + 1
            end
            
            profile.displays[ index ] = import
					
            for j, hook in ipairs( profile.displays[ #profile.displays ].Queues ) do
              if type( hook['Action List'] ) == 'string' then
                for k, list in ipairs( profile.actionLists ) do
                  if list.Name == hook['Action List'] then
										hook['Action List'] = k
										break
									end
								end
                
                if type( hook['Action List'] ) == 'string' then
									-- The list wasn't found.
									hook['Action List'] = 0
								end
							end
						end
					else
						ns.Error( "restoreDefaults() - unable to import '" .. default.name .. "' display." )
					end
				end
			end
		end
	end
	
  ns.refreshOptions()
  ns.loadScripts()
	
end


ns.isDefault = function( name, category )

	if not name or not category then
		return false
	end
  
	for i, default in ipairs( class.defaults ) do
		if default.type == category and default.name == name then
			return true, i
		end
	end
	
	return false

end