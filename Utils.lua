-- Utils.lua
-- Hekili of <Turbo Cyborg Ninjas> - Ner'zhul (A)


-- Tooltip Parser Functions
Hekili.Tooltip = CreateFrame("GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate")

function ttCooldown( sID )
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
	return "Unknown Enchant"
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
			name = string.match(line, "Use: Increases your Intellect, Agility, or Strength")

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