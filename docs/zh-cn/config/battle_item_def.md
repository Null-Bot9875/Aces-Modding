# `battle_item_def` 配置参考

> `battle_item_def` 定义战斗道具的显示信息、使用次数和结算 Skill。

## `battle_item_def` 的基本结构

`转运服务`（Battle Item `3001`）：使用后抽 3 张 Card。

```lua
{
    id = 3001,
    name = "转运服务",
    assetId = 30011,
    assetId2 = 3001,
    type = { 1 },
    rare = 3,
    backAssetId = 1,
    useLimit = 1,
    desc = "抽3张牌",
    useEffect = {},
    useSkillId = 300101,
    extend = {},
    keywordList = {},
}
```

它的结算关系是：

```text
Battle Item 3001：转运服务
└─ useSkillId → Skill 300101：转运服务
   ├─ targetIds → Target 100：自己
   └─ effect → Effect 3001：抽 3 张 Card
```

当前新增一条 `battle_item_def` row 时，需要列出下面这些字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `id` | 正整数 | Battle Item 的配置 ID，也是安装和查询键 |
| `name` | string | Battle Item 名称 |
| `assetId` | int | 道具详情使用的图片资源 ID |
| `assetId2` | int | 战斗道具栏使用的图标资源 ID |
| `type` | int[] | Battle Item 的显示分类 |
| `rare` | int | 稀有度 |
| `backAssetId` | int | 道具背景资源 ID |
| `useLimit` | int | 使用次数配置；普通一次性道具填 `1` |
| `desc` | string | 玩家看到的效果说明 |
| `useEffect` | table | 战役背包的使用效果；战斗道具保持 `{}` |
| `useSkillId` | int | 使用道具时执行的 [`battle_skill_def.skillId`](battle_skill_def.md) |
| `extend` | table | 补充数据；普通战斗道具填 `{}` |
| `keywordList` | table[] | 详情展示的关键词；不使用时填 `{}` |

## `useSkillId`：使用道具后如何结算

战斗道具的主要行为由 `useSkillId` 决定。它引用一条主动 Skill，Skill 再负责目标选择、使用条件和 Effect 顺序。

`转运服务`引用 Skill `300101`：

```lua
{
    skillId = 300101,
    name = "转运服务",
    tag = "道具",
    desc = "抽3张牌",
    effect = { 3001 },
    targetIds = { 100 },
    useConditions = { 0 },
    trigger = 0,
}
```

道具需要选择目标时，也是在 Skill 的 `targetIds` 中配置。`battle_item_def` 本身不再保存一份目标列表。

Effect `3001` 完成实际结算：

```lua
{
    effectId = 3001,
    desc = "抽3张牌",
    targetId = 100,
    event = 11,
    value = 3,
}
```

新增道具时，先确定完整的 Skill 和 Effect，再把 Skill ID 填入 `useSkillId`。Skill 的字段见 [`battle_skill_def`](battle_skill_def.md)，Effect 的字段见 [`battle_effect_def`](battle_effect_def.md)。

## 显示与使用字段

`name`、`desc`、`assetId`、`assetId2`、`rare`、`backAssetId`、`type` 和 `keywordList` 负责道具栏与详情显示。

当前 Battle Item 的 `type` 使用 `1`～`5`，`backAssetId` 通常使用与 `type` 相同的数值。它们共同决定道具的显示分类和背景；复用现有图片时，沿用该图片对应道具的这一组数值。`rare` 使用现有稀有度数值，并会影响稀有度显示。

`useEffect` 不是战斗 Skill 的替代写法。它用于战役背包中的局外道具，当前战斗道具保持空表：

```lua
useEffect = {},
```

`keywordList` 每项使用 `keywordId`；没有关键词时使用空表。

## 在 MOD 中新增 `battle_item_def`

配置文件放在：

```text
config/battle_item_def/config/*.lua
```

下面新增 Battle Item `990601`，使用时执行 Skill `99060101`：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990601,
            name = "示例：紧急补给",
            assetId = 30011,
            assetId2 = 3001,
            type = { 1 },
            rare = 3,
            backAssetId = 1,
            useLimit = 1,
            desc = "抽1张牌。",
            useEffect = {},
            useSkillId = 99060101,
            extend = {},
            keywordList = {},
        },
    },
}
```

`installKey = "id"` 表示按 Battle Item ID 安装。示例中的 Skill `99060101` 需要在同一个 MOD 的 `battle_skill_def` 中另外提供。

新增 Battle Item 后，可以通过 [`reward_def`](reward_def.md#battleitem获得-battle-item) 发放：

```lua
value = {
    { battleItem = { id = 990601, count = 1 } },
}
```
