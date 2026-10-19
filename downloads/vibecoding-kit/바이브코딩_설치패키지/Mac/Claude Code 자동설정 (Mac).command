#!/bin/bash
echo "============================================"
echo " Claude Code + VSCode 자동 설정"
echo "============================================"
echo

if ! command -v code >/dev/null 2>&1; then
    echo "[오류] VSCode를 찾을 수 없습니다."
    echo "가이드 1단계에서 VSCode를 설치한 뒤, VSCode 안에서"
    echo "Cmd+Shift+P > 'Shell Command: Install code command in PATH' 를 실행하세요."
    read -p $'\n엔터를 누르면 종료합니다 '
    exit 1
fi
echo "[1/4] VSCode 확인 완료"
echo

# Git comes with the Command Line Tools; this pops the macOS install dialog if missing
if ! xcode-select -p >/dev/null 2>&1; then
    echo "[2/4] Git 설치 창을 띄웁니다. '설치'를 눌러주세요 (끝날 때까지 기다리지 않아도 됩니다)."
    xcode-select --install
else
    echo "[2/4] Git 확인 완료"
fi
echo

export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null 2>&1; then
    echo "[3/4] Claude Code 설치 중..."
    curl -fsSL https://claude.ai/install.sh | bash
    grep -q '.local/bin' "$HOME/.zshrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
else
    echo "[3/4] Claude Code 확인 완료"
fi
echo

echo "[4/4] VS Code 확장(Claude Code, Live Server) 설치 중..."
code --install-extension anthropic.claude-code
code --install-extension ritwickdey.LiveServer
echo

PROJECT="$HOME/Documents/vibe-coding"
mkdir -p "$PROJECT"
echo "작업 폴더 준비 완료: $PROJECT"
echo

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/../프롬프트.txt"
if [ -f "$PROMPT_FILE" ] && command -v pbcopy >/dev/null 2>&1; then
    LANG=en_US.UTF-8 pbcopy < "$PROMPT_FILE"
    echo "설정용 프롬프트를 클립보드에 복사했습니다. Claude 대화창에서 Cmd+V로 붙여넣으세요."
    echo
fi

echo "============================================"
echo " 자동 설정 끝! 잠시 후 VSCode가 열립니다."
echo " 왼쪽 사이드바의 Claude 아이콘을 눌러 로그인한 뒤,"
echo " 대화창에 Cmd+V로 붙여넣고 엔터를 누르세요."
echo " 로그인은 보안 절차라 자동화할 수 없어 직접 진행해야 합니다."
echo "============================================"
sleep 3
code "$PROJECT"

read -p $'\n엔터를 누르면 이 창을 닫습니다 '
