local ADDON_NAME, ns = ...

-- Модуль IcyVeins для BiSFinder
local IcyVeinsModule = {}

-- Данные модуля
IcyVeinsModule.name = "IcyVeins"
IcyVeinsModule.displayName = "IcyVeins"
IcyVeinsModule.data = nil -- Будет загружено из IcyVeinsData.lua

-- Инициализация модуля
function IcyVeinsModule:Initialize()
    -- Загружаем данные модуля
    if ns.IcyVeinsData then
        self.data = ns.IcyVeinsData
    end
end

-- Получение количества предметов в базе
function IcyVeinsModule:GetItemCount()
    if not self.data then return 0 end
    
    local count = 0
    for role, roleData in pairs(self.data) do
        for specName, specData in pairs(roleData) do
            for itemType, items in pairs(specData) do
                if type(items) == "table" then
                    count = count + #items
                end
            end
        end
    end
    return count
end

-- Получение предметов для специализации
function IcyVeinsModule:GetItemsForSpec(specName)
    if not self.data then return {} end
    
    -- Ищем специализацию в данных по ролям
    for role, roleData in pairs(self.data) do
        if roleData[specName] then
            return roleData[specName]
        end
    end
    
    return {}
end

-- Рендеринг списка предметов для специализации
function IcyVeinsModule:RenderItems(parent, specName, x, y)
    local items = self:GetItemsForSpec(specName)
    if not items or not next(items) then
        print("BiSFinder: No items found for spec " .. specName)
        return {}
    end
    
    local itemRows = {}
    local currentY = y
    local rowHeight = 50
    local rowSpacing = 5
    
    -- Сортируем типы предметов для консистентного отображения
    local itemTypes = {}
    for itemType, _ in pairs(items) do
        table.insert(itemTypes, itemType)
    end
    table.sort(itemTypes)
    
    -- Создаем строки для каждого типа предметов
    for _, itemType in ipairs(itemTypes) do
        local typeItems = items[itemType]
        if typeItems and #typeItems > 0 then
            local row = ns:CreateItemRow(parent, itemType, typeItems, x, currentY)
            table.insert(itemRows, row)
            currentY = currentY - (rowHeight + rowSpacing)
        end
    end
    
    return itemRows
end

-- Получение доступных специализаций для класса и роли
function IcyVeinsModule:GetAvailableSpecs(className, role)
    if ns.IcyVeinsClassSpecMapping and ns.IcyVeinsClassSpecMapping[className] and ns.IcyVeinsClassSpecMapping[className][role] then
        return ns.IcyVeinsClassSpecMapping[className][role]
    end
    return {}
end

-- Получение всех доступных ролей для класса
function IcyVeinsModule:GetAvailableRoles(className)
    if not ns.IcyVeinsClassSpecMapping or not ns.IcyVeinsClassSpecMapping[className] then
        return {}
    end
    
    local roles = {}
    for role, specs in pairs(ns.IcyVeinsClassSpecMapping[className]) do
        if #specs > 0 then
            table.insert(roles, role)
        end
    end
    return roles
end

-- Получение всех классов
function IcyVeinsModule:GetAllClasses()
    if not ns.IcyVeinsClassSpecMapping then
        return {}
    end
    
    local classes = {}
    for className, _ in pairs(ns.IcyVeinsClassSpecMapping) do
        table.insert(classes, className)
    end
    return classes
end

-- Проверка, поддерживает ли класс роль
function IcyVeinsModule:ClassSupportsRole(className, role)
    local specs = self:GetAvailableSpecs(className, role)
    return #specs > 0
end

-- Получение информации о модуле
function IcyVeinsModule:GetInfo()
    return {
        name = self.name,
        displayName = self.displayName,
        itemCount = self:GetItemCount(),
        version = "1.0"
    }
end

-- Экспорт модуля
ns.IcyVeinsModule = IcyVeinsModule
