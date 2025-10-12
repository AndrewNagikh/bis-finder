local ADDON_NAME, ns = ...

ns.specMap = {
    tank = {
        -- Массив для сохранения порядка
        order = {
            "protectionwarrior", "protectionpaladin", "brewmastermonk", 
            "vengeancedemonhunter", "guardiandruid", "blooddeathknight"
        },
        -- Данные специализаций
        ["protectionwarrior"] = {
            name = "Protection Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\ProtectionWarrior.png"
        },
        ["protectionpaladin"] = {
            name = "Protection Paladin", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\ProtectionPaladin.png"
        },
        ["brewmastermonk"] = {
            name = "Brewmaster Monk", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\BrewmasterMonk.png"
        },
        ["vengeancedemonhunter"] = {
            name = "Vengeance Demon Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\VengeanceDemonHunter.png"
        },
        ["guardiandruid"] = {
            name = "Guardian Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\GuardianDruid.png"
        },
        ["blooddeathknight"] = {
            name = "Blood Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Tank\\BloodDeathKnight.png"
        }
    },

    dps = {
        -- Массив для сохранения порядка
        order = {
            "beastmasteryhunter", "marksmanshiphunter", "survivalhunter",
            "havocdemonhunter", "frostdeathknight", "unholydeathknight",
            "arcanemage", "frostmage", "firemage",
            "elementalshaman", "enhancementshaman",
            "destructionwarlock", "demonologywarlock", "afflictionwarlock",
            "subtletyrogue", "assassinationrogue", "outlawrogue",
            "furywarrior", "armswarrior",
            "retributionpaladin",
            "feraldruid", "balancedruid",
            "devastationevoker", "augmentationevoker",
            "shadowpriest",
            "windwalkermonk"
        },
        -- Данные специализаций
        ["beastmasteryhunter"] = { 
            name = "Beast Mastery Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\BeastMasteryHunter.png"
        },
        ["marksmanshiphunter"] = { 
            name = "Marksmanship Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\MarksmanshipHunter.png"
        },
        ["survivalhunter"] = { 
            name = "Survival Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\SurvivalHunter.png"
        },
        ["havocdemonhunter"] = { 
            name = "Havoc Demon Hunter", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\HavocDemonHunter.png"
        },
        ["frostdeathknight"] = { 
            name = "Frost Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FrostDeathKnight.png"
        },
        ["unholydeathknight"] = { 
            name = "Unholy Death Knight", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\UnholyDeathKnight.png"
        },
        ["arcanemage"] = { 
            name = "Arcane Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ArcaneMage.png"
        },
        ["frostmage"] = { 
            name = "Frost Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FrostMage.png"
        },
        ["firemage"] = { 
            name = "Fire Mage", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FireMage.png"
        },
        ["elementalshaman"] = { 
            name = "Elemental Shaman", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ElementalShaman.png"
        },
        ["enhancementshaman"] = { 
            name = "Enhancement Shaman", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\EnhancementShaman.png"
        },
        ["destructionwarlock"] = { 
            name = "Destruction Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DestructionWarlock.png"
        },
        ["demonologywarlock"] = { 
            name = "Demonology Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DemonologyWarlock.png"
        },
        ["afflictionwarlock"] = { 
            name = "Affliction Warlock", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AfflictionWarlock.png"
        },
        ["subtletyrogue"] = { 
            name = "Subtlety Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\SubtletyRogue.png"
        },
        ["assassinationrogue"] = { 
            name = "Assassination Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AssassinationRogue.png"
        },
        ["outlawrogue"] = { 
            name = "Outlaw Rogue", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\OutlawRogue.png"
        },
        ["furywarrior"] = { 
            name = "Fury Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FuryWarrior.png"
        },
        ["armswarrior"] = { 
            name = "Arms Warrior", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ArmsWarrior.png"
        },
        ["retributionpaladin"] = { 
            name = "Retribution Paladin", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\RetributionPaladin.png"
        },
        ["feraldruid"] = { 
            name = "Feral Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\FeralDruid.png"
        },
        ["balancedruid"] = { 
            name = "Balance Druid", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\BalanceDruid.png"
        },
        ["devastationevoker"] = { 
            name = "Devastation Evoker", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\DevastationEvoker.png"
        },
        ["augmentationevoker"] = { 
            name = "Augmentation Evoker", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\AugmentationEvoker.png"
        },
        ["shadowpriest"] = { 
            name = "Shadow Priest", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\ShadowPriest.png"
        },
        ["windwalkermonk"] = { 
            name = "Windwalker Monk", 
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\DPS\\WindwalkerMonk.png"
        },
    },

    healer = {
        -- Массив для сохранения порядка
        order = {
            "restorationdruid", "restorationshaman", "disciplinepriest", 
            "holypriest", "holypaladin", "preservationevoker", "mistweavermonk"
        },
        -- Данные специализаций
        ["restorationdruid"] = {
            name = "Restoration Druid",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\RestorationDruid.png"
        },
        ["restorationshaman"] = {
            name = "Restoration Shaman",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\RestorationShaman.png"
        },
        ["disciplinepriest"] = {
            name = "Discipline Priest",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\DisciplinePriest.png"
        },
        ["holypriest"] = {
            name = "Holy Priest",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\HolyPriest.png"
        },
        ["holypaladin"] = {
            name = "Holy Paladin",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\HolyPaladin.png"
        },
        ["preservationevoker"] = {
            name = "Preservation Evoker",
            texture = "Interface\\AddOns\\BiSFinder\\Textures\\SpecButtons\\Healer\\PreservationEvoker.png"
        },
        ["mistweavermonk"] = {
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