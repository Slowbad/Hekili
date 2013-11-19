-- Hekili.lua
-- The really, REALLY basic setup stuff before we get into the meat of the AddOn.
-- Hekili @ Ner'zhul [A]
-- October 2013

Hekili = LibStub("AceAddon-3.0"):NewAddon("Hekili", "AceConsole-3.0", "AceEvent-3.0")
Hekili.UI = LibStub("AceGUI-3.0")

Hekili:SetDefaultModuleLibraries("AceEvent-3.0")

Hekili.LBF = LibStub("Masque", true)
if Hekili.LBF then
	Hekili.stGroup = Hekili.LBF:Group("Hekili", "Single Target")
	Hekili.aeGroup = Hekili.LBF:Group("Hekili", "Multi-Target")
end

Hekili.Tooltip = CreateFrame("GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate")

BINDING_HEADER_HEKILI_HEADER = "Hekili Priority Helper"
BINDING_NAME_HEKILI_TOGGLE = "Enable/Disable Hekili"
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Priority Cooldowns"

Hekili.Modules = {}

function Hekili.NewModule( name, class, spec, st, ae, cd )

	Hekili.Modules[name]				= {}
	Hekili.Modules[name]['name']		= name
	Hekili.Modules[name]['class']		= class
	Hekili.Modules[name]['spec']		= spec
	Hekili:Print("Added module |cFFFF9900" .. name .. "|r to Hekili.")

	Hekili.Modules[name].state			= {}
	Hekili.Modules[name].state['ST']	= {}
	Hekili.Modules[name].state['AE']	= {}
	Hekili.Modules[name].state['CD'] 	= {}

	Hekili.Modules[name].enabled		= {}
	Hekili.Modules[name].enabled['ST']	= st
	Hekili.Modules[name].enabled['AE']	= ae
	Hekili.Modules[name].enabled['CD']	= cd

	Hekili.Modules[name].Execute		= {}

	Hekili.Modules[name].trackHits		= {}
	Hekili.Modules[name].trackDebuffs	= {}
	
	return Hekili.Modules[name]

end


-- Add a blank module.
Hekili.NewModule( "(none)", nil, nil, false, false, false )


function Hekili.ttCooldown( sID )
	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE" ) 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetSpellByID( sID )

	local time, sTime, unit, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextRight"..i]:GetText()

		if line then
			sTime = string.match(line, "^(.+) min cooldown")

			if sTime then
				time = tonumber(sTime)
				time = time * 60
				return time
			end
			
			sTime = string.match(line, "^(.+) sec cooldown")

			if sTime then return tonumber(sTime) end
		end
	end
	return nil
end


-- Check for weapon buffs (WF/FT).
function Hekili.ttWeaponEnchant( slot )
	Hekili.Tooltip:SetOwner(UIParent,"ANCHOR_NONE") 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetInventoryItem("player", slot)

	local name, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextLeft"..i]:GetText()

		if line then
			name = string.match(line, "^(.-) %(.+%) %(.+%)$")

			if not name then
				name = string.match(line, "^(.-) %(%d+% .-%)$")
			end

			if name then
				return name
			end
		end
	end
	return "Unknown Enchant"
end


-- Check for weapon speed.
function Hekili.ttWeaponSpeed( slot )
	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE" ) 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetInventoryItem("player", slot)

	local swing, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextRight"..i]:GetText()

		if line then
			swing = string.match(line, "Speed (.+)$")

			if sTime then return tonumber(swing) end
		end
	end
	return nil
end


function round( val, decimal )
	if ( decimal ) then
		return math.floor( ( val * 10^decimal ) + 0.5 ) / ( 10^decimal )
	else
		return math.floor( val+0.5 )
	end
end