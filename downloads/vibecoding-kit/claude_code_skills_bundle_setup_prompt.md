# Claude Code 스킬 일괄 설치·패치·자동 활성화 프롬프트

아래 지시를 **설명만 하지 말고 실제 Claude Code 환경에서 순서대로 수행**한다.

목표는 다음과 같다.

- Claude Code 출력 토큰 절약
- 불필요한 코드와 과설계 방지
- 긴 세션의 컨텍스트 효율 개선
- 대용량 프로젝트 탐색 비용 절감
- 긴 문서/CLAUDE.md 압축
- 스킬을 한 번에 설치
- 기존 설정을 안전하게 백업한 뒤 패치
- Claude Code를 다시 실행했을 때 자동으로 적용
- 중복 훅/중복 규칙/충돌 최소화
- Windows 환경도 지원

---

## 0. 설치 대상

다음 스킬/플러그인을 우선 설치한다.

### A. Caveman — "우가우가"
공식 저장소:
`https://github.com/JuliusBrussee/caveman`

역할:
- 장황한 출력 제거
- 핵심 기술 정보 중심으로 답변
- 코드/명령어/오류 메시지는 정확하게 유지
- 출력 토큰 절약
- Claude Code에서는 가능하면 공식 플러그인 + hooks 방식 사용
- 매 세션 자동 활성화

### B. Ponytail — "꽁지머리 아저씨"
공식 저장소:
`https://github.com/DietrichGebert/ponytail`

역할:
- YAGNI
- 기존 코드 재사용 우선
- 표준 라이브러리 우선
- 플랫폼 기본 기능 우선
- 불필요한 추상화/파일/의존성 추가 방지
- 최소한의 코드로 해결
- 기본 모드는 `full`

### C. token-efficiency
우선 확인할 저장소:
`https://github.com/denfry/claude-skills`

역할:
- 매 응답과 도구 사용의 토큰 낭비 감소
- 중복 파일 읽기 방지
- 중복 명령 실행 방지
- 불필요한 설명 및 검증 루프 감소
- 가능하면 제공되는 always-on hook 사용

### D. strategic-compact
공개 원본/정상 배포본을 확인한 뒤 설치한다.

우선 후보:
`https://github.com/GRJY/Claude-Code-skill`

역할:
- 무작정 `/compact`하지 않음
- 작업 단계 경계에서 컨텍스트 압축
- 중요한 결정/진행 상태 보존

### E. token-compact
공식/원본 저장소:
`https://github.com/theosib/token-compact`

역할:
- Markdown
- CLAUDE.md
- 기획서
- 요구사항 문서
등을 의미 손실 없이 토큰 효율형으로 압축

### F. context-optimization
공개 원본/정상 배포본을 검색·검증 후 설치한다.

역할:
- 전체 코드베이스 무작정 로딩 금지
- search / grep / 필요한 범위 읽기 우선
- 대형 프로젝트의 컨텍스트 오염 최소화

---

# 1. 절대 원칙

아래 원칙을 반드시 지킨다.

1. 다운로드 URL을 추측하지 않는다.
2. 설치 전에 실제 저장소와 README/SKILL.md를 확인한다.
3. 기존 `~/.claude` 설정을 바로 덮어쓰지 않는다.
4. `settings.json`, `CLAUDE.md`, hooks를 수정하기 전에 백업한다.
5. 기존 hook을 삭제하지 말고 가능한 경우 병합한다.
6. 동일 hook을 중복 등록하지 않는다.
7. 이미 설치된 스킬은 중복 설치하지 말고 업데이트/검증한다.
8. 외부 install script는 내용을 확인하거나 `--dry-run`이 있으면 먼저 dry-run한다.
9. `curl | bash`, `irm | iex`를 무검토 상태로 바로 실행하지 않는다.
10. API key, SSH key, GitHub token, `.env`, Claude 인증정보를 외부로 전송하지 않는다.
11. 설치 중 실패한 항목 하나 때문에 전체 설정을 망가뜨리지 않는다.
12. 변경 내용을 최종적으로 diff 또는 파일 목록으로 검증한다.
13. 사용자의 기존 프로젝트 규칙은 삭제하지 않는다.
14. 안전성과 정확성을 토큰 절약보다 우선한다.

---

# 2. 환경 감지

먼저 다음을 조사한다.

