#!/usr/bin/env node

import * as path from 'path';
import { generateLuaDatabase } from './json-to-lua-generator.js';
import { formatDateDDMMYYYY } from '../../lib/helpers.js';

/**
 * Скрипт для генерации базы данных Lua из JSON файлов
 */
export async function generateLuaDB(): Promise<void> {
  console.log('🚀 === Генератор базы данных Best in Slot ===\n');

  // Запускаем генерацию
  try {
    const success = await generateLuaDatabase({
      jsonFiles: {
        tank: path.resolve(
          `IcyVeins/bis-json-data/${formatDateDDMMYYYY(new Date())}/tank.json`
        ),
        dps: path.resolve(
          `IcyVeins/bis-json-data/${formatDateDDMMYYYY(new Date())}/dps.json`
        ),
        healer: path.resolve(
          `IcyVeins/bis-json-data/${formatDateDDMMYYYY(new Date())}/healer.json`
        ),
      },
      outputPath: '../addon/Sources/IcyVeins/IcyVeinsData.lua',
    });

    if (success) {
      console.log('\n🎉 Генерация успешно завершена!');
    } else {
      console.error('❌ Генерация завершилась с ошибками');
      process.exit(1);
    }
  } catch (error) {
    console.error(
      '❌ Критическая ошибка при генерации:',
      (error as Error).message
    );
    process.exit(1);
  }
}

// Запускаем генерацию если файл выполняется напрямую
if (import.meta.url === `file://${process.argv[1]}`) {
  generateLuaDB();
}
