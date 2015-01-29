local HeroesLayer = class("HeroesLayer",
	function()
		local layer = ccui.loadLayer("ui/AllHero")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function HeroesLayer:ctor( )
	self._type = LocationType.LOCATION_ALL

	self._scrollview = self:getChild("ScrollView_Hero")

	self._locBtn = {}
	self._locBtn[1] = self:getChild("Button_All")
	self._locBtn[2] = self:getChild("Button_Front")
	self._locBtn[3] = self:getChild("Button_Mid")
	self._locBtn[4] = self:getChild("Button_Back")

	for i = 1,#self._locBtn do
		self._locBtn[i]:setTag(i-1)
		self._locBtn[i]:setTouchEnabled(true)
		self._locBtn[i]:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.locTypeCallback)})
	end

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

	self._scvOriginPos = self:getChild("ScrollView_Hero"):getPosition()
	self._scvOriginSize = self:getChild("ScrollView_Hero"):getSize()

	self._arrowBtn = self:getChild("Button_arrow")
	self._arrowBtn:setTouchEnabled(true)
	self._arrowBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ShowMainMenu)})
	self._bShow = false

	self._maskImg = self:getChild("Image_mask")
	self._maskImg:setTouchEnabled(false)
	self._maskImg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.hideMainMenu)})

	local formationBtn = self:getChild("Button_Formation")
	formationBtn:setTouchEnabled(true)
	formationBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.FormationCallback)})

	local mapBtn = self:getChild("Button_map")
	mapBtn:setTouchEnabled(true)
	mapBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.MapCallback)})

--[[
	local unknow = self:getChild("Button_Hero_2")
	unknow:setTouchEnabled(true)
	unknow:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.SettingCallback)})
]]

	local bagBtn = self:getChild("Button_bag")
	bagBtn:setTouchEnabled(true)
	bagBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.BagCallback)})

	self:AutoScale()

end

function HeroesLayer:AutoScale( )
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

function HeroesLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function HeroesLayer:ShowMainMenu( widget )
--[[local heroBtn = self:getChild("Button_Hero")
	local formationBtn = self:getChild("Button_Formation")
	local mapBtn = self:getChild("Button_map")
	local unknow = self:getChild("Button_Hero_2")
	local bagBtn = self:getChild("Button_bag")
]]
	if self._bShow then
		--[[
		heroBtn:setVisible(false)
		formationBtn:setVisible(false)
		mapBtn:setVisible(false)
		unknow:setVisible(false)
		bagBtn:setVisible(false)]]

		self._bShow = false

		self:getChild("Image_menuBg"):setVisible(false)
		self._maskImg:setTouchEnabled(false)
		self._maskImg:setOpacity(0)
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowdown.png")
	else
		--[[
		heroBtn:setVisible(true)
		formationBtn:setVisible(true)
		mapBtn:setVisible(true)
		unknow:setVisible(true)
		bagBtn:setVisible(true)]]
		self._bShow = true
		self._arrowBtn:loadTextureNormal("maininterface/button_arrowup.png")
		self:getChild("Image_menuBg"):setVisible(true)
		self._maskImg:setTouchEnabled(true)
		self._maskImg:setOpacity(255)
	end
end

function HeroesLayer:returnCallback( )
	self:removeFromParent()
end

function HeroesLayer:locTypeCallback( widget )
	print("press button tag:"..widget:getTag())
	self._type = widget:getTag()
	for i = 1,4 do
		if i == self._type+1 then
			self._locBtn[i]:loadTextureNormal("button/button_label01.png")
			self._locBtn[i]:loadTexturePressed("button/button_label01.png")

			self._locBtn[i]:setTitleColor(cc.c3b(15, 59, 61))
		else
			self._locBtn[i]:loadTextureNormal("button/button_label02.png")
			self._locBtn[i]:loadTexturePressed("button/button_label02.png")

			self._locBtn[i]:setTitleColor(cc.c3b(125, 46, 2))
		end
	end
end

