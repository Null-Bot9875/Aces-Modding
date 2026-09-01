# `act_chip_pool_def` 配置参考

`act_chip_pool_def.base_pool` 决定一个 Chip 会进入哪个机体、哪个奖励池，以及在哪些等级和战役中可以出现。

本页只说明 `base_pool`。

## `act_chip_pool_def` 的基本结构

Chip `4000` 在机体 `501`、等级 `1–10` 时进入池 `20`，并限制在 Act `104`、`105`、`106`：

```lua
{
    chipId = 4000,
    baseId = 501,
    poolId = 20,
    minBaseLevel = 1,
    maxBaseLevel = 10,
    limitActIds = { 104, 105, 106 },
}
```

| 字段 | 作用 |
| --- | --- |
| `chipId` | 要加入池的 `chip_def.id` |
| `baseId` | 可以从哪个机体的奖励中出现 |
| `poolId` | Chip 奖励引用的池 ID |
| `minBaseLevel` | 机体最低等级 |
| `maxBaseLevel` | 机体最高等级 |
| `limitActIds` | 允许出现的 Act；空表表示不增加 Act 限制 |

## 在 MOD 中新增 `act_chip_pool_def`

文件放在：

```text
config/act_chip_pool_def/base_pool/*.lua
```

```lua
return {
    installKey = "poolId",
    installValue = 20,
    operation = "append",
    rows = {
        {
            chipId = 990501,
            baseId = 501,
            poolId = 20,
            minBaseLevel = 1,
            maxBaseLevel = 10,
            limitActIds = { 106 },
        },
    },
}
```

`installValue` 和每一行的 `poolId` 必须相同。`append` 保留现有池成员，并加入 MOD Chip。

一枚 Chip 需要从多个机体的奖励中出现时，为每个 `baseId` 各写一行。不同 `poolId` 分成不同批次。

Reward 通过以下结构使用池 `20`：

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

`count` 决定生成几个候选，`choose` 决定玩家选择几个。完整奖励写法见 [`reward_def` 配置参考](reward_def.md#chip从晶片池选择-chip)，Chip 本体字段见 [`chip_def` 配置参考](chip_def.md)。
