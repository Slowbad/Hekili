--	UI.lua
--	Insert clever description here.
--	Hekili @ Ner'zhul, 10/23/13

local L = LibStub("AceLocale-3.0"):GetLocale("Hekili")

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
	button.ability = 'None'
	
	-- defaults (that should be preferences)
	local btnSize = 50
	local btnDirection = 'RIGHT'
	local btnSpacing = 5
		
	button:SetFrameStrata("MEDIUM")
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

	button.Texture = button:CreateTexture(nil, "MEDIUM")
	button.Texture:SetAllPoints(button)
	button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')	-- default in case nothing is loaded.
	button.Texture:SetAlpha(1)
	
	button.Cooldown = CreateFrame("Cooldown", name.."_Cooldown" , button, "CooldownFrameTemplate")
	button.Cooldown:SetAllPoints(button)

	button.Indicator = button:CreateTexture(nil, "MEDIUM")
	button.Indicator:SetSize(button:GetWidth() / 2, button:GetHeight() / 2)
	button.Indicator:SetPoint("TOPLEFT", button, "TOPLEFT")
	button.Indicator:SetAlpha(1)
	
	button.btmText = button:CreateFontString(name.."BtmText", "OVERLAY" )
	button.btmText:SetSize(button:GetWidth(), button:GetHeight() / 2)
	-- button.btmText:SetTextHeight(button:GetHeight() / 3)
	button.btmText:SetPoint("BOTTOM", button, "BOTTOM")
	button.btmText:SetJustifyV("BOTTOM")
	button.btmText:SetTextColor(1, 1, 1, 1)

	button.topText = button:CreateFontString(name.."TopText", "OVERLAY" )
	button.topText:SetSize(button:GetWidth(), button:GetHeight() / 2)
	button.topText:SetJustifyH("RIGHT")
	button.topText:SetJustifyV("TOP")
	button.topText:SetPoint("TOPRIGHT", button, "TOPRIGHT")
	button.topText:SetTextColor(0, 1, 0, 1)

	if number == 1 then
		button.btmText:SetFont(Hekili.LSM:Fetch("font", self.DB.profile[ group..' Font' ]), self.DB.profile[ group..' Primary Font Size' ], "OUTLINE")
		button.topText:SetFont(Hekili.LSM:Fetch("font", self.DB.profile[ group..' Font' ]), self.DB.profile[ group..' Primary Font Size' ], "OUTLINE")
	else
		button.btmText:SetFont(Hekili.LSM:Fetch("font", self.DB.profile[ group..' Font' ]), self.DB.profile[ group..' Queued Font Size' ], "OUTLINE")
		button.topText:SetFont(Hekili.LSM:Fetch("font", self.DB.profile[ group..' Font' ]), self.DB.profile[ group..' Queued Font Size' ], "OUTLINE")
	end

	button:ClearAllPoints()

	if number == 1 then
		-- Position the first icon.
		button:SetPoint(self.DB.profile[set .. ' Relative To'], self.DB.profile[set .. ' X'], self.DB.profile[set .. ' Y'])
		
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

