local HeroInfoLayer = class("HeroInfoLayer",
	function()
		local layer = ccui.loadLayer("ui/HeroInfo")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function HeroInfoLayer:ctor(guid )
	assert(guid)
	self._guid = guid
	self._languageId = 1

	self:InitInfo()

	self._equipBtn = self:getChild("Button_Equip")
	self._equipBtn:setTouchEnabled(true)
	self._equipBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.EquipCallback)})

	self._spellBtn = self:getChild("Button_Spell")
	self._spellBtn:setTouchEnabled(true)
	self._spellBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.SpellCallback)})

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

	self._addExpBtn = self:getChild("Button_addExp")
	self._addExpBtn:setTouchEnabled(true)
	self._addExpBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.addExpCallback)})

	self._addDebrisBtn = self:getChild("Button_addDebris")
	self._addDebrisBtn:setTouchEnabled(true)
	self._addDebrisBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.addDebrisCallback)})

	self._upgradeBtn = self:getChild("Button_upgrade")
	self._upgradeBtn:setTouchEnabled(true)
	self._upgradeBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.upgradeCallback)})

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

	self:LoadArmature()
	self:AutoScale()
end

function HeroInfoLayer:LoadArmature()
	local filename = sDisplayInfoStore[self._playerInfo._class]
if not filename then
	filename = sDisplayInfoStore[4]
