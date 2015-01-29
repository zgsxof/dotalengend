local BattleMap = class("BattleMap")
BattleMap.__index = BattleMap

SceneStatus =
{
	SCENE_STATUS_BEGIN		= 0,
	SCENE_STATUS_UPDATE		= 1,
	SCENE_STATUS_CHAPTER_WIN= 2, --小关胜利发消息告知客户端
	SCENE_STATUS_WIN_RUN	= 3, --小关胜利Player移动转场
	SCENE_STATUS_FAIL		= 4,
	SCENE_STATUS_WAIT 		= 5,
	SCENE_STATUS_SHOW_RESULT= 6,
	SCENE_STATUS_END		= 7,
};

function BattleMap:ctor( )
	self._pause = false
end

function BattleMap:Init( )
	--清除所有对象
	sObjectAccessor:Clear()

	self._sceneId = sBattleProxy._nextMapId
	math.newrandomseed()
	self._chapter = math.random(1,3)
	self._state = SceneStatus.SCENE_STATUS_BEGIN

	self._mapWidth = sharedDirector:getOpenGLView():getDesignResolutionSize().width--sharedDirector:getOpenGLView():getFrameSize().width
	self._mapHeight = sharedDirector:getOpenGLView():getDesignResolutionSize().height--sharedDirector:getOpenGLView():getFrameSize().height

	--add player
	local players = sObjectInfoMgr:GetBattlePlayers()
	for i = 1,#players do
		local player = require("demo.GameObject").new()
		local data = sObjectInfoMgr:MakeBattlePlayerInfo(i)
		player:Init(data)
		player:SetTypeFaction( TypeFaction.TYPE_FACTION_PLAYER )
		self:Add( player );
	end


	self._AI = require("demo.SceneAI").new(self)

	self._AI:Init()

	self._remainTime = 60

	self:OnEnterBattle()

	self._layer:setBackGround()

	return true
end

function BattleMap:GetAI()
	return self._AI
end

function BattleMap:GetEntry( )
	return self._sceneId,self._chapter
end

function BattleMap:SetLayer( layer )
	self._layer = layer
end

function BattleMap:GetLayer( )
	return self._layer
end

function BattleMap:Add( object )
	object:SetMap(self)

	self._layer:addChild(object,100000)

	sObjectAccessor:AddObject(object)

	object:AIM_Initialize()

	if object then
		local players = sObjectAccessor:GetPlayers()
		for _,v in pairs(players) do
			ObjectObjectRelocationWorker( object,v )
		end

		local creatures = sObjectAccessor:GetCreatures()
		for _,v in pairs(creatures) do
			ObjectObjectRelocationWorker( object,v )
		end
	end

	object:OnEnterBattle()
	
end

function BattleMap:Remove( obj )
	obj:SetMap(nil)

	sObjectAccessor:RemoveObject(obj)
end

function BattleMap:AddCreature( entry )
	local creature = require("demo.GameObject").new()
	local data = MakeCreatureData(entry)
	creature:Init(data)
	creature:SetTypeFaction(TypeFaction.TYPE_FACTION_CREATURE)
	
	self:Add(creature)
	
end

function BattleMap:SetState( s )
	self._state = s
end

function BattleMap:GetState( )
	return self._state
end


function BattleMap:OnEnterBattle()
	--[[]]
	local players = sObjectAccessor:GetPlayers()
	for _,player in pairs(players) do
		if player:IsAlive() then
			--先移除所有光环
			player:RemoveAllAuras()
			--然后释放入场技能（一般是光环类技能）
			local spells = player:GetSpells()
			for k,id in pairs(spells) do
				local spellinfo = GetSpellEntry(id)
				if spellinfo and band(spellinfo.Attributes,SpellAttributes.use_enter_battle) ~= 0 then
					player:CastSpell(player,id)
				end
			end
		end
	end

	local creatures = sObjectAccessor:GetCreatures()
	for _,creature in pairs(creatures) do
		if creature:IsAlive() then
			creature:RemoveAllAuras()
			local spells = creature:GetSpells()
			for k,id in pairs(spells) do
				local spellinfo = GetSpellEntry(id)
				if spellinfo and band(spellinfo.Attributes,SpellAttributes.use_enter_battle) ~= 0 then
					creature:CastSpell(creature,id)
				end
			end
		end
	end

	self._state = SceneStatus.SCENE_STATUS_UPDATE
