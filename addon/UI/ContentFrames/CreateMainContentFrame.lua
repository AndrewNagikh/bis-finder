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

    -- Создаем текстуру для отображения текстуры специализации
    local specTexture = MainContentFrame:CreateTexture(nil, "OVERLAY")
    specTexture:SetSize(280, 45) -- Размер как у кнопок специализаций
    specTexture:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 10, -20)
    specTexture:Hide() -- Скрываем по умолчанию

    -- Создаем кнопку Copy Talents
    local copyTalentsButton = nil
    if ns.CreateCopyTalentsButton then
        copyTalentsButton = ns:CreateCopyTalentsButton(MainContentFrame, specTexture)
    end

    local currentSourceId = ns:GetSelectedSourceId()
    local sourceName = ns.sourcesMap[currentSourceId] or "IcyVeins"
    title:SetText("Search for your BiS (" .. sourceName .. ")")
    
    -- Функция для обновления заголовка
    function ns:UpdateMainContentTitle()
        local currentSourceId = ns:GetSelectedSourceId()
        if currentSourceId == "about" then
            title:SetText("About")
        else
            local sourceName = ns.sourcesMap[currentSourceId] or "IcyVeins"
            title:SetText("Search for your BiS (" .. sourceName .. ")")
        end
        -- Скрываем текстуру специализации и показываем текст
        specTexture:Hide()
        title:Show()
        -- Скрываем кнопку Copy Talents
        if copyTalentsButton then
            copyTalentsButton:Hide()
        end
    end

    -- Функция для обновления заголовка с текстурой специализации
    function ns:UpdateMainContentTitleWithSpec(specId)
        local selectedRoleId = ns:GetSelectedRoleId()
        local selectedSourceId = ns:GetSelectedSourceId()
        
        if selectedRoleId and ns.specMap and ns.specMap[selectedRoleId] and ns.specMap[selectedRoleId][specId] then
            local specData = ns.specMap[selectedRoleId][specId]
            if specData.texture then
                -- Показываем текстуру специализации
                specTexture:SetTexture(specData.texture)
                specTexture:Show()
                title:Hide()
                
                -- Показываем кнопку Copy Talents только для Archon
                if copyTalentsButton then
                    if selectedSourceId == "archon" then
                        copyTalentsButton:Show()
                    else
                        copyTalentsButton:Hide()
                    end
                end
            else
                -- Fallback на текст если текстуры нет
                specTexture:Hide()
                title:SetText(specData.name or "")
                title:Show()
                -- Скрываем кнопку Copy Talents
                if copyTalentsButton then
                    copyTalentsButton:Hide()
                end
            end
        else
            -- Fallback на текст если данных нет
            specTexture:Hide()
            title:Show()
            -- Скрываем кнопку Copy Talents
            if copyTalentsButton then
                copyTalentsButton:Hide()
            end
        end
    end

    ns:CreateRoleShooseFrame(MainContentFrame)
    
    -- Создаем скролл-фрейм для кнопок специализаций
    local scrollFrame = CreateFrame("ScrollFrame", nil, MainContentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 0, -130)
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