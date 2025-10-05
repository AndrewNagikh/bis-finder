local ADDON_NAME, ns = ...

-- Цвета классов для кнопок
local CLASS_COLORS = {
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
    PALADIN = {r = 0.96, g = 0.55, b = 0.73},
    HUNTER = {r = 0.67, g = 0.83, b = 0.45},
    ROGUE = {r = 1.0, g = 0.96, b = 0.41},
    PRIEST = {r = 1.0, g = 1.0, b = 1.0},
    DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
    SHAMAN = {r = 0.0, g = 0.44, b = 0.87},
    MAGE = {r = 0.25, g = 0.78, b = 0.92},
    WARLOCK = {r = 0.53, g = 0.53, b = 0.93},
    MONK = {r = 0.0, g = 1.0, b = 0.59},
    DRUID = {r = 1.0, g = 0.49, b = 0.04},
    DEMONHUNTER = {r = 0.64, g = 0.19, b = 0.79},
    EVOKER = {r = 0.2, g = 0.58, b = 0.5}
}

-- Иконки классов
local CLASS_ICONS = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
    PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
    ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
    PRIEST = "Interface\\Icons\\ClassIcon_Priest",
    DEATHKNIGHT = "Interface\\Icons\\ClassIcon_DeathKnight",
    SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
    MAGE = "Interface\\Icons\\ClassIcon_Mage",
    WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    MONK = "Interface\\Icons\\ClassIcon_Monk",
    DRUID = "Interface\\Icons\\ClassIcon_Druid",
    DEMONHUNTER = "Interface\\Icons\\ClassIcon_DemonHunter",
    EVOKER = "Interface\\Icons\\ClassIcon_Evoker"
}

-- Локализованные названия классов
local CLASS_NAMES = {
    WARRIOR = "Warrior",
    PALADIN = "Paladin", 
    HUNTER = "Hunter",
    ROGUE = "Rogue",
    PRIEST = "Priest",
    DEATHKNIGHT = "Death Knight",
    SHAMAN = "Shaman",
    MAGE = "Mage",
    WARLOCK = "Warlock",
    MONK = "Monk",
    DRUID = "Druid",
    DEMONHUNTER = "Demon Hunter",
    EVOKER = "Evoker"
}

-- Функция для преобразования названия класса в ключ для CLASS_COLORS
local function getClassColorKey(className)
    local colorKey = className:upper():gsub(" ", "")
    return colorKey
end

-- Создание кнопки класса (минималистичный стиль с специализациями)
function ns:CreateClassButton(parent, className, role, specName, onClickCallback)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(280, 45) -- Увеличиваем ширину для более равномерного вида
    
    -- Получаем ключ для цвета класса
    local colorKey = getClassColorKey(className)
    
    -- Основной фон кнопки (минималистичный)
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local classColor = CLASS_COLORS[colorKey] or {r = 0.5, g = 0.5, b = 0.5} -- Fallback цвет
    bg:SetColorTexture(classColor.r * 0.3, classColor.g * 0.3, classColor.b * 0.3, 0.6)
    
    -- Иконка класса (слева)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(35, 35)
    icon:SetPoint("LEFT", button, "LEFT", 8, 0)
    local iconKey = getClassColorKey(className) -- Используем ту же функцию для преобразования
    icon:SetTexture(CLASS_ICONS[iconKey] or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Круглый фон для иконки (минималистичный)
    local iconBg = button:CreateTexture(nil, "BACKGROUND")
    iconBg:SetSize(37, 37)
    iconBg:SetPoint("CENTER", icon, "CENTER")
    iconBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    
    -- Используем переданное название специализации
    local specText = specName or CLASS_NAMES[className]
    
    -- Название специализации (справа от иконки)
    local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", icon, "RIGHT", 12, 0)
    nameText:SetPoint("RIGHT", button, "RIGHT", -10, 0) -- Добавляем правую границу для выравнивания
    nameText:SetText(specText)
    nameText:SetTextColor(0.9, 0.9, 0.9)
    nameText:SetFont(nameText:GetFont(), 13, "OUTLINE")
    nameText:SetJustifyH("LEFT") -- Выравнивание по левому краю
    
    -- Эффекты при наведении (минималистичные)
    button:SetScript("OnEnter", function(self)
        bg:SetColorTexture(classColor.r * 0.5, classColor.g * 0.5, classColor.b * 0.5, 0.8)
        nameText:SetTextColor(1, 1, 1)
    end)
    
    button:SetScript("OnLeave", function(self)
        bg:SetColorTexture(classColor.r * 0.3, classColor.g * 0.3, classColor.b * 0.3, 0.6)
        nameText:SetTextColor(0.9, 0.9, 0.9)
    end)
    
    -- Обработчик клика
    button:SetScript("OnClick", function(self, button)
        if button == "LeftButton" and onClickCallback then
            onClickCallback(className)
        end
    end)
    
    return button
end

-- Функция для получения цвета класса
function ns:GetClassColor(className)
    local colorKey = getClassColorKey(className)
    return CLASS_COLORS[colorKey] or {r = 0.5, g = 0.5, b = 0.5}
end

-- Функция для получения иконки класса
function ns:GetClassIcon(className)
    local iconKey = getClassColorKey(className)
    return CLASS_ICONS[iconKey] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Функция для получения названия класса
function ns:GetClassName(className)
    return CLASS_NAMES[className] or className
end
