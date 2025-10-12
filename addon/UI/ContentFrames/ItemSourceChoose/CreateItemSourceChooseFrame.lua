local ADDON_NAME, ns = ...

function ns:CreateItemSourceChooseFrame(parent)
    if not ns.ItemSourceChooseFrame then
        ns.ItemSourceChooseFrame = CreateFrame("Frame", "ItemSourceChooseFrame", parent, "BackdropTemplate")
        ns.ItemSourceChooseFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, -54)
        ns.ItemSourceChooseFrame:SetSize(510, 60)
        ns.ItemSourceChooseFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", insets = { left = 23, right = 23, top = 10, bottom = 10 } })
        ns.ItemSourceChooseFrame:SetBackdropColor(0.294, 0.294, 0.294, 1)
    end

    local ItemSourceChooseFrame = ns.ItemSourceChooseFrame

    if not ns.itemSourceButtons then
        local itemSourceButtons = {}
        local buttonConfigs = {
            { id = "overroll", text = "Overroll" },
            { id = "mythic", text = "Mythic+" },
            { id = "raid", text = "Raid" }
        }

        for i, config in ipairs(buttonConfigs) do
            local xOffset = 50 + ((i - 1) * (130 + 10))
            local button = ns:CreateItemSourceButton(ItemSourceChooseFrame, config.text, function(button)
                -- Сбрасываем все кнопки источников предметов
                for _, btn in pairs(ns.itemSourceButtons) do
                    btn:SetSelected(false)
                end
                -- Выбираем текущую кнопку
                button:SetSelected(true)
                -- Обновляем источник предметов
                if ns.UpdateSelectedItemSource then
                    ns:UpdateSelectedItemSource(config.id)
                end
                -- Обновляем контент предметов
                if ns.CreateIcyVeinsContent then
                    ns:CreateIcyVeinsContent()
                end
            end, xOffset)

            itemSourceButtons[config.id] = button
        end

        -- Сохраняем ссылку на кнопки источников предметов
        ns.itemSourceButtons = itemSourceButtons

        -- Устанавливаем кнопку по умолчанию как выбранную
        local defaultItemSourceId = ns:GetSelectedItemSourceId()
        if ns.itemSourceButtons[defaultItemSourceId] then
            ns.itemSourceButtons[defaultItemSourceId]:SetSelected(true)
        end
    end

    ItemSourceChooseFrame:Show()
    return ItemSourceChooseFrame
end
