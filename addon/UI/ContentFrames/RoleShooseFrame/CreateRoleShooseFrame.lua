local ADDON_NAME, ns = ...

function ns:CreateRoleShooseFrame(parent)
    if not ns.RoleShooseFrame then
        ns.RoleShooseFrame = CreateFrame("Frame", "RoleShooseFrame", parent, "BackdropTemplate")
        ns.RoleShooseFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, -64)
        ns.RoleShooseFrame:SetSize(510, 60)
        ns.RoleShooseFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", insets = { left = 23, right = 23, top = 10, bottom = 10 } })
        ns.RoleShooseFrame:SetBackdropColor(0.294, 0.294, 0.294, 1)
    end
    
    local RoleShooseFrame = ns.RoleShooseFrame

    -- Создаем кнопки ролей только если они еще не созданы
    if not ns.roleButtons then
        local roleButtons = {}
        local buttonConfigs = {
            { id = "tank", text = "Tank", icon = "Interface\\AddOns\\BiSFinder\\Textures\\tank.png" },
            { id = "healer", text = "Healer", icon = "Interface\\AddOns\\BiSFinder\\Textures\\healer.png" },
            { id = "dps", text = "DPS", icon = "Interface\\AddOns\\BiSFinder\\Textures\\dps.png" }
        }
        
        for i, config in ipairs(buttonConfigs) do
            local xOffset = 50 + ((i - 1) * (130 + 10)) -- 10px отступ + (ширина кнопки + gap) * индекс
            local button = ns:CreateRoleButton(RoleShooseFrame, config.text, function(button)
                -- Сбрасываем все кнопки ролей
                for _, btn in pairs(ns.roleButtons) do
                    btn:SetSelected(false)
                end
                -- Выбираем текущую кнопку
                button:SetSelected(true)
                -- Обновляем роль
                if ns.UpdateSelectedRole then
                    ns:UpdateSelectedRole(config.id)
                end
                -- Обновляем кнопки специализаций
                if ns.CreateButtonList and ns.ContentFrame then
                    ns:CreateButtonList(ns.ContentFrame)
                end
            end, xOffset, config.icon)
            
            roleButtons[config.id] = button
        end
        
        -- Сохраняем ссылку на кнопки ролей
        ns.roleButtons = roleButtons
        
        -- Устанавливаем кнопку по умолчанию как выбранную
        local defaultRoleId = ns:GetSelectedRoleId()
        if ns.roleButtons[defaultRoleId] then
            ns.roleButtons[defaultRoleId]:SetSelected(true)
        end
    end

    RoleShooseFrame:Show()
    return RoleShooseFrame
end