-- Events.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state
local TTD = ns.TTD

local formatKey = ns.formatKey
local getSpecializationInfo = ns.getSpecializationInfo
local getSpecializationKey = ns.getSpecializationKey

local match = string.match

-- Abandoning AceEvent in favor of darkend's solution from:
-- http://andydote.co.uk/2014/11/23/good-design-in-warcraft-addons.html
-- This should be a bit friendlier for our modules.


local events = CreateFrame( "Frame" )
local handlers = {}


function ns.StartEventHandler()
  
  events:SetScript( "OnEvent", function( self, event, ... )

    local eventHandlers = handlers[ event ]
    
    if not eventHandlers then return end
    
    for i, handler in pairs( eventHandlers ) do
      handler( event, ... )
    end
    
  end )

end


function ns.StopEventHandler()

  events:SetScript( "OnEvent", nil )

end


ns.RegisterEvent = function( event, handler )

  handlers[ event ] = handlers[ event ] or {}
  table.insert( handlers[ event ], handler )
  
  events:RegisterEvent( event )

end
local RegisterEvent = ns.RegisterEvent


-- FIND A BETTER HOME
ns.cacheCriteria = function()

  for key, group in pairs( ns.visible ) do
    for key in pairs( group ) do
      group[ key ] = nil
    end
  end
  
  for i, display in ipairs( Hekili.DB.profile.displays ) do
    ns.visible.display[ i ] = display.Enabled and ( display.Specialization == 0 or display.Specialization == state.spec.id ) and ( display['Talent Group'] == 0 or display['Talent Group'] == GetActiveSpecGroup() )

		for j, hook in ipairs( display.Queues ) do
			ns.visible.hook[ i..':'..j ] = hook.Enabled and hook['Action List'] ~= 0
		end
	end
	
	for i, list in ipairs( Hekili.DB.profile.actionLists ) do
		
    if list.Enabled == nil then list.Enabled = true end
    
    ns.visible.list[ i ] = list.Enabled and ( list.Specialization == 0 or list.Specialization == state.spec.id )
		
		for j, action in ipairs( list.Actions ) do
			ns.visible.action[ i..':'..j ] = action.Enabled and action.Ability
		end
	end
	
end


RegisterEvent( "UPDATE_BINDINGS", function () ns.refreshBindings() end )
RegisterEvent( "DISPLAY_SIZE_CHANGED", function () ns.buildUI() end )
RegisterEvent( "PLAYER_ENTERING_WORLD", function () ns.specializationChanged() end )
RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED", function () ns.specializationChanged() end )
RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED", function ( _, unit )
  if unit == 'player' then
    ns.specializationChanged()
  end
end )


ns.updateTalents = function ()

	for k, _ in pairs( state.talent ) do
		state.talent[k].enabled = false
	end
	
  local specGroup = GetActiveSpecGroup()
	
	for i = 1, MAX_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			local _, name, _, enabled = GetTalentInfo( i, j, specGroup )
		
			for k, v in pairs( ns.class.talents ) do
				if name == v.name then
          if rawget( state.talent, k ) then state.talent[ k ].enabled = enabled
          else state.talent[ k ] = { enabled = enabled } end
					break
				end
			end
		end
	end
	
	for k,_ in pairs( state.perk ) do
		state.perk[k].enabled = false
	end
	
	for k, v in pairs( ns.class.perks ) do
		if IsSpellKnown( v.id ) then
      if rawget( state.perk, k ) then state.perk[ k ].enabled = true
      else state.perk[ k ] = { enabled = true } end
		end
	end
	
end


RegisterEvent( "PLAYER_TALENT_UPDATE", function () ns.updateTalents() end )


ns.updateGlyphs = function ()

	for k, _ in pairs( state.glyph ) do
		state.glyph[k].enabled = false
	end
	
	for i=1, NUM_GLYPH_SLOTS do
		local enabled, _, _, gID = GetGlyphSocketInfo(i)
		
		for k,v in pairs( class.glyphs ) do
			if gID == v.id then
				if enabled and v.name then
          if rawget( state.glyph, k ) then state.glyph[ k ].enabled = true
          else state.glyph[ k ] = { enabled = true } end
					break
				end
			end
		end
	end

end


RegisterEvent( "GLYPH_ADDED", function () ns.updateGlyphs() end )
RegisterEvent( "GLYPH_REMOVED", function () ns.updateGlyphs() end )
RegisterEvent( "GLYPH_UPDATED", function () ns.updateGlyphs() end )


RegisterEvent( "ENCOUNTER_START", function () state.boss = true end )
RegisterEvent( "ENCOUNTER_END", function () state.boss = false end )


