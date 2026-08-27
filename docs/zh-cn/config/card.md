# Card 配置教学

当前 Card 教学覆盖从手牌使用的普通战术 Card。Card 可以引用游戏已有配置，也可以引用同一个 MOD 新增的 Skill、Target 和费用 Effect。

触发式异能和静态异能的完整配置分别见[触发式异能配置](skill_def.md)与[静态异能配置](static_def.md)。本页不覆盖音频、无人机、机体、设备或其他复杂 Card 形态。

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
| `targetIds` | list | 已存在的 Target ID 列表；见 [Target 配置参考](targets.md) |
| `costEffect` | int | 已存在的费用 Effect ID；见 [Effect 配置参考](effects.md) |
| `skillList` | list | 游戏已有或同一个 MOD 新增的 Skill ID 列表；结算关系见下方说明 |

### Target 与 Effect 的关系

Card 的 `targetIds` 决定打出 Card 时可以选择谁。Effect 的 `targetId` 决定该 Effect 实际作用于谁。两者可以不同：同一张 Card 可以先选择一个敌人，同时让某个 Effect 作用于己方，让另一个 Effect 作用于刚才选择的敌人。

```text
Card
  |-- targetIds ------> 打出 Card 时允许选择的目标
  |-- costEffect -----> 支付费用时执行的 Effect
  `-- skillList ------> Skill
                          `-- effect ------> 按顺序执行的 Effect
                                               `-- targetId ----> 该 Effect 的作用目标
```

一个 Skill 可以依次执行多个 Effect，每个 Effect 都使用自己的 `targetId`。

Core Card `2061`“连续射击α”的配置是：

```lua
targetIds = { 40 }
costEffect = 8012
skillList = { 206101 }
```

它的执行关系是：

```text
Card 2061
  |-- Target 40：选择一个敌方单位
  |-- Effect 8012：支付 1 点能量
  `-- Skill 206101
        |-- Effect 1534：创建 Card 2097
        `-- Effect 8026：对所选敌方造成 2 点伤害
```

这些字段填写的 ID 必须能在安装完成后的配置中查询到，可以引用游戏已有配置，也可以引用同一个 MOD 新增的配置。引用不存在时，Card 无法正常读取或结算。

Target、Condition、Trigger、触发式异能和 Effect 的配置方式见对应参考文档。

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

`staticList` 填写 Card 自带的静态异能 ID。静态异能的来源区域、目标范围、Condition 和 Attr 写法见[静态异能配置](static_def.md)。

`useConditions` 可以引用 Battle Condition；字段、类型和组合规则见 [Battle Condition 配置参考](conditions.md#battle-condition)。

## Card 图片

`assetId` 有三种写法：

```lua
-- 省略：默认 Core 图片 10001

assetId = 10001
-- 使用已有 Core Card 图片

assetId = "cards/fire_drone.png"
-- 使用当前 MOD 的 assets/cards/fire_drone.png
```

`assetId` 使用相对于 MOD `assets/` 目录的 PNG 路径。

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

`name` 保留原文。需要翻译时，由 MOD 提供 `language/language.csv`。

## 能力请求

需要音频、无人机、机体、设备或文档未覆盖的 Card 形态时，在 GitHub Issues 中选择“能力请求”，并按玩家可见结果描述目标行为。
