local ADDON_NAME, ns = ...

function ns:GetPlayerSpecId()
    local _, _, classId = UnitClass("player")
    local specIndex = GetSpecialization()
    
    if not classId or not specIndex then
        return nil
    end
    
    local _, _, _, _, _, _, _, _, _, specId = GetSpecializationInfo(specIndex)
    if not specId then
        return nil
    end
    
    -- Создаем ключ в формате ns.specMap: "ClassID_SpecID"
    local specKey = classId .. "_" .. specId
    
    return specKey
end