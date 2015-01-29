local FormationLayer = class("IndexLayer",
	function()
		local layer = ccui.loadLayer("ui/Formation")
		layer:setNodeEventEnabled(true)
		return layer
	end
)



function FormationLayer:ctor( ... )
	self._type = LocationType.LOCATION_ALL
	self._battlePlayers = {}

	self._scrollview = self:getChild("ScrollView_hero")

	self._returnBtn = self:getChild("Button_return")
	self._returnBtn:setTouchEnabled(true)
	self._returnBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.returnCallback)})

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

	self._formationBtn = self:getChild("Button_Battle")
	self._formationBtn:setTouchEnabled(true)
	self._formationBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.formationCallback)})

	local team = 0
	local playermap = ObjectMgr:GetPlayerMap()
	for k,v in pairs(playermap) do
		if v:IsInTeam(team) then
		--if band(v:getTeamFlags(),lshift(1,team)) > 0 then
			self._battlePlayers[#self._battlePlayers + 1] = k
		end
	end

	self:AutoScale()
end

function FormationLayer:AutoScale( )
	if display.width == 1136 and display.height == 640 then
		self:getChild("Image_bg"):setScaleX(display.width/960)
		return
	end
	
	if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
		self:getChild("Image_bg"):setScaleY(display.height/640)
	else
		self:getChild("Image_bg"):setScaleX(display.width/960)
	end
end

function FormationLayer:formationCallback( widget )
	for i = 1,#self._battlePlayers do
		local class = sObjectInfoMgr:GetPlayerClass(self._battlePlayers[i])
		local t = {3,6,10,14,15,89}
		if not table.keyof(t,class) then
			sGameMgr:ShowInfo("只能选择3,6,10,14,15,89")
			return
		end
	end

	local packet = WorldPacket:new(CMSG_GAME_MODIFY_TEAM,60)
	packet:setU8(0)
	for i = 1,#self._battlePlayers do
		packet:setU32(self._battlePlayers[i])  --packet:setU64(self._battlePlayers[i])
	end
	for i = #self._battlePlayers + 1,5 do
		packet:setU32(0)--packet:setU64(0)
	end
   	network.send(packet)

   	--sObjectInfoMgr:SetBattlePlayers( self._battlePlayers )
end

function FormationLayer:returnCallback( )
	self:removeFromParent()
end

function FormationLayer:locTypeCallback( widget )
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

function FormationLayer:ChooseHeroCallback( widget )
	local guid = widget._guid
	cclog("guid:"..guid)

	local selImg = widget:getChild("Image_select")
	selImg:setVisible(true)
	
	self:OpBattle(guid,1)
end

local function ClassComp( guid1,guid2 )
	--排序规则。。。按位置
	local class1 = sObjectInfoMgr:GetPlayerClass(guid1)
	local class2 = sObjectInfoMgr:GetPlayerClass(guid2)

	return class1 < class2
end

--op:1为加入战斗队列,0为退出战斗队列
function FormationLayer:OpBattle(guid, op)
	if op == 1 then --入队
		if table.keyof(self._battlePlayers,guid) then
			return
		end

		self._battlePlayers[#self._battlePlayers + 1] = guid

		table.sort(self._battlePlayers,ClassComp)

		print(unpack(self._battlePlayers))
	else
		local removeList = {}
		for i = 1,#self._battlePlayers do
			if self._battlePlayers[i] == guid then
				removeList[#removeList + 1] = i
			end
		end
		for i = 1,#removeList do
			table.remove(self._battlePlayers,removeList[i])
		end

		table.sort(self._battlePlayers,Comp)

		print(unpack(self._battlePlayers))
	end
end

function FormationLayer:update( dt )
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

	self.data:setU32(#self._battlePlayers)
	for i = 1,#self._battlePlayers do
		self.data:setU32(self._battlePlayers[i])
	end
end

local function PowerComp( guid1,guid2 )
	--排序规则。。。按战斗力
	local combatPower1 = sObjectInfoMgr:GetCombatPower(guid1)
	local combatPower2 = sObjectInfoMgr:GetCombatPower(guid2)

	return combatPower1 < combatPower2
end

function FormationLayer:reload( )

	local playerCounts = self.data:getU32()
	cclog("FormationLayer playerCounts:"..playerCounts)
	
	local guidList = {}
	for i = 1,playerCounts do
		local guid = self.data:getU32()
		guidList[#guidList + 1] = guid
	end

	self:makeitem(guidList)

	table.sort(guidList,PowerComp)

	local battlePlayersSize = self.data:getU32()
	for i = 1,battlePlayersSize do
		local guid = self.data:getU32()
		
	end

	self:HandleBattlePlayer()
end

function FormationLayer:leaveTeamCallback( widget )
	local idx = widget:getTag() - 10086

	table.remove(self._battlePlayers,idx)

	--widget:removeFromParent()
end

function FormationLayer:HandleBattlePlayer()
	local frm = self:getChild("Image_10")
	for i = 1,5 do
		frm:removeChildByTag(10086+i)
	end

	for i = 1,#self._battlePlayers do
		local btn = self:getChild(string.format("Image_player%d",i))
		btn:setVisible(true)
		local item = ccui.loadWidget("HeroIcon")
		item:setTag(10086 + i)
		frm:addChild(item)
		-- item:pos(cc.p(btn:getPositionX()- btn:getContentSize().width/2,btn:getPositionY()- btn:getContentSize().height/2 ))
		item:pos(cc.p(btn:getPositionX() - item:getContentSize().width/2, btn:getPositionY() - item:getContentSize().height/2 + 3.5))
if true then
	local class = sObjectInfoMgr:GetPlayerClass(self._battlePlayers[i])
	local label = ccui.label({text=tostring(class),fontSize = 24})
	label:setColor(cc.c3b(0,0,0))
	label:setTouchEnabled(false)
	item:addChild(label,10000)
	label:pos(item:getChild("Image_hero"):getPosition())
end
		--设置item外观
		item:getChild("Image_hero"):loadTexture(sObjectInfoMgr:GetPlayerIconPath(self._battlePlayers[i]))
		item:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.leaveTeamCallback)})
		-- frame img
		-- self:setItemFrame(item, self._battlePlayers[i])
		-- level
		local level = sObjectInfoMgr:GetPlayerLevel(self._battlePlayers[i])
		item:getChild("Label_level"):setString(tostring(level))
	end

	for i = #self._battlePlayers + 1,5 do
		local btn = self:getChild(string.format("Image_player%d",i))
		btn:setVisible(true)
	end

	-- 更新战斗力统计
	self:updateCombatPower()
end

function FormationLayer:makeitem( guidList )
	local itempath = "HeroIcon"
	local col = 5
	local itemCount = #guidList

	self._scrollview:removeAllChildren()

	--add custom item
	local Size = self._scrollview:getContentSize()
	local row = 0
	if #guidList % col == 0 then
		row = itemCount/col
	else
		row = itemCount/col + 1
	end

	local item = ccui.loadWidget(itempath)
	local height = row * item:getContentSize().height
	local innerSize = cc.size(Size.width,height)
	self._scrollview:setInnerContainerSize(innerSize)
	Size = self._scrollview:getInnerContainerSize()

	local wSpace,hSpace = 20,10
	for i = row,1,-1 do
		for j = 1,col do
			if itemCount <= 0 then break end
			local guid = guidList[itemCount]

			local item = ccui.loadWidget(itempath)
			item:getChild("Image_hero"):loadTexture(sObjectInfoMgr:GetPlayerIconPath(guid))
			if table.keyof(self._battlePlayers,guid) then
				item:getChild("Image_select"):setVisible(true)
			end
if true then
	local class = sObjectInfoMgr:GetPlayerClass(guid)
	local label = ccui.label({text=tostring(class),fontSize = 24})
	label:setTouchEnabled(false)
	label:setColor(cc.c3b(0,0,0))
	item:addChild(label,10000)
	label:pos(item:getChild("Image_hero"):getPosition())
end

			--item callback
			item._guid = guid
			item:setTouchEnabled(true)
			item:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.ChooseHeroCallback)})
			-- frame img
			-- self:setItemFrame(item, guid)
			local level = sObjectInfoMgr:GetPlayerLevel(guid)
			item:getChild("Label_level"):setString(tostring(level))

			local x = (j - 1) * item:getContentSize().width + wSpace * j
			local y = Size.height - item:getContentSize().height * (row - i + 1)
			item:setPosition(cc.p(x,y))
			cclog("item pos,x:%f,y:%f",x,y)
			self._scrollview:addChild(item)

			itemCount = itemCount - 1
		end
	end

	self._scrollview:setBounceEnabled(true)
	self._scrollview:setClippingEnabled(true)
