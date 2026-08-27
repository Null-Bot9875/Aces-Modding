# card-pack 模板

用这个模板可以新增一张战术 Card，并为它配置自己的 Skill 和 Effect：

```text
Card 910001：Example: Overcharged Shot
  -> Skill 990801：主动执行
  -> Effect 990701：对所选敌方单位造成 4 点伤害
```

这张 Card 会加入游戏现有的常用卡牌奖励池 `10003`，池中的其他 Card 会保留。

> 发布自己的 MOD 前，请在专门的测试存档中确认奖励出现、目标选择、伤害结算和停用恢复。

## 包含内容

```text
card-pack/
  mod.json
  main.lua
  config/
    card_def/config/cards.lua
    battle_skill_def/config/skills.lua
    battle_effect_def/config/effects.lua
    act_card_pool_def/base_pool/cards.lua
```

- Card：`910001`
- 自定义 Skill：`990801`
- 自定义 Effect：`990701`
- 游戏已有 Target：`40`，选择一个敌方单位
- 游戏已有费用 Effect：`8012`，消耗 1 点能量
- 常用 Card 奖励池：`10003`
- 适用机体：`baseId=501`
- 未填写 `assetId`，因此使用默认图片 `10001`

## 把 Card 加入现有奖励池

普通 Card 奖励会从卡池 `10003` 选择候选 Card。把新 Card 加入这类奖励时，只需向卡池 `10003` 追加成员：

```lua
return {
    installKey = "poolId",
    installValue = 10003,
    operation = "append",
    rows = rows,
}
```

这里必须保留 `operation="append"`，这样游戏原有的池成员不会被替换。省略该字段时，批次会按 `replace` 处理，池 `10003` 将只剩这个 MOD 提供的成员。

## 提高 Card 的出现概率

`act_card_pool_def.base_pool` 没有单独的 `weight` 字段。如果希望新 Card 更容易出现，可以为它添加多个相同成员。这个模板添加 10 个：

```lua
local CARD_POOL_ENTRY_COPIES = 10
```

每个成员会提供一个随机抽取槽位，因此示例 Card 会获得 10 个槽位。最终奖励会按 `cardId` 去重，不会同时显示 10 张相同 Card。

这只会提高出现概率，不保证每次奖励都出现。制作自己的 MOD 时，请按玩法平衡调整 `CARD_POOL_ENTRY_COPIES`；如果只需要普通概率，改为 `1`。

## 复制后要修改

- 修改 `mod.json.id`、名称、作者和版本；
- 更换 Card、Skill、Effect 等新增内容 ID，避免与其他 MOD 冲突；
- 修改 Card 名称、费用、Target、Skill 和 Effect；
- 按玩法平衡调整 `CARD_POOL_ENTRY_COPIES`；
- 确认 `baseId`、`poolId` 和当前游戏版本仍符合你的制作目标。

## 测试步骤

1. 将整个目录复制到游戏可执行文件同级的 `Mods/example.cardpack/`。
2. 在 MOD 管理器中启用 `example.cardpack`，应用选择后重启游戏。
3. 使用 `baseId=501` 新建一局 Rogue 战役；已有战役可能已经保存旧卡池。
4. 进入一次使用卡池 `10003` 的普通 Card 奖励。
5. 确认候选中仍有游戏原有 Card，并能出现 `Example: Overcharged Shot`。
6. 选择示例 Card，确认它进入当前 Rogue 战役牌组。
7. 在后续战斗中抽到并打出 Card，只选择一次敌方目标。
8. 确认目标受到 4 点伤害，Card 正常离开手牌。
9. 保存本轮 `Player.log`，检查 MOD 配置、Skill、Effect 或战斗结算错误。
10. 停用 MOD，冷启动并新建战役，确认示例 Card 不再出现在普通 Card 奖励中。

详细字段说明见：

- [Card 配置参考](../../docs/zh-cn/config/card.md)
- [Skill 配置参考](../../docs/zh-cn/config/skill_def.md)
- [Effect 配置参考](../../docs/zh-cn/config/battle_effect_def.md)

配置文件能够加载后，仍需完成一次真实游戏测试。请分别确认奖励展示、存档、目标选择、伤害结算和停用恢复。
