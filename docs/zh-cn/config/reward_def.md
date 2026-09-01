# `reward_def` 配置参考

## `reward_def` 的基本结构

`reward_def` 定义两类内容：

```text
reward_def/config：玩家获得的奖励
reward_def/cost：玩家选择 Option 时支付的消耗
```

[`act_option_def.rewardList`](act_option_def.md#奖励rewardlist) 引用 `config` Sheet；[`act_option_def.costList`](act_option_def.md#消耗costlist) 引用 `cost` Sheet。战斗奖励也会通过 [`act_node_def.node_reward`](act_node_def.md#战斗奖励与随机规则) 最终引用 `config` Sheet。

## `config`：奖励

Reward `4004`：获得 30 星核。→

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 4004,
            title = "星火币+30",
            icon = "image_decision",
            value = {
                { gold = { count = 30 } },
            },
            cardId = 0,
            chipId = 0,
            itemId = 0,
        },
    },
}
```

| 字段 | 作用 |
| --- | --- |
| `id` | Reward ID，由 `rewardList` 或 `node_reward.reward.id` 引用 |
| `title` | 奖励名称 |
| `icon` | 奖励结果界面使用的图标 |
| `value` | 实际执行的奖励结果列表 |
| `cardId` | 结果界面展示的 Card；不展示时填 `0` |
| `chipId` | 结果界面展示的 Chip；不展示时填 `0` |
| `itemId` | 结果界面展示的 Battle Item；不展示时填 `0` |

每条 `config` 配置都必须填写以上字段；不展示对应详情时，将 `cardId`、`chipId`、`itemId` 填写为 `0`。

`config.value` 是结果列表。每一项的结果名称决定参数如何解释；同一个 Reward 可以写入多项结果。运行时会执行全部结果，但不要依赖它们的执行先后。

## 常用奖励结果

| 结果 | 游戏内作用 |
| --- | --- |
| [`gold`](#gold获得星核) | 获得星核 |
| [`hp`](#hp恢复-ca) | 恢复 CA |
| [`card`](#card从卡池选择-card) | 获得或选择 Card |
| [`cardUpgrade`](#cardupgrade升级-card) | 升级 Card |
| [`cardDelete`](#carddelete删除-card) | 删除 Card |
| [`chip`](#chip从晶片池选择-chip) | 获得或选择 Chip |
| [`battleItem`](#battleitem获得-battle-item) | 获得 Battle Item |
| [`hero`](#hero获得机师) | 获得机师 |

### `gold`：获得星核

Reward `4004` 获得 30 星核：

```lua
value = {
    { gold = { count = 30 } },
}
```

`count` 是获得数量。

### `hp`：恢复 CA

Reward `2125` 恢复 5 点 CA：

```lua
value = {
    { hp = { value = 5 } },
}
```

`value` 是恢复的固定数值。恢复全部 CA 时使用：

```lua
value = {
    { hp = { percent = 100 } },
}
```

### `card`：从卡池选择 Card

Reward `10003` 从 R Card 池生成 3 张 Card，让玩家选择 1 张：

```lua
value = {
    {
        card = {
            count = 3,
            choose = 1,
            pool = { 10003 },
        },
    },
}
```

- `count`：生成的候选数量。
- `choose`：玩家可以选择的数量。
- `pool`：引用 [`act_card_pool_def.base_pool`](act_card_pool_def.md)。

如果已经确定要发放哪张 Card，也可以直接填写 `id`：

```lua
{ card = { id = 2025, count = 4 } }
```

此时 `id` 是 `card_def.cardId`，`count` 是发放数量，不再经过卡池。

### `cardUpgrade`：升级 Card

Reward `4101` 让玩家选择一张 Card 升级：

```lua
value = {
    { cardUpgrade = {} },
}
```

### `cardDelete`：删除 Card

Reward `4102` 让玩家删除一张 Card：

```lua
value = {
    { cardDelete = { count = 1 } },
}
```

`count` 是删除数量。

### `chip`：从晶片池选择 Chip

Reward `2127` 从 Chip 池 `20` 生成 3 个 Chip，让玩家选择 1 个：

```lua
value = {
    {
        chip = {
            count = 3,
            choose = 1,
            pool = { 20 },
        },
    },
}
```

- `count`：生成的候选数量。
- `choose`：玩家可以选择的数量。
- `pool`：引用 [`act_chip_pool_def.base_pool`](act_chip_pool_def.md)。

### `battleItem`：获得 Battle Item

Reward `2130` 获得一个 Battle Item `3001`：

```lua
value = {
    { battleItem = { id = 3001, count = 1 } },
}
```

`id` 引用 `battle_item_def.id`，`count` 是获得数量。可复用 ID 见 [`battle_item_def` 配置参考](battle_item_def.md)。如果要在结果界面展示该 Battle Item，同一条 Reward 的 `itemId` 也填写 `3001`。

### `hero`：获得机师

Reward `2174` 获得机师 `100`：

```lua
value = {
    { hero = { id = 100 } },
}
```

`id` 是获得的机师 ID。该 Reward 的 `cardId = 7000` 只负责在结果界面展示对应的机师 Card。

## 一个 Reward 组合多个结果

Reward `6013` 同时获得机师 `21085` 和 4 张 Card `2025`：

```lua
{
    id = 6013,
    title = "获得机师[另一位邮差]+标准无人机×4",
    icon = "image_decision",
    value = {
        { hero = { id = 21085 } },
        { card = { id = 2025, count = 4 } },
    },
    cardId = 21085,
    chipId = 0,
    itemId = 0,
}
```

两项结果都会执行。每项结果单独写在 `value` 列表中，结构比把多种结果混在同一个表中更清楚。

## `cost`：消耗

Cost 只包含 `id` 和 `value`。下面是 Cost `3030` 的完整配置：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 3030,
            value = {
                gold = { count = 30 },
            },
        },
    },
}
```

与奖励不同，Cost 的 `value` 直接填写消耗类型，不需要再套一层结果列表。

### `gold`：消耗星核

Cost `3030` 消耗 30 星核：

```lua
value = {
    gold = { count = 30 },
}
```

### `hp`：损失 CA

Cost `3015` 损失 15 点 CA：

```lua
value = {
    hp = { count = 15 },
}
```

CA 消耗不能让玩家降到 `0`。如果当前 CA 不足以支付并至少保留 `1` 点，这个 Option 不会继续执行。

## 在 MOD 中新增 `reward_def`

奖励和消耗分别放在：

```text
config/reward_def/config/*.lua
config/reward_def/cost/*.lua
```

两个 Sheet 都使用 `installKey = "id"`。`config` 和 `cost` 可以使用相同的数字 ID，因为它们属于两个独立的 Sheet。

在 Option 中通过 `costList` 和 `rewardList` 引用新增的 ID：

```lua
costList = { 3030 },
rewardList = {
    {
        weight = 100,
        rewards = {
            list = { 4004 },
        },
    },
},
```

如果 `costList` 中包含多个 Cost ID，系统会先检查所有消耗。只有全部满足时才会统一支付，然后继续执行 Option；任意一项不足都不会先扣除其他消耗。

`rewardList` 的固定发放、加权抽取和多项发放写法见 [`act_option_def` 配置参考](act_option_def.md#奖励rewardlist)。
