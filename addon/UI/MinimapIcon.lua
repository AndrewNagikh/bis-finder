local ADDON_NAME, ns = ...

-- Инициализируем базу данных для настроек миникарты
BiSFinderMinimapDB = BiSFinderMinimapDB or {
    hide = false,
    minimapPos = 45,
}

-- Создаем объект для LibDataBroker
local BiSFinderLDB = LibStub("LibDataBroker-1.1"):NewDataObject("BiSFinder", {
    type = "launcher",
    text = "BiSFinder",
    icon = "Interface\\AddOns\\BiSFinder\\Textures\\logo.png", -- Логотип аддона
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Показываем/скрываем главное окно аддона
            if MainFrame then
                if MainFrame:IsVisible() then
                    MainFrame:Hide()
                else
                    MainFrame:Show()
                    -- Автоматически открываем контент по специализации игрока
                    if ns.AutoOpenPlayerSpec then
                        ns:AutoOpenPlayerSpec()
                    end
                end
            else
                -- Если MainFrame не существует, создаем его
                if ns.CreateMainFrame then
                    local frame = ns.CreateMainFrame()
                    if frame then
                        frame:Show()
                        -- Автоматически открываем контент по специализации игрока
                        if ns.AutoOpenPlayerSpec then
                            ns:AutoOpenPlayerSpec()
                        end
                    end
                else
                    -- Используем команду как fallback
                    SlashCmdList["BISF"]()
                end
            end
        elseif button == "RightButton" then
            -- Можно добавить контекстное меню или настройки
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("BiSFinder")
        tooltip:AddLine("Left-click to toggle main window", 1, 1, 1)
    end,
})

-- Флаг для отслеживания регистрации
local isRegistered = false

-- Создаем иконку на миникарте
function ns:CreateMinimapIcon()
    -- Проверяем, не зарегистрирован ли уже объект
    if isRegistered then
        return
    end
    
    -- Проверяем доступность библиотек
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDI = LibStub("LibDBIcon-1.0", true)
    
    if not LDB or not LDI then
        return
    end
    
    -- Проверяем, не зарегистрирован ли объект в LibDBIcon
    if LDI.objects and LDI.objects["BiSFinder"] then
        isRegistered = true
        -- Показываем иконку если она не скрыта
        if not BiSFinderMinimapDB.hide then
            LDI:Show("BiSFinder")
        end
        return
    end
    
    -- Регистрируем иконку с базой данных настроек
    LDI:Register("BiSFinder", BiSFinderLDB, BiSFinderMinimapDB)
    isRegistered = true
    
    -- Показываем иконку если она не скрыта
    if not BiSFinderMinimapDB.hide then
        LDI:Show("BiSFinder")
    end
end

-- Функция для скрытия иконки
function ns:HideMinimapIcon()
    local LDI = LibStub("LibDBIcon-1.0", true)
    if LDI then
        LDI:Hide("BiSFinder")
        BiSFinderMinimapDB.hide = true
    end
end

-- Функция для показа иконки
function ns:ShowMinimapIcon()
    local LDI = LibStub("LibDBIcon-1.0", true)
    if LDI then
        LDI:Show("BiSFinder")
        BiSFinderMinimapDB.hide = false
    end
end

-- Автоматически создаем иконку при загрузке файла
C_Timer.After(1, function()
    if ns.CreateMinimapIcon then
        ns:CreateMinimapIcon()
    end
end)
