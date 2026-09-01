# enemy-pack 模板

这是一个只定义 Enemy 与行动链的完整配置包。Enemy `11999` 使用 Chain `1999`，在修复和点射之间循环。

```text
Enemy 11999：MOD 修复点射核心
└─ Chain 1999
   ├─ 第 1、3、5……回合 → 行动池 990201 → Card 21007：自我修复
   └─ 第 2、4、6……回合 → 行动池 990202 → Card 21006：试探点射
```

这个模板不会自动把 Enemy 放进地图。要实际挑战它，需要让一个战斗节点使用：

```lua
robot = 11999,
```

节点与选项的配置见 [`act_node_def`](../../docs/zh-cn/config/act_node_def.md#战斗节点)；一个可以直接安装的事件节点见 [`node-pack`](../node-pack/README.md)。

## 目录结构

```text
enemy-pack/
├─ mod.json
├─ main.lua
└─ config/
   ├─ robot_def/config/enemy.lua
   └─ robot_chain_def/
      ├─ sequence/two_round_cycle.lua
      └─ config/
         ├─ round_1_buffer.lua
         └─ round_2_attack.lua
```

## 两张表如何连接

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
4. 冷启动游戏。

单独安装只会注册 Enemy 和行动链，不会改变现有地图。把 `robot = 11999` 写入自己的战斗节点后，进入该节点即可观察两回合循环。

## 复制后修改

用于自己的 MOD 前，至少修改并同步以下 ID：

- MOD ID `aces.example.enemypack`。
- Enemy ID `11999`。
- Chain ID `1999`。
- 行动池 ID `990201`、`990202`。
- 行动项 ID `990301`、`990302`。

可以先保留 Card `21007`、`21006` 验证引用链，再逐个换成适合 Enemy 自动使用的 Card。行动链字段见 [`robot_chain_def` 配置参考](../../docs/zh-cn/config/robot_chain_def.md)。
