# 配置字段参考

本页覆盖 `card-pack` 与 `complete-mod` 当前使用的八类配置。字段操作标记：

| 标记 | 含义 |
| --- | --- |
| 必改 | 新内容必须使用新的 ID 或玩家可见内容 |
| 按设计修改 | 可按目标内容修改，但必须使用已经存在的合法引用 |
| 联动修改 | 修改后还要同步其他文件中的引用 |
| 首轮保持 | 字段属于完整 row，但第一版尚未公开安全编辑规则；保留示例值 |

## Card：`card_def.config`

Card 作者格式只要求八个字段，其余字段由适配器补默认值。

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `cardId` | int | Card 的唯一配置 ID，也是卡池和其他配置引用的目标 | 必改、联动修改 |
| `name` | string | Card 原文名称；翻译可放入 `language/language.csv` | 必改 |
| `rare` | int | 稀有度值 | 按设计修改；参考同类型 Core Card |
| `type` | list<int> | Card 类型 ID 列表 | 首轮使用已确认组合 |
| `tagMap` | dict<int,int> | `tagId -> value` 的 Tag 集合 | 首轮使用已确认组合 |
| `targetIds` | list<int> | 可选择的 Target ID | 按设计修改；必须引用已有 Target |
| `costEffect` | int | 打出 Card 时使用的费用 Effect ID | 按设计修改；必须引用已有 Effect |
| `skillList` | list<int> | Card 依次执行的 Skill ID | 按设计修改；必须引用已有 Skill |

自动默认字段、图片 `assetId` 和安装校验见 [Card 配置教学](../content/card.md)。当前已确认组合见 [可复用的 Core 配置](core-configs.md)。

## Card 卡池：`act_card_pool_def.base_pool`

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `cardId` | int | 该卡池候选 Card | 联动 `card_def.cardId` |
| `baseId` | int | 允许使用该候选的 Core 机体基础 ID | 首轮保持 `501` |
| `poolId` | int | 卡池分组 ID；必须与批次 `installValue` 一致 | 必改、联动奖励 |
| `minBaseLevel` | int | 机体最低等级 | 首轮保持 `1` |
| `maxBaseLevel` | int | 机体最高等级 | 首轮保持 `10` |
| `limitActIds` | list<int> | 战役范围限制 | 首轮保持 `{ -1 }` |

一个卡池可包含多条 row。`replace` 会替换同一 `poolId` 的完整分组。

## Card 测试奖励：`reward_def.config`

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `id` | int | 奖励配置 ID | 示例保持 `10003`；只用于测试存档 |
| `title` | string | 奖励原文标题 | 按设计修改 |
| `icon` | string | 已有奖励图标引用 | 首轮保持 `image_decision` |
| `value` | lua | 奖励内容；示例使用 `value[1].card` | 按下表修改 |
| `cardId` | int | 奖励界面附带的 Card 引用字段 | 首轮保持 `0` |
| `chipId` | int | 奖励界面附带的 Chip 引用字段 | 首轮保持 `0` |
| `itemId` | int | 奖励界面附带的 Item 引用字段 | 首轮保持 `0` |

示例 `value`：

```lua
value = {
    {
        card = {
            count = 3,
            choose = 1,
            pool = { 990001 },
        },
    },
}
```

| 子字段 | 含义 |
| --- | --- |
| `count` | 从卡池生成的候选数量 |
| `choose` | 可选择的数量 |
| `pool` | 读取的 Card 卡池 ID 列表；联动 `base_pool.poolId` |

`reward_def 10003` 会被示例覆盖，适合专门的测试存档，不是正式内容的新增奖励 ID。

