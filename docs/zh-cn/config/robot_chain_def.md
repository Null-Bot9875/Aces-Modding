# `robot_chain_def` 配置参考

> Chain 定义 Enemy 在每个行动回合准备哪些 Card，以及多个候选之间如何按 Condition 和权重选择。

## `robot_chain_def` 的基本结构

[`enemy-pack`](../../../templates/enemy-pack/README.md) 中 Enemy `11999` 使用 Chain `1999`。第 1、3 个 Enemy 回合使用 Card `21007`（自我修复），第 2、4 个 Enemy 回合使用 Card `21006`（试探点射）。

```text
Enemy 11999
  -> Chain 1999
     -> 第 1 回合：行动池 990201 -> Card 21007
     -> 第 2 回合：行动池 990202 -> Card 21006
     -> 两回合后重新循环
```

阅读 Chain 配置时，先分清三个 ID：

```text
行动链：chainId=1999，决定读取哪组回合序列
行动池：poolId=990201/990202，决定本回合有哪些候选行动
行动项：id=990301/990302，唯一标识最终被选中的 Card 行动
```

完整配置文件见 [`enemy-pack`](../../../templates/enemy-pack/README.md)。

## Chain 在引用链中的位置

```text
战斗 Node
  -> act_node_def.robot
  -> robot_def.chainId
  -> robot_chain_def.sequence
       -> poolId
       -> robot_chain_def.config
            -> cardId
            -> Card -> Skill -> Target / Effect
```

`robot_def.chainId` 是普通 Enemy 的 Chain 入口。Chain 最终执行的仍然是 Card，因此 Card 的费用、Target、Skill、Effect 和表现都必须适合 Enemy 自动使用。

## 两种配置分别负责什么

`robot_chain_def` 包含两个独立 sheet，也必须使用两个独立安装组：

| 配置 | 文件目录 | `installKey` | 安装组 | 负责内容 |
| --- | --- | --- | --- | --- |
| 回合序列 | `config/robot_chain_def/sequence/` | `"chainId"` | 一个 `chainId` 的完整有序 rows | 当前回合读取哪些行动池 |
| 行动池 | `config/robot_chain_def/config/` | `"poolId"` | 一个 `poolId` 的全部候选 rows | Condition、权重和最终 Card |

两者不能合成一个跨 sheet 的“大 Chain 文件”。一个行动池可以被多个 Chain 共用；修改 `sequence` 不等于拥有或覆盖它引用的行动池。

游戏已有配置中存在多个共享行动池。例如，`poolId=170` 和 `171` 同时被 `chainId=1140` 与 `21000` 引用。这些 ID 属于当前游戏版本，不能当作跨版本常量。

示例省略 `operation`，默认执行 `replace`：

- 对新 `chainId` 或新 `poolId`，`replace` 会新增整个组；
- 对已有组，`replace` 会替换该组的全部 rows；
- `append` 只在明确需要向已有组追加候选时使用；
- 制作独立内容时，优先使用新的 Chain 和行动池 ID，避免改变游戏已有配置或其他 MOD 的共享组。

## 回合序列：`robot_chain_def.sequence`

文件位置：

```text
config/robot_chain_def/sequence/two_round_cycle.lua
```

完整两回合循环：

```lua
return {
    installKey = "chainId",
    installValue = 1999,
    rows = {
        {
            chainId = 1999,
            seqType = 2,
            round = 1,
            circle = 2,
            poolId = 990201,
        },
        {
            chainId = 1999,
            seqType = 2,
            round = 2,
            circle = 2,
            poolId = 990202,
        },
    },
}
```

### 回合序列字段

| 字段 | 类型 | 含义 | 配置规则 |
| --- | --- | --- | --- |
| `chainId` | int | 行动链分组 ID | 每个 row 都必须等于批次 `installValue` |
| `seqType` | int | 回合匹配方式 | 可用值是 `1` 和 `2` |
| `round` | int | 指定回合，或循环中的位置 | 与 `seqType`、`circle` 一起解释 |
| `circle` | int | 循环长度 | `seqType=2` 时必须使用正整数 |
| `poolId` | int | 匹配该回合后读取的行动池 | 引用 `robot_chain_def.config.poolId` |

`sequence` row 没有 `id`。不要从旧配置、旧导出或其他 sheet 复制辅助 `id` 字段。

`rows` 是有序列表。一个逻辑回合可以匹配多行，并按这些行依次准备多个行动池；不要把 rows 改成以 `round` 或 `poolId` 为键的 map，也不要依赖安装器自动排序。

### 循环回合：`seqType=2`

`seqType=2` 按 `circle` 循环。当前 Enemy 是第几个行动回合，可按下面的方式理解：

```text
循环位置 = ((Enemy 行动回合 - 1) % circle) + 1
```

当循环位置等于 row 的 `round` 时，该 row 生效。

例如 `circle=2`：

| Enemy 行动回合 | 循环位置 | 读取的行动池 |
| ---: | ---: | --- |
| 1 | 1 | `990201` |
| 2 | 2 | `990202` |
| 3 | 1 | `990201` |
| 4 | 2 | `990202` |

`enemy-pack` 使用 `seqType=2, circle=2` 作为可复制起点。`circle=0` 会让循环计算无效，不要用于 `seqType=2`。

### 指定回合：`seqType=1`

`seqType=1` 只在 Enemy 行动回合等于 `round` 时匹配。它适合“第 1 回合执行准备、第 2 回合执行攻击”这类不循环的指定回合行为。

