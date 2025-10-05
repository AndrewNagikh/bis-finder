local ADDON_NAME, ns = ...

-- Маппинг классов и специализаций для IcyVeins
-- Создан на основе данных из IcyVeinsData.lua

ns.IcyVeinsClassSpecMapping = {
    ["Warrior"] = {
        tank = {"Protection Warrior"},
        dps = {"Fury Warrior", "Arms Warrior"}
    },
    ["Paladin"] = {
        tank = {"Protection Paladin"},
        dps = {"Retribution Paladin"},
        healer = {"Holy Paladin"}
    },
    ["Hunter"] = {
        dps = {"Beast Mastery Hunter", "Marksmanship Hunter", "Survival Hunter"}
    },
    ["Rogue"] = {
        dps = {"Subtlety Rogue", "Assassination Rogue", "Outlaw Rogue"}
    },
    ["Priest"] = {
        dps = {"Shadow Priest"},
        healer = {"Holy Priest", "Discipline Priest"}
    },
    ["Death Knight"] = {
        tank = {"Blood Death Knight"},
        dps = {"Frost Death Knight", "Unholy Death Knight"}
    },
    ["Shaman"] = {
        dps = {"Elemental Shaman", "Enhancement Shaman"},
        healer = {"Restoration Shaman"}
    },
    ["Mage"] = {
        dps = {"Arcane Mage", "Fire Mage", "Frost Mage"}
    },
    ["Warlock"] = {
        dps = {"Destruction Warlock", "Affliction Warlock", "Demonology Warlock"}
    },
    ["Monk"] = {
        tank = {"Brewmaster Monk"},
        dps = {"Windwalker Monk"},
        healer = {"Mistweaver Monk"}
    },
    ["Druid"] = {
        tank = {"Guardian Druid"},
        dps = {"Balance Druid", "Feral Druid"},
        healer = {"Restoration Druid"}
    },
    ["Demon Hunter"] = {
        tank = {"Vengeance Demon Hunter"},
        dps = {"Havoc Demon Hunter"}
    },
    ["Evoker"] = {
        dps = {"Devastation Evoker"},
        healer = {"Preservation Evoker"}
    }
}

-- Функция получения доступных специализаций для класса и роли
function ns:GetAvailableSpecs(className, role)
    if ns.IcyVeinsClassSpecMapping and ns.IcyVeinsClassSpecMapping[className] and ns.IcyVeinsClassSpecMapping[className][role] then
        return ns.IcyVeinsClassSpecMapping[className][role]
    end
    return {}
end

-- Функция получения всех доступных ролей для класса
function ns:GetAvailableRoles(className)
    if not ns.IcyVeinsClassSpecMapping or not ns.IcyVeinsClassSpecMapping[className] then
        return {}
    end
    
    local roles = {}
    for role, specs in pairs(ns.IcyVeinsClassSpecMapping[className]) do
        if #specs > 0 then
            table.insert(roles, role)
        end
    end
    return roles
end

-- Функция получения всех классов
function ns:GetAllClasses()
    if not ns.IcyVeinsClassSpecMapping then
        return {}
    end
    
    local classes = {}
    for className, _ in pairs(ns.IcyVeinsClassSpecMapping) do
        table.insert(classes, className)
    end
    return classes
end

-- Функция проверки, поддерживает ли класс роль
function ns:ClassSupportsRole(className, role)
    local specs = self:GetAvailableSpecs(className, role)
    return #specs > 0
end