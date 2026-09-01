# `act_option_def` 配置参考

> `act_option_def` 定义玩家进入节点后看到的选项，以及点击后发生的消耗、战斗、节点替换和奖励。

## `act_option_def` 的基本结构

“节约成本”（选项 `14213`）：点击后获得 15 星核，并把当前节点更新为节点 `3113`。

```lua
{
    id = 14213,
    title = "节约成本",
    icon = "get_nano",
    desc = "获得15星核。",
    type = 4,
    costList = {},
    replaceNode = {
        { nodeId = 3113 },
    },
    rewardList = {
        { list = { 4001 }, weight = 107 },
    },
}
```

| 字段 | 作用 |
| --- | --- |
| `id` | 选项 ID，也是 `act_node_def` 中选项列表的引用目标 |
| `title` | 按钮标题 |
| `icon` | 按钮图标 |
| `desc` | 选项说明 |
| `type` | 点击后进入的主要流程 |
| `costList` | 选择前检查并支付的 `reward_def.cost` ID |
| `replaceNode` | 选择后替换到的节点 ID |
| `rewardList` | 选择后抽取并发放的 `reward_def.config` ID |

`id`、`title`、`icon`、`desc` 和 `type` 必须填写；其他字段没有使用时可以省略。

当前可直接复用的图标名包括：

```text
combat  trade  leave  get_ca  lose_ca  get_card  get_chip
get_item  get_nano  lose_nano  get_pilot  remove  upgrade
```

## 点击选项后的执行顺序

一次普通选项按下面的顺序处理：

```text
检查并支付 costList
→ 执行 type 对应的行为
→ 执行 replaceNode
→ 执行 rewardList
→ 判断节点是否完成
```

这个顺序决定字段如何组合。例如先支付消耗，再更新当前节点，最后发放奖励；不能用 `rewardList` 中的新资源反过来支付同一次选择的 `costList`。

## 支付消耗

“强买强卖”（选项 `40061`）先支付 Cost `1009`，再发放 Reward `4110`：

```lua
{
    id = 40061,
    title = "强买强卖",
    icon = "trade",
    desc = "<color=#FFB347>消耗100星核</color> 获得[#PLAYER_CARD]",
    type = 4,
    costList = { 1009 },
    rewardList = {
        { list = { 4110 }, weight = 100 },
    },
}
```

`costList` 填写 [`reward_def.cost`](reward_def.md#cost消耗) 的 ID。列表中存在多个 Cost 时，会先检查全部消耗；只有全部满足才依次支付。任意一项不满足时，不支付其中任何一项，也不继续执行选项结果。

## 选项类型

当前普通节点使用两种选项类型：

| `type` | 玩家结果 |
| --- | --- |
| `3` | 开始所属节点保存的战斗 |
| `4` | 普通选择，继续执行节点替换和奖励 |

“十字星的残响”使用选项 `14161` 开始战斗：

```lua
{
    id = 14161,
    title = "出击！",
    icon = "combat",
    desc = "出击！",
    type = 3,
}
```

```text
节点 1416：十字星的残响
├─ Enemy、站位和战斗奖励
└─ 选项 14161：出击！
   └─ type = 3 → 开始节点 1416 的战斗
```

战斗使用的 Enemy、站位和奖励都来自所属 [`act_node_def`](act_node_def.md#战斗节点)，不写在选项中。

`type = 4` 不启动独立系统流程，会继续处理当前选项的 `replaceNode` 和 `rewardList`。前面的“节约成本”和“强买强卖”都属于这一类型。

## 替换节点

拍卖会中的“参与竞拍”（选项 `42351`）支付 30 星核后，把当前节点位置更新为节点 `42351`：

```lua
{
    id = 42351,
    title = "参与竞拍",
    icon = "trade",
    desc = "<color=#FFB347>消耗30星核</color>，参与竞拍，获得随机奖励。",
    type = 4,
    costList = { 3030 },
    replaceNode = {
        { nodeId = 42351 },
    },
}
```

```text
节点 4235：拍卖会！
└─ 选项 42351：参与竞拍
   └─ replaceNode → 节点 42351：竞拍后续流程
```

`replaceNode` 替换当前节点位置保存的节点，并生成新节点的选项。节点位置不变，也不会沿 `act_ep_map_def.nextNode` 前进。

## 发放奖励

`rewardList` 统一使用下面的结构：

```lua
rewardList = {
    { list = { 奖励ID }, weight = 相对权重 },
}
```

游戏先按外层 `weight` 选择一个结果组，再发放该组 `list` 中的全部 Reward。

### 固定一个 Reward

“节约成本”（选项 `14213`）只有一个结果组，固定发放 Reward `4001`：

```lua
rewardList = {
    { list = { 4001 }, weight = 107 },
}
```

只有一个外层结果组时，`weight` 的绝对数值不会与其他组比较。

### 从多个结果组中抽取一个

“开箱查看”（选项 `423561`）从三组结果中按 `2:2:2` 抽取一组：

```lua
rewardList = {
    { list = { 3146 }, weight = 2 },
    { list = { 3148 }, weight = 2 },
    { list = { 3149 }, weight = 2 },
}
```

`weight` 是相对权重，不是百分比。

### 一个结果组发放多个 Reward

“获取”（选项 `42741`）在一个结果组中同时发放三个 Reward：

```lua
rewardList = {
    { list = { 3055, 3056, 3057 }, weight = 50 },
}
```

抽中一个结果组后，`list` 中的 ID 会全部执行。每个 Reward 的具体内容仍在 [`reward_def`](reward_def.md) 中分别定义。

## 选择前查看详情

`heroId`、`cardId` 和 `chipId` 只控制玩家点击选项时打开的详情，不会发放对应内容。

“邀请冬子”（选项 `31061`）展示机师 `103`，实际加入队伍由 Reward `2177` 完成：

```lua
heroId = 103,
rewardList = {
    { list = { 2177 }, weight = 165 },
},
```

“进行交易”（选项 `31062`）展示 Card `7010`，实际获得 Card 由 Reward `2185` 完成：

```lua
cardId = 7010,
rewardList = {
    { list = { 2185 }, weight = 166 },
},
```

“直接冲过去”（选项 `42272`）展示 Chip `4056`，实际获得 Chip 由 Reward `3035` 完成：

```lua
chipId = 4056,
rewardList = {
    { list = { 3035 }, weight = 50 },
},
```

只填写详情 ID 而没有对应 `rewardList` 时，玩家可以查看内容，但不会获得它。

## 选项什么时候完成

`type = 4` 的选项会等待消耗、节点替换和奖励处理结束。奖励仍要求玩家继续选择时，节点会等待这次奖励完成。

`type = 3` 的选项会等待战斗结果，再由节点决定成功、失败和后续更新。

## 在 MOD 中新增 `act_option_def`

配置文件放在：

```text
config/act_option_def/config/*.lua
```

每个批次使用 `installKey = "id"`：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990201,
            title = "打开补给箱",
            icon = "get_nano",
            desc = "获得15星核。",
            type = 4,
            rewardList = {
                { list = { 4001 }, weight = 100 },
            },
        },
    },
}
```

新增选项后，通过 `act_node_def.optionRandom1/2/3` 或 `optionStatic` 引用它。完整三选一事件见 [`node-pack`](../../../templates/node-pack/README.md)；战斗 Enemy 与行动链见 [`enemy-pack`](../../../templates/enemy-pack/README.md)。
