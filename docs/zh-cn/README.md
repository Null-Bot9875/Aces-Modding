# 中文文档

这里提供制作 Aces MOD 时使用的中文参考。

- [`config/`](config/)：MOD 作者可以直接参考的配置文件说明。每篇文档对应一张真实配置表。
- [`concepts/`](concepts/)：解释配置文件涉及的概念，例如 Trigger、Area、Attr 和节点系统。

制作 MOD 时，先从模板或目标配置表开始；遇到 Trigger、战斗区域、回合阶段和节点池等概念时，再查看对应概念说明。

## 模板

- [`card-pack`](../../templates/card-pack/README.md)：一张自定义战术 Card，以及对应 Skill、Effect 和卡池成员。
- [`node-pack`](../../templates/node-pack/README.md)：一个可选择星核、Card 或 Chip 的三选一事件节点。
- [`enemy-pack`](../../templates/enemy-pack/README.md)：一个可进入的战斗节点，以及使用两回合循环行动链的 Enemy。

## 战斗配置

- [`battle_target_def` 配置参考](config/battle_target_def.md)
- [`battle_effect_def` 配置参考](config/battle_effect_def.md)
- [`battle_condition_def` 配置参考](config/battle_condition_def.md)
- [`battle_skill_def` 配置参考](config/battle_skill_def.md)
- [`static_skill_def` 配置参考](config/static_skill_def.md)
- [`battle_item_def` 配置参考](config/battle_item_def.md)

相关概念：

- [Trigger 配置参考](concepts/triggers.md)
- [RoundStage 回合阶段](concepts/round-stages.md)
- [战斗区域参考](concepts/areas.md)
- [Effect 属性参考](concepts/attrs.md)

## Card、Chip 与奖励

- [`card_def` 配置参考](config/card_def.md)
- [`chip_def` 配置参考](config/chip_def.md)
- [`reward_def` 配置参考](config/reward_def.md)
- [`act_card_pool_def` 配置参考](config/act_card_pool_def.md)
- [`act_chip_pool_def` 配置参考](config/act_chip_pool_def.md)
- [游戏模型目录](concepts/card-models.md)

## 节点与地图

先阅读 [节点系统说明](concepts/nodes.md)，再按需要查看配置表：

- [`act_ep_map_def` 配置参考](config/act_ep_map_def.md)
- [`act_node_refresh_def` 配置参考](config/act_node_refresh_def.md)
- [`act_node_def` 配置参考](config/act_node_def.md)
- [`act_option_def` 配置参考](config/act_option_def.md)
- [节点池编号规则](concepts/node-groups.md)

## Enemy 行动链

- [`robot_chain_def` 配置参考](config/robot_chain_def.md)

Enemy 本体的完整 row 可以从 [`enemy-pack`](../../templates/enemy-pack/README.md) 复制；`robot_chain_def` 说明 Enemy 每回合如何从行动池中选择 Card。