end

function BattleMap:OnQuitBattle()
	--//退出战斗后要将所有object都销毁

	for _,player in pairs(sObjectAccessor:GetPlayers()) do
		if player:GetMap() == self then
			player:CombatStop()
			sObjectAccessor:AddRemoveObject(player)
		end
	end

	for _,creature in pairs(sObjectAccessor:GetCreatures()) do
		if creature:GetMap() == self then
			creature:CombatStop()
			sObjectAccessor:AddRemoveObject(creature)
		end
	end
end

function BattleMap:CombatStop()
	for _,player in pairs(sObjectAccessor:GetPlayers()) do
		if player:GetMap() == self then
			player:CombatStop()
		end
	end

	for _,creature in pairs(sObjectAccessor:GetCreatures()) do
		if creature:GetMap() == self then
			creature:CombatStop()
		end
	end
end

function BattleMap:BattleVictory()
	local players = sObjectAccessor:GetPlayers()
	for _,player in pairs(players) do
		player:Play(Action.Cheer)
	end
end

function BattleMap:BattleFail( ... )
	--失败
	cclog("----battle fail,send battle quit mgs")
	sGameMgr:ShowInfo("战斗失败！！！！")
	self:CombatStop()

	local send_packet = WorldPacket:new(CMSG_BATTLEMAP_QUIT,10)
	send_packet:setU32(self._sceneId)
	send_packet:setU8(0)
	send_packet:setU8(0)
	network.send(send_packet)

	self:SetState(SceneStatus.SCENE_STATUS_END)
	self._waitTime = 0
end

function BattleMap:EnterNextChapter()
	local players = sObjectAccessor:GetPlayers()
	for _,player in pairs(players) do
		if player:IsAlive() then
			player:ModifyPower(player:GetEnergyRecover() --[[+ player:GetExtraPowerRecover()]])

			player:ModifyHealth(player:GetHpRecover() --[[+ player:GetExtraHpRecover()]])

			--走到地图右侧
			local objSz = player:GetObjectSize().width
			player:MoveTo(cc.p(self._mapWidth + objSz + 10, player:GetPositionY()),player:GetStat(uf.move_speed) * 1.2)
		end
	end

	self:SetState(SceneStatus.SCENE_STATUS_WIN_RUN)
end

function BattleMap:HandleTransition() --转场
	local alivePlayers = sObjectAccessor:GetAlivePlayers()
	local count = 0
	for _,player in pairs(alivePlayers) do
		if player:IsAlive() and player:GetPositionX() > self._mapWidth then
			count = count + 1
		end
	end

	if count == table.nums(alivePlayers) then
		for _,player in pairs(alivePlayers) do
			local pos = player:GetInitStandPos()
			player:SetPosition(pos.x,pos.y)
			player:Stop()
			if player:AI() then
				player:AI():Reset()
			end
		end

		self:SetState(SceneStatus.SCENE_STATUS_BEGIN)

		for _,player in pairs(sObjectAccessor:GetPlayers()) do
			if player:IsDead() then
				self:Remove(player)
			end
		end

		for _,creature in pairs(sObjectAccessor:GetCreatures()) do
			if creature:IsDead() then
				self:Remove(creature)
			end
		end

		self._AI:Init()
		self._remainTime = 90
		self._state = SceneStatus.SCENE_STATUS_UPDATE
	end
end

