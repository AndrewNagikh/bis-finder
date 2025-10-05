import path from 'node:path';
import fs from 'fs';

const rolePaths = {
  dps: path.resolve('IcyVeins/generateBisSpecLinks/data/mythic-dps-links.txt'),
  tank: path.resolve(
    'IcyVeins/generateBisSpecLinks/data/mythic-tank-links.txt'
  ),
  healer: path.resolve(
    'IcyVeins/generateBisSpecLinks/data/mythic-healer-links.txt'
  ),
};

export async function processRoleFiles(
  role: 'dps' | 'tank' | 'healer',
  callback: (link: string, index: number, total: number) => Promise<void>
) {
  try {
    const content = fs.readFileSync(rolePaths[role], 'utf-8');
    const links = content.split('\n').filter((line) => line.trim() !== '');

    console.log('\n' + '='.repeat(80));
    console.log(`🎯 ОБРАБОТКА РОЛИ: ${role.toUpperCase()}`);
    console.log(`📁 Файл: ${rolePaths[role].split('/').pop()}`);
    console.log(`🔗 Всего ссылок: ${links.length}`);
    console.log('='.repeat(80) + '\n');

    for (let i = 0; i < links.length; i++) {
      const link = links[i];
      await callback(link, i + 1, links.length);
    }
  } catch (err) {
    console.error('❌ Ошибка при работе с папкой или файлами:', err.message);
  }
}

export function formatRoleName(role: string) {
  const raw = role
    .split('/')
    .pop()
    ?.replace(/-pve-(dps|healing|tank)-gear-best-in-slot/g, '')
    .split('-');
  // Форматируем каждое слово с заглавной буквы
  const formatted = (raw as string[]).map(
    (word) => word.charAt(0).toUpperCase() + word.slice(1)
  );

  // Объединяем с пробелом
  return formatted.join(' ');
}
