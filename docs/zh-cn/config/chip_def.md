# `chip_def` 配置参考

> `chip_def` 定义一枚晶片的显示信息，以及获得晶片后生效的战斗异能或战役奖励。

## `chip_def` 的基本结构

`晶石-2`（Chip `1102`）让玩家获得 Static Skill `103`。晶片本身只保存异能 ID，具体效果由 [`static_skill_def`](static_skill_def.md) 决定。

```lua
{
    id = 1102,
    name = "晶石-2",
    descLua = {
        { desc = "chip_1102_1" },
    },
    triggerEffect = {},
    skillList = {},
    staticList = { 103 },
    pvpReplace = 0,
    assetId = 1102,
    backAssetId = 1,
    type = { 1 },
    extend = {},
    keywordList = {},
}
```

它的引用关系是：

```text
Chip 1102：晶石-2
└─ staticList → Static Skill 103
```

当前新增一条 `chip_def` row 时，需要列出下面这些字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `id` | 正整数 | Chip 的配置 ID，也是安装和查询键 |
| `name` | string | Chip 名称 |
| `descLua` | table[] | Chip 说明片段；`desc` 可以填写文本 key，也可以直接填写说明文字 |
| `triggerEffect` | table | 战役外触发的奖励；不使用时填 `{}` |
| `skillList` | int[] | 进入战斗后携带的 [`battle_skill_def`](battle_skill_def.md) ID |
| `staticList` | int[] | 进入战斗后携带的 [`static_skill_def`](static_skill_def.md) ID |
| `pvpReplace` | int | PVP 替换用的 Chip ID；普通 Chip 填 `0` |
| `assetId` | int | Chip 图标资源 ID |
| `backAssetId` | int | Chip 背景资源 ID |
| `type` | int[] | Chip 的显示分类 |
| `extend` | table | 少数 Chip 使用的补充数据；不使用时填 `{}` |
| `keywordList` | table[] | Chip 详情展示的关键词；不使用时填 `{}` |

## `skillList` 与 `staticList`：战斗中的效果

Chip 进入战斗后，可以同时提供普通 Skill 和 Static Skill：

- `skillList` 填写 `battle_skill_def.skillId`，适合需要监听 Trigger 或主动执行 Effect 的异能。
- `staticList` 填写 `static_skill_def.id`，适合持续生效或改写战斗规则的异能。

`富氧虹吸装置`（Chip `4059`）同时使用两种入口：

```lua
skillList = { 1405901 },
staticList = { 1405951 },
```

```text
Chip 4059：富氧虹吸装置
├─ Skill 1405901：按 Trigger 执行结算
└─ Static Skill 1405951：持续提供规则
```

Chip 只负责把这些异能带入战斗。异能的 Trigger、Target、Condition 和 Effect 应分别在对应配置表中写清楚。

## `triggerEffect`：战役中的效果

`triggerEffect` 不经过战斗 Skill。它在获得晶片、进入节点或完成战斗等战役时机直接执行奖励。

### `key = "init"`：获得晶片时

`装甲补充协议`（Chip `4099`）：获得时，最大装甲增加 10。

```lua
triggerEffect = {
    key = "init",
    reward = {
        { maxHp = { value = 10 } },
    },
},
```

`reward` 使用与 [`reward_def.value`](reward_def.md) 相同的奖励结构。

### `key = "move"`：进入节点时

`晶石-5`（Chip `1105`）：进入 `mainType` 为 `4` 或 `5` 的节点时，获得 5 星火币。

```lua
triggerEffect = {
    key = "move",
    nodeMain = { 4, 5 },
    reward = {
        { gold = { count = 5 } },
    },
},
```

`nodeMain` 按 [`act_node_def.mainType`](act_node_def.md) 筛选节点。需要按显示类型筛选时，可以改用 `nodeType`，它对应 `act_node_def.showType`。

### `key = "battle"`：完成战斗时

`晶石-6`（Chip `1106`）：每完成 3 场战斗，加入一次 Reward `1007`。

```lua
triggerEffect = {
    key = "battle",
    process = 3,
    rewardIds = { 1007 },
},
```

`process` 是触发所需的累计次数；达到数值后执行一次并重新计数。`rewardIds` 填写 [`reward_def.id`](reward_def.md)。

## 显示字段

`name`、`descLua`、`assetId`、`backAssetId`、`type` 和 `keywordList` 共同决定晶片列表与详情的显示。

`descLua` 可以直接写说明文字：

```lua
descLua = {
    { desc = "每完成3场战斗，获得一次额外奖励。" },
},
```

`keywordList` 每项使用 `keywordId`，需要把关键词作为自身状态展示时再填写 `isSelf = 1`：

```lua
keywordList = {
    { keywordId = 1006, isSelf = 1 },
},
```

没有关键词时使用空表。`extend` 也保持空表，除非正在复用一枚已有晶片已经验证过的特殊结构。

## 在 MOD 中新增 `chip_def`

配置文件放在：

```text
config/chip_def/config/*.lua
```

下面新增 Chip `990501`，并让它在战斗中携带 Static Skill `990551`：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990501,
            name = "示例：稳定晶片",
            descLua = {
                { desc = "进入战斗后获得一项持续效果。" },
            },
            triggerEffect = {},
            skillList = {},
            staticList = { 990551 },
            pvpReplace = 0,
            assetId = 1102,
            backAssetId = 1,
            type = { 1 },
            extend = {},
            keywordList = {},
        },
    },
}
```

`installKey = "id"` 表示按 Chip ID 安装。示例中的 Static Skill `990551` 需要在同一个 MOD 的 `static_skill_def` 中另外提供。

新增 Chip 后，它还需要进入 [`act_chip_pool_def.base_pool`](act_chip_pool_def.md)，或被 [`reward_def`](reward_def.md#chip从晶片池选择-chip) 直接引用，玩家才能在战役中获得它。
