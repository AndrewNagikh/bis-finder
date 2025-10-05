import { Page } from '@playwright/test';
import { sleep } from 'lib/helpers';

const selectors = {
  bisButton: 'span.toc_page_list_item > a:has-text("Gear and Best in Slot")',
  adBlockerButton: 'button:has-text("or continue with ad blocker")',
  rotationSwitches: '#area_1 table.rotation_switches.centered',
} as const;

export async function safeGetRowData(
  page: Page,
  specLink: string,
  retryCount: number = 0,
  reloadAttempted: boolean = false
): Promise<{ data: any[]; selector: string; rowCount: number }> {
  // Защита от бесконечной рекурсии
  if (reloadAttempted && retryCount > 3) {
    console.log(
      'Превышено максимальное количество попыток, возвращаем пустой результат'
    );
    return { data: [], selector: 'max_retries', rowCount: 0 };
  }
  try {
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

    // Определяем селектор на основе URL и наличия rotation switches
    const isRotationSelectorPresent =
      (await page.locator(selectors.rotationSwitches).count()) > 0;

    let evalSelector: string;

    // Специфичные селекторы для определенных страниц
    const specificSelectors: Record<string, string> = {
      'augmentation-evoker-pve-dps-gear-best-in-slot':
        'div#area_1 span:nth-of-type(2) table tbody tr',
      'holy-priest-pve-healing-gear-best-in-slot':
        'div div:nth-of-type(2) table tbody tr',
    };

    // Проверяем, есть ли специфичный селектор для данной страницы
    const specificSelector = Object.keys(specificSelectors).find((key) =>
      specLink.includes(key)
    );

    if (specificSelector) {
      evalSelector = specificSelectors[specificSelector]!;
    } else if (isRotationSelectorPresent) {
      evalSelector = 'div#area_1 div:nth-of-type(2) table tbody tr';
    } else {
      evalSelector = 'div#area_1.image_block_content.selected table tbody tr';
    }

    // Ждем данные
    let rowDataCount = 0;
    try {
      await page.waitForSelector(evalSelector, {
        timeout: 20000,
        state: 'visible',
      });
      rowDataCount = await page.locator(evalSelector).count();
    } catch {
      return { data: [], selector: evalSelector, rowCount: 0 };
    }

    if (rowDataCount === 0) {
      // Если данные не найдены и мы еще не пытались перезагрузить страницу
      if (!reloadAttempted) {
        console.log('Данные не найдены, перезагружаем страницу...');
        await page.reload({ waitUntil: 'domcontentloaded' });
        await sleep(Math.random() * 3000 + 2000); // Ждем после перезагрузки

        // Повторяем попытку с флагом reloadAttempted = true и увеличиваем retryCount
        return safeGetRowData(page, specLink, retryCount + 1, true);
      } else {
        console.log('Данные не найдены даже после перезагрузки страницы');
        return { data: [], selector: evalSelector, rowCount: 0 };
      }
    }

    // Извлекаем данные
    const rowsData = await page.locator(evalSelector).evaluateAll((rows) => {
      return rows
        .map((row) => {
          const cells = Array.from(row.querySelectorAll('td'));
          if (cells.length < 3) return null;
          const itemType = cells[0]?.textContent?.trim() || '';
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

    // Проверяем, что после извлечения данных у нас есть предметы
    if (rowsData.length === 0 && !reloadAttempted) {
      console.log('Предметы не извлечены, перезагружаем страницу...');
      await page.reload({ waitUntil: 'domcontentloaded' });
      await sleep(Math.random() * 3000 + 2000); // Ждем после перезагрузки

      // Повторяем попытку с флагом reloadAttempted = true и увеличиваем retryCount
      return safeGetRowData(page, specLink, retryCount + 1, true);
    }

    return { data: rowsData, selector: evalSelector, rowCount: rowDataCount };
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
        return { data: [], selector: 'error', rowCount: 0 }; // Возвращаем пустой объект вместо повтора
      }
    }

    return { data: [], selector: 'error', rowCount: 0 };
  }
}
