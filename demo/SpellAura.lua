local SpellAura = class("SpellAura")

SpellAura.__index = SpellAura

AuraType =
{
--------------------------点数-----------------------
	strength = uf.strength,  			--力量
	agilty 	 = uf.agilty,  				--敏捷
	intellect = uf.intellect, 			--智力
	max_hp 	 = uf.max_hp,				--血上限
	energy 	 = uf.energy, 				--能量
	armor 	 = uf.armor,  				--护甲
	resist 	 = uf.resist, 				--魔抗
	atk_dmg  = uf.atk_dmg, 				--物攻
	magic_power = uf.magic_power, 		--魔法强度
	atk_speed = uf.atk_speed, 			--攻速
	move_speed = uf.move_speed, 		--移动速度
	hit 		= uf.hit, 				--命中
	crit 	= uf.crit, 					--暴击
	dodge = uf.dodge, 					--闪避
	hp_leech = uf.hp_leech, 			--吸血
	attackrange= uf.attackrange,		--攻击范围
	armor_penetration = uf.armor_penetration,	--护甲穿透
	resist_ignore	= uf.resist_ignore,	--忽视抗性
	ad_reduce	= uf.ad_reduce,		--减免受到的物伤
	ap_reduce	= uf.ap_reduce,		--减免受到的魔伤
	heal_increase = uf.heal_increase,		--治疗效果提升
	BASE_STAT_MAX = uf.heal_increase,
----------------------百分比--------------------------
	strength_pct = uf.strength_pct,  			--力量
	agilty_pct 	 = uf.agilty_pct,  			--敏捷
	intellect_pct = uf.intellect_pct, 			--智力
	max_hp_pct 	 = uf.max_hp_pct,				--血上限
	energy_pct 	 = uf.energy_pct, 			--能量
	armor_pct 	 = uf.armor_pct,  			--护甲
	resist_pct 	 = uf.resist_pct, 			--魔抗
	atk_dmg_pct  = uf.atk_dmg_pct, 			--物攻
	magic_power_pct = uf.magic_power_pct, 		--魔法强度
	atk_speed_pct = uf.atk_speed_pct, 		--攻速
	move_speed_pct = uf.move_speed_pct, 		--移动速度
	hit_chance 		= uf.hit_chance, 		--命中率
	crit_chance 	= uf.crit_chance, 		--暴击率
	dodge_chance = uf.dodge_chance, 			--闪避率
	hp_leech_pct = uf.hp_leech_pct, 			--吸血率
	PCT_STAT_MAX = uf.hp_leech_pct,
-------------------我是属性分割线--------------------------
	cannot_move = 100,		--昏迷
	silence		= 110,		--沉默
	charm		= 111,		--魅惑
	immuneSpell		= 112,		--免疫某一系伤害（物理或魔法）
	immuneState		= 113,
	periodic_damage = 120,		--持续伤害
	periodic_heal = 121,		--持续治疗
	periodic_heal_leech = 122,	--持续吸血
	periodic_damage_pct = 130,		--持续伤害（百分比）
	periodic_heal_pct = 131,		--持续治疗（百分比）
	periodic_heal_leech_pct = 132,	--持续吸血（百分比）
}

function SpellAura:ctor(spellinfo,effidx,holder,caster,target)
	self._baseValue = spellinfo.EffectBaseValue[effidx]
	self:SetModifier(spellinfo.EffectApplyAuraName[effidx],self._baseValue, spellinfo.EffectAmplitude[effidx],spellinfo.EffectMiscValue[effidx])
	--[[
	if spellinfo:HasAttribute(SPELL_ATTR_EX5_START_PERIODIC_AT_APPLY) == false then
		self._periodicTimer = m_modifier.periodictime
	end]]
	self._periodicTimer = self._modifier.periodictime
	self._isPeriodic = false
	self._holder = holder
	self._effidx = effidx
	self._spellinfo = spellinfo
end

function SpellAura:GetEffIndex()
	return self._effidx
end

function SpellAura:GetHolder()
	return self._holder
end

function SpellAura:SetModifier( auraname,basevalue,periodictime,miscvalue )
	self._modifier =
	{
		m_auraname = 0,
		m_amount = 0,
		m_miscvalue = 0,
		periodictime = 0,
	}
	self._modifier.m_auraname = auraname
	self._modifier.m_amount = basevalue
	self._modifier.m_miscvalue = miscvalue
	self._modifier.periodictime = periodictime/1000
end

function SpellAura:GetTarget()
	return self._holder:GetTarget()
end

function SpellAura:GetCaster()
	return self._holder:GetCaster()
end