local gearInitialized = false
ns.updateGear = function ()

  for k, _ in pairs( state.set_bonus ) do
    state.set_bonus[ k ] = 0
  end
	
  for set, items in pairs( class.gearsets ) do
    for item, _ in pairs( items ) do
      local itemName = GetItemInfo( item )
      
      if IsEquippedItem( GetItemInfo( item ) ) then
        state.set_bonus[ set ] = state.set_bonus[ set ] + 1
			end
		end
	end

	ns.Tooltip:SetOwner( UIParent, "ANCHOR_NONE") 
	ns.Tooltip:ClearLines()
	
	local MH = GetInventoryItemLink( "player", 16 )
	
	if MH then
		ns.Tooltip:SetInventoryItem( "player", 16 )
		local lines = ns.Tooltip:NumLines()

		for i = 2, lines do
			line = _G[ "HekiliTooltipTextRight"..i ]:GetText()

			if line then
				local speed = tonumber( line:match( "%d[.,]%d+" ) )
				
				if speed then
          state.mainhand_speed = speed
					break
				end
			end
		end	
		
		gearInitialized = true
	else
		state.mainhand_speed = 0		
	end
	
	ns.Tooltip:ClearLines()
	
	if OffhandHasWeapon() then
		ns.Tooltip:SetInventoryItem( "player", 17 )
		local lines = ns.Tooltip:NumLines()

		for i = 2, lines do
			line = _G[ "HekiliTooltipTextRight"..i ]:GetText()

			if line then
				local speed = tonumber( line:match( "%d[.,]%d+" ) )
				
				if speed then
					state.offhand_speed = speed
					break
				end
			end
		end		
	else
		state.offhand_speed = 0
	end
	
	ns.Tooltip:Hide()

	if not gearInitialized then
		C_Timer.After( 3, ns.updateGear )
	end
	
end


RegisterEvent( "PLAYER_EQUIPMENT_CHANGED", function() ns.updateGear() end )


RegisterEvent( "PLAYER_REGEN_DISABLED", function () state.combat = GetTime() end )
RegisterEvent( "PLAYER_REGEN_ENABLED", function () state.combat = 0 end )


RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
  
  if unit == 'player' then
    state.player.lastcast = spell
    state.player.casttime = GetTime()
  end
  
end )


-- Use dots/debuffs to count active targets.
-- Track dot power (until 6.0) for snapshotting.
-- Note that this was ported from an unreleased version of Hekili, and is currently only counting damaged enemies.
RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )

	if subtype == 'UNIT_DIED' or subtype == 'UNIT_DESTROYED' and ns.isTarget( destGUID ) then
		ns.eliminateUnit( destGUID )
		return
	end

	if subtype == 'SPELL_SUMMON' and sourceGUID == state.GUID then
		ns.updateMinion( destGUID, time )
		return
	end

	if sourceGUID ~= state.GUID and not ns.isMinion( sourceGUID ) then
		return
	end

	local hostile = ( bit.band( destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY ) == 0 )
	local time = GetTime()	
	
	-- Player/Minion Event
	if hostile and sourceGUID ~= destGUID then
		
		-- Aura Tracking
		if subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' then
			ns.trackDebuff( spellName, destGUID, time, true )
			ns.updateTarget( destGUID, time, sourceGUID == state.GUID )
    
		elseif subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
			ns.trackDebuff( spellName, destGUID, time )
			ns.updateTarget( destGUID, time, sourceGUID == state.GUID )
      
		elseif subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_MISSED' then
			ns.updateTarget( destGUID, time, sourceGUID == state.GUID )
      
		elseif destGUID and subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
			ns.trackDebuff( spellName, destGUID )
      
		end

		if subtype == 'SPELL_DAMAGE' or subtype == 'SPELL_PERIODIC_DAMAGE' or subtype == 'SPELL_PERIODIC_MISSED' then
			ns.updateTarget( destGUID, time, sourceGUID == state.GUID )

    end
    
	end
  
  -- This is dumb.  Just let modules used the event handler.
  ns.callHook( "COMBAT_LOG_EVENT_UNFILTERED", event, nil, subtype, nil, sourceGUID, sourceName, nil, nil, destGUID, destName, destFlags, nil, spellID, spellName, nil, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
	
end )



RegisterEvent( "UNIT_COMBAT", function( event, unitID, action, descriptor, damage, damageType )

  if unitID == 'player' and action == 'WOUND' and damage > 0 then
    ns.storeDamage( GetTime(), damage, damageType )
  end

end )


-- Time to die calculations.
RegisterEvent( "UNIT_HEALTH", function( _, unit )

	local GUID = UnitGUID( unit )
	
	if not ns.isTarget( GUID ) then
		return
	end
	
	if not TTD or not TTD[ GUID ] then ns.initTTD( unit ) end

	if not TTD[ GUID ] and not UnitIsFriend( 'player', unit ) then
		ns.initTTD( unit )
	end
	
	if ( UnitHealth( unit ) == UnitHealthMax( unit ) ) then
		ns.initTTD( unit )
		return
	end

	local now = GetTime()
	
	if ( not TTD[ GUID ].n ) then ns.initTTD( unit ) end
  
  local ttd = TTD[ GUID ]
	
	ttd.n = ttd.n + 1
	ttd.timeSum = ttd.timeSum + now
	ttd.healthSum = ttd.healthSum + UnitHealth( unit )
	ttd.timeMean = ttd.timeMean + (now * now)
	ttd.healthMean = ttd.healthMean + (now * UnitHealth( unit ))
	
	local difference = ( ttd.healthSum * ttd.timeMean - ttd.healthMean * ttd.timeSum)
	local projectedTTD = nil
	
	if difference > 0 then
		local divisor = ( ttd.healthSum * ttd.timeSum ) - ( ttd.healthMean * ttd.n )
		projectedTTD = 0
		if divisor > 0 then
			projectedTTD = difference / divisor - now
		end
	end

	if not projectedTTD or projectedTTD < 0 or ttd.n < 3 then
		return
	else
		projectedTTD = ceil(projectedTTD)
	end

	ttd.sec = projectedTTD
	
end )