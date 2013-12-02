--	UI.lua
--	Insert clever description here.
--	Hekili @ Ner'zhul, 10/23/13

Hekili.invDirection = {
	['BOTTOM']	= 'TOP',
	['TOP']		= 'BOTTOM',
	['LEFT']	= 'RIGHT',
	['RIGHT']	= 'LEFT'
}


function Hekili:CreatePriorityButton( set, number )
	local name = 'Hekili_' .. set .. '_Action_' .. number

	local button = CreateFrame("Button", name, Hekili.UI.Engine)
	button.desc = 'Hekili Action Button ('..set..'#'..number..')'
	button.ability = '(none)'
	
	-- defaults (that should be preferences)
	local btnSize = 50
	local btnDirection = 'RIGHT'
	local btnSpacing = 5
		
	button:SetFrameStrata("BACKGROUND")
	button:EnableMouse(not Hekili.DB.profile.locked)
	button:SetMovable(not Hekili.DB.profile.locked)
	button:SetClampedToScreen(true)

	local group
	if set == 'ST' then
		group = 'Single Target'
	elseif set == 'AE' then
		group = 'Multi-Target'
	else
		group = 'Bad'
	end

	if number == 1 then
		button:SetSize( Hekili:GetOption( { group .. ' Primary Icon Size' } ), Hekili:GetOption( { group .. ' Primary Icon Size' } ) )
	else
		button:SetSize( Hekili:GetOption( { group .. ' Queued Icon Size' } ), Hekili:GetOption( { group .. ' Queued Icon Size' } ) )
	end

	button.Texture = button:CreateTexture(nil, "BACKGROUND")
	button.Texture:SetAllPoints(button)
	button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')	-- default in case nothing is loaded.
	button.Texture:SetAlpha(1)
	
	button.Cooldown = CreateFrame("Cooldown", name.."_Cooldown" , button, "CooldownFrameTemplate")
	button.Cooldown:SetAllPoints(button)
	
	button.btmText = button:CreateFontString(name.."BtmText", "OVERLAY", "SystemFont_Outline_Small" )
	button.btmText:SetSize(button:GetWidth(), button:GetHeight() / 2)
	-- button.btmText:SetTextHeight(button:GetHeight() / 3)
	button.btmText:SetPoint("BOTTOM", button, "BOTTOM")
	button.btmText:SetJustifyV("BOTTOM")
	button.btmText:SetTextColor(1, 1, 1, 1)
		
	button.topText = button:CreateFontString(name.."TopText", "OVERLAY", "SystemFont_Outline_Small" )
	button.topText:SetSize(button:GetWidth(), button:GetHeight() / 2)
	-- button.topText:SetTextHeight(button:GetHeight() / 3)
	button.topText:SetJustifyH("RIGHT")
	button.topText:SetJustifyV("TOP")
	button.topText:SetPoint("TOP", button, "TOP")
	button.topText:SetTextColor(0, 1, 0, 1)
		
	button:ClearAllPoints()

	if number == 1 then
		-- Position the first icon.
		button:SetPoint(self.DB.profile[set .. ' Relative To'], self.DB.profile[set .. ' X'], self.DB.profile[set .. ' Y'])
		-- button:SetPoint("CENTER", "Hekili_Engine_Frame", "CENTER", 0, initial_offset[set])
		
		button:SetScript("OnEnter", function(self)
			if ( self:IsMovable() ) then
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				GameTooltip:SetText(self.desc)
				GameTooltip:AddLine("Left-click and hold to move.\nRight-click to lock ALL and close.", 1, 1, 1)
				GameTooltip:Show()
				self:SetMovable(true)
				self:EnableMouse(true)
			else
				self:SetMovable(false)
				self:EnableMouse(false)
				GameTooltip:Hide()
			end
		end)

		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

		button:SetScript("OnMouseDown", function(self, btn)
			if ( self:IsMovable() and btn == "LeftButton" and not self.Moving ) then
				self:StartMoving()
				self.Moving = true
			end
		end)

		button:SetScript("OnMouseUp", function(self, btn)
			if ( btn == "LeftButton" and self.Moving ) then
				self:StopMovingOrSizing()
				self.Moving = false
			end
			if ( btn == "RightButton" ) then
				x_offset, y_offset = self:GetCenter()
				self:StopMovingOrSizing()
				self.Moving = false
				Hekili:SetOption({ "locked" }, true)
				GameTooltip:Hide()
			end
			Hekili:SaveCoordinates()
		end)

		if set == 'AE' then
			button.targets = button:CreateFontString(name..'Targets', 'OVERLAY', 'SystemFont_Outline_Small')
			button.targets:SetSize(button:GetWidth(), button:GetHeight() / 2)
			button.targets:SetJustifyH("CENTER")
			button.targets:SetPoint("BOTTOM", button, "TOP", 0, 0)
			button.targets:SetTextColor(1, 0, 0, 1)
		end
	
	else
		if Hekili:GetOption( { group .. ' Queue Direction' } ) == 'RIGHT' then
			button:SetPoint(Hekili.invDirection[Hekili:GetOption( { group .. ' Queue Direction' } )], 'Hekili_'..set..'_Action_'..(number-1), Hekili:GetOption( { group .. ' Queue Direction' } ), Hekili:GetOption( { group .. ' Icon Spacing' } ), 0)
		else
			button:SetPoint(Hekili.invDirection[Hekili:GetOption( { group .. ' Queue Direction' } )], 'Hekili_'..set..'_Action_'..(number-1), Hekili:GetOption( { group .. ' Queue Direction' } ), -1 * Hekili:GetOption( { group .. ' Icon Spacing' } ), 0)
		end
	end	

	button:Hide()

	return button
