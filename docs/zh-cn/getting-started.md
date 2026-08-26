# 从这里开始

本教程使用 `card-pack` 人工验收候选模板完成第一个本地配置型 MOD。

模板会覆盖 Core `rewardId=10003`，只使用专门的测试存档。首版完整记录格式见[人工测试清单](manual-testing.md)。

## 准备

- 确认游戏版本。`mod.json.supportedGameVersions` 使用 `major.minor`，例如 `1.0`。
- 准备支持 UTF-8 without BOM 的文本编辑器。
- 退出游戏后再复制或修改 MOD 文件。
- 使用新建的 Rogue 战役测试模板，避免测试奖励影响正常存档。

## 1. 复制模板

游戏可执行文件同级应存在 `Mods/`：

```text
<game-root>/
  <game-executable>.exe
  Mods/
```

将 [`templates/card-pack`](../../templates/card-pack/README.md) 整个目录复制为：

```text
<game-root>/Mods/example.cardpack/
```

`mod.json` 必须直接位于该目录，不能再多套一层：

```text
Mods/example.cardpack/mod.json            # 正确
Mods/example.cardpack/card-pack/mod.json  # 错误
```

## 2. 修改 MOD 身份

打开 `mod.json`，至少修改：

```json
{
  "id": "author.examplecard",
  "name": "Example Card Pack",
  "author": "MOD Author",
  "version": "0.1.0",
  "supportedGameVersions": ["1.0"]
}
```

`id` 会转为小写，并且必须包含至少两个以 `.` 分隔的部分。推荐格式为 `作者或组织.项目名`。

目录名可以与 `id` 不同，但保持一致更容易排查问题。

## 3. 修改示例 Card

打开：

```text
config/card_def/config/cards.lua
```

第一轮只修改：

- `cardId`：改为未被其他 MOD 使用的正整数；
- `name`：修改显示名称；
- `rare`：保留示例值或参考现有 Card；
- `type`、`tagMap`、`targetIds`、`costEffect`、`skillList`：第一轮保留示例值。

同步修改卡池文件中的 `cardId`：

```text
config/act_card_pool_def/base_pool/cards.lua
```

## 4. 启用并冷启动

1. 启动游戏并打开 MOD 管理器。
2. 启用新的 MOD ID。
3. 应用选择。
4. 退出并重新启动游戏。

当前版本按冷启动加载 MOD。修改启用状态、顺序或配置后，需要重新启动；运行中不会热重载。

`main.lua` 成功加载后会写入：

```text
Example Card Pack loaded
```

## 5. 验证 Card

模板使用测试卡池 `990001` 覆盖现有奖励 `10003`：

1. 使用 `baseId=501` 新建 Rogue 战役。
2. 进入会产生 `rewardId=10003` 的卡牌奖励。
3. 奖励候选应包含示例 Card 和 Core Card `2000`。
4. 选择示例 Card，确认进入当前 Rogue 牌组。
5. 重启并继续同一战役，确认 Card 仍然存在。
6. 在战斗中抽取、选择合法目标并打出。
7. 保存本轮对应的 `Player.log`。

测试完成后禁用模板，冷启动并新建战役，确认示例 Card 不再出现。正式 MOD 应使用独立内容设计替代对 `rewardId=10003` 的测试覆盖。

## 下一步

- [MOD 包结构](mod-package.md)
- [通用配置格式](configuration.md)
- [Card 配置教学](content/card.md)
- [PNG 资源](assets.md)
- [多语言](localization.md)
- [调试指南](debugging.md)
- [首版人工测试清单](manual-testing.md)
