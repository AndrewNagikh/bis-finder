local ADDON_NAME, ns = ...

-- Create an item button (только иконка, без названия)
function ns:CreateItemButton(parent, itemInfo)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 40)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    local id = tonumber(itemInfo.itemId)
    if id then
        local item = Item:CreateFromItemID(id)
        item:ContinueOnItemLoad(function()
            local tex = item:GetItemIcon()
            if tex then icon:SetTexture(tex) end
        end)
    end

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:"..itemInfo.itemId)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFF00Source:|r "..itemInfo.source,1,1,1,true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", function(self, btn)
        if btn=="LeftButton" and IsShiftKeyDown() then
            local _, link = GetItemInfo(itemInfo.itemId)
            if link and ChatEdit_GetActiveWindow() then
                ChatEdit_InsertLink(link)
            end
        end
    end)

    return btn
end

-- Create a header for item type в стиле Details!
function ns:CreateItemTypeHeader(parent, text, x, y)
    local hdr = parent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    hdr:SetText(text)
    hdr:SetTextColor(0.9, 0.9, 0.9) -- Светло-серый текст как в Details!
    hdr:SetFont(hdr:GetFont(), 13, "OUTLINE")
    return hdr
end

-- Create item level text (минималистичный стиль)
function ns:CreateItemLevelText(parent, itemLevel, x, y)
    local levelText = parent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    levelText:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    levelText:SetTextColor(0.8, 0.8, 0.8) -- Светло-серый текст как в Details!
    levelText:SetFont(levelText:GetFont(), 11, "OUTLINE")
    return levelText
end

-- Create item row container (контейнер для строки с типом предмета и иконками)
function ns:CreateItemRow(parent, itemType, items, x, y)
    local rowFrame = CreateFrame("Frame", nil, parent)
    rowFrame:SetSize(600, 50) -- Уменьшаем высоту, так как названия предметов убраны
    rowFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    
    -- Фон строки в стиле Details!
    local bg = rowFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.16, 0.16, 0.16, 0.9) -- Темно-серый фон
    
    -- Заголовок типа предмета (слева)
    local typeHeader = ns:CreateItemTypeHeader(rowFrame, itemType, 10, -10)
    
    -- Текст уровня предмета (под заголовком)
    local levelText = ns:CreateItemLevelText(rowFrame, "662", 10, -30) -- Пока статичный уровень
    
    -- Контейнер для иконок предметов (справа)
    local iconContainer = CreateFrame("Frame", nil, rowFrame)
    iconContainer:SetSize(300, 40) -- Уменьшаем высоту, так как названия предметов убраны
    iconContainer:SetPoint("RIGHT", rowFrame, "RIGHT", -10, 0)
    
    -- Создаем иконки предметов в ряд
    local iconSize = 40
    local iconSpacing = 5
    local startX = 0
    
    for i, item in ipairs(items) do
        local itemBtn = ns:CreateItemButton(iconContainer, item)
        itemBtn:SetSize(iconSize, iconSize)
        itemBtn:SetPoint("LEFT", iconContainer, "LEFT", startX, 0)
        itemBtn:Show()
        
        startX = startX + iconSize + iconSpacing
    end
    
    return rowFrame
end