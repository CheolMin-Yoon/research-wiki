---
tags: [tier/low]
type: source
date: 2026-07-15
status: active
source: AI-Sessions/raw/repos/momaland.md
checked_commit: 2387b18
---

# Source: MOMAland Code (MOMAPPO + MO-MultiwalkerStability)

## What Was Checked

임시 clone(스크래치, 세션 종료 시 소멸), checked commit `2387b18`, pip 배포 버전 `momaland 0.2.0`과 동일 계열.

중요 영역:

- `momaland/learning/cooperative_momappo/continuous_momappo.py` (666줄): OLS 기반 multi-policy MOMAPPO, JAX/flax 구현. 이 노트의 주 분석 대상.
- `momaland/learning/cooperative_momappo/utils.py`: MO policy evaluation(`eval_mo`/`policy_evaluation_mo`), orbax checkpoint 저장.
- `momaland/envs/multiwalker_stability/momultiwalker_stability_base.py` + `momultiwalker_stability.py`: MO-MultiwalkerStability 환경 엔진과 PettingZoo 래핑.
- `momaland/utils/parallel_wrappers.py`: `LinearizeReward`, `NormalizeReward`, `CentraliseAgent`, `RecordEpisodeStatistics`.
- `momaland/utils/all_modules.py`: 환경 레지스트리 13종.

설치 호환성: `pip install --dry-run momaland`으로 env_isaaclab에서 기존 패키지(numpy 1.26.0, gymnasium 1.2.1, torch 2.7.0) 변경 없이 신규 패키지만 추가됨을 확인(2026-07-15). 단 `pygame`과 `pygame-ce`가 동시 설치되는 점만 주의(같은 `pygame` 모듈명을 제공하는 포크 관계; butterfly류 게임 env를 안 쓰면 실사용 무관).

## Library 구조 개요

MOMAland는 Farama의 multi-objective multi-agent RL(MOMARL) 벤치마크 모음이다. PettingZoo API를 확장해 **reward만 스칼라 → 벡터(objective 차원)** 로 바꾼 `MOAECEnv`/`MOParallelEnv`를 제공한다. 즉 우리(isaac_humanoid objective-routing)가 다루는 "agent × objective" 이중 분해 구조의 공인 벤치마크 인터페이스다.

환경 13종 중 continuous 제어는 `momultiwalker_stability_v0`(협동 locomotion, 아래 상세)와 CrazyRL 3종(`catch_v0`/`escort_v0`/`surround_v0`, 드론 kinematic point-mass)뿐이고 나머지(beach, item_gathering, connect4, breakthrough, ingenious, samegame, route_choice, gem_mining, pistonball)는 discrete/보드게임/추상 도메인이다. 휴머노이드 연구 관점에서 유의미한 건 사실상 multiwalker_stability 하나다.

학습 baseline은 3계열: `cooperative_momappo`(이 노트), `iql`(tabular scalarized IQL), `morl`(env를 `CentraliseAgent`로 single-agent MOMDP로 접어 morl-baselines의 GPI-LS/PCN을 돌리는 스크립트).

## MO-MultiwalkerStability 분석

### 구조

PettingZoo SISL multiwalker(Box2D bipedal walker 3대가 머리 위 package를 협동 운반)의 MO 변형이다. 상속 구조:

- `MOMultiWalkerStabilityEnv` ⊂ `pettingzoo...MultiWalkerEnv`: 물리 엔진·reward 산출(`scroll_subroutine` override).
- `MOMultiwalkerStability` ⊂ (`MOAECEnv`, pz `raw_env`): AEC 래핑, `reward_spaces`/`central_observation_space` 선언.
- `parallel_env()` = `mo_aec_to_parallel(raw_env)`. raw는 AEC(agent 순차 act, 마지막 agent에서만 `world.Step`)지만 parallel 변환이 표준 사용형.

### MDP contract (n_walkers=3 기본)

- **Agent**: walker 3대, 각각 action 4차원 연속 `[-1,1]` (hip×2, knee×2; sign=방향, magnitude=torque 비율). Box2D, FPS=50, `max_cycles=500`.
- **Local obs (31차원/agent)**: walker proprio+lidar 24 (hull angle/angvel/vel 4, joint angle·speed 10, leg contact 2, lidar 10) + 이웃 상대위치 4 + package 상대위치 2 + package 절대각 1. 상대위치엔 gaussian noise(`position_noise=1e-3`, `angle_noise=1e-3`).
- **Central state (`env.state()`, 75차원)**: 전체 walker의 24차원 obs flatten(72) + package `(x, y, angle)` 3. metadata `central_observation: True`로 선언되어 `CentraliseAgent`/MOMAPPO critic이 그대로 사용. **이웃/package 상대 obs(7)는 central엔 없음** — critic이 보는 정보와 actor가 보는 정보가 서로 부분집합 관계가 아닌 점이 특이하다.
- **Reward 벡터 (2 objectives)**, `scroll_subroutine`에서 산출:
  - obj0 (forward): package 전진의 potential-based shaping — `forward_reward * 130 * pkg.x / SCALE`의 스텝 간 차분. 스텝당 범위 약 `[-0.46, 0.46]`.
  - obj1 (stability): `-|Δ package angle|` (스텝 간 package 기울기 변화량 페널티). 스텝당 범위 약 `[-0.0157, 0]`.
  - 공통 페널티가 **두 objective 모두에** 더해짐: walker 낙상 시 해당 행에 `fall_reward=-10`, package 낙하/전복 시 전원에 `terminate_reward=-100`.
