-- Classes.lua
-- July 2014

-- Basically, all the setup or shared attributes can stay in this file.  Anything class-specific should get moved to Classes\<classname>.lua.


local H = Hekili


-- Metatable to return modified information about an ability, if available.
local mt_modifiers = {
	__index = function(t, k)
		if not t.mods[ k ] then
			return t.elem[ k ]
		else
			return t.mods[ k ] ( t.elem[ k ] )
		end
	end
}

-- New model requires splitting spells into categories.
H.Abilities		= {}
H.Auras			= {}
H.Glyphs		= {}
H.Talents		= {}


H.Keys			= setmetatable( {}, {
	__newindex = function(t, k, v)
		for i = 1, #t do
			if t[i] == v then return t[i] end
		end
		rawset(t, k, v)
	end
} )


function AddAbility( key, id, cost, cast, gcd, cooldown, ... )
	
	local name = GetSpellInfo( id )
	
	if not name and id > 0 then return end
	
	H.Abilities[ key ] = setmetatable( {
		id		= id,
		name	= name,
		elem	= {}, -- storage for each attribute
		mods	= {}  -- storage for attribute modifiers
	}, mt_modifiers )
	
	H.Abilities[ id ] = H.Abilities[ key ]

	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = key
	
	AbilityElements( key, "cost", cost, "cast", cast, "gcdType", gcd, "cooldown", cooldown, ... )
	
end

	
function AbilityElements( key, ... )
	local args, ability = { ... }, H.Abilities[ key ]
	
	if not ability then return end
	
	for i = 1, #args, 2 do
		local k, v = args[i], args[i+1]
		
		if k and v then
			if k == 'id' then ability[k] = v
			else ability.elem[k] = v end
		end
	end

end


-- Applies a modifying function to a table.  Each line is added in order.
function Modify( tab, key, elem, ... )
	local entry, args = H[tab][key], { ... }
	if not entry then return end
	
	local loader = 'return function( x )\n'
	for i = 1, #args do
		loader = loader .. args[i] .. '\n'
	end
	
	if elem == 'cast' then
		if entry.gcdType == 'melee' then
			loader = loader .. 'return x * melee_haste\n' .. 'end'
		else
			loader = loader .. 'return x * spell_haste\n' .. 'end'
		end
	else
		loader = loader .. 'return x\n' .. 'end'
	end
	
	local success, outcome = pcall( loadstring( loader ) )
	
	if success then
		entry['str_'..elem] = loader
		entry.mods[elem] = setfenv( outcome, Hekili.State )
	else
		entry.mods[elem] = outcome .. '\n' .. loader
	end

end


-- Wrapper for the ability table.
function AbilityMods( key, elem, ... )
	Modify( 'Abilities', key, elem, ... )
end
H.Utils.AbilityMods = AbilityMods


