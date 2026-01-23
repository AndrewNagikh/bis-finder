local ADDON_NAME, ns = ...

function ns:GetPlayerSpecName()
    local _, _, classId = UnitClass("player")
    
    if not classId then
        return nil
    end
    
    -- Получаем активную специализацию
    local specIndex = GetSpecialization()
    if not specIndex then
        return nil
    end
    
    -- Используем новый API C_SpecializationInfo.GetSpecializationInfo для патча 12.0
    -- В патче 12.0 требуется передавать classID как 7-й параметр
    -- Возвращает: specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked
    local specId, specName, specDescription, specIcon, specRole, specPrimaryStat = 
        C_SpecializationInfo.GetSpecializationInfo(specIndex, false, false, nil, nil, nil, classId)
    
    if not specName then
        return nil
    end
    
    -- Возвращаем specName как есть (может быть числом или строкой)
    return specName
end

function ns:GetPlayerSpecId()
    local _, _, classId = UnitClass("player")
    
    if not classId then
        return nil
    end
    
    -- Получаем активную специализацию
    local specIndex = GetSpecialization()
    if not specIndex then
        return nil
    end
    
    -- Используем новый API C_SpecializationInfo.GetSpecializationInfo
    -- Возвращает: specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked
    local specId = C_SpecializationInfo.GetSpecializationInfo(specIndex, false, false, nil, nil, nil, classId)
    
    if not specId or specId == 0 then
        return nil
    end
    
    -- Возвращаем ID специализации
    return specId
end