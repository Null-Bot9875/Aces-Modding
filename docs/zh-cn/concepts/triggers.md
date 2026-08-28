# Trigger 配置参考

> Trigger 决定 `battle_skill_def` 中的 Skill 在什么时机被检查；`triggerEx` 进一步限制这一次检查。

## Trigger 的基本结构

`运输无人机`（Card `2023`）：自身被派出时，抽 1 张 Card。→

```text
Card 2023：运输无人机
└─ Skill 202301
   ├─ trigger = 123
   ├─ triggerEx.self = 1
   └─ effect = { 8022 }：抽 1 张 Card
```

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
effect = {
    8022,
},
```

`trigger = 123` 表示机体派出后检查这项 Skill。`triggerEx.self = 1` 只保留由 Skill 所在 Card 产生的派出事件。两个条件都满足后，Skill 才执行 `effect`。

`trigger` 与 Effect 的 `event` 不是同一组编号：`trigger` 决定 Skill 何时进入检查，`event` 决定 Effect 执行什么结算。

`trigger = 0` 不监听战斗事件。此类 Skill 由 Card 或其他配置通过 Skill ID 主动调用。

## `triggerEx`：筛选本次 Trigger

不需要附加限制时填写空表：

```lua
triggerEx = {},
```

`triggerEx` 不会产生新的 Trigger。多个字段同时填写时，需要同时满足。

并非所有字段都读取 Trigger 携带的信息：`condition` 检查 Skill 所在 Card，`roundMod` 检查当前回合，`nodeShowType` 检查当前 Node。具体 Trigger 没有提供所需信息时，不要填写依赖该信息的字段。

| 字段 | 填写形式 | 基本作用 | 适用 Trigger |
| --- | --- | --- | --- |
| `self` | `0` 或 `1` | 事件来源是否必须是 Skill 所在 Card | [106](#106核心装甲减少)、[107](#107受到-damage)、[109](#109effect-造成伤害)、[111](#111card-移动)、[115](#115使用-card)、[117](#117新增-static-skill)、[120](#120ep-减少)、[123](#123机体派出)、[124](#124攻击破坏机体)、[125](#125机体对核心装甲造成伤害)、[126](#126机体被破坏)、[127](#127机体咆哮)、[128](#128机体移动)、[129](#129机体完成攻击)、[130](#130增加叠层-card)、[131](#131card-获得静态-attr)、[132](#132回路数量增加)、[133](#133回路数量减少)、[135](#135机师进入战斗区域)、[136](#136card-移除静态-attr)、[138](#138有攻击力的机体完成攻击) |
| `src` | `1`、`2` 或 `3` | 限制事件来源玩家：`1` 为己方，`2` 为敌方，`3` 为双方；省略时只响应己方 | [所有自动 Trigger](#trigger-快速索引) |
| `srcTag` | Tag ID 列表 | 事件来源 Card 必须同时具有列表中的全部 Tag | 与 `self` 相同，且本次 Trigger 必须携带来源 Card |
| `srcCondition` | Battle Condition ID 列表 | 使用 [`battle_condition_def`](../config/battle_condition_def.md) 检查事件来源 Card | 与 `self` 相同，且本次 Trigger 必须携带来源 Card |
| `condition` | Battle Condition ID 列表 | 使用 [`battle_condition_def`](../config/battle_condition_def.md) 检查 Skill 所在 Card | 自动 Trigger；Skill 必须有所在 Card |
| `valueCondition` | Battle Condition ID 列表 | 检查 Trigger 携带的数值 | [106](#106核心装甲减少)、[107](#107受到-damage)、[109](#109effect-造成伤害)、[119](#119尝试造成-damage)、[120](#120ep-减少)、[125](#125机体对核心装甲造成伤害) |
| `moveSrc` | Area ID | 限制 Card 移动前所在的 Area | [111](#111card-移动) |
| `moveTarget` | Area ID | 限制 Card 移动后进入的 Area | [111](#111card-移动) |
| `roundMod` | 正整数 | 每隔指定数量的己方回合允许触发一次 | [所有自动 Trigger](#trigger-快速索引) |
| `roundModStart` | 正整数 | 与 `roundMod` 配合，指定周期中的首次触发位置 | [所有自动 Trigger](#trigger-快速索引) |
| `attr` | Attr 名称 | 限制本次增加或移除的 Attr | [131](#131card-获得静态-attr)、[136](#136card-移除静态-attr) |
| `nodeShowType` | `showType` 列表 | 只在当前 Node 的 `showType` 位于列表中时通过 | 自动 Trigger；案例见 [100](#100战斗开始) |
| `targetId` | Target ID | 使用 Trigger 携带的信息生成 Skill 目标 | 已确认案例见 [111](#111card-移动)、[123](#123机体派出)、[138](#138有攻击力的机体完成攻击) |
| `countReset` | `1` | 重置 `extend.triggerCount` 的触发计数 | 已确认案例见 [115](#115使用-card)、[123](#123机体派出)、[134](#134牌库重置) |

`targetId` 不是筛选条件。它使用本次 Trigger 提供的 Card、Grid、Player 或 Stack 信息，按 [`battle_target_def`](../config/battle_target_def.md) 生成 Skill 目标。

`countReset` 也不是筛选条件。它只与 `extend.triggerCount` 配合；是否能按回合重置，还取决于 Skill 的实际承载对象。

## Trigger 快速索引

表中的“通用”指 `src`、`condition`、`roundMod`、`roundModStart` 和 `nodeShowType`。这些字段不要求 Trigger 携带事件 Card，但 `condition` 仍要求 Skill 有所在 Card。

`1—7` 同时也是 RoundStage ID。玩家关注的回合阶段和配置用法见 [RoundStage 回合阶段说明](round-stages.md)。

| ID | 运行时名称 | 触发时机 | 支持的 `triggerEx` |
| --- | --- | --- | --- |
| [`0`](#0主动执行) | `Active` | 不监听战斗事件，由其他配置主动调用 | 无 |
| [`1`](#1重置步骤) | `RESET` | 己方回合的重置步骤 | 通用 |
| [`2`](#2维持步骤) | `MAINTAIN` | 己方回合的维持步骤 | 通用 |
| [`3`](#3抽牌步骤) | `NEWCARD` | 己方回合的抽牌步骤 | 通用 |
| [`4`](#4主要阶段-1) | `MAIN1` | 己方回合的主要阶段 1 | 通用 |
| [`5`](#5攻击阶段) | `ATTK` | 己方回合的攻击阶段 | 通用 |
| [`6`](#6终结阶段) | `FINISH` | 己方回合的终结阶段 | 通用 |
| [`7`](#7清除步骤) | `CLEANUP` | 己方回合的清除步骤 | 通用 |
| [`100`](#100战斗开始) | `GameStart` | 战斗开始 | 通用 |
| [`105`](#105核心装甲回复) | `HPAdd` | 核心装甲实际回复 | 通用 |
| [`106`](#106核心装甲减少) | `HPDec` | 核心装甲实际减少 | 通用、`self`、来源 Card、`valueCondition` |
| [`107`](#107受到-damage) | `Damage` | 目标完成一次 Damage 结算 | 通用、`self`、来源 Card、`valueCondition` |
| [`108`](#108抽到-card) | `NewCard` | 抽到一张 Card | 通用 |
| [`109`](#109effect-造成伤害) | `EffectDamage` | 一项 Effect 实际造成伤害 | 通用、`self`、来源 Card、`valueCondition` |
| [`111`](#111card-移动) | `CardMove` | Card 在 Area 之间移动 | 通用、`self`、来源 Card、`moveSrc`、`moveTarget`、`targetId` |
| [`112`](#112核心装甲被摧毁) | `Destroy` | 核心装甲被摧毁 | 通用 |
| [`115`](#115使用-card) | `UseCard` | 使用一张 Card | 通用、`self`、来源 Card、`countReset` |
| [`117`](#117新增-static-skill) | `NewStatic` | Card 获得 Static Skill | 通用、`self`、来源 Card |
| [`119`](#119尝试造成-damage) | `TryDamage` | 尝试造成 Damage | 通用、`valueCondition` |
| [`120`](#120ep-减少) | `PowerDec` | EP 实际减少 | 通用、`self`、来源 Card、`valueCondition` |
| [`123`](#123机体派出) | `DroneSet` | 机体进入 Drone 区并完成放置 | 通用、`self`、来源 Card、`targetId`、`countReset` |
| [`124`](#124攻击破坏机体) | `DroneDestory` | 机体通过战斗或 Effect 破坏另一台机体 | 通用、`self`、来源 Card |
| [`125`](#125机体对核心装甲造成伤害) | `DroneDamage` | 机体对核心装甲造成实际伤害 | 通用、`self`、来源 Card、`valueCondition` |
| [`126`](#126机体被破坏) | `DroneBeDestory` | 机体被破坏 | 通用、`self`、来源 Card |
| [`127`](#127机体咆哮) | `DroneRoar` | 机体完成派出后检查自身咆哮 Skill | 通用、`self`、来源 Card |
| [`128`](#128机体移动) | `DroneMove` | 机体在 Drone 区内完成换位 | 通用、`self`、来源 Card |
| [`129`](#129机体完成攻击) | `DroneAttk` | 机体完成一次攻击 | 通用、`self`、来源 Card |
| [`130`](#130增加叠层-card) | `StackcardAdd` | Card 增加一张叠层 Card | 通用、`self`、来源 Card |
| [`131`](#131card-获得静态-attr) | `StaticAttrAdd` | Card 获得静态 Attr | 通用、`self`、来源 Card、`attr` |
| [`132`](#132回路数量增加) | `DirCountAdd` | 机体回路数量增加 | 通用、`self`、来源 Card |
| [`133`](#133回路数量减少) | `DirCountDec` | 机体回路数量减少 | 通用、`self`、来源 Card |
| [`134`](#134牌库重置) | `PoolReset` | 牌库重置并实际补入 Card | 通用、`countReset` |
| [`135`](#135机师进入战斗区域) | `HeroCardAdd` | 机师进入一张 Card | 通用、`self`、来源 Card |
| [`136`](#136card-移除静态-attr) | `StaticAttrRemove` | Card 移除静态 Attr | 通用、`self`、来源 Card、`attr` |
| [`137`](#137替换机体攻击) | `DroneAttkReplace` | 机体攻击前检查替换攻击的 Skill | `condition`、`roundMod`、`roundModStart`、`nodeShowType` |
| [`138`](#138有攻击力的机体完成攻击) | `DroneAttkWithPower` | 攻击力大于 0 的机体完成攻击 | 通用、`self`、来源 Card、`targetId` |

## 各个 `trigger` 值

以下小节只列本次 Trigger 实际能提供的信息。`srcTag`、`srcCondition` 等字段的完整结构仍以本页前面的字段索引为准。

## `0`：主动执行

`Active` 不监听阶段或战斗事件。Card、Effect 或其他配置通过 Skill ID 主动调用这项 Skill。

`triggerEx` 不参与主动调用。没有附加配置时保持 `triggerEx = {}`。

## `1`：重置步骤

`RESET` 在己方回合进入重置步骤时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

`兵装-"巨塔"`（Card `10602`、Skill `1060201`）：回合开始时，若主将机体装甲不高于 20，则出鞘`振剑-"圣域"`。→

```lua
trigger = 1,
triggerEx = {
    condition = { 2230 },
},
```

`condition` 检查 Skill 所在 Card 的当前状态，不读取回合 Trigger 的事件来源。

`十字星`（Card `10757`、Skill `1075701`）：第三回合开始时进入“圣域模式”。→

```lua
trigger = 1,
triggerEx = {
    roundMod = 4,
    roundModStart = 4,
},
```

这组值把首次通过位置放在第三个己方回合开始，并按同一周期继续检查。

## `2`：维持步骤

`MAINTAIN` 在己方回合进入维持步骤时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

## `3`：抽牌步骤

`NEWCARD` 在己方回合进入抽牌步骤时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。它与抽到具体 Card 的 [`108`](#108抽到-card) 不是同一个 Trigger。

## `4`：主要阶段 1

`MAIN1` 在己方回合进入主要阶段 1 时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

## `5`：攻击阶段

`ATTK` 在己方回合进入攻击阶段时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。它不会提供本回合实际攻击的机体信息。

## `6`：终结阶段

`FINISH` 在己方回合进入终结阶段时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

## `7`：清除步骤

`CLEANUP` 在己方回合进入清除步骤时触发。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

## `100`：战斗开始

`GameStart` 在战斗建立完成后，为双方各触发一次。

本次 Trigger 不携带事件 Card 或数值。可以使用通用字段。

`枭首`（Chip `5104`、Skill `1510401`）：精英战开始时，对敌方主将造成 20 Damage。→

```lua
trigger = 100,
triggerEx = {
    nodeShowType = { 2, 3 },
},
```

`nodeShowType` 检查当前 Node 的 `showType`。它不是 `GameStart` 自身携带的信息。

## `105`：核心装甲回复

`HPAdd` 在核心装甲实际增加后触发。

本次 Trigger 不携带回复来源 Card 或回复数值。只能使用通用字段，不能用 `valueCondition` 筛选回复量。

## `106`：核心装甲减少

`HPDec` 在核心装甲实际减少后触发。

本次 Trigger 携带核心 Card 和装甲变化值。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `valueCondition`。

这里的来源 Card 是受到装甲减少的核心 Card，不是造成伤害的 Card。

## `107`：受到 Damage

`Damage` 在一次 Damage 通过护盾等前置拦截，并进入实际扣减流程后触发。被完全阻止的 `0` Damage 只会触发 [`119`](#119尝试造成-damage)。

本次 Trigger 携带受伤 Card 和本次 Damage 数值。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `valueCondition`。

这里的来源 Card 是受到 Damage 的 Card。要检查造成 Damage 的 Effect 来源，应使用 [`109`](#109effect-造成伤害)。

## `108`：抽到 Card

`NewCard` 每抽到一张 Card 时触发。

本次 Trigger 不携带抽到的 Card。只能使用通用字段，不能用 `self`、`srcTag` 或 `srcCondition` 筛选抽到哪张 Card。

## `109`：Effect 造成伤害

`EffectDamage` 在一项 Effect 实际造成非零伤害后触发。

本次 Trigger 携带 Effect 的来源 Card 和实际伤害值。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `valueCondition`。

## `111`：Card 移动

`CardMove` 在 Card 从一个 Area 移动到另一个 Area 时触发。复活等不算真实移动的特殊路径不会触发。

本次 Trigger 携带移动的 Card、移动前 Area 和移动后 Area。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition`、`moveSrc`、`moveTarget` 和 `targetId`。

