# `act_card_pool_def` 配置参考

> `act_card_pool_def` 决定一张 Card 会进入哪个机体、哪个稀有度的奖励卡池。

## `act_card_pool_def` 的基本结构

`连续射击α`（Card `2061`）属于机体 `503`，自身稀有度为 `3`。把它加入卡池 `10003` 后，它会成为该机体 R Card 奖励的候选。→

```lua
{
    cardId = 2061,
    baseId = 503,
    poolId = 10003,
}
```

这条配置与 Card 本体的关系如下：

```text
连续射击α（Card 2061）
├─ card_def.rare=3
└─ act_card_pool_def.base_pool
   ├─ baseId=503
   └─ poolId=10003（R）
```

大部分时候只需要填写三个字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `cardId` | int | 要加入奖励卡池的 `card_def.cardId` |
| `baseId` | int | Card 可以从哪个机体的奖励中出现 |
| `poolId` | int | Card 要加入的稀有度卡池 |

`baseId` 决定机体范围。同一张 Card 只配置 `baseId=503` 时，不会自动进入其他机体的奖励池。

`poolId` 决定 Card 实际进入哪个池。`card_def.rare` 只记录 Card 自身稀有度，不会自动创建这条卡池成员。

## 三个常用稀有度卡池

普通 Card 奖励使用下面三个常用卡池：

| `poolId` | 稀有度 | 对应 `card_def.rare` |
| --- | --- | --- |
| `10003` | R | `3` |
| `10004` | SR | `4` |
| `10005` | EXR | `5` |

按照 Card 的 `rare` 选择相同档位的 `poolId`。例如 `rare=3` 的 Card 加入 `10003`，`rare=4` 的 Card 加入 `10004`。

Reward 通过以下结构使用卡池：

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

这会从池 `10003` 生成 3 张 Card，让玩家选择 1 张。完整写法见 [`reward_def` 配置参考](reward_def.md#card从卡池选择-card)。

## 在 MOD 中新增 `act_card_pool_def`

Card 池成员文件放在：

```text
config/act_card_pool_def/base_pool/*.lua
```

下面把 Card `910001` 加入机体 `501` 的 R Card 池。对应的 `card_def.rare` 应填写 `3`：

```lua
return {
    installKey = "poolId",
    installValue = 10003,
    rows = {
        {
            cardId = 910001,
            baseId = 501,
            poolId = 10003,
        },
    },
}
```

`installKey` 固定使用 `"poolId"`。`installValue` 指定本批次要修改的卡池，并且每一行的 `poolId` 都必须与它相同。

省略 `operation` 时默认使用 `append`，在保留原有卡池成员的同时追加 MOD Card。

只有确实需要清空并重建目标卡池时，才声明 `operation = "replace"`。这会完整替换该 `poolId` 原有的全部成员。

一张 Card 要从多个机体的奖励中出现时，为每个 `baseId` 各写一行：

```lua
return {
    installKey = "poolId",
    installValue = 10003,
    rows = {
        {
            cardId = 910001,
            baseId = 501,
            poolId = 10003,
        },
        {
            cardId = 910001,
            baseId = 503,
            poolId = 10003,
        },
    },
}
```

不同 `poolId` 不能放进一个表内；每个卡池分别提供一份 `installValue` 与行数据。

Card 本体的配置方法见 [`card_def` 配置参考](card_def.md)。可以直接运行的完整示例见 [`card-pack` 模板](../../../templates/card-pack/README.md)。
