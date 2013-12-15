-- EnhShaman.lua
-- Default Enhancement Shaman module for Hekili.
-- Hekili of <Turbo Cyborg Ninjas> - Ner'zhul [A]
-- October 2013

local mod = Hekili:NewModule("Enhancement Shaman SimC 5.4.1", "Shaman", "Enhancement", true, true, true)

-- Spells, just to give readable aliases and to help with future localization.
local ancestral_swiftness 	= GetSpellInfo(16188)
local arcane_torrent		= GetSpellInfo(28730)
local ascendance 			= GetSpellInfo(114049)
local berserking			= GetSpellInfo(26297)
local blood_fury			= GetSpellInfo(20572)
local bloodlust 			= GetSpellInfo(2825)
local chain_lightning 		= GetSpellInfo(421)
local earth_elemental_totem	= GetSpellInfo(2062)
local earth_shock 			= GetSpellInfo(8042)
local elemental_blast 		= GetSpellInfo(117014)
local elemental_mastery 	= GetSpellInfo(16166)
local feral_spirit 			= GetSpellInfo(51533)
local fire_elemental_totem 	= GetSpellInfo(2894)
local fire_nova 			= GetSpellInfo(1535)
local flame_shock 			= GetSpellInfo(8050)
local flametongue_weapon 	= GetSpellInfo(8024)
local frost_shock			= GetSpellInfo(8056)
local heroism 				= GetSpellInfo(32182)
local lava_lash 			= GetSpellInfo(60103)
local lifeblood				= GetSpellInfo(121279)
local lightning_bolt 		= GetSpellInfo(403)
local lightning_shield 		= GetSpellInfo(324)
local magma_totem 			= GetSpellInfo(8190)
local searing_totem 		= GetSpellInfo(3599)
local shamanistic_rage 		= GetSpellInfo(30823)
local spiritwalkers_grace	= GetSpellInfo(79206)
local stormblast 			= GetSpellInfo(115356)
local stormlash_totem		= GetSpellInfo(120668)
local stormstrike			= GetSpellInfo(51876)
local synapse_springs		= GetSpellInfo(126731)
local unleash_elements 		= GetSpellInfo(73680)
local virmens_bite			= "Virmen's Bite"
local wind_shear			= GetSpellInfo(57994)
local windfury_weapon 		= GetSpellInfo(8232)

-- Purely for buffs, cannot actually cast these manually.
local ancient_hysteria		= GetSpellInfo(90355)
local insanity				= GetSpellInfo(95809)
local exhaustion			= GetSpellInfo(57723)
local flurry				= GetSpellInfo(16282)
local maelstrom_weapon 		= GetSpellInfo(51530)
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


-- Tell the addon what spell to use to determine the GCD.
mod:SetGCD(lightning_shield)


-- Tell the addon to keep track of how many targets are afflicted by one of your debuffs.
mod:WatchAura(flame_shock)

-- AddTracker:	Name
--				Type		Caption		Show			Timer		Override
--	     Aura:	Name		Unit
--   Cooldown:	Ability
--      Totem:	Element		Totem Name
-- /AddTracker

mod:AddTracker(	'Flame Shock on Target (show target count)',
				'Aura',		'Targets',	'Show Always',	true,		true,
				flame_shock,		'target' )
				
mod:AddTracker(	'Maelstrom Weapon on Player (show aura stacks)',
				'Aura',		'Stacks',	'Show Always',	false,		true,
				maelstrom_weapon,	'player')

mod:AddTracker( 'Fire Totems',
				'Totem',	'None',		'Present',		true,		false,
				'fire',		'' )


mod:AddAbility( ancestral_swiftness, 16188, 'offGCD', 'talent' )
	mod:AddHandler( ancestral_swiftness, function ( state )
		cast = 0
		state.cooldowns[ancestral_swiftness] = 90
	
		state.pBuffs[ancestral_swiftness].up		= true
		state.pBuffs[ancestral_swiftness].count		= 1
		state.pBuffs[ancestral_swiftness].remains	= 0
	
		return cast
	end )

mod:AddAbility( arcane_torrent,	28730, 'offGCD', 'racial', 'interrupt' )
	mod:AddHandler( arcane_torrent, function ( state )
		cast = 0
		state.cooldowns[arcane_torrent] = 120
	
		state.tCast = 0
	
		return cast
	end )
	
