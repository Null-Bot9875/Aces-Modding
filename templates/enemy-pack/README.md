# enemy-pack 模板

这是一个可以直接遇到并进入战斗的 Enemy 模板。它向第一层战斗节点池追加节点 `990101`，节点中的 Enemy `11999` 使用 Chain `1999`，在修复和点射之间循环。

```text
节点池 1401
└─ 节点 990101：MOD 行动链演示
   └─ Enemy 11999：MOD 修复点射核心
      └─ Chain 1999
         ├─ 第 1、3、5……回合 → 行动池 990201 → Card 21007：自我修复
         └─ 第 2、4、6……回合 → 行动池 990202 → Card 21006：试探点射
```

节点 `990101` 使用较高权重，方便安装后快速遇到。正式制作自己的 MOD 时，应按玩法平衡降低权重。

第一次制作 MOD 时，先阅读[开始制作 MOD](../../docs/zh-cn/getting-started.md)。

## 目录结构

```text
enemy-pack/
├─ mod.json
├─ main.lua
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

## 配置如何连接

`act_node_refresh_def` 把节点加入第一层战斗节点池；`act_node_def.robot` 指向 Enemy：

```text
节点池 1401
└─ 节点 990101
   └─ robot 11999
```

`robot_def.config.chainId` 指向行动链：

```text
robot_def.id 11999
└─ chainId 1999
   └─ robot_chain_def.sequence
```

`sequence` 决定每个 Enemy 回合读取哪个行动池，行动池再选出实际执行的 Card：

```text
chainId 1999
├─ 回合位置 1 → poolId 990201 → action 990301 → Card 21007
└─ 回合位置 2 → poolId 990202 → action 990302 → Card 21006
```

## 安装

1. 退出游戏。
2. 将整个目录复制到游戏可执行文件同级的 `Mods/aces.example.enemypack/`。
3. 在 MOD 管理器中启用“两回合行动链 Enemy 模板”并应用选择。
4. 冷启动游戏，新建 EP `1061` 战局。
5. 在第一层战斗节点中进入“MOD 行动链演示”。

节点权重 `1000000` 只用于缩短模板测试时间。它仍然参与随机抽取，但会明显压过节点池中的普通权重；正式内容不要直接沿用这个数值。

进入战斗后，Enemy 第 1、3、5……回合使用 Card `21007`，第 2、4、6……回合使用 Card `21006`。

## 完成检查

- 第一层战斗节点仍会出现游戏已有节点，也能出现“MOD 行动链演示”。
- 节点可以正常进入战斗，并创建 Enemy `11999`。
- Enemy 第 1、3 回合使用 Card `21007`，第 2、4 回合使用 Card `21006`。
- 战斗节点池使用 `append` 后，游戏已有节点没有被整个替换。
- 停用 MOD、冷启动并新建战局后，“MOD 行动链演示”不再出现。

建议使用不需要保留进度的测试存档。安装后仍要实际进入战斗，确认 Enemy 创建和行动顺序。通用检查步骤见[开始制作 MOD](../../docs/zh-cn/getting-started.md#安装和验证)。

## 复制后修改

用于自己的 MOD 前，至少修改并同步以下 ID：

- MOD ID `aces.example.enemypack`。
- 节点 ID `990101`。
- Enemy ID `11999`。
- Chain ID `1999`。
- 行动池 ID `990201`、`990202`。
- 行动项 ID `990301`、`990302`。
- 节点池 `1401` 与 `weight`，决定节点出现的位置和相对概率。

如果改为追加游戏已有节点池，保留 `operation = "append"`；省略或写成 `replace` 会替换整个节点池。发布前降低测试权重，并确认所有新增 ID 不与目标游戏版本或其他 MOD 冲突。

模板还使用了游戏已有的机体 `7366`、开始战斗选项 `10051`、战斗奖励 `100001` 和 Card `21007`、`21006`。可以先保留这些引用确认整条链路，再逐个换成自己的内容。

详细说明见：

- [`act_node_def` 配置参考](../../docs/zh-cn/config/act_node_def.md)
- [`act_node_refresh_def` 配置参考](../../docs/zh-cn/config/act_node_refresh_def.md)
- [`robot_chain_def` 配置参考](../../docs/zh-cn/config/robot_chain_def.md)
