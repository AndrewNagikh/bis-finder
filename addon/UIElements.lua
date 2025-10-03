local ADDON_NAME, ns = ...

-- Create an item button
function ns:CreateItemButton(parent, itemInfo)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 40)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    local id = tonumber(itemInfo.itemId)
    if id then
        local item = Item:CreateFromItemID(id)
        item:ContinueOnItemLoad(function()
            local tex = item:GetItemIcon()
            if tex then icon:SetTexture(tex) end
            local name = item:GetItemName()
            if name then
                if not btn.nameText then
                    btn.nameText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    btn.nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
                    btn.nameText:SetWidth(150)
                    btn.nameText:SetJustifyH("LEFT")
                    btn.nameText:SetTextColor(1,1,1)
                    btn.nameText:SetFont(btn.nameText:GetFont(), 14, "OUTLINE")
                end
                btn.nameText:SetText(name)
            end
        end)
    end

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:"..itemInfo.itemId)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFF00Source:|r "..itemInfo.source,1,1,1,true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", function(self, btn)
        if btn=="LeftButton" and IsShiftKeyDown() then
            local _, link = GetItemInfo(itemInfo.itemId)
            if link and ChatEdit_GetActiveWindow() then
                ChatEdit_InsertLink(link)
            end
        end
    end)

    return btn
end

-- Create a header for item type
function ns:CreateItemTypeHeader(parent, text, x, y)
    local hdr = parent:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    hdr:SetText(text)
    hdr:SetTextColor(1,0.82,0)
    hdr:SetFont(hdr:GetFont(), 16, "OUTLINE")
    return hdr
end