- OS
- Shell
- Claude Code 설치 여부와 버전
- Node.js 버전
- npm / npx 사용 가능 여부
- Python 사용 가능 여부
- Git 사용 가능 여부
- `$CLAUDE_CONFIG_DIR`
- 기본 Claude config 경로
- `~/.claude/settings.json`
- `~/.claude/skills/`
- 프로젝트의 `.claude/`
- 프로젝트의 `CLAUDE.md`
- 기존 plugins
- 기존 marketplaces
- 기존 hooks
- 기존 statusLine
- 기존 skills

Windows에서는 PowerShell 기준으로 처리하되,
Git Bash/WSL을 쓰고 있다면 현재 실행 환경에 맞는 설치 방법을 선택한다.

---

# 3. 전체 백업

Claude 설정을 수정하기 전에 백업 디렉터리를 생성한다.

예:

`~/.claude/backups/skills-bundle-YYYYMMDD-HHMMSS/`

백업 대상:

- settings.json
- CLAUDE.md
- skills/
- hooks/
- plugin 관련 설정
- 기존 statusLine 설정
- 수정하게 되는 프로젝트 `.claude/` 파일

백업 실패 시 위험한 패치를 진행하지 않는다.

---

# 4. Caveman 설치 — 우가우가

먼저 공식 저장소의 현재 설치 문서를 확인한다.

`https://github.com/JuliusBrussee/caveman`

Claude Code에서는 공식 플러그인 설치 방식을 우선한다.

현재 공식 README/INSTALL 문서에서 여전히 유효하다면 다음 계열 명령을 사용한다.

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

이미 marketplace가 등록되어 있다면 다시 중복 등록하지 않는다.

이미 플러그인이 설치되어 있다면 설치 대신 업데이트 여부를 확인한다.

현재 공식 문서상 업데이트 명령이 유효하면:

```bash
claude plugin update caveman@caveman
```

Caveman의 Claude Code hooks가 정상 설치되었는지 확인한다.

특히 다음 기능을 검증한다.

- SessionStart 자동 활성화
- UserPromptSubmit mode tracking
- Caveman 관련 상태 파일
- status line 설정
- hook 파일 존재 여부

Caveman 공식 installer에 `--dry-run`이 제공되면
플러그인 설치만으로 hooks가 정상 구성되지 않았을 경우에만 dry-run 후 보조 설치를 사용한다.

Windows에서도 현재 공식 Windows 설치 지침을 따른다.

### Caveman 기본 상태

기본 모드는 지나치게 공격적인 `ultra`가 아니라
일반적인 토큰 절약에 적합한 안정 모드를 사용한다.

가능하면 `full`을 기본값으로 한다.

매 Claude Code 세션 시작 시 자동 활성화되는지 확인한다.

수동 `/caveman` 입력을 매번 요구하는 상태로 끝내지 않는다.

단, 공식 플러그인 구조가 변경되어 자동 활성화가 불가능한 경우
비공식 위험 패치를 만들지 말고 이유를 최종 보고한다.

---

# 5. Ponytail 설치 — 꽁지머리 아저씨

공식 저장소:

`https://github.com/DietrichGebert/ponytail`

공식 README의 현재 Claude Code 설치법을 우선한다.

현재도 유효하다면 다음 방식으로 설치한다.

```text
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

CLI에서 동일 동작을 지원하는 공식 명령이 있다면
대화형 명령 대신 CLI로 자동화해도 된다.

Ponytail 기본 역할:

1. 애초에 필요한 기능인가?
2. 기존 코드에 이미 있는가?
3. 표준 라이브러리로 가능한가?
4. 플랫폼 기본 기능으로 가능한가?
5. 이미 설치된 의존성으로 가능한가?
6. 한 줄 또는 작은 변경으로 가능한가?
7. 그 후에만 최소한의 새 코드를 작성

보안, 인증, 데이터 손실 방지, 입력 검증, 접근성은
단순화를 이유로 제거하지 않는다.

### Ponytail 자동 상태

기본 모드는:

`full`

로 설정한다.

Claude Code의 공식 plugin/hook 구조가 자동 규칙 주입을 지원하면
그 방식을 사용한다.

매 세션마다 사용자가 `/ponytail full`을 다시 입력해야 하는 구조라면,
공식 저장소의 hook 또는 persistent mode 기능을 먼저 확인한다.

공식 지원이 있으면 그것을 사용한다.

공식 지원이 없다면,
전역 CLAUDE.md에 Ponytail 전체 SKILL.md를 복붙하지 않는다.

대신 최소 길이의 트리거 규칙만 추가한다.

예:

```md
## Coding default
For coding tasks, consult and apply the installed Ponytail skill at `full` level unless the user explicitly disables it. Prefer YAGNI, reuse, stdlib/native features, and the smallest correct change. Never weaken security, validation, data-loss protection, or accessibility.
```

이 규칙은 실제로 필요한 경우에만 사용한다.

---

# 6. token-efficiency 설치

저장소 후보:

`https://github.com/denfry/claude-skills`

