-- Warrior.lua
-- August 2014


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass("player")) == "WARRIOR") then

	-- AddResource( SPELL_POWER_HEALTH )
	AddResource( SPELL_POWER_RAGE )
	
	AddTalent( 152278,	"anger_management" )
	AddTalent( 152276,	"gladiators_resolve" )
	AddTalent( 152277,	"ravager" )
	AddTalent( 176289,	"siegebreaker" )
	AddTalent( 107574,	"avatar" )
	AddTalent( 46294,	"bladestorm" )
	AddTalent( 12292,	"bloodbath" )
	AddTalent( 114028,	"mass_spell_reflection" )
	AddTalent( 114029,	"safeguard" )
	AddTalent( 114030,	"vigilance" )
	AddTalent( 118000,	"dragon_roar" )
	AddTalent( 46968,	"shockwave" )
	AddTalent( 107570,	"storm_bolt" )
	AddTalent( 169679,	"furious_strikes" )
	AddTalent( 169680,	"heavy_repercussions" )
	AddTalent( 1464,	"slam" )
	AddTalent( 29725,	"sudden_death" )
	AddTalent( 56636,	"taste_for_blood" )
	AddTalent( 169683,	"unquenchable_thirst" )
	AddTalent( 169685,	"unyielding_strikes" )
	AddTalent( 55694,	"enraged_regeneration" )
	AddTalent( 103840,	"impending_victory" )
	AddTalent( 29838,	"second_wind" )
	AddTalent( 103827,	"double_time" )
	AddTalent( 103826,	"juggernaut" )
	AddTalent( 103828,	"warbringer" )

	-- Glyphs.
	AddGlyph( 58377,	"blitz" )
	AddGlyph( 58096,	"bloodcurdling_shout" )
	AddGlyph( 58367,	"bloodthirst" )
	AddGlyph( 58369,	"bloody_healing" )
	AddGlyph( 94372,	"bull_rush" )
	AddGlyph( 115946,	"burning_anger" )
	AddGlyph( 159701,	"cleave" )
	AddGlyph( 89003,	"colossus_smash" )
	AddGlyph( 115943,	"crow_feast" )
	AddGlyph( 63325,	"death_from_above" )
	AddGlyph( 58386,	"die_by_the_sword" )
	AddGlyph( 58355,	"enraged_speed" )
	AddGlyph( 159761,	"flawless_defense" )
	AddGlyph( 58357,	"gag_order" )
	AddGlyph( 58099,	"gushing_wound" )
	AddGlyph( 58385,	"hamstring" )
	AddGlyph( 58388,	"heavy_repercussions" )
	AddGlyph( 159708,	"heroic_leap" )
	AddGlyph( 58366,	"hindering_strikes" )
	AddGlyph( 58364,	"hold_the_line" )
	AddGlyph( 146970,	"impaling_throws" )
	AddGlyph( 63327,	"intimidation_shout" )
	AddGlyph( 58097,	"long_charge" )
	AddGlyph( 58104,	"mighty_victory" )
	AddGlyph( 159738,	"mocking_banner" )
	AddGlyph( 58368,	"mortal_strike" )
	AddGlyph( 58095,	"mystic_shout" )
	AddGlyph( 159740,	"raging_blow" )
	AddGlyph( 58370,	"raging_wind" )
	AddGlyph( 159754,	"rallying_cry" )
	AddGlyph( 94374,	"recklessness" )
	AddGlyph( 58356,	"resonating_power" )
	AddGlyph( 58372,	"rude_interruption" )
	AddGlyph( 159759,	"shattering_throw" )
	AddGlyph( 58375,	"shield_slam" )
	AddGlyph( 63329,	"shield_wall" )
	AddGlyph( 63328,	"spell_reflection" )
	AddGlyph( 58384,	"sweeping_strikes" )
	AddGlyph( 123779,	"blazing_trail" )
	AddGlyph( 159703,	"drawn_sword" )
	AddGlyph( 146971,	"executor" )
	AddGlyph( 146968,	"raging_whirlwind" )
	AddGlyph( 146969,	"subtle_defender" )
	AddGlyph( 146973,	"watchful_eye" )
	AddGlyph( 146974,	"weaponmaster" )
	AddGlyph( 68164,	"thunder_strike" )
	AddGlyph( 58098,	"unending_rage" )
	AddGlyph( 146965,	"victorious_throw" )
	AddGlyph( 58382,	"victory_rush" )
	AddGlyph( 63324,	"wind_and_thunder" )
	
	-- Player Buffs.
	

	-- Abilities.
	AddSpell( 6673,		"battle_shout" )
	AddSpell( 2457,		"battle_stance" )
	AddSpell( 18499,	"berserker_rage" )
	AddSpell( 100,		"charge" )
	AddSpell( 469,		"commanding_shout" )
	AddSpell( 115767,	"deep_wounds" )
	AddSpell( 71,		"defensive_stance" )
	AddSpell( 174894,	"devastate" ) -- 20243
	AddSpell( 1715,		"hamstring" )
	AddSpell( 158836,	"headlong_rush" )
	AddSpell( 6544,		"heroic_leap" )
	AddSpell( 78,		"heroic_strike" )
	AddSpell( 57755,	"heroic_throw" )
	AddSpell( 3411,		"intervene" )
	AddSpell( 5246,		"intimidating_shout" )
	AddSpell( 6552,		"pummel" )
	AddSpell( 112048,	"shield_barrier" )
	AddSpell( 23920,	"spell_reflection" )
	AddSpell( 355,		"taunt" )
	AddSpell( 34428,	"victory_rush" )
	AddSpell( 84608,	"bastion_of_defense" )
	AddSpell( 46915,	"bloodsurge" )
	AddSpell( 23881,	"bloodthirst" )
	AddSpell( 167105,	"colossus_smash" )
	-- AddSpell( 86346,	"colossus_smash" )	-- Fury: Catch this in IsKnown()
	AddSpell( 1160,		"demoralizing_shout" )
	AddSpell( 174892,	"devastate" )
	-- AddSpell( 174893,	"devastate" )	-- Fury: Catch this in IsKnown()
	AddSpell( 118038,	"die_by_the_sword" )
	AddSpell( 13046, 	"enrage" )
	AddSpell( 5308,		"execute" )
	-- AddSpell( 163201,	"execute" )		-- Arms: Catch this in IsKnown()
	AddSpell( 12975,	"last_stand" )
	AddSpell( 114192,	"mocking_banner" )
	AddSpell( 12294,	"mortal_strike" )
	AddSpell( 12323,	"piercing_howl" )
	AddSpell( 85288,	"raging_blow" )
	AddSpell( 97462,	"rallying_cry" )
	AddSpell( 1719,		"recklessness" )
	AddSpell( 772,		"rend" )
	AddSpell( 6572,		"revenge" )
	AddSpell( 174926,	"shield_barrier" )
	AddSpell( 2565,		"shield_block" )
	AddSpell( 23922,	"shield_slam" )
	AddSpell( 871,		"shield_wall" )
	AddSpell( 12328,	"sweeping_strikes" )
	AddSpell( 6343,		"thunder_clap" )
	AddSpell( 1680,		"whirlwind" )
	AddSpell( 100130,	"wild_strike" )
	

	-- DoT abilities that we will want to track power.
	SetGCD( "battle_shout" )

	-- Gear Sets
	-- AddItemSet( "tier16_melee", 99347, 99340, 99341, 99342, 99343 )
	-- AddItemSet( "tier15_melee", 96689, 96690, 96691, 96692, 96693 )
	-- AddItemSet( "tier14_melee", 87138, 87137, 87136, 87135, 87134 )

	-- AddAction( name,
	-- { resource = delta },
	-- base cast time, GCD type, cooldown )

	AddAction( "battle_stance",
	0, nil,
	0, 'melee', 1.5 )
	
	AddHandler( "battle_stance", function ()
		H:RemoveBuff( 'defensive_stance' )
		H:RemoveBuff( 'gladiator_stance' )
		H:Buff( "battle_stance", 3600 )
	end )
	
	
	AddAction( "charge",
	{ SPELL_POWER_RAGE	= function()
		if glyph.bull_rush.enabled then
			return -35
		end
		return -20
	end },
	0, 'melee',	20 )
	
	AddHandler( "charge", function ()
		H:Debuff( "target", "charge", 1.5 )
	end )
	
	
	AddAction( "recklessness",
	0, nil,
	0, 'melee', 180 )
	
	AddHandler( "recklessness", function ()
		H:Buff( "recklessness", 10 )
		H:RemoveBuff( "defensive_stance" )
		H:Buff( "battle_stance", 3600 )
	end )
	
	
	AddAction( "avatar",
	0, nil,
	0, 'melee', 180 )
	
	AddHandler( "avatar", function ()
		H:Buff( "avatar", 24 )
	end )
	-- NYI: No current way to 'remove all roots and snares'
	
	
	AddAction( "bloodbath",
	0, nil,
	0, 'melee', 60 )
	
	AddHandler( "bloodbath", function ()
		H:Buff( "bloodbath", 12 )
	end )
	
	
	AddAction( "heroic_leap",
	0, nil,
	0, 'melee', 45 )
	
	
	AddAction( "rend",
	{ SPELL_POWER_RAGE	= 5 },
	0, 'melee', 0 )
	
	AddHandler( "rend", function ()
		H:Debuff( 'target', "rend", 18 )
	end )
	
	
	AddAction( "mortal_strike",
	{ SPELL_POWER_RAGE	= 20 },
	0, 'melee', function()
		return 6 * haste
	end )
	
	AddHandler( "mortal_strike", function ()
		H:Debuff( 'target', 'mortal_strike', 10 )
	end )
	
	
	-- This is the 'leap out and charge back' mechanic to generate rage.
	-- AddAction( "heroic_charge", ...

	
	AddAction( "ravager",
	0, nil,
	0, 'melee', 60 )
	
	
	AddAction( "colossus_smash",
	0, nil,
	0, 'melee', 20 )
	
	AddHandler( "colossus_smash", function ()
		H:Debuff( 'target', 'colossus_smash', 6 )
		H:RemoveBuff( 'defensive_stance' )
		H:Buff( 'battle_stance', 3600 )
	end )
	
	
	AddAction( "storm_bolt",
	0, nil,
	0, 'melee', 30 )
	
	AddHandler( "storm_bolt", function ()
		H:Debuff( 'target', 'storm_bolt', 4 )
	end )
	
	
	AddAction( "dragon_roar",
	0, nil,
	0, 'melee', 60 )
	
	AddHandler( "dragon_roar", function ()
		H:Debuff( 'target', 'dragon_roar', 0.5 )
	end )
	
	
	AddAction( "execute",
	{ SPELL_POWER_RAGE = function ()
		if player.specialization == 71 then
			return max(10, min(rage.current, 40))
		end
		return 10
	end },
	0, 'melee', 0 )
	
	
	AddAction( "impending_victory",
	{ SPELL_POWER_RAGE	= 10 },
	0, melee, 30 )
	
	
	AddAction( "siegebreaker",
	0, nil,
	0, 'melee', 45 )
	
	AddHandler( "siegebreaker", function ()
		H:Debuff( 'target', 'siegebreaker', 1 )
	end )
	
	
	AddAction( "slam",
	{ SPELL_POWER_RAGE	= function ()
		return 10 * (1 + buff.slam.count)
	end },
	0, 'melee', 0 )
	
	AddHandler( "slam", function ()
		if buff.slam.count < 2 then
			H:AddStack( "slam", 2, 1 )
		end
	end )
	
	
	AddAction( "whirlwind",
	{ SPELL_POWER_RAGE	= 20 },
	0, 'melee', 0 )
	
	
	AddAction( "shockwave",
	0, nil,
	0, 'melee', function ()
		if active_enemies >= 3 then
			return 20
		end
		return 40
	end )
	
	AddHandler( "shockwave", function ()
		H:Debuff( 'target', 'shockwave', 4 )
	end )
	
	
	AddAction( "pummel",
	0, nil,
	0, 'melee', 15 )
	
	AddHandler( "pummel", function ()
		H:Interrupt( 'target' )
	end )

end