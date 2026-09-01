# Node Pool ID Conventions

Existing node pool IDs follow a convention that helps authors read IDs such as `1401`, `1412`, `2002`, and `2371`, but it does not change runtime behavior.

## Regular node pools

Regular pools traditionally use `14xy` for layer and content planning:

```text
140x → Layer 1
141x → Layer 2
142x → Layer 3
143x → Layer 4
144x → Layer 5
145x → Layer 6
146x → Layer 7
```

The last digit traditionally identifies content:

```text
1 → Battle
2 → Choice
3 → Elite battle
4 → Final boss
5 → Special battle position
```

For example, `1401` traditionally means a layer-1 battle pool; `1412` a layer-2 choice pool; and `1414` a layer-2 final-boss pool.

## Special node pools

`200x` is used for special pools outside the regular refresh numbering, such as tutorial, shop, supply, and wormhole pools.

`2371`–`2376` are fixed node lists used by layer 7.

These ranges only help read existing configuration; they do not mean every number has a public, stable purpose.

## Not a runtime rule

The game does not parse a node pool ID to determine layer or content type. Existing pools may also be reused by other layers, so an ID alone cannot establish which node positions it affects.

MOD-created pool IDs do not need to follow this convention. They only need to be unique, and the same value must be used in [`act_ep_map_def.refreshGroup`](../config/act_ep_map_def.md) and [`act_node_refresh_def.groupId`](../config/act_node_refresh_def.md).

Pool members, weights, unit restrictions, and appearance counts are defined in [`act_node_refresh_def` reference](../config/act_node_refresh_def.md).