function HeroesLayer:FormationCallback(  )
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil then 
		local mainLayer = self:getParent()
		self:setVisible(false)
		mainLayer:addChild(formationLayer)
		mainLayer:removeChild(self, true)
	end
end

function HeroesLayer:MapCallback(  )
	local mapLayer = require("UI.mapLayer").new()
	if mapLayer ~= nil then 
		local mainLayer = self:getParent()
		self:setVisible(false)
		mainLayer:addChild(mapLayer)
		mainLayer:removeChild(self, true)
	end
end

function HeroesLayer:BagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil then 
		self:setVisible(false)
		self:getParent():addChild(BagLayer)
		self:getParent():removeChild(self, true)
	end
end

function HeroesLayer:update( dt )
	self.data:clear()

	local playerCounts = 0
	local pos = self.data:wpos()
	self.data:setU32(playerCounts)

	local playermap = ObjectMgr:GetPlayerMap()
	for k,v in pairs(playermap) do
		if v:getLocationType() == self._type or self._type == LocationType.LOCATION_ALL then
			self.data:setU32(k)
			playerCounts = playerCounts + 1
		end
	end

	self.data:put(pos,playerCounts)
	-- check the update of coins and diamond
	self.data:setU32(sObjectInfoMgr:GetCoin())
	self.data:setU32(sObjectInfoMgr:GetDiamond())
end

local function PowerComp( guid1,guid2 )
	--排序规则。。。按战斗力
	local combatPower1 = sObjectInfoMgr:GetCombatPower(guid1)
	local combatPower2 = sObjectInfoMgr:GetCombatPower(guid2)

	return combatPower1 < combatPower2
end

function HeroesLayer:reload( )

	local playerCounts = self.data:getU32()
	cclog("HeroesLayer playerCounts:"..playerCounts)
	
	local guidList = {}
	for i = 1,playerCounts do
		local guid = self.data:getU32()
		guidList[#guidList + 1] = guid
	end
	print("before sort:")
	print(unpack(guidList))
	table.sort(guidList,PowerComp)
	print("after sort:")
	print(unpack(guidList))
	local unsummonList = sObjectInfoMgr:GetUnsummonHeroes()
	self:makeitem(guidList,unsummonList)

	-- update coins and diamonds
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))
end

local function heroItemDisplay( item )
	local guid = item._guid
	local playerInfo = sObjectInfoMgr:GetPlayerInfo(guid)
	local name = sObjectInfoMgr:GetPlayerName(guid)
	local level = playerInfo._level
	--local nature = playerInfo._nature
	local nature = sObjectInfoMgr:GetPlayerNature(guid)
	local iconPath = playerInfo._iconPath
if true then
	local class = sObjectInfoMgr:GetPlayerClass(guid)
	local label = ccui.label({text=tostring(class),fontSize = 24})
	label:setColor(cc.c3b(0,0,0))
	item:addChild(label,10000)
	label:pos(item:getChild("Image_HeroFrame"):getPosition())
end

	local heroIcon = item:getChild("Image_Hero")
	heroIcon:loadTexture(iconPath)
	local Label_name = item:getChild("Label_name")
	Label_name:setString(name)
	local Label_level = item:getChild("Label_level")
	Label_level:setString(tostring(level))
	local Image_type = item:getChild("Image_type")
	--Image_type:loadTexture()
	if Image_type ~= nil then 
		local tbTypeImgPath = {
			[1]		= "Property/property_03.png",	-- 力
			[2]		= "Property/property_01.png",	-- 智
			[3]		= "Property/property_04.png",	-- 敏
		}

		if nature > 0 and nature < 4 then 
			Image_type:loadTexture(tbTypeImgPath[nature])
		else		
			Image_type:loadTexture(tbTypeImgPath[1])
		end
	end
end

local function heroItemDisplay2( item )
	
end

