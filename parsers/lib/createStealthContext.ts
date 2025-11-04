import { BrowserContext, chromium } from '@playwright/test';

// Массивы для случайного выбора параметров
const USER_AGENTS = [
  // Chrome на macOS
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
  // Chrome на Windows
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  // Firefox на macOS
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0',
  // Firefox на Windows
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0',
  // Safari на macOS
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
];

const VIEWPORTS = [
  { width: 1920, height: 1080 }, // Full HD
  { width: 1366, height: 768 }, // Common laptop
  { width: 1536, height: 864 }, // Common laptop
  { width: 1440, height: 900 }, // MacBook
  { width: 1280, height: 720 }, // HD
  { width: 1600, height: 900 }, // WSXGA+
  { width: 2560, height: 1440 }, // 2K
];

const TIMEZONES = [
  'America/New_York',
  'America/Los_Angeles',
  'America/Chicago',
  'Europe/London',
  'Europe/Paris',
  'Europe/Berlin',
  'Asia/Tokyo',
  'Asia/Shanghai',
  'Australia/Sydney',
  'America/Toronto',
  'America/Vancouver',
  'Europe/Moscow',
];

const LOCALES = [
  { locale: 'en-US', languages: ['en-US', 'en'] },
  { locale: 'en-GB', languages: ['en-GB', 'en'] },
  { locale: 'de-DE', languages: ['de-DE', 'de', 'en'] },
  { locale: 'fr-FR', languages: ['fr-FR', 'fr', 'en'] },
  { locale: 'es-ES', languages: ['es-ES', 'es', 'en'] },
  { locale: 'ru-RU', languages: ['ru-RU', 'ru', 'en'] },
  { locale: 'ja-JP', languages: ['ja-JP', 'ja', 'en'] },
  { locale: 'zh-CN', languages: ['zh-CN', 'zh', 'en'] },
];

const DEVICE_SCALE_FACTORS = [1, 1.25, 1.5, 2];

// Случайный выбор элемента из массива
function randomChoice<T>(array: T[]): T {
  if (array.length === 0) {
    throw new Error('Array cannot be empty');
  }
  const index = Math.floor(Math.random() * array.length);
  return array[index] as T;
}

// Функция для создания stealth-контекста
async function createStealthContext(): Promise<BrowserContext> {
  // Случайные параметры
  const userAgent = randomChoice(USER_AGENTS);
  const viewport = randomChoice(VIEWPORTS);
  const timezone = randomChoice(TIMEZONES);
  const localeConfig = randomChoice(LOCALES);
  const deviceScaleFactor = randomChoice(DEVICE_SCALE_FACTORS);

  // Случайные значения для инжектируемого скрипта
  const colorDepths = [24, 30, 32];
  const colorDepth = randomChoice(colorDepths);
  const pluginCount = Math.floor(Math.random() * 3) + 3; // 3-5 плагинов

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
    userAgent,
    viewport,
    deviceScaleFactor,
    locale: localeConfig.locale,
    timezoneId: timezone,
    permissions: ['geolocation'],
    // Случайная цветовая схема (может быть светлая или тёмная)
    colorScheme: Math.random() > 0.5 ? 'light' : 'dark',
  });

  // Убираем следы автоматизации
  // Сериализуем значения в скрипт для корректной передачи в браузерный контекст
  const injectedLanguages = JSON.stringify(localeConfig.languages);
  const injectedColorDepth = colorDepth;
  const injectedPluginCount = pluginCount;

  await context.addInitScript(`
    (function() {
      const injectedLanguages = ${injectedLanguages};
      const injectedColorDepth = ${injectedColorDepth};
      const injectedPluginCount = ${injectedPluginCount};

      // Удаляем webdriver флаг
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined,
      });

      // Случайное количество плагинов
      Object.defineProperty(navigator, 'plugins', {
        get: () => Array.from({ length: injectedPluginCount }, (_, i) => i + 1),
      });

      Object.defineProperty(navigator, 'languages', {
        get: () => injectedLanguages,
      });

      // Случайная глубина цвета
      Object.defineProperty(screen, 'colorDepth', {
        get: () => injectedColorDepth,
      });

      // Случайное разрешение экрана (немного варьируем)
      const baseWidth = window.screen.width;
      const baseHeight = window.screen.height;
      const widthVariation = Math.floor(Math.random() * 10) - 5;
      const heightVariation = Math.floor(Math.random() * 10) - 5;

      Object.defineProperty(screen, 'width', {
        get: () => baseWidth + widthVariation,
      });
      Object.defineProperty(screen, 'height', {
        get: () => baseHeight + heightVariation,
      });
    })();
  `);

  return context;
}

export default createStealthContext;