- **Termination**: package 낙하, `terminate_on_fall=True`(기본)면 walker 1대 낙상만으로도 전체 종료, package가 뒤로 밀려 `x<0`. Truncation: `max_cycles`.
- **Reward 공유**: `shared_reward=True`(기본) → 부모 클래스의 `local_ratio = 1 - shared_reward = 0` → 최종 reward는 walker 평균(전 agent 동일 벡터). `False`면 per-walker.

### 코드 특이점 (포팅 시 주의)

1. **죽은 코드**: per-walker hull-shaking shaping(`rewards[i,0] = shaping - prev_shaping`)을 계산해 놓고 바로 다음에 `rewards[:,0] = package_shaping - prev`로 **열 전체를 덮어쓴다**. obj0은 실질적으로 package 전진 항만 남는다(부모 SO 환경에서 물려받은 잔재).
2. **선언된 `reward_space` bound가 실측과 불일치**: `Box(low=[-210, -0.0157], high=[-210+0.46, 0])` — obj0 상한이 `-209.54`로 선언돼 있어 명백히 잘못된 선언이다(의도는 "스텝 reward ±0.46 + 최악 페널티 -210"). 기능상 이 bound를 쓰는 코드는 없지만(정규화는 running stat 기반), bound를 신뢰하면 안 된다.
3. **`local_ratio` 이중 곱**: `local_reward = rewards * local_ratio` 후 `+ local_reward * local_ratio`로 local 성분에 ratio가 제곱으로 걸린다. 공개 API로는 ratio가 0/1뿐이라 발현 안 되지만, fractional 공유를 시도하면 버그가 된다.
4. **objective scale 비대칭 ~30배** (0.46 vs 0.0157): linear scalarization 가중치가 이 스케일을 흡수해야 하며, MOMAPPO가 per-objective `NormalizeReward`를 끼우는 실질적 이유.

## MOMAPPO (continuous) 분석

### 전체 구조: outer OLS × inner MAPPO

single-policy가 아니라 **multi-policy MORL**이다. 한 번의 실행이 Pareto front(정확히는 CCS, convex coverage set) 근사를 만든다:

```
LinearSupport(OLS) 초기화 (morl_baselines, 순수 numpy)
while not ols.ended() and weight_number <= num_weights:
    w = ols.next_weight()            # corner weight 선택
    train(args, env, w, rng)         # w로 스칼라화한 MAPPO를 밑바닥부터 재학습
    disc_vec_return = policy_evaluation_mo(...)  # 5 episode 평균 discounted 벡터 return
    ols.add_solution(disc_vec_return, w)
    (hypervolume/EUM 로깅, actor orbax 저장)
```

- weight마다 **완전 재학습**(warm start 없음), weight당 `timesteps_per_weight`(기본 1e6) 스텝.
- OLS의 value 추정이 **stochastic policy 5-episode 평균**이라 노이즈가 크다. corner weight 선택이 이 노이즈에 좌우될 수 있다.
- `--weights-generation uniform`이면 OLS 대신 등간격 weight grid.

### Inner loop: parameter-shared MAPPO (CTDE)

