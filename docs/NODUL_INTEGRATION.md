# Интеграция с Нодуль (Telegram)

Система Second Brain может работать в облачном режиме через платформу [Нодуль](https://nodul.io), отправляя брифинги и уведомления в Telegram.

## Архитектура

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  GitHub Repo    │────▶│  Нодуль         │────▶│  Telegram       │
│  (private)      │     │  (AI Agent)     │     │  (notifications)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**Важно:** Облачный агент работает в режиме **READ-ONLY**. Для изменения данных редактируйте файлы локально — obsidian-git синхронизирует их с GitHub.

---

## Предварительные требования

1. Аккаунт на [nodul.io](https://nodul.io)
2. Telegram бот (создать через @BotFather)
3. Private GitHub репозиторий с хранилищем
4. GitHub Personal Access Token (PAT) с правами `repo`

---

## Настройка GitHub Token

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token с правами:
   - `repo` (полный доступ к приватным репозиториям)
3. Скопируйте токен (он покажется только один раз!)

---

## Настройка Нодуль

### Переменные сценария

Создайте переменные в настройках сценария:

| Переменная | Значение |
|------------|----------|
| `GITHUB_TOKEN` | Ваш Personal Access Token |
| `REPO_OWNER` | Ваш GitHub username |
| `REPO_NAME` | Название репозитория (например, `obsidian-vault`) |
| `TELEGRAM_BOT_TOKEN` | Токен вашего бота |
| `TELEGRAM_CHAT_ID` | Ваш chat ID |

### Получение TELEGRAM_CHAT_ID

1. Отправьте сообщение вашему боту
2. Откройте: `https://api.telegram.org/bot<TOKEN>/getUpdates`
3. Найдите `"chat":{"id":XXXXXXXXX}`

---

## HTTP Tools для Нодуль

### Tool: fetch_state

Загрузка состояния агента.

```
Method: GET
URL: https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_brain/state.json

Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

### Tool: fetch_daily

Загрузка daily note по дате.

```
Method: GET
URL: https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_daily/{{date}}.md

Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

### Tool: list_daily_notes

Список файлов в _daily/.

```
Method: GET
URL: https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_daily

Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
```

### Tool: fetch_prompt

Загрузка модуля промпта.

```
Method: GET
URL: https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_brain/prompts/{{file}}

Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

---

## Сценарий 1: Утренний брифинг (автоматический)

```
1. [Scheduler] → 07:00 ежедневно

2. [HTTP Request] fetch_prompt (manifest.md)
3. [HTTP Request] fetch_prompt (base.md)
4. [HTTP Request] fetch_prompt (cloud.md)

5. [HTTP Request] fetch_state

6. [HTTP Request] list_daily_notes
7. [Loop] для последних 7 файлов:
   [HTTP Request] fetch_daily

8. [AI Agent]
   - Системный промпт: manifest + base + cloud
   - Пользовательский промпт: "Сформируй утренний брифинг"
   - Контекст: state.json + daily notes

9. [Telegram Send Message]
   - Chat ID: {{TELEGRAM_CHAT_ID}}
   - Text: {{AI_RESPONSE}}
   - Parse mode: MarkdownV2
```

---

## Сценарий 2: Интерактивный бот

```
1. [Telegram Trigger] → входящее сообщение

2. [HTTP Request] fetch_state
3. [HTTP Request] list_daily_notes
4. [Loop] последние 7 daily notes

5. [AI Agent]
   - Системный промпт: manifest + base + cloud
   - Пользовательский промпт: {{MESSAGE_TEXT}}
   - Контекст: state.json + daily notes

6. [Telegram Send Message]
   - Reply to: {{MESSAGE_ID}}
   - Text: {{AI_RESPONSE}}
```

---

## Форматирование Telegram MarkdownV2

В Telegram MarkdownV2 нужно экранировать символы: `_ * [ ] ( ) ~ \` > # + - = | { } . !`

### Шаблон ответа

```
🎯 *Брифинг на {{date}}*

*Статус:* {{goal}} — {{status}}
*Интервенция:* {{intervention}}

📌 *Фокус сегодня*
{{focus}}

*Почему:* {{reason}}

⚠️ *Незакрытые задачи*
• Задача 1 \(5 дн\.\)
• Задача 2 \(3 дн\.\)
```

---

## Команды бота

| Команда | Действие |
|---------|----------|
| `статус` / `status` | Текущее состояние целей |
| `задачи` / `tasks` | Список незакрытых задач |
| `фокус` / `focus` | Фокус на сегодня |
| `[произвольный вопрос]` | AI ответ с контекстом |

---

## Обработка ошибок

### 404 Not Found
Файл не существует (например, daily note не создан).
```
Сообщение: "Daily note на {{date}} не найден. Создай заметку локально."
```

### 401 Unauthorized
Проблема с токеном.
```
Сообщение: "Ошибка авторизации GitHub. Проверь GITHUB_TOKEN."
```

### Rate Limit (403)
Превышен лимит GitHub API (5000 запросов/час для authenticated).
```
Сообщение: "Превышен лимит запросов. Попробуй позже."
```

---

## Тестирование

### Проверка GitHub API

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/vnd.github.raw" \
  "https://api.github.com/repos/USER/REPO/contents/_brain/state.json"
```

### Проверка Telegram бота

```bash
curl "https://api.telegram.org/botYOUR_TOKEN/sendMessage" \
  -d "chat_id=YOUR_CHAT_ID" \
  -d "text=Test message" \
  -d "parse_mode=MarkdownV2"
```
