-- EleShaman.lua
-- Default Elemental Shaman module for Hekili.
-- Hekili of <Turbo Cyborg Ninjas> - Ner'zhul [A]
-- November 2013

local mod = Hekili:NewModule("Elemental Shaman SimC 5.4.1", "Shaman", "Elemental", true, true, true)

-- Spells, just to give readable aliases and to help with future localization.
local ancestral_swiftness 	= GetSpellInfo(16188)
local ascendance 			= GetSpellInfo(114049)
local berserking			= GetSpellInfo(26297)
local blood_fury			= GetSpellInfo(20572)
local bloodlust 			= GetSpellInfo(2825)
local chain_lightning 		= GetSpellInfo(421)
local earth_elemental_totem	= GetSpellInfo(2062)
local earth_shock 			= GetSpellInfo(8042)
local earthquake			= GetSpellInfo(61882)
local elemental_blast 		= GetSpellInfo(117014)
local elemental_mastery 	= GetSpellInfo(16166)
local fire_elemental_totem 	= GetSpellInfo(2894)
local flame_shock 			= GetSpellInfo(8050)
local flametongue_weapon 	= GetSpellInfo(8024)
local heroism 				= GetSpellInfo(32182)
local jade_serpent			= "Potion of the Jade Serpent"
local lava_beam				= GetSpellInfo(114074)
local lava_burst			= GetSpellInfo(51505)
local lifeblood				= GetSpellInfo(121279)
local lightning_bolt 		= GetSpellInfo(403)
local lightning_shield 		= GetSpellInfo(324)
local magma_totem 			= GetSpellInfo(8190)
local searing_totem 		= GetSpellInfo(3599)
local spiritwalkers_grace	= GetSpellInfo(79206)
local stormlash_totem		= GetSpellInfo(120668)
local synapse_springs		= GetSpellInfo(126731)
local thunderstorm			= GetSpellInfo(51490)
local unleash_elements 		= GetSpellInfo(73680)
local wind_shear			= GetSpellInfo(57994)

-- Purely for buffs, cannot actually cast these manually.
local ancient_hysteria		= GetSpellInfo(90355)
local insanity				= GetSpellInfo(95809)
local exhaustion			= GetSpellInfo(57723)
local lava_surge			= GetSpellInfo(77756)
local sated					= GetSpellInfo(57724)
local temporal_displacement	= GetSpellInfo(80354)
local time_warp 			= GetSpellInfo(80353)
local unleash_flame 		= GetSpellInfo(73683)
local unleashed_fury 		= GetSpellInfo(117012)


-- Talents that we may need to check for, but aren't listed above.
local primal_elementalist	= GetSpellInfo(117013) -- 'Primal Elementalist'
local echo_of_the_elements	= GetSpellInfo(108283) -- 'Echo of the Elements'


-- Burst haste CDs.
mod.burstHaste = {}
mod.burstHaste[ancient_hysteria] = 1.30
mod.burstHaste[berserking] = 1.20
mod.burstHaste[bloodlust] = 1.30
mod.burstHaste[elemental_mastery] = 1.30
mod.burstHaste[heroism] = 1.30
mod.burstHaste[time_warp] = 1.30


-- totem indexes
local totem_fire	= 1
local totem_earth	= 2
local totem_water	= 3
local totem_air		= 4


mod:AddAbility( ancestral_swiftness, 16188, 'offGCD', 'talent' )
	mod:AddHandler( ancestral_swiftness, function ( state )
		cast = 0
		state.cooldowns[ancestral_swiftness] = 90
	
		state.pBuffs[ancestral_swiftness].up		= true
		state.pBuffs[ancestral_swiftness].count		= 1
		state.pBuffs[ancestral_swiftness].remains	= 0
	
		return cast
	end )

mod:AddAbility( ascendance, 114049, 'offGCD' )
	mod:AddHandler( ascendance, function ( state )
		cast = 0
	
		state.pBuffs[ascendance].up			= true
		state.pBuffs[ascendance].count		= 1
		state.pBuffs[ascendance].remains	= 15
	
		state.cooldowns[ascendance]			= ttCooldown(114049)
		state.cooldowns[lava_burst]			= 0
	
		return cast
	end )
	
mod:AddAbility( berserking,	26297, 'offGCD', 'racial' )
	mod:AddHandler( berserking, function ( state )
		cast = 0
		state.cooldowns[berserking] = 180

		state.pBuffs[berserking].up			= true
		state.pBuffs[berserking].count 		= 1
		state.pBuffs[berserking].remains	= 10
		RecalculateHaste( state )

		return cast
	end )

mod:AddAbility( blood_fury,	20572, 'offGCD', 'racial' )
	mod:AddHandler( blood_fury, function ( state )
		cast = 0
		state.cooldowns[blood_fury] = 120
	
		return cast
	end )

mod:AddAbility( bloodlust, 2825, 'offGCD', 'bloodlust' )
	mod:AddHandler( bloodlust, function ( state )
		cast = 0
		state.cooldowns[bloodlust] = 300

		if state.pDebuffs[sated].up or state.pDebuffs[exhaustion].up or state.pDebuffs[insanity].up or state.pDebuffs[temporal_displacement].up then
			return cast
		end

		state.pBuffs[bloodlust].up		= true
		state.pBuffs[bloodlust].count 	= 1
		state.pBuffs[bloodlust].remains = 40
		state.pDebuffs[sated].up		= true
		state.pDebuffs[sated].count 	= 1
		state.pDebuffs[sated].remains 	= 600

		RecalculateHaste( state )

		return cast
	end )

mod:AddAbility( chain_lightning, 421 )
	mod:AddHandler( chain_lightning, function ( state, precast )
		cast = 2.5 / state.sHaste
		local hardcast = true
	
		if state.pBuffs[ancestral_swiftness].up and not precast then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
			hardcast = false
		end
	
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast, nil, hardcast
	end )
	
mod:AddAbility( earth_elemental_totem, 2062 )
	mod:AddHandler( earth_elemental_totem, function ( state )
		cast = state.tGCD
		state.cooldowns[earth_elemental_totem] = ttCooldown(2062)
		state.cooldowns[fire_elemental_totem] = 60
	
		state.totems[totem_earth].up		= true
		state.totems[totem_earth].name		= earth_elemental_totem
		state.totems[totem_earth].remains	= 60
	
		return cast
	end )

