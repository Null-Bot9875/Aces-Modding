# Battle Condition 配置参考

Battle Condition 用来判断 Card、Enemy 行动、Target、静态异能或 Trigger 是否满足指定战斗条件。


## Battle Condition

### 基本结构

当前版本 Battle Condition `2310` 的含义是：目标机体至少搭乘 1 名 机师

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

阅读 Battle Condition 时，依次看四部分：

```text
检查哪一方：target=1，检查己方
检查什么值：type=11，使用 Value 判断
允许的范围：minValue=1，至少为 1
怎样取值：args.valueKey="heroCount"，读取目标机体上的 机师 数量
```

`id` 供其他配置引用。实际判断由 `target`、`type`、数值范围和 `args` 共同决定。

### 基本字段

| 字段 | 类型 | 是否填写 | 含义 |
| --- | --- | --- | --- |
| `id` | int | 必填 | Battle Condition 的唯一 ID |
| `target` | int | 必填 | 大部分时候为1 |
| `type` | int | 必填 | 选择判断方式，见下方快速索引 |
| `minValue` | int | 必填 | 包含边界的最小值；大多数类型用 `-1` 表示不限制 |
| `maxValue` | int | 必填 | 包含边界的最大值；大多数类型用 `-1` 表示不限制 |
| `args` | lua | 必填 | 当前类型需要的附加参数；没有参数时填写 `{}` |

大多数 Battle Condition 使用以下范围判断：

```text
实际值 >= minValue 且实际值 <= maxValue
```

`minValue=-1` 或 `maxValue=-1` 通常表示不限制对应一侧。`CardCost` 不使用这套通用规则，不能把 `maxValue=-1` 当作无上限。

### 使用位置与组合方式

```lua
-- Card
useConditions = { 990501 }

-- Enemy 行动 row
useConditions = { 990501 }

-- Target
conditionList = { 990501 }
conditionType = 1
```

| 使用位置 | 组合方式 |
| --- | --- |
| Card `useConditions` | 所有 ID 都满足时通过，即 AND；空表或首项为 `0` 时直接通过 |
| Enemy 行动 `useConditions` | 所有 ID 都满足时保留该行动；失败时从当前行动池候选中移除 |
| Target `conditionList` | `conditionType=1` 为 AND，`conditionType=2` 为 OR |
| 静态异能 `conditionList` | 检查每个候选目标；组合方式由 `flag.conditionType` 控制 |
| 静态异能 `conditionListSelf` | 检查异能来源；组合方式由 `flag.conditionTypeSelf` 控制 |

