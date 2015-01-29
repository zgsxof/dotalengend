require("framework.dbc.DBCStores")

LocaleUnitEntry = 
{
	filename = "config/locale_unit.csv",
	fmt = "nssssssssssssssssssssssss",
	[1] = "id",
	[2] = Array("name",8,""),
	[3] = Array("desc",8,""),
	[4] = Array("tag",8,""),
}

LocaleItemEntry =
{
	filename = "config/locales_item.csv",
	fmt = "nsssssssssssssssss",
	[1] = "id",
	[2] = Array("name",8,""),
	[3] = Array("desc",8,""),
	[4] = "statDesc",
}

SpellChainEntry = 
{
	filename = "config/spellchain.csv",
	fmt = "niiiii",
	[1]		 = "id",
	[2]		 = "first",
	[3]		 = "prev",
	[4]		 = "next",
	[5]		 = "rank",
	[6]		 = "reqLv",	
}

SpellEntry = 
{
	filename = "config/spell.csv",
	--filename = "dbc/spell.dbc",
	fmt 	 = "issiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiss",
	[1]		 = "id",
	[2]		 = "name",
	[3]		 = "description",
	[4]		 = "Attributes",
	[5]		=  "level",
	[6]		= "castTime", --咏唱时间（即前摇时间）
	[7]		= "duration", --技能持续时间
	[8]		= "targetMask",
	[9]		=  Array("Effects",3,""),
	[10]	= Array("EffectImplicitTargetA",3,""),
	[11]	= Array("EffectRadius",3,""),
	[12]	= "DmgClass",
	[13]    = "ExtraDamage",
	[14]	= "speed",
	[15]	= Array("EffectApplyAuraName",3,""),
	[16]	= Array("EffectAmplitude",3,""),
	[17]	= Array("EffectBaseValue",3,""), 
	[18]	= Array("EffectMiscValue",3,""), 
	[19]	= "visual",
	[20]	= "action",
	[21]	= "icon"
}

LocaleSpellEntry = 
{
	filename = "config/locales_spell.csv",
	fmt		 = "nssssssssssssssss",
	[1]		 = "id",
	[2]		 = Array("name", 8, ""),
	[3]		 = Array("desc", 8, ""),
}

BattlePosInfoEntry = 
{
	filename = "config/battle_pos_info.csv",
	--filename = "dbc/battle_pos_info.dbc",
	fmt 	 = "nff",
	[1]		= "id",
	[2]		= "PosX",
	[3]		= "PosY",
}


SpellVisualEffect =
{
	filename = "config/spellvisualeffect.csv",
	--filename = "dbc/SpellVisualEffect.dbc",
	fmt 	 = "nsssssbiiiiiiiiii",
	[1]  = "id",
	[2]	 = Array("VisualEffects",5,""),		-- 施放成功时的特效,打击到目标的特效,buff特效，区域特效,飞行特效
	[3]  = Array("m_attachPos",5,""),				--绑定到哪个骨骼点
	[4]  = Array("m_flags",5,""),					
}

PlayerInfoEntry = 
{
	filename = "config/playerinfo.csv",
	--filename = "dbc/SpellVisualEffect.dbc",
	fmt 	 = "nssifiiiiiiiiiiiiiiiis",
	[1]  = "class",
	[2]  = "name",
	[3]	 = "desc",
	[4]	 = "gender",
	[5]  = "range",
	[6]  = "strength",
	[7]  = "agile",
	[8]	 = "intelligence",
	[9]	 = "hp",
	[10] = "rage",
	[11] = "attack",
	[12] = "power",
	[13] = "armor",
	[14] = "resist",
	[15] = "crit",
	[16] = "speed",
	[17] = Array("spell",5,""),
	[18] = "spellseq",
}

CreatureInfoEntry = 
{
	filename = "config/creatureinfo.csv",
	--filename = "dbc/SpellVisualEffect.dbc",
	fmt 	 = "niifiiiiiiiiiiiiiiiis",
	[1]  = "id",
	[2]  = "class",
	[3]	 = "gender",
	[4]  = "range",
	[5]  = "strength",
	[6]  = "agile",
	[7]	 = "intelligence",
	[8]	 = "hp",
	[9]	 = "rage",
	[10] = "attack",
	[11] = "power",
	[12] = "armor",
	[13] = "resist",
	[14] = "crit",
	[15] = "speed",
	[16] = Array("spell",5,""),
	[17] = "spellseq",
}

DisplayInfoEntry = 
{
	filename = "config/displayinfo.csv",
	fmt 	 = "nssss",
	[1]  = "id",
	[2]	 = "pngPath",
	[3]  = "plistPath",
	[4]  = "xmlPath",
	[5]  = "icon",

}

SceneInfoEntry = 
{
	filename = "config/sceneinfo.csv",
	fmt 	 = "niissiii",
	[1]  = "id",
	[2]	 = "group",	
	[3]	 = "rank",
	[4]	 = "name",
	[5]	 = "desc",
	[6] = Array("chapter",5,""),
}

