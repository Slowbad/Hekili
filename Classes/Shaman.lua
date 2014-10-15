-- Shaman.lua
-- August 2014


local AbilityMods, AddHandler = Hekili.Utils.AbilityMods, Hekili.Utils.AddHandler

-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass("player")) == "SHAMAN") then

	AddResource( SPELL_POWER_MANA )

	AddTalent( "natures_guardian"     , 30884  )
	AddTalent( "stone_bulwark_totem"  , 108270 )
	AddTalent( "astral_shift"         , 108271 )
	AddTalent( "frozen_power"         , 63374  )
	AddTalent( "earthgrab_totem"      , 51485  )
	AddTalent( "windwalk_totem"       , 108273 )
	AddTalent( "call_of_the_elements" , 108285 )
	AddTalent( "totemic_persistence"  , 108284 )
	AddTalent( "totemic_projection"   , 108287 )
	AddTalent( "elemental_mastery"    , 16166  )
	AddTalent( "ancestral_swiftness"  , 16188  )
	AddTalent( "echo_of_the_elements" , 108283 )
	AddTalent( "rushing_streams"      , 147074 )
	AddTalent( "ancestral_guidance"   , 108281 )
	AddTalent( "conductivity"         , 108282 )
	AddTalent( "unleashed_fury"       , 117012 )
	AddTalent( "primal_elementalist"  , 117013 )
	AddTalent( "elemental_blast"      , 117014 )
	AddTalent( "elemental_fusion"     , 152257 )
	AddTalent( "storm_elemental_totem", 152256 )
	AddTalent( "liquid_magma"         , 152255 )

	-- Major Glyphs.
	AddGlyph( "capacitor_totem"     , 55442  )
	AddGlyph( "chain_lightning"     , 55449  )
	AddGlyph( "chaining"            , 55452  )
	AddGlyph( "cleansing_waters"    , 55445  )
	AddGlyph( "ephemeral_spirits"   , 159640 )
	AddGlyph( "eternal_earth"       , 147781 )
	AddGlyph( "feral_spirit"        , 63271  )
	AddGlyph( "fire_elemental_totem", 55455  )
	AddGlyph( "fire_nova"           , 55450  )
	AddGlyph( "flame_shock"         , 55447  )
	AddGlyph( "frost_shock"         , 55443  )
	AddGlyph( "frostflame_weapon"   , 161654 )
	AddGlyph( "ghost_wolf"          , 59289  )
	AddGlyph( "grounding"           , 159643 )
	AddGlyph( "grounding_totem"     , 55441  )
	AddGlyph( "healing_storm"       , 89646  )
	AddGlyph( "healing_stream_totem", 55456  )
	AddGlyph( "healing_wave"        , 55440  )
	AddGlyph( "hex"                 , 63291  )
	AddGlyph( "lava_spread"         , 159644 )
	AddGlyph( "lightning_shield"    , 101052 )
	AddGlyph( "purge"               , 55439  )
	AddGlyph( "purging"             , 147762 )
	AddGlyph( "reactive_shielding"  , 159647 )
	AddGlyph( "riptide"             , 63273  )
	AddGlyph( "shamanistic_rage"    , 63280  )
	AddGlyph( "shamanistic_resolve" , 159648 )
	AddGlyph( "shocks"              , 159649 )
	AddGlyph( "spirit_walk"         , 55454  )
	AddGlyph( "spiritwalkers_aegis" , 159651 )
	AddGlyph( "spiritwalkers_focus" , 159650 )
	AddGlyph( "spiritwalkers_grace" , 55446  )
	AddGlyph( "telluric_currents"   , 55453  )
	AddGlyph( "thunder"             , 63270  )
	AddGlyph( "totemic_recall"      , 55438  )
	AddGlyph( "totemic_vigor"       , 63298  )
	AddGlyph( "unstable_earth"      , 55437  )
	AddGlyph( "water_shield"        , 55436  )
	AddGlyph( "wind_shear"          , 55451  )
	
	-- Minor Glyphs.
	AddGlyph( "astral_fixation"     , 147787 )
	AddGlyph( "astral_recall"       , 58058  )
	AddGlyph( "deluge"              , 63279  )
	AddGlyph( "elemental_familiars" , 147788 )
	AddGlyph( "far_sight"           , 58059  )
	AddGlyph( "flaming_serpents"    , 147772 )
	AddGlyph( "ghostly_speed"       , 159642 )
	AddGlyph( "lava_lash"           , 55444  )
	AddGlyph( "lingering_ancestors" , 147784 )
	AddGlyph( "rain_of_frogs"       , 147707 )
	AddGlyph( "spirit_raptors"      , 147783 )
	AddGlyph( "spirit_wolf"         , 147770 )
	AddGlyph( "compy"               , 147785 )
	AddGlyph( "lakestrider"         , 55448  )
	AddGlyph( "spectral_wolf"       , 58135  )
	AddGlyph( "thunderstorm"        , 62132  )
	AddGlyph( "totemic_encirclement", 58057  )
	
	-- Player Buffs / Debuffs
	AddAura( "ascendance", 114049, "duration", 15 )
	AddAura( "ancestral_swiftness", 16188, "duration", 600 )
	AddAura( "echo_of_the_elements", 159103, "duration", 20 )
	AddAura( "elemental_blast", 117014, "duration", 8 )
	AddAura( "elemental_fusion", 157174, "duration", 15, "max_stacks", 2 )
	AddAura( "elemental_mastery", 16166, "duration", 20 )
	AddAura( "improved_chain_lightning", 157766, "duration", 10 )
	AddAura( "flame_shock", 8050, "duration", 30 )
	AddAura( "frost_shock", 8056, "duration", 8 )
	AddAura( "healing_rain", 73920, "duration", 10 )
	AddAura( "lava_surge"      , 77762 , "duration", 6 )
	AddAura( "lightning_shield", 324, "duration", 3600 )	
	AddAura( "liquid_magma", 152255, "duration", 10, "affects", "pet" )
	AddAura( "maelstrom_weapon", 51530 , "duration", 30, "max_stacks", 5)
	AddAura( "spiritwalkers_grace", 79206, "duration", 15 )
	AddAura( "stormstrike"     , 17364 , "duration", 15 )
	AddAura( "thunderstorm", 51490, "duration", 5 )
	AddAura( "unleash_flame"   , 73683 , "duration", 20                 )
	AddAura( "unleash_wind"    , 73681 , "duration", 30, "max_stacks", 6)

	
	AddPerk( "enhanced_chain_lightning", 157765 )
	AddPerk( "enhanced_unleash", 157784 )
	AddPerk( "improved_flame_shock", 157804 )
	AddPerk( "improved_lightning_shield", 157774 )
	AddPerk( "improved_maelstrom_weapon", 157807 )
	AddPerk( "improved_reincarnation", 157764 )
	
	
	-- Rethink DOT tracking...

	-- Pick an instant cast ability for checking the GCD.
	SetGCD( "lightning_shield" )

	-- Gear Sets
	AddItemSet( "tier17", 115579, 115576, 115577, 115578, 115575 )
	AddItemSet( "tier16_melee", 99347, 99340, 99341, 99342, 99343 )
	AddItemSet( "tier15_melee", 96689, 96690, 96691, 96692, 96693 )
	AddItemSet( "tier14_melee", 87138, 87137, 87136, 87135, 87134 )

	
	--	name, ID, cost (table), cast, gcdType, cooldown, ...
	AddAbility( 'ancestral_swiftness'  , 16188 , 0    , 0  , 'off'  , 90  )
	
	AddAbility( 'ascendance'           , 114049, 0.052, 0  , 'off'  , 120 )
	
	AddAbility( 'bloodlust'            , 2825  , 0.215, 0  , 'off'  , 300 )
	
	AddAbility( 'chain_lightning'      , 421   , 0.071, 2.0, 'spell', 0   )

	AddAbility( 'earth_elemental_totem', 2062  , 0.281, 0  , 'totem', 300 )

	AddAbility( 'earth_shock'          , 8042  , 0.05 , 0  , 'spell', 6   )
	
	AddAbility( 'earthquake'           , 61882 , 0.03 , 2.5, 'spell', 10  )

	AddAbility( 'elemental_blast'      , 117014, 0    , 2.0, 'spell', 12  )

	AddAbility( 'elemental_mastery'    , 16166 , 0    , 0  , 'off'  , 90  )

	AddAbility( 'feral_spirit'         , 51533 , 0.12 , 0  , 'spell', 120 )

	AddAbility( 'fire_elemental_totem' , 2894  , 0.269, 0  , 'totem', 300 )

	AddAbility( 'fire_nova'            , 1535  , 0.137, 0  , 'spell', 4.5 )

	AddAbility( 'flame_shock'          , 8050  , 0.05 , 0  , 'spell', 6   )

	AddAbility( 'frost_shock'          , 8056  , 0.05 , 0  , 'spell', 6   )

	AddAbility( 'healing_rain'         , 73920 , 0.216, 2  , 'spell', 10  )

	AddAbility( 'healing_surge'        , 8004  , 0.207, 1.5, 'spell', 0   )

	AddAbility( 'heroism'              , 32182 , 0.215, 0  , 'off'  , 300 )
	
	AddAbility( 'lava_beam'            , 114074, 0.83 , 2  , 'spell', 0   )

	AddAbility( 'lava_burst'           , 51505 , 0.02 , 2  , 'spell', 8   )

	AddAbility( 'lava_lash'            , 60103 , 0.04 , 0  , 'melee', 9   )

	AddAbility( 'lightning_bolt'       , 403   , 0.071, 2.5, 'spell', 0   )

	AddAbility( 'lightning_shield'     , 324   , 0    , 0  , 'spell', 0   )

	AddAbility( 'liquid_magma'         , 152255, 0    , 0  , 'spell', 45  )

	AddAbility( 'magma_totem'          , 8190  , 0.211, 0  , 'totem', 0   )

	AddAbility( 'searing_totem'        , 3599  , 0.059, 0  , 'totem', 0   )

	AddAbility( 'spiritwalkers_grace'  , 79206 , 0.141, 0  , 'off'  , 120 )

	AddAbility( 'storm_elemental_totem', 152256, 0.269, 0  , 'totem', 300 )

	AddAbility( 'stormstrike'          , 17364 , 0.094, 0  , 'melee', 7.5 )
	
	AddAbility( 'strike'               , 73899 , 0.094, 0  , 'melee', 8   )
	
	AddAbility( 'thunderstorm'         , 51490 , 0    , 0  , 'spell', 45  )

	AddAbility( 'unleash_elements'     , 73680 , 0.082, 0  , 'spell', 15  )

	AddAbility( 'unleash_flame'        , 165462, 0.075, 0  , 'spell', 15  )

	AddAbility( 'wind_shear'           , 57994 , 0.094, 0  , 'off'  , 12  )

	AddAbility( 'windstrike'           , 115356, 0.094, 0  , 'melee', 7.5 )

	
	-- These strings get merged to return appropriate values for cooldowns, cast times, resource costs that have to be dynamically calculated.
	-- Order is important.
	local cast_ancestral_swiftness = 'if buff.ancestral_swiftness.up then return 0 end'
	local cast_lava_surge          = 'if buff.lava_surge.up then return 0 end'
	local cast_maelstrom_weapon    = 'if buff.maelstrom_weapon.up then x = ( x - ( x * ( 0.2 * buff.maelstrom_weapon.stack ) ) ) end'
	
	local cd_ascendance            = 'if buff.ascendance.up then return 0 end'
	local cd_echo_of_the_elements	= 'if buff.echo_of_the_elements.up then return 0 end'
	local cd_ephemeral_spirits		= 'if glyph.ephemeral_spirits.enabled then x = x / 2 end'
	local cd_fire_elemental_totem	= 'if glyph.fire_elemental_totem.enabled then x = x / 2 end'
	local cd_flurry				= 'x = x * haste'
	local cd_frost_shock			= 'if glyph.frost_shock.enabled then x = x - 2 end'
	local cd_thunder				= 'if glyph.thunder.enabled then x = x - 10 end'
	local cd_spiritwalkers_focus	= 'if glyph.spiritwalkers_focus.enabled then x = x - 60 end'
	
	
	function Hekili:SetClassModifiers()
	
		for k,v in pairs( self.Abilities ) do
			for key,mod in pairs( v.mods ) do
				self.Abilities[ k ].mods[ key ] = nil
			end
		end
		
		AuraElements( 'lightning_shield', 'max_stack', 1 )
		
		-- Enhancement
		if self.Specialization == 263 then
			AbilityMods( 'chain_lightning', 'cast', cast_ancestral_swiftness, cast_maelstrom_weapon )
			AbilityMods( 'chain_lightning', 'cost', cast_maelstrom_weapon )
			
			AbilityMods( 'elemental_blast', 'cast', cast_ancestral_swiftness, cast_maelstrom_weapon )

			AbilityMods( 'feral_spirit', 'cooldown', cd_ephemeral_spirits )

			AbilityMods( 'fire_nova', 'cooldown', cd_echo_of_the_elements, cd_flurry )

			AbilityMods( 'flame_shock', 'cooldown', cd_flurry )

			AbilityMods( 'frost_shock', 'cooldown', cd_frost_shock, cd_flurry )

			AbilityMods( 'healing_rain', 'cast', cast_ancestral_swiftness, cast_maelstrom_weapon )
			AbilityMods( 'healing_rain', 'cost', cast_maelstrom_weapon )

			AbilityMods( 'healing_surge', 'cast', cast_ancestral_swiftness, cast_maelstrom_weapon )
			AbilityMods( 'healing_surge', 'cost', cast_maelstrom_weapon )

			AbilityMods( 'lava_lash', 'cooldown', cd_echo_of_the_elements, cd_flurry )

			AbilityMods( 'lightning_bolt', 'cast', cast_ancestral_swiftness, cast_maelstrom_weapon )
			AbilityMods( 'lightning_bolt', 'cost', cast_maelstrom_weapon )

			AbilityMods( 'stormstrike', 'cooldown', cd_echo_of_the_elements, cd_flurry )
			
			AbilityMods( 'unleash_elements', 'cooldown', cd_flurry )
			
			AbilityMods( 'windstrike', 'cooldown', cd_echo_of_the_elements, cd_flurry )
	
		-- Elemental
		elseif self.Specialization == 262 then
			AbilityMods( 'chain_lightning', 'cast', cast_ancestral_swiftness )
		
			AbilityMods( 'earthquake', 'cast', cast_ancestral_swiftness )
			AbilityMods( 'earthquake', 'cooldown', cd_echo_of_the_elements )
	
			AbilityMods( 'elemental_blast', 'cast', cast_ancestral_swiftness )
	
			AbilityMods( 'frost_shock', 'cooldown', cd_frost_shock, cd_echo_of_the_elements )

			AbilityMods( 'healing_rain', 'cast', cast_ancestral_swiftness )
			AbilityMods( 'healing_rain', 'cost', cast_maelstrom_weapon )

			AbilityMods( 'healing_surge', 'cast', cast_ancestral_swiftness )

			AbilityMods( 'lava_burst', 'cast', cast_lava_surge, cast_ancestral_swiftness )
			AbilityMods( 'lava_burst', 'cooldown', cd_ascendance, cd_echo_of_the_elements )

			AbilityMods( 'lightning_bolt', 'cast', cast_ancestral_swiftness )
			
			AbilityMods( 'spiritwalkers_focus', 'cooldown', cd_spiritwalkers_focus )
			
			AbilityMods( 'thunderstorm', 'cooldown', cd_thunder )
			
			AuraElements( 'lightning_shield', 'max_stack', 20 )
		
		end
		
		-- Shared
		AbilityMods( 'fire_elemental_totem', 'cooldown', cd_fire_elemental_totem )

	end
	

	-- All actions that modify the game state are included here.
	AddHandler( 'ancestral_swiftness', function ()
		H:Buff( 'ancestral_swiftness', 60 ) 
	end )

	AddHandler( 'ascendance', function ()
		H:Buff( 'ascendance', 15 )
		H:SetCooldown( 'stormstrike', 0 )
		H:SetCooldown( 'windstrike', 0 )
		H:SetCooldown( 'strike', 0 )
	end )

	AddHandler( 'berserking', function ()
		H:Buff( 'berserking', 10 )
	end )

	AddHandler( 'blood_fury', function ()
		H:Buff( 'blood_fury', 15 )
	end )

	AddHandler( 'bloodlust', function ()
		H:Buff( 'bloodlust', 40 )
		H:Debuff( 'player', 'sated', 600 )
	end )

	AddHandler( 'chain_lightning', function ()
		if buff.ancestral_swiftness.up then H:RemoveBuff( 'ancestral_swiftness' )
		elseif buff.maelstrom_weapon.up then H:RemoveBuff( 'maelstrom_weapon' )
		end
		
		if perk.enhanced_chain_lightning.enabled then
			H:Buff( 'improved_chain_lightning', 15, min( glyph.chain_lightning.enabled and 5 or 3, active_enemies) )
		end
		
		if buff.lightning_shield.up and buff.lightning_shield.stack < buff.lightning_shield.max_stack then
			H:AddStack( 'lightning_shield', 3600, min( glyph.chain_lightning.enabled and 5 or 3, active_enemies) )
		end
	end )

	AddHandler( 'earth_elemental_totem', function ()
		H:AddTotem( 'earth_elemental_totem', 'earth', 60 )

		if talent.storm_elemental_totem.enabled then H:SetCooldown( 'storm_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) ) end
		H:SetCooldown( 'fire_elemental_totem', max( cooldown.fire_elemental_totem.remains, 61 ) )
		-- Remove Fire Elemental Pet?  Reset Fire Elemental Totem?
	end )

	AddHandler( 'earth_shock', function ()
		local cooldown = spec.elemental == 1 and 5 or 6 * haste
		H:SetCooldown( 'flame_shock', cooldown )
		H:SetCooldown( 'frost_shock', cooldown )
		if buff.lightning_shield.stack > 1 then
			buff.lightning_shield.count = 1
		end
	end )

	AddHandler( 'earthquake', function ()
		H:RemoveBuff( 'improved_chain_lightning' )
	end )
	
	AddHandler( 'elemental_blast', function ()
		H:Buff( 'elemental_blast', 8 )
	end )

	AddHandler( 'elemental_mastery', function ()
		H:Buff( 'elemental_mastery', 20 )
	end )

	
	AddHandler( 'fire_elemental_totem', function ()
		if glyph.fire_elemental_totem.enabled then
			H:AddTotem( 'fire_elemental_totem', 'fire', 30 )
		else	
			H:AddTotem( 'fire_elemental_totem', 'fire', 60 )
		end
		
		if talent.storm_elemental_totem.enabled then H:SetCooldown( 'storm_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) ) end
		H:SetCooldown( 'earth_elemental_totem', max( cooldown.storm_elemental_totem.remains, 61 ) )
		-- Remove Earth Elemental Pet?  Reset Earth Elemental Totem?
	end )

	AddHandler( 'fire_nova', function ()
		H:RemoveBuff( 'unleash_flame' )
		H:RemoveBuff( 'echo_of_the_elements' )
	end )

	AddHandler( 'flame_shock', function ()
		local cooldown = spec.elemental == 1 and 5 or 6 * haste
		H:Debuff( 'target', 'flame_shock', 30 )
		H:RemoveBuff( 'unleash_flame' )
		H:RemoveBuff( 'elemental_fusion' )
		H:SetCooldown( 'earth_shock', cooldown )
		H:SetCooldown( 'frost_shock', cooldown )
	end )

	AddHandler( 'flametongue_weapon', function ()
		H:Buff( 'flametongue_weapon', 3600 )
	end )

	AddHandler( 'frost_shock', function()
		local cooldown = 6
		
		if spec.elemental then cooldown = 5 end
		if glyph.frost_shock.enabled then cooldown = 4 end
		if spec.enhancement then cooldown = cooldown * haste end
		
		H:RemoveBuff( 'elemental_fusion' )
		H:Debuff( 'target', 'frost_shock', 8 )
		H:SetCooldown( 'earth_shock', cooldown )
		H:SetCooldown( 'flame_shock', cooldown )
	end )

	AddHandler( 'healing_rain', function ()
		if buff.ancestral_swiftness.up then H:RemoveBuff( 'ancestral_swiftness' )
		elseif buff.maelstrom_weapon.up then H:RemoveBuff( 'maelstrom_weapon' ) end
		H:Buff( 'healing_rain', 10 )
	end )
	
	AddHandler( 'healing_surge', function ()
		if buff.ancestral_swiftness.up then H:RemoveBuff( 'ancestral_swiftness' )
		elseif buff.maelstrom_weapon.up then H:RemoveBuff( 'maelstrom_weapon' ) end
	end )


	AddHandler( 'heroism', Hekili.Abilities[ 'bloodlust' ].handler )

	AddHandler( 'lifeblood', function ()
		H:Buff( 'lifeblood', 20 )
	end )

	AddHandler( 'lava_beam', Hekili.Abilities[ 'chain_lightning' ].handler )
	
	AddHandler( 'lava_burst', function ()
		if buff.lava_surge.up then H:RemoveBuff( 'lava_surge' )
		elseif buff.ancestral_swiftness.up then H:RemoveBuff( 'ancestral_swiftness' ) end
		if buff.echo_of_the_elements.up then H:RemoveBuff( 'echo_of_the_elements' ) end
	end )
	
	AddHandler( 'lava_lash', function ()
		H:RemoveBuff( 'echo_of_the_elements' )
		if talent.elemental_fusion.enabled then
			H:Buff( 'elemental_fusion', 20, max(2, buff.elemental_fusion.stack + 1) )
		end
	end )

	AddHandler( 'lightning_bolt', function ()
		if buff.maelstrom_weapon.stack == 5 then H:RemoveBuff( 'maelstrom_weapon' )
		elseif buff.ancestral_swiftness.up then H:RemoveBuff( 'ancestral_swiftness' )
		elseif buff.maelstrom_weapon.up then H:RemoveBuff( 'maelstrom_weapon' ) end
		
		if buff.lightning_shield.up and buff.lightning_shield.stack < buff.lightning_shield.max_stack then
			H:AddStack( 'lightning_shield', 3600, 1 )
		end
	end )

	AddHandler( 'lightning_shield', function ()
		H:Buff( 'lightning_shield', 3600 )
	end )

	AddHandler( 'magma_totem', function ()
		H:AddTotem( 'magma_totem', 'fire', 60 )
	end )

	AddHandler( 'searing_totem', function ()
		H:AddTotem( 'searing_totem', 'fire', 60 )
	end )

	AddHandler( 'spiritwalkers_grace', function ()
		if glyph.spiritwalkers_focus.enabled then H:Buff( 'spiritwalkers_grace', 1, 8 )
		elseif glyph.spiritwalkers_focus.enabled then H:Buff( 'spiritwalkers_grace', 1, 20 )
		else H:Buff( 'spiritwalkers_grace', 1, 15 ) end
	end )

	AddHandler( 'storm_elemental_totem', function ()
		H:AddTotem( 'storm_elemental_totem', 'air', 60 )
		H:SetCooldown( 'fire_elemental_totem', max( cooldown.fire_elemental_totem.remains, 61 ) )
		H:SetCooldown( 'earth_elemental_totem', max( cooldown.earth_elemental_totem.remains, 61 ) )
	end )

	AddHandler( 'stormstrike', function ()
		if buff.echo_of_the_elements.up then
			H:RemoveBuff( 'echo_of_the_elements' )
		else
			H:SetCooldown( 'strike', 7.5 * haste )
		end
		if set_bonus.tier17_2pc ~= 0 and cooldown.feral_spirit.remains > 0 then
			H:SetCooldown( 'feral_spirit', max(0, cooldown.feral_spirit.remains - 5) )
		end
		H:Debuff( 'target', 'stormstrike', 8 )
		if set_bonus.tier15_2pc_melee ~= 0 then H:AddStack( 'maelstrom_weapon', 30, 2 ) end
	end )

	AddHandler( 'synapse_springs', function ()
		H:Buff( 'synapse_springs', 10 )
	end )
	
	AddHandler( 'thunderstorm', function ()
		H:Debuff( 'target', 'thunderstorm', 5 )
	end )

	AddHandler( 'unleash_elements', function ()
		H:Buff( 'unleash_wind', 12, 6 )
		H:Buff( 'unleash_flame', 8 )
	end )
	
	AddHandler( 'unleash_flame', function ()
		H:Buff( 'unleash_flame', 20 )
	end )

	AddHandler( 'virmens_bite', function ()
		H:Buff( 'virmens_bite', 25 )
	end )

	AddHandler( 'wind_shear', function ()
		H:Interrupt( 'target' )
	end )

	AddHandler( 'windstrike', function ()
		if buff.echo_of_the_elements.up then
			H:RemoveBuff( 'echo_of_the_elements' )
		else
			H:SetCooldown( 'strike', 7.5 * haste )
			H:SetCooldown( 'stormstrike', 7.5 * haste )
		end
		H:Debuff( 'target', 'stormstrike', 8 )
		if set_bonus.tier15_2pc_melee ~= 0 then H:AddStack( 'maelstrom_weapon', 30, 2 ) end
	end )
	
	
	
	-- Import strings
	Hekili.Default( "@Enhancement, Single Target", "actionLists", "^1^T^SSpecialization^N263^SName^S@Enhancement,~`Single~`Target^SActions^T^N1^T^SAbility^Sliquid_magma^SEnabled^B^SScript^Stotem.fire.remains>=15^SName^SLiquid~`Magma^t^N2^T^SAbility^Ssearing_totem^SEnabled^B^SScript^S!totem.fire.active^SName^SSearing~`Totem^t^N3^T^SAbility^Sancestral_swiftness^SEnabled^b^SScript^S^SName^SAncestral~`Swiftness^t^N4^T^SAbility^Sunleash_elements^SEnabled^B^SScript^S(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)^SName^SUnleash~`Elements^t^N5^T^SAbility^Selemental_blast^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react>=1^SName^SElemental~`Blast^t^N6^T^SAbility^Slightning_bolt^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react=5|(buff.maelstrom_weapon.react>=4&!buff.ascendance.up)|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3)^SName^SLightning~`Bolt^t^N7^T^SEnabled^B^SName^SWindstrike^SAbility^Swindstrike^t^N8^T^SEnabled^B^SName^SStormstrike^SAbility^Sstormstrike^t^N9^T^SEnabled^B^SName^SLava~`Lash^SAbility^Slava_lash^t^N10^T^SAbility^Sflame_shock^SEnabled^B^SScript^S(talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9)|!ticking^SName^SFlame~`Shock^t^N11^T^SEnabled^B^SName^SUnleash~`Elements~`(1)^SAbility^Sunleash_elements^t^N12^T^SAbility^Sfrost_shock^SEnabled^B^SScript^S(talent.elemental_fusion.enabled&dot.flame_shock.remains>=16)|!talent.elemental_fusion.enabled^SName^SFrost~`Shock^t^N13^T^SAbility^Slightning_bolt^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react>=1&!buff.ascendance.up^SName^SLightning~`Bolt~`(1)^t^N14^T^SAbility^Ssearing_totem^SEnabled^B^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^SName^SSearing~`Totem~`(1)^t^t^t^^" )
	
	Hekili.Default( "@Enhancement, 2 Cleave", "actionLists","^1^T^SActions^T^N1^T^SAbility^Sliquid_magma^SName^SLiquid~`Magma^SScript^Spet.searing_totem.remains>=15|pet.magma_totem.remains>=15|pet.fire_elemental_totem.remains>=15^SEnabled^B^t^N2^T^SAbility^Ssearing_totem^SName^SSearing~`Totem^SScript^S!totem.fire.active^SEnabled^B^t^N3^T^SAbility^Sancestral_swiftness^SName^SAncestral~`Swiftness^SScript^S^SEnabled^b^t^N4^T^SAbility^Sunleash_elements^SName^SUnleash~`Elements^SScript^S(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)^SEnabled^B^t^N5^T^SAbility^Selemental_blast^SName^SElemental~`Blast^SScript^Sbuff.maelstrom_weapon.react>=1^SEnabled^B^t^N6^T^SEnabled^B^SScript^S!glyph.chain_lightning.enabled&(buff.maelstrom_weapon.react=5|(buff.maelstrom_weapon.react>=4&!buff.ascendance.up)|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3))^SName^SChain~`Lightning^SAbility^Schain_lightning^t^N7^T^SAbility^Slightning_bolt^SName^SLightning~`Bolt^SScript^Sbuff.maelstrom_weapon.react=5|(buff.maelstrom_weapon.react>=4&!buff.ascendance.up)|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3)^SEnabled^B^t^N8^T^SEnabled^B^SName^SWindstrike^SAbility^Swindstrike^t^N9^T^SEnabled^B^SName^SStormstrike^SAbility^Sstormstrike^t^N10^T^SAbility^Sflame_shock^SName^SFlame~`Shock^SScript^S(talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9)|!ticking^SEnabled^B^t^N11^T^SEnabled^B^SName^SLava~`Lash^SAbility^Slava_lash^t^N12^T^SEnabled^B^SName^SUnleash~`Elements~`(1)^SAbility^Sunleash_elements^t^N13^T^SEnabled^B^SScript^Sactive_dot.flame_shock>=2&!((talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9))^SName^SFire~`Nova^SAbility^Sfire_nova^t^N14^T^SAbility^Sfrost_shock^SName^SFrost~`Shock^SScript^S(talent.elemental_fusion.enabled&dot.flame_shock.remains>=16)|!talent.elemental_fusion.enabled^SEnabled^B^t^N15^T^SAbility^Slightning_bolt^SName^SLightning~`Bolt~`(1)^SScript^Sglyph.chain_lightning.enabled&buff.maelstrom_weapon.react>=1&!buff.ascendance.up^SEnabled^B^t^N16^T^SEnabled^B^SScript^S!glyph.chain_lightning.enabled&(buff.maelstrom_weapon.react>=1&!buff.ascendance.up)^SName^SChain~`Lightning~`(1)^SAbility^Schain_lightning^t^N17^T^SAbility^Ssearing_totem^SName^SSearing~`Totem~`(1)^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^SEnabled^B^t^t^SName^S@Enhancement,~`2~`Cleave^SSpecialization^N263^t^^" )
	
	Hekili.Default( "@Enhancement, 3 Cleave", "actionLists", "^1^T^SActions^T^N1^T^SAbility^Sliquid_magma^SEnabled^B^SName^SLiquid~`Magma^SScript^Spet.searing_totem.remains>=15|pet.magma_totem.remains>=15|pet.fire_elemental_totem.remains>=15^t^N2^T^SAbility^Smagma_totem^SEnabled^B^SName^SMagma~`Totem^SScript^S!totem.fire.active^t^N3^T^SAbility^Sancestral_swiftness^SEnabled^B^SName^SAncestral~`Swiftness^SScript^S^t^N4^T^SAbility^Sunleash_elements^SEnabled^B^SName^SUnleash~`Elements^SScript^S(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)^t^N5^T^SAbility^Selemental_blast^SEnabled^B^SName^SElemental~`Blast^SScript^Sbuff.maelstrom_weapon.react>=1^t^N6^T^SAbility^Schain_lightning^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react=5|(buff.maelstrom_weapon.react>=4&!buff.ascendance.up)|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3)^SName^SChain~`Lightning^t^N7^T^SEnabled^B^SName^SWindstrike^SAbility^Swindstrike^t^N8^T^SAbility^Sfire_nova^SEnabled^B^SScript^Sactive_dot.flame_shock>=2&!((talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9))^SName^SFire~`Nova^t^N9^T^SEnabled^B^SName^SStormstrike^SAbility^Sstormstrike^t^N10^T^SAbility^Sflame_shock^SEnabled^B^SName^SFlame~`Shock^SScript^S(talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9)|!ticking^t^N11^T^SEnabled^B^SName^SLava~`Lash^SAbility^Slava_lash^t^N12^T^SEnabled^B^SName^SUnleash~`Elements~`(1)^SAbility^Sunleash_elements^t^N13^T^SAbility^Sfrost_shock^SEnabled^B^SName^SFrost~`Shock^SScript^S(talent.elemental_fusion.enabled&dot.flame_shock.remains>=16)|!talent.elemental_fusion.enabled^t^N14^T^SAbility^Schain_lightning^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react>=1&!buff.ascendance.up^SName^SChain~`Lightning~`(1)^t^N15^T^SAbility^Ssearing_totem^SEnabled^B^SName^SMagma~`Totem~`(1)^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^t^t^SSpecialization^N263^SName^S@Enhancement,~`3~`Cleave^t^^" )
	
	Hekili.Default( "@Enhancement, 4 Cleave", "actionLists", "^1^T^SActions^T^N1^T^SEnabled^B^SScript^Spet.searing_totem.remains>=15|pet.magma_totem.remains>=15|pet.fire_elemental_totem.remains>=15^SName^SLiquid~`Magma^SAbility^Sliquid_magma^t^N2^T^SEnabled^B^SScript^S!totem.fire.active^SName^SMagma~`Totem^SAbility^Smagma_totem^t^N3^T^SEnabled^b^SScript^S^SName^SAncestral~`Swiftness^SAbility^Sancestral_swiftness^t^N4^T^SEnabled^B^SName^SFire~`Nova^SScript^Sactive_dot.flame_shock>=2&!((talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9))^SAbility^Sfire_nova^t^N5^T^SEnabled^B^SScript^S(talent.unleashed_fury.enabled|set_bonus.tier16_2pc_melee=1)^SName^SUnleash~`Elements^SAbility^Sunleash_elements^t^N6^T^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react>=1^SName^SElemental~`Blast^SAbility^Selemental_blast^t^N7^T^SEnabled^B^SName^SChain~`Lightning^SScript^Sbuff.maelstrom_weapon.react=5|(buff.maelstrom_weapon.react>=4&!buff.ascendance.up)|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3)^SAbility^Schain_lightning^t^N8^T^SEnabled^B^SName^SWindstrike^SAbility^Swindstrike^t^N9^T^SEnabled^B^SName^SStormstrike^SAbility^Sstormstrike^t^N10^T^SEnabled^B^SScript^S(talent.elemental_fusion.enabled&buff.elemental_fusion.stack=2&buff.unleash_flame.up&dot.flame_shock.remains<16)|(!talent.elemental_fusion.enabled&buff.unleash_flame.up&dot.flame_shock.remains<=9)|!ticking^SName^SFlame~`Shock^SAbility^Sflame_shock^t^N11^T^SEnabled^B^SName^SLava~`Lash^SAbility^Slava_lash^t^N12^T^SEnabled^B^SName^SUnleash~`Elements~`(1)^SAbility^Sunleash_elements^t^N13^T^SEnabled^B^SScript^S(talent.elemental_fusion.enabled&dot.flame_shock.remains>=16)|!talent.elemental_fusion.enabled^SName^SFrost~`Shock^SAbility^Sfrost_shock^t^N14^T^SEnabled^B^SName^SChain~`Lightning~`(1)^SScript^Sbuff.maelstrom_weapon.react>=1&!buff.ascendance.up^SAbility^Schain_lightning^t^N15^T^SEnabled^B^SScript^Stotem.fire.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up^SName^SMagma~`Totem~`(1)^SAbility^Ssearing_totem^t^t^SName^S@Enhancement,~`4~`Cleave^SSpecialization^N263^t^^" )
	
	Hekili.Default( "@Enhancement, AOE", 'actionLists', "^1^T^SSpecialization^N263^SName^S@Enhancement,~`AOE^SActions^T^N1^T^SAbility^Sliquid_magma^SEnabled^B^SScript^Spet.searing_totem.remains>=15|pet.magma_totem.remains>=15|pet.fire_elemental_totem.remains>=15^SName^SLiquid~`Magma^t^N2^T^SAbility^Sfire_nova^SEnabled^B^SScript^Sactive_dot.flame_shock>=3^SName^SFire~`Nova^t^N3^T^SEnabled^B^SName^SWait^SArgs^Ssec=cooldown.fire_nova.remains^SAbility^Swait^SScript^Sactive_dot.flame_shock>=4&cooldown.fire_nova.remains<=action.fire_nova.gcd^t^N4^T^SAbility^Smagma_totem^SEnabled^B^SScript^S!totem.fire.active^SName^SMagma~`Totem^t^N5^T^SEnabled^b^SName^SAncestral~`Swiftness^SAbility^Sancestral_swiftness^t^N6^T^SAbility^Slava_lash^SEnabled^B^SScript^Sdot.flame_shock.ticking^SName^SLava~`Lash^t^N7^T^SAbility^Selemental_blast^SEnabled^B^SScript^Sbuff.maelstrom_weapon.react>=1^SName^SElemental~`Blast^t^N8^T^SAbility^Schain_lightning^SEnabled^B^SScript^Sactive_enemies>=4&(buff.maelstrom_weapon.react=5|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3))^SName^SChain~`Lightning^t^N9^T^SEnabled^B^SName^SUnleash~`Elements^SAbility^Sunleash_elements^t^N10^T^SEnabled^B^SName^SFlame~`Shock^SArgs^Scycle_targets=1^SAbility^Sflame_shock^SScript^S!ticking^t^N11^T^SAbility^Slightning_bolt^SEnabled^B^SScript^S(!glyph.chain_lightning.enabled|active_enemies<=3)&(buff.maelstrom_weapon.react=5|(buff.ancestral_swiftness.up&buff.maelstrom_weapon.react>=3))^SName^SLightning~`Bolt^t^N12^T^SEnabled^B^SName^SWindstrike^SAbility^Swindstrike^t^N13^T^SAbility^Sfire_nova^SEnabled^B^SScript^Sactive_dot.flame_shock>=2^SName^SFire~`Nova~`(1)^t^N14^T^SAbility^Schain_lightning^SEnabled^B^SScript^Sactive_enemies>=2&buff.maelstrom_weapon.react>=1^SName^SChain~`Lightning~`(1)^t^N15^T^SEnabled^B^SName^SStormstrike^SAbility^Sstormstrike^t^N16^T^SAbility^Sfrost_shock^SEnabled^B^SScript^Sactive_enemies<4^SName^SFrost~`Shock^t^N17^T^SAbility^Schain_lightning^SEnabled^B^SScript^Sactive_enemies>=4&buff.maelstrom_weapon.react>=1^SName^SChain~`Lightning~`(2)^t^N18^T^SAbility^Slightning_bolt^SEnabled^B^SScript^S(!glyph.chain_lightning.enabled|active_enemies<=3)&buff.maelstrom_weapon.react>=1^SName^SLightning~`Bolt~`(1)^t^N19^T^SAbility^Sfire_nova^SEnabled^B^SScript^Sactive_dot.flame_shock>=1^SName^SFire~`Nova~`(2)^t^t^t^^" )
	
	Hekili.Default( "@Enhancement, Cooldowns", 'actionLists', "^1^T^SActions^T^N1^T^SEnabled^b^SName^SBloodlust^SScript^Starget.health_pct<25|time>0.500^SAbility^Sbloodlust^t^N2^T^SAbility^Sheroism^SEnabled^b^SName^SHeroism^SScript^Starget.health_pct<25|time>0.500^t^N3^T^SEnabled^B^SName^SBlood~`Fury^SAbility^Sblood_fury^t^N4^T^SEnabled^B^SName^SBerserking^SAbility^Sberserking^t^N5^T^SEnabled^B^SName^SElemental~`Mastery^SAbility^Selemental_mastery^t^N6^T^SEnabled^B^SName^SStorm~`Elemental~`Totem^SAbility^Sstorm_elemental_totem^t^N7^T^SEnabled^B^SName^SFire~`Elemental~`Totem^SAbility^Sfire_elemental_totem^t^N8^T^SEnabled^B^SName^SAscendance^SScript^Scooldown.strike.remains>=action.stormstrike.cooldown/2^SAbility^Sascendance^t^N9^T^SEnabled^B^SName^SFeral~`Spirit^SAbility^Sferal_spirit^t^t^SSpecialization^N263^SName^S@Enhancement,~`Cooldowns^t^^" )
	
	Hekili.Default( "@Shaman, Interrupt", 'actionLists', "^1^T^SName^S@Shaman,~`Interrupt^SSpecialization^N0^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SWind~`Shear^SAbility^Swind_shear^SCaption^SShear^SScript^Starget.casting^t^t^t^^" )
	
	Hekili.Default( "@Shaman, Buffs", 'actionLists', "^1^T^SSpecialization^N0^SName^SShaman,~`Buffs^SActions^T^N1^T^SAbility^Slightning_shield^SEnabled^B^SScript^S!buff.lightning_shield.up^SName^SLightning~`Shield^t^t^t^^" )
	
	Hekili.Default( "@Elemental, Single Target", "actionLists", "^1^T^SActions^T^N1^T^SEnabled^B^SAbility^Sliquid_magma^SName^SLiquid~`Magma^SScript^Stotem.fire.remains>=15^t^N2^T^SEnabled^B^SAbility^Sancestral_swiftness^SName^SAncestral~`Swiftness^SScript^S!buff.ascendance.up^t^N3^T^SEnabled^B^SAbility^Sunleash_flame^SName^SUnleash~`Flame^SScript^Stalent.unleashed_fury.enabled&!buff.ascendance.up^t^N4^T^SEnabled^B^SName^SSpiritwalker's~`Grace^SArgs^S^SAbility^Sspiritwalkers_grace^SScript^Sbuff.ascendance.up&moving^t^N5^T^SEnabled^B^SAbility^Searth_shock^SName^SEarth~`Shock^SScript^Sbuff.lightning_shield.react=buff.lightning_shield.max_stack^t^N6^T^SEnabled^B^SAbility^Slava_burst^SName^SLava~`Burst^SScript^Sdot.flame_shock.remains>cast_time&(buff.ascendance.up|cooldown_react)^t^N7^T^SEnabled^B^SAbility^Sflame_shock^SName^SFlame~`Shock^SScript^Sdot.flame_shock.remains<=9^t^N8^T^SEnabled^B^SAbility^Searth_shock^SName^SEarth~`Shock~`(1)^SScript^S(set_bonus.tier17_4pc&buff.lightning_shield.react>=15&!buff.lava_surge.up)|(!set_bonus.tier17_4pc&buff.lightning_shield.react>15)^t^N9^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^t^N10^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake~`(1)^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^t^N11^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake~`(2)^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^t^N12^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake~`(3)^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^t^N13^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake~`(4)^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^t^N14^T^SEnabled^B^SAbility^Searthquake^SName^SEarthquake~`(5)^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^t^N15^T^SEnabled^B^SName^SElemental~`Blast^SAbility^Selemental_blast^t^N16^T^SEnabled^B^SAbility^Sflame_shock^SName^SFlame~`Shock~`(1)^SScript^Stime>60&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<duration^t^N17^T^SEnabled^B^SAbility^Ssearing_totem^SName^SSearing~`Totem^SScript^S(!talent.liquid_magma.enabled&!totem.fire.active)|(talent.liquid_magma.enabled&pet.searing_totem.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up)^t^N18^T^SEnabled^B^SName^SSpiritwalker's~`Grace~`(1)^SArgs^S^SAbility^Sspiritwalkers_grace^SScript^Smoving&((talent.elemental_blast.enabled&cooldown.elemental_blast.remains=0)|(cooldown.lava_burst.remains=0&!buff.lava_surge.react))^t^N19^T^SEnabled^B^SName^SLightning~`Bolt^SAbility^Slightning_bolt^t^t^SScript^S^SSpecialization^N262^SName^SElemental,~`Single~`Target^t^^" )
	
	Hekili.Default( "@Elemental, 2-4 Cleave", "actionLists", "^1^T^SEnabled^B^SName^SElemental,~`2-4~`Cleave^SAbility^Slightning_bolt^SSpecialization^N262^SActions^T^N1^T^SAbility^Sliquid_magma^SScript^Stotem.fire.remains>=15^SName^SLiquid~`Magma^SEnabled^B^t^N2^T^SAbility^Sancestral_swiftness^SScript^S!buff.ascendance.up^SName^SAncestral~`Swiftness^SEnabled^b^t^N3^T^SAbility^Schain_lightning^SScript^Sactive_enemies>2&!buff.improved_chain_lightning.up&cooldown.earthquake.remains<=cast_time^SName^SChain~`Lightning^SEnabled^B^t^N4^T^SAbility^Searthquake^SScript^Sbuff.improved_chain_lightning.up^SName^SEarthquake~`(0)^SEnabled^B^t^N5^T^SAbility^Sunleash_flame^SScript^Stalent.unleashed_fury.enabled&!buff.ascendance.up^SName^SUnleash~`Flame^SEnabled^B^t^N6^T^SEnabled^B^SName^SSpiritwalker's~`Grace^SArgs^S^SAbility^Sspiritwalkers_grace^SScript^Sbuff.ascendance.up&moving^t^N7^T^SAbility^Searth_shock^SScript^Sbuff.lightning_shield.react=buff.lightning_shield.max_stack^SName^SEarth~`Shock^SEnabled^B^t^N8^T^SAbility^Slava_burst^SScript^Sdot.flame_shock.remains>cast_time&(buff.ascendance.up|cooldown_react)^SName^SLava~`Burst^SEnabled^B^t^N9^T^SAbility^Sflame_shock^SScript^Sdot.flame_shock.remains<=9^SName^SFlame~`Shock^SEnabled^B^t^N10^T^SAbility^Searth_shock^SScript^S(set_bonus.tier17_4pc&buff.lightning_shield.react>=15&!buff.lava_surge.up)|(!set_bonus.tier17_4pc&buff.lightning_shield.react>15)^SName^SEarth~`Shock~`(1)^SEnabled^B^t^N11^T^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^SName^SEarthquake^SEnabled^B^t^N12^T^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^SName^SEarthquake~`(1)^SEnabled^B^t^N13^T^SAbility^Searthquake^SScript^S!talent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=(1.5+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^SName^SEarthquake~`(2)^SEnabled^B^t^N14^T^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&buff.elemental_mastery.down&buff.bloodlust.down^SName^SEarthquake~`(3)^SEnabled^B^t^N15^T^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=1.3*((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.up|buff.bloodlust.up)^SName^SEarthquake~`(4)^SEnabled^B^t^N16^T^SAbility^Searthquake^SScript^Stalent.unleashed_fury.enabled&((1+stat.spell_haste)*(1+(mastery_value*2%4.5))>=((1.3*1.5)+(1.25*0.226305)+1.25*(2*0.226305*stat.multistrike_pct%100)))&target.time_to_die>10&(buff.elemental_mastery.remains>=10|buff.bloodlust.remains>=10)^SName^SEarthquake~`(5)^SEnabled^B^t^N17^T^SEnabled^B^SName^SElemental~`Blast^SAbility^Selemental_blast^t^N18^T^SAbility^Sflame_shock^SScript^Stime>60&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<duration^SName^SFlame~`Shock~`(1)^SEnabled^B^t^N19^T^SAbility^Ssearing_totem^SScript^S(!talent.liquid_magma.enabled&!totem.fire.active)|(talent.liquid_magma.enabled&pet.searing_totem.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up)^SName^SSearing~`Totem^SEnabled^B^t^N20^T^SEnabled^B^SName^SSpiritwalker's~`Grace~`(1)^SArgs^S^SAbility^Sspiritwalkers_grace^SScript^Smoving&((talent.elemental_blast.enabled&cooldown.elemental_blast.remains=0)|(cooldown.lava_burst.remains=0&!buff.lava_surge.react))^t^N21^T^SAbility^Schain_lightning^SScript^Sactive_enemies>1^SName^SChain~`Lightning~`(1)^SEnabled^B^t^N22^T^SEnabled^B^SAbility^Slightning_bolt^SName^SLightning~`Bolt^SScript^S^t^t^SScript^S^t^^" )
	
	Hekili.Default( "@Elemental, AOE", "actionLists", "^1^T^SSpecialization^N262^SName^SElemental,~`AOE^SScript^S^SActions^T^N1^T^SAbility^Sancestral_swiftness^SScript^S!buff.ascendance.up^SName^SAncestral~`Swiftness^SEnabled^b^t^N2^T^SAbility^Sliquid_magma^SScript^Spet.searing_totem.remains>=15|pet.fire_elemental_totem.remains>=15^SName^SLiquid~`Magma^SEnabled^B^t^N3^T^SAbility^Searthquake^SScript^S(buff.enhanced_chain_lightning.up|level<=90)&active_enemies>=2^SName^SEarthquake^SEnabled^B^t^N4^T^SEnabled^B^SName^SLava~`Beam^SAbility^Slava_beam^t^N5^T^SAbility^Searth_shock^SScript^Sbuff.lightning_shield.react=buff.lightning_shield.max_stack^SName^SEarth~`Shock^SEnabled^B^t^N6^T^SAbility^Sthunderstorm^SScript^Sactive_enemies>=10^SName^SThunderstorm^SEnabled^B^t^N7^T^SAbility^Ssearing_totem^SScript^S(!talent.liquid_magma.enabled&!totem.fire.active)|(talent.liquid_magma.enabled&pet.searing_totem.remains<=20&!pet.fire_elemental_totem.active&!buff.liquid_magma.up)^SName^SSearing~`Totem^SEnabled^B^t^N8^T^SAbility^Schain_lightning^SScript^Sactive_enemies>=2^SName^SChain~`Lightning^SEnabled^B^t^N9^T^SEnabled^B^SName^SLightning~`Bolt^SAbility^Slightning_bolt^t^t^t^^" )
	
	Hekili.Default( "@Elemental, Cooldowns", "actionLists", "^1^T^SEnabled^B^SSpecialization^N262^SAbility^Sbloodlust^SName^SElemental,~`Cooldowns^SActions^T^N1^T^SAbility^Sbloodlust^SScript^Starget.health.pct<25|time>0.500^SName^SBloodlust^SEnabled^b^t^N2^T^SEnabled^B^SAbility^Sheroism^SName^SHeroism^SScript^Starget.health_pct<25|time>0.500^t^N3^T^SAbility^Sberserking^SScript^S!buff.bloodlust.up&!buff.elemental_mastery.up&(set_bonus.tier15_4pc_caster=1|(buff.ascendance.cooldown_remains=0&(dot.flame_shock.remains>buff.ascendance.duration|level<87)))^SName^SBerserking^SEnabled^B^t^N4^T^SAbility^Sblood_fury^SScript^Sbuff.bloodlust.up|buff.ascendance.up|((cooldown.ascendance.remains>10|level<87)&cooldown.fire_elemental_totem.remains>10)^SName^SBlood~`Fury^SEnabled^B^t^N5^T^SAbility^Selemental_mastery^SScript^Saction.lava_burst.cast_time>=1.2^SName^SElemental~`Mastery^SEnabled^B^t^N6^T^SEnabled^B^SName^SStorm~`Elemental~`Totem^SAbility^Sstorm_elemental_totem^t^N7^T^SAbility^Sfire_elemental_totem^SScript^S!active^SName^SFire~`Elemental~`Totem^SEnabled^B^t^N8^T^SAbility^Sascendance^SScript^Sactive_enemies>1|(dot.flame_shock.remains>buff.ascendance.duration&(target.time_to_die<20|buff.bloodlust.up|time>=60)&cooldown.lava_burst.remains>0)^SName^SAscendance^SEnabled^B^t^t^SScript^S^t^^" )
	
	
	
	

	Hekili.Default( "@Enhancement, Primary", 'displays', "^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SMaelstrom~`Weapon^Srel^SCENTER^SSpecialization^N263^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Shaman,~`Buffs^SScript^S^SCleave^B^SName^SBuffs^SAOE^B^SSingle^B^t^N2^T^SEnabled^B^SAction~`List^S@Shaman,~`Interrupt^SScript^Stoggle.interrupts^SCleave^B^SName^SInterrupt^SAOE^B^SSingle^B^t^N3^T^SEnabled^B^SAction~`List^S@Enhancement,~`Cooldowns^SScript^Stoggle.cooldowns^SCleave^B^SName^SCooldowns^SAOE^B^SSingle^B^t^N4^T^SEnabled^B^SAction~`List^S@Enhancement,~`Single~`Target^SName^SSingle~`Target^SScript^Ssingle|(cleave&active_enemies=1)^SSingle^B^t^N5^T^SEnabled^B^SAction~`List^S@Enhancement,~`2~`Cleave^SName^S2~`Target~`Cleave^SScript^Scleave&active_enemies=2^t^N6^T^SEnabled^B^SAction~`List^S@Enhancement,~`3~`Cleave^SName^S3~`Target~`Cleave^SScript^Scleave&active_enemies=3^t^N7^T^SEnabled^B^SAction~`List^S@Enhancement,~`4~`Cleave^SName^S4~`Target~`Cleave^SScript^Scleave&active_enemies>=4^t^N8^T^SEnabled^B^SAction~`List^S@Enhancement,~`AOE^SScript^Saoe^SAOE^B^SName^SAOE^t^t^SScript^S^SSpecialization~`Group^Sboth^SIcons~`Shown^N5^Sy^F-7740562396413950^f-45^STalent~`Group^N0^SName^S@Enhancement,~`Primary^SPvP~`Visibility^Salways^SPrimary~`Caption^Sbuff^Sx^F-6333187512860670^f-46^SAction~`Captions^B^SFont^SABF^t^^" )
	
	Hekili.Default( "@Enhancement, AOE", 'displays', "^1^T^SPrimary~`Icon~`Size^N30^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SFlame~`Shock^Srel^SCENTER^SSpecialization^N263^SSpacing^N15^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N30^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Enhancement,~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^S@Enhancement,~`AOE^SName^SAOE^SScript^S^t^t^SScript^S^SSpecialization~`Group^Sboth^SIcons~`Shown^N3^Sy^F-6333187512860670^f-45^SFont^SABF^SName^S@Enhancement,~`AOE^SPvP~`Visibility^Salways^SPrimary~`Caption^Sratio^Sx^F-6333187512860677^f-47^SAction~`Captions^B^STalent~`Group^N0^t^^" )
	
	Hekili.Default( "@Elemental, Primary", 'displays', 	"^1^T^SPrimary~`Icon~`Size^N40^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SLightning~`Shield^Srel^SCENTER^SSpecialization^N262^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Shaman,~`Buffs^SName^SBuffs^SScript^S^t^N2^T^SEnabled^B^SAction~`List^S@Shaman,~`Interrupt^SName^SInterrupt^SScript^Stoggle.interrupts^t^N3^T^SEnabled^B^SAction~`List^S@Elemental,~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N4^T^SEnabled^B^SAction~`List^S@Elemental,~`Single~`Target^SName^SSingle~`Target^SScript^Ssingle|(cleave&active_enemies=1)^t^N5^T^SEnabled^B^SAction~`List^S@Elemental,~`2-4~`Cleave^SName^S2-4~`Target~`Cleave^SScript^Scleave&active_enemies>1&active_enemies<5^t^N6^T^SEnabled^B^SAction~`List^S@Elemental,~`AOE^SName^SAOE^SScript^Saoe^t^t^SScript^S^STalent~`Group^N0^SIcons~`Shown^N5^Sy^N-220^Sx^N-90^SName^S@Elemental,~`Primary^SPvP~`Visibility^Salways^SPrimary~`Caption^Sbuff^SMaximum~`Time^N30^SAction~`Captions^B^SFont^SArial~`Narrow^t^^" )
	
	Hekili.Default( "@Elemental, AOE", 'displays', "^1^T^SPrimary~`Icon~`Size^N30^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SSpecialization^N262^SSpacing^N15^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N30^SEnabled^B^SQueues^T^N1^T^SEnabled^B^SAction~`List^S@Elemental,~`Cooldowns^SName^SCooldowns^SScript^Stoggle.cooldowns^t^N2^T^SEnabled^B^SAction~`List^S@Elemental,~`AOE^SName^SAOE^SScript^S^t^t^SScript^S^STalent~`Group^N0^SIcons~`Shown^N3^Sy^F-6333187512860670^f-45^Sx^F-6333187512860677^f-47^SName^S@Elemental,~`AOE^SPvP~`Visibility^Salways^SPrimary~`Caption^Stargets^SMaximum~`Time^N30^SAction~`Captions^B^SFont^SArial~`Narrow^t^^" )
	
end