-- UI.lua
-- Dynamic UI Elements

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class

local getInverseDirection = ns.getInverseDirection
local multiUnpack = ns.multiUnpack
local round = ns.round

local Masque, MasqueGroup


local function Mover_OnMouseUp( self, btn )
  if ( btn == "LeftButton" and self.Moving ) then
    self:StopMovingOrSizing()
    Hekili:SaveCoordinates()
    self.Moving = false
  elseif ( btn == "RightButton" and not Hekili.Config ) then
    self:StopMovingOrSizing()
    self.Moving = false
    Hekili.DB.profile.Locked = true
   	local MouseInteract = ( Hekili.DB.profile.Debug and Hekili.Pause ) or Hekili.Config or ( not Hekili.DB.profile.Locked )
    for i = 1, #ns.UI.Buttons do
      for j = 1, #ns.UI.Buttons[i] do
        ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
      end
    end
    -- Hekili:SetOption( { "locked" }, true )
    GameTooltip:Hide()
  end
  Hekili:SaveCoordinates()
end


local function Mover_OnMouseDown( self, btn )
  if ( Hekili.Config or not Hekili.DB.profile.Locked ) and btn == "LeftButton" and not self.Moving then
    self:StartMoving()
    self.Moving = true
  end
end 


local function Button_OnMouseDown( self, btn )
  local display = self:GetName():match("Hekili_D(%d+)_B(%d+)")
  local mover = _G[ "HekiliDisplay" .. display ]
  if ( Hekili.Config or not Hekili.DB.profile.Locked ) and btn == "LeftButton" and not self.Moving then
    mover:StartMoving()
    mover.Moving = true
  end
end 


local function Button_OnMouseUp( self, btn )
  local display = self:GetName():match("Hekili_D(%d+)_B(%d+)")
  local mover = _G[ "HekiliDisplay" .. display ]
  if ( btn == "LeftButton" and mover.Moving ) then
    mover:StopMovingOrSizing()
    mover.Moving = false
    Hekili:SaveCoordinates()
  elseif ( btn == "RightButton" and not Hekili.Config ) then
    mover:StopMovingOrSizing()
    mover.Moving = false
    Hekili.DB.profile.Locked = true
   	local MouseInteract = ( Hekili.DB.profile.Debug and Hekili.Pause ) or Hekili.Config or ( not Hekili.DB.profile.Locked )
    for i = 1, #ns.UI.Buttons do
      for j = 1, #ns.UI.Buttons[i] do
        ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
      end
    end
    -- Hekili:SetOption( { "locked" }, true )
    GameTooltip:Hide()
  end
  Hekili:SaveCoordinates()
end