ChapterInfoEntry = 
{
	filename = "config/chapter_info.csv",
	fmt 	 = "niiiiiiiiiiii",
	[1]  = "id",
	[2]	 = "sceneId",	
	[3] = Array("creatureId",5,""),
	[4]  = "mapId",
}

RandomNameEntry = 
{
	filename = "config/random_name.csv",
	fmt		 = "ns",
	[1]		 = "id",
	[2]		 = "name",
}

ItemIntensifyInfoEntry = 
{
	filename = "config/item_intensify_info.csv",
	fmt		 = "niiiii",
	[1]		 = "firstId",	-- 未强化的装备的id
	[2]		 = "rank",		-- 强化等级
	[3]		 = "itemId",	-- 强化等级为rank的物品id
	[4]		 = "money",		-- 强化所需金钱
	[5]		 = "cd",		-- 强化带来的cd，单位：秒
	[6]		 = "priority",	-- 客户端显示锦囊的顺序，0表示装备，非0表示锦囊
}

ItemRecipeInfoEntry = 
{
	filename = "config/item_recipe_info.csv",
	fmt		 = "niiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",
	[1]		 = "itemId",				-- 合成源物品,必须填强化等级为0的id
	[2]		 = "createItemId",			-- 合成的目标物品,必须填强化等级为0的id
	[3]		 = "mustRequire_1",			-- 必须需要的物品id_1
	[4]		 = "mustRequireCount_1",	-- 必须需要的物品数量_1
	[5]		 = "mustRequire_2",			-- 必须需要的物品id_2
	[6]		 = "mustRequireCount_2",	-- 必须需要的物品数量_2
	[7]		 = "mustRequire_3",			-- 必须需要的物品id_3
	[8]		 = "mustRequireCount_3",	-- 必须需要的物品数量_3
	[9]		 = "require_1",				-- 合成需要的物品id_1
	[10]	 = "count_1",				-- 合成需要的物品id_1对应的数量
	[11]	 = "exchange_1",			-- 表示每缺少一个物品1,则需要多少元宝
	[12]	 = "require_2",				-- 合成需要的物品id_2
	[13]	 = "count_2",				-- 合成需要的物品id_2对应的数量
	[14]	 = "exchange_2",			-- 表示每缺少一个物品2,则需要多少元宝
	[15]	 = "require_3",				-- 合成需要的物品id_3
	[16]	 = "count_3",				-- 合成需要的物品id_3对应的数量
	[17]	 = "exchange_3",			-- 表示每缺少一个物品3,则需要多少元宝
	[18]	 = "require_4",				-- 合成需要的物品id_4
	[19]	 = "count_4",				-- 合成需要的物品id_4对应的数量
	[20]	 = "exchange_4",			-- 表示每缺少一个物品4,则需要多少元宝
	[21]	 = "require_5",				-- 合成需要的物品id_5
	[22]	 = "count_5",				-- 合成需要的物品id_5对应的数量
	[23]	 = "exchange_5",			-- 表示每缺少一个物品5,则需要多少元宝
	[24]	 = "require_6",				-- 合成需要的物品id_6
	[25]	 = "count_6",				-- 合成需要的物品id_6对应的数量
	[26]	 = "exchange_6",			-- 表示每缺少一个物品6,则需要多少元宝
	[27]	 = "require_7",				-- 合成需要的物品id_7
	[28]	 = "count_7",				-- 合成需要的物品id_7对应的数量
	[29]	 = "exchange_7",			-- 表示每缺少一个物品7,则需要多少元宝
	[30]	 = "require_8",				-- 合成需要的物品id_8
	[31]	 = "count_8",				-- 合成需要的物品id_8对应的数量
	[32]	 = "exchange_8",			-- 表示每缺少一个物品8,则需要多少元宝
}

ItemEntry = 
{
	filename	= "config/item.csv",
	fmt			= "nsiiiiiiiiiiiiiiiiiiiii",
	[1]			= "itemId",	
	[2]			= "displayImgPath",		-- 物品外观的路径
	[3]			= "class",				-- 类别
	[4]			= "quality",			-- 品质
	[5]			= "level",				-- 物品等级
	[6]			= "nextId",				-- 强化到下一级的物品的Id
	[7]			= "reqLv",				-- 需要的等级
	[8]			= "strength",			-- 力量
	[9]			= "agility",			-- 敏捷
	[10]		= "intellgence",		-- 智力
	[11]		= "magicpower",			-- 魔法强度
	[12]		= "attackdmg",			-- 物理攻击
	[13]		= "armor",				-- 物理护甲
	[14]		= "resist",				-- 魔法抗性
	[15]		= "hp",					-- 生命值
	[16]		= "absortHeal",			-- 吸血等级
	[17]		= "healEnhance",		-- 治疗效果提升
	[18]		= "speed",				-- 攻速
	[19]		= "buyCoin",			-- 购买金币
	[20]		= "sellCoin",			-- 出售金币
	[21]		= "buyDiamond",			-- 购买钻石
	[22]		= "sellDiamond",		-- 出售钻石
	[23]		= "maxcount",			-- 最多拥有个数
}