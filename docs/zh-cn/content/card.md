# Card 配置教学

当前支持的 Card 作者范围是：从手牌使用、复用游戏已有 Skill、Target、费用效果和 Tag 的普通战术 Card。

本页不表示已经支持自定义 Skill、Target、费用效果、音频、无人机、机体、设备或所有复杂 Card 形态。

## 最小 Card

文件位置：

```text
config/card_def/config/cards.lua
```

内容：

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            name = "Example: Fire Drone",
            rare = 1,
            type = { 2 },
            tagMap = { [3] = 1, [31] = 1 },
            targetIds = { 40 },
            costEffect = 8012,
            skillList = { 201201 },
        },
    },
}
```

## 8 个必填字段

| 字段 | 类型 | 规则 |
| --- | --- | --- |
| `cardId` | 正整数 | Card 查询和安装键；新增内容应避免 ID 冲突 |
| `name` | string | 配置中的原文显示名称 |
| `rare` | int | 稀有度值；参考同版本 Core Card |
| `type` | list | Card 类型 ID 列表 |
| `tagMap` | map | `tagId -> value`；所有 Tag 必须已存在 |
| `targetIds` | list | 已存在的 Target ID 列表 |
| `costEffect` | int | 已存在的费用 Effect ID |
| `skillList` | list | 已存在的 Skill ID 列表 |

安装时会校验 `tagMap`、`targetIds`、`costEffect` 和 `skillList` 的 Core 引用。引用不存在时，整轮 MOD 配置安装失败并回滚。

字段的完整联动规则见[配置字段参考](../reference/config-fields.md)，当前已经核实的 Core 起始组合见[可复用的 Core 配置](../reference/core-configs.md)。

## 自动默认值

缺少下列字段时，Card 作者适配器会填入固定默认值：

```lua
tag = {}
descLua = {}
extraCost = {}
staticList = {}
attkSkill = 0
dir = 0
dirSkillList = {}
areaSkillList = {}
hp = 0
useConditions = { 0 }
stackcard = {}
stackcardSkill = {}
extend = {}
limitBaseIds = {}
upgrade = 0
slotType = { 0 }
initCard = 0
pvpReplace = 0
assetId = 10001
mainType = 1
mainTag = {}
subTag = {}
iconId = 0
deviceStackIcon = {}
keywordList = {}
```

显式填写的空列表或数值不会被默认值覆盖。

## Card 图片

`assetId` 有三种写法：

```lua
-- 省略：默认 Core 图片 10001

assetId = 10001
-- 使用已有 Core Card 图片

assetId = "cards/fire_drone.png"
-- 使用当前 MOD 的 assets/cards/fire_drone.png
```

相对 PNG 路径的完整限制见 [PNG 资源](../assets.md)。

## 把 Card 放进奖励

仅安装 `card_def.config` 会让配置可查询，但不会自动把 Card 放进奖励或牌组。

[`card-pack`](../../../templates/card-pack/README.md) 使用两个额外批次完成可操作测试：

1. `act_card_pool_def.base_pool` 创建测试池 `990001`；
2. `reward_def.config` 覆盖测试奖励 `10003`，使其读取该卡池。

卡池批次使用组替换：

```lua
return {
    installKey = "poolId",
    installValue = 990001,
    rows = {
        {
            cardId = 910001,
            baseId = 501,
            poolId = 990001,
            minBaseLevel = 1,
            maxBaseLevel = 10,
            limitActIds = { -1 },
        },
    },
}
```

`installValue=990001` 只操作该卡池组。省略 `operation` 时默认整组 `replace`。

## 游戏内验证

Card 完成标准包括：

1. 冷启动没有 MOD 配置或加载错误；
2. 正常 Rogue 奖励出现 Card；
3. 选择后进入当前 Rogue 战役牌组；
4. 重启同一存档后仍然存在；
5. 战斗中可以抽取、选择合法目标并打出；
6. 普通战术 Card 成功打出后离开手牌并进入 `desk(area=3)`。

仅能通过 `Config.Get` 查询到 Card 不等于完成游戏内验证。

## 多语言

`name` 保留原文。翻译放在 `language/language.csv`，规则见[多语言](../localization.md)。

## 能力请求

需要自定义 Skill、Target、费用 Effect 或文档未覆盖的 Card 形态时，在 GitHub Issues 中选择“能力请求”，并按玩家可见结果描述目标行为。
