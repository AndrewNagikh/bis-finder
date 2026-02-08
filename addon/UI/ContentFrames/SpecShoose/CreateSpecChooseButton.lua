local ADDON_NAME, ns = ...

local function CreateSpecChooseButton(parent, onClickCallback, yOffset, spec)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(280, 45)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    
    -- Создаем текстуру для кастомного фона (выбранное состояние)
    local customTexture = button:CreateTexture(nil, "BACKGROUND")
    local selectedRoleId = ns:GetSelectedRoleId()
    local texturePath = ns.specMap[selectedRoleId][spec].texture
    
    if texturePath == "" or not texturePath then
        texturePath = "Interface\\Buttons\\WHITE8x8" -- fallback
    end
    
    customTexture:SetAllPoints(button)
    customTexture:SetTexture(texturePath)
    
    button.customTexture = customTexture
    button.customTexture:Show()
    
    -- Обработчик клика
    button:SetScript("OnClick", function(self)
        if not self.isDisabled and onClickCallback then
            onClickCallback(self)
        end
    end)
    
    -- Делаем кнопку кликабельной
    button:EnableMouse(true)
    button:Show()
    return button
end

function ns:CreateButtonList(parent)
    -- Очищаем существующие кнопки специализаций
    if ns.specButtons then
        for _, button in pairs(ns.specButtons) do
            button:Hide()
        end
    end
    
    local roleId = ns:GetSelectedRoleId()
    local selectedRole = ns.specMap[roleId]
    if not selectedRole then
        return
    end
    
    local specButtons = {}
    local i = 1
    -- Используем order массив для правильного порядка
    for _, specId in ipairs(selectedRole.order) do
        local specData = selectedRole[specId]
        if specData and type(specData) == "table" then
            local yOffset = -((i - 1) * (45 + 22))
            local button = CreateSpecChooseButton(parent, function()
                -- Обновляем специализацию
                if ns.UpdateSelectedSpecId then
                    ns:UpdateSelectedSpecId(specId)
                end
                -- Обновляем заголовок с текстурой специализации
                if ns.UpdateMainContentTitleWithSpec then
                    ns:UpdateMainContentTitleWithSpec(specId)
                end
                -- Скрываем кнопки специализаций
                if ns.specButtons then
                    for _, btn in pairs(ns.specButtons) do
                        btn:Hide()
                    end
                end
                -- Скрываем меню выбора роли
                if ns.RoleShooseFrame then
                    ns.RoleShooseFrame:Hide()
                end
                -- Показываем ItemSourceChooseFrame
                if ns.CreateItemSourceChooseFrame and ns.MainContentFrame then
                    ns:CreateItemSourceChooseFrame(ns.MainContentFrame)
                end
                -- Показываем контент предметов в зависимости от источника
                local selectedSourceId = ns:GetSelectedSourceId()
                if selectedSourceId == "archon" then
                    if ns.CreateArchonContent then
                        ns:CreateArchonContent()
                    end
                else
                    if ns.CreateIcyVeinsContent then
                        ns:CreateIcyVeinsContent()
                    end
                end
            end, yOffset, specId)
            specButtons[specId] = button
            i = i + 1
        end
    end
    
    -- Сохраняем ссылку на кнопки специализаций
    ns.specButtons = specButtons
    
    -- Обновляем размер скролл-контента
    if ns.UpdateScrollContent then
        ns:UpdateScrollContent()
    end
    if ns.SetArchonPriorityStatsVisible then
        ns:SetArchonPriorityStatsVisible(false)
    end
end