静态异能的完整调用方式见[静态异能配置](static_def.md#条件)。Trigger 的 `srcCondition`、`valueCondition` 和 `condition` 见[Trigger 配置参考](../concepts/triggers.md)。

Battle Condition 是否能工作，还取决于调用位置提供了什么目标。依赖当前目标 Card 的条件不适合作为 Enemy 行动池入口条件，因为行动检查通常没有玩家选中的运行时 Card UID。

## Battle Condition 类型

### `type` 快速索引

| `type` | 名称 | 检查内容 | 使用要求 |
| --- | --- | --- | --- |
| `1` | `Hp` | 目标 Card 或机体 HP | 根据调用位置提供目标 Card，或使用 `base=1` 检查机体 |
| `2` | `Power` | 当前能量或已消耗能量 | 不需要目标 Card |
| `5` | `HandCard` | 当前目标 Card 是否符合筛选 | 需要目标 Card |
| `8` | `Stack` | 当前 Stack 及其中 Card | 需要 Stack |
| `11` | `Value` | `valueKey` 指定的战斗值 | 是否需要目标 Card 取决于 `valueKey` |
| `12` | `CardCost` | 目标 Card 的费用 | 需要目标 Card 或 Stack，并填写明确上限 |

### `type=1`：`Hp`

检查目标 Card 的当前 HP。找不到目标 Card，或者填写 `args.base=1` 时，改为检查 `target` 指定一方的机体 HP。

| `args` | 作用 |
| --- | --- |
| 省略 | 检查目标 Card 的当前 HP |
| `base=1` | 检查 `target` 指定一方的机体 HP |
| `hpDiff=1` | 检查已经损失的 HP，即 `hpMax-hp` |

```lua
type = 1,
minValue = 1,
maxValue = 5,
args = {},
```

这段配置要求目标 Card 的当前 HP 在 1–5 之间，包含 1 和 5。

### `type=2`：`Power`

检查玩家当前能量。填写 `args.powerDiff=1` 时，改为检查已经消耗的能量。

```lua
type = 2,
minValue = 2,
maxValue = -1,
args = {},
```

这段配置要求对应玩家当前至少有 2 点能量。

### `type=5`：`HandCard`

检查当前目标 Card 是否符合 `args` 中的 Card 筛选条件。名称虽然是 `HandCard`，但实际判断依赖调用位置传入的目标 Card。

```lua
type = 5,
minValue = 1,
maxValue = -1,
args = {
    cardId = { 7617, 7618 },
},
```

该类型必须获得有效的运行时 Card UID。没有目标 Card 时，条件直接不通过。

### `type=8`：`Stack`

检查当前 Stack，并可继续筛选 Stack 中的 Card。

```lua
type = 8,
minValue = 1,
maxValue = -1,
args = {
    stack = { 1 },
    type = { 3 },
},
```

`args.stack` 筛选 Stack 类型，其余 Card 筛选参数作用于 Stack 中的 Card。该类型需要调用位置提供有效的 Stack ID。

### `type=11`：`Value`

根据 `args.valueKey` 选择一个战斗值，再使用 `minValue` 和 `maxValue` 判断范围。

```lua
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "heroCount",
},
```

可用的 `valueKey` 见下方专节。未列出的 key 会尝试读取目标 Card 的同名属性，使用前必须在同版本现有配置和游戏内验证中确认。

### `type=12`：`CardCost`

检查目标 Card 的费用。目标可以是运行时 Card UID，也可以是能够解析出 Card 的 Stack ID。

```lua
type = 12,
minValue = 0,
maxValue = 3,
args = {},
```

`CardCost` 直接比较上下限，`maxValue=-1` 不表示无上限。正常费用都会大于 `-1`，因此会导致条件不通过。使用该类型时必须填写明确的 `maxValue`。

## `args` 定义

`args` 是 Battle Condition 的附加参数表。`type` 决定运行时会读取哪些 key；没有被当前 `type` 或 `valueKey` 读取的 key 不会改变判断结果。

完整 row 始终填写 `args`。不需要附加参数时写成空表：

```lua
args = {},
```

### `type` 与 `args`

| `type` | 名称 | 必需参数 | 可选参数 | 示例 |
| --- | --- | --- | --- | --- |
| `1` | `Hp` | 无 | `base`、`hpDiff` | `args={base=1}` |
| `2` | `Power` | 无 | `powerDiff` | `args={powerDiff=1}` |
| `5` | `HandCard` | 无 | Card 筛选参数 | `args={cardTag={{4}}}` |
| `8` | `Stack` | 无 | `stack`、Card 筛选参数 | `args={stack={1}}` |
| `11` | `Value` | `valueKey` | 由 `valueKey` 决定 | `args={valueKey="hp"}` |
| `12` | `CardCost` | 无 | 无 | `args={}` |

### 基础参数

| 参数 | 示例 | 适用 `type` | 是否必需 | 含义 |
| --- | --- | --- | --- | --- |
| `base` | `base=1` | `1 Hp` | 否 | 改为检查 `target` 指定一方的机体 |
| `hpDiff` | `hpDiff=1` | `1 Hp` | 否 | 改为检查 `hpMax-hp`，即已损失 HP |
| `powerDiff` | `powerDiff=1` | `2 Power` | 否 | 改为检查 `powerMax-power`，即已消耗能量 |
| `stack` | `stack={1,2}` | `8 Stack` | 否 | 只允许列表中的 Stack 类型 |
| `valueKey` | `valueKey="hp"` | `11 Value` | 是 | 指定 `Value` 实际读取或计算哪个值 |

`base`、`hpDiff` 和 `powerDiff` 只判断参数是否存在，通常填写 `1`。不要填写 `0` 表示关闭；不使用时直接省略。

`stack` 可填写以下运行时 Stack 类型：

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

### Card 筛选参数

以下参数由 `HandCard`、`Stack`、`Value.cardCount` 和 `Value.droneCount` 复用。`Value.roundRecord` 只复用其中的 `cardTag`。

| 参数 | 示例 | 是否必需 | 含义 |
| --- | --- | --- | --- |
| `cardTag` | `cardTag={{6},{7}}` | 否 | 按 Tag 组合筛选；外层列表是 OR，内层列表是 AND |
| `cardId` | `cardId={1001,1002}` | 否 | Card ID 命中列表中的任意一个时通过 |
| `noTag` | `noTag={6,7}` | 否 | Card 具有任意一个指定 Tag 时排除 |
| `type` | `type={1,2}` | 否 | Card 类型命中列表中的任意一个时通过 |
| `noType` | `noType={1,2}` | 否 | Card 类型命中列表中的任意一个时排除 |

`cardTag={{6},{7}}` 表示具有 Tag `6` 或 Tag `7`。`cardTag={{6,7}}` 表示必须同时具有 Tag `6` 和 Tag `7`。

## `valueKey` 定义

`valueKey` 只用于 `type=11 Value`，填写在 `args.valueKey` 中。它先决定读取或计算什么值，再由 `minValue` 和 `maxValue` 判断是否通过。

```lua
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "heroCount",
},
```

| `valueKey` | 示例 | 读取或计算的值 | 附加 `args` | 需要运行时目标 Card |
| --- | --- | --- | --- | --- |
| `roundRecord` | `valueKey="roundRecord"` | `target` 指定玩家本回合打出的 Card 数量 | `cardTag` 可选 | 否 |
| `cardCount` | `valueKey="cardCount", area={2}` | 指定战斗区域内符合筛选的 Card 数量 | `area` 必需；Card 筛选参数可选 | 否 |
| `droneCount` | `valueKey="droneCount", cardTag={{4}}` | 玩家战场网格中符合筛选的 Card 数量 | Card 筛选参数、`gridPosition`、`gridCheck` 可选 | 仅 `gridCheck` 需要 |
| `attk` | `valueKey="attk"` | 目标 Card 的当前攻击 | 无 | 是 |
| `hp` | `valueKey="hp"` | 目标 Card 的当前 HP | 无 | 是 |
| `cost` | `valueKey="cost"` | 目标 Card 的当前费用 | 无 | 是 |
| `dirCount` | `valueKey="dirCount"` | 目标 Card 的回路或方向计数 | 无 | 是 |
| `gold` | `valueKey="gold"` | `target` 指定玩家的战斗内 Gold | 无 | 否 |
| `heroCount` | `valueKey="heroCount"` | 目标机体所在网格的机师数量 | 无 | 是 |
| 其他 Card 属性名 | `valueKey="<Attr 名称>"` | 目标 Card 的同名运行时属性 | 无 | 是 |

### `roundRecord`

`roundRecord` 统计 `target` 指定玩家在当前回合实际打出的 Card 数量。它只统计出牌操作，不统计抽牌、创建 Card 或其他行动。

```lua
args = {
    valueKey = "roundRecord",
    cardTag = { { 4 } },
}
```

填写 `cardTag` 后，只统计本回合实际打出并符合该 Tag 组合的 Card。省略 `cardTag` 时统计全部出牌。

### `cardCount`

`cardCount` 统计 `args.area` 指定战斗区域内的 Card 数量。`area` 必填，可以同时使用 Card 筛选参数。

```lua
args = {
    valueKey = "cardCount",
    area = { 2 },
    cardTag = { { 4 } },
}
```

Area ID 的含义见[战斗区域参考](../concepts/areas.md)。

### `droneCount`

`droneCount` 遍历玩家的战场网格并统计符合条件的 Card。这个名称不会自动限定无人机；需要只统计无人机时，必须增加 `cardTag`、`cardId` 或 `type` 筛选。

| 参数 | 示例 | 是否必需 | 含义 |
| --- | --- | --- | --- |
| `gridPosition` | `gridPosition={...}` | 否 | 只统计指定战场位置中的 Card |
| `gridCheck` | `gridCheck={colTarget=1}` | 否 | 根据当前目标 Card 所在网格检查相对位置 |

`gridCheck` 依赖调用位置提供有效的目标 Card。当前 Core 案例使用 `gridCheck={colTarget=1}` 检查目标所在攻击列；其他组合必须按同版本现有配置验证。位置筛选使用的参数名是 `gridPosition`。

### 目标 Card 数值

`attk`、`hp`、`cost`、`dirCount` 和 `heroCount` 都需要调用位置提供运行时 Card UID。缺少目标 Card 时，Battle Condition 直接不通过。

未命中上述固定名称的 `valueKey` 会尝试读取目标 Card 的同名运行时属性。只有在当前版本已有配置或实际游戏内验证确认该属性存在时才能使用。


## 新增完整 Battle Condition

文件位置：

```text
config/battle_condition_def/config/conditions.lua
```

最小配置示例：新增一个要求己方当前至少有 2 点能量的 Battle Condition。

```lua
return {
    installKey = "id",
    rows = {
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

这段配置新增 Battle Condition `990501`。其他配置通过 `{ 990501 }` 引用它。
