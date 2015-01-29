local Spell = class("Spell")

Spell.__index = Spell

AreaFlag = 
{
	AREA_INSTANCEAREA = 0,
	AREA_IMPACTAREA	  = 1,
	AREA_PERSISTENTAREA =2,
};

SpellState = 
{
	SPELL_STATE_START	  = 1,
	SPELL_STATE_PREPARE	  = 2,
	SPELL_STATE_CASTING   = 3,
	SPELL_STATE_DELAY 	  = 4,
	SPELL_STATE_PERIODIC  = 5,
	SPELL_STATE_BACKSWING = 6,
	SPELL_STATE_FINISHED  = 7,
}

SpellPhase = 
{
	--PHASE_PREPARE = 0,
	PHASE_CAST = 0,
	PHASE_IMPACT = 1,
	PHASE_STATE = 2,
	PHASE_AREA = 3,
	PHASE_MISSILE = 4,
}

SpellEffects = 
{
	NONE 			= 0,
	DAMAGE 			= 1,			--伤害
	HEAL 			= 2,			--治疗
	APPLY_AURA 		= 3,			--光环
	INTERRUPT_CAST 	= 4,			--打断
	LEAP			= 5,			--闪现
	SUMMON			= 6,			--召唤
	KNOCKBACK		= 7,			--击退
	RESURRECT		= 8,			--复活
	LEAP_BACK		= 9,			--闪现到背后
	Leech           = 10,			--吸血
	StealEnergy     = 11,			--偷取能量
	ChangePos 		= 12,			--交换位置
}

EffectTarget = 
{
	TARGET_SELF = 1,
	TARGET_SINGLE_FRIEND = 2,
	TARGET_SINGLE_ENEMY = 3,
	TARGET_ALL_FRIEND = 4,
	TARGET_ALL_ENEMY = 5,
	TARGET_ALL_ENEMY_IN_RECT_AREA = 6,		--矩形区域内的敌人
	TARGET_ALL_ENEMY_IN_RADIUS_AREA = 7,		--圆形区域内的敌人
	TARGET_ALL_ENEMY_IN_RADIUS_AREA_POINT = 8, --目标点圆形区域内的敌人
}

MAX_EFFECT_INDEX = 3

function Spell:ctor( caster,target,spellId )
	self._caster = caster
	self._targets = {}
	self._tmpTarget = target
	self._spellinfo = GetSpellEntry(spellId)
	assert(self._spellinfo,string.format("SpellEntry(%d) is null",spellId))
	self._SpellState = SpellState.SPELL_STATE_START

	self._SpellDisplay = nil


	self._ElapsedTime = 0
	self._PeriodTime = 0
	self._backswingTime = 1.5 --技能后摇时间

	self._healing = 0

end

function Spell:GetSpellInfo()
	return self._spellinfo
end

function Spell:Start()
	if  self._caster:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER and  HasSpellAttribute( self._spellinfo,SpellAttributes.ultimate ) then
		self._caster:addUnitState(UnitStat.UTL_PREPARE)

		--如果释放大招，让所有人静止
		sBattleMap:SetPause()

		sBattleMap:GetLayer():setOpacity(255*0.6)

		self._maskTime = 0

		--放大招的人继续动
		local players = sObjectAccessor:GetPlayers()
		for _,v in pairs(players) do
			if v:hasUnitState(UnitStat.UTL_PREPARE) then
				v:Resume()
				v:DoResume()
			end
		end
	end

	self:_handle_prepare()
end

function Spell:GetSpellCastTime( ) --技能吟唱时间
	local speedpct = self._caster:GetModifierValue(UnitMods.UNIT_MOD_ATTACK_SPEED,UnitModifierType.BASE_PCT)
	return self._spellinfo.castTime/1000 / speedpct
end

function Spell:Prepare()

	if self._ElapsedTime > self._spellinfo.castTime/1000 then
		--前摇做完，取消掉大招状态，恢复速度
		self._caster:clearUnitState(UnitStat.UTL_PREPARE)

		sBattleMap:Resume()

		self._ElapsedTime = self._ElapsedTime - self._spellinfo.castTime/1000

		self:Cast()
	end
end