## Enemy：`robot_def.config`

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `id` | int | Enemy 唯一配置 ID，也是 Node 的引用目标 | 必改、联动 Node |
| `name` | string | Enemy 配置原文名称 | 必改 |
| `groupId` | int | Enemy 的内部分类字段 | 首轮保持 `0` |
| `baseId` | int | Core 机体基础数据、外观和部分界面信息 | 按设计修改；只使用已验证值 |
| `chainId` | int | Enemy 使用的行动链 | 必改、联动 `sequence` |
| `newCards` | int | 完整 Enemy row 的抽取/补充相关字段 | 首轮保持 `0` |
| `noSuffle` | int | 完整 Enemy row 的洗牌相关开关 | 首轮保持 `0` |
| `roundAction` | int | 完整 Enemy row 的回合行动相关字段 | 首轮保持 `-1` |
| `noCardCheck` | int | 完整 Enemy row 的 Card 检查相关字段 | 首轮保持 `2` |
| `roomRobot` | int | 完整 Enemy row 的房间 Enemy 相关字段 | 首轮保持 `0` |
| `robotType` | int | Enemy 类型值 | 首轮保持 `1` |

后七个字段的完整枚举尚未公开。数值相同只表示复用已验证示例结构，不构成独立行为承诺。

## Enemy 回合序列：`robot_chain_def.sequence`

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `chainId` | int | 行动链分组 ID；必须与批次 `installValue` 一致 | 必改、联动 Enemy |
| `seqType` | int | 序列类型 | 两回合示例保持 `2` |
| `round` | int | 当前 row 对应的循环回合位置 | 按顺序填写 `1`、`2` |
| `circle` | int | 示例的循环长度 | 两回合示例保持 `2` |
| `poolId` | int | 当前回合读取的行动卡池 | 必改、联动行动池 |

第一版只说明 `seqType=2`、`circle=2` 的两回合循环，不提供其他序列类型枚举。

## Enemy 行动池：`robot_chain_def.config`

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `id` | int | 行动 row 的唯一 ID | 必改 |
| `type` | int | 行动 row 类型 | 首轮保持 `1` |
| `poolId` | int | 行动池分组 ID；必须与批次 `installValue` 一致 | 必改、联动序列 |
| `weight` | int | 同一行动池内的相对选择权重 | 按设计修改 |
| `useConditions` | list<int> | 行动使用条件 | 首轮保持 `{}` |
| `cardId` | int | Enemy 执行的已有 Card ID | 按设计修改；必须战斗验证 |
| `assetId` | string | 已有行动表现引用 | 与 Card 组合一起验证 |
| `extend` | lua | 行动扩展参数 | 首轮保持 `{}` |

第一版不提供 `type` 枚举、条件编写或 `extend` 自定义规则。

## Node：`act_node_def.config`

`act_node_def.config` 没有简化作者格式，必须提交完整 row。字段分为可直接编辑字段和首轮保持字段。

### 可直接编辑或引用的字段

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `id` | int | Node 唯一 ID，也是刷新组的引用目标 | 必改、联动刷新组 |
| `mainType` | int | Node 主分类 | 战斗 Node 示例保持 `1` |
| `type` | int | Node 类型 | 战斗 Node 示例保持 `1` |
| `showType` | int | Node 显示类型 | 示例保持 `1` |
| `name` | string | Node 原文名称 | 必改 |
| `subheading` | string | Node 原文副标题 | 必改 |
| `desc` | string | Node 原文说明 | 必改 |
| `summary` | string | Node 原文摘要 | 必改 |
| `battleReward` | list<int> | `act_node_def.node_reward` 奖励组 ID 列表 | 首轮保持 `{ 100001 }` |
| `robot` | int | 战斗使用的 Enemy ID | 联动 `robot_def.id` |
| `gridPoolList` | list<int> | 玩家侧战斗网格池列表 | 首轮保持 `{ 200 }` |
| `optionRandom1` | list<map> | 第一组选项候选；每项包含 `id` 和 `weight` | 首轮保持 Option `10051` |
| `conditionGroup` | int | Node 进入条件组 | 首轮保持 `99` |
| `skybox` | string | 已有战斗背景引用 | 首轮保持 `Nebula_Coral_4K_3` |

`battleReward` 不是直接引用 `reward_def`。引用链为：

```text
act_node_def.config.battleReward
  -> act_node_def.node_reward
  -> reward_def.config
```

### 完整 row 中首轮保持的字段