mod:AddAbility( ascendance, 114049, 'offGCD' )
	mod:AddHandler( ascendance, function ( state )
		cast = 0
	
		state.pBuffs[ascendance].up			= true
		state.pBuffs[ascendance].count		= 1
		state.pBuffs[ascendance].remains	= 15
	
		state.cooldowns[ascendance]		= ttCooldown(114049)
		state.cooldowns[stormstrike]	= 0
		state.cooldowns[stormblast]		= 0
	
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
	mod:AddHandler( chain_lightning, function ( state )
		cast = 3.0 / state.sHaste
		state.cooldowns[chain_lightning] = 3.0
	
		if state.pBuffs[ancestral_swiftness].up and state.pBuffs[maelstrom_weapon].count < 5 then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
		elseif state.pBuffs[maelstrom_weapon].up then
			cast = cast * (1 - (0.2 * state.pBuffs[maelstrom_weapon].count) )
	
			state.pBuffs[maelstrom_weapon].up		= false
			state.pBuffs[maelstrom_weapon].count	= 0
			state.pBuffs[maelstrom_weapon].remains	= 0
	
		end
	
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast
	end )
	
mod:AddAbility( earth_elemental_totem, 2062 )
	mod:AddHandler( earth_elemental_totem, function ( state )
		cast = state.tGCD
		state.cooldowns[earth_elemental_totem] = ttCooldown(2062)
	
		state.totems[totem_earth].up		= true
		state.totems[totem_earth].name		= earth_elemental_totem
		state.totems[totem_earth].remains	= 60
	
		return cast
	end )

mod:AddAbility( earth_shock, 8042 )
	mod:AddHandler( earth_shock, function ( state )
		cast = state.sGCD

		state.cooldowns[flame_shock] = 6.0
		state.cooldowns[frost_shock] = 6.0
		state.cooldowns[earth_shock] = 6.0

		return cast
	end )

mod:AddAbility( elemental_blast, 117014, 'talent' )
	mod:AddHandler( elemental_blast, function ( state )
		cast = 2.5 / state.sHaste
		state.cooldowns[elemental_blast] = 12.0
	
		if state.pBuffs[ancestral_swiftness].up and state.pBuffs[maelstrom_weapon].count < 5 then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
		elseif state.pBuffs[maelstrom_weapon].up then
			cast = cast * ( 1 - (0.2 * state.pBuffs[maelstrom_weapon].count) )
	
			state.pBuffs[maelstrom_weapon].up		= false
			state.pBuffs[maelstrom_weapon].count	= 0
			state.pBuffs[maelstrom_weapon].remains	= 0
		end
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast
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

mod:AddAbility( feral_spirit, 51533 )
	mod:AddHandler( feral_spirit, function ( state )
		cast = state.sGCD
	
		state.cooldowns[feral_spirit] = ttCooldown(51533)
	
		return cast
	end )

mod:AddAbility( fire_elemental_totem, 2894 )
	mod:AddHandler( fire_elemental_totem, function ( state )
		cast = 1.0
		state.cooldowns[fire_elemental_totem] = ttCooldown(2894)
	
		state.totems[totem_fire].up			= true
		state.totems[totem_fire].name		= fire_elemental_totem
		state.totems[totem_fire].remains	= 60
	
		return cast
	end )

mod:AddAbility( fire_nova, 1535 )
	mod:AddHandler( fire_nova, function ( state )
		cast = state.sGCD
		state.cooldowns[fire_nova] = 4.0
	
		state.pBuffs[unleash_flame].up			= false
		state.pBuffs[unleash_flame].count		= 0
		state.pBuffs[unleash_flame].remains		= 0
	
		return cast
	end )

mod:AddAbility( flame_shock, 8050 )
	mod:AddHandler( flame_shock, function ( state )
		cast = state.sGCD

		state.cooldowns[flame_shock] = 6.0
		state.cooldowns[frost_shock] = 6.0
		state.cooldowns[earth_shock] = 6.0

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

mod:AddAbility( frost_shock, 8056 )
	mod:AddHandler( frost_shock, function ( state )
		cast = state.sGCD

		if state.glyphs[frost_shock] then
			state.cooldowns[flame_shock] = 4.0
			state.cooldowns[frost_shock] = 4.0
			state.cooldowns[earth_shock] = 4.0
		else
			state.cooldowns[flame_shock] = 6.0
			state.cooldowns[frost_shock] = 6.0
			state.cooldowns[earth_shock] = 6.0
		end

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

mod:AddAbility( lava_lash, 60103 )
	mod:AddHandler( lava_lash, function ( state )
		cast = state.mGCD
		state.cooldowns[lava_lash] = 10.0

		return cast
	end )

mod:AddAbility( lifeblood, 121279, 'offGCD', 'profession' )
	mod:AddHandler( lifeblood, function ( state )
		cast = 0
	
		state.cooldowns[lifeblood] = 120
	
		state.pBuffs[lifeblood].up		= true
		state.pBuffs[lifeblood].count	= 1
		state.pBuffs[lifeblood].remains	= 20
	
		local lbBenefit = 2880
		if state.pBuffs[flurry].up then
			lbBenefit = lbBenefit * 1.5
		end

		state.shRating = state.shRating + lbBenefit
		state.mhRating = state.mhRating + lbBenefit
		state.sHaste = 1 + ( state.shRating / 42500 )
		state.mHaste = 1 + ( state.mhRating / 42500 )
	
		RecalculateHaste( state, true )
	
		return cast
	end )

mod:AddAbility( lightning_bolt, 403 )
	mod:AddHandler( lightning_bolt, function ( state )
		cast = 2.5 / state.sHaste
	
		if state.pBuffs[ancestral_swiftness].up and state.pBuffs[maelstrom_weapon].count < 5 then
			state.pBuffs[ancestral_swiftness].up		= false
			state.pBuffs[ancestral_swiftness].count		= 0
			state.pBuffs[ancestral_swiftness].remains	= 0
	
			cast = 0
		elseif state.pBuffs[maelstrom_weapon].up then
			cast = cast * (1 - (0.2 * state.pBuffs[maelstrom_weapon].count))
	
			state.pBuffs[maelstrom_weapon].up		= false
			state.pBuffs[maelstrom_weapon].count	= 0
			state.pBuffs[maelstrom_weapon].remains	= 0
		end
	
		if cast < state.sGCD then cast = state.sGCD end
		return cast
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

mod:AddAbility( stormblast, 115356 )
	mod:AddHandler( stormblast, function ( state )
		cast = state.mGCD
	
		state.cooldowns[stormblast] = 8.0
		state.cooldowns[stormstrike] = 8.0
	
		if state.set_bonuses['t15'] >= 2 then
			state.pBuffs[maelstrom_weapon].up		= true
			state.pBuffs[maelstrom_weapon].count	= state.pBuffs[maelstrom_weapon].count + 2
			state.pBuffs[maelstrom_weapon].remains	= 30
	
			if state.pBuffs[maelstrom_weapon].count > 5 then state.pBuffs[maelstrom_weapon].count = 5 end
		end
	
		return cast
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

mod:AddAbility( stormstrike, 51876 )
	mod:AddHandler( stormstrike, function ( state )
		cast = state.mGCD
		state.cooldowns[stormstrike] = 8.0
	
		if state.set_bonuses['t15'] >= 2 then
			state.pBuffs[maelstrom_weapon].up		= true
			state.pBuffs[maelstrom_weapon].count	= state.pBuffs[maelstrom_weapon].count + 2
			state.pBuffs[maelstrom_weapon].remains	= 30
	
			if state.pBuffs[maelstrom_weapon].count > 5 then state.pBuffs[maelstrom_weapon].count = 5 end
		end
	
		return cast
	end )

mod:AddAbility( synapse_springs, 126731, 'offGCD', 'profession' )
	mod:AddHandler( synapse_springs, function ( state )
		cast = 0
	
		state.cooldowns[synapse_springs] = 60
	
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

mod:AddAbility( virmens_bite, 76089, 'item', 'offGCD', 'consumable' )
	mod:AddHandler( virmens_bite, function ( state )
		cast = 0
		state.cooldowns[virmens_bite] = 120
	
		state.pBuffs[virmens_bite].up		= true
		state.pBuffs[virmens_bite].count	= 1
		state.pBuffs[virmens_bite].remains	= 25
	
		return cast
	end )

mod:AddAbility( wind_shear, 57994, 'offGCD', 'interrupt' )
	mod:AddHandler( wind_shear, function ( state )
		cast = 0
		state.cooldowns[wind_shear] = 12
	
		state.tCast = 0
	
		return cast
	end )

mod:AddAbility( windfury_weapon, 57994, 'precombat' )
	mod:AddHandler( windfury_weapon, function ( state )
		cast = state.sGCD
	
		state.pBuffs[windfury_weapon].up	= true
		state.pBuffs[windfury_weapon].count 	= 1
		state.pBuffs[windfury_weapon].remains 	= 3600
	
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
	flurry,
	heroism,
	lifeblood,
	lightning_shield,
	maelstrom_weapon,
	spiritwalkers_grace,
	stormlash_totem,
	time_warp,
	unleash_flame,
	virmens_bite
}

mod.pDebuffsToTrack		= {
	insanity,
	exhaustion,
	sated,
	temporal_displacement
}

mod.tDebuffsToTrack		= {
	flame_shock,
	stormstrike,
	unleashed_fury
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
					windfury_weapon,
					'',
					'/actions.precombat+=windfury_weapon,weapon=main',
					function( state )
						if not state.pBuffs[windfury_weapon].up then
							return windfury_weapon
						end
						return nil
					end )

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
					synapse_springs,
					'Gloves',
					'actions+=/use_item,name=[gloves]',
					function( state )
						if state.items[synapse_springs] then
							return synapse_springs
						end
					end )

mod:AddToActionList('cooldown',
					stormlash_totem,
					'',
					'actions+=/stormlash_totem,if=!active&!buff.stormlash.up&(buff.bloodlust.up|time>=60)',
					function( state )
						if (not state.pBuffs[stormlash_totem].up) and state.combatTime > 5 then -- or state.pBuffs[bloodlust].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) ) then
							return stormlash_totem
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					virmens_bite,
					'Potion', -- removed combat time check.
					'actions+=/virmens_bite_potion,if=time>60&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active|target.time_to_die<=60)',
					function ( state )
						if ( state.totems[totem_fire].name == fire_elemental_totem or state.timeToDie <= 60 ) then
							return virmens_bite
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					blood_fury,
					'',
					'actions+=/blood_fury',
					function( state )
						if IsUsableSpell(blood_fury) then
							return blood_fury
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					berserking,
					'',
					'actions+=/berserking',
					function( state )
						if IsUsableSpell(berserking) then
							return berserking
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					elemental_mastery,
					'PE+GFET',
					'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&(talent.primal_elementalist.enabled&glyph.fire_elemental_totem.enabled&(cooldown.fire_elemental_totem.remains=0|cooldown.fire_elemental_totem.remains>=80))',
					function( state )
						if state.talents[elemental_mastery] and	(state.talents[primal_elementalist] and state.glyphs[fire_elemental_totem] and (state.cooldowns[fire_elemental_totem] == 0 or state.cooldowns[fire_elemental_totem] >= 80)) then
							return elemental_mastery
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					elemental_mastery,
					'PE-GFET',
					'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&(talent.primal_elementalist.enabled&!glyph.fire_elemental_totem.enabled&(cooldown.fire_elemental_totem.remains=0|cooldown.fire_elemental_totem.remains>=50))',
					function( state )
						if state.talents[elemental_mastery] and	(state.talents[primal_elementalist] and not state.glyphs[fire_elemental_totem] and (state.cooldowns[fire_elemental_totem] == 0 or state.cooldowns[fire_elemental_totem] >= 50)) then
							return elemental_mastery
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					elemental_mastery,
					'-PE',
					'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&!talent.primal_elementalist.enabled',
					function( state )
						if state.talents[elemental_mastery] and	not state.talents[primal_elementalist] then
							return elemental_mastery
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					fire_elemental_totem,
					'',
					'actions+=/fire_elemental_totem,if=!active',
					function( state )
						-- if you have Primal Elementalist, make sure that you're not in a situation to try to drop Fire Elemental Totem with Earth Elemental Totem up or they'll both go poof (two pet bars).
						if (not state.talents[primal_elementalist] or state.totems[totem_earth].name ~= earth_elemental_totem) and (state.totems[totem_fire].name ~= fire_elemental_totem) then
							return fire_elemental_totem
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					ascendance,
					'',
					'actions+=/ascendance,if=cooldown.strike.remains>=3',
					function( state )
						if state.cooldowns[stormstrike] >= 3 then
							return ascendance
						end
						return nil
					end )

mod:AddToActionList('cooldown',
					lifeblood,
					'',
					'actions+=/lifeblood,if=(glyph.fire_elemental_totem.enabled&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active))|!glyph.fire_elemental_totem.enabled',
					function( state )
						if not state.glyphs[fire_elemental_totem] or (state.glyphs[fire_elemental_totem] and state.totems[totem_fire].name == fire_elemental_totem) then
							return lifeblood
						end
						return nil
					end )

-- COOLDOWN --
--------------


---------
-- AOE --


mod:AddToActionList('aoe',
					fire_nova,
					'4+',
					'actions.aoe=fire_nova,if=active_flame_shock>=4',
					function( state )
						if state.fsCount >= 4 then
							return fire_nova
						end
						return nil
					end )

mod:AddToActionList('aoe',
					fire_nova,
 					'Wait',
 					'actions.aoe+=/wait,sec=cooldown.fire_nova.remains,if=active_flame_shock>=4&cooldown.fire_nova.remains<0.67',
 					function( state )
						if state.cooldowns[fire_nova] < 0.67 and state.fsCount >= 4 then
							return fire_nova, state.cooldowns[fire_nova]
						end
						return nil
					end )

mod:AddToActionList('aoe',
					magma_totem,
					'6+',
					'actions.aoe+=/magma_totem,if=active_enemies>5&!totem.fire.active',
					function( state )
						if not state.totems[totem_fire].up and state.tCount > 5 then
							return magma_totem
						end
						return nil
					end )

mod:AddToActionList('aoe',
					searing_totem,
					'5-',
					'actions.aoe+=/searing_totem,if=active_enemies<=5&!totem.fire.active',
					function( state )
						if not state.totems[totem_fire].up and state.tCount <= 5 then
							return searing_totem
						end
						return nil
					end )

mod:AddToActionList('aoe',
					lava_lash,
					'FS',
					'actions.aoe+=/lava_lash,if=dot.flame_shock.ticking',
					function( state )
						if state.tDebuffs[flame_shock].up then
							return lava_lash
						end
						return nil
					end )

mod:AddToActionList('aoe',
					elemental_blast,
					'MW1+',
					'actions.aoe+=/elemental_blast,if=talent.elemental_blast.enabled&buff.maelstrom_weapon.react>=1',
					function( state )
						if state.talents[elemental_blast] and state.pBuffs[maelstrom_weapon].count >= 1 then
							return elemental_blast, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					chain_lightning,
					'MW3+',
					'actions.aoe+=/chain_lightning,if=active_enemies>=2&buff.maelstrom_weapon.react>=3',
					function( state )
						if state.tCount >= 2 and state.pBuffs[maelstrom_weapon].count >= 3 then
							return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					unleash_elements,
					'',
					'actions.aoe+=/unleash_elements',
					function( state )
						if state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
							return unleash_elements
						end
						return nil
					end )

mod:AddToActionList('aoe',
					flame_shock,
					'Cycle',
					'actions.aoe+=/flame_shock,cycle_targets=1,if=!ticking',
					function( state )
						-- This only works if Magma Totem is up and hitting things, otherwise tCount will == fsCount.
						if state.tDebuffs[flame_shock].up and state.tCount > state.fsCount then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('aoe',
					flame_shock,
					'',
					'N/A - use FS if it will expire before it comes off CD again',
					function( state )
						if not state.tDebuffs[flame_shock].up or state.tDebuffs[flame_shock].remains < 6 then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('aoe',
					stormblast,
					'',
					'actions.aoe+=stormblast',
					function( state )
						if state.pBuffs[ascendance].up then
							return stormblast
						end
						return nil
					end )

mod:AddToActionList('aoe',
					fire_nova,
					'3+',
					'actions.aoe+=fire_nova,if=active_flame_shock>=3',
					function( state )
						if state.fsCount >= 3 then
							return fire_nova
						end
						return nil
					end )

mod:AddToActionList('aoe',
					chain_lightning,
					'2+MW1+',
					'actions.aoe+=/chain_lightning,if=active_enemies>=2&buff.maelstrom_weapon.react>=1',
					function( state )
						if state.tCount >= 2 and state.pBuffs[maelstrom_weapon].count >= 1 then
							return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
						end
						return nil
					end )

mod:AddToActionList('aoe',
					stormstrike,
					'',
					'actions.aoe+=/stormstrike',
					function( state )
						if not state.pBuffs[ascendance].up then
							return stormstrike
						end
						return nil
					end )

mod:AddToActionList('aoe',
					earth_shock,
					'',
					'actions.aoe+=/earth_shock,if=active_enemies<4',
					function( state )
						-- Need to bring in FS counter for this.
						if state.tCount < 4 then
							return earth_shock
						end
						return nil
					end )

mod:AddToActionList('aoe',
					feral_spirit,
					'',
					'actions.aoe+=/feral_spirit',
					function( state )
						return feral_spirit
					end )

mod:AddToActionList('aoe',
					earth_elemental_totem,
					'',
					'actions.aoe+=/earth_elemental_totem,if=!active&cooldown.fire_elemental_totem.remains>=50',
					function( state )
						if not (state.talents[primal_elementalist] and state.totems[totem_fire].name == fire_elemental_totem) and (state.totems[totem_earth].name ~= earth_elemental_totem and state.cooldowns[fire_elemental_totem] >= 50) then
							return earth_elemental_totem
						end
						return nil
					end )

mod:AddToActionList('aoe',
					spiritwalkers_grace,
					'',
					'actions.aoe+=/spiritwalkers_grace,moving=1',
					function( state )
						if state.moving then
							return spiritwalkers_grace
						end
						return nil
					end )

mod:AddToActionList('aoe',
					fire_nova,
					'',
					'actions.aoe+=/fire_nova,if=active_flame_shock>=1',
					function( state )
						if state.fsCount >= 1 then
							return fire_nova
						end
						return nil
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
					arcane_torrent,
					'',
					'actions+=/arcane_torrent',
					function( state )
						if IsUsableSpell(arcane_torrent) and state.tCast > 0 then
							return arcane_torrent
						end
						return nil
					end )
					
	-- TBD: Add Symbiosis: Solar Beam if available?

mod:AddToActionList('single',
					searing_totem,
					'',
					'actions.single=searing_totem,if=!totem.fire.active',
					function( state )
						if (not state.totems[totem_fire].up) then
							return searing_totem
						end
						return nil
					end )

mod:AddToActionList('single',
					unleash_elements,
					'UF|T16',
					'actions.single+=/unleash_elements,if=(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)',
					function( state )
						if (state.talents[unleashed_fury] or state.set_bonuses['t16'] >= 2) and state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
							return unleash_elements
						end
						return nil
					end )

mod:AddToActionList('single',
					spiritwalkers_grace,
					'EB',
					'actions.single+=/spiritwalkers_grace,moving=1',
					function( state )
						if state.moving and state.talents[elemental_blast] then
							return spiritwalkers_grace
						end
						return nil
					end )

mod:AddToActionList('single',
					elemental_blast,
					'',
					'actions.single+=/elemental_blast,if=talent.elemental_blast.enabled&buff.maelstrom_weapon.react>=1',
					function( state )
						if state.talents[elemental_blast] and (state.pBuffs[maelstrom_weapon].count >= 1 or state.pBuffs[ancestral_swiftness].up) then
							if state.pBuffs[ancestral_swiftness].up or state.pBuffs[maelstrom_weapon].count == 5 then
								return elemental_blast
							else
								return elemental_blast, nil, true
							end
						end
						return nil
					end )

mod:AddToActionList('single',
					lightning_bolt,
					'MW5',
					'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react=5',
					function( state )
						if state.tCount < 3 and (state.pBuffs[maelstrom_weapon].count == 5) then
							return lightning_bolt
						end
						return nil
					end )

mod:AddToActionList('single',
					chain_lightning,
					'3+MW5',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.tCount >= 3 and (state.pBuffs[maelstrom_weapon].count == 5) then
							return chain_lightning
						end
						return nil
					end )

mod:AddToActionList('single',
					feral_spirit,
					'T15',
					'actions.single+=/feral_spirit,if=set_bonus.tier15_4pc_melee=1',
					function( state )
						if state.set_bonuses['t15'] >= 4 then
							return feral_spirit
						end
						return nil
					end )

mod:AddToActionList('single',
					stormblast,
					'',
					'actions.single+=/stormblast',
					function( state )
						if state.pBuffs[ascendance].up then
							return stormblast
						end
						return nil
					end )

mod:AddToActionList('single',
					stormstrike,
					'',
					'actions.single+=/stormstrike',
					function( state )
						if not state.pBuffs[ascendance].up then
							return stormstrike
						end
						return nil
					end )

mod:AddToActionList('single',
					flame_shock,
					'UF&FS0',
					'actions.single+=/flame_shock,if=buff.unleash_flame.up&!ticking',
					function( state )
						if state.pBuffs[unleash_flame].up and (not state.tDebuffs[flame_shock].up) then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('single',
					lava_lash,
					'',
					'actions.single+=/lava_lash',
					function( state )
						return lava_lash
					end )

mod:AddToActionList('single',
					lightning_bolt,
					'T15',
					'actions.single+=/lightning_bolt,if=set_bonus.tier15_2pc_melee=1&buff.maelstrom_weapon.react>=4&!buff.ascendance.up',
					function( state )
						if state.tCount < 3 and (state.set_bonuses['t15'] >= 2 and (not state.pBuffs[ancestral_swiftness].up) and state.pBuffs[maelstrom_weapon].count >= 4 and (not state.pBuffs[ascendance].up)) then
							return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					chain_lightning,
					'3+T15',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.tCount >= 3 and (state.set_bonuses['t15'] >= 2 and (not state.pBuffs[ancestral_swiftness].up) and state.pBuffs[maelstrom_weapon].count >= 4 and (not state.pBuffs[ascendance].up)) then
							return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					flame_shock,
					'UF|FS0',
					'actions.single+=/flame_shock,if=(buff.unleash_flame.up&(dot.flame_shock.remains<10|set_bonus.tier16_2pc_melee=0))|!ticking',
					function( state )
						if ( state.pBuffs[unleash_flame].up and ( (state.tDebuffs[flame_shock].remains < 10) or (state.set_bonuses['t16'] < 2) ) ) or ( not state.tDebuffs[flame_shock].up ) then
							return flame_shock
						end
						return nil
					end )

mod:AddToActionList('single',
					unleash_elements,
					'',
					'actions.single+=/unleash_elements',
					function( state )
						if state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
							return unleash_elements
						end
						return nil
					end )

mod:AddToActionList('single',
					frost_shock,
					'Glyph',
					'actions.single+=/frost_shock,if=glyph.frost_shock.enabled&set_bonus.tier14_4pc_melee=0',
					function( state )
						if state.glyphs[frost_shock] and state.set_bonuses['t14'] < 4 then
							return frost_shock
						end
						return nil
					end )

mod:AddToActionList('single',
					lightning_bolt,
					'MW3+',
					'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react>=3&!buff.ascendance.up',
					function( state )
						if state.tCount < 3 and (state.pBuffs[maelstrom_weapon].count >= 3 and not state.pBuffs[ancestral_swiftness].up and not state.pBuffs[ascendance].up) then
							-- Hardcasting.
							return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					chain_lightning,
					'3+MW3+',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.tCount >= 3 and (state.pBuffs[maelstrom_weapon].count >= 3 and not state.pBuffs[ancestral_swiftness].up and not state.pBuffs[ascendance].up) then
							-- Hardcasting.
							return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					ancestral_swiftness,
					'MW<2',
					'actions.single+=/ancestral_swiftness,if=talent.ancestral_swiftness.enabled&buff.maelstrom_weapon.react<2',
					function( state )
						if state.talents[ancestral_swiftness] and state.pBuffs[maelstrom_weapon].count < 2 then
							return ancestral_swiftness
						end
						return nil
					end )

mod:AddToActionList('single',
					lightning_bolt,
					'AS',
					'actions.single+=/lightning_bolt,if=buff.ancestral_swiftness.up',
					function( state )
						if state.tCount < 3 and state.pBuffs[ancestral_swiftness].up then
							return lightning_bolt
						end
						return nil
					end )

mod:AddToActionList('single',
					chain_lightning,
					'3+AS',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.tCount >= 3 and state.pBuffs[ancestral_swiftness].up then
							return chain_lightning
						end
						return nil
					end )

mod:AddToActionList('single',
					earth_shock,
					'',
					'actions.single+=/earth_shock,if=(!glyph.frost_shock.enabled|set_bonus.tier14_4pc_melee=1)',
					function( state )
						if (not state.glyphs[frost_shock]) or state.set_bonuses['t14'] >= 4 then
							return earth_shock
						end
						return nil
					end )

mod:AddToActionList('single',
					feral_spirit,
					'',
					'actions.single+=/feral_spirit',
					function( state )
						return feral_spirit
					end )

mod:AddToActionList('single',
					earth_elemental_totem,
					'',
					'actions.single+=/earth_elemental_totem,if=!active',
					function( state )
						if not (state.talents[primal_elementalist] and state.totems[totem_fire].name == fire_elemental_totem) and (state.totems[totem_earth].name ~= earth_elemental_totem and state.cooldowns[fire_elemental_totem] >= 50) then
							return earth_elemental_totem
						end
						return nil
					end )

mod:AddToActionList('single',
					lightning_bolt,
					'MW2+',
					'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react>1&!buff.ascendance.up',
					function( state )
						if state.tCount < 3 and (state.pBuffs[maelstrom_weapon].count > 1 and not state.pBuffs[ancestral_swiftness].up and not state.pBuffs[ascendance].up) then
							-- Hardcasting
							return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					chain_lightning,
					'3+MW2+',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.tCount >= 3 and (state.pBuffs[maelstrom_weapon].count > 1 and not state.pBuffs[ancestral_swiftness].up and not state.pBuffs[ascendance].up) then
							-- Hardcasting
							return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5)
						end
						return nil
					end )

mod:AddToActionList('single',
					fire_nova,
					'2+',
					'http://www.icy-veins.com/enhancement-shaman-wow-pve-dps-rotation-cooldowns-abilities',
					function( state )
						if state.fsCount >= 2 then
							return fire_nova
						end
						return nil
					end )

mod:AddToActionList('single',
					searing_totem,
					'Refresh',
					'N/A',
					function( state )
						if state.totems[totem_fire].name == searing_totem and (state.totems[totem_fire].remains < 15) and ( not Hekili.DB.profile['Show Cooldowns'] or ( state.cooldowns[fire_elemental_totem] > (state.totems[totem_fire].remains + 20) ) ) then
							return searing_totem
						end
						return nil
					end )

-- SINGLE --
------------


-------------------
-- TIER CHECKING --

local tSlots = {
	'Helmet',
	'Spaulders',
	'Cuirass',
	'Grips',
	'Legguards'
}

local function tierCheck( setName, affix )
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
	-- Unleashed Fury
	state.mHaste = state.mHaste * 1.10

	state.mGCD = 1.5
	state.tGCD = 1.0

	state.sGCD = 1.5 / state.sHaste
	if state.sGCD < 1.0 then state.sGCD = 1.0 end

end

-- HASTE --
-----------


function mod:RefreshState( state )

	state.time			= GetTime()

	if Hekili.CombatStart > 0 then
		state.combatTime 	= state.time - Hekili.CombatStart
	else
		state.combatTime	= 0
	end
	
	state.moving		= (GetUnitSpeed("player") > 0)
	
	state.timeToDie		= Hekili.GetTTD()
	state.tCount		= Hekili:TargetCount()
	state.fsCount		= Hekili:AuraCount(flame_shock)

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

		state.pBuffs[windfury_weapon]		= {}
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
	local MH, mhExpires, _, OH, ohExpires = GetWeaponEnchantInfo()
	if MH and ttWeaponEnchant(GetInventorySlotInfo("MainHandSlot")) == "Windfury" then
		state.pBuffs[windfury_weapon].up		= true
		state.pBuffs[windfury_weapon].count		= 1
		state.pBuffs[windfury_weapon].remains	= mhExpires / 1000
	else
		state.pBuffs[windfury_weapon].up		= false
		state.pBuffs[windfury_weapon].count		= 0
		state.pBuffs[windfury_weapon].remains	= 0
	end

	if OH and ttWeaponEnchant(GetInventorySlotInfo("SecondaryHandSlot")) == "Flametongue" then
		state.pBuffs[flametongue_weapon].up			= true
		state.pBuffs[flametongue_weapon].count		= 1
		state.pBuffs[flametongue_weapon].remains	= ohExpires / 1000
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
	state.items[virmens_bite]		= false

	-- Engineering Gloves
	local gSlot = GetInventorySlotInfo("HandsSlot")
	local gloves = GetInventoryItemID("player", gSlot)

	state.cooldowns[synapse_springs]	= 999
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

	-- Virmen's Bite
	local vbCount = GetItemCount(virmens_bite, false)
	state.cooldowns[virmens_bite]			= 999
	if vbCount > 0 then
		state.items[virmens_bite]			= true

		local cdStart, cdLength, cdEnable = GetItemCooldown(76089)

		if (cdStart == 0 and cdLength == 0) then
			cdStart, cdLength = GetSpellCooldown(lightning_shield)
		end

		if cdStart > 0 then
			state.cooldowns[virmens_bite] = cdStart + cdLength - state.time
		else
			state.cooldowns[virmens_bite] = 0
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

		if remains < 0 then remains = 0 end

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


function mod:AdvanceState( state, elapsed )

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
					state.pBuffs[k].up		= false
					state.pBuffs[k].count		= 0
					state.pBuffs[k].remains		= 0

					-- Update Haste effects.
					if k == lifeblood then
						local lbBenefit = 2880
						if state.pBuffs[flurry].up then
							lbBenefit = lbBenefit * 1.5
						end
						state.shRating = state.shRating - lbBenefit
						state.sHaste = 1 + ( state.shRating / 42500 )
						state.mhRating = state.mhRating - lbBenefit
						state.mHaste = 1 + ( state.mhRating / 42500 )
						RecalculateHaste( state )
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


	-------------------------------
	-- MAELSTROM WEAPON GUESSING --

	-- Maelstrom Weapon uses 10 procs per minute prior to counting haste.
	local mhSwing = ttWeaponSpeed( GetInventorySlotInfo("MainHandSlot") )
	local mhPPH = 0

	if mhSwing then
		mhPPH = mhSwing * 10 / 60
	end

	local ohSwing = ttWeaponSpeed( GetInventorySlotInfo("SecondaryHandSlot") )
	local ohPPH = 0

	if ohSwing then
		ohPPH = mhSwing * 10 / 60
	end

end