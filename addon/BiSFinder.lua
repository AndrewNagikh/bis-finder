local ADDON_NAME, ns = ...

function ns:CreateMainFrame()
    if not MainFrame then
        MainFrame = CreateFrame("Frame", "MainFrame", UIParent, "BackdropTemplate")
        MainFrame:SetSize(660, 650)
        MainFrame:SetPoint("CENTER")

        MainFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        MainFrame:SetBackdropColor(0.078, 0.078, 0.078, 1)
        
        -- Создаем кнопку закрытия
        ns:CreateCloseButton(MainFrame)
        
        -- Делаем MainFrame видимым
        MainFrame:Show()

        -- Создаем SideBar и ContentFrame
        ns:CreateSideBar(MainFrame)
        ns:CreateMainContentFrame(MainFrame)
        ns:CreateRoleShooseFrame(MainFrame)
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
    
    -- Создаем иконку на миникарте с задержкой (чтобы MinimapIcon.lua успел загрузиться)
    C_Timer.After(0.5, function()
        if ns.CreateMinimapIcon then
            ns:CreateMinimapIcon()
        end
    end)
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
    end
end

-- Команда для принудительного показа иконки на миникарте
SLASH_BISFMINIMAP1 = "/bisfminimap"
SlashCmdList["BISFMINIMAP"] = function()
    if ns.CreateMinimapIcon then
        ns:CreateMinimapIcon()
    end
end
