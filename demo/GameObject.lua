local BaseObject = require("demo.BaseObject")

local GameObject = class("GameObject", BaseObject)
GameObject.__index = GameObject

TypeFaction =
{
	TYPE_FACTION_PLAYER		        = 0,
	TYPE_FACTION_CREATURE			= 1,
}

AttackType = 
{
	BASE_ATTACK = 1,
	RANGE_ATTACK = 2,
}

SpellImmunity = 
{
	STATE                 = 1,
	SCHOOL                = 2,
};

UnitStat = 
{
	UNIT_STAT_MOVE = 0x01,
	UNIT_STAT_STUNNED = 0x02,
	UNIT_STAT_SILENCED = 0x04,
	UTL_PREPARE = 0x08,
}

DeathState = 
{
	ALIVE = 1,
	JUST_DIED = 2,
	DEAD = 3,
	JUST_ALIVE = 4,
}

UnitModifierType = 
{
	BASE_VALUE = 1,
	BASE_PCT = 2,
	MODIFIER_TYPE_END = 3
}

uf = 
{
	none 	 = 0,
---------------------点数------------------------
	strength = 1,  			--力量
	agilty 	 = 2,  			--敏捷
	intellect = 3, 			--智力
	max_hp 	 = 4,			--血上限
	energy 	 = 5, 			--能量
	armor 	 = 6,  			--护甲
	resist 	 = 7, 			--魔抗
	atk_dmg  = 8, 			--物攻
	magic_power = 9, 		--魔法强度
	atk_speed = 10, 		--攻速
	move_speed = 11, 		--移动速度
	hit 		= 12, 		--命中
	crit 	= 13, 			--暴击
	dodge = 14, 			--闪避
	hp_leech = 15, 			--吸血
	attackrange= 16,		--攻击范围
	armor_penetration = 17,	--护甲穿透
	resist_ignore	= 18,	--忽视抗性
	ad_reduce	= 19,		--减免受到的物伤
	ap_reduce	= 20,		--减免受到的魔伤
	heal_increase = 21,		--治疗效果提升
	hp 		 	 = 22, 			--血量
------------------百分比------------------------------
	stat_per_begin = 30,
	strength_pct = 30,  			--力量
	agilty_pct 	 = 31,  			--敏捷
	intellect_pct = 32, 			--智力
	max_hp_pct 	 = 33,			--血上限
	energy_pct 	 = 34, 			--能量
	armor_pct 	 = 35,  			--护甲
	resist_pct 	 = 36, 			--魔抗
	atk_dmg_pct  = 37, 			--物攻
	magic_power_pct = 38, 		--魔法强度
	atk_speed_pct = 39, 		--攻速
	move_speed_pct = 40, 		--移动速度
	hit_chance 		= 41, 		--命中率
	crit_chance 	= 42, 		--暴击率
	dodge_chance = 43, 			--闪避率
	hp_leech_pct = 44, 			--吸血率
	attackrange_pct = 45,		--攻击范围
	armor_penetration_pct = 46,	--护甲穿透
	resist_ignore_pct	= 47,	--忽视抗性
	ad_reduce_pct	= 48,		--减免受到的物伤
	ap_reduce_pct	= 49,		--减免受到的魔伤
	healEnhance_pct = 50,		--治疗效果提升
	stat_per_end = 50,
	
	max_stat_end = 50,
}

SpellMissInfo = 
{
	SPELL_MISS_NONE = 0,
	SPELL_MISS_MISS = 2,	
	SPELL_MISS_DODGE = 3,
	SPELL_MISS_IMMUNE = 4,
}

SpellDmgClass = --技能伤害类型
{
	NONE     = 0, 
	CLASS_ATK_DMG  = 1, --物理
	CLASS_MAGIC    = 2, --魔法
};

DamageEffectType =
{
	DIRECT_DAMAGE           = 0,                            
	SPELL_DIRECT_DAMAGE     = 1,                            
	DOT                     = 2,
	HEAL                    = 3,
	INFO     				= 4,
}

function GameObject:ctor( )
	self:Reset()
end

function GameObject:Reset( )
	self._stat = 0
	self._class = 0
	self._spellIds = {}
	self._maxpower = 1000
	self._map = nil
	self._AI = nil
	self._typefaction = TypeFaction.TYPE_FACTION_CREATURE
	self._positionX = 0
	self._positionY = 0
	self._orientation = 0
	self._objSize = 0
	self._moveSpeed = 0
	self._attackType = AttackType.BASE_ATTACK
	self._attacktime = {0,0}
	self._attacktimer = {0,0}

	self._spellAuraHolders = {}
	self._auraModifiersGroup = {}
	for i = 1,uf.max_stat_end-1 do
		self._auraModifiersGroup[i] = {}
		self._auraModifiersGroup[i][UnitModifierType.BASE_VALUE] = 0
		self._auraModifiersGroup[i][UnitModifierType.BASE_PCT] = 1
	end

	self._field = {}
	--把属性百分比初始为1
	for i = uf.stat_per_begin,uf.stat_per_end do
		self._field[i] = 1
	end

	--暴击率，闪避率，吸血率初始为0
	self._field[uf.crit_chance] = 0
	self._field[uf.dodge_chance] = 0
	self._field[uf.hp_leech_pct] = 0

	self._SpellImmune = {}
	self._SpellImmune[SpellImmunity.STATE] = {}
	self._SpellImmune[SpellImmunity.SCHOOL] = {}

	self._pause = false
	self._flip = false
