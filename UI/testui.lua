local testlayer = class("testlayer",
	function()
		local layer = cc.CSLoader:createNode("uitest/Login.csb")--ccui.loadLayer("otherui/bag.json")
		cclog("layer w:"..layer:getSize().width)
		layer:setSize(cc.size(config.width,config.height))
		ccui.Helper:doLayout(layer)
		return layer
	end
)
--[[
function testlayer:ctor( ... )
	local path = ""
	if winSize.width <= 640 then
		path = "ipad_img_02.jpg"
	else
		path = "ipad_img_01.jpg"
	end
	local backImg = ccui.image({image = path})
	backImg:pos( winSize.width/2,winSize.height/2 )
	self:addChild(backImg)

	local layer = ccui.loadLayer("otherui/main_btn.json")
	self:addChild(layer,10000)
	local layer2 = ccui.loadLayer("otherui/main-main.json")
	self:addChild(layer2)

	local btn = layer2:getChild("Panel_15_3")
	cclog("btn pos:%f,%f",btn:getPositionX(),btn:getPositionY())
end]]
local itemCount = 40
local col = 5

function testlayer:ctor( ... )
	--self._scrollview = self:getChild("scv_equipList")

	--self:makeitem()

end

function testlayer:makeitem( )
	cclog("scv_equipList type:"..tolua.type(self._scrollview))
	self._scrollview:removeAllChildren()

	--add custom item
	local Size = self._scrollview:getContentSize()
	local row = 0
	if itemCount % col == 0 then
		row = itemCount/col
	else
		row = itemCount/col + 1
	end

	local item = ccui.loadWidget("otherui/bag-item.json")
	local height = row * item:getContentSize().height
	local innerSize = cc.size(Size.width,height)
	self._scrollview:setInnerContainerSize(innerSize)
	Size = self._scrollview:getInnerContainerSize()

	for i = row,1,-1 do
		for j = 1,col do
			local item = ccui.loadWidget("otherui/bag-item.json")
			local x = (j - 1) * item:getContentSize().width
			local y = Size.height - item:getContentSize().height * (row - i + 1)
			item:setPosition(cc.p(x,y))
			cclog("item pos,x:%f,y:%f",x,y)
			self._scrollview:addChild(item)
		end
	end

	self._scrollview:setBounceEnabled(true)
end

return testlayer