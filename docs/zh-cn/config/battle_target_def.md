# `battle_target_def` 配置参考

> `battle_target_def` 定义一次目标选择：先确定候选阵营和区域，再应用选择规则与条件，最后确定结果数量。

## `battle_target_def` 的基本结构

`连续射击α`（Card `2061`）：选择一个敌方单位并造成 2 点伤害。→

```lua
{
    id = 40,
    actor = 1,
    target = 2,
    area = { 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

这条 Target 的选择过程是：

```text
target=2
  从敌方阵营寻找候选
    └─ area={14}
       只查看战场机体
         └─ flag={}、conditionList={0}
            不增加额外筛选
              └─ minValue=1、maxValue=1
                 最终选择 1 个目标
```

它在 Card、Skill 和 Effect 中的引用关系如下：

```text
连续射击α（Card 2061）
├─ targetIds={40} → 使用 Card 时选择 Target 40
└─ Skill 206101
   └─ Effect 8026
      └─ targetId=40 → 对 Target 40 选中的单位造成伤害
```

Card 的 `targetIds` 负责在使用 Card 时收集目标，选择结果会连同 Target ID 保存。
Effect 的 `targetId` 负责在结算时指定要读取哪一组目标，因此不要因为 Card 已配置 `targetIds` 就省略 Effect 的 `targetId`。

当 Card 和 Effect 引用同一个 Target ID 时，Effect 直接复用 Card 阶段保存的选择结果，不会要求玩家再次选择。
上面的 Card `2061` 和 Effect `8026` 都引用 Target `40`，因此伤害会作用于出牌时选中的单位。

如果 Effect 引用的 Target ID 没有对应的已保存结果，结算时会单独计算该 Target。能够自动确定目标时直接继续；
仍需要玩家决定时，才会在 Effect 结算阶段再次发起选择（旧的结算流程，通常不走到这里）。

`battle_target_def` 导出的字段如下：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | int | Target 唯一 ID，也是其他配置引用的值 |
| `actor` | int | 发起方；当前配置填写 `1` |
| `target` | int | 候选对象所属阵营 |
| `area` | int[] | 候选对象所在区域 |
| `flag` | table | 选择或筛选候选对象的规则 |
| `conditionList` | int[] | 候选对象还要满足的 Condition ID |
| `conditionType` | int | `conditionList` 的组合方式 |
| `minValue` | int | 结果数量下限 |
| `maxValue` | int | 结果数量上限 |

`id` 可以被以下字段引用：

- `card_def.config.targetIds`
- `battle_skill_def.config.targetIds`
- `battle_effect_def.config.targetId`

Card 和 Skill 使用 Target ID 列表；Effect 使用单个 Target ID。它们既可以引用游戏已有的 Target，也可以引用同一个 MOD 新增的 Target。

## 确定候选对象

### `target`：候选阵营

`target` 以来源 Card 或 Skill 的所属阵营为参照，决定从哪一方寻找候选。

| 值 | 含义 |
| --- | --- |
| `1` | 己方 |
| `2` | 敌方 |
| `3` | 双方 |

Target `104`：从己方战场机体中选择 1 个无人机。→

```lua
{
    id = 104,
    target = 1,
    area = { 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

Target `40`：从敌方战场机体中选择 1 个单位。→

```lua
{
    id = 40,
    target = 2,
    area = { 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

Target `629`：选择双方战场上的全部机体。→

```lua
{
    id = 629,
    target = 3,
    area = { 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = -1,
    maxValue = -1,
}
```

`target=3` 只表示候选来自双方。是否保留来源自身，仍由 `flag.self` 等规则决定。

### `area`：候选区域

`area` 填写 Area ID 列表，决定从哪些战斗区域寻找候选对象。完整区域表以及它与 `CardArea.value` 的区别见[战斗区域参考](../concepts/areas.md)。

Target `40` 使用单个区域 `area={14}`，只从战场机体中寻找候选：

```lua
{
    id = 40,
    target = 2,
    area = { 14 },
    minValue = 1,
    maxValue = 1,
}
```

Target `114` 组合 `Player` 和战场机体两个区域，选择己方这两个区域中的全部对象：

```lua
{
    id = 114,
    target = 1,
    area = { 8, 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = 1,
    maxValue = -1,
}
```

`area` 只决定在哪里寻找候选。候选是否还要满足身份、位置关系或数量规则，由后续字段决定。

## `flag`：选择与筛选规则

`flag` 是一组与 `target`、`area` 和具体选择过程共同生效的参数。复制某个 `flag` 时，要同时核对例子中的阵营、区域、Condition 和数量字段。

快速索引：[`self`](#self) · [`selfPlayer`](#selfplayer) · [`hero`](#hero) · [`selfRound`](#selfround) · [`side`](#side)<br>
[`colNext`](#colnext) · [`sameRow`](#samerow) · [`colTarget`](#coltarget) · [`rowOne`](#rowone) · [`colOne`](#colone)<br>
[`seq`](#seq) · [`randNum`](#randnum) · [`sort`](#sort) · [`sortType`](#sorttype) · [`attkTarget`](#attktarget)

### `self`

`self` 判断候选是否为来源自身。

`self=1` 只保留来源自身。Target `103` 选择来源无人机自身：

```lua
{
    id = 103,
    target = 1,
    area = { 14 },
    flag = { self = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

`self=0` 排除来源自身。Target `134` 从双方战场机体中保留来源以外的全部对象：

```lua
{
    id = 134,
    target = 3,
    area = { 14 },
    flag = { self = 0 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = -1,
}
```

### `selfPlayer`

`selfPlayer=1` 选择来源所属阵营的 Player。它通常与 `target=1`、`area={8}` 一起使用。

Target `100` 选择己方 Player：

```lua
{
    id = 100,
    target = 1,
    area = { 8 },
    flag = { selfPlayer = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

### `hero`

`hero` 根据机体是否搭乘机师筛选候选。`hero=1` 只保留已搭乘机师的机体。

Target `1225` 选择己方所有已搭乘机师的机体：

```lua
{
    id = 1225,
    target = 1,
    area = { 14 },
    flag = { hero = 1 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = -1,
}
```

### `selfRound`

`selfRound` 根据机体当前是否处于自身回合筛选候选。`selfRound=1` 只保留当前处于自身回合的机体。

Target `940` 从双方候选中选择处于自身回合的普通无人机。Condition `2016` 也是这个结果的一部分：

```lua
{
    id = 940,
    target = 3,
    area = { 14 },
    flag = { selfRound = 1 },
    conditionList = { 2016 },
    conditionType = 1,
    minValue = -1,
    maxValue = -1,
}
```

### `side`

`side` 按来源与候选的相邻关系筛选单位。`side=1` 选择与来源横向或纵向相邻的单位。

Target `123` 选择与来源相邻的己方无人机：

```lua
{
    id = 123,
    target = 1,
    area = { 14 },
    flag = { side = 1 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = -1,
}
```

### `colNext`

`colNext` 按来源所在列筛选后方单位。`colNext=1` 选择来源同列后方的单位。

Target `127` 最多选择一台位于来源后方的己方无人机：

```lua
{
    id = 127,
    target = 1,
    area = { 14 },
    flag = { colNext = 1 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = 1,
}
```

### `sameRow`

`sameRow=1` 只保留与来源处于同一排的候选。

Target `405` 选择己方与来源同排的全部战场机体：

```lua
{
    id = 405,
    target = 1,
    area = { 14 },
    flag = { sameRow = 1 },
    conditionList = { 0 },
    minValue = -1,
    maxValue = -1,
}
```

### `colTarget`

`colTarget` 按来源所在列筛选对方单位。`colTarget=1` 选择对方与来源同列的单位。

Target `113` 选择与来源同列的全部敌方无人机：

```lua
{
    id = 113,
    target = 2,
    area = { 14 },
    flag = { colTarget = 1 },
    conditionList = { 0 },
    minValue = -1,
    maxValue = -1,
}
```

### `rowOne`

`rowOne` 约束一次多选结果的排。`rowOne=1` 让一次多选结果来自同一排。

Target `102` 选择一排敌方无人机，最多选择 3 台：

```lua
{
    id = 102,
    target = 2,
    area = { 14 },
    flag = { rowOne = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 3,
}
```

### `colOne`

`colOne` 约束一次多选结果的列。`colOne=1` 让一次多选结果来自同一列。

Target `503` 选择一列敌方无人机，最多选择 3 台：

```lua
{
    id = 503,
    target = 2,
    area = { 14 },
    flag = { colOne = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 3,
}
```

### `seq`

`seq` 按目标区域的既定顺序取值。`seq=1` 按既定顺序取得目标。

Target `24` 选择敌方储牌区的首张 Card：

```lua
{
    id = 24,
    target = 2,
    area = { 15 },
    flag = { seq = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

### `randNum`

`randNum` 表示从候选中随机取得的数量。它要与 `minValue`、`maxValue` 一起阅读。

`randNum=1` 时，Target `525` 从敌方战场机体中随机选择 1 个对象：

```lua
{
    id = 525,
    target = 2,
    area = { 14 },
    flag = { randNum = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

`randNum=3` 时，Target `1211` 从敌方战场机体中随机选择 3 个对象：

```lua
{
    id = 1211,
    target = 2,
    area = { 14 },
    flag = { randNum = 3 },
    conditionList = { 0 },
    minValue = -1,
    maxValue = 3,
}
```

### `sort`

`sort` 先按指定属性排列候选，再由数量字段截取结果。

| 值 | 排序依据 |
| --- | --- |
| `minHp` | 当前 HP 最低 |
| `maxAttk` | 攻击力最高 |
| `minAttk` | 攻击力最低 |
| `maxCost` | Cost 最高 |

`sort="minHp"`：Target `304` 选择敌方当前 HP 最低的 2 个战场机体。→

```lua
{
    id = 304,
    target = 2,
    area = { 14 },
    flag = { sort = "minHp" },
    conditionList = { 0 },
    minValue = 2,
    maxValue = 2,
}
```

`sort="maxAttk"`：Target `775` 选择敌方攻击力最高的 1 个战场机体。→

```lua
{
    id = 775,
    target = 2,
    area = { 14 },
    flag = { sort = "maxAttk" },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

`sort="minAttk"`：Target `879` 从满足 Condition `2016` 的敌方战场机体中，选择攻击力最低的 1 个对象。→

```lua
{
    id = 879,
    target = 2,
    area = { 14 },
    flag = { sort = "minAttk" },
    conditionList = { 2016 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

`sort="maxCost"`：Target `928` 从敌方指定区域中选择 Cost 最高的 1 个对象。→

```lua
{
    id = 928,
    target = 2,
    area = { 4 },
    flag = { sort = "maxCost" },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

### `sortType`

`sortType` 是 `sort` 的扩展，不能脱离 `sort` 单独使用。

`sortType="random"`：Target `827` 从 HP 最低的一组敌方普通无人机中随机取得 1 台。→

```lua
{
    id = 827,
    target = 2,
    area = { 14 },
    flag = {
        sort = "minHp",
        sortType = "random",
    },
    conditionList = { 2016 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

`sortType="normal"`：Target `828` 按正常顺序取得 HP 最低的一组敌方普通无人机。→

```lua
{
    id = 828,
    target = 2,
    area = { 14 },
    flag = {
        sort = "minHp",
        sortType = "normal",
    },
    conditionList = { 2016 },
    conditionType = 1,
    minValue = -1,
    maxValue = -1,
}
```

### `attkTarget`

`attkTarget` 使用现有攻击选区。不同值代表不同的攻击关系，必须结合来源、阵营和数量字段使用。

`attkTarget=1` 表示同列前排优先。Target `30` 使用默认攻击目标。→

```lua
{
    id = 30,
    target = 2,
    area = { 14 },
    flag = { attkTarget = 1 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

`attkTarget=2` 表示对方扇形。Target `117` 选择扇形攻击范围内的全部敌方无人机。→

```lua
{
    id = 117,
    target = 2,
    area = { 14 },
    flag = { attkTarget = 2 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = -1,
}
```

`attkTarget=3` 表示中路。Target `106` 选择全部敌方中路无人机。→

```lua
{
    id = 106,
    target = 2,
    area = { 14 },
    flag = { attkTarget = 3 },
    conditionList = { 0 },
    minValue = 0,
    maxValue = -1,
}
```

`attkTarget=4` 表示三路。Target `138` 使用三路攻击选区，最多选择 3 台敌方无人机。→

```lua
{
    id = 138,
    target = 2,
    area = { 14 },
    flag = { attkTarget = 4 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 3,
}
```

`attkTarget=5` 表示目标后排。Target `31` 选择目标后排。→

```lua
{
    id = 31,
    target = 2,
    area = { 14 },
    flag = { attkTarget = 5 },
    conditionList = { 0 },
    minValue = 1,
    maxValue = 1,
}
```

## `conditionList`：继续判断候选

`conditionList` 填写 `battle_condition_def.config.id` 列表。Target 先通过 `target`、`area` 和 `flag` 得到候选，再用这些 Condition 继续判断候选是否保留。

`conditionList={0}` 表示不增加 Condition。现有配置使用 `conditionType=1`：列表中的 Condition 都满足时，候选才会保留。

Target `667` 同时使用 Condition `2074` 和 `2016`，从双方战场机体中选择 1 台攻击力小于等于 3 的无人机。→

```lua
{
    id = 667,
    target = 3,
    area = { 14 },
    flag = {},
    conditionList = { 2074, 2016 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

Condition 的字段与可用规则见 [`battle_condition_def` 配置参考](battle_condition_def.md)。

## `minValue` 与 `maxValue`：确定结果数量

`minValue` 和 `maxValue` 在候选完成筛选、排序或随机处理后，限制最终返回的对象数量。负数的具体含义要结合选择规则阅读，不要把它脱离完整 Target 单独套用。

| 用法 | Target | 关键配置 | 游戏结果 |
| --- | --- | --- | --- |
| 选择 1 个 | `40` | `minValue=1`、`maxValue=1` | 选择 1 个敌方战场机体 |
| 固定选择 2 个 | `304` | `sort="minHp"`、`minValue=2`、`maxValue=2` | 选择当前 HP 最低的 2 个敌方战场机体 |
| 返回全部候选 | `113` | `colTarget=1`、`minValue=-1`、`maxValue=-1` | 返回敌方对应列的全部战场机体 |
| 随机选择最多 3 个 | `1211` | `randNum=3`、`minValue=-1`、`maxValue=3` | 从敌方战场机体中随机返回最多 3 个 |

如果 Target 使用 `sort`，先按指定属性排列候选，再按 `minValue`、`maxValue` 取得结果。例如 Target `304` 先按当前 HP 从低到高排列，再取得前 2 个。


## 在 MOD 中新增 `battle_target_def`

在 MOD 中创建：

```text
config/battle_target_def/config/targets.lua
```

文件通过 `installKey="id"` 指定安装键，并在 `rows` 中填写完整配置。例如新增 Target `900001`，从敌方战场机体中选择 1 个对象：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 900001,
            actor = 1,
            target = 2,
            area = { 14 },
            flag = {},
            conditionList = { 0 },
            conditionType = 1,
            minValue = 1,
            maxValue = 1,
        },
    },
}
```

新增完成后，可以在同一个 MOD 的 Card、Skill 或 Effect 中引用 `900001`：

```text
card_def.config.targetIds         → { 900001 }
battle_skill_def.config.targetIds → { 900001 }
battle_effect_def.config.targetId → 900001
```
