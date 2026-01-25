local ADDON_NAME, ns = ...

function ns:CreateItemRow(parent, itemType, items, yOffset)
    -- Проверяем выбранный источник для определения ширины строки
    local selectedSourceId = ns:GetSelectedSourceId()
    local showEnchantments = (selectedSourceId == "archon")
    local rowWidth = showEnchantments and 557 or 477 -- Увеличиваем ширину для Archon
    
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(rowWidth, 60)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    
    -- Создаем нижнюю границу
    local border = row:CreateTexture(nil, "OVERLAY")
    border:SetSize(rowWidth, 1)
    border:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    border:SetColorTexture(0.294, 0.294, 0.294, 1) -- #4B4B4B
    
    -- Создаем текст itemType слева
    local itemTypeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemTypeText:SetPoint("LEFT", row, "LEFT", 5, 0)
    itemTypeText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    itemTypeText:SetTextColor(1, 1, 1, 1)
    itemTypeText:SetText(itemType)
    
    -- Создаем кнопки предметов справа
    -- Для Archon нужно учитывать место для enchantments (примерно 80px слева от каждой иконки)
    local enchantmentWidth = showEnchantments and 80 or 0
    local buttonX = rowWidth - (50 * #items) - 5 -- Позиция справа, учитывая количество кнопок
    if showEnchantments then
        buttonX = buttonX - (enchantmentWidth * #items) -- Учитываем место для enchantments
    end
    
    for i, item in ipairs(items) do
        local itemButtonX = buttonX + ((i - 1) * 50)
        
        -- Если нужно показывать enchantments, создаем область для них слева от кнопки
        if showEnchantments and item.enchantments and #item.enchantments > 0 then
            local enchantmentFrame = CreateFrame("Frame", nil, row)
            enchantmentFrame:SetSize(70, 60)
            enchantmentFrame:SetPoint("LEFT", row, "LEFT", itemButtonX - 75, 0)
            
            -- Создаем текст "Enchantments"
            local enchantmentLabel = enchantmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            enchantmentLabel:SetPoint("TOPLEFT", enchantmentFrame, "TOPLEFT", -40, -2)
            enchantmentLabel:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
            enchantmentLabel:SetTextColor(0.8, 0.8, 0.8, 1)
            enchantmentLabel:SetText("Enchantments")
            
            -- Создаем иконки enchantments
            local iconSize = 25
            local iconGap = 3
            local startY = -20
            local iconsPerRow = 4
            local rowNum = 0
            local colNum = 0
            
            for j, enchantId in ipairs(item.enchantments) do
                if enchantId and enchantId ~= "" then
                    local iconFrame = CreateFrame("Frame", nil, enchantmentFrame)
                    iconFrame:SetSize(iconSize, iconSize)
                    local xPos = colNum * (iconSize + iconGap) - 40
                    local yPos = startY - (rowNum * (iconSize + iconGap))
                    iconFrame:SetPoint("TOPLEFT", enchantmentFrame, "TOPLEFT", xPos, yPos)
                    
                    -- Создаем текстуру иконки
                    local iconTexture = iconFrame:CreateTexture(nil, "OVERLAY")
                    iconTexture:SetAllPoints(iconFrame)
                    iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback
                    
                    -- Пытаемся загрузить иконку по ID
                    local enchantTexture = GetItemIcon(enchantId)
                    if enchantTexture then
                        iconTexture:SetTexture(enchantTexture)
                    end
                    
                    -- Создаем тултип для enchantment
                    iconFrame:EnableMouse(true)
                    iconFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        local itemLink = "item:" .. enchantId
                        GameTooltip:SetHyperlink(itemLink)
                        GameTooltip:Show()
                    end)
                    iconFrame:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                    
                    colNum = colNum + 1
                    if colNum >= iconsPerRow then
                        colNum = 0
                        rowNum = rowNum + 1
                    end
                end
            end
        end
        
        -- Создаем кнопку предмета
        local button = CreateFrame("Button", nil, row, "SecureActionButtonTemplate")
        button:SetSize(50, 50)
        button:SetPoint("LEFT", row, "LEFT", itemButtonX, 0)
        
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
            
            -- Показываем информацию о предмете
            local itemLink = "item:" .. (item.itemId or "")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()

            -- Создаем второй тултип с информацией о боссе и моделью
            if item.itemId and ns.RaidLootData then
                local itemIdNum = tonumber(item.itemId)
                
                if itemIdNum and ns.RaidLootData[itemIdNum] then
                    local lootData = ns.RaidLootData[itemIdNum]
                    
                    C_Timer.After(0.05, function()
                        if GameTooltip:IsOwned(self) then
                            -- Создаем второй тултип
                            local bossTooltip = ns.BossTooltip
                            if not bossTooltip then
                                bossTooltip = CreateFrame("GameTooltip", "BiSFinderBossTooltip", UIParent, "GameTooltipTemplate")
                                bossTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                                ns.BossTooltip = bossTooltip
                            end
                            
                            bossTooltip:ClearLines()
                            bossTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                            
                            -- Определяем, что показывать: Raid или Dungeon
                            local instanceName = nil
                            local bossName = nil
                            local journalEncounterID = nil
                            local instanceID = nil
                            
                            if lootData.dungeonName then
                                instanceName = lootData.dungeonName
                                bossName = lootData.dungeonBoss
                                journalEncounterID = lootData.journalEncounterID
                                instanceID = lootData.instanceID
                                bossTooltip:AddLine("|cffffd700Подземелье: |r|cff00ff00" .. instanceName .. "|r", 1, 1, 1, 1)
                            elseif lootData.raidName then
                                instanceName = lootData.raidName
                                bossName = lootData.bossName
                                journalEncounterID = lootData.journalEncounterID
                                instanceID = lootData.instanceID
                                bossTooltip:AddLine("|cffffd700Рейд: |r|cff00ff00" .. instanceName .. "|r", 1, 1, 1, 1)
                            end
                            
                            -- Добавляем строку с именем босса
                            if bossName then
                                bossTooltip:AddLine("|cffffd700Босс:|r |cff00ff00" .. bossName .. "|r", 1, 1, 1, 1)
                                
                                -- Показываем модельку босса посередине тултипа
                                if journalEncounterID and instanceID then
                                    EJ_SelectInstance(instanceID)
                                    local id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(1, journalEncounterID)
                                    
                                    if displayInfo then
                                        local model = bossTooltip.modelFrame
                                        if not model then
                                            model = CreateFrame("PlayerModel", nil, bossTooltip)
                                            bossTooltip.modelFrame = model
                                        end
                                        
                                        -- Размер модели для тултипа
                                        model:SetSize(150, 150)
                                        
                                        -- Позиционируем модель посередине тултипа
                                        model:SetPoint("TOP", bossTooltip, "TOP", 0, -50)
                                        
                                        model:SetAlpha(1)
                                        model:SetDisplayInfo(displayInfo)
                                        model:SetFacing(0.2)
                                        model:Show()
                                        
                                        -- Добавляем пустые строки для увеличения высоты тултипа
                                        for i = 1, 12 do
                                            bossTooltip:AddLine(" ")
                                        end
                                    end
                                end
                            end
                            
                            bossTooltip:Show()
                            
                            -- Позиционируем второй тултип под основным
                            local tooltipX, tooltipY = GameTooltip:GetCenter()
                            local tooltipHeight = GameTooltip:GetHeight()
                            if tooltipX and tooltipY then
                                bossTooltip:ClearAllPoints()
                                bossTooltip:SetPoint("TOP", GameTooltip, "BOTTOM", 0, -5)
                            end
                        end
                    end)
                end
            end
        end)

        button:SetScript("OnClick", function(self, mouseButton)
            local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent = C_Item.GetItemInfo(item.itemId)
            print(itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent)
        end)
        
        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if ns.BossTooltip then
                ns.BossTooltip:Hide()
                if ns.BossTooltip.modelFrame then
                    ns.BossTooltip.modelFrame:Hide()
                end
            end
        end)
        
        -- Сохраняем данные предмета в кнопке
        button.itemData = item
    end
    
    return row
end
