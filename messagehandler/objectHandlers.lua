
local function ObjectUpdate_ValueUpdate( packet )
	local unuse = packet:getU8()
	local guid = packet:getU64()

	local lpObject= ObjectMgr:GetObjectInWorld( guid )
	if  lpObject then
		lpObject:ReadUpdateMask( packet )
		lpObject:ReadUpdateValues( packet )
	end
end

local function ObjectUpdate_Movement( packet )
	-- body
end

local function ObjectUpdate_CreateObject( packet )
	local unuse = packet:getU8()
	local guid = packet:getU64()
	--guid:printDebug()
	local objecTypeId = packet:getU8()
	local lpObject = ObjectMgr:GetObjectInWorld( guid,objecTypeId )
	if lpObject then assert(false) end

	if not lpObject then
		--local isHero = guid:equals(HERO_GUID)
		--lpObject = ObjectMgr:createObject(objecTypeId,isHero)
		if objecTypeId == ObjectType.TYPEID_PLAYER then
			if guid:getValue32() == HERO_GUID then
				--cclog("-------------create hero")
				lpObject = CHero:new()
				lpObject:setIsHero(true)
			else
				--cclog("-------------create player")
				lpObject = CPlayer:new()
				lpObject:setIsHero(false)
			end
		elseif objecTypeId == ObjectType.TYPEID_ITEM then
			--cclog("-------------create item")
			lpObject = CItem:new()

		elseif objecTypeId == ObjectType.TYPEID_CONTAINER then
			--cclog("-------create bag")
			lpObject = CBag:new()
		else
			--cclog("------create unknown obj")
		end
	end

	if not lpObject then 
		return
	end

	lpObject:InitValues()
	lpObject:ReadMovmentUpdate( packet )
	lpObject:ReadUpdateMask( packet )
	lpObject:ReadUpdateValues( packet )
	ObjectMgr:AddObject( lpObject,objecTypeId )
	sCPlusObjectAccessor:AddObject(lpObject)
end

local function ObjectUpdate_OutOfRange(packet )
	-- body
end

local function ObjectUpdate_NearObject( packet )

end

function Handle_ObjectUpdate( packet )
	local blockCount = packet:getU32()
	local unuse1 = packet:getU8()
	local updateType = 0;

	local UPDATETYPE_VALUES = 1
	local UPDATETYPE_MOVEMENT = 2
	local UPDATETYPE_CREATE_OBJECT = 3
	local UPDATETYPE_CREATE_OBJECT2 = 4
	local UPDATETYPE_OUT_OF_RANGE_OBJECTS = 5
	local UPDATETYPE_NEAR_OBJECTS = 6
	local ObjectUpdateHandler =
	{
		[UPDATETYPE_VALUES] = { handler = ObjectUpdate_ValueUpdate },
		[UPDATETYPE_MOVEMENT] = { handler = ObjectUpdate_Movement },
		[UPDATETYPE_CREATE_OBJECT] = { handler = ObjectUpdate_CreateObject},
		[UPDATETYPE_CREATE_OBJECT2] = { handler = ObjectUpdate_CreateObject},
		[UPDATETYPE_OUT_OF_RANGE_OBJECTS] = { handler = ObjectUpdate_OutOfRange},
		[UPDATETYPE_NEAR_OBJECTS] = { handler = ObjectUpdate_NearObject}
	}
	for i = 0,blockCount-1  do
		updateType = packet:getU8() + 1
		if ObjectUpdateHandler[updateType] ~= nil then 
		    ObjectUpdateHandler[updateType].handler(packet)
		end
	end

end

function Handle_ObjectDestroy( packet )
	print("------------object destroy")
end

function Handle_InitialSpells( packet )
	local guid = packet:getU64()
	local player = ObjectMgr:GetPlayer(guid)
	if not player then 
		assert(false)
		cclog("InitialSpells: nil player,guid:"..guid:getValue32())
		return
	end
	local unk = packet:getU8()
	local counts = packet:getU16()
	for i = 1,counts do
		local spell_id = packet:getU32()
		local unkU16 = packet:getU16()
		sObjectInfoMgr:AddPlayerSpell(guid,spell_id)
	end
end

function Handle_LearnSpells( packet )
	local guid = packet:getU64()
	local player = ObjectMgr:GetPlayer(guid)
	if player then 
		local spell_id = packet:getU32()
		local unkU16 = packet:getU16()
		sObjectInfoMgr:AddPlayerSpell(guid,spell_id)
	end
	
end

function Handle_SupercededSpell( packet )
	local guid = packet:getU64()
	local player = ObjectMgr:GetPlayer(guid)
	if player then 
		local old_spell_id = packet:getU32()
		local new_spell_id = packet:getU32()
		sObjectInfoMgr:AddPlayerSpell(guid,spell_id)
	end
end

function Handle_RemoveSpell( packet )
	local guid = packet:getU64()
	local player = ObjectMgr:GetPlayer(guid)
	if player then 
		local spell_id = packet:getU32()
		sObjectInfoMgr:RemovePlayerSpell(guid,spell_id)
	end
end