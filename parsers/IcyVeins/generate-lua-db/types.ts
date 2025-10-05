/**
 * Типы данных для генератора WoW Best in Slot аддона
 */

export interface ItemInfo {
  itemType: string;
  itemId: string;
  itemName: string;
  source: string;
}

export interface RoleData {
  [specName: string]: ItemInfo[];
}

export interface ItemData {
  tank: RoleData;
  dps: RoleData;
  healer: RoleData;
}

export interface ClassSpecMapping {
  [className: string]: {
    tank: string[];
    dps: string[];
    healer: string[];
  };
}

export type Role = 'tank' | 'dps' | 'healer';

export interface JsonFiles {
  tank: string;
  dps: string;
  healer: string;
}

export interface LuaGeneratorOptions {
  jsonFiles: JsonFiles;
  outputPath: string;
  addonName?: string;
}
