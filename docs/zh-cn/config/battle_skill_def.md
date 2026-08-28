# `battle_skill_def` 配置参考

> `battle_skill_def` 定义 Skill 在什么时候执行，以及执行哪些 Effect。

``trigger = 0` 的 Skill 由 Card 或其他配置主动调用；
`trigger != 0` 的 Skill 监听战斗中的 Trigger，满足筛选条件后执行。

两条路径最终都会按顺序执行 `effect` 中的 Effect ID。

## `battle_skill_def` 的基本结构

`原型组件`（Card `2039`）：派出时，将 1 张[原型无人机]加入手牌。→

```lua
{
    skillId = 203901,
    name = "原型组件",
    tag = "无人机",
    desc = "派出时，将1张[原型无人机]加入你的手牌。",
    effect = { 1527 },
    tagMap = {
        [4] = 1,
    },
    trigger = 123,
    triggerEx = {
        self = 1,
    },
    stack = 1,
    srcCardId = 2039,
    visibility = 1,
}
```

Card、Skill 与 Effect 的引用关系如下：

```text
Card 2039：原型组件
  └─ skillList = { 203901 }
       └─ Skill 203901：原型组件
            ├─ trigger = 123：机体被派出时检查
            ├─ triggerEx.self = 1：只响应自身被派出
            ├─ stack = 1：触发时进入堆叠
            └─ effect = { 1527 }
                 └─ Effect 1527：将 Card 2041 加入手牌
```

这行 Skill 先用 `trigger` 和 `triggerEx` 判断是否执行，再由 `stack` 决定触发时是否进入堆叠，最后执行 Effect `1527`。

`skillId` 是供 Card 和其他配置引用的唯一 ID。`name`、`tag`、`desc` 是 Skill 的名称、文字分类和说明。`effect` 是 Effect ID 列表。

新增 Skill 时必须填写 `skillId`、`name`、`effect` 和 `trigger`。其他字段没有使用时可以省略，由 适配器补默认值。

## `trigger`：决定 Skill 如何进入执行

`trigger` 为 `0` 时，Skill 不监听战斗事件。填写其他 Trigger ID 时，Skill 会等待对应事件发生。

完整 Trigger ID、时机和 `triggerEx` 字段见 [Trigger 配置参考](../concepts/triggers.md)。`trigger` 与 Effect 的 `event` 不是同一组编号。

### `trigger = 0`：主动执行

主动 Skill 由 Card 或其他配置通过 Skill ID 调用。调用方负责决定目标，Skill 被调用后执行 `effect`。

`晋升指令`（Card `2016`）：目标己方无人机获得 +2/+2，进行一次攻击。→

```lua
{
    skillId = 201601,
    name = "晋升指令",
    tag = "指令",
    desc = "目标己方无人机获得+2/+2，进行一次攻击。",
    effect = { 1511, 1512 },
    useConditions = { 0 },
    trigger = 0,
}
```

Card `2016` 通过 `skillList` 调用 Skill `201601`。Skill 不等待 Trigger，直接依次执行 Effect `1511` 和 `1512`。

`useConditions` 是 Battle Condition ID 列表，在主动使用 Skill 时检查。默认值 `{ 0 }` 表示不增加 Condition。Condition 的字段和写法见 [`battle_condition_def` 配置参考](battle_condition_def.md)。

`costEffect` 是启动费用对应的单个 Effect ID，类型为 `int`，默认值为 `0`。`extraCost` 是额外费用对应的 Effect ID 列表，类型为 `list[int]`，默认值为 `{}`。

当前 Core Skill 没有 `costEffect`、`extraCost` 的非默认案例。本页只保留字段形态和默认行为，不提供推测写法。

### `trigger != 0`：监听 Trigger

`trigger` 决定监听哪个战斗时机。`triggerEx` 只筛选已经发生的 Trigger，不会创建新的触发时机。

#### `triggerEx.self`：只响应自身

`原型组件`（Card `2039`）：只有自身被派出时，才将 1 张[原型无人机]加入手牌。→

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
```

