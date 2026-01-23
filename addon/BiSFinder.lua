local ADDON_NAME, ns = ...

function ns:CreateMainFrame()
    if not MainFrame then
        MainFrame = CreateFrame("Frame", "MainFrame", UIParent, "BackdropTemplate")
        MainFrame:SetSize(660, 650)
        MainFrame:SetPoint("CENTER")

        MainFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        MainFrame:SetBackdropColor(0.078, 0.078, 0.078, 1)
        
        -- Делаем окно перетаскиваемым
        MainFrame:SetMovable(true)
        MainFrame:RegisterForDrag("LeftButton")
        MainFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        MainFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
        
        -- Создаем область для перетаскивания в верхней части окна
        local dragRegion = CreateFrame("Frame", nil, MainFrame)
        dragRegion:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, 0)
        dragRegion:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0)
        dragRegion:SetHeight(66) -- Высота области для перетаскивания (верхняя часть окна)
        dragRegion:EnableMouse(true)
        dragRegion:RegisterForDrag("LeftButton")
        dragRegion:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                MainFrame:StartMoving()
            end
        end)
        dragRegion:SetScript("OnMouseUp", function(self)
            MainFrame:StopMovingOrSizing()
        end)
        
        -- Создаем кнопку закрытия
        ns:CreateCloseButton(MainFrame)

        -- Создаем SideBar и ContentFrame
        ns:CreateSideBar(MainFrame)
        ns:CreateMainContentFrame(MainFrame)
        ns:CreateRoleShooseFrame(MainFrame)
        
        -- Скрываем MainFrame по умолчанию
        MainFrame:Hide()
    end
    return MainFrame
end

-- Инициализация аддона
local function InitializeAddon()
    -- Определяем специализацию игрока и устанавливаем как выбранную
    if ns.GetPlayerSpecId then
        local playerSpecId = ns:GetPlayerSpecId()
        if playerSpecId then
            ns.selectedSpecId = playerSpecId
        end
    end
    
    -- Иконка на миникарте создается автоматически в MinimapIcon.lua при загрузке файла
end

-- Функция для автоматического открытия контента по специализации игрока
function ns:AutoOpenPlayerSpec()
    if not ns.GetPlayerSpecName then
        return
    end
    
    local playerSpecName = ns:GetPlayerSpecName()
    if not playerSpecName then
        return
    end
    
    -- Определяем роль игрока по специализации
    local playerRole = nil
    local specId = nil
    
    -- Ищем специализацию в specMap
    for roleId, roleData in pairs(ns.specMap) do
        -- Если playerSpecName является числом, ищем по ключу
        if type(playerSpecName) == "number" then
            if roleData[playerSpecName] then
                playerRole = roleId
                specId = playerSpecName
                break
            end
        else
            -- Если playerSpecName является строкой, ищем по названию
            for specIdKey, specData in pairs(roleData) do
                if type(specData) == "table" and specData.name == playerSpecName then
                    playerRole = roleId
                    specId = specIdKey
                    break
                end
            end
        end
        
        if playerRole then
            break
        end
    end
    
    if not playerRole or not specId then
        return
    end
    
    -- Устанавливаем выбранную роль
    if ns.UpdateSelectedRole then
        ns:UpdateSelectedRole(playerRole)
    end
    
    -- Устанавливаем выбранную специализацию
    if ns.UpdateSelectedSpecId then
        ns:UpdateSelectedSpecId(specId)
    end
    
    -- Устанавливаем источник предметов по умолчанию (overroll)
    if ns.UpdateSelectedItemSource then
        ns:UpdateSelectedItemSource("overroll")
    end
    
    -- Обновляем заголовок с текстурой специализации
    if ns.UpdateMainContentTitleWithSpec and specId then
        ns:UpdateMainContentTitleWithSpec(specId)
    end
    
    -- Скрываем старые экраны перед показом новых
    if ns.RoleShooseFrame then
        ns.RoleShooseFrame:Hide()
    end
    if ns.SpecChooseFrame then
        ns.SpecChooseFrame:Hide()
    end
    -- Скрываем кнопки специализаций
    if ns.specButtons then
        for _, button in pairs(ns.specButtons) do
            if button and button.Hide then
                button:Hide()
            end
        end
    end
    
    -- Показываем ItemSourceChooseFrame
    if ns.CreateItemSourceChooseFrame and ns.MainContentFrame then
        ns:CreateItemSourceChooseFrame(ns.MainContentFrame)
    end
    
    -- Показываем контент предметов в зависимости от источника
    local selectedSourceId = ns:GetSelectedSourceId()
    if selectedSourceId == "archon" then
        if ns.CreateArchonContent then
            ns:CreateArchonContent()
        end
    else
        if ns.CreateIcyVeinsContent then
            ns:CreateIcyVeinsContent()
        end
    end
end

-- Обработчик события загрузки аддона
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == ADDON_NAME then
        InitializeAddon()
    end
end)

SLASH_BISF1 = "/bisf"
SlashCmdList["BISF"] = function()
    local MainFrame = ns:CreateMainFrame()
    if MainFrame then
        MainFrame:Show()
        -- Автоматически открываем контент по специализации игрока
        ns:AutoOpenPlayerSpec()
    end
end

SLASH_BISFINDER1 = "/bisfinder"
SlashCmdList["BISFINDER"] = function()
    local MainFrame = ns:CreateMainFrame()
    if MainFrame then
        MainFrame:Show()
        -- Автоматически открываем контент по специализации игрока
        ns:AutoOpenPlayerSpec()
    end
end

-- Команда для принудительного показа иконки на миникарте
SLASH_BISFMINIMAP1 = "/bisfminimap"
SlashCmdList["BISFMINIMAP"] = function()
    if ns.CreateMinimapIcon then
        ns:CreateMinimapIcon()
    end
end