먼저 현재 저장소의 README와
`skills/token-efficiency/SKILL.md`
및 hooks 문서를 확인한다.

정상이고 현재 Claude Code와 호환되면 사용자 전역에 설치한다.

예상 위치:

`~/.claude/skills/token-efficiency/`

단 Claude Code 현재 버전의 공식 스킬 위치가 다르면
공식 위치를 우선한다.

이 스킬이 제공하는 hook installer가 있다면:

1. dry-run
2. 생성될 settings 변경 확인
3. 기존 hooks와 충돌 여부 확인
4. 안전하면 설치

순서로 진행한다.

hook installer가 idempotent인지 확인한다.

Caveman hook과 같은 이벤트를 사용하더라도
서로 덮어쓰지 않고 배열에 공존하도록 병합한다.

---

# 7. strategic-compact 설치

정상 원본을 확인한다.

우선 후보:

`https://github.com/GRJY/Claude-Code-skill`

다음 조건을 만족하는지 검증한다.

- 실제 `strategic-compact/SKILL.md` 존재
- 악성 스크립트 없음
- 현재 Claude Code와 호환
- `/compact` 남발을 유도하지 않음
- 중요한 결정과 진행 상태를 보존하도록 설계됨

확인 후 사용자 전역 skills 경로에 설치한다.

자동으로 `/compact`를 난사하는 hook은 만들지 않는다.

대신 다음 시점에만 활용한다.

- 조사 완료 → 구현
- 구현 완료 → 검증
- 대규모 디버깅 단계 완료
- 서로 다른 작업으로 전환
- 컨텍스트가 실제로 압박되는 시점

---

# 8. token-compact 설치

공식 저장소:

`https://github.com/theosib/token-compact`

현재 README와 Skill 구조를 확인한다.

가능하면 필요한 skill 디렉터리만 설치한다.

목적:

- 긴 CLAUDE.md 압축
- 기획 문서 압축
- 요구사항 압축
- 반복되는 자연어 지침 제거

압축할 때 다음은 절대 손실시키지 않는다.

- 수치
- 코드
- 경로
- URL
- 조건
- 예외
- 의존성
- TODO
- 명령어
- 파일명
- 결정 사항

기존 CLAUDE.md를 자동 압축해서 즉시 덮어쓰지는 않는다.

압축본을 먼저 별도 파일로 생성하고 diff를 확인한 뒤
의미 손실이 없을 때만 적용한다.

---

# 9. context-optimization 설치

정확한 최신 원본을 웹/GitHub에서 확인한다.

이름이 같은 저장소가 여러 개라면 다음 기준으로 선택한다.

1. 실제 Claude Code Agent Skill 구조
2. 최근 유지보수
3. 공개 라이선스
4. 설치 과정이 투명함
5. shell/hooks가 최소화됨
6. 과도한 권한 요구 없음

적절한 원본을 찾지 못하면
출처 불명의 스킬을 설치하지 않는다.

그 경우에만 아주 작은 로컬 커스텀 스킬을 생성한다.

커스텀 스킬의 핵심 규칙은 다음 정도로 제한한다.

```md
# Context Optimization

- Search before broad reading.
- Read only files and ranges needed for the task.
- Do not reread unchanged files without reason.
- Prefer grep/search/index over dumping whole repositories.
- Keep large logs and generated files out of context unless directly relevant.
- Summarize exploration before implementation when the explored context is large.
- Accuracy overrides token saving.
```

불필요하게 긴 SKILL.md를 만들지 않는다.

---

# 10. 스킬 역할 충돌 방지

역할을 다음처럼 명확히 분리한다.

## Caveman
"어떻게 말할 것인가"
- 출력 압축
- 군더더기 제거

## Ponytail
"얼마나 적게 만들 것인가"
- 최소 구현
- 과설계 방지

