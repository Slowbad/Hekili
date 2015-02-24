-- Options.lua
-- Everything related to building/configuring options.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class

local format = string.format
local match = string.match

local callHook = ns.callHook
local restoreDefaults = ns.restoreDefaults
local tableCopy = ns.tableCopy

-- Default Table
function Hekili:GetDefaults()
	local defaults = {
		profile = {
			Version = 2,
			Release = 20150223.1,
			Enabled = true,
			Locked = false,
			Debug = false,
	
      ['Switch Type'] = 0,
      ['Mode Status'] = 3,
      Interrupts = true,
			Hardcasts = true,
			
			['Audit Targets'] = 5,
			['Updates Per Second'] = 10,
      
      ['Notification Enabled'] = true,
      ['Notification Font'] = 'Arial Narrow',
      ['Notification X'] = 0,
      ['Notification Y'] = 0,
      ['Notification Width'] = 175,
      ['Notification Height'] = 25,

			displays = {
			},
			actionLists = {
			}
		}
	}
	
	return defaults
end	


-- DISPLAYS
-- Add a display to the profile (to be stored in SavedVariables).
ns.newDisplay = function( name )

	if not name then
		return nil
	end
	
	for i,v in ipairs( Hekili.DB.profile.displays ) do
		if v.Name == name then
      Hekili:Error( "newDisplay() - display '" .. name .. "' already exists." )
			return nil
		end
	end

	local index = #Hekili.DB.profile.displays + 1
	
  -- FIX: REPLACE HEARTBEAT
	if not Hekili[ 'ProcessDisplay'..index ] then
		Hekili[ 'ProcessDisplay'..index ] = function()
			Hekili:ProcessHooks( index )
		end
	end
	
	Hekili.DB.profile.displays[ index ] = {
		Name = name,
		Release = Hekili.DB.profile.Version + ( Hekili.DB.profile.Release / 100 ),

		Enabled = true,

    ['PvE - Default'] = true,
    ['PvE - Default Alpha'] = 1,
    ['PvE - Target'] = false,
    ['PvE - Target Alpha'] = 1,
    ['PvE - Combat'] = false,
    ['PvE - Combat Alpha'] = 1,

    ['PvP - Default'] = true,
    ['PvP - Default Alpha'] = 1,
    ['PvP - Target'] = false,
    ['PvP - Target Alpha'] = 1,
    ['PvP - Combat'] = false,
    ['PvP - Combat Alpha'] = 1,

		Script = '',
		
    ['Force Targets'] = 1,
    ['Use SpellFlash'] = false,
    ['SpellFlash Color'] = { r = 1, g = 1, b = 1, a = 1 },
    
		-- Talent Group: Primary, Secondary, Both
		['Talent Group'] = 0,
		['Specialization'] = ns.getSpecializationID(),
		['Icons Shown'] = 5,
		['Maximum Time'] = 30,
		['Queue Direction'] = 'RIGHT',
		
		-- Captions
		['Action Captions'] = true,
		-- Primary Caption: Default, # Targets, Buff ________ Stacks, Debuff ________ Count, Debuff ________ Count / # Targets
		['Primary Caption'] = 'default',
		['Primary Caption Aura'] = '',
		
		-- Visual Elements
		Font = 'Arial Narrow',
		['Primary Icon Size'] = 50,
		['Primary Font Size'] = 12,
		['Queued Icon Size'] = 40,
		['Queued Font Size'] = 12,
		Spacing = 5,
		
		Queues = {}
	}

	return ( 'D' .. index ), index
	
end


