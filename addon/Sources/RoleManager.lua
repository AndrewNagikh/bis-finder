local ADDON_NAME, ns = ...

ns.rolesMap = {
    ["tank"] = "Tank",
    ["healer"] = "Healer",
    ["dps"] = "DPS",
}

ns.selectedRoleId = "tank"

function ns:UpdateSelectedRole(role)
    -- Сохраняем выбранный id роли
    ns.selectedRoleId = role
end

function ns:GetSelectedRoleId()
    return ns.selectedRoleId
end
