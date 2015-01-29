local SpellNotifierObject = class("SpellNotifierObject")
SpellNotifierObject.__index = SpellNotifierObject



function SpellNotifierObject:ctor(spell, radius, type, targetType)
	self._casterObj = spell._caster
	self._pushType = type
	self._targetType = targetType
	self._radius = radius
	if type == SpellNotifyPushType.PUSH_DEST_CENTER then
		--因为是自动战斗，所以不能为区域技能手动选择一个施放点
		--这里处理成centerX = casterX + attackrange
		local caster = spell._caster
		if caster:isFlip() then
			self._centerX = caster:getPositionX() - caster:GetStat(uf.attackrange)
			self._centerY = caster:getPositionY()
		else
			self._centerX = caster:getPositionX() + caster:GetStat(uf.attackrange)
			self._centerY = caster:getPositionY()
		end
	elseif type == SpellNotifyPushType.PUSH_TARGET_CENTER then
		self._centerX = 0
		self._centerY = 0
	else
		self._centerX = spell._caster:getPositionX()
		self._centerY = spell._caster:getPositionY()
	end

	self._list = {}
end

function SpellNotifierObject:ForEachObject( obj )
	if self._targetType == TargetType.Hostile then
		if not self._casterObj:IsHostileTo(obj) then
			return
		end
	elseif self._targetType == TargetType.Friend then
		if not self._casterObj:IsFriendlyTo(obj) then
			return
		end
	elseif self._targetType == TargetType.All then

	end

	if not self._list then self._list = {} end

	if self._pushType == SpellNotifyPushType.PUSH_SELF_CENTER then

		if self._casterObj:IsWithinDistInMap(obj, self._radius) then
			self._list[#self._list + 1] = obj
		end

	elseif self._pushType == SpellNotifyPushType.PUSH_IN_FRONT_RECT then

		if self._casterObj:IsWithinRectRange(obj, self._radius) then
			self._list[#self._list + 1] = obj
		end

	elseif self._pushType == SpellNotifyPushType.PUSH_DEST_CENTER then

		if obj:IsWithinDist2d(cc.p(self._centerX,self._centerY), self._radius) then
			self._list[#self._list + 1] = obj
		end

	end
end

function SpellNotifierObject:GetTargets(  )
	return self._list
end

return SpellNotifierObject