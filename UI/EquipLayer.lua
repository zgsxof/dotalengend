local EquipLayer = class("EquipLayer",
	function()
		local layer = ccui.loadLayer("ui/Equip")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function EquipLayer:ctor( guid )
	assert(guid)
	self._guid = guid
	self._languageId = 1

	self._forgeNode = self:getChild("Image_forge_bg")
	self._upgradeNode = self:getChild("Image_upgrade_bg")

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

	self._forgeBtn = self:getChild("Button_forge")
	self._forgeBtn:setTouchEnabled(true)
	self._forgeBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.showForgeCallback)})

	self._upgradeBtn = self:getChild("Button_upgrade")
	self._upgradeBtn:setTouchEnabled(true)
	self._upgradeBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.showUpgradeCallback)})

	self._heroInfoBtn = self:getChild("Button_Info")
	self._heroInfoBtn:setTouchEnabled(true)
	self._heroInfoBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.HeroInfoCallback)})

	self._spellBtn = self:getChild("Button_Spell")
	self._spellBtn:setTouchEnabled(true)
	self._spellBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.SpellCallback)})

	self._toForgeBtn = self:getChild("Button_toForge")
	self._toForgeBtn:setTouchEnabled(true)
	self._toForgeBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toForgeCallback)})

	self._toUpgradeBtn = self:getChild("Button_toUpgrade")
	self._toUpgradeBtn:setTouchEnabled(true)
	self._toUpgradeBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toUpgradeCallback)})

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

	local mapBtn = self:getChild("Button_map")
	mapBtn:setTouchEnabled(true)
	mapBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.MapCallback)})

	local bagBtn = self:getChild("Button_bag")
	bagBtn:setTouchEnabled(true)
	bagBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.BagCallback)})

	local player = ObjectMgr:GetPlayer( guid )
	assert(player,string.format("不存在此guid对应的Player,guid:"..guid))
	self._equips = {}
	self._equips[1] = ObjectMgr:GetItem( player:getEquipId(17) ) 
	self._equips[2] = ObjectMgr:GetItem( player:getEquipId(1) )
	self._equips[3] = ObjectMgr:GetItem( player:getEquipId(4) )
	self._equips[4] = ObjectMgr:GetItem( player:getEquipId(15) )---- player:getEquip(7)???

	for i = 1, table.nums(self._equips) do
		local equip = self:getChild(string.format("Image_equip%d_bg", i))
		if equip ~= nil then
			equip:setTouchEnabled(true)
			equip:setTag(i)
			equip:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.EquipCallback)})
		end
	end
	self._index = 1

	-- init left part
	self:initLeftPart()

	-- init forge part
	self:updateForgePart(self._equips[1]:getItemId())

	-- init upgrade part
	self:initUpgradePart()

	self:AutoScale()
end

function EquipLayer:AutoScale( )
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

function EquipLayer:update( dt )
	self.data:clear()

	-- check the update of coins and diamond
	self.data:setU32(sObjectInfoMgr:GetCoin())
	self.data:setU32(sObjectInfoMgr:GetDiamond())
end

function EquipLayer:reload(  )
	-- update coins and diamonds
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))
end

function EquipLayer:toForgeCallback( widget )
	--校验装备是否满足强化条件，未做

	if not self._equips[self._index] then assert(false) end
	local slot = self._equips[self._index]:getSlot()
	local packet = WorldPacket:new(CMSG_INTENSIFY_ITEM,60)
	--sendData << (uint8)255 << m_slot << SelectedPlayerID << (uint8)1;
	packet:setU32(self._guid)
	packet:setU8(slot)
   	network.send(packet)
end

function EquipLayer:toUpgradeCallback( widget )
	--校验材料是否满足升级条件，未做

	local slot = self._equips[self._index]:getSlot()
	local packet = WorldPacket:new(CMSG_MERGE_ITEM,60)
	packet:setU8(255)
	packet:setU8(slot)
	packet:setU32(self._guid)
	packet:setU8(0)
   	network.send(packet)
end

