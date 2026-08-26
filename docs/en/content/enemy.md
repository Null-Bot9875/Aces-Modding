# Enemy configuration tutorial

The current Enemy authoring scope reuses existing Core unit data and Cards, then schedules turn behavior through an action chain.

This page does not claim support for custom units, Skills, Targets, Card behavior, models, animation, audio, or every Enemy type.

Runnable files are in [`complete-mod`](../../../examples/complete-mod/README.en.md). This page uses the same IDs to explain references.

## Three parts of an Enemy

```text
robot_def Enemy 11999
  -> robot_chain_def.sequence action chain 1999
  -> robot_chain_def.config action pools 990201 and 990202
  -> existing Core Cards 21007 and 21006
```

`robot_def` selects Core base data and an action chain. `sequence` selects the action pool for each turn. `config` defines the Cards available in each pool.

## 1. Define the Enemy

File location:

```text
config/robot_def/config/enemy.lua
```

Example:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 11999,
            name = "MOD 修复点射核心",
            groupId = 0,
            baseId = 7366,
            chainId = 1999,
            newCards = 0,
            noSuffle = 0,
            roundAction = -1,
            noCardCheck = 2,
            roomRobot = 0,
            robotType = 1,
        },
    },
}
```

Fields directly changed by this example:

| Field | Purpose |
| --- | --- |
| `id` | Enemy configuration ID and the target of `act_node_def.robot` |
| `name` | Enemy configuration name |
| `baseId` | Reused Core unit base data, appearance, and some UI information |
| `chainId` | Action-chain ID; must match the `installValue` in the `sequence` batch |

`robot_def.config` has no simplified author format and requires a complete row. Retain unexplained example fields until a change is required, then compare against a complete same-type Enemy row from the same-version `game-lua` archive.

Some battle UI locations may display the Core name from `baseId` rather than `robot_def.name`. The example can therefore display both `MOD 修复点射核心` and `自成长核心`.

## 2. Define the action pool for each turn

File location:

```text
config/robot_chain_def/sequence/two_round_cycle.lua
```

Example:

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

These complete rows form a two-turn loop: turn 1 reads `990201`, turn 2 reads `990202`, and the sequence then restarts.

| Field | Purpose in the example |
| --- | --- |
| `chainId` | Owning action chain |
| `round` | Turn position inside the loop |
| `circle` | Loop length in this example |
| `poolId` | Action pool read during the current turn |

`installKey` and `installValue` replace the complete `chainId=1999` group. Every row in a new action chain must use the same `chainId`.

## 3. Define the action pools

Turn-one file:

```text
config/robot_chain_def/config/round_1_buffer.lua
```

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

The turn-two file uses the same structure with `poolId=990202`, row `id=990302`, and `cardId=21006`.

| Field | Purpose in the example |
| --- | --- |
| `id` | Unique action-row ID |
| `poolId` | Owning action pool; must match the batch `installValue` |
| `weight` | Selection weight inside one action pool |
| `useConditions` | Use conditions; an empty table adds no condition in this example |
| `cardId` | Existing Card executed by the Enemy |
| `assetId` | Action presentation reference; the example reuses an existing value |

The current scope guarantees only action chains that reuse existing Cards. Battle testing must still confirm target selection, settlement, and turn progression for each chosen Card.

## 4. Place the Enemy in a Node

Enemy configuration does not enter a map or battle automatically. A reachable battle Node must reference the Enemy in `act_node_def`:

```lua
robot = 11999
```

See the [Node configuration tutorial](node.md) for the complete path.

## IDs and editing order

Example IDs are not reserved ranges. Before distributing another MOD, replace these new IDs and update every reference:

- Enemy: `11999`;
- action chain: `1999`;
- action pools: `990201`, `990202`;
- action rows: `990301`, `990302`.

Replace only one existing Core Card first and confirm that the two-turn loop still works. Change pools, conditions, and weights afterward. Changing several references at once makes failures harder to isolate.

## In-game verification

Enemy completion criteria:

1. No MOD configuration or loading error during cold start.
2. The Node enters battle.
3. The battle uses the intended Enemy.
4. At least four turns follow the configured action order.
5. Target selection, effect settlement, and turn progression work for every Card.
6. The Core Node returns after disabling the MOD and cold-starting.

See the [manual testing checklist](../manual-testing.md) for the complete record. Automated checks or successful configuration queries do not establish completed human in-game validation.

## Capability requests

For custom units, Card behavior, Skills, Targets, animations, or action patterns not covered here, choose “Capability request” in GitHub Issues and describe the intended player-visible result.
