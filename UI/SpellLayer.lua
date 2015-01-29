local SpellLayer = class("SpellLayer",
	function()
		local layer = ccui.loadLayer("ui/Spell")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function SpellLayer:ctor( guid )
	assert(guid)
	self._guid = guid
	self._languageId = 1

	self:InitInfo()

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

	self._equipBtn = self:getChild("Button_Equip")
	self._equipBtn:setTouchEnabled(true)
	self._equipBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.EquipCallback)})

	self._heroInfoBtn = self:getChild("Button_Info")
	self._heroInfoBtn:setTouchEnabled(true)
	self._heroInfoBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.HeroInfoCallback)})

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

	self:AutoScale()
end

function SpellLayer:AutoScale( )
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

function SpellLayer:update( dt )
	self.data:clear()

	-- check the update of coins and diamond
	self.data:setU32(sObjectInfoMgr:GetCoin())
	self.data:setU32(sObjectInfoMgr:GetDiamond())
end

function SpellLayer:reload(  )
	-- update coins and diamonds
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))
end

function SpellLayer:InitInfo()
	self._learnSpells = sObjectInfoMgr:GetLearnedSpells(self._guid)
	self._unlearnSpells = sObjectInfoMgr:GetUnlearnedSpells(self._guid)
	assert(#self._learnSpells + #self._unlearnSpells == 4)

	for i = 1,#self._learnSpells do
		local iconPath = GetSpellIconPath(self._learnSpells[i])
		local image = self:getChild(string.format("Image_spell%d",i))
		image:loadTexture(iconPath)
		local spellBtn = self:getChild(string.format("Image_spell%d_bg",i))
		spellBtn:setTouchEnabled(true)
		spellBtn:setTag(i)
		spellBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.SpellBtnCallback)})

		local spellBtnNameLabel = self:getChild(string.format("Label_name%d", i))
		local name = GetSpellName(self._learnSpells[i], self._languageId)
		if spellBtnNameLabel and name then 
			spellBtnNameLabel:setString(name)
		end
	end

	local index = 1
	for i = #self._learnSpells + 1,4 do
		local iconPath = GetSpellIconPath(self._unlearnSpells[index])
		local image = self:getChild(string.format("Image_spell%d",i))
		image:loadTexture(iconPath)
		local spellBtn = self:getChild(string.format("Image_spell%d_bg",i))
		local spellFrm = self:getChild(string.format("Image_spellFrm%d",i))
		spellBtn:setTouchEnabled(true)
		spellBtn:setTag(i)
		spellBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.SpellBtnCallback)})
		image:setShader("gray")
		spellBtn:setShader("gray")
		spellFrm:setShader("gray")

		local spellBtnNameLabel = self:getChild(string.format("Label_name%d", i))
		local name = GetSpellName(self._unlearnSpells[index], self._languageId)
		if spellBtnNameLabel and name then 
			spellBtnNameLabel:setString(name)
		end
		spellBtnNameLabel:setColor(cc.c3b(76,76,76))

		index = index + 1
	end

	-- 设置默认初始化选择第一个技能
	local bg = self:getChild("Image_spell1_bg")
	bg:loadTexture("maininterface/hero_forgingbg03.png")

	-- 更新右边的技能描述
	self._srvSpellInfo = self:getChild("ScrollView_spellInfo")
	if self._srvSpellInfo ~= nil then 
		self._srvSpellInfo:setBounceEnabled(true)
		self._srvSpellInfo:setClippingEnabled(true)
	end

	if self._learnSpells ~= nil and table.nums(self._learnSpells) > 0 then 
		self:UpdateSpellInfo(self._learnSpells[1])
	else		
		self:UpdateSpellInfo(self._unlearnSpells[1])
	end
end

function SpellLayer:UpdateSpellInfo( spellId )
	if self._srvSpellInfo ~= nil then 
		self._srvSpellInfo:removeAllChildren()

		local innerHeight = 0
		
		local nameLabel = ccui.label({text = "技能名字", fontSize = 24})
		local name = GetSpellName(spellId, self._languageId)
		if nameLabel ~= nil and name ~= nil then 
			nameLabel:setColor(cc.c3b(125, 46, 2))
			nameLabel:setString(name)
			innerHeight = innerHeight + 6.5 + nameLabel:getContentSize().height
		end

		local descLabel = nil
		local desc = GetSpellDesc(spellId, self._languageId)
		if desc ~= nil then 
			descLabel = cc.LabelTTF:create(desc, "", 22, cc.size(360, 0), cc.TEXT_ALIGNMENT_LEFT)
			if descLabel ~= nil then 
				descLabel:setColor(cc.c3b(160, 58, 3))
				--descLabel:setString(desc)
				innerHeight = innerHeight + 27.5 + descLabel:getContentSize().height
			end
		end

		self._srvSpellInfo:setInnerContainerSize(cc.size(self._srvSpellInfo:getContentSize().width, innerHeight))
		local Size = self._srvSpellInfo:getInnerContainerSize()
		if descLabel ~= nil and nameLabel ~= nil then 
			nameLabel:setPosition(cc.p(11 + nameLabel:getContentSize().width/2, Size.height - 6.5 - nameLabel:getContentSize().height/2))
			self._srvSpellInfo:addChild(nameLabel)

			descLabel:setPosition(cc.p(Size.width/2, nameLabel:getPositionY() - nameLabel:getContentSize().height/2 - 27.5 - descLabel:getContentSize().height/2))
			self._srvSpellInfo:addChild(descLabel)
		end
	end
end

function SpellLayer:SpellBtnCallback( widget )
	local index = widget:getTag()
	local spellId
	if index <=  #self._learnSpells then
		spellId = self._learnSpells[index]
	else
		spellId = self._unlearnSpells[index - #self._learnSpells]
	end
	cclog("spellLayer,press spellBtn,spellId:"..spellId)

	-- update spell info part
	self:UpdateSpellInfo(spellId)

	-- update bg
	for i = 1,4 do
		local bg = self:getChild(string.format("Image_spell%d_bg",i))
		if i == index then
			bg:loadTexture("maininterface/hero_forgingbg03.png")
		else
			bg:loadTexture("maininterface/hero_forgingbg01.png")
		end
	end
end

function SpellLayer:HeroInfoCallback( ... )
	local parent = self:getParent()
	local HeroInfoLayer = require("UI.HeroInfoLayer").new(self._guid)
	parent:addChild(HeroInfoLayer)

	self:removeFromParent()
end

function SpellLayer:EquipCallback( ... )
	local parent = self:getParent()
	local equip = require("UI.EquipLayer").new(self._guid)
	parent:addChild(equip)

	self:removeFromParent()
end

function SpellLayer:returnCallback( )
	self:removeFromParent()
end

function SpellLayer:ShowMainMenu(  )
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

function SpellLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function SpellLayer:heroCallback( )
	self:setVisible(false)
	self:getParent():removeChild(self, true)
end

function SpellLayer:FormationCallback(  )
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(formationLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function SpellLayer:MapCallback(  )
	local mapLayer = require("UI.mapLayer").new()
	if mapLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(mapLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function SpellLayer:BagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(BagLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

return SpellLayer