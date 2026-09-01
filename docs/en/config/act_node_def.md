# `act_node_def` Configuration Reference

> `act_node_def` defines the node content the player sees and executes after entering a node position.

[`act_ep_map_def`](act_ep_map_def.md) and [`act_node_refresh_def`](act_node_refresh_def.md) define routes and node pools. This page starts from what happens after the player enters a battle, shop, or event node.

## Basic Structure of `act_node_def`

**Echo of the Crux** (Node `1416`) appears as a special battle:

```lua
{
    id = 1416,
    mainType = 1,
    showType = 2,
    name = "Echo of the Crux",
    subheading = "Echo of the Crux",
    desc = "An anomalous drone built around flexible linked armaments.",
    summary = "An anomalous drone built around flexible linked armaments.",
}
```

| Field | Purpose |
| --- | --- |
| `id` | Node ID referenced by `act_node_refresh_def.nodeId` |
| `mainType` | Main flow: `1` battle, `4` shop, `5` event or choice |
| `showType` | Display type; does not change the `mainType` flow |
| `name` | Node name |
| `subheading` | Subtitle shown after entering the node |
| `desc` | Main node text |
| `summary` | Short text shown on the map or summary area |

Common `showType` values are `1` normal battle, `2` special battle, `3` important battle, `4` shop, `5` choice, and `6` supply. A supply node still uses the `mainType=5` choice flow and only changes presentation.

## How a Node Generates Options

**At Your Service** (Node `4006`) generates three options in order:

```lua
{
    id = 4006,
    mainType = 5,
    showType = 5,
    name = "At Your Service",
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
optionRandom1 → draw the first option
optionRandom2 → draw the second option
optionRandom3 → draw the third option
optionStatic  → append fixed options
```

Each `optionRandom` list may contain several `{ id, weight }` entries and draws one by relative weight for that position. A list with one candidate always displays it.

`optionStatic` is a list of fixed Option IDs appended at the end. Omit it when no fixed options are needed.

See [`act_option_def`](act_option_def.md) for costs, rewards, node replacement, and execution order.

## Battle Nodes

`mainType=1` starts a battle. The node stores the Enemy, initial positions, extra Chips, skybox, and rewards. A battle option lets the player engage.

```text
Node 1416: Echo of the Crux
├─ robot → Enemy 527
├─ robotInitGrid → place unit 527 on enemy Grid 5
├─ optionRandom1 → Option 14161: Engage!
└─ battleReward → reward groups 100001 / 1014 / 1015 / 1018
```

```lua
{
    id = 1416,
    mainType = 1,
    showType = 2,
    name = "Echo of the Crux",
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

### `robot`: Enemy ID

`robot` references `robot_def.id`. The node stores only the Enemy ID; `robot_def` and [`robot_chain_def`](robot_chain_def.md) define the Enemy deck and action chain.

A battle option uses `type=3`. It starts the battle saved by the current node and does not repeat its Enemy or rewards. See [Option Types](act_option_def.md#option-types).

### Initial Positions

`robotInitGrid` and `playerInitGrid` both map Grid position to unit ID. The first places enemy units; the second places player units.

Node `1002` places three enemy units:

```lua
robotInitGrid = {
    [1] = 6028,
    [3] = 6028,
    [5] = 6027,
},
```

Node `1102` places both enemy and player units:

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

Omit a field when no fixed position is needed.

### `robotChips`: Extra Enemy Chips

Node `5001` gives the Enemy three Chips:

```lua
robotChips = { 6002, 6003, 6005 },
```

Each number references [`chip_def.id`](chip_def.md). The Chip's own Skills and Static Skills define its behavior.

### `skybox`: Battle Background

`skybox` references an existing game background. Common values include:

- `Nebula_Coral_4K_1`
- `Nebula_Coral_4K_2`
- `Nebula_Coral_4K_3`
- `Nebula_Uluru_4K_2`
- `Nebula_Mirage_4K_2`
- `Dark_Erebus_4K_3`

An empty string selects no specific background. Confirm that any other name exists in the game.

## Battle Rewards and Random Rules

Each number in `battleReward` is an `act_node_def.node_reward.id`, not a `reward_def.id`:

```text
battleReward
→ node_reward.id
→ prob decides whether the group activates
→ reward selects one reward_def.id by weight
→ reward_def grants the result
```

Reward group `100001`:

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

`prob=100` always enters this group. The group then selects Reward `10003`, `10004`, or `10005` by relative weights `40:22:1`.

### `add`: Weight Compensation

`add` increases a candidate's weight after consecutive misses:

```text
effective weight = weight + add × consecutive misses
```

Reward `10005` starts with `weight=1, add=5`. After one miss its weight is `6`; after two misses it is `11`. The miss count resets when selected.

See [`reward_def`](reward_def.md) for reward content.

## Shop Nodes

`mainType=4` opens a shop. Node `3200` is the caravan shop used by the game:

```lua
{
    id = 3200,
    mainType = 4,
    showType = 4,
    name = "Shop-1",
    subheading = "Shop-1",
    desc = "A caravan cargo ship passes by. You can buy supplies and services here.",
    summary = "A caravan cargo ship passes by. You can buy supplies and services here.",
    shopId = 10,
    skybox = "Nebula_Coral_4K_1",
}
```

| `shopId` | Shop |
| --- | --- |
| `10` | Caravan cargo ship |
| `30` | Ruins shop |

This page covers only reusing an existing shop. Its product, price, and refresh rules come from the configuration referenced by `shopId`.

## Event Nodes

`mainType=5` creates an event or choice. A normal event uses `showType=5`, such as **At Your Service** (Node `4006`).

**Supplement** (Node `2117`) uses the same choice flow but `showType=6` for supply presentation:

```lua
{
    id = 2117,
    mainType = 5,
    showType = 6,
    name = "Supplement",
    optionRandom1 = {
        { id = 20042, weight = 100 },
    },
    optionRandom2 = {
        { id = 20043, weight = 100 },
    },
}
```

An event node may also store an Enemy and enter battle through a battle option. **Sharo** (Node `4179`) is an event with different results for victory and defeat.

## Updating a Node After Completion

**Sharo** (Node `4179`) updates the current node position based on the battle result:

```text
Node 4179: Sharo
├─ Win  → finishReplaceNode → Node 4096: Hard Mode
└─ Loss → failReplaceNode   → Node 41790: Sharo (loss result)
```

```lua
{
    id = 4179,
    mainType = 5,
    showType = 3,
    name = "Sharo",
    subheading = "Sharo",
    desc = "I am Sharo, commander of Z3's Third Fleet.\n\nWe do not have to fight. Hand over the package.",
    summary = "High-energy response detected. Prepare for battle.",
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

Both replacement fields change the node saved at the current position. They do not advance through `act_ep_map_def.nextNode`.

## Adding `act_node_def` in a MOD

Place node files under:

```text
config/act_node_def/config/*.lua
```

Place node reward groups under:

```text
config/act_node_def/node_reward/*.lua
```

`act_node_def.config` uses `installKey="id"`. A new node requires at least `id`, `mainType`, `showType`, and `name`, plus fields for its type:

- Battle node: `robot`, a battle option, and optional positions, Chips, background, and `battleReward`.
- Shop node: `shopId`.
- Event node: one or more option lists.

See [`node-pack`](../../../templates/node-pack/README.en.md) for a complete event and [`enemy-pack`](../../../templates/enemy-pack/README.en.md) for an Enemy and action chain. Add the new node to a pool through [`act_node_refresh_def`](act_node_refresh_def.md).
