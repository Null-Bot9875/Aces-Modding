> Target 定义一次目标选择：从哪一方、哪些区域寻找候选对象，应用哪些选择规则，以及最终选择多少个目标。

## Target 的基本结构

Target `40` 的游戏内结果是：选择一个敌方单位。

Effect `8026` 使用这个 Target，对选中的敌方单位造成 2 点伤害。

`连续射击α`（Card `2061`）：造成 2 点伤害。将 1 张[连续射击β]加入你的手牌。

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

```text
目标从哪个阵营选择：target=2，从敌方阵营寻找候选
目标从哪个区域选择：area={14}，从战场机体区域寻找候选
目标筛选条件：flag={}、conditionList={0}，不增加额外规则
目标选择数量：minValue=1、maxValue=1，选择一个
```

## 基本信息

| 字段 | 类型 | 含义 | 作者规则 |
| --- | --- | --- | --- |
| `id` | int | Target 唯一 ID | 新增配置必须使用不冲突的 ID |
| `actor` | int | 发起方 | 必填；当前配置填写 `1` |

Target 不导出 `title`、`desc`、`isFormatDesc` 和 `tips`。需要记录用途时，可以在 Lua 中写注释，或在 MOD 的 README 中说明，不要把这些名称作为配置字段提交。

### `id` 的引用入口

以下字段直接引用 `battle_target_def.config.id`：

| 引用字段 | 作用 |
| --- | --- |
| `card_def.config.targetIds` | 决定使用 Card 时需要选择哪些目标 |
| `battle_skill_def.config.targetIds` | 决定主动使用 Skill 时需要选择哪些目标 |
| `battle_effect_def.config.targetId` | 决定 Effect 结算时作用于哪些对象 |

Card 和 Skill 使用 Target ID 列表；Effect 使用单个 Target ID。它们可以引用 Core Target，也可以引用同一个 MOD 新增的 Target。

## 选择逻辑

Target 的选择逻辑由五部分组成：

| 配置 | 解决的问题 |
| --- | --- |
| `target` | 从哪一方寻找候选 |
| `area` | 从哪些战斗区域寻找候选 |
| `flag` | 使用哪些身份、相对关系或自动选择规则 |
| `conditionList`、`conditionType` | 候选还需要满足哪些 Condition |
| `minValue`、`maxValue` | 最终需要得到多少个目标 |

这些字段共同决定结果。不要脱离 `area` 和具体选择路径，单独解释或复制某个 `flag`。

### 候选阵营：`target`

`target` 以来源 Card 或 Skill 的所属阵营为参照，决定从哪一方寻找候选。

| 值 | 含义 | 说明 |
| --- | --- | --- |
| `1` | 己方 | 从来源所属阵营寻找候选 |
| `2` | 敌方 | 从另一方阵营寻找候选 |
| `3` | 双方 | 同时从双方阵营寻找候选 |

`target=3` 只表示候选来自双方。是否排除来源自身，仍由 `flag.self` 等规则决定。

### 候选区域：`area`

`area` 填写 Area ID 列表，决定从哪些战斗区域寻找目标。完整区域表以及它与 `CardArea.value` 的区别见[战斗区域参考](../concepts/areas.md)。

例如：

```text
area={2}       手牌
area={8}       Player
area={14}      战场机体
area={8,14}    Player 和战场机体
```

一个 Target 可以组合多个区域。例如 Target `114` 使用 `area={8,14}`，选择己方 Player 和全部战场机体。

### 额外选择规则：`flag`

`flag` 是一组与 `area` 和具体选择器配合使用的参数。未知 key 不会注册新的选择算法。

本页收录的每个规则都给出一个当前版本 Core Target 例子。例子中的 `target`、`area`、Condition 和数量字段也是行为的一部分，不要只复制 `flag`。

#### `self`

`self` 判断候选是否为来源自身。

**`self=1`：只保留来源自身**

##### eg: Target `103`

选择来源无人机自身：

