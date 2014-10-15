-- Paladin.lua
-- August 2014


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass("player")) == "PALADIN") then

	-- AddResource( SPELL_POWER_HEALTH )
	AddResource( SPELL_POWER_MANA )
	AddResource( SPELL_POWER_HOLY_POWER )

	AddTalent( 85499,	"speed_of_light" )
	AddTalent( 87172,	"long_arm_of_the_law" )
	AddTalent( 26023,	"pursuit_of_justice" )
	AddTalent( 105593,	"fist_of_justice" )
	AddTalent( 200066,	"repentance" )
	AddTalent( 115750,	"blinding_light" )
	AddTalent( 85804,	"selfless_healer" )
	AddTalent( 114163,	"eternal_flame" )
	AddTalent( 20925,	"sacred_shield" )
	AddTalent( 114039,	"hand_of_purity" )
	AddTalent( 114154,	"unbreakable_spirit" )
	AddTalent( 105622,	"clemency" )
	AddTalent( 105809,	"holy_avenger" )
	AddTalent( 53376,	"sanctified_wrath" )
	AddTalent( 86172,	"divine_purpose" )
	AddTalent( 114165,	"holy_prism" )
	AddTalent( 114158,	"lights_hammer" )
	AddTalent( 114157,	"execution_sentence" )
	AddTalent( 152263,	"empowered_seals" )
	AddTalent( 152262,	"seraphim" )
	AddTalent( 157048,	"final_verdict" )

	-- Glyphs.
	AddGlyph( 159548,	"ardent_defender" )
	AddGlyph( 54927,	"avenging_wrath" )
	AddGlyph( 63218,	"beacon_of_light" )
	AddGlyph( 115934,	"bladed_judgment" )
	AddGlyph( 54943,	"blessed_life" )
	AddGlyph( 54931,	"burden_of_guilt" )
	AddGlyph( 54928,	"consecration" )
	AddGlyph( 125043,	"contemplation" )
	AddGlyph( 56414,	"dazing_shield" )
	AddGlyph( 56420,	"denounce" )
	AddGlyph( 146955,	"devotion_aura" )
	AddGlyph( 54924,	"divine_protection" )
	AddGlyph( 146956,	"divine_shield" )
	AddGlyph( 63220,	"divine_storm" )
	AddGlyph( 159572,	"divine_wrath" )
	AddGlyph( 54939,	"divinity" )
	AddGlyph( 54992,	"double_jeopardy" )
	AddGlyph( 54935,	"final_wrath" )
	AddGlyph( 57954,	"fire_from_the_heavens" )
	AddGlyph( 57955,	"flash_of_light" )
	AddGlyph( 54930,	"focused_shield" )
	AddGlyph( 115738,	"focused_wrath" )
	AddGlyph( 63219,	"hammer_of_the_righteous" )
	AddGlyph( 159579,	"hand_of_freedom" )
	AddGlyph( 146957,	"hand_of_sacrifice" )
	AddGlyph( 54938,	"harsh_words" )
	AddGlyph( 63224,	"holy_shock" )
	AddGlyph( 54923,	"holy_wrath" )
	AddGlyph( 54937,	"illumination" )
	AddGlyph( 56416,	"immediate_truth" )
	AddGlyph( 63225,	"inquisition" )
	AddGlyph( 159592,	"judgment" )
	AddGlyph( 54940,	"light_of_dawn" )
	AddGlyph( 122028,	"mass_exorcism" )
	AddGlyph( 162604,	"merciful_wrath" )
	AddGlyph( 146959,	"pillar_of_light" )
	AddGlyph( 93466,	"protector_of_the_innocent" )
	AddGlyph( 115933,	"righteous_retreat" )
	AddGlyph( 57947,	"seal_of_blood" )
	AddGlyph( 54926,	"templars_verdict" )
	AddGlyph( 63222,	"alabaster_shield" )
	AddGlyph( 119477,	"battle_healer" )
	AddGlyph( 159557,	"consecrator" )
	AddGlyph( 146958,	"exorcist" )
	AddGlyph( 115931,	"falling_avenger" )
	AddGlyph( 159573,	"liberator" )
	AddGlyph( 89401,	"luminous_charger" )
	AddGlyph( 57958,	"mounted_king" )
	AddGlyph( 57979,	"winged_vengeance" )
	AddGlyph( 54936,	"word_of_glory" )
	
	-- Player Buffs.
	AddSpell( 20217,	"blessing_of_kings" )
	AddSpell( 19740,	"blessing_of_might" )
	AddSpell( 144595,	"divine_crusader" )
	AddSpell( 498,		"divine_protection" )
	AddSpell( 86172,	"divine_purpose" )
	AddSpell( 642,		"divine_shield" )
	AddSpell( 1044,		"hand_of_freedom" )
	AddSpell( 1022,		"hand_of_protection" )
	AddSpell( 6940,		"hand_of_sacrifice" )
	AddSpell( 25780,	"righteous_fury" )
	AddSpell( 105361,	"seal_of_command" )
	AddSpell( 20165,	"seal_of_insight" )
	AddSpell( 114250,	"selfless_healer" )

	-- Abilities.
	AddSpell( 114157,	"execution_sentence" )
	AddSpell( 152262,	"seraphim" )
	AddSpell( 157048,	"final_verdict" )
	AddSpell( 20271,	"judgment" )
	AddSpell( 53595,	"hammer_of_the_righteous" )
	AddSpell( 24275,	"hammer_of_wrath" )
	AddSpell( 31884,	"avenging_wrath" )
	AddSpell( 35395,	"crusader_strike" )
	AddSpell( 53385,	"divine_storm" )
	AddSpell( 85256,	"templars_verdict" )
	AddSpell( 879,		"exorcism" )
	AddSpell( 96231,	"rebuke" )
	

	-- DoT abilities that we will want to track power.
	SetGCD( "blessing_of_kings" )

	-- Gear Sets
	-- AddItemSet( "tier16_melee", 99347, 99340, 99341, 99342, 99343 )
	-- AddItemSet( "tier15_melee", 96689, 96690, 96691, 96692, 96693 )
	-- AddItemSet( "tier14_melee", 87138, 87137, 87136, 87135, 87134 )

	-- AddAction( name,
	-- resource cost*, resource type**,
	-- base cast time, GCD type, cooldown )

	AddAction( "avenging_wrath",
	nil,
	9, 'off', 120 )
	
	AddHandler( "avenging_wrath", function ()
		H:Buff( 'avenging_wrath', 20 )
	end )

	
	AddAction( "crusader_strike",
	{	SPELL_POWER_MANA		= 0.05,
		SPELL_POWER_HOLY_POWER	= -1 },
	0, 'melee',
	function ()
		return 4.5 * haste
	end )

	
	AddAction( "divine_storm",
	{	SPELL_POWER_HOLY_POWER = 3 },
	0, 'melee', 0 )	

	AddHandler( "divine_storm", function ()
		if buff.divine_crusader.up then
			H:RemoveBuff( "divine_crusader" )
		end
	end )

	AddAction( "execution_sentence",
	{	SPELL_POWER_MANA = 0.128 },
	0, 'spell', 60 )
	
	AddHandler( "execution_sentence", function ()
		H:Debuff( "target", "execution_sentence", 10 )
	end )

	
	AddAction( "exorcism",
	{	SPELL_POWER_MANA		= 0.04,
		SPELL_POWER_HOLY_POWER	= -1 },
	0, 'spell', 15 )
	
	AddAction( "final_verdict",
	{	SPELL_POWER_HOLY_POWER = 3 },
	0, 'spell', 0 )
	
	AddHandler( "final_verdict", function()
		H:Buff( "final_verdice", 30 )
	end )
	
	
	AddAction( "hammer_of_the_righteous",
	{	SPELL_POWER_MANA		= 0.03,
		SPELL_POWER_HOLY_POWER	= -1	},
	0, 'melee', 
	function ()
		return 4.5 * haste
	end )
	
	
	AddAction( "hammer_of_wrath",
	{	SPELL_POWER_MANA 		= 0.03,
		SPELL_POWER_HOLY_POWER	= -1 },
	0, 'spell',
	function ()
		local cd = 6 * haste
		if buff.avenging_wrath.up then
			cd = cd * 0.53376
		end
		return cd
	end )
	
	
	AddAction( "holy_avenger",
	nil,
	0, 'spell', 120 )
	
	
	AddAction( "holy_prism",
	{	SPELL_POWER_MANA = 0.054 },
	0, 'spell', 20 )
	
	
	AddAction( "judgment",
	{	SPELL_POWER_MANA		= 0.12,
		SPELL_POWER_HOLY_POWER	= -1 },
	0, 'spell',
	function()
		return 6 * haste
	end )
	
	
	AddAction( "lights_hammer",
	nil,
	0, 'spell', 60 )

	
	AddAction( "rebuke",
	{	SPELL_POWER_MANA = 0.117 },
	0, 'off', 15 )
	
	AddHandler( "rebuke", function ()
		H:Interrupt( 'target' )
	end )
	
	
	AddAction( "seal_of_righteousness",
	{	SPELL_POWER_MANA = 0.164 },
	0, 'spell', 0 )
	
	
	AddAction( "seal_of_truth",
	{	SPELL_POWER_MANA = 0.164 },
	0, 'spell', 0 )
	
	
	AddAction( "seraphim",
	{	SPELL_POWER_HOLY_POWER = 5 },
	0, 'spell', 30 )
	
	AddHandler( "seraphim", function ()
		H:Buff( "seraphim", 15 )
	end )
	
	
	AddAction( "templars_verdict",
	{	SPELL_POWER_HOLY_POWER = 3 },
	0, 'spell', 0 )
	
end