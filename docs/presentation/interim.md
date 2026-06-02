---
marp: true
theme: default
paginate: true
size: 16:9
header: "Rhythm — Interim Presentation"
footer: "윤세호 · App Programming Project · 2026-06-02"
style: |
  section {
    font-size: 28px;
    line-height: 1.35;
    padding: 56px 64px 84px;
  }
  h1 { font-size: 1.9em; }
  h2 { font-size: 1.45em; margin-bottom: 0.55em; }
  table { font-size: 21px; line-height: 1.25; }
  code { font-size: 0.9em; }
  .small { font-size: 0.78em; }
  .cover-grid {
    display: grid;
    grid-template-columns: 1fr 0.95fr;
    gap: 48px;
    align-items: center;
    min-height: 430px;
  }
  .cover-copy h1 {
    margin: 0 0 0.8em;
    font-size: 2em;
  }
  .cover-copy h2 {
    margin: 0 0 1.2em;
    font-size: 1.35em;
  }
  .cover-meta {
    font-size: 0.86em;
    line-height: 1.35;
  }
  .hero-preview {
    display: block;
    width: 100%;
    max-height: 315px;
    object-fit: contain;
    margin: 0;
    border-radius: 18px;
  }
  .compact { font-size: 0.78em; line-height: 1.25; }
  .demo-grid {
    display: grid;
    grid-template-columns: 1fr 1.08fr;
    gap: 22px;
    align-items: start;
    margin-top: 8px;
  }
  .demo-box {
    border: 1px solid #d9dfe7;
    border-radius: 10px;
    padding: 14px 16px;
    background: #f8fafc;
  }
  .demo-box h3 {
    font-size: 1em;
    margin: 0 0 0.4em;
  }
  .demo-box ul,
  .demo-box ol {
    margin: 0;
    padding-left: 1.15em;
  }
  .demo-box li { margin: 0.16em 0; }
  .url-line {
    margin-top: 12px;
    padding: 9px 10px;
    border: 1px solid #d9dfe7;
    border-radius: 8px;
    background: #ffffff;
    font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    font-size: 0.68em;
    white-space: nowrap;
  }
  .arch-flow {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    align-items: stretch;
    margin: 16px 0 24px;
  }
  .arch-card {
    position: relative;
    min-height: 156px;
    padding: 16px 14px;
    border: 1px solid #d9dfe7;
    border-radius: 12px;
    background: linear-gradient(180deg, #ffffff 0%, #f7fafc 100%);
    box-shadow: 0 8px 20px rgba(31, 41, 55, 0.08);
  }
  .arch-card:not(:last-child)::after {
    content: "→";
    position: absolute;
    right: -15px;
    top: 50%;
    transform: translateY(-50%);
    color: #8a97a6;
    font-weight: 800;
    font-size: 0.9em;
  }
  .arch-kicker {
    display: inline-block;
    margin-bottom: 10px;
    padding: 4px 9px;
    border-radius: 999px;
    background: #eef4f7;
    color: #24476b;
    font-size: 0.54em;
    font-weight: 800;
  }
  .arch-title {
    margin-bottom: 8px;
    color: #1f2937;
    font-size: 0.86em;
    font-weight: 900;
  }
  .arch-desc {
    color: #4b5563;
    font-size: 0.58em;
    line-height: 1.35;
  }
  .arch-note {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    margin-top: 8px;
  }
  .arch-pill {
    padding: 12px 14px;
    border-left: 5px solid #24476b;
    background: #f8fafc;
    color: #1f2937;
    font-size: 0.68em;
    line-height: 1.35;
  }
---

<div class="cover-grid">
  <div class="cover-copy">
    <h1>Rhythm</h1>
    <h2>감정의 파도를 시각화하는 다이어리 앱</h2>
    <div class="cover-meta">윤세호<br>중간 발표 · 2026-06-02</div>
  </div>
  <img class="hero-preview" src="docs/presentation/assets/rhythm-wave-preview.svg" alt="Rhythm app preview">
</div>

---

## 1. 문제 정의와 해결 아이디어

기존 다이어리 앱은 매일 길게 기록해야 해서 부담이 있고, 기록이 쌓여도 리스트나 숫자로만 보이는 경우가 많다.

Rhythm은 **에너지, 감정, 활동을 30초 안에 기록**하고, 그 데이터를 **Wave Graph**로 표현해 사용자가 자신의 생활 리듬을 직관적으로 돌아보게 하는 앱이다.

> **매일 30초, 감정을 톡톡 찍으면 내 감정의 파도가 보이는 다이어리 앱**

---

## 2. 핵심 흐름과 현재 구현

| 흐름 | 화면 | 현재 구현 |
|------|------|-----------|
| 1 | 오늘 탭 | 에너지, 감정 키워드, 활동 태그 입력 |
| 2 | Wave Graph | 선택 감정에 따라 파동 그래프 변화 |
| 3 | 히스토리 | 저장된 기록을 날짜별로 확인 |
| 4 | 패턴 | 평균 에너지, 자주 나온 감정/활동 카드 |

현재는 중간 발표용 **Flutter Web 데모**로 핵심 사용 흐름을 먼저 구현했다.

---

## 3. 기술 스택과 아키텍처

| 영역 | 선택 | 이유 |
|------|------|------|
| Flutter | Web 데모 + 모바일 확장 | CustomPainter 기반 Wave Graph 구현 |
| Riverpod | 상태 관리 | 화면과 입력 상태 흐름 분리 |
| Isar | 로컬 DB | 오프라인 우선 기록 저장 |
| Layered Architecture | 구조 설계 | 화면, 로직, 저장소 책임 분리 |

<div class="arch-flow">
  <div class="arch-card">
    <div class="arch-kicker">Presentation</div>
    <div class="arch-title">화면 / 위젯</div>
    <div class="arch-desc">오늘 탭, 히스토리, 패턴 화면과 Wave Graph UI를 담당한다.</div>
  </div>
  <div class="arch-card">
    <div class="arch-kicker">Application</div>
    <div class="arch-title">상태 / UseCase</div>
    <div class="arch-desc">입력값 변경, 저장 요청, 화면 갱신 흐름을 관리한다.</div>
  </div>
  <div class="arch-card">
    <div class="arch-kicker">Domain</div>
    <div class="arch-title">규칙 / Entity</div>
    <div class="arch-desc">감정 파동 계산, 기록 모델, Repository 규칙을 정의한다.</div>
  </div>
  <div class="arch-card">
    <div class="arch-kicker">Data</div>
    <div class="arch-title">저장소 / Isar</div>
    <div class="arch-desc">로컬 DB 저장, 조회, 데이터 변환을 구현한다.</div>
  </div>
</div>

<div class="arch-note">
  <div class="arch-pill"><strong>핵심 원칙</strong><br>Wave Graph와 감정 파동 계산 로직을 분리한다.</div>
  <div class="arch-pill"><strong>확장 방향</strong><br>저장소나 분석 기능이 바뀌어도 화면 구조는 크게 흔들리지 않게 한다.</div>
</div>

---

## 4. 데모와 산출물

<div class="demo-grid compact">
  <div class="demo-box">
    <h3>발표 산출물</h3>
    <ul>
      <li>GitHub 저장소의 기획 문서 세트</li>
      <li>WBS/Gantt 페이지</li>
      <li>ADR 3개</li>
      <li>Flutter Web 데모 앱</li>
    </ul>
    <div class="url-line">https://yseho031018.github.io/rhythm-archive/</div>
    <div class="url-line">https://yseho031018.github.io/rhythm-archive/wbs-gantt.html</div>
  </div>
  <div class="demo-box">
    <h3>30초 데모 흐름</h3>
    <ol>
      <li>오늘 탭에서 에너지, 감정, 활동을 입력한다.</li>
      <li>저장 후 Wave Graph가 바뀌는지 확인한다.</li>
      <li>히스토리 탭에서 저장된 기록을 확인한다.</li>
      <li>패턴 탭에서 평균 에너지와 자주 나온 감정/활동을 확인한다.</li>
    </ol>
  </div>
</div>

---

## 5. 남은 일정과 기말 계획

중간 발표 이후에는 단순 기록 앱에서 **생활 리듬 분석 앱**으로 확장한다.

| 우선순위 | 계획 | 목적 |
|----------|------|------|
| 1 | Riverpod + Isar 구조 전환 | 입력/저장/조회 흐름을 설명 가능한 구조로 정리 |
| 2 | 감정-활동 상관 분석 | "공부한 날 성취감이 자주 나타남" 같은 해석 단서 제공 |
| 3 | 주간 리듬 리포트 | 평균 에너지, 대표 감정, 주요 활동을 7일 단위로 요약 |
| 4 | 테스트와 최종 발표 | README, 검증 기록, 데모 안정화 |

추가 후보: **월간 캘린더 뷰**, **날씨 API 맥락 기록**  
핵심 원칙: **기능을 늘리더라도 오프라인 기록/조회 흐름은 유지한다.**
