# `battle_condition_def` 配置参考

> `battle_condition_def` 定义一次战斗条件判断：检查指定一方或运行时目标，并判断结果是否落在允许范围内。

## `battle_condition_def` 的基本结构

`商人（机师支援）`（Card `21070`）：只让已搭乘机师的机体获得 +2/+2。→

```text
商人（机师支援）（Card 21070）
└─ staticList={2107052}：掮客
   ├─ conditionList={2310}：目标机体至少搭乘 1 名机师
   └─ effect：+2/+2
```

Condition `2310` 的完整配置是：

```lua
{
    id = 2310,
    target = 1,
    type = 11,
    minValue = 1,
    maxValue = -1,
    args = {
        valueKey = "heroCount",
    },
}
```

阅读一行 `battle_condition_def` 时，依次看四部分：

```text
检查哪一方：target=1，使用检查发起方
检查什么：type=11，读取 Value
允许什么范围：minValue=1、maxValue=-1，结果至少为 1
怎样取得结果：args.valueKey="heroCount"，统计目标机体搭乘的机师数量
```

| 字段 | 类型 | 作者规则 |
| --- | --- | --- |
| `id` | int | 必填；Condition 的唯一 ID，供其他配置引用 |
| `target` | int | 必填；`1` 使用检查发起方，`2` 使用对方 |
| `type` | int | 必填；决定检查对象和计算方式 |
| `minValue` | int | 必填；含义由当前 `type` 决定 |
| `maxValue` | int | 必填；含义由当前 `type` 决定 |
| `args` | lua | 必填；填写当前 `type` 使用的附加参数，没有参数时填写 `{}` |

`target` 决定从哪一方读取 Player、机体或战场数据，但不会自动提供运行时 Card UID 或 Stack ID。需要目标 Card 或 Stack 的类型，仍依赖引用位置传入对应目标。

`minValue` 和 `maxValue` 是否参与判断，以及 `-1` 的含义，都以具体 `type` 小节为准。

## `battle_condition_def` 如何生效

其他配置通过字段引用 `battle_condition_def.id`：

| 配置表 | 引用字段 |
| --- | --- |
| [`card_def`](card_def.md) | `useConditions` |
| [`robot_chain_def`](chains.md) | `actions[].useConditions` |
| [`battle_target_def`](battle_target_def.md) | `conditionList` |
| [`static_skill_def`](static_skill_def.md) | `conditionListSelf`、`conditionList` |

## 可用 `type`

先选择要检查的 `type`，再在同一小节确认 `target`、数值范围和 `args`。

