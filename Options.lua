--	Options.lua
--	Insert clever description here.
--	Hekili @ Ner'zhul, 10/23/13

function OutputFlags( option, category )
	local output
	local abilities = ''
	local count = 0

	if Hekili.ActiveModule then
		for k,v in pairs(Hekili.ActiveModule.flags) do
			if v[category] then
				if count >= 1 then abilities = abilities .. ', ' end
				abilities = abilities .. k
				count = count + 1
			end
		end
	end

	if Hekili.DB.char[option] == true then
		output = 'Hide ' .. category .. ' abilities from the priority display (presently shown).'
	else
		output = 'Show ' .. category .. ' abilities from the priority display (presently hidden).'
	end

	if abilities ~= '' then
		output = output .. '\n|cFFFFD100Affects:|r ' .. abilities
	end

	return output			
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
									if self.DB.char.enabled == true then
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
									if self.DB.char.locked == true then
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
									if self.DB.char.verbose == true then
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
					['Visibility'] = {
						type = 'select',
						name = 'Visibility',
						values = {
							['Always Show']								= 'Always Show',
							['Always Show (except arenas/BGs)']			= 'Always Show (except arenas/BGs)',
							['Show with Target']						= 'Show with Target',
							['Show with Target (except arenas/BGs)']	= 'Show with Target (except arenas/BGs)'
						},
						desc = 'Choose when the AddOn should be visible.',
						cmdHidden = true,
						set = 'SetOption',
						get = 'GetOption',
						order = 3,
						width = 'full',
					},

					['Modules'] = {
						type = "group",
						name = "Module Settings",
						inline = true,
						order = 4,
						args = {
							['Primary Specialization Module'] = {
								type = 'select',
								name = 'Primary Specialization Module',
								values = function()
											local ptable = {}
											for k,_ in pairs(Hekili.Modules) do
												ptable[k] = k
											end
											ptable["(none)"] = "(none)"
											return ptable
										end,
								desc = 'Select the priority module for your primary specialization.',
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full',
							},

							['Secondary Specialization Module'] = {
								type = 'select',
								name = 'Secondary Specialization Module',
								values = function()
											local ptable = {}
											for k,_ in pairs(Hekili.Modules) do
												ptable[k] = k
											end
											ptable["(none)"] = "(none)"
											return ptable
										end,
								desc = 'Select the priority module for your secondary specialization.',
								cmdHidden = true,
								set = 'SetOption',
								get = 'GetOption',
								order = 1,
								width = 'full',
							},
							
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
											if self.DB.char['Single Target Enabled'] == true then
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
							['Single Target Queue Direction'] = {
								type	= "select",
								name	= 'Queue Direction',
								desc	= 'Set the direction in which single-target rotation buttons are displayed.',
								get		= 'GetOption',
								set		= 'SetOption',
								style	= 'dropdown',
								width	= 'full',
								order	= 2,
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
								order	= 3
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
								order	= 4
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
								order	= 5
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
											if self.DB.char['Single Target Enabled'] == true then
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
											if self.DB.char['Multi-Target Cooldowns'] == true then
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
						type	= 'header',
						name	= 'Cooldown Filters',
						order	= 0,
						width	= 'full',
					},
					['Show Bloodlust'] = {
						type	= 'toggle',
						name	= 'Show Bloodlust',
						desc	= function () return OutputFlags( 'Show Bloodlust', 'bloodlust' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 1,
					},
					['Show Consumables'] = {
						type	= 'toggle',
						name	= 'Show Consumables',
						desc	= function () return OutputFlags( 'Show Consumables', 'consumable' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 2,
					},
					['Show Professions'] = {
						type	= 'toggle',
						name	= 'Show Professions',
						desc	= function () return OutputFlags( 'Show Professions', 'profession' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 3,
					},
					['Show Racials'] = {
						type	= 'toggle',
						name	= 'Show Racials',
						desc	= function () return OutputFlags( 'Show Racials', 'racial' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 4,
					},
					['Show Talents'] = {
						type	= 'toggle',
						name	= 'Show Talents',
						desc	= function () return OutputFlags( 'Show Talents', 'talent' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 5,
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
						order	= 6
					},
					['General Filters'] = {
						type	= 'header',
						name	= 'General Filters',
						order	= 7
					},
					['General Filter Description'] = {
						type	= 'description',
						name	= 'Filtering in this subsection applies to all categories (cooldowns, multi-target, and single target).',
						order	= 8
					},

					['Cooldown Enabled'] = {
						type = 'toggle',
						name = 'Show Cooldowns',
						desc = function ()
									local output
									if self.DB.char['Cooldown Enabled'] == true then
										output = 'Hide cooldowns from both rotations (presently enabled)'
									else
										output = 'Show cooldowns from both rotations (presently disabled).'
									end
									return output			
								end,
						cmdHidden = true,
						set = 'SetOption',
						get = function() return GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") end,
						order = 9,
					},

					['Show Hardcasts'] = {
						type	= 'toggle',
						name	= 'Show Hardcasts',
						desc = function ()
									local output
									if self.DB.char['Cooldown Enabled'] == true then
										output = 'Hide hardcasts from both rotations (presently shown)'
									else
										output = 'Hide hardcasts from both rotations (presently hidden).'
									end
									return output			
								end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 10,
					},

					['Show Interrupts'] = {
						type	= 'toggle',
						name	= 'Show Interrupts',
						desc	= function () return OutputFlags( 'Show Interrupts', 'interrupt' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 11,
					},

					['Show Precombat'] = {
						type	= 'toggle',
						name	= 'Show Precombat',
						desc	= function () return OutputFlags( 'Show Precombat', 'precombat' ) end,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 12,
					},
					
					['Name Filter'] = {
						type	= 'input',
						name	= 'Name Filter',
						get		= 'GetOption',
						set		= 'SetOption',
						multiline = 5,
						desc	= 'Enter the ability names you wish to filter, separated by commas/spaces/returns.',
						order	= 13,
						width	= 'full'
					},

					['Hotkeys'] = {
						type	= 'header',
						name	= 'Hotkeys',
						order	= 14
					},

					['Cooldown Hotkey'] = {
						type	= 'keybinding',
						name	= 'Cooldown Hotkey',
						desc	= 'Bind or unbind a hotkey to toggle cooldowns on/off.',
						cmdHidden = true,
						set = 'SetOption',
						get = 'GetOption',
						order = 15,
					},

					['Hardcast Hotkey'] = {
						type	= 'keybinding',
						name	= 'Hardcast Hotkey',
						desc	= 'Bind or unbind a hotkey to toggle hardcasts on/off.',
						cmdHidden = true,
						set		= 'SetOption',
						get		= 'GetOption',
						order	= 16
					}
				},
			},					
		},
	}

	return Options
end


function Hekili:GetDefaults()
	local defaults = {
		char = {
			enabled = true,
			locked = false,
			verbose = true,
			['ST X'] = 0,
			['ST Y'] = 0,
			['ST Relative To'] = 'CENTER',
			['AE X'] = 0,
			['AE Y'] = -100,
			['AE Relative To'] = 'CENTER',
			['Primary Specialization Module']	= 'Enhancement Shaman SimC 5.4.1',
			['Secondary Specialization Module']	= 'Enhancement Shaman SimC 5.4.1',
			['Single Target Enabled']			= true,
			['Multi-Target Enabled']			= true,
			['Visibility']						= 'Always Show',
			['Cooldown Enabled']				= false,
			['Cooldown Hotkey'] 				= '',
			['Single Target Group Enabled']		= true,
			['Single Target Icons Displayed']	= 5,
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
		},
		profile = {
			['CD Talents']						= true,
			['CD Racials']						= false,
			['CD Interrupts']					= true,
			['CD Precombat']					= true,
			['CD Professions']					= false,
			['CD Bloodlust']					= false,
			['CD Consumables']					= false,
			['CD Threshold']					= 180
		}
	}

	return defaults
end


function Hekili:ToggleEnable()
	if self.DB.char.enabled then
		Hekili.DB.char.enabled = false
		Hekili:Disable()
	else
		Hekili.DB.char.enabled = true
		Hekili:Enable()
	end
end


function Hekili:ToggleCooldowns()
	Hekili.DB.char['Cooldown Enabled'] = not Hekili.DB.char['Cooldown Enabled']
	if self:IsVerbose() then self:Print("Option |cFF00FF00Cooldown Enabled|r set to |cFF00FF00" .. tostring(self.DB.char['Cooldown Enabled']) .. "|r.") end
end


function Hekili:ToggleHardcasts()
	Hekili.DB.char['Show Hardcasts'] = not Hekili.DB.char['Show Hardcasts']
	if self:IsVerbose() then self:Print("Option |cFF00FF00Show Hardcasts|r set to |cFF00FF00" .. tostring(self.DB.char['Show Hardcasts']) .. "|r.") end
end


function Hekili:SetOption(info, input)
	local opt = info[#info]
	local output = tostring(input)
	
	if (self:IsVerbose() or opt == "verbose") and info.type ~= 'range' and info.type ~= 'input' and info.type ~= 'keybinding' then
		self:Print('Option |cFF00FF00' .. opt .. '|r set to |cFF00FF00' .. output .. '|r.')
	end
	
	if (info.type ~= 'keybinding') then
		self.DB.char[opt] = input
	end
	
	if opt == "enabled" then
		if output == "false" and self:IsEnabled() then
			self:Disable()
		elseif output == "true" and not self:IsEnabled() then
			self:Enable()
		end
		
	elseif opt == "locked" then
		self:LockAllButtons(input)

	elseif opt == 'Primary Specialization Module' then
		if GetActiveSpecGroup() == 1 and self.Modules[ self.DB.char['Primary Specialization Module'] ] then
			self.ActiveModule = self.Modules[ self.DB.char['Primary Specialization Module'] ]
		end
		self:SanityCheck()
		
	elseif opt == 'Secondary Specialization Module' then
		if GetActiveSpecGroup() == 2 and self.Modules[ self.DB.char['Secondary Specialization Module'] ] then
			self.ActiveModule = self.Modules[ self.DB.char['Secondary Specialization Module'] ]
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
		if self.DB.char[opt] ~= '' then
			self.DB.char[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_COOLDOWNS"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_COOLDOWNS")
			self.DB.char[opt] = input
		end

	elseif opt == 'Hardcast Hotkey' then
		-- Clear the old binding.
		if self.DB.char[opt] ~= '' then
			self.DB.char[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_HARDCASTS") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_HARDCASTS"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_HARDCASTS")
			self.DB.char[opt] = input
		end
		
	elseif opt == 'Single Target Queue Direction' then
		for i = 2, 5 do
			self.UI.AButtons.ST[i]:ClearAllPoints()
			if input == 'RIGHT' then
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[ input ], self.UI.AButtons.ST[i-1], input, self.DB.char['Single Target Icon Spacing'], 0)
			else
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[ input ], self.UI.AButtons.ST[i-1], input, -1 * self.DB.char['Single Target Icon Spacing'], 0)
			end
		end
		
	elseif opt == 'Single Target Primary Icon Size' then
		self.UI.AButtons.ST[1]:ClearAllPoints()
		self.UI.AButtons.ST[1]:SetPoint(self.DB.char['ST Relative To'], self.DB.char['ST X'], self.DB.char['ST Y'])
		self.UI.AButtons.ST[1]:SetWidth(input)
		self.UI.AButtons.ST[1]:SetHeight(input)
		self.UI.AButtons.ST[1].topText:SetSize(input, input / 2)
		self.UI.AButtons.ST[1].btmText:SetSize(input, input / 2)
		
		if self.LBF then
			self.stGroup:ReSkin()
		end
		
	elseif opt == 'Single Target Icon Spacing' then
		for i = 2, 5 do
			self.UI.AButtons.ST[i]:ClearAllPoints()
			if self.DB.char['Single Target Queue Direction'] == 'RIGHT' then
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[self.DB.char['Single Target Queue Direction']], self.UI.AButtons.ST[i-1], self.DB.char['Single Target Queue Direction'], self.DB.char['Single Target Icon Spacing'], 0)
			else
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[self.DB.char['Single Target Queue Direction']], self.UI.AButtons.ST[i-1], self.DB.char['Single Target Queue Direction'], -1 * self.DB.char['Single Target Icon Spacing'], 0)
			end
		end
		
	elseif opt == 'Single Target Queued Icon Size' then
		for i = 2, 5 do
			if self.DB.char['Single Target Queue Direction'] == 'RIGHT' then
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[self.DB.char['Single Target Queue Direction']], self.UI.AButtons.ST[i-1], self.DB.char['Single Target Queue Direction'], self.DB.char['Single Target Icon Spacing'], 0)
			else
				self.UI.AButtons.ST[i]:SetPoint(self.invDirection[self.DB.char['Single Target Queue Direction']], self.UI.AButtons.ST[i-1], self.DB.char['Single Target Queue Direction'], -1 * self.DB.char['Single Target Icon Spacing'], 0)
			end
			self.UI.AButtons.ST[i]:SetWidth(input)
			self.UI.AButtons.ST[i]:SetHeight(input)
			self.UI.AButtons.ST[i].topText:SetSize(input, input / 2)
			self.UI.AButtons.ST[i].btmText:SetSize(input, input / 2)
		end

		if self.LBF then
			self.stGroup:ReSkin()
		end

	elseif opt == 'Multi-Target Queue Direction' then
		for i = 2, 5 do
			Hekili.UI.AButtons.AE[i]:ClearAllPoints()
			if input == 'RIGHT' then
				Hekili.UI.AButtons.AE[i]:SetPoint(Hekili.invDirection[ input ], Hekili.UI.AButtons.AE[i-1], input, self.DB.char['Multi-Target Icon Spacing'], 0)
			else
				Hekili.UI.AButtons.AE[i]:SetPoint(Hekili.invDirection[ input ], Hekili.UI.AButtons.AE[i-1], input, -1 * self.DB.char['Multi-Target Icon Spacing'], 0)
			end
		end

	elseif opt == 'Multi-Target Primary Icon Size' then
		Hekili.UI.AButtons.AE[1]:ClearAllPoints()
		Hekili.UI.AButtons.AE[1]:SetPoint(self.DB.char['AE Relative To'], self.DB.char['AE X'], self.DB.char['AE Y'])
		Hekili.UI.AButtons.AE[1]:SetWidth(input)
		Hekili.UI.AButtons.AE[1]:SetHeight(input)
		self.UI.AButtons.AE[i].topText:SetSize(input, input / 2)
		self.UI.AButtons.AE[i].btmText:SetSize(input, input / 2)
		
		if self.LBF then
			self.aeGroup:ReSkin()
		end
				
	elseif opt == 'Multi-Target Queued Icon Size' then
		for i = 2, 5 do
			self.UI.AButtons.AE[i]:ClearAllPoints()
			if self.DB.char['Multi-Target Queue Direction'] == 'RIGHT' then
				self.UI.AButtons.AE[i]:SetPoint(self.invDirection[self.DB.char['Multi-Target Queue Direction']], self.UI.AButtons.AE[i-1], self.DB.char['Multi-Target Queue Direction'], self.DB.char['Multi-Target Icon Spacing'], 0)
			else
				self.UI.AButtons.AE[i]:SetPoint(self.invDirection[self.DB.char['Multi-Target Queue Direction']], self.UI.AButtons.AE[i-1], self.DB.char['Multi-Target Queue Direction'], -1 * self.DB.char['Multi-Target Icon Spacing'], 0)
			end
			self.UI.AButtons.AE[i]:SetWidth(input)
			self.UI.AButtons.AE[i]:SetHeight(input)
			self.UI.AButtons.AE[i].topText:SetSize(input, input / 2)
			self.UI.AButtons.AE[i].btmText:SetSize(input, input / 2)
		end

		if self.LBF then
			self.aeGroup:ReSkin()
		end
		
	elseif opt == 'Multi-Target Icon Spacing' then
		for i = 2, 5 do
			self.UI.AButtons.AE[i]:ClearAllPoints()
			if self.DB.char['Multi-Target Queue Direction'] == 'RIGHT' then
				self.UI.AButtons.AE[i]:SetPoint(self.invDirection[self.DB.char['Multi-Target Queue Direction']], self.UI.AButtons.AE[i-1], self.DB.char['Multi-Target Queue Direction'], self.DB.char['Multi-Target Icon Spacing'], 0)
			else
				self.UI.AButtons.AE[i]:SetPoint(self.invDirection[self.DB.char['Multi-Target Queue Direction']], self.UI.AButtons.AE[i-1], self.DB.char['Multi-Target Queue Direction'], -1 * self.DB.char['Multi-Target Icon Spacing'], 0)
			end
		end

	end
end


function Hekili:GetOption(info)
	local opt = info[#info]
	
	if self.DB.char[opt] ~= nil then
		return self.DB.char[opt]
	else
		if Hekili:IsVerbose() then Hekili:Print("Error in GetOption(" .. opt .. "): no such option value.") end
		return nil
	end
end


function Hekili:IsVerbose()
	return self.DB.char['verbose']
end