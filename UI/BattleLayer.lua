BattleLayer = class("BattleLayer",function() 
		local layer = ccui.loadLayer("ui/Battle")
		layer:setNodeEventEnabled(true)
		return layer
	end)
BattleLayer.__index = BattleLayer


function BattleLayer:ctor( ... )

	self:getChild("Image_bg"):removeFromParent()
	--self:setVisible(false)

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.Quit)})

	self._arrowBtn = self:getChild("Button_arrow")
	self._arrowBtn:setTouchEnabled(true)
	self._arrowBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ShowMainMenu)})
	self._bShow = false

	self._menuBg = self:getChild("Image_menuBg")

	self._maskImg = self:getChild("Image_mask")
	self._maskImg:setTouchEnabled(false)
	self._maskImg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.hideMainMenu)})

	local heroBtn = self:getChild("Button_Hero")
	heroBtn:setTouchEnabled(true)
	heroBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.heroCallback)})

	local formationBtn = self:getChild("Button_Formation")
	formationBtn:setTouchEnabled(true)
	formationBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.FormationCallback)})

	local mapBtn = self:getChild("Button_map")
	mapBtn:setTouchEnabled(true)
	mapBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.MapCallback)})

	local bagBtn = self:getChild("Button_bag")
	bagBtn:setTouchEnabled(true)
	bagBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.BagCallback)})
--[[
	self._timeLabel = ccui.label({text = "01:30",fontSize = 24})
	self._timeLabel:setAnchorPoint(cc.p(0,0))
	self._timeLabel:pos( winSize.width/2, self:getSize().height* 0.85 )
	self:addChild(self._timeLabel,0)]]

	self:AutoScale()
end

function BattleLayer:onEnter()
	local players = sObjectInfoMgr:GetBattlePlayers()
	if #players ~= 0 then
		local packet = WorldPacket:new(CMSG_BATTLEMAP_ENTER,60)
		packet:setU32(sBattleProxy._nextMapId) --这里应该传服务器给的battleSceneId
	   	network.send(packet)
	end
end

function BattleLayer:setBackGround()
	local function getMapPath()
		local path = ""
		local sceneId,chapterIndex = sBattleMap:GetEntry()
		chapterIndex = chapterIndex - 1 --dbc数组是从0开始索引的
		local sceneentry = GetSceneInfoEntry(sceneId)
		if not sceneentry then assert(false) end
		local chapterEntry = sChapterInfoStore[sceneentry.chapter[chapterIndex]]
		if chapterEntry then
			path = chapterEntry.mapPath
		end

		return "map/map_attack_10.jpg"
	end
	--self._backGround:loadTexture(getMapPath())
	self._backGround = ccui.image({image = getMapPath()})
	self._backGround:pos( cc.p(winSize.width/2,winSize.height/2) )
	self:addChild(self._backGround,-10000)
end

function BattleLayer:AutoScale( )
	--self:getChild("Image_bg"):setScaleY(display.height/640)
end

function BattleLayer:Quit( )
	--self:setVisible(false)
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

	--self._timeLabel:setString(string.format("%02d:%02d",min,sec))
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

	for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        z = 0 - math.modf(child:getPositionY() * 10)
        if iskindof(child,"BaseObject") then
        	if iskindof(child,"GameObject") and child:hasUnitState(UnitStat.UTL_PREPARE) then
        		z = 0
        	end

			if iskindof(child,"MissileEffect") then
				z = 0
			end

        	if child:getLocalZOrder() ~= z then
	        	self:reorderChild(child,z)
	        end
        end
    end
end

function BattleLayer:ShowMainMenu(  )
	if self._bShow then
		self._bShow = false
		self._menuBg:setVisible(false)
		self._maskImg:setTouchEnabled(false)
		self._maskImg:setOpacity(0)
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowdown.png")
	else
		self._bShow = true
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowup.png")
		self._menuBg:setVisible(true)
		self._maskImg:setTouchEnabled(true)
		self._maskImg:setOpacity(255)
	end
end

function BattleLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function BattleLayer:heroCallback( )
	local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
	local heroLayer = require("UI.HeroesLayer").new()
	if heroLayer ~= nil and mainLayer ~= nil then 
		self:Quit()
		mainLayer:addChild(heroLayer)
	end
end

function BattleLayer:FormationCallback(  )
	local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil and mainLayer ~= nil then 
		self:Quit()
		mainLayer:addChild(formationLayer)
	end
end

function BattleLayer:MapCallback(  )
	local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
	local mapLayer = require("UI.mapLayer").new()
	if mapLayer ~= nil and mainLayer ~= nil then 
		self:Quit()
		mainLayer:addChild(mapLayer)
	end
end

function BattleLayer:BagCallback(  )
	local mainLayer = sharedDirector:getRunningScene():getChildByTag(10086)
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil and mainLayer ~= nil then 
		self:Quit()
		mainLayer:addChild(BagLayer)
	end
end

return BattleLayer