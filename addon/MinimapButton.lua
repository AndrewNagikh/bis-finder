-- BiSFinder Minimap Button using LibDBIcon
-- Создает иконку на миникарте для быстрого доступа к аддону

local ADDON_NAME, ns = ...

local MinimapButton = {}
ns.MinimapButton = MinimapButton

-- Проверяем доступность библиотек
local LibStub = LibStub
local LibDBIcon = LibStub and LibStub("LibDBIcon-1.0")
local LDB = LibStub and LibStub("LibDataBroker-1.1")

-- Настройки миникарты
local minimapData = nil
local isInitialized = false

-- Создание LDB объекта для миникарты
function MinimapButton:CreateLDBObject()
    if not LDB then
        print("|cFFFF0000BiSFinder|r: LibDataBroker не найден")
        return false
    end
    
    minimapData = LDB:NewDataObject("BiSFinder", {
        type = "data source",
        text = "BiSFinder",
        icon = "Interface\\Icons\\INV_Misc_EngGizmos_30", -- Иконка лупы/поиска
        OnClick = function(self, button)
            MinimapButton:OnClick(button)
        end,
        OnTooltipShow = function(tooltip)
            MinimapButton:OnTooltipShow(tooltip)
        end,
    })
    
    return true
end

-- Инициализация миникарты
function MinimapButton:Initialize()
    if isInitialized then return end
    
    -- Проверяем доступность LibDBIcon
    if not LibDBIcon then
        print("|cFFFF0000BiSFinder|r: LibDBIcon не найден, миникарта недоступна")
        return false
    end
    
    -- Создаем LDB объект
    if not self:CreateLDBObject() then
        return false
    end
    
    -- Инициализируем базу данных для миникарты
    if not BiSFinderDB then
        BiSFinderDB = {}
    end
    if not BiSFinderDB.minimap then
        BiSFinderDB.minimap = {
            hide = false,
        }
    end
    
    -- Регистрируем иконку в LibDBIcon
    LibDBIcon:Register("BiSFinder", minimapData, BiSFinderDB.minimap)
    
    isInitialized = true
    print("|cFF00FF00BiSFinder|r: Миникарта иконка инициализирована")
    
    return true
end

-- Обработка клика по кнопке
function MinimapButton:OnClick(button)
    if button == "LeftButton" then
        -- Проверяем доступность основного модуля
        if ns.BiSFinder then
            -- Пытаемся найти функцию ToggleMainFrame или ShowMainFrame
            if ns.BiSFinder.ToggleMainFrame then
                ns.BiSFinder:ToggleMainFrame()
            elseif ns.BiSFinder.ShowMainFrame then
                ns.BiSFinder:ShowMainFrame()
            else
                -- Если нет специальных функций, используем команду
                SlashCmdList["BISFINDER"]("")
            end
        else
            -- Если модуль не загружен, используем команду напрямую
            SlashCmdList["BISFINDER"]("")
        end
    elseif button == "RightButton" then
        -- Создаем контекстное меню
        MinimapButton:ShowContextMenu()
    end
end

-- Показ подсказки
function MinimapButton:OnTooltipShow(tooltip)
    tooltip:SetText("BiSFinder", 1, 1, 1)
    tooltip:AddLine("Левый клик: Открыть BiSFinder", 0.5, 0.5, 0.5)
    tooltip:AddLine("Правый клик: Настройки", 0.5, 0.5, 0.5)
    tooltip:AddLine("Перетаскивание: Переместить", 0.5, 0.5, 0.5)
end

-- Показать контекстное меню
function MinimapButton:ShowContextMenu()
    local menu = CreateFrame("Frame", "BiSFinderMinimapMenu", UIParent, "UIDropDownMenuTemplate")
    
    local menuItems = {
        {
            text = "BiSFinder",
            isTitle = true,
            notCheckable = true,
        },
        {
            text = "Открыть BiSFinder",
            func = function()
                MinimapButton:OnClick("LeftButton")
            end,
            notCheckable = true,
        },
        {
            text = "Скрыть иконку",
            func = function()
                MinimapButton:Hide()
            end,
            notCheckable = true,
        },
        {
            text = "Показать иконку",
            func = function()
                MinimapButton:Show()
            end,
            notCheckable = true,
        },
    }
    
    EasyMenu(menuItems, menu, "cursor", 0, 0, "MENU")
end

-- Показать кнопку
function MinimapButton:Show()
    if LibDBIcon then
        LibDBIcon:Show("BiSFinder")
    end
end

-- Скрыть кнопку
function MinimapButton:Hide()
    if LibDBIcon then
        LibDBIcon:Hide("BiSFinder")
    end
end

-- Переключить видимость
function MinimapButton:Toggle()
    if LibDBIcon then
        if BiSFinderDB.minimap.hide then
            self:Show()
        else
            self:Hide()
        end
    end
end

-- Проверить, видима ли кнопка
function MinimapButton:IsVisible()
    return LibDBIcon and not BiSFinderDB.minimap.hide
end

-- Получить позицию
function MinimapButton:GetPosition()
    return BiSFinderDB.minimap and BiSFinderDB.minimap.minimapPos
end

-- Установить позицию
function MinimapButton:SetPosition(angle)
    if BiSFinderDB.minimap then
        BiSFinderDB.minimap.minimapPos = angle
    end
end

-- Получить радиус
function MinimapButton:GetRadius()
    return BiSFinderDB.minimap and BiSFinderDB.minimap.radius
end

-- Установить радиус
function MinimapButton:SetRadius(radius)
    if BiSFinderDB.minimap then
        BiSFinderDB.minimap.radius = radius
    end
end

-- Очистка
function MinimapButton:Cleanup()
    if LibDBIcon and isInitialized then
        LibDBIcon:Unregister("BiSFinder")
        isInitialized = false
    end
end

-- Проверить, инициализирована ли миникарта
function MinimapButton:IsInitialized()
    return isInitialized
end

return MinimapButton