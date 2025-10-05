-- BiSFinder Addon for World of Warcraft
-- Refactored to use external data from BiSFinderData.lua without changing existing logic

local ADDON_NAME, ns = ...

-- Модульная структура источников данных
-- Каждый источник данных находится в папке Sources/[SourceName]/
-- Основная логика остается в BiSFinder.lua

local BiSFinder = {}
ns.BiSFinder = BiSFinder

-- Local variables
local mainFrame
local sidebarFrame
local contentFrame
local contentTitle
local currentRole = "tank"
local currentSpec = nil
local currentClass = nil
local currentSource = "IcyVeins" -- Будет управляться через SourceManager
local currentScreen = "class_selection" -- "class_selection" или "items"

-- UI элементы для разных экранов
local classButtons = {}
local itemButtons = {}
local headerTexts = {}
local itemRows = {}

-- Get player class and spec
local function GetPlayerClassAndSpec()
    local _, playerClass = UnitClass("player")
    local specIndex = GetSpecialization()
    local specName = nil

    if specIndex then
        local id, name = GetSpecializationInfo(specIndex)
        if name then
            local roles = ns.SourceManager:GetAvailableRoles(playerClass)
            for _, role in ipairs(roles) do
                local specs = ns.SourceManager:GetAvailableSpecs(playerClass, role)
                for _, spec in ipairs(specs) do
                    if string.find(spec, name) then
                        specName = spec
                        currentRole = role
                        break
                    end
                end
                if specName then break end
            end
        end
    end

    return playerClass, specName
end

local function CreateSeparator(parent, x, y, width)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.5, 0.5, 0.5, 0.5) -- серый полупрозрачный цвет
    sep:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    sep:SetSize(width, 2) -- высота линии 2 пикселя
    return sep
end

-- Group items by type
local function GroupItemsByType(items)
    local grp, order = {}, {}
    for _, it in ipairs(items) do
        local t = it.itemType
        if string.match(t,"Ring #%d+") then t="Ring"
        elseif string.match(t,"Trinket #%d+") then t="Trinket" end
        if not grp[t] then
            grp[t] = {}
            table.insert(order, t)
        end
        table.insert(grp[t], it)
    end
    return grp, order
end

-- Clear UI of previous buttons and headers
local function ClearUI()
    for _,b in ipairs(itemButtons) do b:Hide() end; wipe(itemButtons)
    for _,h in ipairs(headerTexts) do h:Hide() end; wipe(headerTexts)
    for _,r in ipairs(itemRows) do r:Hide() end; wipe(itemRows)
    for _,b in ipairs(classButtons) do b:Hide() end; wipe(classButtons)
end

-- Объявляем функции заранее
local ShowItemsScreen

-- Показать экран выбора классов
local function ShowClassSelectionScreen()
    ClearUI()
    currentScreen = "class_selection"
    
    -- Получаем все классы
    local allClasses = ns.SourceManager:GetAllClasses()
    
    local yOffset = -60 -- Увеличиваем отступ сверху, чтобы кнопки не загораживали заголовок
    local buttonSpacing = 55
    
    -- Создаем кнопки для всех специализаций, которые поддерживают текущую роль
    local specCount = 0
    for i, className in ipairs(allClasses) do
        local specs = ns.SourceManager:GetAvailableSpecs(className, currentRole)
        for _, specName in ipairs(specs) do
            specCount = specCount + 1
            
            local specBtn = ns:CreateClassButton(contentFrame, className, currentRole, specName, function(selectedClass)
                currentClass = selectedClass
                currentScreen = "items"
                contentTitle:SetText("Items for " .. specName)
                currentSpec = specName
                ShowItemsScreen()
            end)
            
            specBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, yOffset)
            specBtn:Show()
            table.insert(classButtons, specBtn)
            yOffset = yOffset - buttonSpacing
        end
    end
    
    
    -- Устанавливаем высоту контентной области в зависимости от количества кнопок
    local totalHeight = math.max(650, math.abs(yOffset) + 50)
    contentFrame:SetHeight(totalHeight)
end

