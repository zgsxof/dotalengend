local ObjectInfoMgr = class("ObjectInfoMgr")
ObjectInfoMgr.__index = ObjectInfoMgr

local __instance = nil
local __allowInstance = nil

ObjectInfoMgr._players = {}
ObjectInfoMgr._items = {}
ObjectInfoMgr._hero = nil

function ObjectInfoMgr:ctor( )
	if not __allowInstance then
		error("ObjectInfoMgr is a singleton")
	end

	self:init()
end

function ObjectInfoMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = ObjectInfoMgr.new()
		__allowInstance = false
	end

	return __instance
end

function ObjectInfoMgr:init( )
	
end

function ObjectInfoMgr:GetCoin()
	local hero = ObjectMgr:GetHero()
	assert(hero,"nil hero")

	return hero:getCoin()
end

function ObjectInfoMgr:GetDiamond()
	local hero = ObjectMgr:GetHero()
	assert(hero,"nil hero")

	return hero:getJawel()
end

function ObjectInfoMgr:GetTotalExp() --经验罐子
	local hero = ObjectMgr:GetHero()
	assert(hero,"nil hero")

	return hero:GetTotalExp()
end

function ObjectInfoMgr:GetItemIconPath( guid )
	--[[
	local item = ObjectMgr:GetItem( guid )
	assert(item,"nil item")
	local entry = item:getItemId()]]
	return "itemicon/106.png"
end

function ObjectInfoMgr:GetItemCount( itemId )
	local hero = ObjectMgr:GetHero()
	assert(hero,"nil hero")

	return hero:GetItemCount(itemId)
end

