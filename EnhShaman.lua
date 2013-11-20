-- EnhShaman.lua
-- Default Enhancement Shaman module for Hekili.
-- Hekili of <Turbo Cyborg Ninjas> - Ner'zhul [A]
-- October 2013

local mod = Hekili.NewModule("Enhancement Shaman SimC 5.4.1", "Shaman", "Enhancement", true, true, true)

-- mod = Hekili:NewModule("Enhancement 5.4.1", "AceEvent-3.0")

-- Spells
local ancestral_swiftness 	= GetSpellInfo(16188)
local arcane_torrent		= GetSpellInfo(28730)
local berserking			= GetSpellInfo(26297)
local blood_fury			= GetSpellInfo(20572)
local chain_lightning 		= GetSpellInfo(421)
local earth_elemental_totem	= GetSpellInfo(2062)
local earth_shock 			= GetSpellInfo(8042)
local elemental_blast 		= GetSpellInfo(117014)
local feral_spirit 			= GetSpellInfo(51533)
local fire_nova 			= GetSpellInfo(1535)
local flame_shock 			= GetSpellInfo(8050)
local flametongue_weapon 	= GetSpellInfo(8024)
local flurry				= GetSpellInfo(16282)
local frost_shock			= GetSpellInfo(8056)
local lava_lash 			= GetSpellInfo(60103)
local lightning_bolt 		= GetSpellInfo(403)
local lightning_shield 		= GetSpellInfo(324)
local maelstrom_weapon 		= GetSpellInfo(51530)
local magma_totem 			= GetSpellInfo(8190)
local searing_totem 		= GetSpellInfo(3599)
local shamanistic_rage 		= GetSpellInfo(30823)
local stormblast 			= GetSpellInfo(115356)
local stormlash_totem		= GetSpellInfo(120668)
local stormstrike			= GetSpellInfo(51876)
local synapse_springs		= GetSpellInfo(126731)
local unleash_elements 		= GetSpellInfo(73680)
local unleash_flame 		= GetSpellInfo(73683)
local unleashed_fury 		= GetSpellInfo(117012)
local wind_shear			= GetSpellInfo(57994)
local windfury_weapon 		= GetSpellInfo(8232)

local ascendance 			= GetSpellInfo(114049)
local fire_elemental_totem 	= GetSpellInfo(2894)
local spiritwalkers_grace	= GetSpellInfo(79206)

local ancient_hysteria		= GetSpellInfo(90355)
local bloodlust 			= GetSpellInfo(2825)
local elemental_mastery 	= GetSpellInfo(16166)
local heroism 				= GetSpellInfo(32182)
local lifeblood				= GetSpellInfo(121279)
local time_warp 			= GetSpellInfo(80353)

local exhaustion			= GetSpellInfo(57723)
local insanity				= GetSpellInfo(95809)
local sated					= GetSpellInfo(57724)
local temporal_displacement	= GetSpellInfo(80354)

local virmens_bite			= "Virmen's Bite"

-- Talents that we may need to check for, but aren't listed above.
local primal_elementalist	= GetSpellInfo(117013) -- 'Primal Elementalist'
local echo_of_the_elements	= GetSpellInfo(108283) -- 'Echo of the Elements'


-- Ability Flags (for enable/disable in rotation)
mod.flags = {}

mod.flags[ancestral_swiftness] = {
	talent		= true,
	cooldown	= 90
}

mod.flags[arcane_torrent] = {
	racial		= true,
	cooldown	= 120,
	interrupt	= true
}

mod.flags[berserking] = {
	racial		= true,
	cooldown	= 180
}

mod.flags[blood_fury] = {
	racial		= true,
	cooldown	= 120
}

mod.flags[earth_elemental_totem] = {
	cooldown	= Hekili.ttCooldown(2062)
}

mod.flags[flametongue_weapon] = {
	precombat	= true
}

mod.flags[lightning_shield] = {
	precombat	= true
}

mod.flags[stormlash_totem] = {
	cooldown	= 300
}

mod.flags[synapse_springs] = {
	cooldown	= 60,
	profession	= true
}

mod.flags[windfury_weapon] = {
	precombat	= true
}

mod.flags[ascendance] = {
	cooldown	= Hekili.ttCooldown(114049)
}

mod.flags[fire_elemental_totem] = {
	cooldown	= Hekili.ttCooldown(2894)
}

mod.flags[spiritwalkers_grace] = {
	cooldown	= Hekili.ttCooldown(79206),
	movement	= true
}

mod.flags[bloodlust] = {
	bloodlust	= true,
	cooldown	= 300
}

mod.flags[elemental_mastery] = {
	talent		= true,
	cooldown	= 90
}

mod.flags[heroism] = {
	bloodlust	= true,
	cooldown	= 300
}

mod.flags[lifeblood] = {
	profession	= true,
	cooldown	= 120
}

mod.flags[virmens_bite] = {
	consumable	= true,
	cooldown	= 120
}

mod.flags[wind_shear] = {
	interrupt	= true
}


-- We have to keep a table of pre-haste cast times because MW/etc. will affect them.
mod.cast_time = {}
mod.cast_time[chain_lightning]		= 3.0
mod.cast_time[elemental_blast]		= 2.0
mod.cast_time[lightning_bolt]		= 2.5


-- Burst haste CDs.
mod.burstHaste = {}
mod.burstHaste[ancient_hysteria] = 1.30
mod.burstHaste[bloodlust] = 1.30
mod.burstHaste[elemental_mastery] = 1.30
mod.burstHaste[heroism] = 1.30
mod.burstHaste[time_warp] = 1.30



