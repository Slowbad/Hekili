-- Modules.lua

function Hekili:NewModule( name, class, spec, st, ae, cd )
	local mod		= {}

	mod['name']		= name
	mod['class']	= class
	mod['spec']		= spec

	--[[
	mod.state		= {}
	mod.state.ST	= {}
	mod.state.AE	= {}
	mod.state.CD	= {}
	]]
	
	mod.enabled		= {}
	mod.enabled.ST	= st
	mod.enabled.AE	= ae
	mod.enabled.CD	= cd
	
	-- Spells table (with flags for spell level filtering/etc.)
	mod.spells		= {}
	function mod:AddAbility( name, ID, ... )
		if self.spells[name] then
			Hekili:Print("Attempted to add existing ability '" .. name .. "' to spells table.")
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
			Hekili:Print("Attempted to add a handler for spell '" .. name .. ". that is not in spells table.")
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
			Hekili:Print("Attempted to add a non-existant ability to the action list.")
			return
		end
		
		self.actionList[category][ #self.actionList[category]+1 ] = {
			['ability']		= ability,
			['caption']		= caption,
			['simC']		= simC,
			['check']		= check
		}
	end
	
	mod.trackHits		= {}
	mod.trackDebuffs	= {}
	
	self.Modules[name] = mod
	self:Print("Added module |cFFFF9900" .. name .. "|r to Hekili.")

	return self.Modules[name]
end


-- Add a blank module.
Hekili:NewModule( "(none)", nil, nil, false, false, false )