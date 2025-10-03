-- BiSFinder Addon for World of Warcraft
-- Refactored to use external data from BiSFinderData.lua without changing existing logic

local ADDON_NAME, ns = ...

-- Ensure the data file is loaded
-- BiSFinderData.lua should define ns.ItemData
-- It must be listed after BiSFinder.lua in the .toc so that ns.ItemData is available
-- Example in .toc:
-- ## SavedVariables: ...
-- BiSFinder.lua
-- BiSFinderData.lua

local BiSFinder = {}
ns.BiSFinder = BiSFinder
-- local UIElements = require("UIElements")

-- Local variables
local mainFrame
local currentRole = "tank"
local currentSpec = nil
local itemButtons = {}
local headerTexts = {}

-- Get player class and spec
local function GetPlayerClassAndSpec()
    local _, playerClass = UnitClass("player")
    local specIndex = GetSpecialization()
    local specName = nil

    if specIndex then
        local id, name = GetSpecializationInfo(specIndex)
        if name then
            local roles = ns:GetAvailableRoles(playerClass)
            for _, role in ipairs(roles) do
                local specs = ns:GetAvailableSpecs(playerClass, role)
                for _, spec in ipairs(specs) do
                    if string.find(spec, name) then
                        specName = spec
                        currentRole = role
                        break
                    end
                end
                if specName then break end
            end
        end
    end

    return playerClass, specName
end

local function CreateSeparator(parent, x, y, width)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.5, 0.5, 0.5, 0.5) -- серый полупрозрачный цвет
    sep:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    sep:SetSize(width, 2) -- высота линии 2 пикселя
    return sep
end

-- Group items by type
local function GroupItemsByType(items)
    local grp, order = {}, {}
    for _, it in ipairs(items) do
        local t = it.itemType
        if string.match(t,"Ring #%d+") then t="Ring"
        elseif string.match(t,"Trinket #%d+") then t="Trinket" end
        if not grp[t] then
            grp[t] = {}
            table.insert(order, t)
        end
        table.insert(grp[t], it)
    end
    return grp, order
end

-- Clear UI of previous buttons and headers
local function ClearUI()
    for _,b in ipairs(itemButtons) do b:Hide() end; wipe(itemButtons)
    for _,h in ipairs(headerTexts) do h:Hide() end; wipe(headerTexts)
end