H.Perks = {}
function AddPerk( key, id )
	local name = GetSpellInfo(id)
	
	if name then
		H.Perks[ key ] = {
			id = id,
			key = key,
			name = name
		}
	end
	
	H.Keys[ #H.Keys + 1 ] = key
end
			


function AddAura( key, id, ... )
	local name = GetSpellInfo( key )
	
	H.Auras[ key ] = setmetatable( {
		id		= id,
		key		= key,
		name	= GetSpellInfo( id ),
		elem	= {},
		mods	= {}
	}, mt_modifiers )
	
	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = key

	-- Allow reference by ID as well.
	H.Auras[ id ] = H.Auras[ key ]
	
	-- Add the elements, front-loading defaults and just overriding them if something else is specified.
	AuraElements( key, 'duration', 30, 'max_stacks', 1, ... )
	
end


function AuraElements( key, ... )
	local args, aura = { ... }, H.Auras[ key ]
	
	if not aura then return end
	
	for i = 1, #args, 2 do
		local k, v = args[i], args[i+1]
		
		if k and v then
			if k == 'id' then aura[k] = v
			else aura.elem[k] = v end
		end
	end

end


function AuraMods( key, elem, ... )
	Modify( 'Auras', key, elem, ... )
end


function AddTalent( key, id )
	local name = GetSpellInfo( id )
	
	if not name then return end

	H.Talents[ key ] = {
		id		= id,
		name	= name
	}
	
	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = key

end
H.Utils.AddTalent = AddTalent


function AddGlyph( key, id )
	local name = GetSpellInfo( id )
	
	if not name then return end

	H.Glyphs[ key ] = {
		id		= id,
		name	= name
	}

	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = key

end
H.Utils.AddGlyph = AddGlyph


H.Resources		= {}
function AddResource( resource )

	H.Resources[ resource ] = true

	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = key
	
end
H.Utils.AddResource = AddResource


H.Gear			= {}
function AddItemSet( name, ... )

	local arg = { ... }

	H.Gear[ name ] = H.Gear[ name ] or {}
	
	for i,v in ipairs(arg) do
		H.Gear[ name ][v] = 1
	end
	
	H.Keys = H.Keys or {}
	H.Keys[ #H.Keys+1 ] = name

end
H.Utils.AddItemSet = AddItemSet


H.MetaGem		= {}
function AddMeta( ... )

	for i,v in ipairs( ... ) do
		H.MetaGem[ v ] = 1
	end

end
H.Utils.AddMeta = AddMeta


function SetGCD( key )

	H.GCD = key

end
H.Utils.SetGCD = SetGCD


function AddHandler( ability, f )
	AbilityElements( ability, 'handler', setfenv( f, Hekili.State ) )
end
H.Utils.AddHandler = AddHandler


function RunHandler( ability )
	local ab = H.Abilities[ ability ]
	if ab and ab.elem[ 'handler' ] then ab.elem[ 'handler' ] () end
end
H.Utils.RunHandler = RunHandler

------------------------------
-- SHARED SPELLS/BUFFS/ETC. --
------------------------------

-- Bloodlust.
AddAura( 'ancient_hysteria'     , 90355, 'duration', 40 )
AddAura( 'bloodlust'            , 2825 , 'duration', 40 )
AddAura( 'heroism'              , 32182, 'duration', 40 )
AddAura( 'time_warp'            , 80353, 'duration', 40 )

-- Sated.
AddAura( 'exhaustion'           , 57723, 'duration', 600 )
AddAura( 'insanity'             , 95809, 'duration', 600 )
AddAura( 'sated'                , 57724, 'duration', 600 )
AddAura( 'temporal_displacement', 80354, 'duration', 600 )

-- Enchants.
AddAura( 'dancing_steel'        , 104434, 'duration', 12, 'max_stacks', 2 )

-- Potions.
AddAura( 'jade_serpent_potion'  , 105702, 'duration', 25 )
AddAura( 'mogu_power_potion'    , 105706, 'duration', 25 )
AddAura( 'virmens_bite_potion'  , 105697, 'duration', 25 )

-- Trinkets.
AddAura( 'dextrous'             , 146308, 'duration', 20 )
AddAura( 'vicious'              , 148903, 'duration', 10 )


-- Meta Gems (for crit dmg bonus)
AddItemSet( 'crit_bonus_meta', 76885, 76888, 76886, 76884 )


-- Racials.
-- AddSpell( 26297,	"berserking",	10 )
-- AddSpell( 20572,	"blood_fury",	15 )
AddAbility( 'berserking', 26297, 0         , 0, 'off', 180 )
AddHandler( 'berserking', function ()
	H:Buff( 'berserking' )
end )
AddAura   ( 'berserking', 26297, 'duration', 10 )

AddAbility( 'blood_fury', 20572, 0         , 0, 'off', 120 )
AddHandler( 'blood_fury', function ()
	H:Buff( 'blood_fury', 15 )
end )
AddAura   ( 'blood_fury', 20572, 'duration', 15 )


-- Special Instructions
AddAbility( 'wait', -1, 0, 0, 'off', 0 )
AbilityElements( 'wait', 'name', 'Wait' )










Hekili.Defaults = {}

function Hekili.Default( name, category, import )
	
	if not ( name and category and import ) then
		return
	end
	
	Hekili.Defaults[ #Hekili.Defaults + 1 ] = {
		name	= name,
		type	= category,
		import	= import:gsub("([^|])|([^|])", "%1||%2")
	}
end


-- Restores the defaults if they're not present.
function Hekili:RestoreDefaults( category )

	if not category or category == 'actionLists' then
		for i = 1, #self.Defaults do
			local proto = self.Defaults[i]
			
			if proto.type == 'actionLists' then
				local found = false
				for j = 1, #self.DB.profile.actionLists do
					if self.DB.profile.actionLists[j].Name == proto.name then
						found = true
						break
					end
				end
				
				if not found then
					_, self.DB.profile.actionLists[ #self.DB.profile.actionLists + 1 ] = Hekili:Deserialize( proto.import )
					self.DB.profile.actionLists[ #self.DB.profile.actionLists ].Name = proto.name
				end
			end
		
		end
	end
	
	-- Only rebuild displays if there are 0.
	if ( #self.DB.profile.displays == 0 and not category ) or category == 'displays' then
		for i = 1, #self.Defaults do
			local proto = self.Defaults[i]
			
			if proto.type == 'displays' then
				local found = false
				for j = 1, #self.DB.profile.displays do
					if self.DB.profile.displays[j].Name == proto.name then
						found = true
						break
					end
				end
				
				if not found then
					_, self.DB.profile.displays[ #self.DB.profile.displays + 1 ] = Hekili:Deserialize( proto.import )
					self.DB.profile.displays[ #self.DB.profile.displays ].Name = proto.name
					
					for j, prio in ipairs( self.DB.profile.displays[ #self.DB.profile.displays].Queues ) do
						if type( prio['Action List'] ) == 'string' then
							for k, list in ipairs( self.DB.profile.actionLists ) do
								if list.Name == prio['Action List'] then
									prio['Action List'] = k
									break
								end
							end
							if type( prio['Action List'] ) == 'string' then
								-- The list wasn't found.
								prio['Action List'] = 0
							end
						end
					end
				end
			end
		end
	end
	
	self:LoadScripts()
	self:RefreshOptions()
	
end


-- Loads the default action lists if they're not present.
function Hekili:IsDefault( name, category )

	if not name or not category then
		return nil
	end
	
	for i, default in ipairs( self.Defaults ) do
		if default.type == category and default.name == name then
			return true, i
		end
	end
	
	return false
end