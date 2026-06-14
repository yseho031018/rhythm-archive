# ADR-0003 — Drift/SQLite 기반 로컬 우선 저장

- 상태: 채택
- 결정일: 2026-06-14
- 최종 검토일: 2026-06-14

## 상황

하루톡의 핵심 기록은 인터넷이 없어도 생성·조회되어야 한다. 초기 프로토타입은 SharedPreferences에 JSON 목록을 저장했지만, 기록과 사용자 키워드가 늘어날 때 스키마와 트랜잭션을 명확히 관리할 수 있는 정식 로컬 DB가 필요했다. Flutter Web과 GitHub Pages 시연도 계속 지원해야 했다.

## 결정

`DiaryRepository` 인터페이스 뒤에 Drift/SQLite 저장소를 구현한다. 네이티브에서는 SQLite 파일을, Web에서는 SQLite WebAssembly와 IndexedDB 기반 저장소를 사용한다. 기존 SharedPreferences 기록은 최초 실행에만 Drift로 복사하고 원본은 삭제하지 않는다.

## 선택 이유

- 기록, 사용자 키워드, 초기화 상태를 구조화된 테이블로 관리한다.
- 트랜잭션으로 기록 목록 교체 중 불완전한 저장을 줄인다.
- WebAssembly를 통해 GitHub Pages와 네이티브 앱에서 같은 Repository 구현을 사용한다.
- Repository 분리 덕분에 Controller와 화면 변경 없이 저장 기술을 교체했다.

## 대안

| 대안 | 장점 | 이번 범위에서 제외한 이유 |
|---|---|---|
| SharedPreferences | 구현이 단순하고 Web 지원이 쉬움 | 스키마·트랜잭션·복잡한 조회 확장에 불리함 |
| Isar | Flutter 친화적 객체 DB | Web 배포와 현재 유지보수 선택지가 Drift보다 불명확함 |
| 서버 DB | 여러 기기 동기화 | 오프라인 우선 목표와 발표 안정성에 불리함 |

## 결과와 제한

- 새로고침 후에도 SQLite에 저장한 기록과 사용자 키워드가 유지된다.
- 기존 SharedPreferences 데이터가 있으면 한 번 자동 이전된다.
- 사용자는 JSON 백업으로 기록을 직접 보관하고 다른 기기에 복원할 수 있다.
- 복원과 전체 삭제는 기록·사용자 키워드를 한 트랜잭션에서 교체한다.
- `sqlite3.wasm`과 `drift_worker.js`를 Web 배포 산출물에 포함해야 한다.
- GitHub Pages처럼 추가 보안 헤더가 없는 환경에서는 Drift가 IndexedDB 기반 구현으로 대체한다.
- 여러 기기 동기화는 지원하지 않으며 향후 서버 기능으로 분리한다.
