#!/bin/bash

# ============================================
# SECOND BRAIN AGENT - Claude Code Runner
# ============================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Конфигурация
VAULT_PATH="${OBSIDIAN_VAULT:-$HOME/Documents/WORK}"
BRAIN_DIR="$VAULT_PATH/_brain"
DAILY_DIR="$VAULT_PATH/_daily"
PROMPTS_DIR="$BRAIN_DIR/prompts"
LOG_FILE="$HOME/.logs/second-brain.log"
TODAY=$(date +%Y-%m-%d)
WEEKDAY=$(LANG=ru_RU.UTF-8 date +%A)
CLAUDE_PATH="/usr/local/bin/claude"

# PATH для claude
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.npm-global/bin:$PATH"

# Режим работы: morning | evening | weekly | ask
MODE="${1:-morning}"
QUESTION="${2:-}"

# ============================================
# Функции
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ${NC}  $1"
    log "INFO: $1"
}

success() {
    echo -e "${GREEN}✓${NC}  $1"
    log "SUCCESS: $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC}  $1"
    log "WARN: $1"
}

error() {
    echo -e "${RED}✗${NC}  $1"
    log "ERROR: $1"
}

header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  🧠 Second Brain — $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Spinner для долгих операций
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# ============================================
# Проверки
# ============================================

header "$MODE"

info "Дата: $TODAY ($WEEKDAY)"
info "Vault: $VAULT_PATH"

# Проверить Claude CLI
if [ ! -f "$CLAUDE_PATH" ]; then
    error "Claude CLI не найден: $CLAUDE_PATH"
    exit 1
fi
success "Claude CLI найден"

# Создать директории
mkdir -p "$BRAIN_DIR" "$DAILY_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
success "Директории готовы"

# Проверить модули промптов
if [ ! -d "$PROMPTS_DIR" ]; then
    error "Директория промптов не найдена: $PROMPTS_DIR"
    exit 1
fi

MISSING_PROMPTS=0
for f in manifest.md base.md local.md; do
    if [ ! -f "$PROMPTS_DIR/$f" ]; then
        warn "Модуль не найден: $f"
        MISSING_PROMPTS=1
    fi
done

if [ $MISSING_PROMPTS -eq 0 ]; then
    success "Модули промптов найдены"
else
    error "Отсутствуют необходимые модули промптов"
    exit 1
fi

# Показать состояние
if [ -f "$BRAIN_DIR/state.json" ]; then
    info "state.json существует"
else
    warn "state.json не найден — будет создан"
fi

# Показать последние daily notes
DAILY_COUNT=$(ls -1 "$DAILY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
info "Daily notes: $DAILY_COUNT файлов"

echo ""

# ============================================
# Сборка системного промпта из модулей
# ============================================

info "Собираю системный промпт из модулей..."

# Композиция: manifest + base + local
SYSTEM_PROMPT=$(cat "$PROMPTS_DIR/manifest.md" "$PROMPTS_DIR/base.md" "$PROMPTS_DIR/local.md")

# Сохраняем системный промпт во временный файл
SYSTEM_PROMPT_FILE=$(mktemp)
echo "$SYSTEM_PROMPT" > "$SYSTEM_PROMPT_FILE"
success "Системный промпт собран ($(wc -l < "$SYSTEM_PROMPT_FILE" | tr -d ' ') строк)"

# ============================================
# Формирование промпта пользователя
# ============================================

case $MODE in
    morning)
        info "Режим: УТРЕННИЙ БРИФИНГ"
        PROMPT="Режим: MORNING ($TODAY, $WEEKDAY).
Выполни утренний брифинг согласно алгоритму из системного промпта.
1) Прочитай _brain/state.json
2) Прочитай последние 7 daily notes из _daily/
3) Сверь с планами из _plans/
4) Определи интервенцию
5) ВСТАВЬ секцию брифинга В НАЧАЛО файла _daily/$TODAY.md (создай если нет, сохрани существующий контент)
6) Обнови state.json
7) Добавь запись в _brain/log.md
ВАЖНО: Брифинг идёт В daily note, НЕ в отдельный today.md!"
        ;;

    evening)
        info "Режим: ВЕЧЕРНИЙ АНАЛИЗ"
        PROMPT="Режим: EVENING ($TODAY, $WEEKDAY).
Выполни вечерний анализ согласно системному промпту.
1) Прочитай _daily/$TODAY.md — найди секцию рефлексии
2) Оцени: был ли прогресс по главной цели? Выполнен ли фокус из брифинга?
3) Обнови _brain/state.json: streak или days_without_progress, strategic_ratio, followed в interventions_history
4) Добавь итог в _brain/log.md
НЕ меняй daily note, только читай."
        ;;

    weekly)
        info "Режим: НЕДЕЛЬНЫЙ ОБЗОР"
        PROMPT="Режим: WEEKLY REVIEW.
Выполни недельный обзор согласно системному промпту.
1) Прочитай все daily notes за 7 дней из _daily/
2) Проанализируй state.json
3) Создай _brain/weekly-$(date +%Y-W%V).md: прогресс по целям, паттерны, что работало/нет, рекомендации
4) Обнови patterns в state.json"
        ;;

    ask)
        if [ -z "$QUESTION" ]; then
            error "Использование: brain ask \"твой вопрос\""
            exit 1
        fi
        info "Режим: ВОПРОС"
        info "Вопрос: $QUESTION"
        PROMPT="Вопрос: $QUESTION. Учти state.json, последние daily notes, цели из _plans/. Ответ — конкретный и actionable."
        ;;

    *)
        error "Неизвестный режим: $MODE"
        echo ""
        echo "Использование: brain [morning|evening|weekly|ask] [вопрос]"
        echo ""
        echo "Режимы:"
        echo "  morning  — утренний брифинг с рекомендацией"
        echo "  evening  — вечерний анализ рефлексии"
        echo "  weekly   — недельный обзор"
        echo "  ask      — задать вопрос"
        rm -f "$SYSTEM_PROMPT_FILE"
        exit 1
        ;;
esac

# ============================================
# Запуск Claude
# ============================================

echo ""
echo -e "${YELLOW}▶ Запускаю Claude Code...${NC}"
echo -e "${YELLOW}  (это может занять 30-60 секунд)${NC}"
echo ""

log "Starting Second Brain Agent in mode: $MODE"
log "Prompt: $PROMPT"

cd "$VAULT_PATH" || exit 1

# Запуск Claude Code с выводом в терминал
START_TIME=$(date +%s)

"$CLAUDE_PATH" "$PROMPT" \
    --verbose \
    --permission-mode acceptEdits \
    --system-prompt "$SYSTEM_PROMPT_FILE" \
    --allowedTools "Bash(cat*) Bash(ls*) Bash(grep*) Bash(head*) Bash(tail*) Edit Read Write" \
    2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""

# ============================================
# Результат
# ============================================

# Очистка временного файла
rm -f "$SYSTEM_PROMPT_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    success "Готово за ${DURATION}с"

    # Показать что изменилось
    echo ""
    if [ -f "$DAILY_DIR/$TODAY.md" ]; then
        info "Daily note: $DAILY_DIR/$TODAY.md"
    fi

    if [ -f "$BRAIN_DIR/state.json" ]; then
        info "State обновлён"
    fi
else
    error "Claude завершился с ошибкой (код: $EXIT_CODE)"
    error "Смотри лог: $LOG_FILE"
fi

log "Claude Code finished with exit code: $EXIT_CODE (duration: ${DURATION}s)"

echo ""
exit $EXIT_CODE
