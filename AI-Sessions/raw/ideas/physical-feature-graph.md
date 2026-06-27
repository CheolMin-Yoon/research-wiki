---
type: raw-idea
date: 2026-06-27
status: active
source: 2026-06-27 세션 대화; 기존 raw idea 2개(physical-feature-graph + humanoid-arm-dual-role) 통합
---

# 부유 동역학 로봇의 coupled whole-body를 위한 Physical Feature Graph — morphology token + centroidal token을 attend하는 graph Transformer policy

> 사용자 본인의 **거시적(macro) 연구 아이디어**다. 구현 스키마가 아니라, 고전 안정성 해석과 현대 RL을 잇는 물리 표현(Physical Feature Graph)과 휴머노이드 팔의 이중 역할을 **하나의 graph Transformer 관점**으로 통합한 출발점이다. 기존 raw idea 2개를 흡수했다.
> 아래 **"고려할 수 있는 방식(설계 공간)"** 절은 확정안이 아니라 검토 대상 옵션의 기록이다. 거시 idea가 먼저고, 세부 구현 선택은 열어 둔다.

## Summary (thesis)

Heavy limb·payload가 있는 humanoid loco-manipulation은 본질적으로 **coupled whole-body dynamics** 문제다. locomotion과 manipulation을 분리하면 학습은 쉬워지지만, **arm·leg·object의 움직임이 centroidal을 통해 balance에 함께 작용하는 경로**가 가려진다. 따라서 robot body를 structured token(morphology)으로 표현하고 거기에 **centroidal-dynamics token(stability language)**을 더해, policy가 *morphology 구조*와 *whole-body dynamic coupling* 둘 다에 attend하게 하는 **graph Transformer policy**를 제안한다.

핵심은 두 가지를 하나로 묶는 것이다.
- (표현) 고전 안정성 해석의 물리 언어(CoM·DCM·ZMP·CMM·CAM·contact·footstep)를 morphology graph와는 **다른 층위**의 token으로 둔다.
- (물리) 팔은 비접촉 시 centroidal stabilizer, 접촉 시 manipulation wrench source이며, **두 역할 모두 centroidal momentum $h_G$를 통해 locomotion stability에 결합**한다.

## 문제: loco-manipulation = coupled whole-body

floating-base robot은 결국 end-effector를 통해 세계와 상호작용한다. 발·손·물체 접촉은 외부 wrench이고, 그 효과는 whole-body/centroidal dynamics로 되돌아온다. 분리 학습(locomotion ↔ manipulation, 또는 arm ↔ leg)은 구현을 단순화하지만, 무거운 물체를 들거나 좁은 지형을 지날 때처럼 balance margin이 줄어드는 상황에서 **arm·leg·object가 공통 centroidal 변수 위에서 다시 결합되는 경로**를 표현에서 지워버린다.

## 왜 팔이 핵심 매개인가 (arm dual-role 흡수)

다리는 [3d-lipm-icp] LIPM/ICP, DCM, ZMP, footstep, capturability 같은 강한 reduced-order 해석 도구를 쌓아 왔다. 반면 팔은 보통 별도 end-effector, arm-swing style, 추가 관절, CAM 감소 reward 대상 중 하나로만 다뤄진다. 정작 팔이 **어떤 물리적 경로로** balance에 기여하는지는 덜 명시적이다.

- **접촉 중 — manipulation wrench source**: 손이 밀고/당기고/문을 열고/짐을 들 때 그 wrench는 손끝에 머물지 않고 base motion·CoM·foot contact·CAM과 coupling된다.
- **비접촉 중 — centroidal stabilizer**: 팔 자세·swing은 질량 분포·관성·angular momentum을 바꿔 CAM을 보상한다(빠른 전진/회전/외란 회복/좁은 지형).

두 역할은 분리되어 보여도 **centroidal momentum $h_G$라는 공통 타깃**에서 만난다. 단, 팔이 항상 안정화하는 것은 아니다 — 잘못 조율되면 불필요한 CAM·torso disturbance·contact 불안정을 만든다. 그래서 핵심은 "팔을 움직인다"가 아니라 "팔이 centroidal에 어떤 방향으로 coupling되는지"를 표현에 드러내는 것이다.

## stability language (physical-feature-graph 핵심 유지)

