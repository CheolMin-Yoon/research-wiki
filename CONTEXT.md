# Research Knowledge Context

이 저장소는 휴머노이드 연구의 근거, 재사용 가능한 지식, 가설, 실험을 서로 다른 수명주기로 관리한다. 아래 용어는 연구 노트와 agent 지시에서 같은 의미로 사용한다.

## Language

**Topic**:
여러 연구 노트를 교차 조회하기 위한 큐레이터 승인 어휘다. 하나의 노트는 여러 topic에 속할 수 있다.
_Avoid_: Category, primary category, folder classification

**Concept**:
반복해서 참조되는 정의, 물리량, 원리 또는 구분이다. “무엇인가”에 답한다.
_Avoid_: Keyword, category hub

**Method**:
명시적인 입력, 출력, 가정과 절차를 가진 문제 해결 방식이다. “어떻게 동작하는가”에 답한다.
_Avoid_: Concept, implementation repository

**Task**:
목표, 관측, 행동, 제약과 평가 기준으로 정의되는 연구 문제다.
_Avoid_: Method, experiment run

**Paper**:
한 출판물에서 확인할 수 있는 주장과 근거를 보존하는 연구 증거다.
_Avoid_: Topic, literature category

**Source**:
코드나 저장소의 실제 구현 계약과 실행 경로를 분석한 연구 증거다.
_Avoid_: Paper, generic implementation category

**Comparison**:
공통 축으로 둘 이상의 근거를 대조해 선택 기준과 종합 판단을 제시하는 노트다.
_Avoid_: Paper summary, idea

**Idea**:
근거에 의해 지지되거나 반증될 수 있는 변경 가능한 연구 가설이다.
_Avoid_: Research root, permanent classification

**Experiment**:
고정된 조건에서 관측한 측정값과 판정을 보존하는 실행 기록이다.
_Avoid_: Task, idea

**Curator**:
topic 어휘와 지식 페이지 승격 여부를 최종 승인하는 사람이다.
_Avoid_: Automatic classifier

**Strong Relation**:
단순한 topic 공유가 아니라 설명, 구현, 근거, 대조 또는 검증의 의미가 있는 두 노트의 관계다.
_Avoid_: Exhaustive backlink, co-membership edge
