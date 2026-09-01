# `act_option_def` Configuration Reference

> `act_option_def` defines options shown after entering a node and the costs, battle, node replacement, and rewards produced by a click.

## Basic Structure of `act_option_def`

**Cut the Cost** (Option `14213`) grants 15 Nano and replaces the current node with Node `3113`:

```lua
{
    id = 14213,
    title = "Cut the Cost",
    icon = "get_nano",
    desc = "Gain 15 Nano.",
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

| Field | Purpose |
| --- | --- |
| `id` | Option ID referenced by option lists in `act_node_def` |
| `title` | Button title |
| `icon` | Button icon |
| `desc` | Option description |
| `type` | Main flow after clicking |
| `costList` | `reward_def.cost` IDs checked and paid first |
| `replaceNode` | Node IDs that replace the current node |
| `rewardList` | `reward_def.config` IDs selected and granted |

`id`, `title`, `icon`, `desc`, and `type` are required. Omit other fields when unused.

Reusable icon names include:

```text
combat  trade  leave  get_ca  lose_ca  get_card  get_chip
get_item  get_nano  lose_nano  get_pilot  remove  upgrade
```

## Execution Order After Clicking

```text
Check and pay costList
→ Execute the flow selected by type
→ Execute replaceNode
→ Execute rewardList
→ Decide whether the node is complete
```

The order matters. A reward granted by this option cannot be used to pay the same option's `costList`.

## Paying Costs

**Forced Transaction** (Option `40061`) pays Cost `1009` and then grants Reward `4110`:

```lua
{
    id = 40061,
    title = "Forced Transaction",
    icon = "trade",
    desc = "<color=#FFB347>Spend 100 Nano</color> Gain [#PLAYER_CARD]",
    type = 4,
    costList = { 1009 },
    rewardList = {
        { list = { 4110 }, weight = 100 },
    },
}
```

`costList` contains [`reward_def.cost`](reward_def.md#cost-costs) IDs. When several Costs are listed, the game checks all of them first. If one cannot be paid, none are deducted and the option does not continue.

## Option Types

Normal nodes use two option types:

| `type` | Player result |
| --- | --- |
| `3` | Start the battle saved by the owning node |
| `4` | Normal choice; continue with node replacement and rewards |

**Echo of the Crux** uses Option `14161` to start battle:

```lua
{
    id = 14161,
    title = "Engage!",
    icon = "combat",
    desc = "Engage!",
    type = 3,
}
```

```text
Node 1416: Echo of the Crux
├─ Enemy, positions, and battle rewards
└─ Option 14161: Engage!
   └─ type=3 → start Node 1416's battle
```

Enemy, positions, and rewards come from the owning [`act_node_def`](act_node_def.md#battle-nodes), not the option.

`type=4` starts no separate system flow and continues to `replaceNode` and `rewardList`. **Cut the Cost** and **Forced Transaction** use this type.

## Replacing the Current Node

**Participate in the Auction** (Option `42351`) spends 30 Nano and changes the current position to Node `42351`:

```lua
{
    id = 42351,
    title = "Participate in the Auction",
    icon = "trade",
    desc = "<color=#FFB347>Spend 30 Nano</color> to participate and gain a random reward.",
    type = 4,
    costList = { 3030 },
    replaceNode = {
        { nodeId = 42351 },
    },
}
```

```text
Node 4235: Auction!
└─ Option 42351: Participate in the Auction
   └─ replaceNode → Node 42351: auction follow-up
```

`replaceNode` changes the node saved at the current node position and generates the new node's options. It does not move along `act_ep_map_def.nextNode`.

## Granting Rewards

`rewardList` uses this structure:

```lua
rewardList = {
    { list = { REWARD_ID }, weight = RELATIVE_WEIGHT },
}
```

The game selects one outer result group by `weight`, then grants every Reward in that group's `list`.

### One Fixed Reward

**Cut the Cost** has one group and always grants Reward `4001`:

```lua
rewardList = {
    { list = { 4001 }, weight = 107 },
}
```

With only one outer group, the absolute `weight` is not compared against anything else.

### Select One Result Group

**Opening the Box** (Option `423561`) selects one of three groups at relative weights `2:2:2`:

```lua
rewardList = {
    { list = { 3146 }, weight = 2 },
    { list = { 3148 }, weight = 2 },
    { list = { 3149 }, weight = 2 },
}
```

`weight` is relative, not a percentage.

### Grant Several Rewards from One Group

Option `42741` grants three Rewards from one result group:

```lua
rewardList = {
    { list = { 3055, 3056, 3057 }, weight = 50 },
}
```

After a group is selected, every ID in `list` executes. Each Reward is defined separately in [`reward_def`](reward_def.md).

## Viewing Details Before Selection

`heroId`, `cardId`, and `chipId` only open details when the player clicks an option. They do not grant the referenced content.

**Invite Fuyuko** (Option `31061`) shows pilot `103`; Reward `2177` actually adds the pilot:

```lua
heroId = 103,
rewardList = {
    { list = { 2177 }, weight = 165 },
},
```

**Initiate Transaction** (Option `31062`) shows Card `7010`; Reward `2185` grants it:

```lua
cardId = 7010,
rewardList = {
    { list = { 2185 }, weight = 166 },
},
```

**Charge!** (Option `42272`) shows Chip `4056`; Reward `3035` grants it:

```lua
chipId = 4056,
rewardList = {
    { list = { 3035 }, weight = 50 },
},
```

Without a matching `rewardList`, the player may view the content but does not receive it.

## When an Option Completes

A `type=4` option waits for costs, replacement, and rewards to finish. If a reward still requires a player choice, the node waits for that choice.

A `type=3` option waits for the battle result. The node then handles victory, defeat, and later replacement.

## Adding `act_option_def` in a MOD

Place files under:

```text
config/act_option_def/config/*.lua
```

Use `installKey="id"`:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990201,
            title = "Open Supply Crate",
            icon = "get_nano",
            desc = "Gain 15 Nano.",
            type = 4,
            rewardList = {
                { list = { 4001 }, weight = 100 },
            },
        },
    },
}
```

Reference the Option through `act_node_def.optionRandom1/2/3` or `optionStatic`. See [`node-pack`](../../../templates/node-pack/README.en.md) for a complete event and [`enemy-pack`](../../../templates/enemy-pack/README.en.md) for an Enemy and action chain.
