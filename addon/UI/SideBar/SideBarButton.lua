local ADDON_NAME, ns = ...

function ns:CreateSideBarButton(parent, text, onClickCallback, yOffset, isDisabled)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(120, 30)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset or 0)
    
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Создаем текстуру для кастомного фона (выбранное состояние)
    local customTexture = button:CreateTexture(nil, "BACKGROUND")
    customTexture:SetAllPoints(button)
    customTexture:SetTexture("Interface\\AddOns\\BiSFinder\\Textures\\button_selected.png") -- Путь к PNG файлу
    customTexture:Hide() -- Скрываем по умолчанию
    button.customTexture = customTexture
    
    -- Создаем текстуру для hover состояния
    local hoverTexture = button:CreateTexture(nil, "BACKGROUND")
    hoverTexture:SetAllPoints(button)
    hoverTexture:SetTexture("Interface\\AddOns\\BiSFinder\\Textures\\button_hovered.png") -- Путь к PNG файлу
    hoverTexture:Hide() -- Скрываем по умолчанию
    button.hoverTexture = hoverTexture
    
    -- Состояния кнопки
    button.isSelected = false
    button.isDisabled = isDisabled or false
    
    -- Текст кнопки
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER", button, "CENTER", 0, 0)
    buttonText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    buttonText:SetText(text)
    
    -- Функция для обновления состояния кнопки
    local function updateButtonState()
        if button.isDisabled then
            -- Заблокированная кнопка: прозрачный фон, серый текст
            button:SetBackdropColor(0, 0, 0, 0)
            button.customTexture:Hide()
            button.hoverTexture:Hide()
            buttonText:SetTextColor(0.427, 0.427, 0.427, 1) -- #6D6D6D
        elseif button.isSelected then
            -- Выбранная кнопка: используем кастомную PNG текстуру
            button:SetBackdropColor(0, 0, 0, 0) -- Делаем backdrop прозрачным
            button.customTexture:Show() -- Показываем PNG текстуру
            button.hoverTexture:Hide()
            buttonText:SetTextColor(1, 1, 1, 1) -- белый
        else
            -- Дефолтная кнопка: прозрачный фон, белый текст
            button:SetBackdropColor(0, 0, 0, 0)
            button.customTexture:Hide()
            button.hoverTexture:Hide()
            buttonText:SetTextColor(1, 1, 1, 1) -- белый
        end
    end
    
    -- Обработчики событий для эффектов наведения
    button:SetScript("OnEnter", function(self)
        if not self.isDisabled then
            if not self.isSelected then
                -- При наведении: используем PNG текстуру
                self:SetBackdropColor(0, 0, 0, 0) -- Делаем backdrop прозрачным
                self.hoverTexture:Show() -- Показываем hover PNG текстуру
                buttonText:SetTextColor(1, 1, 1, 1) -- белый
            end
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        if not self.isDisabled then
            updateButtonState()
        end
    end)
    
    -- Обработчик клика
    button:SetScript("OnClick", function(self)
        if not self.isDisabled and onClickCallback then
            onClickCallback(self)
        end
    end)
    
    -- Делаем кнопку кликабельной
    button:EnableMouse(not button.isDisabled)

    -- Функции для управления состоянием
    button.SetSelected = function(self, selected)
        self.isSelected = selected
        updateButtonState()
    end
    
    button.SetDisabled = function(self, disabled)
        self.isDisabled = disabled
        self:EnableMouse(not disabled)
        updateButtonState()
    end
    
    -- Инициализируем состояние
    updateButtonState()
    
    return button
end

-- Функция для создания группы кнопок с автоматическим позиционированием
function ns:CreateSideBarButtonGroup(parent, buttons)
    local buttonGroup = {}
    local startY = 0
    local buttonHeight = 30
    local gap = 10
    
    for i, buttonData in ipairs(buttons) do
        local yOffset = startY - ((i - 1) * (buttonHeight + gap)) -- высота кнопки + gap между кнопками
        local button = ns:CreateSideBarButton(parent, buttonData.text, buttonData.onClick, yOffset, buttonData.isDisabled)
        buttonGroup[buttonData.id or i] = button
    end
    
    return buttonGroup
end
