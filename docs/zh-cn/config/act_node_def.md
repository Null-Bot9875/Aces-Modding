# `act_node_def` 配置参考

> `act_node_def` 定义玩家进入节点位置后实际看到和执行的节点内容。

地图路线与节点池由 [`act_ep_map_def`](act_ep_map_def.md) 和 [`act_node_refresh_def`](act_node_refresh_def.md) 决定；本页从玩家进入节点后的流程说明战斗、商店和事件。

## `act_node_def` 的基本结构

“十字星的残响”（节点 `1416`）在地图上显示为一场特殊战斗。

```lua
{
    id = 1416,
    mainType = 1,
    showType = 2,
    name = "十字星的残响",
    subheading = "十字星的残响",
    desc = "强调灵活链接武装的异形无人机。",
    summary = "强调灵活链接武装的异形无人机。",
}
```

| 字段 | 作用 |
| --- | --- |
| `id` | 节点 ID，也是 `act_node_refresh_def.nodeId` 的引用目标 |
| `mainType` | 节点的主要流程：`1` 战斗、`4` 商店、`5` 事件或抉择 |
| `showType` | 节点的显示类型，不改变 `mainType` 的执行流程 |
| `name` | 节点名称 |
| `subheading` | 进入节点后的副标题 |
| `desc` | 节点正文 |
| `summary` | 地图或摘要区域显示的短说明 |

当前常见 `showType` 为：`1` 普通战斗、`2` 特殊战斗、`3` 重要战斗、`4` 商店、`5` 抉择、`6` 补给。补给仍然执行 `mainType = 5` 的抉择流程，只使用不同显示。

## 节点如何生成选项

“欢迎光临”（节点 `4006`）依次生成三个选项：

```lua
{
    id = 4006,
    mainType = 5,
    showType = 5,
    name = "欢迎光临",
    optionRandom1 = {
        { id = 40061, weight = 100 },
    },
    optionRandom2 = {
        { id = 40062, weight = 100 },
    },
    optionRandom3 = {
        { id = 40063, weight = 100 },
    },
}
```

```text
optionRandom1 → 抽取第一个选项
optionRandom2 → 抽取第二个选项
optionRandom3 → 抽取第三个选项
optionStatic  → 最后追加固定选项
```

每个 `optionRandom` 列表都可以放多个 `{ id, weight }`，并在自己的位置按相对权重抽取一个。列表中只有一个候选时固定显示该选项。

`optionStatic` 填写固定追加的选项 ID 列表。没有固定选项时可以省略。

选项的消耗、奖励、节点替换和执行顺序见 [`act_option_def` 配置参考](act_option_def.md)。

## 战斗节点

`mainType = 1` 表示直接战斗。节点保存敌人、初始站位、额外晶片、战斗背景和奖励，再通过战斗选项让玩家出击。

“十字星的残响”（节点 `1416`）的主要战斗关系是：

```text
节点 1416：十字星的残响
├─ robot → Enemy 527
├─ robotInitGrid → 敌方 5 号位放置单位 527
├─ optionRandom1 → 选项 14161：出击！
└─ battleReward → 奖励组 100001 / 1014 / 1015 / 1018
```

```lua
{
    id = 1416,
    mainType = 1,
    showType = 2,
    name = "十字星的残响",
    robot = 527,
    robotInitGrid = {
        [5] = 527,
    },
    optionRandom1 = {
        { id = 14161, weight = 100 },
    },
    battleReward = { 100001, 1014, 1015, 1018 },
    skybox = "Nebula_Uluru_4K_2",
}
```

### `robot`：使用哪个敌人

`robot` 填写 `robot_def.id`。节点只保存 Enemy ID；Enemy 的卡组和行动链由 `robot_def` 与 [`robot_chain_def`](robot_chain_def.md) 决定。