mod:AddAbility( earth_shock, 8042 )
	mod:AddHandler( earth_shock, function ( state )
		cast = state.sGCD

		state.cooldowns[flame_shock] = 5.0
		state.cooldowns[earth_shock] = 5.0
		
		if state.pBuffs[lightning_shield].up then
			state.pBuffs[lightning_shield].count = 1
			state.pBuffs[lightning_shield].remains = 3600
		end

		return cast
	end )

mod:AddAbility( earthquake, 61882 )
	mod:AddHandler( earthquake, function ( state )
		cast = 2.5 / state.sHaste
		state.cooldowns[earthquake]	= 10.0
		local hardcast = true
	
		if state.pBuffs[ancestral_swiftness].up then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
			hardcast = false
		end
	
		return cast, nil, hardcast
	end )



mod:AddAbility( elemental_blast, 117014, 'talent' )
	mod:AddHandler( elemental_blast, function ( state, precast )
		cast = 2.0 / state.sHaste
		local hardcast = true

		state.cooldowns[elemental_blast] = 12.0
	
		if state.pBuffs[ancestral_swiftness].up and not precast then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
			hardcast = false
		end
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast, nil, hardcast
	end )

mod:AddAbility( elemental_mastery, 16166, 'offGCD', 'talent' )
	mod:AddHandler( elemental_mastery, function ( state )
		cast = 0
		state.cooldowns[elemental_mastery] = 90
	
		state.pBuffs[elemental_mastery].up			= true
		state.pBuffs[elemental_mastery].count 		= 1
		state.pBuffs[elemental_mastery].remains 	= 20
	
		RecalculateHaste( state )
	
		return cast
	end )

mod:AddAbility( fire_elemental_totem, 2894 )
	mod:AddHandler( fire_elemental_totem, function ( state )
		cast = 1.0
		state.cooldowns[fire_elemental_totem] = ttCooldown(2894)
		state.cooldowns[earth_elemental_totem] = 60
	
		state.totems[totem_fire].up			= true
		state.totems[totem_fire].name		= fire_elemental_totem
		state.totems[totem_fire].remains	= 60
	
		return cast
	end )

mod:AddAbility( flame_shock, 8050 )
	mod:AddHandler( flame_shock, function ( state )
		cast = state.sGCD

		state.cooldowns[flame_shock] = 5.0
		state.cooldowns[earth_shock] = 5.0

		state.pBuffs[unleash_flame].up			= false
		state.pBuffs[unleash_flame].count		= 0
		state.pBuffs[unleash_flame].remains		= 0

		local tick	= 3 / state.sHaste
		local ticks	= round( 30 / tick )
		local length = tick * ticks

		state.tDebuffs[flame_shock].up			= true
		state.tDebuffs[flame_shock].count		= 1
		state.tDebuffs[flame_shock].remains		= length

		return cast
	end )

mod:AddAbility( flametongue_weapon, 8024, 'precombat' )
	mod:AddHandler( flametongue_weapon, function ( state )
		cast = state.sGCD

		state.pBuffs[flametongue_weapon].up 		= true
		state.pBuffs[flametongue_weapon].count		= 1
		state.pBuffs[flametongue_weapon].remains 	= 3600

		return cast
	end )

mod:AddAbility( heroism, 32182, 'offGCD', 'bloodlust' )
	mod:AddHandler( heroism, function ( state )
		cast = 0
		state.cooldowns[heroism] = 300
	
		if state.pDebuffs[sated].up or state.pDebuffs[exhaustion].up or state.pDebuffs[insanity].up or state.pDebuffs[temporal_displacement].up then
			return cast
		end
	
		state.pBuffs[heroism].up			= true
		state.pBuffs[heroism].count 		= 1
		state.pBuffs[heroism].remains 		= 40
		state.pDebuffs[exhaustion].up		= true
		state.pDebuffs[exhaustion].count 	= 1
		state.pDebuffs[exhaustion].remains 	= 600
	
		RecalculateHaste( state )
	
		return cast
	end )

mod:AddAbility( jade_serpent, 76093, 'item', 'offGCD', 'consumable' )
	mod:AddHandler( jade_serpent, function ( state )
		cast = 0
		state.cooldowns[jade_serpent] = 120
		
		state.pBuffs[jade_serpent].up		= true
		state.pBuffs[jade_serpent].count	= 1
		state.pBuffs[jade_serpent].remains	= 25
		
		return cast
	end )

mod:AddAbility( lava_beam, 114074 )
	mod:AddHandler( lava_beam, function ( state, precast )
		cast = 2.0 / state.sHaste
		local hardcast = true
		
		if state.pBuffs[ancestral_swiftness].up and not precast then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
			cast = 0
			hardcast = false
		end
		
		if cast < state.sGCD then cast = state.sGCD end
		return cast, nil, hardcast
	end )

mod:AddAbility( lava_burst, 51505 )
	mod:AddHandler( lava_burst, function ( state, precast )
		cast = 2.0 / state.sHaste
		local hardcast = true
		
		if not precast then
			if state.pBuffs[lava_surge].up then
				state.pBuffs[lava_surge].up = false
				state.pBuffs[lava_surge].count = 0
				state.pBuffs[lava_surge].remains = 0
				cast = 0
				hardcast = false
			elseif state.pBuffs[ancestral_swiftness].up then
				state.pBuffs[ancestral_swiftness].up		= false
				state.pBuffs[ancestral_swiftness].count		= 0
				state.pBuffs[ancestral_swiftness].remains	= 0
				cast = 0
				hardcast = false
			end
		end

		if state.pBuffs[ascendance].up and state.pBuffs[ascendance].remains > cast then
			state.cooldowns[lava_burst] = 0
		else
			state.cooldowns[lava_burst] = 8.0
		end
		
		if cast < state.sGCD then cast = state.sGCD end
		return cast, nil, hardcast
	end )

