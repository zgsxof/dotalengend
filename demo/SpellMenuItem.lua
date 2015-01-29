
local BaseObject = require("demo.BaseObject")
local SpellMenuItem = class("SpellMenuItem",BaseObject)

SpellMenuItem.__index = SpellMenuItem

function SpellMenuItem:ctor( player )
	--self:scheduleUpdateWithPriorityLua(handler(self,self.update),0)
	
	self._player = player--sObjectAccessor:GetPlayer(class)

	assert(self._player)

	self._spellId = self._player:GetSpell( SpellAttributes.ultimate )
	assert(self._spellId,"没大招技能")

	local path = "skill.png"--GetSpellIconPath(self.spellId)

	self.m_button = ccui.button({
        normal  = path,
        pressed = path,
        listener = {[ccui.TouchEventType.ended] = handler(self,self.Cast)}
        })
	self:addChild(self.m_button)
end

function SpellMenuItem:Init()
	-- body
end

function SpellMenuItem:Ready()
	--特效分start和loop两个阶段
	if true then
	--	return
	end
	local effectPath = "eff_impact_arya_skill2"
	local readyEffect = require("demo.SpellDisplay").new(effectPath)
	self:addChild(readyEffect,0,10000)


end

function SpellMenuItem:Cast()
	--特效只有start阶段
	if true then 
	--	return 
	end

	local canCast = self._player:CanCastUtl() 
	if not canCast then return end
	
	local target = self._player:GetHostileTarget()
	local spellInfo = GetSpellEntry(self._spellId)
	if band(spellInfo.targetMask,SpellTargets.TARGET_SELF) ~= 0 then
		target = self._player
	end
	self._player:CastSpell(target,self._spellId)

	local readyEffect = self:getChildByTag(10000)
	if readyEffect then
		readyEffect:removeFromParent()
	end

	self:removeChildByTag(10001)
	local effectPath = "eff_impact_zancrow_skill1"
	local castEffect = require("demo.SpellDisplay").new(effectPath)
	self:addChild(castEffect,0,10001)

end

function SpellMenuItem:Normal()
	local readyEffect = self:getChildByTag(10000)
	if readyEffect then
		readyEffect:removeFromParent()
	end
end

function SpellMenuItem:Update(dt)
	local canCast = self._player:CanCastUtl() 
	if canCast then
		--cclog("can cast spell..........")
		if not self:getChildByTag(10000) then
			self:Ready()
		end
	else
		self:Normal()
	end
end



return SpellMenuItem