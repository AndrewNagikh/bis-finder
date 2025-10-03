import path from 'node:path';
import fs from 'fs';

export const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

const rolePaths = {
  dps: path.resolve('generateBisSpecLinks/data/mythic-dps-links.txt'),
  tank: path.resolve('generateBisSpecLinks/data/mythic-tank-links.txt'),
  healer: path.resolve('generateBisSpecLinks/data/mythic-healer-links.txt'),
};

export async function processRoleFiles(
  role: 'dps' | 'tank' | 'healer',
  callback: (link: string) => void
) {
  try {
    const content = fs.readFileSync(rolePaths[role], 'utf-8');
    const links = content.split('\n').filter((line) => line.trim() !== '');

    console.log(
      `Обработка файла: ${rolePaths[role].split('/').pop()}, ссылок: ${links.length}`
    );

    for (const link of links) {
      console.log('Ссылка:', link);
      await callback(link);
    }
  } catch (err) {
    console.error('Ошибка при работе с папкой или файлами:', err.message);
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

export const formatDateDDMMYYYY = (date: Date) => {
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();

  return `${day}-${month}-${year}`;
};
