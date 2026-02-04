# Second Brain — Инструкции для Claude Code

> Этот файл содержит инструкции для автоматической установки системы Second Brain через Claude Code CLI.

## Быстрая установка

```bash
claude -p "Установи и настрой систему Second Brain из этого репозитория"
```

---

## Инструкции для Claude Code Agent

При получении запроса на установку Second Brain, выполни следующие шаги:

### Шаг 1: Определи целевую директорию

Спроси пользователя, куда установить систему. По умолчанию: `~/Documents/WORK`

```bash
# Пример
TARGET_DIR="$HOME/Documents/WORK"
```

### Шаг 2: Клонируй или скопируй репозиторий

Если текущая директория — это клонированный репозиторий шаблона:
```bash
# Скопировать содержимое в целевую директорию
cp -r . "$TARGET_DIR"
cd "$TARGET_DIR"
```

Если нужно клонировать:
```bash
git clone https://github.com/bolkhovsky/second-brain-template.git "$TARGET_DIR"
cd "$TARGET_DIR"
```

### Шаг 3: Преобразуй примеры в рабочие файлы

```bash
# state.json
mv _brain/state.json.example _brain/state.json

# Daily note с сегодняшней датой
TODAY=$(date +%Y-%m-%d)
sed "s/2026-01-01/$TODAY/g" _daily/2026-01-01.md.example > "_daily/$TODAY.md"
rm _daily/2026-01-01.md.example

# 12-week plan
mv _plans/12-week-plan.md.example _plans/12-week-plan.md

# Удалить .gitkeep файлы
find . -name ".gitkeep" -delete 2>/dev/null || true
```

### Шаг 4: Персонализация (интерактивно)

Спроси пользователя:

1. **Манифест**: "Хотите персонализировать манифест сейчас? Расскажите о вашей философии работы/бизнеса, ключевых принципах и целях."

2. **Цели**: "Какие 2-4 главные цели на ближайший квартал?"

3. **Паттерны**: "Какие дни недели для вас наиболее продуктивны? Что обычно мешает сосредоточиться?"

На основе ответов обнови:
- `_brain/prompts/manifest.md` — секция "Мой манифест"
- `_brain/state.json` — секция "goals" и "patterns"

### Шаг 5: Инициализируй Git

```bash
# Удалить исходный .git (от шаблона)
rm -rf .git

# Инициализировать новый репозиторий
git init
git add .
git commit -m "Initial Second Brain setup"
```

### Шаг 6: Настройка GitHub (опционально)

Спроси: "Хотите создать приватный GitHub репозиторий для синхронизации?"

Если да:
```bash
# Проверить gh CLI
if command -v gh &> /dev/null; then
    gh repo create obsidian-vault --private --source=. --push
else
    echo "Установите GitHub CLI (gh) или создайте репозиторий вручную"
    echo "Затем выполните:"
    echo "  git remote add origin https://github.com/USERNAME/obsidian-vault.git"
    echo "  git push -u origin main"
fi
```

### Шаг 7: Проверка Claude CLI

```bash
if command -v claude &> /dev/null; then
    echo "✓ Claude CLI найден"
else
    echo "⚠ Claude CLI не найден. Установите: https://claude.ai/claude-code"
fi
```

### Шаг 8: Первый тестовый запуск

```bash
chmod +x .scripts/second-brain.sh
.scripts/second-brain.sh morning
```

---

## Пример диалога установки

**User:** Установи и настрой систему Second Brain

**Claude:** Начинаю установку Second Brain.

1. **Куда установить?** (по умолчанию ~/Documents/WORK)

**User:** ~/my-brain

**Claude:** Устанавливаю в ~/my-brain...
[выполняет шаги 2-3]

2. **Персонализация манифеста.** Расскажите о вашей философии работы — что для вас важно, как вы принимаете решения, какие принципы вам близки?

**User:** Я фрилансер-дизайнер, работаю с 2-3 клиентами одновременно. Ценю баланс работы и жизни, не беру проекты с горящими дедлайнами. Верю в качество важнее количества.

**Claude:** Отлично! Обновляю манифест...
[обновляет manifest.md]

3. **Цели на квартал.** Какие 2-4 главные цели?

**User:** 
- Запустить личный сайт-портфолио
- Найти 2 постоянных клиента на retainer
- Освоить Figma AI

**Claude:** Добавляю цели в state.json...
[обновляет state.json]

4. **Паттерны продуктивности.** Какие дни для вас лучше всего? Что обычно мешает?

**User:** Вторник-четверг самые продуктивные. Мешают постоянные уведомления и срочные правки от клиентов.

**Claude:** Сохраняю паттерны...
[обновляет patterns в state.json]

5. **GitHub синхронизация?**

**User:** Да

**Claude:** Создаю приватный репозиторий...
[выполняет gh repo create]

✅ **Установка завершена!**

Запустите первый брифинг:
```bash
cd ~/my-brain
.scripts/second-brain.sh morning
```

---

## Структура после установки

```
~/my-brain/
├── _brain/
│   ├── prompts/
│   │   ├── manifest.md    ← Ваш персонализированный манифест
│   │   ├── base.md
│   │   ├── local.md
│   │   └── cloud.md
│   ├── state.json         ← Ваши цели и паттерны
│   └── log.md
├── _daily/
│   └── YYYY-MM-DD.md      ← Сегодняшняя заметка
├── _plans/
│   └── 12-week-plan.md
├── _templates/
├── .scripts/
│   ├── second-brain.sh
│   └── setup.sh
└── docs/
```

---

## Команды после установки

```bash
# Утренний брифинг
.scripts/second-brain.sh morning

# Вечерний анализ
.scripts/second-brain.sh evening

# Задать вопрос
.scripts/second-brain.sh ask "Какие задачи я откладываю?"

# Недельный обзор
.scripts/second-brain.sh weekly
```
