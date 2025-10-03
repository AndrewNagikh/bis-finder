#!/usr/bin/env node

import path from 'path';
import { generateLuaDatabase } from './json-to-lua-generator';
import { formatDateDDMMYYYY } from 'lib/helpers';

/**
 * Скрипт для генерации базы данных Lua из JSON файлов
 */
export async function generateLuaDB(): Promise<void> {
  console.log('🚀 === Генератор базы данных Best in Slot ===\n');

  // Запускаем генерацию
  try {
    const success = await generateLuaDatabase({
      jsonFiles: {
        tank: path.resolve(`bis-json-data/${formatDateDDMMYYYY(new Date())}/tank.json`),
        dps: path.resolve(`bis-json-data/${formatDateDDMMYYYY(new Date())}/dps.json`),
        healer: path.resolve(`bis-json-data/${formatDateDDMMYYYY(new Date())}/healer.json`),
      },
      outputPath: '../addon/BiSFinderData.lua'
    });

    if (success) {
      console.log('\n🎉 Генерация успешно завершена!');
    } else {
      console.error('❌ Генерация завершилась с ошибками');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Критическая ошибка при генерации:', (error as Error).message);
    process.exit(1);
  }
}