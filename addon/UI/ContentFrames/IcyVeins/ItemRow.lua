local ADDON_NAME, ns = ...

function ns:CreateItemRow(parent, itemType, items, yOffset)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(477, 60)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    
    -- Создаем нижнюю границу
    local border = row:CreateTexture(nil, "OVERLAY")
    border:SetSize(477, 1)
    border:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    border:SetColorTexture(0.294, 0.294, 0.294, 1) -- #4B4B4B
    
    -- Создаем текст itemType слева
    local itemTypeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemTypeText:SetPoint("LEFT", row, "LEFT", 5, 0)
    itemTypeText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    itemTypeText:SetTextColor(1, 1, 1, 1)
    itemTypeText:SetText(itemType)
    
    -- Создаем кнопки предметов справа
    local buttonX = 477 - (50 * #items) - 5 -- Позиция справа, учитывая количество кнопок
    for i, item in ipairs(items) do
        local button = CreateFrame("Button", nil, row, "BackdropTemplate")
        button:SetSize(50, 50)
        button:SetPoint("LEFT", row, "LEFT", buttonX + ((i - 1) * 50), 0)
        
        -- Создаем текстуру иконки предмета
        local itemIcon = button:CreateTexture(nil, "OVERLAY")
        itemIcon:SetAllPoints(button)
        itemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback иконка
        
        -- Пытаемся загрузить иконку предмета по itemId
        if item.itemId then
            local itemTexture = GetItemIcon(item.itemId)
            if itemTexture then
                itemIcon:SetTexture(itemTexture)
            end
        end
        
        -- Создаем тултип
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. (item.itemId or ""))
            
            -- Добавляем Source информацию
            if item.source then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Source: " .. item.source, 1, 1, 1)
            end
            
            GameTooltip:Show()
        end)
        
        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        -- Сохраняем данные предмета в кнопке
        button.itemData = item
    end
    
    return row
end
