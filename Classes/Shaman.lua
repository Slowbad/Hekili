-- Shaman.lua
-- August 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addExclusion = ns.addExclusion

local addHook = ns.addHook
local callHook = ns.callHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

local removeResource = ns.removeResource

local setClass = ns.setClass
local setGCD = ns.setGCD

local storeDefault = ns.storeDefault

-- This table gets loaded only if there's a pported class/specialization.
if (select(2, UnitClass('player')) == 'SHAMAN') then

  ns.initializeClassModule = function ()

    setClass( 'SHAMAN' )
    
    addResource( 'mana', true )

    addTalent( 'natures_guardian', 30884 )
    addTalent( 'stone_bulwark_totem', 108270 )
    addTalent( 'astral_shift', 108271 )
    addTalent( 'frozen_power', 63374 )
    addTalent( 'earthgrab_totem', 51485 )
    addTalent( 'windwalk_totem', 108273 )
    addTalent( 'call_of_the_elements', 108285 )
    addTalent( 'totemic_persistence', 108284 )
    addTalent( 'totemic_projection', 108287 )
    addTalent( 'elemental_mastery', 16166 )
    addTalent( 'ancestral_swiftness', 16188 )
    addTalent( 'echo_of_the_elements', 108283 )
    addTalent( 'rushing_streams', 147074 )
    addTalent( 'ancestral_guidance', 108281 )
    addTalent( 'conductivity', 108282 )
    addTalent( 'unleashed_fury', 117012 )
    addTalent( 'primal_elementalist', 117013 )
    addTalent( 'elemental_blast', 117014 )
    addTalent( 'elemental_fusion', 152257 )
    addTalent( 'storm_elemental_totem', 152256 )
    addTalent( 'liquid_magma', 152255 )

    -- Major Glyphs.
    addGlyph( 'capacitor_totem', 55442 )
    addGlyph( 'chain_lightning', 55449 )
    addGlyph( 'chaining', 55452 )
    addGlyph( 'cleansing_waters', 55445 )
    addGlyph( 'ephemeral_spirits', 159640 )
    addGlyph( 'eternal_earth', 147781 )
    addGlyph( 'feral_spirit', 63271 )
    addGlyph( 'fire_elemental_totem', 55455 )
    addGlyph( 'fire_nova', 55450 )
    addGlyph( 'flame_shock', 55447 )
    addGlyph( 'frost_shock', 55443 )
    addGlyph( 'frostflame_weapon', 161654 )
    addGlyph( 'ghost_wolf', 59289 )
    addGlyph( 'grounding', 159643 )
    addGlyph( 'grounding_totem', 55441 )
    addGlyph( 'healing_stream_totem', 55456 )
    addGlyph( 'healing_wave', 55440 )
    addGlyph( 'hex', 63291 )
    addGlyph( 'lava_spread', 159644 )
    addGlyph( 'lightning_shield', 101052 )
    addGlyph( 'purge', 55439 )
    addGlyph( 'purging', 147762 )
    addGlyph( 'reactive_shielding', 159647 )
    addGlyph( 'riptide', 63273 )
    addGlyph( 'shamanistic_rage', 63280 )
    addGlyph( 'shamanistic_resolve', 159648 )
    addGlyph( 'shocks', 159649 )
    addGlyph( 'spirit_walk', 55454 )
    addGlyph( 'spiritwalkers_aegis', 159651 )
    addGlyph( 'spiritwalkers_focus', 159650 )
    addGlyph( 'spiritwalkers_grace', 55446 )
    addGlyph( 'telluric_currents', 55453 )
    addGlyph( 'thunder', 63270 )
    addGlyph( 'totemic_recall', 55438 )
    addGlyph( 'totemic_vigor', 63298 )
    addGlyph( 'unstable_earth', 55437 )
    addGlyph( 'water_shield', 55436 )
    addGlyph( 'wind_shear', 55451 )
    
    -- Minor Glyphs.
    addGlyph( 'astral_fixation', 147787 )
    addGlyph( 'astral_recall', 58058 )
    addGlyph( 'deluge', 63279 )
    addGlyph( 'elemental_familiars', 147788 )
    addGlyph( 'far_sight', 58059 )
    addGlyph( 'flaming_serpents', 147772 )
    addGlyph( 'ghostly_speed', 159642 )
    addGlyph( 'lava_lash', 55444 )
    addGlyph( 'lingering_ancestors', 147784 )
    addGlyph( 'rain_of_frogs', 147707 )
    addGlyph( 'spirit_raptors', 147783 )
    addGlyph( 'spirit_wolf', 147770 )
    addGlyph( 'compy', 147785 )
    addGlyph( 'lakestrider', 55448 )
    addGlyph( 'spectral_wolf', 58135 )
    addGlyph( 'thunderstorm', 62132 )
    addGlyph( 'totemic_encirclement', 58057 )
    
    -- Player Buffs / Debuffs
    addAura( 'ancestral_swiftness', 16188, 'duration', 3600 )
    addAura( 'ascendance', 114051, 'duration', 15 )
    addAura( 'earthquake', 61882, 'duration', 10 )
    addAura( 'echo_of_the_elements', 159103, 'duration', 20 )
    addAura( 'elemental_blast', 117014, 'duration', 8 )
    addAura( 'elemental_fusion', 157174, 'duration', 15, 'max_stack', 2 )
    addAura( 'elemental_mastery', 16166, 'duration', 20 )
    addAura( 'exhaustion', 57723, 'unit', 'player', 'duration', 600 )
    addAura( 'improved_chain_lightning', 157766, 'duration', 10 )
    class.auras[ 'enhanced_chain_lightning' ] = class.auras[ 'improved_chain_lightning' ] -- alias bc SimC uses both.
    addAura( 'flame_shock', 8050, 'duration', 30 )
    addAura( 'frost_shock', 8056, 'duration', 8 )
    addAura( 'healing_rain', 73920, 'duration', 10 )
    addAura( 'lava_surge', 77762 , 'duration', 6 )
    addAura( 'lightning_shield', 324, 'duration', 3600 )	
    addAura( 'liquid_magma', 152255, 'duration', 10, 'affects', 'pet' )
    addAura( 'maelstrom_weapon', 51530 , 'duration', 30, 'max_stack', 5 )
    addAura( 'sated', 57724, 'unit', 'player', 'duration', 600 )
    addAura( 'spiritwalkers_grace', 79206, 'duration', 15 )
    addAura( 'stormstrike', 17364 , 'duration', 15 )
    addAura( 'thunderstorm', 51490, 'duration', 5 )
    addAura( 'unleash_flame', 73683 , 'duration', 20 )
    addAura( 'unleash_wind', 73681 , 'duration', 30, 'max_stack', 6 )
    addAura( 'unleashed_fury', 118472, 'duration', 10 )
    addAura( 'windstrike', 115356, 'duration', 15 )
    
    addPerk( 'enhanced_chain_lightning', 157765 )
    class.perks[ 'improved_chain_lightning' ] = class.perks[ 'enhanced_chain_lightning' ] -- alias bc SimC uses both.
    addPerk( 'enhanced_unleash', 157784 )
    addPerk( 'improved_flame_shock', 157804 )
    addPerk( 'improved_lightning_shield', 157774 )
    addPerk( 'improved_maelstrom_weapon', 157807 )
    addPerk( 'improved_reincarnation', 157764 )
    
    addExclusion( 324 ) -- exclude LS from target detection; enemy could be inaccessible
    addExclusion( 26364 ) -- LS damage spellID
    
    -- Gear Sets
    addGearSet( 'tier17', 115579, 115576, 115577, 115578, 115575 )
    addGearSet( 'tier16_caster', 99341, 99347, 99340, 99342, 99095 )
    addGearSet( 'tier16_melee', 99347, 99340, 99341, 99342, 99343 )
    addGearSet( 'tier15_melee', 96689, 96690, 96691, 96692, 96693 )
    addGearSet( 'tier14_melee', 87138, 87137, 87136, 87135, 87134 )

    addHook( "onInitialize", function ()
      local found, empty = false, nil
      
      for i = 1, 5 do
        if not empty and Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == nil then
          empty = i
        elseif Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == 'magma' then
          found = i
          break
        end
      end
      
      if not found and empty then
        Hekili.DB.profile[ 'Toggle ' ..empty.. ' Name' ] = 'magma'
        found = empty
      end
      
      if type( found ) == 'number' then
        Hekili.DB.profile[ 'Toggle_' .. found ] = Hekili.DB.profile[ 'Toggle_' .. found ] == nil and true or Hekili.DB.profile[ 'Toggle_' .. found ]
      end
    end )
    
    
    ns.RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
  
      if unit == 'player' and class.abilities[ spellID ] and class.abilities[ spellID ].key == 'ascendance' then
        class.abilities[ spellID ].last = GetTime()
      end
      
    end )

    
    addHook( "timeToReady", function( ability, delay )
      if ability == 'ascendance' and class.abilities[ ability ].last and state.now + state.offset + state.delay - class.abilities[ ability ].last < 180 then
        return class.abilities[ ability ].last + 180
      end
      return delay
    end )

    
    -- Set racial to the right spellID.
    class.abilities[ 'blood_fury' ].elem.id = 33697


    addAbility(	'ancestral_swiftness',
          {
            id = 16188,
            spend = 0,
            cast = 0,
            gcdType	= 'off',
            cooldown = 90
          } )

    addAbility(	'ascendance',
          {
            id = 114051,
            known = 114049,
            spend = 0.052,
            cast = 0,
            gcdType = 'off',
            cooldown = 120
          }, 114050 )
    
    addAbility( 'bloodlust',
          {
            id = 2825,
            spend = 0.215,
            cast = 0,
            gcdType = 'off',
            cooldown = 300
          } )
    
    addAbility( 'chain_lightning',
          {
            id = 421,
            spend = 0.01,
            cast = 2.0,
            gcdType = 'spell',
            cooldown = 0,
            hostile = true
          } )

    addAbility( 'earth_elemental_totem', 
          {
            id = 2062,
            spend = 0.281,
            cast = 0,
            gcdType = 'totem',
            cooldown = 300
          } )

    addAbility( 'earth_shock',
          {
            id = 8042,
            spend = 0.012,
            cast = 0,
            gcdType = 'spell',
            cooldown = 6,
            hostile = true
          } )

    addAbility( 'earthquake',
          {
            id = 61882, 
            spend = 0.008,
            cast = 2.5,
            gcdType = 'spell',
            cooldown = 10,
            charges = 1,
            hostile = true
          } )

    addAbility( 'elemental_blast',
          {
            id = 117014,
            spend = 0,
            cast = 2.0,
            gcdType = 'spell',
            cooldown = 12,
            hostile = true
          } )	

    addAbility( 'elemental_mastery',
          {
            id = 16166,
            spend = 0,
            cast = 0,
            gcdType = 'off',
            cooldown = 120
          } )

    addAbility( 'feral_spirit',
          {
            id = 51533,
            spend = 0.12,
            cast = 0,
            gcdType = 'spell',
            cooldown = 120
          } )	

    addAbility( 'fire_elemental_totem',
          {
            id = 2894,
            spend = 0.269,
            cast = 0,
            gcdType = 'totem',
            cooldown = 300
          } )

    addAbility( 'fire_nova',
          {
            id = 1535,
            spend = 0.137,
            cast = 0,
            gcdType = 'spell',
            cooldown = 4.5,
            charges = 1,
            hostile = true
          } )

    addAbility( 'flame_shock',
          {
            id = 8050,
            spend = 0.012,
            cast = 0,
            gcdType = 'spell',
            cooldown = 6,
            hostile = true
          } )

    addAbility( 'frost_shock',
          {
            id = 8056,
            spend = 0.012,
            cast = 0,
            gcdType = 'spell',
            cooldown = 6,
            hostile = true
          } )
    
    class.abilities[ 'shock' ] = class.abilities[ 'frost_shock' ]
    ns.keys[ 'shock' ] = true

    addAbility( 'healing_rain',
          {
            id = 73920,
            spend = 0.216,
            cast = 2,
            gcdType = 'spell',
            cooldown = 10
          } )	

    addAbility( 'healing_surge',
          {
            id = 8004,
            spend = 0.207,
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 0
          } )	

    addAbility( 'heroism',
          {
            id = 32182,
            spend = 0.215,
            cast = 0,
            gcdType = 'off',
            cooldown = 300
          } )	
    
    addAbility( 'lava_beam',
          {
            id = 114074,
            known = function() return spec.elemental and buff.ascendance.up end,
            spend = 0.01,
            cast = 2,
            gcdType = 'spell',
            cooldown = 0,
            hostile = true
          } )

    addAbility( 'lava_burst',
          {
            id = 51505,
            known = function() return spec.elemental and level >= 34 end,
            spend = 0.005,
            cast = 2,
            gcdType = 'spell',
            charges = 1,
            cooldown = 8,
            hostile = true
          } )


    addAbility( 'lava_lash',
          {
            id = 60103,
            spend = 0.01,
            cast = 0,
            gcdType = 'melee',
            cooldown = 9,
            charges = 1,
            hostile = true
          } )

    addAbility( 'lightning_bolt',
          {
            id = 403,
            spend = 0.018,
            cast = 2.5,
            gcdType = 'spell',
            cooldown = 0,
            hostile = true
          } )

    addAbility( 'lightning_shield',
          {
            id = 324,
            spend = 0,
            cast = 0,
            gcdType = 'spell',
            cooldown = 0
          } )

    addAbility( 'liquid_magma',
          {
            id = 152255,
            spend = 0,
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
            hostile = true
          } )

    addAbility( 'magma_totem',
          {
            id = 8190,
            spend = 0.211,
            cast = 0,
            gcdType = 'totem',
            cooldown = 0,
            hostile = true
          } )

    addAbility( 'searing_totem',
          {
            id = 3599,
            spend = 0.03,
            cast = 0,
            gcdType = 'totem',
            cooldown = 0,
            hostile = true
          } )

    addAbility( 'spiritwalkers_grace',
          {
            id = 79206,
            spend = 0.141,
            cast = 0,
            gcdType = 'off',
            cooldown = 120
          } )

    addAbility( 'storm_elemental_totem',
          {
            id = 152256,
            spend = 0.269,
            cast = 0,
            gcdType = 'totem',
            cooldown = 300
          } )

    addAbility( 'stormstrike',
          {
            id = 17364,
            known = function() return spec.enhancement and not buff.ascendance.up end,
            spend = 0.01,
            cast = 0,
            gcdType = 'melee',
            charges = 1,
            cooldown = 7.5,
            hostile = true
          } )
    
    addAbility( 'strike',
          {
            id = 73899,
            spend = 0.094,
            cast = 0,
            gcdType = 'melee',
            cooldown = 8,
            charges = 1,
            hostile = true
          } )
    
    addAbility( 'thunderstorm',
          {
            id = 51490,
            spend = 0,
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
            hostile = true
          } )

    addAbility( 'unleash_elements',
          {
            id = 73680,
            spend = 0.075,
            cast = 0,
            gcdType = 'spell',
            cooldown = 15
          } )

    addAbility( 'unleash_flame',
          {
            id = 165462,
            spend = 0.075,
            cast = 0,
            gcdType = 'spell',
            cooldown = 15
          } )

    addAbility( 'wind_shear',
          {
            id = 57994,
            spend = 0.094,
            cast = 0,
            gcdType = 'off',
            cooldown = 12
          } )

    addAbility( 'windstrike',
          {
            id = 115356,
            known = function() return spec.enhancement and buff.ascendance.up end,
            spend = 0.01,
            cast = 0,
            gcdType = 'melee',
            cooldown = 7.5,
            charges = 1,
            hostile = true
          } )

          
    ns.addHook( "specializationChanged", function ()
    
      for k,v in pairs( class.abilities ) do
        for key,mod in pairs( v.mods ) do
          class.abilities[ k ].mods[ key ] = nil
        end
      end
      
      -- Enhancement
      if state.spec.id == 263 then
        Hekili.minGCD = 1.0
        
        modifyAbility( 'ascendance', 'id', 114051 )

        modifyAbility( 'ascendance', 'spend', function( x )
          return x * 0.25
        end )
        
        modifyAbility( 'bloodlust', 'spend', function( x )
          return x * 0.25
        end )

        modifyAbility( 'chain_lightning', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x * haste
        end )
        
        modifyAbility( 'chain_lightning', 'spend', function( x )
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x
        end )

        modifyAbility( 'earth_elemental_totem', 'spend', function( x )
          return x * 0.25
        end )
        
        modifyAbility( 'elemental_blast', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x * haste
        end )

        modifyAbility( 'feral_spirit', 'cooldown', function( x )
          if glyph.ephemeral_spirits.enabled then x = x / 2 end
          return x
        end )

        modifyAbility( 'feral_spirit', 'spend', function( x )
          return x * 0.25
        end )

        modifyAbility( 'fire_nova', 'cooldown', function( x )
          if cooldown.fire_nova.charges > 1 then return 0 end
          return x * haste
        end )

        modifyAbility( 'fire_nova', 'spend', function( x )
          if spec.enhancement then return x * 0.25 end
          return x
        end )
        
        modifyAbility( 'fire_nova', 'charges', function( x )
          if talent.echo_of_the_elements.up then return 2 end
          return x
        end )
        
        modifyAbility( 'flame_shock', 'cooldown', function( x )
          return x * haste
        end )
        
        modifyAbility( 'flame_shock', 'spend', function( x )
          return x * 0.10
        end )

        modifyAbility( 'frost_shock', 'cooldown', function( x )
          if glyph.frost_shock.enabled then x = 4 end
          return x * haste
        end )
        
        modifyAbility( 'frost_shock', 'spend', function( x )
          return x * 0.10
        end )
        
        modifyAbility( 'healing_rain', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x * haste
        end )
        
        modifyAbility( 'healing_rain', 'spend', function( x )
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x
        end )

        modifyAbility( 'healing_surge', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x * haste
        end )
        
        modifyAbility( 'healing_surge', 'spend', function( x )
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x
        end )

        modifyAbility( 'heroism', 'spend', function( x )
          return x * 0.25
        end )

        modifyAbility( 'lava_lash', 'cooldown', function( x )
          if cooldown.lava_lash.charges > 1 then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'lava_lash', 'charges', function( x )
          if talent.echo_of_the_elements.up then return 2 end
          return x
        end )

        modifyAbility( 'lightning_bolt', 'cast', 2.5 )

        modifyAbility( 'lightning_bolt', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x * haste
        end )
        
        modifyAbility( 'lightning_bolt', 'spend', function( x )
          if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end
          return x
        end )

        modifyAbility( 'magma_totem', 'spend', function( x )
          return x * 0.25
        end )

        modifyAbility( 'searing_totem', 'spend', function( x )
          return x * 0.25
        end )			
        
        modifyAbility( 'stormstrike', 'charges', function( x )
          if talent.echo_of_the_elements.enabled then return 2 end
          return x
        end )
        
        modifyAbility( 'stormstrike', 'cooldown', function( x )
          if cooldown.stormstrike.charges > 1 then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'unleash_elements', 'cooldown', function( x )
          return x * haste
        end )

        modifyAbility( 'unleash_elements', 'spend', function( x )
          return x * 0.25
        end )
        
        modifyAbility( 'wind_shear', 'spend', function( x )
          return x * 0.25
        end )
        
        modifyAbility( 'windstrike', 'charges', function( x )
          if talent.echo_of_the_elements.enabled then return 2 end
          return x
        end )
        
        modifyAbility( 'windstrike', 'cooldown', function( x )
          if cooldown.windstrike.charges > 1 then return 0 end
          return x * haste
        end )
        
        modifyAura( 'ascendance', 'id', 114051 )
        
        modifyAura( 'lightning_shield', 'max_stack', 1 )

      -- Elemental
      elseif state.spec.id == 262 then
        Hekili.minGCD = 1.5

        modifyAbility( 'ascendance', 'id', function( x )
          return 114050
        end )

        modifyAbility( 'chain_lightning', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'earthquake', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          if buff.enhanced_chain_lightning.up then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'earthquake', 'charges', function( x )
          if talent.echo_of_the_elements.enabled then return 2 end
          return x
        end )
        
        modifyAbility( 'earthquake', 'cooldown',  function( x )
          if cooldown.earthquake.charges > 1 then return 0 end
         return x
        end )
    
        modifyAbility( 'elemental_blast', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )
    
        modifyAbility( 'frost_shock', 'cooldown',  function( x )
          if buff.echo_of_the_elements.up then return 0 end
          if glyph.frost_shock.enabled then x = x - 2 end
          return x
        end )

        modifyAbility( 'healing_rain', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )

        modifyAbility( 'healing_surge', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )

        modifyAbility( 'lava_burst', 'cast', function( x )
          if buff.lava_surge.up then return 0
          elseif buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'lava_burst', 'charges', function( x )
          if talent.echo_of_the_elements.up then return 2 end
          return x
        end )
        
        modifyAbility( 'lava_burst', 'cooldown', function( x )
          if buff.lava_surge.up and cast_start > 0 and buff.lava_surge.applied > cast_start then return 0 end
          if buff.ascendance.up then return 0 end
          if cooldown.lava_burst.charges > 1 then return 0 end
          return x
        end )
        
        modifyAbility( 'lightning_bolt', 'cast', 2.0 )

        modifyAbility( 'lightning_bolt', 'cast', function( x )
          if buff.ancestral_swiftness.up then return 0 end
          return x * haste
        end )
        
        modifyAbility( 'spiritwalkers_grace', 'cooldown', function( x )
          if glyph.spiritwalkers_focus.enabled then x = x - 60 end
          return x
        end )
        
        modifyAbility( 'thunderstorm', 'cooldown', function( x )
          if glyph.thunder.enabled then x = x - 10 end
          return x
        end )

        modifyAura( 'ascendance', 'id', 114050 )

        modifyAura( 'lightning_shield', 'max_stack', 15 )
        
        modifyAura( 'lightning_shield', 'max_stack', function( x )
          if perk.improved_lightning_shield.enabled then x = 20 end
          return x
        end )

      end
      
      -- Shared
      modifyAbility( 'fire_elemental_totem', 'cooldown', function( x )
        if glyph.fire_elemental_totem.enabled then x = x / 2 end
        return x
      end )
      
      modifyAbility( 'fire_elemental_totem', 'spend', function( x )
        if spec.enhancement then return x * 0.25 end
        return x
      end )

    end )
    

    -- All actions that modify the game state are included here.
    addHandler( 'ancestral_swiftness', function ()
      applyBuff( 'ancestral_swiftness', 60 ) 
    end )


    addHandler( 'ascendance', function ()
      applyBuff( 'ascendance', 15 )
      setCooldown( 'lava_burst', 0 )
      setCooldown( 'stormstrike', 0 )
      setCooldown( 'windstrike', 0 )
      setCooldown( 'strike', 0 )
    end )


    addHandler( 'berserking', function ()
      applyBuff( 'berserking', 10 )
    end )

    addHandler( 'blood_fury', function ()
      applyBuff( 'blood_fury', 15 )
    end )

    addHandler( 'bloodlust', function ()
      applyBuff( 'bloodlust', 40 )
      applyDebuff( 'player', 'sated', 600 )
    end )

    addHandler( 'chain_lightning', function ()
      if buff.maelstrom_weapon.stack == 5 then removeBuff( 'maelstrom_weapon' )
      elseif buff.ancestral_swiftness.up then removeBuff( 'ancestral_swiftness' )
      elseif buff.maelstrom_weapon.up then removeBuff( 'maelstrom_weapon' ) end
      
      if perk.enhanced_chain_lightning.enabled then
        applyBuff( 'improved_chain_lightning', 15, min( glyph.chain_lightning.enabled and 5 or 3, active_enemies) )
        applyBuff( 'enhanced_chain_lightning', 15, min( glyph.chain_lightning.enabled and 5 or 3, active_enemies) )
      end
      
      if buff.lightning_shield.up and buff.lightning_shield.stack < buff.lightning_shield.max_stack then
        addStack( 'lightning_shield', 3600, min( glyph.chain_lightning.enabled and 5 or 3, active_enemies) )
      end
    end )

    addHandler( 'earth_elemental_totem', function ()
      summonTotem( 'earth_elemental_totem', 'earth', 60 )

      if talent.storm_elemental_totem.enabled then setCooldown( 'storm_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) ) end
      setCooldown( 'fire_elemental_totem', max( cooldown.fire_elemental_totem.remains, 61 ) )
      -- Remove Fire Elemental Pet?  Reset Fire Elemental Totem?
    end )

    addHandler( 'earth_shock', function ()
      local cooldown = spec.elemental == 1 and 5 or 6 * haste
      setCooldown( 'flame_shock', cooldown )
      setCooldown( 'frost_shock', cooldown )
      if buff.lightning_shield.stack > 1 then
        buff.lightning_shield.count = 1
      end
    end )

    addHandler( 'earthquake', function ()
      removeBuff( 'improved_chain_lightning' )
      removeBuff( 'enhanced_chain_lightning' )
      applyDebuff( 'target', 'earthquake', 10 )
    end )
    
    addHandler( 'elemental_blast', function ()
      applyBuff( 'elemental_blast', 8 )
    end )

    addHandler( 'elemental_mastery', function ()
      applyBuff( 'elemental_mastery', 20 )
    end )

    
    addHandler( 'fire_elemental_totem', function ()
      if glyph.fire_elemental_totem.enabled then
        summonTotem( 'fire_elemental_totem', 'fire', 30 )
      else	
        summonTotem( 'fire_elemental_totem', 'fire', 60 )
      end
      
      if talent.storm_elemental_totem.enabled then setCooldown( 'storm_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) ) end
      setCooldown( 'earth_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) )
      -- Remove Earth Elemental Pet?  Reset Earth Elemental Totem?
    end )

    addHandler( 'fire_nova', function ()
      removeBuff( 'unleash_flame' )
    end )

    addHandler( 'flame_shock', function ()
      local cooldown = spec.elemental == 1 and 5 or 6 * haste
      applyDebuff( 'target', 'flame_shock', 30 )
      removeBuff( 'unleash_flame' )
      removeBuff( 'elemental_fusion' )
      setCooldown( 'earth_shock', cooldown )
      setCooldown( 'frost_shock', cooldown )
    end )

    addHandler( 'frost_shock', function()
      local cooldown = 6
      
      if glyph.frost_shock.enabled then cooldown = cooldown - 2 end
      if spec.enhancement then cooldown = cooldown * haste end
      
      removeBuff( 'elemental_fusion' )
      applyDebuff( 'target', 'frost_shock', 8 )
      setCooldown( 'earth_shock', cooldown )
      setCooldown( 'flame_shock', cooldown )
    end )

    addHandler( 'healing_rain', function ()
      if buff.ancestral_swiftness.up then removeBuff( 'ancestral_swiftness' )
      elseif buff.maelstrom_weapon.up then removeBuff( 'maelstrom_weapon' ) end
      applyBuff( 'healing_rain', 10 )
    end )
    
    addHandler( 'healing_surge', function ()
      if buff.ancestral_swiftness.up then removeBuff( 'ancestral_swiftness' )
      elseif buff.maelstrom_weapon.up then removeBuff( 'maelstrom_weapon' ) end
    end )

    addHandler( 'heroism', class.abilities[ 'bloodlust' ].handler )

    addHandler( 'lava_beam', class.abilities[ 'chain_lightning' ].handler )
    
    addHandler( 'lava_burst', function ()
      if buff.lava_surge.up and ( cast_start == 0 or buff.lava_surge.applied < cast_start ) then removeBuff( 'lava_surge' ) end
      if buff.lightning_shield.up then addStack( 'lightning_shield', 3600, 1 ) end
    end )
    
    addHandler( 'lava_lash', function ()
      if talent.elemental_fusion.enabled then
        applyBuff( 'elemental_fusion', 20, max(2, buff.elemental_fusion.stack + 1) )
      end
    end )

    addHandler( 'lightning_bolt', function ()
      if buff.maelstrom_weapon.stack == 5 then removeBuff( 'maelstrom_weapon' )
      elseif buff.ancestral_swiftness.up then removeBuff( 'ancestral_swiftness' )
      elseif buff.maelstrom_weapon.up then removeBuff( 'maelstrom_weapon' ) end
      
      if buff.lightning_shield.up and buff.lightning_shield.stack < buff.lightning_shield.max_stack then
        addStack( 'lightning_shield', 3600, 1 )
      end
    end )

    addHandler( 'lightning_shield', function ()
      applyBuff( 'lightning_shield', 3600 )
    end )
    
    addHandler( 'liquid_magma', function ()
      applyBuff( 'liquid_magma', 10 )
    end )

    addHandler( 'magma_totem', function ()
      summonTotem( 'magma_totem', 'fire', 60 )
    end )

    addHandler( 'searing_totem', function ()
      summonTotem( 'searing_totem', 'fire', 60 )
    end )

    addHandler( 'spiritwalkers_grace', function ()
      if glyph.spiritwalkers_focus.enabled then applyBuff( 'spiritwalkers_grace', 1, 8 )
      elseif glyph.spiritwalkers_focus.enabled then applyBuff( 'spiritwalkers_grace', 1, 20 )
      else applyBuff( 'spiritwalkers_grace', 1, 15 ) end
    end )

    addHandler( 'storm_elemental_totem', function ()
      summonTotem( 'storm_elemental_totem', 'air', 60 )
      setCooldown( 'fire_elemental_totem', max( cooldown.fire_elemental_totem.remains, 61 ) )
      setCooldown( 'earth_elemental_totem', max( cooldown.earth_elemental_totem.remains, 61 ) )
    end )

    addHandler( 'stormstrike', function ()
      setCooldown( 'strike', 7.5 * haste )
      if set_bonus.tier17_2pc and cooldown.feral_spirit.remains > 0 then
        setCooldown( 'feral_spirit', max(0, cooldown.feral_spirit.remains - 5) )
      end
      applyDebuff( 'target', 'stormstrike', 15 )
      if set_bonus.tier15_2pc_melee then addStack( 'maelstrom_weapon', 30, 2 ) end
    end )

    addHandler( 'thunderstorm', function ()
      applyDebuff( 'target', 'thunderstorm', 5 )
    end )

    addHandler( 'unleash_elements', function ()
      if talent.unleashed_fury.enabled then applyBuff( 'unleashed_fury', 10 ) end
      applyBuff( 'unleash_wind', 12, 6 )
      applyBuff( 'unleash_flame', 8 )
    end )
    
    addHandler( 'unleash_flame', function ()
      applyBuff( 'unleash_flame', 20 )
    end )

    addHandler( 'wind_shear', function ()
      interrupt()
    end )

    addHandler( 'windstrike', function ()
      setCooldown( 'strike', 7.5 * haste )
      setCooldown( 'stormstrike', 7.5 * haste )
      applyDebuff( 'target', 'windstrike', 15 )
      if set_bonus.tier15_2pc_melee then addStack( 'maelstrom_weapon', 30, 2 ) end
    end )
    
    -- Pick an instant cast ability for checking the GCD.
    setGCD( 'lightning_shield' )
    
    -- Import strings
    storeDefault( "Enh: Single Target", "actionLists", 20150224.1, "^1^T^SEnabled^B^SName^SEnh:~`Single~`Target^SRelease^N20150223.1^SSpecialization^N263^SActions^T^N1^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SScript^Stoggle.magma&totem.fire.remains>10^SAbility^Sliquid_magma^t^N2^T^SEnabled^B^SRelease^N201504.171^SName^SAncestral~`Swiftness^SAbility^Sancestral_swiftness^t^N3^T^SEnabled^B^SName^SSearing~`Totem^SRelease^N201504.171^SScript^S!totem.fire.active^SAbility^Ssearing_totem^t^N4^T^SEnabled^B^SName^SUnleash~`Elements^SRelease^N201504.171^SScript^S(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee)^SAbility^Sunleash_elements^t^N5^T^SEnabled^B^SName^SElemental~`Blast^SRelease^N201504.171^SScript^Sbuff.maelstrom_weapon.react>=4|buff.ancestral_swiftness.up^SAbility^Selemental_blast^t^N6^T^SEnabled^B^SRelease^N201504.171^SName^SWindstrike^SAbility^Swindstrike^t^N7^T^SEnabled^B^SName^SLightning~`Bolt^SRelease^N201504.171^SScript^Sbuff.maelstrom_weapon.react=5^SAbility^Slightning_bolt^t^N8^T^SEnabled^B^SRelease^N201504.171^SName^SStormstrike^SAbility^Sstormstrike^t^N9^T^SEnabled^B^SRelease^N201504.171^SName^SLava~`Lash^SAbility^Slava_lash^t^N10^T^SEnabled^B^SName^SFlame~`Shock^SRelease^N201504.171^SScript^S(talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9)|!ticking^SAbility^Sflame_shock^t^N11^T^SEnabled^B^SRelease^N201504.171^SName^SUnleash~`Elements~`(1)^SAbility^Sunleash_elements^t^N12^T^SEnabled^B^SName^SFrost~`Shock^SRelease^N201504.171^SScript^S(talent.elemental_fusion.enabled&dot.flame_shock.remains>=16)|!talent.elemental_fusion.enabled^SAbility^Sfrost_shock^t^N13^T^SEnabled^B^SName^SElemental~`Blast~`(1)^SRelease^N201504.171^SScript^Sbuff.maelstrom_weapon.react>=1^SAbility^Selemental_blast^t^N14^T^SEnabled^B^SName^SLightning~`Bolt~`(1)^SRelease^N201504.171^SScript^S(buff.maelstrom_weapon.react>=1&!buff.ascendance.up)|buff.ancestral_swiftness.up^SAbility^Slightning_bolt^t^N15^T^SEnabled^B^SName^SSearing~`Totem~`(1)^SRelease^N201504.171^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^SAbility^Ssearing_totem^t^t^SDefault^B^t^^" )
    
    storeDefault( "Enh: AOE", 'actionLists', 20150224.1,"^1^T^SEnabled^B^SSpecialization^N263^SRelease^N20150223.1^SName^SEnh:~`AOE^SActions^T^N1^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SScript^Stoggle.magma&totem.fire.remains>10^SAbility^Sliquid_magma^t^N2^T^SEnabled^B^SRelease^N201504.171^SName^SAncestral~`Swiftness^SAbility^Sancestral_swiftness^t^N3^T^SEnabled^B^SName^SUnleash~`Elements^SRelease^N201504.171^SScript^Sactive_enemies>=4&dot.flame_shock.ticking&(cooldown.shock.remains>cooldown.fire_nova.remains|cooldown.fire_nova.remains=0)^SAbility^Sunleash_elements^t^N4^T^SEnabled^B^SName^SFire~`Nova^SRelease^N201504.171^SScript^Sactive_dot.flame_shock>=3^SAbility^Sfire_nova^t^N5^T^SEnabled^B^SName^SWait^SArgs^Ssec=cooldown.fire_nova.remains^SRelease^N201504.171^SScript^S!talent.echo_of_the_elements.enabled&active_dot.flame_shock>=4&cooldown.fire_nova.remains<=action.fire_nova.gcd%2^SAbility^Swait^t^N6^T^SEnabled^B^SName^SMagma~`Totem^SRelease^N201504.171^SScript^S!totem.fire.active^SAbility^Smagma_totem^t^N7^T^SEnabled^B^SName^SLava~`Lash^SRelease^N201504.171^SScript^Sdot.flame_shock.ticking&active_dot.flame_shock<active_enemies^SAbility^Slava_lash^t^N8^T^SEnabled^B^SName^SElemental~`Blast^SRelease^N201504.171^SScript^S!buff.unleash_flame.up&(buff.maelstrom_weapon.react>=4|buff.ancestral_swiftness.up)^SAbility^Selemental_blast^t^N9^T^SEnabled^B^SName^SChain~`Lightning^SRelease^N201504.171^SScript^Sbuff.maelstrom_weapon.react=5&((glyph.chain_lightning.enabled&active_enemies>=3)|(!glyph.chain_lightning.enabled&active_enemies>=2))^SAbility^Schain_lightning^t^N10^T^SEnabled^B^SName^SUnleash~`Elements~`(1)^SRelease^N201504.171^SScript^Sactive_enemies<4^SAbility^Sunleash_elements^t^N11^T^SEnabled^B^SName^SFlame~`Shock^SRelease^N201504.171^SScript^Sdot.flame_shock.remains<=9|!ticking^SAbility^Sflame_shock^t^N12^T^SEnabled^B^SName^SWindstrike^SArgs^Starget.unit=1^SRelease^N201504.171^SScript^S!debuff.stormstrike.up^SAbility^Swindstrike^t^N13^T^SEnabled^B^SScript^Sdebuff.stormstrike.up&(active_dot.stormstrike+active_dot.windstrike)<active_enemies^SArgs^Starget.unit=2^SAbility^Swindstrike^SCaption^SCycle^SName^SWindstrike~`(1)^SRelease^N201504.171^t^N14^T^SEnabled^B^SRelease^N201504.171^SName^SWindstrike~`(2)^SAbility^Swindstrike^t^N15^T^SEnabled^B^SName^SElemental~`Blast~`(1)^SRelease^N201504.171^SScript^S!buff.unleash_flame.up&buff.maelstrom_weapon.react>=3^SAbility^Selemental_blast^t^N16^T^SEnabled^B^SName^SChain~`Lightning~`(1)^SRelease^N201504.171^SScript^S(buff.maelstrom_weapon.react>=3|buff.ancestral_swiftness.up)&((glyph.chain_lightning.enabled&active_enemies>=4)|(!glyph.chain_lightning.enabled&active_enemies>=3))^SAbility^Schain_lightning^t^N17^T^SEnabled^B^SName^SMagma~`Totem~`(1)^SRelease^N201504.171^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^SAbility^Smagma_totem^t^N18^T^SEnabled^B^SName^SLightning~`Bolt^SRelease^N201504.171^SScript^Sbuff.maelstrom_weapon.react=5&glyph.chain_lightning.enabled&active_enemies<3^SAbility^Slightning_bolt^t^N19^T^SEnabled^B^SName^SStormstrike^SRelease^N201504.171^SScript^S!debuff.stormstrike.up^SAbility^Sstormstrike^t^N20^T^SEnabled^B^SScript^Sdebuff.stormstrike.up&(active_dot.stormstrike+active_dot.windstrike)<active_enemies^SAbility^Sstormstrike^SCaption^SCycle^SName^SStormstrike~`(1)^SRelease^N201504.171^t^N21^T^SEnabled^B^SRelease^N201504.171^SName^SStormstrike~`(2)^SAbility^Sstormstrike^t^N22^T^SEnabled^B^SRelease^N201504.171^SName^SLava~`Lash~`(1)^SAbility^Slava_lash^t^N23^T^SEnabled^B^SName^SFire~`Nova~`(1)^SRelease^N201504.171^SScript^Sactive_dot.flame_shock>=2^SAbility^Sfire_nova^t^N24^T^SEnabled^B^SName^SElemental~`Blast~`(2)^SRelease^N201504.171^SScript^S!buff.unleash_flame.up&buff.maelstrom_weapon.react>=1^SAbility^Selemental_blast^t^N25^T^SEnabled^B^SName^SChain~`Lightning~`(2)^SRelease^N201504.171^SScript^S(buff.maelstrom_weapon.react>=1|buff.ancestral_swiftness.up)&((glyph.chain_lightning.enabled&active_enemies>=3)|(!glyph.chain_lightning.enabled&active_enemies>=2))^SAbility^Schain_lightning^t^N26^T^SEnabled^B^SName^SLightning~`Bolt~`(1)^SRelease^N201504.171^SScript^S(buff.maelstrom_weapon.react>=1|buff.ancestral_swiftness.up)&glyph.chain_lightning.enabled&active_enemies<3^SAbility^Slightning_bolt^t^N27^T^SEnabled^B^SName^SFire~`Nova~`(2)^SRelease^N201504.171^SScript^Sactive_dot.flame_shock>=1^SAbility^Sfire_nova^t^t^SDefault^B^t^^" )
    
    storeDefault( "Enh: Cooldowns", 'actionLists',  20150224.1,"^1^T^SEnabled^B^SSpecialization^N263^SRelease^N20150223.1^SName^SEnh:~`Cooldowns^SActions^T^N1^T^SEnabled^b^SName^SBloodlust^SRelease^N201504.171^SScript^Starget.health.pct<25|time>0.500^SAbility^Sbloodlust^t^N2^T^SEnabled^b^SName^SHeroism^SRelease^N201504.171^SScript^Starget.health.pct<25|time>0.500^SAbility^Sheroism^t^N3^T^SEnabled^B^SRelease^N201504.171^SName^SBlood~`Fury^SAbility^Sblood_fury^t^N4^T^SEnabled^B^SRelease^N201504.171^SName^SArcane~`Torrent^SAbility^Sarcane_torrent^t^N5^T^SEnabled^B^SRelease^N201504.171^SName^SBerserking^SAbility^Sberserking^t^N6^T^SEnabled^B^SRelease^N201504.171^SName^SElemental~`Mastery^SAbility^Selemental_mastery^t^N7^T^SEnabled^B^SRelease^N201504.171^SName^SStorm~`Elemental~`Totem^SAbility^Sstorm_elemental_totem^t^N8^T^SEnabled^B^SRelease^N201504.171^SName^SFire~`Elemental~`Totem^SAbility^Sfire_elemental_totem^t^N9^T^SEnabled^B^SRelease^N201504.171^SName^SFeral~`Spirit^SAbility^Sferal_spirit^t^N10^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SScript^Stoggle.magma&totem.fire.remains>10^SAbility^Sliquid_magma^t^N11^T^SEnabled^B^SRelease^N201504.171^SName^SAncestral~`Swiftness^SAbility^Sancestral_swiftness^t^N12^T^SEnabled^B^SRelease^N201504.171^SName^SAscendance^SAbility^Sascendance^t^t^SDefault^B^t^^" )
    
    storeDefault( "Shaman: Interrupts", 'actionLists', 2.06, "^1^T^SEnabled^B^SScript^S^SSpecialization^N0^SActions^T^N1^T^SEnabled^B^SName^SWind~`Shear^SAbility^Swind_shear^SCaption^SShear^SScript^Starget.casting^t^t^SName^S@Shaman,~`Interrupt^t^^" )
    
    storeDefault( "Shaman: Buffs", 'actionLists', 2.05, "^1^T^SEnabled^B^SActions^T^N1^T^SEnabled^B^SAbility^Slightning_shield^SScript^S!buff.lightning_shield.up^SName^SLightning~`Shield^t^t^SName^S@Shaman,~`Buffs^SSpecialization^N0^t^^" )
    
    storeDefault( "Ele: Single Target", "actionLists", 20150223.1, "^1^T^SEnabled^B^SSpecialization^N262^SDefault^B^SRelease^N20150119.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SAncestral~`Swiftness^SRelease^N201504.171^SAbility^Sancestral_swiftness^SScript^S!buff.ascendance.up^t^N2^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SAbility^Sliquid_magma^SScript^Stoggle.magma&totem.fire.remains>=15^t^N3^T^SEnabled^B^SName^SUnleash~`Flame^SArgs^S^SRelease^N201504.171^SAbility^Sunleash_flame^SScript^Smoving^t^N4^T^SEnabled^B^SName^SSpiritwalker's~`Grace^SArgs^S^SRelease^N201504.171^SAbility^Sspiritwalkers_grace^SScript^Smoving&(buff.ascendance.up)^t^N5^T^SEnabled^B^SName^SEarth~`Shock^SRelease^N201504.171^SAbility^Searth_shock^SScript^Sbuff.lightning_shield.react=buff.lightning_shield.max_stack^t^N6^T^SEnabled^B^SName^SLava~`Burst^SRelease^N201504.171^SAbility^Slava_burst^SScript^Sdot.flame_shock.remains>cast_time&(buff.ascendance.up|cooldown_react)^t^N7^T^SEnabled^B^SName^SUnleash~`Flame~`(1)^SRelease^N201504.171^SAbility^Sunleash_flame^SScript^Stalent.unleashed_fury.enabled&!buff.ascendance.up^t^N8^T^SEnabled^B^SName^SFlame~`Shock^SRelease^N201504.171^SAbility^Sflame_shock^SScript^Sdot.flame_shock.remains<=9^t^N9^T^SEnabled^B^SName^SEarth~`Shock~`(1)^SRelease^N201504.171^SAbility^Searth_shock^SScript^S(set_bonus.tier17_4pc&buff.lightning_shield.react>=12&!buff.lava_surge.up)|(!set_bonus.tier17_4pc&buff.lightning_shield.react>15)^t^N10^T^SEnabled^B^SName^SEarthquake^SRelease^N201504.171^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.875+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^t^N11^T^SEnabled^B^SName^SEarthquake~`(1)^SRelease^N201504.171^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*(1.875+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^t^N12^T^SEnabled^B^SName^SEarthquake~`(2)^SRelease^N201504.171^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.875+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^t^N13^T^SEnabled^B^SName^SEarthquake~`(3)^SRelease^N201504.171^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.875)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^t^N14^T^SEnabled^B^SName^SEarthquake~`(4)^SRelease^N201504.171^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*((1.3*1.875)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^t^N15^T^SEnabled^B^SName^SEarthquake~`(5)^SRelease^N201504.171^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.875)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^t^N16^T^SRelease^N201504.171^SAbility^Selemental_blast^SName^SElemental~`Blast^SEnabled^B^t^N17^T^SEnabled^B^SName^SFlame~`Shock~`(1)^SRelease^N201504.171^SAbility^Sflame_shock^SScript^Sremains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<duration^t^N18^T^SEnabled^B^SName^SSearing~`Totem^SRelease^N201504.171^SAbility^Ssearing_totem^SScript^S(!talent.liquid_magma.enabled&!totem.fire.active)|(talent.liquid_magma.enabled&totem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up)^t^N19^T^SEnabled^B^SName^SSpiritwalker's~`Grace~`(1)^SArgs^S^SRelease^N201504.171^SAbility^Sspiritwalkers_grace^SScript^Smoving&(((talent.elemental_blast.enabled&cooldown.elemental_blast.remains=0)|(cooldown.lava_burst.remains=0&!buff.lava_surge.up)))^t^N20^T^SRelease^N201504.171^SAbility^Slightning_bolt^SName^SLightning~`Bolt^SEnabled^B^t^t^SName^SEle:~`Single~`Target^t^^" )
    
    storeDefault( "Ele: AOE", "actionLists", 20150223.1, "^1^T^SEnabled^B^SDefault^B^SName^SEle:~`AOE^SRelease^N20150111.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SAncestral~`Swiftness^SRelease^N201504.171^SAbility^Sancestral_swiftness^SScript^S!buff.ascendance.up^t^N2^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SAbility^Sliquid_magma^SScript^Stoggle.magma&totem.fire.remains>=15^t^N3^T^SEnabled^B^SName^SEarthquake^SRelease^N201504.171^SAbility^Searthquake^SScript^S!ticking&(buff.enhanced_chain_lightning.up|level<=90)&active_enemies>=2^t^N4^T^SEnabled^B^SScript^Sactive_dot.earthquake<active_enemies&(buff.enhanced_chain_lightning.up|level<=90)&active_enemies>=2^SAbility^Searthquake^SRelease^N201504.171^SName^SEarthquake~`(1)^SCaption^SCycle^t^N5^T^SRelease^N201504.171^SAbility^Slava_beam^SName^SLava~`Beam^SEnabled^B^t^N6^T^SEnabled^B^SName^SEarth~`Shock^SRelease^N201504.171^SAbility^Searth_shock^SScript^Sbuff.lightning_shield.react=buff.lightning_shield.max_stack^t^N7^T^SEnabled^B^SName^SThunderstorm^SRelease^N201504.171^SAbility^Sthunderstorm^SScript^Sactive_enemies>=10^t^N8^T^SEnabled^B^SName^SSearing~`Totem^SRelease^N201504.171^SAbility^Ssearing_totem^SScript^S(!talent.liquid_magma.enabled&!totem.fire.active)|(talent.liquid_magma.enabled&pet.searing_totem.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up)^t^N9^T^SEnabled^B^SName^SChain~`Lightning^SRelease^N201504.171^SAbility^Schain_lightning^SScript^Sactive_enemies>=2^t^N10^T^SRelease^N201504.171^SAbility^Slightning_bolt^SName^SLightning~`Bolt^SEnabled^B^t^t^SSpecialization^N262^t^^" )
    
    storeDefault( "Ele: Cooldowns", "actionLists", 20150223.1, "^1^T^SEnabled^B^SDefault^B^SName^SEle:~`Cooldowns^SRelease^N2.2^SAbility^Sbloodlust^SSpecialization^N262^SActions^T^N1^T^SEnabled^b^SName^SBloodlust^SRelease^N201504.171^SAbility^Sbloodlust^SScript^Starget.health.pct<25|time>0.500^t^N2^T^SEnabled^b^SName^SHeroism^SRelease^N201504.171^SAbility^Sheroism^SScript^Starget.health.pct<25|time>0.500^t^N3^T^SEnabled^B^SName^SBerserking^SRelease^N201504.171^SAbility^Sberserking^SScript^S!buff.bloodlust.up&!buff.elemental_mastery.up&(set_bonus.tier15_4pc_caster|(buff.ascendance.cooldown.up=0&(dot.flame_shock.remains>buff.ascendance.duration|level<87)))^t^N4^T^SEnabled^B^SName^SBlood~`Fury^SRelease^N201504.171^SAbility^Sblood_fury^SScript^Sbuff.bloodlust.up|buff.ascendance.up|((cooldown.ascendance.remains>10|level<87)&cooldown.fire_elemental_totem.remains>10)^t^N5^T^SRelease^N201504.171^SAbility^Sarcane_torrent^SName^SArcane~`Torrent^SEnabled^B^t^N6^T^SEnabled^B^SName^SElemental~`Mastery^SRelease^N201504.171^SAbility^Selemental_mastery^SScript^Saction.lava_burst.cast_time>=1.2^t^N7^T^SEnabled^B^SName^SAncestral~`Swiftness^SRelease^N201504.171^SAbility^Sancestral_swiftness^SScript^S!buff.ascendance.up^t^N8^T^SRelease^N201504.171^SAbility^Sstorm_elemental_totem^SName^SStorm~`Elemental~`Totem^SEnabled^B^t^N9^T^SEnabled^B^SName^SFire~`Elemental~`Totem^SRelease^N201504.171^SAbility^Sfire_elemental_totem^SScript^S^t^N10^T^SEnabled^B^SName^SAscendance^SRelease^N201504.171^SAbility^Sascendance^SScript^Sactive_enemies>1|(dot.flame_shock.remains>buff.ascendance.duration&cooldown.lava_burst.remains>0)^t^N11^T^SEnabled^B^SName^SLiquid~`Magma^SRelease^N201504.171^SAbility^Sliquid_magma^SScript^Stoggle.magma&totem.fire.remains>=15^t^t^SScript^S^t^^" )
    
    
    
    

    storeDefault( "Enh: Primary", 'displays', 20150223.1, "^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^SMaelstrom~`Weapon^Srel^SCENTER^SSpacing^N4^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SQueues^T^N1^T^SEnabled^B^SAction~`List^SShaman:~`Buffs^SScript^S^SCleave^B^SSingle^B^SAOE^B^SName^SBuffs^t^N2^T^SEnabled^B^SAction~`List^SShaman:~`Interrupts^SScript^Stoggle.interrupts^SCleave^B^SSingle^B^SAOE^B^SName^SInterrupt^t^N3^T^SEnabled^B^SAction~`List^SEnh:~`Cooldowns^SScript^Stoggle.cooldowns^SCleave^B^SSingle^B^SAOE^B^SName^SCooldowns^t^N4^T^SEnabled^B^SAction~`List^SEnh:~`Single~`Target^SName^SSingle~`Target^SSingle^B^SScript^Ssingle|(cleave&active_enemies=1)^t^N5^T^SEnabled^B^SAction~`List^SEnh:~`AOE^SScript^Saoe|(cleave&active_enemies>1)^SAOE^B^SName^SAOE^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^F-4823191901962242^f-44^SIcons~`Shown^N4^SPrimary~`Caption^Sbuff^SForce~`Targets^N1^SPvE~`-~`Combat~`Alpha^N0.67^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N263^SQueue~`Direction^SRIGHT^SSpecialization~`Group^Sboth^SQueued~`Icon~`Size^N40^SEnabled^B^SPvE~`-~`Target^b^SAction~`Captions^B^SPvE~`Visibility^Salways^Sx^N0^SRelease^N2.2^SName^SEnh:~`Primary^SPvE~`-~`Target~`Alpha^N1^SFont^SElvUI~`Font^SDefault^B^SPrimary~`Icon~`Size^N40^SPrimary~`Font~`Size^N12^SScript^S^SPvE~`-~`Default~`Alpha^N1^STalent~`Group^N0^t^^" )
    
    storeDefault( "Enh: AOE", 'displays', 20150223.1, "^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^SFlame~`Shock^Srel^SCENTER^SSpacing^N4^SPvE~`-~`Default^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^SEnh:~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^SEnh:~`AOE^SName^SAOE^SScript^S^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^F-8092406117302270^f-45^STalent~`Group^N0^SPrimary~`Caption^Sratio^SForce~`Targets^N2^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SCopy~`To^Sxxx^SQueue~`Direction^SRIGHT^SSpecialization~`Group^Sboth^SQueued~`Icon~`Size^N40^SEnabled^B^Sx^N0^SPvE~`-~`Default~`Alpha^N1^SRelease^N2.2^SPvE~`Visibility^Salways^SPvE~`-~`Target^b^SDefault^B^SPvE~`-~`Target~`Alpha^N1^SPrimary~`Icon~`Size^N40^SFont^SElvUI~`Font^SName^SEnh:~`AOE^SPrimary~`Font~`Size^N12^SSpecialization^N263^SScript^S^SAction~`Captions^B^SIcons~`Shown^N4^t^^" )
    
    storeDefault( "Ele: Primary", 'displays', 20150223.1, 	"^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SLightning~`Shield^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SShaman:~`Buffs^SName^SBuffs^SScript^S^t^N2^T^SEnabled^B^SAction~`List^SShaman:~`Interrupts^SName^SInterrupt^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^SEle:~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N4^T^SEnabled^B^SAction~`List^SEle:~`Single~`Target^SName^SSingle~`Target^SScript^Ssingle|(cleave&active_enemies=1)^t^N5^T^SEnabled^B^SAction~`List^SEle:~`AOE^SName^SAOE^SScript^Saoe|(cleave&active_enemies>=3)^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-275^STalent~`Group^N0^SPrimary~`Caption^Sbuff^SForce~`Targets^N1^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SCopy~`To^Sxxx^SQueue~`Direction^SRIGHT^SQueued~`Icon~`Size^N40^SEnabled^B^SIcons~`Shown^N4^SAction~`Captions^B^SRelease^N20150111.1^Sx^N0^SPvP~`-~`Target^b^SName^SEle:~`Primary^SPvE~`-~`Target~`Alpha^N1^SFont^SElvUI~`Font^SDefault^B^SPrimary~`Icon~`Size^N40^SSpecialization^N262^SSpacing^N4^SPvE~`-~`Default~`Alpha^N1^SScript^S^t^^" )
    
    storeDefault( "Ele: AOE", 'displays', 20150223.1, "^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SEle:~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^SEle:~`AOE^SName^SAOE^SScript^S^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-230^STalent~`Group^N0^SPrimary~`Caption^Stargets^SForce~`Targets^N3^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N262^SQueue~`Direction^SRIGHT^SQueued~`Icon~`Size^N40^SEnabled^B^SCopy~`To^SEle:~`AOE2^SAction~`Captions^B^SRelease^N2.2^Sx^N0^SIcons~`Shown^N4^SName^SEle:~`AOE^SPvE~`-~`Target~`Alpha^N1^SFont^SElvUI~`Font^SDefault^B^SPrimary~`Icon~`Size^N40^SPrimary~`Font~`Size^N12^SSpacing^N4^SPvE~`-~`Default~`Alpha^N1^SScript^S^t^^" )
    
  end
  
end