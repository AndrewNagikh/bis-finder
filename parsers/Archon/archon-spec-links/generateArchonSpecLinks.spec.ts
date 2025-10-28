import test from '@playwright/test';
import fs from 'fs';
import createStealthContext from 'lib/createStealthContext';
import { sleep } from 'lib/helpers';
import path from 'path';

const archonTierListLink = {
  dps: 'https://www.archon.gg/wow/tier-list/dps-rankings/mythic-plus/10/all-dungeons/this-week',
  tank: 'https://www.archon.gg/wow/tier-list/tank-rankings/mythic-plus/10/all-dungeons/this-week',
  healer:
    'https://www.archon.gg/wow/tier-list/healer-rankings/mythic-plus/10/all-dungeons/this-week',
};

test('generate archon spec links', async () => {
  test.setTimeout(300000);

  const context = await createStealthContext();

  try {
    const page = await context.newPage();
    const linksEntries = Object.entries(archonTierListLink);
    for await (const entry of linksEntries) {
      const [role, link] = entry;

      await page.goto(link, {
        timeout: 60000,
        waitUntil: 'domcontentloaded',
      });

      const specLinks = await page
        .locator('.builds-tier-list-section__spec a')
        .evaluateAll((anchors) =>
          anchors.map((a) => {
            let href = a.getAttribute('href') || '';
            href = 'https://www.archon.gg' + href;
            return href;
          })
        );
      // eslint-disable-next-line no-console
      console.log(`Found ${specLinks.length} spec links for ${role}`);

      // Сохраняем ссылки в файл
      const roleFileName = `mythic-${role}-links.txt`;
      const roleFilePath = path.resolve(
        `Archon/archon-spec-links/data/${roleFileName}`
      );

      // Создаем директорию если не существует
      const dataDir = path.dirname(roleFilePath);
      if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
      }

      // Очищаем файл и записываем новые ссылки
      fs.writeFileSync(roleFilePath, '', 'utf-8');
      for (const specLink of specLinks) {
        fs.writeFileSync(roleFilePath, `${specLink}\n`, {
          flag: 'a',
          encoding: 'utf-8',
        });
      }

      // eslint-disable-next-line no-console
      console.log(`Saved ${specLinks.length} links to ${roleFileName}`);

      // Пауза между разными ролями
      await sleep(5000);
    }
  } finally {
    try {
      await context.close();
    } catch {
      // Игнорируем ошибки закрытия контекста
    }
  }
});
