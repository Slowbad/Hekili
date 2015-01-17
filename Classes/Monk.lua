-- Monk.lua
-- August 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook
local callHook = ns.callHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addGlyph = ns.addGlyph
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance
local addGearSet = ns.addGearSet

local removeResource = ns.removeResource

local setClass = ns.setClass
local setGCD = ns.setGCD

local storeDefault = ns.storeDefault


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'MONK') then

  ns.initializeClassModule = function ()

    setClass( 'MONK' )
    
    addTalent( 'ascension', 115396 )
    addTalent( 'breath_of_the_serpent', 157535 )
    addTalent( 'celerity', 115173 )
    addTalent( 'charging_ox_wave', 119392 )
    addTalent( 'chi_brew', 115399 )
    addTalent( 'chi_burst', 123986 )
    addTalent( 'chi_explosion', 152174 ) -- WW
    -- addTalent( 'chi_explosion', 157676 ) -- BM
    -- addTalent( 'chi_explosion', 157675 ) -- MW
    addTalent( 'chi_torpedo', 115008 )
    addTalent( 'chi_wave', 115098 )
    addTalent( 'dampen_harm', 122278 )
    addTalent( 'diffuse_magic', 122783 )
    addTalent( 'healing_elixirs', 122280 )
    addTalent( 'hurricane_strike', 152175 )
    addTalent( 'invoke_xuen', 123904 )
    addTalent( 'leg_sweep', 119381 )
    addTalent( 'momentum', 115174 )
    addTalent( 'pool_of_mists', 173841 )
    addTalent( 'power_strikes', 121817 )
    addTalent( 'ring_of_peace', 116844 )
    addTalent( 'rushing_jade_wind', 116847 )
    addTalent( 'serenity', 152173 )
    addTalent( 'soul_dance', 157533 )
    addTalent( 'tigers_lust', 116841 )
    addTalent( 'zen_sphere', 124081 )

    -- Glyphs.
    addGlyph( 'breath_of_fire', 123394 )
    addGlyph( 'crackling_tiger_lightning', 125931 )
    addGlyph( 'detox', 146954 )
    addGlyph( 'detoxing', 171926 )
    addGlyph( 'expel_harm', 159487 )
    addGlyph( 'fighting_pose', 125872 )
    addGlyph( 'fists_of_fury', 125671 )
    addGlyph( 'flying_fists', 173182 )
    addGlyph( 'flying_serpent_kick', 123403 )
    addGlyph( 'fortifying_brew', 124997 )
    addGlyph( 'fortuitous_spheres', 146953 )
    addGlyph( 'freedom_roll', 159534 )
    addGlyph( 'guard', 123401 )
    addGlyph( 'honor', 125732 )
    addGlyph( 'jab', 125660 )
    addGlyph( 'keg_smash', 159495 )
    addGlyph( 'leer_of_the_ox', 125967 )
    addGlyph( 'life_cocoon', 124989 )
    addGlyph( 'mana_tea', 123763 )
    addGlyph( 'nimble_brew', 146952 )
    addGlyph( 'paralysis', 125755 )
    addGlyph( 'rapid_rolling', 146951 )
    addGlyph( 'renewed_tea', 159496 )
    addGlyph( 'renewing_mist', 123334 )
    addGlyph( 'rising_tiger_kick', 125151 )
    addGlyph( 'soothing_mist', 159536 )
    addGlyph( 'spirit_roll',  125154 )
    addGlyph( 'surging_mist', 120483 )
    addGlyph( 'targeted_expulsion', 146950 )
    addGlyph( 'floating_butterfly', 159490 )
    addGlyph( 'flying_serpent', 159492 )
    addGlyph( 'touch_of_death', 123391 )
    addGlyph( 'touch_of_karma', 125678 )
    addGlyph( 'transcendence', 123023 )
    addGlyph( 'victory_roll',  159497 )
    addGlyph( 'water_roll', 125901 )
    addGlyph( 'zen_flight', 125893 )
    addGlyph( 'zen_focus', 159545 )
    addGlyph( 'zen_meditation', 120477 )
    
    -- Player Buffs.
    addAura( 'cranes_zeal', 127722, 'duration', 20 )
    addAura( 'fortifying_brew', 115203 )
    addAura( 'shuffle', 115307 )
    addAura( 'breath_of_fire', 123725 )
    addAura( 'chi_explosion', 157680 )
    addAura( 'combo_breaker_bok', 116768 )
    addAura( 'combo_breaker_ce', 159407 )
    addAura( 'combo_breaker_tp', 118864 )
    addAura( 'dampen_harm', 122278 )
    addAura( 'death_note', 121125 )
    addAura( 'diffuse_magic', 122783 )
    addAura( 'elusive_brew_activated', 115308, 'fullscan', true )
    addAura( 'elusive_brew_stacks', 128939, 'max_stacks', 15, 'fullscan', true )
    addAura( 'energizing_brew', 115288 )
    addAura( 'guard', 115295 )
    addAura( 'heavy_stagger', 124273, 'unit', 'player' )
    addAura( 'keg_smash', 121253 )
    addAura( 'legacy_of_the_emperor', 115921, 'duration', 3600 )
    addAura( 'legacy_of_the_white_tiger', 116781, 'duration', 3600 )
    addAura( 'light_stagger', 124275, 'unit', 'player' )
    addAura( 'mana_tea_stacks', 115867, 'duration', 120, 'max_stacks', 15 )
    addAura( 'mana_tea_activated', 115294 )
    addAura( 'power_strikes', 129914 )
    addAura( 'moderate_stagger', 124274, 'duration', 10, 'unit', 'player' )
    addAura( 'rising_sun_kick', 130320 )
    addAura( 'rushing_jade_wind', 116847 )
    addAura( 'serenity', 152173 )
    addAura( 'spinning_crane_kick', 101546 )
    addAura( 'stagger', 124255 )
    addAura( 'tiger_palm', 100787 )
    addAura( 'tiger_power', 125359 )
    addAura( 'tigereye_brew', 125195, 'fullscan', true )
    addAura( 'tigereye_brew_use', 116740, 'fullscan', true )
    addAura( 'vital_mists', 118674, 'duration', 30, 'max_stacks', 5 )
    addAura( 'zen_sphere', 124081 )
    addAura( 'dizzying_haze', 116330 )
    
    -- Perks.
    addPerk( 'empowered_chi', 157411 )
    addPerk( 'empowered_spinning_crane_kick', 157415 )
    addPerk( 'enhanced_roll', 157361 )
    addPerk( 'enhanced_transcendence', 157366 )
    addPerk( 'improved_breath_of_fire', 157362 )
    addPerk( 'improved_guard', 157363 )
    addPerk( 'improved_life_cocoon', 157401 )
    addPerk( 'improved_renewing_mist', 157398 )
    
    -- Stances.
    -- Need to confirm the right IDs based on spec.
    addStance( 'fierce_tiger', 'windwalker', 1 )
    addStance( 'sturdy_ox', 'brewmaster', 1 )
    addStance( 'wise_serpent', 'mistweaver', 1 )
    addStance( 'spirited_crane', 'mistweaver', 2 )
    
    -- Gear Sets
    addGearSet( 'tier17', 115555, 115556, 115557, 115558, 115559 )

    
    -- State Modifications
    state.stagger = setmetatable( {}, {
      __index = function(t, k)
        if k == 'heavy' then return state.debuff.heavy_stagger.up
        elseif k == 'moderate' then return state.debuff.moderate_stagger.up or state.debuff.heavy_stagger.up
        elseif k == 'light' then return state.debuff.light_stagger.up or state.debuff.moderate_stagger.up or state.debuff.heavy_stagger.up
        elseif k == 'amount' then
          if state.debuff.heavy_stagger.up then return state.debuff.heavy_stagger.v2
          elseif state.debuff.moderate_stagger.up then return state.debuff.moderate_stagger.v2
          elseif state.debuff.light_stagger.up then return state.debuff.light_stagger.v2
          else return 0 end
        elseif k == 'tick' then
          if state.debuff.heavy_stagger.up then return state.debuff.heavy_stagger.v1
          elseif state.debuff.moderate_stagger.up then return state.debuff.moderate_stagger.v1
          elseif state.debuff.light_stagger.up then return state.debuff.light_stagger.v1
          else return 0 end
        end
        
        Hekili:Error( "stagger." .. k .. ": unknown key." )
      end
    } )


    addHook( 'specializationChanged', function ()

      addResource( 'chi' )
      removeResource( 'energy' )
      removeResource( 'mana' )
      
      if state.spec.mistweaver then
        state.gcd = nil
        addResource( 'mana', true )
      else
        state.gcd = 1.0
        addResource( 'energy', true )
      end
    end )
    
    -- callHook( 'specializationChanged' )
    
    addHook( 'onInitialize', function ()

      local found, empty = false, nil
      
      for i = 1, 5 do
        if not empty and Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == nil then
          empty = i
        elseif Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == 'mitigation' then
          found = i
          break
        end
      end
      
      if not found and empty then
        Hekili.DB.profile[ 'Toggle ' ..empty.. ' Name' ] = 'mitigation'
        found = empty
      end
      
      if type( found ) == 'number' then
        Hekili.DB.profile[ 'Toggle_' .. found ] = Hekili.DB.profile[ 'Toggle_' .. found ] == nil and true or Hekili.DB.profile[ 'Toggle_' .. found ]
      end
    end )
    
    
    addHook( 'reset', function ( delay )
      if state.buff.spinning_crane_kick.up then
        return max( delay, state.buff.spinning_crane_kick.remains )
      end
      
      return delay
    end )

    
    -- Abilities
    addAbility( 'blackout_kick',
      {
        id = 100784,
        known = function () return not talent.chi_explosion.enabled end,
        spend = function ()
          if buff.combo_breaker_bok.up then return 0, 'chi' end
          return 2, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0,
        usable = function()
          if stance.wise_serpent then return false end
          return true
        end,
      } )
    
    addHandler( 'blackout_kick', function ()
      if spec.brewmaster then applyBuff( 'shuffle', 6 )
      elseif spec.mistweaver then
        addStack( 'vital_mists', 30, 2 )
        applyBuff( 'cranes_zeal', 20 )
      end
      if buff.serenity.up and not buff.combo_breaker_bok.up then gain( 2, 'chi' ) end
      removeBuff( 'combo_breaker_bok' )
    end )
    
    
    addAbility( 'crackling_jade_lightning',
      {
        id = 117952,
        spend = function()
          if stance.spirited_crane then return 0.213, 'mana' end
          return 0, 'energy'
        end,
        cast = 4, -- need a 'channel' version.
        gcdType = 'spell',
        cooldown = 0,
        usable = function() return not stance.wise_serpent end
      } )
    
    addHandler( 'crackling_jade_lightning', function ()
      if spec.mistweaver then gain( 1, 'chi' ) end -- need to fix up for channeling.
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
    end )
    
    
    addAbility( 'expel_harm',
      {
        id = 115072,
        spend = function()
          if spec.mistweaver then
            return 0.02, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 15,
        usable = function() return health.current < health.max and not stance.wise_serpent end
      } )
    
    modifyAbility( 'expel_harm', 'cooldown', function( x )
      if stance.sturdy_ox and health.pct < 35 then return 0 end
      return x
    end )
    
    addHandler( 'expel_harm', function ()
      gain( 1, 'chi' )
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
    end )


    addAbility( 'fortifying_brew',
      {
        id = 115203,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 180
      } )
    
    addHandler( 'fortifying_brew', function ()
      local health_gain = health.max * 0.2
      applyBuff( 'fortifying_brew', 15 )
      health.current = health.current + health_gain
      health.max = health.max + health_gain
    end )
    
    
    addAbility( 'jab',
      {
        id = 100780,
        spend = function()
          if stance.spirited_crane then return 0.035, 'mana'
          elseif stance.fierce_tiger then return 45, 'energy' end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )
    
    addHandler( 'jab', function ()
      gain( spec.windwalker and 2 or 1, 'chi' )
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
    end )
    
    
    addAbility( 'spear_hand_strike',
      {
        id = 116705,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 15
      } )
    
    addHandler( 'spear_hand_strike', function ()
      interrupt()
    end )
    
    
    addAbility( 'spinning_crane_kick',
      {
        id = 101546,
        spend = function()
          if stance.spirited_crane then
            return 0.08, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )
    
    addHandler( 'spinning_crane_kick', function ()
      applyBuff( 'spinning_crane_kick', ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
      setCooldown( class.gcd, ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
      if min_targets >= 3 or my_enemies >= 3 then
        gain( 1, 'chi' )
        if buff.power_strikes.up then
          gain( 1, 'chi' )
          removeBuff( 'power_strikes' )
        end
      end
    end )
    
    
    addAbility( 'fierce_tiger',
      {
        id = 103985,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )
    
    addHandler( 'fierce_tiger', function ()
      setStance( 'fierce_tiger' )
    end )
    
    
    addAbility( 'surging_mist',
      {
        id = 116694,
        spend = function()
          if spec.mistweaver then return 0.047, 'mana' end
          return 30, 'energy'
        end,
        cast = 1.5,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    modifyAbility( 'surging_mist', 'cast', function ( x )
      if buff.vital_mists.up then x = ( x - ( x * ( 0.2 * buff.vital_mists.stack ) ) ) end
      return x * haste
    end )
    
    addHandler( 'surging_mist', function ()
      if spec.mistweaver then gain( 1, 'chi' ) end
      removeBuff( 'vital_mists' )
    end )
    
    
    addAbility( 'tiger_palm',
      {
        id = 100787,
        spend = function()
          if spec.brewmaster or buff.combo_breaker_tp.up then
            return 0, 'chi'
          end
          return 1, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0,
        usable = function()
          if stance.wise_serpent then
            return false
          end
          return true
        end
      } )
    
    addHandler( 'tiger_palm', function ()
      if buff.serenity.up and not buff.combo_breaker_tp.up then gain( 1, 'chi' ) end
      if spec.brewmaster then applyBuff( 'tiger_palm', 20 )
      else
        applyBuff( 'tiger_power', 20 )
        addStack( 'vital_mists', 30, 1 )
      end
      removeBuff( 'combo_breaker_tp' )
    end )
    
    
    addAbility( 'touch_of_death',
      {
        id = 115080,
        spend = 3,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'melee',
        cooldown = 90,
        usable = function() return buff.death_note.up end
      } )
    
    addHandler( 'touch_of_death', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
    end )
    
    modifyAbility( 'touch_of_death', 'spend', function ( x )
      if glyph.touch_of_death.enabled then return 0 end
      return x
    end )
    
    modifyAbility( 'touch_of_death', 'cooldown', function ( x )
      if glyph.touch_of_death.enabled then return x + 120 end
      return x
    end )
    
    
    addAbility( 'breath_of_fire',
      {
        id = 115181,
        spend = 2,
        spend_type, 'chi',
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'breath_of_fire', function ()
      if perk.improved_breath_of_fire.enabled or debuff.dizzying_haze.up or debuff.keg_smash.up then
        applyDebuff( 'target', 'breath_of_fire', 8 )
      end
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )
    
    
    addAbility( 'detonate_chi',
      {
        id = 115460,
        spend = 0.03,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        cooldown = 10
      } )
    
    
    addAbility( 'disable',
      {
        id = 116095,
        spend = function()
          if stance.fierce_tiger then
            return 15, 'energy'
          end
          return 0.007, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )
    
    addHandler( 'disable', function ()
      if debuff.disable.up then
        -- apply disable root
      else
        applyDebuff( 'target', 'disable', 8 )
      end
    end )
    
    
    addAbility( 'dizzying_haze',
      {
        id = 115180,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'dizzying_haze', function ()
      applyDebuff( 'target', 'dizzying_haze', 15 )
    end )
    
    
    addAbility( 'elusive_brew',
      {
        id = 115308,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 6
      } )
    
    addHandler( 'elusive_brew', function ()
      applyBuff( 'elusive_brew_activated', buff.elusive_brew_stacks.stack )
      removeBuff( 'elusive_brew_stacks' )
    end )
    
    
    addAbility( 'energizing_brew',
      {
        id = 115288,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 60
      } )
    
    addHandler( 'energizing_brew', function ()
      applyBuff( 'energizing_brew', 6 )
    end )
    
   
    addAbility( 'enveloping_mist',
      {
        id = 124682,
        spend = 3,
        spend_type = 'chi',
        usable = function() return stance.wise_serpent end,
        cast = 2,
        cooldown = 0
      } )
    
    addHandler( 'enveloping_mist', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
    end )
    

    addAbility( 'fists_of_fury',
      {
        id = 113656,
        spend = 3,
        spend_type = 'chi',
        cast = 4,
        gcdType = 'spell',
        cooldown = 25
      } )
      
    modifyAbility( 'fists_of_fury', 'cast', function ( x )
      return x * haste
    end )
    
    addHandler( 'fists_of_fury', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
    end )
    
    
    addAbility( 'flying_serpent_kick',
      {
        id = 101545,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 25
      } )
    
    addHandler( 'flying_serpent_kick', function ()
      if target.within8 then applyDebuff( 'target', 'flying_serpent_kick', 4 ) end
    end )
    
    
    addAbility( 'guard',
      {
        id = 115295, 
        spend = 2,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'off',
        cooldown = 30,
        charges = 1
      } )

    modifyAbility( 'guard', 'cooldown', function ( x )
      if cooldown.guard.charges > 1 then return 1 end
      return x
    end )
    
    modifyAbility( 'guard', 'charges', function ( x )
      if perk.improved_guard.enabled then return 2 end
      return x
    end )
    
    addHandler( 'guard', function ()
      applyBuff( 'guard', 30 )
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )
    
    
    addAbility( 'keg_smash',
      {
        id = 121253,
        spend = 40,
        spend_type = 'energy',
        cast = 0,
        gcdType = 'melee',
        cooldown = 8
      } )
    
    addHandler( 'keg_smash', function ()
      applyDebuff( 'target', 'keg_smash', 15 )
      gain( 2, 'chi' )
    end )
    
    
    addAbility( 'legacy_of_the_emperor',
      {
        id = 115921,
        spend = function()
          if spec.mistweaver then return 0.01, 'mana' end
          return 20, 'energy'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true
      } )
    
    addHandler( 'legacy_of_the_emperor', function ()
      applyBuff( 'legacy_of_the_emperor', 3600 )
      applyBuff( 'str_agi_int', 3600 )
    end )
    
    
    addAbility( 'legacy_of_the_white_tiger',
      {
        id = 116781,
        spend = 20,
        spend_type = 'energy',
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true
      } )
     
    addHandler( 'legacy_of_the_white_tiger', function ()
      applyBuff( 'legacy_of_the_white_tiger', 3600 )
      applyBuff( 'str_agi_int', 3600 )
      applyBuff( 'critical_strike', 3600 )
    end )
    
    
    addAbility( 'life_cocoon',
      {
        id = 116849,
        spend = 0.024,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        cooldown = 120
      } )
    
    addHandler( 'life_cocoon', function ()
      applyBuff( 'life_cocoon', 12 )
    end )
    
    modifyAbility( 'life_cocoon', 'cooldown', function ( x )
      if perk.improved_life_cocoon.enabled then return x - 20 end
      return x
    end )
    
    
    addAbility( 'mana_tea',
      {
        id = 115294,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    modifyAbility( 'mana_tea', 'cast', function ( x )
      return buff.mana_tea.stack * 0.5
    end )
    
    addHandler( 'mana_tea', function ()
      removeBuff( 'mana_tea_stacks' )
    end )
    
    
    addAbility( 'purifying_brew',
      {
        id = 119582,
        spend = 1,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'off',
        cooldown = 1,
        usable = function() return stagger.light end,
      } )
    
    addHandler( 'purifying_brew', function ()
      if buff.serenity.up then gain( 1, 'chi' ) end
      removeDebuff( 'player', 'stagger' )
      removeDebuff( 'player', 'light_stagger' )
      removeDebuff( 'player', 'moderate_stagger' )
      removeDebuff( 'player', 'heavy_stagger' )
    end )
    
    
    addAbility( 'renewing_mist',
      {
        id = 115151,
        spend = 0.04,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        cooldown = 8
      } )
    
    addHandler( 'renewing_mist', function ()
      applyBuff( 'renewing_mist', 18 )
      gain( 1, 'chi' )
    end )
    
    
    addAbility( 'revival',
      {
        id = 115310,
        spend = 0.044,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        cooldown = 180
      } )
    
    
    addAbility( 'rising_sun_kick',
      {
        id = 107428,
        spend = 2,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'melee',
        cooldown = 8,
        charges = 1
      } )
    
    modifyAbility( 'rising_sun_kick', 'charges', function ( x )
      if talent.pool_of_mists.enabled then return 3 end
      return nil
    end )
    
    addHandler( 'rising_sun_kick', function ()
      if buff.serenity.up then gain( 2, 'chi' ) end
      if spec.mistweaver then addStack( 'vital_mists', 30, 2 ) end
      applyDebuff( 'target', 'rising_sun_kick', 15 )
    end )
    
    
    addAbility( 'soothing_mist',
      {
        id = 115175,
        spend = 0,
        cast = 8,
        gcdType = 'spell',
        cooldown = 1
      } )
    
    addHandler( 'soothing_mist', function ()
      applyBuff( 'soothing_mist', 8 )
    end )
    
    
    addAbility( 'spirited_crane',
      {
        id = 154436,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'spirited_crane', function ()
      setStance( 'spirited_crane' )
    end )
    
    
    addAbility( 'sturdy_ox',
      {
        id = 115069,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'sturdy_ox', function ()
      setStance( 'sturdy_ox' )
    end )
    
    
    addAbility( 'wise_serpent',
      {
        id = 115070,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'wise_serpent', function ()
      setStance( 'wise_serpent' )
    end )
    
    
    addAbility( 'storm_earth_and_fire',
      {
        id = 137639,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 1
      } )
    
    
    addAbility( 'summon_black_ox_statue',
      {
        id = 115315,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 10
      } )
    
    addHandler( 'summon_black_ox_statue', function ()
      summonTotem( 'summon_black_ox_statue', 600 )
    end )
    
    
    addAbility( 'summon_jade_serpent_statue',
      {
        id = 115315,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 10
      } )
    
    addHandler( 'summon_jade_serpent_statue', function ()
      summonTotem( 'summon_jade_serpent_statue', 600 )
    end )
    
    
    addAbility( 'thunder_focus_tea',
      {
        id = 116680,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 45
      } )
    
    addHandler( 'thunder_focus_tea', function ()
      applyBuff( 'thunder_focus_tea', 20 )
    end )
    
    
    addAbility( 'tigereye_brew',
      {
        id = 116740,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 5
      } )
    
    addHandler( 'tigereye_brew', function ()
      applyBuff( 'tigereye_brew_use', 15 )
      removeStack( 'tigereye_brew', min( 10, buff.tigereye_brew.stack ) )
    end )
    

    addAbility( 'touch_of_karma',
      {
        id = 122470,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90
      } )
    
    addHandler( 'touch_of_karma', function ()
      applyBuff( 'touch_of_karma', 10 )
      applyDebuff( 'target', 'touch_of_karma', 10 )
    end )
    
    
    addAbility( 'uplift',
      {
        id = 116670,
        spend = 2,
        spend_type = 'chi',
        cast = 1.5,
        gcdType = 'spell',
        cooldown = 0
      } )
      
    addHandler( 'uplift', function ()
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )
    
    
    addAbility( 'zen_meditation',
      {
        id = 115176,
        spend = 0,
        cast = 8,
        gcdType = 'spell',
        cooldown = 180
      } )
      
      
    addAbility( 'breath_of_the_serpent',
      {
        id = 157535,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90
      } )
    
    
    addAbility( 'charging_ox_wave',
      {
        id = 119392,
        known = function() return talent.charging_ox_wave.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 30
      } )
    
    addHandler( 'charging_ox_wave', function ()
      applyDebuff( 'target', 'charging_ox_wave', 3 )
    end )
    
    
    addAbility( 'chi_brew',
      {
        id = 115399,
        known = function() return talent.chi_brew.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 60,
        charges = 2,
        recharge = 60
      } )
      
    modifyAbility( 'chi_brew', 'cooldown', function ( x )
      if cooldown.chi_brew.charges > 1 then return 0 end
      return x
    end )
      
      
    addHandler( 'chi_brew', function ()
      gain( 2, 'chi' )
      if spec.windwalker then
        addStack( 'tigereye_brew', 120, 2 )
      elseif spec.brewmaster then
        addStack( 'elusive_brew_stacks', 30, 5 )
      elseif spec.mistweaver then
        addStack( 'mana_tea_stacks', 120, 1 )
      end
    end )
    
    
    addAbility( 'chi_burst',
      {
        id = 123986,
        known = function() return talent.chi_burst.enabled end,
        spend = 0,
        cast = 1,
        gcdType = 'spell',
        cooldown = 30
      } )
    
    
    addAbility( 'chi_explosion',
      {
        id = 157676,
        known = function() return talent.chi_explosion.enabled end,
        spend = function()
          if buff.combo_breaker_ce.up then return 0, 'chi' end
          return 1, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      }, 157675, 152174 )
    
    addHandler( 'chi_explosion', function ()
      local faux_chi = buff.combo_breaker_ce.up and chi.current or chi.current + 1
      if spec.brewmaster then
        if faux_chi >= 2 then applyBuff( 'shuffle', 2 + 2 * min(4, chi.current ) ) end
        if faux_chi >= 3 then
          removeDebuff( 'player', 'stagger' )
          removeDebuff( 'player', 'light_stagger' )
          removeDebuff( 'player', 'moderate_stagger' )
          removeDebuff( 'player', 'heavy_stagger' )
        end
      elseif spec.windwalker then
        if faux_chi >= 2 then applyDebuff( 'target', 'chi_explosion', 6 ) end
        if faux_chi >= 3 then addStack( 'tigereye_brew', 120, 1 ) end
      elseif spec.mistweaver then
        if faux_chi >= 1 then applyBuff( 'chi_explosion', 6 ) end
        if faux_chi >= 2 then applyBuff( 'cranes_zeal', 20 ) end
        addStack( 'vital_mists', 30, faux_chi )
      end
      -- If we had more than one chi going into this, spend up to 3 more.
      if chi.current > 0 and not buff.combo_breaker_ce.up then
        spend( min( 3, chi.current ), 'chi' )
      end
      removeBuff( 'combo_breaker_ce' )
    end )
    
    
    addAbility( 'chi_torpedo',
      {
        id = 115008,
        known = function() return talent.chi_torpedo.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 20,
        charges = 2
      } )
    
    
    addAbility( 'chi_wave',
      {
        id = 115098,
        known = function() return talent.chi_wave.enabled end,
        -- spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 15
      } )
    
    
    addAbility( 'dampen_harm',
      {
        id = 122278,
        known = function() return talent.dampen_harm.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90
      } )
    
    addHandler( 'dampen_harm', function ()
      applyBuff( 'dampen_harm', 15 )
    end )
    
    
    addAbility( 'diffuse_magic',
      {
        id = 122783,
        known = function() return talent.diffuse_magic.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90
      } )
    
    addHandler( 'diffuse_magic', function ()
      applyBuff( 'diffuse_magic', 6 )
    end )
    
    
    addAbility( 'hurricane_strike',
      {
        id = 152175,
        spend = 3,
        spend_type = 'chi',
        cast = 2,
        gcdType = 'melee',
        cooldown = 45
      } )
    
     
     addAbility( 'invoke_xuen',
      {
        id = 123904,
        known = function() return talent.invoke_xuen.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 180
      } )
    
    addHandler( 'invoke_xuen', function ()
      summonPet( 'invoke_xuen', 45 )
    end )
    
    
    addAbility( 'leg_sweep',
      {
        id = 119381,
        known = function() return talent.leg_sweep.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 45
      } )
    
    addHandler( 'leg_sweep', function ()
      applyDebuff( 'target', 'leg_sweep', 5 )
    end )
    
    
    addAbility( 'ring_of_peace',
      {
        id = 116844,
        known = function() return talent.ring_of_peace.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 45
      } )
    
    addHandler( 'ring_of_peace', function ()
      applyBuff( 'ring_of_peace', 8 )
    end )
    
    
    addAbility( 'rushing_jade_wind',
      {
        id = 116847,
        known = function() return talent.rushing_jade_wind.enabled end,
        spend = function()
          if stance.spirited_crane or stance.wise_serpent then
            return 0.125, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 6
      } )
    
    addHandler( 'rushing_jade_wind', function ()
      if min_targets >= 3 or my_enemies >= 3 then
        gain( 1, 'chi' )
        if buff.power_strikes.up then
          gain( 1, 'chi' )
          removeBuff( 'power_strikes' )
        end
      end
      applyBuff( 'rushing_jade_wind', 6 )
    end )
    
    modifyAbility( 'rushing_jade_wind', 'cooldown', function ( x )
      return x * haste
    end )
    
    
    addAbility( 'serenity',
      {
        id = 152173,
        known = function() return talent.serenity.enabled end,
        spend = 0,
        cast = 0,
        cooldown = 90,
        gcdType = 'spell'
      } )
    
    addHandler( 'serenity', function ()
      applyBuff( 'serenity', 10 )
    end )
    
    
    addAbility( 'tigers_lust',
      {
        id = 116841,
        spend = 0,
        cast = 0,
        cooldown = 30,
        gcdType = 'spell'
      } )
      
    addHandler( 'tigers_lust', function ()
      applyBuff( 'tigers_lust', 6 )
    end )
    
    
    addAbility( 'zen_sphere',
      {
        id = 124081,
        known = function() return talent.zen_sphere.enabled end,
        spend = 0,
        cast = 0,
        cooldown = 10,
        gcdType = 'spell'
      } )
    
    addHandler( 'zen_sphere', function ()
      applyBuff( 'zen_sphere', 16 )
    end )

    
    addAbility( 'energizing_brew',
      {
        id = 115288,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 60
      } )
    
    addHandler( 'energizing_brew', function ()
      applyBuff( 'energizing_brew', 6 )
    end )

    -- Pick an instant cast ability for checking the GCD.
    setGCD( 'legacy_of_the_emperor' )
    
    storeDefault( "WW: Single Target", "actionLists", 20150116.1, "^1^T^SEnabled^B^SDefault^B^SName^SWW:~`Single~`Target^SRelease^N20150116.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2)&buff.tigereye_brew.stack<=16^SAbility^Schi_brew^t^N2^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.25^SScript^Sbuff.tiger_power.remains<=3^SAbility^Stiger_palm^t^N3^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.25^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^SAbility^Stigereye_brew^t^N4^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.25^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^SAbility^Srising_sun_kick^t^N5^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.25^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^SAbility^Stiger_palm^t^N6^T^SEnabled^B^SName^SFists~`of~`Fury^SRelease^N2.25^SScript^Sbuff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&!buff.serenity.up^SAbility^Sfists_of_fury^t^N7^T^SEnabled^B^SName^SFortifying~`Brew^SRelease^N2.25^SScript^Saction.touch_of_death.ready^SAbility^Sfortifying_brew^t^N8^T^SEnabled^B^SName^STouch~`of~`Death^SRelease^N2.25^SScript^S^SAbility^Stouch_of_death^t^N9^T^SEnabled^B^SName^SHurricane~`Strike^SRelease^N2.25^SScript^Stalent.hurricane_strike.enabled&energy.time_to_max>cast_time&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.energizing_brew.down^SAbility^Shurricane_strike^t^N10^T^SEnabled^B^SName^SEnergizing~`Brew^SRelease^N2.25^SScript^Scooldown.fists_of_fury.remains>6&(!talent.serenity.enabled|!toggle.cooldowns|(!buff.serenity.up&cooldown.serenity.remains>4))&energy.current+energy.regen*gcd<50^SAbility^Senergizing_brew^t^N11^T^SEnabled^B^SName^SRising~`Sun~`Kick~`(1)^SRelease^N2.25^SScript^S!talent.chi_explosion.enabled^SAbility^Srising_sun_kick^t^N12^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.25^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^t^N13^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.25^SScript^Stalent.chi_burst.enabled&energy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^t^N14^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.25^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking&buff.serenity.down^SAbility^Szen_sphere^t^N15^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.25^SScript^S!talent.chi_explosion.enabled&(buff.combo_breaker_bok.up|buff.serenity.up)^SAbility^Sblackout_kick^t^N16^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.25^SScript^Stalent.chi_explosion.enabled&chi.current>=3&buff.combo_breaker_ce.up&cooldown.fists_of_fury.remains>3^SAbility^Schi_explosion^t^N17^T^SEnabled^B^SName^STiger~`Palm~`(2)^SRelease^N2.25^SScript^S(talent.chi_explosion.enabled&chi.current>=4)|(buff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=6)^SAbility^Stiger_palm^t^N18^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.25^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^SAbility^Sblackout_kick^t^N19^T^SEnabled^B^SName^SChi~`Explosion~`(1)^SRelease^N2.25^SScript^Stalent.chi_explosion.enabled&chi.current>=3^SAbility^Schi_explosion^t^N20^T^SEnabled^B^SName^SJab^SRelease^N2.25^SScript^Schi.max-chi.current>=2^SAbility^Sjab^t^N21^T^SEnabled^B^SName^SJab~`(1)^SRelease^N2.25^SScript^Schi.max-chi.current>=1&talent.chi_explosion.enabled&cooldown.fists_of_fury.remains<=3^SAbility^Sjab^t^t^SSpecialization^N269^t^^" )
    
    storeDefault( "WW: AOE", "actionLists", 20150116.1, "^1^T^SEnabled^B^SSpecialization^N269^SName^SWW:~`AOE^SRelease^N20150116.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2)&buff.tigereye_brew.stack<=16^t^N2^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.remains<=3^t^N3^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^t^N4^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N5^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^t^N6^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=4&(cooldown.fists_of_fury.remains>3|!talent.rushing_jade_wind.enabled)^t^N7^T^SRelease^N2.06^SAbility^Srushing_jade_wind^SName^SRushing~`Jade~`Wind^SEnabled^B^t^N8^T^SEnabled^B^SScript^Scooldown.fists_of_fury.remains>6&(!talent.serenity.enabled|!toggle.cooldowns|(!buff.serenity.up&cooldown.serenity.remains>4))&(energy.current+energy.regen*gcd)<50^SRelease^N2.06^SAbility^Senergizing_brew^SName^SEnergizing~`Brew^t^N9^T^SEnabled^B^SName^SRising~`Sun~`Kick~`(1)^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S!talent.rushing_jade_wind.enabled&chi.current=chi.max^t^N10^T^SEnabled^B^SName^SFists~`of~`Fury^SRelease^N2.06^SAbility^Sfists_of_fury^SScript^Stalent.rushing_jade_wind.enabled&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&!buff.serenity.up^t^N11^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0^SAbility^Sfortifying_brew^SRelease^N2.06^SName^SFortifying~`Brew^t^N12^T^SEnabled^B^SName^STouch~`of~`Death^SRelease^N2.06^SAbility^Stouch_of_death^SScript^Starget.health.percent<10^t^N13^T^SEnabled^B^SName^SHurricane~`Strike^SRelease^N2.06^SAbility^Shurricane_strike^SScript^Stalent.rushing_jade_wind.enabled&talent.hurricane_strike.enabled&energy.time_to_max>cast_time&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.energizing_brew.down^t^N14^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.06^SAbility^Szen_sphere^SScript^S!dot.zen_sphere.ticking^t^N15^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SScript^Senergy.time_to_max>2&buff.serenity.down^t^N16^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SScript^Stalent.chi_burst.enabled&energy.time_to_max>2&buff.serenity.down^t^N17^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Stalent.rushing_jade_wind.enabled&!talent.chi_explosion.enabled&(buff.combo_breaker_bok.up|buff.serenity.up)^t^N18^T^SEnabled^B^SName^STiger~`Palm~`(2)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Stalent.rushing_jade_wind.enabled&buff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=6^t^N19^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S(talent.rushing_jade_wind.enabled|my_enemies<3)&!talent.chi_explosion.enabled&chi.max-chi.current<2&(cooldown.fists_of_fury.remains>3|!talent.rushing_jade_wind.enabled)^t^N20^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^Smy_enemies>=3&!talent.rushing_jade_wind.enabled^t^N21^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^S(talent.rushing_jade_wind.enabled|my_enemies<3)&chi.max-chi.current>=2^t^N22^T^SEnabled^B^SName^SJab~`(1)^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max&talent.chi_explosion.enabled&cooldown.fists_of_fury.remains<=3^t^t^SDefault^B^t^^" )
    
    storeDefault( "WW: Cooldowns", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SSpecialization^N269^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SInvoke~`Xuen,~`the~`White~`Tiger^SRelease^N2.25^SAbility^Sinvoke_xuen^SScript^Stalent.invoke_xuen.enabled^t^N2^T^SEnabled^B^SName^SBlood~`Fury^SRelease^N2.25^SAbility^Sblood_fury^SScript^Sbuff.tigereye_brew_use.up^t^N3^T^SEnabled^B^SName^SBerserking^SRelease^N2.25^SAbility^Sberserking^SScript^Sbuff.tigereye_brew_use.up^t^N4^T^SEnabled^B^SName^SArcane~`Torrent^SRelease^N2.25^SAbility^Sarcane_torrent^SScript^Schi.max-chi.current>=1&(buff.tigereye_brew_use.up))^t^N5^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2)&buff.tigereye_brew.stack<=16^t^N6^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.25^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.remains<=3^t^N7^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.25^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^t^N8^T^SEnabled^B^SName^STigereye~`Brew~`(1)^SRelease^N2.25^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&buff.serenity.up^t^N9^T^SEnabled^B^SName^STigereye~`Brew~`(2)^SRelease^N2.25^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&cooldown.fists_of_fury.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N10^T^SEnabled^B^SName^STigereye~`Brew~`(3)^SRelease^N2.25^SAbility^Stigereye_brew^SScript^Stalent.hurricane_strike.enabled&buff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&cooldown.hurricane_strike.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N11^T^SEnabled^B^SName^STigereye~`Brew~`(4)^SRelease^N2.25^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&chi.current>=2&(buff.tigereye_brew.stack>=16|target.time_to_die<40)&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N12^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.25^SAbility^Srising_sun_kick^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N13^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.25^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^t^N14^T^SEnabled^B^SName^SSerenity^SRelease^N2.25^SAbility^Sserenity^SScript^Stalent.serenity.enabled&chi.current>=2&buff.tiger_power.up&debuff.rising_sun_kick.up^t^t^SName^SWW:~`Cooldowns^t^^" )
    
    
    storeDefault( "BM: Single Target", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N2.2^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10&((charges=1&recharge_time<5)|charges=2)^t^N2^T^SEnabled^B^SName^SPurifying~`Brew^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.heavy^t^N3^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.down^t^N4^T^SEnabled^B^SName^SPurifying~`Brew~`(1)^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&buff.serenity.up^t^N5^T^SEnabled^B^SName^SPurifying~`Brew~`(2)^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.moderate&buff.shuffle.remains>=6^t^N6^T^SEnabled^B^SName^SGuard^SRelease^N2.25^SAbility^Sguard^SScript^Stoggle.mitigation&(charges=1&recharge_time<5)|charges=2^t^N7^T^SEnabled^B^SName^SGuard~`(1)^SRelease^N2.25^SAbility^Sguard^SScript^Stoggle.mitigation&incoming_damage_10s>=health.max*0.5^t^N8^T^SEnabled^B^SName^SKeg~`Smash^SRelease^N2.25^SAbility^Skeg_smash^SScript^Schi.max-chi.current>=1&!buff.serenity.up^t^N9^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.25^SAbility^Schi_burst^SScript^S(energy.current+(energy.regen*gcd))<100^t^N10^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.25^SAbility^Schi_wave^SScript^S(energy.current+(energy.regen*gcd))<100^t^N11^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.25^SAbility^Szen_sphere^SScript^Stalent.zen_sphere.enabled&!dot.zen_sphere.ticking&(energy.current+(energy.regen*gcd))<100^t^N12^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.25^SAbility^Schi_explosion^SScript^Schi.current>=3^t^N13^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Schi.current>=4^t^N14^T^SEnabled^B^SName^SBlackout~`Kick~`(2)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^t^N15^T^SEnabled^B^SName^SBlackout~`Kick~`(3)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.serenity.up^t^N16^T^SEnabled^B^SName^SExpel~`Harm^SRelease^N2.25^SAbility^Sexpel_harm^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^t^N17^T^SEnabled^B^SName^SJab^SRelease^N2.25^SAbility^Sjab^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^t^N18^T^SRelease^N2.25^SAbility^Stiger_palm^SName^STiger~`Palm^SEnabled^B^t^t^SName^SBM:~`Single~`Target^t^^" )
    
    storeDefault( "BM: AOE", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N2.2^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10&((charges=1&recharge_time<5)|charges=2)^t^N2^T^SEnabled^B^SName^SPurifying~`Brew^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&stagger.heavy^t^N3^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.down^t^N4^T^SEnabled^B^SName^SPurifying~`Brew~`(1)^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&buff.serenity.up^t^N5^T^SEnabled^B^SName^SPurifying~`Brew~`(2)^SRelease^N2.25^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.moderate&buff.shuffle.remains>=6^t^N6^T^SEnabled^B^SName^SGuard^SRelease^N2.25^SAbility^Sguard^SScript^Stoggle.mitigation&(charges=1&recharge_time<5)|charges=2|target.time_to_die<15^t^N7^T^SEnabled^B^SName^SGuard~`(1)^SRelease^N2.25^SAbility^Sguard^SScript^Stoggle.mitigation&incoming_damage_10s>=health.max*0.5^t^N8^T^SEnabled^B^SName^SBreath~`of~`Fire^SRelease^N2.25^SAbility^Sbreath_of_fire^SScript^S(chi.current>=3|buff.serenity.up)&buff.shuffle.remains>=6&dot.breath_of_fire.remains<=2.4&!talent.chi_explosion.enabled^t^N9^T^SEnabled^B^SName^SKeg~`Smash^SRelease^N2.25^SAbility^Skeg_smash^SScript^Schi.max-chi.current>=1&!buff.serenity.up^t^N10^T^SEnabled^B^SName^SRushing~`Jade~`Wind^SRelease^N2.25^SAbility^Srushing_jade_wind^SScript^Schi.max-chi.current>=1&!buff.serenity.up&talent.rushing_jade_wind.enabled^t^N11^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.25^SAbility^Schi_burst^SScript^S(energy.current+(energy.regen*gcd))<100^t^N12^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.25^SAbility^Schi_wave^SScript^S(energy.current+(energy.regen*gcd))<100^t^N13^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.25^SAbility^Szen_sphere^SScript^Stalent.zen_sphere.enabled&!dot.zen_sphere.ticking&(energy.current+(energy.regen*gcd))<100^t^N14^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.25^SAbility^Schi_explosion^SScript^Schi.current>=4^t^N15^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Schi.current>=4^t^N16^T^SEnabled^B^SName^SBlackout~`Kick~`(2)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^t^N17^T^SEnabled^B^SName^SBlackout~`Kick~`(3)^SRelease^N2.25^SAbility^Sblackout_kick^SScript^Sbuff.serenity.up^t^N18^T^SEnabled^B^SName^SExpel~`Harm^SRelease^N2.25^SAbility^Sexpel_harm^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^t^N19^T^SEnabled^B^SName^SJab^SRelease^N2.25^SAbility^Sjab^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^t^N20^T^SRelease^N2.25^SAbility^Stiger_palm^SName^STiger~`Palm^SEnabled^B^t^t^SName^SBM:~`AOE^t^^" )
    
    storeDefault( "BM: Cooldowns", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SSpecialization^N268^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SBlood~`Fury^SRelease^N2.25^SAbility^Sblood_fury^SScript^Senergy.current<=40^t^N2^T^SEnabled^B^SName^SBerserking^SRelease^N2.25^SAbility^Sberserking^SScript^Senergy.current<=40^t^N3^T^SEnabled^B^SName^SArcane~`Torrent^SRelease^N2.25^SAbility^Sarcane_torrent^SScript^Senergy.current<=40^t^N4^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10&((charges=1&recharge_time<5)|charges=2|target.time_to_die<15)^t^N5^T^SEnabled^B^SName^SInvoke~`Xuen,~`the~`White~`Tiger^SRelease^N2.25^SAbility^Sinvoke_xuen^SScript^Stalent.invoke_xuen.enabled&target.time_to_die>15&buff.shuffle.remains>=3&buff.serenity.down^t^N6^T^SEnabled^B^SName^SSerenity^SRelease^N2.25^SAbility^Sserenity^SScript^Stalent.serenity.enabled&cooldown.keg_smash.remains>6^t^t^SName^SBM:~`Cooldowns^t^^" )

    storeDefault( "BM: Mitigation", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N2.2^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SName^SDampen~`Harm^SRelease^N2.25^SAbility^Sdampen_harm^SScript^Stoggle.mitigation&time=0^t^N2^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.25^SAbility^Schi_brew^SScript^Stoggle.mitigation&(chi.current<1&stagger.heavy)|(chi.current<2&buff.shuffle.down)^t^N3^T^SEnabled^B^SName^SDiffuse~`Magic^SRelease^N2.25^SAbility^Sdiffuse_magic^SScript^Stoggle.mitigation&incoming_damage_1500ms>0&buff.fortifying_brew.down^t^N4^T^SEnabled^B^SName^SDampen~`Harm~`(1)^SRelease^N2.25^SAbility^Sdampen_harm^SScript^Stoggle.mitigation&incoming_damage_1500ms>0&buff.fortifying_brew.down&buff.elusive_brew_activated.down^t^N5^T^SEnabled^B^SName^SFortifying~`Brew^SRelease^N2.25^SAbility^Sfortifying_brew^SScript^Stoggle.mitigation&incoming_damage_1500ms>0&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down^t^N6^T^SEnabled^B^SName^SElusive~`Brew^SRelease^N2.25^SAbility^Selusive_brew^SScript^Stoggle.mitigation&buff.elusive_brew_stacks.react>=9&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down^t^t^SName^SBM:~`Mitigation^t^^" )
    

    storeDefault( "Monk: Buffs", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SSpecialization^N0^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SLegacy~`of~`the~`White~`Tiger^SRelease^N2.06^SAbility^Slegacy_of_the_white_tiger^SScript^S!buff.str_agi_int.up|!buff.critical_strike.up^t^t^SName^SMonk:~`Buffs^t^^" )
    
    storeDefault( "Monk: Interrupts", "actionLists", 2.13, "^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N2.13^SSpecialization^N0^SActions^T^N1^T^SEnabled^B^SName^SSpear~`Hand~`Strike^SRelease^N2.06^SScript^Starget.casting^SAbility^Sspear_hand_strike^t^t^SName^SMonk:~`Interrupts^t^^" )
    
    storeDefault( "MW: Crane", "actionLists", 2.20, "^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N2.2^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns^SRelease^N2.06^SName^SInvoke~`Xuen^SAbility^Sinvoke_xuen^SCaption^S^t^N2^T^SEnabled^B^SName^SBreath~`of~`the~`Serpent^SRelease^N2.06^SAbility^Sbreath_of_the_serpent^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SName^SSurging~`Mist^SRelease^N2.06^SCaption^S^SScript^S(health.pct<100|group)&buff.vital_mists.stack=5^SAbility^Ssurging_mist^t^N4^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.mana_tea_stacks.stacks<=19^t^N5^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SScript^Sbuff.tiger_power.remains<=3^SAbility^Stiger_palm^t^N6^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SRelease^N2.06^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N7^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SScript^Sbuff.cranes_zeal.down^SAbility^Sblackout_kick^t^N8^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SCaption^S^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1^t^N9^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_wave^t^N10^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_burst^t^N11^T^SEnabled^B^SScript^S^SRelease^N2.06^SAbility^Szen_sphere^SName^SZen~`Sphere^SCaption^S^t^N12^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SScript^S((!group&chi.current>=3)|chi.current>=4)&buff.combo_breaker_ce.react^SAbility^Schi_explosion^t^N13^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^t^N14^T^SEnabled^B^SName^SChi~`Explosion~`(1)^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=4|(!group&chi.current>=3)^t^N15^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^S!talent.rushing_jade_wind.enabled&my_enemies>=3&chi.current<chi.max^t^N16^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max^t^N17^T^SEnabled^B^SName^SBlackout~`Kick~`(Filler)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S^t^t^SName^SMW:~`Crane^t^^" )
    
    storeDefault( "MW: Buffs", "actionLists", 20150110.1, "^1^T^SEnabled^B^SName^SMW:~`Buffs^SRelease^N2.25^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SName^SLegacy~`of~`the~`Emperor^SRelease^N2.25^SAbility^Slegacy_of_the_emperor^SScript^S!buff.str_agi_int.up^t^t^SScript^S^t^^" )
    
    
    storeDefault( "WW: Primary", "displays", 20150116.1, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^STigereye~`Brew^Srel^SCENTER^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N269^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMonk:~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^Stime<2^t^N2^T^SEnabled^B^SAction~`List^SWW:~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SAction~`List^SMonk:~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N4^T^SEnabled^B^SAction~`List^SWW:~`Single~`Target^SName^SSingle~`Target^SRelease^N2.06^SScript^Ssingle|(cleave&my_enemies<3)^t^N5^T^SEnabled^B^SAction~`List^SWW:~`AOE^SName^SAOE^SRelease^N2.06^SScript^Saoe|(cleave&my_enemies>=3)^t^t^SScript^S^SEnabled^B^STalent~`Group^N0^SFont^SElvUI~`Font^SRelease^N20150107.1^SName^SWW:~`Primary^Sy^N-270^SIcons~`Shown^N4^SDefault^B^SPvP~`Visibility^Salways^SPrimary~`Caption^Sbuff^SForce~`Targets^N1^SAction~`Captions^B^Sx^N-68^t^^" )
    
    storeDefault( "WW: AOE", "displays", 2.13, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N269^SSpacing^N7^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^SWW:~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^SWW:~`AOE^SName^SAOE^SRelease^N2.06^SScript^S^t^t^SScript^S^SMaximum~`Time^N30^SIcons~`Shown^N4^STalent~`Group^N0^SRelease^N2.13^SName^SWW:~`AOE^Sy^N-175^SFont^SArial~`Narrow^SDefault^B^SPvP~`Visibility^Salways^SPrimary~`Caption^Stargets^SForce~`Targets^N3^SAction~`Captions^B^Sx^N-90^t^^" )
    
    
    storeDefault( "BM: Primary", "displays", 20150116.1, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N268^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMonk:~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^Stime<2^t^N2^T^SEnabled^B^SAction~`List^SMonk:~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^SBM:~`Mitigation^SName^SMitigation^SRelease^N2.06^SScript^Stoggle.mitigation^t^N4^T^SEnabled^B^SAction~`List^SBM:~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N5^T^SEnabled^B^SAction~`List^SBM:~`Single~`Target^SName^SSingle~`Target^SRelease^N2.06^SScript^Ssingle|(cleave&active_enemies<3)^t^N6^T^SEnabled^B^SAction~`List^SBM:~`AOE^SName^SAOE^SRelease^N2.06^SScript^Saoe|(cleave&active_enemies>2)^t^t^SScript^S^SIcons~`Shown^N4^STalent~`Group^N0^Sx^N-68^SPrimary~`Caption^Sdefault^SDefault^B^Sy^N-270^SFont^SElvUI~`Font^SName^SBM:~`Primary^SPvP~`Visibility^Salways^SRelease^N2.2^SForce~`Targets^N1^SAction~`Captions^B^SEnabled^B^t^^" )
    
    storeDefault( "BM: AOE", "displays", 2.20, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N268^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^SBM:~`Mitigation^SName^SMitigation^SRelease^N2.06^SScript^Stoggle.mitigation^t^N2^T^SEnabled^B^SAction~`List^SBM:~`Cooldowns^SName^SCooldowns^SRelease^N2.11^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SAction~`List^SBM:~`AOE^SName^SAOE^SRelease^N2.06^SScript^S^t^t^SScript^S^Sx^N-40^SIcons~`Shown^N4^SFont^SArial~`Narrow^SRelease^N2.2^SDefault^B^Sy^N-182.5^STalent~`Group^N0^SName^SBM:~`AOE^SPvP~`Visibility^Salways^SPrimary~`Caption^Stargets^SForce~`Targets^N3^SAction~`Captions^B^SMaximum~`Time^N30^t^^" )
    
    storeDefault( "MW: Primary", "displays", 20150116.1, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SVital~`Mists^Srel^SCENTER^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N270^SSpacing^N7^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMW:~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^Stime<2^t^N2^T^SEnabled^B^SAction~`List^SMonk:~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^SMW:~`Crane^SName^SCrane~`Stance^SRelease^N2.06^SScript^S^t^t^SScript^Sstance.spirited_crane^STalent~`Group^N0^Sx^N-90^SFont^SArial~`Narrow^SRelease^N20150110.2^SDefault^B^Sy^N-225^SIcons~`Shown^N5^SName^SMW:~`Primary^SPvP~`Visibility^Salways^SPrimary~`Caption^Sbuff^SForce~`Targets^N1^SAction~`Captions^B^SMaximum~`Time^N30^t^^" )
    
    
  end
  
end