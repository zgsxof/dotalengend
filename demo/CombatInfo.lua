local CombatInfo = class("CombatInfo", function()
    return ccui.label({text = "",fontSize = 24})
end)

function CombatInfo:ctor(victim,value,type,bCrit)
	assert(victim and value)
	assert(value ~= 0)
	self:setString(tostring(value))
	if bCrit then
		self:setFontSize(28)
	end

	if type == DamageEffectType.HEAL then
		self:setColor(cc.c3b(0,255,0))
	elseif type == DamageEffectType.INFO then
		self:setColor(cc.c3b(64,122,255))
	else
		self:setColor(cc.c3b(255,0,0))
	end

	--[[
	local pos = cc.p(victim:getPosition().x, victim:getPosition().y + victim:getContentSize().height/2)
	self:setPosition(pos)

	local offset = cc.MoveTo:create(1,cc.pAdd(self:getPosition(),cc.p(0,300)));
	local fadeout = cc.FadeOut:create(1);
	local scale = cc.ScaleTo:create(0.2,1.0);
	local easeOut = cc.EaseExponentialIn:create(scale);
	local sp = cc.Spawn:create(offset,cc.Sequence:create(easeOut,fadeout));
	sp:setTag(1);
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),sp))]]
end

return CombatInfo