
local dbcloader = import(".CSVLoader")
sSpellEntryStore = dbcloader.load(SpellEntry)
sSpellEffectStore = dbcloader.load( SpellVisualEffect )
sBattlePosInfoStore = dbcloader.load( BattlePosInfoEntry )
sPlayerInfoStore = dbcloader.load( PlayerInfoEntry )
sDisplayInfoStore = dbcloader.load( DisplayInfoEntry )
sSceneInfoStore = dbcloader.load( SceneInfoEntry )
sChapterInfoStore = dbcloader.load( ChapterInfoEntry )
sCreatureInfoStore = dbcloader.load( CreatureInfoEntry )
sSpellChainStore = dbcloader.load(SpellChainEntry)
sLocaleUnitStore = dbcloader.load(LocaleUnitEntry)
sRandomNameStore = dbcloader.load(RandomNameEntry)
sLocaleSpellStore = dbcloader.load(LocaleSpellEntry)
sLocaleItemStore = dbcloader.load(LocaleItemEntry)
sItemIntensifyInfoStore = dbcloader.load(ItemIntensifyInfoEntry)
G_ItemIntensifyChain = {}
G_ItemFirstIntensify = {}
--[[
tbItemIntensifyInfoStore = tbItemIntensifyInfoStore or {}	-- 全局表，存放物品强化信息
local sItemIntensifyInfoStore = dbcloader.load(ItemIntensifyInfoEntry)
if sItemIntensifyInfoStore then
	for k,v in pairs(sItemIntensifyInfoStore) do
		tbItemIntensifyInfoStore[k] = v
	end
end]]

tbItemRecipeInfoStore = tbItemRecipeInfoStore or {}			-- 全局表，存放物品升级信息
local sItemRecipeInfoStore = dbcloader.load(ItemRecipeInfoEntry)
if sItemRecipeInfoStore then
	for k,v in pairs(sItemRecipeInfoStore) do
		tbItemRecipeInfoStore[k] = v
	end
end

tbLocaleItemStore = tbLocaleItemStore or {}					-- 全局表，存放多语言下的物品的普通信息
if sLocaleItemStore then 
	for k,v in pairs(sLocaleItemStore) do
		tbLocaleItemStore[k] = v
		tbLocaleItemStore[k]._statDesc = string.split(v.statDesc, ";")
	end
end

tbItemStore = tbItemStore or {}
local sItemStore = dbcloader.load(ItemEntry)
if sItemStore then 
	for k,v in pairs(sItemStore) do
		tbItemStore[k] = v
	end
end

function LoadItemIntensify()
	--[[
	for k,v in pairs(sItemIntensifyInfoStore) do
		local t = clone(v)
		assert(G_ItemFirstIntensify[t.itemId],string.format("LoadItemIntensify-3, Item id %d repeat!",t.itemId))
		--assert(G_ItemIntensifyChain[t.firstId],string.format())
		G_ItemIntensifyChain[t.firstId] = {rank = t.rank,itemId = t.itemId}
		G_ItemFirstIntensify[t.itemId] = t
	end]]
end

function GetLocaleUnitEntry( id )
	for k,v in pairs(sLocaleUnitStore) do
		local pEntry = sLocaleUnitStore[k]
		if pEntry and pEntry.id == spellId then
			return pEntry
		end
	end

	return nil
end

function GetSpellChainEntry( spellId )
	for k,v in pairs(sSpellChainStore) do
		local pEntry = sSpellChainStore[k]
		if pEntry and pEntry.id == spellId then
			return pEntry
		end
	end

	return nil
end

function GetSpellEntry(spellId)
	for k,v in pairs(sSpellEntryStore) do
		local pEntry = sSpellEntryStore[k]
		if pEntry and pEntry.id == spellId then
			return pEntry
		end
	end

	return nil
end

function GetSpellIconPath( spellId )
	local entry = sSpellEntryStore[spellId]
	if entry then
		return entry.icon
	end

	return "spellicon/101.png"
end

function GetSpellName( spellId, languageId )
	local entry = sLocaleSpellStore[spellId]
	if entry then
		return entry.name[languageId-1]
	else
		return nil
	end
end

function GetSpellDesc( spellId, languageId )
	local entry = sLocaleSpellStore[spellId]
	if entry then 
		return entry.desc[languageId-1]
	else
		return nil
	end
end

function GetSpellVisualEntry( id )
	for k,v in pairs(sSpellVisualStore) do
		local pEntry = sSpellVisualStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetSpellVisualKitEntry( id )
	for k,v in pairs(sSpellVisualKitStore) do
		local pEntry = sSpellVisualKitStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetSpellEffectEntry( id )
	for k,v in pairs(sSpellEffectStore) do
		local pEntry = sSpellEffectStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetBattlePosInfoEntry( id )
	for k,v in pairs(sBattlePosInfoStore) do
		local pEntry = sBattlePosInfoStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetPlayerInfoEntry( id )
	for k,v in pairs(sPlayerInfoStore) do
		local pEntry = sPlayerInfoStore[k]
		if pEntry and pEntry.class == id then
			return pEntry
		end
	end

	return nil
end

function GetDisplayInfoEntry( id )
	for k,v in pairs(sDisplayInfoStore) do
		local pEntry = sDisplayInfoStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetSceneInfoEntry( id )
	for k,v in pairs(sSceneInfoStore) do
		local pEntry = sSceneInfoStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetChapterInfoEntry( id )
	for k,v in pairs(sChapterInfoStore) do
		local pEntry = sChapterInfoStore[k]
		if pEntry and pEntry.id == id then
			return pEntry
		end
	end

	return nil
end

function GetCreatureInfoEntry( id )
	for k,v in pairs(sCreatureInfoStore) do
		local pEntry = sCreatureInfoStore[k]
		if pEntry and pEntry.class == id then
			return pEntry
		end
	end

	return nil
end

function GetRandomName(  )
	math.newrandomseed()
	local size = #sRandomNameStore
	local num = math.random(1,size)
	local pEntry = sRandomNameStore[num]
	if pEntry and pEntry.name then
		return pEntry.name
	end
end

function GetEquipName( id, languageId )
	local entry = sLocaleItemStore[id]
	if entry then 
		return entry.name[languageId-1]
	else
		return nil
	end
end

function GetEquipDesc( id, languageId )
	local entry = sLocaleItemStore[id]
	if entry then 
		return entry.desc[languageId-1]
	else
		return nil
	end
end

function GetItemIntensifyInfo( itemId )
	local entry = tbItemIntensifyInfoStore[itemId]
	return entry
end

function GetItemRecipeInfo( itemId )
	local entry = tbItemRecipeInfoStore[itemId]
	return entry
end