| 字段 | 类型 | 当前作用边界 |
| --- | --- | --- |
| `replaceNode` | lua | Node 替换规则；保持 `{}` |
| `finishReplaceNode` | lua | 完成后的 Node 替换规则；保持 `{}` |
| `failReplaceNode` | lua | 失败后的 Node 替换规则；保持 `{}` |
| `finish` | int | 完成状态相关字段；保持 `0` |
| `finishReward` | list<int> | 非战斗完成奖励相关字段；保持 `{ 0 }` |
| `winCondition` | list<int> | 战斗胜利条件引用；保持 `{}` |
| `conditionRewards` | dict<int,int> | 条件与奖励映射；保持 `{}` |
| `robotChips` | list<int> | Enemy Chip 引用；保持 `{}` |
| `robotGridPoolList` | list<int> | Enemy 侧网格池；保持 `{}` |
| `robotInitGrid` | dict<int,int> | Enemy 初始网格配置；保持 `{}` |
| `playerInitGrid` | dict<int,int> | 玩家初始网格配置；保持 `{}` |
| `battleExtend` | lua | 战斗扩展参数；保持 `{}` |
| `heroList` | list<int> | 参战角色相关列表；保持 `{}` |
| `shopId` | int | 商店 Node 引用；战斗 Node 保持 `0` |
| `optionType` | int | 选项组织类型；示例保持 `1` |
| `optionStatic` | list<int> | 固定选项列表；示例保持 `{ 0 }` |
| `optionRandom2` | list<map> | 第二组选项候选；保持 `{}` |
| `optionRandom3` | list<map> | 第三组选项候选；保持 `{}` |
| `heroIds` | list<int> | 玩家侧角色限制；保持 `{}` |
| `enemyHeroIds` | list<int> | Enemy 侧角色限制；保持 `{}` |
| `dialogueId` | int | 对话引用；保持 `0` |
| `dontShowEnemyEntrance` | int | Enemy 入场显示相关开关；保持 `0` |
| `useRetreat` | int | 撤退相关开关；保持 `0` |
| `endTimeline` | string | 结束 Timeline 引用；保持空字符串 |
| `showLink` | int | 地图连接显示相关开关；保持 `0` |

这些字段的名称只说明所在功能范围，不代表第一版已开放对应配置能力。需要改变时，应提交“能力请求”或等待对应教学补齐。

## 现有 Node Group：`act_node_refresh_def.config`

第一版使用 EP `1061` 已存在的 Group，不需要定义新的 Group。全部 44 个现有 Group 见 [EP 1061 Node Group 目录](node-groups.md)。

| 字段 | 类型 | 含义 | 操作 |
| --- | --- | --- | --- |
| `groupId` | int | EP `1061` 已存在的地图入口 Group | 从目录选择，并同步 `installValue` |
| `nodeId` | int | 该入口产生的 Node | 联动 `act_node_def.id` |
| `weight` | int | 同组候选的相对选择权重 | 按内容平衡设置；人工测试可临时提高 |
| `limitBaseId` | list<int> | 非空时只允许列表中的机体基础 ID | 第一版保持 `{}` |
| `nodeLimit` | int | 同一 Node 的正常重复次数限制 | 第一版保持 `1` |

`replace`、`append`、全部 EP 位置和停用恢复规则见 [EP 1061 Node Group 目录](node-groups.md)。

## ID 联动清单

| 修改的 ID | 必须同步的位置 |
| --- | --- |
| Card `cardId` | `card_def.cardId`、卡池 `cardId`；若作为 Enemy 行动，还包括行动池 `cardId` |
| Card 卡池 `poolId` | `base_pool.installValue`、所有 row 的 `poolId`、奖励 `value.card.pool` |
| Enemy `id` | `robot_def.id`、Node `robot` |
| 行动链 `chainId` | `robot_def.chainId`、`sequence.installValue`、所有 sequence row 的 `chainId` |
| 行动池 `poolId` | sequence row 的 `poolId`、行动池 `installValue`、所有行动 row 的 `poolId` |
| 行动 row `id` | 对应行动 row 的 `id` |
| Node `id` | `act_node_def.id`、刷新组 `nodeId` |

配置能加载只证明结构和引用通过基础检查。Card、Enemy、Node 仍需分别完成人工游戏内测试。
