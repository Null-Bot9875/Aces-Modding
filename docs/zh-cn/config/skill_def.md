# 触发式异能配置

> 触发式异能决定一组 Effect 在什么时候执行。

`battle_skill_def.config` 是触发式异能配置表。`trigger` 决定异能是否监听战斗中的
Trigger：

- `trigger=0`：不监听 Trigger，由 Card 或其他配置直接调用；
- `trigger!=0`：监听对应 Trigger，条件满足时自动执行。

## 触发式异能的基本结构

游戏内 Wiki Card `原型组件`（Card `2039`）的文本是：

> 派出时，将 1 张[原型无人机]加入手牌。←：+2/+0。

Card 引用异能 `203901`。以下只列出理解这次结算需要关注的字段：

```lua
{
    skillId = 203901,
    name = "原型组件",
    desc = "派出时，将1张[原型无人机]加入你的手牌。",
    effect = { 1527 },
    trigger = 123,
    triggerEx = {
        self = 1,
    },
}
```

这项异能可以拆成三个问题：

```text
什么时候执行：trigger=123，机体被派出时
响应哪次事件：triggerEx.self=1，只响应自身被派出
执行什么内容：effect={1527}，执行 Effect 1527
```

Effect `1527` 会将 1 张 Card `2041` 加入手牌。完整结算是：`原型组件`被派出时，
将 1 张`原型无人机`加入手牌。

## Card、触发式异能与 Effect

Card 通过 `skillList` 引用触发式异能。触发式异能决定执行时机，再按 `effect` 中的顺序
执行 Effect。

```text
Card 2039：原型组件
  └─ skillList = { 203901 }
       └─ 触发式异能 203901
            ├─ trigger = 123：机体被派出时检查
            ├─ triggerEx.self = 1：只响应自身
            └─ effect = { 1527 }
                 └─ Effect 1527：将 Card 2041 加入手牌
```

`trigger` 与 Effect 的 `event` 不是同一组编号：`trigger` 决定何时执行，`event` 决定
具体进行什么结算。

## 必填字段

新增触发式异能需要填写四个字段：

| 字段 | 类型 | 含义 | 示例 |
| --- | --- | --- | --- |
| `skillId` | int | 触发式异能的唯一 ID，供 Card 和其他配置引用 | `990801` |
| `name` | string | 异能名称 | `"派出补给"` |
| `effect` | list[int] | 按顺序执行的 Effect ID | `{ 8022 }` |
| `trigger` | int | Trigger ID；填写 `0` 时不监听 Trigger | `123` |

其他字段没有使用时可以省略。常用可选字段的默认值如下：

```lua
desc = ""
triggerEx = {}
tagMap = {}
targetIds = { 0 }
useConditions = { 0 }
stack = 1
extend = {}
visibility = 0
playResultType = 0
```

显式填写的值不会被默认值覆盖。

## 触发配置

### `trigger=0`：由其他配置直接调用

`trigger=0` 表示这项异能不监听战斗中的 Trigger。Card 或其他配置引用它时，会直接执行
`effect` 中的内容。

```lua
trigger = 0,
```

#### eg: `晋升指令`（Skill `201601`）

来源 Card（游戏内 Wiki）：`晋升指令`（Card `2016`）

Card 文本：目标己方无人机获得 +2/+2，进行一次攻击。

```lua
{
    skillId = 201601,
    effect = { 1511, 1512 },
    trigger = 0,
}
```

Card 通过 `skillList` 引用 Skill `201601`。打出 Card 时依次执行 Effect `1511`、`1512`，
不需要等待其他战斗事件。

### `trigger!=0`：监听 Trigger

填写 Trigger ID 后，异能会在对应战斗时机到来时进行检查。例如 `123` 表示机体被派出。

```lua
trigger = 123,
```

完整 Trigger 列表见 [Trigger 概念说明](../concepts/triggers.md)。

### `triggerEx`：筛选触发事件

`triggerEx` 决定同一种 Trigger 中，哪些事件可以触发这项异能。

```lua
triggerEx = {
    self = 1,
},
```

`self=1` 表示事件来源必须是拥有这项异能的 Card。配合 `trigger=123` 时，只有该 Card
自身被派出才会触发。

省略 `triggerEx` 时使用空表。以 `trigger=123` 为例，空表会响应符合该 Trigger 的己方
事件，不再限定为自身。

来源阵营、Tag、Condition、Area 和周期等筛选规则见 [Trigger 概念说明](../concepts/triggers.md)。

#### eg: `废热回收模组`（Skill `1102001`）

