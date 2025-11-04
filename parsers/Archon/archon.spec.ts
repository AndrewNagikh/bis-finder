import test from '@playwright/test';
import createStealthContext from 'lib/createStealthContext';
import { getArchonClassName, processRoleFiles } from './lib/helpers';
import { TArchonSourceMap } from './types';
import { formatDateDDMMYYYY, sleep } from 'lib/helpers';
import { extractArchonRows } from './lib/extractRows.spec';
import path from 'path';
import fs from 'fs';

test.describe.configure({ mode: 'parallel' });

test('Generate archon data', async () => {
  test.setTimeout(900000);
  const role = process.env.ROLE as 'dps' | 'tank' | 'healer';

  if (!role) {
    console.error('❌ ROLE environment variable is required');
    return;
  }

  const resultObj: Record<
    string,
    {
      raid: { talents: any; items: any[] };
      mythic: { talents: any; items: any[] };
    }
  > = {};

  const sources: TArchonSourceMap[] = ['raid', 'mythic'];

  await processRoleFiles(role, async (link, index, total) => {
    console.log(`\n📋 [${index}/${total}] Обработка ссылки:`);
    console.log(`🔗 ${link}`);

    const specName = getArchonClassName(link);
    resultObj[specName] = {
      raid: { talents: null, items: [] },
      mythic: { talents: null, items: [] },
    };

    let context = await createStealthContext();
    let page = await context.newPage();
    let retryCount = 0;
    const maxRetries = 1;

    const parseLink = async (): Promise<void> => {
      try {
        for (const source of sources) {
          console.log(`\n🎯 Парсинг источника: ${source.toUpperCase()}`);
          await page.goto(link, {
            timeout: 55000,
            waitUntil: 'domcontentloaded',
          });
          const result = await extractArchonRows(page, source, context);
          if (resultObj[specName]) {
            resultObj[specName][source] = {
              talents: result.taletns,
              items: result.items,
            };
          }

          console.log(
            `   ✅ Данные добавлены: {${source}: ${result.items.length} предметов}`
          );

          // Пауза между источниками
          await sleep(Math.random() * 2000 + 1000);
        }

        // Логирование итогов по специализации
        if (resultObj[specName]) {
          const totalItems =
            resultObj[specName].raid.items.length +
            resultObj[specName].mythic.items.length;
          console.log(`\n📊 Итого по ${specName}: ${totalItems} предметов`);
        }
      } catch (error) {
        if (retryCount < maxRetries) {
          retryCount++;
          console.warn(
            `⚠️  Ошибка при обработке ${link}, попытка ${retryCount}/${maxRetries}: ${error}`
          );

          // Закрываем текущие страницу и контекст
          try {
            if (!page.isClosed()) {
              await page.close();
            }
            await context.close();
          } catch {
            // Игнорируем ошибки закрытия
          }

          // Пауза перед ретраем
          await sleep(Math.random() * 3000 + 2000);

          // Создаем новый контекст и страницу для ретрая
          context = await createStealthContext();
          page = await context.newPage();

          // Ретрай
          await parseLink();
        } else {
          console.error(
            `❌ Ошибка при обработке ${link} после ${maxRetries} попыток: ${error}`
          );
          throw error;
        }
      }
    };

    try {
      await parseLink();
    } catch (error) {
      console.error(`❌ Критическая ошибка при обработке ${link}: ${error}`);
    } finally {
      try {
        if (!page.isClosed()) {
          await page.close();
        }
        await context.close();
      } catch {
        // Игнорируем ошибки закрытия
      }
    }

    // Увеличиваем паузу между запросами
    await sleep(Math.random() * 5000 + 3000);
  });

  const date = formatDateDDMMYYYY(new Date());
  const dirPath = path.resolve(`Archon/bis-json-data/${date}`);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
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
      (specData: {
        raid: { talents: any; items: any[] };
        mythic: { talents: any; items: any[] };
      }) => {
        (sourceStats.raid as number) += specData.raid.items.length;
        (sourceStats.mythic as number) += specData.mythic.items.length;
        totalItems += specData.raid.items.length + specData.mythic.items.length;
      }
    );

    console.log(`🎯 Всего предметов: ${totalItems}`);
    console.log(`   • Raid: ${sourceStats.raid} предметов`);
    console.log(`   • Mythic: ${sourceStats.mythic} предметов`);

    // Детальная статистика по специализациям
    console.log('\n📋 Детальная статистика:');
    Object.entries(resultObj).forEach(([spec, specData]) => {
      const specTotal =
        specData.raid.items.length + specData.mythic.items.length;
      console.log(`  • ${spec}: ${specTotal} предметов`);

      if (specData.raid.items.length > 0) {
        console.log(`    - raid: ${specData.raid.items.length} предметов`);
      }
      if (specData.mythic.items.length > 0) {
        console.log(`    - mythic: ${specData.mythic.items.length} предметов`);
      }
    });

    console.log('='.repeat(80) + '\n');
  }
});
