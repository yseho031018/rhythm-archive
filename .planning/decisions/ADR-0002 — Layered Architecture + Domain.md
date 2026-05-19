# ADR-0002 — Layered Architecture + Domain 중심 구조 적용

**상태**: Accepted  
**작성일**: 2026-05-19  
**작성자**: 포도

## 배경
Rhythm은 Particle Canvas라는 복잡한 시각화와 감정 파동 계산, 기록 관리 등의 비즈니스 로직이 함께 존재하는 앱이다.  
7주라는 짧은 기간 동안 1인 개발을 하다 보면 UI와 로직이 쉽게 뒤섞여 코드가 복잡해질 위험이 크다.  
따라서 적절한 수준의 레이어 분리가 필요하다.

## 결정
Rhythm 프로젝트에 **Layered Architecture**를 적용한다.  
Domain Layer를 중심으로 핵심 로직을 보호하는 **간소화된 Clean Architecture** 형태로 구성한다.

### 레이어 구조
- **Presentation Layer**: UI, Screen, Widget, CustomPainter (Particle Canvas), ViewModel (Riverpod Notifier)
- **Domain Layer**: Entity, UseCase, Repository Interface, 핵심 비즈니스 규칙 (감정 파동 계산, Particle 생성 로직 등)
- **Data Layer**: Repository 구현체, Isar DB, 데이터 매핑

## 선택 이유
- **Domain Layer 보호**: 감정 파동 계산, Particle 생성 규칙 같은 **앱의 핵심 로직**을 UI와 DB로부터 독립시켜 변경에 강하게 만든다.
- **현실적인 균형**: 완전한 Clean Architecture는 7주 1인 프로젝트에 과도하게 복잡하므로, Layered Architecture 기반으로 Domain 중심으로 간소화했다.
- **Riverpod과의 궁합**: Presentation Layer에서 ViewModel(Riverpod Notifier)을 사용해 상태 관리를 깔끔하게 처리할 수 있다.
- **유지보수성과 테스트 용이성**: 나중에 Particle Canvas 디자인을 바꾸거나 DB를 교체해도 Domain Layer는 거의 수정하지 않아도 된다.
- **AI Vibe Coding에 최적**: AI Agent에게 “Domain UseCase 만들어줘”, “Presentation ViewModel 만들어줘”라고 명확하게 지시할 수 있다.

## 대안 비교

| 대안                    | 장점                          | 단점                              | 적합도 |
|-------------------------|-------------------------------|-----------------------------------|--------|
| Layered + Domain 중심   | 균형 좋음, 유지보수 용이      | 초기 구조 설정 필요               | ★★★★★ |
| 단순 MVVM               | 빠른 개발                     | 로직이 분산되어 장기적으로 어려움 | ★★★☆☆ |
| 완전 Clean Architecture | 최고 수준의 분리              | 7주 1인 프로젝트에 과도하게 복잡  | ★★☆☆☆ |
| Feature-first 구조      | 직관적                        | 레이어 분리가 약해 코드가 엉킴    | ★★☆☆☆ |

## 위험 및 대응
- **초기 구조 설정 부담** → Session 3에서 기본 구조를 먼저 잡고, 이후 기능 구현 시 레이어를 철저히 지킨다.
- **과도한 분리** → 작은 기능은 실용적으로 합쳐서 적용한다.

## 발표 시 설명 포인트
- 7주 1인 프로젝트 규모에 맞게 Layered Architecture를 기반으로 Domain Layer를 중심으로 설계했다.
- Particle Canvas(UI)와 감정 파동 계산(로직)을 분리하여 코드 변경이 용이하게 만들었다.
- Riverpod과 함께 사용해 Presentation Layer를 깔끔하게 관리한다.

---

*참조: [ADR-0001 Flutter 선택](../0001-platform-flutter.md)*  
*참조: [Vision Document](../../vision.md)*