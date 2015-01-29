local SpellMenuLayer = class("SpellMenuLayer", function() 
	return cc.LayerColor:create()
end)
SpellMenuLayer.__index = SpellMenuLayer

function SpellMenuLayer:ctor()
	local size = cc.size(800,150)
	
	self:setContentSize(size)

	self:setOpacity(255*0.4)

	self:Init()
end

function SpellMenuLayer:AlignItemsHorizontallyWithPadding(offset)
	local children = self:getChildren()
	local count = self:getChildrenCount()
	if count == 0 then return end
	
	if count % 2 == 0 then
		local centerL = count/2 
		local centerLChild = self:getChildByTag(centerL)
		centerLChild:setPosition(cc.p(self:getContentSize().width/2 - centerLChild:getContentSize().width/2 * centerLChild:getScaleX() + offset/2,self:getContentSize().height/2))
		local centerR = count/2 + 1
		local centerRChild = self:getChildByTag(centerR)
		centerRChild:setPosition(cc.p(self:getContentSize().width/2 + centerRChild:getContentSize().width/2 * centerRChild:getScaleX() - offset/2,self:getContentSize().height/2))

		if count < 4 then return end

		for i = 1,centerL-1 do 
			local leftChild = self:getChildByTag(i)
			leftChild:setPosition(cc.p(centerLChild:getPosition().x - centerLChild:getContentSize().width * (centerL - i) * centerLChild:getScaleX() + offset*(centerL - i), centerLChild:getPosition().y))
		end
		for i = centerR+1,count do
			local rightChild = self:getChildByTag(i)
			rightChild:setPosition(cc.p(centerRChild:getPosition().x + centerRChild:getContentSize().width * (i-centerR) * centerRChild:getScaleX() - offset * (i-centerR), centerRChild:getPosition().y))
		end
	else
		local center = math.modf(count/2) + 1
		local centerChild = self:getChildByTag(center)
		centerChild:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
		for i = 1,center-1 do 
			local leftChild = self:getChildByTag(i)
			leftChild:setPosition(cc.p(centerChild:getPosition().x - centerChild:getContentSize().width * (center - i) * centerChild:getScaleX() + offset * (center - i), centerChild:getPosition().y))
		end
		for i = center+1,count do
			local rightChild = self:getChildByTag(i)
			rightChild:setPosition(cc.p(centerChild:getPosition().x + centerChild:getContentSize().width * (i-center) * centerChild:getScaleX() - offset* (i-center), centerChild:getPosition().y))
		end
	end
end

function SpellMenuLayer:Init( )
	local players = sObjectAccessor:GetPlayers()
	local i = 1
	for _,player in pairs(players) do
		local spellMenu = require("demo.SpellMenuItem").new(player)
		self:addChild(spellMenu,0,i)
		i = i + 1
	end

	self:AlignItemsHorizontallyWithPadding(120)
end

function SpellMenuLayer:pause( )
	
end

function SpellMenuLayer:Update( dt )
	for i = 1,self._spellLayer:getChildrenCount() do
		local child = self._spellLayer:getChildren()[i]
		if child then
			child:Update(dt)
		end
	end
end

return SpellMenuLayer