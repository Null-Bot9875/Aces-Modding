# `act_ep_map_def` Configuration Reference

> `act_ep_map_def` defines the map skeleton. Each row is a node position that stores its campaign, node pool, and outgoing connections.

## Basic Structure of `act_ep_map_def`

Node position `230001` in EP `1061` is on layer 1, uses node pool `2001`, and connects to three later positions:

```lua
{
    id = 230001,
    epId = 1061,
    refreshGroup = 2001,
    nextNode = {
        [230024] = 1,
        [230021] = 1,
        [230022] = 1,
    },
    layer = 1,
}
```

```text
Node position 230001
├─ Layer 1 of EP 1061
├─ Node pool 2001 selects the current node
└─ Next positions: 230024 / 230021 / 230022
```

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | int | Node position ID; not `act_node_def.id` |
| `epId` | int | Campaign containing the position; the published map uses `1061` |
| `refreshGroup` | int | Node pool ID matching `act_node_refresh_def.groupId` |
| `nextNode` | dict&lt;int,int&gt; | Outgoing positions; key is another `act_ep_map_def.id`, value is connection type |
| `layer` | int | Layer used by map display and flow |

## Which Campaign and Layer Contains the Position

`id` identifies a fixed map position. It is separate from the displayed `act_node_def.id`. The same position may generate different nodes in different runs and may replace its current node after resolution.

`epId` selects the campaign and `layer` selects the map layer. Examples here use the published map EP `1061`.

## What the Position Generates

`refreshGroup` references a node pool:

```text
act_ep_map_def.refreshGroup = 2001
└─ act_node_refresh_def.groupId = 2001
   └─ Select one act_node_def entry from the pool
```

See [`act_node_refresh_def`](act_node_refresh_def.md) for pool members and weighted selection, and [Node Pool Numbering](../concepts/node-groups.md) for existing ID conventions.

## Connecting Node Positions

Keys in `nextNode` are destination node position IDs. Values are connection types. Normal routes in EP `1061` use `1`:

```lua
nextNode = {
    [230024] = 1,
    [230021] = 1,
    [230022] = 1,
},
```

- One position with several destinations creates a branch.
- Several positions with the same destination create a merge.
- An empty table creates no outgoing connection.

`nextNode` advances the map after completing the current position. It does not replace the current node. Option, victory, and defeat replacement use `act_option_def.replaceNode`, `act_node_def.finishReplaceNode`, and `act_node_def.failReplaceNode`.

## Modifying an Existing Route

When replacing an existing position, provide the complete new row. This example adds a fourth route to position `230001`:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 230001,
            epId = 1061,
            refreshGroup = 2001,
            nextNode = {
                [230024] = 1,
                [230021] = 1,
                [230022] = 1,
                [990001] = 1,
            },
            layer = 1,
        },
    },
}
```

Keep the three existing connections. Omitted fields or connections are not inherited from the old row.

Maps are normally generated when a run starts. After changing routes, layers, or node pools, begin a new run; a saved map is not updated automatically.

## Adding `act_ep_map_def` in a MOD

Place files under:

```text
config/act_ep_map_def/config/*.lua
```

This example adds node position `990001` to EP `1061`:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990001,
            epId = 1061,
            refreshGroup = 990001,
            nextNode = {
                [230024] = 1,
            },
            layer = 1,
        },
    },
}
```

Use `installKey="id"`. Provide matching `groupId=990001` in [`act_node_refresh_def`](act_node_refresh_def.md), and connect another node position to `990001` through `nextNode` so the new position is reachable.
