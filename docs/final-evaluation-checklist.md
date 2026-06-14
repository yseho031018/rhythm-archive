# 2026-06-16 최종 평가 체크리스트

## 점수 전략

앱 기능을 무리하게 추가하기보다 이미 구현한 기능을 안정화하고, 각 평가 항목을 발표 장면·문서·코드 증빙과 연결한다.

## 1. 발표 체계성 10점

| 평가 항목 | 증빙 | 준비 상태 |
|---|---|---|
| 비전과 공감 | `.planning/00-vision.md`, 발표 1~2장 | 완료 |
| 문제 정의 | 긴 일기 부담과 기록 활용 어려움 | 완료 |
| 대사 준비 | `docs/presentation/final-script-5min.md`, `final-speaking-cues.md` | 완료 |
| WBS | `.planning/02-wbs.md`, `wbs-gantt.html`, 발표 4장 | 완료 |
| 적용 기술 | Flutter, ChangeNotifier, SharedPreferences, Repository | 문서화 완료 |
| 진행 및 완료 | WBS, Git log, 기능 체크리스트 | 완료 |
| 구현 방법 | `docs/architecture.md`, 발표 5장 | 완료 |
| 활용 방안 | 생활 패턴 회고, 향후 실제 AI 연결 | 대본 포함 |

## 2. 질의응답 5점

| 질문 | 답변 근거 |
|---|---|
| ADR 최소 3개 | `.planning/decisions/` |
| 앱 구조 | `docs/architecture.md` |
| 개발 환경 | `docs/setup.md` |
| 빌드와 배포 | `docs/deploy.md` |
| 정확한 답변 | 현재 구현과 향후 계획을 구분해서 말하기 |

## 3. 개발자 기본소양 10점

| 평가 항목 | 증빙 |
|---|---|
| 적용 기술 이해 | README 기술 스택과 30초 설명 |
| 아키텍처 이해 | Repository, Controller, 화면, 분석 로직 |
| 시행착오 | 생성 결과 사용자 제어, 최소 표본 규칙, Isar 대신 SharedPreferences 범위 조절 |
| 개발 환경 | Flutter 3.44.0, Dart 3.12.0, Chrome, Git |
| 개선 의지 | 실제 AI 연결과 저장소 교체 가능성 |
| 성능 최적화 | 모바일 최대 폭, 단순 로컬 연산, 패턴 최소 표본, 에셋 최적화 |
| 코드 품질 | lint, 책임 분리, Repository 주입 |
| 단위 테스트 | controller와 pattern analysis |
| 통합 테스트 | record flow와 화면 기간 이동 |
| 설치 가이드 | README, setup, deploy |
| 빌드·배포 자동화 | `.github/workflows/deploy-pages.yml` |

## 4. 결과물 품질 5점

- [ ] `demo-script-30s.md` 순서로 현재 하루톡 MP4를 촬영한다.
- [ ] 기분 → 키워드 → 한 줄 생성 → 저장 → 생활 패턴 순서로 보여준다.
- [ ] 시작 전 영상과 로컬 앱을 각각 한 번 재생한다.
- [ ] URL 실패에 대비해 로컬 서버를 준비한다.

## 과제 문서화 5점

- [x] 기획서 및 요구사항
- [x] WBS/일정 최신화
- [x] 아키텍처/ADR
- [x] setup/deploy/testing
- [x] AGENTS.md 및 README

## 가산점

- [x] AI Agent / 스킬 / 워크플로우 활용 증빙
- [x] 단일 `AGENTS.md`에 agent/skills/rules/commands 통합
- [x] 암묵지를 `AGENTS.md`와 ADR에 기록
- [ ] 발표에서 AI 활용을 15초 이내로 설명

## 제출 경로

- [x] GitHub 공개 API에서 최근 커밋 작성자가 `yseho031018` 계정과 연결됨을 확인
- [ ] 최종 변경사항 커밋·push 후 GitHub Pages 세 URL 확인
- [ ] GitHub Pages Source를 `GitHub Actions`로 변경하고 workflow 성공 확인
- [ ] `num.slogs.dev`에 발표자료 URL 등록 후 학번으로 열기 확인

## 남은 일정

### 6월 13일 토요일

- 문서 정합성, ADR, AGENTS, setup/deploy/testing 완료
- 앱 분석·테스트·Web Release 빌드 통과
- 최종 발표자료와 말하기 카드 완료

### 6월 14일 일요일

- 30초 시연 영상 촬영
- 4분 30초 발표를 말하기 카드로 3회 연습

### 6월 15일 월요일

- 기능 동결
- 4분 30초 발표 5회, 30초 데모 5회 연습
- Q&A 구두 연습과 URL·영상 백업 점검

### 6월 16일 화요일

- 공개 URL, 로컬 서버, 영상, 타이머 최종 확인
