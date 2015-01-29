local CreatureAI = class("CreatureAI")
CreatureAI.__index = CreatureAI

function CreatureAI:ctor( object )
	self._unit = object
	self._bPause = false

	self._castIdx = 1
end

function CreatureAI:Reset( )
	self._bPause = false

	self._castIdx = 1
end


function CreatureAI:Update( dt )
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
	if band(spellInfo.targetMask,SpellTargets.TARGET_SELF) ~= 0 then
		target = self._unit
	end

	if target:IsAlive() == false then
		--cclog("target is dead")
		return
	end

	if self._unit:IsInAttackRange(target) then --目标在攻击范围内
		--cclog("creatureai,target in attack range,posx:"..self._unit:GetPositionX())
		if self._unit:IsMoving() then 
			--cclog("creatureai,target in attack range,posx:"..self._unit:GetPositionX())
			self._unit:Stop() 			--停止移动
			return
		end
	else
		--cclog("creatureai, target not in atk range")
		if self._unit:IsMoving() == false then
			self._unit:MoveTo( cc.p(target:GetPositionX(),self._unit:GetPositionY()),self._unit:GetStat(uf.move_speed) )
		end

		return
	end

	if self._unit:GetAttackTimer(self._unit:GetAttackType()) == 0 then
		if not self:CanCast(target,spellId) then return end

		self._unit:Stop()
		self._unit:Attack(target,spellId)

		self._castIdx = self._castIdx + 1
	end
end

function CreatureAI:CanCast( target,spellId )
	if not target then return false end
	local entry = GetSpellEntry(spellId)
	if not entry then return false end

	if self._unit:hasUnitState(UnitStat.UNIT_STAT_SILENCED) then
		return false
	end

	if self._unit:HasSpellCasted() then return false end

	--check spell range
	
	return true
	
end

function CreatureAI:MoveInLineOfSight( pWho )
	if self._unit:IsHostileTo(pWho) then
		pWho:SetInCombatWith(self._unit);
		self._unit:AddThreat(pWho);
	end
end

return CreatureAI