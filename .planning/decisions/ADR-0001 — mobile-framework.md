# ADR-0001 — Flutter를 모바일 프레임워크로 선택

**상태**: Accepted  
**작성일**: 2026-05-19  
**작성자**: 포도

## 배경
Rhythm은 사용자의 감정·활동을 기록하고 Particle Canvas로 시각화하는 감성 다이어리 앱이다.  
수업 프로젝트가 모바일 앱을 우선하고 있으며, iOS와 Android 모두 지원해야 하고, 1인 개발이기 때문에 개발 속도와 UI 구현 편의성이 중요하다.

## 결정
Rhythm의 모바일 프레임워크로 **Flutter**를 선택한다.  
- 상태 관리: **Riverpod**  
- 로컬 DB: **Isar**  
- 아키텍처: Clean Architecture (Presentation / Domain / Data)

## 대안 비교

| 대안                    | 장점                          | 단점 / 제외 이유                          | 적합도 |
|-------------------------|-------------------------------|-------------------------------------------|--------|
| Android Native (Kotlin) | 최고 성능, 네이티브 기능 활용 | iOS 별도 개발 필요                        | ★★☆☆☆ |
| iOS Native (Swift)      | Apple 디자인 완벽 구현, 최고 성능 | Android 별도 개발 필요, macOS 필수       | ★★☆☆☆ |
| React Native            | JS/TS 생태계                  | 복잡한 커스텀 UI(Particle) 구현 어려움     | ★★★☆☆ |

## 선택 이유

- **Rhythm의 핵심 기능인 Particle Canvas 구현에 최적**  
  Flutter는 `CustomPainter`와 **Animation 시스템(AnimationController, Tween, CurvedAnimation)** 이 프레임워크에 **내장**되어 있어, 수천 개의 입자가 부드럽게 움직이는 복잡한 시각적 애니메이션을 비교적 쉽게 구현할 수 있다.

- 하나의 코드베이스로 iOS·Android를 동시에 지원 → 1인 프로젝트 시간 효율 극대화.

- Hot Reload로 빠른 반복 개발 가능 (감정 입력 → Particle Canvas 즉시 반영 테스트).

- Riverpod, Isar과의 궁합이 매우 뛰어나며, Clean Architecture와도 잘 어울린다.

## 위험 및 대응

- **Dart/Flutter 학습 부담**  
  → AI Agent와 함께 Pair Programming 방식으로 개발하면서 핵심 개념(CustomPainter, Riverpod, Clean Architecture)을 위주로 이해한다. 초기에는 CRUD + 기본 Particle 구현에 집중.

- **Particle Canvas 성능 이슈**  
  → CustomPainter 최적화 + 필요 시 Flame 엔진 도입 검토. 실제 구현하면서 프레임률을 지속적으로 모니터링한다.

- **AI 의존성**  
  → AI가 생성한 코드는 반드시 직접 이해하고, 발표 시 설명할 수 있도록 문서화한다.


---

*참조: [Vision Document](../vision.md)*