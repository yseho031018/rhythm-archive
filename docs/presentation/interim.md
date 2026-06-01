---
marp: true
theme: default
paginate: true
size: 16:9
header: ""
footer: "윤세호 · App Programming Project · C반 중간발표 · 2026-06-02"
style: |
  :root {
    --bg: #050808;
    --panel: rgba(12, 19, 20, 0.86);
    --panel2: rgba(18, 31, 32, 0.72);
    --line: rgba(214, 182, 109, 0.34);
    --line2: rgba(48, 72, 75, 0.7);
    --gold: #d6b66d;
    --gold2: #f1d7a1;
    --mint: #1be0b5;
    --blue: #6ec6ff;
    --text: #e9eff0;
    --muted: #a8b5b7;
    --dim: #718082;
  }
  section {
    color: var(--text);
    background:
      radial-gradient(circle at 72% 18%, rgba(27,224,181,.13), transparent 34%),
      radial-gradient(circle at 16% 84%, rgba(214,182,109,.11), transparent 32%),
      linear-gradient(145deg, #071111 0%, #050808 52%, #030505 100%);
    font-family: "Segoe UI", "Pretendard", "Malgun Gothic", sans-serif;
    font-size: 25px;
    line-height: 1.34;
    padding: 54px 64px 72px;
    letter-spacing: 0;
  }
  section::after {
    color: rgba(233,239,240,.44);
    font-size: 13px;
    right: 34px;
    bottom: 24px;
  }
  h1, h2, h3 { color: var(--text); letter-spacing: -0.02em; }
  h1 { font-size: 64px; line-height: .98; margin: 0 0 14px; }
  h2 { font-size: 38px; margin: 0 0 22px; }
  h3 { font-size: 25px; margin: 0 0 10px; color: var(--gold2); }
  p { margin: 0 0 16px; }
  strong { color: var(--gold2); }
  em { color: var(--mint); font-style: normal; }
  a { color: var(--gold2); }
  ul, ol { margin: 0; padding-left: 1.15em; }
  li { margin: 7px 0; }
  table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    overflow: hidden;
    border: 1px solid var(--line2);
    border-radius: 14px;
    font-size: 18px;
    background: rgba(5,8,8,.34);
  }
  th {
    color: var(--gold2);
    background: rgba(214,182,109,.09);
    font-weight: 800;
  }
  td, th {
    border: 0;
    border-bottom: 1px solid rgba(48,72,75,.55);
    padding: 11px 14px;
  }
  tr:last-child td { border-bottom: 0; }
  code {
    background: rgba(27,224,181,.1);
    color: var(--mint);
    border-radius: 8px;
    padding: 2px 7px;
  }
  .eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: var(--gold2);
    font-size: 15px;
    font-weight: 800;
    letter-spacing: .08em;
    text-transform: uppercase;
    margin-bottom: 14px;
  }
  .eyebrow::before {
    content: "";
    width: 28px;
    height: 2px;
    border-radius: 999px;
    background: linear-gradient(90deg, var(--mint), var(--gold));
  }
  .lead {
    color: var(--muted);
    font-size: 24px;
    max-width: 760px;
  }
  .hero {
    display: grid;
    grid-template-columns: 1.05fr .95fr;
    gap: 42px;
    align-items: center;
  }
  .hero img {
    width: 100%;
    filter: drop-shadow(0 28px 42px rgba(0,0,0,.42));
  }
  .card, .metric, .quote, .urlbox {
    background: linear-gradient(145deg, var(--panel2), var(--panel));
    border: 1px solid var(--line2);
    border-radius: 18px;
    box-shadow: 0 22px 44px rgba(0,0,0,.26);
  }
  .card { padding: 24px; }
  .quote {
    padding: 26px 30px;
    border-color: var(--line);
    font-size: 28px;
    font-weight: 800;
    line-height: 1.28;
  }
  .grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
  .grid3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  .metric { padding: 20px; min-height: 126px; }
  .metric b { display:block; color: var(--gold2); font-size: 34px; line-height:1; margin-bottom: 10px; }
  .metric span { color: var(--muted); font-size: 17px; }
  .tag {
    display: inline-block;
    padding: 6px 10px;
    border-radius: 999px;
    background: rgba(27,224,181,.11);
    border: 1px solid rgba(27,224,181,.26);
    color: var(--mint);
    font-size: 15px;
    font-weight: 800;
    margin: 3px 5px 3px 0;
  }
  .flow {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-top: 18px;
  }
  .step {
    padding: 18px;
    border-radius: 16px;
    background: rgba(12,19,20,.72);
    border: 1px solid var(--line2);
  }
  .step b { color: var(--gold2); font-size: 18px; display:block; margin-bottom: 8px; }
  .step span { color: var(--muted); font-size: 16px; }
  .urlbox {
    padding: 16px 18px;
    font-size: 20px;
    margin: 12px 0;
  }
  .urlbox small {
    display:block;
    color: var(--dim);
    font-size: 14px;
    margin-bottom: 6px;
    font-weight: 800;
  }
  .small { color: var(--muted); font-size: 18px; }
  mermaid { color: var(--text); }
