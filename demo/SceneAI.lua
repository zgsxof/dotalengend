local SceneAI = class("SceneAI")
SceneAI.__index = SceneAI

SceneCheckShutdownCondition =
{
	SCENE_CHECK_SHUTDOWN_KILL_ALL_MONSTER		= 0,
	SCENE_CHECK_SHUTDOWN_KILL_ALL_PLAYER		= 1,
};

MAX_CREATURE_COUNT = 10

function SceneAI:ctor( map )
	self._map = map
	
end

function SceneAI:Init()
	--[[for i = 1,#CreatureList do
		self._map:AddCreature(CreatureList[i])
	end]]
	local sceneId,chapterIndex = self._map:GetEntry()
	chapterIndex = chapterIndex - 1 --dbc数组是从0开始索引的
	local sceneentry = GetSceneInfoEntry(sceneId)
	if not sceneentry then return false end
	local chapterEntry = sChapterInfoStore[sceneentry.chapter[chapterIndex]]--GetChapterInfoEntry(sceneentry.chapter[chapterIndex])
	cclog("--------chapter id:"..chapterEntry.id)
	if not chapterEntry then return false end
	for i = 0,MAX_CREATURE_COUNT-1 do
		if chapterEntry.creatureId[i] and chapterEntry.creatureId[i]~= 0 then
			self._map:AddCreature(chapterEntry.creatureId[i])
		end
	end

	return true
end

function SceneAI:Update( dt )
	
end

function SceneAI:OnCreatureDead( victim )
	if sObjectAccessor:HasCreature(victim) then
		self:DoCheckShutDown(SceneCheckShutdownCondition.SCENE_CHECK_SHUTDOWN_KILL_ALL_MONSTER)
	end
end

function SceneAI:OnPlayerDead( victim )
	if sObjectAccessor:HasPlayer(victim) then
		self:DoCheckShutDown(SceneCheckShutdownCondition.SCENE_CHECK_SHUTDOWN_KILL_ALL_PLAYER)
	end
end

function SceneAI:DoCheckShutDown( type )
	if type == SceneCheckShutdownCondition.SCENE_CHECK_SHUTDOWN_KILL_ALL_MONSTER then
		local bAllDead = true
		local creatures = sObjectAccessor:GetCreatures()
		for _,v in pairs(creatures) do
			if v:IsAlive() then
				bAllDead = false
			end
		end
		if bAllDead then
			self._map:SetState(SceneStatus.SCENE_STATUS_CHAPTER_WIN)
		end
		
	elseif type == SceneCheckShutdownCondition.SCENE_CHECK_SHUTDOWN_KILL_ALL_PLAYER then
		local bAllDead = true
		local players = sObjectAccessor:GetPlayers()
		for _,player in pairs(players) do
			if player:IsAlive() then
				bAllDead = false
			end
		end

		if bAllDead then
			self._map:SetState(SceneStatus.SCENE_STATUS_FAIL)
		end
	end
end

return SceneAI