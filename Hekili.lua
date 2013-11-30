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

BINDING_HEADER_HEKILI_HEADER = "Hekili Priority Helper"
BINDING_NAME_HEKILI_TOGGLE = "Enable/Disable Hekili"
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Display of Cooldowns"
BINDING_NAME_HEKILI_TOGGLE_HARDCASTS = "Toggle Display of Hardcasts"

Hekili.Modules = {}

Hekili.State = {}
Hekili.State.ST = {}
Hekili.State.AE = {}