end
	assert(filename,"nil display entry")
	if LOAD_ARMATURE == LOAD_ARMATURE_BY_CCS then
		filename = filename.xmlPath
	end

	self._armature = ccui.loadArmature( filename )

	self._armature:setScale(1.2)
	self._armature:getAnimation():playWithIndex(0)
	self._armature:pos(cc.p(self:getChild("Image_hero_bg"):getSize().width/2,30))
	self:getChild("Image_hero_bg"):addChild(self._armature,10000)

	local function movementEventCallback( armature, type, movementID )
		if type == ccs.MovementEventType.loopComplete or type == ccs.MovementEventType.complete then
	    	armature:getAnimation():play(Action.Idle)
	    end
	end

	self._armature:getAnimation():setMovementEventCallFunc(movementEventCallback);

	self:getChild("Image_hero_bg"):setTouchEnabled(true)
	self:getChild("Image_hero_bg"):addTouchEvent({[ccui.TouchEventType.ended] = function ()
		local actionList = {"standby","walk","victory","attack","skill1","skill2","skill3"}
		local index = math.random(1,#actionList)
		self._armature:getAnimation():play(actionList[index])
	end})
end

function HeroInfoLayer:AutoScale( )
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

function HeroInfoLayer:update( dt )
	self.data:clear()

	-- check the update of coins and diamond
	self.data:setU32(sObjectInfoMgr:GetCoin())
	self.data:setU32(sObjectInfoMgr:GetDiamond())

	-- 检测各数值
	self.data:setU32(self._playerInfo._level)				-- 等级
	self.data:setU32(self._playerInfo._combatPower)			-- 战斗力
	self.data:setU32(self._playerInfo._exp)					-- 经验
	self.data:setU32(self._playerInfo._nextExp)				-- 升级经验
	self.data:setU32(self._playerInfo._grade)				-- 评级
	self.data:setU32(self._playerInfo._debrisCounts)		-- 灵魂石

	self.data:setU32(self._playerInfo._strengthGrow)		-- 力量成长	
	self.data:setU32(self._playerInfo._intelligenceGrow)	-- 智力成长
	self.data:setU32(self._playerInfo._agilityGrow)			-- 敏捷成长
	self.data:setU32(self._playerInfo._strength)			-- 力量
	self.data:setU32(self._playerInfo._extraStrength)		-- 力量加成
	self.data:setU32(self._playerInfo._intelligence)		-- 智力
	self.data:setU32(self._playerInfo._extraIntelligence)	-- 智力加成
	self.data:setU32(self._playerInfo._agility)				-- 敏捷
	self.data:setU32(self._playerInfo._extraAgility)		-- 敏捷加成
	self.data:setU32(self._playerInfo._hp)					-- 最大生命值
	self.data:setU32(self._playerInfo._phy_dmg)				-- 物理攻击力
	self.data:setU32(self._playerInfo._magic_dmg)			-- 魔法强度
	self.data:setU32(self._playerInfo._armor)				-- 物理护甲
	self.data:setU32(self._playerInfo._resis)				-- 魔法抗性
	self.data:setU32(self._playerInfo._crit)				-- 物理暴击
	self.data:setU32(self._playerInfo._hpRecover)			-- 生命回复
	self.data:setU32(self._playerInfo._powerRecover)		-- 能量回复
	self.data:setU32(self._playerInfo._dodge)				-- 闪避
	self.data:setU32(self._playerInfo._strikeArmor)			-- 穿透物理护甲
	self.data:setU32(self._playerInfo._absorbHeal)			-- 吸血等级
	self.data:setU32(self._playerInfo._hit)					-- 命中
end

function HeroInfoLayer:reload(  )
	-- update coins and diamonds
	local coin = self.data:getU32()
	local diamond = self.data:getU32()
	self:getChild("AtlasLabel_gold"):setString(tostring(coin))
	self:getChild("AtlasLabel_Diamond"):setString(tostring(diamond))

	-- 等级
	if self._levelLabel ~= nil then 
		self._levelLabel:setString(self._playerInfo._level)
	end
	-- 战斗力
	if self._combatPowerLabel ~= nil then 
		self._combatPowerLabel:setString(self._playerInfo._combatPower)
		--self._combatPowerLabel:enableOutline(cc.c4b(37,20,6,255),2)
		--self:getChild("Label_power"):enableOutline(cc.c4b(37,20,6,255),2)
		--self:getChild("Label_power"):enableShadow(cc.c4b(0, 0, 0, 255),cc.size(0,-2))
	end
	-- 经验
	if self._expProgressBar ~= nil then 
		local percent = (self._playerInfo._exp / self._playerInfo._nextExp) * 100
		if self._playerInfo._nextExp <= 0 or self._playerInfo._nextExp == nil then
			--assert(false, "server error")
			percent = 0
		end
		self._expProgressBar:setPercent(percent)
	end
	-- 评级
	if self._gradeImg ~= nil then 
		self._gradeImg:loadTexture(self:getGradeIcon(self._playerInfo._grade))
	end
	-- 灵魂石
	local item = ObjectMgr:GetItem(self._playerInfo._debrisCounts)
	if item ~= nil then 
		local curItemCount = sObjectInfoMgr:GetItemCount(item:getItemId())
		local upgradeItemCount = getUpgradeItemCount(self._playerInfo._grade)
		if self._debrisProgressBar ~= nil then 
			self._debrisProgressBar:setPercent((curItemCount / upgradeItemCount) * 100)
		end
		if self._debirsLabel ~= nil then 
			self._debirsLabel:setString(tostring(curItemCount) .. "/" .. tostring(upgradeItemCount))
		end
	else
		--assert(false,"nil debris")
		self._debrisProgressBar:setPercent(0)
		self._debirsLabel:setString("0/100")
	end
	-- 各细节属性
	if self._detail ~= nil then
		local pTextRich = self._detail:getChildByTag(162018)-- 162018: 代表pTR，在字母表中的顺序ID，p是第16个
		if pTextRich ~= nil then 
			self._detail:removeChild(pTextRich, true)
		end

		self:testRichText(self._detail)
	end
end

function HeroInfoLayer:getGradeIcon( grade )
	local iconTable = {
		[1] = "hero_class_e.png",
		[2] = "hero_class_d.png",
		[3] = "hero_class_c.png",
		[4] = "hero_class_b.png",
		[5] = "hero_class_a.png",
		[6] = "hero_class_s.png",
		[7] = "hero_plus_b.png",
		[8] = "hero_class_ss.png",
		[9] = "hero_plus_a.png",
		[10] = "hero_class_sss.png",
	}

	if grade <= 0 or grade > 10 then
		return iconTable[1]
	end
	return iconTable[grade]
end

local function getUpgradeItemCount( grade )
	if grade <= 0 or grade > 10 then
		return 0
	end

	math.newrandomseed()
	return math.random(100,600)
end

function HeroInfoLayer:InitInfo(  )
	self._playerInfo = sObjectInfoMgr:GetPlayerInfo(self._guid)
	local nameLabel = self:getChild("Label_name")
	nameLabel:setString(self._playerInfo._name)

	self._levelLabel = self:getChild("Label_Level")
	self._levelLabel:setString("1")

	self._combatPowerLabel = self:getChild("Label_combatpower")
	self._combatPowerLabel:setString("0")

	self._detail = self:getChild("ScrollView_detail")
	self._detail:setVisible(true)

	self._expProgressBar = self:getChild("ProgressBar_exp")
	self._expProgressBar:setPercent(0)

	self._gradeImg = self:getChild("Image_grade_bg")
	self._gradeImg:loadTexture(self:getGradeIcon(1))

	self._debrisProgressBar = self:getChild("ProgressBar_Debris")
	self._debirsLabel = self:getChild("Label_DebrisPer")

	--cclog(string.format("----------ProgressBar_Debris pos:%f,%f",debrisProgressBar:getPositionX(),debrisProgressBar:getPositionY()))
end

function HeroInfoLayer:returnCallback( )
	self:removeFromParent()
end

function HeroInfoLayer:SpellCallback( ... )
	local parent = self:getParent()
	local spell = require("UI.SpellLayer").new(self._guid)
	parent:addChild(spell)

	self:removeFromParent()
end

function HeroInfoLayer:EquipCallback( ... )
	local parent = self:getParent()
	local equip = require("UI.EquipLayer").new(self._guid)
	parent:addChild(equip)

	self:removeFromParent()
end

function HeroInfoLayer:ShowMainMenu(  )
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

function HeroInfoLayer:hideMainMenu( widget )
	self._maskImg:setTouchEnabled(false)
	self._maskImg:setOpacity(0)
	self:ShowMainMenu()
end

function HeroInfoLayer:heroCallback( )
	self:setVisible(false)
	self:getParent():removeChild(self, true)
end

function HeroInfoLayer:FormationCallback(  )
	local formationLayer = require("UI.FormationLayer").new()
	if formationLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(formationLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function HeroInfoLayer:MapCallback(  )
	local mapLayer = require("UI.mapLayer").new()
	if mapLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(mapLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end

function HeroInfoLayer:BagCallback(  )
	local BagLayer = require("UI.BagLayer").new()
	if BagLayer ~= nil then 
		local heroLayer = self:getParent()
		local mainLayer = heroLayer:getParent()
		heroLayer:setVisible(false)
		mainLayer:addChild(BagLayer)
		mainLayer:removeChild(heroLayer, true)
	end
end


function HeroInfoLayer:addExpCallback(  )
	local addexp = require("UI.Dialog.AddExp").new(self._guid)
	self:addChild(addexp)
end

function HeroInfoLayer:addDebrisCallback(  )
	sGameMgr:ShowInfo("addDebrisCallback, 暂时还没实现")
end

function HeroInfoLayer:upgradeCallback(  )
	--sGameMgr:ShowInfo("addDebrisCallback, 暂时还没实现")

	cclog("send hero upgrade mgs,guid:"..self._guid)
	local packet = WorldPacket:new(CMSG_UPGRADE_CHARACTER,4)
	packet:setU32(self._guid)
   	network.send(packet)
	
end

function HeroInfoLayer:testRichText( widget )
	local pTextRich = CTextRich:create();
	pTextRich:setMaxLineLength(20);
	pTextRich:setVerticalSpacing(5);

	local innerHeight = 0

	-- 标题
	local labelTitle = ccui.label({text = "详细信息", fontSize = 24})
	labelTitle:setColor(cc.c3b(153, 51, 0))
	
	-- 标题背景
	local titleBg = ccui.image({image = "maininterface/hero_title01.png"})
	innerHeight = innerHeight + titleBg:getContentSize().height

	-- 简介
	-- title of intro
	local labelIntro = ccui.label({text = "角色简介", fontSize = 24})
	labelIntro:setColor(cc.c3b(36, 66, 34))
	innerHeight = innerHeight + labelIntro:getContentSize().height
	
	local entry = sLocaleUnitStore[self._guid]
	local desc = nil
	local tag = nil
	if entry ~= nil then
		local str = nil

		-- desc
		str = entry.desc[self._languageId-1]
		if str ~= nil then 
			desc = cc.LabelTTF:create(str,"",22,cc.size(widget:getContentSize().width ,0),cc.TEXT_ALIGNMENT_LEFT)
			desc:setColor(cc.c3b(36, 66, 34))
			innerHeight = innerHeight + desc:getContentSize().height + 15
		end
		-- tag(口头禅)
		str = entry.tag[self._languageId-1]
		if str ~= nil then 
			tag = cc.LabelTTF:create(str,"",22,cc.size(widget:getContentSize().width ,0),cc.TEXT_ALIGNMENT_LEFT)
			tag:setColor(cc.c3b(65, 47, 26))
			innerHeight = innerHeight + tag:getContentSize().height + 15
		end

		if desc == nil and tag == nil then 
			labelIntro:setVisible(false)
		end
	else
		labelIntro:setVisible(false)
	end

	-- line img
	local lineImg = ccui.image({image = "sundry/line_04.png"})
	innerHeight = innerHeight + lineImg:getContentSize().height + 10

	-- title of detail
	local labelArr = ccui.label({text = "属性", fontSize = 24})
	labelArr:setColor(cc.c3b(36, 66, 34))
	innerHeight = innerHeight + labelArr:getContentSize().height + 10

	-- 详细信息
	local color_Des_Grow = cc.c3b(125, 46, 2)
	local color_Des_Attribute = cc.c3b(255, 115, 0)
	
	local textSize = 20

	local basicValue = 0
	local extraValue = 0

	local player = ObjectMgr:GetPlayer(self._guid)
	if player ~= nil then
		-- 力量成长
		basicValue = self._playerInfo._strengthGrow
		self:insertElementToTextRich(pTextRich, "力量成长: ", basicValue, 0, textSize, textSize, color_Des_Grow)
		-- 智力成长
		basicValue = self._playerInfo._intelligenceGrow
		self:insertElementToTextRich(pTextRich, "智力成长: ", basicValue, 0, textSize, textSize, color_Des_Grow)
		-- 敏捷成长
		basicValue = self._playerInfo._agilityGrow
		self:insertElementToTextRich(pTextRich, "敏捷成长: ", basicValue, 0, textSize, textSize, color_Des_Grow)
		-- 力量
		basicValue = self._playerInfo._strength
		extraValue = self._playerInfo._extraStrength
		self:insertElementToTextRich(pTextRich, "力量: ", basicValue, extraValue, textSize, textSize, color_Des_Attribute)
		-- 智力
		basicValue = self._playerInfo._intelligence
		extraValue = self._playerInfo._extraIntelligence
		self:insertElementToTextRich(pTextRich, "智力: ", basicValue, extraValue, textSize, textSize, color_Des_Attribute)
		-- 敏捷
		basicValue = self._playerInfo._agility
		extraValue = self._playerInfo._extraAgility
		self:insertElementToTextRich(pTextRich, "敏捷: ", basicValue, extraValue, textSize, textSize, color_Des_Attribute)
		-- 最大生命值
		basicValue = self._playerInfo._hp
		self:insertElementToTextRich(pTextRich, "最大生命值: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 物理攻击力
		basicValue = self._playerInfo._phy_dmg
		self:insertElementToTextRich(pTextRich, "物理攻击力: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 魔法强度
		basicValue = self._playerInfo._magic_dmg
		self:insertElementToTextRich(pTextRich, "魔法强度: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 物理护甲
		basicValue = self._playerInfo._armor
		self:insertElementToTextRich(pTextRich, "物理护甲: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 魔法抗性
		basicValue = self._playerInfo._resis
		self:insertElementToTextRich(pTextRich, "魔法抗性: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 物理暴击
		basicValue = self._playerInfo._crit
		self:insertElementToTextRich(pTextRich, "物理暴击: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 生命回复
		basicValue = self._playerInfo._hpRecover
		self:insertElementToTextRich(pTextRich, "生命回复: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 能量回复
		basicValue = self._playerInfo._powerRecover
		self:insertElementToTextRich(pTextRich, "能量回复: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 闪避
		basicValue = self._playerInfo._dodge
		self:insertElementToTextRich(pTextRich, "闪避: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 穿透物理护甲
		basicValue = self._playerInfo._strikeArmor
		self:insertElementToTextRich(pTextRich, "穿透物理护甲: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 吸血等级
		basicValue = self._playerInfo._absorbHeal
		self:insertElementToTextRich(pTextRich, "吸血等级: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
		-- 命中
		basicValue = self._playerInfo._hit
		self:insertElementToTextRich(pTextRich, "命中: ", basicValue, 0, textSize, textSize, color_Des_Attribute)
	end

	pTextRich:reloadData();
	innerHeight = innerHeight + pTextRich:getContentSize().height + 15

	widget:setInnerContainerSize(cc.size(widget:getContentSize().width, innerHeight))
	widget:setBounceEnabled(true)
	widget:setClippingEnabled(true)
	local innerSize = widget:getInnerContainerSize()

	titleBg:setPosition(cc.p(innerSize.width/2, innerSize.height - titleBg:getContentSize().height/2))
	widget:addChild(titleBg)
	local imgLineY = titleBg:getPositionY() - titleBg:getContentSize().height/2

	labelTitle:setPosition(titleBg:getPosition())
	widget:addChild(labelTitle)
	
	labelIntro:setPosition(cc.p(labelIntro:getContentSize().width/2, titleBg:getPositionY() - titleBg:getContentSize().height/2 - labelIntro:getContentSize().height/2))
	widget:addChild(labelIntro)

	if desc ~= nil then
		desc:setPosition(cc.p(desc:getContentSize().width/2, labelIntro:getPositionY() - labelIntro:getContentSize().height/2 - 15 - desc:getContentSize().height/2))
		widget:addChild(desc)

		imgLineY = desc:getPositionY() - desc:getContentSize().height/2
	end

	if tag ~= nil then 
		if desc ~= nil then 
			tag:setPosition(cc.p(tag:getContentSize().width/2, desc:getPositionY() - desc:getContentSize().height/2 - 15 - tag:getContentSize().height/2))
		else
			tag:setPosition(cc.p(tag:getContentSize().width/2, labelIntro:getPositionY() - labelIntro:getContentSize().height/2 - 15 - tag:getContentSize().height/2))
		end
		widget:addChild(tag)

		imgLineY = tag:getPositionY() - tag:getContentSize().height/2
	end

	lineImg:setPosition(cc.p(widget:getContentSize().width/2, imgLineY - 10 - lineImg:getContentSize().height/2))
	widget:addChild(lineImg)

	labelArr:setPosition(cc.p(labelArr:getContentSize().width/2, lineImg:getPositionY() - lineImg:getContentSize().height/2 - 10 - labelIntro:getContentSize().height/2))
	widget:addChild(labelArr)

	pTextRich:setPosition(cc.p(pTextRich:getContentSize().width/2, labelArr:getPositionY() - labelArr:getContentSize().height/2 - 15 - pTextRich:getContentSize().height/2))
	widget:addChild(pTextRich, 0, 162018);		-- 162018: 代表pTR，在字母表中的顺序ID，p是第16个
end

function HeroInfoLayer:insertElementToTextRich( pTextRich, strDescription, basicValue, extraValue, desSize, valueSize, desColor )
	if not pTextRich or strDescription == "" or basicValue == 0 then
		return false
	end

	local color_basic_num = cc.c3b(65, 47, 26)
	local color_extra_num = cc.c3b(119, 170, 136)
	local valueString = ""

	pTextRich:insertElement(strDescription, "", desSize, desColor);

	if extraValue ~= 0 then
		valueString = tostring(basicValue)
	else
		valueString = tostring(basicValue) .. "\n"
	end
	pTextRich:insertElement(valueString, "", valueSize, color_basic_num);

	if extraValue ~= 0 then
		valueString = "+" .. tostring(extraValue) .. "\n"
		pTextRich:insertElement(valueString, "", valueSize, color_extra_num);
	end

	return true
end

return HeroInfoLayer