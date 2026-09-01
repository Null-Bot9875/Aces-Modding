# `robot_chain_def` Configuration Reference

> Chain defines which Cards an Enemy prepares on each action round and how Conditions and weights select among candidates.

## Basic Structure of `robot_chain_def`

In [`enemy-pack`](../../../templates/enemy-pack/README.en.md), Enemy `11999` uses Chain `1999`. It uses Card `21007` on Enemy rounds 1 and 3, and Card `21006` on rounds 2 and 4.

```text
Enemy 11999
  -> Chain 1999
     -> Round 1: action pool 990201 -> Card 21007
     -> Round 2: action pool 990202 -> Card 21006
     -> Repeat every two rounds
```

Keep three IDs separate:

```text
Chain: chainId=1999 selects a round sequence
Action pool: poolId=990201/990202 contains candidates for one round
Action entry: id=990301/990302 identifies the selected Card action
```

The complete files are in [`enemy-pack`](../../../templates/enemy-pack/README.en.md).

## Chain in the Reference Path

```text
Battle Node
  -> act_node_def.robot
  -> robot_def.chainId
  -> robot_chain_def.sequence
       -> poolId
       -> robot_chain_def.config
            -> cardId
            -> Card -> Skill -> Target / Effect
```

`robot_def.chainId` is the Chain entry for a normal Enemy. The Chain still executes Cards, so their costs, Targets, Skills, Effects, and presentation must work with automatic Enemy use.

## Two Sheets with Different Jobs

`robot_chain_def` has two independent sheets and requires separate installation groups:

| Sheet | Directory | `installKey` | Installation group | Purpose |
| --- | --- | --- | --- | --- |
| Round sequence | `config/robot_chain_def/sequence/` | `"chainId"` | Complete ordered rows for one `chainId` | Select action pools for the current round |
| Action pool | `config/robot_chain_def/config/` | `"poolId"` | All candidate rows for one `poolId` | Conditions, weight, and final Card |

Do not combine both sheets into one file. One action pool may be shared by several Chains; replacing a `sequence` does not replace the pools it references.

Existing configuration contains shared pools. For example, pools `170` and `171` are referenced by both Chains `1140` and `21000`. Existing IDs are specific to the current game version and are not stable cross-version constants.

Examples omit `operation`, which defaults to `replace`:

- A new `chainId` or `poolId` creates a new group.
- Reusing an existing group replaces all rows in that group.
- Use `append` only when you intentionally add candidates to an existing group.
- Prefer new Chain and action pool IDs for independent content.

## Round Sequence: `robot_chain_def.sequence`

File location:

```text
config/robot_chain_def/sequence/two_round_cycle.lua
```

Complete two-round loop:

```lua
return {
    installKey = "chainId",
    installValue = 1999,
    rows = {
        {
            chainId = 1999,
            seqType = 2,
            round = 1,
            circle = 2,
            poolId = 990201,
        },
        {
            chainId = 1999,
            seqType = 2,
            round = 2,
            circle = 2,
            poolId = 990202,
        },
    },
}
```

### Round Sequence Fields

| Field | Type | Meaning | Rule |
| --- | --- | --- | --- |
| `chainId` | int | Chain group ID | Every row must equal the file's `installValue` |
| `seqType` | int | Round matching mode | Supported values are `1` and `2` |
| `round` | int | Exact round or position in a loop | Read together with `seqType` and `circle` |
| `circle` | int | Loop length | Must be positive for `seqType=2` |
| `poolId` | int | Action pool read when the row matches | References `robot_chain_def.config.poolId` |

`sequence` rows have no `id`. Do not copy an auxiliary `id` from old exports or another sheet.

`rows` is ordered. One logical round may match several rows and prepare several pools in that order. Keep it as a list; do not convert it into a table keyed by `round` or `poolId`, and do not expect the game to sort it.

### Looping Rounds: `seqType=2`

`seqType=2` loops by `circle`:

```text
loop position = ((Enemy action round - 1) % circle) + 1
```

A row matches when its `round` equals the loop position.

For `circle=2`:

| Enemy action round | Loop position | Action pool |
| ---: | ---: | --- |
| 1 | 1 | `990201` |
| 2 | 2 | `990202` |
| 3 | 1 | `990201` |
| 4 | 2 | `990202` |

`enemy-pack` uses `seqType=2, circle=2`. Do not use `circle=0` with `seqType=2`.

### Exact Rounds: `seqType=1`

`seqType=1` matches only when the Enemy action round equals `round`. It is useful for a non-looping sequence such as preparation on round 1 and attack on round 2.

