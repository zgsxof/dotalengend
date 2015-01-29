local MainLayer = class("MainLayer",
	function()
		local layer = ccui.loadLayer("ui/Main")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function MainLayer:ctor()
	self._formationBtn = self:getChild("Button_Formation")
	self._formationBtn:setTouchEnabled(true)
	self._formationBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.FormationCallback)})

	self._heroBtn = self:getChild("Button_Hero")
	self._heroBtn:setTouchEnabled(true)
	self._heroBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.heroCallback)})

	self._bagBtn = self:getChild("Button_bag")
	self._bagBtn:setTouchEnabled(true)
	self._bagBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.bagCallback)})

	self._mapBtn = self:getChild("Button_map")
	self._mapBtn:setTouchEnabled(true)
	self._mapBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.mapCallback)})

	self._battleBtn = self:getChild("Button_Battle")
	self._battleBtn:setTouchEnabled(true)
	self._battleBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.battleCallback)})

	self._arrowBtn = self:getChild("Button_arrow")
	self._arrowBtn:loadTextureNormal("maininterface/button_arrowup.png")
	self._arrowBtn:setTouchEnabled(true)
	self._arrowBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.ShowMainMenuCallback)})
	self._bShow = true

	self.initBattle = false

	self:AutoScale()
end

function MainLayer:onEnter( ... )
	local players = sObjectInfoMgr:GetBattlePlayers()
	if #players ~= 0 then
		local packet = WorldPacket:new(CMSG_BATTLEMAP_ENTER,60)
		packet:setU32(sBattleProxy._nextMapId) --这里应该传服务器给的battleSceneId
	   	network.send(packet)
	end
end

function MainLayer:AutoScale( )
	if display.width == 1136 and display.height == 640 then
		self:getChild("Image_bg"):setScaleX(display.width/960)
		return
	end

	if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
		self:getChild("Image_bg"):setScaleY(display.height/640)
		self:getChild("Image_mask"):setScaleY(display.height/640)
	else
		self:getChild("Image_bg"):setScaleX(display.width/960)
		self:getChild("Image_mask"):setScaleX(display.width/960)
	end
end

function MainLayer:battleCallback()

	local players = sObjectInfoMgr:GetBattlePlayers()
	if #players == 0 then
		sGameMgr:ShowInfo( "请先选择出战英雄！！！" )
		return
	end
	if sBattleMap then
		sBattleMap:GetLayer():setVisible(true)
	else
		local packet = WorldPacket:new(CMSG_BATTLEMAP_ENTER,60)
		packet:setU32(sBattleProxy._nextMapId) --这里应该传服务器给的battleSceneId
	   	network.send(packet)
	end
end

function MainLayer:FormationCallback()
	local formationLayer = require("UI.FormationLayer").new()
	self:addChild(formationLayer)
end

function MainLayer:heroCallback( )
	local HeroesLayer = require("UI.HeroesLayer").new()
	self:addChild(HeroesLayer)
end

function MainLayer:bagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	self:addChild(BagLayer)
end

function MainLayer:mapCallback( )
	local mapLayer = require("UI.MapLayer").new()
	self:addChild(mapLayer)
end

function MainLayer:ShowMainMenuCallback(  )
	if self._bShow then 
		self._bShow = false
		self:getChild("Image_menuBg"):setVisible(false)
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowdown.png")
	else
		self._bShow = true
		self:getChild("Image_menuBg"):setVisible(true)
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowup.png")
	end
end

function MainLayer:update( dt )
	self.data:clear()

	--self.data:setU32(sObjectInfoMgr:GetCoin())
	--self.data:setU32(sObjectInfoMgr:GetDiamond())
end

function MainLayer:reload( ... )
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	cclog("coin:"..coin..",diamond:"..diamond)
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))
end

return MainLayer
