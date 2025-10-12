local ADDON_NAME, ns = ...

ns.sourcesMap = {
    ["icyveins"] = "IcyVeins",
    ["archon"] = "Archon",
}

ns.selectedSourceId = "icyveins"

function ns:UpdateMainContentSource(source)
    -- Сохраняем выбранный id
    ns.selectedSourceId = source
end

function ns:GetSelectedSourceId()
    return ns.selectedSourceId
end