| `type` | 名称 | 检查内容 |
| --- | --- | --- |
| [`1`](#type-1) | `Hp` | 目标 Card 或机体的 HP |
| [`2`](#type-2) | `Power` | 指定一方的当前能量 |
| [`5`](#type-5) | `HandCard` | 调用位置传入的目标 Card 是否符合筛选 |
| [`8`](#type-8) | `Stack` | 调用位置传入的 Stack 是否符合筛选 |
| [`11`](#type-11) | `Value` | `args.valueKey` 指定的战斗值 |

<a id="type-1"></a>

### `type = 1`：`Hp`

检查运行时目标 Card 的当前 HP。调用位置没有提供有效 Card 时，会改为检查 `target` 指定一方的机体 HP；填写 `args.base=1` 可以明确要求检查机体。

`minValue` 和 `maxValue` 是包含边界的 HP 范围。负数表示不限制对应一侧；公开配置统一使用 `-1`。

#### 检查目标 Card 的当前 HP

Condition `1016`：目标 Card 的当前 HP 在 1–5 之间。→

```lua
id = 1016,
target = 1,
type = 1,
minValue = 1,
maxValue = 5,
args = {},
```

这个写法依赖引用位置提供运行时 Card UID。没有有效目标 Card 时，会转而检查己方机体。

#### 检查机体 HP：`base`

Condition `2166`：己方机体当前 HP 在 1–50 之间。→

```lua
id = 2166,
target = 1,
type = 1,
minValue = 1,
maxValue = 50,
args = {
    base = 1,
},
```

`base` 只判断是否存在，通常填写 `1`。不使用时直接省略，不要用 `base=0` 表示关闭。

#### 检查已损失 HP：`hpDiff`

Condition `2116`：对方机体没有损失 HP，也就是处于满 HP。→

```lua
id = 2116,
target = 2,
type = 1,
minValue = -1,
maxValue = 0,
args = {
    hpDiff = 1,
},
```

`hpDiff` 把检查值改为 `hpMax-hp`。结果为 `0` 表示满 HP，结果越大表示已损失的 HP 越多。

<a id="type-2"></a>

### `type = 2`：`Power`

检查 `target` 指定一方的当前能量。`target=1` 检查发起方，`target=2` 检查对方；该类型不需要运行时 Card 或 Stack。

`minValue` 和 `maxValue` 是包含边界的能量范围。负数表示不限制对应一侧；公开配置统一使用 `-1`。当前公开写法不需要附加 `args`。

Condition `2134`：己方当前至少有 1 点能量。→

```lua
id = 2134,
target = 1,
type = 2,
minValue = 1,
maxValue = -1,
args = {},
```

<a id="type-5"></a>

### `type = 5`：`HandCard`

检查调用位置传入的目标 Card 是否符合 `args` 筛选。名称虽然是 `HandCard`，但运行时不会检查 Card 是否位于手牌；引用位置必须提供有效的运行时 Card UID。

`target` 不会代替运行时 Card UID。该类型不读取 `minValue` 和 `maxValue`；完整 row 仍需填写，示例沿用 Core 配置中的 `0` 和 `-1`。

当前公开的 Card 筛选参数如下：

| 参数 | 示例 | 含义 |
| --- | --- | --- |
| `cardTag` | `cardTag={{4}}` | 按 Tag 组合筛选 |
| `cardId` | `cardId={9201}` | Card 定义 ID 命中列表中的任意一个时通过 |
| `noTag` | `noTag={502}` | Card 具有任意一个指定 Tag 时不通过 |

#### 按 Tag 筛选：`cardTag`

Condition `501`：目标 Card 具有 Tag `4`。→

```lua
id = 501,
target = 1,
type = 5,
minValue = 0,
maxValue = -1,
args = {
    cardTag = { { 4 } },
},
```

`cardTag` 的外层列表是 OR，内层列表是 AND。Condition `2260` 使用 `cardTag={{6},{7}}`，表示目标具有 Tag `6` 或 Tag `7` 时通过。

```lua
id = 2260,
target = 1,
type = 5,
minValue = 0,
maxValue = 1,
args = {
    cardTag = { { 6 }, { 7 } },
},
```

同理，`cardTag={{6,7}}` 表示目标必须同时具有 Tag `6` 和 Tag `7`。

#### 按 Card ID 筛选：`cardId`

Condition `2001`：目标 Card 的定义 ID 是 `9201`。→

```lua
id = 2001,
target = 1,
type = 5,
minValue = 1,
maxValue = -1,
args = {
    cardId = { 9201 },
},
```

这里填写的是 `card_def.cardId`，不是运行时 Card UID。运行时 Card UID 由引用位置传入。

#### 排除 Tag：`noTag`

Condition `603`：目标 Card 不具有 Tag `502`。→

```lua
id = 603,
target = 1,
type = 5,
minValue = 1,
maxValue = -1,
args = {
    noTag = { 502 },
},
```

多个筛选参数同时填写时必须全部满足。Condition `2091` 同时要求目标具有 Tag `4`，并且不具有 Tag `6` 或 `7`。

<a id="type-8"></a>

### `type = 8`：`Stack`

检查调用位置传入的 Stack。该类型需要有效的 Stack ID；运行时 Card UID 不能代替 Stack ID。

`target=1` 用于己方 Stack。当前公开案例只使用 `target=1`。该类型不读取 `minValue` 和 `maxValue`；完整 row 仍需填写，示例沿用 Core 配置中的 `0` 和 `1`。

`args.stack` 是允许的 Stack 类型列表：

| 值 | 含义 |
| --- | --- |
| `1` | 命令 |
| `2` | 装备 |
| `3` | 启动 |
| `4` | 攻击 |
| `5` | 被动触发 |
| `6` | 无人机 |
| `8` | 道具 |
| `9` | 机师 |

Condition `2089`：当前 Stack 是命令 Stack。→

```lua
id = 2089,
target = 1,
type = 8,
minValue = 0,
maxValue = 1,
args = {
    stack = { 1 },
},
```

<a id="type-11"></a>

### `type = 11`：`Value`

`args.valueKey` 决定读取或计算哪个战斗值，再使用 `minValue` 和 `maxValue` 判断结果是否通过。

`minValue` 和 `maxValue` 都包含边界。`-1` 表示不限制对应一侧；其他负数不会按“不限制”处理。

| `valueKey` | 读取或计算的值 | 目标要求 |
| --- | --- | --- |
| [`roundRecord`](#valuekey-roundrecord) | 指定玩家本回合打出的 Card 数量 | 不需要目标 Card |
| [`cardCount`](#valuekey-cardcount) | 指定 Area 中符合筛选的 Card 数量 | 不需要目标 Card |
| [`droneCount`](#valuekey-dronecount) | 指定玩家战场网格中符合筛选的 Card 数量 | `gridCheck` 需要目标 Card |
| [`attk`](#valuekey-attk) | 目标 Card 的当前攻击 | 需要目标 Card |
| [`hp`](#valuekey-hp) | 目标 Card 的当前 HP | 需要目标 Card |
| [`cost`](#valuekey-cost) | 目标 Card 的当前费用 | 需要目标 Card |
| [`dirCount`](#valuekey-dircount) | 指向目标 Card 的回路数量 | 需要目标 Card |
| [`gold`](#valuekey-gold) | 指定玩家的当前战斗 Gold | 不需要目标 Card |
| [`heroCount`](#valuekey-herocount) | 目标机体搭乘的机师数量 | 需要目标 Card |
| [Card Attr 名称](#valuekey-card-attr) | 目标 Card 的同名 Attr 合计值 | 需要目标 Card |

<a id="valuekey-roundrecord"></a>

#### `roundRecord`

统计 `target` 指定玩家在当前回合实际打出的 Card 数量。它只统计出牌操作，不统计抽牌、创建 Card 或其他行动。

Condition `2090`：对方本回合已经打出至少 2 张 Card。→

```lua
id = 2090,
target = 2,
type = 11,
minValue = 2,
maxValue = -1,
args = {
    valueKey = "roundRecord",
},
```

`roundRecord` 可以使用 `cardTag`，只统计符合 Tag 组合的已打出 Card。Condition `2125` 使用 `cardTag={{4}}` 统计本回合打出的机体 Card。

```lua
id = 2125,
target = 1,
type = 11,
minValue = 2,
maxValue = -1,
args = {
    valueKey = "roundRecord",
    cardTag = { { 4 } },
},
```

<a id="valuekey-cardcount"></a>

#### `cardCount`

统计 `args.area` 指定战斗区域内符合筛选的 Card 数量。`area` 必填；Area ID 的含义见[战斗区域参考](../concepts/areas.md)。

Condition `2019`：己方牌库为空。→

```lua
id = 2019,
target = 1,
type = 11,
minValue = 0,
maxValue = 0,
args = {
    valueKey = "cardCount",
    area = { 1 },
},
```

`cardCount` 可以继续使用 `cardTag` 或 `cardId`。Condition `2077` 要求己方手牌中至少有 2 张带 Tag `430` 的 Card。

```lua
id = 2077,
target = 1,
type = 11,
minValue = 2,
maxValue = -1,
args = {
    valueKey = "cardCount",
    area = { 2 },
    cardTag = { { 430 } },
},
```

Condition `2224` 要求己方战场区域至少存在 1 张 Card `10540`。

```lua
id = 2224,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "cardCount",
    area = { 14 },
    cardId = { 10540 },
},
```

<a id="valuekey-dronecount"></a>

#### `droneCount`

遍历 `target` 指定玩家的战场网格，并统计符合筛选的 Card。名称虽然是 `droneCount`，但它不会自动限定无人机；需要按 `cardId`、`cardTag` 或 `noTag` 筛选具体对象。

Condition `2000`：己方战场网格中至少存在 1 张 Card `9201`。→

```lua
id = 2000,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "droneCount",
    cardId = { 9201 },
},
```

Condition `2083` 使用 `cardTag={{610}}`，要求己方战场网格中至少有 3 张带 Tag `610` 的 Card。

```lua
id = 2083,
target = 1,
type = 11,
minValue = 3,
maxValue = -1,
args = {
    valueKey = "droneCount",
    cardTag = { { 610 } },
},
```

Condition `2010` 使用 `noTag={6,7}`，要求己方战场网格中至少有 3 张不带 Tag `6` 或 `7` 的 Card。

```lua
id = 2010,
target = 1,
type = 11,
minValue = 3,
maxValue = -1,
args = {
    valueKey = "droneCount",
    noTag = { 6, 7 },
},
```

#### 按目标 Card 的位置筛选：`gridCheck`

`gridCheck` 根据调用位置传入的目标 Card 所在网格，继续筛选被统计的战场 Card。使用它时必须提供有效的运行时 Card UID。

Condition `2243`：目标 Card 所在列没有敌方机体。→

```lua
id = 2243,
target = 2,
type = 11,
minValue = 0,
maxValue = 0,
args = {
    valueKey = "droneCount",
    gridCheck = {
        colTarget = 1,
    },
},
```

<a id="valuekey-attk"></a>

#### `attk`

读取运行时目标 Card 的当前攻击。没有有效的运行时 Card UID 时，Condition 不通过。

Condition `505`：目标 Card 的当前攻击至少为 7。→

```lua
id = 505,
target = 1,
type = 11,
minValue = 7,
maxValue = -1,
args = {
    valueKey = "attk",
},
```

<a id="valuekey-hp"></a>

#### `hp`

读取运行时目标 Card 的当前 HP。没有有效的运行时 Card UID 时，Condition 不通过。

Condition `2107`：目标 Card 的当前 HP 不超过 1。→

```lua
id = 2107,
target = 1,
type = 11,
minValue = 0,
maxValue = 1,
args = {
    valueKey = "hp",
},
```

<a id="valuekey-cost"></a>

#### `cost`

读取运行时目标 Card 的当前费用。没有有效的运行时 Card UID 时，Condition 不通过。

Condition `2185`：目标 Card 的当前费用等于 1。→

```lua
id = 2185,
target = 1,
type = 11,
minValue = 1,
maxValue = 1,
args = {
    valueKey = "cost",
},
```

<a id="valuekey-dircount"></a>

#### `dirCount`

统计己方战场中指向运行时目标 Card 的回路数量。目标 Card 不在对应战场网格，或没有有效 Card UID 时，结果无法满足正数条件。

Condition `2024`：指向目标机体的回路数量至少为 2。→

```lua
id = 2024,
target = 1,
type = 11,
minValue = 2,
maxValue = -1,
args = {
    valueKey = "dirCount",
},
```

<a id="valuekey-gold"></a>

#### `gold`

读取 `target` 指定玩家在当前战斗中的 Gold。该值不需要运行时目标 Card。

Condition `2285`：己方当前战斗 Gold 至少为 200。→

```lua
id = 2285,
target = 1,
type = 11,
minValue = 200,
maxValue = -1,
args = {
    valueKey = "gold",
},
```

<a id="valuekey-herocount"></a>

#### `heroCount`

统计运行时目标机体当前搭乘的机师数量。目标 Card 不在战场网格，或没有有效的运行时 Card UID 时，Condition 不通过。

Condition `2310`：目标机体至少搭乘 1 名机师。→

```lua
id = 2310,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "heroCount",
},
```

<a id="valuekey-card-attr"></a>

#### 使用 Card Attr 名称作为 `valueKey`

未命中前述固定名称时，`Value` 会把 `valueKey` 当作 Card Attr 名称，读取目标 Card 上所有同名 Attr 的合计值。目标 Card 没有该 Attr 时，Condition 不通过。

Condition `2012`：目标 Card 的 `attkShield` 合计值至少为 1。→

```lua
id = 2012,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "attkShield",
},
```

当前 Core Condition 中已有的 Attr 名称包括 `attkBack`、`attkShield`、`attkTwice` 和 `attkDelay`。Attr 的来源和含义见 [Effect 属性参考](../concepts/attrs.md)。

## 旧设计

以下配置属于旧设计，请勿用于新 MOD：

| 配置 | 名称 |
| --- | --- |
| `type = 9` | `Token` |
| `type = 13` | `Gauge` |
| `Stack type = 7` | `Trap` |

## 在 MOD 中新增 `battle_condition_def`

配置文件放在：

```text
config/battle_condition_def/config/conditions.lua
```

每个文件返回一个批次，`installKey` 固定为 `id`：

```lua
return {
    installKey = "id",
    rows = {
        -- 己方当前至少有 2 点能量
        {
            id = 990501,
            target = 1,
            type = 2,
            minValue = 2,
            maxValue = -1,
            args = {},
        },
    },
}
```

这段配置新增 Condition `990501`。它可以写入上表列出的引用字段，例如 `card_def.useConditions`。