mod:AddAbility( lifeblood, 121279, 'offGCD', 'profession' )
	mod:AddHandler( lifeblood, function ( state )
		cast = 0
	
		state.cooldowns[lifeblood] = 120
	
		state.pBuffs[lifeblood].up		= true
		state.pBuffs[lifeblood].count	= 1
		state.pBuffs[lifeblood].remains	= 20
	
		local lbBenefit = 2880

		state.shRating = state.shRating + lbBenefit
		state.mhRating = state.mhRating + lbBenefit
		state.sHaste = 1 + ( state.shRating / 42500 )
		state.mHaste = 1 + ( state.mhRating / 42500 )
	
		RecalculateHaste( state, true )
	
		return cast
	end )

mod:AddAbility( lightning_bolt, 403 )
	mod:AddHandler( lightning_bolt, function ( state, precast )
		cast = 2.0 / state.sHaste
		local hardcast = true
	
		if state.pBuffs[ancestral_swiftness].up and not precast then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
			hardcast = false
		end
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast, nil, hardcast
	end )

mod:AddAbility( lightning_shield, 324, 'precombat' )
	mod:AddHandler( lightning_shield, function ( state )
		cast = state.sGCD
	
		state.pBuffs[lightning_shield].up		= true
		state.pBuffs[lightning_shield].count	= 1
		state.pBuffs[lightning_shield].remains	= 3600
	
		return cast
	end )

mod:AddAbility( magma_totem, 8190 )
	mod:AddHandler( magma_totem, function ( state )
		cast = state.tGCD
	
		state.totems[totem_fire].up			= true
		state.totems[totem_fire].name		= magma_totem
		state.totems[totem_fire].remains	= 60
	
		return cast
	end )

mod:AddAbility( searing_totem, 3599 )
	mod:AddHandler( searing_totem, function ( state )
		cast = state.tGCD
	
		state.totems[totem_fire].up			= true
		state.totems[totem_fire].name		= searing_totem
		state.totems[totem_fire].remains	= 60
	
		return cast
	end )

mod:AddAbility( spiritwalkers_grace, 79206, 'offGCD' )
	mod:AddHandler( spiritwalkers_grace, function ( state )
		state.cooldowns[spiritwalkers_grace] = ttCooldown(79206)

		state.pBuffs[spiritwalkers_grace].up		= true
		state.pBuffs[spiritwalkers_grace].count		= 1
		state.pBuffs[spiritwalkers_grace].remains	= 15

		return 0
	end )

mod:AddAbility( stormlash_totem, 120668 )
	mod:AddHandler( stormlash_totem, function ( state )
		cast = state.tGCD
	
		state.totems[totem_air].up			= true
		state.totems[totem_air].name		= stormlash_totem
		state.totems[totem_air].remains		= 10
	
		state.pBuffs[stormlash_totem].up		= true
		state.pBuffs[stormlash_totem].count		= 1
		state.pBuffs[stormlash_totem].remains	= 10
	
		return cast
	end )

mod:AddAbility( synapse_springs, 126731, 'offGCD', 'profession' )
	mod:AddHandler( synapse_springs, function ( state )
		cast = 0
	
		state.cooldowns[synapse_springs] = 60
	
		return cast
	end )

mod:AddAbility( thunderstorm, 51490 )
	mod:AddHandler( thunderstorm, function ( state )
		cast = 0
		
		state.cooldowns[thunderstorm] = 45
		
		return cast
	end )

mod:AddAbility( unleash_elements, 73680 )
	mod:AddHandler( unleash_elements, function ( state )
		cast = state.sGCD
		state.cooldowns[unleash_elements] = 15.0
	
		if state.pBuffs[flametongue_weapon].up then
			state.pBuffs[unleash_flame].up 			= true
			state.pBuffs[unleash_flame].count		= 1
			state.pBuffs[unleash_flame].remains		= 8
		end
	
		return cast
	end )

mod:AddAbility( wind_shear, 57994, 'offGCD', 'interrupt' )
	mod:AddHandler( wind_shear, function ( state )
		cast = 0
		state.cooldowns[wind_shear] = 12
	
		state.tCast = 0
	
		return cast
	end )


-- we would need to make glyph name aliases (for localization) if any were different from "Glyph of __________" spell names.
mod.pBuffsToTrack			= {
	ancestral_swiftness,
	ancient_hysteria,
	ascendance,
	berserking,
	bloodlust,
	elemental_mastery,
	heroism,
	jade_serpent,
	lava_surge,
	lifeblood,
	lightning_shield,
	spiritwalkers_grace,
	stormlash_totem,
	time_warp,
	unleash_flame
}

mod.pDebuffsToTrack		= {
	insanity,
	exhaustion,
	sated,
	temporal_displacement
}

mod.tDebuffsToTrack		= {
	flame_shock
}



-- As compared to SimC:
--
-- Hekili		SimC		Description
-- precombat	precombat	(generally, buffs)
-- cooldown		(blank)		'Executed every time the actor is available'
-- single		single		'Single target action priority list'
-- aoe			aoe			'Multi target action priority list'
-- 
-- For this addon, the single target display will go through:  precombat, cooldowns, single
-- The multi target display will go through:  precombat, cooldowns, aoe
--
-- AddToActionList( category, ability, caption, simC, check )


---------------
-- PRECOMBAT --

mod:AddToActionList('precombat',
					flametongue_weapon,
					'',
					'/actions.precombat+=flametongue_weapon,weapon=off',
					function( state )
						if not state.pBuffs[flametongue_weapon].up then
							return flametongue_weapon
						end
						return nil
					end )

mod:AddToActionList('precombat',
					lightning_shield,
					'',
					'/actions.precombat+=lightning_shield,if=!buff.lightning_shield.up',
					function( state )
						if not state.pBuffs[lightning_shield].up then
							return lightning_shield
						end
						return nil
					end )

-- PRECOMBAT --
---------------

--------------
-- COOLDOWN --