战斗选项使用 `type = 3`。它只负责开始当前节点的战斗，不重复保存 Enemy 和奖励，见 [`act_option_def`](act_option_def.md#选项类型)。

### 初始站位

`robotInitGrid` 和 `playerInitGrid` 都使用“格子位置 → 单位 ID”的结构，区别只在于前者放置敌方单位，后者放置玩家单位。

“钳形战术”（节点 `1002`）指定三个敌方单位：

```lua
robotInitGrid = {
    [1] = 6028,
    [3] = 6028,
    [5] = 6027,
},
```

“序言”（节点 `1102`）同时指定敌方和玩家单位：

```lua
robotInitGrid = {
    [2] = 8010,
    [4] = 8036,
    [6] = 8036,
},
playerInitGrid = {
    [2] = 8009,
},
```

没有固定站位时省略对应字段。

### `robotChips`：敌人携带的额外晶片

“白矮星-鸣响”（节点 `5001`）让敌人携带三枚 Chip：

```lua
robotChips = { 6002, 6003, 6005 },
```

列表中的数字引用 [`chip_def.id`](chip_def.md)。晶片效果由 Chip 自己的 Skill 和 Static Skill 决定。

### `skybox`：战斗背景

`skybox` 填写游戏已有的背景名称。当前节点常用值包括：

- `Nebula_Coral_4K_1`
- `Nebula_Coral_4K_2`
- `Nebula_Coral_4K_3`
- `Nebula_Uluru_4K_2`
- `Nebula_Mirage_4K_2`
- `Dark_Erebus_4K_3`

空字符串表示不指定。填写其他值前，需要确认对应背景已经随游戏提供。

## 战斗奖励与随机规则

`battleReward` 中的每个数字是 `act_node_def.node_reward.id`，不是 `reward_def.id`：

```text
battleReward
→ node_reward.id
→ prob 判断这个奖励组是否生效
→ reward 按 weight 抽取一个 reward_def.id
→ reward_def 发放实际奖励
```

奖励组 `100001` 的配置是：

```lua
{
    id = 100001,
    prob = 100,
    reward = {
        { id = 10003, weight = 40 },
        { id = 10004, weight = 22 },
        { id = 10005, weight = 1, add = 5 },
    },
}
```

`prob = 100` 表示该奖励组必定进入抽取。进入后，再按 `40:22:1` 的相对权重选择 Reward `10003`、`10004` 或 `10005`。

### `add`：连续未抽中的权重补偿

`add` 会根据连续未抽中的次数提高候选权重：

```text
有效权重 = weight + add × 连续未抽中次数
```

Reward `10005` 初始 `weight = 1`、`add = 5`。连续未抽中一次后权重变为 `6`，连续未抽中两次后变为 `11`；抽中后累计次数重置。

奖励内容见 [`reward_def` 配置参考](reward_def.md)。

## 商店节点

`mainType = 4` 表示商店。游戏内实际使用的商队商店是节点 `3200`：

```lua
{
    id = 3200,
    mainType = 4,
    showType = 4,
    name = "商店-1",
    subheading = "商店-1",
    desc = "商队货运船通过，你可以在这里购买物资和服务。",
    summary = "商队货运船通过，你可以在这里购买物资和服务。",
    shopId = 10,
    skybox = "Nebula_Coral_4K_1",
}
```

| `shopId` | 玩家看到的商店 |
| --- | --- |
| `10` | 商队货运船 |
| `30` | 废墟商店 |

本页只说明复用已有商店。商品、价格和刷新规则由 `shopId` 对应的商店配置决定。

## 事件节点

`mainType = 5` 表示事件或抉择。普通事件使用 `showType = 5`，例如前面的“欢迎光临”（节点 `4006`）。

“补给”（节点 `2117`）仍然是相同的抉择流程，只使用 `showType = 6` 显示为补给节点：

```lua
{
    id = 2117,
    mainType = 5,
    showType = 6,
    name = "补给",
    optionRandom1 = {
        { id = 20042, weight = 100 },
    },
    optionRandom2 = {
        { id = 20043, weight = 100 },
    },
}
```

事件节点也可以保存 Enemy，并用战斗选项进入战斗。“夏洛”（节点 `4179`）就是一段带战斗结果分支的事件。

## 节点完成后如何更新

“夏洛”（节点 `4179`）根据战斗结果更新当前节点位置：

```text
节点 4179：夏洛
├─ 战斗成功 → finishReplaceNode → 节点 4096：困难模式
└─ 战斗失败 → failReplaceNode → 节点 41790：夏洛（失败结果）
```

```lua
{
    id = 4179,
    mainType = 5,
    showType = 3,
    name = "夏洛",
    subheading = "夏洛",
    desc = "“我是夏洛，Z3第三舰队指挥官。\n\n我们不必这样兵戎相见，不是吗？\n现在，你只需要交出包裹。”",
    summary = "检测到高能反应，做好战斗准备。",
    finishReplaceNode = {
        { nodeId = 4096 },
    },
    failReplaceNode = {
        { nodeId = 41790 },
    },
    battleReward = { 3144, 1029, 1015, 1019, 1014 },
    robot = 7321,
    optionRandom1 = {
        { id = 10051, weight = 100 },
    },
    skybox = "Nebula_Mirage_4K_2",
}
```

`finishReplaceNode` 与 `failReplaceNode` 都替换当前节点位置保存的节点，不会沿 `act_ep_map_def.nextNode` 前进。

## 在 MOD 中新增 `act_node_def`

节点配置文件放在：

```text
config/act_node_def/config/*.lua
```

节点奖励组放在：

```text
config/act_node_def/node_reward/*.lua
```

`act_node_def.config` 使用 `installKey = "id"`。新增节点至少填写 `id`、`mainType`、`showType` 和 `name`，再按节点类型增加：

- 战斗节点：`robot`、战斗选项，以及需要时的站位、晶片、背景和 `battleReward`。
- 商店节点：`shopId`。
- 事件节点：一个或多个选项列表。

完整的三选一事件见 [`node-pack`](../../../templates/node-pack/README.md)。Enemy 与行动链见 [`enemy-pack`](../../../templates/enemy-pack/README.md)。新增节点后，还需要通过 [`act_node_refresh_def`](act_node_refresh_def.md) 把它加入节点池。