-- Add a display to the options UI.
ns.newDisplayOption = function( key )

	if not key or not Hekili.DB.profile.displays[ key ] then
		return nil
	end

	local dispOption = {
		type = "group",
		name = function(info, val)
      if Hekili.DB.profile.displays[key].Default then
        return "|cFF00C0FF" .. Hekili.DB.profile.displays[key].Name .. "|r"
      end
      return Hekili.DB.profile.displays[key].Name
    end,
		order = key,
		args = {
			Enabled = {
				type = 'toggle',
				name = 'Enabled',
				desc = 'Enable this display (hides the display and ignores its hooked action list(s) if unchecked).',
				order = 1,
        width = 'double'
			},
      Default = {
        type = 'toggle',
        name = 'Default',
        desc = 'This display is a default, and is updated automatically updated when the addon is updated.  Unchecking this setting will prevent the addon from automatically updating this display.  This cannot be undone without reloading the display.',
        order = 3,
        hidden = function(info, val)
          return not Hekili.DB.profile.displays[key].Default
        end,
        width = 'single',
      },
      UndefBlank = {
				type = "description",
				name = " ",
				width = "single",
				order = 3,
        hidden = function(info, val)
          return Hekili.DB.profile.displays[key].Default
        end
			},
			['Name'] = {
				type = 'input',
				name = 'Name',
				desc = 'Rename this display.',
				order = 20,
				validate = function(info, val)
					local key = tonumber( info[2]:match("^D(%d+)") )
					for i, display in pairs( Hekili.DB.profile.displays ) do
						if i ~= key and display.Name == val then
							return "That display name is already in use."
						end
					end
          return true
				end,
				width = 'double',
			},
      ['Force Targets'] = {
        type = 'range',
        name = "Force Minimum Targets",
        desc = "If set above 1, the addon will assume there are at least this many targets when deciding which abilities to recommend (useful for AOE displays and action lists).",
        order = 21,
        min = 1,
        max = 5,
        step = 1
      },
			['Talent Group'] = {
				type = 'select',
				name = 'Talent Group',
				desc = 'Choose the talent group(s) for this display.',
				order = 30,
				values = {
					[0] = 'Both',
					[1] = 'Primary',
					[2] = 'Secondary'
				},
				width = "single"
			},		
			--[[ ['PvE Visibility'] = {
				type = 'select',
				name = 'PvE Visibility',
				desc = 'Set the visibility for this display in PvE zones.',
				order = 40,
				values = {
					always = 'Show Always',
					combat = 'Show in Combat',
					target = 'Show with Target',
					zzz = 'Never'
				},
			}, ]]
			['Specialization'] = {
				type = 'select',
				name = 'Specialization',
				desc = 'Choose the talent specialization(s) for this display.',
				order = 40,
				values = function(info)
					local class = select(2, UnitClass("player"))
					if not class then return nil end
					
					local num = GetNumSpecializations()
					local list = {}
					
					for i = 1, num do
						local specID, name = GetSpecializationInfoForClassID( ns.getClassID(class), i )
						list[specID] = '|T' .. select( 4, GetSpecializationInfoByID( specID ) ) .. ':0|t ' .. name
					end
					
					list[ 0 ] = '|TInterface\\Addons\\Hekili\\Textures\\' .. class .. '.blp:0|t Any'
					return list
				end,
				width = 'double',
			},
			--[[ ['PvP Visibility'] = {
				type = 'select',
				name = 'PvP Visibility',
				desc = 'Set the visibility for this display in PvP zones.',
				order = 51,
				values = {
					always = 'Show Always',
					combat = 'Show in Combat',
					target = 'Show with Target',
					zzz = 'Never'
				},
			}, ]]
      ['SpellFlash Group'] = {
        type = 'group',
        inline = true,
        name = "SpellFlash",
        order = 50,
        hidden = function(info, val)
          return ns.lib.SpellFlash == nil
        end,
        args = {
          ['Use SpellFlash'] = {
            type = 'toggle',
            name = 'Use SpellFlash',
            desc = "If enabled and SpellFlash (or SpellFlashCore) is installed, the addon will cause the action buttons for recommended abilities to flash.",
            order = 3,
            width = 'double'
          },
          ['SpellFlash Color'] = {
            type = 'color',
            name = 'SpellFlash Color',
            desc = "If SpellFlash is installed, actions recommended from this display will flash with the selected color.",
            order = 4,
            width = 'single'
          }
        }
      },
      PvE = {
        type = 'group',
        inline = true,
        name = "PvE Visibility",
        order = 60,
        args = {
          ["PvE - Default"] = {
            type = 'toggle',
            name = 'Show Always',
            desc = 'Show this display at all times, regardless of combat state and whether you have a target.',
            order = 1
          },
          ['PvE - Default Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show Always', set the alpha transparency to this value.",
            order = 2,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double",
          },
          ['PvE - Target'] = {
            type = 'toggle',
            name = 'Show with Target',
            desc = 'Show this display whenever you have a hostile enemy targeted, regardless of whether you are in combat.',
            order = 3,
          },
          ['PvE - Target Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show with Target', set the alpha transparency to this value.",
            order = 4,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double"
          },
          ['PvE - Combat'] = {
            type = 'toggle',
            name = 'Show in Combat',
            desc = "Show this display whenever you are in combat.",
            order = 5
          },
          ['PvE - Combat Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When the display is shown because you are in combat, set the transparency to this value.",
            order = 6,
            min = 0,
            max = 1,
            step = 0.01,
            width = 'double'
           
          }
        }
      },
      PvP = {
        type = 'group',
        inline = true,
        name = "PvP Visibility",
        order = 65,
        args = {
          ["PvP - Default"] = {
            type = 'toggle',
            name = 'Show Always',
            desc = 'Show this display at all times, regardless of combat state and whether you have a target.',
            order = 1
          },
          ['PvP - Default Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show Always', set the alpha transparency to this value.",
            order = 2,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double",
          },
          ['PvP - Target'] = {
            type = 'toggle',
            name = 'Show with Target',
            desc = 'Show this display whenever you have a hostile enemy targeted, regardless of whether you are in combat.',
            order = 3,
          },
          ['PvP - Target Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show with Target', set the alpha transparency to this value.",
            order = 4,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double"
          },
          ['PvP - Combat'] = {
            type = 'toggle',
            name = 'Show in Combat',
            desc = "Show this display whenever you are in combat.",
            order = 5
          },
          ['PvP - Combat Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When the display is shown because you are in combat, set the transparency to this value.",
            order = 6,
            min = 0,
            max = 1,
            step = 0.01,
            width = 'double'
           
          }
        }
      },
			Script = {
				type = 'input',
				name = 'Conditions',
				desc = 'Enter the conditions (Lua or SimC-like syntax) for this display to be visible.',
				dialogControl = "HekiliCustomEditor",
				arg = function(info)
					local dispKey = info[2]
					local dispIdx = tonumber( dispKey:match("^D(%d+)" ) )
					local results = {}
					
					ns.state.reset()
					ns.state.this_action = 'wait'
					ns.storeValues( results, ns.scripts.D[ dispIdx ] )
					return results
				end,
				multiline = 6,
				order = 70,
				usage = 'See http://www.curse.com/addons/wow/hekili for a reference list of game state options.',
				width = 'full'
			},
			BLANK = {
				type = "description",
				name = " ",
				width = "full",
				order = 80
			},
			['Add Hook'] = {
				type = "execute",
				name = "Add Hook",
				desc = "Adds a new hook for an action list.  You can specific which action list to use, and under which conditions to use the list.",
				order = 90,
				func = function (info)
					local dispKey, display = info[2], tonumber( info[2]:match("^D(%d+)") )
				
					local clear, suffix, name, result = 0, 1, "New Hook", "New Hook"
					while clear < #Hekili.DB.profile.displays[ display ].Queues do
						for i, queue in ipairs( Hekili.DB.profile.displays[ display ].Queues ) do
							if queue.Name == result then
								result = name .. ' (' .. suffix .. ')'
								suffix = suffix + 1
							else
								clear = clear + 1
							end
						end
					end
			
					local key, index = ns.newHook( display, result )
					if key then
						Hekili.Options.args.displays.args[ dispKey ].args[ key ] = ns.newHookOption( display, index )
						ns.refreshOptions()
					end
					ns.cacheCriteria()
					ns.loadScripts()
				end
			},
			Reload = {
				type = "execute",
				name = "Reload Display",
				desc = function( info, ... ) 
					local dispKey, dispID = info[2], tonumber( string.match( info[2], "^D(%d+)" ) )
					local display = Hekili.DB.profile.displays[ dispID ]
					
					local _, defaultID = ns.isDefault( display.Name, 'displays' )

					local output = "Reloads this display from the default options available. Style settings are left untouched, but hooks and criteria are reset."
					
					if class.defaults[ defaultID ].version > ( display.Release or 0 ) then
						output = output .. "\n|cFF00FF00The default display is newer (" .. class.defaults[ defaultID ].version .. ") than your existing display (" .. ( display.Release or "2.00" ) .. ").|r"
					end
					
					return output
				end,
				confirm = true,
				confirmText = "Reload the default settings for this default display?",
				order = 91,
				hidden = function( info, ... )
					local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
					local display = Hekili.DB.profile.displays[ dispID ]
					
					if ns.isDefault( display.Name, 'displays' ) then
						return false
					end
					
					return true
				end,
				func = function( info, ... )
					local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
					local display = Hekili.DB.profile.displays[ dispID ]
					
					local _, defaultID = ns.isDefault( display.Name, 'displays' )
					
					local import = ns.deserializeDisplay( class.defaults[ defaultID ].import )
		
					if not import then
						Hekili:Print("Unable to import " .. class.defaults[ defaultID ].name .. ".")
						return
					end
		
					local settings_to_keep = { "Primary Icon Size", "Queued Font Size", "Primary Font Size", "Primary Caption Aura", "rel", "Spacing", "Queue Direction", "Queued Icon Size", "Font", "x", "y", "Icons Shown", "Action Captions", "Primary Caption", "Primary Caption Aura" }
					
					for _, k in pairs( settings_to_keep ) do
						import[ k ] = display[ k ]
					end
					
					Hekili.DB.profile.displays[ dispID ] = import
          Hekili.DB.profile.displays[ dispID ].Name = class.defaults[ defaultID ].name
					Hekili.DB.profile.displays[ dispID ].Release = class.defaults[ defaultID ].version
          Hekili.DB.profile.displays[ dispID ].Default = true
					ns.refreshOptions()
					ns.loadScripts()
					ns.buildUI()
				end,
			},
			BLANK2 = {
				type = "description",
				name = " ",
				order = 92,
				hidden = function( info, ... )
					local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
					local display = Hekili.DB.profile.displays[ dispID ]
					
					if ns.isDefault( display.Name, 'displays' ) then
						return true
					end
					
					return false
				end,
				width = "single",
			},
			Delete = {
				type = "execute",
				name = "Delete Display",
				desc = "Deletes this display and all associated action list hooks and criteria.  The action lists will remain untouched.",
				confirm = true,
				confirmText = "Permanently delete this display and all associated action list hooks?",
				order = 93,
				func		=	function(info, ...)
					if not info[2] then return end
					
					-- Key to Current Display (string)
					local dispKey = info[2]
					local dispIdx = tonumber( match( info[2], "^D(%d+)" ) )

					for i, queue in ipairs( Hekili.DB.profile.displays[dispIdx].Queues ) do
						for k,v in pairs( queue ) do
							queue[k] = nil
						end
						table.remove( Hekili.DB.profile.displays[dispIdx].Queues, i)
					end
					
					-- Will need to be more elaborate later.
					table.remove( Hekili.DB.profile.displays, dispIdx )
					table.remove( ns.queue, dispIdx )
					ns.refreshOptions()
					ns.loadScripts()
					ns.buildUI()
					ns.lib.AceConfigDialog:SelectGroup( "Hekili", 'displays' )
				end
			},
			['UI and Style'] = {
				type = 'group',
				name = 'UI and Style',
				order = 9,
				args = {
					x = {
						type = 'input',
						name = "Position (X)",
						desc = "Enter the horizontal position of this display's primary icon relative to the center of your screen.  Negative numbers move the icon left, positive numbers move the icon right.",
						order = 2,
					},
					y = {
						type = 'input',
						name = "Position (Y)",
						desc = "Enter the vertical position of this display's primary icon relative to the center of your screen.  Negative numbers move the icon up, positive numbers move the icon down.",
						order = 3,
					},
					iconHeader = {
						type = 'header',
						name = 'Icons and Layout',
						order = 8,
					},
					['Icons Shown'] = {
						type = 'range',
						name = 'Icons Shown',
						desc = "Select the number of icons to display.  This also determines the number of actions the addon will try to predict.",
						min = 1,
						max = 10,
						order = 10,
						step = 1,
					},
					Spacing = {
						type = 'range',
						name = 'Icon Spacing',
						desc = "Select the number of pixels to skip between icons in this display.",
						min = -10,
						max = 50,
						order = 11,
						step = 1,
					},
					['Queue Direction'] = {
						type = 'select',
						name = 'Queue Direction',
						order = 12,
						values = {
							TOP = 'Up',
							BOTTOM = 'Down',
							LEFT = 'Left',
							RIGHT = 'Right'
						},
					},
					['Primary Icon Size'] = {
						type = 'range',
						name = 'Primary Icon Size',
						desc = "Select the size of the primary icon.",
						min = 10,
						max = 100,
						order = 21,
						step = 1,
					},
					['Queued Icon Size'] = {
						type = 'range',
						name = 'Queued Icon Size',
						desc = "Select the size of the queued icons.",
						min = 10,
						max = 100,
						order = 22,
						step = 1,
					},
					fontHeader = {
						type = 'header',
						name = 'Style',
						order = 30,
					},
					Font = {
						type = 'select',
						name = 'Font',
						desc = "Select the font to use on all icons in this display.",
						dialogControl = 'LSM30_Font',
						order = 31,
						values = ns.lib.SharedMedia:HashTable("font"), -- pull in your font list from LSM
					},
					['Primary Font Size'] = {
						type = 'range',
						name = 'Primary Font Size',
						desc = "Enter the size of the font for primary icon captions.",
						min = 6,
						max = 30,
						order = 32,
						step = 1,
					},
					['Queued Font Size'] = {
						type = 'range',
						name = 'Queued Font Size',
						desc = "Enter the size of the font for queued icon captions.",
						min = 6,
						max = 30,
						order = 33,
						step = 1,
					},
					captionHeader = {
						type = 'header',
						name = 'Captions',
						order = 40,
					},
					-- Captions
					['Action Captions'] = {
						type = 'toggle',
						name = 'Action Captions',
						desc = "Enable or disable action captions.  This allows you to display additional information about a particular action when shown.",
						order = 51,
						width = 'full'
					},
					['Primary Caption'] = {
						type = 'select',
						name = 'Primary Caption',
						desc = "This allows you to override the caption on the primary icon under a variety of circumstances.",
						hidden = function(info)
							local display = tonumber( match( info[2], "^D(%d+)" ) )
							if not Hekili.DB.profile.displays[ display ]['Action Captions'] then
								return true
							end
							return false
						end,
						order = 52,
						values = {
							default = 'Use Default Captions',
							targets = 'Show # of Targets',
							buff = 'Buff Stacks',
							debuff = 'Debuff Count',
							ratio = 'Debuff Count / # Targets',
              sratio = 'Buff Stacks / # Targets'
						}
					},
					-- Should probably use the autocomplete aura tool.
					['Primary Caption Aura'] = {
						type = 'input',
						name = 'Aura',
						desc = "Enter the name of the aura to check for certain Primary Caption overrides.",
						hidden = function(info)
							local display = tonumber( match( info[2], "^D(%d+)" ) )
							if not Hekili.DB.profile.displays[ display ]['Action Captions'] then
								return true
							end
							return false
						end,
						order = 53,
					}
				}
			},
			['Import/Export'] = {
				type = 'group',
				name = 'Import/Export',
				order = 10,
				args = {	
					['Copy To'] = {
						type = 'input',
						name = 'Copy To',
						desc = 'Enter a name for the new display.  All settings, including action list hooks, will be duplicated in the new display.',
						order = 11,
						validate = function(info, val)
							if val == '' then return true end
              for k,v in ipairs(Hekili.DB.profile.displays) do
                if val == v.Name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
              end
							return true
						end,
						width = 'full',
					},
					['Import'] = {
						type = 'input',
						name = 'Import Display',
						desc = "Paste the export string from another display to copy its settings to this display.  All settings will be copied, except for the display name.",
						order = 11,
						width = 'full',
					},
					['Export'] = {
						type = 'input',
						name = 'Export Display',
						desc = "Copy this export string and paste it into another display's Import field to copy all settings from this display to another existing display.",
						get = function(info)
							local dispKey = info[2]
							local dispIdx = tonumber( dispKey:match("^D(%d+)") )
							
							return ns.serializeDisplay( dispIdx )
						end,
						set = function(...)
							return
						end,
						order = 12,
						width = 'full',
						multiline = 6,
						dialogControl = 'HekiliCustomEditor'
					},
				}
			},
		}
	}
	
	return dispOption
	
end


-- DISPLAYS > HOOKS
-- Add a hook to a display.
ns.newHook = function( display, name )

	if not name then
		return nil
	end
	
	if type(display) == string then
		display = tonumber( match( display, "^D(%d+)") )
	end
	
	for i,v in ipairs( Hekili.DB.profile.displays[display].Queues ) do
		if v.Name == name then
			self:Error('NewHook() - tried to use an existing display name.')
			return nil
		end
	end

	local index = #Hekili.DB.profile.displays[display].Queues + 1
	
	Hekili.DB.profile.displays[ display ].Queues[ index ] = {
		Name = name,
		Release = Hekili.DB.profile.Version + ( Hekili.DB.profile.Release / 100 ),
		Enabled = false,
		['Action List'] = 0,
		Script = '',
	}

	return ( 'P' .. index ), index
	
end


