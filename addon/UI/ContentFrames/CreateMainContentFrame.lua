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

    -- Фрейм "Priority stats" только для Archon (под первым фреймом, скрыт по умолчанию)
    local PRIORITY_STATS_TOP = -130   -- 64+60 (RoleShooseFrame) + 16 (отступ сверху)
    local PRIORITY_FRAME_HEIGHT = 35
    local SCROLL_TOP_DEFAULT = -130
    local SCROLL_TOP_WITH_PRIORITY = -140 - PRIORITY_FRAME_HEIGHT - 10  -- фрейм + 10px отступ = -195

    local priorityStatsFrame = CreateFrame("Frame", nil, MainContentFrame)
    priorityStatsFrame:SetSize(480, PRIORITY_FRAME_HEIGHT)
    priorityStatsFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 10, PRIORITY_STATS_TOP)

    local priorityStatsText = priorityStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    priorityStatsText:SetPoint("LEFT", priorityStatsFrame, "LEFT", 0, 0)
    priorityStatsText:SetFont("Fonts\\FRIZQT__.TTF", 15, "")
    priorityStatsText:SetTextColor(1, 1, 1, 1)
    priorityStatsFrame:Hide()

    priorityStatsFrame.priorityStatsText = priorityStatsText
    ns.ArchonPriorityStatsFrame = priorityStatsFrame

    -- Цвета для приоритета статов: 1-й #f89737, 2-й rgba(123,25,190,.9), 3-й rgba(0,90,205,.6), остальные белый
    local STAT_COLOR_1 = "|cFFf89737"  -- оранжевый
    local STAT_COLOR_2 = "|cE67B19BE"  -- фиолетовый 90%
    local STAT_COLOR_3 = "|c99005ACD"  -- синий 60%
    local STAT_COLOR_RESET = "|r"

    function ns:UpdateArchonPriorityStatsText(statsArray)
        local text = ns.ArchonPriorityStatsFrame and ns.ArchonPriorityStatsFrame.priorityStatsText
        if not text then return end
        if not statsArray or #statsArray == 0 then
            text:SetText("Priority stats: —")
            return
        end
        local parts = { "Priority stats: " }
        for i, stat in ipairs(statsArray) do
            if i > 1 then
                parts[#parts + 1] = " > "
            end
            if i == 1 then
                parts[#parts + 1] = STAT_COLOR_1 .. stat .. STAT_COLOR_RESET
            elseif i == 2 then
                parts[#parts + 1] = STAT_COLOR_2 .. stat .. STAT_COLOR_RESET
            elseif i == 3 then
                parts[#parts + 1] = STAT_COLOR_3 .. stat .. STAT_COLOR_RESET
            else
                parts[#parts + 1] = stat
            end
        end
        text:SetText(table.concat(parts, ""))
    end

    function ns:SetArchonPriorityStatsVisible(visible)
        if ns.ArchonPriorityStatsFrame then
            if visible then
                ns.ArchonPriorityStatsFrame:Show()
                if ns.ScrollFrame then
                    ns.ScrollFrame:ClearAllPoints()
                    ns.ScrollFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 0, SCROLL_TOP_WITH_PRIORITY)
                    ns.ScrollFrame:SetPoint("BOTTOMRIGHT", MainContentFrame, "BOTTOMRIGHT", -20, 20)
                end
            else
                ns.ArchonPriorityStatsFrame:Hide()
                if ns.ScrollFrame then
                    ns.ScrollFrame:ClearAllPoints()
                    ns.ScrollFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 0, SCROLL_TOP_DEFAULT)
                    ns.ScrollFrame:SetPoint("BOTTOMRIGHT", MainContentFrame, "BOTTOMRIGHT", -20, 20)
                end
            end
        end
    end

    -- Создаем скролл-фрейм для кнопок специализаций
    local scrollFrame = CreateFrame("ScrollFrame", nil, MainContentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", MainContentFrame, "TOPLEFT", 0, SCROLL_TOP_DEFAULT)
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