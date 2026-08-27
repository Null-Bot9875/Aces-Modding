# Node 配置教学

当前支持的 Node 作者范围是：提交完整 `act_node_def` row，引用已有或 MOD 提供的 Enemy，并通过地图刷新组把战斗 Node 放到可到达位置。

本页不表示已经支持所有 Node 类型、地图结构、条件、选项、对话或奖励组合。

可运行文件见 [`node-pack`](../../../templates/node-pack/README.md)。本页使用相同 ID 说明引用关系。

## 完整引用链

```text
act_node_refresh_def groupId 1401（append）
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

完整 row 见 [`node-pack/config/act_node_def/config/node.lua`](../../../templates/node-pack/config/act_node_def/config/node.lua)。模板中的主要引用：

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
            -- 其余字段必须保留，见 node-pack 完整文件
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

Node 文本先直接写在 row 中。需要中英文翻译时，由 MOD 提供 `language/language.csv`。

## 2. 让 Node 出现在地图上

文件位置：

```text
config/act_node_refresh_def/config/reachable_node.lua
```

示例：

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "append",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1000000,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

这个批次把 Node `990101` 追加到 Core 第一层战斗节点组 `1401`。EP `1061` 的地图位置 `230021`、`230022`、`230031`、`230032` 使用该组；新手引导入口不受影响。

| 字段 | 示例中的作用 |
| --- | --- |
| `groupId` | 被地图引用的刷新组 |
| `nodeId` | 刷新组产生的 Node |
| `weight` | 同组候选的随机权重 |
| `limitBaseId` | 机体限制；空表表示示例不增加限制 |
| `nodeLimit` | 本次刷新中的数量限制 |

`operation = "append"` 会保留 Core `1401` rows，并把示例 row 加到组末尾。不要省略这一字段；省略后默认 `replace`，会删除该组全部 Core 战斗候选。

`weight=1000000` 只为人工测试时几乎总能遇到目标 Node，仍不是绝对确定；其他 MOD 也可能改变组权重。`nodeLimit=1` 会限制它在同一张地图中最多出现一次。制作正式内容时应按玩法平衡降低权重。

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

示例 ID `990101` 不是保留号段，发布其他 MOD 前必须更换。地图刷新组 `1401` 是 Core 已有的第一层战斗组；示例只追加 row，不覆盖 Core 成员，但测试高权重会明显改变节点分布，因此仍应使用专门的测试存档。

停用示例并不会修改已有战役已经保存的地图结果。恢复检查必须冷启动后新建 EP `1061`，再确认第一层战斗位置不再出现 Node `990101`。

## 游戏内验证

Node 完成标准包括：

1. 冷启动没有 MOD 配置或加载错误；
2. 新建 EP `1061` 并进入第一层战斗位置后显示 Node `990101`；
3. Node 名称、说明和选项正常显示；
4. 进入 Node 后启动目标 Enemy 战斗；
5. 战斗能够完成并结算奖励；
6. 停用 MOD、冷启动并新建战役后，第一层战斗位置不再出现 Node `990101`。

自动检查、配置查询或开发环境运行结果不等于完成 MOD 作者人工验证。

## 能力请求

需要新 Node 类型、复杂条件、特殊地图连接、对话流程或文档未覆盖的奖励方式时，在 GitHub Issues 中选择“能力请求”，并按玩家可见流程描述目标内容。
