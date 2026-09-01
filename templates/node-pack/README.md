# node-pack 模板

这是一个完整的三选一事件节点。它向第一层事件节点池追加节点 `990110`，玩家进入后可以在星核、Card 和 Chip 中选择一份奖励。

```text
节点池 1402
└─ 节点 990110：MOD 补给选择
   ├─ 选项 990111：带走星核 → Reward 990121
   ├─ 选项 990112：挑选 Card → Reward 990122 → Card 池 10003
   └─ 选项 990113：挑选 Chip → Reward 990123 → Chip 池 20
```

本模板不包含 Enemy 或行动链。战斗内容从 [`enemy-pack`](../enemy-pack/README.md) 开始。

第一次制作 MOD 时，先阅读[开始制作 MOD](../../docs/zh-cn/getting-started.md)。

## 目录结构

```text
node-pack/
├─ mod.json
├─ main.lua
└─ config/
   ├─ act_node_def/config/node.lua
   ├─ act_node_refresh_def/config/reachable_node.lua
   ├─ act_option_def/config/options.lua
   └─ reward_def/config/rewards.lua
```

## 运行结果

- 节点 `990110` 通过 `append` 加入节点池 `1402`，不会删除该节点池原有内容。
- 节点有三个固定选项，不会在三个按钮位置继续随机替换其他选项。
- 星核选项固定获得 30 星核。
- Card 选项从普通 Card 池 `10003` 生成 3 个候选，选择 1 个。
- Chip 选项从 Chip 池 `20` 生成 3 个候选，选择 1 个。

节点 `990110` 的 `weight = 100` 会与节点池 `1402` 中的其他节点按相对权重一起抽取，因此不是每张地图都必定出现。修改节点池后需要新建战局。

## 安装

1. 退出游戏。
2. 将整个目录复制到游戏可执行文件同级的 `Mods/aces.example.nodepack/`。
3. 在 MOD 管理器中启用“三选一节点模板”并应用选择。
4. 冷启动游戏，新建 EP `1061` 战局。

进入第一层事件节点时，可以遇到“MOD 补给选择”。

## 完成检查

- 第一层事件节点仍会出现游戏已有节点，也能出现“MOD 补给选择”。
- 三个按钮分别显示星核、Card 和 Chip 奖励。
- 星核选项获得 30 星核。
- Card 选项生成 3 个候选并允许选择 1 个；Chip 选项同样生成 3 个候选并允许选择 1 个。
- 停用 MOD、冷启动并新建战局后，“MOD 补给选择”不再出现。

模板会复用 Card 池 `10003` 和 Chip 池 `20`。安装后仍要实际领取三种奖励，确认两个池都能生成候选。通用检查步骤见[开始制作 MOD](../../docs/zh-cn/getting-started.md#安装和验证)。

## 复制后修改

用于自己的 MOD 前，至少修改以下内容并同步全部引用：

- MOD ID `aces.example.nodepack`。
- 节点 ID `990110`。
- 选项 ID `990111`～`990113`。
- Reward ID `990121`～`990123`。
- 节点名称、说明和奖励数值。
- 节点池 `1402` 与 `weight`，决定节点在哪些位置出现以及相对概率。

配置说明见：

- [`act_node_def` 配置参考](../../docs/zh-cn/config/act_node_def.md)
- [`act_option_def` 配置参考](../../docs/zh-cn/config/act_option_def.md)
- [`reward_def` 配置参考](../../docs/zh-cn/config/reward_def.md)
- [`act_node_refresh_def` 配置参考](../../docs/zh-cn/config/act_node_refresh_def.md)