end

function GameObject:Init( data )
	self._objSize = data._objSize
	self._class = data._class
	self._spellIds = data._spellIds
	self._spellseq = data._spellseq

	self._field = {}
	--把属性百分比初始为1
	for i = uf.stat_per_begin,uf.stat_per_end do
		self._field[i] = 1
	end

	--暴击率，闪避率，吸血率初始为0
	self._field[uf.crit_chance] = 0
	self._field[uf.dodge_chance] = 0
	self._field[uf.hp_leech_pct] = 0
	self._field[uf.healEnhance_pct] = 0

------------------------set stat-----------------------------
	self._field[uf.max_hp] = data._hp
	self._field[uf.hp] = data._hp
	self._field[uf.energy] = 0
self._field[uf.energy] = 999
	self._field[uf.armor] = data._armor
	self._field[uf.resist] = data._resis
	self._field[uf.atk_dmg] = data._phy_dmg
	self._field[uf.magic_power] = data._magic_dmg
	self._field[uf.atk_speed] = data._attacktime
	self._field[uf.move_speed] = data._moveSpeed
	self._field[uf.hit] = 0
	self._field[uf.crit] = data._crit
	self._field[uf.dodge] = data._dodge
	self._field[uf.hp_leech] = data._absorbHeal
	self._field[uf.armor_penetration] = data._strikeArmor	--护甲穿透
	self._field[uf.resist_ignore]	= data._ignoreResist	--忽视抗性

	self._field[uf.attackrange] = data._attackrange * (winSize.width/48)
cclog("---player attackrange:"..self._field[uf.attackrange])
	self._field[uf.atk_speed_pct] = 1 --攻击速度百分比初始时为1
	self._field[uf.healEnhance_pct] = data._healEnhance --治疗效果提升百分比

	self:InitGuise()

end

function GameObject:InitGuise()
 	local filename = self:GetDisplayPath()
	self:Load(filename)
end

function GameObject:GetStat( id )
	return self._field[id]
end

function GameObject:SetStat( id,value )
	if id == uf.move_speed then
		local a
	end
	self._field[id] = value
end


function GameObject:GetDisplayPath()
	local entry = GetDisplayInfoEntry(self._class)
if not entry then
	entry = GetDisplayInfoEntry(4)
end
	if LOAD_ARMATURE == LOAD_ARMATURE_BY_CCS then
		entry = entry.xmlPath
	end
	assert(entry)
	return entry
end

function GameObject:GetClass()
	return self._class
end

function GameObject:GetSpells()
	return self._spellIds
end

function GameObject:GetSpellSeq()
	return self._spellseq
end

function GameObject:GetInitStandPos()
	local function getLocation(classId)
		if classId < 80 then
			return LocationType.LOCATION_FRONT
		elseif classId >= 80 and classId < 160 then
			return LocationType.LOCATION_MIDDLE
		elseif classId >= 160 and classId < 240 then
			return LocationType.LOCATION_BACK
		end
	end

	local loc = getLocation(self._class)
	local index = 0  --队伍中的位置
	local location_pos = 1 --排中的位置
	local objects = {}
	local InitPos = 0
	local factor = 1
	local x = 0
	if self:GetTypeFaction() == TypeFaction.TYPE_FACTION_PLAYER then
		objects = sObjectAccessor:GetPlayers()
		InitPos = OFFENCE_INIT_POS_BEGIN
		factor = -1
	else
		objects = sObjectAccessor:GetCreatures()
		InitPos = DEFENCE_INIT_POS_BEGIN
		factor = 1
		x = self:GetMap()._mapWidth
	end

	for k,v in pairs(objects) do
		if v == self then
			index = k
			break
		end
	end

	for k,v in pairs(objects) do
		if k < index and getLocation(v:GetClass()) == loc then
			location_pos = location_pos + 1
		end
	end

	local sBattleOffenceInitPos = {}
	for i = 1,MAX_BATTLE_CHAR_NUM * 3 do
		local lpEntry = GetBattlePosInfoEntry(i+InitPos);
		if lpEntry then
			sBattleOffenceInitPos[i] = cc.p(lpEntry.PosX,lpEntry.PosY)
		end
	end

	assert(loc >= LocationType.LOCATION_FRONT and loc <= LocationType.LOCATION_BACK);
	assert(location_pos >= 0 and location_pos <= MAX_BATTLE_CHAR_NUM);
	local retPos = sBattleOffenceInitPos[ MAX_BATTLE_CHAR_NUM * ( loc - 1 ) + location_pos];
	retPos.x = 100 * index * factor + x
	cclog("battle init pos,posx:"..retPos.x..",posy:"..retPos.y)

	return retPos

end

function GameObject:ModifyHealth( dVal )
	if dVal == 0 then return end

	local curHp = self:GetStat(uf.hp) --self:GetHealth()

	local val = dVal + curHp

	if val <= 0 then
		self:SetStat(uf.hp,0)
		--self:SetHealth(0)
		return -curHp
	end

	local maxHp = self:GetStat(uf.max_hp) --self:GetMaxHealth()
	if val < maxHp then
		self:SetStat(uf.hp,val)

		return dVal
	else
		self:SetStat(uf.hp,maxHp)

		return maxHp - curHp
	end

