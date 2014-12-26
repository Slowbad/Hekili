-- Monk.lua
-- August 2014

local addon, ns = ...

local Hekili = _G[ addon ]

local AddAbility = Hekili.Utils.AddAbility
local ModifyAbility = Hekili.Utils.ModifyAbility

local AddHandler = Hekili.Utils.AddHandler

local AddAura = Hekili.Utils.AddAura
local ModifyAura = Hekili.Utils.ModifyAura

local AddGlyph	= Hekili.Utils.AddGlyph
local AddTalent = Hekili.Utils.AddTalent
local AddPerk = Hekili.Utils.AddPerk
local AddResource = Hekili.Utils.AddResource
local AddStance = Hekili.Utils.AddStance

local AddItemSet = Hekili.Utils.AddItemSet

local SetGCD = Hekili.Utils.SetGCD


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'MONK') then

	Hekili.Class = 'MONK'
  Hekili.State.gcd = 1.0

	function Hekili:SetClassModifiers()
    if Hekili.SpecializationKey == 'mistweaver' then Hekili.State.gcd = nil
    else Hekili.State.gcd = 1.0 end
  end
  
	AddResource( SPELL_POWER_ENERGY, true )
	AddResource( SPELL_POWER_CHI )
  AddResource( SPELL_POWER_MANA )
	-- AddResource( SPELL_POWER_HEALTH )

	AddTalent( 'ascension', 115396 )
	AddTalent( 'breath_of_the_serpent', 157535 )
	AddTalent( 'celerity', 115173 )
	AddTalent( 'charging_ox_wave', 119392 )
	AddTalent( 'chi_brew', 115399 )
	AddTalent( 'chi_burst', 123986 )
	AddTalent( 'chi_explosion', 152174 ) -- WW
	-- AddTalent( 'chi_explosion', 157676 ) -- BM
	-- AddTalent( 'chi_explosion', 157675 ) -- MW
	AddTalent( 'chi_torpedo', 115008 )
	AddTalent( 'chi_wave', 115098 )
	AddTalent( 'dampen_harm', 122278 )
	AddTalent( 'diffuse_magic', 122783 )
	AddTalent( 'healing_elixirs', 122280 )
	AddTalent( 'hurricane_strike', 152175 )
	AddTalent( 'invoke_xuen', 123904 )
	AddTalent( 'leg_sweep', 119381 )
	AddTalent( 'momentum', 115174 )
	AddTalent( 'pool_of_mists', 173841 )
	AddTalent( 'power_strikes', 121817 )
	AddTalent( 'ring_of_peace', 116844 )
	AddTalent( 'rushing_jade_wind', 116847 )
	AddTalent( 'serenity', 152173 )
	AddTalent( 'soul_dance', 157533 )
	AddTalent( 'tigers_lust', 116841 )
	AddTalent( 'zen_sphere', 124081 )

	-- Glyphs.
	AddGlyph( 'breath_of_fire', 123394 )
	AddGlyph( 'crackling_tiger_lightning', 125931 )
	AddGlyph( 'detox', 146954 )
	AddGlyph( 'detoxing', 171926 )
	AddGlyph( 'expel_harm', 159487 )
	AddGlyph( 'fighting_pose', 125872 )
	AddGlyph( 'fists_of_fury', 125671 )
	AddGlyph( 'flying_fists', 173182 )
	AddGlyph( 'flying_serpent_kick', 123403 )
	AddGlyph( 'fortifying_brew', 124997 )
	AddGlyph( 'fortuitous_spheres', 146953 )
	AddGlyph( 'freedom_roll', 159534 )
	AddGlyph( 'guard', 123401 )
	AddGlyph( 'honor', 125732 )
	AddGlyph( 'jab', 125660 )
	AddGlyph( 'keg_smash', 159495 )
	AddGlyph( 'leer_of_the_ox', 125967 )
	AddGlyph( 'life_cocoon', 124989 )
	AddGlyph( 'mana_tea', 123763 )
	AddGlyph( 'nimble_brew', 146952 )
	AddGlyph( 'paralysis', 125755 )
	AddGlyph( 'rapid_rolling', 146951 )
	AddGlyph( 'renewed_tea', 159496 )
	AddGlyph( 'renewing_mist', 123334 )
	AddGlyph( 'rising_tiger_kick', 125151 )
	AddGlyph( 'soothing_mist', 159536 )
	AddGlyph( 'spirit_roll',  125154 )
	AddGlyph( 'surging_mist', 120483 )
	AddGlyph( 'targeted_expulsion', 146950 )
	AddGlyph( 'floating_butterfly', 159490 )
	AddGlyph( 'flying_serpent', 159492 )
	AddGlyph( 'touch_of_death', 123391 )
	AddGlyph( 'touch_of_karma', 125678 )
	AddGlyph( 'transcendence', 123023 )
	AddGlyph( 'victory_roll',  159497 )
	AddGlyph( 'water_roll', 125901 )
	AddGlyph( 'zen_flight', 125893 )
	AddGlyph( 'zen_focus', 159545 )
	AddGlyph( 'zen_meditation', 120477 )
	
	-- Player Buffs.
	AddAura( 'cranes_zeal', 127722, 'duration', 20 )
	AddAura( 'fortifying_brew', 115203 )
	AddAura( 'shuffle', 115307 )
  AddAura( 'breath_of_fire', 123725 )
  AddAura( 'chi_explosion', 157680 )
  AddAura( 'combo_breaker_bok', 116768 )
  AddAura( 'combo_breaker_ce', 159407 )
  AddAura( 'combo_breaker_tp', 118864 )
  AddAura( 'dampen_harm', 122278 )
  AddAura( 'diffuse_magic', 122783 )
  AddAura( 'elusive_brew_activated', 115308, 'fullscan', true )
  AddAura( 'elusive_brew_stacks', 128939, 'fullscan', true )
  AddAura( 'energizing_brew', 115288 )
  AddAura( 'guard', 115295 )
  AddAura( 'heavy_stagger', 124273, 'unit', 'player' )
  AddAura( 'keg_smash', 121253 )
  AddAura( 'legacy_of_the_emperor', 115921, 'duration', 3600 )
  AddAura( 'legacy_of_the_white_tiger', 116781, 'duration', 3600 )
  AddAura( 'light_stagger', 124275, 'unit', 'player' )
  AddAura( 'mana_tea_stacks', 115867, 'duration', 120, 'max_stacks', 15 )
  AddAura( 'mana_tea_activated', 115294 )
  AddAura( 'moderate_stagger', 124274, 'duration', 10, 'unit', 'player' )
  AddAura( 'rising_sun_kick', 130320 )
  AddAura( 'rushing_jade_wind', 116847 )
  AddAura( 'serenity', 152173 )
  AddAura( 'spinning_crane_kick', 101546 )
  AddAura( 'stagger', 124255 )
  AddAura( 'tiger_palm', 100787 )
  AddAura( 'tiger_power', 125359 )
  AddAura( 'tigereye_brew', 125195, 'fullscan', true )
  AddAura( 'tigereye_brew_use', 116740, 'fullscan', true )
  AddAura( 'vital_mists', 118674, 'duration', 30, 'max_stacks', 5 )
  AddAura( 'zen_sphere', 124081 )
  
	-- Perks.
	AddPerk( 'empowered_chi', 157411 )
	AddPerk( 'empowered_spinning_crane_kick', 157415 )
	AddPerk( 'enhanced_roll', 157361 )
	AddPerk( 'enhanced_transcendence', 157366 )
	AddPerk( 'improved_breath_of_fire', 157362 )
	AddPerk( 'improved_guard', 157363 )
	AddPerk( 'improved_life_cocoon', 157401 )
	AddPerk( 'improved_renewing_mist', 157398 )
	
	-- Stances.
	-- Need to confirm the right IDs based on spec.
	AddStance( 'fierce_tiger', 'windwalker', 1 )
	AddStance( 'sturdy_ox', 'brewmaster', 1 )
	AddStance( 'wise_serpent', 'mistweaver', 1 )
  AddStance( 'spirited_crane', 'mistweaver', 2 )
		
	-- Pick an instant cast ability for checking the GCD.
	SetGCD( 'legacy_of_the_emperor' )
	-- Need to confirm "legacy_of_the_emperor" works with WW, BM since they upgrade to "legacy_of_the_white_tiger."

	-- Gear Sets
	AddItemSet( 'tier17', 115555, 115556, 115557, 115558, 115559 )

  
  -- State Modifications
  Hekili.State.stagger = setmetatable( {}, {
    __index = function(t, k)
      if k == 'heavy' then return Hekili.State.debuff.heavy_stagger.up
      elseif k == 'moderate' then return Hekili.State.debuff.moderate_stagger.up or Hekili.State.debuff.heavy_stagger.up
      elseif k == 'light' then return Hekili.State.debuff.light_stagger.up or Hekili.State.debuff.moderate_stagger.up or Hekili.State.debuff.heavy_stagger.up
      elseif k == 'amount' then
        if Hekili.State.debuff.heavy_stagger.up then return Hekili.State.debuff.heavy_stagger.v2
        elseif Hekili.State.debuff.moderate_stagger.up then return Hekili.State.debuff.moderate_stagger.v2
        elseif Hekili.State.debuff.light_stagger.up then return Hekili.State.debuff.light_stagger.v2
        else return 0 end
      elseif k == 'tick' then
        if Hekili.State.debuff.heavy_stagger.up then return Hekili.State.debuff.heavy_stagger.v1
        elseif Hekili.State.debuff.moderate_stagger.up then return Hekili.State.debuff.moderate_stagger.v1
        elseif Hekili.State.debuff.light_stagger.up then return Hekili.State.debuff.light_stagger.v1
        else return 0 end
      end
      
      error( "UNK: " .. k )
    end
  } )
  
  
  function Hekili:CreateClassToggles()
    local found, empty = false, nil
    
    for i = 1, 5 do
      if not empty and self.DB.profile[ 'Toggle ' ..i.. ' Name' ] == nil then
        empty = i
      elseif self.DB.profile[ 'Toggle ' ..i.. ' Name' ] == 'mitigation' then
        found = i
        break
      end
    end
    
    if not found and empty then
      self.DB.profile[ 'Toggle ' ..empty.. ' Name' ] = 'mitigation'
      found = empty
    end
    
    if type( found ) == 'number' then
      self.DB.profile[ 'Toggle_' .. found ] = self.DB.profile[ 'Toggle_' .. found ] == nil and true or self.DB.profile[ 'Toggle_' .. found ]
    end
  end

  
	-- Abilities
	
	AddAbility( 'blackout_kick', 100784,
		{
      known = function ( s ) return not s.talent.chi_explosion.enabled end,
			spend = function ( s )
        if s.buff.combo_breaker_bok.up then return 0, SPELL_POWER_CHI end
        return 2, SPELL_POWER_CHI
      end,
			cast = 0,
			gcdType = 'melee',
			cooldown = 0,
			usable = function( s )
				if s.stance.wise_serpent then return false end
				return true
			end,
		} )
	
	AddHandler( 'blackout_kick', function ()
		if spec.brewmaster then H:Buff( 'shuffle', 6 )
		elseif spec.mistweaver then
      H:AddStack( 'vital_mists', 30, 2 )
      H:Buff( 'cranes_zeal', 20 )
    end
    if buff.serenity.up and not buff.combo_breaker_bok.up then H:Gain( 2, 'chi' ) end
    H:RemoveBuff( 'combo_breaker_bok' )
	end )
	
	
	AddAbility( 'crackling_jade_lightning', 117952,
		{
			spend = function( s )
				if s.stance.spirited_crane then return 0.213, SPELL_POWER_MANA end
				return 0, SPELL_POWER_ENERGY
			end,
			cast = 4, -- need a 'channel' version.
			gcdType = 'spell',
			cooldown = 0,
			usable = function( s ) return not s.stance.wise_serpent end
		} )
	
	AddHandler( 'crackling_jade_lightning', function ()
		if spec.mistweaver then H:Gain( 1, "chi" ) end -- need to fix up for channeling.
	end )
	
	
	AddAbility( 'expel_harm', 115072,
		{
			spend = function( s )
        if s.spec.mistweaver then
          return 0.02, SPELL_POWER_MANA
        end
        return 40, SPELL_POWER_ENERGY
      end,
			cast = 0,
			gcdType = 'melee',
			cooldown = 15,
			usable = function( s ) return not s.stance.wise_serpent end
		} )
	
	ModifyAbility( 'expel_harm', 'cooldown', function( x )
		if stance.sturdy_ox and health.pct < 35 then return 0 end
		return x
	end )
  
  AddHandler( 'expel_harm', function ()
    H:Gain( 1, 'chi' )
  end )


	AddAbility( 'fortifying_brew', 115203,
		{
			spend = 0,
			cast = 0,
			gcdType = 'spell',
			cooldown = 180
		} )
	
	AddHandler( 'fortifying_brew', function ()
		local health_gain = health.max * 0.2
		H:Buff( 'fortifying_brew', 15 )
		health.current = health.current + health_gain
		health.max = health.max + health_gain
	end )
  
  
  AddAbility( 'jab', 100780,
    {
      spend = function( s )
        if s.stance.spirited_crane then return 0.035, SPELL_POWER_MANA
        elseif s.stance.fierce_tiger then return 45, SPELL_POWER_ENERGY end
        return 40, SPELL_POWER_ENERGY
      end,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0
    } )
  
  AddHandler( 'jab', function ()
    H:Gain( spec.windwalker and 2 or 1, 'chi' )
  end )
  
  
  AddAbility( 'spear_hand_strike', 116705,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 15
    } )
  
  AddHandler( 'spear_hand_strike', function ()
    H:Interrupt( 'target' )
  end )
  
  
  AddAbility( 'spinning_crane_kick', 101546,
    {
      spend = function ( s )
        if s.stance.spirited_crane then
          return 0.08, SPELL_POWER_MANA
        end
        return 40, SPELL_POWER_ENERGY
      end,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0
    } )
  
  AddHandler( 'spinning_crane_kick', function ()
    H:Buff( 'spinning_crane_kick', ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
    H:SetCooldown( H.GCD, ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
    if active_enemies >= 3 then H:Gain( 1, 'chi' ) end
  end )
  
  
  AddAbility( 'fierce_tiger', 103985,
    {
      spend = 0,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0
    } )
  
  AddHandler( 'fierce_tiger', function ()
    H:Stance( 'fierce_tiger' )
  end )
  
  
  AddAbility( 'surging_mist', 116694,
    {
      spend = function ( s )
        if s.spec.mistweaver then return 0.047, SPELL_POWER_MANA end
        return 30, SPELL_POWER_ENERGY
      end,
      cast = 1.5,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  ModifyAbility( 'surging_mist', 'cast', function ( x )
    if buff.vital_mists.up then x = ( x - ( x * ( 0.2 * buff.vital_mists.stack ) ) ) end
    return x * haste
  end )
  
  AddHandler( 'surging_mist', function ()
    if spec.mistweaver then H:Gain( 1, 'chi' ) end
    H:RemoveBuff( 'vital_mists' )
  end )
  
  
  AddAbility( 'tiger_palm', 100787,
    {
      spend = function ( s )
        if s.spec.brewmaster or s.buff.combo_breaker_tp.up then
          return 0, SPELL_POWER_CHI
        end
        return 1, SPELL_POWER_CHI
      end,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0,
      usable = function ( s )
        if s.stance.wise_serpent then
          return false
        end
        return true
      end
    } )
  
  AddHandler( 'tiger_palm', function ()
    if buff.serenity.up and not buff.combo_breaker_tp.up then H:Gain( 1, 'chi' ) end
    if spec.brewmaster then H:Buff( 'tiger_palm', 20 )
    else
      H:Buff( 'tiger_power', 20 )
      H:AddStack( 'vital_mists', 30, 1 )
    end
    H:RemoveBuff( 'combo_breaker_tp' )
  end )
  
  
  AddAbility( 'touch_of_death', 115080,
    {
      spend = 3,
      spend_type = SPELL_POWER_CHI,
      cast = 0,
      gcdType = 'melee',
      cooldown = 90,
      usable = function ( s ) return s.target.health.pct < 10 end
    } )
  
  AddHandler( 'touch_of_death', function ()
    if buff.serenity.up then H:Gain( 3, 'chi' ) end
  end )
  
  
  AddAbility( 'breath_of_fire', 115181,
    {
      spend = 2,
      spend_type, SPELL_POWER_CHI,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'breath_of_fire', function ()
    if perk.improved_breath_of_fire.enabled or debuff.dizzying_haze.up then
      H:Debuff( 'target', 'breath_of_fire', 8 )
    end
    if buff.serenity.up then H:Gain( 2, 'chi' ) end
  end )
  
  
  AddAbility( 'detonate_chi', 115460,
    {
      spend = 0.03,
      spend_type = SPELL_POWER_MANA,
      cast = 0,
      gcdType = 'spell',
      cooldown = 10
    } )
  
  
  AddAbility( 'disable', 116095,
    {
      spend = function ( s )
        if s.stance.fierce_tiger then
          return 15, SPELL_POWER_ENERGY
        end
        return 0.007, SPELL_POWER_ENERGY
      end,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0
    } )
  
  AddHandler( 'disable', function ()
    if debuff.disable.up then
      -- apply disable root
    else
      H:Debuff( 'target', 'disable', 8 )
    end
  end )
  
  
  AddAbility( 'dizzying_haze', 115180,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'dizzying_haze', function ()
    H:Debuff( 'target', 'dizzying_haze', 15 )
  end )
  
  
  AddAbility( 'elusive_brew', 115308,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 6
    } )
  
  AddHandler( 'elusive_brew', function ()
    H:Buff( 'elusive_brew_activated', buff.elusive_brew_stacks.stack )
    H:RemoveBuff( 'elusive_brew_stacks' )
  end )
  
  
  AddAbility( 'energizing_brew', 115288,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 60
    } )
  
  AddHandler( 'energizing_brew', function ()
    H:Buff( 'energizing_brew', 6 )
  end )
  
 
  AddAbility( 'enveloping_mist', 124682,
    {
      spend = 3,
      spend_type = SPELL_POWER_CHI,
      usable = function ( s ) return s.stance.wise_serpent end,
      cast = 2,
      cooldown = 0
    } )
  
  AddHandler( 'enveloping_mist', function ()
    if buff.serenity.up then H:Gain( 3, 'chi' ) end
  end )
  

  AddAbility( 'fists_of_fury', 113656,
    {
      spend = 3,
      spend_type = SPELL_POWER_CHI,
      cast = 4,
      gcdType = 'spell',
      cooldown = 25
    } )
    
  ModifyAbility( 'fists_of_fury', 'cast', function ( x )
    return x * haste
  end )
  
  AddHandler( 'fists_of_fury', function ()
    if buff.serenity.up then H:Gain( 3, 'chi' ) end
  end )
  
  
  AddAbility( 'flying_serpent_kick', 101545,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 25
    } )
  
  AddHandler( 'flying_serpent_kick', function ()
    if target.within8 then H:Debuff( 'target', 'flying_serpent_kick', 4 ) end
  end )
  
  
  AddAbility( 'guard', 115295, 
    {
      spend = 2,
      spend_type = SPELL_POWER_CHI,
      cast = 0,
      gcdType = 'off',
      cooldown = 30,
      charges = 1
    } )

  ModifyAbility( 'guard', 'cooldown', function ( x )
    if cooldown.guard.charges > 1 then return 1 end
    return x
  end )
  
  ModifyAbility( 'guard', 'charges', function ( x )
    if perk.improved_guard.enabled then return 2 end
    return x
  end )
  
  AddHandler( 'guard', function ()
    H:Buff( 'guard', 30 )
    if buff.serenity.up then H:Gain( 2, 'chi' ) end
  end )
  
  
  AddAbility( 'keg_smash', 121253,
    {
      spend = 40,
      spend_type = SPELL_POWER_ENERGY,
      cast = 0,
      gcdType = 'melee',
      cooldown = 8
    } )
  
  AddHandler( 'keg_smash', function ()
    H:Debuff( 'target', 'keg_smash', 15 )
    H:Gain( 2, 'chi' )
  end )
  
  
  AddAbility( 'legacy_of_the_emperor', 115921,
    {
      spend = function ( s )
        if s.spec.mistweaver then return 0.01, SPELL_POWER_MANA end
        return 20, SPELL_POWER_ENERGY
      end,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'legacy_of_the_emperor', function ()
    H:Buff( 'legacy_of_the_emperor', 3600 )
    H:Buff( 'str_agi_int', 3600 )
  end )
  
  
  AddAbility( 'legacy_of_the_white_tiger', 116781,
    {
      spend = 20,
      spend_type = SPELL_POWER_ENERGY,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
   
  AddHandler( 'legacy_of_the_white_tiger', function ()
    H:Buff( 'legacy_of_the_white_tiger', 3600 )
    H:Buff( 'str_agi_int', 3600 )
    H:Buff( 'critical_strike', 3600 )
  end )
  
  
	AddAbility( 'life_cocoon', 116849,
    {
      spend = 0.024,
      spend_type = SPELL_POWER_MANA,
      cast = 0,
      gcdType = 'spell',
      cooldown = 120
    } )
  
  AddHandler( 'life_cocoon', function ()
    H:Buff( 'target', 'life_cocoon', 12 )
  end )
  
  ModifyAbility( 'life_cocoon', 'cooldown', function ( x )
    if perk.improved_life_cocoon.enabled then return x - 20 end
    return x
  end )
  
  
  AddAbility( 'mana_tea', 115294,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  ModifyAbility( 'mana_tea', 'cast', function ( x )
    return buff.mana_tea.stack * 0.5
  end )
  
  AddHandler( 'mana_tea', function ()
    H:RemoveBuff( 'mana_tea_stacks' )
  end )
  
  
  AddAbility( 'purifying_brew', 119582,
    {
      spend = 1,
      spend_type = SPELL_POWER_CHI,
      cast = 0,
      gcdType = 'off',
      cooldown = 1,
      usable = function ( s ) return s.stagger.light end,
    } )
  
  AddHandler( 'purifying_brew', function ()
    if buff.serenity.up then H:Gain( 1, 'chi' ) end
    H:RemoveDebuff( 'player', 'stagger' )
    H:RemoveDebuff( 'player', 'light_stagger' )
    H:RemoveDebuff( 'player', 'moderate_stagger' )
    H:RemoveDebuff( 'player', 'heavy_stagger' )
  end )
  
  
  AddAbility( 'renewing_mist', 115151,
    {
      spend = 0.04,
      spend_type = SPELL_POWER_MANA,
      cast = 0,
      gcdType = 'spell',
      cooldown = 8
    } )
  
  AddHandler( 'renewing_mist', function ()
    H:Buff( 'target', 'renewing_mist', 18 )
    H:Gain( 1, 'chi' )
  end )
  
  
  AddAbility( 'revival', 115310,
    {
      spend = 0.044,
      spend_type = SPELL_POWER_MANA,
      cast = 0,
      gcdType = 'spell',
      cooldown = 180
    } )
  
  
  AddAbility( 'rising_sun_kick', 107428,
    {
      spend = 2,
      spend_type = SPELL_POWER_CHI,
      cast = 0,
      gcdType = 'melee',
      cooldown = 8,
      charges = 1
    } )
  
  ModifyAbility( 'rising_sun_kick', 'charges', function ( x )
    if talent.pool_of_mists.enabled then return 3 end
    return nil
  end )
  
  AddHandler( 'rising_sun_kick', function ()
    if buff.serenity.up then H:Gain( 2, 'chi' ) end
    if spec.mistweaver then H:AddStack( 'vital_mists', 30, 2 ) end
    H:Debuff( 'target', 'rising_sun_kick', 15 )
  end )
  
  
  AddAbility( 'soothing_mist', 115175,
    {
      spend = 0,
      cast = 8,
      gcdType = 'spell',
      cooldown = 1
    } )
  
  AddAbility( 'soothing_mist', function ()
    H:Buff( 'target', 'soothing_mist', 8 )
  end )
  
  
  AddAbility( 'spirited_crane', 154436,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'spirited_crane', function ()
    H:Stance( 'spirited_crane' )
  end )
  
  
  AddAbility( 'sturdy_ox', 115069,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'sturdy_ox', function ()
    H:Stance( 'sturdy_ox' )
  end )
  
  
  AddAbility( 'wise_serpent', 115070,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 0
    } )
  
  AddHandler( 'wise_serpent', function ()
    H:Stance( 'wise_serpent' )
  end )
  
  
  AddAbility( 'storm_earth_and_fire', 137639,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 1
    } )
  
  
  AddAbility( 'summon_black_ox_statue', 115315,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 10
    } )
  
  AddHandler( 'summon_black_ox_statue', function ()
    H:AddTotem( 'summon_black_ox_statue', 600 )
  end )
  
  
  AddAbility( 'summon_jade_serpent_statue', 115315,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 10
    } )
  
  AddHandler( 'summon_jade_serpent_statue', function ()
    H:AddTotem( 'summon_jade_serpent_statue', 600 )
  end )
  
  
  AddAbility( 'thunder_focus_tea', 116680,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 45
    } )
  
  AddHandler( 'thunder_focus_tea', function ()
    H:Buff( 'thunder_focus_tea', 20 )
  end )
  
  
  AddAbility( 'tigereye_brew', 116740,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 5
    } )
  
  AddHandler( 'tigereye_brew', function ()
    H:Buff( 'tigereye_brew_use', 15 )
    H:RemoveStack( 'tigereye_brew', min( 10, buff.tigereye_brew.stack ) )
  end )
  

  AddAbility( 'touch_of_karma', 122470,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 90
    } )
  
  AddHandler( 'touch_of_karma', function ()
    H:Buff( 'touch_of_karma', 10 )
    H:DebufF( 'target', 'touch_of_karma', 10 )
  end )
  
  
  AddAbility( 'uplift', 116670,
    {
      spend = 2,
      spend_type = SPELL_POWER_CHI,
      cast = 1.5,
      gcdType = 'spell',
      cooldown = 0
    } )
    
  AddHandler( 'uplift', function ()
    if buff.serenity.up then H:Gain( 2, 'chi' ) end
  end )
  
  
  AddAbility( 'zen_meditation', 116176,
    {
      spend = 0,
      cast = 8,
      gcdType = 'spell',
      cooldown = 180
    } )
  
  AddHandler( 'zen_meditation', function ()
    H:Buff( 'zen_meditation', 8 )
  end )
      
    
  AddAbility( 'breath_of_the_serpent', 157535,
    {
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 90
    } )
  
  
  AddAbility( 'charging_ox_wave', 119392,
    {
      known = function ( s ) return s.talent.charging_ox_wave.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 30
    } )
  
  AddHandler( 'charging_ox_wave', function ()
    H:Debuff( 'target', 'charging_ox_wave', 3 )
  end )
  
  
  AddAbility( 'chi_brew', 115399,
    {
      known = function ( s ) return s.talent.chi_brew.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 60,
      charges = 2,
      recharge = 60
    } )
    
  ModifyAbility( 'chi_brew', 'cooldown', function ( x )
    if cooldown.chi_brew.charges > 1 then return 0 end
    return x
  end )
    
    
  AddHandler( 'chi_brew', function ()
    H:Gain( 2, 'chi' )
    if spec.windwalker then
      H:AddStack( 'tigereye_brew', 120, 2 )
    elseif spec.brewmaster then
      H:AddStack( 'elusive_brew_stacks', 30, 5 )
    elseif spec.mistweaver then
      H:AddStack( 'mana_tea_stacks', 120, 1 )
    end
  end )
  
  
  AddAbility( 'chi_burst', 123986,
    {
      known = function ( s ) return s.talent.chi_burst.enabled end,
      spend = 0,
      cast = 1,
      gcdType = 'spell',
      cooldown = 30
    } )
  
  
  AddAbility( 'chi_explosion', 157676, 157675, 152174,
    {
      known = function ( s ) return s.talent.chi_explosion.enabled end,
      spend = function ( s )
        if s.buff.combo_breaker_ce.up then return 0, SPELL_POWER_CHI end
        return 1, SPELL_POWER_CHI
      end,
      cast = 0,
      gcdType = 'melee',
      cooldown = 0
    } )
  
  AddHandler( 'chi_explosion', function ()
    local faux_chi = buff.combo_breaker_ce.up and chi.current or chi.current + 1
    if spec.brewmaster then
      if faux_chi >= 2 then H:Buff( 'shuffle', 2 + 2 * min(4, chi.current ) ) end
      if faux_chi >= 3 then
        H:RemoveDebuff( 'player', 'stagger' )
        H:RemoveDebuff( 'player', 'light_stagger' )
        H:RemoveDebuff( 'player', 'moderate_stagger' )
        H:RemoveDebuff( 'player', 'heavy_stagger' )
      end
    elseif spec.windwalker then
      if faux_chi >= 2 then H:Debuff( 'target', 'chi_explosion', 6 ) end
      if faux_chi >= 3 then H:AddStack( 'tigereye_brew', 120, 1 ) end
    elseif spec.mistweaver then
      if faux_chi >= 1 then H:Buff( 'chi_explosion', 6 ) end
      if faux_chi >= 2 then H:Buff( 'cranes_zeal', 20 ) end
      H:AddStack( 'vital_mists', 30, faux_chi )
    end
    -- If we had more than one chi going into this, spend up to 3 more.
    if chi.current > 0 and not buff.combo_breaker_ce.up then
      H:Spend( min( 3, chi.current ), 'chi' )
    end
    H:RemoveBuff( 'combo_breaker_ce' )
  end )
  
  
  AddAbility( 'chi_torpedo', 115008,
    {
      known = function ( s ) return s.talent.chi_torpedo.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'melee',
      cooldown = 20,
      charges = 2
    } )
  
  
  AddAbility( 'chi_wave', 115098,
    {
      known = function ( s ) return s.talent.chi_wave.enabled end,
      -- spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 15
    } )
  
  
  AddAbility( 'dampen_harm', 122278,
    {
      known = function ( s ) return s.talent.dampen_harm.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 90
    } )
  
  AddHandler( 'dampen_harm', function ()
    H:Buff( 'dampen_harm', 15 )
  end )
  
  
  AddAbility( 'diffuse_magic', 122783,
    {
      known = function ( s ) return s.talent.diffuse_magic.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 90
    } )
  
  AddHandler( 'diffuse_magic', function ()
    H:Buff( 'diffuse_magic', 6 )
  end )
  
  
  AddAbility( 'hurricane_strike', 152175,
    {
      spend = 3,
      spend_type = SPELL_POWER_CHI,
      cast = 2,
      gcdType = 'melee',
      cooldown = 45
    } )
  
   
   AddAbility( 'invoke_xuen', 123904,
    {
      known = function ( s ) return s.talent.invoke_xuen.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 180
    } )
  
  AddHandler( 'invoke_xuen', function ()
    H:AddPet( 'invoke_xuen', 45 )
  end )
  
  
  AddAbility( 'leg_sweep', 119381,
    {
      known = function ( s ) return s.talent.leg_sweep.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'melee',
      cooldown = 45
    } )
  
  AddHandler( 'leg_sweep', function ()
    H:Debuff( 'target', 'leg_sweep', 5 )
  end )
  
  
  AddAbility( 'ring_of_peace', 116844,
    {
      known = function ( s ) return s.talent.ring_of_peace.enabled end,
      spend = 0,
      cast = 0,
      gcdType = 'spell',
      cooldown = 45
    } )
  
  AddHandler( 'ring_of_peace', function ()
    H:Buff( 'target', 'ring_of_peace', 8 )
  end )
  
  
  AddAbility( 'rushing_jade_wind', 116847,
    {
      known = function ( s ) return s.talent.rushing_jade_wind.enabled end,
      spend = function ( s )
        if s.stance.spirited_crane or s.stance.wise_serpent then
          return 0.125, SPELL_POWER_MANA
        end
        return 40, SPELL_POWER_ENERGY
      end,
      cast = 0,
      gcdType = 'spell',
      cooldown = 6
    } )
  
  AddHandler( 'rushing_jade_wind', function ()
    if active_enemies >= 3 then H:Gain( 1, 'chi' ) end
    H:Buff( 'rushing_jade_wind', 6 )
  end )
  
  ModifyAbility( 'rushing_jade_wind', 'cooldown', function ( x )
    return x * haste
  end )
  
  
  AddAbility( 'serenity', 152173,
    {
      known = function ( s ) return s.talent.serenity.enabled end,
      spend = 0,
      cast = 0,
      cooldown = 90,
      gcdType = 'spell'
    } )
  
  AddHandler( 'serenity', function ()
    H:Buff( 'serenity', 10 )
  end )
  
  
  AddAbility( 'tigers_lust', 116841,
    {
      spend = 0,
      cast = 0,
      cooldown = 30,
      gcdType = 'spell'
    } )
    
  AddHandler( 'tigers_lust', function ()
    H:Buff( 'tigers_lust', 6 )
  end )
  
  
  AddAbility( 'zen_sphere', 124081,
    {
      known = function ( s ) return s.talent.zen_sphere.enabled end,
      spend = 0,
      cast = 0,
      cooldown = 10,
      gcdType = 'spell'
    } )
  
  AddHandler( 'zen_sphere', function ()
    H:Buff( 'target', 'zen_sphere', 16 )
  end )

  
  AddAbility( 'energizing_brew', 115288,
    {
      spend = 0,
      cast = 0,
      gcdType = 'off',
      cooldown = 60
    } )
  
  AddHandler( 'energizing_brew', function ()
    H:Buff( 'energizing_brew', 6 )
  end )
  
  
	Hekili.Default( "@Windwalker, Single Target", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Windwalker,~`Single~`Target^SRelease^N2.17^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.tigereye_brew.stack<=16^t^N2^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.remains<=3^t^N3^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^t^N4^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N5^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^t^N6^T^SEnabled^B^SName^SFists~`of~`Fury^SRelease^N2.06^SAbility^Sfists_of_fury^SScript^Sbuff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&!buff.serenity.up^t^N7^T^SEnabled^B^SScript^Starget.health.pct<10&cooldown.touch_of_death.remains=0^SAbility^Sfortifying_brew^SRelease^N2.06^SCaption^SToD^SName^SFortifying~`Brew^t^N8^T^SEnabled^B^SName^STouch~`of~`Death^SRelease^N2.06^SAbility^Stouch_of_death^SScript^Starget.health.percent<10^t^N9^T^SEnabled^B^SName^SHurricane~`Strike^SRelease^N2.06^SAbility^Shurricane_strike^SScript^Stalent.hurricane_strike.enabled&energy.time_to_max>cast_time&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.energizing_brew.down^t^N10^T^SEnabled^B^SName^SEnergizing~`Brew^SRelease^N2.06^SAbility^Senergizing_brew^SScript^Scooldown.fists_of_fury.remains>6&(!talent.serenity.enabled|!toggle.cooldowns|(!buff.serenity.up&cooldown.serenity.remains>4))&(energy.current+(energy.regen*gcd)<50)^t^N11^T^SEnabled^B^SName^SRising~`Sun~`Kick~`(1)^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S!talent.chi_explosion.enabled^t^N12^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SScript^Senergy.time_to_max>2&buff.serenity.down^t^N13^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SScript^Stalent.chi_burst.enabled&energy.time_to_max>2&buff.serenity.down^t^N14^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.06^SAbility^Szen_sphere^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking&buff.serenity.down^t^N15^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&(buff.combo_breaker_bok.up|buff.serenity.up)^t^N16^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^Stalent.chi_explosion.enabled&chi.current>=3&buff.combo_breaker_ce.up&cooldown.fists_of_fury.remains>3^t^N17^T^SEnabled^B^SName^STiger~`Palm~`(2)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^t^N18^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^t^N19^T^SEnabled^B^SName^SChi~`Explosion~`(1)^SRelease^N2.06^SAbility^Schi_explosion^SScript^Stalent.chi_explosion.enabled&chi.current>=3^t^N20^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.max-chi.current>=2^t^N21^T^SEnabled^B^SName^SJab~`(1)^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max&talent.chi_explosion.enabled&cooldown.fists_of_fury.remains<=3^t^t^SScript^S^t^^" )
  
  Hekili.Default( "@Windwalker, AOE", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Windwalker,~`AOE^SRelease^N2.17^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.tigereye_brew.stack<=16^t^N2^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.remains<=3^t^N3^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^t^N4^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N5^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^t^N6^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=4&(cooldown.fists_of_fury.remains>3|!talent.rushing_jade_wind.enabled)^t^N7^T^SRelease^N2.06^SAbility^Srushing_jade_wind^SName^SRushing~`Jade~`Wind^SEnabled^B^t^N8^T^SEnabled^B^SScript^Scooldown.fists_of_fury.remains>6&(!talent.serenity.enabled|!toggle.cooldowns|(!buff.serenity.remains&cooldown.serenity.remains>4))&(energy.current+energy.regen*gcd)<50^SRelease^N2.06^SAbility^Senergizing_brew^SName^SEnergizing~`Brew^t^N9^T^SEnabled^B^SName^SRising~`Sun~`Kick~`(1)^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S!talent.rushing_jade_wind.enabled&chi.current=chi.max^t^N10^T^SEnabled^B^SName^SFists~`of~`Fury^SRelease^N2.06^SAbility^Sfists_of_fury^SScript^Stalent.rushing_jade_wind.enabled&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&!buff.serenity.up^t^N11^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0^SAbility^Sfortifying_brew^SRelease^N2.06^SName^SFortifying~`Brew^t^N12^T^SEnabled^B^SName^STouch~`of~`Death^SRelease^N2.06^SAbility^Stouch_of_death^SScript^Starget.health.percent<10^t^N13^T^SEnabled^B^SName^SHurricane~`Strike^SRelease^N2.06^SAbility^Shurricane_strike^SScript^Stalent.rushing_jade_wind.enabled&talent.hurricane_strike.enabled&energy.time_to_max>cast_time&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.energizing_brew.down^t^N14^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.06^SAbility^Szen_sphere^SScript^S!dot.zen_sphere.ticking^t^N15^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SScript^Senergy.time_to_max>2&buff.serenity.down^t^N16^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SScript^Stalent.chi_burst.enabled&energy.time_to_max>2&buff.serenity.down^t^N17^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Stalent.rushing_jade_wind.enabled&!talent.chi_explosion.enabled&(buff.combo_breaker_bok.up|buff.serenity.up)^t^N18^T^SEnabled^B^SName^STiger~`Palm~`(2)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Stalent.rushing_jade_wind.enabled&buff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^t^N19^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S(talent.rushing_jade_wind.enabled|active_direct_enemies<3)&!talent.chi_explosion.enabled&chi.max-chi.current<2&(cooldown.fists_of_fury.remains>3|!talent.rushing_jade_wind.enabled)^t^N20^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^Sactive_direct_enemies>=3&!talent.rushing_jade_wind.enabled^t^N21^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^S(talent.rushing_jade_wind.enabled|active_direct_enemies<3)&chi.max-chi.current>=2^t^N22^T^SEnabled^B^SName^SJab~`(1)^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max&talent.chi_explosion.enabled&cooldown.fists_of_fury.remains<=3^t^t^SScript^S^t^^" )
  
  Hekili.Default( "@Windwalker, Cooldowns", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Windwalker,~`Cooldowns^SRelease^N2.17^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SName^SInvoke~`Xuen,~`the~`White~`Tiger^SRelease^N2.06^SAbility^Sinvoke_xuen^SScript^Stalent.invoke_xuen.enabled^t^N2^T^SEnabled^B^SName^SBlood~`Fury^SRelease^N2.06^SAbility^Sblood_fury^SScript^Sbuff.tigereye_brew_use.up|target.time_to_die<18^t^N3^T^SEnabled^B^SName^SBerserking^SRelease^N2.06^SAbility^Sberserking^SScript^Sbuff.tigereye_brew_use.up|target.time_to_die<18^t^N4^T^SEnabled^B^SName^SArcane~`Torrent^SRelease^N2.06^SAbility^Sarcane_torrent^SScript^Schi.max-chi.current>=1&(buff.tigereye_brew_use.up|target.time_to_die<18)^t^N5^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.tigereye_brew.stack<=16^t^N6^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.remains<=3^t^N7^T^SEnabled^B^SName^STigereye~`Brew^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^t^N8^T^SEnabled^B^SName^STigereye~`Brew~`(1)^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&buff.serenity.up^t^N9^T^SEnabled^B^SName^STigereye~`Brew~`(2)^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&cooldown.fists_of_fury.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N10^T^SEnabled^B^SName^STigereye~`Brew~`(3)^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Stalent.hurricane_strike.enabled&buff.tigereye_brew_use.down&buff.tigereye_brew.stack>=10&cooldown.hurricane_strike.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N11^T^SEnabled^B^SName^STigereye~`Brew~`(4)^SRelease^N2.06^SAbility^Stigereye_brew^SScript^Sbuff.tigereye_brew_use.down&chi.current>=2&(buff.tigereye_brew.stack>=16|target.time_to_die<40)&debuff.rising_sun_kick.up&buff.tiger_power.up^t^N12^T^SEnabled^B^SName^SRising~`Sun~`Kick^SRelease^N2.06^SAbility^Srising_sun_kick^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N13^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1&energy.time_to_max>1^t^N14^T^SEnabled^B^SName^SSerenity^SRelease^N2.06^SAbility^Sserenity^SScript^Stalent.serenity.enabled&chi.current>=2&buff.tiger_power.up&debuff.rising_sun_kick.up^t^t^SScript^S^t^^" )
  
  
  Hekili.Default( "@Brewmaster, Single Target", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Brewmaster,~`Single~`Target^SRelease^N2.13^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10^t^N2^T^SEnabled^B^SName^SElusive~`Brew^SRelease^N2.06^SAbility^Selusive_brew^SScript^Sbuff.elusive_brew_stacks.react=15&buff.elusive_brew_activated.down^t^N3^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.down^t^N4^T^SEnabled^B^SName^SPurifying~`Brew^SRelease^N2.06^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.heavy^t^N5^T^SEnabled^B^SName^SPurifying~`Brew~`(1)^SRelease^N2.06^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&((!group&health.pct<66)|buff.serenity.up)&stagger.light^t^N6^T^SRelease^N2.06^SAbility^Sguard^SName^SGuard^SEnabled^B^t^N7^T^SEnabled^B^SName^SKeg~`Smash^SRelease^N2.06^SAbility^Skeg_smash^SScript^Schi.max-chi.current>=2&!buff.serenity.up^t^N8^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SScript^Stalent.chi_burst.enabled&energy.time_to_max>3^t^N9^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SScript^Stalent.chi_wave.enabled&energy.time_to_max>3^t^N10^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.06^SAbility^Szen_sphere^SScript^Stalent.zen_sphere.enabled&!dot.zen_sphere.ticking^t^N11^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=3^t^N12^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Sbuff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^t^N13^T^SEnabled^B^SName^SBlackout~`Kick~`(2)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Sbuff.serenity.up^t^N14^T^SEnabled^B^SName^SBlackout~`Kick~`(3)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Schi.current>=4^t^N15^T^SEnabled^B^SName^SExpel~`Harm^SRelease^N2.06^SAbility^Sexpel_harm^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd^t^N16^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&cooldown.expel_harm.remains>=gcd^t^N17^T^SEnabled^B^SName^SPurifying~`Brew~`(2)^SRelease^N2.06^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.moderate&buff.shuffle.remains>=6^t^N18^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^S(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=40^t^N19^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Scooldown.keg_smash.remains>=gcd^t^t^SSpecialization^N268^t^^" )
  
  Hekili.Default( "@Brewmaster, AOE", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Brewmaster,~`AOE^SRelease^N2.13^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10^t^N2^T^SEnabled^B^SName^SElusive~`Brew^SRelease^N2.06^SAbility^Selusive_brew^SScript^Sbuff.elusive_brew_stacks.react=15&buff.elusive_brew_activated.down^t^N3^T^SRelease^N2.06^SAbility^Sguard^SName^SGuard^SEnabled^B^t^N4^T^SEnabled^B^SName^SBreath~`of~`Fire^SRelease^N2.06^SAbility^Sbreath_of_fire^SScript^Schi.current>=3&buff.shuffle.remains>=6&dot.breath_of_fire.remains<=gcd^t^N5^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=4^t^N6^T^SEnabled^B^SName^SRushing~`Jade~`Wind^SRelease^N2.06^SAbility^Srushing_jade_wind^SScript^Schi.max-chi.current>=1&talent.rushing_jade_wind.enabled^t^N7^T^SEnabled^B^SName^SPurifying~`Brew^SRelease^N2.06^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&stagger.heavy^t^N8^T^SRelease^N2.06^SAbility^Sguard^SName^SGuard~`(1)^SEnabled^B^t^N9^T^SEnabled^B^SName^SKeg~`Smash^SRelease^N2.06^SAbility^Skeg_smash^SScript^Schi.max-chi.current>=2&!buff.serenity.up^t^N10^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SScript^Stalent.chi_burst.enabled&energy.time_to_max>3^t^N11^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SScript^Stalent.chi_wave.enabled&energy.time_to_max>3^t^N12^T^SEnabled^B^SName^SZen~`Sphere^SArgs^Scycle_targets=1^SRelease^N2.06^SAbility^Szen_sphere^SScript^Stalent.zen_sphere.enabled&!dot.zen_sphere.ticking^t^N13^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Stalent.rushing_jade_wind.enabled&buff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^t^N14^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Stalent.rushing_jade_wind.enabled&buff.serenity.up^t^N15^T^SEnabled^B^SName^SBlackout~`Kick~`(2)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^Stalent.rushing_jade_wind.enabled&chi.current>=4^t^N16^T^SEnabled^B^SName^SExpel~`Harm^SRelease^N2.06^SAbility^Sexpel_harm^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=40^t^N17^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^Schi.max-chi.current>=1&!talent.rushing_jade_wind.enabled^t^N18^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Stalent.rushing_jade_wind.enabled&chi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&cooldown.expel_harm.remains>=gcd^t^N19^T^SEnabled^B^SName^SPurifying~`Brew~`(1)^SRelease^N2.06^SAbility^Spurifying_brew^SScript^Stoggle.mitigation&!talent.chi_explosion.enabled&talent.rushing_jade_wind.enabled&stagger.moderate&buff.shuffle.remains>=6^t^N20^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SAbility^Stiger_palm^SScript^Stalent.rushing_jade_wind.enabled&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=40^t^N21^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SScript^Stalent.rushing_jade_wind.enabled&cooldown.keg_smash.remains>=gcd^t^N22^T^SEnabled^B^SName^STiger~`Palm^SAbility^Stiger_palm^SRelease^N2.06^SScript^Scooldown.keg_smash.remains>=gcd^t^t^SSpecialization^N268^t^^" )
  
  Hekili.Default( "@Brewmaster, Cooldowns", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Brewmaster,~`Cooldowns^SRelease^N2.13^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SName^SBlood~`Fury^SRelease^N2.06^SAbility^Sblood_fury^SScript^Senergy.current<=40^t^N2^T^SEnabled^B^SName^SBerserking^SRelease^N2.06^SAbility^Sberserking^SScript^Senergy.current<=40^t^N3^T^SEnabled^B^SName^SArcane~`Torrent^SRelease^N2.06^SAbility^Sarcane_torrent^SScript^Senergy.current<=40^t^N4^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10^t^N5^T^SEnabled^B^SName^SInvoke~`Xuen,~`the~`White~`Tiger^SRelease^N2.06^SAbility^Sinvoke_xuen^SScript^Stalent.invoke_xuen.enabled^t^N6^T^SEnabled^B^SName^SSerenity^SRelease^N2.06^SAbility^Sserenity^SScript^Stalent.serenity.enabled&energy.current<=40^t^t^SScript^S^t^^" )
  
  Hekili.Default( "@Brewmaster, All", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Brewmaster,~`All^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SScript^Stalent.chi_brew.enabled&chi.max-chi>=2&buff.elusive_brew_stacks.stack<=10^SAbility^Schi_brew^t^t^SSpecialization^N268^t^^" )
  
  Hekili.Default( "@Brewmaster, Mitigation", "actionLists", 2.20, "^1^T^SEnabled^B^SName^S@Brewmaster,~`Mitigation^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SDampen~`Harm^SRelease^N2.06^SScript^Stime<2^SAbility^Sdampen_harm^t^N2^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10^SAbility^Schi_brew^t^N3^T^SEnabled^B^SName^SDiffuse~`Magic^SRelease^N2.06^SScript^Sincoming_damage_1500ms>0&buff.fortifying_brew.down^SAbility^Sdiffuse_magic^t^N4^T^SEnabled^B^SName^SDampen~`Harm~`(1)^SRelease^N2.06^SScript^Sincoming_damage_1500ms>0&buff.fortifying_brew.down&buff.elusive_brew_activated.down^SAbility^Sdampen_harm^t^N5^T^SEnabled^B^SName^SFortifying~`Brew^SRelease^N2.06^SScript^Sincoming_damage_1500ms>(0.2*health.max)&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down^SAbility^Sfortifying_brew^t^N6^T^SEnabled^B^SName^SElusive~`Brew^SRelease^N2.06^SScript^Sbuff.elusive_brew_stacks.react>=9&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down^SAbility^Selusive_brew^t^t^SSpecialization^N268^t^^" )
  

  Hekili.Default( "@Monk, Buffs", "actionLists", 2.20, "^1^T^SEnabled^B^SName^SMonk,~`Buffs^SRelease^N2.06^SSpecialization^N0^SActions^T^N1^T^SEnabled^B^SName^SLegacy~`of~`the~`White~`Tiger^SRelease^N2.06^SAbility^Slegacy_of_the_white_tiger^SScript^S!buff.str_agi_int.up|!buff.critical_strike.up^t^t^SScript^S^t^^" )
  
  Hekili.Default( "@Monk, Interrupts", "actionLists", 2.13, "^1^T^SEnabled^B^SName^SMonk,~`Interrupts^SRelease^N2.06^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SSpear~`Hand~`Strike^SRelease^N2.06^SScript^Starget.casting^SAbility^Sspear_hand_strike^t^t^SSpecialization^N0^t^^" )
  
  Hekili.Default( "@Mistweaver, Crane", "actionLists", 2.20, "^1^T^SEnabled^B^SName^SMistweaver,~`Crane~`Stance^SRelease^N2.06^SScript^S^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns^SRelease^N2.06^SName^SInvoke~`Xuen^SAbility^Sinvoke_xuen^SCaption^S^t^N2^T^SEnabled^B^SName^SBreath~`of~`the~`Serpent^SRelease^N2.06^SAbility^Sbreath_of_the_serpent^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SName^SSurging~`Mist^SRelease^N2.06^SCaption^S^SScript^S(health.pct<100|group)&buff.vital_mists.stack=5^SAbility^Ssurging_mist^t^N4^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.mana_tea_stacks.stacks<=19^t^N5^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SScript^Sbuff.tiger_power.remains<=3^SAbility^Stiger_palm^t^N6^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SRelease^N2.06^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^t^N7^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SScript^Sbuff.cranes_zeal.down^SAbility^Sblackout_kick^t^N8^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SCaption^S^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1^t^N9^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_wave^t^N10^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_burst^t^N11^T^SEnabled^B^SScript^S^SRelease^N2.06^SAbility^Szen_sphere^SName^SZen~`Sphere^SCaption^S^t^N12^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SScript^S((!group&chi.current>=3)|chi.current>=4)&buff.combo_breaker_ce.react^SAbility^Schi_explosion^t^N13^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^t^N14^T^SEnabled^B^SName^SChi~`Explosion~`(1)^SRelease^N2.06^SAbility^Schi_explosion^SScript^Schi.current>=4|(!group&chi.current>=3)^t^N15^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^S!talent.rushing_jade_wind.enabled&active_direct_enemies>=3&chi.current<chi.max^t^N16^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max^t^N17^T^SEnabled^B^SName^SBlackout~`Kick~`(Filler)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S^t^t^SSpecialization^N270^t^^" )
  
  
  Hekili.Default( "@Windwalker, Primary", "displays", 2.20, "^1^T^SPrimary~`Icon~`Size^N50^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpecialization^N269^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Monk,~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^S^t^N2^T^SEnabled^B^SAction~`List^S@Windwalker,~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SAction~`List^S@Monk,~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N4^T^SEnabled^B^SAction~`List^S@Windwalker,~`Single~`Target^SName^SSingle~`Target^SRelease^N2.06^SScript^Ssingle|(cleave&active_enemies<=3)^t^N5^T^SEnabled^B^SAction~`List^S@Windwalker,~`AOE^SName^SAOE^SRelease^N2.06^SScript^Saoe|(cleave&active_direct_enemies>3)^t^t^SScript^S^SIcons~`Shown^N5^STalent~`Group^N0^SFont^SArial~`Narrow^Sy^N-225^Sx^F-6333187512860670^f-46^SName^S@Windwalker,~`Primary^SPvP~`Visibility^Salways^SPrimary~`Caption^Sdefault^SRelease^N2.13^SAction~`Captions^B^SEnabled^B^t^^" )
	
	Hekili.Default( "@Windwalker, AOE", "displays", 2.13, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpecialization^N269^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Windwalker,~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^S@Windwalker,~`AOE^SName^SAOE^SRelease^N2.06^SScript^S^t^t^SScript^S^SEnabled^B^Sx^F-5746782743035898^f-47^SPrimary~`Caption^Sdefault^Sy^F-6421148443082750^f-45^STalent~`Group^N0^SName^S@Windwalker,~`AOE^SPvP~`Visibility^Salways^SRelease^N2.13^SFont^SArial~`Narrow^SAction~`Captions^B^SIcons~`Shown^N4^t^^" )
  
  
  Hekili.Default( "@Brewmaster, Primary", "displays", 2.20, "^1^T^SPrimary~`Icon~`Size^N50^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpecialization^N268^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Monk,~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^S@Monk,~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^S@Brewmaster,~`All^SName^SAll^SRelease^N2.06^SScript^S^t^N4^T^SEnabled^B^SAction~`List^S@Brewmaster,~`Mitigation^SName^SMitigation^SRelease^N2.06^SScript^Stoggle.mitigation^t^N5^T^SEnabled^B^SAction~`List^S@Brewmaster,~`Cooldowns^SName^SCooldowns^SRelease^N2.06^SScript^Stoggle.cooldowns^t^N6^T^SEnabled^B^SAction~`List^S@Brewmaster,~`Single~`Target^SName^SSingle~`Target^SRelease^N2.06^SScript^Ssingle|(cleave&active_enemies<3)^t^N7^T^SEnabled^B^SAction~`List^S@Brewmaster,~`AOE^SName^SAOE^SRelease^N2.06^SScript^Saoe|(cleave&active_enemies>2)^t^t^SScript^S^SMaximum~`Time^N30^SIcons~`Shown^N5^SPrimary~`Caption^Sdefault^Sy^N-225^STalent~`Group^N0^SName^S@Brewmaster,~`Primary^SPvP~`Visibility^Salways^SRelease^N2.13^Sx^N-90^SAction~`Captions^B^SFont^SArial~`Narrow^t^^" )
  
  Hekili.Default( "@Brewmaster, AOE", "displays", 2.20, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpecialization^N268^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Brewmaster,~`All^SName^SAll^SRelease^N2.06^SScript^S^t^N2^T^SEnabled^B^SAction~`List^S@Brewmaster,~`Mitigation^SName^SMitigation^SRelease^N2.06^SScript^Stoggle.mitigation^t^N3^T^SEnabled^B^SAction~`List^S@Brewmaster,~`Cooldowns^SName^SCooldowns^SRelease^N2.11^SScript^Stoggle.cooldowns^t^N4^T^SEnabled^B^SAction~`List^S@Brewmaster,~`AOE^SName^SAOE^SRelease^N2.06^SScript^S^t^t^SScript^S^STalent~`Group^N0^SIcons~`Shown^N4^Sx^N-40^Sy^N-182.5^SFont^SArial~`Narrow^SName^S@Brewmaster,~`AOE^SPvP~`Visibility^Salways^SRelease^N2.13^SPrimary~`Caption^Stargets^SAction~`Captions^B^SEnabled^B^t^^" )
  
  Hekili.Default( "@Mistweaver, Primary", "displays", 2.20, "^1^T^SPrimary~`Icon~`Size^N50^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SVital~`Mists^SSpecialization^N270^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Monk,~`Buffs^SName^SBuffs^SRelease^N2.06^SScript^S^t^N2^T^SEnabled^B^SAction~`List^S@Monk,~`Interrupts^SName^SInterrupts^SRelease^N2.06^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^S@Mistweaver,~`Crane^SName^SCrane~`Stance^SRelease^N2.06^SScript^S^t^t^SScript^Sstance.spirited_crane^SIcons~`Shown^N5^STalent~`Group^N0^SFont^SArial~`Narrow^Sy^N-225^Sx^N-90^SName^SMistweaver,~`Primary^SPvP~`Visibility^Salways^SRelease^N2.06^SPrimary~`Caption^Sbuff^SAction~`Captions^B^SEnabled^B^t^^" )
	
	
end