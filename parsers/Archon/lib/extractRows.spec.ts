import { BrowserContext, Page } from '@playwright/test';
import { TArchonSourceMap } from 'Archon/types';
import { parseItems } from './parseArchonBodyItems';

export const extractArchonRows = async (
  page: Page,
  source: TArchonSourceMap,
  context: BrowserContext
): Promise<{ taletns: string; items: any[] }> => {
  if (source === 'raid') {
    await page
      .locator('a.tabbed-select__tab--rounded-square')
      .filter({ hasText: 'Raid' })
      .click();
  }
  if (source === 'mythic') {
    await page
      .locator('a.tabbed-select__tab--rounded-square')
      .filter({ hasText: 'Mythic+' })
      .click();
  }
  const data: { taletns: string; items: any[] } = { taletns: '', items: [] };
  // save talents
  await context.grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.click('button.talent-tree__interactions-export__copy-button ');

  const talentsCode = await page.evaluate(() => navigator.clipboard.readText());
  if (talentsCode) data.taletns = talentsCode;

  //parse items
  data.items = await parseItems(page);
  return data;
};
