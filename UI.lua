-- UI.lua
-- Dynamic UI Elements

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class

local getInverseDirection = ns.getInverseDirection
local multiUnpack = ns.multiUnpack
local round = ns.round


if ns.lib.Masque then
  ns.MasqueGroup = ns.lib.Masque:Group( addon )
  if not ns.MasqueGroup then ns.lib.Masque = nil end
end


-- Builds and maintains the visible UI elements.
-- Buttons (as frames) are never deleted, but should get reused effectively.
function ns.buildUI()

	ns.cacheCriteria()
	
	if not ns.UI.Engine then
		ns.UI.Engine = CreateFrame( "Frame", "Hekili_Engine_Frame", UIParent)
		ns.UI.Engine:SetFrameStrata("BACKGROUND")
		ns.UI.Engine:SetClampedToScreen(true)
		ns.UI.Engine:SetMovable(false)
		ns.UI.Engine:EnableMouse(false)
	end
	
	ns.UI.Buttons	= ns.UI.Buttons or {}
	
	for dispID, display in ipairs( Hekili.DB.profile.displays ) do
		ns.UI.Buttons[dispID] = ns.UI.Buttons[dispID] or {}
		
		if not Hekili[ 'ProcessDisplay'..dispID ] then
			Hekili[ 'ProcessDisplay'..dispID ] = function()
				Hekili:ProcessHooks( dispID )
			end
		end

		for i = 1, max( #ns.UI.Buttons[dispID], display['Icons Shown'] ) do
			ns.UI.Buttons[dispID][i] = Hekili:CreateButton( dispID, i )
			
			ns.UI.Buttons[dispID][i]:Hide()

			if ns.visible.display[ dispID ] and i <= display[ 'Icons Shown' ] then
				ns.UI.Buttons[dispID][i]:Show()
			end
			
			if ns.MasqueGroup then ns.MasqueGroup:AddButton( ns.UI.Buttons[dispID][i], { Icon = ns.UI.Buttons[dispID][i].Texture, Cooldown = ns.UI.Buttons[dispID][i].Cooldown } ) end	
		end
		
	end

	if ns.MasqueGroup then ns.MasqueGroup:ReSkin() end
	
	-- Check for a display that has been removed.
	for display, buttons in ipairs( ns.UI.Buttons ) do
		if not Hekili.DB.profile.displays[display] then
			for i,_ in ipairs( buttons) do
				buttons[i]:Hide()
			end
		end
	end
	
end


local T = ns.lib.Format.Tokens
local SyntaxColors = {};

function ns.primeTooltipColors()
	T = ns.lib.Format.Tokens;
	--- Assigns a color to multiple tokens at once.
	local function Color ( Code, ... )
		for Index = 1, select( "#", ... ) do
			SyntaxColors[ select( Index, ... ) ] = Code;
		end
	end
	Color( "|cffB266FF", T.KEYWORD ) -- Reserved words

	Color( "|cffffffff", T.LEFTCURLY, T.RIGHTCURLY,
		T.LEFTBRACKET, T.RIGHTBRACKET,
		T.LEFTPAREN, T.RIGHTPAREN )
		
	Color( "|cffFF66FF", T.UNKNOWN, T.ADD, T.SUBTRACT, T.MULTIPLY, T.DIVIDE, T.POWER, T.MODULUS,
		T.CONCAT, T.VARARG, T.ASSIGNMENT, T.PERIOD, T.COMMA, T.SEMICOLON, T.COLON, T.SIZE,
		T.EQUALITY, T.NOTEQUAL, T.LT, T.LTE, T.GT, T.GTE )

	Color( "|cFFB2FF66", multiUnpack( ns.keys, ns.attr ) )
	
	Color( "|cffFFFF00", T.NUMBER )
	Color( "|cff888888", T.STRING, T.STRING_LONG )
	Color( "|cff55cc55", T.COMMENT_SHORT, T.COMMENT_LONG )
	Color( "|cff55ddcc", -- Minimal standard Lua functions
		"assert", "error", "ipairs", "next", "pairs", "pcall", "print", "select",
		"tonumber", "tostring", "type", "unpack",
		-- Libraries
		"bit", "coroutine", "math", "string", "table" )
	Color( "|cffddaaff", -- Some of WoW's aliases for standard Lua functions
		-- math
		"abs", "ceil", "floor", "max", "min",
		-- string
		"format", "gsub", "strbyte", "strchar", "strconcat", "strfind", "strjoin",
		"strlower", "strmatch", "strrep", "strrev", "strsplit", "strsub", "strtrim",
		"strupper", "tostringall",
		-- table
		"sort", "tinsert", "tremove", "wipe" )
end


local SpaceLeft = { "(%()" }
local SpaceRight = { "(%))" }
local DoubleSpace = { "(!=)", "(~=)", "(>=*)", "(<=*)", "(&)", "(||)", "(+)", "(*)", "(-)", "(/)" }


local function Format ( Code )
	for Index = 1, #SpaceLeft do
		Code = Code:gsub( "%s-"..SpaceLeft[Index].."%s-", " %1")
	end

	for Index = 1, #SpaceRight do
		Code = Code:gsub( "%s-"..SpaceRight[Index].."%s-", "%1 ")
	end

	for Index = 1, #DoubleSpace do
		Code = Code:gsub( "%s-"..DoubleSpace[Index].."%s-", " %1 ")
	end
	
	Code = Code:gsub( "([^<>~!])(=+)", "%1 %2 ")
	Code = Code:gsub( "%s+", " " ):trim()
	return Code
end


function Hekili:ShowDiagnosticTooltip( q )
	ns.Tooltip:SetOwner( UIParent, "ANCHOR_CURSOR" )
	ns.Tooltip:SetBackdropColor( 0, 0, 0, 1 )
	ns.Tooltip:SetText( class.abilities[ q.actName ].name )
	ns.Tooltip:AddDoubleLine( q.alName.." #"..q.action, "+" .. round( q.time, 2 ) .."s", 1, 1, 1, 1, 1, 1 )

	if q.HookScript and q.HookScript ~= "" then
		ns.Tooltip:AddLine( "\nHook Criteria" )
		
		local Text = Format ( q.HookScript )
		ns.Tooltip:AddLine( ns.lib.Format:ColorString( Text, SyntaxColors ), 1, 1, 1, 1 )
		
		if q.HookElements then
			ns.Tooltip:AddLine( "Values" )
			for k, v in pairs( q.HookElements ) do
				ns.Tooltip:AddDoubleLine( k, ns.formatValue( v ) , 1, 1, 1, 1, 1, 1 )
			end
		end
	end
	
	if q.ActScript and q.ActScript ~= "" then
		ns.Tooltip:AddLine( "\nAction Criteria" )
		
		local Text = Format ( q.ActScript )
		ns.Tooltip:AddLine( ns.lib.Format:ColorString( Text, SyntaxColors ), 1, 1, 1, 1 )
		
		if q.ActElements then
			ns.Tooltip:AddLine( "Values" )
			for k,v in pairs( q.ActElements ) do
				ns.Tooltip:AddDoubleLine( k, ns.formatValue( v ) , 1, 1, 1, 1, 1, 1 )
			end
		end
	end
	ns.Tooltip:Show()
end


function Hekili:CreateButton( display, ID )
	
	local name = "Hekili_D" .. display .. "_B" .. ID
	local disp = self.DB.profile.displays[display]
	
	local button = ns.UI.Buttons[ display ][ ID ] or CreateFrame( "Button", name, ns.UI.Engine )
	
	local btnSize
	if ID == 1 then
		btnSize = disp['Primary Icon Size']
	else
		btnSize = disp['Queued Icon Size']
	end
	local btnDirection	= disp['Queue Direction']
	local btnSpacing	= disp['Spacing']
	
	button:SetFrameStrata( "LOW" )
	button:SetFrameLevel( 100 - display )
	button:SetParent(UIParent)
	button:EnableMouse( not self.DB.profile.Locked )
	button:SetMovable( not self.DB.profile.Locked )
	button:SetClampedToScreen( true )
	
	button:SetSize( btnSize, btnSize )
	
	if not button.Texture then
		button.Texture = button:CreateTexture(nil, "LOW")
		button.Texture:SetAllPoints(button)
		button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')
		button.Texture:SetAlpha(1)
	end
	
	if display == 1 and ID == 1 then
		button.Notification = button.Notification or button:CreateFontString("HekiliNotification", "OVERLAY")
		button.Notification:SetSize( disp['Primary Icon Size'] * 2 + disp["Spacing"], disp['Primary Icon Size'] )
		button.Notification:ClearAllPoints()
		button.Notification:SetPoint( btnDirection, name, getInverseDirection( btnDirection ), 0, 0 )
		button.Notification:SetJustifyV( "CENTER" )
		button.Notification:SetTextColor(1, 0, 0, 0)
		button.Notification:SetTextHeight( disp['Primary Icon Size'] / 3 )
    button.Notification:SetFont( ns.lib.SharedMedia:Fetch("font", disp.Font), disp['Primary Icon Size'] / 2.5, "OUTLINE" )		
	end
	
	button.Caption = button.Caption or button:CreateFontString(name.."Caption", "OVERLAY" )
	button.Caption:SetSize( button:GetWidth(), button:GetHeight() / 2)
	button.Caption:SetPoint( "BOTTOM", button, "BOTTOM" )
	button.Caption:SetJustifyV( "BOTTOM" )
	button.Caption:SetTextColor(1, 1, 1, 1)
	
	button.Cooldown = button.Cooldown or CreateFrame("Cooldown", name .. "_Cooldown", button, "CooldownFrameTemplate")
	button.Cooldown:SetAllPoints(button)
	
	button:ClearAllPoints()
	
	if ID == 1 then
		button.Overlay = button.Overlay or button:CreateTexture(nil, "LOW")
		button.Overlay:SetAllPoints(button)
		button.Overlay:Hide()
		
		button.Caption:SetFont( ns.lib.SharedMedia:Fetch("font", disp.Font), disp['Primary Font Size'], "OUTLINE" )

		button:SetPoint( self.DB.profile.displays[ display ].rel or "CENTER", self.DB.profile.displays[ display ].x, self.DB.profile.displays[ display ].y )
		
		button:SetScript( "OnMouseDown", function(self, btn)
			if ( Hekili.Config or not Hekili.DB.profile.Locked ) and btn == "LeftButton" and not self.Moving then
				self:StartMoving()
				self.Moving = true
			end
		end )
		
		button:SetScript( "OnMouseUp", function(self, btn)
			if ( btn == "LeftButton" and self.Moving ) then
				self:StopMovingOrSizing()
				Hekili:SaveCoordinates()
				self.Moving = false
			elseif ( btn == "RightButton" and not Hekili.Config and not Hekili.Pause ) then
				x_offset, y_offset = self:GetCenter()
				self:StopMovingOrSizing()
				self.Moving = false
				Hekili.DB.profile.Locked = true
				self:SetMovable( not Hekili.DB.profile.Locked )
				self:EnableMouse( not Hekili.DB.profile.Locked )
				-- Hekili:SetOption( { "locked" }, true )
				GameTooltip:Hide()
			end
			Hekili:SaveCoordinates()
		end )
	
	else
		button.Caption:SetFont( ns.lib.SharedMedia:Fetch("font", disp.Font), disp['Queued Font Size'], "OUTLINE" )

		if btnDirection == 'RIGHT' then
			button:SetPoint( getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection, btnSpacing, 0 )
		elseif btnDirection == 'LEFT' then
			button:SetPoint( getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection, -1 *  btnSpacing, 0 )
		elseif btnDirection == 'TOP' then
			button:SetPoint( getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection, 0, btnSpacing )
		else -- BOTTOM
			button:SetPoint( getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection, 0, -1 * btnSpacing )
		end

	end
	
	button:SetScript( "OnEnter", function(self)
		if ( ID == 1 and ( not Hekili.Pause ) and ( Hekili.Config or not Hekili.DB.profile.Locked ) ) then
			ns.Tooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			ns.Tooltip:SetBackdropColor( 0, 0, 0, 1 )
			ns.Tooltip:SetText(Hekili.DB.profile.displays[ display ].Name .. " (" .. display .. ")")
			ns.Tooltip:AddLine("Left-click and hold to move.", 1, 1, 1)
			if not Hekili.Config or not Hekili.DB.profile.Locked then ns.Tooltip:AddLine("Right-click to lock all and close.",1 ,1 ,1)  end
			ns.Tooltip:Show()
			self:SetMovable(true)
		elseif ( Hekili.Pause and ns.queue[ display ] and ns.queue[ display ][ ID ] ) then
			Hekili:ShowDiagnosticTooltip( ns.queue[ display ][ ID ] )
		else
			self:SetMovable(false)
			self:EnableMouse(false)
		end
	end )
	
	button:SetScript( "OnLeave", function(self)
		ns.Tooltip:Hide()
	end )
	
	return button

end


function Hekili:SaveCoordinates()
	for k,_ in pairs(ns.UI.Buttons) do
		local _, _, rel, x, y = ns.UI.Buttons[k][1]:GetPoint()
		
		self.DB.profile.displays[k].rel = rel
		self.DB.profile.displays[k].x = x
		self.DB.profile.displays[k].y = y
	end
end