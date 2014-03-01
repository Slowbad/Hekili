--	Options.lua
--	Insert clever description here.
--	Hekili @ Ner'zhul, 10/23/13

local L = LibStub("AceLocale-3.0"):GetLocale("Hekili")

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
		output = string.format(L["Hide %s abilities from the priority display (presently shown)."], category)
	else
		output = string.format(L["Show %s abilities from the priority display (presently hidden)."], category)
	end

	if abilities ~= '' then
		output = output .. '\n|cFFFFD100' .. L["Affects"] .. ':|r ' .. abilities
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
				name = L["Basic Settings"],
				childGroups = 'tree',
				order = 0,
				args = {
					enabled = {
						type = 'toggle',
						name = L["Enabled"],
						set = 'SetOption',
						get = 'GetOption',
						order = 0,
					},
					locked = {
						type = 'toggle',
						name = L["Locked"],
						set = 'SetOption',
						get = 'GetOption',
						order = 1,
					},
					verbose = {
						type = 'toggle',
						name = L["Verbose"],
						set = 'SetOption',
						get = 'GetOption',
						order = 2,
					},
					['Visibility Settings'] = {
						type = 'group',
						name = L["Visibility Settings"],
						inline = true,
						order = 3,
						args = {
							['Visibility'] = {
								type = 'select',
								name = L["Visibility"],
								values = {
									['Always Show']			= L["Always Show"],
									['Show in Combat']		= L["Show in Combat"],
									['Show with Target']	= L["Show with Target"],
								},
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full',
							},
							['PvP Visibility'] = {
								type = 'toggle',
								name = L["Include BG and Arenas"],
								set = 'SetOption',
								get = 'GetOption',
								order = 1
							}
						}
					},
					['Modules'] = {
						type = "group",
						name = L["Module Settings"],
						inline = true,
						order = 5,
						args = {
							['Module'] = {
								type = 'select',
								name = L["Module"],
								values = function()
											local ptable = {}
											for k,v in pairs(Hekili.Modules) do
												--if v.spec == GetSpecializationInfo(GetSpecialization()) then
													ptable[k] = v.name
												--end
											end
											-- ptable["None"] = L["None"]
											return ptable
										end,
								set = 'SetOption',
								get = 'GetOption',
								order = 0,
								width = 'full',
							},
							['Load Trackers'] = {
									type = 'execute',
									name = L["Load Module Trackers"],
									desc = L["Load Module Trackers Description"],
									func = function()
												local num = 1
												for k,v in pairs(Hekili.Active.trackers) do
													self.DB.profile['Tracker '..num..' Type']			= v.type
													self.DB.profile['Tracker '..num..' Caption']		= v.caption
													self.DB.profile['Tracker '..num..' Show']			= v.show
													self.DB.profile['Tracker '..num..' Timer']			= v.timer
													
													if v.type == 'Aura' then
														self.DB.profile['Tracker '..num..' Aura']		= v.aura
														self.DB.profile['Tracker '..num..' Unit']		= v.unit
													elseif v.type == 'Cooldown' then
														self.DB.profile['Tracker '..num..' Ability']	= v.ability
													elseif v.type == 'Totem' then
														self.DB.profile['Tracker '..num..' Element']	= v.element
														self.DB.profile['Tracker '..num..' Totem Name']	= v.ttmName
													end
													num = num + 1
												end
												
												for num = num, 5 do
													self.DB.profile['Tracker '..num..' Type'] = 'None'
												end
											end,
									order = 1
							},
						}
					},
					['Counter'] = {
						type = "group",
						name = L["Target Count"],
						inline = true,
						order = 5,
						args = {
							['Delay Description'] = {
								type	= 'description',
								name	= L["Target Count Delay Description"],
								order	= 0
							},
							['Grace Period'] = {
								type	= 'range',
								name	= L["Grace Period"],
								min		= 4,
								max		= 10,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								width	= 'full',
								order	= 1
							}						
						}
					},
					['Engine'] = {
						type = "group",
						name = L["Engine Settings"],
						inline = true,
						order = 6,
						args = {
							['Engine Description'] = {
								type	= 'description',
								name	= L["Engine Description"],
								order	= 0
							},
							['Updates Per Second'] = {
								type	= 'range',
								name	= L["Updates Per Second"],
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
				name = L["UI Settings"],
				order = 1,
				args = {
					['Global'] = {
						type = 'group',
						name = L["Globals"],
						order = 0,
						args = {
							['Global Warning'] = { -- that's kinda funny
								type = 'description',
								name = L["Global Warning"],
								order = 0
							},
							['Global Font'] = {
								type			= 'select',
								dialogControl	= 'LSM30_Font', --Select your widget here
								name			= L["Font"],
								values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
								get				= 'GetOption',
								set				= 'SetOption',
								width			= 'full',
								order			= 1
							},
							['Global Icon Size'] = {
								type 	= 'range',
								name 	= L["Icon Size"],
								min		= 25,
								max		= 250,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 2
							},
							['Global Font Size'] = {
								type	= 'range',
								name 	= L["Font Size"],
								min		= 6,
								max		= 26,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 3
							},
						},
					},
					['Single Target Group'] = {
						type = 'group',
						name = L["Single Target Group"],
						order = 1,
						args = {
							['ST Priority'] = {
								type = 'group',
								name = L["Single Target Priority"],
								inline = true,
								order = 0,
								args = {
									['Single Target Enabled'] = {
										type = 'toggle',
										name = L["Enable Single Target"],
										set = 'SetOption',
										get = 'GetOption',
										order = 0,
									},
									['Integration Enabled'] = {
										type = 'toggle',
										name = L["Enable Integration"],
										desc = L["Integration Description"],
										set = 'SetOption',
										get = 'GetOption',
										order = 2,
									},
									['Single Target Icons Displayed'] = {
										type	= 'range',
										name	= L["Icons Displayed"],
										get		= 'GetOption',
										set		= 'SetOption',
										min		= 1,
										max		= 5,
										step	= 1,
										order	= 1,
									},
									['Multi-Target Integration'] = {
										type	= 'range',
										name	= L["Multi Integration"],
										desc	= L["Multi Integration Description"],
										min		= 2,
										max		= 10,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 3
									},
									['Single Target Queue Direction'] = {
										type	= "select",
										name	= L["Queue Direction"],
										get		= 'GetOption',
										set		= 'SetOption',
										style	= 'dropdown',
										width	= 'full',
										order	= 4,
										values	= {
											RIGHT	= L["Left to Right"],
											LEFT	= L["Right to Left"],
										},
									},
								},
							},
							['ST Caption'] = {
								type = 'group',
								name = L["Captions"],
								inline = true,
								order = 1,
								args = {
									['Single Target Greentext'] = {
										type	= 'toggle',
										name	= L["Show Prediction Times"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0,
									},
									['Single Target Captions'] = {
										type	= 'toggle',
										name	= L["Show Action Captions"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 1,
									},
									['Single Target Tracker'] = {
										type	= 'select',
										name	= L["Primary Caption"],
										desc	= L["Primary Caption Description"],
										values	= function ()
														local options = {}

														options['None'] = L["Primary Caption Default"]

														if Hekili.Active then
															for k,v in pairs(Hekili.Active.trackers) do
																if v.override then
																	options[k] = k
																end
															end
														end

														return options
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 2,
										width	= 'full'
									},
								},
							},
							['ST Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 2,
								args = {
									['Single Target Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 0
									},
									['Single Target Primary Icon Size'] = {
										type 	= 'range',
										name 	= L["Primary Icon Size"],
										min		= 25,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 1
									},
									['Single Target Primary Font Size'] = {
										type	= 'range',
										name 	= L["Primary Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 2
									},
									['Single Target Queued Icon Size'] = {
										type	= 'range',
										name 	= L["Queued Icon Size"],
										min		= 25,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 3
									},
									['Single Target Queued Font Size'] = {
										type	= 'range',
										name 	= L["Queued Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 4
									},
									['Single Target Icon Spacing'] = {
										type	= 'range',
										name	= L["Icon Spacing"],
										min		= 0,
										max		= 100,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 5
									},
								},
							},
						},
					},
					['Multi-Target'] = {
						type = 'group',
						name = L["Multi-Target Group"],
						order = 2,
						args = {
							['MT Priority'] = {
								type = 'group',
								name = L["Multi-Target Priority"],
								inline = true,
								order = 0,
								args = {
									['Multi-Target Enabled'] = {
										type = 'toggle',
										name = L["Enable Multi-Target"],
										set = 'SetOption',
										get = 'GetOption',
										order = 0,
									},
									['Multi-Target Icons Displayed'] = {
										type	= 'range',
										name	= L["Icons Displayed"],
										get		= 'GetOption',
										set		= 'SetOption',
										min		= 1,
										max		= 5,
										step	= 1,
										order	= 1,
									},
									['Multi-Target Cooldowns'] = {
										type	= 'toggle',
										name	= L["Allow Cooldowns"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 2,
									},
									['Multi-Target Illumination'] = {
										type	= 'range',
										name	= L["Icon Illumination"],
										desc	= L["Icon Illumination Description"],
										min		= 0,
										max		= 10,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 3
									},
									['Multi-Target Queue Direction'] = {
										type	= "select",
										name	= L["Queue Direction"],
										get		= 'GetOption',
										set		= 'SetOption',
										style	= 'dropdown',
										width	= 'full',
										order	= 4,
										values	= {
											RIGHT	= L["Left to Right"],
											LEFT	= L["Right to Left"],
										},
									},
								},
							},
							['MT Caption'] = {
								type = 'group',
								name = L["Captions"],
								inline = true,
								order = 1,
								args = {
									['Multi-Target Greentext'] = {
										type	= 'toggle',
										name	= L["Show Prediction Times"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0,
									},
									['Multi-Target Captions'] = {
										type	= 'toggle',
										name	= L["Show Action Captions"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 1,
									},
								},
							},
							['MT Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 2,
								args = {
									['Multi-Target Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Multi-Target Primary Icon Size'] = {
										type 	= 'range',
										name 	= L["Primary Icon Size"],
										min		= 25,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6
									},
									['Multi-Target Primary Font Size'] = {
										type	= 'range',
										name 	= L["Primary Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
									['Multi-Target Queued Icon Size'] = {
										type	= 'range',
										name 	= L["Queued Icon Size"],
										min		= 25,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 8
									},
									['Multi-Target Queued Font Size'] = {
										type	= 'range',
										name 	= L["Queued Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 9
									},
									['Multi-Target Icon Spacing'] = {
										type	= 'range',
										name	= L["Icon Spacing"],
										min		= 0,
										max		= 100,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 10
									},
								},
							},
						},
					},
					['Tracker Icon #1'] = {
						type = 'group',
						name = L["Tracker Icon #1"],
						order = 3,
						args = {
							['T1 Config'] = {
								type = 'group',
								name = L["Tracker"],
								inline = true,
								order = 0,
								args = {
									['Tracker 1 Type'] = {
										type	= 'select',
										name	= L["Type"],
										values	= {
											['None']		= L["None"],
											['Cooldown']	= L["Cooldown"],
											['Aura']		= L["Aura"],
											['Totem']		= L["Totem"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0
									},


									['Tracker 1 Custom'] = {
										type	= 'header',
										name	= function()
														if self.DB.profile['Tracker 1 Type'] == 'None' then
															return L["Tracker Disabled"]
														end
														return self.DB.profile['Tracker 1 Type'] .. ' ' .. L["Settings"]
													end,	
										order	= 1
									},
									
									
									-- None
									['Tracker 1 None'] = {
										type	= 'description',
										name	= L["Tracker None Description"],
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'None' then
															return false
														end
														return true
													end,
									},


									-- Aura
									['Tracker 1 Aura'] = {
										type	= 'input',
										name	= L["Aura"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif GetSpellInfo(val) then return true
														else
															local err = string.format(L["Tracker Aura Error"], L["ERROR"], val)
															Hekili:Print(err)
															return err
														end
														return true
													end,
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 1 Unit'] = {
										type	= 'select',
										name	= L["Unit"],
										values	= {
											['focus']	= L["Focus"],
											['player']	= L["Player"],
											['target']	= L["Target"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 3
									},


									-- Totem
									['Tracker 1 Totem Name'] = {
										type	= 'input',
										name	= L["Totem"],
										desc	= L["Totem Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Totem' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 1 Element'] = {
										type	= 'select',
										name	= L["Element"],
										values	= {
											['fire']	= 'Fire',
											['earth']	= 'Earth',
											['water']	= 'Water',
											['air']		= 'Air'
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 3,
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},


									-- Cooldown
									['Tracker 1 Ability'] = {
										type	= 'input',
										name	= L["Ability"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif IsUsableSpell(val) then return true
														else
															local err = string.format(L["Tracker Ability Error"], L["ERROR"], val)
															self:Print(err)
															return err
														end
													end,
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Cooldown' then
															return false
														end
														return true
													end,
									},	
											
									
									['Tracker 1 Visibility'] = {
										type	= 'header',
										name	= 'Display Settings',
										order	= 4
									},
									
									
									-- Caption Options
									['Tracker 1 Caption'] = {
										type	= 'select',
										name	= L["Caption"],
										desc	= function()
														local output = L["Caption Description"]
														
														if self.DB.profile['Tracker 1 Type'] == 'Aura' then
															output = output .. '  ' .. L["Caption Description Aura"]

															if self.Active then
																local numWatched = 0

																for k,_ in pairs(self.Active:Watchlist()) do
																	if numWatched == 0 then
																		output = output .. '\n|cFFFFD100' .. L["Watched Spells"] .. ':|r ' .. k
																		numWatched = numWatched + 1
																	else
																		output = output .. ', ' .. k
																	end
																end
															end
														end

														return output
													end,
										values	= {
											['None']	= L["None"],
											['Stacks']	= L["Stacks"],
											['Targets']	= L["Targets"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Totem' then
															return true
														end
														return false
													end,
									},
									['Tracker 1 Totem Caption'] = {
										type	= 'select',
										name	= L['Caption'],
										desc	= L["Caption Description"],
										values	= {
											['None']	= L["None"],
											['Targets']	= L["Targets"],
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 1 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},
									
									
									['Tracker 1 Show'] = {
										type	= 'select',
										name	= L['Show'],
										values	= function ()
														if self.DB.profile['Tracker 1 Type'] == 'Cooldown' then
															return {	['Absent']		= L['Unusable'],
																		['Present']		= L['Usable'],
																		['Show Always']	= L['Always'] }
														else
															return {	['Absent']		= L['Absent'],
																		['Present']		= L['Present'],
																		['Show Always'] = L['Always'] }
														end
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 6,
									},
									
									['Tracker 1 Timer'] = {
										type	= 'toggle',
										name	= L['Show Timer'],
										desc	= L["Show Timer Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 7
									}
								}
							},
							['T1 Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 1,
								args = {
									['Tracker 1 Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Tracker 1 Size'] = {
										type	= 'range',
										name 	= L["Icon Size"],
										min		= 20,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6 
									},
									['Tracker 1 Font Size'] = {
										type	= 'range',
										name 	= L["Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
								},
							},
						},
					},
					['Tracker Icon #2'] = {
						type = 'group',
						name = L["Tracker Icon #2"],
						order = 4,
						args = {
							['T2 Config'] = {
								type = 'group',
								name = L["Tracker"],
								inline = true,
								order = 0,
								args = {
									['Tracker 2 Type'] = {
										type	= 'select',
										name	= L["Type"],
										values	= {
											['None']		= L["None"],
											['Cooldown']	= L["Cooldown"],
											['Aura']		= L["Aura"],
											['Totem']		= L["Totem"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0
									},


									['Tracker 2 Custom'] = {
										type	= 'header',
										name	= function()
														if self.DB.profile['Tracker 2 Type'] == 'None' then
															return L["Tracker Disabled"]
														end
														return self.DB.profile['Tracker 2 Type'] .. ' ' .. L["Settings"]
													end,	
										order	= 1
									},
									
									
									-- None
									['Tracker 2 None'] = {
										type	= 'description',
										name	= L["Tracker None Description"],
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'None' then
															return false
														end
														return true
													end,
									},


									-- Aura
									['Tracker 2 Aura'] = {
										type	= 'input',
										name	= L["Aura"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif GetSpellInfo(val) then return true
														else
															local err = string.format(L["Tracker Aura Error"], L["ERROR"], val)
															Hekili:Print(err)
															return err
														end
														return true
													end,
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 2 Unit'] = {
										type	= 'select',
										name	= L["Unit"],
										values	= {
											['focus']	= L["Focus"],
											['player']	= L["Player"],
											['target']	= L["Target"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 3
									},


									-- Totem
									['Tracker 2 Totem Name'] = {
										type	= 'input',
										name	= L["Totem"],
										desc	= L["Totem Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Totem' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 2 Element'] = {
										type	= 'select',
										name	= L["Element"],
										values	= {
											['fire']	= 'Fire',
											['earth']	= 'Earth',
											['water']	= 'Water',
											['air']		= 'Air'
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 3,
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},


									-- Cooldown
									['Tracker 2 Ability'] = {
										type	= 'input',
										name	= L["Ability"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif IsUsableSpell(val) then return true
														else
															local err = string.format(L["Tracker Ability Error"], L["ERROR"], val)
															self:Print(err)
															return err
														end
													end,
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Cooldown' then
															return false
														end
														return true
													end,
									},	
											
									
									['Tracker 2 Visibility'] = {
										type	= 'header',
										name	= 'Display Settings',
										order	= 4
									},
									
									
									-- Caption Options
									['Tracker 2 Caption'] = {
										type	= 'select',
										name	= L["Caption"],
										desc	= function()
														local output = L["Caption Description"]
														
														if self.DB.profile['Tracker 2 Type'] == 'Aura' then
															output = output .. '  ' .. L["Caption Description Aura"]

															if self.Active then
																local numWatched = 0

																for k,_ in pairs(self.Active:Watchlist()) do
																	if numWatched == 0 then
																		output = output .. '\n|cFFFFD100' .. L["Watched Spells"] .. ':|r ' .. k
																		numWatched = numWatched + 1
																	else
																		output = output .. ', ' .. k
																	end
																end
															end
														end

														return output
													end,
										values	= {
											['None']	= L["None"],
											['Stacks']	= L["Stacks"],
											['Targets']	= L["Targets"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Totem' then
															return true
														end
														return false
													end,
									},
									['Tracker 2 Totem Caption'] = {
										type	= 'select',
										name	= L['Caption'],
										desc	= L["Caption Description"],
										values	= {
											['None']	= L["None"],
											['Targets']	= L["Targets"],
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 2 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},
									
									
									['Tracker 2 Show'] = {
										type	= 'select',
										name	= L['Show'],
										values	= function ()
														if self.DB.profile['Tracker 2 Type'] == 'Cooldown' then
															return {	['Absent']		= L['Unusable'],
																		['Present']		= L['Usable'],
																		['Show Always']	= L['Always'] }
														else
															return {	['Absent']		= L['Absent'],
																		['Present']		= L['Present'],
																		['Show Always'] = L['Always'] }
														end
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 6,
									},
									
									['Tracker 2 Timer'] = {
										type	= 'toggle',
										name	= L['Show Timer'],
										desc	= L["Show Timer Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 7
									}
								}
							},
							['T2 Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 1,
								args = {
									['Tracker 2 Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Tracker 2 Size'] = {
										type	= 'range',
										name 	= L["Icon Size"],
										min		= 20,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6 
									},
									['Tracker 2 Font Size'] = {
										type	= 'range',
										name 	= L["Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
								},
							},
						},
					},
					['Tracker Icon #3'] = {
						type = 'group',
						name = L["Tracker Icon #3"],
						order = 5,
						args = {
							['T3 Config'] = {
								type = 'group',
								name = L["Tracker"],
								inline = true,
								order = 0,
								args = {
									['Tracker 3 Type'] = {
										type	= 'select',
										name	= L["Type"],
										values	= {
											['None']		= L["None"],
											['Cooldown']	= L["Cooldown"],
											['Aura']		= L["Aura"],
											['Totem']		= L["Totem"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0
									},


									['Tracker 3 Custom'] = {
										type	= 'header',
										name	= function()
														if self.DB.profile['Tracker 3 Type'] == 'None' then
															return L["Tracker Disabled"]
														end
														return self.DB.profile['Tracker 3 Type'] .. ' ' .. L["Settings"]
													end,	
										order	= 1
									},
									
									
									-- None
									['Tracker 3 None'] = {
										type	= 'description',
										name	= L["Tracker None Description"],
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'None' then
															return false
														end
														return true
													end,
									},


									-- Aura
									['Tracker 3 Aura'] = {
										type	= 'input',
										name	= L["Aura"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif GetSpellInfo(val) then return true
														else
															local err = string.format(L["Tracker Aura Error"], L["ERROR"], val)
															Hekili:Print(err)
															return err
														end
														return true
													end,
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 3 Unit'] = {
										type	= 'select',
										name	= L["Unit"],
										values	= {
											['focus']	= L["Focus"],
											['player']	= L["Player"],
											['target']	= L["Target"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 3
									},


									-- Totem
									['Tracker 3 Totem Name'] = {
										type	= 'input',
										name	= L["Totem"],
										desc	= L["Totem Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Totem' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 3 Element'] = {
										type	= 'select',
										name	= L["Element"],
										values	= {
											['fire']	= 'Fire',
											['earth']	= 'Earth',
											['water']	= 'Water',
											['air']		= 'Air'
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 3,
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},


									-- Cooldown
									['Tracker 3 Ability'] = {
										type	= 'input',
										name	= L["Ability"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif IsUsableSpell(val) then return true
														else
															local err = string.format(L["Tracker Ability Error"], L["ERROR"], val)
															self:Print(err)
															return err
														end
													end,
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Cooldown' then
															return false
														end
														return true
													end,
									},	
											
									
									['Tracker 3 Visibility'] = {
										type	= 'header',
										name	= 'Display Settings',
										order	= 4
									},
									
									
									-- Caption Options
									['Tracker 3 Caption'] = {
										type	= 'select',
										name	= L["Caption"],
										desc	= function()
														local output = L["Caption Description"]
														
														if self.DB.profile['Tracker 3 Type'] == 'Aura' then
															output = output .. '  ' .. L["Caption Description Aura"]

															if self.Active then
																local numWatched = 0

																for k,_ in pairs(self.Active:Watchlist()) do
																	if numWatched == 0 then
																		output = output .. '\n|cFFFFD100' .. L["Watched Spells"] .. ':|r ' .. k
																		numWatched = numWatched + 1
																	else
																		output = output .. ', ' .. k
																	end
																end
															end
														end

														return output
													end,
										values	= {
											['None']	= L["None"],
											['Stacks']	= L["Stacks"],
											['Targets']	= L["Targets"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Totem' then
															return true
														end
														return false
													end,
									},
									['Tracker 3 Totem Caption'] = {
										type	= 'select',
										name	= L['Caption'],
										desc	= L["Caption Description"],
										values	= {
											['None']	= L["None"],
											['Targets']	= L["Targets"],
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 3 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},
									
									
									['Tracker 3 Show'] = {
										type	= 'select',
										name	= L['Show'],
										values	= function ()
														if self.DB.profile['Tracker 3 Type'] == 'Cooldown' then
															return {	['Absent']		= L['Unusable'],
																		['Present']		= L['Usable'],
																		['Show Always']	= L['Always'] }
														else
															return {	['Absent']		= L['Absent'],
																		['Present']		= L['Present'],
																		['Show Always'] = L['Always'] }
														end
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 6,
									},
									
									['Tracker 3 Timer'] = {
										type	= 'toggle',
										name	= L['Show Timer'],
										desc	= L["Show Timer Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 7
									}
								}
							},
							['T3 Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 1,
								args = {
									['Tracker 3 Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Tracker 3 Size'] = {
										type	= 'range',
										name 	= L["Icon Size"],
										min		= 20,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6 
									},
									['Tracker 3 Font Size'] = {
										type	= 'range',
										name 	= L["Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
								},
							},
						},
					},
					['Tracker Icon #4'] = {
						type = 'group',
						name = L["Tracker Icon #4"],
						order = 6,
						args = {
							['T4 Config'] = {
								type = 'group',
								name = L["Tracker"],
								inline = true,
								order = 0,
								args = {
									['Tracker 4 Type'] = {
										type	= 'select',
										name	= L["Type"],
										values	= {
											['None']		= L["None"],
											['Cooldown']	= L["Cooldown"],
											['Aura']		= L["Aura"],
											['Totem']		= L["Totem"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0
									},


									['Tracker 4 Custom'] = {
										type	= 'header',
										name	= function()
														if self.DB.profile['Tracker 4 Type'] == 'None' then
															return L["Tracker Disabled"]
														end
														return self.DB.profile['Tracker 4 Type'] .. ' ' .. L["Settings"]
													end,	
										order	= 1
									},
									
									
									-- None
									['Tracker 4 None'] = {
										type	= 'description',
										name	= L["Tracker None Description"],
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'None' then
															return false
														end
														return true
													end,
									},


									-- Aura
									['Tracker 4 Aura'] = {
										type	= 'input',
										name	= L["Aura"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif GetSpellInfo(val) then return true
														else
															local err = string.format(L["Tracker Aura Error"], L["ERROR"], val)
															Hekili:Print(err)
															return err
														end
														return true
													end,
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 4 Unit'] = {
										type	= 'select',
										name	= L["Unit"],
										values	= {
											['focus']	= L["Focus"],
											['player']	= L["Player"],
											['target']	= L["Target"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 3
									},


									-- Totem
									['Tracker 4 Totem Name'] = {
										type	= 'input',
										name	= L["Totem"],
										desc	= L["Totem Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Totem' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 4 Element'] = {
										type	= 'select',
										name	= L["Element"],
										values	= {
											['fire']	= 'Fire',
											['earth']	= 'Earth',
											['water']	= 'Water',
											['air']		= 'Air'
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 3,
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},


									-- Cooldown
									['Tracker 4 Ability'] = {
										type	= 'input',
										name	= L["Ability"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif IsUsableSpell(val) then return true
														else
															local err = string.format(L["Tracker Ability Error"], L["ERROR"], val)
															self:Print(err)
															return err
														end
													end,
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Cooldown' then
															return false
														end
														return true
													end,
									},	
											
									
									['Tracker 4 Visibility'] = {
										type	= 'header',
										name	= 'Display Settings',
										order	= 4
									},
									
									
									-- Caption Options
									['Tracker 4 Caption'] = {
										type	= 'select',
										name	= L["Caption"],
										desc	= function()
														local output = L["Caption Description"]
														
														if self.DB.profile['Tracker 4 Type'] == 'Aura' then
															output = output .. '  ' .. L["Caption Description Aura"]

															if self.Active then
																local numWatched = 0

																for k,_ in pairs(self.Active:Watchlist()) do
																	if numWatched == 0 then
																		output = output .. '\n|cFFFFD100' .. L["Watched Spells"] .. ':|r ' .. k
																		numWatched = numWatched + 1
																	else
																		output = output .. ', ' .. k
																	end
																end
															end
														end

														return output
													end,
										values	= {
											['None']	= L["None"],
											['Stacks']	= L["Stacks"],
											['Targets']	= L["Targets"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Totem' then
															return true
														end
														return false
													end,
									},
									['Tracker 4 Totem Caption'] = {
										type	= 'select',
										name	= L['Caption'],
										desc	= L["Caption Description"],
										values	= {
											['None']	= L["None"],
											['Targets']	= L["Targets"],
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 4 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},
									
									
									['Tracker 4 Show'] = {
										type	= 'select',
										name	= L['Show'],
										values	= function ()
														if self.DB.profile['Tracker 4 Type'] == 'Cooldown' then
															return {	['Absent']		= L['Unusable'],
																		['Present']		= L['Usable'],
																		['Show Always']	= L['Always'] }
														else
															return {	['Absent']		= L['Absent'],
																		['Present']		= L['Present'],
																		['Show Always'] = L['Always'] }
														end
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 6,
									},
									
									['Tracker 4 Timer'] = {
										type	= 'toggle',
										name	= L['Show Timer'],
										desc	= L["Show Timer Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 7
									}
								}
							},
							['T4 Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 1,
								args = {
									['Tracker 4 Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Tracker 4 Size'] = {
										type	= 'range',
										name 	= L["Icon Size"],
										min		= 20,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6 
									},
									['Tracker 4 Font Size'] = {
										type	= 'range',
										name 	= L["Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
								},
							},
						},
					},
					['Tracker Icon #5'] = {
						type = 'group',
						name = L["Tracker Icon #5"],
						order = 7,
						args = {
							['T5 Config'] = {
								type = 'group',
								name = L["Tracker"],
								inline = true,
								order = 0,
								args = {
									['Tracker 5 Type'] = {
										type	= 'select',
										name	= L["Type"],
										values	= {
											['None']		= L["None"],
											['Cooldown']	= L["Cooldown"],
											['Aura']		= L["Aura"],
											['Totem']		= L["Totem"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 0
									},


									['Tracker 5 Custom'] = {
										type	= 'header',
										name	= function()
														if self.DB.profile['Tracker 5 Type'] == 'None' then
															return L["Tracker Disabled"]
														end
														return self.DB.profile['Tracker 5 Type'] .. ' ' .. L["Settings"]
													end,	
										order	= 1
									},
									
									
									-- None
									['Tracker 5 None'] = {
										type	= 'description',
										name	= L["Tracker None Description"],
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'None' then
															return false
														end
														return true
													end,
									},


									-- Aura
									['Tracker 5 Aura'] = {
										type	= 'input',
										name	= L["Aura"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif GetSpellInfo(val) then return true
														else
															local err = string.format(L["Tracker Aura Error"], L["ERROR"], val)
															Hekili:Print(err)
															return err
														end
														return true
													end,
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 5 Unit'] = {
										type	= 'select',
										name	= L["Unit"],
										values	= {
											['focus']	= L["Focus"],
											['player']	= L["Player"],
											['target']	= L["Target"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Aura' then
															return false
														end
														return true
													end,
										order	= 3
									},


									-- Totem
									['Tracker 5 Totem Name'] = {
										type	= 'input',
										name	= L["Totem"],
										desc	= L["Totem Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Totem' then
															return false
														end
														return true
													end,
										order	= 2,
										width	= 'full'
									},
									['Tracker 5 Element'] = {
										type	= 'select',
										name	= L["Element"],
										values	= {
											['fire']	= 'Fire',
											['earth']	= 'Earth',
											['water']	= 'Water',
											['air']		= 'Air'
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 3,
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},


									-- Cooldown
									['Tracker 5 Ability'] = {
										type	= 'input',
										name	= L["Ability"],
										set		= 'SetOption',
										get		= 'GetOption',
										validate = function(info, val)
														if val == '' then return true
														elseif IsUsableSpell(val) then return true
														else
															local err = string.format(L["Tracker Ability Error"], L["ERROR"], val)
															self:Print(err)
															return err
														end
													end,
										order	= 2,
										width	= 'full',
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Cooldown' then
															return false
														end
														return true
													end,
									},	
											
									
									['Tracker 5 Visibility'] = {
										type	= 'header',
										name	= 'Display Settings',
										order	= 4
									},
									
									
									-- Caption Options
									['Tracker 5 Caption'] = {
										type	= 'select',
										name	= L["Caption"],
										desc	= function()
														local output = L["Caption Description"]
														
														if self.DB.profile['Tracker 5 Type'] == 'Aura' then
															output = output .. '  ' .. L["Caption Description Aura"]

															if self.Active then
																local numWatched = 0

																for k,_ in pairs(self.Active:Watchlist()) do
																	if numWatched == 0 then
																		output = output .. '\n|cFFFFD100' .. L["Watched Spells"] .. ':|r ' .. k
																		numWatched = numWatched + 1
																	else
																		output = output .. ', ' .. k
																	end
																end
															end
														end

														return output
													end,
										values	= {
											['None']	= L["None"],
											['Stacks']	= L["Stacks"],
											['Targets']	= L["Targets"]
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Totem' then
															return true
														end
														return false
													end,
									},
									['Tracker 5 Totem Caption'] = {
										type	= 'select',
										name	= L['Caption'],
										desc	= L["Caption Description"],
										values	= {
											['None']	= L["None"],
											['Targets']	= L["Targets"],
										},
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 5,
										hidden	= function()
														if self.DB.profile['Tracker 5 Type'] == 'Totem' then
															return false
														end
														return true
													end,
									},
									
									
									['Tracker 5 Show'] = {
										type	= 'select',
										name	= L['Show'],
										values	= function ()
														if self.DB.profile['Tracker 5 Type'] == 'Cooldown' then
															return {	['Absent']		= L['Unusable'],
																		['Present']		= L['Usable'],
																		['Show Always']	= L['Always'] }
														else
															return {	['Absent']		= L['Absent'],
																		['Present']		= L['Present'],
																		['Show Always'] = L['Always'] }
														end
													end,
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 6,
									},
									
									['Tracker 5 Timer'] = {
										type	= 'toggle',
										name	= L['Show Timer'],
										desc	= L["Show Timer Description"],
										set		= 'SetOption',
										get		= 'GetOption',
										order	= 7
									}
								}
							},
							['T5 Visual'] = {
								type = 'group',
								name = L["Visual Elements"],
								inline = true,
								order = 1,
								args = {
									['Tracker 5 Font'] = {
										type			= 'select',
										dialogControl	= 'LSM30_Font', --Select your widget here
										name			= L["Font"],
										values			= Hekili.LSM:HashTable("font"), -- pull in your font list from LSM
										get				= 'GetOption',
										set				= 'SetOption',
										width			= 'full',
										order			= 5
									},
									['Tracker 5 Size'] = {
										type	= 'range',
										name 	= L["Icon Size"],
										min		= 20,
										max		= 250,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 6 
									},
									['Tracker 5 Font Size'] = {
										type	= 'range',
										name 	= L["Font Size"],
										min		= 6,
										max		= 26,
										step	= 1,
										get		= 'GetOption',
										set		= 'SetOption',
										order	= 7
									},
								},
							},
						},
					},
				},
			},
			['Filters'] = {
				type = 'group',
				name = L["Filters"],
				order = 2,
				args = {
					['Special Action Lists'] = {
						type = "group",
						name = L["Special Action Lists"],
						inline = true,
						order = 0,
						args = {
							['Show Precombat'] = {
								type	= 'toggle',
								name	= L["Show Precombat"],
								desc	= function () return OutputFlags( 'Show Precombat', 'precombat' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 0,
							},

							['Cooldown Enabled'] = {
								type	= 'toggle',
								name	= L["Show Cooldowns"],
								set 	= 'SetOption',
								get 	= 'GetOption',
								order	= 1,
							},
						},
					},
					['Cooldowns'] = {
						type = "group",
						name = L["Cooldown Filters"],
						inline = true,
						order = 1,
						args = {
							['Show Bloodlust'] = {
								type	= 'toggle',
								name	= L['Show Bloodlust'],
								desc	= function () return OutputFlags( 'Show Bloodlust', 'bloodlust' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 0,
							},
							['Show Consumables'] = {
								type	= 'toggle',
								name	= L['Show Consumables'],
								desc	= function () return OutputFlags( 'Show Consumables', 'consumable' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1,
							},
							['Show Professions'] = {
								type	= 'toggle',
								name	= L['Show Professions'],
								desc	= function () return OutputFlags( 'Show Professions', 'profession' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 2,
							},
							['Show Racials'] = {
								type	= 'toggle',
								name	= L['Show Racials'],
								desc	= function () return OutputFlags( 'Show Racials', 'racial' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 3,
							},
							['Cooldown Threshold'] = {
								type 	= 'range',
								name 	= L['Cooldown Threshold'],
								desc 	= L["Cooldown Threshold Description"],
								min		= 30,
								max		= 600,
								step	= 1,
								get		= 'GetOption',
								set		= 'SetOption',
								order	= 4,
								width	= 'double'
							},
						},
					},
					['General Filters'] = {
						type = "group",
						name = L["General Filters"],
						inline = true,
						order = 2,
						args = {

							['Show Hardcasts'] = {
								type	= 'toggle',
								name	= L['Show Hardcasts'],
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
								name	= L['Show Interrupts'],
								desc	= function () return OutputFlags( 'Show Interrupts', 'interrupt' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 2,
							},

							['Show Talents'] = {
								type	= 'toggle',
								name	= L['Show Talents'],
								desc	= function () return OutputFlags( 'Show Talents', 'talent' ) end,
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 4,
							},
							
							['Show AOE in ST'] = {
								type	= 'toggle',
								name	= L['Show Blended ST'],
								desc	= L["Show Blended ST Description"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 5,
							},

							['Name Filter'] = {
								type	= 'input',
								name	= L['Name Filter'],
								get		= 'GetOption',
								set		= 'SetOption',
								multiline = 5,
								desc	= L["Name Filter Description"],
								order	= 6,
								width	= 'full'
							},
						}
					},
				}
			},
			['Hotkeys'] = {
				type = "group",
				name = L["Key Bindings"],
				order = 3,
				args = {
					['Visibility Hotkeys'] = {
						type = 'group',
						name = L['Visibility'],
						inline = true,
						order = 0,
						args = {
							['Hekili Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Addon"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 0
							},
							['ST Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Single Target Display"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1
							},
							['AE Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Multi-Target Display"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 2
							},
							['Integrate Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Multi Integration"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 3
							},
						}
					},
					['Filter Hotkeys'] = {
						type = 'group',
						name = L['Filters'],
						inline = true,
						order = 1,
						args = {
							['Cooldown Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Cooldowns"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 0
							},
							['Hardcast Hotkey'] = {
								type	= 'keybinding',
								name	= L["Toggle Hardcasts"],
								set		= 'SetOption',
								get		= 'GetOption',
								order	= 1
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
			
			-- Basic Settings

			enabled								= true,
			locked								= false,
			verbose								= false,

			['Visibility']						= 'Always Show',
			['PvP Visibility']					= true,
			
			['Module']							= 'Enhancement Shaman SimC 5.4.1',
			
			['Updates Per Second']				= 5,

			['Grace Period']					= 5,
			
			-- UI Settings
			-- Globals
			
			['Global Font']						= 'Arial Narrow',
			['Global Icon Size']				= 50,
			['Global Font Size']				= 12,
			
			-- Single Target Group

			['Single Target Enabled']			= true,
			['Single Target Icons Displayed']	= 5,
			['Integration Enabled']				= false,
			['Multi-Target Integration']		= 4,
			['Single Target Queue Direction']	= 'RIGHT',

			['Single Target Greentext']			= true,
			['Single Target Captions']			= true,
			['Single Target Tracker']			= 'None',

			['Single Target Font']				= 'Arial Narrow',
			['Single Target Primary Icon Size'] = 50,
			['Single Target Primary Font Size']	= 12,
			['Single Target Primary Icon Size'] = 50,
			['Single Target Queued Icon Size']	= 40,
			['Single Target Queued Font Size']	= 12,
			['Single Target Icon Spacing']		= 5,

			-- Single-Target (Hidden)
			
			['ST X']							= 0,
			['ST Y']							= 0,
			['ST Relative To']					= 'CENTER',

			-- Multi-Target Group

			['Multi-Target Enabled']			= true,
			['Multi-Target Cooldowns']			= false,
			['Multi-Target Icons Displayed']	= 5,
			['Multi-Target Illumination']		= 2,
			['Multi-Target Queue Direction']	= 'RIGHT',

			['Multi-Target Greentext']			= true,
			['Multi-Target Captions']			= true,

			['Multi-Target Font']				= 'Arial Narrow',
			['Multi-Target Primary Icon Size'] 	= 50,
			['Multi-Target Primary Font Size']	= 12,
			['Multi-Target Queued Icon Size']	= 40,
			['Multi-Target Queued Font Size']	= 12,
			['Multi-Target Icon Spacing']		= 5,

			-- Multi-Target (Hidden)
			
			['AE X']							= 0,
			['AE Y']							= -100,
			['AE Relative To']					= 'CENTER',

			-- Trackers
			-- Tracker 1

			['Tracker 1 Type']					= 'None',
			['Tracker 1 Caption']				= 'None',
			['Tracker 1 Show']					= 'Show Always',
			['Tracker 1 Timer']					= true,

			-- Aura
			['Tracker 1 Aura']					= '',
			['Tracker 1 Unit']					= 'player',
			
			-- Totem
			['Tracker 1 Totem']					= '',
			['Tracker 1 Element']				= 'fire',
			['Tracker 1 Totem Name']			= '',
			['Tracker 1 Totem Caption']			= 'None',
			
			-- Ability Cooldown
			['Tracker 1 Ability']				= '',

			['Tracker 1 Font']					= 'Arial Narrow',
			['Tracker 1 Size']					= 40,
			['Tracker 1 Font Size']				= 12,

			-- Tracker 1 (Hidden)

			['Tracker 1 X']						= 0,
			['Tracker 1 Y']						= 100,
			['Tracker 1 Relative To']			= 'CENTER',
			
			-- Tracker 2

			['Tracker 2 Type']					= 'None',
			['Tracker 2 Caption']				= 'None',
			['Tracker 2 Show']					= 'Show Always',
			['Tracker 2 Timer']					= true,

			-- Aura
			['Tracker 2 Aura']					= '',
			['Tracker 2 Unit']					= 'player',
			
			-- Totem
			['Tracker 2 Totem']					= '',
			['Tracker 2 Element']				= 'fire',
			['Tracker 2 Totem Name']			= '',
			['Tracker 2 Totem Caption']			= 'None',
			
			-- Ability Cooldown
			['Tracker 2 Ability']				= '',

			['Tracker 2 Font']					= 'Arial Narrow',
			['Tracker 2 Size']					= 40,
			['Tracker 2 Font Size']				= 12,

			-- Tracker 2 (Hidden)

			['Tracker 2 X']						= 50,
			['Tracker 2 Y']						= 100,
			['Tracker 2 Relative To']			= 'CENTER',
			
			-- Tracker 3

			['Tracker 3 Type']					= 'None',
			['Tracker 3 Caption']				= 'None',
			['Tracker 3 Show']					= 'Show Always',
			['Tracker 3 Timer']					= true,

			-- Aura
			['Tracker 3 Aura']					= '',
			['Tracker 3 Unit']					= 'player',
			
			-- Totem
			['Tracker 3 Totem']					= '',
			['Tracker 3 Element']				= 'fire',
			['Tracker 3 Totem Name']			= '',
			['Tracker 3 Totem Caption']			= 'None',
			
			-- Ability Cooldown
			['Tracker 3 Ability']				= '',

			['Tracker 3 Font']					= 'Arial Narrow',
			['Tracker 3 Size']					= 40,
			['Tracker 3 Font Size']				= 12,

			-- Tracker 3 (Hidden)

			['Tracker 3 X']						= 100,
			['Tracker 3 Y']						= 100,
			['Tracker 3 Relative To']			= 'CENTER',
			
			-- Tracker 4

			['Tracker 4 Type']					= 'None',
			['Tracker 4 Caption']				= 'None',
			['Tracker 4 Show']					= 'Show Always',
			['Tracker 4 Timer']					= true,

			-- Aura
			['Tracker 4 Aura']					= '',
			['Tracker 4 Unit']					= 'player',
			
			-- Totem
			['Tracker 4 Totem']					= '',
			['Tracker 4 Element']				= 'fire',
			['Tracker 4 Totem Name']			= '',
			['Tracker 4 Totem Caption']			= 'None',
			
			-- Ability Cooldown
			['Tracker 4 Ability']				= '',

			['Tracker 4 Font']					= 'Arial Narrow',
			['Tracker 4 Size']					= 40,
			['Tracker 4 Font Size']				= 12,

			-- Tracker 4 (Hidden)

			['Tracker 4 X']						= 150,
			['Tracker 4 Y']						= 100,
			['Tracker 4 Relative To']			= 'CENTER',
			
			-- Tracker 5

			['Tracker 5 Type']					= 'None',
			['Tracker 5 Caption']				= 'None',
			['Tracker 5 Show']					= 'Show Always',
			['Tracker 5 Timer']					= true,

			-- Aura
			['Tracker 5 Aura']					= '',
			['Tracker 5 Unit']					= 'player',
			
			-- Totem
			['Tracker 5 Totem']					= '',
			['Tracker 5 Element']				= 'fire',
			['Tracker 5 Totem Name']			= '',
			['Tracker 5 Totem Caption']			= 'None',
			
			-- Ability Cooldown
			['Tracker 5 Ability']				= '',

			['Tracker 5 Font']					= 'Arial Narrow',
			['Tracker 5 Size']					= 40,
			['Tracker 5 Font Size']				= 12,

			-- Tracker 5 (Hidden)

			['Tracker 5 X']						= 200,
			['Tracker 5 Y']						= 100,
			['Tracker 5 Relative To']			= 'CENTER',
			
			-- Filters
			
			['Show Bloodlust']					= false,
			['Show Consumables']				= false,
			['Show Professions']				= false,
			['Show Racials']					= false,
			['Cooldown Threshold']				= 300,
			
			['Cooldown Enabled']				= false,
			['Show Hardcasts']					= true,
			['Show Interrupts']					= true,
			['Show Precombat']					= true,
			['Show Talents']					= true,	
			['Show AOE in ST']					= false,
			['Name Filter']						= '',

			-- Key Bindings

			['Hekili Hotkey']					= '',
			['ST Hotkey']						= '',
			['AE Hotkey']						= '',
			['Cooldown Hotkey'] 				= '',
			['Hardcast Hotkey'] 				= ''
		}
	}

	return defaults
end


-- Toggle Keybinds
local toggle = {}

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
	toggle[1] = 'Cooldown Enabled'
	self:SetOption(toggle, not self.DB.profile['Cooldown Enabled'])
end

function Hekili:ToggleHardcasts()
	toggle[1] = 'Show Hardcasts'
	self:SetOption(toggle, not self.DB.profile['Show Hardcasts'])
end

function Hekili:ToggleSingle()
	toggle[1] = 'Single Target Enabled'
	self:SetOption(toggle, not self.DB.profile['Single Target Enabled'])
end

function Hekili:ToggleMulti()
	toggle[1] = 'Multi-Target Enabled'
	self:SetOption(toggle, not self.DB.profile['Multi-Target Enabled'])
end

function Hekili:ToggleIntegration()
	toggle[1] = 'Integration Enabled'
	self:SetOption(toggle, not self.DB.profile['Integration Enabled'])
end

-- End Toggles




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
		self:ClearAuras()
		self:LoadAuras()

		if self.Active then self:ProcessPriorityList( 'ST' ) end
		if self.Active then self:ProcessPriorityList( 'AE' ) end
		
	elseif opt == 'Single Target Enabled' then
		for i = 1, 5 do
			if input == false then
				self.UI.AButtons['ST'][i]:Hide()
			elseif i <= self.DB.profile['Single Target Icons Displayed'] then
				self.UI.AButtons['ST'][i]:Show()
			end
		end

		if input == true then
			self:ProcessPriorityList( 'ST' )
		end
		
	elseif opt == 'Integration Enabled' then
		if self.DB.profile['Multi-Target Integration'] < 2 then
			self.DB.profile['Multi-Target Integration'] = 2
		end
		
	elseif opt == 'Multi-Target Enabled' then
		for i = 1, 5 do
			if input == false then
				self.UI.AButtons['AE'][i]:Hide()
			elseif i <= self.DB.profile['Multi-Target Icons Displayed'] then
				self.UI.AButtons['AE'][i]:Show()
			end
		end

		if input == true then
			self:ProcessPriorityList( 'AE' )
		end

	elseif opt == 'Tracker 1 Type' then
		if	( input == 'Aura' ) then
			if (not GetSpellInfo(self.DB.profile['Tracker 1 Aura'])) then
				self.DB.profile['Tracker 1 Aura'] = ''
			end
		end
		
	elseif opt == 'Hekili Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE")
			self.DB.profile[opt] = input
		end

		SaveBindings(GetCurrentBindingSet())

	elseif opt == 'ST Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_SINGLE") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_SINGLE"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_SINGLE")
			self.DB.profile[opt] = input
		end

		SaveBindings(GetCurrentBindingSet())

	elseif opt == 'AE Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_MULTI") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_MULTI"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_MULTI")
			self.DB.profile[opt] = input
		end

		SaveBindings(GetCurrentBindingSet())
		
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

		SaveBindings(GetCurrentBindingSet())

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

		SaveBindings(GetCurrentBindingSet())
		
	elseif opt == 'Integrate Hotkey' then
		-- Clear the old binding.
		if self.DB.profile[opt] ~= '' then
			self.DB.profile[opt] = ''
		end
		
		if GetBindingKey("HEKILI_TOGGLE_INTEGRATE") then
			SetBinding(GetBindingKey("HEKILI_TOGGLE_INTEGRATE"))
		end
		
		if input ~= '' then
			SetBinding(input, "HEKILI_TOGGLE_INTEGRATE")
			self.DB.profile[opt] = input
		end

		SaveBindings(GetCurrentBindingSet())
		
		
	elseif opt == 'Name Filter' then
		self.DB.profile[opt] = self:ApplyNameFilters( input )
		
	elseif opt == 'Global Font' then
		self.DB.profile['Single Target Font'] = input
		self.DB.profile['Multi-Target Font'] = input
		self.DB.profile['Tracker 1 Font'] = input
		self.DB.profile['Tracker 2 Font'] = input
		self.DB.profile['Tracker 3 Font'] = input
		self.DB.profile['Tracker 4 Font'] = input
		self.DB.profile['Tracker 5 Font'] = input
		self:RefreshUI()

	elseif opt == 'Global Icon Size' then
		self.DB.profile['Single Target Primary Icon Size'] = input
		self.DB.profile['Single Target Queued Icon Size'] = input
		self.DB.profile['Multi-Target Primary Icon Size'] = input
		self.DB.profile['Multi-Target Queued Icon Size'] = input
		self.DB.profile['Tracker 1 Size'] = input
		self.DB.profile['Tracker 2 Size'] = input
		self.DB.profile['Tracker 3 Size'] = input
		self.DB.profile['Tracker 4 Size'] = input
		self.DB.profile['Tracker 5 Size'] = input
		self:RefreshUI()

	elseif opt == 'Global Font Size' then
		self.DB.profile['Single Target Primary Font Size'] = input
		self.DB.profile['Single Target Queued Font Size'] = input
		self.DB.profile['Multi-Target Primary Font Size'] = input
		self.DB.profile['Multi-Target Queued Font Size'] = input
		self.DB.profile['Tracker 1 Font Size'] = input
		self.DB.profile['Tracker 2 Font Size'] = input
		self.DB.profile['Tracker 3 Font Size'] = input
		self.DB.profile['Tracker 4 Font Size'] = input
		self.DB.profile['Tracker 5 Font Size'] = input
		self:RefreshUI()

	elseif opt == 'Single Target Queue Direction' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Font' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Primary Icon Size' then
		self:RefreshUI()
				
	elseif opt == 'Single Target Primary Font Size' then
		self:RefreshUI()
				
	elseif opt == 'Single Target Icon Spacing' then
		self:RefreshUI()
		
	elseif opt == 'Single Target Queued Icon Size' then
		self:RefreshUI()

	elseif opt == 'Single Target Queued Font Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Queue Direction' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Font' then
		self:RefreshUI()
		
	elseif opt == 'Multi-Target Primary Icon Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Primary Font Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Queued Icon Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Queued Font Size' then
		self:RefreshUI()

	elseif opt == 'Multi-Target Icon Spacing' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 1 Font' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 1 Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 1 Font Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 2 Font' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 2 Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 2 Font Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 3 Font' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 3 Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 3 Font Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 4 Font' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 4 Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 4 Font Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 5 Font' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 5 Size' then
		self:RefreshUI()
		
	elseif opt == 'Tracker 5 Font Size' then
		self:RefreshUI()
		
	end
end


function Hekili:GetOption(info)
	local opt = info[#info]
	
	if self.DB.profile[opt] ~= nil then
		return self.DB.profile[opt]
	else
		if Hekili:IsVerbose() then
			local err = string.format(L["GetOption Error"], opt)
			Hekili:Print(err)
		end
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