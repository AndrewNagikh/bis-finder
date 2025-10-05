import { test } from '@playwright/test';
import createStealthContext from 'lib/createStealthContext';
import fs from 'fs';
import path from 'path';
import { sleep, formatDateDDMMYYYY } from 'lib/helpers';
import { safeGetRowData } from './lib/getRowData';
import { processRoleFiles, formatRoleName } from './lib/helpers';

test.describe.configure({ mode: 'parallel' });

test('find Mythic+ links with stealth protection', async () => {
  test.setTimeout(600000); // 5 минут на тест
  const role = process.env.ROLE;
  const resultObj: Record<string, any> = {};

  await processRoleFiles(
    role as 'dps' | 'tank' | 'healer',
    async (link, index, total) => {
      const context = await createStealthContext();
      const newPage = await context.newPage();

      try {
        // логирование начала обработки ссылки
        console.log(`\n📋 [${index}/${total}] Обработка ссылки:`);
        console.log(`🔗 ${link}`);

        const result = await safeGetRowData(newPage, link as string);

        // Логирование результатов
        console.log(`🎯 Селектор: ${result.selector}`);
        console.log(`📊 Найдено строк в таблице: ${result.rowCount}`);

        const specName = formatRoleName(link);
        resultObj[specName] = result.data;
        // Логирование добавленных данных
        console.log(
          `✅ Данные добавлены: {${specName}: ${result.data.length} предметов}`
        );
      } catch (error) {
        console.error(`❌ Ошибка при обработке ${link}: ${error}`);
      } finally {
        try {
          if (!newPage.isClosed()) {
            await newPage.close();
          }
        } catch {
          // Игнорируем ошибки закрытия
        }
      }

      // Увеличиваем паузу между запросами
      await sleep(Math.random() * 5000 + 3000);
    }
  );

  // Создание итогового файла
  const date = formatDateDDMMYYYY(new Date());
  const dirPath = path.resolve(`IcyVeins/bis-json-data/${date}`);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath);
  }
  const roleFilePath = path.join(dirPath, `${role}.json`);

  if (!fs.existsSync(roleFilePath)) {
    fs.writeFileSync(roleFilePath, JSON.stringify(resultObj), 'utf-8');

    // Красивое логирование итогов
    console.log('\n' + '='.repeat(80));
    console.log('🎉 ПАРСИНГ ЗАВЕРШЕН!');
    console.log('='.repeat(80));
    console.log(`📁 Итоговый файл создан: ${roleFilePath}`);
    console.log(
      `📊 Обработано специализаций: ${Object.keys(resultObj).length}`
    );

    // Подсчет общего количества предметов
    const totalItems = Object.values(resultObj).reduce(
      (sum: number, items: any) => sum + items.length,
      0
    );
    console.log(`🎯 Всего предметов: ${totalItems}`);

    // Детальная статистика по специализациям
    console.log('\n📋 Детальная статистика:');
    Object.entries(resultObj).forEach(([spec, items]) => {
      console.log(`  • ${spec}: ${(items as any[]).length} предметов`);
    });

    console.log('='.repeat(80) + '\n');
  }
});
