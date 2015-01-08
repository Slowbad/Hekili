-- Hekili.lua
-- April 2014

local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )

local format = string.format


ns.lib = {
  AceConfig = LibStub( "AceConfig-3.0" ),
  AceConfigDialog = LibStub( "AceConfigDialog-3.0" ),
  Format = {}, -- filled by Formatting.lua
  LibDualSpec = LibStub( "LibDualSpec-1.0" ),
  Masque = LibStub( "Masque", true ),
  RangeCheck = LibStub( "LibRangeCheck-2.0" ),
  SpellFlash = SpellFlash or SpellFlashCore,
  SpellRange = LibStub( "SpellRange-1.0" ),
  SharedMedia = LibStub( "LibSharedMedia-3.0", true )
}

  
ns.class = {
  file = "NONE",
  
  abilities = {},
  auras = {},
  defaults = {},
  gearsets = {},
  glyphs = {},
  hooks = {},
  perks = {},
  resources = {},
  searchAbilities = {},
  stances = {},
  talents = {},
}
ns.keys = {}
ns.queue = {}
ns.scripts = {
  D = {},
  P = {},
  A = {}
}
ns.state = {}
ns.TTD = {}
ns.UI = {
  Buttons = {}
}
ns.visible = {
  display = {},
  hook = {},
  list = {},
  action = {}
}


-- Default Keybinding UI
BINDING_HEADER_HEKILI_HEADER = "Hekili v2"
BINDING_NAME_HEKILI_TOGGLE_PAUSE = "Pause"
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Cooldowns"
BINDING_NAME_HEKILI_TOGGLE_HARDCASTS = "Toggle Hardcasts"
BINDING_NAME_HEKILI_TOGGLE_INTERRUPTS = "Toggle Interrupts"
BINDING_NAME_HEKILI_TOGGLE_MODE = "Toggle Mode"
BINDING_NAME_HEKILI_TOGGLE_1 = "Custom Toggle 1"
BINDING_NAME_HEKILI_TOGGLE_2 = "Custom Toggle 2"
BINDING_NAME_HEKILI_TOGGLE_3 = "Custom Toggle 3"
BINDING_NAME_HEKILI_TOGGLE_4 = "Custom Toggle 4"
BINDING_NAME_HEKILI_TOGGLE_5 = "Custom Toggle 5"


ns.refreshBindings = function ()

  local profile = Hekili.DB.profile
  
	profile[ 'HEKILI_TOGGLE_MODE' ] = GetBindingKey( "HEKILI_TOGGLE_MODE" )
	profile[ 'HEKILI_TOGGLE_PAUSE' ] = GetBindingKey( "HEKILI_TOGGLE_PAUSE" )
	profile[ 'HEKILI_TOGGLE_COOLDOWNS' ] = GetBindingKey( "HEKILI_TOGGLE_COOLDOWNS" )
	profile[ 'HEKILI_TOGGLE_HARDCASTS' ] = GetBindingKey( "HEKILI_TOGGLE_HARDCASTS" )
	profile[ 'HEKILI_TOGGLE_1' ] = GetBindingKey( "HEKILI_TOGGLE_1" )
	profile[ 'HEKILI_TOGGLE_2' ] = GetBindingKey( "HEKILI_TOGGLE_2" )
	profile[ 'HEKILI_TOGGLE_3' ] = GetBindingKey( "HEKILI_TOGGLE_3" )
	profile[ 'HEKILI_TOGGLE_4' ] = GetBindingKey( "HEKILI_TOGGLE_4" )
	profile[ 'HEKILI_TOGGLE_5' ] = GetBindingKey( "HEKILI_TOGGLE_5" )

end


function Hekili:Query( ... )

  local output = ns

  for i = 1, select( '#', ... ) do
    output = output[ select( i, ... ) ]
  end
  
  return output
end


function Hekili:Run( ... )

  local n = select( "#", ... )
  local fn = select( n, ... )
  
  local func = ns
  
  for i = 1, fn - 1 do
    func = func[ select( i, ... ) ]
  end
  
  return func( select( fn, ... ) )

end


ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )

-- Grab the default backdrop and copy it with a solid background.
local Backdrop = GameTooltip:GetBackdrop()
Backdrop.bgFile = [[Interface\Buttons\WHITE8X8]]
ns.Tooltip:SetBackdrop( Backdrop )