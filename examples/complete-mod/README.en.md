# Complete Node and Enemy example

This installable example demonstrates the complete Node-to-Enemy reference chain:

```text
Map refresh group 2001
  -> Node 990101
  -> Enemy 11999
  -> action chain 1999
  -> turn-one pool 990201 / Core Card 21007
  -> turn-two pool 990202 / Core Card 21006
```

> Current status: Candidate for human validation. The configuration chain has passed automated checks and a development-environment run. MOD-author installation, gameplay, and disable-and-recovery checks are still required.

This example does not add a player Card. For Card authoring, use [`card-pack`](../../templates/card-pack/README.en.md).

## Expected result

- Map position `230001` in EP `1061` displays `MOD 行动链演示`.
- Entering the Node starts a battle against `MOD 修复点射核心`.
- On turns 1 and 3, the Enemy uses Core Card `21007` (`自我修复`).
- On turns 2 and 4, the Enemy uses Core Card `21006` (`试探点射`).
- The two-turn sequence repeats.

The top-right battle UI may display the Core name `自成长核心` from `baseId=7366`. This is expected while reusing Core appearance and base data and does not mean the Enemy configuration failed.

## Directory structure

```text
complete-mod/
  mod.json
  main.lua
  config/
    act_node_def/config/node.lua
    act_node_refresh_def/config/reachable_node.lua
    robot_def/config/enemy.lua
    robot_chain_def/config/round_1_buffer.lua
    robot_chain_def/config/round_2_attack.lua
    robot_chain_def/sequence/two_round_cycle.lua
```

## Installation

1. Exit the game.
2. Copy the entire directory to `Mods/aces.example.nodeenemy/` beside the game executable.
3. Use a dedicated test save rather than a normal play save.
4. Enable only `aces.example.nodeenemy` in the MOD manager, apply the selection, and exit the game.
5. Cold-start the game.

A successful `main.lua` load writes the following line to `Player.log`:

```text
Node and chain enemy example loaded
```

## In-game checks

1. Enter local mode and start EP `1061`.
2. Reach map position `230001`.
3. Confirm that the position displays `MOD 行动链演示` instead of Core Node `4315`.
4. Enter the Node and start the battle.
5. Confirm that the Enemy name or behavior comes from Enemy `11999`.
6. Observe at least four turns and confirm the repair, shot, repair, shot sequence.
7. Save the matching `Player.log`.

See the [manual testing checklist](../../docs/en/manual-testing.md) for the result record.

## Disable and recovery

1. Exit the game.
2. Disable `aces.example.nodeenemy` in the MOD manager, apply the selection, and exit the game.
3. Cold-start the game and create a new EP `1061` run.
4. Confirm that map position `230001` returns to Core Node `4315`.

Recovery after disabling is part of version-one human validation and must not be skipped.

## Recommended editing order

Change one group at a time and cold-start after each change:

1. Change the Node name and description in `act_node_def`.
2. Change the Enemy name in `robot_def`.
3. Replace an action-chain `cardId` with another existing Core Card.
4. Replace all new IDs and update every reference last.

Example IDs are not reserved ranges. Before reuse in another MOD, replace `990101`, `11999`, `1999`, `990201`, `990202`, `990301`, and `990302` to avoid conflicts with other MODs.

See the [Enemy configuration tutorial](../../docs/en/content/enemy.md) and [Node configuration tutorial](../../docs/en/content/node.md) for field details.
