# `enemy-pack` Template

This is a reachable Enemy template. It appends battle node `990101` to the battle node pool on the first map layer. Enemy `11999` uses Chain `1999` to alternate between repair and shooting.

```text
Node pool 1401
└─ Node 990101: MOD Action Chain Demo
   └─ Enemy 11999: MOD Repair-and-Shoot Core
      └─ Chain 1999
         ├─ Enemy rounds 1, 3, 5... -> action pool 990201 -> Card 21007: self-repair
         └─ Enemy rounds 2, 4, 6... -> action pool 990202 -> Card 21006: probe shot
```

Node `990101` uses a high weight so it is easy to find during testing. Lower the weight when turning the template into balanced content.

If this is your first MOD, read [Start Making a MOD](../../docs/en/getting-started.md) first.

## Directory Layout

```text
enemy-pack/
├─ mod.json
├─ main.lua
├─ locales/en_us/mod.json
└─ config/
   ├─ act_node_def/config/node.lua
   ├─ act_node_refresh_def/config/reachable_node.lua
   ├─ robot_def/config/enemy.lua
   └─ robot_chain_def/
      ├─ sequence/two_round_cycle.lua
      └─ config/
         ├─ round_1_buffer.lua
         └─ round_2_attack.lua
```

## How the Configuration Connects

`act_node_refresh_def` adds the node to the battle node pool on the first map layer. `act_node_def.robot` points to the Enemy:

```text
Node pool 1401
└─ Node 990101
   └─ robot 11999
```

`robot_def.config.chainId` points to the action chain:

```text
robot_def.id 11999
└─ chainId 1999
   └─ robot_chain_def.sequence
```

The `sequence` sheet decides which action pool is read on each Enemy round. The selected pool then provides the Card to execute:

```text
chainId 1999
├─ Round position 1 -> poolId 990201 -> action 990301 -> Card 21007
└─ Round position 2 -> poolId 990202 -> action 990302 -> Card 21006
```

## Installation

1. Exit the game.
2. Copy the whole directory to `Mods/aces.example.enemypack/` beside the game executable.
3. Enable **Two-Round Action Chain Enemy Template** in the MOD manager and apply the selection.
4. Restart the game and begin a new EP `1061` run.
5. Enter **MOD Action Chain Demo** at a battle node position on the first map layer.

The `weight=1000000` value is only for quick template testing. It still participates in random selection, but it overwhelms normal pool weights. Do not use this value for balanced release content.

In battle, the Enemy uses Card `21007` on rounds 1, 3, 5... and Card `21006` on rounds 2, 4, 6...

## Completion Checklist

- Existing battle nodes on the first map layer still appear, and **MOD Action Chain Demo** can also appear.
- The node enters battle and creates Enemy `11999`.
- The Enemy uses Card `21007` on rounds 1 and 3, and Card `21006` on rounds 2 and 4.
- `operation="append"` preserves the existing battle node pool.
- After disabling the MOD, restarting, and beginning a new run, **MOD Action Chain Demo** no longer appears.

Use a test save that does not need to preserve progress. Enter the battle to confirm Enemy creation and action order. See [Installation and Verification](../../docs/en/getting-started.md#installation-and-verification) for the shared checklist.

## What to Change After Copying

Change these IDs and update every reference to them:

- MOD ID `aces.example.enemypack`
- Node ID `990101`
- Enemy ID `11999`
- Chain ID `1999`
- Action pool IDs `990201` and `990202`
- Action entry IDs `990301` and `990302`
- Node pool `1401` and `weight`, which determine where the node appears and its relative chance

When appending to an existing node pool, keep `operation="append"`. Omitting it or using `replace` replaces the whole pool. Lower the test weight before release and confirm that every new ID is free in the target game version and other installed MODs.

The template also reuses base `7366`, battle option `10051`, battle reward `100001`, and Cards `21007` and `21006`. Keep these references until the complete chain works, then replace them one at a time.

References:

- [`act_node_def` Configuration Reference](../../docs/en/config/act_node_def.md)
- [`act_node_refresh_def` Configuration Reference](../../docs/en/config/act_node_refresh_def.md)
- [`robot_chain_def` Configuration Reference](../../docs/en/config/robot_chain_def.md)
