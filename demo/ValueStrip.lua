local ValueStrip = class("ValueStrip",function ()
	return cc.Node:create()
end)
ValueStrip.__index = ValueStrip

StripEvent = 
{
	VALUE_ADD,
	VALUE_SUB,
}

function ValueStrip:ctor( background,foreground )
	self._curPer = 100

	self._bar = cc.ProgressTimer:create( cc.Sprite:create(foreground) )
	self._bar:setType(1)
	self._bar:setMidpoint(cc.p(1,0))
	self._bar:setBarChangeRate(cc.p(1, 0))
	self._bar:setPercentage(100)

	self._bg = cc.Sprite:create(background)
	--self._bg:addChild(self._bar)

	self:addChild(self._bg)
	self:addChild(self._bar)
end

function ValueStrip:changeValue( event,per )
	local from = self._bar:getPercentage()
	local to = per

	if self._curPer ~= to then
		self._bar:stopAllActions()
		self:setVisible(true)
		local act = cc.ProgressFromTo:create(0.2,from,to)
		self._bar:runAction(act)

		if per == 0 then
			self:setVisible(false)
		end
	end
	self._curPer = per
	--[[
	if event == StripEvent.VALUE_ADD then

	elseif event == StripEvent.VALUE_SUB then

	end

	local func =
	{
		[StripEvent.VALUE_ADD] = function () end,
		[StripEvent.VALUE_SUB] = function () end,
	}]]
end

function ValueStrip:Update( dt )
	-- body
end

return ValueStrip