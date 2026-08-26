# AGENTS.md — 포트폴리오 사이트

김민재 개인 포트폴리오. 정적 HTML 사이트, 빌드 도구 없음(순수 HTML/CSS/JS).

## ⚠ 가장 먼저 읽을 것: 2단 구조

명함에 이미 `mkim.vercel.app`으로 QR코드가 인쇄되어 있어서 **이 주소는 절대 바꿀 수 없음**. 하지만 Vercel이 이 프로젝트에서 반복적으로 배포가 영구히 멈추는 장애를 겪어서(아래 "Vercel 장애 이력" 참고), 다음과 같이 분리했다(2026-08-26).

```
mkim.vercel.app                              ← QR코드가 가리키는 주소. 순수 리다이렉트 전용.
        │  (meta refresh + JS로 즉시 이동)
        ▼
rlaalswo4942.github.io/portfolio-site/       ← 실제 콘텐츠. 이 저장소를 GitHub Pages로 서빙.
```

- **실제 콘텐츠 수정은 전부 이 저장소(GitHub Pages)에서 한다.** `main`에 push하면 GitHub Pages가 자동으로 다시 빌드한다(보통 1분 이내, 안정적).
- `mkim.vercel.app` 쪽은 **다시는 재배포하지 않는다.** 별도의 독립된 임시 폴더에서 딱 한 번 배포된 상태로 그대로 둔다. 이 저장소의 git 히스토리와도 무관하다(git 연동 안 되어 있음, 의도적).
- `mkim.vercel.app`의 리다이렉트 페이지 소스는 아래 "리다이렉트 페이지 원본" 섹션에 그대로 백업해뒀다 — 혹시 그 프로젝트도 재생성해야 할 일이 생기면 이 내용 그대로 다시 배포하면 됨.

## 구조 (GitHub Pages 쪽, 실제 콘텐츠)

```
index.html              메인 인덱스 — 히어로 + 카테고리별 프로젝트 목록
assets/theme.css         전체 페이지 공용 스타일시트 (index + 모든 상세 페이지가 공유)
projects/<slug>.html     프로젝트별 개별 상세 페이지 (23개)
```

- 디자인 시스템: 화이트 배경 + `#111111` 잉크 모노크롬. 색상 대신 명암(채움/윤곽/흐림)으로 상태 표현.
- 프로젝트 목록은 격자 박스가 아니라 `flex-wrap` 기반의 여백 중심 나열(`​.grid`/`a.card`, 하드보더 없음) — 명확한 구획선 없이 부드럽게 흐르는 느낌 유지할 것.
- 모든 페이지가 `assets/theme.css` 하나를 공유하므로, 스타일 변경은 이 파일 한 곳만 고치면 전체에 반영됨.
- 상세 페이지는 섹션 구조가 통일되어 있음: 헤더(태그+제목+링크) → hook 문장 → 스크린샷 자리(placeholder) → Main Features → (선택) Data/Method/Validation/Limitation → Stack & Role → Coming Soon.
- 실제 스크린샷·GitHub 링크·검증 수치가 없는 프로젝트는 `<span class="placeholder">...추가 예정</span>` 또는 `.todo-block`으로 비워둠 — 지어내지 말고 실제 자료가 생기면 그때 채울 것.
- 저장소는 **공개(public)**임 — GitHub Pages 무료 플랜이 비공개 저장소를 지원하지 않아서 2026-08-26에 전환함. 민감한 내용(비밀키 등) 절대 커밋하지 말 것.

## 새 프로젝트 추가하는 법

1. `index.html`의 해당 카테고리 `<div class="grid">` 안에 카드 추가 (기존 카드 복사해서 텍스트만 교체, `href="projects/<slug>.html"`)
2. `projects/` 폴더에 기존 상세 페이지 하나를 복사해서 `<slug>.html`로 저장, 내용 교체 (`../assets/theme.css` 상대경로 유지)
3. 카테고리 프로젝트 수가 바뀌면 `index.html` 상단 `Projects` 통계 숫자도 갱신
4. 커밋 + push — 그게 끝. GitHub Pages가 자동으로 반영한다.

