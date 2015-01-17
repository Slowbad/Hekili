-- Hekili.lua
-- April 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local buildUI = ns.buildUI
local callHook = ns.callHook
local checkScript = ns.checkScript
local formatKey = ns.formatKey
local getSpecializationID = ns.getSpecializationID
local getResourceName = ns.getResourceName
local initializeClassModule = ns.initializeClassModule
local isKnown = ns.isKnown
local isUsable = ns.isUsable
local loadScripts = ns.loadScripts
local refreshBindings = ns.refreshBindings
local refreshOptions = ns.refreshOptions
local restoreDefaults = ns.restoreDefaults
local runHandler = ns.runHandler
local tableCopy = ns.tableCopy
local timeToReady = ns.timeToReady

local mt_resource = ns.metatables.mt_resource

local trim = string.trim


-- checkImports()
-- Remove any displays or action lists that were unsuccessfully imported.
local checkImports = function ()

  local profile = Hekili.DB.profile

  for i = #profile.displays, 1, -1 do
    local display = profile.displays[ i ]
		if type( display ) ~= 'table' then
			table.remove( profile.displays, i )
		elseif display.Name:match("^@") then
      -- Remove old defaults.
      table.remove( profile.displays, i )
    elseif not display['Force Targets'] then
      display['Force Targets'] = 1
    end
	end
	
	for i = #profile.actionLists, 1, -1 do
    local list = profile.actionLists[ i ]
		if type( list ) ~= 'table' or list.Name:match("^@") then
			for dispID, display in ipairs( profile.displays ) do
				for hookID, hook in ipairs ( display.Queues ) do
					if hook[ 'Action List' ] == i then
						hook[ 'Action List' ] = 0
						hook.Enabled = false
					elseif hook[ 'Action List' ] > i then
						hook[ 'Action List' ] = hook[ 'Action List' ] - 1
					end
				end
			end
			table.remove( profile.actionLists, i )
    end
	end
  
end


-- OnInitialize()
-- Addon has been loaded by the WoW client (1x).
function Hekili:OnInitialize()
	self.DB = LibStub( "AceDB-3.0" ):New( "HekiliDB", self:GetDefaults() )
	
	self.Options = self:GetOptions()
	self.Options.args.profiles = LibStub( "AceDBOptions-3.0" ):GetOptionsTable( self.DB )
	
	-- Add dual-spec support
	ns.lib.LibDualSpec:EnhanceDatabase( self.DB, "Hekili" )
	ns.lib.LibDualSpec:EnhanceOptions( self.Options.args.profiles, self.DB )

	self.DB.RegisterCallback( self, "OnProfileChanged", "TotalRefresh" )
	self.DB.RegisterCallback( self, "OnProfileCopied", "TotalRefresh" )
	self.DB.RegisterCallback( self, "OnProfileReset", "TotalRefresh" )
	
	ns.lib.AceConfig:RegisterOptionsTable( "Hekili", self.Options )
	self.optionsFrame = ns.lib.AceConfigDialog:AddToBlizOptions( "Hekili", "Hekili" )
	self:RegisterChatCommand( "hekili", "CmdLine" )
	self:RegisterChatCommand( "hek", "CmdLine" )

  if not self.DB.profile.Version or self.DB.profile.Version < 2 then
    self.DB:ResetDB()
  end

  initializeClassModule()
  refreshBindings()
	restoreDefaults()
  checkImports()
  refreshOptions()
	loadScripts()

  ns.updateTalents()
  ns.updateGear()
  ns.updateGlyphs()

  ns.primeTooltipColors()
  
	self.DB.profile.Release = 25
  callHook( "onInitialize" )
	
	if class.file == 'NONE' then
		self.DB.profile.Enabled = false
		for i, buttons in ipairs( ns.UI.Buttons ) do
			for j, _ in ipairs( buttons ) do
				buttons[j]:Hide()
			end
		end
	end
	
end


function Hekili:OnEnable()

  ns.specializationChanged()
  ns.StartEventHandler()
	buildUI()

  Hekili.s = ns.state
  
	-- May want to refresh configuration options, key bindings.
	if self.DB.profile.Enabled then

		for i = 1, #self.DB.profile.displays do
			self:ProcessHooks( i )
		end
		
		self:UpdateDisplays()
		ns.Audit()
	
	else
		self:Disable()

	end
	
end


function Hekili:OnDisable()
	self.DB.profile.Enabled = false
  ns.StopEventHandler()
end


