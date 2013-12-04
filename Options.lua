--	Options.lua
--	Insert clever description here.
--	Hekili @ Ner'zhul, 10/23/13

function OutputFlags( option, category )
	local output
	local abilities = ''
	local count = 0

	if Hekili.Active then
		for k,v in pairs(Hekili.Active.spells) do
			if v[category] then
				if count >= 1 then abilities = abilities .. ', ' end
				abilities = abilities .. k
				count = count + 1
			end
		end
	end

	if Hekili.DB.profile[option] == true then
		output = 'Hide ' .. category .. ' abilities from the priority display (presently shown).'
	else
		output = 'Show ' .. category .. ' abilities from the priority display (presently hidden).'
	end

	if abilities ~= '' then
		output = output .. '\n|cFFFFD100Affects:|r ' .. abilities
	end

	return output			
end



function Hekili:IsFiltered( ability, cooldown )
	local mod = self.Active
	local spell

	if not mod or not mod.spells or not mod.spells[ability] then
		return false
	else
		spell = mod.spells[ability]
	end
	
	if cooldown then
		if spell.bloodlust and not self.DB.profile[ 'Show Bloodlust' ] then
			return true
		elseif spell.consumable and not self.DB.profile[ 'Show Consumables' ] then
			return true
		elseif spell.profession and not self.DB.profile[ 'Show Professions' ] then
			return true
		elseif cooldown and spell.racial and not self.DB.profile[ 'Show Racials' ] then
			return true
		elseif spell.cooldown then
			if spell.cdUpdated < self.eqChanged and not spell.item then
				spell.cooldown	= ttCooldown(spell.id)
				spell.cdUpdated	= GetTime()
			end
		
			if spell.cooldown > self.DB.profile['Cooldown Threshold'] then
				return true
			end
		end
	end
	
	if spell.interrupt and not self.DB.profile[ 'Show Interrupts' ] then
		return true
	elseif spell.precombat and not self.DB.profile[ 'Show Precombat' ] then
		return true
	elseif spell.talent and not self.DB.profile[ 'Show Talents' ] then
		return true
	elseif spell.name then
		return true
	end
	
	return false
end