function Spell:Cast()
	self:FillTarget()

	if self:IsMissilePointSpell() == false and #self._targets == 0 then
		self:Cancel()
		return
	end

	if self._spellinfo.speed > 0 then
		--飞行技能或延迟技能
		self:Missile()
	else
		self:Handle_Immediate() --logic

		--播放出手特效和区域特效
		self:_on_casting()

		--这里并没有播放光环特效，光环特效由spellauraholder负责播放。。。

		--技能施放后，给每个技能一个后摇状态，防止施法者施放技能后立即移动
		self._SpellState = SpellState.SPELL_STATE_BACKSWING
	end

	--如果是一个入场技能，取消其后摇时间
	if HasSpellAttribute(self._spellinfo,SpellAttributes.use_enter_battle) then
		self._backswingTime = 0 
	end
end

function Spell:Delaying()
	if self._ElapsedTime > self._delayTime then
		self:_finish_areaVisual()
		self:Handle_Delay()
		self:Finish()
	end
end

function Spell:Cancel( )
	self._SpellState = SpellState.SPELL_STATE_FINISHED

	if self._caster:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER then
		sBattleMap:GetLayer():setOpacity(0)
	end
end

function Spell:Finish()
	----clog("spell finish")
	self._SpellState = SpellState.SPELL_STATE_FINISHED
end

function Spell:CheckCast( )
	
end

function Spell:CheckRange()
	
end

function Spell:_handle_prepare()
	--开始播放技能动作。。
	local spellaction = self._spellinfo.action
	if spellaction ~= "" then
		self._caster:Play(spellaction)
	end

	self._SpellState = SpellState.SPELL_STATE_PREPARE

	if self._spellinfo.id == 5002 then
		local a
	end
end

function Spell:IsAreaSpell( )
	for i = 0,MAX_EFFECT_INDEX-1 do
		if self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RECT_AREA 
			or self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RADIUS_AREA
			or self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RADIUS_AREA_POINT then
			return true
		end
	end

	return false
end

function Spell:IsMissilePointSpell()
	for i = 0,MAX_EFFECT_INDEX-1 do
		if self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RADIUS_AREA_POINT then
			return true
		end
	end

	return false
end

function Spell:_on_casting()
	self:PlayPhase(SpellPhase.PHASE_CAST)

	--区域特效分为即时性特效和延时性特效
	--延时性特效：类似LOL中的爆破鬼才的大招，丢一个炮弹到某个区域上，炮弹落地后才播放特效
	--即时性特效：吟唱时间完后，立即播放的区域特效（比如刀塔传奇中，冰女的大招）
	self:PlayPhase(SpellPhase.PHASE_AREA)
end

function Spell:CastEffect()
	local spelleffectEntry = GetSpellEffectEntry(self._spellinfo.visual)
	if not spelleffectEntry then return end

	local effectPath = spelleffectEntry.VisualEffects[SpellPhase.PHASE_CAST]
	if effectPath == "" then return end
	local spellDisplay = require("demo.SpellDisplay").new(effectPath)

	self._caster:addChild(spellDisplay)
	if self._caster:isFlip() then
		spellDisplay:setFlip(true)
		--spellDisplay._armature:setScaleX( spellDisplay._armature:getScaleX() * -1 )
	end
end

function Spell:ImpactEffect( )
	local spelleffectEntry = GetSpellEffectEntry(self._spellinfo.visual)
	if not spelleffectEntry then return end

	local effectPath = spelleffectEntry.VisualEffects[SpellPhase.PHASE_IMPACT]
	if effectPath == "" then return end

	for i = 1,#self._targets do
		local flag = spelleffectEntry.m_flags[phase]
		local targetinfo = self._targets[i]
		local target = targetinfo.target
		local impactEffect = require("demo.SpellDisplay").new(effectPath,SpellPhase.PHASE_IMPACT)
		if target:isFlip() then
			impactEffect:setFlip(true)
			--impactEffect._armature:setScaleX( impactEffect._armature:getScaleX() * -1 )
		end
		if flag == -1 then
			target:addChild(impactEffect,-1)
		else
			target:addChild(impactEffect,1)
		end
	end
end

