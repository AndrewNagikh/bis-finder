import * as fs from 'fs';
import * as path from 'path';
import {
  ItemData,
  ClassSpecMapping,
  Role,
  ItemInfo,
  RoleData,
  LuaGeneratorOptions,
} from './types';

/**
 * Генератор Lua файла базы данных из JSON файлов с данными о предметах
 */
export class LuaDataGenerator {
  private itemData: ItemData;
  private classSpecMapping: ClassSpecMapping = {};

  constructor() {
    this.itemData = {
      tank: {},
      dps: {},
      healer: {},
    };
  }

  /**
   * Читает JSON файл и возвращает объект
   */
  private readJsonFile<T = any>(filepath: string): T | null {
    try {
      const content = fs.readFileSync(filepath, 'utf-8');
      return JSON.parse(content) as T;
    } catch (error) {
      console.error(
        `Ошибка чтения файла ${filepath}:`,
        (error as Error).message
      );
      return null;
    }
  }

  /**
   * Преобразует JS объект в Lua таблицу (строковое представление)
   */
  private jsObjectToLuaTable(obj: any, indent: number = 0): string {
    const spaces = '    '.repeat(indent);

    if (Array.isArray(obj)) {
      if (obj.length === 0) return '{}';

      let result = '{\n';
      obj.forEach((item, index) => {
        result += `${spaces}    ${this.jsObjectToLuaTable(item, indent + 1)}`;
        if (index < obj.length - 1) result += ',';
        result += '\n';
      });
      result += `${spaces}}`;
      return result;
    } else if (typeof obj === 'object' && obj !== null) {
      const keys = Object.keys(obj);
      if (keys.length === 0) return '{}';

      let result = '{\n';
      keys.forEach((key, index) => {
        const luaKey = this.escapeLuaKey(key);
        const value = this.jsObjectToLuaTable(obj[key], indent + 1);
        result += `${spaces}    ${luaKey} = ${value}`;
        if (index < keys.length - 1) result += ',';
        result += '\n';
      });
      result += `${spaces}}`;
      return result;
    } else if (typeof obj === 'string') {
      return `"${obj.replace(/"/g, '\\"').replace(/\n/g, '\\n')}"`;
    } else if (typeof obj === 'number') {
      return obj.toString();
    } else if (typeof obj === 'boolean') {
      return obj ? 'true' : 'false';
    } else {
      return 'nil';
    }
  }