end


function Hekili:SaveCoordinates()
	local _, _, relative, x, y = Hekili.UI.AButtons['ST'][1]:GetPoint()
	self.DB.profile['ST Relative To'] = relative
	self.DB.profile['ST X'] = x
	self.DB.profile['ST Y'] = y

	_, _, relative, x, y = Hekili.UI.AButtons['AE'][1]:GetPoint()
	self.DB.profile['AE Relative To'] = relative
	self.DB.profile['AE X'] = x
	self.DB.profile['AE Y'] = y
end


function Hekili:RefreshUI()
	self.UI.AButtons['ST'][1]:ClearAllPoints()
	self.UI.AButtons['ST'][1]:SetPoint(self.DB.profile['ST Relative To'], self.DB.profile['ST X'], self.DB.profile['ST Y'])
	self.UI.AButtons['ST'][1]:EnableMouse(not self.DB.profile.locked)
	self.UI.AButtons['ST'][1]:SetMovable(not self.DB.profile.locked)
	self.UI.AButtons['ST'][1]:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'])
	self.UI.AButtons['ST'][1].topText:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'] / 2)
	self.UI.AButtons['ST'][1].btmText:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'] / 2)

	for i = 2, 5 do
		self.UI.AButtons['ST'][i]:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'])
		self.UI.AButtons['ST'][i].topText:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'] / 2)
		self.UI.AButtons['ST'][i].btmText:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'] / 2)
		self.UI.AButtons['ST'][i]:ClearAllPoints()

		if self.DB.profile['Single Target Queue Direction'] == 'RIGHT' then
			self.UI.AButtons['ST'][i]:SetPoint(self.invDirection[ self.DB.profile['Single Target Queue Direction'] ], self.UI.AButtons['ST'][i-1], self.DB.profile['Single Target Queue Direction'], self.DB.profile['Single Target Icon Spacing'], 0)
		else
			self.UI.AButtons['ST'][i]:SetPoint(self.invDirection[ self.DB.profile['Single Target Queue Direction'] ], self.UI.AButtons['ST'][i-1], self.DB.profile['Single Target Queue Direction'], -1 * self.DB.profile['Single Target Icon Spacing'], 0)
		end
	end

	if self.LBF then
		self.stGroup:ReSkin()
	end


	self.UI.AButtons['AE'][1]:ClearAllPoints()
	self.UI.AButtons['AE'][1]:SetPoint(self.DB.profile['AE Relative To'], self.DB.profile['AE X'], self.DB.profile['AE Y'])
	self.UI.AButtons['AE'][1]:EnableMouse(not self.DB.profile.locked)
	self.UI.AButtons['AE'][1]:SetMovable(not self.DB.profile.locked)
	self.UI.AButtons['AE'][1]:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'])
	self.UI.AButtons['AE'][1].topText:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'] / 2)
	self.UI.AButtons['AE'][1].btmText:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'] / 2)

	for i = 2, 5 do
		self.UI.AButtons['AE'][i]:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'])
		self.UI.AButtons['AE'][i].topText:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'] / 2)
		self.UI.AButtons['AE'][i].btmText:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'] / 2)
		self.UI.AButtons['AE'][i]:ClearAllPoints()

		if self.DB.profile['Multi-Target Queue Direction'] == 'RIGHT' then
			self.UI.AButtons['AE'][i]:SetPoint(self.invDirection[ self.DB.profile['Multi-Target Queue Direction'] ], self.UI.AButtons['AE'][i-1], self.DB.profile['Multi-Target Queue Direction'], self.DB.profile['Multi-Target Icon Spacing'], 0)
		else
			self.UI.AButtons['AE'][i]:SetPoint(self.invDirection[ self.DB.profile['Multi-Target Queue Direction'] ], self.UI.AButtons['AE'][i-1], self.DB.profile['Multi-Target Queue Direction'], -1 * self.DB.profile['Multi-Target Icon Spacing'], 0)
		end
	end

	if self.LBF then
		self.aeGroup:ReSkin()
	end


