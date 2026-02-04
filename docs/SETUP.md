# Детальная настройка Second Brain

## Требования

### Обязательные
- **Git** — для версионирования и синхронизации
- **Claude Code CLI** — для работы агента
  - Установка: https://claude.ai/claude-code
  - Требуется активная подписка Claude Pro/API

### Опциональные
- **Obsidian** — визуальный редактор заметок
- **obsidian-git** — плагин для автосинхронизации
- **GitHub CLI (gh)** — для быстрого создания репозиториев

---

## Пошаговая установка

### 1. Клонирование шаблона

```bash
# Клонируйте в вашу рабочую директорию
git clone https://github.com/USERNAME/second-brain-template.git ~/Documents/WORK

# Или в любую другую папку
git clone https://github.com/USERNAME/second-brain-template.git ~/my-second-brain
```

### 2. Запуск скрипта настройки

```bash
cd ~/Documents/WORK
chmod +x .scripts/setup.sh
.scripts/setup.sh
```

Скрипт выполнит:
- Переименование `.example` файлов в рабочие
- Создание первой daily note с сегодняшней датой
- Инициализацию нового git-репозитория (удалит исходный .git)

### 3. Персонализация манифеста

Откройте `_brain/prompts/manifest.md` и замените пример на ваш манифест.

Хороший манифест включает:
- Вашу философию работы/бизнеса
- Ключевые принципы принятия решений
- Долгосрочные цели и ценности
- Ограничения и границы

### 4. Настройка целей в state.json

Отредактируйте `_brain/state.json`:

```json
{
  "goals": {
    "project_alpha": {
      "name": "Название вашего проекта",
      "target": "Конкретный, измеримый результат",
      "current": "Текущее состояние",
      "progress_percent": 0,
      "trend": "stable"
    }
  }
}
```

### 5. Создание приватного репозитория

```bash
# Через GitHub CLI
gh repo create obsidian-vault --private

# Или создайте вручную на github.com
```

### 6. Подключение к GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/obsidian-vault.git
git branch -M main
git push -u origin main
```

---

## Настройка Obsidian

### Установка плагинов

1. Откройте Obsidian → Settings → Community plugins
2. Установите рекомендуемые плагины:
   - **Calendar** — навигация по daily notes
   - **Templater** — шаблоны для создания заметок
   - **Tasks** — управление задачами
   - **Dataview** — запросы к заметкам
   - **obsidian-git** — синхронизация с GitHub

### Настройка obsidian-git

1. Settings → obsidian-git
2. Auto pull interval: 5 минут
3. Auto push interval: 5 минут
4. Commit message: `vault backup: {{date}}`

### Настройка Templater

1. Settings → Templater
2. Template folder: `_templates`
3. Включите "Trigger Templater on new file creation"

---

## Настройка переменной окружения

Укажите путь к хранилищу:

```bash
# В ~/.bashrc или ~/.zshrc
export OBSIDIAN_VAULT="$HOME/Documents/WORK"
```

---

## Проверка установки

```bash
# Проверить структуру
ls -la _brain/
ls -la _daily/
ls -la _plans/

# Проверить Claude CLI
claude --version

# Запустить тестовый брифинг
.scripts/second-brain.sh morning
```

---

## Решение проблем

### Claude CLI не найден

```bash
# Проверьте путь
which claude

# Если установлен в другом месте, обновите .scripts/second-brain.sh:
# CLAUDE_PATH="/path/to/claude"
```

### Permission denied

```bash
chmod +x .scripts/second-brain.sh
chmod +x .scripts/setup.sh
```

### Git push требует пароль

Используйте SSH или Personal Access Token:
```bash
# SSH
git remote set-url origin git@github.com:USERNAME/obsidian-vault.git

# HTTPS с токеном
git remote set-url origin https://TOKEN@github.com/USERNAME/obsidian-vault.git
```
