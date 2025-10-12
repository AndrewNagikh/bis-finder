import { Page } from '@playwright/test';

const parseRows = async (page: Page, evalSelector: string) => {
  const data = await page.locator(evalSelector).evaluateAll((rows) => {
    return rows
      .map((row) => {
        const cells = Array.from(row.querySelectorAll('td'));
        if (cells.length < 3) return null;
        const itemType = cells[0]?.textContent?.trim() || '';

        // Проверяем, есть ли списки в ячейках (множественные предметы)
        const itemList = cells[1]?.querySelector('ul');
        const sourceList = cells[2]?.querySelector('ul');

        if (itemList && sourceList) {
          // Обрабатываем случай с множественными предметами
          const itemElements = Array.from(itemList.querySelectorAll('li'));
          const sourceElements = Array.from(sourceList.querySelectorAll('li'));

          const items = [];
          for (let i = 0; i < itemElements.length; i++) {
            const itemElement = itemElements[i];
            const sourceElement = sourceElements[i];

            let itemId = '';
            let itemName = '';
            const source = sourceElement?.textContent?.trim() || '';

            // Ищем ссылку на предмет в элементе
            const aElement = itemElement?.querySelector(
              'a[data-wowhead]'
            ) as HTMLAnchorElement;
            const spanElement = itemElement?.querySelector(
              'span[data-wowhead]'
            ) as HTMLSpanElement;

            if (spanElement) {
              const dataWowhead = spanElement.getAttribute('data-wowhead');
              const match = dataWowhead?.match(/item=(\d+)/);
              itemName = spanElement.textContent?.trim() || '';
              if (match) itemId = match[1] as string;
            }
            if (aElement) {
              const dataWowhead = aElement.getAttribute('data-wowhead') || '';
              const match = dataWowhead.match(/item=(\d+)/);
              itemName = aElement.textContent?.trim() || '';
              if (match) itemId = match[1] as string;
            }

            if (itemId && itemName) {
              items.push({ itemType, itemId, itemName, source });
            }
          }

          return items.length > 0 ? items : null;
        } else {
          // Обрабатываем обычный случай (один предмет)
          let itemId = '';
          let itemName = '';
          let source = '';

          const aElement = cells[1]?.querySelector(
            'a[data-wowhead]'
          ) as HTMLAnchorElement;
          const spanElement = cells[1]?.querySelector(
            'span[data-wowhead]'
          ) as HTMLSpanElement;

          if (spanElement) {
            const dataWowhead = spanElement.getAttribute('data-wowhead');
            const match = dataWowhead?.match(/item=(\d+)/);
            itemName = spanElement.textContent?.trim() || '';
            if (match) itemId = match[1] as string;
          }
          if (aElement) {
            const dataWowhead = aElement.getAttribute('data-wowhead') || '';
            const match = dataWowhead.match(/item=(\d+)/);
            itemName = aElement.textContent?.trim() || '';
            if (match) itemId = match[1] as string;
          }

          source = cells[2]?.textContent?.trim() || '';
          return itemId && itemName
            ? { itemType, itemId, itemName, source }
            : null;
        }
      })
      .filter(Boolean)
      .flat();
  });
  return data;
};

export default parseRows;