-- Texture Caching, 
local s_textures = setmetatable( {},
	{
		__index = function(t, k)
			local a = _G[ 'GetSpellTexture' ](k)
			if a and k ~= GetSpellInfo( 115698 ) then t[k] = a end
			return (a)
		end
	} )

-- Insert textures that don't work well with predictions.@
s_textures[GetSpellInfo(157676)] = 'Interface\\Icons\\ability_monk_chiexplosion' -- Chi Explosion
s_textures[GetSpellInfo(115356)] = 'Interface\\Icons\\ability_skyreach_four_wind'	-- Windstrike
s_textures[GetSpellInfo(114074)] = 'Interface\\Icons\\Spell_Fire_SoulBurn'			-- Lava Beam
s_textures[GetSpellInfo(421)] = 'Interface\\Icons\\Spell_Nature_ChainLightning'	-- Chain Lightning
	
local function GetSpellTexture( spell )
	return ( s_textures[ spell ] )
end


local z_PVP = {
	arena = true,
	pvp = true
}					


function Hekili:ProcessHooks( dispID )

	if not self.DB.profile.Enabled then
		return
	end

	if not self.Pause then
		local display = self.DB.profile.displays[ dispID ]

		ns.queue[ dispID ] = ns.queue[ dispID ] or {}
		local Queue = ns.queue[ dispID ]
    local clash = Hekili.DB.profile.Clash or 0
		
		if display and ns.visible.display[ dispID ] then
		
			state.reset()
      state.min_targets = display['Force Targets'] or 1
			
			if ( self.Config or checkScript( 'D', dispID )  ) then 

				for i = 1, display['Icons Shown'] do

					local chosen_action, chosen_caption
					local chosen_wait = 999
					
					Queue[i] = Queue[i] or {}
					
					for k in pairs( Queue[ i ] ) do
						if type( Queue[ i ][ k ] ) ~= 'table' then
							Queue[ i ][ k ] = nil
						end
					end
					
					for hookID, hook in ipairs( display.Queues ) do
					
						if ns.visible.hook[ dispID..':'..hookID ] then
						
							local HookPassed = checkScript( 'P', dispID..':'..hookID )
							
							if HookPassed then
  
								local listID = hook[ 'Action List' ]
								local list = self.DB.profile.actionLists[ listID ]
								
								-- Only action list criteria is whether it matches the spec.
								if ns.visible.list[ listID ] then

									local actID = 1
									while actID <= #list.Actions do
										if chosen_wait == 0 then
											break
										end
										
										if ns.visible.action[ listID..':'..actID ] then
                    
											-- Check for commands before checking actual actions.
                      local entry = list.Actions[ actID ]
                      state.this_action = entry.Ability

                      local wait_time = isKnown( state.this_action ) and timeToReady( state.this_action ) or 999
                      state.delay = wait_time
                      
											if entry.Ability == 'wait' then
												if checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then
													local args = ns.getModifiers( listID, actID )
													if not args.sec then args.sec = 1 end
													if args.sec > 0 then
														state.advance( args.sec )
														actID = 0
													end

												end
											
											elseif isKnown( state.this_action ) and isUsable( state.this_action ) and wait_time + clash < chosen_wait and ns.hasRequiredResources( state.this_action ) and ( class.abilities[ state.this_action ].cast == 0 or self.DB.profile.Hardcasts ) and checkScript( 'A', listID..':'..actID, nil, nil, wait_time ) then
                      
												chosen_action = state.this_action
												chosen_caption = entry.Caption
												chosen_wait = wait_time

												Queue[i].display = dispID
												Queue[i].button = i
                        
                        Queue[i].resource = ns.resourceType( chosen_action )
													
												Queue[i].hook = hookID
													
												Queue[i].actionlist = listID
												Queue[i].action = actID
													
												Queue[i].alName = list.Name
												Queue[i].actName = state.this_action
													
												Queue[i].caption = chosen_caption
												Queue[i].wait = wait_time
												
                      end
                      
                      state.delay = nil
                      
										end
										
										actID = actID + 1
									
									end
									
								end -- end Action List

							end
							
						end 
						
					end -- end Hook
					
					if chosen_action then
						-- We have our actual action, so let's get the script values if we're debugging.
						if self.DB.profile.Debug then
							ns.implantDebugData( Queue[i] )
						end
					
						-- Advance through the wait time.
						state.advance( chosen_wait )
							
						Queue[i].time = state.offset
						Queue[i].since = i > 1 and ( state.offset - Queue[i - 1].time ) or 0
					
						local action = class.abilities[ chosen_action ]

            -- Start the GCD.
            state.setCooldown( class.gcd, action.gcdType ~= 'off' and state.gcd or 0 )
						
						-- Advance the clock by cast_time.
						state.advance( action.cast )
						
						-- Put the action on cooldown.  (It's slightly premature, but addresses CD resets like Echo of the Elements.)
            state.setCooldown( chosen_action, action.cooldown )
            
						-- Perform the action.
						ns.runHandler( chosen_action )
						
						-- Spend resources.
						ns.spendResources( chosen_action )

            -- Adjust charges as needed.
            if class.abilities[ chosen_action ].charges then
              state.cooldown[ chosen_action ].charges = state.cooldown[ chosen_action ].charges - 1
              if state.cooldown[ chosen_action ].next_charge == 0 then
                state.cooldown[ chosen_action ].next_charge = state.now + state.offset + class.abilities[ chosen_action ].cooldown
              end
            end

						-- Move the clock forward if the GCD hasn't expired.
						if state.cooldown[ class.gcd ].remains > 0 then
							state.advance( state.cooldown[ class.gcd ].remains )
						end

						
					else
						for n = i, display['Icons Shown'] do
							Queue[n] = nil
						end
						break
					end
					
				end
				
			end			
		
		end

	end

	C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self[ 'ProcessDisplay'..dispID ] )
	
