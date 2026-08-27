# card-pack 模板

这是普通战术 Card 的人工验收候选模板。示例复用游戏已有 Skill、Target、费用效果和 Tag，不包含自定义战斗逻辑。

> 模板会覆盖 Core `rewardId=10003`。只使用专门的测试存档，测试结束后停用或移出 `Mods/`。

## 包含内容

```text
card-pack/
  mod.json
  main.lua
  config/
    card_def/config/cards.lua
    act_card_pool_def/base_pool/cards.lua
    reward_def/config/card_reward.lua
```

- Card `910001`：`Example: Fire Drone`
- 测试卡池 `990001`
- 被替换的现有奖励 `10003`
- 适用机体 `baseId=501`
- 未填写 `assetId`，因此使用默认 Core 图片 `10001`

## 使用前修改

- `mod.json.id`、名称、作者和版本；
- Card、卡池等新增内容 ID，避免与其他 MOD 冲突；
- Card 显示名称和行为引用；
- 正式发布前移除或替换针对 `rewardId=10003` 的测试覆盖。

## 测试步骤

1. 将整个目录复制到游戏可执行文件同级的 `Mods/example.cardpack/`。
2. 在 MOD 管理器中启用 `example.cardpack`，应用选择后重启游戏。
3. 使用 `baseId=501` 新建一局 Rogue 战役。
4. 进入会产生 `rewardId=10003` 的卡牌奖励。
5. 奖励候选应包含 `Example: Fire Drone` 和 Core Card `2000`。
6. 选择示例 Card，在当前 Rogue 牌组中确认加入结果。
7. 重启并继续同一战役，确认 Card 仍然存在。
8. 在战斗中抽取、选择合法目标并打出 Card。
9. 保存本轮对应的 `Player.log`。
10. 停用 MOD，冷启动并新建战役，确认测试 Card 不再出现。

测试完成后禁用或移除模板，避免测试奖励覆盖继续影响正常游戏。

详细字段说明见 [Card 配置教学](../../docs/zh-cn/config/card.md)。
