# Rhythm — Setup Guide

> 새 사람이 저장소를 clone한 뒤 Rhythm 데모 앱을 실행하기 위한 절차를 정리한다.

---

## 1. 필요한 도구

| 도구 | 권장 버전 | 확인 명령 |
|------|-----------|-----------|
| Flutter | 3.44.0 이상 | `flutter --version` |
| Dart | Flutter SDK 포함 | `dart --version` |
| Chrome | 최신 버전 | `flutter devices` |
| Git | 최신 버전 | `git --version` |

현재 중간 발표 데모는 **Chrome Web** 실행을 기준으로 한다. Android SDK가 없어도 웹 데모는 실행할 수 있다.

---

## 2. 저장소 받기

```powershell
git clone https://github.com/yseho031018/rhythm-archive.git
cd rhythm-archive
```

이미 저장소가 있다면:

```powershell
git pull origin master
```

---

## 3. 의존성 설치

```powershell
flutter pub get
```

---

## 4. 실행

Chrome에서 실행:

```powershell
flutter run -d chrome
```

Windows 데스크톱에서 실행:

```powershell
flutter run -d windows
```

단, Windows 데스크톱 실행은 플러그인 symlink 때문에 Windows 개발자 모드가 필요할 수 있다. 발표용으로는 Chrome 실행을 우선 사용한다.

---

## 5. 검증 명령

정적 분석:

```powershell
flutter analyze
```

테스트:

```powershell
flutter test
```

웹 빌드:

```powershell
flutter build web
```

---

## 6. 데모 기능

- 오늘의 에너지 레벨 입력
- 감정 키워드 선택
- 활동 태그 선택
- 짧은 메모 저장
- Particle Canvas 시각화
- 히스토리 조회
- 기본 패턴 카드 확인

중간 발표 데모는 `shared_preferences`를 사용해 브라우저/로컬 환경에 간단히 저장한다. 최종 구조에서는 ADR-0003에 따라 Isar 기반 로컬 DB로 확장할 계획이다.

---

## 7. GitHub Pages URL

앱 데모:

```text
https://yseho031018.github.io/rhythm-archive/
```

중간 발표자료:

```text
https://yseho031018.github.io/rhythm-archive/presentation.html
```

WBS/Gantt:

```text
https://yseho031018.github.io/rhythm-archive/wbs-gantt.html
```

---

## 8. 문제 해결

### `flutter` 명령을 찾을 수 없음

Flutter SDK의 `bin` 경로가 PATH에 등록되어 있는지 확인한다.

예:

```powershell
$env:Path='C:\seho\Apps\flutter\bin;' + $env:Path
```

### Android SDK 오류가 표시됨

현재 데모는 Chrome 실행을 기준으로 하므로 Android SDK 오류가 있어도 웹 실행은 가능하다.

### Windows 실행 시 Developer Mode 오류

Windows 설정에서 개발자 모드를 켠 뒤 다시 실행한다.

```powershell
start ms-settings:developers
```

### 화면이 이전 데이터로 보임

앱 상단 오른쪽의 새로고침 아이콘을 눌러 데모 데이터를 초기화한다.

### 테스트가 오래 걸림

다음 명령으로 다시 실행한다.

```powershell
flutter test
```

---

*문서 버전: 1.0*  
*작성일: 2026-05-26*