function EquipLayer:initLeftPart(  )
	-- init euips name and image
	if self._equips then 
		for i = 1, table.nums(self._equips) do
			-- name
			local equipNameLabel = self:getChild(string.format("Label_name%d", i))
			local name = GetEquipName(self._equips[i]:getItemId(), self._languageId)
			if equipNameLabel and name then 
				equipNameLabel:setString(name)
			end

			-- icon
			local equipImg = self:getChild(string.format("Image_equip%d", i))
			equipImg:loadTexture(sObjectInfoMgr:GetItemIconPath(self._equips[i]:getItemId()))
			equipImg:setScale(0.75)
		end
	end

	-- 设置默认选择第一项
	local bg = self:getChild("Image_equip1_bg")
	bg:loadTexture("maininterface/hero_forgingbg03.png")
end

function EquipLayer:updateForgePart( itemId )
	-- 更新信息：左边的scrollView
	self._lScrView = self:getChild("ScrollView_before")
	self._lScrView:setBounceEnabled(true)
	self._lScrView:setClippingEnabled(true)
	self:updateContainer(itemId, self._lScrView)

	-- 更新信息：右边的scrollView
	self._rScrView = self:getChild("ScrollView_after")
	self._rScrView:setBounceEnabled(true)
	self._rScrView:setClippingEnabled(true)
	-- 现在暂时先用测试数据
	local item = tbItemStore[itemId]
	local nextLvId = -1
	if item ~= nil then 
		nextLvId = item.nextId
		if nextLvId ~= -1 then 
			self:updateContainer(nextLvId, self._rScrView)
		end
	end

	-- 更新信息：成功率
	local successRate = self:getChild("Label_successRate")
	-- 这里应该是去服务器查询成功率，现在暂时用测试数据
	successRate:setString("66")

	-- 更新信息：剩余锻造点
	local remainCounts = self:getChild("Label_remainCounts")
	-- 这里应该是去服务器查询剩余锻造点，现在暂时用测试数据
	remainCounts:setString("24")
end

function EquipLayer:initUpgradePart(  )
	local equip = nil
	if self._equips[1] ~= nil then 
		equip = self._equips[1]
	elseif self._equips[2] ~= nil then
		equip = self._equips[2]
	elseif self._equips[3] ~= nil then
		equip = self._equips[3]
	else
		equip = self._equips[4]
	end

	if equip ~= nil then 
		local info = tbItemRecipeInfoStore[equip:getItemId()]
		if info ~= nil then 
			-- 升级前的物品
			-- 图片
			self._needUpgradeEquipImg = self:getChild("Image_Upgrade_1")
			self._needUpgradeEquipImg:loadTexture(sObjectInfoMgr:GetItemIconPath(info.itemId))
			self._needUpgradeEquipImg:setScale(0.75)
			-- 名字
			self._needUpgradeEquipName = self:getChild("Label_weapon1")
			self._needUpgradeEquipName:setString(GetEquipName(info.itemId, self._languageId))

			-- 升级后的物品
			-- 图片
			self._didUpgradeEquipImg = self:getChild("Image_Upgrade_2")
			self._didUpgradeEquipImg:loadTexture(sObjectInfoMgr:GetItemIconPath(info.createItemId))
			self._didUpgradeEquipImg:setScale(0.75)
			-- 名字
			self._didUpgradeEquipName = self:getChild("Label_weapon2")
			self._didUpgradeEquipName:setString(GetEquipName(info.createItemId, self._languageId))

			local existingCount = 0
			local requireCount = 1
			local requireItemID = 0

			local mustRequireImg = nil
			local mustRequireCountLabel = nil
			local mustRequireCountProgress = nil
			-- 合成所需的物品
			for i = 1, 3 do
				if i == 1 then 
					requireItemID = info.mustRequire_1
					requireCount = info.mustRequireCount_1
				elseif i == 2 then 
					requireItemID = info.mustRequire_2
					requireCount = info.mustRequireCount_2
				elseif i == 3 then 
					requireItemID = info.mustRequire_3
					requireCount = info.mustRequireCount_3
				else
					requireItemID = 0
					requireCount = 1
				end

				-- 图片
				mustRequireImg = self:getChild(string.format("Image_item%d", i))
				mustRequireImg:loadTexture(sObjectInfoMgr:GetItemIconPath(requireItemID))
				mustRequireImg:setScale(0.75)
				-- 所需数量
				existingCount = sObjectInfoMgr:GetItemCount(requireItemID)
				-- label
				mustRequireCountLabel = self:getChild(string.format("Label_Progress%d", i))
				mustRequireCountLabel:setString(tostring(existingCount) .. "/" .. tostring(requireCount))
				-- progress bar
				mustRequireCountProgress = self:getChild(string.format("ProgressBar_%d", i))
				mustRequireCountProgress:setPercent((existingCount / requireCount) * 100)
			end
		end
	end
