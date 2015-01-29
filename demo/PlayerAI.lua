local PlayerAI = class("PlayerAI")
PlayerAI.__index = PlayerAI

function PlayerAI:ctor( object )
	self._unit = object
	self._bPause = false

	self._castIdx = 1
end

function PlayerAI:Reset( )
	self._bPause = false

	self._castIdx = 1
end

function PlayerAI:Update( dt )
	--cclog("player ai update...")
	if self._bPause then
		return
	end

	if self._unit:IsAlive() == false then
		return
	end

	if self._unit:hasUnitState(UnitStat.UNIT_STAT_STUNNED) then
		return
	end

	if self._unit:HasSpellCasted() then
		--self._unit:Stop()
		return
	end

	local target = self._unit:GetHostileTarget()
	if not target then return end

	local spellSeq = self._unit:GetSpellSeq()
	local spellId = 0
	if self._castIdx > #spellSeq then
		self._castIdx = 1
	end

	spellId = spellSeq[self._castIdx]

	local spellInfo = GetSpellEntry(spellId)
	if spellInfo.targetMask == SpellTargets.TARGET_SELF then
		target = self._unit
	end

	if target:IsAlive() == false then
		--cclog("target is dead")
		return
	end

	if self._unit:IsInAttackRange(target) then --目标在攻击范围内
		--cclog("playerai,target in attack range,posx:"..self._unit:GetPositionX())
		if self._unit:IsMoving() then 
			--cclog("playerai,target in attack range,posx:"..self._unit:GetPositionX())
			self._unit:Stop() 			--停止移动
			return
		end
	else
		--cclog("playerai,target out of attack range")
		if self._unit:IsMoving() == false then
			--cclog("playerai,let player move to target")
			self._unit:MoveTo( cc.p(target:GetPositionX(),self._unit:GetPositionY()),self._unit:GetStat(uf.move_speed) )
		end
		return
	end

	local t = self._unit:GetAttackTimer(self._unit:GetAttackType())

	if self._unit:GetAttackTimer(self._unit:GetAttackType()) == 0 then
		--cclog("playerai,player can attack target")

		if not self:CanCast(target,spellId) then return end

		self._unit:Stop()
		self._unit:Attack(target,spellId)

		self._castIdx = self._castIdx + 1
	end
end

function PlayerAI:CanCast( target,spellId )
	if not target then return false end
	local entry = GetSpellEntry(spellId)
	if not entry then return false end

	--被沉默的情况下，只能放物理技能，不能放魔法技能
	if self._unit:hasUnitState(UnitStat.UNIT_STAT_SILENCED) and entry.DmgClass == SpellDmgClass.CLASS_MAGIC then
		return false
	end

	if self._unit:HasSpellCasted() then return false end

	--check spell range

	local ani = self._unit._armature:getAnimation()
	


	return true
	
end

function PlayerAI:MoveInLineOfSight( pWho )
	if self._unit:IsHostileTo(pWho) then
		pWho:SetInCombatWith(self._unit);
		self._unit:AddThreat(pWho);
	end
end

return PlayerAI