end


function Hekili:RefreshBindings()
	self.DB.profile['Cooldown Hotkey'] = GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") or ''
	self.DB.profile['Hardcast Hotkey'] = GetBindingKey("HEKILI_TOGGLE_HARDCASTS") or ''
end	


function Hekili:LockAllButtons( lock )

	local alpha = 0
	if not lock then alpha = 1 end

	for i = 1, 5 do
		Hekili.UI.AButtons.ST[i]:SetMovable(not lock)
		Hekili.UI.AButtons.ST[i]:EnableMouse(not lock)
		Hekili.UI.AButtons.AE[i]:SetMovable(not lock)
		Hekili.UI.AButtons.AE[i]:EnableMouse(not lock)
	end

end


function Hekili:InitCoreUI()

	if self.CoreInitialized then
		return
	end

	self.UI.Engine = CreateFrame("Frame", "Hekili_Engine_Frame", UIParent)
	self.UI.Engine:SetFrameStrata("BACKGROUND")
	self.UI.Engine:SetClampedToScreen(true)
	self.UI.Engine:SetMovable(false)
	self.UI.Engine:EnableMouse(false)
	self.UI.Engine:SetAllPoints(UIParent)

	-- Engine Values
	self.UI.Engine.Interval = (1.0 / self.DB.profile['Updates Per Second'])
	self.UI.Engine.Delay = 0

	self.UI.Engine.TextInterval = 0.1
	self.UI.Engine.TextDelay = 0

    self.UI.Engine:SetScript("OnUpdate", function(self, elapsed)
		self.Delay = self.Delay - elapsed
		self.TextDelay = self.TextDelay - elapsed

		if Hekili:IsEnabled() and UnitHealth('player') > 0 then
			if self.Delay <= 0 then
				Hekili:HeartBeat()
				self.Delay = self.Interval
			end
			
			if self.TextDelay <= 0 then
				Hekili:UpdateGreenText()
				self.TextDelay = self.TextInterval
			end
		end
	end)

	-- For tooltip parsing.
	if not self.Tooltip then self.Tooltip = CreateFrame("GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate") end

	-- Display Elements
	self.UI.AButtons = {}
	self.UI.AButtons['ST'] = {}
	for i = 1, 5 do
		self.UI.AButtons.ST[i] = self:CreatePriorityButton( 'ST', i )
		if self.LBF then self.stGroup:AddButton( self.UI.AButtons.ST[i], { Icon = self.UI.AButtons.ST[i].Texture, Cooldown = self.UI.AButtons.ST[i].Cooldown } ) end	
	end

	self.UI.AButtons['AE'] = {}
	for i = 1, 5 do
		self.UI.AButtons.AE[i] = self:CreatePriorityButton( 'AE', i )
		if self.LBF then self.aeGroup:AddButton( self.UI.AButtons.AE[i], { Icon = self.UI.AButtons.AE[i].Texture, Cooldown = self.UI.AButtons.AE[i].Cooldown } ) end	
	end

	self.CoreInitialized = true
end