end



local pvpZones = {
	arena = true,
	pvp = true
}


function CheckDisplayCriteria( dispID )

	local display = Hekili.DB.profile.displays[ dispID ]
	local _, zoneType = IsInInstance()
	
	if C_PetBattles.IsInBattle() or not ns.visible.display[ dispID ] then
		return false
		
	elseif not pvpZones[ zoneType ] and display['PvE Visibility'] ~= 'always' then
		if display['PvE Visibility'] == 'combat' and ( not UnitAffectingCombat('player') and not UnitCanAttack('player', 'target') ) then
			return false
			
		elseif display['PvE Visibility'] == 'target' and ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
			return false
			
		elseif display['PvE Visibility'] == 'zzz' and not pvpZones[ zoneType ] then
			return false
			
		end
	
	elseif pvpZones[ zoneType ] and display['PvP Visibility'] ~= 'always' then
		if display['PvP Visibility'] == 'combat' and ( not UnitAffectingCombat('player') and not UnitCanAttack('player', 'target') ) then
			return false
			
		elseif display['PvP Visibility'] == 'target' and ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
			return false
		
		elseif display['PvP Visibility'] == 'zzz' then
			return false
			
		end
		
	elseif not Hekili.Config and not ns.queue[ dispID ] then
		return false
		
	elseif not checkScript( 'D', dispID ) then
    return false
  
  end
	
	return true

end
Hekili.CDC = CheckDisplayCriteria




local flashes = {}

