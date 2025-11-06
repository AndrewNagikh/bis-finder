local ADDON_NAME, ns = ...

function ns:CreateCloseButton(parent)
    -- Создаем минималистичную кнопку закрытия в правом верхнем углу
    local closeButton = CreateFrame("Button", nil, parent, "BackdropTemplate")
    closeButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
    closeButton:SetSize(20, 20)
    closeButton:SetFrameLevel(parent:GetFrameLevel() + 100) -- Очень высокий уровень, чтобы быть поверх всего
    closeButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    closeButton:SetBackdropColor(0, 0, 0, 0) -- Прозрачный фон
    closeButton:SetBackdropBorderColor(0.294, 0.294, 0.294, 1) -- Серый крестик
    
    -- Создаем крестик из двух линий
    local line1 = closeButton:CreateTexture(nil, "OVERLAY")
    line1:SetTexture("Interface\\Buttons\\WHITE8x8")
    line1:SetColorTexture(0.294, 0.294, 0.294, 1)
    line1:SetSize(12, 1)
    line1:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    line1:SetRotation(math.rad(45))
    
    local line2 = closeButton:CreateTexture(nil, "OVERLAY")
    line2:SetTexture("Interface\\Buttons\\WHITE8x8")
    line2:SetColorTexture(0.294, 0.294, 0.294, 1)
    line2:SetSize(12, 1)
    line2:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    line2:SetRotation(math.rad(-45))
    
    -- Обработчики событий для hover эффекта
    closeButton:SetScript("OnEnter", function(self)
        line1:SetColorTexture(0.5, 0.5, 0.5, 1) -- Светлее при наведении
        line2:SetColorTexture(0.5, 0.5, 0.5, 1)
    end)
    
    closeButton:SetScript("OnLeave", function(self)
        line1:SetColorTexture(0.294, 0.294, 0.294, 1) -- Возвращаем исходный цвет
        line2:SetColorTexture(0.294, 0.294, 0.294, 1)
    end)
    
    closeButton:SetScript("OnClick", function()
        parent:Hide()
    end)
    
    closeButton:EnableMouse(true)
    closeButton:RegisterForClicks("AnyUp") -- Регистрируем все клики
    
    return closeButton
end
