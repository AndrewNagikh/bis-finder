import { test } from '@playwright/test';
import createStealthContext from 'lib/createStealthContext';
import fs from 'fs';
import path from 'path';
import { sleep, formatDateDDMMYYYY } from 'lib/helpers';
import { safeGetRowData, TIcyVeinsSourceMap } from './lib/getRowData';
import { processRoleFiles, formatRoleName } from './lib/helpers';

test.describe.configure({ mode: 'parallel' });

test('find Mythic+ links with stealth protection', async () => {
  test.setTimeout(900000); // 5 минут на тест
  const role = process.env.ROLE;
  const resultObj: Record<
    string,
    { overroll: any[]; raid: any[]; mythic: any[] }
  > = {};

  // Определяем источники данных для парсинга
  const sources: TIcyVeinsSourceMap[] = ['overrall', 'raid', 'mythic'];

  await processRoleFiles(
    role as 'dps' | 'tank' | 'healer',
    async (link, index, total) => {
      const context = await createStealthContext();
      const newPage = await context.newPage();

      try {
        // логирование начала обработки ссылки
        console.log(`\n📋 [${index}/${total}] Обработка ссылки:`);
        console.log(`🔗 ${link}`);

        const specName = formatRoleName(link);
        resultObj[specName] = { overroll: [], raid: [], mythic: [] };

        // Парсим данные из всех трех источников
        for (const source of sources) {
          console.log(`\n🎯 Парсинг источника: ${source.toUpperCase()}`);

          const result = await safeGetRowData(newPage, source, link as string);

          // Логирование результатов
          console.log(`   Селектор: ${result.selector}`);
          console.log(`   Найдено строк в таблице: ${result.rowCount}`);

          // Сохраняем данные в правильном ключе (overrall -> overroll)
          const targetKey = source === 'overrall' ? 'overroll' : source;
          resultObj[specName][targetKey] = result.data;

          // Логирование добавленных данных
          console.log(
            `   ✅ Данные добавлены: {${targetKey}: ${result.data.length} предметов}`
          );

          // Пауза между источниками
          await sleep(Math.random() * 2000 + 1000);
        }

        // Логирование итогов по специализации
        const totalItems =
          resultObj[specName].overroll.length +
          resultObj[specName].raid.length +
          resultObj[specName].mythic.length;
        console.log(`\n📊 Итого по ${specName}: ${totalItems} предметов`);
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

    // Подсчет общего количества предметов по источникам
    const sourceStats: Record<string, number> = {
      overroll: 0,
      raid: 0,
      mythic: 0,
    };
    let totalItems = 0;

    Object.values(resultObj).forEach(
      (specData: { overroll: any[]; raid: any[]; mythic: any[] }) => {
        sourceStats.overroll += specData.overroll.length;
        sourceStats.raid += specData.raid.length;
        sourceStats.mythic += specData.mythic.length;
        totalItems +=
          specData.overroll.length +
          specData.raid.length +
          specData.mythic.length;
      }
    );

    console.log(`🎯 Всего предметов: ${totalItems}`);
    console.log(`   • Overall: ${sourceStats.overroll} предметов`);
    console.log(`   • Raid: ${sourceStats.raid} предметов`);
    console.log(`   • Mythic: ${sourceStats.mythic} предметов`);

    // Детальная статистика по специализациям
    console.log('\n📋 Детальная статистика:');
    Object.entries(resultObj).forEach(([spec, specData]) => {
      const specTotal =
        specData.overroll.length +
        specData.raid.length +
        specData.mythic.length;
      console.log(`  • ${spec}: ${specTotal} предметов`);
      if (specData.overroll.length > 0) {
        console.log(`    - overroll: ${specData.overroll.length} предметов`);
      }
      if (specData.raid.length > 0) {
        console.log(`    - raid: ${specData.raid.length} предметов`);
      }
      if (specData.mythic.length > 0) {
        console.log(`    - mythic: ${specData.mythic.length} предметов`);
      }
    });

    console.log('='.repeat(80) + '\n');
  }
});
