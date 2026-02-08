import { BrowserContext, Page } from '@playwright/test';
import { TArchonSourceMap } from 'Archon/types';
import { parseItems, parseStats } from './parseArchonBodyItems';

export const extractArchonRows = async (
  page: Page,
  source: TArchonSourceMap,
  context: BrowserContext
): Promise<{ taletns: string; items: any[]; stats: string[] }> => {
  if (source === 'raid') {
    const raidLink = await page
      .locator('a.tabbed-select__tab--rounded-square')
      .filter({ hasText: 'Raid' })
      .getAttribute('href');
    await page.goto(`https://www.archon.gg${raidLink}`, {
      timeout: 55000,
      waitUntil: 'domcontentloaded',
    });
  }
  if (source === 'mythic') {
    const mythicLink = await page
      .locator('a.tabbed-select__tab--rounded-square')
      .filter({ hasText: 'Mythic+' })
      .getAttribute('href');
    await page.goto(`https://www.archon.gg${mythicLink}`, {
      timeout: 55000,
      waitUntil: 'domcontentloaded',
    });
  }
  const data: { taletns: string; items: any[]; stats: string[] } = {
    taletns: '',
    items: [],
    stats: [],
  };
  // save talents
  await context.grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.click('button.talent-tree__interactions-export__copy-button ');

  const talentsCode = await page.evaluate(() => navigator.clipboard.readText());
  if (talentsCode) data.taletns = talentsCode;

  // parse items
  data.items = await parseItems(page);

  // parse stats (priority stats labels)
  data.stats = await parseStats(page);

  return data;
};
