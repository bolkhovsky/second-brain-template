#!/bin/bash

# ============================================
# SECOND BRAIN SETUP SCRIPT
# ============================================

set -e

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🧠 Second Brain Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Определяем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo -e "${YELLOW}1. Конвертирую примеры в рабочие файлы...${NC}"

# Переименование state.json.example
if [ -f "_brain/state.json.example" ]; then
    mv "_brain/state.json.example" "_brain/state.json"
    echo -e "   ${GREEN}✓${NC} _brain/state.json создан"
fi

# Создание первой daily note
TODAY=$(date +%Y-%m-%d)
if [ -f "_daily/2026-01-01.md.example" ]; then
    # Используем сегодняшнюю дату
    sed "s/2026-01-01/$TODAY/g" "_daily/2026-01-01.md.example" > "_daily/$TODAY.md"
    rm "_daily/2026-01-01.md.example"
    echo -e "   ${GREEN}✓${NC} _daily/$TODAY.md создан"
fi

# Переименование плана
if [ -f "_plans/12-week-plan.md.example" ]; then
    mv "_plans/12-week-plan.md.example" "_plans/12-week-plan.md"
    echo -e "   ${GREEN}✓${NC} _plans/12-week-plan.md создан"
fi

# Удаление .gitkeep если есть файлы
find . -name ".gitkeep" -type f -delete 2>/dev/null || true

echo ""
echo -e "${YELLOW}2. Подготовка git репозитория...${NC}"

# Удаляем исходный .git (если клонировали из template)
if [ -d ".git" ]; then
    rm -rf .git
    echo -e "   ${GREEN}✓${NC} Исходный .git удалён"
fi

# Инициализируем новый репозиторий
git init
git add .
git commit -m "Initial Second Brain setup"
echo -e "   ${GREEN}✓${NC} Новый репозиторий инициализирован"

echo ""
echo -e "${YELLOW}3. Проверка Claude CLI...${NC}"

if command -v claude &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} Claude CLI найден: $(which claude)"
else
    echo -e "   ⚠️  Claude CLI не найден"
    echo "   Установите: https://claude.ai/claude-code"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Настройка завершена!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Следующие шаги:"
echo ""
echo "1. Отредактируйте манифест:"
echo "   ${BLUE}nano _brain/prompts/manifest.md${NC}"
echo ""
echo "2. Создайте приватный репозиторий на GitHub"
echo ""
echo "3. Подключите репозиторий:"
echo "   ${BLUE}git remote add origin https://github.com/USERNAME/obsidian-vault.git${NC}"
echo "   ${BLUE}git push -u origin main${NC}"
echo ""
echo "4. Запустите первый брифинг:"
echo "   ${BLUE}.scripts/second-brain.sh morning${NC}"
echo ""
