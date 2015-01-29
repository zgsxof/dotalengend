local ObjectMgr = class("ObjectMgr")
ObjectMgr.__index = ObjectMgr

local __instance = nil
local __allowInstance = nil

ObjectMgr._players = {}
ObjectMgr._items = {}
ObjectMgr._hero = nil

function ObjectMgr:ctor( )
	if not __allowInstance then
		error("ObjectMgr is a singleton")
	end

	self:init()
end

function ObjectMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = ObjectMgr.new()
		__allowInstance = false
	end

	return __instance
end

function ObjectMgr:init( )
	
end

function ObjectMgr:AddItem( item )
	local guid = item:GetGUIDLow()
	--local guid32 = guid:getValue32()
	self._items[guid] = item
end

function ObjectMgr:GetItem( guid )
	return self._items[guid]
end

function ObjectMgr:GetItemMap( )
	return self._items
end

function ObjectMgr:AddPlayer( player )
	local guid = player:GetGUIDLow()
	player:initLocationTypeWithClass()
	self._players[guid] = player
end

function ObjectMgr:GetPlayer( guid )
	if tolua.type(guid) == "Guid" then
		guid = guid:getValue32()
	end

	return self._players[guid]
end

function ObjectMgr:GetPlayerMap( )
	return self._players
end

function ObjectMgr:AddHero( hero )
	self._hero = hero
end

function ObjectMgr:GetHero( ... )
	return self._hero
end

function ObjectMgr:AddObject(object,typeId)
	--local typeId = object:GetTypeId()
	if typeId == ObjectType.TYPEID_ITEM then
		self:AddItem( object )
	elseif typeId == ObjectType.TYPEID_PLAYER then
		local guid = object:GetGUIDLow()
		if guid == HERO_GUID then
			self:AddHero(object)
		else
			self:AddPlayer(object)
		end
	end
	
end

function ObjectMgr:GetObjectInWorld( guid,typeId )
	if tolua.type(guid) == "Guid" then
		typeId = guid:GetGuidType()
		guid = guid:getValue32()
	end

	assert(typeId)
	if typeId == ObjectType.TYPEID_PLAYER then
		for k,v in pairs(self._players) do
			if k == guid then
				return v
			end
		end
		if guid == HERO_GUID then
			return self._hero
		end
	elseif typeId == ObjectType.TYPEID_ITEM then
		for k,v in pairs(self._items) do
			if k == guid then
				return v
			end
		end
	else
		cclog("don't handle this typeid:"..typeId)
		--assert(false)
	end
	
	return nil
end

return ObjectMgr