-- Показать экран с предметами
ShowItemsScreen = function()
    ClearUI()
    currentScreen = "items"
    
    -- Используем SourceManager для получения предметов
    local items = ns.SourceManager:GetItemsForSpec(currentSpec)

    if #items == 0 then
        local no = contentFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
        no:SetPoint("CENTER", contentFrame, "CENTER", 0, -50)
        no:SetText("No data for spec"); no:SetTextColor(1,0,0)
        table.insert(headerTexts, no)
        contentFrame:SetHeight(650)
        return
    end

    local grouped, order = GroupItemsByType(items)
    local x0, y0 = 20, -60 -- Увеличиваем отступ сверху для заголовка
    local rowHeight = 60 -- Высота строки (уменьшена, так как названия предметов убраны)
    local yOffset = y0

    -- Создаем строки для каждого типа предмета
    for i, itemType in ipairs(order) do
        local itemsOfType = grouped[itemType]
        local rowFrame = ns:CreateItemRow(contentFrame, itemType, itemsOfType, x0, yOffset)
        rowFrame:Show()
        table.insert(itemRows, rowFrame)
        
        yOffset = yOffset - rowHeight
    end

    -- Устанавливаем размер фрейма в зависимости от количества строк
    local totalHeight = math.max(650, math.abs(yOffset) + 100)
    contentFrame:SetHeight(totalHeight)
end

-- Обновить отображение в зависимости от текущего экрана
local function UpdateDisplay()
    if currentScreen == "class_selection" then
        ShowClassSelectionScreen()
    elseif currentScreen == "items" then
        ShowItemsScreen()
    end
end

-- Функция для переключения главного окна (для миникарты)
function BiSFinder:ToggleMainFrame()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        -- Инициализируем начальное состояние
        currentScreen = "class_selection"
        UpdateDisplay()
    end
end


-- Create main frame
local function CreateMainFrame()
    mainFrame = CreateFrame("Frame","BiSFinderMain",UIParent)
    mainFrame:SetSize(900,700); mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true); mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

    -- Создаем собственный фон в стиле Details!
    local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.15, 0.15, 0.15, 0.98) -- Темно-серый фон как в Details!
    
    -- Создаем собственную рамку
    local border = mainFrame:CreateTexture(nil, "BORDER")
    border:SetAllPoints()
    border:SetColorTexture(0.25, 0.25, 0.25, 0.9) -- Светлее фона для контраста
    border:SetPoint("TOPLEFT", bg, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 2, -2)

    mainFrame.title = mainFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    mainFrame.title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -15)
    mainFrame.title:SetText("BiSFinder")
    mainFrame.title:SetTextColor(1, 1, 1) -- Белый текст
    mainFrame.title:SetFont(mainFrame.title:GetFont(), 18, "OUTLINE")
    

    local closeButton = CreateFrame("Button", nil, mainFrame)
    closeButton:SetSize(25, 25)
    closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -8, -8)
    
    local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(0.2, 0.2, 0.2, 0.9) -- Темно-серый фон
    
    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetAllPoints()
    closeText:SetText("×")
    closeText:SetTextColor(1, 1, 1) -- Белый текст
    closeText:SetFont(closeText:GetFont(), 16, "OUTLINE")
    closeText:SetJustifyH("CENTER")
    
    closeButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            mainFrame:Hide()
        end
    end)
    
    closeButton:SetScript("OnEnter", function(self)
        closeBg:SetColorTexture(0.3, 0.3, 0.3, 0.9) -- Светлее при наведении
    end)
    
    closeButton:SetScript("OnLeave", function(self)
        closeBg:SetColorTexture(0.2, 0.2, 0.2, 0.9) -- Возвращаем исходный цвет
    end)

    local inst = mainFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    inst:SetPoint("BOTTOMLEFT",mainFrame,"BOTTOMLEFT",10,10)
    inst:SetText("Shift+Click to link"); inst:SetTextColor(0.8,0.8,0.8) -- Светлее для лучшей читаемости

    -- Создаем боковое меню (всегда видимое)
    sidebarFrame = ns.SourceMenu:CreateMenuFrame(mainFrame)
    
    -- Создаем скролл-фрейм для контентной области
    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(660, 650) -- Высота должна совпадать с боковым меню
    scrollFrame:SetPoint("TOPLEFT", sidebarFrame, "TOPRIGHT", 5, 0) -- Выравниваем по верхнему краю
    scrollFrame:SetPoint("BOTTOMLEFT", sidebarFrame, "BOTTOMRIGHT", 5, 0) -- И по нижнему краю
    
    -- Создаем контентную область внутри скролла
    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(640, 650) -- Высота должна совпадать с боковым меню
    scrollFrame:SetScrollChild(contentFrame)
    

    local contentBg = contentFrame:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(0.12, 0.12, 0.12, 0.98) -- Темно-серый фон
    
    -- Добавляем рамку для контентной области
    local contentBorder = contentFrame:CreateTexture(nil, "BORDER")
    contentBorder:SetAllPoints()
    contentBorder:SetColorTexture(0.2, 0.2, 0.2, 0.9) -- Светлее фона
    contentBorder:SetPoint("TOPLEFT", contentBg, "TOPLEFT", -2, 2)
    contentBorder:SetPoint("BOTTOMRIGHT", contentBg, "BOTTOMRIGHT", 2, -2)
    
    -- Заголовок контентной области в стиле Details!
    contentTitle = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentTitle:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, -20)
    contentTitle:SetText("Select Class")
    contentTitle:SetTextColor(1, 1, 1) -- Белый текст
    contentTitle:SetFont(contentTitle:GetFont(), 16, "OUTLINE")
    
    -- Настраиваем callback для SourceMenu
    ns.SourceMenu:SetOnChangeCallback(function(event, source, role, class)
        if event == "role_changed" then
            currentRole = role
            currentClass = nil
            currentScreen = "class_selection"
            contentTitle:SetText("Select Class")
            UpdateDisplay()
        elseif event == "show_class_selection" then
            currentScreen = "class_selection"
            contentTitle:SetText("Select Class")
            UpdateDisplay()
        elseif event == "class_selected" then
            currentClass = class
            currentScreen = "items"
            contentTitle:SetText("Items for " .. ns:GetClassName(class))
            -- Получаем первую доступную специализацию для выбранного класса и роли
            local specs = ns.SourceManager:GetAvailableSpecs(class, role)
            if #specs > 0 then
                currentSpec = specs[1]
            end
            UpdateDisplay()
        end
    end)

    mainFrame:Hide()
    return mainFrame
