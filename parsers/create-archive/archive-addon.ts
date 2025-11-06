import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface ArchiveOptions {
  addonPath: string;
  outputDir: string;
  archiveName?: string;
  excludePatterns?: string[];
}

class AddonArchiver {
  private options: Required<ArchiveOptions>;

  constructor(options: ArchiveOptions) {
    this.options = {
      addonPath: path.resolve(options.addonPath),
      outputDir: path.resolve(options.outputDir),
      archiveName: options.archiveName || 'BiSFinder',
      excludePatterns: options.excludePatterns || [
        'node_modules',
        '.git',
        '.gitignore',
        '*.log',
        '*.tmp',
        '.DS_Store',
        'Thumbs.db',
      ],
    };
  }

  /**
   * Создает архив аддона
   */
  public async createArchive(): Promise<string> {
    console.log('🚀 Начинаем создание архива аддона...');

    // Проверяем существование папки аддона
    if (!fs.existsSync(this.options.addonPath)) {
      throw new Error(`Папка аддона не найдена: ${this.options.addonPath}`);
    }

    // Создаем папку для архивов если её нет
    if (!fs.existsSync(this.options.outputDir)) {
      fs.mkdirSync(this.options.outputDir, { recursive: true });
      console.log(`📁 Создана папка для архивов: ${this.options.outputDir}`);
    }

    // Генерируем имя архива без даты
    const archiveFileName = `${this.options.archiveName}.zip`;
    const archivePath = path.join(this.options.outputDir, archiveFileName);

    // Проверяем, существует ли уже архив с таким именем
    if (fs.existsSync(archivePath)) {
      console.log(
        `⚠️  Архив ${archiveFileName} уже существует, удаляем старый...`
      );
      fs.unlinkSync(archivePath);
    }

    try {
      // Создаем временную папку для копирования файлов
      const tempDir = path.join(this.options.outputDir, 'temp-addon');
      if (fs.existsSync(tempDir)) {
        fs.rmSync(tempDir, { recursive: true, force: true });
      }
      fs.mkdirSync(tempDir, { recursive: true });

      console.log('📋 Копируем файлы аддона...');
      await this.copyAddonFiles(tempDir);

      console.log('🗜️  Создаем ZIP архив...');
      await this.createZipArchive(tempDir, archivePath);

      // Удаляем временную папку
      fs.rmSync(tempDir, { recursive: true, force: true });

      const archiveSize = this.getFileSize(archivePath);
      console.log(`✅ Архив успешно создан: ${archivePath}`);
      console.log(`📦 Размер архива: ${archiveSize}`);
      console.log(`🔗 Для CurseForge используйте: ${archiveFileName}`);

      return archivePath;
    } catch (error) {
      console.error('❌ Ошибка при создании архива:', error);
      throw error;
    }
  }

  /**
   * Копирует файлы аддона во временную папку
   */
  private async copyAddonFiles(tempDir: string): Promise<void> {
    // Создаем папку BiSFinder в корне архива
    const targetDir = path.join(tempDir, 'BiSFinder');
    fs.mkdirSync(targetDir, { recursive: true });

    await this.copyDirectory(this.options.addonPath, targetDir);
  }