```lua
target = 1,
area = { 14 },
flag = { self = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

**`self=0`：排除来源自身**

##### eg: Target `134`

```lua
target = 3,
area = { 14 },
flag = { self = 0 },
conditionList = { 0 },
minValue = 0,
maxValue = -1,
```

这条 Target 选择双方除来源自身外的全部无人机。

#### `selfPlayer`

`selfPlayer` 指定来源所属的 Player。

**`selfPlayer=1`：选择来源所属的 Player**

##### eg: Target `100`

```lua
target = 1,
area = { 8 },
flag = { selfPlayer = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

#### `hero`

`hero` 根据机体是否搭乘机师筛选候选。

**`hero=1`：只保留已搭乘机师的机体**

##### eg: Target `1225`

```lua
target = 1,
area = { 14 },
flag = { hero = 1 },
conditionList = { 0 },
minValue = 0,
maxValue = -1,
```

这条 Target 选择己方所有已搭乘机师的机体。

#### `selfRound`

`selfRound` 根据机体当前是否处于自身回合筛选候选。

**`selfRound=1`：只保留当前处于自身回合的机体**

##### eg: Target `940`

```lua
target = 3,
area = { 14 },
flag = { selfRound = 1 },
conditionList = { 2016 },
minValue = -1,
maxValue = -1,
```

这条 Target 从双方候选中选择处于自身回合的普通无人机。Condition `2016` 也是这个结果的一部分。

#### `side`

`side` 按来源与候选的相邻关系筛选单位。

**`side=1`：选择与来源横向或纵向相邻的单位**

##### eg: Target `123`

```lua
target = 1,
area = { 14 },
flag = { side = 1 },
conditionList = { 0 },
minValue = 0,
maxValue = -1,
```

这条 Target 选择与来源相邻的己方无人机。

#### `colNext`

`colNext` 按来源所在列筛选后方单位。

**`colNext=1`：选择来源同列后方的单位**

##### eg: Target `127`

```lua
target = 1,
area = { 14 },
flag = { colNext = 1 },
conditionList = { 0 },
minValue = 0,
maxValue = 1,
```

这条 Target 最多选择一台位于来源后方的己方无人机。

#### `sameRow`

`sameRow` 按来源所在排筛选单位。

**`sameRow=1`：选择与来源同排的单位**

##### eg: Target `405`

```lua
target = 1,
area = { 14 },
flag = { sameRow = 1 },
conditionList = { 0 },
minValue = -1,
maxValue = -1,
```

这条 Target 选择与来源同排的己方无人机。

#### `colTarget`

`colTarget` 按来源所在列筛选对方单位。

**`colTarget=1`：选择对方与来源同列的单位**

##### eg: Target `113`

```lua
target = 2,
area = { 14 },
flag = { colTarget = 1 },
conditionList = { 0 },
minValue = -1,
maxValue = -1,
```

这条 Target 选择与来源同列的敌方无人机。

#### `rowOne`

`rowOne` 约束一次多选结果的排。

**`rowOne=1`：让一次多选结果来自同一排**

##### eg: Target `102`

```lua
target = 2,
area = { 14 },
flag = { rowOne = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 3,
```

这条 Target 选择一排敌方无人机，最多选择 3 台。

#### `colOne`

`colOne` 约束一次多选结果的列。

**`colOne=1`：让一次多选结果来自同一列**

##### eg: Target `503`

```lua
target = 2,
area = { 14 },
flag = { colOne = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 3,
```

这条 Target 选择一列敌方无人机，最多选择 3 台。

#### `seq`

`seq` 按目标区域的既定顺序取值。

**`seq=1`：按既定顺序取得目标**

##### eg: Target `24`

```lua
target = 2,
area = { 15 },
flag = { seq = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 选择敌方储牌区的首张 Card。

#### `randNum`

`randNum` 指定从候选中随机取得的目标数量。候选数量和最终上限仍由 `minValue`、`maxValue` 共同约束。

**`randNum=1`：随机取得 1 个目标**

##### eg: Target `525`

```lua
target = 2,
area = { 14 },
flag = { randNum = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 随机选择一台敌方无人机。

**`randNum=3`：随机取得 3 个目标**

##### eg: Target `1211`

```lua
target = 2,
area = { 14 },
flag = { randNum = 3 },
conditionList = { 0 },
minValue = -1,
maxValue = 3,
```

这条 Target 随机选择 3 台敌方无人机。

#### `sort`

`sort` 按指定属性排列候选。排序只决定候选顺序；最终数量仍由 `minValue`、`maxValue` 和具体选择路径共同决定。

**`sort="minHp"`：HP 从低到高**

##### eg: Target `304`

```lua
target = 2,
area = { 14 },
flag = { sort = "minHp" },
conditionList = { 0 },
minValue = 2,
maxValue = 2,
```

这条 Target 选择 HP 最低的两台敌方无人机。

**`sort="maxAttk"`：攻击从高到低**

##### eg: Target `775`

```lua
target = 2,
area = { 14 },
flag = { sort = "maxAttk" },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 选择攻击最高的敌方无人机。

**`sort="minAttk"`：攻击从低到高**

##### eg: Target `879`

```lua
target = 2,
area = { 14 },
flag = { sort = "minAttk" },
conditionList = { 2016 },
minValue = 1,
maxValue = 1,
```

这条 Target 选择攻击最低的敌方普通无人机。Condition `2016` 是这个结果的一部分。

**`sort="maxCost"`：费用从高到低**

##### eg: Target `928`

```lua
target = 2,
area = { 4 },
flag = { sort = "maxCost" },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 选择敌方废弃区费用最高的 Card。

#### `sortType`

`sortType` 是 `sort` 的扩展，不能脱离 `sort` 单独使用。

**`sortType="random"`：从极值候选组中随机取值**

##### eg: Target `827`

```lua
target = 2,
area = { 14 },
flag = {
    sort = "minHp",
    sortType = "random",
},
conditionList = { 2016 },
minValue = 1,
maxValue = 1,
```

这条 Target 从 HP 最低的一组敌方普通无人机中随机取 1 台。

**`sortType="normal"`：按正常顺序取得极值候选组**

##### eg: Target `828`

```lua
target = 2,
area = { 14 },
flag = {
    sort = "minHp",
    sortType = "normal",
},
conditionList = { 2016 },
minValue = -1,
maxValue = -1,
```

这条 Target 取得 HP 最低的一组敌方普通无人机。

#### `attkTarget`

`attkTarget` 使用现有攻击选区。五个值都必须连同整条 Core Target 配置一起复制：

**`attkTarget=1`：同列前排优先**

##### eg: Target `30`

```lua
target = 2,
area = { 14 },
flag = { attkTarget = 1 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 使用默认攻击目标。

**`attkTarget=2`：对方扇形**

##### eg: Target `117`

```lua
target = 2,
area = { 14 },
flag = { attkTarget = 2 },
conditionList = { 0 },
minValue = 0,
maxValue = -1,
```

这条 Target 选择扇形攻击范围内的敌方无人机。

**`attkTarget=3`：中路**

##### eg: Target `106`

```lua
target = 2,
area = { 14 },
flag = { attkTarget = 3 },
conditionList = { 0 },
minValue = 0,
maxValue = -1,
```

这条 Target 选择敌方中路无人机。

**`attkTarget=4`：三路**

##### eg: Target `138`

```lua
target = 2,
area = { 14 },
flag = { attkTarget = 4 },
conditionList = { 0 },
minValue = 1,
maxValue = 3,
```

这条 Target 使用三路攻击选区，最多选择 3 台敌方无人机。

**`attkTarget=5`：目标后排**

##### eg: Target `31`

```lua
target = 2,
area = { 14 },
flag = { attkTarget = 5 },
conditionList = { 0 },
minValue = 1,
maxValue = 1,
```

这条 Target 选择目标后排。

这些 key 不是可以任意组合的独立开关。初次新增 Target 时，应先复制行为接近的完整 Core Target，只修改 `id` 和确实需要变化的选择字段，再在实际战斗中验证。

### 条件过滤：`conditionList`

`conditionList` 引用 [Battle Condition](conditions.md#battle-condition)，对区域和 `flag` 得到的候选继续检查。

| 配置 | 含义 |
| --- | --- |
| `conditionList={0}` | 不增加 Condition |
| `conditionType=1` | 列表中的 Condition 全部满足，即 AND |
| `conditionType=2` | 列表中的 Condition 满足任意一个，即 OR |

Condition 会对候选对象进行判断，因此必须使用与候选类型匹配的 Condition。选择 Card 的 Target 不能直接套用只处理 Player 的 Condition。

### 选择数量：`minValue` 和 `maxValue`

`minValue` 表示完成选择所需的最低数量，`maxValue` 表示最多得到多少个目标。

最常见的手动单选配置是：

```lua
minValue = 1,
maxValue = 1,
```

部分 Core Target 使用 `maxValue=-1` 表示不设置普通上限，或配合自动选择取得全部候选。`minValue=0`、负数和 `maxValue=-1` 的实际含义会受区域与选择路径影响。

新增 Target 时，除非正在复制一条已验证的 Core 配置，否则优先使用明确的非负数量，不要把 `-1` 统一理解为“全部”。

## 常用 Target

下面按当前版本 `card_def.config.targetIds` 的实际引用次数筛选。统计排除名称含“测试”的 Card 和 `targetIds=0`；同一 Target 在一条 Card row 中只计一次，普通版与升级版分别计数。

从中保留直接选择 Player 或战场单位的通用 Target，并按引用次数从高到低排列：

| ID | Card 引用数 | 当前用途 | 关键配置 | 代表 Card |
| --- | ---: | --- | --- | --- |
| `40` | 96 | 任选一个敌方单位 | `target=2`、`area={14}`，选择 1 个 | `连续射击α`、`炮击` |
| `109` | 37 | 选择一台敌方机体 | 与 Target `40` 使用相同配置 | `射击`、`背水一战` |
| `613` | 37 | 选择一台己方普通无人机 | `target=1`、`area={14}`、Condition `2016` | `叹息长阶`、`覆膜` |
| `104` | 20 | 选择一台己方无人机 | `target=1`、`area={14}`，选择 1 个 | `攻击指令`、`联结指令` |
| `101` | 9 | 选择敌方 Player | `target=2`、`area={8}`，选择 1 个 | `神经元劫持`、`磁感领域` |
| `683` | 9 | 选择一台敌方普通无人机 | `target=2`、`area={14}`、Condition `2016` | `点到为止`、`熔毁` |

引用次数只说明当前 Card 表使用频率，不表示这个 Target 适合所有 Card。使用前仍要检查目标类型、选择方式和实际战斗结果。

这些 ID 来自当前版本 Core 配置，不是跨版本永久常量。游戏更新后，需要重新统计同版本 Card 表，并对照 [`game-lua`](../../../game-lua/README.md) 和实际战斗结果确认。

## 新增完整 Target 配置

文件位置：

```text
config/battle_target_def/config/targets.lua
```

Target 当前没有作者字段适配器。新增 row 时，必须提供当前导出的 9 个字段：`id`、`actor`、`target`、`area`、`flag`、`conditionList`、`conditionType`、`minValue` 和 `maxValue`。

下面新增 Target `990401`，它与 Core Target `40` 使用相同的选择规则：从敌方战场机体中选择一个目标。

```lua
return {
    installKey = "id",
    rows = {
        -- 选择一个敌方单位
        {
            id = 990401,
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

同一个 MOD 的 Card 或 Skill 可以在 `targetIds` 中引用 `990401`，Effect 可以在 `targetId` 中引用它。

新增 Target 表示新增一组已有选择规则的配置，不会新增 `area`、`flag` 或选择算法。未知值不会自动产生新行为。
