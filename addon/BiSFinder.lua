local ADDON_NAME, ns = ...

local function CreateMainFrame()
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

SLASH_BISF1 = "/bisf"
SlashCmdList["BISF"] = function()
    local MainFrame = CreateMainFrame()
    MainFrame:Show()
end
