# Rhythm

> 매일 30초, 감정을 톡톡 찍으면 내 감정의 파도가 보이는 다이어리 앱

Rhythm은 사용자가 하루의 에너지, 감정, 활동을 짧게 기록하고 이를 Wave Graph로 시각화하는 Flutter 기반 모바일 앱 프로젝트다. 현재 버전은 중간 발표용 데모로, Chrome에서 실행 가능한 Flutter Web 앱이다.

## 현재 데모 기능

- 오늘의 에너지 레벨 입력
- 감정 키워드 선택
- 활동 태그 선택
- 짧은 메모 저장
- Wave Graph 시각화
- 히스토리 조회
- 기본 패턴 카드 표시

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

현재 중간 발표 데모는 빠른 시연을 위해 `shared_preferences`를 사용해 간단히 저장한다. 최종 구조에서는 ADR-0003에 따라 Isar 기반 로컬 우선 데이터 저장으로 확장할 예정이다.