- **Actor 1개를 전 agent가 공유**, agent 구분은 supersuit `agent_indicator_v0`(obs에 one-hot 3차원 append → 입력 34차원). MLP `[256,256]` tanh, state-독립 `log_std` 파라미터, `MultivariateNormalDiag`. orthogonal init(√2, 최종 0.01).
- **Critic 1개**, 입력은 `env.state()`(75차원) → 스칼라 V. **objective별 값이 아니라 스칼라화된 team return의 값 하나**다.
- **Wrapper 스택 순서**(train 내부에서 재구성): `clip_actions` → `normalize_obs [-1,1]` → `agent_indicator` → objective×agent별 `NormalizeReward`(EMA return 분산 정규화) → `LinearizeReward`(w·r) → `RecordEpisodeStatistics`. **정규화 후 스칼라화**이므로 OLS가 다루는 objective 공간은 정규화된 공간이고, 평가(`eval_mo`)는 raw reward 공간이다 — 학습 목표와 CCS 좌표계가 어긋나 있는 점 주의.
- **Rollout**: 벡터화 없이 **단일 env**를 Python 루프로 1280 스텝(`num_steps_per_epoch`) 수집. numpy `Buffer`에 쌓고 update 시 jnp 변환. JAX는 update 수학에만 쓰인다(rollout은 CPU/Box2D bound).
- **Team reward**: `sum(rewards.values())` — `shared_reward=True`라 전 agent reward가 동일하므로 실질 `n_agents ×` 스케일이다. **Truncation을 termination에 접어버림**(`terminated = any(term) or any(trunc)`, 코드에 TODO 명시) — time-limit bootstrap이 없다.
- **GAE**: 표준 스칼라 GAE(`jax.lax.scan` reverse), 기본 `gamma=0.99`, **`gae_lambda=0.99`**(이례적으로 높음).
- **PPO update**: epoch 2 × minibatch 2. advantage는 **minibatch 단위로** 정규화 후 전 agent에 동일 브로드캐스트. actor loss는 clipped surrogate를 agent별 평균 후 **agent 합**(mean이 아님 — 유효 학습률에 n_agents 배율). value는 old value 기준 clipped loss, `vf_coef=0.8`. entropy `ent_coef=0.0` 기본(꺼짐). optax `clip_by_global_norm(0.5) + adam(eps=1e-5)`, actor/critic이 **같은 optimizer chain 정의를 공유**하고 lr linear anneal은 `count // (num_minibatches*update_epochs) / num_updates`로 계산.
- **전역 상태 의존 jit**: `_ma_get_pi` 등이 module-level `env`/`actor`를 캡처한 `@jax.jit` 함수다. 리팩토링/포팅 시 명시적 인자로 바꿔야 한다.

### discrete 변형과의 차이

`discrete_momappo.py`는 actor 출력이 `distrax.Categorical(logits)`로 바뀌는 것 외에 구조 동일(공유 actor + central critic + OLS).

### 한계 정리 (baseline으로 쓸 때 알고 있어야 할 것)

1. 단일 env rollout — 처리량이 낮고 minibatch 통계가 한 trajectory에 종속.
2. truncation bootstrap 부재 — max_cycles 근처 value 학습이 편향.
3. weight마다 재학습 + stochastic 평가 — CCS 품질이 계산량 대비 낮다.
4. 정규화-스칼라화 순서로 인한 학습/평가 좌표계 불일치.
5. objective별 value 정보가 없다 — 스칼라화 후 학습이므로 per-objective credit이 원천적으로 없음. **우리 additive objective GAE(objective별 critic 유지)와 정확히 대비되는 설계 지점.**

## 우리 연구와의 관계

isaac_humanoid의 objective-routing은 "agent(leg/arm) × objective(tracking/CAM/regularization)" 분해에서 **objective 축을 스칼라화하지 않고** per-objective(현재는 per-body) critic과 공유 discount로 additive GAE를 만든다. MOMAPPO는 같은 MOMARL 문제를 **바깥에서 스칼라화**(LinearizeReward + OLS weight 탐색)로 푼다. 즉:

- MOMAPPO(OLS) = scalarize-then-learn. **preference 축 multi-policy**: objective weight마다 별도 policy를 재학습해 policy 집합(CCS)을 만들고 utility는 사후 선택. (agent 축은 오히려 parameter-shared actor 1개.)
- 우리 = decompose-inside-learner. **preference 축 single-policy**: 한 run이 joint policy 하나를 내고 objective 구조를 학습 신호(credit)로 사용. (agent 축은 leg/arm decentralized actor 여러 개 — MARL 의미의 multi-policy는 우리 쪽이다.)

논문 서사에서 momaland는 (a) MOMARL 벤치마크 표준 인터페이스, (b) `LinearizeReward` 고정-가중치 baseline, (c) MOMAPPO(OLS) 비교군, (d) `momultiwalker_stability_v0` = 휴머노이드 외 generality 실험 후보로 쓸 수 있다. MASH([[AI-Sessions/wiki/research/papers/2025-liu-mash|2025-liu-mash]])식 limb-agent 관점과도 궤가 같다(walker 3대 ↔ limb agent).

## Torch 포팅 경로

### Path A — 환경을 우리 러너로 (권장, generality 실험용)

momaland parallel env를 rsl_rl 스타일 VecEnv로 감싸 우리 modular runner([[AI-Sessions/wiki/research/sources/rsl-rl-code|rsl-rl-code]], isaac_humanoid 포크)에 붙인다.

