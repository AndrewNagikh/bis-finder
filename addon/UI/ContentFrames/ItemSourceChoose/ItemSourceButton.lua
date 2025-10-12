local ADDON_NAME, ns = ...

function ns:CreateItemSourceButton(parent, text, onClickCallback, xOffset)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(130, 30)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset or 0, -15)

    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })

    -- Состояния кнопки
    button.isSelected = false

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

    -- Текст кнопки (без иконки)
    local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetPoint("CENTER", button, "CENTER", 0, 0)
    buttonText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    buttonText:SetText(text)

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