function Hekili:CreateTracker( num )
	local name = 'Hekili_Tracker_'..num

	local button = CreateFrame("Button", name, Hekili.UI.Engine)
	button.desc = 'Hekili Tracker #'..num
	

	button:SetSize( self.DB.profile['Tracker '..num..' Size'], self.DB.profile['Tracker '..num..' Size'] )
	
	button:SetFrameStrata("MEDIUM")
	button:EnableMouse(not Hekili.DB.profile.locked)
	button:SetMovable(not Hekili.DB.profile.locked)
	button:SetClampedToScreen(true)

	button.Texture = button:CreateTexture(nil, "MEDIUM")
	button.Texture:SetAllPoints(button)
	button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')	-- default in case nothing is loaded.
	button.Texture:SetAlpha(1)
	
	button.Cooldown = CreateFrame("Cooldown", name.."_Cooldown" , button, "CooldownFrameTemplate")
	button.Cooldown:SetReverse()
	button.Cooldown:SetAllPoints(button)
	
	button.btmText = button:CreateFontString(name.."BtmText", "OVERLAY" )
	button.btmText:SetSize(button:GetWidth(), button:GetHeight() / 2)
	button.btmText:SetPoint("BOTTOM", button, "BOTTOM")
	button.btmText:SetJustifyH("RIGHT")
	button.btmText:SetJustifyV("BOTTOM")
	button.btmText:SetTextColor(1, 1, 1, 1)

	button.btmText:SetFont(Hekili.LSM:Fetch("font", self.DB.profile[ 'Tracker Font' ]), self.DB.profile[ 'Tracker 1 Font Size' ], "OUTLINE")

	button:ClearAllPoints()

	button:SetPoint(self.DB.profile['Tracker '..num..' Relative To'], self.DB.profile['Tracker '..num..' X'], self.DB.profile['Tracker '..num..' Y'])
		
	button:SetScript("OnEnter", function(self)
		if ( self:IsMovable() ) then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetText(self.desc)
			GameTooltip:AddLine(L["Movable Tooltip"], 1, 1, 1)
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
	
	for i = 1, 5 do
		_, _, relative, x, y = Hekili.UI.Trackers[i]:GetPoint()
		self.DB.profile['Tracker '..i..' Relative To'] = relative
		self.DB.profile['Tracker '..i..' X'] = x
		self.DB.profile['Tracker '..i..' Y'] = y
	end
			
end


function Hekili:RefreshUI()

	self.UI.AButtons['ST'][1]:ClearAllPoints()
	self.UI.AButtons['ST'][1]:SetPoint(self.DB.profile['ST Relative To'], self.DB.profile['ST X'], self.DB.profile['ST Y'])
	self.UI.AButtons['ST'][1]:EnableMouse(not self.DB.profile.locked)
	self.UI.AButtons['ST'][1]:SetMovable(not self.DB.profile.locked)
	self.UI.AButtons['ST'][1]:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'])
	self.UI.AButtons['ST'][1].topText:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'] / 2)
	self.UI.AButtons['ST'][1].btmText:SetSize(self.DB.profile['Single Target Primary Icon Size'], self.DB.profile['Single Target Primary Icon Size'] / 2)

	local font = Hekili.LSM:Fetch("font", self.DB.profile[ 'Single Target Font' ])

	self.UI.AButtons['ST'][1].topText:SetFont(font, self.DB.profile[ 'Single Target Primary Font Size' ], "OUTLINE")
	self.UI.AButtons['ST'][1].btmText:SetFont(font, self.DB.profile[ 'Single Target Primary Font Size' ], "OUTLINE")

	for i = 2, 5 do
		self.UI.AButtons['ST'][i]:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'])
		self.UI.AButtons['ST'][i].topText:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'] / 2)
		self.UI.AButtons['ST'][i].btmText:SetSize(self.DB.profile['Single Target Queued Icon Size'], self.DB.profile['Single Target Queued Icon Size'] / 2)
		self.UI.AButtons['ST'][i]:ClearAllPoints()

		self.UI.AButtons['ST'][i].topText:SetFont(font, self.DB.profile[ 'Single Target Queued Font Size' ], "OUTLINE")
		self.UI.AButtons['ST'][i].btmText:SetFont(font, self.DB.profile[ 'Single Target Queued Font Size' ], "OUTLINE")

		if self.DB.profile['Single Target Queue Direction'] == 'RIGHT' then
			self.UI.AButtons['ST'][i]:SetPoint(self.invDirection[ self.DB.profile['Single Target Queue Direction'] ], self.UI.AButtons['ST'][i-1], self.DB.profile['Single Target Queue Direction'], self.DB.profile['Single Target Icon Spacing'], 0)
		else
			self.UI.AButtons['ST'][i]:SetPoint(self.invDirection[ self.DB.profile['Single Target Queue Direction'] ], self.UI.AButtons['ST'][i-1], self.DB.profile['Single Target Queue Direction'], -1 * self.DB.profile['Single Target Icon Spacing'], 0)
		end
	end


	self.UI.AButtons['AE'][1]:ClearAllPoints()
	self.UI.AButtons['AE'][1]:SetPoint(self.DB.profile['AE Relative To'], self.DB.profile['AE X'], self.DB.profile['AE Y'])
	self.UI.AButtons['AE'][1]:EnableMouse(not self.DB.profile.locked)
	self.UI.AButtons['AE'][1]:SetMovable(not self.DB.profile.locked)
	self.UI.AButtons['AE'][1]:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'])
	self.UI.AButtons['AE'][1].topText:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'] / 2)
	self.UI.AButtons['AE'][1].btmText:SetSize(self.DB.profile['Multi-Target Primary Icon Size'], self.DB.profile['Multi-Target Primary Icon Size'] / 2)

	font = Hekili.LSM:Fetch("font", self.DB.profile[ 'Multi-Target Font' ])

	self.UI.AButtons['AE'][1].topText:SetFont(font, self.DB.profile[ 'Multi-Target Primary Font Size' ], "OUTLINE")
	self.UI.AButtons['AE'][1].btmText:SetFont(font, self.DB.profile[ 'Multi-Target Primary Font Size' ], "OUTLINE")

	for i = 2, 5 do
		self.UI.AButtons['AE'][i]:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'])
		self.UI.AButtons['AE'][i].topText:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'] / 2)
		self.UI.AButtons['AE'][i].btmText:SetSize(self.DB.profile['Multi-Target Queued Icon Size'], self.DB.profile['Multi-Target Queued Icon Size'] / 2)
		self.UI.AButtons['AE'][i]:ClearAllPoints()

		self.UI.AButtons['AE'][i].topText:SetFont(font, self.DB.profile[ 'Multi-Target Queued Font Size' ], "OUTLINE")
		self.UI.AButtons['AE'][i].btmText:SetFont(font, self.DB.profile[ 'Multi-Target Queued Font Size' ], "OUTLINE")

		if self.DB.profile['Multi-Target Queue Direction'] == 'RIGHT' then
			self.UI.AButtons['AE'][i]:SetPoint(self.invDirection[ self.DB.profile['Multi-Target Queue Direction'] ], self.UI.AButtons['AE'][i-1], self.DB.profile['Multi-Target Queue Direction'], self.DB.profile['Multi-Target Icon Spacing'], 0)
		else
			self.UI.AButtons['AE'][i]:SetPoint(self.invDirection[ self.DB.profile['Multi-Target Queue Direction'] ], self.UI.AButtons['AE'][i-1], self.DB.profile['Multi-Target Queue Direction'], -1 * self.DB.profile['Multi-Target Icon Spacing'], 0)
		end
	end

	for i = 1, 5 do
		font = Hekili.LSM:Fetch("font", self.DB.profile[ 'Tracker '..i..' Font' ])

		self.UI.Trackers[i]:SetSize(self.DB.profile[ 'Tracker '..i..' Size' ], self.DB.profile[ 'Tracker '..i..' Size' ])
		self.UI.Trackers[i].btmText:SetSize( self.DB.profile['Tracker '..i..' Size'], self.DB.profile['Tracker '..i..' Size'] / 2)
		self.UI.Trackers[i].btmText:SetFont(font, self.DB.profile[ 'Tracker '..i..' Font Size' ], 'OUTLINE')

		self.UI.Trackers[i]:ClearAllPoints()
		self.UI.Trackers[i]:SetPoint(self.DB.profile['Tracker '..i..' Relative To'], self.DB.profile['Tracker '..i..' X'], self.DB.profile['Tracker '..i..' Y'])
	end

	if self.LBF then
		self.stGroup:ReSkin()
		self.aeGroup:ReSkin()
		self.trGroup:ReSkin()
	end

end


function Hekili:RefreshBindings()
	self.DB.profile['Hekili Hotkey']	= GetBindingKey("HEKILI_TOGGLE") or ''
	self.DB.profile['ST Hotkey']		= GetBindingKey("HEKILI_TOGGLE_SINGLE") or ''
	self.DB.profile['AE Hotkey']		= GetBindingKey("HEKILI_TOGGLE_MULTI") or ''
	self.DB.profile['Cooldown Hotkey']	= GetBindingKey("HEKILI_TOGGLE_COOLDOWNS") or ''
	self.DB.profile['Hardcast Hotkey']	= GetBindingKey("HEKILI_TOGGLE_HARDCASTS") or ''
	self.DB.profile['Integrate Hotkey']	= GetBindingKey("HEKILI_TOGGLE_INTEGRATE") or ''
end	


function Hekili:LockAllButtons( lock )

	for i = 1, 5 do
		self.UI.AButtons.ST[i]:SetMovable(not lock)
		self.UI.AButtons.ST[i]:EnableMouse(not lock)
		self.UI.AButtons.AE[i]:SetMovable(not lock)
		self.UI.AButtons.AE[i]:EnableMouse(not lock)
		self.UI.Trackers[i]:SetMovable(not lock)
		self.UI.Trackers[i]:EnableMouse(not lock)
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
	self.UI.Engine.VisualInterval = 0.05
	self.UI.Engine.VisualDelay = 0

	self.UI.Engine.Interval = (1.0 / self.DB.profile['Updates Per Second'])
	self.UI.Engine.Delay = 0

	self.UI.Engine.AuditorInterval = 0.5
	self.UI.Engine.AuditorDelay = 0
	
    self.UI.Engine:SetScript("OnUpdate", function(self, elapsed)
		self.VisualDelay = self.VisualDelay - elapsed
		self.Delay = self.Delay - elapsed
		self.AuditorDelay = self.AuditorDelay - elapsed

		if Hekili:IsEnabled() and UnitHealth('player') > 0 then
			if self.AuditorDelay <= 0 then
				Hekili:Audit()
				self.AuditorDelay = self.AuditorInterval
			end

			if self.VisualDelay <= 0 then
				Hekili:MaintainActionLists()
				Hekili:UpdateVisuals()
				self.VisualDelay = self.VisualInterval
			end

			if self.Delay <= 0 then
				Hekili:HeartBeat()
				self.Delay = self.Interval
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
	
	self.UI.Trackers = {}
	for i = 1, 5 do
		self.UI.Trackers[i] = self:CreateTracker( i )
		if self.LBF then self.trGroup:AddButton( self.UI.Trackers[i], { Icon = self.UI.Trackers[i].Texture, Cooldown = self.UI.Trackers[i].Cooldown } ) end
	end
	
	self.CoreInitialized = true
end