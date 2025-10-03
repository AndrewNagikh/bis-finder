import { BrowserContext, chromium } from '@playwright/test';

// Функция для создания stealth-контекста
async function createStealthContext(): Promise<BrowserContext> {
  const browser = await chromium.launch({
    headless: false, // Используем headful режим
    args: [
      '--disable-blink-features=AutomationControlled',
      '--disable-dev-shm-usage',
      '--disable-web-security',
      '--disable-features=VizDisplayCompositor',
    ],
  });

  const context = await browser.newContext({
    userAgent:
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    viewport: { width: 1920, height: 1080 },
    deviceScaleFactor: 1,
    locale: 'en-US',
    timezoneId: 'America/New_York',
    permissions: ['geolocation'],
  });

  // Убираем следы автоматизации
  await context.addInitScript(() => {
    // Удаляем webdriver флаг
    Object.defineProperty(navigator, 'webdriver', {
      get: () => undefined,
    });

    // Маскируем другие признаки автоматизации
    Object.defineProperty(navigator, 'plugins', {
      get: () => [1, 2, 3, 4, 5],
    });

    Object.defineProperty(navigator, 'languages', {
      get: () => ['en-US', 'en'],
    });
  });

  return context;
}

export default createStealthContext;
