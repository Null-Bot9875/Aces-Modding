# Node configuration tutorial

The current Node authoring scope submits a complete `act_node_def` row, references an existing or MOD-provided Enemy, and uses a map refresh group to place a battle Node at a reachable position.

This page does not claim support for every Node type, map structure, condition, option, dialogue, or reward combination.

Runnable files are in [`complete-mod`](../../../examples/complete-mod/README.en.md). This page uses the same IDs to explain references.

## Complete reference chain

```text
act_node_refresh_def groupId 2001
  -> act_node_def Node 990101
  -> robot_def Enemy 11999
  -> robot_chain_def chainId 1999
```

Defining `act_node_def` alone does not place a Node on the map. A refresh group is also insufficient unless its `nodeId` references an installed complete Node.

## 1. Define the battle Node

File location:

```text
config/act_node_def/config/node.lua
```

The complete row is in [`complete-mod/config/act_node_def/config/node.lua`](../../../examples/complete-mod/config/act_node_def/config/node.lua). Its main references are:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990101,
            mainType = 1,
            type = 1,
            showType = 1,
            name = "MOD 行动链演示",
            subheading = "先修复，再点射",
            desc = "用于验证 Rogue 节点、敌人和行动链共享配置链路。",
            summary = "两回合循环的纯行动链敌人。",
            battleReward = { 100001 },
            robot = 11999,
            gridPoolList = { 200 },
            optionRandom1 = {
                { id = 10051, weight = 100 },
            },
            conditionGroup = 99,
            skybox = "Nebula_Coral_4K_3",
            -- Retain all remaining fields from the complete example file
        },
    },
}
```

| Field | Purpose in the example |
| --- | --- |
| `id` | Node ID and the target of the refresh-group `nodeId` |
| `name`, `subheading`, `desc`, `summary` | Player-facing Node text |
| `robot` | Enemy ID used by the battle |
| `battleReward` | Battle reward reference |
| `gridPoolList` | Battle grid-pool reference |
| `optionRandom1` | Node option and weight |
| `conditionGroup` | Condition-group reference |
| `skybox` | Battle background reference |

`act_node_def.config` has no simplified author format and requires a complete row. Missing fields may fail during loading or only become visible after entering the Node. Retain unexplained example fields until a change is required, then compare against a complete same-type battle Node row from the same-version `game-lua` archive.

Node text can begin as literals in the row. For Chinese and English translations, use `language/language.csv`; see [Localization](../localization.md).

## 2. Place the Node on the map

File location:

```text
config/act_node_refresh_def/config/reachable_node.lua
```

Example:

```lua
return {
    installKey = "groupId",
    installValue = 2001,
    rows = {
        {
            groupId = 2001,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

This batch replaces map refresh group `2001`, making Node `990101` appear consistently at map position `230001` in EP `1061`.

| Field | Purpose in the example |
| --- | --- |
| `groupId` | Refresh group referenced by the map |
| `nodeId` | Node produced by the refresh group |
| `weight` | Random weight among candidates in the group |
| `limitBaseId` | Unit restriction; an empty table adds no restriction in this example |
| `nodeLimit` | Quantity limit in this refresh |

An omitted `operation` defaults to `replace`. Core rows in refresh group `2001` are removed before the example row is written, so the intended Node appears consistently during testing.

Using `operation = "append"` retains Core rows and adds the new row, but random selection may omit the intended Node. Retain `replace` for initial validation. Whether distributed content should override a Core group requires a separate content decision.

## 3. Connect the Enemy

Node reference:

```lua
robot = 11999
```

A complete `robot_def` row with `id=11999` must exist. See the [Enemy configuration tutorial](enemy.md) for its action chain and turn Cards.

After changing Enemy, chain, or pool IDs, check references in this direction:

```text
Node.robot
  -> Enemy.id
Enemy.chainId
  -> sequence.installValue / sequence rows[].chainId
sequence rows[].poolId
  -> action pool installValue / rows[].poolId
```

## IDs and override risk

Example ID `990101` is not a reserved range and must be changed before distributing another MOD. Map refresh group `2001` already exists in Core and is replaced by this example, so a dedicated test save is required.

Disabling the example does not rewrite map results already stored in an existing run. The recovery check must cold-start, create a new EP `1061` run, and confirm that position `230001` returns to Core Node `4315`.

## In-game verification

Node completion criteria:

1. No MOD configuration or loading error during cold start.
2. Position `230001` displays Node `990101` in a new EP `1061` run.
3. Node name, description, and options display correctly.
4. Entering the Node starts the intended Enemy battle.
5. The battle can finish and settle its reward.
6. Core Node `4315` returns after disabling the MOD, cold-starting, and creating a new run.

See the [manual testing checklist](../manual-testing.md) for the complete record. Automated checks, successful configuration queries, or development-environment runs do not establish completed MOD-author human validation.

## Capability requests

For new Node types, complex conditions, special map links, dialogue flows, or reward methods not covered here, choose “Capability request” in GitHub Issues and describe the intended player-visible flow.
