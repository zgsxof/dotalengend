BattleLayer = class("BattleLayer",function() 
	return cc.LayerColor:create()--ccui.layer()
	 end)
BattleLayer.__index = BattleLayer

BattleLayerTag = 
{
	bgTag = 10085,
	pauseTag = 10086,
}

--[[
ColorLayer设置透明度时，相当于对Zorder小于0的Child加上一层蒙版，所以Child的Zorder是有讲究的

背景图Zorder: -10000

人物的Zorder要在背景图上面，不过要<=0：[-10000 , (-10000 + getPositionY()*10)]

放大招时人物的Zorder：0

其他（时间，SpellMenu, 暂停按钮）Zorder：0

]]

function BattleLayer:ctor( ... )
	self:scheduleUpdateWithPriorityLua(handler(self,self.update),0)

	self._animationID = 0
	self._pause = false

	--self:setSize(winSize)

	self._backGround = ccui.image({image = "scene/foreste.jpg"})--cc.Sprite:create("scene/bbg_fine_ship.jpg")--
	self._backGround:pos( cc.p(winSize.width/2,winSize.height/2) )
	self:addChild(self._backGround,-10000,BattleLayerTag.bgTag)
	
	self.nextChapterTip = ccui.image({image = "addon_rankbalance.png"})
	self.nextChapterTip:addTouchEvent({[ccui.TouchEventType.ended] =  handler(self,self.EnterNextChapter)})
	self.nextChapterTip:setVisible(false)
	SET_POS(self.nextChapterTip,self:getSize().width - 50,self:getSize().height* 0.5)
	self:addChild(self.nextChapterTip,0)
	--[[
	local stop = ccui.image({image = "button_gamepause.png"})
	stop:addTouchEvent({[ccui.TouchEventType.ended] =  handler(self,self.Stop)})
	SET_POS(stop,winSize.width - stop:getSize().width,winSize.height* 0.85)
	self:addChild(stop,0,BattleLayerTag.pauseTag)]]

	local quit = ccui.ImageView:create("button/button_back01.png",1)--ccui.image({image = "button_gamepause.png"})
	quit:setTouchEnabled(true)
	quit:addTouchEvent({[ccui.TouchEventType.ended] =  handler(self,self.Quit)})
	quit:pos(cc.p(quit:getSize().width,winSize.height* 0.85))
	self:addChild(quit,0,BattleLayerTag.pauseTag)

	self._timeLabel = ccui.label({text = "01:30",fontSize = 24})
	self._timeLabel:setAnchorPoint(cc.p(0,0))
	self._timeLabel:pos( winSize.width/2, self:getSize().height* 0.85 )
	self:addChild(self._timeLabel,0)

	--[[
	local test = ccui.image({image = "button_gamepause.png"})
	test:addTouchEvent({[ccui.TouchEventType.ended] =  handler(self,self.Test)})
	self:addChild(test)]]
end

function BattleLayer:Quit( )
	self:setVisible(false)
end

function BattleLayer:onEnter( ... )
	cclog("-----onenter")
	AdjustContent(self._backGround)
end

function BattleLayer:Test(  )
	local scale = self._backGround:getScaleY()
	self._backGround:setScaleY(scale * 1.2)
end

function BattleLayer:InitSpellLayer()
	self._spellLayer = require("demo.SpellMenuLayer").new() --cc.Node:create()
	self._spellLayer:pos( (winSize.width - self._spellLayer:getSize().width)/2,50 )
	self:addChild(self._spellLayer,20000)
end

function BattleLayer:onExit()
	self:unscheduleUpdate()
end

function BattleLayer:EnterNextChapter( uiwidget )
	sBattleMap:EnterNextChapter()
	self.nextChapterTip:setVisible(false)
end

function BattleLayer:NextChapterTip( )
	self.nextChapterTip:setVisible(true)
end

function BattleLayer:Stop(  )
	if not self._pause then
		self._pause = true
	else
		self._pause = false
	end

	if self._pause then
		sBattleMap:SetPause()
	else
		sBattleMap:Resume()
	end
end

function BattleLayer:Refresh( uiwidget )
	local players = sObjectAccessor:GetPlayers()
	for _,player in pairs(players) do
		player:SetHealth(player:GetMaxHealth())
		player:OnEnterBattle()
		for _,creature in pairs(sObjectAccessor:GetCreatures()) do
			ObjectObjectRelocationWorker(player,creature)
		end
	end

	local creatures = sObjectAccessor:GetCreatures()
	for _,creature in pairs(creatures) do
		creature:SetHealth(creature:GetMaxHealth())
		creature:OnEnterBattle()
		for _,player in pairs(sObjectAccessor:GetPlayers()) do
			ObjectObjectRelocationWorker(creature,player)
		end
	end
end

function BattleLayer:UpdateTime( time )
	local min,sec
	if time > 0 then
		time = math.ceil(time)
		min = math.modf(time / 60)
		sec = math.modf(time)
		if time > 60 then
			sec = math.modf(time - 60)
		end
	else
		min,sec = 0,0
	end

	self._timeLabel:setString(string.format("%02d:%02d",min,sec))
end

function BattleLayer:UpdatePauseResume( )
	if self._pause then
		--self:pause()

		for i = 1,self:getChildrenCount() do
	        local child = self:getChildren()[i]

	        if iskindof(child,"BaseObject") then
				child:DoPause()
			else
				if child:getTag() ~= BattleLayerTag.pauseTag then
					child:pause()
				end
			end
	    end

	else
		--self:resume()

		for i = 1,self:getChildrenCount() do
	        local child = self:getChildren()[i]
	        if child then
	        	child:resume()
	        end
	    end
		
	end
end

function BattleLayer:update(dt)
	self:UpdatePauseResume()

	if sBattleMap then
		sBattleMap:Update(dt)
	end
	
	if sObjectAccessor then
		sObjectAccessor:Update(dt)
	end

	if self._spellLayer then
		for i = 1,self._spellLayer:getChildrenCount() do
			local child = self._spellLayer:getChildren()[i]
			if child then
				child:Update(dt)
			end
		end
	end

	for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        z = 0 - math.modf(child:getPositionY() * 10)
        if iskindof(child,"BaseObject") then
        	if iskindof(child,"GameObject") and child:hasUnitState(UnitStat.UTL_PREPARE) then
        		z = 0
        	end
if iskindof(child,"MissileEffect") then
	cclog("......missile zorder:%d",z)
elseif iskindof(child,"GameObject") then
	if child:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER then
		cclog("player(class:%d) zorder:%d",child:GetClass(),z)
	end
end

        	if child:getLocalZOrder() ~= z then
	        	self:reorderChild(child,z)
	        end
        end
    end
end

return BattleLayer