---

<div class="hero">
<div>
<div class="eyebrow">Rhythm</div>

# 감정을 파동으로 기록하는 다이어리

<p class="lead">에너지, 감정, 활동을 짧게 입력하면 오늘의 상태를 움직이는 <em>Wave Graph</em>로 시각화하는 Flutter Web 데모입니다.</p>

<span class="tag">Flutter</span>
<span class="tag">CustomPainter</span>
<span class="tag">GitHub Pages</span>
</div>

![Rhythm app preview](docs/presentation/assets/rhythm-wave-preview.svg)
</div>

---

## 1. 기획: 문제 정의와 비전

<div class="grid2">
<div class="card">
<h3>문제</h3>

- 기존 다이어리 앱은 기록이 길고 무겁다.
- 기록이 쌓여도 리스트와 숫자 중심이라 직관성이 낮다.
- 감정의 흐름을 사용자가 직접 느끼기 어렵다.
</div>

<div class="quote">
매일 30초, 감정을 톡톡 찍으면<br>
내 감정의 파도가 보이는 앱
</div>
</div>

<p class="small">Rhythm의 비전은 기록을 의무가 아니라 자기관찰 경험으로 바꾸는 것입니다.</p>

---

## 2. 핵심 경험: 기록 → 시각화 → 회고

<div class="flow">
<div class="step"><b>1. 에너지</b><span>오늘의 컨디션을 1~5로 선택</span></div>
<div class="step"><b>2. 감정</b><span>감정 키워드 최대 3개 선택</span></div>
<div class="step"><b>3. Wave Graph</b><span>감정별 파동 성격을 하나로 융합</span></div>
<div class="step"><b>4. 패턴</b><span>히스토리와 평균, 빈도 힌트 확인</span></div>
</div>

<div class="grid3" style="margin-top:22px;">
<div class="metric"><b>30초</b><span>짧은 입력 흐름</span></div>
<div class="metric"><b>1개</b><span>감정 조합을 하나의 대표 파동으로 표현</span></div>
<div class="metric"><b>Web</b><span>URL로 바로 실행 가능한 데모</span></div>
</div>

---

## 3. 기능 범위와 현재 데모

| 구분 | 현재 데모에서 보여주는 내용 |
|---|---|
| 일일 기록 | 에너지, 감정 키워드, 활동 태그, 메모 입력 |
| 감정 시각화 | 감정별 색상·속도·불규칙성을 Wave Graph로 표현 |
| 히스토리 | 저장된 리듬 기록을 날짜별로 확인 |
| 패턴 카드 | 평균 에너지, 자주 나온 감정/활동, 최근 흐름 |
| 배포 | GitHub Pages URL로 앱과 발표자료 제공 |

<p class="small">단순 CRUD가 아니라, 감정 데이터를 시각적 파동으로 변환하는 구조를 중간 데모의 핵심으로 잡았습니다.</p>

---

## 4. 설계: 아키텍처 방향

```mermaid
flowchart LR
  UI["Presentation<br/>Screens / Widgets / Painters"]
  APP["Application<br/>ViewModel / UseCase"]
  DOMAIN["Domain<br/>Entity / Rule / Repository Interface"]
  DATA["Data<br/>Isar / Repository Implementation"]

  UI --> APP
  APP --> DOMAIN
  DATA --> DOMAIN
```

<div class="card" style="margin-top:18px;">
<strong>핵심 원칙:</strong> UI, 감정 파동 계산, 저장소 책임을 분리해서 나중에 Riverpod과 Isar로 확장하기 쉽게 만든다.
</div>

---

## 5. WBS와 진행 상황

<div class="grid2">
<div class="card">
<h3>완료한 것</h3>

- Vision / Requirements / WBS / Risk
- ADR 3개
- Flutter Web 데모
- GitHub Pages 배포
- 기본 테스트와 구조 분리
</div>

<div class="card">
<h3>다음 작업</h3>

- Riverpod 상태관리 도입
- Isar 기반 로컬 DB 적용
- 기록 수정/삭제
- 패턴 분석 고도화
</div>
</div>

<div class="urlbox">
<small>WBS / Gantt URL</small>
https://yseho031018.github.io/rhythm-archive/wbs-gantt.html
</div>

---

## 6. 발표 URL과 데모 흐름

<div class="urlbox">
<small>발표자료</small>
https://yseho031018.github.io/rhythm-archive/presentation.html
</div>

<div class="urlbox">
<small>앱 데모</small>
https://yseho031018.github.io/rhythm-archive/
</div>

<div class="card" style="margin-top:18px;">
<h3>2분 발표 흐름</h3>

1. 문제 정의와 비전 설명  
2. 감정 기반 Wave Graph 핵심 기능 설명  
3. WBS/Gantt로 진행 상황 확인  
4. 아키텍처와 남은 계획 설명
</div>

---

## 마무리

<div class="quote">
Rhythm은 감정을 저장하는 앱이 아니라,<br>
감정의 흐름을 사용자가 직접 바라보게 하는<br>
감정 시각화 앱입니다.
</div>

<p class="lead" style="margin-top:24px;">감사합니다.</p>
