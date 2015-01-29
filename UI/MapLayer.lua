local MapLayer = class("MapLayer",
	function()
		local layer = ccui.loadLayer("ui/Map")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function MapLayer:ctor( )

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

	self._arrowBtn = self:getChild("Button_arrow")
	self._arrowBtn:setTouchEnabled(true)
	self._arrowBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ShowMainMenu)})
	self._bShow = false

	self._maskImg = self:getChild("Image_mask")
	self._maskImg:setTouchEnabled(false)
	self._maskImg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.hideMainMenu)})

	local heroBtn = self:getChild("Button_Hero")
	heroBtn:setTouchEnabled(true)
	heroBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.heroCallback)})

	local formationBtn = self:getChild("Button_Formation")
	formationBtn:setTouchEnabled(true)
	formationBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.FormationCallback)})

	local bagBtn = self:getChild("Button_bag")
	bagBtn:setTouchEnabled(true)
	bagBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.BagCallback)})

	self._maplist = self:getChild("ListView_map")
	self:InitInfo()

	self:AutoScale()
end

function MapLayer:AutoScale( )
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

function MapLayer:update( dt )
	self.data:clear()

	-- check the update of coins and diamond
	self.data:setU32(sObjectInfoMgr:GetCoin())
	self.data:setU32(sObjectInfoMgr:GetDiamond())
end

function MapLayer:reload(  )
	-- update coins and diamonds
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))
end

function MapLayer:returnCallback( )
	self:removeFromParent()
end

function MapLayer:InitInfo( )
	local canEnterMap = sSceneMgr:GetCanEnterMap()
	--for i = 1,table.nums(canEnterMap) do
	for mapId,_ in pairs(canEnterMap) do
		local item = ccui.loadWidget("ui/MapItem")
		item:setTag(mapId)
		item:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.mapCallback)})
		self._maplist:addChild(item)
	end
	self._maplist:setItemsMargin(-70.0)
end

function MapLayer:mapCallback( widget )
	local mapId = widget:getTag()
	cclog("[[MapLayer:mapCallback]]next mapId:"..mapId)
	sBattleProxy._nextMapId = mapId
end

function MapLayer:ShowMainMenu(  )
	if self._bShow then
		self._bShow = false
		self:getChild("Image_menuBg"):setVisible(false)
		self._maskImg:setTouchEnabled(false)
		self._maskImg:setOpacity(0)
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowdown.png")
	else
		self._bShow = true
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowup.png")
		self:getChild("Image_menuBg"):setVisible(true)
		self._maskImg:setTouchEnabled(true)
		self._maskImg:setOpacity(255)
	end
end

function MapLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function MapLayer:heroCallback( )
	local HeroesLayer = require("UI.HeroesLayer").new()
	if HeroesLayer ~= nil then 
		local mainLayer = self:getParent()
		self:setVisible(false)
		mainLayer:addChild(HeroesLayer)
		mainLayer:removeChild(self, true)
	end
end

function MapLayer:FormationCallback(  )
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil then 
		local mainLayer = self:getParent()
		self:setVisible(false)
		mainLayer:addChild(formationLayer)
		mainLayer:removeChild(self, true)
	end
end

function MapLayer:BagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil then 
		local mainLayer = self:getParent()
		self:setVisible(false)
		mainLayer:addChild(BagLayer)
		mainLayer:removeChild(self, true)
	end
end

return MapLayer