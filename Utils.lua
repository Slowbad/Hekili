-- Utils.lua
-- Hekili of <Turbo Cyborg Ninjas> - Ner'zhul (A)

local L = LibStub("AceLocale-3.0"):GetLocale("Hekili")

-- Tooltip Parser Functions
Hekili.Tooltip = CreateFrame("GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate")

function toLocalNumber( numString )
	if numString then
		local localNumString = numString:gsub(",", ".")
		local localNumber = tonumber(localNumString)
		return localNumber
	end
	
	return nil
end


function ttCooldown( sID )
	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE" ) 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetSpellByID( sID )

	local time, timestr, unit, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextRight"..i]:GetText()

		if line then
			timestr = string.match(line, L["Cooldown Parser (Minutes)"])

			if timestr then
				time = toLocalNumber(timestr)
				time = time * 60
				return time
			end
			
			timestr = string.match(line, L["Cooldown Parser (Seconds)"])
			
			if timestr then return toLocalNumber(timestr) end
		end
	end
	return 0
end


-- Check for weapon buffs (WF/FT).
function ttWeaponEnchant( slot )
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
	return L["Unknown Enchant"]
end


-- Check for glove tinker.
function ttGloveTinker( slot )
	Hekili.Tooltip:SetOwner(UIParent,"ANCHOR_NONE") 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetInventoryItem("player", slot)

	local name, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextLeft"..i]:GetText()

		if line then
			name = string.match(line, L["Synapse Springs Tooltip"])

			if name then
				return true
			end
		end
	end
	return false
end

-- Check for weapon speed (PPM predictions?).
function ttWeaponSpeed( slot )
	Hekili.Tooltip:SetOwner( UIParent, "ANCHOR_NONE" ) 
	Hekili.Tooltip:ClearLines()
	Hekili.Tooltip:SetInventoryItem("player", slot)

	local swing, lines
	lines = Hekili.Tooltip:NumLines()

	for i = 2, lines do
		line = _G["HekiliTooltipTextRight"..i]:GetText()

		if line then
			swing = string.match(line, L["Speed"] .. " (.+)$")

			if sTime then return toLocalNumber(swing) end
		end
	end
	return nil
end

-- Math!
function round( val, decimal )
	if ( decimal ) then
		return math.floor( ( val * 10^decimal ) + 0.5 ) / ( 10^decimal )
	else
		return math.floor( val+0.5 )
	end
end