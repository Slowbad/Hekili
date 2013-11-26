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
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Display of Cooldowns"
BINDING_NAME_HEKILI_TOGGLE_HARDCASTS = "Toggle Display of Hardcasts"

Hekili.Modules = {}

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
	return nil
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


-- Check for weapon speed.
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


function Hekili:IsFiltered( ability )
	local mod = self.ActiveModule
	local spell

	if not mod or not mod.spells or not mod.spells[ability] then
		return false
	else
		spell = mod.spells[ability]
	end
	
	if spell.talent and not self.DB.char[ 'Show Talents' ] then
		return true
	elseif spell.racial and not self.DB.char[ 'Show Racials' ] then
		return true
	elseif spell.interrupt and not self.DB.char[ 'Show Interrupts' ] then
		return true
	elseif spell.precombat and not self.DB.char[ 'Show Precombat' ] then
		return true
	elseif spell.profession and not self.DB.char[ 'Show Professions' ] then
		return true
	elseif spell.bloodlust and not self.DB.char[ 'Show Bloodlust' ] then
		return true
	elseif spell.consumable and not self.DB.char[ 'Show Consumables' ] then
		return true
	elseif spell.name then
		return true
	elseif spell.cooldown then
		if spell.cdUpdated < self.eqChanged and not spell.item then
			spell.cooldown	= ttCooldown(spell.id)
			spell.cdUpdated	= GetTime()
		end
		
		if spell.cooldown > self.DB.char['Cooldown Threshold'] then
			return true
		end
	end
	
	return false
end


function round( val, decimal )
	if ( decimal ) then
		return math.floor( ( val * 10^decimal ) + 0.5 ) / ( 10^decimal )
	else
		return math.floor( val+0.5 )
	end
end


function Hekili:NewModule( name, class, spec, st, ae, cd )
	local mod		= {}

	mod['name']		= name
	mod['class']	= class
	mod['spec']		= spec

	mod.state		= {}
	mod.state.ST	= {}
	mod.state.AE	= {}
	mod.state.CD	= {}
	
	mod.enabled		= {}
	mod.enabled.ST	= st
	mod.enabled.AE	= ae
	mod.enabled.CD	= cd
	

	-- Spells table (with flags for spell level filtering/etc.)
	mod.spells		= {}
	function mod:AddAbility( name, ID, ... )
		if self.spells[name] then
			Hekili:Print("Attempted to add existing ability '" .. name .. "' to spells table.")
			return
		end

		local spell			= {}
		spell.id			= ID

		-- Assorted flags.
		local flags = { ... }
		for k,v in pairs(flags) do
			spell[v] = true
		end
		
		if not spell.item then
			spell.cooldown	= ttCooldown(ID)
			spell.cdUpdated	= GetTime()
		end
		
		self.spells[name]	= spell
	end
		
	function mod:AddHandler( name, func )
		if not self.spells[name] then
			Hekili:Print("Attempted to add a handler for spell '" .. name .. ". that is not in spells table.")
			return
		end
		
		self.spells[name].handler		= func
	end


	-- Action table (for comparing ability criteria/etc.)
	mod.actionList		= {}
	function mod:AddToActionList( category, ability, caption, simC, check )
		if not self.spells[ability] then
			Hekili:Print("Attempted to add a non-existant ability to the action list.")
			return
		end
		
		self.actionList[ #self.actionList+1 ] = {
			['type']		= category,
			['ability']		= ability,
			['caption']		= caption,
			['simC']		= simC,
			['check']		= check
		}
	end
	
	mod.trackHits		= {}
	mod.trackDebuffs	= {}
	
	self.Modules[name] = mod
	self:Print("Added module |cFFFF9900" .. name .. "|r to Hekili.")

	return self.Modules[name]
end


-- Add a blank module.
Hekili:NewModule( "(none)", nil, nil, false, false, false )