function HeroesLayer:drawScrollView()

	local image = self:getChild("Image_ScrollBg")
	image:removeChildByTag(10086)

	local draw = cc.DrawNode:create()
	image:addChild(draw, 10,10086)
    --self._scrollview:addChild(draw, 10,10086)

	local rect = self._scrollview:getBoundingBox()
    local star = {
        cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y),
        cc.p(rect.x + rect.width, rect.y + rect.height), cc.p(rect.x, rect.y + rect.height),
    }
    draw:drawPolygon(star, table.getn(star), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
end

function HeroesLayer:makeitem( summonList,unsummonList )
	local itempath = "ui/HeroItem"
	local pTextRich = nil
	local col = 2
	local unsummonCount = #unsummonList
	local summonCount = #summonList

	self._scrollview:removeAllChildren()

	local contentSize = self._scrollview:getContentSize()
	local item = ccui.loadWidget(itempath)

	local summonRows,unsummonRows = math.ceil(summonCount/col),math.ceil(unsummonCount/col) --summonRows可召唤英雄行数,unsummonRows未召唤英雄行数

	local wSpace,hSpace = 20,0
	local height = (summonRows + unsummonRows) * item:getContentSize().height + (summonRows + unsummonRows + 1) / 2 * hSpace
	if unsummonRows > 0 then
		pTextRich = CTextRich:create();
		pTextRich:setMaxLineLength(20);
		pTextRich:setVerticalSpacing(5);
		pTextRich:insertElement("以下英雄尚未召唤", "", 24,cc.c3b(253,233,8));
		pTextRich:reloadData();

		height = height + pTextRich:getContentSize().height
	end

	local fpTRHeight = pTextRich:getContentSize().height

	if height < contentSize.height then
		height = contentSize.height
	end
	local innerSize = cc.size(contentSize.width,height + fpTRHeight)
	self._scrollview:setInnerContainerSize(innerSize)

	local lastSummonItemPosY 
	--可召唤英雄Item
	for i = summonRows,1,-1 do
		for j = 1,col do
			if summonCount <= 0 then break end
			local guid = summonList[summonCount]

			local item = ccui.loadWidget(itempath)
			item._guid = guid
			heroItemDisplay(item)
			item:setTouchEnabled(true)
			item:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ChooseHeroCallback)})

			local x = (j - 1) * item:getContentSize().width + wSpace * j
			local y = innerSize.height - item:getContentSize().height * (summonRows - i + 1) - hSpace * (summonRows - i + 1)
			item:setPosition(cc.p(x,y))
			self._scrollview:addChild(item)

			summonCount = summonCount - 1
			if summonCount == 0 then
				lastSummonItemPosY = y
			end
		end
	end

	--未召唤Label
	if pTextRich then
		lastSummonItemPosY = lastSummonItemPosY - pTextRich:getContentSize().height
		pTextRich:setPosition(innerSize.width/2,lastSummonItemPosY);
		self._scrollview:addChild(pTextRich)
	end

	--未召唤英雄Item
	for i = unsummonRows,1,-1 do
		for j = 1,col do
			if unsummonCount <= 0 then break end
			local class = unsummonList[unsummonCount]

			local item = ccui.loadWidget(itempath)
			local label = item:getChild("Label_progress")
			--设置进度
			local pb = item:getChild("ProgressBar_9")
			pb:setPercent(0)
			item:getChild("Image_pbBg"):setVisible(true)
			item:getChild("Image_itembg"):setVisible(false)

			local heroIcon = item:getChild("Image_Hero")
			heroIcon:setShader("gray")
			item:getChild("Image_HeroFrame"):setShader("gray")
			item._class = class

			local x = (j - 1) * item:getContentSize().width + wSpace * j
			local y = lastSummonItemPosY - item:getContentSize().height * (unsummonRows - i + 1) - hSpace * (unsummonRows - i + 1) - fpTRHeight
			item:setPosition(cc.p(x,y))
			self._scrollview:addChild(item)

			unsummonCount = unsummonCount - 1
		end
	end

	self._scrollview:setBounceEnabled(true)
	self._scrollview:setClippingEnabled(true)

--self:drawScrollView()
end

function HeroesLayer:ChooseHeroCallback( widget )
	local guid = widget._guid
	local heroinfo = require("UI.HeroInfoLayer").new(guid)
	self:addChild(heroinfo)
end

return HeroesLayer