mod:AddToActionList('cooldown',
					bloodlust,
					'',
					'actions+=/bloodlust,if=target.health.pct<25|time>5',
					function( state )
						if (IsUsableSpell(bloodlust) and state.tHealthPct < 25 and state.combatTime > 5)
							and (not state.pDebuffs[sated].up and not state.pDebuffs[exhaustion].up and not state.pDebuffs[temporal_displacement].up and not state.pDebuffs[insanity].up) then
							return bloodlust
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					heroism,
					'',
					'actions+=/heroism,if=target.health.pct<25|time>5',
					function( state )
						if (IsUsableSpell(heroism) and state.tHealthPct < 25 and state.combatTime > 5)
							and (not state.pDebuffs[sated].up and not state.pDebuffs[exhaustion].up and not state.pDebuffs[temporal_displacement].up and not state.pDebuffs[insanity].up) then
							return heroism
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					stormlash_totem,
					'',
					'actions+=/stormlash_totem,if=!active&!buff.stormlash.up&(buff.bloodlust.up|time>=60)',
					function( state )
						if (not state.pBuffs[stormlash_totem].up) and ( (state.pBuffs[heroism].up or state.pBuffs[bloodlust].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) or state.combatTime >= 60 ) then
							return stormlash_totem
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					jade_serpent,
					'Potion', -- removed combat time check (if you didn't pre-pot, maybe you want to use it now) and checking to see if the totem is actually going to get the full benefit of the pot.
					'actions+=/jade_serpent_potion,if=time>60&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active|target.time_to_die<=60)',
					function ( state )
						if ( (state.totems[totem_fire].up and state.totems[totem_fire].name == fire_elemental_totem and state.totems[totem_fire].remains >= 25) or state.timeToDie <= 60 ) then
							return jade_serpent
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					berserking,
					'',
					'actions+=/berserking,if=!buff.bloodlust.up&!buff.elemental_mastery.up&(set_bonus.tier15_4pc_caster=1|(buff.ascendance.cooldown_remains=0&(dot.flame_shock.remains>buff.ascendance.duration|level<87)))',
					function( state )
						if IsUsableSpell(berserking) and not (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) and not state.pBuffs[elemental_mastery].up and (state.set_bonuses['t15'] >= 4 or (state.cooldowns[ascendance] == 0 and state.tDebuffs[flame_shock].remains > 15)) then
							return berserking
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					blood_fury,
					'',
					'actions+=/blood_fury,if=buff.bloodlust.up|buff.ascendance.up|((cooldown.ascendance.remains>10|level<87)&cooldown.fire_elemental_totem.remains>10)',
					function( state )
						if IsUsableSpell(blood_fury) and (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) or state.pBuffs[ascendance].up or ( state.cooldowns[ascendance] > 10 and state.cooldowns[fire_elemental_totem] > 10) then
							return blood_fury
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					elemental_mastery,
					'',
					'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&(time>15&((!buff.bloodlust.up&time<120)|(!buff.berserking.up&!buff.bloodlust.up&buff.ascendance.up)|(time>=200&(cooldown.ascendance.remains>30|level<87))))',
					function( state )
						if state.talents[elemental_mastery] and	(state.combatTime > 15 and (not (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) and state.combatTime < 120) or (not state.pBuffs[berserking].up and not (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) and not state.pBuffs[ascendance].up) or ( state.combatTime >= 200 and state.cooldowns[ascendance].remains > 30 ) ) then 
							return elemental_mastery
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					ancestral_swiftness,
					'',
					'actions+=/ancestral_swiftness,if=talent.ancestral_swiftness.enabled&!buff.ascendance.up',
					function( state )
						if state.talents[ancestral_swiftness] and not state.pBuffs[ascendance].up then
							return ancestral_swiftness
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					fire_elemental_totem,
					'',
					'actions+=/fire_elemental_totem,if=!active',
					function( state )
						if not state.totems[totem_fire].up or state.totems[totem_fire].name ~= fire_elemental_totem then
							return fire_elemental_totem
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					lifeblood,
					'',
					'actions+=/lifeblood,if=(glyph.fire_elemental_totem.enabled&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active))|!glyph.fire_elemental_totem.enabled',
					function( state )
						if not state.glyphs[fire_elemental_totem] or (state.glyphs[fire_elemental_totem] and state.totems[totem_fire].up and state.totems[totem_fire].name == fire_elemental_totem) then
							return lifeblood
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					ascendance,
					'', -- 
					'actions+=/ascendance,if=active_enemies>1|(dot.flame_shock.remains>buff.ascendance.duration&(target.time_to_die<20|buff.bloodlust.up|time>=60)&cooldown.lava_burst.remains>0)',
					function( state )
						-- if not state.pBuffs[ascendance].up and (state.tCount > 1 or (state.tDebuffs[flame_shock].remains > 15 and (state.timeToDie < 20 or (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) or state.combatTime >= 60) and state.cooldowns[lava_burst] > 0)) then
						if not state.pBuffs[ascendance].up and state.tCount > 1 or (state.tDebuffs[flame_shock].remains > 15 and state.cooldowns[lava_burst] > 0) then
							return ascendance
						end
						return nil
					end )

-- COOLDOWN --
--------------


---------
-- AOE --

mod:AddToActionList('aoe',
					lava_beam,
					'',
					'actions.aoe=lava_beam',
					function( state )
						if state.pBuffs[ascendance].up then
							return lava_beam, nil, (not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					magma_totem,
					'>2',
					'actions.aoe+=/magma_totem,if=active_enemies>2&!totem.fire.active',
					function( state )
						if not state.totems[totem_fire].up and state.tCount > 2 then
							return magma_totem
						end
						return nil
					end )

mod:AddToActionList('aoe',
					searing_totem,
					'2-',
					'actions.aoe+=/searing_totem,if=active_enemies<=2&!totem.fire.active',
					function( state )
						if not state.totems[totem_fire].up and state.tCount <= 2 then
							return searing_totem
						end
						return nil
					end )

mod:AddToActionList('aoe',
					lava_burst,
					'2-',
					'actions.aoe+=/lava_burst,if=active_enemies<3&dot.flame_shock.remains>cast_time&cooldown_react',
					function( state )
						if state.tCount < 3 and state.tDebuffs[flame_shock].remains > 2.0 then
							return lava_burst, nil, (not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					flame_shock,
					'Cycle',
					'actions.aoe+=/flame_shock,cycle_targets=1,if=!ticking&active_enemies<3',
					function( state )
						-- This only works if Magma Totem is up and hitting things, otherwise tCount will == fsCount.
						if state.tDebuffs[flame_shock].up and state.tCount > state.fsCount and state.tCount < 3 then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('aoe',
					flame_shock,
					'',
					'N/A - use FS if it will expire before it comes off CD again',
					function( state )
						if state.tCount < 3 and (not state.tDebuffs[flame_shock].up or state.tDebuffs[flame_shock].remains < 5) then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('aoe',
					earthquake,
					'5+',
					'actions.aoe+=/earthquake,if=active_enemies>4',
					function( state )
						if state.tCount > 4 then
							return earthquake, nil, (not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					thunderstorm,
					'',
					'actions.aoe+=/thunderstorm,if=mana.pct_nonproc<80',
					function( state )
						if state.pManaPct < 80 then
							return thunderstorm
						end
						return nil
					end )

mod:AddToActionList('aoe',
					chain_lightning,
					'',
					'actions.aoe+=/chain_lightning,if=mana.pct_nonproc>10',
					function( state )
						if state.pManaPct > 10 then
							return chain_lightning, nil, (not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					lightning_bolt,
					'',
					'actions.aoe+=/lightning_bolt',
					function( state )
						return lightning_bolt, nil, (not state.pBuffs[ancestral_swiftness].up)
					end )

-- AOE --
---------


------------
-- SINGLE --

mod:AddToActionList('single',
					wind_shear,
					'',
					'actions=wind_shear',
					function( state )
						if state.tCast > 0 then
							return wind_shear
						end
						return nil
					end )

mod:AddToActionList('single',
					synapse_springs,
					'Gloves',
					'actions.single=use_item,name=[gloves],if=((cooldown.ascendance.remains>10|level<87)&cooldown.fire_elemental_totem.remains>10)|buff.ascendance.up|buff.bloodlust.up|totem.fire_elemental_totem.active',
					function( state )
						if state.items[synapse_springs] and ( state.cooldowns[ascendance] > 10 and state.cooldowns[fire_elemental_totem] > 10 ) or state.pBuffs[ascendance].up or (state.pBuffs[bloodlust].up or state.pBuffs[heroism].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) or (state.totems[totem_fire].up and state.totems[totem_fire].name == fire_elemental_totem) then
							return synapse_springs
						end
					end )

mod:AddToActionList('single',
					unleash_elements,
					'UF',
					'actions.single+=/unleash_elements,if=talent.unleashed_fury.enabled&!buff.ascendance.up',
					function( state )
						if state.talents[unleashed_fury] and state.pBuffs[flametongue_weapon].up and not state.pBuffs[ascendance].up then
							return unleash_elements
						end
						return nil
					end )

mod:AddToActionList('single',
					spiritwalkers_grace,
					'',
					'actions.single+=/spiritwalkers_grace,moving=1,if=buff.ascendance.up',
					function( state )
						if state.moving and state.pBuffs[ascendance].up then
							return spiritwalkers_grace
						end
						return nil
					end )


mod:AddToActionList('single',
					lava_burst,
					'',
					'actions.single+=/lava_burst,if=dot.flame_shock.remains>cast_time&(buff.ascendance.up|cooldown_react)',
					function( state )
						if (state.lastCast == flame_shock or state.tDebuffs[flame_shock].remains > (2.0 / state.sHaste)) or (state.tDebuffs[flame_shock].up and state.pBuffs[lava_surge].up) then
							return lava_burst, nil, (not state.pBuffs[ancestral_swiftness].up and not state.pBuffs[lava_surge].up)
						end
						return nil
					end )

mod:AddToActionList('single',
					flame_shock,
					'<6sec',
					'actions.single+=/flame_shock,if=ticks_remain<2',
					function( state )
						if state.tDebuffs[flame_shock].remains < 6 then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('single',
					elemental_blast,
					'',
					'actions.single+=/elemental_blast,if=talent.elemental_blast.enabled',
					function( state )
						if state.talents[elemental_blast] then
							return elemental_blast, nil, (not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('single',
					earth_shock,
					'7x',
					'actions.single+=/earth_shock,if=buff.lightning_shield.react=buff.lightning_shield.max_stack',
					function( state )
						if state.pBuffs[lightning_shield].count == 7 then
							return earth_shock
						end
						return nil
					end )
					
mod:AddToActionList('single',
					flame_shock,
					'preAsc',
					'actions.single+=/flame_shock,if=time>60&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<duration',
					function( state )
						if state.combatTime > 60 and state.tDebuffs[flame_shock].remains < 15 and (state.cooldowns[ascendance] + 15 < 30 ) then
							return flame_shock
						end
						return nil
					end )
					
mod:AddToActionList('single',
					earth_elemental_totem,
					'',
					'actions.single+=/earth_elemental_totem,if=!active&cooldown.fire_elemental_totem.remains>=60',
					function( state )
						if state.combatTime > 60 and not state.totems[totem_earth].up or state.totems[totem_earth].name ~= earth_elemental_totem and state.cooldowns[fire_elemental_totem] >= 60 then
							return earth_elemental_totem
						end
						return nil
					end )

mod:AddToActionList('single',
					searing_totem,
					'',
					'actions.single+=/searing_totem,if=cooldown.fire_elemental_totem.remains>20&!totem.fire.active',
					function( state )
						if not state.totems[totem_fire].up then
							return searing_totem
						end
						return nil
					end )

mod:AddToActionList('single',
					spiritwalkers_grace,
					'',
					'actions.single+=/spiritwalkers_grace,moving=1,if=((talent.elemental_blast.enabled&cooldown.elemental_blast.remains=0)|(cooldown.lava_burst.remains=0&!buff.lava_surge.react))|(buff.raid_movement.duration>=action.unleash_elements.gcd+action.earth_shock.gcd)',
					function( state )
						if state.moving and ((state.talents[elemental_blast] and state.cooldowns[elemental_blast] == 0) or (state.cooldowns[lava_burst] == 0 and not state.pBuffs[lava_surge].up)) then
							return spiritwalkers_grace
						end
						return nil
					end )


mod:AddToActionList('single',
					lightning_bolt,
					'',
					'actions.single+=/lightning_bolt',
					function( state )
						return lightning_bolt, nil, (not state.pBuffs[ancestral_swiftness].up)
					end )


-- SINGLE --
------------


-------------------
-- TIER CHECKING --

local tSlots = {
	'Headpiece',
	'Shoulderwraps',
	'Hauberk',
	'Gloves',
	'Kilt'
}

function tierCheck( setName, affix )

	equipped = 0

	for i=1, 5 do
		if affix then
			if IsEquippedItem(setName .. ' ' .. tSlots[i]) then
				equipped = equipped + 1
			end
		else
			if IsEquippedItem(tSlots[i] .. ' of ' .. setName) then
				equipped = equipped + 1
			end
		end
	end
	return equipped
end

-- TIER CHECKING --
-------------------


-----------
-- HASTE --

function RecalculateHaste( state, saveRating )

	if not saveRating then
		-- Player's Combat Rating, for updates.
		state.shRating = GetCombatRating(CR_HASTE_SPELL)
		state.mhRating = GetCombatRating(CR_HASTE_MELEE)

		state.sHaste = (1 + ( state.shRating / 42500 ) )
		state.mHaste = (1 + ( state.shRating / 42500 ) )
	end

	for k,v in pairs(mod.burstHaste) do
		if state.pBuffs[k].up then
			state.sHaste = state.sHaste * v
			state.mHaste = state.mHaste * v
		end
	end
	if state.talents[ancestral_swiftness] then
		state.sHaste = state.sHaste * 1.05
		state.mHaste = state.mHaste * 1.10
	end
	
	-- Elemental Oath
	state.sHaste = state.sHaste * 1.05

	state.mGCD = 1.5
	state.tGCD = 1.0

	state.sGCD = 1.5 / state.sHaste
	if state.sGCD < 1.0 then state.sGCD = 1.0 end

end

-- HASTE --
-----------




function mod.RefreshState( state )

	state.time			= GetTime()

	if Hekili.CombatStart > 0 then
		state.combatTime 	= state.time - Hekili.CombatStart
	else
		state.combatTime	= 0
	end
	
	state.moving		= (GetUnitSpeed("player") > 0)
	
	state.timeToDie		= Hekili.GetTTD()
	state.tCount,
	state.mtCount,
	state.fsCount		= mod.activeTargets()

	if Hekili.lastCast and (state.time - Hekili.lastCast.time < 0.5) then
		state.lastCast = Hekili.lastCast.spell
	else
		state.lastCast = ''
	end
	
	state.faction		= UnitFactionGroup("player")
	state.race			= UnitRace("player")


	------------------
	-- PLAYER BUFFS --

	if not state.pBuffs then
		state.pBuffs = {}

		for i,v in ipairs(mod.pBuffsToTrack) do
			state.pBuffs[v] = {}
		end

		state.pBuffs[flametongue_weapon]	= {}
	end

	for i,v in ipairs(mod.pBuffsToTrack) do
		local name, _, _, count, _, _, expires = UnitBuff("player", v)
		local remains = 0

		if expires then
			remains = expires - state.time
		end

		if not name then name = v end
		state.pBuffs[name].up		= count and true or false
		state.pBuffs[name].count	= count and count or 0
		state.pBuffs[name].remains	= remains
	end

	-- Put temporary weapon enchants into pBuffs for simplicity's sake.
	local MH, mhExpires = GetWeaponEnchantInfo()
	if MH and ttWeaponEnchant(GetInventorySlotInfo("MainHandSlot")) == "Flametongue" then
		state.pBuffs[flametongue_weapon].up			= true
		state.pBuffs[flametongue_weapon].count		= 1
		state.pBuffs[flametongue_weapon].remains	= mhExpires / 1000
	else
		state.pBuffs[flametongue_weapon].up			= false
		state.pBuffs[flametongue_weapon].count		= 0
		state.pBuffs[flametongue_weapon].remains	= 0
	end

	-- PLAYER BUFFS --
	------------------


	--------------------
	-- PLAYER DEBUFFS --

	if not state.pDebuffs then
		state.pDebuffs = {}

		for i,v in ipairs(mod.pDebuffsToTrack) do
			state.pDebuffs[v] = {}
		end
	end

	for i,v in ipairs(mod.pDebuffsToTrack) do
		local name, _, _, count, _, _, expires = UnitDebuff("player", v)
		local remains = 0

		if expires then
			remains = expires - state.time
		end

		if not name then name = v end
		state.pDebuffs[name].up	= count and true or false
		state.pDebuffs[name].count		= count and count or 0
		state.pDebuffs[name].remains	= remains
	end

	-- PLAYER DEBUFFS --
	--------------------


	---------------
	-- COOLDOWNS --

	if not state.cooldowns then
		state.cooldowns = {}
	end

	for k,v in pairs(mod.spells) do
		local cdStart, cdLength = GetSpellCooldown(k)

		-- Faking the CD for off-GCD abilities preserves the order.
		if v.offGCD and cdLength == 0 then
			cdStart, cdLength = GetSpellCooldown(lightning_shield)
		end

		if cdStart ~= nil and cdStart > 0 then
			state.cooldowns[k] = cdStart + cdLength - state.time
		else
			state.cooldowns[k] = 0
		end
		
		if state.cooldowns[k] < 0 then state.cooldowns[k] = 0 end
	end

	-- Special Cases
	if state.pBuffs[ascendance].up then
		state.cooldowns[ascendance] = ttCooldown(114049)
	end


	-- COOLDOWNS --
	---------------


	-----------
	-- ITEMS --

	if not state.items then state.items	= {} end

	state.items[synapse_springs]	= false
	state.items[jade_serpent]		= false

	-- Engineering Gloves
	local gSlot = GetInventorySlotInfo("HandsSlot")
	local gloves = GetInventoryItemID("player", gSlot)

	state.cooldowns[synapse_springs]	= 0
	if ttGloveTinker(gSlot) then
		state.items[synapse_springs]	= true

		local cdStart, cdLength = GetItemCooldown(gloves)

		if cdStart == 0 and cdLength == 0 then
			cdStart, cdLength = GetSpellCooldown(lightning_shield)
		end

		if cdStart ~= nil and cdStart > 0 then
			state.cooldowns[synapse_springs] = cdStart + cdLength - state.time
		else
			state.cooldowns[synapse_springs] = 0
		end
	end

	-- Jade Serpent
	local vbCount = GetItemCount(jade_serpent, false)
	state.cooldowns[jade_serpent]			= 999

	if vbCount > 0 then
		state.items[jade_serpent]			= true

		local cdStart, cdLength, cdEnable = GetItemCooldown(76093)

		if (cdStart == 0 and cdLength == 0) then
			cdStart, cdLength = GetSpellCooldown(lightning_shield)
		end

		if cdStart > 0 then
			state.cooldowns[jade_serpent] = cdStart + cdLength - state.time
		else
			state.cooldowns[jade_serpent] = 0
		end
	end

	-- ITEMS --
	-----------


	------------
	-- TOTEMS --

	if not state.totems then
		state.totems = {}
	end

	for i = 1, 4 do
		if not state.totems[i] then state.totems[i] = {} end

		local up, name, start, duration = GetTotemInfo(i)
		local remains = start + duration - state.time

		if remains < 0 then remains = 0
		else remains = remains + 2 end

		state.totems[i].name 	= name
		state.totems[i].up		= up
		state.totems[i].remains = remains
	end

	-- TOTEMS --
	------------


	-------------
	-- TALENTS --

	if not state.talents then
		state.talents = {}
	end

	for i=1, MAX_NUM_TALENTS do
		local name, _, _, _, enabled = GetTalentInfo(i)

		state.talents[name] = enabled
	end
	-- TALENTS --
	-------------


	------------
	-- GLYPHS --

	if not state.glyphs then
		state.glyphs = {}
	end

	-- Set all glyphs to false before checking to see which ones are actually active.
	for k,_ in pairs(state.glyphs) do
		state.glyphs[k] = false
	end

	for i=1, NUM_GLYPH_SLOTS do
		local enabled, _, _, gID = GetGlyphSocketInfo(i)

		if enabled == 1 and gID then
			-- Strip "Glyph of" for the sake of most glyphs sharing the name of the spell they modify.
			local gName = string.match(GetSpellInfo(gID), "^%a+ %a+ (.*)$")

			state.glyphs[gName] = true
		end
	end

	-- GLYPHS --
	------------


	-----------------
	-- SET BONUSES --

	if not state.set_bonuses then
		state.set_bonuses = {}
	end
	state.set_bonuses['t14'] = tierCheck( "Firebird's", true )
	state.set_bonuses['t15'] = tierCheck( "the Witch Doctor" )
	state.set_bonuses['t16'] = tierCheck( "Celestial Harmony" )

	-- SET BONUSES --
	-----------------


	-----------------
	-- PLAYER MANA --
	
	state.pMana			= UnitMana('player') or 0
	state.pManaPct		= ((UnitMana('player') or 0) / (UnitManaMax('player') or 1) * 100) or 100

	-- PLAYER MANA --
	-----------------

	state.pCast			= 0
	state.pCasting		= ''

	local spellcast, _, _, _, _, endCast, _, _, notInterruptible = UnitCastingInfo('player')

	if endCast ~= nil then
		state.pCast	= (endCast / 1000) - GetTime() 
		state.pCasting = spellcast
	end

	spellcast, _, _, _, _, endCast, _, notInterruptible = UnitChannelInfo('player')

	if endCast ~= nil then
		state.pCast = (endCast / 1000) - GetTime() 
		state.pCasting = spellcast
	end
	

	-------------------
	-- TARGET HEALTH --

	state.tHealth		= UnitHealth('target') or 0
	state.tHealthPct	= ((UnitHealth('target') or 0) / (UnitHealthMax('target') or 1) * 100) or 100

	-- TARGET HEALTH --
	-------------------


	--------------------
	-- TARGET DEBUFFS --

	if not state.tDebuffs then
		state.tDebuffs = {}

		for i,v in ipairs(mod.tDebuffsToTrack) do
			state.tDebuffs[v] = {}
		end
	end

	if UnitExists("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
		for i,v in ipairs(mod.tDebuffsToTrack) do
			local name, _, _, count, _, _, expires, caster = UnitDebuff("target", v)
			local remains = 0

			-- UnitDebuff("target", "ability", "PLAYER") shits the bed.
			if caster ~= 'player' then
				name	= nil
				count	= nil
				expires	= nil
			end

			if expires then
				remains = expires - state.time
			end

			if not name then name = v end

			state.tDebuffs[name].up			= count and true or false
			state.tDebuffs[name].count		= count and count or 0
			state.tDebuffs[name].remains	= remains
		end
	else
		for i,v in ipairs(mod.tDebuffsToTrack) do
			state.tDebuffs[v].up		= false
			state.tDebuffs[v].count		= 0
			state.tDebuffs[v].remains	= 0
		end
	end

	-- TARGET DEBUFFS --
	--------------------


	----------------------
	-- TARGET CAST INFO --

	state.tCast = 0

	if UnitName("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
		_, _, _, _, _, endCast, _, _, notInterruptible = UnitCastingInfo("target")

		if endCast ~= nil and not notInterruptible then
			state.tCast	= (endCast / 1000) - GetTime() 
		end

		_, _, _, _, _, endCast, _, notInterruptible = UnitChannelInfo("target")

		if endCast ~= nil and not notInterruptible then
			state.tCast = (endCast / 1000) - GetTime() 
		end
	end

	-- TARGET CAST INFO --
	----------------------


	----------------
	-- HASTE INFO --

	RecalculateHaste( state )

	-- HASTE INFO --
	------------------

end


function mod.AdvanceState( state, elapsed )

	state.time			= state.time + elapsed
	state.combatTime	= state.combatTime + elapsed
	state.timeToDie		= state.timeToDie - elapsed

	if Hekili.lastCast and (state.time - Hekili.lastCast.time < 0.5) then
		state.lastCast = Hekili.lastCast.spell
	else
		state.lastCast = ''
	end

	---------------
	-- COOLDOWNS --

	for k,_ in pairs(mod.spells) do
		if not state.cooldowns[k] then
			state.cooldowns[k] = 0
		end

		if state.cooldowns[k] > 0 then
			state.cooldowns[k] = state.cooldowns[k] - elapsed
		end

		if state.cooldowns[k] < 0 then
			state.cooldowns[k] = 0
		end
	end

	-- COOLDOWNS --
	---------------


	------------
	-- TOTEMS --

	for i = 1, 4 do
		if state.totems[i].up then
			if state.totems[i].remains > 0 then
				state.totems[i].remains = state.totems[i].remains - elapsed
			end

			if state.totems[i].remains < 0 then
				state.totems[i].name = nil
				state.totems[i].up = false
				state.totems[i].remains = 0
			end
		end
	end

	-- TOTEMS --
	------------


	------------------
	-- PLAYER BUFFS --

	for k,_ in pairs(state.pBuffs) do
		if state.pBuffs[k].up then
			if state.pBuffs[k].remains > 0 then
				state.pBuffs[k].remains = state.pBuffs[k].remains - elapsed

				if state.pBuffs[k].remains < 0 then
					state.pBuffs[k].up			= false
					state.pBuffs[k].count		= 0
					state.pBuffs[k].remains		= 0

					-- Update Haste effects.
					if k == lifeblood then
						local lbBenefit = 2880
						state.shRating = state.shRating - lbBenefit
						state.sHaste = 1 + ( state.shRating / 42500 )
						state.mhRating = state.mhRating - lbBenefit
						state.mHaste = 1 + ( state.mhRating / 42500 )
						RecalculateHaste( state, true )
					elseif mod.burstHaste[k] ~= nil then
						RecalculateHaste( state )
					end
				end
			end
		end
	end

	-- PLAYER BUFFS --
	------------------


	--------------------
	-- PLAYER DEBUFFS --

	for k,v in pairs(state.pDebuffs) do
		if v.up then
			if v.remains > 0 then
				v.remains = v.remains - elapsed

				if v.remains < 0 then
					v.up 	= false
					v.count 	= 0
					v.remains 	= 0
				end
			end
		end
	end

	-- PLAYER DEBUFFS --
	--------------------


	--------------------
	-- TARGET DEBUFFS --

	for k,v in pairs(state.tDebuffs) do
		if v.up then
			if v.remains > 0 then
				v.remains = v.remains - elapsed

				if v.remains < 0 then
					v.up = false
					v.count = 0
					v.remains = 0
				end
			end
		end
	end

	-- TARGET DEBUFFS --
	--------------------

end


mod.trackHits.source	= 0
mod.trackHits.pulse		= 0
mod.trackHits.count		= 0
mod.trackHits.timeOut	= 5.0

mod.trackHits.qPulse	= 0
mod.trackHits.qCount	= 0
mod.trackHits.qTimeOut	= 2.0

mod.trackDebuffs[flame_shock] = {}


function mod.countHits( verb )

	if verb then
		for k,v in pairs(mod.trackHits) do
			print(k .. ' = ' .. v .. '.')
		end
	end

	if mod.trackHits.qCount > mod.trackHits.count then
		return mod.trackHits.qCount
	else
		return mod.trackHits.count and mod.trackHits.count or 0
	end

end


function mod.countDebuffs( spell, verb )
	local num = 0

	if verb then Hekili:Print('Counting ' .. spell .. '.') end

	if mod.trackDebuffs[ spell ] then
		if verb then Hekili:Print(spell .. ' has spell table.') end

		for k,_ in pairs(mod.trackDebuffs[spell]) do
			num = num + 1
		end
	end

	if verb then Hekili:Print(spell .. ' had ' .. num .. '.') end
	return num
end


function mod.activeTargets( verb )

	local debuffs = 0

	for k,v in pairs(mod.trackDebuffs) do
		local tmpDebuffs = mod.countDebuffs( k, verb )

		if tmpDebuffs > debuffs then debuffs = tmpDebuffs end
	end

	local hits = mod.countHits( verb )

	if hits > debuffs then
		return hits, hits, debuffs
	else
		return debuffs, hits, debuffs
	end
end



function mod.auditTrackers( )
	for spell, spellTable in pairs(mod.trackDebuffs) do
		for unit, lastTick in pairs(spellTable) do
			if GetTime() - lastTick > 5.0 then spellTable[unit] = nil end
		end
	end

	if GetTime() - mod.trackHits.pulse > mod.trackHits.timeOut then
		mod.trackHits.pulse		= 0
		mod.trackHits.count		= 0
	end
	
	if GetTime() - mod.trackHits.qPulse > mod.trackHits.qTimeOut then
		mod.trackHits.qPulse	= 0
		mod.trackHits.qCount	= 0
	end
end


function mod:CLEU(AddOn, event, time, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, _, interrupt)

	-- If you don't care about multiple targets, I don't!
	if AddOn.DB.char['Multi-Target Enabled'] == false and AddOn.DB.char['Multi-Target Integration'] == 0 then
		return true
	end

	-- Detect our own Magma Totem; should later expand to detect AOE from our Fire Elemental if its output is consistent.
	if subtype == 'SPELL_SUMMON' and sourceGUID == UnitGUID('player') and destName == 'Magma Totem' then
		self.trackHits.source	= destGUID
		self.trackHits.pulse	= GetTime()
		self.trackHits.count	= 0
	end


	if subtype == 'SPELL_DAMAGE' and self.trackHits and sourceGUID == self.trackHits.source and spellName == 'Magma Totem' then
		if self.trackHits.pulse == 0 or (GetTime() - self.trackHits.pulse > 0.5) then
			self.trackHits.pulse	= GetTime()
			self.trackHits.count	= 0
		end
		self.trackHits.count	= self.trackHits.count + 1
	end

	if subtype == 'SPELL_DAMAGE' and sourceGUID == UnitGUID('player') and spellName == earthquake then
		if self.trackHits.qPulse == 0 or (GetTime() - self.trackHits.qPulse > 0.5) then
			self.trackHits.qPulse	= GetTime()
			self.trackHits.qCount	= 0
		end
		self.trackHits.qCount	= self.trackHits.qCount + 1
	end

	if subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' or subtype == 'SPELL_DAMAGE' then
		if spellName == 'Flame Shock' and sourceGUID == UnitGUID('player') then
			if not self.trackDebuffs[spellName] then self.trackDebuffs[spellName] = {} end
			self.trackDebuffs[spellName][destGUID]	= GetTime()
		end
	end

	if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' then
		if self.trackDebuffs[spellName] and self.trackDebuffs[spellName][destGUID] then
			self.trackDebuffs[spellName][destGUID] = nil
		end

		if self.trackHits and self.trackHits.source and self.trackHits.source == destGUID then
			self.trackHits.source	= 0
			self.trackHits.pulse	= 0
			self.trackHits.count	= 0
		end
	end

	-- Check to reduce Flame Shock targets.
    if subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
		if spellName == 'Flame Shock' and sourceGUID == UnitGUID('player') then
			self.trackDebuffs[spellName][destGUID] = nil
		end
    end

end