  /**
   * Рекурсивно копирует директорию
   */
  private async copyDirectory(src: string, dest: string): Promise<void> {
    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
      const srcPath = path.join(src, entry.name);
      const destPath = path.join(dest, entry.name);

      // Проверяем, нужно ли исключить файл/папку
      if (this.shouldExclude(entry.name)) {
        console.log(`⏭️  Пропускаем: ${entry.name}`);
        continue;
      }

      if (entry.isDirectory()) {
        fs.mkdirSync(destPath, { recursive: true });
        await this.copyDirectory(srcPath, destPath);
      } else {
        fs.copyFileSync(srcPath, destPath);
        console.log(`📄 Скопирован: ${entry.name}`);
      }
    }
  }

  /**
   * Проверяет, нужно ли исключить файл/папку
   */
  private shouldExclude(name: string): boolean {
    return this.options.excludePatterns.some((pattern) => {
      if (pattern.includes('*')) {
        // Экранируем специальные символы регулярных выражений, кроме *
        // Преобразуем * в .*, но экранируем точки и другие спецсимволы
        const escapedPattern = pattern
          .replace(/[.+?^${}()|[\]\\]/g, '\\$&') // Экранируем спецсимволы
          .replace(/\*/g, '.*'); // Заменяем * на .*
        // Якорим регулярное выражение для точного совпадения
        const regex = new RegExp(`^${escapedPattern}$`);
        return regex.test(name);
      }
      return name === pattern;
    });
  }

  /**
   * Создает ZIP архив
   */
  private async createZipArchive(
    sourceDir: string,
    archivePath: string
  ): Promise<void> {
    try {
      // Используем системную команду zip
      // Создаем архив с корневой папкой BiSFinder
      const command = `cd "${sourceDir}" && zip -r "${archivePath}" .`;
      execSync(command, { stdio: 'pipe' });
    } catch (error) {
      // Если zip не доступен, пробуем tar
      try {
        const command = `cd "${sourceDir}" && tar -czf "${archivePath.replace('.zip', '.tar.gz')}" .`;
        execSync(command, { stdio: 'pipe' });
        console.log('📦 Создан TAR.GZ архив вместо ZIP');
      } catch (tarError) {
        throw new Error(
          'Не удалось создать архив. Убедитесь, что установлены zip или tar'
        );
      }
    }
  }

  /**
   * Получает размер файла в читаемом формате
   */
  private getFileSize(filePath: string): string {
    const stats = fs.statSync(filePath);
    const bytes = stats.size;

    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  /**
   * Получает список всех архивов в папке
   */
  public getArchivesList(): string[] {
    if (!fs.existsSync(this.options.outputDir)) {
      return [];
    }

    return fs
      .readdirSync(this.options.outputDir)
      .filter((file) => file.endsWith('.zip') || file.endsWith('.tar.gz'))
      .sort((a, b) => {
        const aPath = path.join(this.options.outputDir, a);
        const bPath = path.join(this.options.outputDir, b);
        return (
          fs.statSync(bPath).mtime.getTime() -
          fs.statSync(aPath).mtime.getTime()
        );
      });
  }

  /**
   * Удаляет старые архивы (оставляет только последние N)
   */
  public cleanupOldArchives(keepCount: number = 5): void {
    const archives = this.getArchivesList();

    if (archives.length <= keepCount) {
      console.log(`📦 Всего архивов: ${archives.length}, очистка не требуется`);
      return;
    }

    const toDelete = archives.slice(keepCount);
    console.log(`🗑️  Удаляем ${toDelete.length} старых архивов...`);

    for (const archive of toDelete) {
      const archivePath = path.join(this.options.outputDir, archive);
      fs.unlinkSync(archivePath);
      console.log(`❌ Удален: ${archive}`);
    }

    console.log(`✅ Очистка завершена. Осталось архивов: ${keepCount}`);
  }
}

// Основная функция
async function main() {
  try {
    const archiver = new AddonArchiver({
      addonPath: '../addon',
      outputDir: './archives',
      archiveName: 'BiSFinder',
      excludePatterns: [
        'node_modules',
        '.git',
        '.gitignore',
        '*.log',
        '*.tmp',
        '.DS_Store',
        'Thumbs.db',
        '*.md', // Исключаем README файлы
      ],
    });

    // Создаем архив
    await archiver.createArchive();

    // Показываем список архивов
    console.log('\n📋 Список всех архивов:');
    const archives = archiver.getArchivesList();
    archives.forEach((archive, index) => {
      const archivePath = path.join(archiver['options'].outputDir, archive);
      const size = archiver['getFileSize'](archivePath);
      const stats = fs.statSync(archivePath);
      const date = stats.mtime.toLocaleDateString();
      console.log(`${index + 1}. ${archive} (${size}) - ${date}`);
    });

    // Очищаем старые архивы (оставляем последние 5)
    console.log('\n🧹 Очистка старых архивов...');
    archiver.cleanupOldArchives(5);
  } catch (error) {
    console.error('❌ Ошибка:', error);
    process.exit(1);
  }
}

// Запускаем скрипт если он вызван напрямую
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { AddonArchiver, ArchiveOptions };
