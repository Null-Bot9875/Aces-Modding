# Node 配置教学

当前支持的 Node 作者范围是：提交完整 `act_node_def` row，引用已有或 MOD 提供的 Enemy，并通过地图刷新组把战斗 Node 放到可到达位置。

本页不表示已经支持所有 Node 类型、地图结构、条件、选项、对话或奖励组合。

可运行文件见 [`complete-mod`](../../../examples/complete-mod/README.md)。本页使用相同 ID 说明引用关系。

## 完整引用链

```text
act_node_refresh_def groupId 2001
  -> act_node_def Node 990101
  -> robot_def Enemy 11999
  -> robot_chain_def chainId 1999
```

只定义 `act_node_def` 不会让 Node 自动出现在地图上。只定义刷新组也不够，`nodeId` 必须引用已经安装的完整 Node。

## 1. 定义战斗 Node

文件位置：

```text
config/act_node_def/config/node.lua
```

完整 row 见 [`complete-mod/config/act_node_def/config/node.lua`](../../../examples/complete-mod/config/act_node_def/config/node.lua)。示例中的主要引用：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990101,
            mainType = 1,
            type = 1,
            showType = 1,
            name = "MOD 行动链演示",
            subheading = "先修复，再点射",
            desc = "用于验证 Rogue 节点、敌人和行动链共享配置链路。",
            summary = "两回合循环的纯行动链敌人。",
            battleReward = { 100001 },
            robot = 11999,
            gridPoolList = { 200 },
            optionRandom1 = {
                { id = 10051, weight = 100 },
            },
            conditionGroup = 99,
            skybox = "Nebula_Coral_4K_3",
            -- 其余字段必须保留，见完整示例文件
        },
    },
}
```

| 字段 | 示例中的作用 |
| --- | --- |
| `id` | Node ID；同时是刷新组 `nodeId` 的引用目标 |
| `name`、`subheading`、`desc`、`summary` | Node 的玩家可见文本 |
| `robot` | 战斗使用的 Enemy ID |
| `battleReward` | 战斗奖励引用 |
| `gridPoolList` | 战斗网格池引用 |
| `optionRandom1` | Node 使用的选项及权重 |
| `conditionGroup` | 条件组引用 |
| `skybox` | 战斗场景背景引用 |

`act_node_def.config` 当前没有简化作者格式，必须提交完整 row。字段缺失可能导致加载失败，也可能直到进入 Node 后才暴露问题。未明确说明的字段先保留示例值；需要改变时，对照同版本 `game-lua` 中同类型战斗 Node 的完整 row。

Node 文本先直接写在 row 中。需要中英文翻译时，使用 `language/language.csv`，规则见[多语言](../localization.md)。

## 2. 让 Node 出现在地图上

文件位置：

```text
config/act_node_refresh_def/config/reachable_node.lua
```

示例：

```lua
return {
    installKey = "groupId",
    installValue = 2001,
    rows = {
        {
            groupId = 2001,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

这个批次替换地图刷新组 `2001`，使 EP `1061` 的地图位置 `230001` 稳定出现 Node `990101`。

| 字段 | 示例中的作用 |
| --- | --- |
| `groupId` | 被地图引用的刷新组 |
| `nodeId` | 刷新组产生的 Node |
| `weight` | 同组候选的随机权重 |
| `limitBaseId` | 机体限制；空表表示示例不增加限制 |
| `nodeLimit` | 本次刷新中的数量限制 |

省略 `operation` 时默认使用 `replace`。这会删除 Core 刷新组 `2001` 的旧 rows，再写入示例 row，因此测试时能稳定看到目标 Node。

改成 `operation = "append"` 会保留 Core rows 并加入新 row，但目标 Node 可能因随机选择而不出现。首轮验证建议保留 `replace`；正式内容是否覆盖 Core 组，需要单独设计。

## 3. 接入 Enemy

Node 中的引用：

```lua
robot = 11999
```

必须存在 `id=11999` 的 `robot_def` 完整 row。Enemy 的行动链和每回合 Card 见 [Enemy 配置教学](enemy.md)。

新增 Enemy、行动链或行动池 ID 后，按以下方向逐层检查：

```text
Node.robot
  -> Enemy.id
Enemy.chainId
  -> sequence.installValue / sequence rows[].chainId
sequence rows[].poolId
  -> action pool installValue / rows[].poolId
```

## ID 与覆盖风险

示例 ID `990101` 不是保留号段，发布其他 MOD 前必须更换。地图刷新组 `2001` 是 Core 已有组，示例会覆盖该组，仅适合专门的测试存档。

停用示例并不会修改已有战役已经保存的地图结果。恢复检查必须冷启动后新建 EP `1061`，再确认位置 `230001` 回到 Core Node `4315`。

## 游戏内验证

Node 完成标准包括：

1. 冷启动没有 MOD 配置或加载错误；
2. 新建 EP `1061` 后，位置 `230001` 显示 Node `990101`；
3. Node 名称、说明和选项正常显示；
4. 进入 Node 后启动目标 Enemy 战斗；
5. 战斗能够完成并结算奖励；
6. 停用 MOD、冷启动并新建战役后，Core Node `4315` 恢复。

完整记录格式见[人工测试清单](../manual-testing.md)。自动检查、配置查询或开发环境运行结果不等于完成 MOD 作者人工验证。

## 能力请求

需要新 Node 类型、复杂条件、特殊地图连接、对话流程或文档未覆盖的奖励方式时，在 GitHub Issues 中选择“能力请求”，并按玩家可见流程描述目标内容。
