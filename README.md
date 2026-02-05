# Second Brain Agent

AI-ассистент для управления фокусом и стратегического планирования.

Система "Второго мозга" помогает:
- Формировать ежедневные брифинги с приоритетами
- Отслеживать прогресс по целям
- Автоматически переносить незакрытые задачи
- Получать рекомендации на основе вашего манифеста

## Быстрый старт

### Автоматическая установка (рекомендуется)

Если у вас установлен [Claude Code CLI](https://claude.ai/claude-code), выполните одну команду:

```bash
claude "Установи и настрой систему Second Brain из https://github.com/bolkhovsky/second-brain-template"
```

Claude Code автоматически:
- Клонирует репозиторий
- Настроит рабочие файлы
- Интерактивно поможет заполнить ваш манифест и цели
- Создаст приватный GitHub репозиторий (опционально)
- Запустит первый брифинг

---

### Ручная установка

#### 1. Клонируйте репозиторий

```bash
mkdir ~/Documents/second-brain
git clone https://github.com/USERNAME/second-brain-template.git ~/Documents/second-brain
cd ~/Documents/second-brain
```

#### 2. Запустите скрипт настройки

```bash
chmod +x .scripts/setup.sh
.scripts/setup.sh
```

Скрипт:
- Переименует примеры файлов в рабочие
- Создаст первую daily note
- Подготовит репозиторий для вашего приватного GitHub

#### 3. Персонализируйте манифест

Отредактируйте `_brain/prompts/manifest.md` — замените пример на свой манифест:
- Ваша философия бизнеса/жизни
- Ключевые принципы
- Цели и ценности

#### 4. Создайте приватный репозиторий

```bash
# Создайте приватный репозиторий на GitHub (например, obsidian-vault)
git remote add origin https://github.com/YOUR_USERNAME/obsidian-vault.git
git push -u origin main
```

#### 5. Настройте obsidian-git (опционально)

Если используете Obsidian:
1. Установите плагин [obsidian-git](https://github.com/denolehov/obsidian-git)
2. Настройте auto-push/pull каждые 5 минут
3. Ваши заметки будут автоматически синхронизироваться

## Использование

### Утренний брифинг (CLI)

```bash
.scripts/second-brain.sh morning
```

Агент:
1. Прочитает ваше состояние и последние заметки
2. Определит приоритеты дня
3. Добавит брифинг в daily note

### Вечерний анализ

```bash
.scripts/second-brain.sh evening
```

### Задать вопрос

```bash
.scripts/second-brain.sh ask "Какие задачи я откладываю дольше всего?"
```

## Структура

```
.
├── _brain/
│   ├── prompts/           # Модули промпта агента
│   │   ├── manifest.md    # ВАШ манифест (персонализировать!)
│   │   ├── base.md        # Ядро логики
│   │   ├── local.md       # Для Claude Code CLI
│   │   └── cloud.md       # Для Нодуль/Telegram
│   ├── state.json         # Состояние агента
│   └── log.md             # История решений
├── _daily/                # Ежедневные заметки
├── _plans/                # 12-недельные планы
├── _templates/            # Шаблоны для Obsidian
├── @nodul_workflows/      # Сценарии автоматизации для Нодуль
├── .scripts/              # Скрипты запуска
└── docs/                  # Документация
```

## Требования

- [Claude Code CLI](https://claude.ai/claude-code) для локальной работы
- Git для синхронизации
- (Опционально) Obsidian + obsidian-git для визуального редактирования

## Интеграции

- **Claude Code CLI** — локальная работа с прямым доступом к файлам
- **[Нодуль](https://app.nodul.ru/auth?ref=822ADEDE) + Telegram** — облачный режим с уведомлениями (готовые сценарии в папке `@nodul_workflows/`)
- **Obsidian** — визуальный редактор заметок

Подробнее:
- [Детальная настройка](docs/SETUP.md)
- [Интеграция с Нодуль](docs/NODUL_INTEGRATION.md)
- [Персонализация манифеста](docs/CUSTOMIZATION.md)

## Лицензия

MIT
