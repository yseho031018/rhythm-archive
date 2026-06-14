# 하루톡 빌드와 배포

## 개념

- **빌드:** Dart와 Flutter 코드를 브라우저가 실행할 수 있는 HTML, JavaScript, 에셋 파일로 변환하는 과정이다.
- **배포:** 빌드 결과와 발표 문서를 GitHub Pages 같은 공개 서버에 올려 URL로 접근 가능하게 만드는 과정이다.

## Web Release 빌드

GitHub Pages 프로젝트 경로가 `/rhythm-archive/`이므로 base href를 지정한다.

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href "/rhythm-archive/"
```

빌드 결과는 `build/web/`에 생성된다.

Drift Web 실행에 필요한 `sqlite3.wasm`과 `drift_worker.js`도 `web/`에서 빌드 결과로 복사된다.

## 로컬 빌드 확인

```powershell
python -m http.server 8110 --directory build/web
```

브라우저에서 `http://127.0.0.1:8110`을 열어 기록 흐름과 에셋 로드를 확인한다.

## GitHub Pages 자동 배포

`.github/workflows/deploy-pages.yml`은 `master` push마다 다음 과정을 실행한다.

```text
checkout
→ Flutter 3.44.0 설정
→ flutter pub get
→ flutter analyze
→ flutter test
→ Flutter Web Release 빌드
→ 발표자료와 WBS를 빌드 산출물에 포함
→ GitHub Pages 배포
```

첫 실행 전 GitHub 저장소에서 `Settings → Pages → Build and deployment → Source`를 `GitHub Actions`로 선택해야 한다.

## GitHub Pages 배포 단계

1. 소스와 문서를 커밋한다.
2. `flutter analyze`, `flutter test`, Web Release 빌드를 통과시킨다.
3. `master` 브랜치를 GitHub에 push한다.
4. GitHub Actions의 `Verify and deploy GitHub Pages` 실행이 성공하는지 확인한다.
5. 앱 데모, `presentation.html`, `wbs-gantt.html`이 공개 URL에서 열리는지 확인한다.

공개 URL:

- <https://yseho031018.github.io/rhythm-archive/>
- <https://yseho031018.github.io/rhythm-archive/presentation.html>
- <https://yseho031018.github.io/rhythm-archive/wbs-gantt.html>

## 배포 실패 대응

- URL이 404이면 GitHub Pages의 branch와 folder 설정을 확인한다.
- 아이콘이나 이미지가 보이지 않으면 base href와 에셋 경로를 확인한다.
- DB 초기화가 실패하면 `sqlite3.wasm`, `drift_worker.js`의 배포 여부와 WASM MIME 타입을 확인한다.
- 브라우저에 옛 화면이 보이면 강력 새로고침 또는 캐시 삭제 후 확인한다.
- 공개 루트가 README 페이지로 보이면 Pages Source가 `GitHub Actions`인지 확인한다.
- 발표 당일 Pages가 느리면 로컬 서버와 30초 MP4를 백업으로 사용한다.

## 발표용 배포 체크

- [ ] 세 공개 URL이 PC에서 바로 열린다.
- [ ] 앱 URL이 모바일 폭 형태로 정상 렌더링된다.
- [ ] 발표자료 URL이 전체 화면으로 전환된다.
- [ ] WBS/Gantt에서 완료·진행 상태가 보인다.
- [ ] 로컬 서버와 데모 영상 백업이 준비되어 있다.

## 숫자링 등록

`https://num.slogs.dev`의 `내 링크 등록/수정`에서 다음 값을 입력한다.

- 학번: 본인 학번
- 발표자료 URL: `https://yseho031018.github.io/rhythm-archive/presentation.html`
- 수업 코드: `shingu`
- 수정 PIN: 발표 전 다시 입력할 수 있는 본인 PIN

새 발표자료를 GitHub Pages에 배포한 뒤 등록하고, 왼쪽 `발표자료 열기`에서 학번으로 직접 확인한다.

## GitHub 잔디 확인

- 로컬 커밋 작성자: `yunseho <sehoho1018@gmail.com>`
- GitHub 공개 API에서 최근 커밋이 `yseho031018` 계정과 연결됨을 확인했다.
- 발표 전 새 변경사항을 커밋·push한 뒤 GitHub 프로필과 저장소 commit history를 다시 확인한다.
