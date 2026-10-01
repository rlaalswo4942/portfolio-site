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

if ! command -v node >/dev/null 2>&1; then
    echo "[오류] Node.js를 찾을 수 없습니다."
    echo "가이드 2단계에서 Node.js를 먼저 설치해주세요."
    read -p $'\n엔터를 누르면 종료합니다 '
    exit 1
fi

echo "[1/3] VSCode, Node.js 확인 완료"
echo

echo "[2/3] Claude Code 확장 설치 중..."
code --install-extension anthropic.claude-code
echo

PROJECT="$HOME/Desktop/my-first-app"
mkdir -p "$PROJECT"
echo "[3/3] 연습용 폴더 준비 완료: $PROJECT"
echo

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/../프롬프트.txt"
if [ -f "$PROMPT_FILE" ] && command -v pbcopy >/dev/null 2>&1; then
    pbcopy < "$PROMPT_FILE"
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
