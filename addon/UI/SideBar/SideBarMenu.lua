local ADDON_NAME, ns = ...

-- Функция для проверки наличия данных для источника
function ns:HasDataForSource(sourceId)
    if not ns.IcyVeinsData then
        return false
    end
    
    -- Для IcyVeins всегда есть данные (в itemSourceId: overroll, mythic, raid)
    if sourceId == "icyveins" then
        return true
    end
    
    -- Для других источников (например, Archon) пока нет данных
    if sourceId == "archon" then
        return false
    end
    
    return false
end

function ns:CreateSideBarMenu(parent)
    local menu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    menu:SetSize(130, 576)
    menu:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -66)
    menu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 3, bottom = 3 }
    })
    menu:SetBackdropColor(0.10, 0.10, 0.12, 0)

    -- Создаем кнопки в стиле с скриншота
    local buttons = {}
    
    -- Создаем кнопки динамически
    local buttonConfigs = {
        { id = "icyveins", text = "Icy Veins" },
        { id = "archon", text = "Archon" }
    }
    
    for _, config in ipairs(buttonConfigs) do
        local buttonData = {
            id = config.id,
            text = config.text,
            onClick = function(button)
                -- Сбрасываем все кнопки
                for _, btn in pairs(ns.sideBarButtons) do
                    btn:SetSelected(false)
                end
                -- Выбираем текущую кнопку
                button:SetSelected(true)
                -- Обновляем источник
                if ns.UpdateMainContentSource then
                    ns:UpdateMainContentSource(config.id)
                end
                -- Обновляем заголовок
                if ns.UpdateMainContentTitle then
                    ns:UpdateMainContentTitle()
                end
                
                -- Проверяем наличие данных для источника
                if ns:HasDataForSource(config.id) then
                    -- Есть данные - показываем обычный интерфейс
                    -- Показываем меню выбора роли
                    if ns.RoleShooseFrame then
                        ns.RoleShooseFrame:Show()
                    end
                    -- Скрываем ItemSourceChooseFrame если он есть
                    if ns.ItemSourceChooseFrame then
                        ns.ItemSourceChooseFrame:Hide()
                    end
                    -- Скрываем контент предметов если он есть
                    if ns.itemRows then
                        for _, row in pairs(ns.itemRows) do
                            row:Hide()
                        end
                    end
                    if ns.noDataMessage then
                        ns.noDataMessage:Hide()
                    end
                    -- Показываем кнопки специализаций
                    if ns.CreateButtonList and ns.ContentFrame then
                        ns:CreateButtonList(ns.ContentFrame)
                    end
                else
                    -- Нет данных - показываем сообщение "нет данных"
                    -- Скрываем все остальные элементы
                    if ns.RoleShooseFrame then
                        ns.RoleShooseFrame:Hide()
                    end
                    if ns.ItemSourceChooseFrame then
                        ns.ItemSourceChooseFrame:Hide()
                    end
                    if ns.specButtons then
                        for _, btn in pairs(ns.specButtons) do
                            btn:Hide()
                        end
                    end
                    if ns.itemRows then
                        for _, row in pairs(ns.itemRows) do
                            row:Hide()
                        end
                    end
                    -- Показываем сообщение "нет данных"
                    if ns.ContentFrame then
                        ns:ShowNoDataMessage(ns.ContentFrame)
                    end
                end
            end
        }
        table.insert(buttons, buttonData)
    end
    
    -- Создаем группу кнопок
    ns.sideBarButtons = ns:CreateSideBarButtonGroup(menu, buttons)
    
    -- Устанавливаем кнопку по умолчанию как выбранную
    local defaultSourceId = ns:GetSelectedSourceId()
    if ns.sideBarButtons[defaultSourceId] then
        ns.sideBarButtons[defaultSourceId]:SetSelected(true)
        
        -- Проверяем наличие данных для источника по умолчанию
        if not ns:HasDataForSource(defaultSourceId) then
            -- Нет данных - показываем сообщение "нет данных"
            if ns.ContentFrame then
                ns:ShowNoDataMessage(ns.ContentFrame)
            end
        end
    end

    menu:Show()
    return menu
end