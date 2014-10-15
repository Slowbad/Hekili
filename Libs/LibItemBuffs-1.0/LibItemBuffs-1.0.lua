--[[
LibItemBuffs-1.0 - buff-to-item database.
(c) 2013 Adirelle (adirelle@gmail.com)

This file is part of LibItemBuffs-1.0.

LibItemBuffs-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibItemBuffs-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibItemBuffs-1.0.  If not, see <http://www.gnu.org/licenses/>.
--]]

local MAJOR, MINOR = "LibItemBuffs-1.0", 5
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.__itemBuffs = lib.__itemBuffs or {}
lib.__databaseVersion = lib.__databaseVersion or 0

lib.trinkets = lib.trinkets or {}
lib.consumables = lib.consumables or {}

lib.enchantments = {

	-- MoP enchantments

	-- Weapon (we assign it to the main hand weapon though it could come from the off-hand)
	[109085] = INVSLOT_MAINHAND, -- Engineering: Lord Blastington's Scope of Doom
	[118334] = INVSLOT_MAINHAND, -- Enchanting: Dancing Steel (agility)
	[118335] = INVSLOT_MAINHAND, -- Enchanting: Dancing Steel (strength)
	[104993] = INVSLOT_MAINHAND, -- Enchanting: Jade Spirit
	[116660] = INVSLOT_MAINHAND, -- Enchanting: River's Song -- NEED CONFIRMATION
	[116631] = INVSLOT_MAINHAND, -- Enchanting: Colossus
	[104423] = INVSLOT_MAINHAND, -- Enchanting: Windsong (haste)
	[104510] = INVSLOT_MAINHAND, -- Enchanting: Windsong (mastery)
	[104509] = INVSLOT_MAINHAND, -- Enchanting: Windsong (critical strike)

	-- Glove
	[108788] = INVSLOT_HAND, -- Engineering: Phase Fingers -- NEED CONFIRMATION
	[ 96228] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (agility)
	[ 96229] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (strength)
	[ 96230] = INVSLOT_HAND, -- Engineering: Synapse Springs, Mark II (intellect)

	-- Belt
	[131459] = INVSLOT_WAIST, -- Engineering: Watergliding Jets

	-- Cloak
	[126389] = INVSLOT_BACK, -- Engineering: Goblin Glider -- NEED CONFIRMATION
	[125488] = INVSLOT_BACK, -- Tailoring: Darkglow Embroidery, rank 3 -- NEED CONFIRMATION
	[125487] = INVSLOT_BACK, -- Tailoring: Lightweave Embroidery, rank 3
	[125489] = INVSLOT_BACK, -- Tailoring: Swordguard  Embroidery, rank 3 -- NEED CONFIRMATION

	-- Legendary meta gems
	[137593] = INVSLOT_HEAD, -- Indomitable Primal Diamond
	[137288] = INVSLOT_HEAD, -- Courageous Primal Diamond
	[137596] = INVSLOT_HEAD, -- Capacitive Primal Diamond
	[137590] = INVSLOT_HEAD, -- Sinister Primal Diamond

}

-- Known slots
lib.slots = {
	INVSLOT_MAINHAND,
	INVSLOT_HAND,
	INVSLOT_WAIST,
	INVSLOT_BACK,
	INVSLOT_HEAD,
	INVSLOT_TRINKET1,
	INVSLOT_TRINKET2,
}

--- Tell whether a spell is an item buff or not.
-- @name LibItemBuffs:IsItemBuff
-- @param spellID number Spell identifier.
-- @return boolean True if the spell is a buff given by an item.
function lib:IsItemBuff(spellID)
	return spellID and (lib.enchantments[spellID] or lib.trinkets[spellID] or lib.consumables[spellID]) and true
end

--- Return the inventory slot containing the item that can apply the given buff.
-- @name LibItemBuffs:GetBuffInventorySlot
-- @param spellID number Spell identifier.
-- @return number The inventory slot of matching item (see INVSLOT_* values), returns nil for items in bags.
function lib:GetBuffInventorySlot(spellID)
	if not spellID then return end

	local invSlot = lib.enchantments[spellID]
	if invSlot then
		return invSlot
	end

	local itemID = lib.trinkets[spellID]
	if not itemID then return end
	if GetInventoryItemID("player", INVSLOT_TRINKET2) == itemID then
		return INVSLOT_TRINKET1
	elseif GetInventoryItemID("player", INVSLOT_TRINKET2) == itemID then
		return INVSLOT_TRINKET2
	end
end

--- Return the identifier of the item that can apply the given buff.
-- @name LibItemBuffs:GetBuffItemID
-- @param spellID number Spell identifier.
-- @return number The item identifier or nil.
function lib:GetBuffItemID(spellID)
	if not spellID then return end

	local itemID = lib.trinkets[spellID] or lib.consumables[spellID]
	if itemID then
		return itemID
	end

	local invSlot = lib.enchantments[spellID]
	return invSlot and GetInventoryItemID("player", invSlot)
end

--- Get the list of inventory slots for which the library has information.
-- @name LibItemBuffs:GetInventorySlotList
-- @return table A list of INVSLOT_* values.
function lib:GetInventorySlotList()
	return lib.slots
end


--- Return the buffs provided by then given item, excluding any enchant.
-- @name LibItemBuffs:GetItemBuffs
-- @param itemID number Item identifier.
-- @return number, ... A list of spell identifiers.
function lib:GetItemBuffs(itemID)
	if not itemID then return end
	local buffs = lib.__itemBuffs[itemID]
	if type(buffs) == "table" then
		return unpack(buffs)
	elseif type(buffs) == "number" then
		return buffs
	end
end

-- Add the content of the given table into the reverse table.
-- Create a table when an item can provide several buffs.
local function FeedReverseTable(reverse, data)
	for spellID, itemID in pairs(data) do
		local previous = reverse[itemID]
		if not previous then
			reverse[itemID] = spellID
		elseif type(previous) == "table" then
			tinsert(previous, spellID)
		else
			reverse[itemID] = { previous, spellID }
		end
	end
end

-- Upgrade the trinket and consumables database if needed
function lib:__UpgradeDatabase(version, trinkets, consumables)
	if version < lib.__databaseVersion then return end

	-- Upgrade the tables
	lib.__databaseVersion, lib.trinkets, lib.consumables  = version, trinkets, consumables

	-- Rebuild the reverse database
	wipe(lib.__itemBuffs)
	FeedReverseTable(lib.__itemBuffs, trinkets)
	FeedReverseTable(lib.__itemBuffs, consumables)
end