end


-- Slash commands
SLASH_BISFINDER1 = "/bisfinder"
SLASH_BISFINDER2 = "/bisf"
SlashCmdList["BISFINDER"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "minimap" or command == "minimap toggle" then
        -- Переключить видимость миникарты
        if ns.MinimapButton then
            ns.MinimapButton:Toggle()
            print("|cFF00FF00BiSFinder|r: Миникарта " .. (ns.MinimapButton.minimapButton and ns.MinimapButton.minimapButton:IsVisible() and "показана" or "скрыта"))
        else
            print("|cFFFF0000BiSFinder|r: Модуль миникарты не загружен")
        end
    elseif command == "minimap show" then
        -- Показать миникарту
        if ns.MinimapButton then
            ns.MinimapButton:Show()
            print("|cFF00FF00BiSFinder|r: Миникарта показана")
        end
    elseif command == "minimap hide" then
        -- Скрыть миникарту
        if ns.MinimapButton then
            ns.MinimapButton:Hide()
            print("|cFF00FF00BiSFinder|r: Миникарта скрыта")
        end
    elseif command == "help" then
        -- Показать справку
        print("|cFF00FF00BiSFinder|r - Команды:")
        print("|cFFFFFF00/bisf|r или |cFFFFFF00/bisfinder|r - Открыть/закрыть BiSFinder")
        print("|cFFFFFF00/bisf minimap|r - Переключить видимость миникарты")
        print("|cFFFFFF00/bisf minimap show|r - Показать миникарту")
        print("|cFFFFFF00/bisf minimap hide|r - Скрыть миникарту")
        print("|cFFFFFF00/bisf help|r - Показать эту справку")
    else
        -- Основная команда - открыть/закрыть окно
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
            -- Инициализируем начальное состояние
            currentScreen = "class_selection"
            UpdateDisplay()
        end
    end
end

-- Update on spec change
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function()
    if mainFrame:IsShown() then
        local _, ps = GetPlayerClassAndSpec()
        if ps and ps ~= currentSpec then
            -- Используем SourceManager для поиска роли
        local allClasses = ns.SourceManager:GetAllClasses()
        for _, className in ipairs(allClasses) do
            local roles = ns.SourceManager:GetAvailableRoles(className)
            for _, role in ipairs(roles) do
                local specs = ns.SourceManager:GetAvailableSpecs(className, role)
                for _, spec in ipairs(specs) do
                    if spec == ps then
                        currentRole = role
                        currentSpec = ps
                        break
                    end
                end
                if currentRole then break end
            end
            if currentRole then break end
        end
            UpdateDisplay()
        end
    end
end)

-- Initialization on ADDON_LOADED
local function OnLoad(self, event, aname)
    if aname == ADDON_NAME then
        -- Инициализируем SourceManager
        if ns.SourceManager then
            -- Регистрируем модуль IcyVeins
            if ns.IcyVeinsModule then
                ns.SourceManager:RegisterSource(ns.IcyVeinsModule)
            end
            
            -- Инициализируем все источники
            ns.SourceManager:InitializeAllSources()
        end
        
        CreateMainFrame()
        
        -- Инициализируем миникарту
        if ns.MinimapButton then
            ns.MinimapButton:Initialize()
        end
        
        print("|cFF00FF00BiSFinder|r loaded! /bisf /bisfinder")
        self:UnregisterEvent("ADDON_LOADED")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnLoad)