end

function GameObject:GetMaxPower( )
	return 1000
end

function GameObject:ModifyPower( dVal )
	if dVal == 0 then return end

	local curPow = self:GetStat(uf.energy) --self:GetPower()

	local val = dVal + curPow

	if val <= 0 then
		self:SetStat(uf.energy,0)
		return
	end

	local maxPower = self:GetMaxPower()
	if val < maxPower then
		self:SetStat(uf.energy,val)
	else
		self:SetStat(uf.energy,maxPower)
	end
end

function GameObject:SetMap( map )
	self._map = map
end

function GameObject:GetMap()
	return self._map
end

function GameObject:OnEnterBattle()
	cclog("game obj enter battle func......")

	local pos = self:GetInitStandPos()
	self:SetPosition(pos.x,pos.y)

	self._deathState = DeathState.ALIVE
end

function GameObject:OnQuitBattle()
	
end

function GameObject:AI()
	return self._AI
end

function GameObject:AIM_Initialize()
	if self._typefaction == TypeFaction.TYPE_FACTION_PLAYER then
		self._AI = require("demo.PlayerAI").new(self)
	else
		self._AI = require("demo.CreatureAI").new(self)
	end

	return true;
end

function GameObject:DeleteThreatList()
	self._threatList = nil
end

function GameObject:AddThreat( victim )
	if not self._threatList then self._threatList = {} end
	for _,v in pairs(self._threatList) do
		if v == victim then
			cclog("already exist threat,return")
			return
		end
	end
	self._threatList[ #self._threatList + 1 ] = victim
end

function GameObject:RemoveThreat( victim )
	if not self._threatList then return end

	for k,v in pairs(self._threatList) do
		if v == victim then
			table.remove(self._threatList,k)
		end
	end
end

function GameObject:SetTypeFaction( type )
	self._typefaction = type
end

function GameObject:GetTypeFaction(  )
	return self._typefaction
end

function GameObject:IsFriendlyTo( object )
	if object:GetTypeFaction() == self:GetTypeFaction() then
		return true
	else
		return false
	end
end

function GameObject:IsHostileTo( object )
	if object:GetTypeFaction() ~= self:GetTypeFaction() then
		return true
	else
		return false
	end
end

function GameObject:SetDeathState( s )
	if s ~= DeathState.ALIVE then
		self:CombatStop()

		self:DeleteThreatList()

		if self:HasSpellCasted() then
			self:InterruptSpell()
		end

		self:stopAllActions()

		self:Play(Action.Death)

		--移除身上所有特效
		for i = 1,self:getChildrenCount() do
	        local child = self:getChildren()[i]

	        if iskindof(child,"SpellDisplay") then
				child:removeFromParent()
			end
	    end

		local delay = cc.DelayTime:create(2)
		local fade = cc.FadeOut:create(1.5)
		self:runAction(cc.Sequence:create(delay,fade))

		--self:UpdateHp()
		--self._map:Remove(self)
	end
	self._deathState = s
end

function GameObject:IsDead()
	return self._deathState == DeathState.JUST_DIED or self._deathState == DeathState.DEAD
end

function GameObject:IsAlive()
	return self._deathState == DeathState.ALIVE
end

function GameObject:SetPositionX(x)
	self:setPositionX(x)
end

function GameObject:GetPositionX( )
	return self:getPositionX()
end

function GameObject:SetPositionY(y)
	self:setPositionY(y)
end

function GameObject:GetPositionY()
	return self:getPositionY()
end

function GameObject:SetPosition( x,y )
	self:setPosition(cc.p(x,y))
end

function GameObject:GetPosition()
	return self:getPosition()
end

function GameObject:SetOrientation( o )
	self._orientation = o
end

function GameObject:GetOrientation()
	return self._orientation
end

function GameObject:GetBone( name )
	local dict = self._armature:getBoneDic()
	for bonename,bone in pairs(dict) do
		if string.find(bonename,name) then
			return bone
		end
	end

	return nil
end

function GameObject:GetBonePos2( name )
	local pos
	local dict = self._armature:getBoneDic()
	for bonename,bone in pairs(dict) do
		if string.find(bonename,name) then
			pos = bone:getDisplayRenderNode():convertToWorldSpaceAR(cc.p(0, 0));
			break
		end
	end

	return pos
end

function GameObject:GetBonePos(BonePos)
	--[[
	local dict = self._armature:getBoneDic()
	for k,v in pairs(dict) do
		cclog(k)
	end
	local bone = self._armature:getBone("laxus_ybs")
	local pos = bone:getDisplayRenderNode():convertToWorldSpaceAR(cc.p(0, 0));
	cclog("bone jura_qg posx:"..pos.x..",posy:"..pos.y)

	return pos]]
--[[暂时先返回object的位置]]
local posx,posy = self:GetPosition()
return cc.p(posx,posy)
end

function GameObject:SetObjectSize( size )
	self._objSize = size
end

function GameObject:GetObjectSize()
	return self._objSize
end

function GameObject:GetDistance( obj )
	local dx = self:GetPositionX() - obj:GetPositionX();
	local dy = self:GetPositionY() - obj:GetPositionY();
	local sizefactor = self:GetObjectSize().width/2 + obj:GetObjectSize().width/2
	local dist = math.sqrt((dx*dx) + (dy*dy)) - sizefactor;
	if dist > 0 then
		return dist
	else
		return 0
	end
end

function GameObject:GetDistancePoint( pos )
	local dx = self:GetPositionX() - pos.x;
	local dy = self:GetPositionY() - pos.y;

	local dist = math.sqrt((dx*dx) + (dy*dy))
	if dist > 0 then
		return dist
	else
		return 0
	end
end

function GameObject:IsWithinDistInMap( obj, dist )
	local objPos = obj:getPosition()

	return self:IsWithinDist2d(objPos,dist)
end

function GameObject:IsWithinRectRange( obj, dist )
	local objDis
	if self:isFlip() then
		if self:getPositionX() - dist >= obj:getPositionX() then
			return true
		end
	else
		if self:getPositionX() - dist <= obj:getPositionX() then
			return true
		end
	end

	return false
end

function GameObject:IsWithinDist2d( pos, dist )
	if self:GetDistancePoint(pos) <= dist then
		return true
	else
		return false
	end
end

function GameObject:IsInAttackRange(victim)
	local dx = self:GetPositionX() - victim:GetPositionX();
	local dy = self:GetPositionY() - victim:GetPositionY();

	assert(victim)

	local objectSize = victim:GetObjectSize().width/2 + self:GetObjectSize().width/2
	--[[if self:GetObjectSize() > objectSize then
		objectSize = self.GetObjectSize()
	end]]

	local reach = self._field[uf.attackrange] + objectSize + 1

	return math.abs(dx) < reach
end

function GameObject:GetAttackType()
	if self._field[uf.attackrange] > 6.4 * (winSize.width / 48) then
		return AttackType.RANGE_ATTACK
	else
		return AttackType.BASE_ATTACK
	end
end

function GameObject:SetAttackTime( type,time )
	self._attacktime[type] = time
end

function GameObject:GetAttackTime( type )
	local speedpct = self:GetModifierValue(uf.atk_speed_pct,UnitModifierType.BASE_PCT)
	if self._class == 1 then
		local a
	end
	return self._attacktime[type] / speedpct
end

function GameObject:GetAttackTimer( type )
	return self._attacktimer[type]
end

function GameObject:SetAttackTimer( attacktype,time )
	self._attacktimer[attacktype] = time
end

function GameObject:ResetAttackTimer(attacktype)
	self._attacktimer[attacktype] = self:GetAttackTime(attacktype)
end

function GameObject:SortThreatList()
	if not self._threatList or #self._threatList == 0 then return nil end
	
	if #self._threatList > 1 then
		for _,v in pairs(self._threatList) do
			if self:GetDistance(v) < minDis then
				target = v
				minDis = self:GetDistance(v)
			end
		end
	end
end

function GameObject:GetDeltaX( target )
	return math.abs(self:GetPositionX() - target:GetPositionX())
end

function GameObject:GetHostileTarget( )
	if not self._threatList or #self._threatList == 0 then return nil end

	local removeList = {}
	for k,v in pairs(self._threatList) do
		if v:IsDead() then
			removeList[#removeList + 1] = k
		end
	end

	for i = 1,#removeList do
		table.remove(self._threatList,removeList[i])
	end

	if not self._threatList or #self._threatList == 0 then return nil end

	--根据minX来选择目标
	local minDis = self:GetDeltaX(self._threatList[1])
	local target = {}
	for _,v in pairs(self._threatList) do
		if self:GetDeltaX(v) <= minDis then
			target[#target + 1] = v
			minDis = self:GetDeltaX(v)
		end
	end

	--minX相同，优先选择
	if #target >= 1 then
		return target[1]
	end

	return nil
end

function GameObject:GetObjectBox( )
	local origin = cc.p( self:getPositionX() - self._objSize.width,self:getPositionY() )
	return cc.rect( origin.x,origin.y,self._objSize.width,self._objSize.height )
end


function GameObject:Load( filename )
	self._armature = ccui.loadArmature( filename )
	self._armature:getAnimation():playWithIndex(0)
	--
	if tolua.type(self) == "cc.Sprite" then
		self:addChild(self._armature)
		self._armature:pos(cc.pMul(cc.s2p(self:getContentSize()),0.5))
	else
		self:addChild(self._armature)
		self._armature:pos(cc.pMul(cc.s2p(self:getVirtualRendererSize()),0.5))
	end
	local rect = self._armature:getBoundingBox()
	self._objSize = cc.size(self._armature:getContentSize().width,self._armature:getContentSize().height)--self._armature:getContentSize().width/2

	local function movementEventCallback( armature, type, movementID )
		if type == ccs.MovementEventType.loopComplete then
	    	if movementID ~= Action.Move and movementID ~= Action.Idle and movementID ~= Action.Death and movementID ~= Action.Cheer then
	    		 armature:getAnimation():play(Action.Idle)
	    	end
	    elseif type == ccs.MovementEventType.complete then
	    	if movementID ~= Action.Move and movementID ~= Action.Idle and movementID ~= Action.Death and movementID ~= Action.Cheer then
	    		armature:getAnimation():play(Action.Idle)
	    	end
	    end
	end


	self._armature:getAnimation():setMovementEventCallFunc(movementEventCallback);

	----血条
	self._valueStrip = require("demo.ValueStrip").new("frame_blood.png","bloodr.png")
	self:addChild(self._valueStrip)
	self._valueStrip:pos(cc.p( self._armature:getPositionX(),self._armature:getPositionY() + self._armature:getContentSize().height + 15))

--self:ShowBoundingBox()
end

function GameObject:Play( action,loop )
	self._armature:getAnimation():play( action ) 
	if self._info then
		local rate = self._info.frameRate/60
		self._armature:getAnimation():setSpeedScale(rate)
	end
end

function GameObject:PlayWithIndex( index )
	index = index % self._armature:getAnimation():getMovementCount();
	cclog("object playwithindex:"..index)
	self._armature:getAnimation():playWithIndex( index ) 
end

function GameObject:GetAngle( pos )
	local dx = pos.x - self:GetPositionX()
	local dy = pos.y - self:GetPositionY()

	local ang = math.atan2(dy,dx)
	if ang < 0 then
		ang = 2 * math.pi + ang
	end

	return ang
end

function GameObject:isFlip(  )
	return self._flip
end

function GameObject:setFlip(bFlip)
	--[[
	if bFlip and not self._flip then
		self._armature:setScaleX( self._armature:getScaleX() * -1 )
	end
	self._flip = bFlip]]

	if self._flip ~= bFlip then
		self._armature:setScaleX( self._armature:getScaleX() * -1 )
		self._flip = bFlip
	end
end

function GameObject:SetFaceTo( o )
	
	if o > math.pi/2 and o < math.pi * 1.5 then
		self:setFlip(true)
	else
		self:setFlip(false)
	end

	self._orientation = o
end

function GameObject:MoveTo( pos,speed )
	local ang = self:GetAngle(pos)
	self:SetFaceTo(ang)

	local t = self:GetDistancePoint(pos) / speed
	local moveTo = cc.MoveTo:create(t,cc.p(pos.x,pos.y) )
	--local moveTo = MoveToEx:create(t,cc.p(pos.x,pos.y) )
	self:runAction(moveTo)
	self:Play(Action.Move) --self:Play("Move")

	self:addUnitState(UnitStat.UNIT_STAT_MOVE)
end

function GameObject:Stop( )
	self:stopAllActions()
	self:Play(Action.Idle)
	self:clearUnitState(UnitStat.UNIT_STAT_MOVE)
end

function GameObject:IsMoving()
	if self:hasUnitState(UnitStat.UNIT_STAT_MOVE) then
		return true
	else
		return false
	end
end

function GameObject:AdjustPosition( )
	-- body
end

function GameObject:SetInCombatWith( enemy )
	
end

function GameObject:IsSpellCrit( spellinfo )
	local critChance = self._field[uf.crit_chance] * 100

	math.randomseed(os.time())
	local roll = math.random(1,100)
	if roll < critChance then
		return true
	else
		return false
	end

end

function GameObject:ApplySpellImmune( spellId, op, type, apply )
	if apply then
		local removeList = {}
		for k,val in pairs(self._SpellImmune[op]) do
			if val._type == type then
				removeList[#removeList + 1] = k
			end
		end
		for i = 1,#removeList do
			table.remove(self._SpellImmune[op],removeList[i])
		end

		local info = { _type = type,_spellId = spellId }
		table.insert(self._SpellImmune[op],info)
	else
		for k,val in pairs(self._SpellImmune[op]) do
			if val._spellId == spellId then
				table.remove(self._SpellImmune[op],k)
				break
			end
		end

	end
end

--免疫伤害
function GameObject:IsImmunedToDamage( spellinfo )
	return self:IsImmuneToSpell(spellinfo)
end

--免疫技能类型
function GameObject:IsImmuneToSpell(spellinfo)
	if not spellinfo then return false end

	local SpellImmuneList = self._SpellImmune[SpellImmunity.SCHOOL]
	for k,v in pairs(SpellImmuneList) do
		if spellinfo.DmgClass == v._type then
			return true
		end
	end

	return false
end

--免疫技能效果或光环
function GameObject:IsImmuneToSpellEffect( spellinfo,effidx )
	local SpellImmuneList = self._SpellImmune[SpellImmunity.STATE]
	for k,v in pairs(SpellImmuneList) do
		if spellinfo.EffectApplyAuraName[effidx] == v._type then
			return true
		end
	end

	return false
end

function GameObject:PhysicalSpellHitResult( victim,spellinfo )
	math.randomseed(os.time())
	local roll = math.random(1,100)

	local hitchance = self:GetStat(uf.hit_chance) * 100 --self:GetHitChance() --得计算光环影响后的命中率
	local misschance = 100 - hitchance
	if roll < misschance then
		return SpellMissInfo.SPELL_MISS_MISS
	end

	local dodgeChance = victim:GetStat(uf.dodge_chance) * 100 --victim:GetDodgeChance()
	if roll < misschance + dodgeChance then
		return SpellMissInfo.SPELL_MISS_DODGE
	end

	return SpellMissInfo.SPELL_MISS_NONE
end

function GameObject:MagicSpellHitResult( victim,spellinfo )
	return SpellMissInfo.SPELL_MISS_NONE
end

function GameObject:SpellHitResult( victim,spellinfo)
	local ret = SpellMissInfo.SPELL_MISS_NONE

	--target是否对技能系免疫
	if victim:IsImmuneToSpell(spellinfo) then
		return SpellMissInfo.SPELL_MISS_IMMUNE
	end

	if spellinfo.DmgClass == SpellDmgClass.CLASS_ATK_DMG then
		ret = self:PhysicalSpellHitResult(victim, spellinfo);
	elseif spellinfo.DmgClass == SpellDmgClass.CLASS_MAGIC then
		ret = self:MagicSpellHitResult(victim, spellinfo);
	end

	return ret
end

function GameObject:GetSpell( attr )
	for _,v in pairs(self._spellIds) do
		local spellinfo = GetSpellEntry(v)
		if spellinfo and HasSpellAttribute(spellinfo,attr) then
			return v
		end
	end
end

function GameObject:CanCastUtl()
	if self:IsDead() then return false end

	if self._map:GetState() ~= SceneStatus.SCENE_STATUS_UPDATE then return false end

	if self._field[uf.energy] >= self:GetMaxPower() then
	
		local utlSpellId = self:GetSpell( SpellAttributes.ultimate )
		local spellinfo = GetSpellEntry(utlSpellId)
		assert(spellinfo)

		--被沉默的情况下，只能放物理技能，不能放魔法技能
		if self:hasUnitState(UnitStat.UNIT_STAT_SILENCED) and spellinfo.DmgClass == SpellDmgClass.CLASS_MAGIC then
			return false
		end

		--昏迷的情况下不能施法
		if self:hasUnitState(UnitStat.UNIT_STAT_STUNNED) then
			return false
		end

		if band(spellinfo.targetMask ,SpellTargets.TARGETS_UNIT) ~= 0 then
			--需要有目标才能释放技能
			local target = self:GetHostileTarget()
			if not target then return false end
			
			--check cast:距离？
		end
	else
		return false
	end

	return true
end

function GameObject:CastSpell( victim,spellId )
	if spellId == self:GetSpell(SpellAttributes.ultimate) then
		self:Stop()
		self:InterruptSpell()
		self:SetStat(uf.energy,0)
	else
		self:ModifyPower(91)
	end

	local spell = require("demo.Spell").new(self,victim,spellId)
	self._currentSpell = spell
end

function GameObject:SetCurrentCastedSpell( spell )
	self._currentSpell = spell
end

function GameObject:GetCurrentSpell()
	return self._currentSpell
end

function GameObject:InterruptSpell(bPlayHurt)
	if bPlayHurt then
		self:Play(Action.Hurt)
	end

	if not self._currentSpell then return end

	self._currentSpell:Cancel()
end

function GameObject:HasSpellCasted()
	--在施放技能
	if self._currentSpell then
		if self._currentSpell:GetState() == SpellState.SPELL_STATE_FINISHED then
			return false
		else
			return true
		end
	else
		return false
	end
end

function GameObject:CastFailure()
	
end

function GameObject:Attack( target,spellId )
	self:CastSpell(target,spellId)
	
	self:ResetAttackTimer(self:GetAttackType())

	if self ~= target then
		self._attacking = target
		local orientation = self:GetAngle(target:GetPosition())
		self:SetFaceTo(orientation)
	end
end

function GameObject:AttackStop()
	-- body
end

function GameObject:CombatStop()
	self:InterruptSpell()
	self:DeleteThreatList()
end

function GameObject:SetFlag( flag )
	-- body
end

function GameObject:RemoveFlag( flag )
	-- body
end

function GameObject:addUnitState( f) 
	self._stat = bor(self._stat,f)
end
	
function GameObject:hasUnitState( f)
	if band(self._stat,f) == 0 then
		return false
	else
		return true
	end
end

function GameObject:clearUnitState( f)
	self._stat = band(self._stat,bnot(f))
end

function GameObject:getBoundBox( ... )

	local rect = self._armature:getBoundingBox()

    local rect2 = cc.rect(self:GetPositionX(),self:GetPositionY(),rect.width/2,rect.height/2)

    return rect2
end

function GameObject:ShowBoundingBox()
	if not self._armature then return end

	local draw = cc.DrawNode:create()
    self._armature:addChild(draw, 10,10086)

    local rect = self._armature:getBoundingBox()
    local star = {
        cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y),
        cc.p(rect.x + rect.width, rect.y + rect.height), cc.p(rect.x, rect.y + rect.height),
    }
    draw:drawPolygon(star, table.getn(star), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))


    local draw2 = cc.DrawNode:create()
    self:addChild(draw2)
    local rect2 = self:getBoundingBox()
    rect2.width = 5
    rect2.height = 5
     local star2 = {
        cc.p(rect2.x, rect2.y), cc.p(rect2.x + rect2.width, rect2.y),
        cc.p(rect2.x + rect2.width, rect2.y + rect2.height), cc.p(rect2.x, rect2.y + rect2.height),
    }
    draw2:drawPolygon(star2, table.getn(star2), cc.c4f(1,0,0,0.5), 1, cc.c4f(0,0,1,1))
end

function GameObject:AddAuraToModList( )
	
end

function GameObject:AddSpellAuraHolder( holder )
	self._spellAuraHolders[holder:GetID()] = holder
	
	holder:_AddSpellAuraHolder();

	for i = 0,MAX_EFFECT_INDEX-1 do
		local aur = holder:GetAuraByEffectIndex(i)
		if aur then self:AddAuraToModList(aur) end
	end

	holder:ApplyAuraModifiers(true, true);
end

function GameObject:RemoveAllAuras()
	for k,holder in pairs(self._spellAuraHolders) do
		self:RemoveSpellAuraHolder(holder)
	end
end

function GameObject:RemoveSpellAuraHolder(holder, mode)
	self._spellAuraHolders[holder:GetID()] = nil
	holder:_RemoveSpellAuraHolder();

	for i = 1,MAX_EFFECT_INDEX do
		local aura = holder:GetAuraByEffectIndex(i)
		if aura then
		    self:RemoveAura(aura, mode);
		end
	end
end

function GameObject:RemoveAura( aura,mode )
	aura:GetHolder():RemoveAura(aura:GetEffIndex())

	aura:ApplyModifier(false,true)
end

function GameObject:UpdateSpell( dt )
	if self._currentSpell then
		self._currentSpell:Update(dt)
	end

	for k,holder in pairs(self._spellAuraHolders) do
		holder:Update(dt)
	end

	local removeList = {}
	for _,holder in pairs(self._spellAuraHolders) do
		--local holder = self._spellAuraHolders[i]
		if --[[holder:IsPermanent() == false and]] holder:GetAuraDuration() == 0 then
			removeList[#removeList + 1] = holder
		end
	end

	for i = 1,#removeList do
		self:RemoveSpellAuraHolder(removeList[i])
	end
end

function GameObject:UpdateMovement( dt )
	-- body
end

function GameObject:UpdateStat( dt )
	-- body
end

function GameObject:CalculateDamage(attacktype)
	--这里还没计算加成后的攻击力
	if attacktype == AttackType.RANGE_ATTACK then
		return self._field[uf.magic_power]
	else
		return self._field[uf.atk_dmg]
	end
end

function GameObject:CalculateReduceDamage(caster,DmgClass,damage)
	--物理受伤比 = 1/(（物理护甲-护甲穿透）*0.003+1)
	--魔法受伤比 = 1/（（对方魔法抗性-我方忽视抗性）*0.003+1）
	local ret = 0
	if DmgClass == SpellDmgClass.CLASS_MAGIC then --魔法伤害
		local per = 1 / ( ( self._field[uf.resist] - caster:GetStat(uf.resist_ignore) ) * 0.003 + 1 )
		ret = damage * (1-per)
	else --物理伤害
		local per = 1 / ( ( self._field[uf.armor] - caster:GetStat(uf.armor_penetration) ) * 0.003 + 1 )
		ret = damage * (1-per)
	end
	return math.ceil(ret)
end

function GameObject:AddCombatInfo(damage,type,bCrit)
	if damage <= 0 then
		return
	end
	
	local combatinfo = require("demo.CombatInfo").new(self,damage,type,bCrit)
	self:addChild(combatinfo)
	
	local pos = cc.p(self._armature:getPositionX(), self._armature:getPositionY() + self._armature:getContentSize().height)
	combatinfo:pos(pos)

	local offset = cc.MoveTo:create(1,cc.pAdd(combatinfo:getPosition(),cc.p(0,300)));
	local fadeout = cc.FadeOut:create(1);
	local scale = cc.ScaleTo:create(0.2,1.0);
	local easeOut = cc.EaseExponentialIn:create(scale);
	local sp = cc.Spawn:create(offset,cc.Sequence:create(easeOut,fadeout));
	combatinfo:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),sp,cc.CallFunc:create(function ()
		combatinfo:removeFromParent()
	end)))
