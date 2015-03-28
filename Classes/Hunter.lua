-- Hunter.lua
-- February 2015

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

-- This table gets loaded only if there's a ported class/specialization
if (select(2, UnitClass('player')) == 'HUNTER') then
	ns.initializeClassModule = function ()
		setClass( 'HUNTER' )

		addResource( 'focus', true )

		addTalent( 'posthaste', 109215 )
		addTalent( 'narrow_escape', 109298 )
		addTalent( 'crouching_tiger_hidden_chimaera', 118675 )

		addTalent( 'binding_shot', 109248 )
		addTalent( 'wyvern_sting', 19386 )
		addTalent( 'intimidation', 19577 )

		addTalent( 'exhilaration', 109304 )
		addTalent( 'iron_hawk', 109260 )
		addTalent( 'spirit_bond', 109212 )

		addTalent( 'steady_focus', 177667 )
		addTalent( 'dire_beast', 120679 )
		addTalent( 'thrill_of_the_hunt', 109306 )

		addTalent( 'a_murder_of_crows', 131894 )
		addTalent( 'blink_strikes', 130392 )
		addTalent( 'stampede', 121818 )

		addTalent( 'glaive_toss', 117050 )
		addTalent( 'powershot', 109259 )
		addTalent( 'barrage', 120360 )

		addTalent( 'exotic_munitions', 162534 )
		addTalent( 'focusing_shot', 152245 )
		addTalent( 'adaptation', 152244 )
		addTalent( 'lone_wolf', 155228 )

		-- Major Glyphs
		addGlyph( 'animal_bond', 20895 )
		addGlyph( 'black_ice', 109263 )
		addGlyph( 'camouflage', 42898 )
		addGlyph( 'chimaera_shot', 119447 )
		addGlyph( 'deterrence', 42903 )
		addGlyph( 'disengage', 42904 )
		addGlyph( 'distracting_shot', 42901 )
		addGlyph( 'enduring_deceit', 104276 )
		addGlyph( 'explosive_trap', 42908 )
		addGlyph( 'freezing_trap', 42905 )
		addGlyph( 'ice_trap', 42906 )
		addGlyph( 'liberation', 132106 )
		addGlyph( 'masters_call', 45733 )
		addGlyph( 'mend_pet', 42915 )
		addGlyph( 'mending', 56833 )
		addGlyph( 'mirrored_blades', 45735 )
		addGlyph( 'misdirection', 56829 )
		addGlyph( 'no_escape', 42910 )
		addGlyph( 'pathfinding', 19560 )
		addGlyph( 'quick_revival', 110821 )
		addGlyph( 'snake_trap', 110822 )
		addGlyph( 'solace', 42917 )
		addGlyph( 'lean_pack', 104270 )
		addGlyph( 'tranquilizing_shot', 45731 )

		-- Minor Glyphs
		addGlyph( 'aspect_of_the_beast', 85683 )
		addGlyph( 'aspect_of_the_cheetah', 45732 )
		addGlyph( 'aspect_of_the_pack', 43355 )
		addGlyph( 'aspects', 42897 )
		addGlyph( 'fetch', 87393 )
		addGlyph( 'fireworks', 43351 )
		addGlyph( 'lesser_proportion', 43350 )
		addGlyph( 'play_dead', 110819 )
		addGlyph( 'revive_pet', 43338 )
		addGlyph( 'stampede', 43356 )
		addGlyph( 'tame_beast', 42912)

		-- Player Buffs / Debuffs
		addAura( 'a_murder_of_crows', 131894, 'duration', 15 )
		addAura( 'aspect_of_the_fox', 172106, 'duration', 6 )
		addAura( 'beastial_wrath', 19574, 'duration', 10 )
		addAura( 'binding_shot', 109248, 'duration', 5 ) 
		addAura( 'black_arrow', 3674, 'duration', 20 )
		addAura( 'camouflage', 51753)
		addAura( 'concussive_shot', 5116, 'duration', 6 )
		addAura( 'deterrence', 148467, 'duration', 5 )
		addAura( 'dire_beast', 120679, 'duration', 15 )
		addAura( 'explosive_shot', 53301, 'duration', 4 )
		addAura( 'explosive_trap', 82939, 'duration', 10 )
		addAura( 'feign_death', 5384, 'duration', 300 )
		addAura( 'focus_fire', 82692, 'duration', 20)
		addAura( 'freezing_trap', 60192, 'duration', 60 )
		addAura( 'frenzy', 19615, 'duration', 30, 'max_stacks', 5 )
		addAura( 'frozen_ammo', 162539, 'duration', 3600 )
		addAura( 'frozen_ammo_debuff', 162546, 'duration', 4 )
		addAura( 'glaive_toss', 117050, 'duration', 3 )
		addAura( 'ice_trap', 13809, 'duration', 60 )
		addAura( 'incendiary_ammo', 162536, 'duration', 3600 )
		addAura( 'intimidation', 19577, 'duration', 3)
		addAura( 'lock_and_load', 168980, 'duration', 15, 'max_stacks', 2)
		addAura( 'lone_wolf', 164273, 'duration', 3600 )
		addAura( 'lone_wolf_ferocity_of_the_raptor', 160200, 'duration', 3600 )
		addAura( 'lone_wolf_fortitude_of_the_bear', 160199, 'duration', 3600 )
		addAura( 'lone_wolf_grace_of_the_cat', 160198, 'duration', 3600 )
		addAura( 'lone_wolf_haste_of_the_hyena', 160203, 'duration', 3600 )
		addAura( 'lone_wolf_power_of_the_primates', 160206, 'duration', 3600 )
		addAura( 'lone_wolf_wisdom_of_the_serpent', 160205, 'duration', 3600 )
		addAura( 'lone_wolf_versatility_of_the_ravager', 172967, 'duration', 3600 )
		addAura( 'lone_wolf_quickness_of_the_dragonhawk', 172968, 'duration', 3600 )
		addAura( 'masters_call', 53271, 'duration', 4 )
		addAura( 'misdirection', 34477, 'duration', 8 )
		addAura( 'narrow_escape', 109298, 'duration', 8 )
		addAura( 'poisoned_ammo', 162537, 'duration', 3600)
		addAura( 'poisoned_ammo_debuff', 162543, 'duration', 16)
		addAura( 'posthaste', 109215, 'duration', 8 )
		addAura( 'serpent_sting', 87935 , 'duration', 15 )
		addAura( 'sniper_training', 168811, 'duration', 3600 )
		addAura( 'spirit_bond', 118694, 'duration', 3600 )
		addAura( 'steady_focus', 177667, 'duration', 10 )
		addAura( 'thrill_of_the_hunt', 34720, 'duration', 15 , 'max_stacks', 3 )
		addAura( 'wyvern_sting', 19386, 'duration', 30 )
		addAura( 't17_4pc_survival', 165545, 'duration', 3 )

		-- Perks
		addPerk( 'improved_focus_fire', 157705 )
		addPerk( 'improved_beast_cleave', 157714 )
		addPerk( 'enhanced_basic_attacks', 157715 )
		addPerk( 'enhanced_camouflage', 157718 )
		addPerk( 'enhanced_aimed_shot', 157724 )
		addPerk( 'improved_focus', 157726 )
		addPerk( 'enhanced_kill_shot', 157707 )
		addPerk( 'empowered_explosive_shot', 157748 )
		addPerk( 'enhanced_traps', 157751 )
		addPerk( 'enhanced_entrapment', 157752 )

		-- Gear Sets
		addGearSet( 'tier17', 115545, 115546, 115547, 115548, 115549)

		-- Pick an instant cast ability for checking the GCD.
		setGCD( 'arcane_shot' )

		addHook( 'onInitialize', function()
			local found, empty = false, nil

			for i = 1, 5 do
				if not empty and Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == nil then
					empty = i
				elseif Hekili.DB.profile[ 'Toggle ' ..i.. ' Name' ] == 'hunter2' then
					found = i
					break
				end
			end

			if not found and empty then
				Hekili.DB.profile[ 'Toggle ' ..empty.. ' Name' ] = 'hunter2' --What is this string for?
				found = empty
			end

			if type( found ) == 'number' then
				Hekili.DB.profile[ 'Toggle_' .. found ] = Hekili.DB.profile[ 'Toggle_' .. found ] == nil and true or Hekili.DB.profile[ 'Toggle_' .. found ]
			end
		end )

		addAbility( 'a_murder_of_crows',
			{
				id = 131894,
				spend = 30,
				cast = 0,
				gcdType = 'spell',
				cooldown = 60
			})

		addHandler( 'a_murder_of_crows', function ()
			applyDebuff('target', 'a_murder_of_crows', 15 )
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'aimed_shot', 
			{
				id = 19434,
				spend = 50,
				cast = 2.5,
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'aimed_shot', 'spend', function ( x )
			if buff.thrill_of_the_hunt.up then
				return x - 20
			end
			return x
		end)

		modifyAbility( 'aimed_shot', 'cast', function ( x )
			return x * haste
		end)

		addHandler( 'aimed_shot' , function()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'arcane_shot', 
			{
				id = 3044,
				spend = 30,
				cast = 0,
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'arcane_shot', 'cost', function ( x )
			if buff.thrill_of_the_hunt.up then
				return x - 20
			end
			return x
		end)

		addHandler( 'arcane_shot', function()
			if spec.survival then 
				applyDebuff( 'target', 'serpent_sting', 15 )
			end
			if talent.thrill_of_the_hunt.enabled then
				removeStack( 'thrill_of_the_hunt' )
			end
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'aspect_of_the_cheetah',
		  {
			id = 5118,
			spend = 0,
			cast = 0,
			gcdType = 'spell',
			cooldown = 0,
			passive = true
		  } )
		
		addHandler( 'aspect_of_the_cheetah', function ()
			applyBuff( 'aspect_of_the_cheetah', 3600 )
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)
	
		addAbility( 'barrage',
			{
				id = 120360,
				spend = 60,
				cast = 3,
				gcdType = 'spell',
				cooldown = 20
			})

		modifyAbility( 'barrage', 'cast', function ( x ) 
			return x * haste
		end)

		addHandler( 'barrage', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'beastial_wrath', 
			{
				id = 19574,
				spend = 0,
				cast = 0,
				gcdType = 'off',
				cooldown = 60
			})

		addHandler( 'beastial_wrath', function ()
			applyBuff( 'beastial_wrath', 10)
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'black_arrow', 
			{
				id = 3674,
				spend = 35,
				cast = 0,
				gcdType = 'spell',
				cooldown = 24
			})

		addHandler( 'black_arrow', function ()
			applyDebuff('target', 'black_arrow', 20)
			if set_bonus.t17_2pc and spec.survival then
				applyBuff( 'lock_and_load', 15, 2 )
				setCooldown( 'explosive_shot', 0 )
			end
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'chimaera_shot',
			{
				id = 53209,
				spend = 35,
				cast = 0,
				gcdType = 'spell',
				cooldown = 9
			})

		addHandler( 'chimaera_shot', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'cobra_shot',
			{
				id = 77767,
				known = function () return level >= 81 and (spec.survival or spec.beast_mastery) end,
				spend = 0,
				cast = 2,
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'cobra_shot', 'cast', function ( x )
			return x * haste
		end)

		addHandler( 'cobra_shot', function ()
			if talent.steady_focus.enabled and state.pre_steady_focus then
				applyBuff( 'steady_focus', 10 )
				state.pre_steady_focus = false
			elseif talent.steady_focus.enabled and not state.pre_steady_focus then
				state.pre_steady_focus = true
			end
			gain( 14, 'focus' )
		end)

		addAbility( 'counter_shot', 
			{
				id = 146362,
				spend = 0,
				cast = 0,
				gcdType = 'off',
				cooldown = 24
			})

		addHandler( 'counter_shot', function ()
			interrupt()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'dire_beast',
			{
				id = 120679,
				spend = 0,
				cast = 0,
				gcdType = 'spell',
				cooldown = 30
			})

		addHandler( 'dire_beast', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'explosive_shot',
			{
				id = 53301,
				spend = 15,
				cast = 0,
				gcdType = 'spell',
				cooldown = 6
			})      

		modifyAbility( 'explosive_shot', 'spend', function ( x )
			if buff.lock_and_load.up then return 0 end
			return x
		end)

		modifyAbility( 'explosive_shot', 'cooldown', function ( x )
			if buff.lock_and_load.up then return 0 end
			return x
		end)

		addHandler( 'explosive_shot', function() 
			applyDebuff( 'target', 'explosive_shot', 4 )
			removeStack( 'lock_and_load' )
			if set_bonus.t17_4pc and spec.survival then
				applyBuff( 't17_4pc_survival', 3 )
			end
		end)

		addAbility( 'explosive_trap', 
			{
				id = 13813,
				spend = 0,
				cast = 0,
				gcdType = 'spell',
				cooldown = 30
			})

		addHandler( 'explosive_trap' ,function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		modifyAbility( 'explosive_trap', 'cooldown' , function ( x )
			if spec.survival then
				return x * 0.66
			end
			return x
		end)

		addAbility( 'focusing_shot',
			{
				id = 152245,
				known = function() return talent.focusing_shot.enabled end,
				spend = 0,
				cast = 3, 
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'focusing_shot', 'id', function ( x )
			if spec.marksmanship then return 163485 end
			return x
		end)

		modifyAbility( 'focusing_shot', 'cooldown', function ( x )
			return x * haste
		end)

		addHandler( 'focusing_shot', function()
			if talent.steady_focus.enabled then
				applyBuff( 'steady_focus', 10 )
			end
			gain( 50, 'focus' )
		end)

		addAbility( 'focus_fire', 
			{
				id = 82692,
				spend = 0,
				cast = 0,
				gcdType = 'spell',
				cooldown = 0
			})

		addHandler( 'focus_fire', function()
			applyBuff('focus_fire', 20)
			removeBuff( 'frenzy' )
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'glaive_toss', 
			{
				id = 117050,
				known = function () return talent.glaive_toss.enabled end,
				spend = 15,
				cast = 0,
				gcdType = 'spell',
				cooldown = 15
			})

		addHandler( 'glaive_toss', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'kill_command', 
			{
				id = 34026,
				spend = 40,
				cast = 0,
				gcdType = 'spell',
				cooldown = 6
			})

		addHandler( 'kill_command', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'kill_shot',
			{
				id = 53351,
				spend = 0,
				cast = 0,
				gcdType = 'spell',
				cooldown = 10
			})

		addHandler( 'kill_shot', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'multishot',
			{
				id = 2643,
				spend = 40,
				cast = 0,
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'multishot', 'spend', function ( x )
			if buff.thrill_of_the_hunt.up then
				x = x - 20
			end
			if buff.bombardment.up then
				x = x - 25
			end
			return max( 0, x )
		end)

		addHandler( 'multishot', function ()
			if spec.beast_mastery then
				applyBuff( 'beast_cleave', 4)
			elseif spec.survival then
				applyDebuff( 'serpent_sting', 15 )
			end
			if talent.thrill_of_the_hunt.enabled then
				removeStack( 'thrill_of_the_hunt' )
			end
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)
	
		addAbility( 'powershot',
		  {
			id = 109259,
			spend = 15,
			cast = 2.25,
			gcdType = 'spell',
			cooldown = 45
		  })

		addHandler( 'powershot', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'rapid_fire', 
			{
				id = 3045,
				spend = 0,
				cast = 0,
				gcdType = 'off',
				cooldown = 120
			})

		addHandler( 'rapid_fire', function ()
			applyBuff( 'rapid_fire', 15)
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'stampede', 
			{
				id = 121818,
				spend = 0,
				cast = 0,
				gcdType = 'spell',
				cooldown = 300
			})

		addHandler( 'stampede', function ()
			if talent.steady_focus.enabled then
				state.pre_steady_focus = false
			end
		end)

		addAbility( 'steady_shot',
			{
				id = 56641,
				known = function () return not (level >= 81 and (spec.survival or spec.beast_mastery)) end,
				spend = 0,
				cast = 2,
				gcdType = 'spell',
				cooldown = 0
			})

		modifyAbility( 'steady_shot', 'cast', function ( x )
			return x * haste
		end)

		addHandler( 'steady_shot', function ()
			if talent.steady_focus.enabled and state.pre_steady_focus then
				applyBuff( 'steady_focus', 10)
				state.pre_steady_focus = false
			elseif talent.steady_focus.enabled and not state.pre_steady_focus then
				state.pre_steady_focus = true
			end
			gain( 14, 'focus' )
		end)
		
	end
end