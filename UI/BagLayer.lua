local BagLayer = class("BagLayer", 
	function (  )
		local layer = ccui.loadLayer("ui/Bag")
		layer:setNodeEventEnabled(true)
		return layer
	end
)

function BagLayer:ctor(  )
	self._languageId = 1

	self._srvItem = self:getChild("ScrollView_item")
	self._srvDetail = self:getChild("ScrollView_detail")
	self._labelCount = self:getChild("Label_count")

	local addCountBtn = self:getChild("Button_addCount")
	addCountBtn:setTouchEnabled(true)
	addCountBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.AddCountCallback)})

	local sellBtn = self:getChild("Button_sell")
	sellBtn:setTouchEnabled(true)
	sellBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.SellCallback)})

	local exitBtn = self:getChild("Button_exit")
	exitBtn:setTouchEnabled(true)
	exitBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.ExitCallback)})

	self._selectedCellID = 0
	self._tbCells = {}

	self:InitCells()

	self:AutoScale()
end

function BagLayer:AutoScale( )
	--self:getChild("Image_bg"):setScaleY(display.height/640)
end

function BagLayer:InitCells(  )
	-- 这里应该是从服务器返回背包中的物品的数据，这里暂时使用测试数据
	self._tbItemID = {
		[1]		 = 17,
		[2]		 = 1,
		[3]		 = 4,
		[4]		 = 7,
		[5]		 = 17,
		[6]		 = 1,
		[7]		 = 4,
		[8]		 = 7,
		[9]		 = 17,
		[10]	 = 1,
		[11]	 = 4,
		[12]	 = 7,
		[13]	 = 17,
		[14]	 = 1,
		[15]	 = 4,
		[16]	 = 7,
	}
end

function BagLayer:update( dt )
	self.data:clear()

	self.data:setU32(table.nums(self._tbItemID))
--	self.data:setU32(self._selectedCellID)
end

function BagLayer:reload(  )
--	local item = ObjectMgr:GetItem( self._tbItemID[self._selectedCellID] )

	-- table of items
	self:MakeItem(self._tbItemID)
end

function BagLayer:AddCountCallback(  )
	
end

function BagLayer:SellCallback(  )
	
end

function BagLayer:ExitCallback(  )
	self:getParent():removeChild(self, true)
end

function BagLayer:MakeItem( itemIDList )
	local itemPath = "ui/BagItem"
	local itemCount = table.nums(itemIDList)
	local col = 6
	local wSpace, hSpace = 20, 10
	self._srvItem:removeAllChildren()

	-- calculate some data
	local Size = self._srvItem:getContentSize()
	local row = 0
	if itemCount % col == 0 then 
		row = itemCount / col
	else
		row = itemCount / col + 1
	end
	row = math.modf(row)

	local item = ccui.loadWidget(itemPath)
	local innerSize = cc.size(Size.width, row * item:getContentSize().height)
	self._srvItem:setInnerContainerSize(innerSize)
	Size = self._srvItem:getInnerContainerSize()

	-- add cells in scrollView of item
	local index = 1
	local x = 1
	local y = 1
	for i = row, 1, -1 do
		for j = 1, col do
			if itemCount <= 0 then 
				break
			end

			-- cell
			local item = ccui.loadWidget(itemPath)
			-- img
			item:getChild("Image_item"):loadTexture(sObjectInfoMgr:GetItemIconPath(self._tbItemID[index]))
			-- count
			local count = sObjectInfoMgr:GetItemCount(self._tbItemID[index])
			-- 这里的物品存放的最大值应该是由服务器提供的，但现在暂未实现，暂时写测试数据
			local maxCount = 30
			if count ~= nil and count > 0 and maxCount > 30 then 
				item:getChild("Label_itemCount"):setString(tostring(count) .. "/" .. tostring(maxCount))
			else
				-- assert(false, "server error! where: BagLayer:reload(), error count or max count")
				item:getChild("Label_itemCount"):setString(tostring(index) .. "/30")
			end
			-- tag
			item:setTag(index)
			-- callback
			item:setTouchEnabled(true)
			item:addTouchEvent({[ccui.TouchEventType.ended] = handler(self, self.ItemCallback)})
			-- pos
			x = (j - 1) * item:getContentSize().width + wSpace * j
			y = Size.height - item:getContentSize().height * (row - i + 1)
			item:setPosition(cc.p(x, y))
			-- parent
			self._srvItem:addChild(item)

			itemCount = itemCount - 1
			index = index + 1
		end
	end

	self._srvItem:setBounceEnabled(true)
	self._srvItem:setClippingEnabled(true)
end

function BagLayer:UpdateDetail( desc )
	local pTextRich = CTextRich:create();
	pTextRich:setMaxLineLength(20);
	pTextRich:setVerticalSpacing(5);

	pTextRich:insertElement(desc, "", 24, cc.c3b(255, 248, 199))
	pTextRich:reloadData()
	pTextRich:setPosition(cc.p(self._srvDetail:getContentSize().width/2, self._srvDetail:getContentSize().height/2))
	self._srvDetail:addChild(pTextRich, 0, 162018)	-- 162018: 代表pTR，在字母表中的顺序ID，p是第16个
end

function BagLayer:ItemCallback( widget )
	if widget ~= nil then 
		-- 先将前面的已选择的cell的状态，改为未选择的状态（实际就是将发光的边框设为不可视）
		local sltItem = self._srvItem:getChildByTag(self._selectedCellID)
		if sltItem ~= nil then 
			sltItem:getChild("Image_slctFrm"):setVisible(false)
		end
		-- 然后将最新选择的cell的状态，改为已选择状态
		widget:getChild("Image_slctFrm"):setVisible(true)
		self._selectedCellID = widget:getTag()

		local itemID = self._tbItemID[self._selectedCellID]
		if itemID ~= nil then 
			-- Detail
			local desc = GetEquipDesc(itemID, self._languageId)
			if desc ~= nil and self._srvDetail ~= nil then 
				local pTextRich = self._srvDetail:getChildByTag(162018)-- 162018: 代表pTR，在字母表中的顺序ID，p是第16个
				if pTextRich ~= nil then 
					self._srvDetail:removeChild(pTextRich, true)
				end
				self:UpdateDetail(desc)
			end
			-- count
			self._labelCount:setString(widget:getChild("Label_itemCount"):getString())
		end
	end
end

return BagLayer