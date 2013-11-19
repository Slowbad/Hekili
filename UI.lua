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
	button:EnableMouse(not Hekili.DB.char.locked)
	button:SetMovable(not Hekili.DB.char.locked)
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
	button.btmText:SetSize(button:GetWidth(), button:GetHeight() / 3)
	-- button.btmText:SetTextHeight(button:GetHeight() / 3)
	button.btmText:SetPoint("BOTTOM", button, "BOTTOM")
	button.btmText:SetTextColor(1, 1, 1, 1)
		
	button.topText = button:CreateFontString(name.."TopText", "OVERLAY", "SystemFont_Outline_Small" )
	button.topText:SetSize(button:GetWidth(), button:GetHeight() / 3)
	-- button.topText:SetTextHeight(button:GetHeight() / 3)
	button.topText:SetJustifyH("RIGHT")
	button.topText:SetPoint("TOPRIGHT", button, "TOPRIGHT")
	button.topText:SetTextColor(0, 1, 0, 1)
		
	button:ClearAllPoints()

	if number == 1 then
		-- Position the first icon.
		button:SetPoint(self.DB.char[set .. ' Relative To'], self.DB.char[set .. ' X'], self.DB.char[set .. ' Y'])
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

	button:Show()

	return button
end


function Hekili:SaveCoordinates()
	local _, _, relative, x, y = Hekili.UI.AButtons['ST'][1]:GetPoint()
	self.DB.char['ST Relative To'] = relative
	self.DB.char['ST X'] = x
	self.DB.char['ST Y'] = y

	_, _, relative, x, y = Hekili.UI.AButtons['AE'][1]:GetPoint()
	self.DB.char['AE Relative To'] = relative
	self.DB.char['AE X'] = x
	self.DB.char['AE Y'] = y
end


function Hekili:LockAllButtons( lock )

	local alpha = 0
	if not lock then alpha = 1 end

	for i = 1, 5 do
		Hekili.UI.AButtons.ST[i]:SetMovable(not lock)
		Hekili.UI.AButtons.ST[i]:EnableMouse(not lock)
		Hekili.UI.AButtons.AE[i]:SetMovable(not lock)
		Hekili.UI.AButtons.AE[i]:EnableMouse(not lock)
		-- Hekili.UI.AButtons.CD[i]:SetMovable(not lock)
		-- Hekili.UI.AButtons.CD[i]:EnableMouse(not lock)
	end

end


function Hekili:InitCoreUI()

	if Hekili.CoreInitialized then
		return
	end

	Hekili.UI.Engine = CreateFrame("Frame", "Hekili_Engine_Frame", UIParent)
	Hekili.UI.Engine:SetFrameStrata("BACKGROUND")
	Hekili.UI.Engine:SetClampedToScreen(true)
	Hekili.UI.Engine:SetMovable(false)
	Hekili.UI.Engine:EnableMouse(false)
	Hekili.UI.Engine:SetAllPoints(UIParent)

	-- Engine Values
	Hekili.UI.Engine.Interval = 0.1
	Hekili.UI.Engine.Delay = 0

    Hekili.UI.Engine:SetScript("OnUpdate", function(self, elapsed)
		self.Delay = self.Delay - elapsed
		if Hekili.DB.char.enabled and self.Delay <= 0 and UnitHealth("player") > 0 then
			Hekili:HeartBeat()
			self.Delay = self.Interval
		end
	end)

	-- For tooltip parsing.
	if not Hekili.Tooltip then Hekili.Tooltip = CreateFrame("GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate") end

	-- Display Elements
	Hekili.UI.AButtons = {}
	Hekili.UI.AButtons['ST'] = {}
	for i = 1, 5 do
		Hekili.UI.AButtons.ST[i] = Hekili:CreatePriorityButton( 'ST', i )
		if Hekili.LBF then Hekili.stGroup:AddButton( Hekili.UI.AButtons.ST[i], { Icon = Hekili.UI.AButtons.ST[i].Texture, Cooldown = Hekili.UI.AButtons.ST[i].Cooldown } ) end	
	end

	Hekili.UI.AButtons['AE'] = {}
	for i = 1, 5 do
		Hekili.UI.AButtons.AE[i] = Hekili:CreatePriorityButton( 'AE', i )
		if Hekili.LBF then Hekili.aeGroup:AddButton( Hekili.UI.AButtons.AE[i], { Icon = Hekili.UI.AButtons.AE[i].Texture, Cooldown = Hekili.UI.AButtons.AE[i].Cooldown } ) end	
	end

	Hekili.CoreInitialized = true
end