function ns.StartConfiguration()
  Hekili.Config = true

  local scaleFactor = 1
  if GetCVar( "UseUIScale" ) == 1 then
    scaleFactor = GetScreenHeight() / select( GetCurrentResolution(), GetScreenResolutions() ):match("%d+x(%d+)")
  end

  -- Notification Panel
  ns.UI.Notification:EnableMouse(true)
  ns.UI.Notification:SetMovable(true)
  ns.UI.Notification.Mover = ns.UI.Notification.Mover or CreateFrame( "Frame", "HekiliNotificationMover", ns.UI.Notification )
  ns.UI.Notification.Mover:SetAllPoints(HekiliNotification)
  -- ns.UI.Notification.Mover:SetHeight(20)
  ns.UI.Notification.Mover:SetBackdrop( {
      bgFile	 	= "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile 	= "Interface/Tooltips/UI-Tooltip-Border",
      tile		  = false,
      tileSize 	= 0,
      edgeSize 	= 2,
      insets 		= { left = 0, right = 0, top = 0, bottom = 0 }
    } )
	ns.UI.Notification.Mover:SetBackdropColor(.1, .1, .1, .8)
  ns.UI.Notification.Mover:SetBackdropBorderColor(.1, .1, .1, .5)
  ns.UI.Notification.Mover:Show()
  
  f = ns.UI.Notification
  f.Header = f.Header or f:CreateFontString( "HekiliNotificationHeader", "OVERLAY", "GameFontNormal" )
  f.Header:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor * 0.5, 20 )
  f.Header:SetText( "Notifications" )
  f.Header:SetJustifyH( "LEFT" )
  f.Header:SetPoint( "BOTTOMLEFT", f, "TOPLEFT" )
  f.Header:Show()

  HekiliNotification:SetScript( "OnMouseDown", Mover_OnMouseDown )
  HekiliNotification:SetScript( "OnMouseUp", Mover_OnMouseUp )  
  
  for i,v in ipairs(ns.UI.Displays) do
    if v.Mover then v.Mover:Hide() end
    if v.Header then v.Header:Hide() end
    
    if ns.UI.Buttons[i][1] and ns.visible.display[ i ] and Hekili.DB.profile.displays[ i ] then
      v:EnableMouse(true)
      v:SetMovable(true)
      -- v.Mover:EnableMouse(true)
      -- v.Mover:SetMovable(true)

      v:SetBackdrop( {
          bgFile	 	= "Interface/Tooltips/UI-Tooltip-Background",
          edgeFile 	= "Interface/Tooltips/UI-Tooltip-Border",
          tile		  = false,
          tileSize 	= 0,
          edgeSize 	= 2,
          insets 		= { left = 0, right = 0, top = 0, bottom = 0 }
        } )
      v:SetBackdropColor(.1, .1, .1, .8)
      v:SetBackdropBorderColor(.1, .1, .1, .5)
      v:SetScript( "OnMouseDown", Mover_OnMouseDown )
      v:SetScript( "OnMouseUp", Mover_OnMouseUp )
      v:Show()
  
      v.Header = v.Header or v:CreateFontString( "HekiliDisplay"..i.."Header", "OVERLAY", "GameFontNormal" )
      v.Header:SetSize( v:GetWidth() * 0.5, 20 )
      v.Header:SetText( Hekili.DB.profile.displays[ i ].Name )
      v.Header:SetJustifyH( "LEFT" )
      v.Header:SetPoint( "BOTTOMLEFT", v, "TOPLEFT" )
      v.Header:Show()
    else
      v:Hide()
    end
  end
  
  -- HekiliNotification:EnableMouse(true)
  -- HekiliNotification:SetMovable(true)
  ns.lib.AceConfigDialog:SetDefaultSize( "Hekili", 785, 555 )
  ns.lib.AceConfigDialog:Open("Hekili")
  ns.OnHideFrame = ns.OnHideFrame or CreateFrame("Frame", nil)
  ns.OnHideFrame:SetParent( ns.lib.AceConfigDialog.OpenFrames["Hekili"].frame )
  ns.OnHideFrame:SetScript( "OnHide", function(self)
    ns.StopConfiguration()
    self:SetScript("OnHide", nil)
    collectgarbage()
  end )
  
end



function ns.StopConfiguration()
  Hekili.Config = false
  
  local scaleFactor = 1
  if GetCVar( "UseUIScale" ) == 1 then
    scaleFactor = GetScreenHeight() / select( GetCurrentResolution(), GetScreenResolutions() ):match("%d+x(%d+)")
  end

	local MouseInteract = ( Hekili.DB.profile.Debug and Hekili.Pause ) or ( not Hekili.DB.profile.Locked )
  
  for i,v in ipairs(ns.UI.Buttons) do
    for j, btn in ipairs(v) do
      btn:EnableMouse( MouseInteract )
      btn:SetMovable( not Hekili.DB.profile.Locked )
    end
  end

  HekiliNotification:EnableMouse( MouseInteract )
  HekiliNotification:SetMovable( not Hekili.DB.profile.Locked )
  HekiliNotification.Mover:Hide()
  HekiliNotification.Header:Hide()
  
 for i,v in ipairs(ns.UI.Displays) do
    v:EnableMouse( false )
    v:SetMovable( true )
    v:SetBackdrop( nil )
    if v.Header then v.Header:Hide() end
  end
  
end  
  