## token-efficiency
"전체 작업 과정에서 어디서 토큰을 아낄 것인가"
- 중복 읽기/실행/설명 방지

## strategic-compact
"언제 컨텍스트를 압축할 것인가"
- 단계 경계 압축

## token-compact
"긴 문서를 어떻게 압축할 것인가"
- 문서 자체 최적화

## context-optimization
"프로젝트에서 무엇을 읽을 것인가"
- 필요한 컨텍스트만 로딩

같은 규칙을 여러 파일에 복붙하지 않는다.

---

# 11. 기본 자동 실행 정책

최종 기본값은 다음으로 구성한다.

### 항상 적용
- Caveman: `full`
- token-efficiency: always-on core hook이 공식 제공되고 안전하면 활성화
- Ponytail: 코딩 작업에서 `full`

### 조건부 적용
- context-optimization: 코드베이스 탐색/대형 프로젝트
- strategic-compact: 긴 세션 및 작업 단계 경계
- token-compact: 긴 문서를 압축할 때

Caveman과 Ponytail을 모두 켠 결과가 너무 극단적으로 축약되어
필수 설명이나 요구사항이 손실되지 않도록 한다.

우선순위:

1. 정확성
2. 안전성
3. 사용자의 명시적 요구
4. 기능 완성
5. 최소 구현
6. 토큰 절약
7. 말투 압축

---

# 12. CLAUDE.md 최소 패치

자동 실행을 위해 CLAUDE.md가 필요한 경우에만 수정한다.

기존 내용을 삭제하지 않는다.

아래처럼 최소한의 bootstrap 규칙만 추가한다.

```md
## Installed workflow skills

For coding tasks, use the installed skills when relevant:

- Caveman: concise, high-signal responses; preserve exact code, commands and errors.
- Ponytail: default `full`; YAGNI → reuse → stdlib → native → existing dependency → smallest correct custom change.
- token-efficiency: avoid redundant reads, reruns, restatement and context growth.
- context-optimization: search first and read only relevant files/ranges.
- strategic-compact: compact only at logical phase boundaries or genuine context pressure.
- token-compact: use for long documents, preserving facts, numbers, paths, conditions and TODOs.

Accuracy, security, validation, data-loss protection and accessibility override brevity.
```

이미 각 plugin hook이 항상 주입하고 있다면
중복 CLAUDE.md 패치를 하지 않는다.

---

# 13. settings.json 안전 병합

`~/.claude/settings.json`을 수정할 때:

- JSON을 문자열 치환으로 수정하지 않는다.
- JSON parser로 읽고 병합한다.
- 기존 알 수 없는 키를 보존한다.
- 기존 hooks 배열을 보존한다.
- 같은 hook command가 이미 있으면 추가하지 않는다.
- statusLine이 이미 있으면 Caveman statusline으로 무조건 덮어쓰지 않는다.
- 가능한 경우 기존 statusline과 병합하거나 기존 설정을 유지한다.
- 변경 전에 백업한다.
- 변경 후 JSON parse 검증을 한다.

---

# 14. 통합 설치 스크립트 생성

설치가 정상 완료되면 재설치/복구용 스크립트를 생성한다.

Windows:
`setup-claude-skills.ps1`

macOS/Linux/WSL:
`setup-claude-skills.sh`

현재 OS에 필요한 파일은 반드시 만들고,
다른 OS용도 만들 수 있으면 함께 만든다.

스크립트 기능:

- 환경 검사
- 설정 백업
- 설치 여부 검사
- Caveman 설치/업데이트
- Ponytail 설치/업데이트
- token-efficiency 설치/업데이트
- strategic-compact 설치/업데이트
- token-compact 설치/업데이트
- context-optimization 설치/업데이트
- hooks 안전 병합
- 중복 제거
- 설치 검증
- 실패한 항목 표시

스크립트는 idempotent해야 한다.

두 번 실행해도 같은 항목이 중복 생성되지 않아야 한다.

---

# 15. 자동 패치 후 검증

다음 항목을 실제로 검사한다.

### 설치 상태
- Caveman 설치됨
- Ponytail 설치됨
- token-efficiency 설치됨
- strategic-compact 설치됨
- token-compact 설치됨
- context-optimization 설치됨 또는 안전한 로컬 대체본 존재

### Caveman
- SessionStart hook 확인
- mode tracker 확인
- 자동 활성화 확인
- 기본 mode 확인

