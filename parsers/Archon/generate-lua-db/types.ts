/**
 * Типы данных для генератора WoW Best in Slot аддона (Archon)
 */

export interface ArchonItemInfo {
  itemId: string;
  itemName: string;
  itemType: string;
  enchantments: string[];
}

export interface ArchonSourceData {
  talents: string;
  items: ArchonItemInfo[];
  stats?: string[];
}

export interface ArchonSpecData {
  raid: ArchonSourceData;
  mythic: ArchonSourceData;
}

export interface ArchonRoleData {
  [specName: string]: ArchonSourceData;
}

export interface ArchonItemData {
  tank: ArchonRoleData;
  dps: ArchonRoleData;
  healer: ArchonRoleData;
}

export interface ArchonDataStructure {
  raid: ArchonItemData;
  mythic: ArchonItemData;
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
