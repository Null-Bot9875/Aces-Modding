# Node 与 Enemy 完整示例

这是一个可安装的 Node 与 Enemy 联合示例，用于学习以下完整引用链：

```text
地图刷新组 2001
  -> Node 990101
  -> Enemy 11999
  -> 行动链 1999
  -> 第 1 回合卡池 990201 / Core Card 21007
  -> 第 2 回合卡池 990202 / Core Card 21006
```

> 当前状态：人工验收候选。配置链路已经过自动检查和开发环境运行验证，仍需完成 MOD 作者视角的人工安装、游玩和停用恢复测试。

本示例不增加玩家 Card。Card 制作见 [`card-pack`](../../templates/card-pack/README.md)。

## 运行结果

- EP `1061` 的地图位置 `230001` 出现 `MOD 行动链演示`；
- 进入 Node 后挑战 Enemy `MOD 修复点射核心`；
- Enemy 第 1、3 回合使用 Core Card `21007`（自我修复）；
- Enemy 第 2、4 回合使用 Core Card `21006`（试探点射）；
- 两回合行动持续循环。

战斗界面右上角可能显示 `baseId=7366` 对应的 Core 名称 `自成长核心`。这是当前复用 Core 外观和基础数据的结果，不代表 Enemy 配置未生效。

## 目录结构

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

## 安装

1. 退出游戏。
2. 将整个目录复制到游戏可执行文件同级的 `Mods/aces.example.nodeenemy/`。
3. 使用专门的测试存档，不使用正常游玩存档。
4. 在 MOD 管理器中只启用 `aces.example.nodeenemy`，应用选择后退出游戏。
5. 冷启动游戏。

`main.lua` 成功加载后，`Player.log` 中会出现：

```text
Node and chain enemy example loaded
```

## 游戏内检查

1. 进入本地模式，开始 EP `1061`。
2. 到达地图位置 `230001`。
3. 确认位置显示 `MOD 行动链演示`，而不是 Core Node `4315`。
4. 进入 Node 并开始战斗。
5. 确认战斗中的 Enemy 名称或行为来自 Enemy `11999`。
6. 连续观察至少四个回合，确认行动顺序为修复、点射、修复、点射。
7. 保存本次 `Player.log`。

完整记录格式见[人工测试清单](../../docs/zh-cn/manual-testing.md)。

## 停用与恢复

1. 退出游戏。
2. 在 MOD 管理器中停用 `aces.example.nodeenemy`，应用选择后退出游戏。
3. 冷启动游戏并新建 EP `1061`。
4. 确认地图位置 `230001` 恢复为 Core Node `4315`。

停用后的恢复结果属于首版人工验收内容，不能省略。

## 修改顺序

首次修改时，每次只改一组内容并冷启动检查：

1. 修改 `act_node_def` 中的 Node 名称和说明；
2. 修改 `robot_def` 中的 Enemy 名称；
3. 把行动链引用的 `cardId` 换成另一个已存在的 Core Card；
4. 最后再更换所有新增 ID，并同步修改引用。

示例 ID 不是保留号段。用于其他 MOD 前，必须更换 `990101`、`11999`、`1999`、`990201`、`990202`、`990301` 和 `990302`，避免与其他 MOD 冲突。

字段说明见 [Enemy 配置教学](../../docs/zh-cn/content/enemy.md)和[Node 配置教学](../../docs/zh-cn/content/node.md)。
