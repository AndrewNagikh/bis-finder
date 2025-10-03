import { test, expect, Page, BrowserContext } from '@playwright/test';
import createStealthContext from 'lib/createStealthContext';
import { formatDateDDMMYYYY, formatRoleName, processRoleFiles, sleep } from 'lib/helpers';
import { safeGetRowData } from 'lib/getRowData';
import fs from 'fs';
import path from 'path';
import { generateLuaDB } from 'generate-lua-db/generate-db';

test.describe.configure({ mode: 'parallel' });

test('find Mythic+ links with stealth protection', async ({}) => {
  test.setTimeout(600000); // 5 минут на тест
  const role = process.env.ROLE;
  const resultObj: Record<string, any> = {};
  await processRoleFiles(role as 'dps' | 'tank' | 'healer', async (link) => {
    const context = await createStealthContext();
    const newPage = await context.newPage();
    try {
      const rowData = await safeGetRowData(newPage, link as string);
      console.log(`Spec ${link}: ${rowData.length} items found`);
      const specName = formatRoleName(link);
      // const specData = {[specName]: rowData};
      resultObj[specName] = rowData;
    } catch (error) {
      console.error(`Failed to process spec ${link}: ${error}`);
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
  });
  const date = formatDateDDMMYYYY(new Date());
  const dirPath = path.resolve(`bis-json-data/${date}`);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath);
  }
  const roleFilePath = path.join(dirPath, `${role}.json`)
    if (!fs.existsSync(roleFilePath)) {
      fs.writeFileSync(roleFilePath, JSON.stringify(resultObj), 'utf-8')
    }
});
