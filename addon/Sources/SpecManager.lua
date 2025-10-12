local ADDON_NAME, ns = ...

ns.specMap = {
    tank = {
        -- Массив для сохранения порядка
        order = {
            73, 66, 268, 581, 104, 250
        },
        -- Данные специализаций
        [73] = { -- Protection Warrior
            name = "Protection Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\ProtectionWarrior.png"
        },
        [66] = { -- Protection Paladin
            name = "Protection Paladin", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\ProtectionPaladin.png"
        },
        [268] = { -- Brewmaster Monk
            name = "Brewmaster Monk", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\BrewmasterMonk.png"
        },
        [581] = { -- Vengeance Demon Hunter
            name = "Vengeance Demon Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\VengeanceDemonHunter.png"
        },
        [104] = { -- Guardian Druid
            name = "Guardian Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\GuardianDruid.png"
        },
        [250] = { -- Blood Death Knight
            name = "Blood Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\BloodDeathKnight.png"
        }
    },

    dps = {
        -- Массив для сохранения порядка
        order = {
            253, 254, 255, 577, 251, 252, 62, 64, 63, 262, 263, 267, 266, 265, 261, 259, 260, 72, 71, 70, 103, 102, 1467, 1473, 258, 269
        },
        -- Данные специализаций
        [253] = { -- Beast Mastery Hunter
            name = "Beast Mastery Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\BeastMasteryHunter.png"
        },
        [254] = { -- Marksmanship Hunter
            name = "Marksmanship Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\MarksmanshipHunter.png"
        },
        [255] = { -- Survival Hunter
            name = "Survival Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\SurvivalHunter.png"
        },
        [577] = { -- Havoc Demon Hunter
            name = "Havoc Demon Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\HavocDemonHunter.png"
        },
        [251] = { -- Frost Death Knight
            name = "Frost Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FrostDeathKnight.png"
        },
        [252] = { -- Unholy Death Knight
            name = "Unholy Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\UnholyDeathKnight.png"
        },
        [62] = { -- Arcane Mage
            name = "Arcane Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ArcaneMage.png"
        },
        [64] = { -- Frost Mage
            name = "Frost Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FrostMage.png"
        },
        [63] = { -- Fire Mage
            name = "Fire Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FireMage.png"
        },
        [262] = { -- Elemental Shaman
            name = "Elemental Shaman", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ElementalShaman.png"
        },
        [263] = { -- Enhancement Shaman
            name = "Enhancement Shaman", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\EnhancementShaman.png"
        },
        [267] = { -- Destruction Warlock
            name = "Destruction Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DestructionWarlock.png"
        },
        [266] = { -- Demonology Warlock
            name = "Demonology Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DemonologyWarlock.png"
        },
        [265] = { -- Affliction Warlock
            name = "Affliction Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AfflictionWarlock.png"
        },
        [261] = { -- Subtlety Rogue
            name = "Subtlety Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\SubtletyRogue.png"
        },
        [259] = { -- Assassination Rogue
            name = "Assassination Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AssassinationRogue.png"
        },
        [260] = { -- Outlaw Rogue
            name = "Outlaw Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\OutlawRogue.png"
        },
        [72] = { -- Fury Warrior
            name = "Fury Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FuryWarrior.png"
        },
        [71] = { -- Arms Warrior
            name = "Arms Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ArmsWarrior.png"
        },
        [70] = { -- Retribution Paladin
            name = "Retribution Paladin", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\RetributionPaladin.png"
        },
        [103] = { -- Feral Druid
            name = "Feral Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FeralDruid.png"
        },
        [102] = { -- Balance Druid
            name = "Balance Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\BalanceDruid.png"
        },
        [1467] = { -- Devastation Evoker
            name = "Devastation Evoker", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DevastationEvoker.png"
        },
        [1473] = { -- Augmentation Evoker
            name = "Augmentation Evoker", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AugmentationEvoker.png"
        },
        [258] = { -- Shadow Priest
            name = "Shadow Priest", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ShadowPriest.png"
        },
        [269] = { -- Windwalker Monk
            name = "Windwalker Monk", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\WindwalkerMonk.png"
        },
    },

    healer = {
        -- Массив для сохранения порядка
        order = {
            105, 264, 256, 257, 65, 1468, 270
        },
        -- Данные специализаций
        [105] = { -- Restoration Druid
            name = "Restoration Druid",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\RestorationDruid.png"
        },
        [264] = { -- Restoration Shaman
            name = "Restoration Shaman",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\RestorationShaman.png"
        },
        [256] = { -- Discipline Priest
            name = "Discipline Priest",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\DisciplinePriest.png"
        },
        [257] = { -- Holy Priest
            name = "Holy Priest",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\HolyPriest.png"
        },
        [65] = { -- Holy Paladin
            name = "Holy Paladin",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\HolyPaladin.png"
        },
        [1468] = { -- Preservation Evoker
            name = "Preservation Evoker",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\PreservationEvoker.png"
        },
        [270] = { -- Mistweaver Monk
            name = "Mistweaver Monk",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\MistweaverMonk.png"
        }
    }
}

ns.selectedSpeceId = "icyveins"

function ns:UpdateSelectedSpecId(spec)
    -- Сохраняем выбранный id
    ns.selectedSpeceId = spec
end

function ns:GetSelectedSpecId()
    return ns.selectedSpeceId
end