Area ID 的完整定义见 [Area 配置参考](areas.md)。

`预警机“套娃”`（Card `7108`、Skill `710801`）：自身从 Drone 区离场时，在原 Grid 派出`预警结构`。→

```lua
trigger = 111,
triggerEx = {
    moveSrc = 14,
    self = 1,
    targetId = 103,
},
```

`moveSrc = 14` 要求 Card 从 Drone 区离开。`targetId = 103` 使用本次移动信息保留原 Grid，供 Skill 的 Effect 使用。

`紧急维修`（Card `7599`、Skill `759902`）：自身在废弃区时，其他非同名 Card 被废弃后返回手牌。→

```lua
trigger = 111,
triggerEx = {
    moveTarget = 4,
    srcCondition = { 2079 },
},
```

`moveTarget = 4` 要求 Card 移入废弃区；`srcCondition` 继续检查这张被移动的 Card。

## `112`：核心装甲被摧毁

`Destroy` 在核心装甲归零，或由摧毁玩家的 Effect 直接结算时触发。

本次 Trigger 不携带被摧毁的 Card 或伤害来源。只能使用通用字段。机体 Card 被破坏使用 [`126`](#126机体被破坏)。

## `115`：使用 Card

`UseCard` 在一张 Card 完成使用入口后触发。

本次 Trigger 携带被使用的 Card 和本次 EP 消耗。公开筛选字段可以读取来源 Card，因此可使用 `self`、`srcTag` 和 `srcCondition`；没有公开字段直接筛选 EP 消耗。

需要限制每回合触发次数时，可以同时填写 `extend.triggerCount` 和 `triggerEx.countReset = 1`。完整 Skill 示例见 [`battle_skill_def` 配置参考](../config/battle_skill_def.md#限制触发次数)。

## `117`：新增 Static Skill

`NewStatic` 在 Card 获得一项 Static Skill 时触发。

本次 Trigger 携带获得 Static Skill 的 Card 和 Static Skill ID。公开筛选字段可以读取来源 Card，因此可使用 `self`、`srcTag` 和 `srcCondition`；当前公开字段不直接筛选 Static Skill ID。

## `119`：尝试造成 Damage

`TryDamage` 在 Damage 结算开始时触发。即使护盾或其他规则使最终伤害为 `0`，仍可能触发。

本次 Trigger 携带尝试造成的 Damage 数值，但不携带来源 Card。除通用字段外，可以使用 `valueCondition`。

## `120`：EP 减少

`PowerDec` 在 Effect 使 EP 实际减少后触发。

本次 Trigger 携带 EP 变化值和 Effect 的来源 Card。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `valueCondition`。

## `123`：机体派出

`DroneSet` 在机体进入 Drone 区并完成放置后触发。

本次 Trigger 携带被派出的 Card 和所在 Grid。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition`、`targetId` 和 `countReset`。

`运输无人机`的 `self = 1` 基本用法见[本文开头](#trigger-的基本结构)。

`团结无人机`（Card `2031`、Skill `203101`）：其他无人机被派出时，自身获得 +1/+0。→

```lua
trigger = 123,
triggerEx = {
    self = 0,
    srcCondition = { 2016 },
},
```

`self = 0` 排除自身派出事件；`srcCondition` 检查被派出的 Card。

`追猎者-哨戒`（Card `10750`、Skill `1075002`）：敌方机体被派出时，对其造成 1 Damage。→

```lua
trigger = 123,
triggerEx = {
    src = 2,
    srcCondition = { 2016 },
    targetId = 103,
},
```

`src = 2` 只响应敌方事件。`targetId = 103` 使用本次派出信息，把新进入的机体作为 Skill 目标。

`伊米尔改-集约`（Card `10184`、Skill `1018402`）：派出机体时自身获得 +2/+0，每回合最多触发一次。→

```lua
trigger = 123,
triggerEx = {
    countReset = 1,
},
extend = {
    triggerCount = 1,
},
```

`triggerCount = 1` 限制当前计数周期内只触发一次；`countReset = 1` 在下一回合重置计数。

## `124`：攻击破坏机体

`DroneDestory` 在机体通过攻击或 Effect 破坏另一台机体时触发。

本次 Trigger 携带造成破坏的机体 Card。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

该 Trigger 不把被破坏的机体作为来源 Card。需要监听被破坏的机体时使用 [`126`](#126机体被破坏)。

## `125`：机体对核心装甲造成伤害

`DroneDamage` 在机体对核心装甲造成实际伤害后触发。

本次 Trigger 携带造成伤害的机体 Card 和装甲变化值。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `valueCondition`。

## `126`：机体被破坏

`DroneBeDestory` 在机体被破坏后触发，包括直接摧毁和伤害降至 `0` 的路径。

本次 Trigger 携带被破坏的机体 Card 和原 Grid。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

## `127`：机体战吼

`DroneRoar` 在机体通过 Stack 派出并完成放置后，检查这台机体自身的咆哮 Skill。

本次 Trigger 携带刚派出的机体 Card。可以使用 `self`、`srcTag`、`srcCondition`、`condition`、`roundMod`、`roundModStart` 和 `nodeShowType`。

## `128`：机体移动

`DroneMove` 在机体于 Drone 区内完成 Grid 换位，并刷新相关 Static Skill 后触发。

本次 Trigger 携带移动的机体 Card 和新 Grid。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

它与跨 Area 移动的 [`111`](#111card-移动) 不同，不提供 `moveSrc` 或 `moveTarget`。

## `129`：机体完成攻击

`DroneAttk` 在机体完成一次攻击后触发，不要求本次攻击实际造成伤害。

本次 Trigger 携带攻击机体 Card 和所在 Grid。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

## `130`：增加叠层 Card

`StackcardAdd` 在 Card 增加一张叠层 Card 后触发。

本次 Trigger 携带获得叠层的 Card 和新增叠层 Card 的配置 ID。公开筛选字段可以读取前者，因此可使用 `self`、`srcTag` 和 `srcCondition`。

## `131`：Card 获得静态 Attr

`StaticAttrAdd` 在战斗区域内的 Card 获得静态 Attr 后触发。

本次 Trigger 携带发生变化的 Card、所在 Grid 和 Attr 名称。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `attr`。

Attr 名称和作用见 [Attr 配置参考](attrs.md)。

`振剑-"提神"`（Card `10611`、Skill `1061101`）：主将机体获得“延缓”时，废弃自身，移除主将的“延缓”并使其获得 +5/+0。→

```lua
trigger = 131,
triggerEx = {
    attr = "attkDelay",
    srcTag = { 6 },
},
```

`attr = "attkDelay"` 只响应“延缓”Attr；`srcTag = { 6 }` 继续限制发生变化的 Card。

## `132`：回路数量增加

`DirCountAdd` 在机体回路数量刷新后，且新值大于旧值时触发。

本次 Trigger 携带回路数量增加的机体 Card。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

## `133`：回路数量减少

`DirCountDec` 在机体回路数量刷新后，且新值小于旧值时触发。

本次 Trigger 携带回路数量减少的机体 Card。除通用字段外，可以使用 `self`、`srcTag` 和 `srcCondition`。

## `134`：牌库重置

`PoolReset` 在牌库重置并实际补入至少一张 Card 后触发。空重置不会触发。

本次 Trigger 只携带牌库所属玩家，不携带 Card。可以使用通用字段；不能使用 `self`、`srcTag` 或 `srcCondition`。

配合 `extend.triggerCount` 限制每回合次数时，可以填写 `countReset = 1`。

## `135`：机师进入战斗区域

`HeroCardAdd` 在机师搭乘一张战斗区域内的 Card，并完成 Skill 与 Static Skill 添加后触发。

本次 Trigger 携带接收机师的 Card、所在 Grid 和机师 Card ID。公开筛选字段可以读取接收机师的 Card，因此可使用 `self`、`srcTag` 和 `srcCondition`。

`self = 1` 表示只响应机师进入 Skill 所在 Card，不是检查机师 Card 自身。

## `136`：Card 移除静态 Attr

`StaticAttrRemove` 在战斗区域内的 Card 移除静态 Attr 后触发。

本次 Trigger 携带发生变化的 Card、所在 Grid 和 Attr 名称。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `attr`。

## `137`：替换机体攻击

`DroneAttkReplace` 在机体开始普通攻击前，检查这台机体自身是否有替换攻击的 Skill。匹配后执行替换 Skill，不再使用普通攻击流程。

本次 Trigger 不携带事件 Card 或数值。它只检查当前攻击机体自身的 Skill，可以使用 `condition`、`roundMod`、`roundModStart` 和 `nodeShowType`。

`self`、`srcTag`、`srcCondition`、`valueCondition` 在这个入口没有所需信息，不要填写。

## `138`：有攻击力的机体完成攻击

`DroneAttkWithPower` 在攻击力大于 `0` 的机体完成攻击后触发。它在 [`129`](#129机体完成攻击) 之后检查。

本次 Trigger 携带攻击机体 Card 和所在 Grid。除通用字段外，可以使用 `self`、`srcTag`、`srcCondition` 和 `targetId`。

## Trigger 的配置位置

Skill 的触发入口位于 [`battle_skill_def.trigger`](../config/battle_skill_def.md#trigger决定-skill-如何进入执行)，筛选配置位于 `battle_skill_def.triggerEx`。

Static Skill 可以通过 [`static_skill_def.flag.removeTrigger.trigger`](../config/static_skill_def.md#按-trigger-自动移除flagremovetrigger) 监听 Trigger，并在 `static_skill_def.flag.removeTrigger.triggerEx` 中使用同一套筛选规则。

`battle_effect_def.extend.trigger` 只用于 `event = 120` 的 Effect。它负责指定要执行的 Trigger Skill，不是另一套 Trigger 定义，具体用法见 [`event = 120`：触发 Skill](../config/battle_effect_def.md#event-120触发-skillskilltrigger)。