function Hekili:UpdateDisplays()

	local self = self or Hekili

	if not self.DB.profile.Enabled then
		return
	end

	-- for dispID, display in pairs(self.DB.profile.displays) do
  for dispID = #self.DB.profile.displays, 1, -1 do
    local display = self.DB.profile.displays[ dispID ]
  
		if self.Pause then
			ns.UI.Buttons[ dispID ][1].Overlay:SetTexture('Interface\\Addons\\Hekili\\Textures\\Pause.blp')
			ns.UI.Buttons[ dispID ][1].Overlay:Show()

		else
      flashes[dispID] = flashes[dispID] or 0
      
			ns.UI.Buttons[ dispID ][1].Overlay:Hide()
		
			if CheckDisplayCriteria( dispID ) then
				local Queue = ns.queue[ dispID ]

				local gcd_start, gcd_duration = GetSpellCooldown( class.abilities[ class.gcd ].id )
				
				for i, button in ipairs( ns.UI.Buttons[dispID] ) do
					if not Queue or not Queue[i] and ( self.DB.profile.Enabled or self.Config ) then
						for n = i, display['Icons Shown'] do
							ns.UI.Buttons[dispID][n].Texture:SetTexture( 'Interface\\ICONS\\Spell_Nature_BloodLust' )
							ns.UI.Buttons[dispID][n].Texture:SetVertexColor(1, 1, 1)
							ns.UI.Buttons[dispID][n].Caption:SetText(nil)
							if not self.Config then
								ns.UI.Buttons[dispID][n]:Hide()
							else
								ns.UI.Buttons[dispID][n]:Show()
							end
						end
						break
					end
					
					local aKey, caption = Queue[i].actName, Queue[i].caption
				
					if aKey then
						button:Show()
						button.Texture:SetTexture( GetSpellTexture( class.abilities[ aKey ].name ) )
						button.Texture:Show()
						
						if display['Action Captions'] then
              
              local targets = max( display['Force Targets'] or 1, ns.numTargets() )
              local targColor = ''
              if display['Force Targets'] > 1 and ns.numTargets() < targets then targColor = '|cFFFF0000' end
            
							if i == 1 then
								button.Caption:SetJustifyH('RIGHT')
								-- check for special captions.
								if display['Primary Caption'] == 'targets' and targets > 1 then
									button.Caption:SetText( targColor .. targets .. '|r' )

								elseif display['Primary Caption'] == 'buff' then
									if display['Primary Caption Aura'] then
										local name, _, _, count, _, _, expires = UnitBuff( 'player', display['Primary Caption Aura'] )
										if name then button.Caption:SetText( count or 1 )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
									end

								elseif display['Primary Caption'] == 'debuff' then
									if display['Primary Caption Aura'] then
										local name, _, _, count = UnitDebuff( 'target', display['Primary Caption Aura'] )
										if name then button.Caption:SetText( count or 1 )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
									end

								elseif display['Primary Caption'] == 'ratio' then
									if display['Primary Caption Aura'] then
										if ns.numDebuffs( display['Primary Caption Aura'] ) > 1 or targets > 1 then
											button.Caption:SetText( ns.numDebuffs( display['Primary Caption Aura'] ) .. ' / ' .. targColor .. targets .. '|r' )
										else
											button.Caption:SetJustifyH('CENTER')
											button.Caption:SetText(caption)
										end
                  end

								elseif display['Primary Caption'] == 'sratio' then
									if display['Primary Caption Aura'] then
										local name, _, _, count, _, _, expires = UnitBuff( 'player', display['Primary Caption Aura'] )
                    if name and ( ( count or 1 ) > 0 ) then
                      local cap = count or 1
                      if targets > 1 then cap = cap .. ' / ' .. targColor .. targets .. '|r' end
                      button.Caption:SetText( cap )
                    else
                      if targets > 1 then button.Caption:SetText( targColor .. targets .. '|r' )
                      else
                        button.Caption:SetJustifyH('CENTER')
                        button.Caption:SetText(caption)
                      end
                    end
                  end

								else
									button.Caption:SetJustifyH('CENTER')
									button.Caption:SetText(caption)
									
								end
							else
								button.Caption:SetJustifyH('CENTER')
								button.Caption:SetText(caption)
							
							end
						else
							button.Caption:SetJustifyH('CENTER')
							button.Caption:SetText(nil)

						end
						
						local start, duration = GetSpellCooldown( class.abilities[ aKey ].id )
						
						if class.abilities[ aKey ].gcdType ~= 'off' and ( not start or start == 0 or ( start + duration ) < ( gcd_start + gcd_duration ) ) then
							start = gcd_start
							duration = gcd_duration
						end
						
						if i == 1 then
							button.Cooldown:SetCooldown( start, duration )
              if ns.lib.SpellFlash and display['Use SpellFlash'] and GetTime() >= flashes[dispID] + 0.2 then
                ns.lib.SpellFlash.FlashAction( class.abilities[ aKey ].id, display['SpellFlash Color'] )
                flashes[dispID] = GetTime()
              end
							
						else
							if ( start + duration ~= gcd_start + gcd_duration ) then
								button.Cooldown:SetCooldown( start, duration )
							else
								button.Cooldown:SetCooldown( 0, 0 )
							end
						end

						if ns.lib.SpellRange.IsSpellInRange( class.abilities[ aKey ].name, 'target') == 0 then
							ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 0, 0)
						elseif i == 1 and select(2, IsUsableSpell( class.abilities[ aKey ].name )) then
							ns.UI.Buttons[dispID][i].Texture:SetVertexColor(0.4, 0.4, 0.4)
						else
							ns.UI.Buttons[dispID][i].Texture:SetVertexColor(1, 1, 1)
						end
						

					else
						ns.UI.Buttons[dispID][i].Texture:SetTexture( nil )
						ns.UI.Buttons[dispID][i].Cooldown:SetCooldown( 0, 0 )
						ns.UI.Buttons[dispID][i]:Hide()
					
					end

				end
				
			else
				for i, button in ipairs(ns.UI.Buttons[dispID]) do
					button:Hide()
					
				end
			end
		end
	end
	
	C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self.UpdateDisplays )
	
end


