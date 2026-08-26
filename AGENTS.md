# AGENTS.md — 포트폴리오 사이트

김민재 개인 포트폴리오. 정적 HTML 사이트, 빌드 도구 없음(순수 HTML/CSS/JS).

## 구조

```
index.html              메인 인덱스 — 히어로 + 카테고리별 프로젝트 그리드
assets/theme.css         전체 페이지 공용 스타일시트 (index + 모든 상세 페이지가 공유)
projects/<slug>.html     프로젝트별 개별 상세 페이지 (23개)
```

- 디자인 시스템: 화이트 배경 + `#111111` 잉크 모노크롬. 색상 대신 명암(채움/윤곽/흐림)으로 상태 표현.
- 모든 페이지가 `assets/theme.css` 하나를 공유하므로, 스타일 변경은 이 파일 한 곳만 고치면 전체에 반영됨.
- 상세 페이지는 섹션 구조가 통일되어 있음: 헤더(태그+제목+링크) → hook 문장 → 스크린샷 자리(placeholder) → Main Features → (선택) Data/Method/Validation/Limitation → Stack & Role → Coming Soon.
- 실제 스크린샷·GitHub 링크·검증 수치가 없는 프로젝트는 `<span class="placeholder">...추가 예정</span>` 또는 `.todo-block`으로 비워둠 — 지어내지 말고 실제 자료가 생기면 그때 채울 것.

## 새 프로젝트 추가하는 법

1. `index.html`의 해당 카테고리 `<div class="grid">` 안에 카드 추가 (기존 카드 복사해서 텍스트만 교체, `href="projects/<slug>.html"`)
2. `projects/` 폴더에 기존 상세 페이지 하나를 복사해서 `<slug>.html`로 저장, 내용 교체 (`../assets/theme.css` 상대경로 유지)
3. 카테고리 프로젝트 수가 바뀌면 `index.html` 상단 `Projects` 통계 숫자도 갱신
4. 커밋 + push (아래 배포 절차 참고)

## 배포

**주 경로 (자동)**: GitHub(`rlaalswo4942/portfolio-site`)에 Vercel Git 연동이 붙어 있음. `main`에 push하면 자동으로 `mkim.vercel.app`에 배포됨. 평소엔 그냥 커밋 + push만 하면 됨.

```
git add -A && git commit -m "..." && git push origin main
```

**수동 경로 (필요시)**: 즉시 확인하고 싶거나 자동 배포가 안 됐을 때.

```
vercel deploy --prod --yes
```

이 명령은 오래 걸릴 수 있으니(아래 장애 참고) `run_in_background: true`로 실행하고 충분히 기다릴 것 — 90~100초 타임아웃으로 강제 종료하지 말 것.

## ⚠ 알려진 장애: 배포가 "Building…"에서 영구히 멈춤

**증상**: `vercel deploy` 또는 git push 배포가 `Building…`에서 멈추고, `vercel ls`로 봐도 상태가 `UNKNOWN`으로 몇 분~몇십 분째 안 바뀜. `vercel inspect --logs`로도 로그가 전혀 안 나옴.

**원인**: Vercel(Hobby 플랜) 쪽에서 이 프로젝트의 빌드 큐 슬롯이 막히는 문제로 추정(2026-08-26 최소 2회 재현, 원인 특정 못함 — 계정/CLI/네트워크 문제 아님, 무관한 새 프로젝트는 항상 즉시 성공했음). 개별 배포를 `vercel remove <deployment-url>`로 지워도 큐는 안 풀림. 12분간 전혀 개입하지 않고 관찰해도 저절로 안 풀림 — "느려서 그런가" 하고 더 기다리는 건 의미 없음.

**유일하게 확인된 해결책**: 프로젝트 자체를 삭제하고 동일한 이름으로 재생성. 이렇게 하면 `mkim.vercel.app` 주소(별칭)는 그대로 유지되면서 큐만 초기화됨. 지금까지 두 번 다 이 방법으로 즉시 해결됨.

```bash
# 1. 프로젝트 전체 삭제 (배포 하나가 아니라 프로젝트 자체)
vercel remove mkim --yes

# 2. 동일한 이름으로 재생성 + 현재 폴더 연결
cd portfolio-site
rm -rf .vercel
vercel project add mkim
vercel link --yes --project mkim

# 3. Git 연동 다시 붙이기 (재생성하면 끊김)
vercel git connect https://github.com/rlaalswo4942/portfolio-site.git --yes

# 4. 배포
vercel deploy --prod --yes
```

`vercel remove mkim --yes`는 Claude Code 자동 모드 분류기가 가끔(항상은 아님) 막을 수 있음 — 막히면 사용자에게 직접 터미널에서 실행해달라고 요청할 것. 절대 다른 이름으로 새 프로젝트를 만들지 말 것(명함 QR코드에 `mkim.vercel.app` 주소가 이미 박혀있어서 주소가 바뀌면 안 됨).

## 하지 말 것

- `vercel deploy`를 짧은 타임아웃으로 여러 번 중복 실행 (겹쳐서 꼬일 수 있음)
- 멈춘 배포를 보고 성급하게 여러 번 `vercel remove`만 반복 (개별 배포 삭제는 효과 없음 — 프로젝트를 통째로 지워야 함)
- 도메인 이름(`mkim`) 변경
