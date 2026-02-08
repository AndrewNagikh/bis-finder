local ADDON_NAME, ns = ...

local isRaid = true
local isDungeon = false

-- Инициализация таблицы данных о луте
if not ns.RaidLootData then
    ns.RaidLootData = {}
end

-- Функция для извлечения itemID из lootInfo
local function GetItemID(lootInfo)
    if lootInfo.itemID then
        return lootInfo.itemID
    elseif lootInfo.link then
        local itemIDMatch = lootInfo.link:match("item:(%d+)")
        return itemIDMatch and tonumber(itemIDMatch) or nil
    end
    return nil
end

-- Функция для обработки лута одного босса
local function ProcessBossLoot(bossName, bossLink, instanceName, isDungeon, journalEncounterID, instanceID)
    EJ_ResetLootFilter()
    EJ_SetLootFilter(0, 0)
    
    local numLoot = EJ_GetNumLoot()
    for lootIndex = 1, numLoot do
        local lootInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
        if lootInfo then
            local itemID = GetItemID(lootInfo)
            if itemID then
                if not ns.RaidLootData[itemID] then
                    ns.RaidLootData[itemID] = {}
                end
                ns.RaidLootData[itemID].journalEncounterID = journalEncounterID
                ns.RaidLootData[itemID].instanceID = instanceID
                -- Сохраняем данные о рейде или подземелье
                if isDungeon then
                    -- Подземелье
                    ns.RaidLootData[itemID].dungeonName = instanceName
                    ns.RaidLootData[itemID].dungeonBoss = bossName
                    ns.RaidLootData[itemID].dungeonLink = bossLink
                else
                    -- Рейд
                    ns.RaidLootData[itemID].raidName = instanceName
                    ns.RaidLootData[itemID].bossName = bossName
                    ns.RaidLootData[itemID].raidLink = bossLink
                end
            end
        end
    end
end

-- Функция для обработки всех боссов в инстансе
local function ProcessInstanceBosses(instanceID, instanceName, isDungeonInstance)
    EJ_SelectInstance(instanceID)
    
    for i = 1, 100 do
        local name, description, journalEncounterID, rootSectionID, link = EJ_GetEncounterInfoByIndex(i)
        if not name then
            break
        end
        
        EJ_SelectEncounter(journalEncounterID)
        ProcessBossLoot(name, link, instanceName, isDungeonInstance, journalEncounterID, instanceID)
    end
end

function GetRaid()
    local lastRaidID, lastRaidName
    for i = 1, 20 do
        local id, name = EJ_GetInstanceByIndex(i, isRaid)
        if id then
            lastRaidID, lastRaidName = id, name
        else
            break
        end
    end
    return lastRaidID, lastRaidName
end

function GetDungeons()
    local dungeons = {}
    for i = 1, 20 do
        local id, name = EJ_GetInstanceByIndex(i, isDungeon)
        if not id then
            break
        end
        table.insert(dungeons, { id = id, name = name })
    end
    return dungeons
end

function ProcessBossesLootRaid()
    local lastRaidID, lastRaidName = GetRaid()
    if lastRaidID then
        ProcessInstanceBosses(lastRaidID, lastRaidName, false)
    end
end

function ProcessBossesLootDungeon()
    local dungeons = GetDungeons()
    for _, dungeon in ipairs(dungeons) do
        ProcessInstanceBosses(dungeon.id, dungeon.name, true)
    end
end

-- Индекс тира "Текущий сезон" в выпадающем списке Encounter Journal
local CURRENT_SEASON_TIER = 13

-- Возвращает последний валидный индекс тира (запасной вариант, если 13 ещё недоступен)
local function GetLatestTierIndex()
    local lastValid = 1
    for t = 1, 20 do
        local ok = pcall(EJ_SelectTier, t)
        if ok then
            lastValid = t
        else
            break
        end
    end
    return lastValid
end

function ns:ProcessLoot()
    if UnitLevel("player") >= 10 then
        local ok = pcall(EJ_SelectTier, CURRENT_SEASON_TIER)
        if not ok then
            -- Тир 13 может быть недоступен до полной загрузки Journal — используем последний валидный
            local fallback = GetLatestTierIndex()
            ok = pcall(EJ_SelectTier, fallback)
        end
        if ok then
            ProcessBossesLootRaid()
            ProcessBossesLootDungeon()
        end
    end
end