function ObjectInfoMgr:GetUnsummonHeroes() --得到未召唤的英雄列表
	--[[数据还未配置，暂时返回测试数据
	local allClass = {}
	for i = 1,table.nums(sPlayerInfoStore) do
		if sPlayerInfoStore[i] then
			allClass[#allClass + 1] = sPlayerInfoStore[i].class
		end
	end
	local players = sObjectMgr:GetPlayerMap( )
	for k,player in pairs(players) do
		table.filter(allClass, function(v, k)
		    return v ~= player:GetClass() 
		end)
	end

	return allClass]]
	return {1,2,3,4}
end

function ObjectInfoMgr:GetPlayerInfo( guid )
	if tolua.type(guid) == "Guid" then
		guid = guid:getValue32()
	end

	local player = ObjectMgr:GetPlayer( guid )
	assert(player,string.format("不存在此guid对应的Player,guid:"..guid))

	local info = {}
	info._class = player:GetClass()
	info._debrisCounts = player:GetDebrisId()
	info._grade = player:getGrade()
	info._combatPower = player:GetCombatPower()
	info._level = player:getLevel()
	info._exp = player:getCurXp()
	info._nextExp = player:getNextLvXp()
	info._hp = player:GetHealth()
	info._strengthGrow = player:GetStrengthGrow()
	info._agilityGrow = player:GetAgilityGrow()
	info._intelligenceGrow = player:GetIntelligenceGrow()
	info._strength = player:GetStrength()
	info._agility = player:GetAgility()
	info._intelligence = player:GetIntelligence()
	info._extraStrength = player:GetExtraStrength()
	info._extraAgility = player:GetExtraAgility()
	info._extraIntelligence = player:GetExtraIntelligence()
	info._phy_dmg = player:GetPhysicalAttack()
	info._magic_dmg = player:GetMagicAttack()
	info._armor = player:GetArmor()
	info._resis = player:GetResistance()
	info._crit = player:GetCrit()
	info._dodge = player:GetDodge()	
	info._hit = player:GetHit()
	info._absorbHeal = player:GetAbsorbHeal()
	info._hpRecover = player:GetHpRecover()
	info._powerRecover = player:GetRageRecover()
	info._ignoreResist = player:GetIgnoreResist()
	info._strikeArmor = player:GetStrikeArmor()
	info._healEnhance = player:GetHealEnhance()
	info._attackrange = player:getAttackRange()
	info._equips = {}
	info._equips[1] = ObjectMgr:GetItem( player:getEquipId(17) ) -- player:getEquip(15)???
	info._equips[2] = ObjectMgr:GetItem( player:getEquipId(1) )
	info._equips[3] = ObjectMgr:GetItem( player:getEquipId(4) )
	info._equips[4] = ObjectMgr:GetItem( player:getEquipId(7) )
	info._spells = self._playerSpell[guid]


	--[[以下属性通过查询配置得到,暂时写死]]
	info._debrisCountsSummon = 30--self:GetDebrisCountsWhenSummon()
	info._debrisCountsUpgrade = 30--self:GetDebrisCountsWhenUpgrade()

	info._name = self:GetPlayerName(guid)
	info._desc = self:GetPlayerDesc(guid)
	info._iconPath = self:GetPlayerIconPath(guid)

	return info
end

function ObjectInfoMgr:AddPlayerSpell( guid,spellId )
	if tolua.type(guid) == "Guid" then
		guid = guid:getValue32()
	end
	if not self._playerSpell then self._playerSpell = {} end
	if not self._playerSpell[guid] then self._playerSpell[guid] = {} end
	if table.keyof(self._playerSpell[guid],spellId) == nil then
		table.insert(self._playerSpell[guid],spellId)
	end

	--排列技能顺序
end

function ObjectInfoMgr:RemovePlayerSpell( guid,spellId )
	if tolua.type(guid) == "Guid" then
		guid = guid:getValue32()
	end

	if not self._playerSpell[guid] then return end
	local index = table.keyof(self._playerSpell[guid],spellId)
	if index then
		table.remove(spells,index)
	end
end

local function getPlayerInitSpells( class )
	local initSpells = {}
	local playerinfo = sPlayerInfoStore[class]
	if playerinfo then
		--playerinfo.spell是从下标0开始
		if false then --如果普攻技是填在spell[5]
			for i = 1,4 do
				initSpells[i] = playerinfo.spell[i-1]
			end
		else
			for i = 1,4 do
				initSpells[i] = playerinfo.spell[i]
			end
		end
	else
		--assert(false)
		--还没配数值。。先默认给初始技能
		initSpells = {1,1,1,1}
	end

	return initSpells
end

local function getFirstSpellId(spellId)
	local entry = GetSpellChainEntry( spellId )
	if entry then
		return entry.first
	end

	return 0
end

function ObjectInfoMgr:GetLearnedSpells( guid )
	if tolua.type(guid) == "Guid" then
		guid = guid:getValue32()
	end

	local initSpells = getPlayerInitSpells(self:GetPlayerClass(guid))
	local spells = self._playerSpell[guid]
	local sortSpells = {}
	for i = 1,#spells do
		local spellId = spells[i]
		local firstSpell = getFirstSpellId(spellId)
		local index = table.keyof(initSpells,firstSpell)
		if index then
			sortSpells[index] = spellId
		else	
			--还没配数值。。暂时屏蔽检测
			--assert(false)
		end
	end

--assert( #sortSpells == table.nums(sortSpells) )
	return sortSpells
end

function ObjectInfoMgr:GetUnlearnedSpells( guid )
	local unlearnSpell = {}

	local initSpells = getPlayerInitSpells(self:GetPlayerClass(guid))
	local learnSpell = self:GetLearnedSpells(guid)
	local learnCounts = table.nums(learnSpell)
	for i = learnCounts + 1,4 do
		unlearnSpell[#unlearnSpell + 1] = initSpells[i]
	end

	return unlearnSpell
end

function ObjectInfoMgr:GetCastSpellSeq( guid )
	local castSpellSeq,meleeSpellId = {},0
	--[[
	local masterSpell = self._playerSpell[guid]
	for i = 1,#masterSpell do
		local entry = GetSpellEntry(masterSpell[i])
		if entry and HasSpellAttribute(entry,SpellAttributes.melee) then
			meleeSpellId = masterSpell[i]
			break
		end
	end

	local entry = GetPlayerInfoEntry(self:GetPlayerClass(guid))
	if entry then 
	    local tmp = string.split(entry.spellseq, ";")
	    for i = 1,#tmp - 1 do
	    	castSpellSeq[i] = tonumber(tmp[i])
		end

		
		for i = 1,#castSpellSeq do
			if table.keyof(masterSpell,castSpellSeq[i]) == nil then
				castSpellSeq[i] = meleeSpellId
			end
		end
	end
if #castSpellSeq == 1 and castSpellSeq[1] == 0 then
	castSpellSeq[1] = 3
end
	return castSpellSeq]]
	local entry = GetPlayerInfoEntry(self:GetPlayerClass(guid))
	if entry then 
	    local tmp = string.split(entry.spellseq, ";")
	    for i = 1,#tmp do
	    	if tonumber(tmp[i]) ~= 0 then
	    		castSpellSeq[i] = tonumber(tmp[i])
	    	end
		end
	end
	return castSpellSeq
end

function ObjectInfoMgr:SetBattlePlayers( players )
	self._battlePlayers = {}
	--[[
	for i = 1,#players do
		self._battlePlayers[i] = players[i]
	end]]
	self._battlePlayers = clone(players)
end

function ObjectInfoMgr:GetBattlePlayers()
	
if true then
	self._battlePlayers = {}

	local team = 0
	local playermap = ObjectMgr:GetPlayerMap()
	for k,v in pairs(playermap) do
		if v:IsInTeam(team) then
		--if band(v:getTeamFlags(),lshift(1,team)) > 0 then
			self._battlePlayers[#self._battlePlayers + 1] = k
		end
	end
end

	assert(#self._battlePlayers <= 5)

	--if not self._battlePlayers then self._battlePlayers = {} end
	return self._battlePlayers
end

function ObjectInfoMgr:MakeBattlePlayerInfo( index )
	local guid = self._battlePlayers[index]
	local info = self:GetPlayerInfo(guid)
	local data = {}
	data._objSize = 80
	data._class = info._class
	data._spellIds = self:GetLearnedSpells(guid)
	data._hp = info._hp
	data._phy_dmg = info._phy_dmg
	data._magic_dmg = info._magic_dmg
	data._armor = info._armor
	data._resis = info._resis
	data._crit = info._crit
	data._power = 0
	data._dodge = info._dodge
	data._hit = info._hit
	data._absorbHeal = info._absorbHeal
	data._hpRecover = info._hpRecover
	data._powerRecover = info._powerRecover
	data._ignoreResist = info._ignoreResist
	data._strikeArmor = info._strikeArmor
	data._healEnhance = info._healEnhance
	data._attackrange = info._attackrange
data._moveSpeed = 150
data._attackType = 0
data._attacktime = {4,4}
data._attacktimer = {0,0}
	data._spellseq = self:GetCastSpellSeq( guid )
--data._spellseq = {40,40}
       

	return data
end
--[[
	以下为player的属性方法
]]

function ObjectInfoMgr:GetPlayerClass(guid)
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
 	return player:GetClass()
end

function ObjectInfoMgr:GetPlayerIconPath( guid )
	local class = self:GetPlayerClass(guid)
	local entry = GetDisplayInfoEntry(class)
	if entry then
		return entry.icon
	end

	return ""
end

function ObjectInfoMgr:GetPlayerName( guid )
	local class = self:GetPlayerClass(guid)
	local entry = sPlayerInfoStore[class]
	if not entry then return "" end
	local name = entry.name
	local loc_idx = 0--INT.getLocaleIndex()
	if loc_idx > 0 then
		local localeUnitEntry = sLocaleUnitStore[id]
		if localeUnitEntry then name = localeUnitEntry.name[loc_idx-1] end
	end
	return name
end

function ObjectInfoMgr:GetPlayerDesc( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return ""
end

function ObjectInfoMgr:GetPlayerGrade( guid )	   --player的评级,可以通过魔力碎片来提高评级
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:getGrade()
end

function ObjectInfoMgr:GetPlayerNature( guid )	   --战斗属性:力量,智力,敏捷
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:getNature()
end

function ObjectInfoMgr:GetDebrisId(guid)  --英雄碎片个数
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetDebrisId()
end

function ObjectInfoMgr:GetDebrisCountsWhenSummon( guid )  --召唤英雄需多少碎片
	return 30
end

function ObjectInfoMgr:GetDebrisCountsWhenUpgrade()
	return 30
end

function ObjectInfoMgr:GetCombatPower(guid) --战斗力
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetCombatPower()
end

function ObjectInfoMgr:GetPlayerLevel(guid)
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:getLevel()
end

function ObjectInfoMgr:GetPlayerExp( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetDebrisId()
end

function ObjectInfoMgr:GetPlayerEquips( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return 0,0,0,0
end

function ObjectInfoMgr:GetPlayerSpells( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return 0,0,0,0
end

function ObjectInfoMgr:GetStrengthGrow(guid) --力量成长
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetStrengthGrow()
end

function ObjectInfoMgr:GetAgilityGrow(guid) --敏捷成长
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetAgilityGrow()
end

function ObjectInfoMgr:GetIntelligenceGrow(guid) --智力成长
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetIntelligenceGrow()
end

function ObjectInfoMgr:GetStrength( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetStrength()
end

function ObjectInfoMgr:GetAgility( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetAgility()
end

function ObjectInfoMgr:GetIntelligence( guid )
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")

	return player:GetIntelligence()
end

function ObjectInfoMgr:GetPhysicalAttack(guid) --物理攻击
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetPhysicalAttack()
end

function ObjectInfoMgr:GetMagicAttack(guid) --魔法攻击
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetMagicAttack()
end

function ObjectInfoMgr:GetArmor(guid) --物理防御
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetArmor()
end

function ObjectInfoMgr:GetResistance(guid) --魔法防御
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetResistance()
end

function ObjectInfoMgr:GetCrit(guid)		--暴击
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetCrit()
end

function ObjectInfoMgr:GetDodge(guid)		--闪避率
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetDodge()
end

function ObjectInfoMgr:GetHit(guid)		--命中
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetHit()
end

function ObjectInfoMgr:GetAbsorbHeal(guid) --吸血
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetAbsorbHeal()
end

function ObjectInfoMgr:GetHpRecover(guid)  --生命回复
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetHpRecover()
end

function ObjectInfoMgr:GetRageRecover(guid) --怒气回复
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetRageRecover()
end

function ObjectInfoMgr:GetIgnoreResist(guid) --忽视抗性
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetIgnoreResist()
end

function ObjectInfoMgr:GetStrikeArmor(guid)  --护甲穿透
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetStrikeArmor()
end

function ObjectInfoMgr:GetHealEnhance(guid)  --治疗效果提升
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetHealEnhance()
end

function ObjectInfoMgr:GetExtraStrength(guid) --加成的力量
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraStrength()
end

function ObjectInfoMgr:GetExtraAgility(guid)  --加成的敏捷
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraAgility()
end

function ObjectInfoMgr:GetExtraIntelligence(guid) --加成的智力
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraIntelligence()
end

function ObjectInfoMgr:GetExtraHp(guid)	--加成的生命
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraHp()
end

function ObjectInfoMgr:GetExtraPhysicalAttack(guid) --物理攻击
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraPhysicalAttack()
end

function ObjectInfoMgr:GetExtraMagicAttack(guid) --魔法攻击
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraMagicAttack()
end

function ObjectInfoMgr:GetExtraArmor(guid) --物理防御
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraArmor()
end

function ObjectInfoMgr:GetExtraResistance(guid) --魔法防御
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraResistance()
end

function ObjectInfoMgr:GetExtraHpRecover(guid)  --生命回复
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraHpRecover()
end

function ObjectInfoMgr:GetExtraRageRecover(guid) --怒气回复
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraRageRecover()
end

function ObjectInfoMgr:GetExtraDodge(guid)		--闪避率
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraDodge()
end

function ObjectInfoMgr:GetExtraHit(guid)			--命中
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraHit()
end

function ObjectInfoMgr:GetExtraAbsorbHeal(guid) --吸血
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraAbsorbHeal()
end

function ObjectInfoMgr:GetExtraIgnoreResist(guid) --忽视抗性
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraIgnoreResist()
end

function ObjectInfoMgr:GetExtraStrikeArmor(guid)  --护甲穿透
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraStrikeArmor()
end

function ObjectInfoMgr:GetExtraHealEnhance(guid)  --治疗效果提升
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraHealEnhance()
end

function ObjectInfoMgr:GetExtraCrit(guid)
	local player = ObjectMgr:GetPlayer( guid )
	assert(player,"nil player")
	return player:GetExtraCrit()
end



return ObjectInfoMgr