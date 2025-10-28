import test from '@playwright/test';
import createStealthContext from 'lib/createStealthContext';
import { processRoleFiles } from './lib/helpers';

test.describe.configure({ mode: 'parallel' });

test('Generate archon data', async () => {
  test.setTimeout(900000);
  const role = process.env.ROLE as 'dps' | 'tank' | 'healer';

  if (!role) {
    console.error('❌ ROLE environment variable is required');
    return;
  }

  const context = await createStealthContext();

  try {
    await processRoleFiles(role, async (link, index, total) => {
      console.log(`\n🔗 Processing link ${index}/${total}: ${link}`);

      const page = await context.newPage();

      try {
        await page.goto(link, {
          timeout: 60000,
          waitUntil: 'domcontentloaded',
        });

        // Здесь можно добавить логику парсинга данных с каждой страницы
        // Например, извлечение информации о билдах, предметах и т.д.

        console.log(`✅ Successfully processed: ${link}`);

        // Пауза между запросами
        await new Promise((resolve) => setTimeout(resolve, 2000));
      } catch (error) {
        console.error(`❌ Error processing ${link}:`, error.message);
      } finally {
        await page.close();
      }
    });
  } finally {
    try {
      await context.close();
    } catch {
      // Игнорируем ошибки закрытия контекста
    }
  }
});