CoM·DCM·ZMP·CMM·CAM·contact·footstep은 hand-crafted feature가 아니라, 부유 동역학 로봇의 안정성을 설명하려 고전 안정성 해석과 centroidal dynamics에서 추출된 **물리 언어**다. LIPM/ICP류는 full-body를 다 설명하지 못하지만(점질량·등고 CoM·angular momentum 무시), 안정성을 판단하는 **거시 좌표계**이기 때문에 여전히 강력하다. 이들은 정답 dynamics model이 아니라 **agent에게 줄 수 있는 구조적 guide**다. 축소모델과 실제 full-body 사이의 차이는 RL이 학습할 영역으로 남는다.

이 아이디어가 보는 네 가지 관점(구현 스키마가 아니라 해석 층위):
1. **로봇 상태**: `q`, `dq`, base state, command (기존 raw observation)
2. **물리적 특징**: CoM, DCM/ICP, ZMP, CMM, CAM (stability language)
3. **접촉 정보**: stance/swing, support region, footstep, contact wrench, foothold feasibility
4. **body 정보**: pelvis/torso/leg/foot/arm/hand (물리량의 anchor)

선행 흐름과의 연결: [2024-lee-footstep-planning-rl]은 3D-LIPM/ICP footstep을 RL에 partial guidance로 주고 나머지는 학습에 맡긴다. [2025-lee-humanoid-arm-cam-marl]은 CAM을 reward/observation에 넣어 arm-leg coordination을 유도한다. 둘 다 "reduced-order physics는 버릴 대상이 아니라 좋은 guide"라는 힌트를 준다. 이 아이디어는 그것을 footstep 하나·CAM 하나에 머물지 않고 **stability language 전체의 coupling 구조**로 확장한다.

## 표현: 두 결합 경로가 CAM hub에서 만난다 (통합의 핵심)

centroidal momentum은 [centroidal] 정의상
$$h_G=\begin{bmatrix}k_G\\ l_G\end{bmatrix}=A_G(q)\,\dot q,\qquad \dot h_G=\sum_i \text{wrench}_i$$
이고, CMM $A_G(q)$는 $6\times n$ 행렬, **column $j$ = joint/actuator $j$가 centroidal momentum에 기여하는 양**이다. 즉 CMM 자체가 *joint↔centroidal 결합 행렬*이며, $h_G=\sum_j A_G[:,j]\,\dot q_j$는 구조적으로 **attention의 weighted aggregation과 동형**이다. 그래서 centroidal token이 joint node들을 "읽는" 연산은 CMM이 하는 일의 soft/learnable 일반화로 볼 수 있다.

두 물리 결합 경로:
- **비접촉**: joint/limb node ──(CMM $A_G$)──▶ **CAM(=$h_G$) hub token** — 팔의 stabilizer 역할.
- **접촉**: hand/foot **site node**(end-effector wrench) ──(wrench)──▶ **CAM token의 rate $\dot h_G$** — 팔의 wrench-source 역할. 물체를 쥐면 payload 반력이 hand site wrench로 잡히므로 **object/payload 효과가 자연 유입**된다.

이 둘이 **하나의 CAM hub token**으로 모이고, 그 위에서 Transformer **global attention**이 whole-body coupling을 학습한다. 이것이 morphology graph(몸이 어떻게 연결되는가) 위에 stability-language 층(물리 특징이 어떻게 커플링되는가)을 얹는다는 원래 주장의 구체화다.

## 아키텍처 참조점

- **[2024-sferrazza-body-transformer] BoT**: morphology token + adjacency hard/mixed **mask**. 구조가 **정적**(kinematic adjacency)이고 token화는 node-type별 별도 Linear.
- **[2025-luo-gcnt] GCNT**: GCN+WL로 morphology 추출 + **full attention** + learnable **distance(SPD) soft-bias**. 구조 bias가 **정적**(SPD).
- **이 아이디어의 차별점(가설)**: 구조 bias의 출처가 정적 거리/인접이 아니라 **state-dependent 물리량(CMM·wrench)**이고, morphology token에 **centroidal token을 추가**한다. attention은 GCNT처럼 full로 열어 두는 쪽이 BoT의 "GCN+hard-mask 중복" 함정을 피한다.
- **[2021-ying-graphormer] Graphormer**: attention logit에 더하는 soft-bias(spatial encoding)의 원형. CMM-bias도 같은 자리에 들어간다.

## 고려할 수 있는 방식 (설계 공간 — 미확정, 옵션 기록)

