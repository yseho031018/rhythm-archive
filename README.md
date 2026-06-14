# 하루톡

[![Verify and deploy GitHub Pages](https://github.com/yseho031018/rhythm-archive/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/yseho031018/rhythm-archive/actions/workflows/deploy-pages.yml)

> 세 가지 질문에 답하면 오늘을 한 줄로 정리하고, 쌓인 기록에서 생활 패턴을 발견하는 감정 다이어리

하루톡은 긴 일기를 직접 쓰는 부담을 줄이기 위해 만든 Flutter 앱이다. 사용자는 기분, 함께한 일, 만족도만 선택한다. 앱은 선택한 사실만 사용해 한 줄을 만들고, 감정잔디와 생활 패턴으로 기록을 다시 보여준다.

## 비전과 문제 정의

- **비전:** 매일 긴 글을 쓰지 않아도 자신의 하루와 감정 흐름을 돌아볼 수 있게 한다.
- **문제:** 기존 일기는 꾸준히 긴 글을 작성해야 해서 기록이 쉽게 끊기고, 기록이 쌓여도 생활과 감정의 관계를 찾기 어렵다.
- **해결:** 토리와 세 단계로 대화하듯 기록하고, 한 줄 요약과 누적 패턴으로 결과를 돌려준다.

## 현재 구현

- 기분 → 키워드 → 만족도 순차 기록
- 규칙 기반 AI 한 줄 생성, 다시 생성, 직접 수정
- 사용자 키워드 추가·삭제·재사용
- 과거 날짜 기록과 하루 한 개 기록 규칙
- Drift/SQLite 기반 오프라인 로컬 DB와 기존 기록 자동 이전
- JSON 백업 저장·복원과 전체 데이터 삭제
- 한줄 목록·상세·삭제
- 월별 감정잔디와 날짜별 기록 연결
- 주간·월간·연간 감정 통계
- 키워드별 만족도와 대표 기분을 계산하는 생활 패턴 분석
- 라이트·다크 테마와 토리 상태별 이미지

## 기술 스택

| 구분 | 적용 기술 | 역할 |
|---|---|---|
| UI | Flutter, Material 3 | 모바일 중심 화면과 상호작용 |
| 상태 | ChangeNotifier | 화면 상태와 기록 흐름 관리 |
| 저장 | Drift, SQLite, WebAssembly | 오프라인 기록·키워드 저장, 트랜잭션 |
| 파일 | file_picker | JSON 백업 저장·복원 |
| 구조 | Repository Pattern, 간소화된 Layered Architecture | UI, 상태, 저장 책임 분리 |
| 품질 | flutter_lints, flutter_test | 정적 분석, 단위·통합 위젯 테스트 |
| 배포 | Flutter Web, GitHub Pages | URL 기반 시연 및 제출 |

현재 프로토타입의 “AI 한 줄”은 외부 API가 아니라 설명 가능한 규칙 기반 생성기다. 실제 AI 서버 연결은 향후 확장 항목이며, 발표에서는 구현 여부를 정확히 구분해 설명한다.

## 빠른 실행

```powershell
flutter pub get
flutter run -d chrome
```

검증:

```powershell
flutter analyze
flutter test
flutter build web --release --base-href "/rhythm-archive/"
```

## 프로젝트 구조

```text
lib/
  main.dart
  prototype/
    screens/                       # 기록, 한줄, 감정잔디, 통계 화면
    widgets/                       # 공통 UI, 테마, 토리
    diary_controller.dart          # 기록 흐름과 상태
    backup_file_service.dart       # JSON 백업 파일 저장·선택
    diary_entry.dart               # 기록 모델
    diary_repository.dart          # 저장소 인터페이스
    database/harutalk_database.dart        # Drift 스키마와 SQLite 연결
    drift_diary_repository.dart            # 현재 로컬 DB 저장 구현
    migrating_diary_repository.dart        # 기존 SharedPreferences 자동 이전
    shared_preferences_diary_repository.dart # 이전 데이터 읽기
    pattern_analysis.dart          # 생활 패턴 계산
test/                              # 단위·통합 위젯 테스트
docs/                              # setup, architecture, deploy, testing
.planning/                         # 비전, 요구사항, WBS, 일정, 위험, ADR
AGENTS.md                          # AI Agent 작업 규칙과 암묵지
```

## 문서와 평가 증빙

- [비전과 문제 정의](.planning/00-vision.md)
- [요구사항](.planning/01-requirements.md)
- [WBS](.planning/02-wbs.md)
- [최종 주간 계획](.planning/05-final-week-plan.md)
- [아키텍처](docs/architecture.md)
- [개발 환경 설정](docs/setup.md)
- [빌드와 배포](docs/deploy.md)
- [테스트 결과](docs/testing.md)
- [최종 평가 체크리스트](docs/final-evaluation-checklist.md)
- [AI Agent 운영 가이드](AGENTS.md)
- [ADR 목록](.planning/decisions/)

## 공개 URL

- 앱 데모: <https://yseho031018.github.io/rhythm-archive/>
- 발표자료: <https://yseho031018.github.io/rhythm-archive/presentation.html>
- WBS/Gantt: <https://yseho031018.github.io/rhythm-archive/wbs-gantt.html>
- GitHub: <https://github.com/yseho031018/rhythm-archive>

## 설치 및 배포 요약

자세한 설치 과정은 [docs/setup.md](docs/setup.md), 빌드·배포 개념과 절차는 [docs/deploy.md](docs/deploy.md)를 참고한다. 기능 브랜치 push와 PR에서는 [품질 검사 workflow](.github/workflows/quality-check.yml)가 Drift 생성 코드, 정적 분석, 테스트, Web Release 빌드를 검증한다. `master` push 시에는 [GitHub Pages workflow](.github/workflows/deploy-pages.yml)가 같은 품질 게이트를 통과한 뒤 앱·발표자료·WBS를 함께 배포한다.