-- Add a hook to the options UI.
-- display	(number)	The index of the display to which this entry is attached.
-- key		(number)	The index for this particular hook.
ns.newHookOption = function( display, key )

	if not key or not Hekili.DB.profile.displays[display].Queues[ key ] then
		return nil
	end

	local pqOption = {
		type = "group",
		name = '|cFFFFD100' .. key .. '.|r ' .. Hekili.DB.profile.displays[ display ] .Queues[ key ].Name,
		order = 50 + key,
		-- childGroups = "tab",
		-- This number must be index + number of options in "Display Queues" section.
		-- order = index + 2,
		args = {

			Enabled = {
				type = 'toggle',
				name = 'Enabled',
				order = 00,
				width = 'double',
			},
			['Move'] = {
				type = 'select',
				name = 'Position',
				order = 01,
				values = function(info)
					local dispKey, hookKey = info[2], info[3]
					local dispIdx, hookID = tonumber( dispKey:match("^D(%d+)") ), tonumber( hookKey:match("^P(%d+)") )
					local list = {}
					for i = 1, #Hekili.DB.profile.displays[ dispIdx ].Queues do
						list[i] = i
					end
					return list
				end
			},
			['Name'] = {
				type = 'input',
				name = 'Name',
				order = 03,
				validate = function(info, val)
					local key = tonumber(info[2])
					for i, hook in pairs( Hekili.DB.profile.displays[display].Queues ) do
						if i ~= key and hook.Name == val then
							return "That hook name is already in use."
						end
					end
					return true
				end,
				width = 'double'
			},
			['Action List'] = {
				type = 'select',
				name = 'Action List',
				order = 04,
				values = function(info)
					local lists = {}
					
					lists[0] = 'None'
					for i, list in ipairs( Hekili.DB.profile.actionLists ) do
						if list.Specialization > 0 then
							lists[i] = '|T' .. select(4, GetSpecializationInfoByID( list.Specialization ) ) .. ':0|t ' .. list.Name
						else
							lists[i] = '|TInterface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp:0|t ' .. list.Name
						end
					end

					return lists
				end,
			},
			Script = {
				type = 'input',
				name = 'Conditions',
				dialogControl = "HekiliCustomEditor",
				arg = function(info)
					local dispKey, hookKey = info[2], info[3]
					local dispIdx, hookID = tonumber( dispKey:match("^D(%d+)" ) ), tonumber( hookKey:match("^P(%d+)") )
					local prio = Hekili.DB.profile.displays[ dispIdx ].Queues[ hookID ]
					local results = {}
					
					ns.state.reset()
					ns.state.this_action = 'wait'
					ns.storeValues( results, ns.scripts.P[ dispIdx..':'..hookID ] )
					return results
				end,
				multiline = 6,
				order = 12,
				width = 'full'
			},
			Delete = {
				type = "execute",
				name = "Delete Hook",
				confirm = true,
				-- confirmText = '
				order = 999,
				func		=	function(info, ...)
					-- Key to Current Display (string)
					local dispKey = info[2]
					local dispIdx = tonumber( match( dispKey, "^D(%d+)" ) )
					local queueKey = info[3]
					local queueIdx = tonumber( match( queueKey, "^P(%d+)" ) )

					-- Will need to be more elaborate later.
					table.remove( Hekili.DB.profile.displays[dispIdx].Queues, queueIdx )
					ns.refreshOptions()
					ns.loadScripts()
				end
			},
		}
	}
	
	return pqOption
	
end


-- ACTION LISTS
-- Add an action list to the profile (to be stored in SavedVariables).
ns.newActionList = function( name )

	local index = #Hekili.DB.profile.actionLists + 1
	
	if not name then
		name = "List #" .. index
	end

	Hekili.DB.profile.actionLists[index] = {
		Enabled = false,
		Name = name,
		Release = Hekili.DB.profile.Version + ( Hekili.DB.profile.Release / 100 ),
		Specialization = ns.getSpecializationID() or 0,
		Script = '',
		Actions = {}
	}
	
	return ( 'L' .. index ), index
end


-- Add an action list to the options UI.
ns.newActionListOption = function( index )

	if not index or Hekili.DB.profile.actionLists[ index ] == nil then
		return nil
	end

	local name = Hekili.DB.profile.actionLists[ index ].Name
	
	local listOption = {
		type = "group",
		name = function(info, val)
      if Hekili.DB.profile.actionLists[ index ].Default then
        return "|cFF00C0FF" .. name .. "|r"
      end
      return name
    end,
		icon = function(info)
			local list = tonumber( match( info[#info], "^L(%d+)" ) )
			if Hekili.DB.profile.actionLists[ list ].Specialization > 0 then
				return select( 4, GetSpecializationInfoByID( Hekili.DB.profile.actionLists[ list ].Specialization ) )
			else return 'Interface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp' end
		end,
		order = 10 + index,
		args = {
			Enabled = {
				type = 'toggle',
				name = 'Enabled',
				desc = "Enable or disable this action list for processing in all displays.",
				order = 1,
        width = 'double',
			},
      Default = {
        type = 'toggle',
        name = 'Default',
        desc = "This action list is a default, and will be automatically updated when the addon is updated.  To prevent this behavior, uncheck this box.  This cannot be undone without reloading the action list.",
        order = 2,
        hidden = function(info, val)
          return not Hekili.DB.profile.actionLists[ index ].Default
        end
      },
      DefBlank = {
        type = 'description',
        name = " ",
        order = 2,
        hidden = function(info, val)
          return Hekili.DB.profile.actionLists[ index ].Default
        end
      },
			Name = {
				type = "input",
				name = "Name",
				desc = "Enter a unique name for this action list.",
				validate = function(info, val)
					for i, list in pairs( Hekili.DB.profile.actionLists ) do
						if list.Name == val and index ~= i then
							return "That action list name is already in use."
						end
					end
          return true
				end,
				order = 3,
				width = "full",
			},
			Specialization = {
				type = 'select',
				name = 'Specialization',
				desc = "Select the class specialization for this action list.  If you select 'Any', the list will work in all specializations, though abilities unavailable to your specialization will not be recommended.",
				order = 4,
				values = function(info)
					local class = select(2, UnitClass("player"))
					if not class then return nil end
					
					local num = GetNumSpecializations()
					local list = {}
					
					list[0] = '|TInterface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp:0|t Any'
					for i = 1, num do
						local specID, name = GetSpecializationInfoForClassID( ns.getClassID(class), i )
						list[specID] = '|T' .. select( 4, GetSpecializationInfoByID( specID ) ) .. ':0|t ' .. name
					end
					return list
				end,
				width = 'full'
			},
			['Import/Export'] = {
				type = "group",
				name = 'Import/Export',
				order = 5,
				args = {
					['Copy To'] = {
						type = 'input',
						name = 'Copy To',
						desc = 'Enter a name for the new action list.  All settings, except for the list name, will be duplicated into the new list.',
						order = 32,
						validate = function(info, val)
							if val == '' then return true end
              for k,v in ipairs(Hekili.DB.profile.actionLists) do
                if val == v.Name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
							end
							return true
						end,
						width = 'full',
					},
					['Import Action List'] = {
						type = 'input',
						name = 'Import Action List',
						desc = "Paste the export string from another action list to copy it here.  All settings, except for the list name, will be duplicated into this list.",
						order = 33,
						width = 'full',
					},
					['Export Action List'] = {
						type = 'input',
						name = 'Export Action List',
						desc = "Copy this export string and paste it into another action list to overwrite the other action list.",
						get = function(info)
							local listKey = info[2]
							local listIdx = tonumber( listKey:match("^L(%d+)") )
							
							return ns.serializeActionList( listIdx )
						end,
						set = function(...)
							return
						end,
						order = 34,
						width = 'full',
						multiline = 6,
						dialogControl = 'HekiliCustomEditor'
					},
					['SimulationCraft'] = {
						type = 'input',
						name = 'Import SimulationCraft List',
						desc = "Copy a SimulationCraft action list and paste it here to import.  If any lines cannot be parsed, the action list will not be imported.",
						order = 35,
						multiline = 6,
						dialogControl = 'HekiliCustomEditor',
						-- validate = 'ImportSimulationCraftActionList',
						width = 'full',
						confirm = true,
					},
				}
			},
			spcHeader = {
				type = 'description',
				name = "\n",
				order = 900,
				width = 'full'
			},
			['Add Action'] = {
				type = "execute",
				name = "Add Action",
				desc = "Adds a new action entry, where you can set the ability and conditions required for that ability to be shown.",
				order = 901,
				func = function( info )
					local listKey, listIdx = info[2], tonumber( info[2]:match("^L(%d+)") )

					local clear, suffix, name, result = 0, 1, "New Action", "New Action"
					while clear < #Hekili.DB.profile.actionLists[ listIdx ].Actions do
						for i, action in ipairs( Hekili.DB.profile.actionLists[ listIdx ].Actions ) do
							if action.Name == result then
								result = name .. ' (' .. suffix .. ')'
								suffix = suffix + 1
							else
								clear = clear + 1
							end
						end
					end
					
					local key, index = ns.newAction( listIdx, result )
					if key then
						Hekili.Options.args.actionLists.args[ listKey ].args[ key ] = ns.newActionOption( listIdx, index )
						ns.cacheCriteria()
						ns.loadScripts()
					end
				end
			},
			Reload = {
				type = "execute",
				name = "Reload Action List",
				desc = function( info, ... ) 
					local listKey, listID = info[2], tonumber( string.match( info[2], "^L(%d+)" ) )
					local list = Hekili.DB.profile.actionLists[ listID ]
					
					local _, defaultID = ns.isDefault( list.Name, 'actionLists' )

					local output = "Reloads this action list from the default options available."
					
					if class.defaults[ defaultID ].version > ( list.Release or 0 ) then
						output = output .. "\n|cFF00FF00The default action list is newer (" .. class.defaults[ defaultID ].version .. ") than your existing action list (" .. ( list.Release or "2.00" ) .. ").|r"
					end
					
					return output
				end,
				confirm = true,
				confirmText = "Reload the default settings for this default action list?",
				order = 902,
				hidden = function( info, ... )
					local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
					local list = Hekili.DB.profile.actionLists[ listID ]
					
					if ns.isDefault( list.Name, 'actionLists' ) then
						return false
					end
					
					return true
				end,
				func = function( info, ... )
					local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
					local list = Hekili.DB.profile.actionLists[ listID ]
					
					local _, defaultID = ns.isDefault( list.Name, 'actionLists' )
					
					local import = ns.deserializeActionList( class.defaults[ defaultID ].import )
					
					if not import then
						Hekili:Print("Unable to import " .. class.defaults[ defaultID ].name .. ".")
						return
					end
					
					Hekili.DB.profile.actionLists[ listID ] = import
          Hekili.DB.profile.actionLists[ listID ].Name = class.defaults[ defaultID ].name
					Hekili.DB.profile.actionLists[ listID ].Release = class.defaults[ defaultID ].version
          Hekili.DB.profile.actionLists[ listID ].Default = true
					ns.refreshOptions()
					ns.loadScripts()
					-- ns.buildUI()
				end,
			},
			BLANK2 = {
				type = "description",
				name = " ",
				order = 902,
				hidden = function( info, ... )
					local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
					local list = Hekili.DB.profile.actionLists[ listID ]
					
					if ns.isDefault( list.Name, 'actionLists' ) then
						return true
					end
					
					return false
				end,
				width = "single",
			},
			Delete = {
				type = "execute",
				name = "Delete Action List",
				desc = "Delete this action list, and all actions associated with this list.",
				confirm = true,
				order = 999,
				func		=	function(info, ...)
					local actKey = info[2]
					local actIdx = tonumber( match( actKey, "^L(%d+)" ) )
					
					for d_key, display in ipairs( Hekili.DB.profile.displays ) do
						for l_key, list in ipairs ( display.Queues ) do
							if list['Action List'] == actIdx then
								list['Action List'] = 0
								list.Enabled = false
							elseif list['Action List'] > actIdx then
								list['Action List'] = list['Action List'] - 1
							end
						end
					end
					
					table.remove( Hekili.DB.profile.actionLists, actIdx )
					ns.loadScripts()
					ns.refreshOptions()
					ns.lib.AceConfigDialog:SelectGroup( "Hekili", "actionLists" )
					
				end
			}
		}
	}
	
	return listOption
	
end


-- ACTION LISTS > ACTIONS
-- Add an action to the action list.
ns.newAction = function( aList, name )

	if not name then
		return nil
	end
	
	if type(aList) == string then
		aList = tonumber( match( aList, "^A(%d+)") )
	end
	
	local clear, suffix, name_arg = 0, 1, name
	while clear < #Hekili.DB.profile.actionLists[aList].Actions do
		clear = 0
		for i, action in ipairs( Hekili.DB.profile.actionLists[aList].Actions ) do
			if name == action.Name then
				name = name_arg .. ' (' .. suffix .. ')'
				suffix = suffix + 1
			else
				clear = clear + 1
			end
		end
	end

	local index = #Hekili.DB.profile.actionLists[ aList ].Actions + 1
	
	Hekili.DB.profile.actionLists[ aList ].Actions[ index ] = {
		Name = name,
		Release = Hekili.DB.profile.Version + ( Hekili.DB.profile.Release / 100 ),
		Enabled = false,
		Ability = nil,
		Caption = nil,
		Arguments = nil,
		Script = '',
	}

	return ( 'A' .. index ), index
	
end


--- NewActionOption()
-- Add a new action to the action list options.
-- aList	(number)	index of the action list.
-- index	(number)	index of the action in the action list.
ns.newActionOption = function( aList, index )

	if not index or not Hekili.DB.profile.actionLists[ aList ].Actions[ index ] then
		return nil
	end

	local actOption = {
		type = "group",
		name = '|cFFFFD100' .. index .. '.|r ' .. Hekili.DB.profile.actionLists[ aList ].Actions[ index ].Name,
		order = index * 10,
		-- childGroups = "tab",
		-- This number must be index + number of options in "Display Queues" section.
		-- order = index + 2,
		args = {
			Enabled = {
				type = 'toggle',
				name = 'Enabled',
				desc = "If disabled, this action will not be shown under any circumstances.",
				order = 00,
				width = 'double'
			},
			['Move'] = {
				type = 'select',
				name = 'Position',
				desc = "Select another position in the action list and move this item to that location.",
				order = 01,
				values = function(info)
					local listKey, actKey = info[2], info[3]
					local listIdx, actIdx = tonumber( listKey:match("^L(%d+)") ), tonumber( actKey:match("^A(%d+)") )
					local list = {}
					for i = 1, #Hekili.DB.profile.actionLists[ listIdx ].Actions do
						list[i] = i
					end
					return list
				end
			},
			['Name'] = {
				type = 'input',
				name = 'Name',
				desc = "Enter a unique name for this action in the action list.  This is typically the ability name accompanied by a short description.",
				order = 02,
				validate = function(info, val)
					local listIdx = tonumber( match( info[2], "^L(%d+)" ) )
					
					for i, action in pairs( Hekili.DB.profile.actionLists[ aList ].Actions ) do
						if action.Name == val and i ~= listIdx then
							return "That action name is already in use."
						end
					end
          return true
				end,
			},
			Ability = {
				type = 'select',
				name = 'Ability',
				desc = "Select the ability for this action entry.  Only abilities supported by the addon's prediction engine will be shown.",
				order = 03,
				values = class.searchAbilities
			},
			Caption = {
				type = 'input',
				name = 'Caption',
				desc = "Enter a caption to be displayed on this action's icon when the action is shown.",
				order = 04,
			},
			Script = {
				type = 'input',
				name = 'Conditions',
				dialogControl = "HekiliCustomEditor",
				arg = function(info)
					local listKey, actKey = info[2], info[3]
					local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )
					local results = {}
					
					ns.state.reset()
					ns.state.this_action = Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].Ability
					ns.storeValues( results, ns.scripts.A[ listIdx..':'..actIdx ] )
					
					return results
				end,
				multiline = 6,
				order = 10,
				width = 'full'
			},
			Args = { -- should rename at some point.
				type = 'input',
				name = 'Modifiers',
				order = 11,
				width = 'full'
			},
			deleteHeader = {
				type = 'header',
				name = 'Delete',
				order = 998,
			},
			Delete = {
				type = "execute",
				name = "Delete Action",
				confirm = true,
				-- confirmText = '
				order = 999,
				func		=	function(info, ...)
					-- Key to Current Display (string)
					local listKey = info[2]
					local listIdx = tonumber( match( listKey, "^L(%d+)" ) )
					local actKey = info[3]
					local actIdx = tonumber( match( actKey, "^A(%d+)" ) )

					-- Will need to be more elaborate later.
					ns.lib.AceConfigDialog:SelectGroup("Hekili", 'actionLists', listKey )
					table.remove( Hekili.DB.profile.actionLists[ listIdx ].Actions, actIdx )
					Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ] = nil
					ns.loadScripts()
					ns.refreshOptions()
				end
			},
		}
	}
	
	return actOption
	
