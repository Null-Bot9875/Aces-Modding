# node-pack 模板

这是一个可安装的 Node 模板，包含用于测试完整引用链的 Enemy 和两回合行动链：

```text
第一层战斗节点组 1401
  -> 以高权重 append Node 990101，保留 Core 候选
  -> Node 990101
  -> Enemy 11999
  -> 行动链 1999
  -> 第 1 回合卡池 990201 / Core Card 21007
  -> 第 2 回合卡池 990202 / Core Card 21006
```

> 当前状态：人工验收候选。配置链路已经过自动检查和开发环境运行验证，仍需完成 MOD 作者视角的人工安装、游玩和停用恢复测试。

本模板不增加玩家 Card。Card 制作见 [`card-pack`](../card-pack/README.md)。

## 运行结果

- EP `1061` 的新手引导入口保持不变；
- 后续第一层战斗位置通常会出现 `MOD 行动链演示`；
- 进入 Node 后挑战 Enemy `MOD 修复点射核心`；
- Enemy 第 1、3 回合使用 Core Card `21007`（自我修复）；
- Enemy 第 2、4 回合使用 Core Card `21006`（试探点射）；
- 两回合行动持续循环。

战斗界面右上角可能显示 `baseId=7366` 对应的 Core 名称 `自成长核心`。这是当前复用 Core 外观和基础数据的结果，不代表 Enemy 配置未生效。

## 目录结构

```text
node-pack/
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

刷新批次使用 `operation="append"` 把 Node 加入 Core 第一层战斗节点组 `1401`，不会覆盖新手引导组或删除 Core 战斗候选。`weight=1000000` 只为让人工测试更快遇到目标 Node，不是正式内容的平衡值；抽取仍然是随机的。

`nodeLimit=1` 会让目标 Node 在同一张地图中最多出现一次。

## 游戏内检查

1. 进入本地模式，开始 EP `1061`。
2. 正常完成新手引导入口，进入后续第一层地图。
3. 检查第一层战斗位置。当前 `230021`、`230022`、`230031`、`230032` 使用组 `1401`，其中一个位置通常应显示 `MOD 行动链演示`。若极少数情况下没有出现，退出当前战役并冷启动后新建战役重试。
4. 进入 Node 并开始战斗。
5. 确认战斗中的 Enemy 名称或行为来自 Enemy `11999`。
6. 连续观察至少四个回合，确认行动顺序为修复、点射、修复、点射。
7. 保存本次 `Player.log`。

保存记录时注明游戏版本、操作步骤和实际结果。

## 停用与恢复

1. 退出游戏。
2. 在 MOD 管理器中停用 `aces.example.nodeenemy`，应用选择后退出游戏。
3. 冷启动游戏并新建 EP `1061`。
4. 确认新手引导入口正常，第一层战斗位置不再出现 `MOD 行动链演示`，只从 Core 候选中刷新。

停用后的恢复结果属于人工验收内容，不能省略。

## 修改顺序

首次修改时，每次只改一组内容并冷启动检查：

1. 修改 `act_node_def` 中的 Node 名称和说明；
2. 修改 `robot_def` 中的 Enemy 名称；
3. 把行动链引用的 `cardId` 换成另一个已存在的 Core Card；
4. 最后再更换所有新增 ID，并同步修改引用。

模板 ID 不是保留号段。用于其他 MOD 前，必须更换 `990101`、`11999`、`1999`、`990201`、`990202`、`990301` 和 `990302`，避免与其他 MOD 冲突。

Node 字段说明见 [Node 配置教学](../../docs/zh-cn/config/node.md)。