function BattleMap:ChapterWin( )
	--[[刀塔传奇的模式
	if self._chapter < 3 then
		self._chapter = self._chapter + 1
		
		self._layer:NextChapterTip()
		
		self:SetState(SceneStatus.SCENE_STATUS_WAIT)
	else
		self:BattleVictory()

		self:SetState(SceneStatus.SCENE_STATUS_SHOW_RESULT)

		self.result = 1
	end
	]]
	--挂机模式
	cclog("----battle win,send battle quit mgs")
	sGameMgr:ShowInfo("战斗胜利！！！！")
	local send_packet = WorldPacket:new(CMSG_BATTLEMAP_QUIT,10)
	send_packet:setU32(self._sceneId)
	send_packet:setU8(1)
	send_packet:setU8(0)
	network.send(send_packet)

	self:SetState(SceneStatus.SCENE_STATUS_END)
	self._waitTime = 0
end

function BattleMap:ShowResult(dt)
	if not self._ElpasedTime then self._ElpasedTime = 0 end
	self._ElpasedTime = self._ElpasedTime + dt
	if self._ElpasedTime > 2 then
		if self.result == 1 then --win 

		else

		end

		self:SetState(SceneStatus.SCENE_STATUS_END)
	end

end

function BattleMap:Update(dt)
	if self._pause then
		return 
	end

	local funcTable = 
	{
		[SceneStatus.SCENE_STATUS_BEGIN] = function() end,
		[SceneStatus.SCENE_STATUS_UPDATE] = function() end,
		[SceneStatus.SCENE_STATUS_CHAPTER_WIN] = function () self:ChapterWin()	end,
		[SceneStatus.SCENE_STATUS_WIN_RUN] = function() self:HandleTransition() end,
		[SceneStatus.SCENE_STATUS_FAIL] = function() self:BattleFail() end,
		[SceneStatus.SCENE_STATUS_WAIT] = function(dt) self:Wait(dt) end,
		[SceneStatus.SCENE_STATUS_SHOW_RESULT] = function(dt) self:ShowResult(dt) end,
		[SceneStatus.SCENE_STATUS_END]	= function() end,
	}

	funcTable[self._state](dt)

	if self._state == SceneStatus.SCENE_STATUS_UPDATE or self._state == SceneStatus.SCENE_STATUS_BEGIN then
		self:UpdateTime(dt)
	end
end

function BattleMap:Wait(dt )
	self._waitTime = self._waitTime + dt
	if self._waitTime > 5 then
		cclog("send enter battlemap mgs")
		local packet = WorldPacket:new(CMSG_BATTLEMAP_ENTER,60)
		packet:setU32(sBattleProxy._nextMapId) 
	   	network.send(packet)

	   	self:SetState(SceneStatus.SCENE_STATUS_END)
	elseif self._waitTime > 3 then
		self:OnQuitBattle()
	end
end

function BattleMap:UpdateTime(dt)
	if self._remainTime > 0 then
		if self._remainTime - dt > 0 then
			self._remainTime = self._remainTime - dt
		else
			self._remainTime = 0
		end

		self._layer:UpdateTime(self._remainTime)
	else
		self:SetState(SceneStatus.SCENE_STATUS_FAIL)
	end
end

function BattleMap:SetPause()
	self._pause = true

	local players = sObjectAccessor:GetPlayers()
	for _,v in pairs(players) do
		v:Pause()
	end

	local creatures = sObjectAccessor:GetCreatures()
	for _,v in pairs(creatures) do
		v:Pause()
	end
end

function BattleMap:Resume( )
	self._pause = false

	local players = sObjectAccessor:GetPlayers()
	for _,v in pairs(players) do
		v:Resume()
	end

	local creatures = sObjectAccessor:GetCreatures()
	for _,v in pairs(creatures) do
		v:Resume()
	end
end

function BattleMap:IsPause()
	return self._pause
end

return BattleMap