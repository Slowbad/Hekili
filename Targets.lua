-- Targets.lua


-- Anything hurt by me or my pets will be in this table up to 'Grace Period'.
Hekili.targets = {}

function Hekili:Targets()
	return self.targets
end

function Hekili:UpdateTarget( id, time )
	self.targets[id] = time
end

function Hekili:TargetCount()
	local count = 0
	
	for k,_ in pairs( self.targets ) do
		count = count + 1
	end

	return count
end


-------------
-- MINIONS --

-- Minions should capture pets/totems/guardians/etc.  Anything that does damage on our behalf should be found.
Hekili.minions = {}

function Hekili:UpdateMinion( id, time )
	self.minions[id] = time
end

function Hekili:IsMinion( id )
	return self.minions[id] ~= nil
end

-- MINIONS --
-------------


-----------
-- AURAS --

Hekili.auras = {}

function Hekili:Auras()
	return self.auras
end

function Hekili:LoadAuras()
	if self.Active then
		for aura, _ in pairs( self.Active:Watchlist() ) do
			if not self.auras[ aura ] then self.auras[ aura ] = {} end
		end	
	end
end

function Hekili:ClearAuras()
	for k,v in pairs ( self:Auras() ) do
		table.wipe(v)
	end
end

function Hekili:UpdateAura( spell, target, time )
	self.auras[ spell ][ target ] = time
end

function Hekili:AuraCount( spell )
	local count = 0

	if self.Active and self.Active:Watched( spell ) then
		for k,_ in pairs( self.auras[spell] ) do
			count = count + 1
		end
	end

	return count
end

function Hekili:IsAuraWatched( spell )
	return ( self.auras[ spell ] ~= nil )
end

function Hekili:GetAuraTargets( spell )
	return self.auras[ spell ]
end

-- AURAS --
-----------


-- Remove a GUID from all our tables.
function Hekili:Eliminate( id )
	self:UpdateMinion( id, nil )
	self:UpdateTarget( id, nil )
	
	for k,_ in pairs( self:Auras() ) do
		self:UpdateAura( k, id, nil )
	end
end


-- Eliminate auras that have vanished from combat log and wipe targets that are too old.  TOO OLD.
function Hekili:Audit()
	
	local now = GetTime()
	
	for aura, targets in pairs( self:Auras() ) do
		for unit, lastTick in pairs( targets ) do
			if now - lastTick > 5 then
				self:UpdateAura( aura, unit, nil )
			end
		end
	end
	
	for whom, when in pairs( self:Targets() ) do
		if now - when > Hekili.DB.profile['Grace Period'] then
			self:UpdateTarget( whom, nil )
		end
	end
	
end