end

function FormationLayer:setItemFrame( item, guid )
	local grade = sObjectInfoMgr:GetPlayerGrade(guid)
	if item ~= nil and grade ~= nil then 
		local tbFrmImgPath = {
			[1]		= "cardlvup/hero_classbg_d.png",
			[2]		= "cardlvup/hero_classbg_c.png",
			[3]		= "cardlvup/hero_classbg_b.png",
			[4]		= "cardlvup/hero_classbg_a.png",
			[5]		= "cardlvup/hero_classbg_sss.png",
			[6]		= "cardlvup/hero_classbg_d.png",
			[7]		= "cardlvup/hero_classbg_d.png",
			[8]		= "cardlvup/hero_classbg_d.png",
			[9]		= "cardlvup/hero_classbg_d.png",
			[10]	= "cardlvup/hero_classbg_d.png",
		}

		item:getChild("Image_bg"):loadTexture(tbFrmImgPath[grade], 1)

		local tbGradeImgPath = {
			[1]		= "cardlvup/hero_class_e.png",
			[2]		= "cardlvup/hero_class_d.png",
			[3]		= "cardlvup/hero_class_c.png",
			[4]		= "cardlvup/hero_class_b.png",
			[5]		= "cardlvup/hero_class_a.png",
			[6]		= "cardlvup/hero_class_s.png",
			[7]		= "cardlvup/hero_class_ss.png",
			[8]		= "cardlvup/hero_class_sss.png",
			[9]		= "cardlvup/hero_class_e.png",
			[10]	= "cardlvup/hero_class_e.png",
		}

		item:getChild("Image_grade"):loadTexture(tbGradeImgPath[grade], 1)
	end
end

function FormationLayer:updateCombatPower(  )
	local count = table.nums(self._battlePlayers)
	if count > 0 then 
		local totalCombatPower = 0
		for i = 1, count do
			totalCombatPower = totalCombatPower + sObjectInfoMgr:GetCombatPower(self._battlePlayers[i])
		end

		self:getChild("Label_combatpower"):setString(tostring(totalCombatPower))
	elseif count == 0 then 
		self:getChild("Label_combatpower"):setString("0")
	end
end

return FormationLayer