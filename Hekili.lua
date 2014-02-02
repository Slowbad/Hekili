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
	Hekili.trGroup = Hekili.LBF:Group("Hekili", "Trackers")
end

Hekili.LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Hekili")

BINDING_HEADER_HEKILI_HEADER = "Hekili"

BINDING_NAME_HEKILI_TOGGLE				= L["Toggle Addon"]
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS	= L["Toggle Cooldowns"]
BINDING_NAME_HEKILI_TOGGLE_HARDCASTS	= L["Toggle Hardcasts"]
BINDING_NAME_HEKILI_TOGGLE_SINGLE		= L["Toggle Single Target Display"]
BINDING_NAME_HEKILI_TOGGLE_MULTI		= L["Toggle Multi-Target Display"]
BINDING_NAME_HEKILI_TOGGLE_INTEGRATE	= L["Toggle Multi Integration"]

Hekili.Modules = {}

Hekili.State = {}

Hekili.Actions = {}
Hekili.Actions['ST'] = {}
Hekili.Actions['AE'] = {}

for i = 1, 5 do
	Hekili.Actions['ST'][i] = {}
	Hekili.Actions['AE'][i] = {}
end


totems = {
	fire	= 1,
	earth	= 2,
	water	= 3,
	air		= 4
}

