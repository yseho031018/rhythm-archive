# Rhythm — Work Breakdown Structure (WBS)

> 현재 프로젝트 진행 흐름을 반영한 작업 분해 구조.  
> 중간 발표 준비를 위해 일부 구현 순서를 조정했으며, Flutter Web 데모를 먼저 만든 뒤 아키텍처 분리와 Isar 연동을 진행한다.

---

## WBS 테이블

| WBS | 작업명 (Lv.2) | 세부 작업 (Lv.3) | 산출물 |
|:---:|---|---|---|
| **1** | **기획 및 요구사항** | | |
| 1.1 | 프로젝트 기획 | • 비전 및 문제 정의 문서화<br>• 핵심 사용자 시나리오 3개 작성<br>• MoSCoW 요구사항 분류 | `00-vision.md`<br>`01-requirements.md` |
| 1.2 | 일정 및 위험 관리 | • WBS 작성<br>• 10~15주차 일정 정리<br>• 위험 식별 및 대응 방안 작성 | `02-wbs.md`<br>`03-risk.md`<br>`04-schedule.md` |
| 1.3 | 작성자/가산점 문서 | • AUTHORING 문서 작성<br>• BONUS 가산점 트래킹 문서 작성 | `AUTHORING...md`<br>`BONUS.md` |
| **2** | **설계 결정 및 발표 준비** | | |
| 2.1 | ADR 작성 | • Flutter 선택 이유<br>• Layered Architecture 선택 이유<br>• Isar 기반 로컬 우선 저장 선택 이유 | `ADR-0001~0003` |
| 2.2 | 중간 발표 자료 | • 중간 발표 Marp 슬라이드 작성<br>• 발표자료 HTML 변환<br>• Q&A 대비용 기술 선택 근거 정리 | `docs/presentation/interim.md`<br>`presentation.html` |
| 2.3 | GitHub Pages 공개 | • WBS/Gantt 페이지 루트 배치<br>• 발표자료 URL 공개<br>• Flutter Web 데모 URL 공개 | `wbs-gantt.html`<br>`index.html` |
| **3** | **중간 발표용 Flutter Web 데모 선행 개발** | | |
| 3.1 | Flutter 프로젝트 초기화 | • Flutter 프로젝트 생성<br>• Web/Windows 플랫폼 구성<br>• 기본 테스트 및 분석 환경 구성 | `pubspec.yaml`<br>`lib/main.dart`<br>`test/widget_test.dart` |
| 3.2 | 일일 입력 데모 | • 에너지 레벨 입력<br>• 감정 키워드 선택<br>• 활동 태그 선택<br>• 짧은 메모 저장 | 오늘 탭 |
| 3.3 | 시각화 데모 | • CustomPainter 기반 Particle Canvas<br>• 감정/에너지 기반 색상과 파동 표현<br>• 더미 데이터 기반 즉시 시연 | Particle Canvas |
| 3.4 | 히스토리/패턴 데모 | • 저장된 기록 목록 표시<br>• 평균 에너지 카드<br>• 자주 나온 감정/활동 카드<br>• 최근 흐름 그래프 | 히스토리 탭<br>패턴 탭 |
| **4** | **아키텍처 정리 및 리팩토링** | | |
| 4.1 | 레이어 구조 분리 | • 현재 단일 파일 데모를 Presentation/Application/Domain/Data로 분리<br>• 화면, Painter, Entity, Repository 책임 분리 | `lib/` 레이어 구조 |
| 4.2 | 상태 관리 정리 | • Riverpod 도입<br>• 입력 상태와 기록 목록 상태 분리<br>• ViewModel/Notifier 작성 | Application 레이어 |
| **5** | **도메인 및 데이터 레이어 개발** | | |
| 5.1 | 도메인 레이어 | • `RhythmEntry` Entity 분리<br>• Repository 인터페이스 정의<br>• 저장/조회 UseCase 구현 | `domain/` 레이어 |
| 5.2 | 데이터 레이어 | • Isar DB 초기화<br>• Isar Collection 모델 작성<br>• Repository 구현체 작성<br>• 임시 저장을 Isar로 교체 | `data/` 레이어 |
| **6** | **기능 고도화** | | |
| 6.1 | 히스토리 고도화 | • 날짜별 기록 조회<br>• 기록 수정/삭제<br>• 메모 표시 개선 | 히스토리 화면 |
| 6.2 | 패턴 분석 고도화 | • 에너지 평균/빈도 계산<br>• 감정/활동별 힌트 문구<br>• 최소 데이터 기준 가드 | 패턴 화면 |
| 6.3 | 선택 기능 | • 데이터 내보내기(JSON/CSV)<br>• 리마인드 알림<br>• Multi-Layer 블렌딩은 시간 여유 시 진행 | 설정/고급 시각화 |
| **7** | **테스트 및 품질 보증** | | |
| 7.1 | 테스트 | • 위젯 테스트<br>• 저장→조회 수동 검증<br>• Web 빌드 검증 | `flutter test`<br>`flutter build web` |
| 7.2 | 발표 검증 | • 데모 URL 접속 확인<br>• 발표자료 URL 접속 확인<br>• Q&A 예상 질문 점검 | 발표 체크리스트 |
| **8** | **최종 발표 준비** | | |
| 8.1 | 문서화 | • README 보강<br>• setup/architecture 문서 최신화<br>• 회고 및 Q&A 로그 작성 | `README.md`<br>`docs/` |
| 8.2 | 최종 발표 | • 최종 발표자료 작성<br>• 데모 안정화<br>• 남은 기능 범위 정리 | 최종 발표 자료 |

---

## Gantt Chart (개략)

```mermaid
gantt
    title Rhythm 개발 일정 개략
    dateFormat  YYYY-MM-DD
    section 기획 및 요구사항
    기획 문서 세트          :done,    plan, 2026-05-12, 7d
    section 설계 결정/발표 준비
    ADR 및 중간 발표 자료   :done,    adr, 2026-05-19, 8d
    section 데모 선행 개발
    Flutter Web 데모        :done,    demo, 2026-05-26, 1d
    section 아키텍처 정리
    레이어 분리 및 Riverpod :active,  refactor, 2026-05-27, 8d
    section 도메인/데이터
    도메인 및 Isar 연동     :         domain, 2026-06-03, 7d
    section 기능 고도화
    히스토리/패턴/설정      :         feature, 2026-06-09, 7d
    section 테스트
    테스트 및 품질 보증     :         test, 2026-06-13, 6d
    section 최종 발표
    최종 문서/발표 준비     :         final, 2026-06-18, 5d
```

---

## 일정 변경 메모

초기 계획은 도메인/데이터 레이어를 먼저 구현한 뒤 화면을 붙이는 흐름이었다.  
하지만 12주차 중간 발표에서 **간단한 URL로 바로 열 수 있는 발표자료와 앱 데모**가 필요해져, Flutter Web 데모와 GitHub Pages 배포를 먼저 진행했다.

따라서 현재 실제 흐름은 다음과 같다.

1. 기획/요구사항/WBS/위험/일정 문서 완료
2. ADR 3개 작성
3. 중간 발표자료와 WBS/Gantt URL 공개
4. Flutter Web 데모 선행 구현
5. 이후 Riverpod, Isar, 레이어 분리를 진행

이 변경은 중간 발표 대응을 위한 우선순위 조정이며, 최종 구조 목표는 여전히 Layered Architecture + Isar 로컬 우선 저장이다.

---

*문서 버전: 2.1*  
*수정일: 2026-05-26*
