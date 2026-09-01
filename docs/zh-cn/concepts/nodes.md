# 节点系统说明

节点系统决定一局战役的地图怎么连接、每个节点位置出现什么，以及玩家进入后可以做什么。

## 一局游戏中的节点流程

```text
新建战局
→ 生成地图路线
→ 每个节点位置确定一个节点池
→ 从节点池中抽出战斗、事件或商店
→ 玩家进入节点并看到选项
→ 选项产生战斗、奖励或后续事件
→ 节点完成后继续前进
```

地图先确定“可以走到哪里”，再为每个节点位置生成本局实际显示的内容。玩家进入后看到的按钮和结果属于选项，不是地图路线本身。

## 节点位置、节点池、节点和选项

```text
节点位置
└─ 节点池
   └─ 节点
      └─ 选项
```

- 节点位置是地图上的固定格子，保存它位于哪一层、接下来连接到哪里。
- 节点池是这个位置可以抽到的节点集合。
- 节点是本局实际抽中并显示的战斗、事件或商店。
- 选项是进入节点后出现的按钮及其结果。

一个节点位置保存一个当前节点。选择选项或完成结算后，当前节点可以被替换；替换时节点位置不变，只更新当前位置保存的节点和选项。

这些对象在配置中的关系是：

```text
act_ep_map_def.id：节点位置
└─ refreshGroup
   └─ act_node_refresh_def.groupId：节点池
      └─ nodeId
         └─ act_node_def.id：节点
            └─ optionRandom1 / optionRandom2 / optionRandom3 / optionStatic
               └─ act_option_def.id：选项
```

## 节点怎么抽出来，选项怎么抽出来

节点和选项分别在两个时机生成。

先生成节点：

```text
节点位置的 refreshGroup
→ 找到节点池
→ 排除当前不可出现的节点
→ 按 weight 从剩余节点中抽取一个
```

节点池里只有一个当前可用的节点时，该位置会固定生成这个节点。节点池中存在多个节点时，`weight` 决定相对概率；实际结果还会受到 `limitBaseId`、`nodeLimit`、同池其他节点和地图中使用该节点池的位置数量影响。完整规则见 [`act_node_refresh_def` 配置参考](../config/act_node_refresh_def.md)。

节点确定后，再生成选项：

```text
optionRandom1 → 抽取第一个选项
optionRandom2 → 抽取第二个选项
optionRandom3 → 抽取第三个选项
optionStatic  → 追加固定选项
```

具体写法见 [`act_node_def` 配置参考](../config/act_node_def.md#节点如何生成选项)。

需要固定内容时，让节点池里只放一个当前可用的节点；不要使用极高 `weight` 模拟必定出现。

## 战斗、事件和商店

### 战斗节点

玩家进入后，通过“出击”选项开始节点保存的战斗。战斗结束后，当前节点可以按胜利或失败结果更新。

“十字星的残响”（节点 `1416`）是一场普通战斗：

```text
节点 1416：十字星的残响
├─ 敌人和初始战场
├─ 选项：出击！
└─ 战斗奖励
```

### 事件节点

玩家进入后看到一个或多个选择。不同选项可以支付消耗、发放奖励、开始战斗，或把当前位置更新成下一段事件。

“欢迎光临”（节点 `4006`）提供三个不同结果：

```text
节点 4006：欢迎光临
├─ 强买强卖
├─ 拒绝购买，径直离开
└─ 攻击！
```

### 商店节点

玩家进入后打开游戏已有的商店，离开后继续地图流程。商店节点通过 `shopId` 选择商店；本文不展开商品和刷新规则。

游戏内实际使用的商队商店是节点 `3200`，它引用商店 `10`。配置方式见 [`act_node_def` 配置参考](../config/act_node_def.md#商店节点)。

## 节点替换和地图前进

节点替换与地图前进是两种不同结果：

- 节点替换：节点位置不变，更新当前位置保存的节点和选项。
- 地图前进：当前位置完成，玩家移动到相连的下一个节点位置。

节点替换又分为三个时机：

```text
选择选项后
└─ act_option_def.replaceNode

战斗成功后
└─ act_node_def.finishReplaceNode

战斗失败后
└─ act_node_def.failReplaceNode
```

这三个字段都不会沿地图路线前进。

拍卖会中的“参与竞拍”选项会在玩家选择后更新当前节点，见 [`act_option_def.replaceNode`](../config/act_option_def.md#替换节点)。

“夏洛”（节点 `4179`）则根据战斗结果进入不同节点：

```text
节点 4179：夏洛
├─ 战斗成功 → 节点 4096：困难模式
└─ 战斗失败 → 节点 41790：夏洛（失败结果）
```

完整字段见 [`act_node_def`](../config/act_node_def.md#节点完成后如何更新)。

地图前进由节点位置的 `nextNode` 决定，见 [`act_ep_map_def` 配置参考](../config/act_ep_map_def.md#节点位置连接到哪里)。

## 为什么修改后需要新开战局

地图路线和初始节点通常在新战局生成地图时确定。已经写入存档的地图不会因为节点池、权重或路线配置变化而自动重新生成。

修改 `act_ep_map_def`、`act_node_refresh_def` 或节点池成员后，需要新建战局观察。当前节点的替换结果也可能保存在原战局中。

## 从哪里开始

| 想实现的内容 | 查看内容 |
| --- | --- |
| 在现有地图随机加入一场战斗 | [`act_node_def`](../config/act_node_def.md) + [`act_option_def`](../config/act_option_def.md) + [`act_node_refresh_def`](../config/act_node_refresh_def.md) |
| 加入一个有多个选项的事件 | [`act_node_def`](../config/act_node_def.md) + [`act_option_def`](../config/act_option_def.md) + [`act_node_refresh_def`](../config/act_node_refresh_def.md) |
| 把某个节点位置固定为指定内容 | [`act_ep_map_def`](../config/act_ep_map_def.md) + 只放一个节点的节点池 |
| 给地图增加一条分支 | [`act_ep_map_def.nextNode`](../config/act_ep_map_def.md#节点位置连接到哪里) |
| 制作连续多段事件 | [`act_option_def.replaceNode`](../config/act_option_def.md#替换节点) |
| 制作胜利和失败走向不同的战斗 | [`act_node_def.finishReplaceNode`](../config/act_node_def.md#节点完成后如何更新) + `failReplaceNode` |
| 放置商店 | [`act_node_def.shopId`](../config/act_node_def.md#商店节点)，复用已有商店 |
| 创建完整新地图 | 从 [`act_ep_map_def`](../config/act_ep_map_def.md) 开始，并继续提供战役入口配置 |

三个常见起点分别是：

- 普通战斗：参考“十字星的残响”（节点 `1416`），再使用 [`enemy-pack`](../../../templates/enemy-pack/README.md) 提供敌人与行动链。
- 多选事件：参考“欢迎光临”（节点 `4006`），或直接从完整的 [`node-pack`](../../../templates/node-pack/README.md) 开始。
- 固定 Boss：参考“夏洛”（节点 `4179`），让一个节点池只包含该战斗节点，再由 `finishReplaceNode` 和 `failReplaceNode` 区分结果。