end

function GameObject:DealHeal( victim,addhealth,bCrit )
	local gain = victim:ModifyHealth(addhealth)

	victim:AddCombatInfo(gain,DamageEffectType.HEAL,bCrit)
end

function GameObject:DealDamage( victim,damage,dmgType )
	if victim:IsDead() then
		return
	end
	
	local function getLocation(classId)
		if classId < 80 then
			return LocationType.LOCATION_FRONT
		elseif classId >= 80 and classId < 160 then
			return LocationType.LOCATION_MIDDLE
		elseif classId >= 160 and classId < 240 then
			return LocationType.LOCATION_BACK
		end
	end

	local victimLoc = getLocation(self._class);
	local dmgPer = damage/victim:GetStat(uf.max_hp)
	local incPer = 0
	if victimLoc == LocationType.LOCATION_FRONT then
		victim:ModifyPower( (dmgPer / 0.01) * 0.005 * victim:GetMaxPower() )
	elseif victimLoc == LocationType.LOCATION_MIDDLE then
		victim:ModifyPower( (dmgPer / 0.01) * 0.007 * victim:GetMaxPower() )
	elseif victimLoc == LocationType.LOCATION_BACK then
		victim:ModifyPower( (dmgPer / 0.01) * 0.01 * victim:GetMaxPower() )
	end

	local health = victim:GetStat(uf.hp)
	if health < damage then
		victim:SetStat(uf.hp,0)

		self:ModifyPower(300) --击杀1个敌人回复300点能量

		victim:SetDeathState(DeathState.JUST_DIED)

		if victim:GetMap():GetAI() then
			if victim:GetTypeFaction() == TypeFaction.TYPE_FACTION_CREATURE then
				victim:GetMap():GetAI():OnCreatureDead(victim)
			else
				victim:GetMap():GetAI():OnPlayerDead(victim)
			end
		end

		self:RemoveThreat(victim)
	else
		victim:ModifyHealth(-damage)
		--1次普通攻击伤害>被攻击英雄最大生命值8%时（数值待定），打断被攻击英雄当前动作
		if damage >= victim:GetStat(uf.max_hp) * 0.08 then
			local spell = victim:GetCurrentSpell()
			if spell then
				victim:InterruptSpell(true)
			end
		end
	end

	victim:AddCombatInfo(damage,dmgType)
