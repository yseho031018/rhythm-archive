# 하루톡 개발 환경 설정

## 확인된 개발 환경

| 도구 | 현재 확인 버전 | 용도 |
|---|---|---|
| Flutter | 3.44.0 stable | 앱 개발·분석·테스트·빌드 |
| Dart | 3.12.0 | 언어와 테스트 실행 |
| Git | 2.53.0.windows.2 | 버전 관리 |
| GitHub CLI | 2.93.0 | 저장소 상태와 배포 보조 |
| Chrome | Flutter Web 지원 버전 | 로컬 실행과 발표 시연 |

## 저장소 설치

```powershell
git clone https://github.com/yseho031018/rhythm-archive.git
cd rhythm-archive
flutter pub get
```

## 실행

Chrome:

```powershell
flutter run -d chrome
```

사용 가능한 디바이스 확인:

```powershell
flutter devices
```

## 환경 확인

```powershell
flutter doctor
flutter --version
dart --version
git --version
```

## 품질 검증

```powershell
flutter analyze
flutter test
flutter build web --release --base-href "/rhythm-archive/"
```

## 현재 의존성

| 패키지 | 목적 |
|---|---|
| `shared_preferences` | 기록과 사용자 키워드 로컬 저장 |
| `cupertino_icons` | 아이콘 |
| `flutter_test` | 단위·위젯 테스트 |
| `flutter_lints` | 정적 분석 규칙 |

## 문제 해결

### flutter 명령을 찾을 수 없음

Flutter SDK의 `bin` 디렉토리를 PATH에 등록한다.

```powershell
$env:Path='C:\seho\Apps\flutter\bin;' + $env:Path
```

### Web 에셋이 보이지 않음

GitHub Pages 경로를 포함해 다시 빌드한다.

```powershell
flutter build web --release --base-href "/rhythm-archive/"
```

### 저장 데이터 초기화

브라우저 사이트 데이터에서 `yseho031018.github.io` 또는 localhost의 저장 데이터를 삭제한다. SharedPreferences Web 구현은 브라우저 로컬 저장소를 사용한다.

### Android SDK 경고

현재 발표 시연과 공개 배포는 Chrome Web 기준이므로 Android SDK가 없어도 Web 실행·빌드는 가능하다.

## 연결 문서

- [아키텍처](architecture.md)
- [빌드와 배포](deploy.md)
- [테스트](testing.md)
