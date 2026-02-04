# Cloud режим (Нодуль + Telegram)

Этот модуль используется при работе через платформу Нодуль с доступом к данным через GitHub API.

## Ограничения cloud-режима

**ВАЖНО:** Cloud-агент работает в режиме **READ-ONLY**.

- Можно читать: state.json, daily notes, plans (через GitHub API)
- Нельзя писать в файлы напрямую
- Для записи: пользователь редактирует локально → obsidian-git sync → данные обновляются

---

## HTTP Tools (Нодуль)

### fetch_prompt
Загрузка модуля промпта из GitHub.
```
GET https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_brain/prompts/{{file}}
Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

### fetch_state
Загрузка состояния агента.
```
GET https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_brain/state.json
Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

### fetch_daily
Загрузка daily note по дате.
```
GET https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_daily/{{date}}.md
Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
  Accept: application/vnd.github.raw
```

### list_daily_notes
Список файлов в _daily/.
```
GET https://api.github.com/repos/{{REPO_OWNER}}/{{REPO_NAME}}/contents/_daily
Headers:
  Authorization: Bearer {{GITHUB_TOKEN}}
```

---

## Telegram MarkdownV2 форматирование

### Экранирование символов

В Telegram MarkdownV2 нужно экранировать следующие символы:
```
_ * [ ] ( ) ~ ` > # + - = | { } . !
```

Используй `\` перед каждым из этих символов.

### Примеры форматирования

```
*жирный текст*
_курсив_
__подчёркнутый__
~зачёркнутый~
||спойлер||
`код`
```code block```
[ссылка](URL)
```

### Шаблон ответа для Telegram

```
🎯 *Брифинг на {{date}}*

*Статус:* {{goal}} — {{status}}
*Интервенция:* {{intervention}}

📌 *Фокус сегодня*
{{focus}}

*Почему:* {{reason}}

{{#if pending_tasks}}
⚠️ *Незакрытые задачи*
{{#each pending_tasks}}
• {{task}} \({{age}} дн\.\)
{{/each}}
{{/if}}

{{#if changes}}
🔄 *Изменения планов*
{{#each changes}}
• {{description}}
{{/each}}
{{/if}}
```

---

## Режимы работы в Telegram

### Утренний брифинг (автоматический)
Триггер: Scheduler в 07:00

1. Fetch state.json
2. Fetch последние 7 daily notes (list + fetch each)
3. Сформировать брифинг по алгоритму из base.md
4. Отправить в Telegram с MarkdownV2 форматированием

### Интерактивный режим (по запросу)
Триггер: сообщение в Telegram боте

Команды:
- `статус` / `status` — текущее состояние целей
- `задачи` / `tasks` — список незакрытых задач
- `фокус` / `focus` — фокус на сегодня
- `[вопрос]` — произвольный вопрос по контексту

### Формат ответов

**Короткие ответы (до 100 символов):**
- Используй plain text
- Без форматирования

**Длинные ответы (брифинг, списки):**
- Используй MarkdownV2
- Группируй информацию в секции
- Используй emoji для визуального разделения

---

## Переменные сценария Нодуль

```
GITHUB_TOKEN    — Personal Access Token (repo scope)
REPO_OWNER      — имя пользователя GitHub
REPO_NAME       — название репозитория
TELEGRAM_BOT_ID — ID бота для отправки сообщений
CHAT_ID         — ID чата пользователя
```

---

## Обработка ошибок

### 404 Not Found
Файл не существует (например, daily note не создан).
→ Сообщить: "Daily note на {{date}} не найден. Создай заметку локально."

### 401 Unauthorized
Проблема с токеном.
→ Сообщить: "Ошибка авторизации GitHub. Проверь GITHUB_TOKEN."

### Rate Limit
Превышен лимит GitHub API.
→ Сообщить: "Превышен лимит запросов. Попробуй позже."

---

## Примеры сценариев Нодуль

### Scenario 1: Telegram Bot (интерактивный)
```
1. [Telegram Trigger] → получить сообщение
2. [HTTP] fetch_state → загрузить state.json
3. [HTTP] list_daily_notes → получить список файлов
4. [HTTP] fetch_daily (последние 7) → загрузить daily notes
5. [AI Agent] → обработать запрос с контекстом
6. [Telegram Send] → отправить ответ
```

### Scenario 2: Auto Briefing (ежедневный)
```
1. [Scheduler] 07:00
2. [HTTP] fetch prompts (manifest + base + cloud)
3. [HTTP] fetch_state
4. [HTTP] fetch daily notes (7 дней)
5. [AI Agent] → сформировать брифинг
6. [Telegram Send] → отправить брифинг
```
