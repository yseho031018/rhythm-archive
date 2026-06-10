# 하루톡

> 세 가지 질문에 답하면 AI가 오늘을 한 줄로 정리해주는 인터뷰 다이어리

하루톡은 긴 일기를 직접 쓰기 어려운 사용자를 위한 Flutter 기반 모바일 앱 프로토타입이다. 사용자는 오늘의 기분, 키워드, 만족도만 선택하고 AI가 생성한 오늘의 한 줄을 확인할 수 있다.

## 현재 프로토타입 기능

- 기분, 오늘의 키워드, 하루 만족도 선택
- 토리와 질문을 하나씩 진행하는 순차형 대화 UI
- 진행률, 건너뛰기, 키워드 직접 입력
- 더미 AI 한 줄 기록 생성
- AI 한 줄 다시 생성 및 직접 수정
- SharedPreferences 기반 로컬 저장과 기록 삭제
- 생성된 한 줄 기록 목록 및 상세 조회
- 날짜별 기분을 보여주는 감정잔디
- 이번 달 감정 통계 및 연속 기록 일수
- 모바일 중심 반응형 UI

## 실행

```powershell
flutter pub get
flutter run -d chrome
```

자세한 실행 절차는 [docs/setup.md](docs/setup.md)를 참고한다.

## 문서

- [Vision](.planning/00-vision.md)
- [Requirements](.planning/01-requirements.md)
- [WBS](.planning/02-wbs.md)
- [Risk](.planning/03-risk.md)
- [Schedule](.planning/04-schedule.md)
- [Final Week Plan](.planning/05-final-week-plan.md)
- [Today Plan — 2026-06-09](.planning/06-today-2026-06-09.md)
- [Today Plan — 2026-06-10](.planning/07-today-2026-06-10.md)
- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [Interim Presentation](docs/presentation/interim.md)

## ADR

- `.planning/decisions/ADR-0001 — mobile-framework.md`
- `.planning/decisions/ADR-0002 — Layered Architecture + Domain.md`
- `.planning/decisions/ADR-0003 — local-first-database.md`

## GitHub Pages

앱 데모:

```text
https://yseho031018.github.io/rhythm-archive/
```

중간 발표자료:

```text
https://yseho031018.github.io/rhythm-archive/presentation.html
```

WBS/Gantt 페이지:

```text
https://yseho031018.github.io/rhythm-archive/wbs-gantt.html
```

## 개발 메모

현재 프로토타입은 실제 AI API 없이 로컬 상태와 더미 데이터로 동작한다. 기존 Rhythm 데모 코드는 제거했고, 앱을 선택형 AI 인터뷰 다이어리 프로토타입(`lib/prototype/`)으로 전환했다.

현재 토리 마스코트는 Flutter 위젯으로 제작한 플레이스홀더이며, 이후 표정별 이미지 에셋으로 교체할 수 있도록 별도 컴포넌트로 분리되어 있다.

## 향후 개발 계획

- 사용자 키워드 추가와 과거 날짜 기록
- 감정과 활동의 관계를 보여주는 생활 패턴 분석
- 별도 컴퓨터의 로컬 AI 모델을 이용한 실제 한 줄 생성
- AI 서버 연결 실패 시 규칙 기반 생성 유지
