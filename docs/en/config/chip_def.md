# `chip_def` Configuration Reference

> `chip_def` defines a Chip's display data and the battle abilities or campaign rewards it grants.

## Basic Structure of `chip_def`

**Crystal-2** (Chip `1102`) grants Static Skill `103`. The Chip stores only the ability ID; [`static_skill_def`](static_skill_def.md) defines the actual effect.

```lua
{
    id = 1102,
    name = "Crystal-2",
    descLua = {
        { desc = "chip_1102_1" },
    },
    triggerEffect = {},
    skillList = {},
    staticList = { 103 },
    pvpReplace = 0,
    assetId = 1102,
    backAssetId = 1,
    type = { 1 },
    extend = {},
    keywordList = {},
}
```

```text
Chip 1102: Crystal-2
└─ staticList → Static Skill 103
```

Provide these fields for a new `chip_def` entry:

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | positive int | Chip ID and installation key |
| `name` | string | Chip name |
| `descLua` | table[] | Description parts; `desc` may be a text key or direct text |
| `triggerEffect` | table | Campaign reward trigger; use `{}` when unused |
| `skillList` | int[] | [`battle_skill_def`](battle_skill_def.md) IDs carried into battle |
| `staticList` | int[] | [`static_skill_def`](static_skill_def.md) IDs carried into battle |
| `pvpReplace` | int | Replacement Chip ID for PVP; use `0` for a normal Chip |
| `assetId` | int | Chip icon resource ID |
| `backAssetId` | int | Chip background resource ID |
| `type` | int[] | Display category |
| `extend` | table | Additional data; use `{}` when unused |
| `keywordList` | table[] | Keywords shown in details; use `{}` when unused |

## `skillList` and `staticList`: Battle Effects

A Chip may provide both a normal Skill and a Static Skill:

- `skillList` references `battle_skill_def.skillId` for Trigger-based or actively executed Effects.
- `staticList` references `static_skill_def.id` for continuous rules.

Chip `4059` uses both entries:

```lua
skillList = { 1405901 },
staticList = { 1405951 },
```

```text
Chip 4059
├─ Skill 1405901: resolves through Trigger
└─ Static Skill 1405951: provides a continuous rule
```

The Chip only carries these abilities into battle. Configure Trigger, Target, Condition, and Effect in their own tables.

## `triggerEffect`: Campaign Effects

`triggerEffect` does not use a battle Skill. It grants rewards directly at campaign timing points.

### `key="init"`: When the Chip Is Obtained

**Armor Reinforcement** (Chip `4099`) increases maximum armor by 10 when obtained:

```lua
triggerEffect = {
    key = "init",
    reward = {
        { maxHp = { value = 10 } },
    },
},
```

`reward` uses the same structure as [`reward_def.value`](reward_def.md).

### `key="move"`: When Entering a Node

**Crystal-5** (Chip `1105`) grants 5 Nano when entering a node with `mainType` `4` or `5`:

```lua
triggerEffect = {
    key = "move",
    nodeMain = { 4, 5 },
    reward = {
        { gold = { count = 5 } },
    },
},
```

`nodeMain` filters [`act_node_def.mainType`](act_node_def.md). Use `nodeType` to filter `act_node_def.showType` instead.

### `key="battle"`: After Completing Battles

**Crystal-6** (Chip `1106`) adds Reward `1007` after every 3 completed battles:

```lua
triggerEffect = {
    key = "battle",
    process = 3,
    rewardIds = { 1007 },
},
```

`process` is the required count. After it triggers, the count starts again. `rewardIds` references [`reward_def.id`](reward_def.md).

## Display Fields

`name`, `descLua`, `assetId`, `backAssetId`, `type`, and `keywordList` control Chip list and detail display.

`descLua` may use direct text:

```lua
descLua = {
    { desc = "After every 3 completed battles, gain one extra reward." },
},
```

Each `keywordList` entry uses `keywordId`. Add `isSelf=1` when the keyword is shown as the Chip's own status:

```lua
keywordList = {
    { keywordId = 1006, isSelf = 1 },
},
```

Use an empty table for no keywords. Keep `extend={}` unless you are copying a verified special structure from an existing Chip.

## Adding `chip_def` in a MOD

Place files under:

```text
config/chip_def/config/*.lua
```

This example adds Chip `990501` and gives it Static Skill `990551`:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990501,
            name = "Example: Stable Chip",
            descLua = {
                { desc = "Gain a continuous effect after entering battle." },
            },
            triggerEffect = {},
            skillList = {},
            staticList = { 990551 },
            pvpReplace = 0,
            assetId = 1102,
            backAssetId = 1,
            type = { 1 },
            extend = {},
            keywordList = {},
        },
    },
}
```

Use `installKey="id"`. Provide Static Skill `990551` in the same MOD under `static_skill_def`.

The new Chip must also be added to [`act_chip_pool_def.base_pool`](act_chip_pool_def.md) or granted directly through [`reward_def`](reward_def.md#chip-choose-from-a-pool) before the player can obtain it.
