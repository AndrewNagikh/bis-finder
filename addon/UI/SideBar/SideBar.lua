local ADDON_NAME, ns = ...

function ns:CreateSideBar(parentFrame)
    local SideBar = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    SideBar:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
    SideBar:SetSize(150, 650)
    SideBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", insets = { left = 10, right = 10, top = 20, bottom = 20 } })
    SideBar:SetBackdropColor(0.10, 0.10, 0.12, 0)
    
    local rightBorder = CreateFrame("Frame", nil, SideBar, "BackdropTemplate")
    rightBorder:SetPoint("TOPRIGHT", SideBar, "TOPRIGHT", 0, 0)
    rightBorder:SetPoint("BOTTOMRIGHT", SideBar, "BOTTOMRIGHT", 0, 0)
    rightBorder:SetWidth(1)
    rightBorder:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    rightBorder:SetBackdropColor(0.278, 0.275, 0.275, 1)
    
    local title = SideBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", SideBar, "TOPLEFT", 10, -20)
    title:SetTextColor(1, 1, 1, 1)
    title:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
    title:SetText("BiSFinder")

    ns:CreateSideBarMenu(SideBar)
    SideBar:Show()
    
    return SideBar
end