import { Page } from '@playwright/test';

export const parseItems = async (page: Page) => {
  return await page
    .locator('.builds-best-in-slot-gear-section__gear')
    .evaluateAll((tables) => {
      // Локальный массив слотов экипировки
      const BODY_ITEMS = [
        'Helm',
        'Neck',
        'Shoulder',
        'Cloak',
        'Chest',
        'Bracers',
        'Gloves',
        'Belt',
        'Legs',
        'Boots',
        'Ring#1',
        'Ring#2',
      ];

      // Функция определения типа оружия/триньки
      function getWeaponType(column: string, row: string) {
        const key = `${column}-${row}`;
        const types: Record<string, string> = {
          '1-1': 'Main-Hand',
          '1-2': 'Off-Hand',
          '2-1': 'Trinket#1',
          '2-2': 'Trinket#2',
        };
        return types[key] || '';
      }

      // Функция для извлечения itemId из href
      function extractItemId(href: string) {
        if (!href) return '';
        const lastPart = href.split('/').pop() || '';
        const eqIdx = lastPart.indexOf('=');
        return eqIdx !== -1 ? lastPart.substring(eqIdx + 1) : '';
      }

      // Функция для парсинга чарок и камней
      function parseEnchantments(item: Element) {
        const enchantments: string[] = [];
        [
          '.gear-icon__item-meta__multitype a',
          '.gear-icon__item-meta__gems a',
          '.gear-icon__item-meta__enchant a',
        ].forEach((selector) => {
          item
            .querySelectorAll(`.gear-icon__item-meta ${selector}`)
            .forEach((ench) => {
              const enchId = extractItemId(ench.getAttribute('href') as string);
              if (enchId) enchantments.push(enchId);
            });
        });
        return enchantments;
      }

      // Основная логика парсинга
      const parsedItems: any[] = [];
      tables.forEach((table, tableIndex) => {
        if (tableIndex > 1) return;
        const itemsNodes = table.querySelectorAll(
          '.builds-best-in-slot-gear-section__gear-item'
        );
        itemsNodes.forEach((item, index) => {
          const itemWowHeadLink = item.querySelector(
            '.gear-icon__item-name a[class]:last-of-type'
          );

          const itemData = {
            itemId: '',
            itemName: '',
            itemType: '',
            enchantments: [] as string[],
          };

          if (itemWowHeadLink) {
            itemData.itemId = extractItemId(
              itemWowHeadLink.getAttribute('href') as string
            );
            itemData.itemName = itemWowHeadLink.textContent?.trim() || '';

            if (tableIndex === 0) {
              itemData.itemType = BODY_ITEMS[index] || '';
            } else if (tableIndex === 1) {
              const column = item.getAttribute('data-column') || '';
              const row = item.getAttribute('data-row') || '';
              itemData.itemType = getWeaponType(column, row);
            }
          }

          itemData.enchantments = parseEnchantments(item);
          parsedItems.push(itemData);
        });
      });
      return parsedItems;
    });
};

export const parseStats = async (page: Page): Promise<string[]> => {
  return await page.evaluate(() => {
    const stats: string[] = [];
    document
      .querySelectorAll(
        '.builds-stat-priority-section__container__stat-box__label'
      )
      .forEach((item) => {
        const text = (item as HTMLElement).innerText?.trim();
        if (text) stats.push(text);
      });
    return stats;
  });
};