-- Update displayed items
local function UpdateItemDisplay()
    ClearUI()
    local items = ns.ItemData[currentRole][currentSpec] or {}

    if #items == 0 then
        local no = mainFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
        no:SetPoint("CENTER", mainFrame, "CENTER", 0, -50)
        no:SetText("No data for spec"); no:SetTextColor(1,0,0)
        table.insert(headerTexts, no)
        return
    end

    local grouped, order = GroupItemsByType(items)
    local x0, y0 = 20, -80
    local col, row = 0, 0
    local yOffset = y0

    local buttonSize = 40           -- размер кнопки
    local headerToItemGap = 15       -- отступ между заголовком и кнопками
    local rowGap = 15               -- отступ между строками
    local previousBlockLength = 0
    local rowHeight = buttonSize + rowGap

    local maxR, w = 6,200
    local itemsInCol, maxItemsInCol = 0,6
    local previousItemCount = nil

    for i, t in ipairs(order) do
        local list = grouped[t]
        if itemsInCol + #list > maxItemsInCol then
            itemsInCol = 0
            row = 0
            col = col + 1
            yOffset = y0
        end
        local headerY = yOffset
        local h = ns:CreateItemTypeHeader(mainFrame, t, x0 + col*w, headerY)
        table.insert(headerTexts, h)
        local ix, iy = x0 + col*w, headerY - headerToItemGap
        for i, it in ipairs(list) do
            local btn = ns:CreateItemButton(mainFrame, it)
            local colOffset = math.floor((i - 1) / maxR)
            local rowOffset = (i - 1) % maxR
            local btnX = ix + colOffset * 160
            local btnY = iy - rowOffset * rowHeight
            btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", btnX, btnY)
            btn:Show()
            table.insert(itemButtons, btn)
            itemsInCol = itemsInCol + 1
        end

        yOffset = yOffset - (#list * rowHeight + headerToItemGap)
        row = row + 1
        if row >= maxR  then
            itemsInCol = 0
            row = 0
            col = col + 1
            yOffset = y0
        end
        if #order == i then
            mainFrame:SetWidth((col+1)*w + 40)
        end
    end
end

-- Create role dropdown
local function CreateRoleDropdown()
    local dd = CreateFrame("Frame","BiSFinderRoleDD",mainFrame,"UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT",mainFrame,"TOPLEFT",20,-30)
    UIDropDownMenu_SetWidth(dd,120); UIDropDownMenu_SetText(dd,"TANK")
    local function Init(self)
        local info = UIDropDownMenu_CreateInfo()
        local cls = select(2,UnitClass("player"))
        local roles = ns:GetAvailableRoles(cls)
        for _,r in ipairs({"tank","dps","healer"}) do
            info.text = r:upper()
            info.value = r
            info.func = function()
                currentRole = r
                UIDropDownMenu_SetSelectedValue(dd,r)
                UIDropDownMenu_SetText(dd,r:upper())
                UpdateSpecDropdown()
                UpdateItemDisplay()
            end
            info.colorCode = tContains(roles, r) and "|cFF00FF00" or "|cFFFF6600"
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(dd,Init)
    return dd
end

-- Create spec dropdown
local function CreateSpecDropdown()
    local dd = CreateFrame("Frame","BiSFinderSpecDD",mainFrame,"UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT",mainFrame,"TOPLEFT",160,-30)
    UIDropDownMenu_SetWidth(dd,200)
    return dd
end

-- Update spec dropdown
function UpdateSpecDropdown()
    local dd = _G["BiSFinderSpecDD"]
    if not dd then return end
    local cls = select(2,UnitClass("player"))
    local specs = ns:GetAvailableSpecs(cls, currentRole)
    for spec,_ in pairs(ns.ItemData[currentRole]) do
        if not tContains(specs, spec) then table.insert(specs, spec) end
    end

    local function Init(self)
        local info = UIDropDownMenu_CreateInfo()
        local _, ps = GetPlayerClassAndSpec()
        for _, s in ipairs(specs) do
            info.text = s; info.value = s
            info.func = function()
                currentSpec = s
                UIDropDownMenu_SetSelectedValue(dd, s)
                UIDropDownMenu_SetText(dd, s)
                UpdateItemDisplay()
            end
            if s == ps then info.colorCode = "|cFF00FF00" end
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dd, Init)
    local _, ps = GetPlayerClassAndSpec()
    if ps then
        currentSpec = ps
        UIDropDownMenu_SetSelectedValue(dd, ps)
        UIDropDownMenu_SetText(dd, ps)
    elseif #specs > 0 then
        currentSpec = specs[1]
        UIDropDownMenu_SetSelectedValue(dd, currentSpec)
        UIDropDownMenu_SetText(dd, currentSpec)
    end
end

-- Create main frame
local function CreateMainFrame()
    mainFrame = CreateFrame("Frame","BiSFinderMain",UIParent,"BasicFrameTemplateWithInset")
    mainFrame:SetSize(500,550); mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true); mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

    mainFrame.title = mainFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    mainFrame.title:SetPoint("LEFT", mainFrame.TitleBg, "LEFT", 5, 0)
    mainFrame.title:SetText("BiSFinder")

    local inst = mainFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    inst:SetPoint("BOTTOMLEFT",mainFrame,"BOTTOMLEFT",10,10)
    inst:SetText("Shift+Click to link"); inst:SetTextColor(0.7,0.7,0.7)

    CreateRoleDropdown()
    CreateSpecDropdown()
    mainFrame:Hide()
    return mainFrame
end

-- Slash commands
SLASH_BISFINDER1 = "/bisfinder"
SLASH_BISFINDER2 = "/bisf"
SlashCmdList["BISFINDER"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        local cls, ps = GetPlayerClassAndSpec()
        for r,_ in pairs(ns.ItemData) do
            if ns.ItemData[r][ps] then currentRole = r; break end
        end
        local rd = _G["BiSFinderRoleDD"]
        if rd then UIDropDownMenu_SetText(rd, currentRole:upper()) end
        UpdateSpecDropdown()
        UpdateItemDisplay()
    end
end

-- Update on spec change
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function()
    if mainFrame:IsShown() then
        local _, ps = GetPlayerClassAndSpec()
        if ps and ps ~= currentSpec then
            for r,_ in pairs(ns.ItemData) do
                if ns.ItemData[r][ps] then
                    currentRole = r
                    currentSpec = ps
                    break
                end
            end
            local rd = _G["BiSFinderRoleDD"]
            if rd then UIDropDownMenu_SetText(rd, currentRole:upper()) end
            UpdateSpecDropdown()
            UpdateItemDisplay()
        end
    end
end)

-- Initialization on ADDON_LOADED
local function OnLoad(self, event, aname)
    if aname == ADDON_NAME then
        CreateMainFrame()
        print("|cFF00FF00BiSFinder|r loaded! /bisf /bisfinder")
        self:UnregisterEvent("ADDON_LOADED")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnLoad)