end

function EquipLayer:updateContainer( itemId, widget )
	if widget == nil then
		return
	end

	widget:removeAllChildren()

	local innerHeight = 0
	local labelTitle = ccui.label({text = "当前属性", fontSize = 24})
	labelTitle:setColor(cc.c3b(125, 46, 2))
	innerHeight = innerHeight + labelTitle:getContentSize().height + 10

	local lineImg = ccui.image({image = "sundry/line_04.png"})
	lineImg:setScaleX(0.5)
	innerHeight = innerHeight + lineImg:getContentSize().height + 5

	local pTextRich = nil

	local entry = tbLocaleItemStore[itemId]
	local tbStatDesc = {}
	if entry ~= nil then 
		tbStatDesc = entry._statDesc
	end
	if tbStatDesc ~= nil then 
		pTextRich = CTextRich:create()
		pTextRich:setMaxLineLength(20)
		pTextRich:setVerticalSpacing(5)

		for i = 1, table.nums(tbStatDesc) do 
			-- tbStatDesc中的信息是从表locales_item.csv中读取出来，且经过一次分割的
			-- 但需对信息进行二次处理，才能得到有用的信息
			local tbDescAndValue = string.split(tbStatDesc[i], ":")
			if tbDescAndValue ~= nil then 
				-- tbDescAndValue[1]就是desc，tbDescAndValue[2]就是value
				if tbDescAndValue[1] == nil or tbDescAndValue[2] == nil then 
					-- assert(false, "表locales_item.csv信息错误")
				end

				pTextRich:insertElement(tbDescAndValue[1] .. ":", "", 22, cc.c3b(160, 58, 3))
				pTextRich:insertElement(tbDescAndValue[2] .. "\n", "", 22, cc.c3b(65, 47, 26))
			end
		end

		pTextRich:reloadData()
		innerHeight = innerHeight + pTextRich:getContentSize().height + 10	
	end

	widget:setInnerContainerSize(cc.size(widget:getContentSize().width, innerHeight))
	local Size = widget:getInnerContainerSize()

	labelTitle:setPosition(cc.p(Size.width/2, Size.height - 10 - labelTitle:getContentSize().height/2))
	widget:addChild(labelTitle)

	lineImg:setPosition(cc.p(Size.width/2, labelTitle:getPositionY() - labelTitle:getContentSize().height/2 - 5 - lineImg:getContentSize().height/2))
	widget:addChild(lineImg)

	if pTextRich ~= nil then 
		pTextRich:setPosition(cc.p(Size.width/2, lineImg:getPositionY() - lineImg:getContentSize().height/2 - 10 - pTextRich:getContentSize().height/2))
		widget:addChild(pTextRich)
	end
end

function EquipLayer:HeroInfoCallback( ... )
	local parent = self:getParent()
	local HeroInfoLayer = require("UI.HeroInfoLayer").new(self._guid)
	parent:addChild(HeroInfoLayer)

	self:removeFromParent()
end

function EquipLayer:SpellCallback( ... )
	local parent = self:getParent()
	local spell = require("UI.SpellLayer").new(self._guid)
	parent:addChild(spell)

	self:removeFromParent()
end