-- Builds and maintains the visible UI elements.
-- Buttons (as frames) are never deleted, but should get reused effectively.
function ns.buildUI()

  if not Masque then
    Masque = LibStub( "Masque", true )
    
    if Masque then MasqueGroup = Masque:Group( addon ) end
  end

	ns.cacheCriteria()
	
	if not ns.UI.Engine then
		ns.UI.Engine = CreateFrame( "Frame", "Hekili_Engine_Frame", UIParent )
		ns.UI.Engine:SetFrameStrata("BACKGROUND")
		ns.UI.Engine:SetClampedToScreen(true)
		ns.UI.Engine:SetMovable(false)
		ns.UI.Engine:EnableMouse(false)
	end
	
  local scaleFactor = 1
  if GetCVar( "UseUIScale" ) == 1 then
    scaleFactor = GetScreenHeight() / select( GetCurrentResolution(), GetScreenResolutions() ):match("%d+x(%d+)")
  end

	local MouseInteract = ( Hekili.DB.profile.Debug and Hekili.Pause ) or ( not Hekili.DB.profile.Locked )
  
  local f = ns.UI.Notification or CreateFrame( "Frame", "HekiliNotification", UIParent )
  f:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor, Hekili.DB.profile['Notification Height'] * scaleFactor )
  f:SetClampedToScreen( true )
  f:ClearAllPoints()
  f:SetPoint( "CENTER", Hekili.DB.profile['Notification X'], Hekili.DB.profile['Notification Y'] )
  
  f.Text = f.Text or f:CreateFontString( "HekiliNotificationText", "OVERLAY" )
  f.Text:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor, Hekili.DB.profile['Notification Height'] * scaleFactor )
	f.Text:SetPoint( "TOP", f, "TOP" )
	f.Text:SetFont( ns.lib.SharedMedia:Fetch("font", Hekili.DB.profile['Notification Font']), Hekili.DB.profile['Notification Height'] * scaleFactor * 0.8, "OUTLINE" )
	f.Text:SetJustifyV( "MIDDLE" )
	f.Text:SetTextColor(1, 1, 1, 1)
  
  ns.UI.Notification = f
  
  if not Hekili.DB.profile['Notification Enabled'] then
    ns.UI.Notification:Hide()
  else
    ns.UI.Notification.Text:SetText(nil)
    ns.UI.Notification:Show()
  end
  
  ns.UI.Displays = ns.UI.Displays or {}
	ns.UI.Buttons	= ns.UI.Buttons or {}
  
	for dispID, display in ipairs( Hekili.DB.profile.displays ) do
    
    local f = ns.UI.Displays[dispID] or CreateFrame( "Frame", "HekiliDisplay"..dispID, UIParent )
    
    f:SetSize( Hekili.DB.profile.displays[dispID]['Primary Icon Size'] + ( Hekili.DB.profile.displays[dispID]['Queued Icon Size'] * ( Hekili.DB.profile.displays[dispID]['Icons Shown'] - 1 ) ) + ( Hekili.DB.profile.displays[dispID]['Spacing'] * ( Hekili.DB.profile.displays[dispID]['Icons Shown'] - 1 ) ), Hekili.DB.profile.displays[dispID]['Primary Icon Size'] )
    f:SetPoint( "CENTER", Hekili.DB.profile.displays[ dispID ].x, Hekili.DB.profile.displays[ dispID ].y )
    f:SetClampedToScreen( true )
    f:EnableMouse( false )
    f:SetMovable( true )
    ns.UI.Displays[dispID] = f

    ns.UI.Buttons[dispID] = ns.UI.Buttons[dispID] or {}
		
		if not Hekili[ 'ProcessDisplay'..dispID ] then
			Hekili[ 'ProcessDisplay'..dispID ] = function()
				Hekili:ProcessHooks( dispID )
			end
		end

		for i = 1, max( #ns.UI.Buttons[dispID], display['Icons Shown'] ) do
			ns.UI.Buttons[dispID][i] = Hekili:CreateButton( dispID, i )
			ns.UI.Buttons[dispID][i]:Hide()

			if Hekili.DB.profile.Enabled and ns.visible.display[ dispID ] and i <= display[ 'Icons Shown' ] then
        local alpha = ns.CheckDisplayCriteria and ns.CheckDisplayCriteria( dispID ) or 0
        if alpha > 0 then
          ns.UI.Buttons[dispID][i]:SetAlpha( alpha )
          ns.UI.Buttons[dispID][i]:Show()
        end
			end
			
			if MasqueGroup then MasqueGroup:AddButton( ns.UI.Buttons[dispID][i], { Icon = ns.UI.Buttons[dispID][i].Texture, Cooldown = ns.UI.Buttons[dispID][i].Cooldown } ) end	
		end
		
	end

  --if Hekili.Config then ns.StartConfiguration() end
	if MasqueGroup then MasqueGroup:ReSkin() end
	
	-- Check for a display that has been removed.
	for display, buttons in ipairs( ns.UI.Buttons ) do
		if not Hekili.DB.profile.displays[display] then
			for i,_ in ipairs( buttons) do
				buttons[i]:Hide()
			end
		end
	end
	
  if Hekili.Config then ns.StartConfiguration() end
  
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
	
	local button = ns.UI.Buttons[ display ][ ID ] or CreateFrame( "Button", name, ns.UI.Displays[ display ] )
	
	local btnSize
	if ID == 1 then
		btnSize = disp['Primary Icon Size']
	else
		btnSize = disp['Queued Icon Size']
	end
	local btnDirection	= disp['Queue Direction']
	local btnSpacing	= disp['Spacing']

  local scaleFactor = 1
  if GetCVar( "UseUIScale" ) == 1 then
    scaleFactor = GetScreenHeight() / select( GetCurrentResolution(), GetScreenResolutions() ):match("%d+x(%d+)")
  end

	button:SetFrameStrata( "LOW" )
	button:SetClampedToScreen( true )
	
	button:SetSize( scaleFactor * btnSize, scaleFactor * btnSize )
	
	if not button.Texture then
		button.Texture = button:CreateTexture(nil, "LOW")
		button.Texture:SetAllPoints(button)
		button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')
		button.Texture:SetAlpha(1)
	end
	
	button.Caption = button.Caption or button:CreateFontString(name.."Caption", "OVERLAY" )
	button.Caption:SetSize( scaleFactor * button:GetWidth(), scaleFactor * button:GetHeight() / 2)
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

		button:SetPoint( "LEFT", ns.UI.Displays[ display ], "LEFT" ) -- self.DB.profile.displays[ display ].rel or "CENTER", self.DB.profile.displays[ display ].x, self.DB.profile.displays[ display ].y )
    
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
	
  button:SetScript( "OnMouseDown", Button_OnMouseDown )
  button:SetScript( "OnMouseUp", Button_OnMouseUp )  

  button:SetScript( "OnEnter", function(self)
    if ( not Hekili.Pause ) or ( Hekili.Config or not Hekili.DB.profile.Locked ) then
      ns.Tooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
      ns.Tooltip:SetBackdropColor( 0, 0, 0, 1 )
      ns.Tooltip:SetText(Hekili.DB.profile.displays[ display ].Name .. " (" .. display .. ")")
      ns.Tooltip:AddLine("Left-click and hold to move.", 1, 1, 1)
      if not Hekili.Config or not Hekili.DB.profile.Locked then ns.Tooltip:AddLine("Right-click to lock all and close.",1 ,1 ,1) end
      ns.Tooltip:Show()
      self:SetMovable(true)
    elseif ( Hekili.Pause and ns.queue[ display ] and ns.queue[ display ][ ID ] ) then
      Hekili:ShowDiagnosticTooltip( ns.queue[ display ][ ID ] )
    end
  end )

  button:SetScript( "OnLeave", function(self)
    ns.Tooltip:Hide()
  end )
    
	button:EnableMouse( not Hekili.DB.profile.Locked )
	button:SetMovable( not Hekili.DB.profile.Locked )
	
	return button

end


function Hekili:SaveCoordinates()
	for i in pairs(Hekili.DB.profile.displays) do
		local _, _, rel, x, y = ns.UI.Displays[i]:GetPoint()
		
		self.DB.profile.displays[i].rel = "CENTER"
		self.DB.profile.displays[i].x = x
		self.DB.profile.displays[i].y = y
	end
  
  _, _, _, self.DB.profile['Notification X'], self.DB.profile['Notification Y'] = HekiliNotification:GetPoint()
  
end