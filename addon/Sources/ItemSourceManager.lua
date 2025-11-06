local ADDON_NAME, ns = ...

ns.itemSourcesMap = {
    ["overroll"] = "Overroll",
    ["mythic"] = "Mythic+",
    ["raid"] = "Raid",
}

ns.selectedItemSourceId = "mythic" -- Default item source

function ns:UpdateSelectedItemSource(source)
    -- Сохраняем выбранный id источника предметов
    ns.selectedItemSourceId = source
end

function ns:GetSelectedItemSourceId()
    return ns.selectedItemSourceId
end
