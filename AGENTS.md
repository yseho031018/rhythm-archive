# AGENTS.md — 하루톡 AI Agent 운영 가이드

이 문서는 하루톡 프로젝트에서 AI Agent, 스킬, 워크플로우, 규칙, 명령을 한 곳에서 관리하는 단일 운영 가이드다. AI가 만든 결과를 그대로 제출하지 않고, 개발자가 검토·수정·검증한 내용만 반영한다.

## 1. 프로젝트 목표

- 긴 일기의 부담을 세 번의 선택으로 줄인다.
- 사용자가 선택하지 않은 사건을 한 줄에 새로 만들지 않는다.
- 쌓인 기록에서 키워드·기분·만족도의 관계를 설명 가능하게 보여준다.
- 인터넷이 없어도 핵심 기록 흐름이 동작해야 한다.

## 2. 현재 사실

- 앱 이름: 하루톡
- 실제 프레임워크: Flutter / Dart
- 실제 상태 관리: `ChangeNotifier`
- 실제 저장소: `SharedPreferences`
- 실제 구조: Repository Pattern을 사용한 간소화된 Layered Architecture
- 실제 한 줄 생성: 규칙 기반 생성기
- 실제 배포: Flutter Web + GitHub Pages

문서와 발표에서 Riverpod, Isar, 외부 AI API를 “현재 구현”이라고 말하지 않는다. 이들은 검토했던 대안 또는 향후 확장 후보다.

## 3. 디렉토리 규칙

- `lib/prototype/screens/`: 화면과 사용자 상호작용
- `lib/prototype/widgets/`: 재사용 UI, 테마, 토리
- `diary_controller.dart`: 화면 상태와 Use Case 흐름
- `diary_entry.dart`: 핵심 기록 모델
- `diary_repository.dart`: 저장소 추상화
- `shared_preferences_diary_repository.dart`: 로컬 저장 구현
- `pattern_analysis.dart`: UI와 분리된 순수 분석 로직
- `test/`: 단위 테스트와 사용자 흐름 통합 위젯 테스트
- `.planning/decisions/`: 기술 결정과 시행착오를 기록하는 ADR

## 4. AI Agent 워크플로우

1. **Observe:** 관련 코드·문서·현재 변경사항을 먼저 읽는다.
2. **Plan:** 평가 기준과 사용자 흐름에 연결되는 최소 작업을 고른다.
3. **Implement:** 기존 구조와 디자인 규칙을 지키며 수정한다.
4. **Verify:** `flutter analyze`, `flutter test`, 필요한 화면 검증을 실행한다.
5. **Document:** 결정 이유, 시행착오, 테스트 결과를 문서에 남긴다.
6. **Explain:** 개발자가 읽지 않고도 말로 설명할 수 있는 수준으로 정리한다.

## 5. 품질 게이트 명령

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href "/rhythm-archive/"
```

배포 전에는 네 명령이 모두 성공해야 한다. 새로운 핵심 규칙에는 단위 테스트를, 기록 생성·저장 같은 사용자 흐름에는 통합 위젯 테스트를 추가한다.

## 6. 구현 규칙

- 하루에는 기록 한 개만 유지한다.
- 기록 생성 전에는 기분과 키워드가 반드시 있어야 한다.
- 패턴 분석은 표본이 부족할 때 관계를 단정하지 않는다.
- 저장 실패가 발생해도 화면 상태를 잃지 않고 오류를 알린다.
- 외부 AI가 실패해도 규칙 기반 한 줄 생성으로 핵심 흐름을 유지한다.
- 화면은 최대 폭 560px의 모바일 경험을 기준으로 한다.
- 접근성과 다크 모드를 깨뜨리지 않는다.

## 7. AI 활용 증빙

- 기획, WBS, ADR, 위험 관리 초안을 AI Agent와 함께 만들었다.
- Flutter 구현과 테스트 초안을 AI Agent로 생성하고 직접 실행·수정했다.
- 토리 이미지 시트를 투명 상태별 에셋로 분리해 UI에 연결했다.
- 평가표를 저장소 문서와 연결해 누락 항목을 기계적으로 점검한다.

## 8. 암묵지

- 기능을 많이 추가하는 것보다 발표에서 설명 가능한 기능을 안정적으로 만드는 편이 점수가 높다.
- 시각 자료에는 결론만 두고, 원인과 과정은 대사로 설명해야 따라 읽는 발표가 되지 않는다.
- “AI”라는 이름보다 실패 시 대체 흐름과 사용자가 수정할 권리를 설명하는 것이 중요하다.
- 계획과 실제 구현이 달라졌다면 숨기지 않고 ADR에 변경 이유를 기록한다.

