local ADDON_NAME, ns = ...

function ns:CreateAboutContent()
    -- Удаляем старый контент если он есть
    if ns.aboutContentFrame then
        ns.aboutContentFrame:Hide()
        ns.aboutContentFrame = nil
    end
    
    if not ns.MainContentFrame then
        return
    end
    
    -- Создаем фрейм для контента About
    local aboutFrame = CreateFrame("Frame", nil, ns.MainContentFrame)
    aboutFrame:SetAllPoints(ns.MainContentFrame)
    aboutFrame:Show()
    
    -- Основной текст
    local mainText = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainText:SetPoint("TOP", aboutFrame, "TOP", 0, -50)
    mainText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    mainText:SetTextColor(1, 1, 1, 1)
    mainText:SetText("Data Sources")
    mainText:SetJustifyH("CENTER")
    
    -- Описание
    local descriptionText = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descriptionText:SetPoint("TOP", mainText, "BOTTOM", 0, -30)
    descriptionText:SetWidth(450)
    descriptionText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    descriptionText:SetTextColor(0.9, 0.9, 0.9, 1)
    descriptionText:SetText("The data used in this addon is sourced from the following websites. You can find additional information about classes on these sites:")
    descriptionText:SetJustifyH("CENTER")
    descriptionText:SetJustifyV("TOP")
    
    -- Icy Veins секция
    local icyVeinsTitle = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    icyVeinsTitle:SetPoint("TOP", descriptionText, "BOTTOM", 0, -40)
    icyVeinsTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    icyVeinsTitle:SetTextColor(0.4, 0.8, 1, 1)
    icyVeinsTitle:SetText("Icy Veins")
    icyVeinsTitle:SetJustifyH("CENTER")
    
    local icyVeinsLink = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    icyVeinsLink:SetPoint("TOP", icyVeinsTitle, "BOTTOM", 0, -10)
    icyVeinsLink:SetFont("Fonts\\FRIZQT__.TTF", 12)
    icyVeinsLink:SetTextColor(0.5, 0.7, 1, 1)
    icyVeinsLink:SetText("https://www.icy-veins.com/")
    icyVeinsLink:SetJustifyH("CENTER")
    
    -- Кнопка поддержки Icy Veins
    local icyVeinsSupportButton = CreateFrame("Button", nil, aboutFrame, "BackdropTemplate")
    icyVeinsSupportButton:SetSize(200, 30)
    icyVeinsSupportButton:SetPoint("TOP", icyVeinsLink, "BOTTOM", 0, -15)
    icyVeinsSupportButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    icyVeinsSupportButton:SetBackdropColor(0.2, 0.4, 0.8, 0.8)
    
    local icyVeinsSupportText = icyVeinsSupportButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    icyVeinsSupportText:SetPoint("CENTER", icyVeinsSupportButton, "CENTER", 0, 0)
    icyVeinsSupportText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    icyVeinsSupportText:SetTextColor(1, 1, 1, 1)
    icyVeinsSupportText:SetText("Support Icy Veins")
    
    icyVeinsSupportButton:SetScript("OnClick", function()
        -- Открываем ссылку в браузере (через команду)
        local url = "https://www.icy-veins.com/forums/premium"
        -- В WoW нет прямого способа открыть URL, но можно скопировать в чат
        print("Visit: " .. url)
    end)
    
    icyVeinsSupportButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.5, 0.9, 1)
    end)
    
    icyVeinsSupportButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.4, 0.8, 0.8)
    end)
    
    icyVeinsSupportButton:EnableMouse(true)
    
    -- Archon секция
    local archonTitle = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    archonTitle:SetPoint("TOP", icyVeinsSupportButton, "BOTTOM", 0, -40)
    archonTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    archonTitle:SetTextColor(0.8, 0.6, 0.2, 1)
    archonTitle:SetText("Archon")
    archonTitle:SetJustifyH("CENTER")
    
    local archonLink = aboutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    archonLink:SetPoint("TOP", archonTitle, "BOTTOM", 0, -10)
    archonLink:SetFont("Fonts\\FRIZQT__.TTF", 12)
    archonLink:SetTextColor(0.9, 0.7, 0.3, 1)
    archonLink:SetText("https://www.archon.gg/")
    archonLink:SetJustifyH("CENTER")
    
    -- Кнопка поддержки Archon
    local archonSupportButton = CreateFrame("Button", nil, aboutFrame, "BackdropTemplate")
    archonSupportButton:SetSize(200, 30)
    archonSupportButton:SetPoint("TOP", archonLink, "BOTTOM", 0, -15)
    archonSupportButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    archonSupportButton:SetBackdropColor(0.8, 0.6, 0.2, 0.8)
    
    local archonSupportText = archonSupportButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    archonSupportText:SetPoint("CENTER", archonSupportButton, "CENTER", 0, 0)
    archonSupportText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    archonSupportText:SetTextColor(1, 1, 1, 1)
    archonSupportText:SetText("Support Archon")
    
    archonSupportButton:SetScript("OnClick", function()
        -- Открываем ссылку в браузере (через команду)
        local url = "https://www.archon.gg/wow/articles/help/subscriber-benefits"
        -- В WoW нет прямого способа открыть URL, но можно скопировать в чат
        print("Visit: " .. url)
    end)
    
    archonSupportButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.9, 0.7, 0.3, 1)
    end)
    
    archonSupportButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.8, 0.6, 0.2, 0.8)
    end)
    
    archonSupportButton:EnableMouse(true)
    
    -- Сохраняем ссылку на фрейм
    ns.aboutContentFrame = aboutFrame
    
    return aboutFrame
end