1. **벡터화**: Box2D 스텝은 저렴하므로 in-process 루프(64–256 env copies)로 시작. 필요 시 supersuit `pettingzoo_env_to_vec_env_v1 + concat_vec_envs_v1`(멀티프로세스)나 gymnasium `AsyncVectorEnv`(CentraliseAgent 위에).
2. **인터페이스 매핑**:
   - actor obs group: walker별 31차원(+ agent-id는 우리 러너가 agent축을 명시적으로 다루므로 불필요할 수 있음) ↔ leg/arm obs group 자리.
   - critic obs group: `env.state()` 75차원을 privileged obs로.
   - reward: **2-objective 벡터를 스칼라화하지 않고 그대로** additive objective GAE에 투입(shared gamma). obj0/obj1이 우리 bundle 구조의 최소 케이스.
   - done 분리: parallel API가 `terminations`/`truncations`를 따로 주므로 **MOMAPPO처럼 접지 말고** rsl_rl의 time-out bootstrap 경로에 연결한다.
3. **정규화**: supersuit `normalize_obs` 대신 러너의 EmpiricalNormalization. reward는 objective scale 30배 차이 때문에 per-objective 정규화 또는 가중치 보정 필수. 종료 페널티(-100/-110)가 스텝 reward 대비 거대해 value loss spike를 감안(클리핑/스케일링 검토).
4. **러너 쪽 손댈 가정들**: env 당 episode 길이 500, agent 수 3(우리 2-agent 가정 하드코딩 여부 확인), obs-group layout 선언, objective 수 = critic 수 설정, 로깅 키.
5. **규모 추정**: adapter+task config로 200–400줄. 128 envs × 500 steps → update당 64k step 배치가 CPU에서 분 단위. GPU는 update만 쓰게 된다(IsaacLab과 반대 병목).

### Path B — MOMAPPO를 torch로 (비교 baseline용)

전체 재구현보다 **B-lite**가 경제적이다: OLS(`morl_baselines...LinearSupport`)는 순수 numpy라 torch와 무관하게 재사용 가능. 우리 PPO(single scalar critic 모드) + LinearizeReward 등가 스칼라화 + LinearSupport outer loop만 조립하면 MOMAPPO(OLS)와 논문-비교 가능한 baseline이 된다.

완전 포팅 시 대응표:

| JAX 구성요소 | torch 등가물 |
| --- | --- |
| `distrax.MultivariateNormalDiag(mean, exp(log_std))` | `Independent(Normal(mean, log_std.exp()), 1)` |
| flax `TrainState` + optax chain | `nn.Module` + `clip_grad_norm_(0.5)` + `Adam(eps=1e-5)` |
| `orthogonal(√2)/orthogonal(0.01)/orthogonal(1.0)` init | `nn.init.orthogonal_` gain 동일 |
| `jax.lax.scan` GAE/epoch | 역방향 python 루프(우리 러너에 이미 존재) |
| orbax checkpoint | `torch.save` |

**Parity 함정** (숫자 재현이 목표라면):

1. advantage 정규화가 **minibatch 단위**(전체 batch 아님).
2. actor loss가 agent **합**(우리식 mean과 유효 lr이 n배 차이).
3. team reward가 shared_reward 하에서 n_agents× 스케일 — value 스케일에 반영.
4. `gae_lambda=0.99`, `vf_coef=0.8`, `ent_coef=0.0`, lr anneal 카운트 방식.
5. value clipping이 rollout 시점 old value 기준.
6. `NormalizeReward` running stat이 weight마다 리셋(래퍼가 train() 안에서 재생성).
7. OLS value가 stochastic 5-episode 평가라는 점(재현 시 seed 고정 필요; `eval_mo`는 내부 `PRNGKey(42)` 고정).

### 판단

지금 마일스톤(γ screen seed 43/44 confirmation) 이후, 논문 generality 섹션이 필요해지는 시점에 Path A를 먼저 — 우리 additive-GAE가 humanoid 밖 표준 MOMARL 벤치에서 도는 걸 보이는 게 목적이고, adapter 비용이 낮다. Path B-lite는 그 실험에 비교군이 필요할 때만.

## Links

- 우리 구현 digest: [[AI-Sessions/wiki/research/sources/isaac-humanoid-code|isaac-humanoid-code]]
- 러너 구조: [[AI-Sessions/wiki/research/sources/rsl-rl-code|rsl-rl-code]]
- category: [[AI-Sessions/wiki/research/categories/rl-algorithms-frameworks|rl-algorithms-frameworks]]
- 관련 논문 노트: [[AI-Sessions/wiki/research/papers/2025-liu-mash|2025-liu-mash]] (limb=agent MARL)
- MOMAland 논문(노트 미작성): Felten et al., "MOMAland: A Set of Benchmarks for Multi-Objective Multi-Agent Reinforcement Learning", arXiv:2407.16312
