# ADR-0002 — Repository Pattern 기반 간소화 아키텍처

- 상태: 채택
- 결정일: 2026-05-19
- 최종 검토일: 2026-06-13

## 상황

개인 프로젝트에서 완전한 Clean Architecture와 Riverpod을 한 번에 적용하면 구조 설명보다 보일러플레이트가 커질 위험이 있다. 하지만 UI, 기록 흐름, 저장, 패턴 분석을 한 파일에 두면 테스트와 변경이 어려워진다.

## 결정

화면, `DiaryController`, 핵심 모델·분석 로직, `DiaryRepository` 인터페이스, Drift/SQLite 구현체로 책임을 분리한다. 상태 관리는 현재 규모에 맞게 `ChangeNotifier`를 사용한다.

## 선택 이유

- 완전한 Clean Architecture보다 개인 프로젝트 범위에 현실적이다.
- Repository 인터페이스를 통해 저장 기술을 교체할 수 있다.
- 테스트에서 메모리 Repository를 주입할 수 있다.
- `pattern_analysis.dart`를 UI와 분리해 순수 함수로 검증할 수 있다.

## 대안

| 대안 | 제외 이유 |
|---|---|
| 모든 코드를 화면에 작성 | 빠르지만 테스트와 설명이 어려움 |
| 완전한 Clean Architecture + Riverpod | 현재 범위에 과도하고 학습·구현 시간이 큼 |

## 결과와 시행착오

- 기록 생성·저장 흐름과 분석 규칙을 독립적으로 테스트할 수 있게 되었다.
- 초기 계획의 Riverpod은 구현하지 않았다. 발표에서는 계획과 실제 구현을 구분한다.
- 기능이 커지면 Controller 분리 또는 Riverpod 도입을 다시 검토한다.
