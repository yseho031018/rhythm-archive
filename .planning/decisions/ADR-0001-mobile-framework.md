# ADR-0001 — Flutter를 모바일 프레임워크로 선택

## 상태

Accepted

## 배경

Rhythm은 감정과 활동 기록을 기반으로 사용자의 하루를 시각화하는 모바일 앱이다. 수업의 프로젝트 방향도 모바일 앱을 우선 권장하고 있으므로, Android와 iOS를 모두 고려할 수 있는 모바일 프레임워크가 필요하다.

또한 개인 프로젝트이기 때문에 개발 속도, 학습 부담, UI 구현 편의성, 발표 시 설명 가능성을 함께 고려해야 한다.

## 결정

Rhythm의 모바일 프레임워크로 **Flutter**를 선택한다.

상태 관리는 **Riverpod**, 로컬 데이터 저장은 **Isar**를 우선 검토한다. 앱 구조는 Presentation, Domain, Data 레이어를 분리하는 Clean Architecture 형태로 구성한다.

## 대안

| 대안 | 장점 | 제외 이유 |
|------|------|-----------|
| Android Native(Kotlin) | Android 기능을 깊게 활용할 수 있고 성능이 좋다. | iOS 확장이 어렵고, UI/상태관리 구조를 처음부터 더 많이 작성해야 한다. |
| React Native | JavaScript/TypeScript 생태계를 활용할 수 있다. | 애니메이션과 네이티브 의존성 관리가 Flutter보다 복잡해질 수 있다. |
| 웹 앱 | 배포와 접근이 쉽다. | 수업의 앱 프로그래밍 취지와 모바일 앱 우선 조건에 덜 맞는다. |

## 결과

Flutter를 사용하면 하나의 코드베이스로 Android와 iOS를 모두 고려할 수 있고, CustomPainter를 활용해 Rhythm의 핵심 기능인 Particle Canvas를 구현하기 좋다.

단, Flutter, Riverpod, Isar를 동시에 사용하는 구조는 학습 부담이 있으므로 초기에는 일일 기록 CRUD와 기본 시각화를 먼저 구현한다. 이후 시간이 남으면 히스토리, 통계 힌트, Multi-Layer 블렌딩을 확장한다.

## 발표 시 설명 포인트

- 모바일 앱을 우선하는 수업 방향에 맞춰 Flutter를 선택했다.
- Particle 시각화 구현에 CustomPainter가 적합하다.
- 개인 프로젝트이므로 하나의 코드베이스로 빠르게 개발할 수 있는 점을 중요하게 봤다.
- 기술을 선택한 이유와 대안을 ADR로 남겨 Q&A에 대비한다.

---

*작성일: 2026-05-13*
