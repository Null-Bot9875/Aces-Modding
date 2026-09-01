# `act_card_pool_def` Configuration Reference

> `act_card_pool_def` decides which base and rarity reward pool can contain a Card.

## Basic Structure of `act_card_pool_def`

**Continuous Shot α** (Card `2061`) belongs to base `503` and has rarity `3`. Adding it to pool `10003` makes it a candidate for that base's R Card rewards.

```lua
{
    cardId = 2061,
    baseId = 503,
    poolId = 10003,
}
```

```text
Continuous Shot α (Card 2061)
├─ card_def.rare=3
└─ act_card_pool_def.base_pool
   ├─ baseId=503
   └─ poolId=10003 (R)
```

Most entries need only three fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `cardId` | int | `card_def.cardId` to add to the reward pool |
| `baseId` | int | Base whose rewards may contain the Card |
| `poolId` | int | Rarity pool to add the Card to |

`baseId` limits the compatible base. An entry with only `baseId=503` does not add the Card to rewards for other bases.

`poolId` chooses the actual pool. `card_def.rare` records the Card's rarity but does not create a pool entry automatically.

## Three Common Rarity Pools

Normal Card rewards use these pools:

| `poolId` | Rarity | Matching `card_def.rare` |
| --- | --- | --- |
| `10003` | R | `3` |
| `10004` | SR | `4` |
| `10005` | EXR | `5` |

Choose the `poolId` that matches the Card's `rare`. For example, add `rare=3` to `10003` and `rare=4` to `10004`.

A Reward uses a Card pool like this:

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

This generates 3 Cards from pool `10003` and lets the player choose 1. See [Card: Choose from a Pool](reward_def.md#card-choose-from-a-pool).

## Adding `act_card_pool_def` in a MOD

Place Card pool entries under:

```text
config/act_card_pool_def/base_pool/*.lua
```

This example adds Card `910001` to base `501`'s R Card pool. Its `card_def.rare` should be `3`:

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

Use `installKey="poolId"`. `installValue` selects the pool being changed, and every row must use the same `poolId`.

When `operation` is omitted, this sheet defaults to `append`. Existing members remain and the MOD Card is added.

Use `operation="replace"` only when you intend to rebuild the entire target pool. It removes all existing members of that `poolId`.

To make one Card available to several bases, add one row for each `baseId`:

```lua
return {
    installKey = "poolId",
    installValue = 10003,
    rows = {
        { cardId = 910001, baseId = 501, poolId = 10003 },
        { cardId = 910001, baseId = 503, poolId = 10003 },
    },
}
```

Put different `poolId` values in separate files, each with its own `installValue`.

See [`card_def`](card_def.md) for the Card itself. A complete runnable example is available in [`card-pack`](../../../templates/card-pack/README.en.md).