end

function GameObject:Pause()
	self._pause = true
end

function GameObject:Resume()
	self._pause = false
end

function GameObject:UpdatePauseResume( )
	if self._pause then
		self:pause()

		self:DoPause()

	else
		self:resume()
		
		self:DoResume()
	end
end

function GameObject:UpdateHp( )
	local per = self:GetStat(uf.hp) / self:GetStat(uf.max_hp) * 100
	self._valueStrip:changeValue(1,per)
end

function GameObject:UpdateFace( )
	
	if self._attacking then
		local target = self._attacking
		local orientation = self:GetAngle(target:GetPosition())
		self:SetFaceTo(orientation)

	end

end

function GameObject:Update( dt )
	self:UpdateHp()

	self:UpdatePauseResume()
	if self._pause then
		return
	end

	if self:AI() then
		self:AI():Update(dt)
	end

	if self:GetAttackTimer(AttackType.BASE_ATTACK) ~= 0 then
		if dt >= self:GetAttackTimer(AttackType.BASE_ATTACK) then
			self:SetAttackTimer(AttackType.BASE_ATTACK,0)
		else
        	self:SetAttackTimer(AttackType.BASE_ATTACK,self:GetAttackTimer(AttackType.BASE_ATTACK) - dt);
        end
    end

	if self:GetAttackTimer(AttackType.RANGE_ATTACK) ~= 0 then
		if dt >= self:GetAttackTimer(AttackType.RANGE_ATTACK) then
			self:SetAttackTimer(AttackType.RANGE_ATTACK,0)
		else
        	self:SetAttackTimer(AttackType.RANGE_ATTACK,self:GetAttackTimer(AttackType.RANGE_ATTACK) - dt);
        end
		--self:SetAttackTimer(AttackType.RANGED_ATTACK, (dt >= self:GetAttackTimer(AttackType.BASE_ATTACK) ? 0 : self:GetAttackTimer(AttackType.BASE_ATTACK) - dt));
	end

	self:UpdateMovement(dt)
	self:UpdateSpell(dt)

	self:UpdateStat(dt)