  /**
   * Экранирует ключ для Lua таблицы
   */
  private escapeLuaKey(key: string): string {
    // Если ключ содержит пробелы или специальные символы, заключаем в квадратные скобки
    if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(key)) {
      return key;
    } else {
      return `["${key.replace(/"/g, '\\"')}"]`;
    }
  }

  /**
   * Извлекает название класса из специализации
   */
  private extractClassName(specName: string): string {
    const classNames: Record<string, string> = {
      'Protection Warrior': 'WARRIOR',
      'Arms Warrior': 'WARRIOR',
      'Fury Warrior': 'WARRIOR',
      'Protection Paladin': 'PALADIN',
      'Retribution Paladin': 'PALADIN',
      'Holy Paladin': 'PALADIN',
      'Beast Mastery Hunter': 'HUNTER',
      'Marksmanship Hunter': 'HUNTER',
      'Survival Hunter': 'HUNTER',
      'Assassination Rogue': 'ROGUE',
      'Outlaw Rogue': 'ROGUE',
      'Subtlety Rogue': 'ROGUE',
      'Elemental Shaman': 'SHAMAN',
      'Enhancement Shaman': 'SHAMAN',
      'Restoration Shaman': 'SHAMAN',
      'Affliction Warlock': 'WARLOCK',
      'Demonology Warlock': 'WARLOCK',
      'Destruction Warlock': 'WARLOCK',
      'Balance Druid': 'DRUID',
      'Feral Druid': 'DRUID',
      'Guardian Druid': 'DRUID',
      'Restoration Druid': 'DRUID',
      'Blood Death Knight': 'DEATHKNIGHT',
      'Frost Death Knight': 'DEATHKNIGHT',
      'Unholy Death Knight': 'DEATHKNIGHT',
      'Arcane Mage': 'MAGE',
      'Fire Mage': 'MAGE',
      'Frost Mage': 'MAGE',
      'Brewmaster Monk': 'MONK',
      'Mistweaver Monk': 'MONK',
      'Windwalker Monk': 'MONK',
      'Holy Priest': 'PRIEST',
      'Discipline Priest': 'PRIEST',
      'Shadow Priest': 'PRIEST',
      'Havoc Demon Hunter': 'DEMONHUNTER',
      'Vengeance Demon Hunter': 'DEMONHUNTER',
      'Devastation Evoker': 'EVOKER',
      'Preservation Evoker': 'EVOKER',
      'Augmentation Evoker': 'EVOKER',
    };

    return classNames[specName] || 'UNKNOWN';
  }

  /**
   * Генерирует маппинг классов и специализаций
   */
  private generateClassSpecMapping(): ClassSpecMapping {
    const mapping: ClassSpecMapping = {};

    const roles: Role[] = ['tank', 'dps', 'healer'];

    roles.forEach((role) => {
      const roleData = this.itemData[role];
      Object.keys(roleData).forEach((specName) => {
        const className = this.extractClassName(specName);

        if (!mapping[className]) {
          mapping[className] = { tank: [], dps: [], healer: [] };
        }

        if (!mapping[className]?.[role].includes(specName)) {
          mapping[className]?.[role].push(specName);
        }
      });
    });

    return mapping;
  }

  /**
   * Обрабатывает JSON файлы и загружает данные
   */
  public loadDataFromJsonFiles(
    tankFile: string,
    dpsFile: string,
    healerFile: string
  ): boolean {
    console.log('Загрузка данных из JSON файлов...');

    let hasErrors = false;

    // Загружаем данные для танков
    if (fs.existsSync(tankFile)) {
      const tankData = this.readJsonFile<RoleData>(tankFile);
      if (tankData) {
        this.itemData.tank = tankData;
        console.log(
          `✅ Tank данные загружены: ${Object.keys(tankData).length} специализаций`
        );
      } else {
        hasErrors = true;
      }
    } else {
      console.warn(`⚠️  Файл ${tankFile} не найден`);
    }

    // Загружаем данные для DPS
    if (fs.existsSync(dpsFile)) {
      const dpsData = this.readJsonFile<RoleData>(dpsFile);
      if (dpsData) {
        this.itemData.dps = dpsData;
        console.log(
          `✅ DPS данные загружены: ${Object.keys(dpsData).length} специализаций`
        );
      } else {
        hasErrors = true;
      }
    } else {
      console.warn(`⚠️  Файл ${dpsFile} не найден`);
    }

    // Загружаем данные для хилеров
    if (fs.existsSync(healerFile)) {
      const healerData = this.readJsonFile<RoleData>(healerFile);
      if (healerData) {
        this.itemData.healer = healerData;
        console.log(
          `✅ Healer данные загружены: ${Object.keys(healerData).length} специализаций`
        );
      } else {
        hasErrors = true;
      }
    } else {
      console.warn(`⚠️  Файл ${healerFile} не найден`);
    }

    // Генерируем маппинг классов и специализаций для внутреннего использования
    this.classSpecMapping = this.generateClassSpecMapping();
    console.log(
      '✅ Маппинг классов и специализаций сгенерирован (для внутреннего использования)'
    );

    return !hasErrors;
  }

  /**
   * Генерирует Lua файл с данными
   */
  public generateLuaFile(outputPath: string): boolean {
    console.log('Генерация Lua файла...');

    const luaContent = `-- Автоматически сгенерированный файл с данными о предметах
-- Не редактируйте вручную! Используйте генератор.
-- Сгенерировано: ${new Date().toISOString()}

local ADDON_NAME, ns = ...

-- База данных предметов IcyVeins по ролям и специализациям
ns.IcyVeinsData = ${this.jsObjectToLuaTable(this.itemData, 0)}

-- Маппинг классов WoW к доступным специализациям по ролям
-- ClassSpecMapping теперь находится в отдельном модуле ClassSpecMapping.lua

-- Функция получения данных для роли и специализации
function ns:GetItemsForSpec(role, specName)
    if not self.IcyVeinsData[role] or not self.IcyVeinsData[role][specName] then
        return {}
    end
    return self.IcyVeinsData[role][specName]
end

-- Функции GetAvailableSpecs и GetAvailableRoles теперь находятся в ClassSpecMapping.lua

print("|cFF00FF00BiSFinder IcyVeins Data|r: База данных загружена с " .. 
      (function()
          local totalSpecs = 0
          for role, roleData in pairs(ns.IcyVeinsData) do
              for spec, items in pairs(roleData) do
                  totalSpecs = totalSpecs + 1
              end
          end
          return totalSpecs
      end)() .. " специализациями")`;

    try {
      // Создаем директорию если не существует
      const dir = path.dirname(outputPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      fs.writeFileSync(outputPath, luaContent, 'utf-8');
      console.log(`✅ Lua файл успешно сгенерирован: ${outputPath}`);
      return true;
    } catch (error) {
      console.error('❌ Ошибка записи Lua файла:', (error as Error).message);
      return false;
    }
  }

  /**
   * Генерирует статистику по загруженным данным
   */
  public generateStats(): void {
    console.log('\n=== Статистика загруженных данных ===');

    let totalSpecs = 0;
    let totalItems = 0;

    const roles: Role[] = ['tank', 'dps', 'healer'];

    roles.forEach((role) => {
      const roleData = this.itemData[role];
      const specCount = Object.keys(roleData).length;
      totalSpecs += specCount;

      let roleItems = 0;
      Object.values(roleData).forEach((items: ItemInfo[]) => {
        roleItems += items.length;
      });
      totalItems += roleItems;

      console.log(
        `📊 ${role.toUpperCase()}: ${specCount} специализаций, ${roleItems} предметов`
      );
    });

    console.log(
      `📈 ИТОГО: ${totalSpecs} специализаций, ${totalItems} предметов`
    );
    console.log(`🎮 Классы: ${Object.keys(this.classSpecMapping).join(', ')}`);
    console.log('=====================================\n');
  }

  /**
   * Получить загруженные данные
   */
  public getItemData(): ItemData {
    return this.itemData;
  }

  /**
   * Получить маппинг классов
   */
  public getClassSpecMapping(): ClassSpecMapping {
    return this.classSpecMapping;
  }
}

/**
 * Основная функция генерации с настройками
 */
export async function generateLuaDatabase(
  options?: Partial<LuaGeneratorOptions>
): Promise<boolean> {
  const defaultOptions: LuaGeneratorOptions = {
    jsonFiles: {
      tank: './IcyVeins/bis-json-data/tank.json',
      dps: './IcyVeins/bis-json-data/dps.json',
      healer: './IcyVeins/bis-json-data/healer.json',
    },
    outputPath: path.resolve('../addon/Sources/IcyVeins/IcyVeinsData.lua'),
    addonName: 'BiSFinder',
  };

  const config = { ...defaultOptions, ...options };
  const generator = new LuaDataGenerator();

  // Загрузка данных
  const success = generator.loadDataFromJsonFiles(
    config.jsonFiles.tank,
    config.jsonFiles.dps,
    config.jsonFiles.healer
  );

  if (!success) {
    console.error('❌ Ошибки при загрузке данных');
    return false;
  }

  // Генерация статистики
  generator.generateStats();

  // Генерация Lua файла
  return generator.generateLuaFile(config.outputPath);
}
