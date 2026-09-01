# English Documentation

This section contains English references for creating Aces MODs.

- [`config/`](config/): one configuration reference for each exported table.
- [`concepts/`](concepts/): concepts used by configuration files, including Trigger, Area, Attr, and the node system.

## Start

- [Start Making a MOD](getting-started.md): minimum directory layout, `mod.json`, configuration paths, installation, and verification.

## Templates

- [`card-pack`](../../templates/card-pack/README.en.md): one custom tactical Card with its Skill, Effect, and Card pool entry.
- [`node-pack`](../../templates/node-pack/README.en.md): a three-choice event node that grants Nano, a Card, or a Chip.
- [`enemy-pack`](../../templates/enemy-pack/README.en.md): a reachable battle node with an Enemy that uses a two-round action chain.

## Battle Configuration

- [`battle_target_def` Configuration Reference](config/battle_target_def.md)
- [`battle_effect_def` Configuration Reference](config/battle_effect_def.md)
- [`battle_condition_def` Configuration Reference](config/battle_condition_def.md)
- [`battle_skill_def` Configuration Reference](config/battle_skill_def.md)
- [`static_skill_def` Configuration Reference](config/static_skill_def.md)
- [`battle_item_def` Configuration Reference](config/battle_item_def.md)

Related concepts:

- [Trigger Reference](concepts/triggers.md)
- [Round Stages](concepts/round-stages.md)
- [Battle Areas](concepts/areas.md)
- [Effect Attributes](concepts/attrs.md)

## Card, Chip, and Rewards

- [`card_def` Configuration Reference](config/card_def.md)
- [`chip_def` Configuration Reference](config/chip_def.md)
- [`reward_def` Configuration Reference](config/reward_def.md)
- [`act_card_pool_def` Configuration Reference](config/act_card_pool_def.md)
- [`act_chip_pool_def` Configuration Reference](config/act_chip_pool_def.md)
- [Game Model Catalog](concepts/card-models.md)

## Nodes and Maps

Read the [Node System](concepts/nodes.md) first, then use the table references you need:

- [`act_ep_map_def` Configuration Reference](config/act_ep_map_def.md)
- [`act_node_refresh_def` Configuration Reference](config/act_node_refresh_def.md)
- [`act_node_def` Configuration Reference](config/act_node_def.md)
- [`act_option_def` Configuration Reference](config/act_option_def.md)
- [Node Pool Numbering](concepts/node-groups.md)

## Enemy Action Chains

- [`robot_chain_def` Configuration Reference](config/robot_chain_def.md)

Copy a complete Enemy example from [`enemy-pack`](../../templates/enemy-pack/README.en.md). The `robot_chain_def` reference explains how the Enemy selects a Card from an action pool each round.
