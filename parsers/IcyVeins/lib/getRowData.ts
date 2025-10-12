import { Page } from '@playwright/test';
import { sleep } from 'lib/helpers';
import parseRows from './parseRows';

export type TIcyVeinsSourceMap = 'overrall' | 'raid' | 'mythic';

const icyVeinsSourceMap = {
  overrall: '#area_1',
  raid: '#area_2',
  mythic: '#area_3',
};

export async function safeGetRowData(
  page: Page,
  icyVeinsSource: TIcyVeinsSourceMap = 'overrall',
  specLink: string,
  retryCount: number = 0,
  reloadAttempted: boolean = false
): Promise<{ data: any[]; selector: string; rowCount: number }> {
  const area = icyVeinsSourceMap[icyVeinsSource];
  const selectors = {
    bisButton: 'span.toc_page_list_item > a:has-text("Gear and Best in Slot")',
    adBlockerButton: 'button:has-text("or continue with ad blocker")',
    rotationSwitches: `${area} table.rotation_switches.centered`,
  } as const;

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

    // Отладочная информация
    console.log(`   🔍 Отладка для источника ${icyVeinsSource}:`);
    console.log(`   📍 Область: ${area}`);
    console.log(
      `   🔄 Переключатели ротации: ${isRotationSelectorPresent ? 'найдены' : 'не найдены'}`
    );

    // Проверяем наличие различных элементов
    const areaExists = (await page.locator(area).count()) > 0;
    const imageBlockExists =
      (await page.locator(`div${area}.image_block_content`).count()) > 0;
    const selectedImageBlockExists =
      (await page.locator(`div${area}.image_block_content.selected`).count()) >
      0;
    const tableExists = (await page.locator(`${area} table`).count()) > 0;

    console.log(
      `   📦 Элемент ${area}: ${areaExists ? 'найден' : 'не найден'}`
    );
    console.log(
      `   🖼️ image_block_content: ${imageBlockExists ? 'найден' : 'не найден'}`
    );
    console.log(
      `   ✅ selected image_block_content: ${selectedImageBlockExists ? 'найден' : 'не найден'}`
    );
    console.log(
      `   📊 Таблица в области: ${tableExists ? 'найдена' : 'не найдена'}`
    );

    let evalSelector: string;

    // Специфичные селекторы для определенных страниц
    const specificSelectors: Record<string, string> = {
      'augmentation-evoker-pve-dps-gear-best-in-slot': `div${area} span:nth-of-type(2) table tbody tr`,
      'holy-priest-pve-healing-gear-best-in-slot': `div${icyVeinsSource === 'mythic' ? '#mplus' : icyVeinsSource === 'raid' ? '#raid' : '#overall'} table tbody tr`,
    };

    // Проверяем, есть ли специфичный селектор для данной страницы
    const specificSelector = Object.keys(specificSelectors).find((key) =>
      specLink.includes(key)
    );

    if (specificSelector) {
      evalSelector = specificSelectors[specificSelector] as string;
    } else if (isRotationSelectorPresent) {
      evalSelector = `div${area} div:nth-of-type(2) table tbody tr`;
    } else {
      // Для overrall (#area_1) используем селектор с selected, для остальных - без
      if (icyVeinsSource === 'overrall') {
        const selectedSelector = `div${area}.image_block_content.selected table tbody tr`;
        const count = await page.locator(selectedSelector).count();
        if (count > 0) {
          evalSelector = selectedSelector;
          console.log(
            `   🎯 Выбран селектор: ${selectedSelector} (найдено: ${count} элементов)`
          );
        } else {
          evalSelector = `${area} table tbody tr`;
          console.log(`   🎯 Fallback селектор: ${evalSelector}`);
        }
      } else {
        // Для raid и mythic используем упрощенный селектор без tbody
        evalSelector = `${area} table tr`;
        const count = await page.locator(evalSelector).count();
        console.log(
          `   🎯 Выбран селектор: ${evalSelector} (найдено: ${count} элементов)`
        );
      }
    }

    // Получаем данные напрямую без waitForSelector
    let rowDataCount = 0;
    try {
      rowDataCount = await page.locator(evalSelector).count();
      console.log(
        `   📊 Найдено строк с селектором ${evalSelector}: ${rowDataCount}`
      );

      if (rowDataCount === 0) {
        console.log(`   ⚠️ Селектор не нашел элементов: ${evalSelector}`);
        return { data: [], selector: evalSelector, rowCount: 0 };
      }
    } catch (error) {
      console.log(`   ⚠️ Ошибка при поиске селектора: ${evalSelector}`);
      return { data: [], selector: evalSelector, rowCount: 0 };
    }

    if (rowDataCount === 0) {
      // Если данные не найдены и мы еще не пытались перезагрузить страницу
      if (!reloadAttempted) {
        console.log('Данные не найдены, перезагружаем страницу...');
        await page.reload({ waitUntil: 'domcontentloaded' });
        await sleep(Math.random() * 3000 + 2000); // Ждем после перезагрузки

        // Повторяем попытку с флагом reloadAttempted = true и увеличиваем retryCount
        return safeGetRowData(
          page,
          icyVeinsSource,
          specLink,
          retryCount + 1,
          true
        );
      } else {
        console.log('Данные не найдены даже после перезагрузки страницы');
        return { data: [], selector: evalSelector, rowCount: 0 };
      }
    }

    // Извлекаем данные
    const rowsData = await parseRows(page, evalSelector);

    // Проверяем, что после извлечения данных у нас есть предметы
    if (rowsData.length === 0 && !reloadAttempted) {
      console.log('Предметы не извлечены, перезагружаем страницу...');
      await page.reload({ waitUntil: 'domcontentloaded' });
      await sleep(Math.random() * 3000 + 2000); // Ждем после перезагрузки

      // Повторяем попытку с флагом reloadAttempted = true и увеличиваем retryCount
      return safeGetRowData(
        page,
        icyVeinsSource,
        specLink,
        retryCount + 1,
        true
      );
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
