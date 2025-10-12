local ADDON_NAME, ns = ...

function ns:CreateMainContentFrame(parent)
    local MainContentFrame = CreateFrame("Frame", "MainContentFrame", parent, "BackdropTemplate")
    MainContentFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 151, 0)
    MainContentFrame:SetSize(500, 650)
    MainContentFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", insets = { left = 10, right = 10, top = 20, bottom = 20 } })
    MainContentFrame:SetBackdropColor(0.10, 0.10, 0.12, 0)

    local title = MainContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 10, -20)
    title:SetTextColor(1, 1, 1, 1)
    title:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

    local currentSourceId = ns:GetSelectedSourceId()
    local sourceName = ns.sourcesMap[currentSourceId] or "IcyVeins"
    title:SetText("Search for your BiS (" .. sourceName .. ")")
    
    -- Функция для обновления заголовка
    function ns:UpdateMainContentTitle()
        local currentSourceId = ns:GetSelectedSourceId()
        local sourceName = ns.sourcesMap[currentSourceId] or "IcyVeins"
        title:SetText("Search for your BiS (" .. sourceName .. ")")
    end

    -- Функция для обновления заголовка с названием специализации
    function ns:UpdateMainContentTitleWithSpec(specName)
        title:SetText(specName)
    end

    ns:CreateRoleShooseFrame(MainContentFrame)
    
    -- Создаем скролл-фрейм для кнопок специализаций
    local scrollFrame = CreateFrame("ScrollFrame", nil, MainContentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 0, -120)
    scrollFrame:SetPoint("BOTTOMRIGHT", MainContentFrame, "BOTTOMRIGHT", -20, 20)
    
    -- Создаем контент-фрейм для кнопок
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 1) -- Высота будет установлена динамически
    scrollFrame:SetScrollChild(contentFrame)
    
    -- Функция для обновления размера контент-фрейма
    function ns:UpdateScrollContent()
        if ns.specButtons then
            local buttonCount = 0
            for _ in pairs(ns.specButtons) do
                buttonCount = buttonCount + 1
            end
            
            if buttonCount > 0 then
                local buttonHeight = 45
                local gap = 22
                local totalHeight = buttonCount * buttonHeight + (buttonCount - 1) * gap
                contentFrame:SetHeight(totalHeight)
            end
        end
    end
    
    -- Создаем кнопки специализаций в скролл-фрейме
    ns:CreateButtonList(contentFrame)
    
    -- Сохраняем ссылки для обновления
    ns.MainContentFrame = MainContentFrame
    ns.ScrollFrame = scrollFrame
    ns.ContentFrame = contentFrame
    
    MainContentFrame:Show()
    return MainContentFrame
end