### Ponytail
- skill/plugin 인식 확인
- coding task에서 `full` 기본 적용 확인
- off/normal 전환 가능 확인

### token-efficiency
- skill 인식
- hook 사용 시 중복 없음

### 설정
- settings.json 유효한 JSON
- 기존 hooks 보존
- 기존 statusLine 보존 또는 안전 병합
- 백업 존재

---

# 16. 기능 테스트

설치 후 간단한 테스트를 수행한다.

## 테스트 A — Caveman

질문:
`React에서 불필요한 re-render가 생기는 대표 원인 하나와 해결법을 설명해.`

통과 기준:
- 장황한 서론 없음
- 원인/해결책 빠르게 제시
- 기술 정보는 정확

## 테스트 B — Ponytail

요청:
`간단한 설정값 하나를 저장하기 위해 새 서비스 클래스, 인터페이스, 팩토리, 저장소 레이어를 만들어줘.`

통과 기준:
- 불필요한 계층을 거부/축소
- 더 작은 정상 구현 선택

## 테스트 C — token-efficiency/context-optimization

큰 프로젝트에서 특정 함수 위치를 찾게 한다.

통과 기준:
- 전체 저장소를 무작정 읽지 않음
- search/grep 우선
- 필요한 파일만 읽음

## 테스트 D — strategic-compact

짧은 작업에서는 compact를 요구하지 않아야 한다.

## 테스트 E — token-compact

긴 Markdown 샘플을 압축한다.

통과 기준:
- 의미 유지
- 숫자/경로/조건/TODO 유지

---

# 17. 재시작

hooks/plugin이 세션 시작 시 로드되는 경우
설치 완료 후 Claude Code를 새 세션에서 다시 시작해야 함을 확인한다.

현재 프로세스를 안전하게 자동 재시작할 수 있고
사용자의 작업 손실 위험이 없다면 재시작한다.

작업 중인 세션/미저장 작업 손실 가능성이 있으면
강제 종료하지 않는다.

그 경우 최종 출력에:

`새 Claude Code 세션부터 자동 활성화`

라고 명확하게 표시한다.

---

# 18. 실패 시 처리

설치 실패 시 임의의 가짜 성공 메시지를 출력하지 않는다.

각 항목을:

- SUCCESS
- UPDATED
- SKIPPED
- FALLBACK
- FAILED

중 하나로 표시한다.

출처를 검증하지 못한 스킬은 `FAILED` 또는 안전한 `FALLBACK`으로 처리한다.

기존 설정을 깨뜨렸다면 즉시 백업에서 복구한다.

---

# 19. 최종 출력 형식

모든 작업 후 설명을 길게 하지 말고 아래 형식으로만 보고한다.

```text
Claude Skills Bundle

Caveman            : SUCCESS / UPDATED / FAILED
Ponytail           : SUCCESS / UPDATED / FAILED
token-efficiency   : SUCCESS / UPDATED / FAILED
strategic-compact  : SUCCESS / UPDATED / FAILED
token-compact      : SUCCESS / UPDATED / FAILED
context-optimization: SUCCESS / FALLBACK / FAILED

AUTO
Caveman            : ON/OFF
Ponytail coding    : ON/OFF
token-efficiency   : ON/OFF

BACKUP
<backup path>

CHANGED
<changed files only>

RESTART
Required / Not required

TEST
Caveman             PASS/FAIL
Ponytail            PASS/FAIL
Token efficiency    PASS/FAIL
Context optimization PASS/FAIL
Strategic compact   PASS/FAIL
Token compact       PASS/FAIL

ISSUES
<only if something failed>
```

---

# 20. 최종 실행 명령

이제 위 내용을 다시 설명하지 말고 실제 설치 작업을 시작한다.

먼저 환경을 감지하고 기존 설정을 백업한다.

그 다음 공식 저장소와 현재 설치 문서를 확인한다.

검증되지 않은 스크립트를 바로 실행하지 않는다.

공식 플러그인/스킬 설치 방식을 우선한다.

설치 후 필요한 설정을 안전하게 병합하고,
Caveman과 Ponytail이 가능한 범위에서 새 세션마다 자동 적용되도록 구성한다.

마지막으로 실제 인식 여부와 hooks/settings 상태를 테스트한다.

**목표는 "파일을 다운로드했다"가 아니라 "Claude Code를 다음 세션에서 열었을 때 바로 사용할 수 있는 상태"다.**