`self = 1` 要求事件来源是拥有这项 Skill 的 Card。省略该筛选时，同类己方事件也可能进入检查。

#### `triggerEx.srcTag`：筛选事件来源的 Tag

`废热回收模组`（Card `11020`）：当你使用一张战术 Card 时，此机体获得 +0/+1。→

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

`trigger = 115` 监听 Card 使用事件。`srcTag = { 3 }` 只保留来源 Card 带有战术 Tag 的事件。

#### `triggerEx.condition`：检查 Skill 所在 Card

`ACE-001 白矮星`（Card `6201`）：回路达到 3 且使用战术 Card 时，下一张无人机 Card 费用减少 1，直到回合结束。→

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

`condition = { 2025 }` 检查 Skill 所在 Card 是否满足对应 Battle Condition；
`srcTag = { 3 }` 同时要求事件来源是战术 Card。

其他来源阵营、Target、Area、Attr 和筛选字段见 [Trigger 配置参考](../concepts/triggers.md)。

#### 限制触发次数

`extend.triggerCount` 限制一项 Skill 可以触发的次数。需要每回合重新计数时，同时填写 `triggerEx.countReset = 1`。

`成长机4`（Card `2703`）：此机体在场时，每回合第一次使用战术、无人机、机师或僚机 Card 时，分别获得 +3 攻击力。→

Card 通过 `skillList` 引用四项 Skill：

```lua
skillList = { 270301, 270302, 270303, 270304 },
```

四项 Skill 使用相同的 Effect 和次数限制，只用 `srcTag` 区分 Card 类型：

| Skill | `srcTag` | 筛选的 Card |
| --- | --- | --- |
| `270301` | `{ 3 }` | 战术 |
| `270302` | `{ 4 }` | 无人机 |
| `270303` | `{ 8 }` | 机师 |
| `270304` | `{ 7 }` | 僚机 |

其中 Skill `270301` 的完整触发配置如下：

```lua
{
    skillId = 270301,
    effect = { 4442 },
    trigger = 115,
    triggerEx = {
        srcTag = { 3 },
        countReset = 1,
    },
    stack = 1,
    extend = {
        triggerCount = 1,
    },
}
```

`triggerCount = 1` 让这项 Skill 每个计数周期最多触发 1 次，`countReset = 1` 在下一回合重置计数。四个 Skill 各自计数，因此四类 Card 分别拥有一次触发机会。

#### `stack`：触发时是否进入堆叠

`stack` 只说明触发 Skill 的结算方式：

- `stack = 1`：触发时进入堆叠，也是默认值。
- `stack = 0`：触发时不进入堆叠。

`扩容引擎`（Card `1001`）：你的回合开始时，回复全部能量。→

```lua
{
    skillId = 100101,
    effect = { 9002, 9003 },
    trigger = 1,
    triggerEx = {},
    stack = 0,
}
```

Skill `100101` 由“回合开始”Trigger 触发，但使用 `stack = 0`，因此触发时不进入堆叠。