function Hekili:GetOptions()

	local Options = {
		name = 'Hekili',
		handler = Hekili,
		type = 'group',
		childGroups = 'tab',
		args = {
			['Basic'] = {
				type = "group",
				name = "Basic Settings",
				childGroups = 'tree',
				order = 0,
				args = {
					enabled = {
						type = 'toggle',
						name = 'Enabled',
						desc = function ()
									local output
									if Hekili.DB.profile.enabled == true then
										output = 'Disable this AddOn (presently enabled).'
									else
										output = 'Enable this AddOn (presently disabled).'
									end
									return output			
								end,
						set = 'SetOption',
						get = 'GetOption',
						order = 0,
					},
					locked = {
						type = 'toggle',
						name = 'Locked',
						desc = function ()
									local output
									if Hekili.DB.profile.locked == true then
										output = 'Unlock the priority action buttons (presently locked).'
									else
										output = 'Lock this AddOn (presently unlocked).'
									end
									return output			
								end,
						set = 'SetOption',
						get = 'GetOption',
						order = 1,
					},
					verbose = {
						type = 'toggle',
						name = 'Verbose',
						desc = function ()
									local output
									if Hekili.DB.profile.verbose == true then
										output = 'Hide detailed status information for this AddOn (presently shown).'
									else
										output = 'Show detailed status information for this AddOn (presently hidden).'
									end
									return output			
								end,
						set = 'SetOption',
						get = 'GetOption',
						order = 2,
					},
					['Visibility Settings'] = {
						type = 'group',
						name = 'Visibility Settings',
						inline = true,
						order = 3,
						args = {
							['Visibility'] = {
								type = 'select',
								name = 'Visibility',
								values = {
									['Always Show']			= 'Always Show',
									['Show in Combat']		= 'Show in Combat',
									['Show with Target']	= 'Show with Target',
								},
								desc = 'Choose when the priority display(s) should be visible.',
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full',
							},
							['PvP Visibility'] = {
								type = 'toggle',
								name = 'Include BG/Arena',
								desc = function ()
											local output
											if Hekili.DB.profile['PvP Visibility'] then
												output = 'Hide the priority displays in arenas and battlegrounds (presently shown).'
											else
												output = 'Show the priority displays in arenas and battlegrounds (presently hidden).'
											end
											return output			
										end,
								set = 'SetOption',
								get = 'GetOption',
								order = 1
							}
						}
					},
					['Modules'] = {
						type = "group",
						name = "Module Settings",
						inline = true,
						order = 5,
						args = {
							['Module'] = {
								type = 'select',
								name = 'Module',
								values = function()
											local ptable = {}
											for k,v in pairs(Hekili.Modules) do
												if v.class == UnitClass("player") and v.spec == select(2, GetSpecializationInfo(GetSpecialization())) then
													ptable[k] = k
												end
											end
											ptable["(none)"] = "(none)"
											return ptable
										end,
								desc = 'Select the priority module for your current specialization profile.',
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full',
							},
						}
					},
					['Engine'] = {
						type = "group",
						name = "Engine Settings",
						inline = true,
						order = 6,
						args = {
							['Engine Description'] = {
								type	= 'description',
								name	= 'Set the frequency with which you want the addon to update your priority displays.  More frequent updates require more processor time (and can impact your frame rate); less frequent updates use less CPU, but may cause the display to be sluggish or to respond slowly to game events.  The default setting is 10 updates per second.',
								order	= 0
							},
							['Updates Per Second'] = {
								type	= 'range',
								name	= 'Updates Per Second',
								desc	= 'Set the number of times the addon should refresh its priority display each second.',
								min		= 4,
								max		= 10,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								width	= 'full',
								order	= 1
							}						
						}
					}
				}
			},
			['UI'] = {
				type = 'group',
				name = 'UI Settings',
				order = 1,
				args = {
					['Single Target Group'] = {
						type = 'group',
						name = 'Single Target Group',
						order = 0,
						args = {
							['Single Target Enabled'] = {
								type = 'toggle',
								name = 'Enable Single Target',
								desc = function ()
											local output
											if Hekili.DB.profile['Single Target Enabled'] == true then
												output = 'Disable Hekili for single-target rotation (presently enabled).'
											else
												output = 'Enable Hekili for single-target rotation (presently disabled).'
											end
											return output			
										end,
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full'
							},

							['Single Target Icons Displayed'] = {
								type	= 'range',
								name	= 'Icons Displayed',
								desc	= 'Set the number of icons to be displayed.',
								get		= 'GetOption',
								set		= 'SetOption',
								min		= 1,
								max		= 5,
								step	= 1,
								order	= 1,
							},
							['Multi-Target Integration'] = {
								type	= 'range',
								name	= 'Multi Integration',
								desc	= 'Use the multi-target priority in the Single Target display if this number of targets (or more) are detected (0 to disable).',
								min		= 0,
								max		= 10,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 2
							},
							['Single Target Queue Direction'] = {
								type	= "select",
								name	= 'Queue Direction',
								desc	= 'Set the direction in which single-target rotation buttons are displayed.',
								get		= 'GetOption',
								set		= 'SetOption',
								style	= 'dropdown',
								width	= 'full',
								order	= 3,
								values	= {
									RIGHT	= 'Right (L to R)',
									LEFT	= 'Left (R to L)',
								},
							},
							['Single Target Primary Icon Size'] = {
								type 	= 'range',
								name 	= 'Primary Icon Size',
								desc 	= 'Set the height and width of the primary icon.',
								min		= 25,
								max		= 250,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 4
							},
							['Single Target Icon Spacing'] = {
								type	= 'range',
								name	= 'Icon Spacing',
								desc	= 'Set the spacing between icons (if anchored).',
								min		= 0,
								max		= 100,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 5
							},
							['Single Target Queued Icon Size'] = {
								type	= 'range',
								name 	= 'Queued Icon Size',
								desc 	= 'Set the height and width of the queued ability icons.',
								min		= 25,
								max		= 250,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 6
							},
						},
					},
					['Multi-Target'] = {
						type = 'group',
						name = 'Multi-Target Group',
						order = 1,
						args = {
							['Multi-Target Enabled'] = {
								type = 'toggle',
								name = 'Enable Multi-Target',
								desc = function ()
											local output
											if Hekili.DB.profile['Single Target Enabled'] == true then
												output = 'Disable Hekili for single-target rotation (presently enabled).'
											else
												output = 'Enable Hekili for single-target rotation (presently disabled).'
											end
											return output			
										end,
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full'
							},
							['Multi-Target Cooldowns'] = {
								type	= 'toggle',
								name	= 'Allow Cooldowns',
								desc	= function ()
											local output
											if Hekili.DB.profile['Multi-Target Cooldowns'] == true then
												output = 'Disallow cooldowns from showing in the multi-target rotation when cooldowns are enabled (presently allowed).'
											else
												output = 'Allow cooldowns to show in the multi-target rotation when cooldowns are enabled (presently disallowed).'
											end
											return output			
										end,
								width	= 'full',
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1,
							},
							['Multi-Target Icons Displayed'] = {
								type	= 'range',
								name	= 'Icons Displayed',
								desc	= 'Set the number of icons to be displayed.',
								get		= 'GetOption',
								set		= 'SetOption',
								min		= 1,
								max		= 5,
								step	= 1,
								order	= 2,
							},
							['Multi-Target Illumination'] = {
								type	= 'range',
								name	= 'Icon Illumination',
								desc	= 'Set the number of targets required for the multi-target icon to light up (or 0 for never).',
								min		= 0,
								max		= 10,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 3
							},
							['Multi-Target Queue Direction'] = {
								type	= "select",
								name	= 'Queue Direction',
								desc	= 'Set the direction in which multi-target rotation buttons are displayed.',
								get		= 'GetOption',
								set		= 'SetOption',
								style	= 'dropdown',
								width	= 'full',
								order	= 4,
								values	= {
									RIGHT	= 'Right (L to R)',
									LEFT	= 'Left (R to L)',
								},
							},
							['Multi-Target Primary Icon Size'] = {
								type 	= 'range',
								name 	= 'Primary Icon Size',
								desc 	= 'Set the height and width of the primary icon.',
								min		= 25,
								max		= 250,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 5
							},
							['Multi-Target Icon Spacing'] = {
								type	= 'range',
								name	= 'Icon Spacing',
								desc	= 'Set the spacing between icons (if anchored).',
								min		= 0,
								max		= 100,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 6
							},
							['Multi-Target Queued Icon Size'] = {
								type	= 'range',
								name 	= 'Queued Icon Size',
								desc 	= 'Set the height and width of the queued ability icons.',
								min		= 25,
								max		= 250,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 7
							},
						},
					},
				},
			},
			['Filters'] = {
				type = 'group',
				name = 'Filters',
				order = 2,
				args = {
					['Cooldowns'] = {
						type = "group",
						name = "Cooldown Filters",
						inline = true,
						order = 0,
						args = {
							['Show Bloodlust'] = {
								type	= 'toggle',
								name	= 'Show Bloodlust',
								desc	= function () return OutputFlags( 'Show Bloodlust', 'bloodlust' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 0,
							},
							['Show Consumables'] = {
								type	= 'toggle',
								name	= 'Show Consumables',
								desc	= function () return OutputFlags( 'Show Consumables', 'consumable' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1,
							},
							['Show Professions'] = {
								type	= 'toggle',
								name	= 'Show Professions',
								desc	= function () return OutputFlags( 'Show Professions', 'profession' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 2,
							},
							['Show Racials'] = {
								type	= 'toggle',
								name	= 'Show Racials',
								desc	= function () return OutputFlags( 'Show Racials', 'racial' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 3,
							},
							['Cooldown Threshold'] = {
								type 	= 'range',
								name 	= 'Cooldown Threshold',
								desc 	= 'Set the maximum cooldown to be shown (to filter out longer abilities).',
								min		= 30,
								max		= 600,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 4,
								width	= 'double'
							},
						}
					},
					['General Filters'] = {
						type = "group",
						name = "General Filters",
						inline = true,
						order = 1,
						args = {
							['Cooldown Enabled'] = {
								type	= 'toggle',
								name	= 'Show Cooldowns',
								desc	= function ()
											local output
											if Hekili.DB.profile['Cooldown Enabled'] == true then
												output = 'Hide cooldowns from both rotations (presently enabled)'
											else
												output = 'Show cooldowns from both rotations (presently disabled).'
											end
											return output			
										end,
								cmdHidden	= true,
								set 		= 'SetOption',
								get 		= 'GetOption',
								order	 = 0,
							},

							['Show Hardcasts'] = {
								type	= 'toggle',
								name	= 'Show Hardcasts',
								desc 	= function ()
											local output
											if Hekili.DB.profile['Cooldown Enabled'] == true then
												output = 'Hide hardcasts from both rotations (presently shown)'
											else
												output = 'Hide hardcasts from both rotations (presently hidden).'
											end
											return output			
										end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1,
							},

							['Show Interrupts'] = {
								type	= 'toggle',
								name	= 'Show Interrupts',
								desc	= function () return OutputFlags( 'Show Interrupts', 'interrupt' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 2,
							},

							['Show Precombat'] = {
								type	= 'toggle',
								name	= 'Show Precombat',
								desc	= function () return OutputFlags( 'Show Precombat', 'precombat' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 3,
							},

							['Show Talents'] = {
								type	= 'toggle',
								name	= 'Show Talents',
								desc	= function () return OutputFlags( 'Show Talents', 'talent' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 4,
							},

							['Name Filter'] = {
								type	= 'input',
								name	= 'Name Filter',
								get		= 'GetOption',
								set		= 'SetOption',
								multiline = 5,
								desc	= 'Enter the ability names you wish to filter, separated by commas/spaces/returns.',
								order	= 5,
								width	= 'full'
							},
						}
					},
					['Hotkeys'] = {
						type = "group",
						name = "Key Bindings",
						inline = true,
						order = 2,
						args = {
							['Cooldown Hotkey'] = {
								type	= 'keybinding',
								name	= 'Toggle Cooldowns',
								desc	= 'Bind or unbind a hotkey to toggle cooldowns on/off.',
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 15,
							},

							['Hardcast Hotkey'] = {
								type	= 'keybinding',
								name	= 'Toggle Hardcasts',
								desc	= 'Bind or unbind a hotkey to toggle hardcasts on/off.',
								cmdHidden = true,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 16
							}
						}
					}
				}
			}		
		}
	}
	
	return Options
end


function Hekili:GetDefaults()
	local defaults = {
		profile = {
			enabled								= true,
			locked								= false,
			verbose								= false,

			['Updates Per Second']				= 10,

			['ST X']							= 0,
			['ST Y']							= 0,
			['ST Relative To']					= 'CENTER',
			['AE X']							= 0,
			['AE Y']							= -100,
			['AE Relative To']					= 'CENTER',
			['Module']							= 'Enhancement Shaman SimC 5.4.1',
			['Single Target Enabled']			= true,
			['Multi-Target Enabled']			= true,
			['Visibility']						= 'Always Show',
			['PvP Visibility']					= true,
			['Cooldown Enabled']				= false,
			['Cooldown Hotkey'] 				= '',
			['Single Target Group Enabled']		= true,
			['Single Target Icons Displayed']	= 5,
			['Multi-Target Integration']		= 0,
			['Single Target Queue Direction']	= 'RIGHT',
			['Single Target Primary Icon Size'] = 50,
			['Single Target Icon Spacing']		= 5,
			['Single Target Queued Icon Size']	= 40,
			['Multi-Target Group Enabled']		= true,
			['Multi-Target Cooldowns']			= false,
			['Multi-Target Icons Displayed']	= 2,
			['Multi-Target Illumination']		= 2,
			['Multi-Target Queue Direction']	= 'LEFT',
			['Multi-Target Primary Icon Size'] 	= 50,
			['Multi-Target Icon Spacing']		= 5,
			['Multi-Target Queued Icon Size']	= 40,
			['Show Talents']					= true,
			['Show Racials']					= false,
			['Show Interrupts']					= true,
			['Show Precombat']					= true,
			['Show Professions']				= false,
			['Show Bloodlust']					= false,
			['Show Consumables']				= false,
			['Show Hardcasts']					= true,
			['Hardcast Hotkey'] 				= '',
			['Cooldown Threshold']				= 300,
			['Name Filter']						= ''
		}
	}

	return defaults
end


function Hekili:ToggleEnable()
	if self.DB.profile.enabled then
		self.DB.profile.enabled = false
		Hekili:Disable()
	else
		self.DB.profile.enabled = true
		Hekili:Enable()
	end
end


function Hekili:ToggleCooldowns()
	self.DB.profile['Cooldown Enabled'] = not self.DB.profile['Cooldown Enabled']
	if self:IsVerbose() then self:Print("Option |cFF00FF00Cooldown Enabled|r set to |cFF00FF00" .. tostring(self.DB.profile['Cooldown Enabled']) .. "|r.") end
end


function Hekili:ToggleHardcasts()
	self.DB.profile['Show Hardcasts'] = not self.DB.profile['Show Hardcasts']
	if self:IsVerbose() then self:Print("Option |cFF00FF00Show Hardcasts|r set to |cFF00FF00" .. tostring(self.DB.profile['Show Hardcasts']) .. "|r.") end
end


function Hekili:SetOption(info, input)
	local opt = info[#info]
	local output = tostring(input)
	
	if (self:IsVerbose() or opt == "verbose") and info.type ~= 'range' and info.type ~= 'input' and info.type ~= 'keybinding' then
		self:Print('Option |cFF00FF00' .. opt .. '|r set to |cFF00FF00' .. output .. '|r.')
	end
	
	if (info.type ~= 'keybinding') then
		self.DB.profile[opt] = input
	end
	
	if opt == "enabled" then
		if output == "false" and self:IsEnabled() then
			self:Disable()
		elseif output == "true" and not self:IsEnabled() then
			self:Enable()
		end
		
	elseif opt == "locked" then
		self:LockAllButtons(input)

	elseif opt == 'Updates Per Second' then
		self.UI.Engine.Interval = (1.0 / input)

	elseif opt == 'Module' then
		if self.Modules[ self.DB.profile['Module'] ] then
			self.Active = self.Modules[ self.DB.profile['Module'] ]
		end
		self:SanityCheck()
		
	elseif opt == 'Single Target Enabled' then
		if input == false then
			for i = 1, 5 do
				self.UI.AButtons['ST'][i]:Hide()
			end
		end
		
	elseif opt == 'Multi-Target Enabled' then
		if input == false then
			for i = 1, 5 do
				self.UI.AButtons['AE'][i]:Hide()
			end
		end
		
	elseif opt == 'Cooldown Enabled' then
		-- ...

	elseif opt == 'Cooldown Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_COOLDOWNS"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_COOLDOWNS")
			self.DB.profile[opt] = input
		end

	elseif opt == 'Hardcast Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_HARDCASTS") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_HARDCASTS"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_HARDCASTS")
			self.DB.profile[opt] = input
		end
		
	elseif opt == 'Name Filter' then
		self.DB.profile[opt] = self:ApplyNameFilters( input )
		
	elseif opt == 'Single Target Queue Direction' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Primary Icon Size' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Icon Spacing' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Queued Icon Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Queue Direction' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Primary Icon Size' then
		self:RefreshUI()
				
	elseif opt == 'Multi-Target Queued Icon Size' then
		self:RefreshUI()
		
	elseif opt == 'Multi-Target Icon Spacing' then
		self:RefreshUI()

	end
end


function Hekili:GetOption(info)
	local opt = info[#info]
	
	if self.DB.profile[opt] ~= nil then
		return self.DB.profile[opt]
	else
		if Hekili:IsVerbose() then Hekili:Print("Error in GetOption(" .. opt .. "): no such option value.") end
		return nil
	end
end



function Hekili:ApplyNameFilters( input )
	local updatedFilter = ''
	local count = 0

	if not input then input = self.DB.profile[ 'Name Filter' ] end

	if self.Active and self.Active.spells then
		for k, v in pairs(self.Active.spells) do
			if input:find(k) then
				v.name = true
				count = count + 1
				
				if count == 1 then 					
					updatedFilter = k
				else
					updatedFilter = updatedFilter .. ', ' .. k
				end
			else
				v.name = nil
			end
		end
	end
	
	return updatedFilter
end
		
	

function Hekili:IsVerbose()
	return self.DB.profile['verbose']
end