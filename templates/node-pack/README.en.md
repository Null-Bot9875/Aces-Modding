# `node-pack` Template

This is a complete three-choice event node. It appends node `990110` to the event node pool on the first map layer. The player can choose Nano, a Card, or a Chip.

```text
Node pool 1402
└─ Node 990110: MOD Supply Choice
   ├─ Option 990111: Take Nano -> Reward 990121
   ├─ Option 990112: Choose a Card -> Reward 990122 -> Card pool 10003
   └─ Option 990113: Choose a Chip -> Reward 990123 -> Chip pool 20
```

This template does not contain an Enemy or action chain. Start battle content from [`enemy-pack`](../enemy-pack/README.en.md).

If this is your first MOD, read [Start Making a MOD](../../docs/en/getting-started.md) first.

## Directory Layout

```text
node-pack/
├─ mod.json
├─ main.lua
├─ locales/en_us/mod.json
└─ config/
   ├─ act_node_def/config/node.lua
   ├─ act_node_refresh_def/config/reachable_node.lua
   ├─ act_option_def/config/options.lua
   └─ reward_def/config/rewards.lua
```

## Game Result

- Node `990110` is appended to node pool `1402`, so existing entries are preserved.
- The node has three fixed options. Each button position always uses its configured option.
- The Nano option grants 30 Nano.
- The Card option generates 3 candidates from Card pool `10003` and lets the player choose 1.
- The Chip option generates 3 candidates from Chip pool `20` and lets the player choose 1.

Node `990110` has `weight=100` and is selected against other entries in node pool `1402` by relative weight. It is not guaranteed to appear on every map. Start a new run after changing a node pool.

## Installation

1. Exit the game.
2. Copy the whole directory to `Mods/aces.example.nodepack/` beside the game executable.
3. Enable **Three-Choice Node Template** in the MOD manager and apply the selection.
4. Restart the game and begin a new EP `1061` run.

The **MOD Supply Choice** node can appear at an event node position on the first map layer.

## Completion Checklist

- Existing event nodes on the first map layer still appear, and **MOD Supply Choice** can also appear.
- The three buttons show Nano, Card, and Chip rewards.
- The Nano option grants 30 Nano.
- The Card option generates 3 candidates and allows 1 choice. The Chip option does the same.
- After disabling the MOD, restarting, and beginning a new run, **MOD Supply Choice** no longer appears.

The template reuses Card pool `10003` and Chip pool `20`. Claim all three rewards in the game to confirm both pools produce valid candidates. See [Installation and Verification](../../docs/en/getting-started.md#installation-and-verification) for the shared checklist.

## What to Change After Copying

Change these values and update every reference to them:

- MOD ID `aces.example.nodepack`
- Node ID `990110`
- Option IDs `990111` through `990113`
- Reward IDs `990121` through `990123`
- Node name, text, and reward values
- Node pool `1402` and `weight`, which determine where the node can appear and its relative chance

Configuration references:

- [`act_node_def` Configuration Reference](../../docs/en/config/act_node_def.md)
- [`act_option_def` Configuration Reference](../../docs/en/config/act_option_def.md)
- [`reward_def` Configuration Reference](../../docs/en/config/reward_def.md)
- [`act_node_refresh_def` Configuration Reference](../../docs/en/config/act_node_refresh_def.md)
