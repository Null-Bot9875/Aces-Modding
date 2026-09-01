# `reward_def` Configuration Reference

## Basic Structure of `reward_def`

`reward_def` defines two kinds of entries:

```text
reward_def/config: rewards granted to the player
reward_def/cost: costs paid when the player selects an option
```

[`act_option_def.rewardList`](act_option_def.md#granting-rewards) references the `config` sheet. [`act_option_def.costList`](act_option_def.md#paying-costs) references the `cost` sheet. Battle rewards also reach the `config` sheet through [`act_node_def.node_reward`](act_node_def.md#battle-rewards-and-random-rules).

## `config`: Rewards

Reward `4004` grants 30 Nano:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 4004,
            title = "Nano +30",
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

| Field | Purpose |
| --- | --- |
| `id` | Reward ID referenced by `rewardList` or `node_reward.reward.id` |
| `title` | Reward name |
| `icon` | Icon shown on the reward result screen |
| `value` | List of reward results to execute |
| `cardId` | Card shown on the result screen; use `0` for none |
| `chipId` | Chip shown on the result screen; use `0` for none |
| `itemId` | Battle Item shown on the result screen; use `0` for none |

Every `config` entry must provide all of these fields. Use `0` for `cardId`, `chipId`, or `itemId` when no corresponding detail should be shown.

`config.value` is a list of results. Each result name determines how its parameters are read. A Reward may contain several results; all of them execute, but do not rely on their execution order.

## Common Reward Results

| Result | Game result |
| --- | --- |
| [`gold`](#gold-grant-nano) | Grant Nano |
| [`hp`](#hp-restore-ca) | Restore CA |
| [`card`](#card-choose-from-a-pool) | Grant or choose a Card |
| [`cardUpgrade`](#cardupgrade-upgrade-a-card) | Upgrade a Card |
| [`cardDelete`](#carddelete-delete-a-card) | Delete a Card |
| [`chip`](#chip-choose-from-a-pool) | Grant or choose a Chip |
| [`battleItem`](#battleitem-grant-a-battle-item) | Grant a Battle Item |
| [`hero`](#hero-grant-a-pilot) | Grant a pilot |

### `gold`: Grant Nano

Reward `4004` grants 30 Nano:

```lua
value = {
    { gold = { count = 30 } },
}
```

`count` is the amount granted.

### `hp`: Restore CA

Reward `2125` restores 5 CA:

```lua
value = {
    { hp = { value = 5 } },
}
```

`value` is a fixed amount. To restore all CA:

```lua
value = {
    { hp = { percent = 100 } },
}
```

### `card`: Choose from a Pool

Reward `10003` generates 3 Cards from R Card pool `10003` and lets the player choose 1:

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

- `count`: number of candidates.
- `choose`: number the player may select.
- `pool`: references [`act_card_pool_def.base_pool`](act_card_pool_def.md).

To grant a specific Card without a pool, provide `id`:

```lua
{ card = { id = 2025, count = 4 } }
```

`id` is `card_def.cardId`; `count` is the amount granted.

### `cardUpgrade`: Upgrade a Card

Reward `4101` lets the player choose a Card to upgrade:

```lua
value = {
    { cardUpgrade = {} },
}
```

### `cardDelete`: Delete a Card

Reward `4102` lets the player delete one Card:

```lua
value = {
    { cardDelete = { count = 1 } },
}
```

`count` is the number to delete.

### `chip`: Choose from a Pool

Reward `2127` generates 3 Chips from Chip pool `20` and lets the player choose 1:

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

- `count`: number of candidates.
- `choose`: number the player may select.
- `pool`: references [`act_chip_pool_def.base_pool`](act_chip_pool_def.md).

### `battleItem`: Grant a Battle Item

Reward `2130` grants Battle Item `3001`:

```lua
value = {
    { battleItem = { id = 3001, count = 1 } },
}
```

`id` references `battle_item_def.id`; `count` is the amount. To show the item on the result screen, also set the Reward's `itemId=3001`.

### `hero`: Grant a Pilot

Reward `2174` grants pilot `100`:

```lua
value = {
    { hero = { id = 100 } },
}
```

`id` is the pilot ID. This Reward's `cardId=7000` is used only to show the matching pilot Card on the result screen.

## Combining Several Results in One Reward

Reward `6013` grants pilot `21085` and 4 copies of Card `2025`:

```lua
{
    id = 6013,
    title = "Gain pilot and four standard drones",
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

Both results execute. Put each result in its own item in the `value` list.

## `cost`: Costs

A Cost contains only `id` and `value`. Cost `3030` is a complete example:

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

Unlike a Reward, Cost `value` contains the cost type directly instead of a list of results.

### `gold`: Spend Nano

```lua
value = {
    gold = { count = 30 },
}
```

### `hp`: Lose CA

Cost `3015` removes 15 CA:

```lua
value = {
    hp = { count = 15 },
}
```

A CA cost cannot reduce the player to `0`. If the player cannot pay while keeping at least 1 CA, the option does not continue.

## Adding `reward_def` in a MOD

Place rewards and costs under:

```text
config/reward_def/config/*.lua
config/reward_def/cost/*.lua
```

Both sheets use `installKey="id"`. The `config` and `cost` sheets may reuse the same numeric ID because they are separate sheets.

Reference new IDs from an option through `costList` and `rewardList`:

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

When `costList` contains several Cost IDs, the game checks all of them before paying any cost. If one cannot be paid, the other costs are not deducted.

See [Granting Rewards](act_option_def.md#granting-rewards) for fixed rewards, weighted groups, and several Rewards in one result group.