function EquipLayer:EquipCallback( widget )
	-- update BG
	for i = 1,4 do
		local bg = self:getChild(string.format("Image_equip%d_bg",i))
		if i == index then
			bg:loadTexture("maininterface/hero_forgingbg03.png")
		else
			bg:loadTexture("maininterface/hero_forgingbg01.png")
		end
	end

	local index = widget:getTag()
	self._index = index
	if self._equips[index] ~= nil then 
		local equipItemId = self._equips[index]:getItemId()

		-- update upgrade part
		self:updateForgePart(equipItemId)

		-- update forge part
		local info = tbItemRecipeInfoStore[equipItemId]
		if info ~= nil then 
			-- 升级前的物品
			-- 图片
			self._needUpgradeEquipImg:loadTexture(sObjectInfoMgr:GetItemIconPath(info.itemId))
			-- 名字
			self._needUpgradeEquipName:setString(GetEquipName(info.itemId, self._languageId))

			-- 升级后的物品
			-- 图片
			self._didUpgradeEquipImg:loadTexture(sObjectInfoMgr:GetItemIconPath(info.createItemId))
			-- 名字
			self._didUpgradeEquipName:setString(GetEquipName(info.createItemId, self._languageId))

			local existingCount = 0
			local requireCount = 1
			local requireItemID = 0

			local mustRequireImg = nil
			local mustRequireCountLabel = nil
			local mustRequireCountProgress = nil
			-- 合成所需的物品
			for i = 1, 3 do
				if i == 1 then 
					requireItemID = info.mustRequire_1
					requireCount = info.mustRequireCount_1
				elseif i == 2 then 
					requireItemID = info.mustRequire_2
					requireCount = info.mustRequireCount_2
				elseif i == 3 then 
					requireItemID = info.mustRequire_3
					requireCount = info.mustRequireCount_3
				else
					requireItemID = 0
					requireCount = 1
				end

				-- 图片
				mustRequireImg = self:getChild(string.format("Image_item%d", i))
				mustRequireImg:loadTexture(sObjectInfoMgr:GetItemIconPath(requireItemID))
				-- 所需数量
				existingCount = sObjectInfoMgr:GetItemCount(requireItemID)
				-- label
				mustRequireCountLabel = self:getChild(string.format("Label_Progress%d", i))
				mustRequireCountLabel:setString(tostring(existingCount) .. "/" .. tostring(requireCount))
				-- progress bar
				mustRequireCountProgress = self:getChild(string.format("ProgressBar_%d", i))
				mustRequireCountProgress:setPercent((existingCount / requireCount) * 100)
			end
		end
	else
		assert(false)
	end

	for i = 1,4 do
		local bg = self:getChild(string.format("Image_equip%d_bg",i))
		if i == index then
			bg:loadTexture("maininterface/hero_forgingbg03.png")
		else
			bg:loadTexture("maininterface/hero_forgingbg01.png")
		end
	end
end

function EquipLayer:ShowMainMenu(  )
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

function EquipLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function EquipLayer:heroCallback( )
	self:setVisible(false)
	self:getParent():removeChild(self, true)
end

function EquipLayer:FormationCallback(  )
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(formationLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function EquipLayer:MapCallback(  )
	local mapLayer = require("UI.mapLayer").new()
	if mapLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(mapLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function EquipLayer:BagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(BagLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end


function EquipLayer:showForgeCallback(  )
	self._forgeNode:setVisible(true)
	self._upgradeNode:setVisible(false)

	self._forgeBtn:loadTextureNormal("button/button_chatbg01.png")
	self._forgeBtn:loadTexturePressed("button/button_chatbg01.png")

	self._upgradeBtn:loadTextureNormal("button/button_chatbg02.png")
	self._upgradeBtn:loadTextureNormal("button/button_chatbg02.png")
end

function EquipLayer:showUpgradeCallback( ... )
	self._forgeNode:setVisible(false)
	self._upgradeNode:setVisible(true)

	self._upgradeBtn:loadTextureNormal("button/button_chatbg01.png")
	self._upgradeBtn:loadTexturePressed("button/button_chatbg01.png")

	self._forgeBtn:loadTextureNormal("button/button_chatbg02.png")
	self._forgeBtn:loadTextureNormal("button/button_chatbg02.png")
end

function EquipLayer:returnCallback( )
	self:removeFromParent()
end

return EquipLayer