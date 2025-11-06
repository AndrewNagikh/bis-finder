local ADDON_NAME, ns = ...

function ns:CreateArchonContent(parent)
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
    
    -- Получаем данные из ArchonData
    local specData = nil
    if ns.ArchonData and ns.ArchonData[selectedItemSourceId] and ns.ArchonData[selectedItemSourceId][selectedRoleId] then
        -- Получаем полное имя специализации из specMap
        local specName = nil
        if ns.specMap and ns.specMap[selectedRoleId] and ns.specMap[selectedRoleId][selectedSpecId] then
            specName = ns.specMap[selectedRoleId][selectedSpecId].name
        end
        
        if specName and ns.ArchonData[selectedItemSourceId][selectedRoleId][specName] then
            specData = ns.ArchonData[selectedItemSourceId][selectedRoleId][specName].items
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
    ns:UpdateArchonScrollContent()
    
    contentFrame:Show()
    return contentFrame
end

function ns:UpdateArchonScrollContent()
    if ns.itemRows and ns.ContentFrame then
        local rowCount = 0
        for _ in pairs(ns.itemRows) do
            rowCount = rowCount + 1
        end

        if rowCount > 0 then
            local rowHeight = 60
            local totalHeight = rowCount * rowHeight
            ns.ContentFrame:SetHeight(totalHeight)
            -- Устанавливаем ширину для Archon (с учетом enchantments)
            ns.ContentFrame:SetWidth(577) -- 557 (ширина строки) + 20 (отступы)
        else
            -- Если нет строк, устанавливаем минимальную высоту
            ns.ContentFrame:SetHeight(100)
        end
    end
end

