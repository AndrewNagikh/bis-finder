local ADDON_NAME, ns = ...

-- Менеджер источников данных для BiSFinder
local SourceManager = {}

-- Зарегистрированные источники
SourceManager.sources = {}
SourceManager.currentSource = nil

-- Регистрация источника данных
function SourceManager:RegisterSource(sourceModule)
    if sourceModule and sourceModule.name then
        self.sources[sourceModule.name] = sourceModule
        
        -- Если это первый источник, делаем его текущим
        if not self.currentSource then
            self.currentSource = sourceModule.name
        end
    end
end

-- Получение текущего источника
function SourceManager:GetCurrentSource()
    if self.currentSource and self.sources[self.currentSource] then
        return self.sources[self.currentSource]
    end
    return nil
end

-- Установка текущего источника
function SourceManager:SetCurrentSource(sourceName)
    if self.sources[sourceName] then
        self.currentSource = sourceName
        return true
    else
        return false
    end
end

-- Получение списка всех источников
function SourceManager:GetAllSources()
    local sourceList = {}
    for name, module in pairs(self.sources) do
        table.insert(sourceList, {
            name = name,
            displayName = module.displayName or name,
            info = module:GetInfo()
        })
    end
    return sourceList
end

-- Инициализация всех источников
function SourceManager:InitializeAllSources()
    for name, module in pairs(self.sources) do
        if module.Initialize then
            module:Initialize()
        end
    end
    
    -- Устанавливаем IcyVeins как источник по умолчанию
    if self.sources["IcyVeins"] then
        self:SetCurrentSource("IcyVeins")
    end
end

-- Получение предметов для специализации из текущего источника
function SourceManager:GetItemsForSpec(specName)
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.GetItemsForSpec then
        return currentSource:GetItemsForSpec(specName)
    end
    return {}
end

-- Рендеринг предметов для специализации из текущего источника
function SourceManager:RenderItems(parent, specName, x, y)
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.RenderItems then
        return currentSource:RenderItems(parent, specName, x, y)
    end
    return {}
end

-- Получение доступных специализаций для класса и роли из текущего источника
function SourceManager:GetAvailableSpecs(className, role)
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.GetAvailableSpecs then
        return currentSource:GetAvailableSpecs(className, role)
    end
    return {}
end

-- Получение всех доступных ролей для класса из текущего источника
function SourceManager:GetAvailableRoles(className)
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.GetAvailableRoles then
        return currentSource:GetAvailableRoles(className)
    end
    return {}
end

-- Получение всех классов из текущего источника
function SourceManager:GetAllClasses()
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.GetAllClasses then
        return currentSource:GetAllClasses()
    end
    return {}
end

-- Проверка, поддерживает ли класс роль в текущем источнике
function SourceManager:ClassSupportsRole(className, role)
    local currentSource = self:GetCurrentSource()
    if currentSource and currentSource.ClassSupportsRole then
        return currentSource:ClassSupportsRole(className, role)
    end
    return false
end

-- Экспорт менеджера
ns.SourceManager = SourceManager