```lua
{
    chainId = 990001,
    seqType = 1,
    round = 1,
    circle = 0,
    poolId = 990101,
}
```

没有匹配 row 的回合不会从这条 Chain 得到行动池。现有配置同时存在 `seqType=1` 与 `2`；复制时应沿用所参考行动链的取值。

不要在同一个 `chainId` 中混写 `seqType=1` 与 `2`。当前运行时会使用本次刷新中先匹配到的类型，并跳过另一种类型；结果会依赖 row 顺序。

## 行动池：`robot_chain_def.config`

文件位置：

```text
config/robot_chain_def/config/round_1_buffer.lua
```

完整行动池：

```lua
return {
    installKey = "poolId",
    installValue = 990201,
    rows = {
        {
            id = 990301,
            type = 1,
            poolId = 990201,
            weight = 1,
            useConditions = {},
            cardId = 21007,
            assetId = "buff_1",
            extend = {},
        },
    },
}
```

### 行动池字段

| 字段 | 类型 | 含义 | 配置规则 |
| --- | --- | --- | --- |
| `id` | int | 行动项唯一 ID | 必须在整张 `robot_chain_def.config` 表中唯一，不只是 pool 内唯一 |
| `type` | int | 完整行动 row 的类型字段 | 新内容保持示例值 `1` |
| `poolId` | int | 行动池分组 ID | 每个 row 都必须等于批次 `installValue` |
| `weight` | int | 通过 Condition 后的相对选择权重 | 使用正整数；同一 pool 内比较 |
| `useConditions` | list<int> | 使用该行动必须满足的 Battle Condition | 空表表示没有额外条件；见 [`battle_condition_def` 配置参考](battle_condition_def.md) |
| `cardId` | int | Enemy 最终执行的 Card | 复用同版本已有 Card，并在战斗中验证自动选目标和结算 |
| `assetId` | string | 行动链界面使用的已有图标引用 | 复用已确认值；新字符串不会创建资源 |
| `extend` | lua | 行动链界面的附加表现参数 | 普通行动使用 `{}`；当前确认字段见下方 |

`id` 会写入战斗中的待执行 Chain，并被战斗逻辑和客户端界面再次查询。重复或不存在的 `id` 不是显示问题，而会破坏行动执行或界面读取。

普通行动的 `type` 保持 `1`。不要根据其他数据中的数值推断新的行动类型。

### Condition 和权重如何选择 Card

每个匹配到的 `poolId` 按以下顺序选择至多一条行动：

```text
读取 pool 的全部 rows
  -> 删除不满足 useConditions 的 rows
  -> 对剩余 rows 按 weight 做加权随机
  -> 保存被选中 row 的 id
  -> 执行该 row 的 cardId
```

例如同一 pool 有两条都满足 Condition 的候选：

```lua
rows = {
    {
        id = 990311,
        type = 1,
        poolId = 990211,
        weight = 3,
        useConditions = {},
        cardId = 21007,
        assetId = "buff_1",
        extend = {},
    },
    {
        id = 990312,
        type = 1,
        poolId = 990211,
        weight = 1,
        useConditions = {},
        cardId = 21006,
        assetId = "attack_1",
        extend = {},
    },
}
```

两条候选的相对权重是 `3:1`，不是固定每四次执行三次与一次。`id` 和文件顺序不会覆盖权重选择。

如果所有候选都不满足 Condition，或有效候选总权重不大于 `0`，该 pool 不会产生行动。负权重没有公开语义，不要使用。

## 游戏内表现

表现字段只控制客户端 Chain 列表，不改变服务器选择哪个 Card。

### 行动图标：`assetId`

客户端使用 `assetId` 读取已有行动链图标。示例使用：

| 值 | 示例用途 |
| --- | --- |
| `"buff_1"` | 自我修复行动 |
| `"attack_1"` | 试探点射行动 |

字符串存在于配置中不等于客户端存在对应资源。这里复用游戏已有的 Chain 图标。

### 行动特效：`extend.showChainEffect`

普通行动使用空表：

```lua
extend = {}
```

需要复用现有 Chain 列表特效时，可以使用：

```lua
extend = {
    showChainEffect = true,
}
```

该字段只控制现有界面特效的显示与隐藏，不新增特效资源，也不改变 Card 结算。

## 在 MOD 中新增 `robot_chain_def`

一个新的两回合 Chain 至少涉及四处同步修改：

1. `robot_def.config.chainId` 指向新的 Chain；
2. 一个 `sequence` 文件定义完整 `chainId` 组；
3. 每个新 `poolId` 各有一个独立 `config` 文件；
4. 每条行动 row 使用全表唯一 `id`，并引用已有 `cardId`。

```text
robot_def.chainId = 1999

sequence chainId=1999
  -> round 1 -> poolId=990201
  -> round 2 -> poolId=990202

config poolId=990201
  -> id=990301 -> cardId=21007

config poolId=990202
  -> id=990302 -> cardId=21006
```

示例 ID 不是保留号段。发布其他 MOD 前，必须更换 Enemy ID、`chainId`、每个 `poolId` 和每个 action `id`，并同步全部引用。

复制模板后按下面的顺序修改：

1. 先复制 `enemy-pack` 的三类 Chain 文件；
2. 更换所有新增 ID，但暂时保留 Card、Condition 和表现值；
3. 确认两回合循环仍然成立；
4. 一次只替换一个 `cardId`；
5. 最后再增加候选、Condition、权重或表现。
