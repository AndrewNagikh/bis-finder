import { test } from '@playwright/test';
import fs from 'fs';
import createStealthContext from 'lib/createStealthContext';
import { sleep } from 'lib/helpers';
import path from 'path';

test('find Mythic+ links with stealth protection', async ({}) => {
  test.setTimeout(300000); // 5 минут на тест

  const context = await createStealthContext();

  try {
    const page = await context.newPage();

    await page.goto('https://www.icy-veins.com/wow/tier-lists', {
      timeout: 60000,
      waitUntil: 'domcontentloaded',
    });

    const mythicLinks = await page
      .locator('a.nav_content_block_entry_button')
      .filter({ hasText: 'Mythic+' })
      .evaluateAll((anchors) =>
        anchors.map((a) => {
          let href = a.getAttribute('href') || '';
          if (href.startsWith('//')) href = 'https:' + href;
          return href;
        })
      );

    console.log('Mythic+ links found:', mythicLinks);

    for (const role of mythicLinks) {
      await page.goto(role, {
        timeout: 60000,
        waitUntil: 'domcontentloaded',
      });

      const spec = await page
        .locator('details.details-block div.centered a')
        .evaluateAll((anchors: HTMLLinkElement[]) =>
          anchors.map((a) => a.href)
        );

      const roleFileName = role.split('/').pop()?.replace('tier-list', 'links');
      const roleFilePath = path.resolve(
        `IcyVeins/generateBisSpecLinks/data/${roleFileName}.txt`
      );
      if (!fs.existsSync(roleFilePath)) {
        fs.writeFile(roleFilePath, '', (err) => {
          if (err) throw err;
          console.log(`Файл ${roleFileName} создан`);
        });
      } else {
        console.log(`Processing ${spec.length} specs from ${role}`);
        fs.truncate(roleFilePath, 0, (err) => {
          if (err) throw err;
          console.log(`Файл ${roleFileName} очищен`);
          for (let i = 0; i < spec.length; i++) {
            const specLink = spec[i]?.replace(
              /guide|mythic-plus-tips/gm,
              'gear-best-in-slot'
            );
            if (fs.existsSync(roleFilePath)) {
              fs.writeFileSync(roleFilePath, `${specLink}\n`, {
                flag: 'a',
                encoding: 'utf-8',
              });
            }
          }
        });
      }

      // Пауза между разными классами
      await sleep(10000);
    }
  } finally {
    try {
      await context.close();
    } catch {
      // Игнорируем ошибки закрытия контекста
    }
  }
});
