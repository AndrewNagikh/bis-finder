local ADDON_NAME, ns = ...

function ns:GetPlayerSpecName()
    local _, _, classId = UnitClass("player")
    local specIndex = GetSpecialization()
    
    if not classId or not specIndex then
        return nil
    end
    
    local specName, specDescription, specIcon, specBackground, specRole, specPrimaryStat, specId = GetSpecializationInfo(specIndex)
    
    if not specName then
        return nil
    end
    
    -- Возвращаем specName как есть (может быть числом или строкой)
    return specName
end