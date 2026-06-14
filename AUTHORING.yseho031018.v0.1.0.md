# 하루톡 작성 및 AI 활용 기록

## 작성자

- 윤세호 (`yseho031018`)
- GitHub: <https://github.com/yseho031018>
- 저장소: <https://github.com/yseho031018/rhythm-archive>

## 프로젝트

하루톡은 기분, 키워드, 만족도 세 가지 선택으로 오늘을 한 줄로 남기고 누적 기록에서 생활 패턴을 찾는 Flutter 감정 다이어리다.

## 실제 적용 기술

- Flutter / Dart / Material 3
- ChangeNotifier
- Repository Pattern
- SharedPreferences
- flutter_test / flutter_lints
- Flutter Web / GitHub Pages

## AI Agent 활용

- 하루톡 사용자 흐름과 기능 우선순위 검토
- 비전, 요구사항, WBS, ADR, 위험 관리 초안
- Flutter UI와 로컬 저장 구현 보조
- 토리 이미지 시트 분리와 화면 적용
- 단위·통합 테스트 작성과 실행
- 최종 평가 기준을 이용한 문서 누락 감사

AI가 작성한 결과는 그대로 제출하지 않고, 작성자가 방향을 결정하고 실제 실행·수정·검증한 내용만 반영한다.

## 주요 시행착오

1. 자동 생성 결과가 선택하지 않은 사실을 만들지 않도록 입력값과 문장 규칙을 제한했다.
2. 생성 결과를 다시 생성하고 직접 수정할 수 있게 해 사용자 제어권을 보완했다.
3. 초기 검토 기술인 Riverpod과 Isar보다 현재 범위에 맞는 ChangeNotifier와 SharedPreferences를 적용했다.
4. 발표자료와 대본이 비슷해 따라 읽는 느낌이 강했던 피드백을 받아, 최종 발표자료는 시각 자료와 핵심 결론 중심으로 구성한다.

## 버전 히스토리

| 버전 | 날짜 | 변경 내용 |
|---|---|---|
| v0.1.0 | 2026-05-12 | 작성자와 프로젝트 메타데이터 |
| v0.2.0 | 2026-05-13 | 기획, WBS, ADR, BONUS 정리 |
| v0.3.0 | 2026-06-13 | 하루톡 최종 구현, AI 활용, 시행착오, 실제 기술 스택 반영 |
