local ObjectAccessor = class("ObjectAccessor")

ObjectAccessor.__index = ObjectAccessor

function ObjectAccessor:ctor(  )
	self:Clear()
end

function ObjectAccessor:Clear( ... )
	self._players = {}
	self._creatures = {}
	self._removeObjs = {}
end

function ObjectAccessor:AddObject( obj )
	if obj:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER then
		self:AddPlayer(obj)
	elseif obj:GetTypeFaction() == TypeFaction.TYPE_FACTION_CREATURE then
		self:AddCreature(obj)
	else
		assert(false)
	end
end

function ObjectAccessor:RemoveObject( obj )
	if obj:GetTypeFaction() ==  TypeFaction.TYPE_FACTION_PLAYER then
		self:RemovePlayer(obj)
	else
		self:RemoveCreature(obj)
	end
end

function ObjectAccessor:AddPlayer( player )
 	self._players[#self._players + 1] = player
end 

function ObjectAccessor:RemovePlayer( player )
 	if table.keyof(self._players,player) then
 		table.remove(self._players,table.keyof(self._players,player))
 		player:Remove()
 	else
 		assert("nil player found!!!")
 	end
end

function ObjectAccessor:GetPlayer( class )
	for k,player in pairs(self._players) do
 		if player:GetClass() == class then
 			return player
 		end
 	end

 	return nil
end

function ObjectAccessor:AddCreature( creature )
 	self._creatures[#self._creatures + 1] = creature
end

function ObjectAccessor:RemoveCreature( creature )
 	if table.keyof(self._creatures,creature) then
 		table.remove(self._creatures,table.keyof(self._creatures,creature))
 		creature:Remove()
 	else
 		assert("nil creature found!!!")
 	end
end

function ObjectAccessor:GetCreature( guid )
 	-- body
end

function ObjectAccessor:HasCreature( obj )
	for _,v in pairs(self._creatures) do
		if v == obj then
			return true
		end
	end

	return false
end

function ObjectAccessor:GetPlayer( guid )
 	-- body
end

function ObjectAccessor:HasPlayer( obj )
	for _,v in pairs(self._players) do
		if v == obj then
			return true
		end
	end

	return false
end

function ObjectAccessor:GetAlivePlayers()
	local t = {}
	for _,v in pairs(self._players) do
		if v:IsAlive() then
			t[#t + 1] = v
		end
	end
	return t
end

function ObjectAccessor:GetPlayers( )
 	return self._players
end

function ObjectAccessor:GetCreatures( )
 	return self._creatures
end

function ObjectAccessor:AddRemoveObject( obj )
	for _,existobj in pairs(self._removeObjs) do
		if obj == existobj then
			assert(false,"obj has added to remove list")
			return
		end
	end
	self._removeObjs[#self._removeObjs + 1] = obj
end

function ObjectAccessor:ChooseSpellTarget( spell, radius, pushtype, TargetType )
	local searcher = require("demo.SpellNotifierObject").new( spell, radius, pushtype,TargetType )
	for _,player in pairs(self._players) do
		if player:IsAlive() then
			searcher:ForEachObject(player)
		end
	end

	for _,creature in pairs(self._creatures) do
		if creature:IsAlive() then
			searcher:ForEachObject(creature)
		end
	end

	return searcher:GetTargets()
end

function ObjectAccessor:Update( dt )
	
	for i = 1,#self._removeObjs do
		if i == 3 then
			local a
		end
		self._removeObjs[i]:GetMap():Remove(self._removeObjs[i])
	end
	self._removeObjs = {}

	for _,v in pairs(self._players) do
		v:Update(dt)
	end

	for _,v in pairs(self._creatures) do
		v:Update(dt)
	end
end

return ObjectAccessor