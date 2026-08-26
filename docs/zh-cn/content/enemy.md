# Enemy 配置教学

当前支持的 Enemy 作者范围是：复用已有 Core 机体基础数据和 Card，通过行动链安排每回合行为。

本页不表示已经支持自定义机体、Skill、Target、Card 行为、模型、动画、音频或所有 Enemy 类型。

可运行文件见 [`complete-mod`](../../../examples/complete-mod/README.md)。本页使用相同 ID 说明引用关系。

## Enemy 由三部分组成

```text
robot_def Enemy 11999
  -> robot_chain_def.sequence 行动链 1999
  -> robot_chain_def.config 行动卡池 990201、990202
  -> 已存在的 Core Card 21007、21006
```

`robot_def` 决定 Enemy 使用哪个 Core 基础数据和哪条行动链。`sequence` 决定每个回合读取哪个行动卡池。`config` 决定该卡池可执行哪些 Card。

## 1. 定义 Enemy

文件位置：

```text
config/robot_def/config/enemy.lua
```

示例：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 11999,
            name = "MOD 修复点射核心",
            groupId = 0,
            baseId = 7366,
            chainId = 1999,
            newCards = 0,
            noSuffle = 0,
            roundAction = -1,
            noCardCheck = 2,
            roomRobot = 0,
            robotType = 1,
        },
    },
}
```

示例中直接修改的关键字段：

| 字段 | 作用 |
| --- | --- |
| `id` | Enemy 配置 ID；同时是 `act_node_def.robot` 的引用目标 |
| `name` | Enemy 配置名称 |
| `baseId` | 复用的 Core 机体基础数据、外观和部分界面信息 |
| `chainId` | 行动链 ID；必须与 `sequence` 批次的 `installValue` 一致 |

`robot_def.config` 当前没有简化作者格式，必须提交完整 row。未明确说明的字段先保留示例值；需要改变时，对照同版本 `game-lua` 中同类型 Enemy 的完整 row。

战斗界面部分位置可能显示 `baseId` 对应的 Core 名称，而不是 `robot_def.name`。示例因此可能同时出现 `MOD 修复点射核心` 和 `自成长核心`。

## 2. 定义每回合使用的行动卡池

文件位置：

```text
config/robot_chain_def/sequence/two_round_cycle.lua
```

示例：

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

这组完整 row 形成两回合循环：第 1 回合读取 `990201`，第 2 回合读取 `990202`，之后重新开始。

| 字段 | 示例中的作用 |
| --- | --- |
| `chainId` | 归属的行动链 |
| `round` | 循环内的回合位置 |
| `circle` | 示例循环长度 |
| `poolId` | 当前回合读取的行动卡池 |

`installKey` 与 `installValue` 会替换 `chainId=1999` 的完整分组。新增行动链时，所有 row 的 `chainId` 必须一致。

## 3. 定义行动卡池

第 1 回合文件：

```text
config/robot_chain_def/config/round_1_buffer.lua
```

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

第 2 回合使用相同结构，把 `poolId` 改为 `990202`、row `id` 改为 `990302`、`cardId` 改为 `21006`。

| 字段 | 示例中的作用 |
| --- | --- |
| `id` | 行动 row 的唯一 ID |
| `poolId` | 所属行动卡池；必须与批次 `installValue` 一致 |
| `weight` | 同一行动池内的选择权重 |
| `useConditions` | 使用条件；空表表示示例不增加额外条件 |
| `cardId` | Enemy 执行的已有 Card ID |
| `assetId` | 行动表现引用；示例复用已有值 |

当前范围只保证复用已存在 Card 的行动链。Card 是否适合 Enemy 使用，仍需在战斗中观察目标选择、结算和回合推进。

## 4. 把 Enemy 放进 Node

Enemy 配置不会自动出现在地图或战斗中。可进入的战斗 Node 必须在 `act_node_def` 中引用：

```lua
robot = 11999
```

完整步骤见 [Node 配置教学](node.md)。

## ID 与修改顺序

示例 ID 不是保留号段。发布其他 MOD 前，更换以下新增 ID 并同步所有引用：

- Enemy：`11999`；
- 行动链：`1999`；
- 行动卡池：`990201`、`990202`；
- 行动 row：`990301`、`990302`。

推荐先只替换一张已有 Core Card，确认两回合循环仍然成立；再调整行动池、条件和权重。一次修改多条引用会增加排查难度。

## 游戏内验证

Enemy 完成标准包括：

1. 冷启动没有 MOD 配置或加载错误；
2. Node 能进入战斗；
3. 战斗使用目标 Enemy；
4. 至少四个回合的行动顺序符合配置；
5. 每张 Card 的目标选择、效果结算和回合推进正常；
6. 停用 MOD 并冷启动后，Core Node 恢复。

完整记录格式见[人工测试清单](../manual-testing.md)。自动检查或配置查询成功不等于完成游戏内人工验证。

## 能力请求

需要自定义机体、Card 行为、Skill、Target、动画或文档未覆盖的行动方式时，在 GitHub Issues 中选择“能力请求”，并按玩家可见结果描述目标行为。
