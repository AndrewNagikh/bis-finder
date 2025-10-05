local ADDON_NAME, ns = ...

-- Маппинг классов и специализаций для IcyVeins
-- Автоматически сгенерированный файл
-- Сгенерировано: 2025-10-05T18:44:30.359Z

ns.IcyVeinsClassSpecMapping = {
    WARRIOR = {
        tank = {
            "Protection Warrior"
        },
        dps = {
            "Fury Warrior",
            "Arms Warrior"
        },
        healer = {}
    },
    PALADIN = {
        tank = {
            "Protection Paladin"
        },
        dps = {
            "Retribution Paladin"
        },
        healer = {
            "Holy Paladin"
        }
    },
    MONK = {
        tank = {
            "Brewmaster Monk"
        },
        dps = {
            "Windwalker Monk"
        },
        healer = {
            "Mistweaver Monk"
        }
    },
    DEMONHUNTER = {
        tank = {
            "Vengeance Demon Hunter"
        },
        dps = {
            "Havoc Demon Hunter"
        },
        healer = {}
    },
    DRUID = {
        tank = {
            "Guardian Druid"
        },
        dps = {
            "Feral Druid",
            "Balance Druid"
        },
        healer = {
            "Restoration Druid"
        }
    },
    DEATHKNIGHT = {
        tank = {
            "Blood Death Knight"
        },
        dps = {
            "Frost Death Knight",
            "Unholy Death Knight"
        },
        healer = {}
    },
    HUNTER = {
        tank = {},
        dps = {
            "Beast Mastery Hunter",
            "Marksmanship Hunter",
            "Survival Hunter"
        },
        healer = {}
    },
    MAGE = {
        tank = {},
        dps = {
            "Arcane Mage",
            "Frost Mage",
            "Fire Mage"
        },
        healer = {}
    },
    SHAMAN = {
        tank = {},
        dps = {
            "Elemental Shaman",
            "Enhancement Shaman"
        },
        healer = {
            "Restoration Shaman"
        }
    },
    WARLOCK = {
        tank = {},
        dps = {
            "Destruction Warlock",
            "Demonology Warlock",
            "Affliction Warlock"
        },
        healer = {}
    },
    ROGUE = {
        tank = {},
        dps = {
            "Subtlety Rogue",
            "Assassination Rogue",
            "Outlaw Rogue"
        },
        healer = {}
    },
    EVOKER = {
        tank = {},
        dps = {
            "Devastation Evoker",
            "Augmentation Evoker"
        },
        healer = {
            "Preservation Evoker"
        }
    },
    PRIEST = {
        tank = {},
        dps = {
            "Shadow Priest"
        },
        healer = {
            "Discipline Priest",
            "Holy Priest"
        }
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