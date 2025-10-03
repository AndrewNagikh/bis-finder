import { Page } from '@playwright/test';
import { sleep } from './helpers';

const selectors = {
  bisButton: 'span.toc_page_list_item > a:has-text("Gear and Best in Slot")',
  adBlockerButton: 'button:has-text("or continue with ad blocker")',
  rotationSwitches: '#area_1 table.rotation_switches.centered',
} as const;

export async function safeGetRowData(
  page: Page,
  specLink: string,
  retryCount: number = 0
): Promise<any[]> {
  try {
    console.log(`Navigating to ${specLink} (attempt ${retryCount + 1})`);
    // Проверяем, что страница еще активна
    if (page.isClosed()) {
      throw new Error('Page was closed before navigation');
    }

    await page.goto(specLink, {
      timeout: 45000,
      waitUntil: 'domcontentloaded',
    });

    // Добавляем случайную задержку для имитации человеческого поведения
    await sleep(Math.random() * 3000 + 2000);

    // Обрабатываем блокировщик рекламы
    try {
      const adBlockerButton = page.locator(selectors.adBlockerButton).first();
      if (await adBlockerButton.isVisible({ timeout: 5000 })) {
        await adBlockerButton.click();
        await sleep(2000);
      }
    } catch {
      // Игнорируем если кнопка не найдена
    }

    // Определяем селектор
    const isRotationSelectorPresent =
      (await page.locator(selectors.rotationSwitches).count()) > 0;
    const evalSelector = isRotationSelectorPresent
      ? 'div#area_1 div:nth-of-type(2) table tbody tr'
      : 'div#area_1.image_block_content.selected table tbody tr';

    // Ждем данные
    try {
      await page.waitForSelector(evalSelector, {
        timeout: 20000,
        state: 'visible',
      });
    } catch {
      console.log('Data selector not found, skipping...');
      return [];
    }
    const rowDataCount = await page.locator(evalSelector).count();
    console.log(`Found ${rowDataCount} rows`);

    if (rowDataCount === 0) return [];
    // Извлекаем данные
    const rowsData = await page.locator(evalSelector).evaluateAll((rows) => {
      return rows
        .map((row) => {
          const cells = Array.from(row.querySelectorAll('td'));
          if (cells.length < 3) return null;
          const itemType = cells[0]?.textContent?.trim() || '';
          let wowheadLink = '';
          let itemId = '';
          let itemName = '';
          let source = '';

          const aElement = cells[1]?.querySelector(
            'a[data-wowhead]'
          ) as HTMLAnchorElement;
          const spanElement = cells[1]?.querySelector(
            'span[data-wowhead]'
          ) as HTMLAnchorElement;
          if (spanElement) {
            const dataWowhead = spanElement.getAttribute('data-wowhead');
            const match = dataWowhead?.match(/item=(\d+)/);
            itemName = spanElement.innerText;
            if (match) itemId = match[1] as string;
          }
          if (aElement) {
            wowheadLink = aElement.href;
            const dataWowhead = aElement.getAttribute('data-wowhead') || '';
            const match = dataWowhead.match(/item=(\d+)/);
            itemName = aElement.innerText;
            if (match) itemId = match[1] as string;
          }

          source = cells[2]?.textContent?.trim() || '';
          return { itemType, itemId, itemName, source };
        })
        .filter(Boolean);
    });
    return rowsData;
  } catch (error: any) {
    console.error(`Error in safeGetRowData: ${error.message}`);

    // Проверяем, связана ли ошибка с закрытием страницы/контекста
    if (
      error.message.includes(
        'Target page, context or browser has been closed'
      ) ||
      error.message.includes('Page was closed') ||
      page.isClosed()
    ) {
      if (retryCount < 2) {
        console.log(
          `Context/page was closed, retrying... (${retryCount + 1}/3)`
        );
        await sleep(5000); // Ждем перед повторной попыткой
        return []; // Возвращаем пустой массив вместо повтора
      }
    }

    return [];
  }
}