function Spell:AreaEffect( dest )
	local spelleffectEntry = GetSpellEffectEntry(self._spellinfo.visual)
	if not spelleffectEntry then return end
	local effectPath = spelleffectEntry.VisualEffects[SpellPhase.PHASE_AREA]
	if effectPath == "" then return end

	local pos = cc.p(0,0)
	if dest then --对地
		pos = dest
	else
		if #self._targets == 1 then --只有一个目标
			local targetinfo = self._targets[1]
			target = targetinfo.target

			pos = cc.p(target:getPositionX(),winSize.height/2)
		elseif #self._targets > 1 then
			--[[ 多个目标，把特效加到多个目标的中心点]]
			local function sortByPos(t1,t2)
				return t1.target:getPositionX() < t2.target:getPositionX()
			end
			table.sort(self._targets,sortByPos)
			local midPosX =  (self._targets[1].target:getPositionX() + self._targets[#self._targets].target:getPositionX())/2
			if midPosX == 0 then
				midPosX = self._targets[1].target:getPositionX()
			end
			cclog("多目标的区域特效PosX:"..midPosX)
			pos = cc.p(midPosX,winSize.height/2)
		end
	end

	local spellDisplay = require("demo.SpellDisplay").new(effectPath)
	sBattleMap:GetLayer():addChild(spellDisplay)
	spellDisplay:pos(pos)

	if self._caster:isFlip() then
		spellDisplay:setFlip(true)
	end
end

function Spell:MissileEffect(  )
	local target,time
	if self:IsMissilePointSpell() then --对某个点释放的飞行技能
		local srcPos = self._caster:GetPosition()
		if self._caster:isFlip() == false then
			target = cc.p(srcPos.x + self._caster:GetStat(uf.attackrange),srcPos.y)
		else
			target = cc.p(srcPos.x - self._caster:GetStat(uf.attackrange),srcPos.y)
		end

		time = self._MyDelayTime[1]
	else
		local targetinfo = self._targets[1]
		target = targetinfo.target

		time = self._MyDelayTime[1]
	end

	local missileEffect = require("demo.MissileEffect").new(self,self._caster,target,time)
	missileEffect:retain()
	sBattleMap:GetLayer():addChild(missileEffect,10000)
end

function Spell:PlayPhase( phase )

	local funcTable = 
	{
		[SpellPhase.PHASE_CAST] = function() self:CastEffect() end,
		[SpellPhase.PHASE_MISSILE] = function () self:MissileEffect() end,
		[SpellPhase.PHASE_IMPACT] = function () self:ImpactEffect() end,
		[SpellPhase.PHASE_AREA] = function () self:AreaEffect() end,
	
	}
	
	funcTable[phase]()
end

function Spell:FinishAuraVisualEffect()
	self:_finish_areaVisual()
	self:_finish_stateVisual()
end

function Spell:tick()
	if self._ElapsedTime > self._spellinfo.duration/1000 then
		self:_finish_areaVisual()
		self:_finish_stateVisual()
		self:Finish()
	end
end

function Spell:_on_buff()
	self._PeriodTime = self._PeriodTime - self._spellinfo.castTime/1000

	self:PlayPhase(SpellPhase.PHASE_STATE)
end

function Spell:GetDistance()
	local targetinfo = self._targets[1]
	local target = targetinfo.target
	assert(target,"target nil")
	return self._caster:GetDistance(target)
end

function Spell:Missile()
	self._SpellState = SpellState.SPELL_STATE_DELAY

	--self._delayTime = self:GetDistance()/self._spellinfo.speed

	if not self._MyDelayTime then self._MyDelayTime = {} end
	if not self._ElapsedDelayTime then self._ElapsedDelayTime = 0 end

	for i = 1,#self._targets do
		local targetInfo = self._targets[i]
		local target = targetInfo.target
		self._MyDelayTime[i] = self._caster:GetDistance(target)/self._spellinfo.speed

	end

	if self:IsMissilePointSpell() then
		local targetPos = cc.p(0,0)
		if self._caster:isFlip() == false then
			targetPos = cc.p(self._caster:getPositionX() + self._caster:GetStat(uf.attackrange),self._caster:getPositionY())
		else
			targetPos = cc.p(self._caster:getPositionX() - self._caster:GetStat(uf.attackrange),self._caster:getPositionY())
		end
		self._MyDelayTime = {}
		self._MyDelayTime[1] = self._caster:GetDistancePoint(targetPos)/self._spellinfo.speed
	end

	--self:PlayPhase(SpellPhase.PHASE_MISSILE)
	self:MissileEffect()
end

function Spell:_handle_impact()
	self._SpellDisplay:Impact()
end

function Spell:_handle_channel()

end

function Spell:_finish_stateVisual()
	for k,stateEffect in pairs(self._stateVisual) do
		stateEffect:End()
	end
end

function Spell:_finish_areaVisual()
	if self.areaVisual then
		self.areaVisual:End()
	end
end

function Spell:PlayMissile( )
	self._SpellDisplay:PlayMissile()
end

function Spell:Handle_Immediate()
	----clog(" spell immediate...... ")
	if self._caster:IsDead() then return end
	
	for k,v in pairs(self._targets) do
		self:DoAllEffectOnTarget(v)
	end
end

function Spell:IsSpellAppliesAura()
	for i = 0,MAX_EFFECT_INDEX-1 do
		if self._spellinfo.Effects[i] == SpellEffects.APPLY_AURA then
			return true
		end
	end

	return false
end

function Spell:DoAllEffectOnTarget(targetInfo)
	local target = targetInfo.target
	local missCondition = targetInfo.missCondition

	if missCondition == SpellMissInfo.SPELL_MISS_NONE then
		self:DoSpellHitOnUnit(target)
	elseif missCondition == SpellMissInfo.SPELL_MISS_MISS then
		target:AddCombatInfo("未命中!",DamageEffectType.INFO)
	elseif missCondition == SpellMissInfo.SPELL_MISS_DODGE then
		target:AddCombatInfo("闪避!",DamageEffectType.INFO)
	elseif missCondition == SpellMissInfo.SPELL_MISS_IMMUNE then
		target:AddCombatInfo("免疫!",DamageEffectType.INFO)
	end

	if self._healing and self._healing ~= 0 then
		local bCrit
		if target:IsSpellCrit(self._spellinfo) then
			self._healing = self._healing * 2 
			bCrit = true
		end
		self._caster:DealHeal( target,self._healing,bCrit )
	elseif self._damage and self._damage ~= 0 then
		--sendspelldmglog
		if target:IsSpellCrit(self._spellinfo) then
			self._damage = self._damage * 2 
		end
		--target:AddCombatInfo(self._damage,0)
		self._caster:DealDamage(target, self._damage,DamageEffectType.SPELL_DIRECT_DAMAGE)
	else
		--assert(false)
	end

	if self._spellinfo.id == 23 then
		local a
	end

	self:PlayPhase(SpellPhase.PHASE_IMPACT)
end

function Spell:DoSpellHitOnUnit(unit )

	if self:IsSpellAppliesAura() then
		self._spellAuraHolder = require( "demo.SpellAuraHolder" ).new(self._spellinfo, unit, self._caster)
	else
		self._spellAuraHolder = nil
	end

	for i = 0,MAX_EFFECT_INDEX-1 do
		self:HandleEffects(unit,i)
	end

	if self._spellAuraHolder and self._spellAuraHolder:IsEmptyHolder() == false then
		unit:AddSpellAuraHolder(self._spellAuraHolder)
	end
end

function Spell:HandleEffects( target,effidx )
	--clog(" spell handle effects...... ")
	self._unitTarget = target

	
	local eff = self._spellinfo.Effects[effidx];

	local SpellEffectsHandler = 
	{
		[SpellEffects.NONE] = function (index) self:SpellEffectNull(index) end,
		[SpellEffects.DAMAGE] = function (index) self:SpellEffectDamage(index) end,
		[SpellEffects.HEAL] = function (index) self:SpellEffectHeal(index) end,
		[SpellEffects.APPLY_AURA] = function (index) self:EffectApplyAura(index) end,
		[SpellEffects.INTERRUPT_CAST] = function (index) self:SpellEffectInterruptCast(index) end,
		[SpellEffects.LEAP] = function (index) self:SpellEffectLeap(index) end,
		[SpellEffects.SUMMON] = function (index) self:SpellEffectSummon(index) end,
		[SpellEffects.KNOCKBACK] = function (index) self:SpellEffectKnockBack(index) end,
		[SpellEffects.RESURRECT]   = function (index)	self:SpellEffectResurrect() end,			
		[SpellEffects.LEAP_BACK]   = function ( index ) self:SpellEffectLeapBack()	end,
		[SpellEffects.Leech] = function (index)	 self:SpellEffectHealthLeech()	end,
		[SpellEffects.StealEnergy] = function (index)	 self:SpellEffectStealEnergy()	end,
		[SpellEffects.ChangePos] = function (index)	 self:SpellEffectChangePos()	end,
	}

	SpellEffectsHandler[eff](effidx)
end

function Spell:CalculateDamage( )
	--clog(" spell calcu dmg...... ")
end

function Spell:_Handle_Immediate_Phase( ... )
	-- body
end

function Spell:_Handle_Finish_Phase( ... )
	-- body
end

function Spell:Handle_Delay( )
	for k,v in pairs(self._targets) do
		self:DoAllEffectOnTarget(v)
	end
end

function Spell:AddUnitTarget(pVictim,effidx )
	local bImmuned = pVictim:IsImmuneToSpellEffect(self._spellinfo, effidx);

	local targetInfo = {}
	targetInfo.target = pVictim
	if bImmuned then
		targetInfo.missCondition = SpellMissInfo.SPELL_MISS_IMMUNE
	else
		targetInfo.missCondition = self._caster:SpellHitResult(pVictim, self._spellinfo)
	end
	
	self._targets[#self._targets + 1 ] = targetInfo

end

function Spell:FillAreaTargets( effidx,radius,pushtype,targetType )
	local targetList = sObjectAccessor:ChooseSpellTarget( self, radius, pushtype, targetType )
	for i = 1, #targetList do
		self:AddUnitTarget(targetList[i],effidx)
	end
end

function Spell:FillTarget()
	for i = 0,MAX_EFFECT_INDEX-1 do
		if self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_SELF then --自身
			self:AddUnitTarget(self._caster)
		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_SINGLE_FRIEND then --单一友方
			--根据技能的选择规则来选择目标，比如血量最少的友方。。
		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_SINGLE_ENEMY then --单一敌方
			local target = self._caster:GetHostileTarget()

			if not target or target:IsDead() then
				self:Finish() 
				return
			end

			self:AddUnitTarget(target)
		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_FRIEND then --全体友方
			if self._caster:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER then
				for _,player in pairs(sObjectAccessor:GetPlayers()) do
					self:AddUnitTarget(player)
				end
			else
				for _,creature in pairs(sObjectAccessor:GetCreatures()) do
					self:AddUnitTarget(creature)
				end
			end

		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY then --全体敌方
			if self._caster:GetTypeFaction() == TypeFaction.TYPE_FACTION_CREATURE then
				for _,player in pairs(sObjectAccessor:GetPlayers()) do
					self:AddUnitTarget(player)
				end
			else
				for _,creature in pairs(sObjectAccessor:GetCreatures()) do
					self:AddUnitTarget(creature)
				end
			end
		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RECT_AREA then --矩形区域内的敌方
			
			local radius = self._spellinfo.EffectRadius[i] * (winSize.width / 48)
			self:FillAreaTargets(i,radius,SpellNotifyPushType.PUSH_IN_FRONT_RECT,TargetType.Hostile)

		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RADIUS_AREA then --圆形区域内的敌方
			local radius = self._spellinfo.EffectRadius[i]
			self:FillAreaTargets(i,radius,SpellNotifyPushType.PUSH_SELF_CENTER,TargetType.Hostile)

		elseif self._spellinfo.EffectImplicitTargetA[i] == EffectTarget.TARGET_ALL_ENEMY_IN_RADIUS_AREA_POINT then --圆形区域内的敌方
			local radius = self._spellinfo.EffectRadius[i]
			self:FillAreaTargets(i,radius,SpellNotifyPushType.PUSH_DEST_CENTER,TargetType.Hostile)
		end	
	end

	if #self._targets == 0 then 
		--clog("sadf")
	end
end

function Spell:GetState()
	return self._SpellState
end

function Spell:UpdateTarget( )
	-- body
end

function Spell:GetSpellDmgType( )
	return self._spellinfo.DmgClass
end

function Spell:SpellEffectNull(effct_idx)
	-- body
end

function Spell:SpellEffectDamage( effct_idx )
	--clog("spell effect: weapon damage")
	if not self._unitTarget then return end

	if self._unitTarget:IsDead() then return end

	local atkType = self._caster:GetAttackType()
	local extraDmg = self._spellinfo.ExtraDamage
	local tmpDmg = 0
	--[[
	if band(self._spellinfo.DmgClass,SpellDmgClass.SPELL_SCHOOL_MASK_PHYSICAL) == 0 then --非物理伤害
		tmpDmg = self._caster:CalculateDamage(AttackType.RANGE_ATTACK) + extraDmg
	else
		tmpDmg = self._caster:CalculateDamage(AttackType.BASE_ATTACK) + extraDmg
	end]]
	if self._spellinfo.DmgClass == SpellDmgClass.CLASS_MAGIC then --魔法伤害
		tmpDmg = self._caster:CalculateDamage(AttackType.RANGE_ATTACK) + extraDmg
	else --物理伤害
		tmpDmg = self._caster:CalculateDamage(AttackType.BASE_ATTACK) + extraDmg
	end

	local reduceDmg = self._unitTarget:CalculateReduceDamage(self._caster,self._spellinfo.DmgClass,tmpDmg)
	local finalDamage = tmpDmg - reduceDmg

	if finalDamage > 0 then
		self._damage = finalDamage
	else
		self._damage = 0
	end
end

function Spell:SpellEffectHeal(effidx)
	-- 治疗量应该根据什么公式来算，
	--治疗量=(基础伤害+额外治疗量)*治疗效果加成（暂时）
	cclog("-----治疗")
	local extra = self._spellinfo.ExtraDamage
	local heal = ( self._caster:CalculateDamage(AttackType.RANGE_ATTACK) + extra ) * (1 + self._caster:GetStat(uf.healEnhance_pct))
	self._healing = self._healing + heal
end

function Spell:SpellEffectHealthLeech(effidx) --吸血
	cclog("-----吸血")
	local stealCounts = self._spellinfo.ExtraDamage
	for i = 1,#self._targets do
		local targetinfo = self._targets[i]
		local target = targetinfo.target
		target:ModifyHealth(-stealCounts)
		self._caster:ModifyHealth(stealCounts)
	end
end

function Spell:SpellEffectStealEnergy(effidx)
	cclog("-----偷取能量")
	local stealCounts = self._spellinfo.ExtraDamage
	for i = 1,#self._targets do
		local targetinfo = self._targets[i]
		local target = targetinfo.target
		cclog("before steal energy")
		cclog("caster's energy:"..self._caster:GetStat(uf.energy))
		cclog("victim's energy:"..target:GetStat(uf.energy))
		cclog("--------------------------------------------")
		target:ModifyPower(-stealCounts)
		self._caster:ModifyPower(stealCounts)
		cclog("after steal energy")
		cclog("caster's energy:"..self._caster:GetStat(uf.energy))
		cclog("victim's energy:"..target:GetStat(uf.energy))
	end
end

function Spell:SpellEffectChangePos( effidx)
	assert(#self._targets == 1,"only can ChangePos with one target")
	local target = self._targets[1].target
	local casterPos = self._caster:getPosition()
	local targetPos = target:getPosition()
	self._caster:setPosition(targetPos)
	target:setPosition(casterPos)

end

function Spell:SpellEffectKnockBack( ) --击退
	--多少时间，击退多少距离
	--视觉上victim会飞起来再落下
	cclog("--------击退")
	local time = 0.3
	local dis = 100
	for i = 1,#self._targets do
		local targetinfo = self._targets[i]
		local target = targetinfo.target
		target:addUnitState(UnitStat.UNIT_STAT_STUNNED)
		local dest1,dest2
		if target:isFlip() then
			dest1 = cc.p(target:GetPositionX() + dis/2,target:GetPositionY()+25)
			dest2 = cc.p(target:GetPositionX() + dis,target:GetPositionY())
		else
			dest1 = cc.p(target:GetPositionX() - dis/2,target:GetPositionY()+25)
			dest2 = cc.p(target:GetPositionX() - dis,target:GetPositionY())
		end

		if dest1.x <= 0 then
			dest1.x = 0
		elseif dest1.x >= winSize.width then
			dest1.x = winSize.width
		end
		if dest1.y <= 0 then
			dest1.y = 0
		elseif dest1.y >= winSize.height then
			dest1.y = winSize.height
		end

		if dest2.x <= 0 then
			dest2.x = 0
		elseif dest2.x >= winSize.width then
			dest2.x = winSize.width
		end
		if dest2.y <= 0 then
			dest2.y = 0
		elseif dest2.y >= winSize.height then
			dest2.y = winSize.height
		end
		target:InterruptSpell(true)
		local move1 = cc.MoveTo:create(time/2,dest1)
		local move2 = cc.MoveTo:create(time/2,dest2)
		local seq1 = cc.Sequence:create(move1, move2,cc.CallFunc:create(function ()
			target:clearUnitState(UnitStat.UNIT_STAT_STUNNED)
		end))
		target:runAction(seq1)
	end
end

function Spell:EffectApplyAura( effidx )
	if not self._unitTarget then return end
	if self._unitTarget:IsDead() then return end
	
	local SpellAura = require("demo.SpellAura").new(self._spellinfo,effidx,self._spellAuraHolder,self._caster,self._unitTarget)
	self._spellAuraHolder:AddAura(SpellAura,effidx)
	
end

function Spell:SpellEffectInterruptCast( effidx )
	cclog("----打断技能")
	if not self._unitTarget then return end
	if self._unitTarget:IsDead() then return end

	local spell = self._unitTarget:GetCurrentSpell()
	if spell then
		self._unitTarget:InterruptSpell()
	end
end

function Spell:SpellEffectLeap( effidx )
	--闪现到敌人面前
	if not self._unitTarget then return end
	if self._unitTarget:IsDead() then return end

	local casterPos = self._caster:getPosition()
	local targetPos = self._unitTarget:getPosition()
	local destPos 
	if casterPos.x < targetPos.x then
		destPos = cc.p(targetPos.x - self._unitTarget:GetObjectSize().width/2 - self._caster:GetObjectSize().width/2, targetPos.y )
	else
		destPos = cc.p(targetPos.x + self._unitTarget:GetObjectSize().width/2 + self._caster:GetObjectSize().width/2, targetPos.y )
	end
	self._caster:setPosition(destPos)
end

function Spell:SpellEffectLeapBack( effidx )
	--闪现到敌人背后，
	if not self._unitTarget then return end
	if self._unitTarget:IsDead() then return end

	local casterPos = self._caster:getPosition()
	local targetPos = self._unitTarget:getPosition()
	local destPos 
	if casterPos.x < targetPos.x then
		destPos = cc.p(targetPos.x + self._caster:GetObjectSize().width/2, targetPos.y )
	else
		destPos = cc.p(targetPos.x - self._caster:GetObjectSize().width/2, targetPos.y )
	end
	self._caster:setPosition(destPos)

	local ang = self._caster:GetAngle(targetPos)
	self._caster:SetFaceTo(ang)
end

function Spell:SpellEffectResurrect( effidx )
	--复活
end

function Spell:HandleMyDelay(dt )
	if not self._ElapsedDelayTime then self._ElapsedDelayTime = 0 end
	self._ElapsedDelayTime = self._ElapsedDelayTime + dt

	if not self._MyDelayTime then self._MyDelayTime = {} end

	local removeList = {}
	for i = 1,#self._targets do
		local targetInfo = self._targets[i]
		local target = targetInfo.target
		if target:IsDirty() then
			self._MyDelayTime[i] = self._caster:GetDistance(target)/self._spellinfo.speed
			target:SetDirty(false)
		end

		if self._ElapsedDelayTime >= self._MyDelayTime[i] then
			self:DoAllEffectOnTarget(targetInfo)
			removeList[#removeList + 1] = i
		end
	end

	for i = 1,#removeList do
		table.remove( self._targets, i )
	end

	if table.nums(self._targets) == 0 then
		self:Finish()
	end
end

function Spell:Update( dt )
	if self._maskTime then
		self._maskTime = self._maskTime + dt
		if self._maskTime > 1 then
			sBattleMap:GetLayer():setOpacity(0)
			self._maskTime = nil
		end
	end

	self._ElapsedTime = self._ElapsedTime + dt
	self._PeriodTime = self._PeriodTime + dt
	if self._SpellState == SpellState.SPELL_STATE_START then
		self:Start()
	elseif self._SpellState == SpellState.SPELL_STATE_PREPARE then
		self:Prepare()
	elseif self._SpellState == SpellState.SPELL_STATE_CASTING then
		self:Cast()
	elseif self._SpellState == SpellState.SPELL_STATE_DELAY then
		self:HandleMyDelay(dt)
	elseif self._SpellState == SpellState.SPELL_STATE_PERIODIC then
		self:tick()
	elseif self._SpellState == SpellState.SPELL_STATE_BACKSWING then

		if dt >= self._backswingTime then
			self._backswingTime = 0;
		else
			self._backswingTime = self._backswingTime - dt;
		end

		if self._backswingTime == 0 then
			----clog("spell %u backswing time over,will change to finish state",m_spellInfo->Id);
			self:Finish()
		end
	elseif self._SpellState == SpellState.SPELL_STATE_FINISHED then

	end
end

return Spell