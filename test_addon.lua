-- Тест для проверки работы аддона BiSFinder
-- Этот файл можно загрузить в WoW для тестирования

-- Симулируем загрузку аддона
local ADDON_NAME = "BiSFinder"
local ns = {}

-- Загружаем данные (симулируем)
print("=== Тест BiSFinder ===")

-- Проверяем, что ClassSpecMapping загружен
if ns.IcyVeinsClassSpecMapping then
    print("✅ ClassSpecMapping загружен")
    
    -- Проверяем Evoker
    if ns.IcyVeinsClassSpecMapping.EVOKER then
        print("✅ EVOKER найден в ClassSpecMapping")
        
        -- Проверяем DPS специализации
        if ns.IcyVeinsClassSpecMapping.EVOKER.dps then
            local dpsSpecs = ns.IcyVeinsClassSpecMapping.EVOKER.dps
            print("✅ DPS специализации для EVOKER:")
            for i, spec in ipairs(dpsSpecs) do
                print("  " .. i .. ". " .. spec)
            end
            
            -- Проверяем, что Augmentation Evoker есть
            local hasAugmentation = false
            for _, spec in ipairs(dpsSpecs) do
                if spec == "Augmentation Evoker" then
                    hasAugmentation = true
                    break
                end
            end
            
            if hasAugmentation then
                print("✅ Augmentation Evoker найден в DPS специализациях!")
            else
                print("❌ Augmentation Evoker НЕ найден в DPS специализациях!")
            end
        else
            print("❌ DPS специализации для EVOKER не найдены")
        end
        
        -- Проверяем Healer специализации
        if ns.IcyVeinsClassSpecMapping.EVOKER.healer then
            local healerSpecs = ns.IcyVeinsClassSpecMapping.EVOKER.healer
            print("✅ Healer специализации для EVOKER:")
            for i, spec in ipairs(healerSpecs) do
                print("  " .. i .. ". " .. spec)
            end
        else
            print("❌ Healer специализации для EVOKER не найдены")
        end
    else
        print("❌ EVOKER не найден в ClassSpecMapping")
    end
else
    print("❌ ClassSpecMapping не загружен")
end

print("=== Конец теста ===")