function SpellAura:ApplyModifier(bApply, bReal)
	local auratype = self._modifier.m_auraname
	
	local AuraHandler = 
	{
		[0] = function (apply, Real) self:HandleNull(apply, Real) end,
		[AuraType.cannot_move] = function (apply, Real)  self:HandleAuraModStun(apply, Real) end,
		[AuraType.silence]	   = function (apply, Real)	self:HandleAuraModSilence() end,
		[AuraType.charm]	   = function (apply, Real)	self:HandleAuraModCharm() end,
		[AuraType.immuneSpell]	   = function (apply, Real) self:HandleAuraModImmuneSpell(apply, Real) end,
		[AuraType.immuneState]	   = function (apply, Real) self:HandleAuraModImmuneState(apply, Real) end,
		[AuraType.periodic_damage] = function (apply, Real) self:HandlePeriodicDamage(apply, Real) end,
		[AuraType.periodic_heal] = function (apply, Real) self:HandlePeriodicHeal(apply, Real) end,
		[AuraType.periodic_heal_leech] = function (apply, Real) self:HandlePeriodicHealLeech(apply, Real) end,
	}
	if auratype == 0 then
		AuraHandler[auratype](bApply,bReal)
	elseif auratype > 0 and auratype <= AuraType.BASE_STAT_MAX then
		self:HandleStatModifier(bApply,bReal)
	elseif auratype > AuraType.BASE_STAT_MAX and auratype <= AuraType.PCT_STAT_MAX then
		self:HandleStatPctModifier(bApply,bReal)
	else
		AuraHandler[auratype](bApply,bReal)
	end
end

function SpellAura:HandleNull( bApply, bReal )
	
end

function SpellAura:HandleAuraModImmuneState(apply,real  )
	local target = self:GetTarget()
	target:ApplySpellImmune( self._spellinfo.id,SpellImmunity.STATE,self._modifier.m_miscvalue,apply )
end

function SpellAura:HandleAuraModImmuneSpell( apply,real )
	local target = self:GetTarget()
	target:ApplySpellImmune( self._spellinfo.id,SpellImmunity.SCHOOL,self._modifier.m_miscvalue,apply )
end

function SpellAura:HandleAuraModCharm( apply,real )
	local target = self:GetTarget()
	if apply then
		local caster = self:GetCaster()

		target:SetTypeFaction( caster:GetTypeFaction() )

		--删除仇恨列表。。新添仇恨列表
	else

		--删除仇恨列表。。新添仇恨列表
	end
end

function SpellAura:HandleAuraModSilence( apply, Real )
	local target = self:GetTarget()
	if apply then
		target:addUnitState( UnitStat.UNIT_STAT_SILENCED )

		local spell = target:GetCurrentSpell()
		--如果目标施法的技能是魔法技能，就打断它
		if spell:GetSpellDmgType() == SpellDmgClass.CLASS_MAGIC then
			target:InterruptSpell()
		end
	else
		target:clearUnitState( UnitStat.UNIT_STAT_SILENCED ) 
	end
end

function SpellAura:HandleAuraModStun(apply, Real)
	local target = self:GetTarget()
	if apply then
		target:addUnitState( UnitStat.UNIT_STAT_STUNNED ) 

		target:Stop()
		--目标昏迷时打断其技能，播放受伤动作
		target:InterruptSpell(true)
	else
		target:clearUnitState( UnitStat.UNIT_STAT_STUNNED ) 
	end
end

function SpellAura:HandleStatPctModifier( bApply,bReal )
	local auratype = self._modifier.m_auraname

	
	local target = self:GetTarget()
	target:HandleStatModifier(auratype, UnitModifierType.BASE_PCT, self._modifier.m_amount, bApply);
end

function SpellAura:HandleStatModifier( bApply,bReal )
	local auratype = self._modifier.m_auraname

	
	local target = self:GetTarget()
	target:HandleStatModifier(auratype, UnitModifierType.BASE_VALUE, self._modifier.m_amount, bApply);
end

function SpellAura:HandleModHealth( bApply, bReal )
	local target = self:GetTarget()

    target:HandleStatModifier(UnitMods.UNIT_MOD_HEALTH, UnitModifierType.BASE_VALUE, self._modifier.m_amount, bApply);
end

function SpellAura:HandleModArmor( bApply, bReal )
	local target = self:GetTarget()

    target:HandleStatModifier(UnitMods.UNIT_MOD_ARMOR, UnitModifierType.BASE_VALUE, self._modifier.m_amount, bApply);
end

function SpellAura:HandleModSpeed( bApply, bReal )
	local target = self:GetTarget()

    target:HandleStatModifier(UnitMods.UNIT_MOD_ATTACK_SPEED, UnitModifierType.BASE_PCT, self._modifier.m_amount, bApply);
end

function SpellAura:HandlePeriodicDamage( bApply, bReal )
	-- SPELL_AURA_PERIODIC_DAMAGE
	self._isPeriodic = bApply


end

function SpellAura:PeriodicTick()
    cclog("SpellAura:PeriodicTick()")
	local target = self:GetTarget()
	local caster = self:GetCaster()

	local funcTable = 
	{
		[AuraType.periodic_damage] = function() caster:DealDamage(target,self._modifier.m_amount,DamageEffectType.DOT) end,
		[AuraType.periodic_heal] = function() caster:DealDamage(target,self._modifier.m_amount,DamageEffectType.HEAL) end,
	}

	funcTable[self._modifier.m_auraname]()
end

function SpellAura:Update( dt )
	if self._isPeriodic then
		self._periodicTimer = self._periodicTimer - dt
		if self._periodicTimer <= 0 then
			self._periodicTimer = self._periodicTimer + self._modifier.periodictime
			--self._periodicTick = self._periodicTick + 1
			self:PeriodicTick()
		end
	end
end


return SpellAura