### A. centroidal token 구성
- **A1. 단일 CAM hub token** ($h_G$, CAM+linear 6D): 비접촉·접촉 두 경로의 공통 타깃이 $h_G$라 물리적으로 자연스럽고 token 수가 적다.
- **A2. 분할**: CAM token / linear-momentum token / contact-wrench token 등을 분리. 표현력↑·해석↑이지만 token·결합이 늘어난다.
- (현재 직관: A1이 깔끔. 미확정.)

### B. EE wrench를 읽는 node *(두 방식 모두 기록)*
- **B1. 분리** *(현재 선호)*: hand/foot **site node**를 limb node와 별도로 둔다. "kinematic limb"과 "contact interface"의 의미가 달라 결합 경로(CMM vs wrench)가 깔끔히 갈린다. token 수는 늘어난다.
- **B2. 증강**: 기존 hand/foot limb node의 obs에 wrench를 덧붙인다. token 수 절약·단순하지만 두 역할이 한 node에 섞인다.

### C. CMM coupling 주입 강도 *(미확정 — ablation 축)*
- **C1. 순수 global attention**: CMM을 명시적으로 쓰지 않고 coupling을 attention이 학습. baseline.
- **C2. CMM soft-bias**: joint↔CAM-token attention logit에 $g_\phi(A_G[:,j])$를 더함(GCNT distance-bias 자리, 출처만 state-dependent $A_G$).
- **C3. CMM node feature**: 각 joint node 임베딩에 $A_G[:,j]$(centroidal 기여 6-vector)를 포함.
- (C2·C3 병행 가능. C1 대비 C2/C3가 "구조적 guide" 변이.)

### D. token화 방식
- 단일 G1이라 node-type별 obs 차원이 다름(limb=`[q,dq,...]`, EE site=6D wrench, CAM=6D) → **GCNT의 uniform MLP보다 BoT식 node-type별 Linear**가 적합. (GCNT의 morphology-agnostic universality는 목표 아님 — 단일 morphology에 GCN/추출 메커니즘만 차용.)

### E. centroidal 값의 사용처 *(미확정)*
- **E1. observation only**: 표현 수준 guide로만.
- **E2. auxiliary prediction/reward까지**: [2025-lee-humanoid-arm-cam-marl] 계열처럼 CAM을 학습 신호로도 사용.

## 예시

- **Loco-manipulation**: 무거운 물체 운반·문 열기·이동 중 grasp. 손이 만든 wrench가 hand site → CAM rate로 전파. 좋은 정책은 hand trajectory뿐 아니라 그 wrench가 centroidal state에 미치는 효과까지 고려한다.
- **Narrow terrain**: foot placement 자유도가 줄어 다리만으론 안정성 회복이 한계. 팔의 internal motion이 CMM 경유로 CAM을 보상하는 비중이 커진다. 발 위치 자유도가 줄수록 팔/상체 internal motion의 stability margin 기여가 커진다는 사고 실험.

## 피해야 할 주장 (두 노트 통합)

- "Physical Feature Graph가 full-body dynamics의 정답 모델이다." → 아니다. reduced-order physics·centroidal language를 **구조적 guide**로 쓴다.
- "Attention이 물리 법칙을 새로 발견한다." → 아니다. **이미 알려진 coupling**을 표현에 드러낼 뿐이다.
- "Morphology graph는 필요 없다." → 아니다. body graph 위에 **stability-language 층을 추가**하는 것이다.
- "Reward shaping이 완전히 사라진다." → 아니다. 일부 안정성 shaping 부담을 representation으로 옮길 가능성일 뿐이다.
- "팔은 항상 안정성을 높인다." → 아니다. 잘못 조율된 팔은 disturbance가 된다.
- "단일 G1을 넘어 morphology-agnostic까지 노린다." → 아니다(현 scope). GCNT의 universality가 아니라 **추출·attention 메커니즘만** 차용한다.

## Links (raw plaintext — graph 비노출)

- 통합 전 raw provenance: humanoid-arm-dual-role.md(이 문서로 흡수), 구 physical-feature-graph 내용 포함
- 관련 논문: 2024-lee-footstep-planning-rl, 2025-lee-humanoid-arm-cam-marl, 2024-sferrazza-body-transformer, 2025-luo-gcnt, 2021-ying-graphormer, 2013-orin-centroidal-dynamics
- 관련 개념: centroidal, lipm, transformer, ppo
