local ADDON_NAME, ns = ...

function ns:CreateIcyVeinsContent(parent)
    if ns.SetArchonPriorityStatsVisible then
        ns:SetArchonPriorityStatsVisible(false)
    end
    -- Используем существующий ContentFrame из скролл-фрейма
    local contentFrame = ns.ContentFrame
    if not contentFrame then
        return
    end
    
    -- Очищаем существующий контент
    if ns.itemRows then
        for _, row in pairs(ns.itemRows) do
            row:Hide()
        end
    end
    
    -- Скрываем сообщение "нет данных" если оно было показано
    if ns.noDataMessage then
        ns.noDataMessage:Hide()
    end
    
    -- Получаем данные для выбранной специализации
    local selectedSpecId = ns:GetSelectedSpecId()
    local selectedRoleId = ns:GetSelectedRoleId()
    local selectedItemSourceId = ns:GetSelectedItemSourceId()
    
    if not selectedSpecId or not selectedRoleId or not selectedItemSourceId then
        -- Показываем сообщение "нет данных"
        ns:ShowNoDataMessage(contentFrame)
        return contentFrame
    end
    
    -- Получаем данные из IcyVeinsData
    local specData = nil
    if ns.IcyVeinsData and ns.IcyVeinsData[selectedItemSourceId] and ns.IcyVeinsData[selectedItemSourceId][selectedRoleId] then
        -- Получаем полное имя специализации из specMap
        local specName = nil
        if ns.specMap and ns.specMap[selectedRoleId] and ns.specMap[selectedRoleId][selectedSpecId] then
            specName = ns.specMap[selectedRoleId][selectedSpecId].name
        end
        
        if specName then
            specData = ns.IcyVeinsData[selectedItemSourceId][selectedRoleId][specName]
        end
    end
    
    if not specData or #specData == 0 then
        -- Показываем сообщение "нет данных"
        ns:ShowNoDataMessage(contentFrame)
        return contentFrame
    end
    
    -- Группируем предметы по itemType, сохраняя порядок
    local itemsByType = {}
    local itemTypeOrder = {} -- Массив для сохранения порядка типов предметов
    
    for _, item in ipairs(specData) do
        if not itemsByType[item.itemType] then
            itemsByType[item.itemType] = {}
            table.insert(itemTypeOrder, item.itemType) -- Сохраняем порядок появления
        end
        table.insert(itemsByType[item.itemType], item)
    end
    
    -- Создаем строки для каждого типа предметов в правильном порядке
    local itemRows = {}
    for i, itemType in ipairs(itemTypeOrder) do
        local items = itemsByType[itemType]
        local yOffset = -((i - 1) * (60 + 0)) -- 60px высота строки
        local row = ns:CreateItemRow(contentFrame, itemType, items, yOffset)
        itemRows[itemType] = row
    end
    
    -- Сохраняем ссылки на строки
    ns.itemRows = itemRows
    
    -- Обновляем размер контент-фрейма для скролла
    ns:UpdateIcyVeinsScrollContent()
    
    contentFrame:Show()
    return contentFrame
end

function ns:ShowNoDataMessage(parent)
    -- Скрываем существующие строки
    if ns.itemRows then
        for _, row in pairs(ns.itemRows) do
            row:Hide()
        end
    end
    
    -- Создаем сообщение "нет данных" если его еще нет
    if not ns.noDataMessage then
        ns.noDataMessage = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        ns.noDataMessage:SetPoint("CENTER", parent, "CENTER", 0, 0)
        ns.noDataMessage:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
        ns.noDataMessage:SetTextColor(0.7, 0.7, 0.7, 1)
        ns.noDataMessage:SetText("No data available")
    end
    
    -- Устанавливаем минимальную высоту для скролла
    if ns.ContentFrame then
        ns.ContentFrame:SetHeight(100)
    end
    
    ns.noDataMessage:Show()
end

function ns:UpdateIcyVeinsScrollContent()
    if ns.itemRows and ns.ContentFrame then
        local rowCount = 0
        for _ in pairs(ns.itemRows) do
            rowCount = rowCount + 1
        end

        if rowCount > 0 then
            local rowHeight = 60
            local totalHeight = rowCount * rowHeight
            ns.ContentFrame:SetHeight(totalHeight)
        else
            -- Если нет строк, устанавливаем минимальную высоту
            ns.ContentFrame:SetHeight(100)
        end
    end
end