-- totem indexes
local totem_fire	= 1
local totem_earth	= 2
local totem_water	= 3
local totem_air		= 4


-- we would need to make glyph name aliases (for localization) if any were different from "Glyph of __________" spell names.


mod.pBuffsToTrack			= {
	ancestral_swiftness,
	ancient_hysteria,
	ascendance,
	bloodlust,
	elemental_mastery,
	flurry,
	heroism,
	lifeblood,
	lightning_shield,
	maelstrom_weapon,
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



--------------------------
-- Cooldown Action List --
--------------------------
mod.state['CD'].actions = {
 
	{	act		= bloodlust,
		desc	= '',
		SimC	= 'actions+=/bloodlust,if=target.health.pct<25|time>5',
		check	= function( state )
			-- TBI:  Snapshot Target Health, predict target health, track combat length.
			if (IsUsableSpell(bloodlust) and state.tHealthPct < 25 and state.combatTime > 5)
				and (not state.pDebuffs[sated].up and not state.pDebuffs[exhaustion].up and not state.pDebuffs[temporal_displacement].up and not state.pDebuffs[insanity].up) then
				return bloodlust
			end
			return nil
		end },
		
	{	act		= heroism,
		desc	= '',
		SimC	= 'actions+=/heroism,if=target.health.pct<25|time>5',
		check	= function( state )
			-- TBI:  Snapshot Target Health, predict target health, track combat length.
			if (IsUsableSpell(heroism) and state.tHealthPct < 25 and state.combatTime > 5)
				and (not state.pDebuffs[sated].up and not state.pDebuffs[exhaustion].up and not state.pDebuffs[temporal_displacement].up and not state.pDebuffs[insanity].up) then
				return heroism
			end
			return nil
		end },
		
	{	act		= synapse_springs,
		desc	= 'Gloves',
		SimC	= 'actions+=/use_item,name=[gloves]',
		check	= function( state )
			if state.items[synapse_springs] then
				return synapse_springs
			end
		end },
		
	{	act		= stormlash_totem,
		desc	= '',
		SimC	= 'actions+=/stormlash_totem,if=!active&!buff.stormlash.up&(buff.bloodlust.up|time>=60)',
		check	= function( state )
			-- TBI: Combat time.
			if (not state.pBuffs[stormlash_totem].up) and ( (state.pBuffs[heroism].up or state.pBuffs[bloodlust].up or state.pBuffs[ancient_hysteria].up or state.pBuffs[time_warp].up) or state.combatTime >= 60 ) then
				return stormlash_totem
			end
			return nil
		end },

	{	act		= virmens_bite,
		desc	= 'Potion',
		SimC	= 'actions+=/virmens_bite_potion,if=time>60&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active|target.time_to_die<=60)',
		check	= function ( state )
			-- TBI: Combat time.
			if state.combatTime > 60 and ( (state.totems[totem_fire].up and state.totems[totem_fire].name == fire_elemental_totem) or state.timeToDie <= 60 ) then
				return virmens_bite
			end
			return nil
		end },
		
	{	act		= blood_fury,
		desc	= '',
		SimC	= 'actions+=/blood_fury',
		check	= function( state )
			if IsUsableSpell(blood_fury) then
				return blood_fury
			end
			return nil
		end },
		
	{	act		= berserking,
		desc	= '',
		SimC	= 'actions+=/berserking',
		check	= function( state )
			if IsUsableSpell(berserking) then
				return berserking
			end
			return nil
		end },
		
	{	act		= elemental_mastery,
		desc	= 'PE+GFET',
		SimC	= 'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&(talent.primal_elementalist.enabled&glyph.fire_elemental_totem.enabled&(cooldown.fire_elemental_totem.remains=0|cooldown.fire_elemental_totem.remains>=80))',
		check	= function( state )
			if state.talents[elemental_mastery] and	(state.talents[primal_elementalist] and state.glyphs[fire_elemental_totem] and (state.cooldowns[fire_elemental_totem] == 0 or state.cooldowns[fire_elemental_totem] >= 80)) then
				return elemental_mastery
			end
			return nil
		end },
		
	{	act		= elemental_mastery,
		desc	= 'PE-GFET',
		SimC	= 'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&(talent.primal_elementalist.enabled&!glyph.fire_elemental_totem.enabled&(cooldown.fire_elemental_totem.remains=0|cooldown.fire_elemental_totem.remains>=50))',
		check	= function( state )
			if state.talents[elemental_mastery] and	(state.talents[primal_elementalist] and not state.glyphs[fire_elemental_totem] and (state.cooldowns[fire_elemental_totem] == 0 or state.cooldowns[fire_elemental_totem] >= 50)) then
				return elemental_mastery
			end
			return nil
		end },
		
	{	act		= elemental_mastery,
		desc	= '-Primal',
		SimC	= 'actions+=/elemental_mastery,if=talent.elemental_mastery.enabled&!talent.primal_elementalist.enabled',
		check	= function( state )
			if state.talents[elemental_mastery] and	not state.talents[primal_elementalist] then
				return elemental_mastery
			end
			return nil
		end },

	{	act		= fire_elemental_totem,
		desc	= '',
		SimC	= 'actions+=/fire_elemental_totem,if=!active',
		check	= function( state )
			if not state.totems[totem_fire].up or state.totems[totem_fire].up and state.totems[totem_fire].name ~= fire_elemental_totem then
				return fire_elemental_totem
			end
			return nil
		end },
		
	{	act		= ascendance,
		desc	= '',
		SimC	= 'actions+=/ascendance,if=cooldown.strike.remains>=3',
		check	= function( state )
			if state.cooldowns[stormstrike] >= 3 then
				return ascendance
			end
			return nil
		end },
		
	{	act		= lifeblood,
		desc	= '',
		SimC	= 'actions+=/lifeblood,if=(glyph.fire_elemental_totem.enabled&(pet.primal_fire_elemental.active|pet.greater_fire_elemental.active))|!glyph.fire_elemental_totem.enabled',
		check	= function( state )
			if not state.glyphs[fire_elemental_totem] or (state.glyphs[fire_elemental_totem] and state.totems[totem_fire].up and state.totems[totem_fire].name == fire_elemental_totem) then
				return lifeblood
			end
			return nil
		end }
		
}


---------------------------
-- Single Target Actions --
---------------------------
mod.state['ST'].actions = {

 	{	act		= windfury_weapon,
 		desc	= '',
 		SimC	= '/actions.precombat+=windfury_weapon,weapon=main',
 		check	= function( state )
 			if not state.pBuffs[windfury_weapon].up then
 				return windfury_weapon
 			end
 			return nil
 		end },
 
 	{	act		= flametongue_weapon,
 		desc	= '',
 		SimC	= '/actions.precombat+=flametongue_weapon,weapon=off',
 		check	= function( state )
 			if not state.pBuffs[flametongue_weapon].up then
 				return flametongue_weapon
 			end
 			return nil
 		end },
 
  	{	act		= lightning_shield,
  		desc	= '',
  		SimC	= '/actions.precombat+=lightning_shield,if=!buff.lightning_shield.up',
  		check	= function( state )
  			if not state.pBuffs[lightning_shield].up then
  				return lightning_shield
  			end
  			return nil
  		end },
  
	{	act		= wind_shear,
		desc	= '',
		SimC	= 'actions=wind_shear',
		check	= function( state )
			if state.tCast > 0 then
				return wind_shear
			end
			return nil
		end },
		
	{	act		= arcane_torrent,
		desc	= '',
		SimC	= 'actions+=/arcane_torrent',
		check	= function( state )
			if IsUsableSpell(arcane_torrent) and state.tCast > 0 then
				return arcane_torrent
			end
			return nil
		end },

	-- TBD: Add Symbiosis: Solar Beam if available?
  
	{	act		= searing_totem,
		desc	= '',
		SimC	= 'actions.single=searing_totem,if=!totem.fire.active',
		check	= function( state )
			if not state.totems[totem_fire].up then
				return searing_totem
			end
			return nil
		end },
	
	{	act		= unleash_elements,
		desc	= 'UF|T16',
		SimC	= 'actions.single+=/unleash_elements,if=(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)',
		check	= function( state )
			if state.talents[unleashed_fury] or state.set_bonuses['t16'] >= 2 and state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
				return unleash_elements
			end
			return nil
		end },
	
	{	act		= elemental_blast,
		desc	= '',
		SimC	= 'actions.single+=/elemental_blast,if=talent.elemental_blast.enabled&buff.maelstrom_weapon.react>=1',
		check	= function( state )
			if state.talents[elemental_blast] and (state.pBuffs[maelstrom_weapon].count >= 1 or state.pBuffs[ancestral_swiftness].up) then
				if state.pBuffs[ancestral_swiftness].up or state.pBuffs[maelstrom_weapon].count == 5 then
					return elemental_blast
				else
					-- Hardcasting.
					return elemental_blast, nil, true
				end
			end
			return nil
		end },
	
	{	act		= lightning_bolt,
		desc	= 'MW5',
		SimC	= 'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react=5',
		check	= function( state )
			if state.pBuffs[maelstrom_weapon].count == 5 then -- and not state.pBuffs[ancestral_swiftness].up then
				return lightning_bolt
			end
			return nil
		end },
		
	{	act		= feral_spirit,
		desc	= 'T15',
		SimC	= 'actions.single+=/feral_spirit,if=set_bonus.tier15_4pc_melee=1',
		check	= function( state )
			if state.set_bonuses['t15'] >= 4 then
				return feral_spirit
			end
			return nil
		end },

	{	act		= stormblast,
		desc	= '',
		SimC	= 'actions.single+=/stormblast',
		check	= function( state )
			if state.pBuffs[ascendance].up then
				return stormblast
			end
			return nil
		end },
		
	{	act		= stormstrike,
		desc	= '',
		SimC	= 'actions.single+=/stormstrike',
		check	= function( state )
			if not state.pBuffs[ascendance].up then
			 	return stormstrike
			end
			return nil
		end },
	
	{	act		= flame_shock,
		desc	= 'UF&FS0',
		SimC	= 'actions.single+=/flame_shock,if=buff.unleash_flame.up&!ticking',
		check	= function( state )
			if state.pBuffs[unleash_flame].up and not state.tDebuffs[flame_shock].up then
				return flame_shock
			end
			return nil
		end },
			
	{	act		= lava_lash,
		desc	= '',
		SimC	= 'actions.single+=/lava_lash',
		check	= function( state )
			return lava_lash
		end },
	
	{	act		= lightning_bolt,
		desc	= 'T15',
		SimC	= 'actions.single+=/lightning_bolt,if=set_bonus.tier15_2pc_melee=1&buff.maelstrom_weapon.react>=4&!buff.ascendance.up',
		check	= function( state )
			if state.set_bonuses['t15'] >= 2 and state.pBuffs[maelstrom_weapon].count >= 4 and not state.pBuffs[ascendance].up then
				return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
			end
			return nil
		end },
	
	{	act		= flame_shock,
		desc	= 'UF|FS0',
		SimC	= 'actions.single+=/flame_shock,if=(buff.unleash_flame.up&(dot.flame_shock.remains<10|set_bonus.tier16_2pc_melee=0))|!ticking',
		check	= function( state )
			if (state.pBuffs[unleash_flame].up and (state.tDebuffs[flame_shock].remains < 10 or state.set_bonuses['t16'] < 2)) or not state.tDebuffs[flame_shock].up then
				return flame_shock
			end
			return nil
		end },
	
	{	act		= unleash_elements,
		desc	= '',
		SimC	= 'actions.single+=/unleash_elements',
		check	= function( state )
			if state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
				return unleash_elements
			end
			return nil
		end },
	
	{	act 	= frost_shock,
		desc	= 'Glyph',
		SimC	= 'actions.single+=/frost_shock,if=glyph.frost_shock.enabled&set_bonus.tier14_4pc_melee=0',
		check	= function( state )
			if state.glyphs[frost_shock] and state.set_bonuses['t14'] < 4 then
				return frost_shock
			end
			return nil
		end },
			
	{	act		= lightning_bolt,
		desc	= 'MW3+',
		SimC	= 'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react>=3&!buff.ascendance.up',
		check	= function( state )
			if state.pBuffs[maelstrom_weapon].count >= 3 and not state.pBuffs[ascendance].up then
				-- Hardcasting.
				return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
			end
			return nil
		end },
	
	{	act		= ancestral_swiftness,
		desc	= 'MW<2',
		SimC	= 'actions.single+=/ancestral_swiftness,if=talent.ancestral_swiftness.enabled&buff.maelstrom_weapon.react<2',
		check	= function( state )
			if state.talents[ancestral_swiftness] and state.pBuffs[maelstrom_weapon].count < 2 then
				return ancestral_swiftness
			end
			return nil
		end },
	
	{	act		= lightning_bolt,
		desc	= 'AS',
		SimC	= 'actions.single+=/lightning_bolt,if=buff.ancestral_swiftness.up',
		check	= function( state )
			if state.pBuffs[ancestral_swiftness].up then
				return lightning_bolt
			end
			return nil
		end },
	
	{	act		= earth_shock,
		desc	= '',
		SimC	= 'actions.single+=/earth_shock,if=(!glyph.frost_shock.enabled|set_bonus.tier14_4pc_melee=1)',
		check	= function( state )
			if not state.glyphs[frost_shock] or state.set_bonuses['t14'] >= 4 then
				return earth_shock
			end
			return nil
		end },
	
	{	act		= feral_spirit,
		desc	= '',
		SimC	= 'actions.single+=/feral_spirit',
		check	= function( state )
			return feral_spirit
		end },
	
	{	act		= earth_elemental_totem,
		desc	= '',
		SimC	= 'actions.single+=/earth_elemental_totem,if=!active',
		check	= function( state )
			if not state.totems[totem_earth].up or state.totems[totem_earth].name ~= earth_elemental_totem then -- and state.cooldowns[fire_elemental_totem] >= 60 then
				return earth_elemental_totem
			end
			return nil
		end },
	
	{	act		= spiritwalkers_grace,
		desc	= '',
		SimC	= 'actions.single+=/spiritwalkers_grace,moving=1',
		check	= function( state )
			if state.moving then
				return spiritwalkers_grace
			end
			return nil
		end },
	
	{	act		= lightning_bolt,
		desc	= 'MW2+',
		SimC	= 'actions.single+=/lightning_bolt,if=buff.maelstrom_weapon.react>1&!buff.ascendance.up',
		check	= function( state )
			if state.pBuffs[maelstrom_weapon].count > 1 and not state.pBuffs[ascendance].up then
				-- Hardcasting
				return lightning_bolt, 0, (state.pBuffs[maelstrom_weapon].count < 5)
			end
			return nil
		end },
			
	{	act		= searing_totem,
		desc	= 'Refresh',
		SimC	= 'N/A',
		check	= function( state )
			if state.totems[totem_fire].up and state.totems[totem_fire].name == searing_totem and state.totems[totem_fire].remains < 15 then
				return searing_totem
			end
			return nil
		end }
}


---------------------
-- AOE Action List --
---------------------
mod.state['AE'].actions = {
 
 	{	act		= fire_nova,
 		desc	= '4+',
 		SimC	= 'actions.aoe=fire_nova,if=active_flame_shock>=4',
 		check	= function( state )
			if state.fsCount >= 4 then
				return fire_nova
			end
			return nil
 		end },

 	{	act		= fire_nova,
 		desc	= 'Wait',
 		SimC	= 'actions.aoe+=/wait,sec=cooldown.fire_nova.remains,if=active_flame_shock>=4&cooldown.fire_nova.remains<0.67',
 		check	= function( state )
			if state.cooldowns[fire_nova] < 0.67 and state.fsCount >= 4 then
				return fire_nova, state.cooldowns[fire_nova]
			end
			return nil
 		end },

	{	act		= magma_totem,
		desc	= '6+',
		SimC	= 'actions.aoe+=/magma_totem,if=active_enemies>5&!totem.fire.active',
		check	= function( state )
			if not state.totems[totem_fire].up and state.tCount > 5 then
				return magma_totem
			end
			return nil
		end },

	{	act		= searing_totem,
		desc	= '5-',
		SimC	= 'actions.aoe+=/searing_totem,if=active_enemies<=5&!totem.fire.active',
		check	= function( state )
			if not state.totems[totem_fire].up and state.tCount <= 5 then
				return searing_totem
			end
			return nil
		end },

	{	act		= lava_lash,
		desc	= 'FS',
		SimC	= 'actions.aoe+=/lava_lash,if=dot.flame_shock.ticking',
		check	= function( state )
			if state.tDebuffs[flame_shock].up then
				return lava_lash
			end
			return nil
		end },

	{	act		= elemental_blast,
		desc	= 'MW1+',
		SimC	= 'actions.aoe+=/elemental_blast,if=talent.elemental_blast.enabled&buff.maelstrom_weapon.react>=1',
		check	= function( state )
			if state.talents[elemental_blast] and state.pBuffs[maelstrom_weapon].count >= 1 then
				return elemental_blast, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
			end
			return nil
		end },

	{	act		= chain_lightning,
		desc	= 'MW3+',
		SimC	= 'actions.aoe+=/chain_lightning,if=active_enemies>=2&buff.maelstrom_weapon.react>=3',
		check	= function( state )
			-- Need to bring in FS counter for this.
			if state.tCount >= 2 and state.pBuffs[maelstrom_weapon].count >= 3 then
				return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
			end
			return nil
		end },

	{	act		= unleash_elements,
		desc	= '',
		SimC	= 'actions.aoe+=/unleash_elements',
		check	= function( state )
			if state.pBuffs[windfury_weapon].up and state.pBuffs[flametongue_weapon].up then
				return unleash_elements
			end
			return nil
		end },
		
	{	act		= flame_shock,
		desc	= 'Cycle',
		SimC	= 'actions.aoe+=/flame_shock,cycle_targets=1,if=!ticking',
		check	= function( state )
			-- This only works if Magma Totem is up and hitting things, otherwise tCount will == fsCount.
			if state.tDebuffs[flame_shock].up and state.tCount > state.fsCount then
				return flame_shock
			end
			return nil
		end },

	{	act		= flame_shock,
		desc	= '',
		SimC	= 'N/A - use FS if it will expire before it comes off CD again',
		check	= function( state )
			if not state.tDebuffs[flame_shock].up or state.tDebuffs[flame_shock].remains < 6 then
				return flame_shock
			end
			return nil
		end },
				
	{	act		= stormblast,
		desc	= '',
		SimC	= 'actions.aoe+=stormblast',
		check	= function( state )
			if state.pBuffs[ascendance].up then
				return stormblast
			end
			return nil
		end },
	
	{	act		= fire_nova,
		desc	= '3+',
		SimC	= 'actions.aoe+=fire_nova,if=active_flame_shock>=3',
		check	= function( state )
			if state.fsCount >= 3 then
				return fire_nova
			end
			return nil
		end },
		
	{	act		= chain_lightning,
		desc	= '2+MW1+',
		SimC	= 'actions.aoe+=/chain_lightning,if=active_enemies>=2&buff.maelstrom_weapon.react>=1',
		check	= function( state )
			-- Need to bring in FS counter for this.
			if state.tCount >= 2 and state.pBuffs[maelstrom_weapon].count >= 1 then
				return chain_lightning, 0, (state.pBuffs[maelstrom_weapon].count < 5 and not state.pBuffs[ancestral_swiftness].up)
			end
			return nil
		end },

	{	act		= stormstrike,
		desc	= '',
		SimC	= 'actions.aoe+=/stormstrike',
		check	= function( state )
			if not state.pBuffs[ascendance].up then
				return stormstrike
			end
			return nil
		end },

	{	act		= earth_shock,
		desc	= '',
		SimC	= 'actions.aoe+=/earth_shock,if=active_enemies<4',
		check	= function( state )
			-- Need to bring in FS counter for this.
			if state.tCount < 4 then
				return earth_shock
			end
			return nil
		end },

	{	act		= feral_spirit,
		desc	= '',
		SimC	= 'actions.aoe+=/feral_spirit',
		check	= function( state )
			return feral_spirit
		end },
		
	{	act		= earth_elemental_totem,
		desc	= '',
		SimC	= 'actions.aoe+=/earth_elemental_totem,if=!active&cooldown.fire_elemental_totem.remains>=50',
		check	= function( state )
			if not state.totems[totem_earth].up and state.cooldowns[fire_elemental_totem] >= 50 then
				return earth_elemental_totem
			end
			return nil
		end },
		
	{	act		= spiritwalkers_grace,
		desc	= '',
		SimC	= 'actions.aoe+=/spiritwalkers_grace,moving=1',
		check	= function( state )
			if state.moving then
				return spiritwalkers_grace
			end
			return nil
		end },
		
	{	act		= fire_nova,
		desc	= '',
		SimC	= 'actions.aoe+=/fire_nova,if=active_flame_shock>=1',
		check	= function( state )
			if state.fsCount >= 1 then
				return fire_nova
			end
			return nil
		end }

}	


----------------------------------------------------------------------------------------------
-- mod.Execute[] -- Updates the state to reflect what happens if/when this ability is used. --
----------------------------------------------------------------------------------------------


mod.Execute[ancestral_swiftness] = function( state )
	-- Fake a GCD?
	cast = 0
	state.cooldowns[ancestral_swiftness] = 90

	-- apply the ancestral swiftness buff
	state.pBuffs[ancestral_swiftness].up	= true
	state.pBuffs[ancestral_swiftness].count		= 1
	state.pBuffs[ancestral_swiftness].remains	= 0

	return cast
end
	
mod.Execute[arcane_torrent] = function( state )
	cast = 0
	state.cooldowns[arcane_torrent] = 120
	
	state.tCast = 0
	
	return cast
end

mod.Execute[ascendance] = function( state )
	cast = 0
	
	state.pBuffs[ascendance].up			= true
	state.pBuffs[ascendance].count		= 1
	state.pBuffs[ascendance].remains	= 15
	
	state.cooldowns[ascendance]		= Hekili.ttCooldown(114049)
	state.cooldowns[stormstrike]	= 0
	state.cooldowns[stormblast]		= 0
	
	return cast
end
	
mod.Execute[berserking] = function( state )
	cast = 0
	state.cooldowns[berserking] = 120
	
	return cast
end

mod.Execute[blood_fury] = function( state )
	cast = 0
	state.cooldowns[blood_fury] = 120
	
	return cast
end

mod.Execute[bloodlust] = function( state )
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
end

mod.Execute[chain_lightning] = function ( state )
	cast = 3.0 / state.sHaste

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
end
		
mod.Execute[earth_elemental_totem] = function( state )
	cast = state.tGCD
	state.cooldowns[earth_elemental_totem] = Hekili.ttCooldown(2062)

	state.totems[totem_earth].up		= true
	state.totems[totem_earth].name		= earth_elemental_totem
	state.totems[totem_earth].remains	= 60

	return cast
end

mod.Execute[earth_shock] = function( state )
	cast = state.mGCD
		
	state.cooldowns[flame_shock] = 6.0
	state.cooldowns[frost_shock] = 6.0
	state.cooldowns[earth_shock] = 6.0
		
	return cast
end
	
mod.Execute[elemental_blast] = function( state )
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
end

mod.Execute[elemental_mastery] = function( state )
	cast = 0
	state.cooldowns[elemental_mastery] = 90

	state.pBuffs[elemental_mastery].up			= true
	state.pBuffs[elemental_mastery].count 		= 1
	state.pBuffs[elemental_mastery].remains 	= 20

	RecalculateHaste( state )
	
	return cast
end


mod.Execute[feral_spirit] = function( state )
	cast = state.sGCD

	state.cooldowns[feral_spirit] = Hekili.ttCooldown(51533)
	
	return cast
end

mod.Execute[fire_elemental_totem] = function( state )
	cast = 1.0
	state.cooldowns[fire_elemental_totem] = Hekili.ttCooldown(2894)

	state.totems[totem_fire].up			= true
	state.totems[totem_fire].name		= fire_elemental_totem
	state.totems[totem_fire].remains	= 60

	return cast
end

mod.Execute[fire_nova] = function( state )
	cast = state.sGCD
	state.cooldowns[fire_nova] = 4.0
	
	state.pBuffs[unleash_flame].up			= false
	state.pBuffs[unleash_flame].count		= 0
	state.pBuffs[unleash_flame].duration	= 0

	return cast
end

mod.Execute[flame_shock] = function( state )
	cast = state.sGCD
	
	state.cooldowns[flame_shock] = 6.0
	state.cooldowns[frost_shock] = 6.0
	state.cooldowns[earth_shock] = 6.0

	state.pBuffs[unleash_flame].up			= false
	state.pBuffs[unleash_flame].count		= 0
	state.pBuffs[unleash_flame].duration	= 0

	local tick	= 3 / state.sHaste
	local ticks	= round( 30 / tick )
	local length = tick * ticks
	
	state.tDebuffs[flame_shock].up			= true
	state.tDebuffs[flame_shock].count		= 1
	state.tDebuffs[flame_shock].duration	= length
	
	return cast
end

mod.Execute[frost_shock] = function( state )
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
end

mod.Execute[flametongue_weapon] = function( state )
	cast = state.sGCD
	
	state.pBuffs[flametongue_weapon].up 		= true
	state.pBuffs[flametongue_weapon].count		= 1
	state.pBuffs[flametongue_weapon].remains 	= 3600
	
	return cast
end

mod.Execute[heroism] = function( state )
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
end

mod.Execute[lava_lash] = function( state )
	cast = state.mGCD
	state.cooldowns[lava_lash] = 10.0
	
	return cast
end

mod.Execute[lifeblood] = function( state )
	-- fake cooldown (to prevent queue-jumping)
	cast = 0

	state.cooldowns[lifeblood] = 120

	state.pBuffs[lifeblood].up	= true
	state.pBuffs[lifeblood].count	= 1
	state.pBuffs[lifeblood].remains	= 20
	
	local lbBenefit = 2880
	if state.pBuffs[flurry].up then
		lbBenefit = lbBenefit * 1.5
	end
	state.shRating = state.shRating + lbBenefit
	state.sHaste = 1 + ( state.shRating / 42500 )
	state.mHaste = 1 + ( state.mhRating / 42500 )

	RecalculateHaste( state )

	return cast
end	

mod.Execute[lightning_bolt] = function( state )
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
end

mod.Execute[lightning_shield] = function( state )
	cast = state.sGCD
	
	state.pBuffs[lightning_shield].up		= true
	state.pBuffs[lightning_shield].count	= 1
	state.pBuffs[lightning_shield].remains	= 3600
		
	return cast
end
	
mod.Execute[magma_totem] = function( state )
	cast = state.tGCD
	
	state.totems[totem_fire].up			= true
	state.totems[totem_fire].name		= magma_totem
	state.totems[totem_fire].remains	= 60
	
	return cast
end

mod.Execute[searing_totem] = function( state )
	cast = state.tGCD
	
	state.totems[totem_fire].up			= true
	state.totems[totem_fire].name		= searing_totem
	state.totems[totem_fire].remains	= 60
	
	return cast
end

mod.Execute[stormblast] = function( state )
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
end

mod.Execute[stormlash_totem] = function( state )
	cast = state.tGCD
	
	state.totems[totem_air].up			= true
	state.totems[totem_air].name		= stormlash_totem
	state.totems[totem_air].remains		= 10
	
	-- should i add the buff?
	state.pBuffs[stormlash_totem].up		= true
	state.pBuffs[stormlash_totem].count		= 1
	state.pBuffs[stormlash_totem].remains	= 10
	
	return cast
end
	
mod.Execute[stormstrike] = function( state )
	cast = state.mGCD
	state.cooldowns[stormstrike] = 8.0

	if state.set_bonuses['t15'] >= 2 then
		state.pBuffs[maelstrom_weapon].up		= true
		state.pBuffs[maelstrom_weapon].count	= state.pBuffs[maelstrom_weapon].count + 2
		state.pBuffs[maelstrom_weapon].remains	= 30
		
		if state.pBuffs[maelstrom_weapon].count > 5 then state.pBuffs[maelstrom_weapon].count = 5 end
	end
	
	return cast
end

mod.Execute[synapse_springs] = function( state )
	cast = 0
	
	state.cooldowns[synapse_springs] = 60
	
	return cast
end

mod.Execute[unleash_elements] = function( state ) 
	cast = state.sGCD
	state.cooldowns[unleash_elements] = 15.0

	if state.pBuffs[flametongue_weapon].up then
		state.pBuffs[unleash_flame].up 			= true
		state.pBuffs[unleash_flame].count		= 1
		state.pBuffs[unleash_flame].remains		= 8
	end
	
	return cast
end

mod.Execute[virmens_bite] = function( state )
	-- 1.0 GCD
	cast = state.tGCD
	state.cooldowns[virmens_bite] = 120

	-- apply the buff if used in combat.
	if (state.combatTime > 0) then Hekili.UsedConsumable = true end
	state.pBuffs[virmens_bite].up		= true
	state.pBuffs[virmens_bite].count	= 1
	state.pBuffs[virmens_bite].remains	= 25	

	return cast
end

mod.Execute[wind_shear] = function( state )
	cast = 0
	state.cooldowns[wind_shear] = 12	
	
	state.tCast = 0
	
	return cast
end

mod.Execute[windfury_weapon] = function( state )
	cast = state.sGCD
	
	state.pBuffs[windfury_weapon].up	= true
	state.pBuffs[windfury_weapon].count 	= 1
	state.pBuffs[windfury_weapon].remains 	= 3600
	
	return cast
end
	

mod.offGCD = {}
mod.offGCD[ancestral_swiftness]	= true
mod.offGCD[arcane_torrent]		= true
mod.offGCD[ascendance]			= true
mod.offGCD[berserking]			= true
mod.offGCD[blood_fury]			= true
mod.offGCD[bloodlust]			= true
mod.offGCD[heroism]				= true
mod.offGCD[lifeblood]			= true
mod.offGCD[synapse_springs]		= true
mod.offGCD[wind_shear]			= true


local tSlots = {
	'Helmet',
	'Spaulders',
	'Cuirass',
	'Grips',
	'Legguards'
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


function mod.RefreshState( state )
	
	state.time			= GetTime()
	state.combatTime 	= state.time - (Hekili.CombatStart or state.time)
	state.timeToDie		= Hekili.GetTTD()
	state.tCount,
	state.mtCount,
	state.fsCount		= mod.activeTargets()
	
	state.faction	= UnitFactionGroup("player")
	state.race		= UnitRace("player")


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
	if MH and Hekili.ttWeaponEnchant(GetInventorySlotInfo("MainHandSlot")) == "Windfury" then
		state.pBuffs[windfury_weapon].up		= true
		state.pBuffs[windfury_weapon].count		= 1
		state.pBuffs[windfury_weapon].remains	= mhExpires / 1000
	else
		state.pBuffs[windfury_weapon].up		= false
		state.pBuffs[windfury_weapon].count		= 0
		state.pBuffs[windfury_weapon].remains	= 0
	end

	if OH and Hekili.ttWeaponEnchant(GetInventorySlotInfo("SecondaryHandSlot")) == "Flametongue" then
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
	
	for k,_ in pairs(mod.Execute) do
		local cdStart, cdLength = GetSpellCooldown(k)
		
		-- Faking the CD for off-GCD abilities preserves the order.
		if mod.offGCD[k] and cdLength == 0 then
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
		state.cooldowns[ascendance] = Hekili.ttCooldown(114049)
	end
	
	
	-- COOLDOWNS --
	---------------


	-----------
	-- ITEMS --
	
	if not state.items then state.items	= {} end

	state.items[synapse_springs]	= false
	-- state.items[virmens_bite]		= false

	-- Engineering Gloves
	local gloves = GetInventoryItemID("player", GetInventorySlotInfo("HandsSlot"))

	state.cooldowns[synapse_springs]	= 0
	if IsUsableItem(gloves) == 1 then
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

	--[[ Virmen's Bite
	local vbCount = GetItemCount(virmens_bite, false)

	state.cooldowns[virmens_bite]			= 0
	if Hekili.UsedConsumable then
		state.cooldowns[virmens_bite] 		= 120
	elseif vbCount > 0 then
		state.items[virmens_bite]			= true

		local gCDstart, gCDduration = GetItemCooldown(76089)
		
		if gCDstart > 0 then
			state.cooldowns[virmens_bite]	= gCDstart + gCDduration - state.time
		end
		
	end ]]

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

	if UnitName("target") and UnitCanAttack("player", "target") and UnitHealth("target") > 0 then
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
		local _, _, _, _, _, endCast, _, _, notInterruptible = UnitCastingInfo("target")
		
		if endCast ~= nil and not notInterruptible then
			state.tCast	= endCast / 1000
		end
		
		_, _, _, _, _, endCast, _, notInterruptible = UnitChannelInfo("target")
		
		if endCast ~= nil and not notInterruptible then
			state.tCast = endCast / 1000
		end
	end
	
	

	----------------
	-- HASTE INFO --
	
	-- Player's Combat Rating, for updates.
	state.shRating = GetCombatRating(CR_HASTE_SPELL)
	state.mhRating = GetCombatRating(CR_HASTE_MELEE)

	-- Gives player's current, total calculated spell haste.
	state.sHaste = (1 + ( state.shRating / 42500 ) )
	state.mHaste = (1 + ( state.mhRating / 42500 ) )
	state.mGCD = 1.5
	state.tGCD = 1.0
	
	RecalculateHaste( state )
	
	-- HASTE INFO --
	------------------

end


function RecalculateHaste( state )
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

	state.sGCD = 1.5 / state.sHaste
	if state.sGCD < 1.0 then state.sGCD = 1.0 end

end


function mod.AdvanceState( state, elapsed )

	state.time			= state.time + elapsed
	state.combatTime	= state.combatTime + elapsed
	state.timeToDie		= state.timeToDie - elapsed

	---------------
	-- COOLDOWNS --
	
	for k,_ in pairs(mod.Execute) do
		if not state.cooldowns[k] then
			state.cooldowns[k] = 0
		end

		if state.cooldowns[k] > 0 then
			state.cooldowns[k] = state.cooldowns[k] - elapsed
		end

		if state.cooldowns[k] < 0 then
			state.cooldowns[i] = 0
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
	local mhSwing = Hekili.ttWeaponSpeed( GetInventorySlotInfo("MainHandSlot") )
	local mhPPH = 0
	
	if mhSwing then
		mhPPH = mhSwing * 10 / 60
	end
	
	local ohSwing = Hekili.ttWeaponSpeed( GetInventorySlotInfo("SecondaryHandSlot") )
	local ohPPH = 0
	
	if ohSwing then
		ohPPH = mhSwing * 10 / 60
	end
	
end


mod.trackHits.source	= 0
mod.trackHits.pulse		= 0
mod.trackHits.count		= 0
mod.trackHits.timeOut	= 5.0

mod.trackDebuffs[flame_shock] = {}


function mod.countHits( verb )

	if verb then
		for k,v in pairs(mod.trackHits) do
			print(k .. ' = ' .. v .. '.')
		end
	end

	return mod.trackHits.count and mod.trackHits.count or 0
	
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
	
	if hits > debuffs and hits > 1 then
		return hits, hits, debuffs
	elseif debuffs > hits and debuffs > 1 then
		return debuffs, hits, debuffs
	else
		return (hits and hits or 1), hits, debuffs
	end
end


	
function mod.auditTrackers( )
	for spell, spellTable in pairs(mod.trackDebuffs) do
		for unit, lastTick in pairs(spellTable) do
			if GetTime() - lastTick > 5.0 then spellTable[unit] = nil end
		end
	end

	if GetTime() - mod.trackHits.pulse > mod.trackHits.timeOut then
		mod.trackHits.source	= 0
		mod.trackHits.pulse		= 0
		mod.trackHits.count		= 0
	end
end


function mod:CLEU(AddOn, event, time, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, _, interrupt)

	-- Capture summoning of a Magma Totem for # targets by # hits.
	if subtype == 'SPELL_SUMMON' and sourceGUID == UnitGUID('player') and destName == 'Magma Totem' then
		AddOn:Print("Found summon of Magma Totem.")
		self.trackHits.source	= destGUID
		self.trackHits.pulse	= GetTime()
		self.trackHits.count	= 0
		return true
	end

	if AddOn.DB.char['Multi-Target Enabled'] == false then
		return true
	end
		
	local hasTotem, totemName = GetTotemInfo(1)
	
	if hasTotem and totemName == 'Magma Totem' then
		if subtype == 'SPELL_DAMAGE' and sourceGUID == self.trackHits.source and spellName == 'Magma Totem' then
			if self.trackHits.pulse == 0 or (GetTime() - self.trackHits.pulse > 0.5) then
				self.trackHits.pulse	= GetTime()
				self.trackHits.count	= 0
			end
			self.trackHits.count = self.trackHits.count + 1
		else
			if self.trackHits.pulse > 0 and GetTime() - self.trackHits.pulse > self.trackHits.timeOut then
				self.trackHits.source		= 0
				self.trackHits.pulse		= 0
				self.trackHits.count		= 0
			end
		end
	else
		self.trackHits.source	= 0
		self.trackHits.pulse	= 0
		self.trackHits.count	= 0
	end
	
	if subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' or subtype == 'SPELL_DAMAGE' then
		if spellName == 'Flame Shock' and sourceGUID == UnitGUID('player') then
			if not self.trackDebuffs[spellName] then self.trackDebuffs[spellName] = {} end
			self.trackDebuffs[spellName][destGUID]	= GetTime()
		end
	end
	
	-- Theory: Sometimes, the unit dies but SPELL_AURA_REMOVED does not fire.
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" then
		if self.trackDebuffs[spellName] and self.trackDebuffs[spellName][destGUID] then
			self.trackDebuffs[spellName][destGUID] = nil
		end

		-- Tracked Pets/Totems
		if self.trackHits and self.trackHits.source and self.trackHits.source == destGUID then
			self.trackHits.source	= 0
			self.trackHits.pulse	= 0
			self.trackHits.count	= 0
		end
	end

	-- Check to reduce Flame Shock targets.
    if (subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL') and spellName == 'Flame Shock' and sourceGUID == UnitGUID('player') then
		self.trackDebuffs[spellName][destGUID] = nil
    end
    
end