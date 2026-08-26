# 可复用的 Core 配置

本页不是 Core 配置全集，只列出第一版示例已经采用、引用关系已经核实的起始值。未列出的 Core ID 不代表不可读取，但不属于当前公开支持承诺。

## Card 起始组合

`card-pack` 的普通战术 Card 复用 Core Card `2012`“炮击”的行为组合：

```lua
type = { 2 }
tagMap = { [3] = 1, [31] = 1 }
targetIds = { 40 }
costEffect = 8012
skillList = { 201201 }
```

| 配置 | 已确认含义 | 当前边界 |
| --- | --- | --- |
| Card `2012` | Core“炮击”；提供上方整组行为参考 | `card-pack` 使用 `rare=1`，不是照搬 Core `2012` 的 `rare=3` |
| Skill `201201` | “炮击”；造成 2 点伤害 | 只确认与上方 Card 组合使用 |
| Target `40` | 攻击时任选一个敌方单位 | 其他 Target 尚未整理成公开目录 |
| Effect `8012` | 自身减少 1 能量 | 其他费用 Effect 尚未整理成公开目录 |
| `tagMap` 的 `3`、`31` | Core Card `2012` 使用的成对 Tag | Tag ID 的完整枚举尚未公开 |
| Card `2000` | “无人机派出” | 只作为 `card-pack` 测试奖励中的 Core 对照卡 |
| `baseId=501` | `ACE-001 白矮星` | 只确认用于示例卡池筛选 |
| Reward `10003` | `card-pack` 覆盖的测试奖励入口 | 这是测试存档方案，不是新增奖励 ID，也不应直接用于正式发布内容 |

这组值适合验证“从奖励获得一张可从手牌打出的普通战术 Card”。自定义 Skill、Target、费用 Effect、机体、无人机或设备 Card 不在第一版范围内。

## Enemy 起始组合

`complete-mod` 使用以下 Core 内容构成两回合 Enemy：

| 配置 | 已确认含义 | 示例中的使用方式 |
| --- | --- | --- |
| `baseId=7366` | “自成长核心”的 Core 基础数据 | 提供 Enemy 基础数值、外观和部分界面信息 |
| Card `21007` | “自我修复” | 第 1 回合行动，配合表现引用 `buff_1` |
| Card `21006` | “试探点射” | 第 2 回合行动，配合表现引用 `attack_1` |
| `assetId="buff_1"` | 已有行动表现引用 | 只与示例的 `21007` 组合确认 |
| `assetId="attack_1"` | 已有行动表现引用 | 只与示例的 `21006` 组合确认 |

Card 名称相似不表示适合 Enemy 使用。更换行动 Card 后，仍需逐张检查目标选择、效果结算和回合推进。

## Node 入口与现有引用

### 第一层普通战斗 Group：`1401`

EP `1061` 使用的全部 44 个 Group、命名规律、地图位置和当前用途见 [EP 1061 Node Group 目录](node-groups.md)。普通第一层战斗位置使用以下链路：

```text
EP 1061 地图位置 230021、230022、230031、230032
  -> refreshGroup 1401
  -> Core 第一层战斗候选池
```

自定义战斗 Node 可通过 `append` 加入 `1401`，从而保留 Core 候选。人工测试期间可以临时提高 `weight` 以便更快遇到目标 Node；权重选择不保证绝对出现，测试权重也不应直接作为正式内容的平衡值。

Group 配置遵循以下通用规则：

| 配置 | 规则 |
| --- | --- |
| `operation` 省略或为 `replace` | 整组 Core rows 被替换；使用普通路线 Group 时会删除该组原有内容 |
| `operation="append"` | 保留 Core rows 并加入 MOD rows；候选按权重选择，目标 Node 不保证出现 |
| `weight` | 同组候选的相对选择权重；只有一个候选时无需通过该值控制概率 |
| `limitBaseId={}` | 不增加机体限制；第一版示例保持空表 |
| `nodeLimit=1` | 限制同一 Node 的正常重复出现；所有候选都达到限制时存在运行时回退，不应视为绝对不重复保证 |

`1401` 是现有 Core Group，不是 MOD 保留号段。完整目录中的其他 Group 也可以作为地图入口，但一个 Group 可能被多个位置或多层复用，修改前必须检查全部使用位置。第一版不需要创建新的 Group。

### Node row 中已采用的 Core 引用

| 配置 | 已确认含义 | 当前边界 |
| --- | --- | --- |
| `battleReward={100001}` | 引用 `act_node_def.node_reward` 的奖励组 `100001` | 该奖励组再引用 `reward_def`；不是直接引用 `reward_def 100001` |
| Option `10051` | “开始战斗” | 作为 `optionRandom1` 的唯一候选 |
| `gridPoolList={200}` | Core 战斗网格池 `200` | 只确认示例保持值，不承诺任意 Grid Pool |
| `conditionGroup=99` | 无条件通过的 Core 占位条件组 | 只确认示例保持值，不提供自定义条件教学 |
| `skybox="Nebula_Coral_4K_3"` | 已存在的 Core 战斗背景引用 | 只确认示例保持值，不提供完整 Skybox 目录 |

## 查找更多 Core 配置

同版本 [`game-lua`](../../../game-lua/README.md) 压缩包提供后，可按配置文件名和 ID 查看完整 Core row。选择未列出的值时，需要同时满足：

1. 引用对象存在于相同游戏版本；
2. 上下游字段全部同步；
3. 不依赖未公开的自定义 Skill、Target、模型、动画、音频或地图结构；
4. 完成冷启动、实际进入内容、行为结算和停用恢复测试。

只通过配置查询或加载检查不等于完成游戏内验证。