end



local optionBuffer = {}

local buffer = function( msg )
  optionBuffer[ #optionBuffer + 1 ] = msg
end

local getBuffer = function()
  local output = table.concat( optionBuffer )
  table.wipe( optionBuffer )
  return output
end

local getColoredName = function( tab )
  if not tab then return '(none)'
  elseif tab.Default then return '|cFF00C0FF' .. tab.Name .. '|r'
  else return '|cFFFFC000' .. tab.Name .. '|r' end
end


function Hekili:GetOptions()
	local Options = {
		name = "Hekili",
		type = "group",
		handler = Hekili,
		get = 'GetOption',
		set = 'SetOption',
		childGroups = "tree",
		args = {
      welcome = {
        type = "group",
        name = "Welcome",
        order = 10,
        args = {
					headerWarn = {
						type = 'description',
						name	=	"Welcome to Hekili v2 for Warlords of Draenor.  This addon's default settings will give you similar behavior to the original version. " ..
									"The major changes for v2 include in-game editing for more options: more displays, customize action lists in-game, and so forth. " .. 
									'Please report bugs to hekili.tcn@gmail.com / @Hekili808 on Twitter / Hekili on MMO-C.\n',
						order = 0,
					},
          gettingStarted = {
            type = 'description',
            name = "|cFFFFD100Getting Started|r\n\n" ..
              "By default, this addon shows two displays.  The lower display is a hybrid display that will display a single-target, cleave, or AOE priority list depending on the number of targets that have been detected.  The upper display will show an AOE priority list, assuming a certain number of targets.\n\n" ..
              "For greater control over the primary display, you may want to adjust the |cFFFFD100Mode Switch|r settings found in the |cFFFFD100Filters and Keybinds|r section of the options.  You can bind a key that will manually swap the primary display between fixed, single-target mode, automatic mode, or fixed AOE mode.\n\n" ..
              "Additionally, by default, most major cooldowns are excluded from the action lists.  To enable them, it is strongly recommend that you bind a key in the |cFFFFD100Filters and Keybinds|r section for |cFFFFD100Show Cooldowns|r.  This will enable you to tell the addon when you do (or do not) want to have your cooldowns recommended.\n\n" ..
              "Finally, there are many options that can be changed on a per-display basis.  Check the |cFFFFD100Displays|r section, click the display in question, and check the |cFFFFD100UI and Style|r section to explore the available options for customization.\n",
            order = 1,
          },
          whatsNew = {
            type = 'description',
            name = "|cFFFFD100What's New!|r\n\n" ..
              "|cFFFFD100Clash|r - Under |cFFFFD100General Settings|r, you can now specify a |cFFFFD100Cooldown Clash|r setting.  This allows you to set a small buffer of time for preferring higher priority abilities over lower priority abilities.  For example, if Hammer of Wrath is ready in 0.1s and Judgment is ready now, setting this to 0.1 (or higher) will tell the addon to recommend Hammer of Wrath over Judgment.\n\n" ..
              "|cFF00C0FFDefaults|r - The names of the default displays and action lists have been changed.  They no longer begin with @, and if a display or action list is a default, its name will be in |cFF00C0FFblue|r.  Default lists and displays are automatically updated whenever you update the addon.\n\n" ..
              "|cFFFFD100SpellFlash Support|r - At user request, minimal SpellFlash support has been implemented.  If you have SpellFlash (or SpellFlashCore) installed, you will find an option for 'Use SpellFlash' on each display.  You can specify the color that display will flash when highlighting an entry.  If two or more lists are recommending the same ability, the addon will use the color of the first display.\n\n" ..
              "|cFFFFD100Minimum Targets|r - Displays now have an option labeled 'Force Minimum Targets'.  When action lists are processed in this display, the addon will always assume there are at least this many targets.  This purpose of this function is to prevent AOE displays from appearing very bizarre when there are not enough targets for the action list to function properly.  If a display is forced to act as though there are 3 targets but fewer than 3 targets are actually detected, the number of targets will be displayed in |cFFFF0000red|r.\n",
            order = 2
          },
          endCap = { -- just here to trigger scrolling if needed.
            type = 'description',
            name = ' ',
            order = 3
          }
          
        }
      },
			general = {
				type = "group",
				name = "General Settings",
				order = 20,
				args = {
					Enabled = {
						type = "toggle",
						name = "Enabled",
						desc = "Enables or disables the addon.",
						order = 1
					},
					Locked = {
						type = "toggle",
						name = "Locked",
						desc = "Locks or unlocks all displays for movement, except when the options window is open.",
						order = 2
					},
					Debug = {
						type = "toggle",
						name = "Debug",
						desc = "If checked, the addon will collect additional information that you can view by pausing the addon and placing your mouse over your displayed abilities.",
						order = 3
					},
					['Clash'] = {
						type = "group",
						name = "Cooldown Clash",
						inline = true,
						order = 4,
						args = {
							['Clash Description'] = {
								type = 'description',
								name = "When recommending abilities, the addon prioritizes the action that is available soonest and whose criteria passes.  Sometimes, a lower priority action will be recommended over a higher priority action because the lower priority action will be available slightly sooner.  By setting a Cooldown Clash value greater than 0, the addon will recommend a lower priority action only if it is available at least this much sooner than a higher priority ability.",
								order = 0
							},
							['Clash'] = {
								type = 'range',
								name = "Clash",
								min = 0,
								max = 0.5,
								step = 0.01,
								width = 'full',
								order = 1
							}						
						}
					},
					['Counter'] = {
						type = "group",
						name = "Target Count",
						inline = true,
						order = 5,
						args = {
							['Delay Description'] = {
								type = 'description',
								name = "This addon includes a mechanism for counting targets with whom you are actively engaged.  Any target that you damage, or is damaged by your pets/totems/guardians, is included in this target count.  Targets are removed when they are killed or if you do not damage them within the following 'Grace Period'.",
								order = 0
							},
							['Audit Targets'] = {
								type = 'range',
								name = "Grace Period",
								min = 3,
								max = 20,
								step = 1,
								width = 'full',
								order = 1
							}						
						}
					},
					['Engine'] = {
						type = "group",
						name = "Engine Settings",
						inline = true,
						order = 6,
						args = {
							['Engine Description'] = {
								type = 'description',
								name = "Set the frequency with which you want the addon to update your priority displays.  More frequent updates require more processor time (and can impact your frame rate); less frequent updates use less CPU, but may cause the display to be sluggish or to respond slowly to game events.  The default setting is 10 updates per second.",
								order = 0
							},
							['Updates Per Second'] = {
								type = 'range',
								name = "Updates Per Second",
								min = 4,
								max = 20,
								step = 1,
								width = 'full',
								order = 1
							}						
						}
					}
				}
			},
      notifs = {
        type = "group",
        name = "Notifications",
        childGroups = "tree",
        cmdHidden = true,
        order = 25,
        args = {
          ['Notification Enabled'] = {
            type = 'toggle',
            name = "Show Notifications",
            desc = "Show a frame where some updates will be posted during combat (e.g., 'Cooldowns ON' when you press your Cooldown toggle key).",
            order = 1,
            width = 'full',
          },
          ['Notification X'] = {
            type = 'input',
            name = 'Position (X)',
            desc = "Enter the horizontal position of the notification panel relative to the center of your screen.",
            order = 2,
          },
          ['Notification Y'] = {
            type = 'input',
            name = 'Position (Y)',
            desc = "Enter the vertical position of the notification panel relative to the center of your screen.",
            order = 3,
          },
          blank1 = {
            type = 'description',
            name = ' ',
            order = 4,
          },
          ['Notification Width'] = {
            type = 'range',
            name = 'Panel Width',
            desc = "Select the width of the panel in pixels.",
            order = 4,
            min = 25,
            max = 500,
            step = 1,
          },
          ['Notification Height'] = {
            type = 'range',
            name = 'Panel Height',
            desc = "Select the height of the panel in pixels.",
            order = 5,
            min = 10,
            max = 100,
            step = 1,
          },
          blank2 = {
            type = 'description',
            name = ' ',
            order = 6
          },
          ['Notification Font'] = {
						type = 'select',
						name = 'Font',
						desc = "Select the font to use in the Notification panel.",
						dialogControl = 'LSM30_Font',
						order = 7,
						values = ns.lib.SharedMedia:HashTable("font"), -- pull in your font list from LSM
					},
        },
      },
			displays = {
				type = "group",
				name = "Displays",
				childGroups = "tree",
				cmdHidden = true,
				order = 30,
				args = {
					header = {
						type = "description",
						name = "A display is a group of 1 to 10 icons.  Each display can multiple hooks for action lists, with customized criteria and actions for display.",
						order = 0
					},
					['New Display'] = {
						type = "input",
						name = "New Display",
						desc = 'Enter a new display name.  Default options will be used.',
						width = 'full',
						validate = function(info, val)
										if val == '' then return true end
                    for k,v in pairs(Hekili.DB.profile.displays) do
                      if val == v.name then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end
										return true
									end,
						order = 1
					},
					['Import Display'] = {
						type = "input",
						name = "Import Display",
						desc = "Paste a display's export string to import it here.",
						width = 'full',
						order = 2,
						multiline = 6,
					},
					footer = {
						type = "description",
						name = "   ",
						order = 3
					},
					Reload = {
						type = "execute",
						name = "Reload Missing",
						desc = "Reloads all missing default displays.",
						confirm = true,
						confirmText = "Restore any deleted default displays?",
						order = 4,
						func = function( info, ... )
							local exists = {}
							
							for i, display in ipairs( Hekili.DB.profile.displays ) do
								exists[ display.Name ] = true
							end

							for i, default in ipairs( class.defaults ) do
								if not exists[ default.name ] and default.type == 'displays' then
									local import = ns.deserializeDisplay( default.import )
									local index = #Hekili.DB.profile.displays + 1
									
									if import then
										Hekili.DB.profile.displays[ index ] = import
                    Hekili.DB.profile.displays[ index ].Name = default.name
										Hekili.DB.profile.displays[ index ].Release = default.version
                    Hekili.DB.profile.displays[ index ].Default = true
										
										if not Hekili[ 'ProcessDisplay' .. index ] then
											Hekili[ 'ProcessDisplay' .. index ] = function()
												Hekili:ProcessHooks( index )
											end
											C_Timer.After( 2 / Hekili.DB.profile['Updates Per Second'], Hekili[ 'ProcessDisplay' .. index ] )
										end
									else
										Hekili:Print("Unable to import " .. default.name .. ".")
									end
								end
							end
							
							ns.refreshOptions()
							ns.loadScripts()
							ns.buildUI()
						end,
					},
					ReloadAll = {
						type = "execute",
						name = "Reload All",
						desc = "Reloads all default displays.",
						confirm = true,
						confirmText = "Restore all default displays?",
						order = 5,
						func = function( info, ... )
							local exists = {}
							
							for i, display in ipairs( Hekili.DB.profile.displays ) do
								exists[ display.Name ] = i
							end

							for i, default in ipairs( class.defaults ) do
								if default.type == 'displays' then
									local import = ns.deserializeDisplay( default.import )
									local index = exists[ default.name ] or #Hekili.DB.profile.displays + 1
									
									if import then
										if exists[ default.name ] then
											local settings_to_keep = { "Primary Icon Size", "Queued Font Size", "Primary Font Size", "Primary Caption Aura", "rel", "Spacing", "Queue Direction", "Queued Icon Size", "Font", "x", "y", "Icons Shown", "Action Captions", "Primary Caption", "Primary Caption Aura", "PvE - Default", "PvE - Default Alpha", "PvE - Target", "PvE - Target Alpha", "PvE - Combat", "PvE - Combat Alpha", "PvP - Default", "PvP - Default Alpha", "PvP - Target", "PvP - Target Alpha", "PvP - Combat", "PvP - Combat Alpha" }
											
											for _, k in pairs( settings_to_keep ) do
												import[ k ] = Hekili.DB.profile.displays[ index ][ k ]
											end
										end
									
										Hekili.DB.profile.displays[ index ] = import
										Hekili.DB.profile.displays[ index ].Name = default.name
										Hekili.DB.profile.displays[ index ].Release = default.version
                    Hekili.DB.profile.displays[ index ].Default = true
										
										if not Hekili[ 'ProcessDisplay' .. index ] then
											Hekili[ 'ProcessDisplay' .. index ] = function()
												Hekili:ProcessHooks( index )
											end
											C_Timer.After( 2 / Hekili.DB.profile['Updates Per Second'], Hekili[ 'ProcessDisplay' .. index ] )
										end
									else
										Hekili:Print("Unable to import " .. default.name .. ".")
									end
								end
							end
							
							ns.refreshOptions()
							ns.loadScripts()
							ns.buildUI()
						end,
					},
				}
			},
			actionLists = {
				type = "group",
				name = "Action Lists",
				childGroups = "tree",
				cmdHidden = true,
				order = 40,
				args = {
					header = {
						type = "description",
						name = "Each action list is a selection of several abilities and the conditions for using them.",
						order = 10
					},
					['New Action List'] = {
						type = "input",
						name = "New Action List",
						desc = "Enter a name for this action list and press ENTER.",
						width = "full",
						validate = function(info, val)
										if val == '' then return true	end
										for k,v in pairs(Hekili.DB.profile.actionLists) do
											if val == v.Name then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
										return true
									end,
						order = 20
					},
					['Import Action List'] = {
						type = "input",
						name = "Import Action List",
						desc = "Paste an action list's export string to import it here.",
						width = 'full',
						order = 30,
						multiline = 6,
					},
					footer = {
						type = "description",
						name = "   ",
						order = 35
					},
					Reload = {
						type = "execute",
						name = "Reload Missing",
						desc = "Reloads all missing default action lists.",
						confirm = true,
						confirmText = "Restore any deleted default action lists?",
						order = 40,
						func = function( info, ... )
							local exists = {}
							
							for i, list in ipairs( Hekili.DB.profile.actionLists ) do
								exists[ list.Name ] = true
							end

							for i, default in ipairs( class.defaults ) do
								if not exists[ default.name ] and default.type == 'actionLists' then
									local import = ns.deserializeActionList( default.import )
									local index = #Hekili.DB.profile.actionLists + 1
									
									if import then
										Hekili.DB.profile.actionLists[ index ] = import
										Hekili.DB.profile.actionLists[ index ].Name = default.name
										Hekili.DB.profile.actionLists[ index ].Release = default.version
										Hekili.DB.profile.actionLists[ index ].Default = true
									else
										Hekili:Print("Unable to import " .. default.name .. ".")
										return
									end
								end
							end
							
							ns.refreshOptions()
							ns.loadScripts()
						end,
					},
					ReloadAll = {
						type = "execute",
						name = "Reload All",
						desc = "Reloads all default action lists.",
						confirm = true,
						confirmText = "Restore all default action lists?",
						order = 41,
						func = function( info, ... )
							local exists = {}
							
							for i, list in ipairs( Hekili.DB.profile.actionLists ) do
								exists[ list.Name ] = i
							end

							for i, default in ipairs( class.defaults ) do
								if default.type == 'actionLists' then
									local index = exists[ default.name ] or #Hekili.DB.profile.actionLists+1

									local import = ns.deserializeActionList( default.import )
									
									if import then
										Hekili.DB.profile.actionLists[ index ] = import
										Hekili.DB.profile.actionLists[ index ].Name = default.name
										Hekili.DB.profile.actionLists[ index ].Release = default.version
										Hekili.DB.profile.actionLists[ index ].Default = true
									else
										Hekili:Print("Unable to import " .. default.name .. ".")
										return
									end
								end
							end
							
							ns.refreshOptions()
							ns.loadScripts()
						end,
					},
				}
			},
			bindings = {
				type = 'group',
				name = 'Filters and Keybinds',
				order = 50,
				childGroups = 'tab',
				args = {
					default = {
						type = 'group',
						name = 'Default Filters',
						order = 0,
						args = {
							HEKILI_TOGGLE_PAUSE = {
								type = 'keybinding',
								name = 'Pause',
								desc = "Set a key to pause processing of your action lists.  Your current display(s) will freeze, and you can mouseover each icon to see information about the displayed action.",
								order = 10,
							},
							Pause = {
								type = 'toggle',
								name = 'Pause',
								order = 11,
								width = 'double',
							},
							HEKILI_TOGGLE_MODE = {
								type = 'keybinding',
								name = 'Mode Switch',
								desc = "Pressing this key will tell the addon to change how it handles the priority lists in the primary display, if your displays and action lists are configured to take advantage of this feature.\n" ..
                      "|cFFFFD100Auto:|r\nPressing this key will switch between single-target and automatic detection of single-target vs. cleave vs. AOE.\n" ..
                      "|cFFFFD100Manual:|r\nPressing this key will switch between single-target and AOE.  Cleave action lists will not be used.\n",
								order = 20,
							},
							['Switch Type'] = {
                type = 'select',
                name = 'Switch Type',
                desc = "|cFFFFD100Auto:|r\nPressing the Mode Switch keybind will switch between single-target and automatic detection of single-target vs. cleave vs. AOE.\n" ..
                      "|cFFFFD100Manual:|r\nPressing this key will switch between single-target and AOE.  Cleave action lists will not be used.\n",
                values = {
                  [0] = 'Auto',
                  [1] = 'Manual',
                },
								order = 21,
							},
              ['Mode Status'] = {
                type = 'select',
                name = 'Current Mode',
                desc = "Based upon the Switch Type, this setting can switch between single-target and auto ('cleave') or single-target and AOE.",
                values = function(info, val)
                  if Hekili.DB.profile['Switch Type'] == 2 then
                    return { [0] = 'Single Target', [1] = 'Cleave', [2] = 'AOE' }
                  elseif Hekili.DB.profile['Switch Type'] == 1 then
                    return { [0] = 'Single Target', [2] = 'AOE' }
                  elseif Hekili.DB.profile['Switch Type'] == 0 then
                    return { [0] = 'Single Target', [3] = 'Auto' }
                  end
                end,
                order = 22
              },
							HEKILI_TOGGLE_COOLDOWNS = {
								type = 'keybinding',
								name = 'Cooldowns',
								desc = 'Set a key for toggling cooldowns on and off.  This option is used by testing the criterion |cFFFFD100toggle.cooldowns|r in your condition scripts.',
								order = 30
							},
							Cooldowns = {
								type = 'toggle',
								name = 'Show Cooldowns',
								order = 31,
								width = 'double'
							},
							HEKILI_TOGGLE_HARDCASTS = {
								type = 'keybinding',
								name = 'Hardcasts',
								desc = 'Set a key for toggling hardcasts on and off.  Hardcast detection is handled by the addon and does not need to be included in your condition scripts.',
								order = 40
							},
							Hardcasts = {
								type = 'toggle',
								name = 'Show Hardcasts',
								order = 41,
								width = 'double'
							},
							HEKILI_TOGGLE_INTERRUPTS = {
								type = 'keybinding',
								name = 'Interrupts',
								desc = 'Set a key for toggling interrupts on and off.  This option is used by testing the criterion |cFFFFD100toggle.interrupts|r in your condition scripts.',
								order = 50
							},
							Interrupts = {
								type = 'toggle',
								name = 'Show Interrupts',
								order = 51,
								width = 'double'
							},
						}
					},
					custom = {
						type = 'group',
						name = 'Custom Filters',
						order = 10,
						args = {
							HEKILI_TOGGLE_1 = {
								type = 'keybinding',
								name = 'Toggle 1',
								order = 10
							},
							['Toggle 1 Name'] = {
								type = 'input',
								name = 'Alias',
								desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.one|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
								order = 12,
								validate = function(info, val)
									if val == '' then
										return true
									elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
										Hekili:Print("'" .. val .. "' is a reserved toggle name.")
										return "'" .. val .. "' is a reserved toggle name."
									end

									if match(val, "[^a-z]") then
										Hekili:Print("Toggle names must be all lowercase alphabet characters.")
										return "Toggle names must be all lowercase alphabet characters."

									else
										local this = tonumber( info[#info]:match('Toggle (%d) Name') )

										for i = 1, 5 do
											if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
									end

									return true
								end,
								width = 'double'
							},
							HEKILI_TOGGLE_2 = {
								type = 'keybinding',
								name = 'Toggle 2',
								order = 20
							},
							['Toggle 2 Name'] = {
								type = 'input',
								name = 'Alias',
								desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.two|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
								order = 21,
								validate = function(info, val)
									if val == '' then
										return true
									elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
										Hekili:Print("'" .. val .. "' is a reserved toggle name.")
										return "'" .. val .. "' is a reserved toggle name."
									end

									if match(val, "[^a-z]") then
										Hekili:Print("Toggle names must be all lowercase alphabet characters.")
										return "Toggle names must be all lowercase alphabet characters."

									else
										local this = tonumber( info[#info]:match('Toggle (%d) Name') )

										for i = 1, 5 do
											if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
									end

									return true
								end,
								width = 'double'
							},
							HEKILI_TOGGLE_3 = {
								type = 'keybinding',
								name = 'Toggle 3',
								order = 30
							},
							['Toggle 3 Name'] = {
								type = 'input',
								name = 'Alias',
								desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.three|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
								order = 31,
								validate = function(info, val)
									if val == '' then
										return true
									elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
										Hekili:Print("'" .. val .. "' is a reserved toggle name.")
										return "'" .. val .. "' is a reserved toggle name."
									end

									if match(val, "[^a-z]") then
										Hekili:Print("Toggle names must be all lowercase alphabet characters.")
										return "Toggle names must be all lowercase alphabet characters."

									else
										local this = tonumber( info[#info]:match('Toggle (%d) Name') )

										for i = 1, 5 do
											if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
									end

									return true
								end,
								width = 'double'
							},
							HEKILI_TOGGLE_4 = {
								type = 'keybinding',
								name = 'Toggle 4',
								order = 40
							},
							['Toggle 4 Name'] = {
								type = 'input',
								name = 'Alias',
								desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.four|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
								order = 41,
								validate = function(info, val)
									if val == '' then
										return true
									elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
										Hekili:Print("'" .. val .. "' is a reserved toggle name.")
										return "'" .. val .. "' is a reserved toggle name."
									end

									if match(val, "[^a-z]") then
										Hekili:Print("Toggle names must be all lowercase alphabet characters.")
										return "Toggle names must be all lowercase alphabet characters."

									else
										local this = tonumber( info[#info]:match('Toggle (%d) Name') )

										for i = 1, 5 do
											if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
									end

									return true
								end,
								width = 'double'
							},
							HEKILI_TOGGLE_5 = {
								type = 'keybinding',
								name = 'Toggle 5',
								order = 50
							},
							['Toggle 5 Name'] = {
								type = 'input',
								name = 'Alias',
								desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.five|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
								order = 51,
								validate = function(info, val)
									if val == '' then
										return true
									elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
										Hekili:Print("'" .. val .. "' is a reserved toggle name.")
										return "'" .. val .. "' is a reserved toggle name."
									end

									if match(val, "[^a-z]") then
										Hekili:Print("Toggle names must be all lowercase alphabet characters.")
										return "Toggle names must be all lowercase alphabet characters."

									else
										local this = tonumber( info[#info]:match('Toggle (%d) Name') )

										for i = 1, 5 do
											if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
												Hekili:Print("That name is already in use.")
												return "That name is already in use."
											end
										end
										
									end

									return true
								end,
								width = 'double'
							},
						}
					}
				}
			}
		}
	}

	for i, v in ipairs(Hekili.DB.profile.displays) do
		local dispKey = 'D' .. i
		Options.args.displays.args[ dispKey ] = ns.newDisplayOption( i )
		
		if v.Queues then
			for key, value in ipairs( v.Queues ) do
				Options.args.displays.args[ dispKey ].args[ 'P' .. key ] = ns.newHookOption( i, key )
			end
		end
		
	end

	for i,v in ipairs(Hekili.DB.profile.actionLists) do
		local listKey = 'L' .. i
		Options.args.actionLists.args[ listKey ] = ns.newActionListOption( i )

		if v.Actions then
			for key, value in ipairs( v.Actions ) do
--				Options.args.actionLists.args[ listKey ].args['Actions'].args[ 'A' .. key ] = ns.newActionOption( i, key )
				Options.args.actionLists.args[ listKey ].args[ 'A' .. key ] = ns.newActionOption( i, key )
			end
		end

	end
	
	return Options
end


function Hekili:TotalRefresh()

	restoreDefaults()

	for i, queue in ipairs( ns.queue ) do
		for j, _ in pairs( queue ) do
			ns.queue[i][j] = nil
		end
		ns.queue[i] = nil
	end

  callHook( "onInitialize" )
	ns.refreshOptions()
	ns.buildUI()
  
end


ns.refreshOptions = function()

	-- Remove existing displays from Options and rebuild the options table.
	for k,_ in pairs(Hekili.Options.args.displays.args) do
		if match(k, "^D(%d+)") then
			Hekili.Options.args.displays.args[k] = nil
		end
	end
	
	for i,v in ipairs(Hekili.DB.profile.displays) do
		local dispKey = 'D' .. i
		Hekili.Options.args.displays.args[ dispKey ] = ns.newDisplayOption( i )
		
		if v.Queues then
			for p, value in ipairs( v.Queues ) do
				local hookKey = 'P' .. p
				Hekili.Options.args.displays.args[ dispKey ].args[ hookKey ] = ns.newHookOption( i, p )
			end
		end
	end
	
	for k,_ in pairs(Hekili.Options.args.actionLists.args) do
		if match(k, "^L(%d+)") then
			Hekili.Options.args.actionLists.args[k] = nil
		end
	end
	
	for i,v in ipairs(Hekili.DB.profile.actionLists) do
		local listKey = 'L' .. i
		Hekili.Options.args.actionLists.args[ listKey ] = ns.newActionListOption( i )
		
		if v.Actions then
			for a,_ in ipairs( v.Actions ) do
				local actKey = 'A' .. a
				Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ] = ns.newActionOption( i, a )
			end
		end
	end
	
	-- Until I feel like making this better at managing memory.
	collectgarbage()
	
end


function Hekili:GetOption( info, input )
	local category, depth, option = info[1], #info, info[#info]
	local profile = Hekili.DB.profile
	
	if category == 'general' then
		return profile[option]
	
  elseif category == 'notifs' then
    if option == 'Notification X' or option == 'Notification Y' then
      return tostring( profile[ option ] )
    end  
    return profile[option]
  
	elseif category == 'bindings' then
	
		if option:match( "TOGGLE" ) then
			return select( 1, GetBindingKey( option ) )
		
		elseif option == 'Pause' then
			return self.Pause
      
		else
			return profile[ option ]

		end

	elseif category == 'displays' then

		-- This is a generic display option/function.
		if depth == 2 then
			return nil
			
		-- This is a display (or a hook).
		else
			local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
			local hookKey, hookID = info[3], tonumber( match( info[3] or "", "^P(%d+)" ) )
			local display = profile.displays[ dispID ]

			-- This is a specific display's settings.
			if depth == 3 or not hookID then
				
				if option == 'x' or option == 'y' then
					return tostring( display[ option ] )
        
        elseif option == 'SpellFlash Color' then
          if type( display[option] ) ~= 'table' then display[option] = { r = 1, g = 1, b = 1, a = 1 } end
          return display[option].r, display[option].g, display[option].b, display[option].a
				
				elseif option == 'Copy To' or option == 'Import' then
					return nil
					
				else
					return display[ option ]
					
				end
			
			-- This is a priority hook.
			else
				local hook = display.Queues[ hookID ]
				
				if option == 'Move' then
					return hookID
				
				else
					return hook[ option ]
				
				end
			
			end
			
		end
	
	elseif category == 'actionLists' then
	
		-- This is a general action list option.
		if depth == 2 then
			return nil
			
		else
			local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
			local actKey, actID = info[3], tonumber( match( info[3], "^A(%d+)" ) )
			local list = listID and profile.actionLists[ listID ]
		
			-- This is a specific action list.
			if depth == 3 or not actID then
				return list[ option ]
			
			-- This is a specific action.
			elseif listID and actID then
				local action = list.Actions[ actID ]
				
				if option == 'Move' then
					return actID
				
				else
					return action[ option ]
				
				end
			
			end
		
		end
		
	end

	Hekili:Error( "GetOption() - should never see." )

end


local getUniqueName = function( category, name )
	local numChecked, suffix, original = 0, 1, name
	
	while numChecked < #category do
		for i, instance in ipairs( category ) do
			if name == instance.Name then
				name = original .. ' (' .. suffix .. ')'
				suffix = suffix + 1
				numChecked = 0
			else
				numChecked = numChecked + 1
			end
		end
	end
	
	return name
end


function Hekili:SetOption( info, input, ... )
	local category, depth, option, subcategory = info[1], #info, info[#info], nil
	local Rebuild, RebuildUI, RebuiltScripts, RebuildOptions, RebuildCache, Select
	local profile = Hekili.DB.profile
	
	if category == 'general' then
		-- We'll preset the option here; works for most options.
		profile[ option ] = input
		
		if option == 'Enabled' then
			for i, buttons in ipairs( ns.UI.Buttons ) do
				for j, _ in ipairs( buttons ) do
					if input == false then
						buttons[j]:Hide()
					else
						buttons[j]:Show()
					end
				end
			end
			
			if input == true then self:Enable()
			else self:Disable() end

			return
			
		elseif option == 'Locked' then
			if not self.Config and not self.Pause then
				for i, v in ipairs( ns.UI.Buttons ) do
					ns.UI.Buttons[i][1]:EnableMouse( not input )
				end
			end
		
		elseif option == 'Audit Targets' or option == 'Updates Per Second' then
			return
			
		end
		
		-- General options do not need add'l handling.
		return 
	
  elseif category == 'notifs' then
    profile[ option ] = input
    
    if option == 'Notification X' or option == 'Notification Y' then
      profile[ option ] = tonumber( input )
    end
    
    RebuildUI = true
  
	elseif category == 'bindings' then

		local revert = profile[ option ]
		profile[ option ] = input
	
		if option:match( "TOGGLE" ) then
			if GetBindingKey( option ) then
				SetBinding( GetBindingKey( option ) )
			end
			SetBinding( input, option )
			SaveBindings( GetCurrentBindingSet() )

		elseif option == 'Mode' then
      profile[option] = revert
      self:ToggleMode()
    
    elseif option == 'Pause' then
			profile[option] = revert
			self:TogglePause()
			return
			
		elseif option == 'Cooldowns' then
			profile[option] = revert
			self:ToggleCooldowns()
			return
		
		elseif option == 'Hardcasts' then
			profile[option] = revert
			self:ToggleHardcasts()
			return
			
		elseif option == 'Interrupts' then
			profile[option] = revert
			self:ToggleInterrupts()
			return
    
    elseif option == 'Switch Type' then
      if input == 0 then
        if profile['Mode Status'] == 1 or profile['Mode Status'] == 2 then
        -- Check that the current mode is supported.
          profile['Mode Status'] = 0
          self:Print("Switch type updated; reverting to single-target.")
        end
      elseif input == 1 then
        if profile['Mode Status'] == 1 or profile['Mode Status'] == 3 then
          profile['Mode Status'] = 0
          self:Print("Switch type updated; reverting to single-target.")
        end
      end
    
    elseif option == 'Mode Status' then
      -- do nothing, we're good.
		
		else -- Toggle Names.
			if input:trim() == "" then
				profile[ option ] = nil
			end
			
		end

		-- Bindings do not need add'l handling.
		return

	elseif category == 'displays' then

		-- This is a generic display option/function.
		if depth == 2 then
		
			if option == 'New Display' then
				local key, index = ns.newDisplay( input )
				
				if not key then return end
				
				C_Timer.After( 1 / profile['Updates Per Second'], Hekili[ 'ProcessDisplay'..index ] )
			
			elseif option == 'Import Display' then
				local import = ns.deserializeDisplay( input )
				
				if not import then
					Hekili:Print("Unable to import from given input string.")
					return
				end
				
				import.Name = getUniqueName( profile.displays, import.Name )
				profile.displays[ #profile.displays + 1 ] = import
				
			end

			Rebuild = true
			
		-- This is a display (or a hook).
		else
			local dispKey, dispID = info[2], info[2] and tonumber( match( info[2], "^D(%d+)" ) )
			local hookKey, hookID = info[3], info[3] and tonumber( match( info[3], "^P(%d+)" ) )
			local display = dispID and profile.displays[ dispID ]

			-- This is a specific display's settings.
			if depth == 3 or not hookID then
				local revert = display[option]
				display[option] = input
				
				if option == 'x' or option == 'y' then
					display[option] = tonumber( input )
					RebuildUI = true
				
				elseif option == 'Name' then
					Hekili.Options.args.displays.args[ dispKey ].name = input
          if input ~= revert and display.Default then display.Default = false end
				
				elseif option == 'Enabled' then
					-- Might want to replace this with RebuildUI = true
					for i, button in ipairs( ns.UI.Buttons[ dispID ] ) do
						if not input then
							button:Hide()
						else
							button:Show()
						end
					end
					RebuildUI = true
        
        elseif option == 'Use SpellFlash' then
				
        elseif option == 'SpellFlash Color' then
          if type( display[ option ] ~= 'table' ) then display[ option ] = {} end
          display[ option ].r = input
          display[ option ].g = select( 1, ... )
          display[ option ].b = select( 2, ... )
          display[ option ].a = select( 3, ... )
        
				elseif option == 'Script' then
					display[option] = input:trim()
					RebuildScripts = true
				
				elseif option == 'Copy To' then
					local index = #profile.displays + 1
					
					profile.displays[ index ] = tableCopy( display )
					profile.displays[ index ].Name = input
          profile.displays[ index ].Default = ns.isDefault( input, 'displays' )
          
          if not Hekili[ 'ProcessDisplay'..index ] then
            Hekili[ 'ProcessDisplay'..index ] = function ()
              Hekili:ProcessHooks( index )
            end
            C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self[ 'ProcessDisplay'..index ] )
          end
					Rebuild = true
				
				elseif option == 'Import' then
					local import = ns.deserializeDisplay( input )
				
					if not import then
						Hekili:Print("Unable to import from given input string.")
						return
					end
					
					local name = display.Name
					profile.displays[ dispID ] = import
					profile.displays[ dispID ].Name = name
					
					Rebuild = true
				
				elseif option == 'Icons Shown' then
					if ns.queue[ dispID ] then
						for i = input + 1, #ns.queue[ dispID ] do
							ns.queue[ dispID ][ i ] = nil
						end
					end
				
				end
				
				RebuildUI = true
			
			-- This is a priority hook.
			else
				local hook = display.Queues[ hookID ]
				
				if option == 'Move' then
					local placeholder = table.remove( display.Queues, hookID )
					table.insert( display.Queues, input, placeholder )
					Rebuild, Select = true, 'P'..input
				
				elseif option == 'Script' then
					hook[ option ] = input:trim()
					RebuildScripts = true
				
				elseif option == 'Name' then
					Hekili.Options.args.displays.args[ dispKey ].args[ hookKey ].name = '|cFFFFD100' .. hookID .. '.|r ' .. input
					hook[ option ] = input
					
				elseif option == 'Action List' or option == 'Enabled' then
          hook[ option ] = input
          RebuildCache = true
          
        else
					hook[ option ] = input
				
				end
			
			end
		end
	
	elseif category == 'actionLists' then
	
		if depth == 2 then 
	
			if option == 'New Action List' then
				local key = ns.newActionList( input )
				if key then
					RebuildOptions, RebuildCache = true, true
				end
				
			elseif option == 'Import Action List' then
				local import = ns.deserializeActionList( input )
				
				if not import then
					Hekili:Print("Unable to import from given input string.")
					return
				end
				
				import.Name = getUniqueName( profile.actionLists, import.Name )
				profile.actionLists[ #profile.actionLists + 1 ] = import
				Rebuild = true
				
			end
		
		else
			local listKey, listID = info[2], info[2] and tonumber( match( info[2], "^L(%d+)" ) )
			local actKey, actID = info[3], info[3] and tonumber( match( info[3], "^A(%d+)" ) )
			local list = profile.actionLists[ listID ]
			
			if depth == 3 or not actID then

				local revert = list[ option ]
				list[option] = input
				
				if option == 'Name' then
					Hekili.Options.args.actionLists.args[ listKey ].name = input
          if input ~= revert and list.Default then list.Default = false end
				
				elseif option == 'Enabled' or option == 'Specialization' then
					RebuildCache = true
					
				elseif option == 'Script' then
					list[ option ] = input:trim()
					RebuildScripts = true
				
				-- Import/Exports
				elseif option == 'Copy To' then
					list[option] = nil

					local index = #profile.actionLists + 1
					
					profile.actionLists[ index ] = tableCopy( list )
					profile.actionLists[ index ].Name = input
          profile.actionLists[ index ].Default = false
					
					Rebuild = true
					
				elseif option == 'Import Action List' then
					list[option] = nil

					local import = ns.deserializeActionList( input )
					
					if not import then
						Hekili:Print("Unable to import from given import string.")
						return
					end
					
					import.Name = list.Name
					table.remove( profile.actionLists, listID )
          table.insert( profile.actionLists, listID, import )
					-- profile.actionLists[ listID ] = import
					Rebuild = true
				
				elseif option == 'SimulationCraft' then
					list[option] = nil

					local import, error = self:ImportSimulationCraftActionList( input )
					
					if error then
						Hekili:Print( "SimulationCraft import failed.  The following lines threw errors:" )
						for i = 1, #error do
							Hekili:Print( error[i] )
						end
						return
					end
					
					if not import then
						Hekili:Print( "No actions were successfully imported." )
						return
					end
					
					table.wipe( list.Actions )
				
					for i = 1, #import do
						local key = ns.newAction( listID, class.abilities[ import[ i ].ability ].name )
						
						list.Actions[ i ].Ability = import[ i ].ability
						list.Actions[ i ].Args = import[ i ].modifiers
						list.Actions[ i ].Script = import[ i ].conditions
						list.Actions[ i ].Enabled = true
					end
					
					Rebuild = true
				
				end
		
			-- This is a specific action.
			else
				local list = profile.actionLists[ listID ]
				local action = list.Actions[ actID ]
				
				action[ option ] = input
				
				if option == 'Name' then
					Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ].name = '|cFFFFD100' .. actID .. '.|r ' .. input
				
				elseif option == 'Enabled' then
					RebuildCache = true
					
				elseif option == 'Move' then
					action[ option ] = nil
					local placeholder = table.remove( list.Actions, actID )
					table.insert( list.Actions, input, placeholder )
					Rebuild, Select = true, 'A'..input
				
				elseif option == 'Script' or option == 'Args' then
					input = input:trim()
					action[ option ] = input
					RebuildScripts = true
				
				end
			
			end
		end
	end
	
	if Rebuild then
		ns.refreshOptions()
		ns.loadScripts()
		ns.buildUI()
	else
		if RebuildOptions then ns.refreshOptions() end
		if RebuildScripts then ns.loadScripts() end
		if RebuildUI then ns.buildUI() end
		if RebuildCache and not RebuildUI then ns.cacheCriteria() end
	end
	
	if Select then
		ns.lib.AceConfigDialog:SelectGroup( "Hekili", category, info[2], Select )
	end

end	


function Hekili:CmdLine( input )
	if not input or input:trim() == "" then
    if InCombatLockdown() then
      Hekili:Print( "This addon cannot be configured while in combat." )
      return
    end
    ns.StartConfiguration()
			
	elseif input:trim() == 'center' then
		for i, v in ipairs( Hekili.DB.profile.displays ) do
			ns.UI.Buttons[i][1]:ClearAllPoints()
			ns.UI.Buttons[i][1]:SetPoint("CENTER", 0, (i-1) * 50 )
		end
		self:SaveCoordinates()
	
	elseif input:trim() == 'recover' then
		Hekili.DB.profile.displays = {}
		Hekili.DB.profile.actionLists = {}
		ns.restoreDefaults()
		ns.buildUI()
		Hekili:Print("Default displays and action lists restored.")
	
	else
		LibStub("AceConfigCmd-3.0"):HandleCommand("hekili", "Hekili", input)
	end
end


function ns.serializeDisplay( num )

	if not Hekili.DB.profile.displays[ num ] then return nil end
	
	local serial = tableCopy( Hekili.DB.profile.displays[ num ] )
	
	-- Change actionlist IDs to actionlist names so we can validate later.
	for i,v in ipairs( serial.Queues ) do
		if serial.Queues[i]['Action List'] ~= 0 then
			serial.Queues[i]['Action List'] = Hekili.DB.profile.actionLists[ v['Action List'] ].Name
		end
	end
	
	-- return self:Serialize(flat_display)
	return Hekili:Serialize( serial )
end


function ns.deserializeDisplay( str )
	local success, import = Hekili:Deserialize( str )

	if not success then return nil end

	-- Check for duplicate names.
	for i, prio in ipairs( import.Queues ) do
		if prio['Action List'] ~= 0 then
			for j, list in ipairs( Hekili.DB.profile.actionLists ) do
				if prio['Action List'] == list.Name then
					prio['Action List'] = j
				end
			end
			if type( prio['Action List'] ) == 'string' then
				prio['Action List'] = 0
			end
		end
	end
	
	return import
end	


function ns.serializeActionList( num )

	if not Hekili.DB.profile.actionLists[ num ] then return nil end
	
	local serial = tableCopy( Hekili.DB.profile.actionLists[ num ] )
	
	return Hekili:Serialize( serial )
end


function ns.deserializeActionList( str )
	local success, import = Hekili:Deserialize( str )

	if not success then return nil end
	
	return import
end	


function Hekili:ImportSimulationCraftActionList( str )
	local import = str and str or Hekili.ImportString
	local output, errors = {}, {}
	local line, times = 0, 0

	import = import:gsub("(|)([^|])", "%1|%2"):gsub("|||", "||")
	
  for i in import:gmatch("action.-=/?([^\n^$]*)") do
    line = line + 1
  
    for v in pairs( class.resources ) do
      i, times = i:gsub( '([^_ ])('..v..')([^._])', "%1%2.current%3" )
      if times > 0 then
        Hekili:Print("Line " .. line .. ": Converted '" .. v .. "' to '" .. v .. ".current' (" .. times .. "x)." )
      end
      i, times = i:gsub( '([^_ ])('..v..')$', "%1%2.current" )
      if times > 0 then
        Hekili:Print("Line " .. line .. ": Converted '" .. v .. "' to '" .. v .. ".current' at EOL (" .. times .. "x)." )
      end
    end
    
    i, times = i:gsub( "buff[.](.-)[.](react)([^><=~])", "buff.%1.up%3" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted unconditional 'X.react' to 'X.up' (" .. times .. "x)." )
    end
    i, times = i:gsub( "buff[.](.-)[.](react)$", "buff.%1.up" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted unconditional 'X.react' to 'X.up' at EOL (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "gcd.max", "gcd" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted 'gcd.max' to 'gcd' (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "(incoming_damage_%d+[m]?s)([^><=~])", "%1>0%2" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted unconditional 'incoming_damage_Xms' to 'incoming_damage_Xms>0' (" .. times .. "x)." )
    end
    i, times = i:gsub( "(incoming_damage_%d+[m]?s)$", "%1>0" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted unconditional 'incoming_damage_Xms' to 'incoming_damage_Xms>0' at EOL(" .. times .. "x)." )
    end
    
    i, times = i:gsub( "[!]buff.(.-).remains", "!buff.%1.up")
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted '!buff.X.remains' to '!buff.X.up' (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "([^_])target([^.])", "%1target.unit%2" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted non-specific 'target' to 'target.unit' (" .. times .. "x)." )
    end
    i, times = i:gsub( "([^_])target$", "%1target.unit" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted non-specific 'target' to 'target.unit' at EOL (" .. times .. "x)." )
    end
    
    i,times = i:gsub( "(set_bonus.[^.=|&]+)=1", "%1" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted set_bonus.X=1 to set_bonus.X (" .. times .. "x)." )
    end
    i,times = i:gsub( "(set_bonus.[^.=|&]+)=0", "!%1" )
    if times > 0 then
      Hekili:Print("Line " .. line .. ": Converted set_bonus.X=0 to !set_bonus.X (" .. times .. "x)." )
    end
  
		local _, commas = i:gsub(",", "")
		local _, condis = i:gsub(",if=", "")
		
		-- Action
		if commas == 0 then 
			local ability = i:trim()
			
			if ability and class.abilities[ ability ] then
				output[#output + 1] = {
					ability = ability
				}
			else
				errors[#errors + 1] = i
			end
		
		-- Action and Conditions
		elseif commas == 1 and condis == 1 then 
			local ability, conditions = i:match("(.-),if=(.-)$")
			
			if ability and conditions and class.abilities[ ability ] then
				output[#output + 1] = {
					ability = ability,
					conditions = conditions
				}
			else
				errors[#errors + 1] = i
			end
		
		-- Action and Modifiers
		elseif commas >= 1 and condis == 0 then
			local ability, modifier = i:match("(.-),(.-)$")
      local conditions = nil
      
      if modifier == "moving=1" then
        Hekili:Print("Line " .. line .. ": Converted 'moving=1' modifier to 'moving' conditional.")
        conditions = "moving"
        modifier = ""
      end

      if modifier:sub(1, 5) == 'sync=' then
        Hekili:Print("Line " .. line .. ": Converted 'sync=' modifier to 'action.X.ready' conditional.")
        conditions = "action." .. modifier:sub(6) .. ".ready&("..conditions..")"
        modifier = ""
      end

			if ability and modifier and class.abilities[ ability ] then
				output[#output + 1] = {
					ability = ability,
					modifiers = modifier,
          conditions = conditions
				}
			else
				errors[#errors + 1] = i
			end
			
		-- Action, Modifiers, Conditions
		elseif commas > 1 and condis == 1 then 
			local ability, modifiers, conditions = i:match("(.-),(.-),if=(.-)$")	

      if modifiers == "moving=1" then
        Hekili:Print("Line " .. line .. ": Converted 'moving=1' modifier to 'moving' conditional.")
        conditions = "moving&("..conditions..")"
        modifiers = ""
      end
      
      if modifiers:sub(1, 5) == 'sync=' then
        Hekili:Print("Line " .. line .. ": Converted 'sync=' modifier to 'action.X.ready' conditional.")
        conditions = "action." .. modifiers:sub(6) .. ".ready&("..conditions..")"
        modifiers = ""
      end
			
			if ability and modifiers and conditions and class.abilities[ ability ] then
				output[#output + 1] = {
					ability = ability,
					modifiers = modifiers,
					conditions = conditions
				}
			else
				errors[#errors + 1] = i
			end
		
		end
	end
	
	return #output > 0 and output or nil, #errors > 0 and errors or nil
	
end

-- Key Bindings
function Hekili:TogglePause()
	self.Pause = not self.Pause
	
	local MouseInteract = self.Pause or self.Config or not Hekili.DB.profile.Locked
	
	for i = 1, #ns.UI.Buttons do
		for j = 1, #ns.UI.Buttons[i] do
			ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
		end
	end
	
	Hekili:Print( (not self.Pause and "UN" or "") .. "PAUSED." )
	Hekili:Notify( (not self.Pause and "UN" or "") .. "PAUSED" )
end


function Hekili:Notify( str )
	--[[ if not ns.UI.Buttons or not ns.UI.Buttons[1] or not ns.UI.Buttons[1][1] or not str then
		return
	end ]]
  
  
	HekiliNotificationText:SetText( str )
	HekiliNotificationText:SetTextColor( 1, 0.8, 0, 1 )
	UIFrameFadeOut( HekiliNotificationText, 3, 1, 0 )
end


local nextMode = {
  [0] = { [0] = 3, [3] = 0 },
  [1] = { [0] = 2, [2] = 0 },
  [2] = { [0] = 1, [1] = 2, [2] = 0 }
}

local modeMsgs = {
  [0] = {
    p = "Single-target mode activated.",
    n = "Mode: Single"
  },
  [1] = {
    p = "Cleave mode activated.",
    n = "Mode: Cleave"
  },
  [2] = {
    p = "AOE mode activated.",
    n = "Mode: AOE"
  },
  [3] = {
    p = "Automatic mode activated.",
    n = "Mode: Auto"
  }
}

function Hekili:ToggleMode()
  local switch = Hekili.DB.profile['Switch Type']
  
  Hekili.DB.profile['Mode Status'] = nextMode[ switch ][ Hekili.DB.profile['Mode Status'] ]
  
  Hekili:Print( modeMsgs[ Hekili.DB.profile['Mode Status'] ].p )
  Hekili:Notify( modeMsgs[ Hekili.DB.profile['Mode Status'] ].n )
end


function Hekili:ToggleInterrupts()
	Hekili.DB.profile.Interrupts = not Hekili.DB.profile.Interrupts
	Hekili:Print( Hekili.DB.profile.Interrupts and "Interrupts |cFF00FF00ENABLED|r." or "Interrupts |cFFFF0000DISABLED|r." )
	Hekili:Notify( "Interrupts " .. ( Hekili.DB.profile.Interrupts and "ON" or "OFF" ) )
end
	

function Hekili:ToggleCooldowns()
	Hekili.DB.profile.Cooldowns = not Hekili.DB.profile.Cooldowns
	Hekili:Print( Hekili.DB.profile.Cooldowns and "Cooldowns |cFF00FF00ENABLED|r." or "Cooldowns |cFFFF0000DISABLED|r." )
	Hekili:Notify( "Cooldowns " .. ( Hekili.DB.profile.Cooldowns and "ON" or "OFF" ) )
end


function Hekili:ToggleHardcasts()
	Hekili.DB.profile.Hardcasts = not Hekili.DB.profile.Hardcasts
	Hekili:Print( Hekili.DB.profile.Hardcasts and "Hardcasts |cFF00FF00ENABLED|r." or "Hardcasts |cFFFF0000DISABLED|r." )
	Hekili:Notify( "Hardcasts " .. ( Hekili.DB.profile.Hardcasts and "ON" or "OFF" ) )
end


function Hekili:Toggle( num )
	Hekili.DB.profile['Toggle_' .. num] = not Hekili.DB.profile['Toggle_' .. num]
	
	if Hekili.DB.profile['Toggle ' .. num .. ' Name'] then
		Hekili:Print( Hekili.DB.profile['Toggle_' .. num] and ( 'Toggle \'' .. Hekili.DB.profile['Toggle ' .. num .. ' Name'] .. "' |cFF00FF00ENABLED|r." ) or ( 'Toggle \'' .. Hekili.DB.profile['Toggle ' .. num .. ' Name'] .. "' |cFFFF0000DISABLED|r." ) )
	else
		Hekili:Print( Hekili.DB.profile['Toggle_' .. num] and ( "Custom Toggle #" .. num .. " |cFF00FF00ENABLED|r." ) or ( "Custom Toggle #" .. num .. " |cFFFF0000DISABLED|r." ) )
	end
end