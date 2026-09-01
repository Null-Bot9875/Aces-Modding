# `act_node_refresh_def` Configuration Reference

> `act_node_refresh_def` defines node pools: their members, which nodes may currently appear, and how one valid node is selected.

## Basic Structure of `act_node_refresh_def`

**Echo of the Crux** (Node `1416`) is in node pool `1413` with relative weight `30` and normally appears at most once on a map:

```lua
{
    groupId = 1413,
    nodeId = 1416,
    weight = 30,
    limitBaseId = {},
    nodeLimit = 1,
}
```

```text
Node pool 1413
└─ Node 1416: Echo of the Crux
   ├─ weight = 30
   ├─ no extra base restriction
   └─ nodeLimit = 1
```

| Field | Type | Purpose |
| --- | --- | --- |
| `groupId` | int | Node pool ID matching `act_ep_map_def.refreshGroup` |
| `nodeId` | int | `act_node_def.id` added to the pool |
| `weight` | int | Relative weight against other valid nodes in the pool |
| `limitBaseId` | int[] | Bases allowed to generate the node; empty adds no base restriction |
| `nodeLimit` | int | Appearance limit on one map |

## How a Node Pool Selects a Node

The game reads all rows with the same `groupId`, removes nodes that cannot currently appear, and selects one remaining row by `weight`.

`weight` is relative, not a percentage. Three valid nodes with weights `1`, `2`, and `7` are selected in a `1:2:7` ratio.

For a fixed result, keep only one currently valid node with `weight>0` in the pool. Do not simulate a guaranteed result with an extremely high weight.

## Which Nodes Can Currently Appear

```text
Check limitBaseId against the current base
→ Check whether nodeLimit has been reached
→ Select by weight from the remaining nodes
```

### `limitBaseId`

An empty table adds no base restriction:

```lua
limitBaseId = {},
```

A nonempty list allows only specific bases:

```lua
limitBaseId = { 501, 503 },
```

If no row matches the current base, the pool cannot provide a node. A pool still used by the map should always retain at least one entry valid for the current base.

### `nodeLimit`

- `nodeLimit=0`: no additional count limit.
- `nodeLimit>0`: normal maximum appearances on one map.
- `nodeLimit=-1`: exclude this row from the active node pool.

If every base-compatible node has reached a positive `nodeLimit`, the game retries while ignoring the count limit so the position does not remain empty. A positive limit is therefore not an absolute cap in every situation.

## Modifying an Existing Node Pool

Place files under:

```text
config/act_node_refresh_def/config/*.lua
```

### Append a Node

Append Node `990101` to node pool `1401`:

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "append",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

`operation="append"` preserves existing pool members and adds the MOD node.

`installValue` must match every row's `groupId`. One file changes one node pool; use separate files for several pools.

### Replace a Node Pool

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "replace",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 0,
        },
    },
}
```

`replace` removes existing members and installs only the current `rows`. A node pool may be reused by several node positions, so replacing it affects every position that references the same `groupId`.

Start a new run after changing pool members, weights, or limits. An already generated map does not select nodes again automatically.

## Adding `act_node_refresh_def` in a MOD

This example creates node pool `990001` with only Node `990101`:

```lua
return {
    installKey = "groupId",
    installValue = 990001,
    operation = "append",
    rows = {
        {
            groupId = 990001,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 0,
        },
    },
}
```

Reference the pool through [`act_ep_map_def.refreshGroup`](act_ep_map_def.md#what-the-position-generates). Define Node `990101` first in [`act_node_def`](act_node_def.md).