```bash
git add -A && git commit -m "..." && git push origin main
```

배포 확인:
```bash
gh api repos/rlaalswo4942/portfolio-site/pages/builds/latest   # status: "built" 되면 반영 완료
curl -s https://rlaalswo4942.github.io/portfolio-site/
```

## 하지 말 것

- `mkim.vercel.app` 프로젝트를 재배포하지 말 것 (아래 예외 상황 제외)
- 저장소를 다시 비공개로 전환하지 말 것 (GitHub Pages가 꺼짐)
- `index.html`/`projects/*.html`의 상대경로(`assets/theme.css`, `projects/...`, `../index.html`) 구조를 깨지 말 것 — GitHub Pages가 서브패스(`/portfolio-site/`)에서 서빙되므로 절대경로(`/assets/...`)로 바꾸면 깨짐

---

## Vercel 장애 이력 (참고용 — 이제 일상 작업엔 영향 없음)

2026-08-26, `mkim.vercel.app`에 배포할 때마다 `vercel deploy`/`vercel ls`가 `UNKNOWN` 상태로 영구히 멈추는 장애를 반복적으로 겪음. 확인된 패턴: **프로젝트를 삭제 후 재생성하면 그 직후 첫 배포만 항상 성공하고, 그 이후 배포는(CLI든 Git 자동배포든) 다시 멈춘다.** 계정/CLI/네트워크 문제 아님(무관한 새 프로젝트는 항상 정상), 로컬 세션 재연결로도 해결 안 됨, 막힌 배포만 지워도 뒤에 대기 중인 배포는 안 풀림 — Vercel 백엔드 쪽 문제로 추정, 근본 원인 미상.

이 문제 때문에 위의 2단 구조(Vercel=1회성 리다이렉트, GitHub Pages=실제 콘텐츠)로 전환함. **이제 콘텐츠를 아무리 자주 바꿔도 Vercel을 다시 건드릴 일이 없으므로 이 장애와 무관하다.**

### 예외: mkim.vercel.app 리다이렉트 자체를 재생성해야 하는 경우

(예: 실 콘텐츠 호스팅 주소가 바뀌었거나, Vercel 프로젝트가 완전히 사라졌거나 등 — 극히 드묾)

```bash
# 1. 새로운 독립 폴더 준비 (이 저장소와 무관하게, git 연결 없이)
mkdir mkim-redirect && cd mkim-redirect
# 아래 "리다이렉트 페이지 원본"을 index.html로 저장

# 2. 기존 프로젝트가 있다면 삭제 (Claude Code 자동 모드 분류기가 막을 수 있음 — 막히면 사용자가 직접 터미널에서 실행)
vercel remove mkim --yes

# 3. 재생성 + 링크 + 배포 (git connect는 절대 하지 말 것 — 재발 방지)
vercel project add mkim
vercel link --yes --project mkim
vercel deploy --prod --yes

# 4. 자동 별칭이 mkim.vercel.app으로 안 잡힐 수 있음 — 수동 지정 필수
vercel alias set <방금 나온 production URL> mkim.vercel.app

# 5. ⚠ 배포 보호(SSO Protection)가 기본 켜져 있어서 방문자가 로그인 페이지로 튕길 수 있음 — 반드시 끌 것
vercel project protection disable mkim --sso
```

배포 후 항상 `curl -s https://mkim.vercel.app | grep github.io`로 로그인 페이지가 아니라 리다이렉트 페이지가 나오는지 확인할 것.

### 리다이렉트 페이지 원본

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="0; url=https://rlaalswo4942.github.io/portfolio-site/">
<link rel="canonical" href="https://rlaalswo4942.github.io/portfolio-site/">
<title>김민재 · MinJae Kim</title>
<style>
  body { font-family: -apple-system, sans-serif; background: #fff; color: #111; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
  a { color: #111; }
</style>
<script>location.replace("https://rlaalswo4942.github.io/portfolio-site/");</script>
</head>
<body>
  <p>이동 중입니다… 자동으로 넘어가지 않으면 <a href="https://rlaalswo4942.github.io/portfolio-site/">여기를 클릭하세요</a>.</p>
</body>
</html>
```
