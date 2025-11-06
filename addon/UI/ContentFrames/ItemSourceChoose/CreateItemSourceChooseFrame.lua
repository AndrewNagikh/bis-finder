local ADDON_NAME, ns = ...

function ns:CreateItemSourceChooseFrame(parent)
    if not ns.ItemSourceChooseFrame then
        ns.ItemSourceChooseFrame = CreateFrame("Frame", "ItemSourceChooseFrame", parent, "BackdropTemplate")
        ns.ItemSourceChooseFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, -64)
        ns.ItemSourceChooseFrame:SetSize(510, 60)
        ns.ItemSourceChooseFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", insets = { left = 23, right = 23, top = 10, bottom = 10 } })
        ns.ItemSourceChooseFrame:SetBackdropColor(0.294, 0.294, 0.294, 1)
    end

    local ItemSourceChooseFrame = ns.ItemSourceChooseFrame

    -- Получаем выбранный источник для определения каких кнопок показывать
    local selectedSourceId = ns:GetSelectedSourceId()
    
    -- Определяем конфигурацию кнопок в зависимости от источника
    local buttonConfigs = {}
    if selectedSourceId == "archon" then
        buttonConfigs = {
            { id = "mythic", text = "Mythic+" },
            { id = "raid", text = "Raid" }
        }
    else
        -- Для IcyVeins и других источников по умолчанию
        buttonConfigs = {
            { id = "overroll", text = "Overroll" },
            { id = "mythic", text = "Mythic+" },
            { id = "raid", text = "Raid" }
        }
    end

    -- Скрываем все существующие кнопки
    if ns.itemSourceButtons then
        for _, btn in pairs(ns.itemSourceButtons) do
            btn:Hide()
        end
    else
        ns.itemSourceButtons = {}
    end

    -- Определяем ширину кнопок в зависимости от источника
    local buttonWidth = (selectedSourceId == "archon") and 200 or 130
    local buttonSpacing = 10
    
    -- Создаем или показываем нужные кнопки
    for i, config in ipairs(buttonConfigs) do
        local button = ns.itemSourceButtons[config.id]
        
        if not button then
            -- Создаем новую кнопку если её еще нет
            local xOffset = 50 + ((i - 1) * (buttonWidth + buttonSpacing))
            button = ns:CreateItemSourceButton(ItemSourceChooseFrame, config.text, function(btn)
                -- Сбрасываем все кнопки источников предметов
                for _, b in pairs(ns.itemSourceButtons) do
                    if b:IsShown() then
                        b:SetSelected(false)
                    end
                end
                -- Выбираем текущую кнопку
                btn:SetSelected(true)
                -- Обновляем источник предметов
                if ns.UpdateSelectedItemSource then
                    ns:UpdateSelectedItemSource(config.id)
                end
                -- Обновляем контент предметов в зависимости от источника
                local currentSourceId = ns:GetSelectedSourceId()
                if currentSourceId == "archon" then
                    if ns.CreateArchonContent then
                        ns:CreateArchonContent()
                    end
                else
                    if ns.CreateIcyVeinsContent then
                        ns:CreateIcyVeinsContent()
                    end
                end
            end, xOffset)
            
            ns.itemSourceButtons[config.id] = button
        else
            -- Обновляем размер существующей кнопки если источник изменился
            button:SetSize(buttonWidth, 30)
        end
        
        -- Показываем кнопку и устанавливаем правильную позицию
        button:Show()
        local xOffset = 50 + ((i - 1) * (buttonWidth + buttonSpacing))
        button:ClearAllPoints()
        button:SetPoint("LEFT", ItemSourceChooseFrame, "LEFT", xOffset, 0)
    end

    -- Устанавливаем кнопку по умолчанию как выбранную
    local defaultItemSourceId = ns:GetSelectedItemSourceId()
    -- Проверяем что выбранный источник поддерживает выбранный itemSourceId
    local isValid = false
    for _, config in ipairs(buttonConfigs) do
        if config.id == defaultItemSourceId then
            isValid = true
            break
        end
    end
    
    -- Если выбранный itemSourceId не валиден для текущего источника, выбираем первый доступный
    if not isValid and #buttonConfigs > 0 then
        defaultItemSourceId = buttonConfigs[1].id
        if ns.UpdateSelectedItemSource then
            ns:UpdateSelectedItemSource(defaultItemSourceId)
        end
    end
    
    -- Сбрасываем выбор всех кнопок
    for _, btn in pairs(ns.itemSourceButtons) do
        if btn:IsShown() then
            btn:SetSelected(false)
        end
    end
    
    -- Выбираем нужную кнопку
    if ns.itemSourceButtons[defaultItemSourceId] and ns.itemSourceButtons[defaultItemSourceId]:IsShown() then
        ns.itemSourceButtons[defaultItemSourceId]:SetSelected(true)
    end

    ItemSourceChooseFrame:Show()
    return ItemSourceChooseFrame
end