```lua
{
    chainId = 990001,
    seqType = 1,
    round = 1,
    circle = 0,
    poolId = 990101,
}
```

A round with no matching row receives no action pool from this Chain. Existing configuration uses both `seqType=1` and `2`; follow the Chain you are using as a reference.

Do not mix `seqType=1` and `2` in one `chainId`. The game uses the first matching type during a refresh and skips the other, making the result depend on row order.

## Action Pool: `robot_chain_def.config`

File location:

```text
config/robot_chain_def/config/round_1_buffer.lua
```

Complete action pool:

```lua
return {
    installKey = "poolId",
    installValue = 990201,
    rows = {
        {
            id = 990301,
            type = 1,
            poolId = 990201,
            weight = 1,
            useConditions = {},
            cardId = 21007,
            assetId = "buff_1",
            extend = {},
        },
    },
}
```

### Action Pool Fields

| Field | Type | Meaning | Rule |
| --- | --- | --- | --- |
| `id` | int | Unique action entry ID | Must be unique across the whole `robot_chain_def.config` table |
| `type` | int | Action entry type | Keep `1` for new content |
| `poolId` | int | Action pool group ID | Every row must equal the file's `installValue` |
| `weight` | int | Relative weight after Conditions pass | Use a positive integer; compared within the pool |
| `useConditions` | list<int> | Battle Conditions required by this action | Empty means no extra Condition; see [`battle_condition_def`](battle_condition_def.md) |
| `cardId` | int | Card executed by the Enemy | Reuse a Card from the same game version and test automatic targeting and resolution |
| `assetId` | string | Existing action chain icon reference | Reuse a confirmed value; a new string does not create a resource |
| `extend` | lua | Additional list presentation data | Use `{}` for a normal action |

The selected `id` is saved in the pending Chain and queried again by battle logic and UI. A duplicate or missing `id` can break both execution and display.

Keep normal actions at `type=1`. Do not infer new action types from unrelated numeric values.

### How Conditions and Weight Select a Card

Each matched `poolId` selects at most one action:

```text
Read all rows in the action pool
  -> Remove rows whose useConditions fail
  -> Select from remaining rows by weight
  -> Save the selected row's id
  -> Execute its cardId
```

Two candidates in one pool may use relative weights `3:1`:

```lua
rows = {
    {
        id = 990311,
        type = 1,
        poolId = 990211,
        weight = 3,
        useConditions = {},
        cardId = 21007,
        assetId = "buff_1",
        extend = {},
    },
    {
        id = 990312,
        type = 1,
        poolId = 990211,
        weight = 1,
        useConditions = {},
        cardId = 21006,
        assetId = "attack_1",
        extend = {},
    },
}
```

This is relative random selection, not a fixed three-out-of-four pattern. If all candidates fail Conditions or total valid weight is not positive, the pool produces no action. Do not use negative weights.

## In-Game Presentation

Presentation fields affect the client Chain list, not which Card the server selects.

### Action Icon: `assetId`

The client uses `assetId` to load an existing action chain icon:

| Value | Example use |
| --- | --- |
| `"buff_1"` | Self-repair action |
| `"attack_1"` | Probe shot action |

A string in configuration does not guarantee that the resource exists. Reuse an existing Chain icon.

### Action Effect: `extend.showChainEffect`

Normal actions use:

```lua
extend = {}
```

To reuse the existing Chain list effect:

```lua
extend = {
    showChainEffect = true,
}
```

This changes list presentation only. It does not add a new effect resource or change Card resolution.

## Adding `robot_chain_def` in a MOD

A new two-round Chain requires four synchronized parts:

1. `robot_def.config.chainId` points to the new Chain.
2. One `sequence` file defines the complete `chainId` group.
3. Each new `poolId` has its own `config` file.
4. Every action row has a globally unique `id` and references a valid `cardId`.

```text
robot_def.chainId = 1999

sequence chainId=1999
  -> round 1 -> poolId=990201
  -> round 2 -> poolId=990202

config poolId=990201
  -> id=990301 -> cardId=21007

config poolId=990202
  -> id=990302 -> cardId=21006
```

Example IDs are not reserved. Before publishing, replace the Enemy ID, `chainId`, every `poolId`, and every action `id`, then update all references.

Recommended order:

1. Copy the three Chain file groups from `enemy-pack`.
2. Replace all new IDs while keeping the Cards, Conditions, and presentation values.
3. Confirm that the two-round loop still works.
4. Replace one `cardId` at a time.
5. Add candidates, Conditions, weights, or presentation only after the basic loop works.