来源 Card（游戏内 Wiki）：`废热回收模组`（Card `11020`）

异能文本：当你释放一张战术时，此机体获得 +0/+1。

```lua
{
    skillId = 1102001,
    effect = { 9055 },
    trigger = 115,
    triggerEx = {
        srcTag = { 3 },
    },
}
```

`trigger=115` 监听 Card 的使用事件。`srcTag={3}` 只保留来源 Card 带有 Tag `3` 的事件，
因此释放战术牌时才会执行 Effect `9055`。

#### eg: `ACE-001 白矮星`（Skill `220102`）

来源 Card：`ACE-001 白矮星`（Card `6201`）

异能文本：回路 3：当你使用战术牌时，你的下一张无人机牌费用减少 1，直到回合结束。

```lua
{
    skillId = 220102,
    effect = { 4209 },
    trigger = 115,
    triggerEx = {
        condition = { 2025 },
        srcTag = { 3 },
    },
}
```

`srcTag={3}` 要求事件来源是战术牌，`condition={2025}` 要求回路达到 3。两个条件同时满足
时，才会执行 Effect `4209`。

### 限制触发次数

`extend.triggerCount` 限制异能的触发次数。需要每回合重新计数时，同时填写
`triggerEx.countReset=1`。

```lua
triggerEx = {
    self = 1,
    countReset = 1,
},
extend = {
    triggerCount = 1,
},
```

这段配置表示：每回合最多触发 1 次，下一回合重新计数。

#### eg: `废热投射算法`（Skill `402601`）

来源晶片（游戏内 Wiki）：`废热投射算法`（Chip `4026`）

晶片文本：一回合 3 次，当你释放战术牌时，对 1 个随机敌方机体造成 1 点伤害。

```lua
{
    skillId = 402601,
    effect = { 4553 },
    trigger = 115,
    triggerEx = {
        srcTag = { 3 },
        countReset = 1,
    },
    extend = {
        triggerCount = 3,
    },
    stack = 0,
}
```

`triggerCount=3` 把每个计数周期的触发上限设为 3，`countReset=1` 在下一回合重置计数。
该游戏已有配置使用 `stack=0` 立即结算；普通触发式异能仍使用默认值 `stack=1`。

## Effect 执行顺序

`effect` 按列表顺序执行。每个 Effect 使用自己的 `targetId`、`event`、`value` 和
`extend`。

```lua
effect = { 4089, 3014, 4090 },
```

这段配置会依次执行 Effect `4089`、`3014` 和 `4090`。后一项需要读取前一项结果时，
顺序不能交换。Effect 的字段、事件和前序结果读取规则见 [Effect 配置参考](battle_effect_def.md)。

## 结算方式：`stack`

`stack` 决定异能是否进入战斗结算堆叠：

- `stack=1`：进入战斗结算堆叠，也是默认值；
- `stack=0`：立即结算，只用于明确需要跳过堆叠的特殊异能。

普通触发式异能不需要填写 `stack`。

## 异能说明：`visibility`

`visibility` 只控制是否单独展示异能说明，不影响异能能否触发：

- Card 已经完整写明一次性结算内容，不需要再展示一条异能说明：使用 `0`，也是默认值；
- 无人机、机体上持续存在，玩家需要随时查看的异能：使用 `1`。

使用 `visibility=1` 时，在 `desc` 中填写需要展示的异能说明：

```lua
desc = "回合开始时，抽 1 张牌。",
visibility = 1,
```

## 异能分类：`tagMap`

普通触发式异能可以省略 `tagMap`，按所属 Card 的 `tagMap` 参与异能分类。

只有异能需要使用不同于所属 Card 的分类时，才显式填写 `tagMap`。显式配置会完整覆盖
Card 的分类，不会与 Card 的 `tagMap` 合并。

```lua
tagMap = {
    [4] = 1,
},
```

## 新增触发式异能

文件位置：

```text
config/battle_skill_def/config/skills.lua
```

下面新增异能 `990801`：拥有这项异能的机体被派出时，抽 1 张牌。

```lua
return {
    installKey = "skillId",
    rows = {
        {
            skillId = 990801,
            name = "派出补给",
            effect = { 8022 },
            trigger = 123,
            triggerEx = {
                self = 1,
            },
        },
    },
}
```

Effect `8022` 的结算是抽 1 张牌。Card 通过 `skillList` 引用该异能：

```lua
skillList = { 990801 },
```

该 Card 必须能够进入 Drone 区，否则不会产生 `trigger=123` 对应的触发时机。