`原型组件`（Card `2039`）：自身被派出时进入堆叠，再执行 Effect `1527`。→

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
stack = 1,
```

不要使用主动 Skill 的 `stack` 值推断其调用流程；`trigger = 0` 的执行入口由调用方决定。

## `effect`：执行哪些 Effect

`effect` 是 `list[int]`，填写 [`battle_effect_def.effectId`](battle_effect_def.md)。Skill 按列表顺序执行这些 Effect。

Effect 的 `event`、`targetId`、`value`、`extend` 和完整用法由 [`battle_effect_def` 配置参考](battle_effect_def.md)说明，本页只解释 Skill 中的引用和顺序。

### 单个 Effect

`原型组件`（Card `2039`）：执行 Effect `1527`，将 Card `2041` 加入手牌。→

```lua
effect = { 1527 },
```

### 多个 Effect

`破限齐射`（Card `7547`）：摧毁一台己方无人机，对所有敌方机体造成该无人机攻击力的伤害。→

```lua
{
    skillId = 754701,
    effect = { 4089, 3014, 4090 },
    trigger = 0,
    playResultType = 1,
}
```

三个 Effect 必须按当前顺序执行：

1. Effect `4089` 记录目标无人机的攻击力。
2. Effect `3014` 摧毁目标无人机。
3. Effect `4090` 读取 Effect `4089` 的结果，对所有敌方机体造成伤害。

交换顺序后，后一项可能无法读取结算所需的前序结果。

### 特殊用法：Skill 自身的 `playResultType`

普通 Skill 不需要填写 `playResultType`，默认值为 `0`。结算和客户端表现通常由各个 Effect 自己负责。

Skill `754701` 使用 `playResultType = 1`，表示这项 Skill 自身承担攻击表现。只有 Skill 需要在 Effect 之外指定整项结算的特殊表现时，才填写该字段。

Effect 自身的表现字段和规则见 [`battle_effect_def` 配置参考](battle_effect_def.md)，本页不重复展开。

## Skill 的说明、分类与显示

`name`、`tag`、`desc` 都是 `string`。`name` 是 Skill 名称，`tag` 是文字分类，`desc` 是说明文本。是否在战斗界面单独显示，另由 `visibility` 决定。

### `tagMap`

`tagMap` 的类型是 `dict[int,int]`，用于 Skill 的结构化标签。

省略或填写空表时，Skill 使用所属 Card 的 `tagMap`。显式填写非空 `tagMap` 时，使用 Skill 自己的标签，不与 Card 的标签合并。

`原型组件`的 Skill 使用无人机 Tag：

```lua
tagMap = {
    [4] = 1,
},
```

### `icon`

`icon` 是 Skill 使用的战斗图标资源名，类型为 `string`，默认值为 `""`。空字符串表示不指定独立图标。

`猎户座-狂热`（Card `10532`）的 Skill `1053201` 使用图标资源 `"1"`：

```lua
icon = "1",
```

### `srcCardId`

`srcCardId` 是用于触发式 Skill 堆叠显示的来源 Card ID，类型为 `int`，默认值为 `0`。它只改变显示时采用的来源 Card，不是执行 Skill 的必要条件。

`原型组件`的 Skill 指向来源 Card `2039`：

```lua
srcCardId = 2039,
```

### `visibility`

`visibility` 是 Skill 的显示标记，类型为 `int`，默认值为 `0`。它只控制 Skill 是否在战斗 Skill 列表中单独显示，不影响 Trigger 和 Effect 结算。

- `visibility = 0`：不单独显示，例如 Card 已经完整写明的一次性结算。
- `visibility = 1`：单独显示，例如需要持续查看的机体 Skill。

`原型组件`使用 `visibility = 1`；主动执行的`晋升指令`使用 `visibility = 0`。

### `keywordList`

`keywordList` 的类型是 `list[dict[string,int]]`，默认值为 `{}`。当前 Core Skill 没有非空正式案例，本页不提供推测写法。

## 旧设计

`targetIds`（`list[int]`）已经废弃，不要在新 Skill 中使用。

## 在 MOD 中新增 `battle_skill_def`

配置文件放在：

```text
config/battle_skill_def/config/skills.lua
```

下面新增 Skill `990801`：拥有这项 Skill 的机体被派出时，进入堆叠并抽 1 张 Card。

```lua
return {
    installKey = "skillId",
    rows = {
        {
            skillId = 990801,
            name = "派出补给",
            tag = "无人机",
            desc = "派出时，抽1张牌。",
            effect = { 8022 },
            tagMap = {
                [4] = 1,
            },
            trigger = 123,
            triggerEx = {
                self = 1,
            },
            stack = 1,
            srcCardId = 9908,
            visibility = 1,
        },
    },
}
```

`installKey = "skillId"` 表示按 Skill ID 安装这些 row。Effect `8022` 是游戏已有的抽 1 张 Card 结算。

同一个 MOD 中的 Card `9908` 通过 `skillList` 引用新 Skill：

```lua
skillList = { 990801 },
```