end

function GameObject:GetModifierValue( unitMod,modifierType)
	if unitMod >= uf.max_stat_end or modifierType >= UnitModifierType.MODIFIER_TYPE_END then
		assert(false)
		return 0.0
	end

	return self._auraModifiersGroup[unitMod][modifierType];
end

function GameObject:UpdateSpeed()
	local timer = self:GetAttackTimer(self:GetAttackType())
	local speedpct = self:GetModifierValue(uf.atk_speed_pct,UnitModifierType.BASE_PCT)
	self:SetAttackTimer(self:GetAttackType(),timer/speedpct)
end

----------------------aura
function GameObject:HandleStatModifier( unitMod, modifierType, amount, apply )
	if modifierType == UnitModifierType.BASE_VALUE then
		if not apply then
			amount = 0 - amount
		end
cclog("-------handle stat modifyier,base,unitMod:"..unitMod..",amount:"..amount)
		self._auraModifiersGroup[unitMod][modifierType] = self._auraModifiersGroup[unitMod][modifierType] + amount
	elseif modifierType == UnitModifierType.BASE_PCT then
		local val = ( 100 + amount )/100
		if apply then
cclog("-------handle stat modifyier,base_pct,apply")
			self._auraModifiersGroup[unitMod][modifierType] = self._auraModifiersGroup[unitMod][modifierType] * val
		else
cclog("-------handle stat modifyier,base_pct,unapply")
			self._auraModifiersGroup[unitMod][modifierType] = self._auraModifiersGroup[unitMod][modifierType] * (1.0/val)
		end
	end

	
	local value = self:GetModifierValue(unitMod, UnitModifierType.BASE_VALUE) + self._field[unitMod];
	value = value * self:GetModifierValue(unitMod, UnitModifierType.BASE_PCT);

	if value < 0 then
		value = 0
	end

	self:SetStat(unitMod,value)

	if unitMod == uf.atk_speed_pct then
		self:UpdateSpeed()
	end

end


function GameObject:IsDirty()
	return self._dirty
end

function GameObject:SetDirty( flag )
	self._dirty = flag
end

return GameObject