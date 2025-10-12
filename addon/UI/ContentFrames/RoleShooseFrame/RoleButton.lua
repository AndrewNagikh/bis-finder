local ADDON_NAME, ns = ...

function ns:CreateRoleButton(parent, text, onClickCallback, xOffset, iconPath)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(130, 30)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset or 0, -15)
    
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Состояния кнопки
    button.isSelected = false
    
    -- Иконка кнопки
    local buttonIcon = button:CreateTexture(nil, "OVERLAY")
    buttonIcon:SetSize(25, 25)
    
    -- Вычисляем отступ в зависимости от длины текста
    local btnContentOffset = 5
    if text == "Tank" then
        btnContentOffset = 25
    elseif text == "Healer" then
        btnContentOffset = 15
    elseif text == "DPS" then
        btnContentOffset = 28
    end

    buttonIcon:SetPoint("LEFT", button, "LEFT", btnContentOffset, 0)
    if iconPath then
        buttonIcon:SetTexture(iconPath)
    end
    
    -- Текст кнопки
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("LEFT", buttonIcon, "RIGHT", 10, 0) -- 10px отступ от иконки
    buttonText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    buttonText:SetText(text)
    
    -- Создаем текстуру для кастомного фона (выбранное состояние)
    local customTexture = button:CreateTexture(nil, "BACKGROUND")
    customTexture:SetAllPoints(button)
    customTexture:SetTexture("Interface\\AddOns\\BiSFinder\\Textures\\button_selected.png")
    customTexture:Hide()
    button.customTexture = customTexture
    
    -- Создаем текстуру для hover состояния (синяя)
    local hoverTexture = button:CreateTexture(nil, "BACKGROUND")
    hoverTexture:SetAllPoints(button)
    hoverTexture:SetTexture("Interface\\AddOns\\BiSFinder\\Textures\\button-hovered-blue.png")
    hoverTexture:Hide()
    button.hoverTexture = hoverTexture
    
    -- Функция для обновления состояния кнопки
    local function updateButtonState()
        if button.isSelected then
            -- Выбранная кнопка: используем кастомную PNG текстуру
            button:SetBackdropColor(0, 0, 0, 0)
            button.customTexture:Show()
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
        if not self.isSelected then
            -- При наведении: используем синюю PNG текстуру
            self:SetBackdropColor(0, 0, 0, 0)
            self.hoverTexture:Show()
            buttonText:SetTextColor(1, 1, 1, 1) -- белый
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        updateButtonState()
    end)
    
    -- Обработчик клика
    button:SetScript("OnClick", function(self)
        if onClickCallback then
            onClickCallback(self)
        end
    end)
    
    -- Делаем кнопку кликабельной
    button:EnableMouse(true)
    
    -- Функции для управления состоянием
    button.SetSelected = function(self, selected)
        self.isSelected = selected
        updateButtonState()
    end
    
    -- Инициализируем состояние
    updateButtonState()
    
    return button
end
