local ADDON_NAME, ns = ...

local talentsWindow = nil
local editBox = nil

local function GetParentFrame()
    return MainFrame or UIParent
end

local function CreateTalentsWindow()
    if talentsWindow then
        return talentsWindow
    end
    local parentFrame = GetParentFrame()
    
    talentsWindow = CreateFrame("Frame", "BiSFinderTalentsWindow", parentFrame, "BackdropTemplate")
    talentsWindow:SetSize(500, 160)
    talentsWindow:SetPoint("CENTER", parentFrame, "CENTER", 0, 0)
    talentsWindow:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    talentsWindow:SetBackdropColor(0.3, 0.3, 0.3, 1)
    talentsWindow:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    talentsWindow:SetFrameStrata(parentFrame:GetFrameStrata())
    talentsWindow:SetFrameLevel(parentFrame:GetFrameLevel() + 50)
    talentsWindow:Hide()
    
    -- Заголовок
    local titleText = talentsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOP", talentsWindow, "TOP", 0, -15)
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    titleText:SetTextColor(1, 1, 1, 1)
    titleText:SetText("Talents String")
    
    -- EditBox
    editBox = CreateFrame("EditBox", nil, talentsWindow, "LargeInputBoxTemplate")
    editBox:SetSize(460, 150)
    editBox:SetPoint("TOP", talentsWindow, "TOP", 0, -50)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetScript("OnEscapePressed", function(self)
        talentsWindow:Hide()
        self:ClearFocus()
    end)
    
    -- Инструкция
    local instructionText = talentsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructionText:SetPoint("TOP", editBox, "BOTTOM", 0, -10)
    instructionText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
    instructionText:SetTextColor(0.8, 0.8, 0.8, 1)
    instructionText:SetText("Ctrl+A to select all, then Ctrl+C to copy")
    
    -- Кнопка закрытия
    local closeButton = CreateFrame("Button", nil, talentsWindow, "GameMenuButtonTemplate")
    closeButton:SetSize(100, 30)
    closeButton:SetPoint("BOTTOM", talentsWindow, "BOTTOM", 0, 10)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        talentsWindow:Hide()
        editBox:ClearFocus()
    end)
    
    return talentsWindow
end

local function ShowTalentsWindow(talentsString)
    if not talentsWindow then
        CreateTalentsWindow()
    end
    
    if editBox then
        editBox:SetText(talentsString)
    end
    
    local parentFrame = GetParentFrame()
    talentsWindow:SetFrameStrata(parentFrame:GetFrameStrata())
    talentsWindow:SetFrameLevel(parentFrame:GetFrameLevel() + 50)
    talentsWindow:Show()
    
    if editBox then
        editBox:SetFocus()
        C_Timer.After(0.1, function()
            if editBox and editBox:HasFocus() then
                editBox:HighlightText()
            end
        end)
    end
end

function ns:CreateCopyTalentsButton(parent, specTexture)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(140, 30)
    button:SetPoint("LEFT", specTexture, "RIGHT", 10, 0)
    button:Hide()
    
    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(button)
    texture:SetTexture("Interface\\AddOns\\BiSFinder\\Textures\\button_hovered.png")
    
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    text:SetTextColor(1, 1, 1, 1)
    text:SetText("Copy Talents")
    
    button:SetScript("OnClick", function()
        local selectedSourceId = ns:GetSelectedSourceId()
        if selectedSourceId ~= "archon" then
            print("Error: Not Archon source")
            return
        end
        
        local selectedSpecId = ns:GetSelectedSpecId()
        local selectedRoleId = ns:GetSelectedRoleId()
        local selectedItemSourceId = ns:GetSelectedItemSourceId()
        
        local itemSourceData = ns.ArchonData[selectedItemSourceId]
        
        local roleData = itemSourceData[selectedRoleId]
        
        local specName = ns.specMap[selectedRoleId][selectedSpecId].name
        
        local specData = roleData[specName]
        
        local talents = specData.talents
        if talents and talents ~= "" then
            ShowTalentsWindow(talents)
        else
            print("Error: No talents string found")
        end
    end)
    
    return button
end
