-- Modules.lua

function Hekili:NewModule( name, specID, st, ae, cd )
	local mod		= {}

	mod['name']		= name
	mod['spec']		= specID

	mod.enabled		= {}
	mod.enabled.ST	= st
	mod.enabled.AE	= ae
	mod.enabled.CD	= cd
	
	
	-- For comparisons against the GCD.  An instant-cast self-buff works well.
	function mod:SetGCD( spell )
		mod.GCDspell = spell
	end
	
	function mod:GetGCD()
		return mod.GCDspell
	end
	
	
	-- Spells table (with flags for spell level filtering/etc.)
	mod.spells		= {}
	function mod:AddAbility( name, ID, ... )
		if self.spells[name] then
			local err = string.format(L["AddAbility Spell Exists"], name)
			Hekili:Print(err)
			return
		end

		local spell			= {}
		spell.id			= ID

		-- Assorted flags.
		local flags = { ... }
		for k,v in pairs(flags) do
			spell[v] = true
		end
		
		if not spell.item then
			spell.cooldown	= ttCooldown(ID)
			spell.cdUpdated	= GetTime()
		end
		
		self.spells[name]	= spell
	end
		
	function mod:AddHandler( name, func )
		if not self.spells[name] then
			local err = string.format(L["AddHandler Spell Does Not Exist"], name)
			Hekili:Print(err)
			return
		end
		
		self.spells[name].handler		= func
	end


	-- Action table (for comparing ability criteria/etc.)
	mod.actionList				= {}
	mod.actionList.precombat	= {}
	mod.actionList.cooldown		= {}
	mod.actionList.aoe			= {}
	mod.actionList.single		= {}
	
	function mod:AddToActionList( category, ability, caption, simC, check )
		if not self.spells[ability] then
			local err = string.format(L["AddToActionList Ability Does Not Exist"], ability, category)
			Hekili:Print(err)
			return
		end
		
		self.actionList[category][ #self.actionList[category]+1 ] = {
			['ability']		= ability,
			['caption']		= caption,
			['simC']		= simC,
			['check']		= check
		}
	end


	-- Trackers (for recommended aura icons)
	mod.trackers = {}
	

	function mod:AddTracker( name, type, caption, show, timer, override, ... )
		self.trackers[name]				= {}
		self.trackers[name].type		= type
		self.trackers[name].caption		= caption
		self.trackers[name].show		= show
		self.trackers[name].timer		= timer
		self.trackers[name].override	= override
		
		if type == 'Aura' then
			local aura, unit = ...
			
			self.trackers[name].aura	= aura
			self.trackers[name].unit	= unit
		elseif type == 'Cooldown' then
			local ability = ...
			
			self.trackers[name].ability	= ability
		elseif type == 'Totem' then
			local element, ttmName = ...
			
			self.trackers[name].element	= element
			self.trackers[name].ttmName	= ttmName
			self.trackers[name].ttmCap	= caption
		end
		
	end


	-- Target Counts
	mod.trackHits		= {}
	mod.trackDebuffs	= {}
	
	function mod:WatchAura( aura  )
		self.trackDebuffs[aura] = true
	end
	
	function mod:Watchlist()
		return mod.trackDebuffs
	end
	
	function mod:Watched( aura )
		return (self.trackDebuffs[aura] ~= nil)
	end
	
	self.Modules[name] = mod

	local success = string.format(L["AddModule Success"], name)
	self:Print(success)

	return self.Modules[name]
end


-- Add a blank module.
Hekili:NewModule( "None", nil, nil, false, false, false )