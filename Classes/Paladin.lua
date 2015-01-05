-- Paladin.lua
-- August 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook

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

local RegisterEvent = ns.RegisterEvent
local storeDefault = ns.storeDefault


-- TODO: PUT LAST_JUDGMENT_TARGET BACK IN!

-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'PALADIN') then

  ns.initializeClassModule = function ()

    setClass( 'PALADIN' )
    
    -- addResource( SPELL_POWER_HEALTH )
    addResource( 'mana', true )
    addResource( 'holy_power' )

    addTalent( 'speed_of_light', 85499 )
    addTalent( 'long_arm_of_the_law', 87172 )
    addTalent( 'pursuit_of_justice', 26023 )
    addTalent( 'fist_of_justice', 105593 )
    addTalent( 'repentance', 200066 )
    addTalent( 'blinding_light', 115750 )
    addTalent( 'selfless_healer', 85804 )
    addTalent( 'eternal_flame', 114163 )
    addTalent( 'sacred_shield', 20925 )
    addTalent( 'hand_of_purity', 114039 )
    addTalent( 'unbreakable_spirit', 114154 )
    addTalent( 'clemency', 105622 )
    addTalent( 'holy_avenger', 105809 )
    addTalent( 'sanctified_wrath', 53376 )
    addTalent( 'divine_purpose', 86172 )
    addTalent( 'holy_prism', 114165 )
    addTalent( 'lights_hammer', 114158 )
    addTalent( 'execution_sentence', 114157 )
    addTalent( 'empowered_seals', 152263 )
    addTalent( 'seraphim', 152262 )
    addTalent( 'final_verdict', 157048 )

    -- Glyphs.
    addGlyph( 'ardent_defender', 159548 )
    addGlyph( 'avenging_wrath', 54927 )
    addGlyph( 'beacon_of_light', 63218 )
    addGlyph( 'bladed_judgment', 115934 )
    addGlyph( 'blessed_life', 54943 )
    addGlyph( 'burden_of_guilt', 54931 )
    addGlyph( 'consecration', 54928 )
    addGlyph( 'contemplation', 125043 )
    addGlyph( 'dazing_shield', 56414 )
    addGlyph( 'denounce', 56420 )
    addGlyph( 'devotion_aura', 146955 )
    addGlyph( 'divine_protection', 54924 )
    addGlyph( 'divine_shield', 146956 )
    addGlyph( 'divine_storm', 63220 )
    addGlyph( 'divine_wrath', 159572 )
    addGlyph( 'divinity', 54939 )
    addGlyph( 'double_jeopardy', 54992 )
    addGlyph( 'final_wrath', 54935 )
    addGlyph( 'fire_from_the_heavens', 57954 )
    addGlyph( 'flash_of_light', 57955 )
    addGlyph( 'focused_shield', 54930 )
    addGlyph( 'focused_wrath', 115738 )
    addGlyph( 'hammer_of_the_righteous', 63219 )
    addGlyph( 'hand_of_freedom', 159579 )
    addGlyph( 'hand_of_sacrifice', 146957 )
    addGlyph( 'harsh_words', 54938 )
    addGlyph( 'holy_shock', 63224 )
    addGlyph( 'holy_wrath', 54923 )
    addGlyph( 'illumination', 54937 )
    addGlyph( 'immediate_truth', 56416 )
    addGlyph( 'inquisition', 63225 )
    addGlyph( 'judgment', 159592 )
    addGlyph( 'light_of_dawn', 54940 )
    addGlyph( 'mass_exorcism', 122028 )
    addGlyph( 'merciful_wrath', 162604 )
    addGlyph( 'pillar_of_light', 146959 )
    addGlyph( 'protector_of_the_innocent', 93466 )
    addGlyph( 'righteous_retreat', 115933 )
    addGlyph( 'seal_of_blood', 57947 )
    addGlyph( 'templars_verdict', 54926 )
    addGlyph( 'alabaster_shield', 63222 )
    addGlyph( 'battle_healer', 119477 )
    addGlyph( 'consecrator', 159557 )
    addGlyph( 'exorcist', 146958 )
    addGlyph( 'falling_avenger', 115931 )
    addGlyph( 'liberator', 159573 )
    addGlyph( 'luminous_charger', 89401 )
    addGlyph( 'mounted_king', 57958 )
    addGlyph( 'winged_vengeance', 57979 )
    addGlyph( 'word_of_glory', 54936 )
    
    -- Player Buffs.
    addAura( 'avenging_wrath', 31884 )
    addAura( 'blazing_contempt', 166831 )
    addAura( 'blessing_of_kings', 20217 )
    addAura( 'blessing_of_might', 19740 )
    addAura( 'divine_crusader', 144595 )
    addAura( 'divine_protection', 498 )
    addAura( 'divine_purpose', 90174 )
    addAura( 'divine_shield', 642 )
    addAura( 'execution_sentence', 114157 )
    addAura( 'final_verdict', 157048 )
    addAura( 'hand_of_freedom', 1044 )
    addAura( 'hand_of_protection', 1022 )
    addAura( 'hand_of_sacrifice', 6940 )
    addAura( 'holy_avenger', 105809 )
    addAura( 'liadrins_righteousness', 156989, 'duration', 20  )
    addAura( 'maraads_truth', 156990, 'duration', 20  )
    addAura( 'righteous_fury', 25780 )
    addAura( 'seal_of_command', 105361 )
    addAura( 'seal_of_insight', 20165 )
    addAura( 'selfless_healer', 114250 )
    addAura( 'seraphim', 152262 )
    addAura( 'turalyons_justice', 156987, 'duration', 20 )
    addAura( 'uthers_insight', 156988, 'duration', 20 )

    -- Perks.
    addPerk( 'empowered_divine_storm', 174718 )
    addPerk( 'empowered_hammer_of_wrath', 157496 )
    addPerk( 'enhanced_hand_of_sacrifice', 157493 )
    addPerk( 'improved_forbearance', 157482 )
    
    -- Stances.
    addStance( 'truth', 'protection', 1, 'retribution', 1 )
    addStance( 'righteousness', 'protection', 2, 'retribution', 2 )
    addStance( 'justice', 'retribution', 3 )
    addStance( 'insight', 'protection', 3, 'retribution', 4 )
    
    -- Pick an instant cast ability for checking the GCD.
    setGCD( 'blessing_of_kings' )

    -- Gear Sets
    addGearSet( 'tier17', 115565, 115566, 115567, 115568, 115569 )


    -- Seals are stances.
    state.seal = state.stance
    
    
    RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
      
      if unit == 'player' and spell == class.abilities[ 'judgment' ].name then
        state.last_judgment_target = UnitGUID( 'target' )
      end
      
    end )

    
    addAbility( 'avenging_wrath', 
      {
        id = 31884,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 120
      } )
    
    addHandler( 'avenging_wrath', function ()
      applyBuff( 'avenging_wrath', 20 )
    end )

    
    addAbility( 'blessing_of_kings',
      {
        id = 20217,
        spend = 0.05,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )
    
    addHandler( 'blessing_of_kings', function ()
      if buff.blessing_of_might.mine then
        removeBuff( 'blessing_of_might' )
        removeBuff( 'mastery' )
      end
      applyBuff( 'blessing_of_kings', 3600 )
      applyBuff( 'str_agi_int', 3600 )
    end )
      
      
    addAbility( 'blessing_of_might',
      {
        id = 19740,
        spend = 0.05,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )

    addHandler( 'blessing_of_might', function ()
      if buff.blessing_of_kings.mine then
        removeBuff( 'blessing_of_kings' )
        removeBuff( 'str_agi_int' )
      end
      applyBuff( 'blessing_of_might', 3600 )
      applyBuff( 'mastery', 3600 )
    end )
      
    
    addAbility( 'crusader_strike',
      {
        id = 35395,
        spend = 0.10,
        cast = 0,
        gcdType = 'melee',
        cooldown = 4.5
      } )
    
    modifyAbility( 'crusader_strike', 'cooldown', function( x )
      return x * haste
    end )
      
    addHandler( 'crusader_strike', function ()
      gain( buff.holy_avenger.up and 3 or 1, 'holy_power' )
    end )
    
    addAbility( 'divine_storm',
      {
        id = 53385,
        spend = function()
          if buff.divine_purpose.up then return 0, 'holy_power' end
          return 3, 'holy_power'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0,
        hostile = true
      } )

    addHandler( 'divine_storm', function ()
      removeBuff( 'divine_crusader' )
      removeBuff( 'divine_purpose' )
      spend( 3, 'holy_power' )
    end )

    addAbility( 'execution_sentence',
      {
        id = 114157,
        spend = 0.128,
        cast = 0,
        gcdType = 'spell', 
        cooldown = 60,
        known = function() return talent.execution_sentence.enabled end,
        hostile = true
      } )
    
    addHandler( 'execution_sentence', function ()
      applyDebuff( 'target', 'execution_sentence', 10 )
    end )
    
    modifyAbility( 'execution_sentence', 'cooldown', function ( x )
      if not talent.execution_sentence.enabled then return 999 end
      return x
    end )
    

    addAbility( 'exorcism',
      {
        id = 879,
        known = 879,
        spend = 0.04,
        cast = 0,
        gcdType = 'spell',
        cooldown = 15,
        hostile = true
      }, 122032 )

    modifyAbility( 'exorcism', 'cooldown', function( x )
      return x * haste
    end )
    
    modifyAbility( 'exorcism', 'id', function ( x )
      if glyph.mass_exorcism.enabled then return 122032 end
      return x
    end )

    addHandler( 'exorcism', function ()
      if buff.blazing_contempt.up then
        gain( 3, 'holy_power' )
        removeBuff( 'blazing_contempt' )
      else
        gain( buff.holy_avenger.up and 3 or 1, 'holy_power' )
      end
    end )	
    

    addAbility( 'final_verdict',
      {
        id = 157048,
        spend = function()
          if buff.divine_purpose.up then return 0, 'holy_power' end
          return 3, 'holy_power'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        known = function() return talent.final_verdict.enabled end,
        hostile = true
      } )

    addHandler( 'final_verdict', function()
      applyBuff( 'final_verdict', 30 )
      removeBuff( 'divine_purpose' )
    end )
    
    modifyAbility( 'final_verdict', 'cooldown', function ( x )
      if not talent.final_verdict.enabled then return 999 end
      return x
    end )

    
    addAbility( 'hammer_of_the_righteous',
      {
        id = 53595,
        spend = 0.03,
        cast = 0,
        gcdType = 'melee',
        cooldown = 4.5,
        hostile = true
      } )	
    
    modifyAbility( 'hammer_of_the_righteous', 'cooldown', function( x )
      return x * haste
    end )
    
    addHandler( 'hammer_of_the_righteous', function ()
      gain( buff.holy_avenger.up and 3 or 1, 'holy_power' )
    end )
    
    
    addAbility( 'hammer_of_wrath',
      {
        id = 24275,
        spend = 0.03,
        cast = 0,
        gcdType = 'melee',
        cooldown = 6,
        usable = function() return ( target.health_pct <= ( perk.empowered_hammer_of_wrath.enabled and 35 or 20 ) ) or buff.avenging_wrath.up or IsUsableSpell( class.abilities[ 'hammer_of_wrath' ].name ) end,
        hostile = true
      } )

    modifyAbility( 'hammer_of_wrath', 'cooldown', function( x )
      if talent.sanctified_wrath.enabled then
        x = x / 2
      end
      return x * haste
    end )
    
    addHandler( 'hammer_of_wrath', function ()
      if set_bonus.tier17_4pc==1 then applyBuff( "blazing_contempt", 20 ) end
      gain( buff.holy_avenger.up and 3 or 1, 'holy_power' )
    end )
    
    
    addAbility( 'holy_avenger',
      {
        id = 105809,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 120
      } )
      
    addHandler( 'holy_avenger', function ()
      applyBuff( 'holy_avenger', 18 )
    end )
    
    modifyAbility( 'holy_avenger', 'cooldown', function( x )
      if not talent.holy_avenger.enabled then return 999 end
      return x
    end )
    
    
    addAbility( 'holy_prism',
      {
        id = 114165,
        known = function() return talent.holy_prism.enabled end,
        spend = 0.17,
        cast = 0,
        gcdType = 'spell',
        cooldown = 20,
        hostile = true
      } )
    
    modifyAbility( 'holy_prism', 'cooldown', function( x )
      if not talent.holy_prism.enabled then return 999 end
      return x
    end )
    

    addAbility( 'judgment',
      {
        id = 20271,
        spend = 0.12,
        cast = 0,
        gcdType = 'spell',
        cooldown = 6,
        hostile = true
      } )
    
    modifyAbility( 'judgment', 'cooldown', function( x )
      return x * haste
    end )
    
    addHandler( 'judgment', function ()
      gain( buff.holy_avenger.up and 3 or 1, 'holy_power' )
      if talent.empowered_seals.enabled then
        if seal.justice then applyBuff( 'turalyons_justice', 20 )
        elseif seal.insight then applyBuff( 'uthers_insight', 20 )
        elseif seal.righteousness then applyBuff( 'liadrins_righteousness', 20 )
        elseif seal.truth then applyBuff( 'maraads_truth', 20 )
        end
      end
    end )
    
    
    addAbility( 'lights_hammer',
      {
        id = 114158,
        known = function() return talent.lights_hammer.enabled end,
        spend = 0.519,
        cast = 0,
        gcdType = 'spell',
        cooldown = 60,
        hostile = true
      } )
    
    modifyAbility( 'lights_hammer', 'cooldown', function( x )
      if not talent.lights_hammer.enabled then return 999 end
      return x
    end )

    
    addAbility( 'rebuke',
      {
        id = 96231,
        spend =  0.117,
        cast = 0,
        gcdType = 'off',
        cooldown = 15,
        hostile = true
      } )
    
    addHandler( 'rebuke', function ()
      interrupt()
    end )
    
    
    addAbility( 'seal_of_righteousness',
      {
        id = 20154,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        usable = function() return not seal.righteousness end
      } )
    
    addHandler( 'seal_of_righteousness', function ()
      setStance( 'righteousness' )
    end )
    
    
    addAbility( 'seal_of_truth',
      {
        id = 31801,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        known = 105361,
        usable = function() return not seal.truth end
      } )

    addHandler( 'seal_of_truth', function ()
      setStance( 'truth' )
    end )
      
    
    addAbility( 'seraphim',
      {
        id = 152262,
        known = function() return talent.seraphim.enabled end,
        spend = 5,
        spend_type = 'holy_power',
        cast = 0,
        gcdType = 'spell',
        cooldown = 30,
      } )
    
    addHandler( 'seraphim', function ()
      applyBuff( 'seraphim', 15 )
    end )
    
    modifyAbility( 'seraphim', 'cooldown', function ( x )
      if not talent.seraphim.enabled then return 999 end
      return x
    end )
    
    
    addAbility( 'templars_verdict',
      {
        id = 85256,
        spend = function()
          if buff.divine_purpose.up then return 0, 'holy_power' end
          return 3, 'holy_power'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        known = function() return not talent.final_verdict.enabled end,
        hostile = true
      } )
    
    addHandler( 'templars_verdict', function ()
      removeBuff( 'divine_purpose' )
    end )
    
    
    storeDefault( 'Ret: Single Target', 'actionLists', 2.20, "^1^T^SEnabled^B^SName^SRet:~`Single~`Target^SRelease^N2.25^SSpecialization^N70^SActions^T^N1^T^SEnabled^B^SName^SJudgment^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&time<2^t^N2^T^SEnabled^B^SAbility^Sexecution_sentence^SName^SExecution~`Sentence^SRelease^N2.25^t^N3^T^SEnabled^B^SAbility^Slights_hammer^SName^SLight's~`Hammer^SRelease^N2.25^t^N4^T^SEnabled^B^SName^SDivine~`Storm^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&holy_power.current=5&buff.final_verdict.up^t^N5^T^SEnabled^B^SName^SDivine~`Storm~`(1)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&holy_power.current=5&active_enemies=2&!talent.final_verdict.enabled^t^N6^T^SEnabled^B^SName^SDivine~`Storm~`(2)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current=5&active_enemies=2&buff.final_verdict.up^t^N7^T^SEnabled^B^SName^SDivine~`Storm~`(3)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&holy_power.current=5&(talent.seraphim.enabled&cooldown.seraphim.remains<gcd*4)^t^N8^T^SEnabled^B^SName^STemplar's~`Verdict^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sholy_power.current=5|buff.holy_avenger.up&holy_power.current>=3&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*4)^t^N9^T^SEnabled^B^SName^STemplar's~`Verdict~`(1)^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sbuff.divine_purpose.up&buff.divine_purpose.remains<3^t^N10^T^SEnabled^B^SName^SDivine~`Storm~`(4)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&buff.divine_crusader.remains<3&!talent.final_verdict.enabled^t^N11^T^SEnabled^B^SName^SFinal~`Verdict^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sholy_power.current=5|buff.holy_avenger.up&holy_power.current>=3^t^N12^T^SEnabled^B^SName^SFinal~`Verdict~`(1)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.divine_purpose.up&buff.divine_purpose.remains<3^t^N13^T^SEnabled^B^SAbility^Shammer_of_wrath^SName^SHammer~`of~`Wrath^SRelease^N2.25^t^N14^T^SEnabled^B^SName^SJudgment~`(1)^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&seal.truth&buff.maraads_truth.remains<cooldown.judgment.duration^t^N15^T^SEnabled^B^SName^SJudgment~`(2)^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&seal.righteousness&buff.liadrins_righteousness.remains<cooldown.judgment.duration^t^N16^T^SEnabled^B^SName^SExorcism^SRelease^N2.25^SAbility^Sexorcism^SScript^Sbuff.blazing_contempt.up&holy_power.current<=2&buff.holy_avenger.down^t^N17^T^SEnabled^B^SName^SSeal~`of~`Truth^SRelease^N2.25^SAbility^Sseal_of_truth^SScript^Stalent.empowered_seals.enabled&buff.maraads_truth.down^t^N18^T^SEnabled^B^SName^SSeal~`of~`Righteousness^SRelease^N2.25^SAbility^Sseal_of_righteousness^SScript^Stalent.empowered_seals.enabled&buff.liadrins_righteousness.down&!buff.avenging_wrath.up&!buff.bloodlust.up^t^N19^T^SEnabled^B^SName^SDivine~`Storm~`(5)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&buff.final_verdict.up&(buff.avenging_wrath.up|target.health.pct<35)^t^N20^T^SEnabled^B^SName^SDivine~`Storm~`(6)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sactive_enemies=2&buff.final_verdict.up&(buff.avenging_wrath.up|target.health.pct<35)^t^N21^T^SEnabled^B^SName^SFinal~`Verdict~`(2)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.avenging_wrath.up|target.health.pct<35^t^N22^T^SEnabled^B^SName^STemplar's~`Verdict~`(2)^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sbuff.avenging_wrath.up|target.health.pct<35&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*5)^t^N23^T^SEnabled^B^SName^SCrusader~`Strike^SRelease^N2.25^SAbility^Scrusader_strike^SScript^Sholy_power.current<5^t^N24^T^SEnabled^B^SName^SDivine~`Storm~`(7)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&(buff.avenging_wrath.up|target.health.pct<35)&!talent.final_verdict.enabled^t^N25^T^SEnabled^B^SName^SJudgment~`(3)^SArgs^Scycle_targets=1^SRelease^N2.25^SAbility^Sjudgment^SScript^Slast_judgment_target!=target.unit&glyph.double_jeopardy.enabled&holy_power.current<5^t^N26^T^SEnabled^B^SName^SExorcism~`(1)^SRelease^N2.25^SAbility^Sexorcism^SScript^Sglyph.mass_exorcism.enabled&active_enemies>=2&holy_power.current<5&!glyph.double_jeopardy.enabled^t^N27^T^SEnabled^B^SName^SJudgment~`(4)^SArgs^S^SRelease^N2.25^SAbility^Sjudgment^SScript^Sholy_power.current<5^t^N28^T^SEnabled^B^SName^SDivine~`Storm~`(8)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&buff.final_verdict.up^t^N29^T^SEnabled^B^SName^SDivine~`Storm~`(9)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sactive_enemies=2&holy_power.current>=4&buff.final_verdict.up^t^N30^T^SEnabled^B^SName^SFinal~`Verdict~`(3)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.divine_purpose.up^t^N31^T^SEnabled^B^SName^SFinal~`Verdict~`(4)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sholy_power.current>=4^t^N32^T^SEnabled^B^SName^SDivine~`Storm~`(10)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&active_enemies=2&holy_power.current>=4&!talent.final_verdict.enabled^t^N33^T^SEnabled^B^SName^STemplar's~`Verdict~`(3)^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sbuff.divine_purpose.up^t^N34^T^SEnabled^B^SName^SDivine~`Storm~`(11)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&!talent.final_verdict.enabled^t^N35^T^SEnabled^B^SName^STemplar's~`Verdict~`(4)^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sholy_power.current>=4&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*5)^t^N36^T^SEnabled^B^SName^SSeal~`of~`Truth~`(1)^SRelease^N2.25^SAbility^Sseal_of_truth^SScript^Stalent.empowered_seals.enabled&buff.maraads_truth.remains<cooldown.judgment.duration^t^N37^T^SEnabled^B^SName^SSeal~`of~`Righteousness~`(1)^SRelease^N2.25^SAbility^Sseal_of_righteousness^SScript^Stalent.empowered_seals.enabled&buff.liadrins_righteousness.remains<cooldown.judgment.duration&!buff.bloodlust.up^t^N38^T^SEnabled^B^SName^SExorcism~`(2)^SRelease^N2.25^SAbility^Sexorcism^SScript^Sholy_power.current<5^t^N39^T^SEnabled^B^SName^SDivine~`Storm~`(12)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sactive_enemies=2&holy_power.current>=3&buff.final_verdict.up^t^N40^T^SEnabled^B^SName^SFinal~`Verdict~`(5)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sholy_power.current>=3^t^N41^T^SEnabled^B^SName^STemplar's~`Verdict~`(5)^SRelease^N2.25^SAbility^Stemplars_verdict^SScript^Sholy_power.current>=3&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*6)^t^N42^T^SEnabled^B^SAbility^Sholy_prism^SName^SHoly~`Prism^SRelease^N2.25^t^t^SScript^S^t^^" )
    
    storeDefault( 'Ret: AOE', 'actionLists', 2.21, "^1^T^SEnabled^B^SSpecialization^N70^SScript^S^SRelease^N2.2^SName^SRet:~`AOE^SActions^T^N1^T^SEnabled^B^SName^SJudgment^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&time<2^t^N2^T^SEnabled^B^SAbility^Sexecution_sentence^SName^SExecution~`Sentence^SRelease^N2.25^t^N3^T^SEnabled^B^SAbility^Slights_hammer^SName^SLight's~`Hammer^SRelease^N2.25^t^N4^T^SEnabled^B^SName^SFinal~`Verdict^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.final_verdict.down&holy_power.current=5^t^N5^T^SEnabled^B^SName^SDivine~`Storm^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&holy_power.current=5&buff.final_verdict.up^t^N6^T^SEnabled^B^SName^SDivine~`Storm~`(1)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current=5&buff.final_verdict.up^t^N7^T^SEnabled^B^SName^SDivine~`Storm~`(2)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&holy_power.current=5&!talent.final_verdict.enabled^t^N8^T^SEnabled^B^SName^SDivine~`Storm~`(3)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current=5&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*4)&!talent.final_verdict.enabled^t^N9^T^SEnabled^B^SAbility^Shammer_of_wrath^SName^SHammer~`of~`Wrath^SRelease^N2.25^t^N10^T^SEnabled^B^SName^SExorcism^SRelease^N2.25^SAbility^Sexorcism^SScript^Sbuff.blazing_contempt.up&holy_power.current<=2&buff.holy_avenger.down^t^N11^T^SEnabled^B^SName^SJudgment~`(1)^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&seal.righteousness&buff.liadrins_righteousness.remains<=5^t^N12^T^SEnabled^B^SName^SDivine~`Storm~`(4)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&buff.final_verdict.up&(buff.avenging_wrath.up|target.health.pct<35)^t^N13^T^SEnabled^B^SName^SDivine~`Storm~`(5)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.final_verdict.up&(buff.avenging_wrath.up|target.health.pct<35)^t^N14^T^SEnabled^B^SName^SFinal~`Verdict~`(1)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.final_verdict.down&(buff.avenging_wrath.up|target.health.pct<35)^t^N15^T^SEnabled^B^SName^SDivine~`Storm~`(6)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&(buff.avenging_wrath.up|target.health.pct<35)&!talent.final_verdict.enabled^t^N16^T^SEnabled^B^SName^SDivine~`Storm~`(7)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^S(buff.avenging_wrath.up|target.health.pct<35)&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*5)&!talent.final_verdict.enabled^t^N17^T^SEnabled^B^SName^SHammer~`of~`the~`Righteous^SRelease^N2.25^SAbility^Shammer_of_the_righteous^SScript^Sactive_enemies>=4&holy_power.current<5^t^N18^T^SEnabled^B^SName^SCrusader~`Strike^SRelease^N2.25^SAbility^Scrusader_strike^SScript^Sholy_power.current<5^t^N19^T^SEnabled^B^SName^SDivine~`Storm~`(8)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&buff.final_verdict.up^t^N20^T^SEnabled^B^SName^SDivine~`Storm~`(9)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_purpose.up&buff.final_verdict.up^t^N21^T^SEnabled^B^SName^SDivine~`Storm~`(10)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current>=4&buff.final_verdict.up^t^N22^T^SEnabled^B^SName^SFinal~`Verdict~`(2)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sbuff.divine_purpose.up&buff.final_verdict.down^t^N23^T^SEnabled^B^SName^SFinal~`Verdict~`(3)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sholy_power.current>=4&buff.final_verdict.down^t^N24^T^SEnabled^B^SName^SDivine~`Storm~`(11)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sbuff.divine_crusader.up&!talent.final_verdict.enabled^t^N25^T^SEnabled^B^SName^SDivine~`Storm~`(12)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current>=4&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*5)&!talent.final_verdict.enabled^t^N26^T^SEnabled^B^SName^SExorcism~`(1)^SRelease^N2.25^SAbility^Sexorcism^SScript^Sglyph.mass_exorcism.enabled&holy_power.current<5^t^N27^T^SEnabled^B^SName^SJudgment~`(2)^SArgs^Scycle_targets=1^SRelease^N2.25^SAbility^Sjudgment^SScript^Sglyph.double_jeopardy.enabled&holy_power.current<5^t^N28^T^SEnabled^B^SName^SJudgment~`(3)^SRelease^N2.25^SAbility^Sjudgment^SScript^Sholy_power.current<5^t^N29^T^SEnabled^B^SName^SExorcism~`(2)^SRelease^N2.25^SAbility^Sexorcism^SScript^Sholy_power.current<5^t^N30^T^SEnabled^B^SName^SDivine~`Storm~`(13)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current>=3&(!talent.seraphim.enabled|cooldown.seraphim.remains>gcd*6)&!talent.final_verdict.enabled^t^N31^T^SEnabled^B^SName^SDivine~`Storm~`(14)^SRelease^N2.25^SAbility^Sdivine_storm^SScript^Sholy_power.current>=3&buff.final_verdict.up^t^N32^T^SEnabled^B^SName^SFinal~`Verdict~`(4)^SRelease^N2.25^SAbility^Sfinal_verdict^SScript^Sholy_power.current>=3&buff.final_verdict.down^t^t^SDefault^B^t^^" )
    
    storeDefault( 'Ret: Cooldowns', 'actionLists', 2.20, "^1^T^SEnabled^B^SDefault^B^SSpecialization^N70^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SJudgment^SRelease^N2.25^SAbility^Sjudgment^SScript^Stalent.empowered_seals.enabled&time<2^t^N2^T^SRelease^N2.25^SEnabled^B^SName^SExecution~`Sentence^SAbility^Sexecution_sentence^t^N3^T^SRelease^N2.25^SEnabled^B^SName^SLight's~`Hammer^SAbility^Slights_hammer^t^N4^T^SEnabled^B^SName^SHoly~`Avenger^SArgs^S^SRelease^N2.25^SAbility^Sholy_avenger^SScript^Saction.seraphim.ready&(talent.seraphim.enabled)^t^N5^T^SEnabled^B^SName^SHoly~`Avenger~`(1)^SRelease^N2.25^SAbility^Sholy_avenger^SScript^Sholy_power.current<=2&!talent.seraphim.enabled^t^N6^T^SEnabled^B^SName^SAvenging~`Wrath^SArgs^S^SRelease^N2.25^SAbility^Savenging_wrath^SScript^Saction.seraphim.ready&(talent.seraphim.enabled)^t^N7^T^SEnabled^B^SName^SAvenging~`Wrath~`(1)^SRelease^N2.25^SAbility^Savenging_wrath^SScript^S!talent.seraphim.enabled^t^N8^T^SRelease^N2.25^SEnabled^B^SName^SBlood~`Fury^SAbility^Sblood_fury^t^N9^T^SRelease^N2.25^SEnabled^B^SName^SBerserking^SAbility^Sberserking^t^N10^T^SRelease^N2.25^SEnabled^B^SName^SArcane~`Torrent^SAbility^Sarcane_torrent^t^N11^T^SRelease^N2.25^SEnabled^B^SName^SSeraphim^SAbility^Sseraphim^t^N12^T^SEnabled^B^SName^SWait^SArgs^Ssec=cooldown.seraphim.remains^SRelease^N2.25^SAbility^Swait^SScript^Stalent.seraphim.enabled&cooldown.seraphim.remains>0&cooldown.seraphim.remains<gcd&holy_power.current>=5^t^t^SName^SRet:~`Cooldowns^t^^" )
    
    storeDefault( 'Ret: Interrupts', 'actionLists', 2.21, "^1^T^SEnabled^B^SDefault^B^SSpecialization^N70^SRelease^N2.2^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SRebuke^SRelease^N2.25^SAbility^Srebuke^SScript^Starget.casting^t^t^SName^SRet:~`Interrupts^t^^" )
    
    storeDefault( 'Ret: Buffs', 'actionLists', 2.20, "^1^T^SEnabled^B^SName^S@Retribution,~`Buffs^SRelease^N2.07^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SBlessing~`of~`Might^SRelease^N2.06^SAbility^Sblessing_of_might^SScript^S!buff.mastery.up^t^N2^T^SEnabled^B^SName^SBlessing~`of~`Kings^SRelease^N2.06^SAbility^Sblessing_of_kings^SScript^S!buff.str_agi_int.up&buff.mastery.up&!buff.mastery.mine^t^N3^T^SEnabled^b^SName^SSeal~`of~`Truth^SRelease^N2.06^SAbility^Sseal_of_truth^SScript^Sactive_enemies<2^t^N4^T^SEnabled^b^SName^SSeal~`of~`Righteousness^SRelease^N2.06^SAbility^Sseal_of_righteousness^SScript^Sactive_enemies>=2^t^t^SSpecialization^N70^t^^" )
    
    
    storeDefault( 'Ret: Primary', 'displays', 2.20, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^SUse~`SpellFlash^b^SSpecialization^N70^SSpacing^N7^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SRet:~`Buffs^SName^SBuffs^SRelease^N2.2^SScript^S^t^N2^T^SEnabled^B^SAction~`List^SRet:~`Interrupts^SName^SInterrupts^SRelease^N2.2^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^SRet:~`Cooldowns^SName^SCooldowns^SRelease^N2.2^SScript^Stoggle.cooldowns^t^N4^T^SEnabled^B^SAction~`List^SRet:~`Single~`Target^SName^SSingle^SRelease^N2.2^SScript^Ssingle|(cleave&active_enemies<3)^t^N5^T^SEnabled^B^SAction~`List^SRet:~`AOE^SName^SAOE^SRelease^N2.2^SScript^Saoe|(cleave&active_enemies>=3)^t^t^SScript^S^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SEnabled^B^SIcons~`Shown^N4^SRelease^N2.2^STalent~`Group^N0^Sy^N-220^Sx^N-90^SName^SRet:~`Primary^SPvP~`Visibility^Salways^SPrimary~`Caption^Sdefault^SForce~`Targets^N1^SAction~`Captions^B^SFont^SArial~`Narrow^t^^" )
    
    storeDefault( 'Ret: AOE', 'displays', 2.20, "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^SUse~`SpellFlash^b^SSpecialization^N70^SSpacing^N7^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SRet:~`Cooldowns^SName^SCooldowns^SRelease^N2.2^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^SRet:~`AOE^SName^SAOE^SRelease^N2.2^SScript^S^t^t^SScript^S^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SEnabled^B^SIcons~`Shown^N4^SRelease^N2.2^STalent~`Group^N0^Sy^N-175^Sx^N-90^SName^SRet:~`AOE^SPvP~`Visibility^Salways^SPrimary~`Caption^Stargets^SForce~`Targets^N3^SAction~`Captions^B^SFont^SArial~`Narrow^t^^" )
    
  end
  
end