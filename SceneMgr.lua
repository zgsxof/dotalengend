local SceneMgr = class("SceneMgr")
SceneMgr.__index = SceneMgr

local __instance = nil
local __allowInstance = nil

SceneMgr._canEnterScene = {}
SceneMgr._allowable = {}

function SceneMgr:ctor( )
	if not __allowInstance then
		error("SceneMgr is a singleton")
	end

	self:init()
end

function SceneMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = SceneMgr.new()
		__allowInstance = false
	end

	return __instance
end

function SceneMgr:init( )
	
end

function SceneMgr:getScenesByGroup( groupId )
	if not table.keyof(self._allowable,groupId) then return {} end

	local sceneList = {}
	for sceneId,entry in pairs(sSceneInfoStore) do
		if entry.group == groupId then
			sceneList[entry.rank] = entry.id
		end
	end

	return sceneList
end

function SceneMgr:AddPassed( id )
	cclog("---------add passed sceneId:"..id)
	self._canEnterScene[id] = {}
end

function SceneMgr:AddAllowable( groupid )
	cclog("---------add allowable groupId:"..groupid)
	if not self._allowable then self._allowable = {} end
	self._allowable[#self._allowable + 1] = groupid

	local sceneList = self:getScenesByGroup(groupid)
	local bNew = false
	for i = 1,#sceneList do
		if not table.keyof(self._canEnterScene,sceneList[i]) then
			if not bNew then
				self._canEnterScene[sceneList[i]] = {}
			end
		end
	end
end

function SceneMgr:GetCanEnterMap( )
	return clone(self._canEnterScene)
end

return SceneMgr