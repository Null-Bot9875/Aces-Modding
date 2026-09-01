# Node System

The node system determines how a run's map connects, what appears at each node position, and what the player can do after entering it.

## Node Flow in a Run

```text
Start a new run
→ Generate map routes
→ Assign a node pool to each node position
→ Draw a battle, event, or shop from the pool
→ Enter the node and see its options
→ Resolve a battle, reward, or follow-up event
→ Continue after completing the node
```

The map first determines where the player can travel. Each node position then receives the content displayed in that run. Buttons and their results are options, not map routes.

## Node Position, Node Pool, Node, and Option

```text
Node position
└─ Node pool
   └─ Node
      └─ Option
```

- A **node position** is a fixed place on the map. It stores its layer and outgoing connections.
- A **node pool** is the set of nodes that this position may draw.
- A **node** is the battle, event, or shop selected and displayed for this run.
- An **option** is a button shown after entering the node and the result of choosing it.

A node position stores one current node. Choosing an option or completing a result may replace that node. The node position stays in place; only its saved node and options change.

The configuration chain is:

```text
act_ep_map_def.id: node position
└─ refreshGroup
   └─ act_node_refresh_def.groupId: node pool
      └─ nodeId
         └─ act_node_def.id: node
            └─ optionRandom1 / optionRandom2 / optionRandom3 / optionStatic
               └─ act_option_def.id: option
```

## How Nodes and Options Are Drawn

Nodes and options are generated at different times.

First, the game draws the node:

```text
refreshGroup on the node position
→ Find the node pool
→ Remove nodes that cannot currently appear
→ Draw one remaining node by weight
```

If only one node in the pool is currently valid, that position always receives it. If several nodes are valid, `weight` sets their relative chance. `limitBaseId`, `nodeLimit`, other members of the pool, and the number of map positions using the pool also affect the result. See [`act_node_refresh_def`](../config/act_node_refresh_def.md) for the full rules.

After the node is selected, the game draws its options:

```text
optionRandom1 → draw the first option
optionRandom2 → draw the second option
optionRandom3 → draw the third option
optionStatic  → append fixed options
```

See [How a Node Generates Options](../config/act_node_def.md#how-a-node-generates-options).

For fixed content, put only one currently valid node in the pool. Do not simulate a guaranteed result with an extremely high `weight`.

## Battles, Events, and Shops

### Battle Nodes

The player starts the saved battle through an **Engage!** option. The current node may update after a win or loss.

**Echo of the Crux** (Node `1416`) is a normal battle:

```text
Node 1416: Echo of the Crux
├─ Enemy and initial battlefield
├─ Option: Engage!
└─ Battle rewards
```

### Event Nodes

The player sees one or more choices. An option may pay a cost, grant a reward, start a battle, or update the current position to the next part of the event.

**At Your Service** (Node `4006`) provides three different results:

```text
Node 4006: At Your Service
├─ Forced Transaction
├─ Refuse and leave
└─ Attack!
```

### Shop Nodes

The player enters an existing shop and returns to the map after leaving it. A shop node selects the shop with `shopId`; item and refresh rules are outside this guide.

The caravan shop used by the game is Node `3200`, which references Shop `10`. See [Shop Nodes](../config/act_node_def.md#shop-nodes).

## Node Replacement and Map Progress

Replacing a node and moving forward on the map are different results:

- **Node replacement:** keep the node position and update its saved node and options.
- **Map progress:** complete the current position and move to a connected node position.

Node replacement has three timing points:

```text
After choosing an option
└─ act_option_def.replaceNode

After winning a battle
└─ act_node_def.finishReplaceNode

After losing a battle
└─ act_node_def.failReplaceNode
```

None of these fields moves along the map route.

The **Participate in the Auction** option replaces the current node after it is selected. See [`act_option_def.replaceNode`](../config/act_option_def.md#replacing-the-current-node).

**Sharo** (Node `4179`) enters a different node depending on the battle result:

```text
Node 4179: Sharo
├─ Win  → Node 4096: Hard Mode
└─ Loss → Node 41790: Sharo (loss result)
```

See [Updating a Node After Completion](../config/act_node_def.md#updating-a-node-after-completion).

Map progress is controlled by `nextNode` on the node position. See [Connecting Node Positions](../config/act_ep_map_def.md#connecting-node-positions).

## Why Configuration Changes Need a New Run

Map routes and initial nodes are normally selected when a new run generates its map. A saved map is not rebuilt automatically after node pool, weight, or route changes.

After changing `act_ep_map_def`, `act_node_refresh_def`, or node pool members, start a new run to observe the result. A replacement result for the current node may also be stored in the old run.

## Where to Start

| Goal | Read |
| --- | --- |
| Add a random battle to an existing map | [`act_node_def`](../config/act_node_def.md) + [`act_option_def`](../config/act_option_def.md) + [`act_node_refresh_def`](../config/act_node_refresh_def.md) |
| Add an event with several options | [`act_node_def`](../config/act_node_def.md) + [`act_option_def`](../config/act_option_def.md) + [`act_node_refresh_def`](../config/act_node_refresh_def.md) |
| Fix one node position to specific content | [`act_ep_map_def`](../config/act_ep_map_def.md) + a node pool containing one node |
| Add a branch to the map | [`act_ep_map_def.nextNode`](../config/act_ep_map_def.md#connecting-node-positions) |
| Build a multi-step event | [`act_option_def.replaceNode`](../config/act_option_def.md#replacing-the-current-node) |
| Send wins and losses to different nodes | [`act_node_def.finishReplaceNode`](../config/act_node_def.md#updating-a-node-after-completion) + `failReplaceNode` |
| Place a shop | [`act_node_def.shopId`](../config/act_node_def.md#shop-nodes), reusing an existing shop |
| Create a complete new map | Start with [`act_ep_map_def`](../config/act_ep_map_def.md), then provide a campaign entry configuration |

Reference configurations:

- **Normal battle:** use **Echo of the Crux** (Node `1416`) as a reference, then use [`enemy-pack`](../../../templates/enemy-pack/README.en.md) for the Enemy and action chain.
- **Multi-choice event:** use **At Your Service** (Node `4006`) as a reference, or start from the complete [`node-pack`](../../../templates/node-pack/README.en.md).
- **Fixed boss:** use **Sharo** (Node `4179`) as a reference. Put only that battle node in a node pool, then use `finishReplaceNode` and `failReplaceNode` for different results.
