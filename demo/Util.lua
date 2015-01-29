

MAX_BATTLE_CHAR_NUM = 5

OFFENCE_INIT_POS_BEGIN = 0;
OFFENCE_MOVETO_POS_BEGIN = 15;
DEFENCE_INIT_POS_BEGIN = 30;
DEFENCE_MOVETO_POS_BEGIN = 45;

SpellAttributes = 
{
	ultimate	= 0x01, --大招
	auto  		= 0x02,	--自动技能
	melee 		= 0x04, --普攻
	passive		= 0x08, --被动技能（战场外释放）
	use_enter_battle = 0x10,	--光环类技能，一进入战场就释放
}

PlayerList = 
{
	[1] = 4, --第一个我方英雄是classid为1的英雄
	--[2] = 4,
}

CreatureList = 
{
	[1] = 4, --第一个怪物是classid为2的怪物
}

function HasSpellAttribute( spellinfo,attr )
	if band(spellinfo.Attributes, attr) ~= 0 then
		return true
	else
		return false
	end
end

function MakeCreatureData(id)
	local data = {}
	local entry = sCreatureInfoStore[id]
	assert(entry)
	data._objSize = 80
	data._class = entry.class
	data._spellIds = entry.spell
	data._hp = entry.hp
	data._phy_dmg = entry.attack
	data._magic_dmg = entry.power
	data._armor = entry.armor
	data._resis = entry.resist
	data._crit = entry.crit
	data._power = entry.power
	data._attackrange = entry.range
	data._moveSpeed = entry.speed
	data._attackType = 0
	data._attacktime = {4,4}
	data._attacktimer = {0,0}
	data._spellseq = {}
	local seq = entry.spellseq
    local tmp = string.split(seq, ";")
    for i = 1,#tmp do
    	data._spellseq[i] = tonumber(tmp[i])
    	cclog("creature spell seq "..i..":"..tmp[i])
	end

	data._absorbHeal = 0
	data._ignoreResist = 0
	data._strikeArmor = 0
	data._healEnhance = 0   

	return data
end

function ObjectObjectRelocationWorker( obj1,obj2 )
	--obj没失控的话。。。此判断以后再加
	if obj1:AI() then
		obj1:AI():MoveInLineOfSight(obj2)
	end

	if obj2:AI() then
		obj2:AI():MoveInLineOfSight(obj1)
	end
end

--[[--

如果对象是指定类或其子类的实例，返回 true，否则返回 false

~~~ lua

local Animal = class("Animal")
local Duck = class("Duck", Animal)

print(iskindof(Duck.new(), "Animal")) -- 输出 true

~~~

@param mixed obj 要检查的对象
@param string classname 类名

@return boolean

]]
function iskindof(obj, classname)
    local t = type(obj)
    local mt
    if t == "table" then
        mt = getmetatable(obj)
    elseif t == "userdata" then
        mt = tolua.getpeer(obj)
    end

    while mt do
        if mt.__cname == classname then
            return true
        end
        mt = mt.super
    end

    return false
end

function AdjustContent( node )
	if node then
	 	local size = sharedDirector:getOpenGLView():getFrameSize()
        node:setScaleX(node:getScaleX() * size.width/node:getContentSize().width);
        node:setScaleY(node:getScaleY() * size.height/node:getContentSize().height);
    end
end