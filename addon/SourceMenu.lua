local ADDON_NAME, ns = ...

-- Модуль для бокового меню с выбором источников данных
local SourceMenu = {}
ns.SourceMenu = SourceMenu

-- Текущий выбранный источник
local currentSource = "IcyVeins"
local currentRole = "tank"
local currentClass = nil

-- Фрейм меню
local menuFrame = nil
local roleButtons = {}
local classButtons = {}

-- Callback для уведомления основного приложения об изменениях
local onChangeCallback = nil

-- Создание кнопки роли (минималистичный стиль)
local function CreateRoleButton(parent, role, x, y)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(180, 35)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    
    -- Фон кнопки в стиле Details!
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.22, 0.22, 0.22, 0.9) -- Темно-серый фон
    
    -- Текст роли
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetAllPoints()
    text:SetText(role:upper())
    text:SetTextColor(0.9, 0.9, 0.9)
    text:SetJustifyH("CENTER")
    text:SetFont(text:GetFont(), 12, "OUTLINE")
    
    -- Эффекты при наведении
    button:SetScript("OnEnter", function(self)
        bg:SetColorTexture(0.3, 0.3, 0.3, 0.95) -- Светлее при наведении
        text:SetTextColor(1, 1, 1) -- Белый текст при наведении
    end)
    
    button:SetScript("OnLeave", function(self)
        if currentRole == role then
            bg:SetColorTexture(0.8, 0.6, 0.2, 0.9) -- Желтый акцент для выбранной роли
        else
            bg:SetColorTexture(0.22, 0.22, 0.22, 0.9) -- Возвращаем исходный цвет
        end
        text:SetTextColor(0.9, 0.9, 0.9) -- Возвращаем исходный цвет текста
    end)
    
    -- Обработчик клика
    button:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            currentRole = role
            currentClass = nil
            SourceMenu:UpdateRoleSelection()
            SourceMenu:ShowClassSelection()
            
            -- Уведомляем основное приложение об изменении роли
            if onChangeCallback then
                onChangeCallback("role_changed", currentSource, currentRole, currentClass)
            end
        end
    end)
    
    return button
end

-- Создание заголовка источника (минималистичный стиль)
local function CreateSourceHeader(parent, sourceName, x, y)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    header:SetText(sourceName)
    header:SetTextColor(1, 1, 1) -- Белый текст как в Details!
    header:SetFont(header:GetFont(), 14, "OUTLINE")
    return header
end

-- Создание основного фрейма меню
function SourceMenu:CreateMenuFrame(parent)
    menuFrame = CreateFrame("Frame", nil, parent)
    menuFrame:SetSize(210, 650) -- Высота должна совпадать с правым окном
    menuFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -50) -- Отступ сверху для заголовка
    menuFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 5, 10) -- Отступ снизу для текста
    
    -- Фон меню в стиле Details!
    local bg = menuFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.18, 0.18, 0.18, 0.98) -- Темно-серый фон
    
    -- Добавляем рамку для бокового меню
    local border = menuFrame:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetColorTexture(0.25, 0.25, 0.25, 0.9) -- Светлее фона
    border:SetPoint("TOPLEFT", bg, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 2, -2)
    
    -- Заголовок IcyVeins
    local icyVeinsHeader = CreateSourceHeader(menuFrame, "IcyVeins", 10, -10)
    
    -- Кнопки ролей для IcyVeins
    local tankBtn = CreateRoleButton(menuFrame, "tank", 15, -40)
    local dpsBtn = CreateRoleButton(menuFrame, "dps", 15, -85)
    local healerBtn = CreateRoleButton(menuFrame, "healer", 15, -130)
    
    roleButtons = {
        tank = tankBtn,
        dps = dpsBtn,
        healer = healerBtn
    }
    
    -- Заголовок Archon (пока неактивный)
    local archonHeader = CreateSourceHeader(menuFrame, "Archon", 10, -170)
    archonHeader:SetTextColor(0.5, 0.5, 0.5)
    
    -- Кнопки ролей для Archon (пока неактивные)
    local archonTankBtn = CreateRoleButton(menuFrame, "tank", 15, -200)
    local archonDpsBtn = CreateRoleButton(menuFrame, "dps", 15, -240)
    local archonHealerBtn = CreateRoleButton(menuFrame, "healer", 15, -280)
    
    -- Делаем кнопки Archon неактивными
    archonTankBtn:SetEnabled(false)
    archonDpsBtn:SetEnabled(false)
    archonHealerBtn:SetEnabled(false)
    
    -- Обновляем выделение текущей роли
    self:UpdateRoleSelection()
    
    return menuFrame
end

-- Обновление выделения выбранной роли
function SourceMenu:UpdateRoleSelection()
    for role, button in pairs(roleButtons) do
        local bg = button:GetRegions()
        if currentRole == role then
            bg:SetColorTexture(0.1, 0.5, 0.1, 0.8)
        else
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        end
    end
end

-- Показать выбор классов (теперь вызывается из основного приложения)
function SourceMenu:ShowClassSelection()
    -- Уведомляем основное приложение о необходимости показать выбор классов
    if onChangeCallback then
        onChangeCallback("show_class_selection", currentSource, currentRole, currentClass)
    end
end

-- Обработчик выбора класса
function SourceMenu:OnClassSelected(className)
    currentClass = className
    
    -- Уведомляем основное приложение об изменении класса
    if onChangeCallback then
        onChangeCallback("class_selected", currentSource, currentRole, currentClass)
    end
end

-- Установить callback для уведомлений об изменениях
function SourceMenu:SetOnChangeCallback(callback)
    onChangeCallback = callback
end

-- Показать/скрыть меню
function SourceMenu:Toggle()
    if menuFrame then
        if menuFrame:IsShown() then
            menuFrame:Hide()
        else
            menuFrame:Show()
        end
    end
end

-- Получить текущий источник
function SourceMenu:GetCurrentSource()
    return currentSource
end

-- Получить текущую роль
function SourceMenu:GetCurrentRole()
    return currentRole
end

-- Получить текущий класс
function SourceMenu:GetCurrentClass()
    return currentClass
end

-- Установить текущий класс
function SourceMenu:SetCurrentClass(className)
    currentClass = className
end
