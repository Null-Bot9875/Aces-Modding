# `act_chip_pool_def` Configuration Reference

> `act_chip_pool_def.base_pool` decides which base and reward pool may contain a Chip, and the base levels and Acts where it may appear.

This page covers only `base_pool`.

## Basic Structure of `act_chip_pool_def`

Chip `4000` enters pool `20` for base `501` at levels `1` through `10`, limited to Acts `104`, `105`, and `106`:

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

| Field | Purpose |
| --- | --- |
| `chipId` | `chip_def.id` to add to the pool |
| `baseId` | Base whose rewards may contain the Chip |
| `poolId` | Pool ID referenced by a Chip reward |
| `minBaseLevel` | Minimum base level |
| `maxBaseLevel` | Maximum base level |
| `limitActIds` | Allowed Acts; an empty table adds no Act restriction |

## Adding `act_chip_pool_def` in a MOD

Place files under:

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

`installValue` and every row's `poolId` must match. `append` preserves existing members and adds the MOD Chip.

To support several bases, add one row for each `baseId`. Put different `poolId` values in separate files.

A Reward uses pool `20` like this:

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

`count` is the number of candidates and `choose` is the number the player may select. See [Chip: Choose from a Pool](reward_def.md#chip-choose-from-a-pool) and [`chip_def`](chip_def.md).
