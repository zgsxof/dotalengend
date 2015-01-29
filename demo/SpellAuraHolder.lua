local SpellAuraHolder = class("SpellAuraHolder")

SpellAuraHolder.__index = SpellAuraHolder

function SpellAuraHolder:ctor(spellinfo,target,caster)
	--self._baseValue = spellinfo.EffectBaseValue[effidx]
	--self:SetModifier(spellinfo.EffectApplyAuraName[effidx],self._baseValue, spellinfo.EffectAmplitude[effidx],0) --spellinfo.EffectMiscValue[effidx])
	
	--[[if spellinfo:HasAttribute(SPELL_ATTR_EX5_START_PERIODIC_AT_APPLY) == false then
		self.m_periodicTimer = m_modifier.periodictime
	end]]
	self._duration =  spellinfo.duration/1000
	self._maxDuration = self._duration

	self._spellinfo = spellinfo
	self._auraList = {}
	self._target = target
	self._caster = caster
end

function SpellAuraHolder:IsEmptyHolder()
	for i = 0,MAX_EFFECT_INDEX do
		if self._auraList[i] then
			return false
		end
	end

	return true
end

function SpellAuraHolder:AddAura( aura,index )
	--self._auraList[#self._auraList + 1] = aura
	self._auraList[index+1] = aura
end

function SpellAuraHolder:RemoveAura( index )
	if self._auraList[index+1] then
		self._auraList[index+1] = nil
	end
end

function SpellAuraHolder:GetID(  )
	return self._spellinfo.id
end

function SpellAuraHolder:ApplyAuraModifiers(apply, real)
    for i = 1,MAX_EFFECT_INDEX do
    	local aura = self:GetAuraByEffectIndex(i)
    	if aura then
    		aura:ApplyModifier(apply, real)
    	end
   	end
end

function SpellAuraHolder:GetAuraByEffectIndex( index )
	return self._auraList[index]
end

function SpellAuraHolder:GetCaster( )
 	return self._caster
end

function SpellAuraHolder:GetTarget( )
 	return self._target
end

function SpellAuraHolder:GetAuraDuration( )
	return self._duration
end

function SpellAuraHolder:SetAuraDuration( d )
	self._duration = d
end

function SpellAuraHolder:GetAuraMaxDuration( )
	return self._maxDuration
end

function SpellAuraHolder:SetAuraMaxDuration( d )
	self._maxDuration = d
end

function SpellAuraHolder:_AddSpellAuraHolder()
	--播放光环特效
	--当一个技能有多个光环时，只播放一个光环的特效
	local spelleffectEntry = GetSpellEffectEntry(self._spellinfo.visual)
	if spelleffectEntry then
		local effectPath = spelleffectEntry.VisualEffects[SpellPhase.PHASE_STATE]
		if effectPath == "" then return end
		local stateEffect = require("demo.SpellDisplay").new(effectPath)
		self._stateVisual = stateEffect
		self._target:addChild(stateEffect)
	end
end

function SpellAuraHolder:_RemoveSpellAuraHolder( )
	--移除光环特效
	if self._stateVisual then
		self._stateVisual:End()
		self._stateVisual = nil
	end
end

function SpellAuraHolder:Update( dt )
	if self._duration > 0 then
	    self._duration = self._duration - dt
	    if self._duration < 0 then
	        self._duration = 0
	    end
    end

    for k,v in pairs(self._auraList) do
    	v:Update(dt)
    end
end

return SpellAuraHolder