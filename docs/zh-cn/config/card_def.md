# `card_def` 配置参考

> `card_def` 定义 Card 的名称、颜色、目标、费用和结算入口，并补充战术卡、无人机卡与机师卡各自需要的战斗字段。

本文只涉及战术卡、无人机卡和机师卡。道具与晶片使用其他配置表，不在本文范围。

## `card_def` 的基本结构

`连续射击α`（Card `2061`）是一张白色战术卡。玩家支付 1 点能量并选择一个敌方单位后，它会造成 2 点伤害，再把 1 张 `连续射击β` 加入手牌。`连续射击β` 会消耗，造成 2 点伤害并创造 1 张 `连续射击γ`。
```lua
{
    cardId = 2061,
    name = "连续射击α",
    tag = { "战术" },
    descLua = {
        { desc = "desc_2061_1" },
    },
    targetIds = { 40 },
    costEffect = 8012,
    extraCost = {},
    skillList = { 206101 },
    staticList = {},
    attkSkill = 0,
    dir = 0,
    dirSkillList = {},
    areaSkillList = {},
    hp = 0,
    useConditions = { 0 },
    stackcard = {},
    stackcardSkill = {},
    extend = {
        linkCards = { 2097 },
    },
    tagMap = {
        [3] = 1,
        [31] = 1,
    },
    upgrade = 2062,
    assetId = 5097,
    mainType = 1,
    type = { 4 },
    mainTag = { "战术" },
    subTag = { "基础" },
    iconId = 0,
    rare = 3,
    deviceStackIcon = {},
    keywordList = {},
}
```

它的引用与结算关系是：

```text
Card 2061：连续射击α（造成 2 点伤害，并创造 1 张连续射击β）
├─ targetIds → Target 40：选择 1 个敌方单位
├─ costEffect → Effect 8012：自身减少 1 点能量
└─ skillList → Skill 206101：连续射击
   ├─ Effect 1534：创建 Card 2097 连续射击β（消耗；造成 2 点伤害，并创造 1 张连续射击γ）
   └─ Effect 8026：对所选敌方造成 2 点伤害
```

`card_def` 有 8 个必填字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `cardId` | 正整数 | Card 的配置 ID，也是安装和查询键 |
| `name` | string | Card 的显示名称 |
| `rare` | int | Card 的稀有度 |
| `type` | int[] | Card 的颜色列表，不负责区分战术卡、无人机卡和机师卡 |
| `tagMap` | dict&lt;int, int&gt;| Card 的运行时 Tag；用于区分 Card 类型并参与筛选 |
| `targetIds` | int[] | 使用 Card 时要完成的目标选择；见 [`battle_target_def` 配置参考](battle_target_def.md) |
| `costEffect` | int | 基础费用使用的 Effect；见 [`battle_effect_def` 配置参考](battle_effect_def.md) |
| `skillList` | int[] | Card 使用或进入战场后携带的 Skill 列表；见 [`battle_skill_def` 配置参考](battle_skill_def.md) |

这 8 个字段缺失或类型错误时，Card 批次不能安装。安装过程不会主动确认 `targetIds`、`costEffect`、`skillList` 或 `tagMap` 中的每个 ID 都存在；引用错误通常会在 Card 被显示、使用或结算时才暴露。

## Card 如何被使用并完成结算

Card 从“可以使用”到“完成结算”依次经过以下部分：

```text
useConditions
    ↓
costEffect + extraCost
    ↓
targetIds
    ↓
skillList / attkSkill / dirSkillList / 其他类型字段
    ↓
stackFinArea
```

### `useConditions`：当前是否允许使用

`useConditions` 填写 [`battle_condition_def.id`](battle_condition_def.md) 列表。默认值 `{ 0 }` 表示不增加使用条件。

普通条件检查当前 Card 或 Player。条件必须先满足，Card 才会继续处理费用和目标选择。

`斩钢势`（Card `10314`）：仅当主将处于延缓状态时可以使用。使用时移除主将的延缓作为额外费用，再让主将机体进行 1 次攻击。

需要检查主将机体是否处于指定状态。它使用 `extend.conditionTarget` 先自动取得要检查的目标，再把该目标交给 `useConditions`：

```lua
useConditions = { 2138 }
extend = {
    conditionTarget = 60,
}
```

`conditionTarget` 填写 Target ID。只有需要先选定一个对象再判断 Condition 时才需要。

### `costEffect` 与 `extraCost`：支付费用

`costEffect` 是单个基础费用 Effect。`连续射击α` 的 `costEffect=8012` 会让使用者减少 1 点能量。

`extraCost` 是额外费用 Effect 列表。它不会替代 `costEffect`，两部分都会进入费用处理。

`债务欠条`（Card `11029`）：消耗 20 点星核作为额外费用；被弃置到弃牌堆时，再失去 10 点星核。它把 Effect `4742` 作为额外费用：

```lua
costEffect = 8011
extraCost = { 4742 }
```

### `targetIds`：完成目标选择

`targetIds` 决定打出 Card 时需要选择哪些对象。`{ 40 }` 表示按 Target `40` 选择 1 个敌方单位；`{ 0 }` 表示不增加目标选择。

Card 的 `targetIds` 只负责使用阶段的选择。真正执行 Effect 时，每个 Effect 仍使用自己的 `targetId`，因此一张 Card 可以选择敌人，同时让不同 Effect 分别作用于自己、敌人或其他对象。

### 进入实际结算

战术卡通常从 `skillList` 开始执行。无人机卡和机师卡还会读取 `attkSkill`、`staticList`、`dirSkillList`、`hp` 与 `extend` 中的类型字段。

这些字段不是同时执行的一组通用 Skill。它们在不同 Card 类型、Area 和 Trigger 下被读取，具体组合见后面的三个 Card 类型章节。

### `extend.stackFinArea`：结算后去哪里

战术卡进入战斗堆叠后，默认在结算结束时移动到 `Desk`（area `3`）。消耗卡可以用 `extend.stackFinArea` 改写这个去向。

`突击指令`（Card `2008`）：消耗；让所有己方机体进行 1 次攻击。它从手牌进入堆叠并完成结算后，会进入 `Scrap`（area `4`）：

```lua
extend = {
    stackFinArea = {
        old = 2,
        new = 4,
    },
}
```

这里的 `old=2` 表示 Card 原本来自 `Hand`，`new=4` 表示堆叠结束后移入 `Scrap`。这项规则只改写战术卡的结算去向，不决定 Skill 本身如何执行。

## Card 的显示与分类字段

下面这些字段决定 Card 在卡面、详情和筛选界面中的显示方式：

| 字段 | 类型 | 默认值 | 作用 |
| --- | --- | --- | --- |
| `name` | string | 必填 | Card 名称 |
| `descLua` | lua | `{}` | Card 说明片段；Core Card 通常填写语言 key |
| `assetId` | int 或 string | `10001` | Core Card 图片 ID，或当前 MOD `assets/` 下的相对 PNG 路径 |
| `rare` | int | 必填 | 稀有度；会影响卡面稀有度显示 |
| `type` | int[] | 必填 | Card 颜色：`1` 绿、`2` 红、`3` 蓝、`4` 白 |
| `tagMap` | dict&lt;int, int&gt; | 必填 | 运行时 Tag；例如 `3` 为战术卡、`4` 为无人机卡、`8` 为机师卡 |
| `mainType` | int | `1` | 界面使用的上层 Card 分类；普通 Card 保持 `1` |
| `tag` | string[] | `{}` | Card 的文本标签列表 |
| `mainTag` | string[] | `{}` | 卡面使用的主标签文本 |
| `subTag` | string[] | `{}` | 卡面使用的副标签文本 |
| `iconId` | int | `0` | Card 的额外图标 ID |
| `keywordList` | table[] | `{}` | Card 详情要展示的关键词；每项使用 `keywordId`，需要时补 `isSelf=1` |

`type` 只决定颜色。判断一条 row 是战术卡、无人机卡还是机师卡时，主要看 `tagMap`，不能用颜色代替类型判断。

`tagMap` 是运行时分类数据，`tag`、`mainTag` 和 `subTag` 是文本标签。它们用途不同，不要因为显示文字相同就只填其中一组。

字段经常使用默认值，不表示字段没有作用。例如大多数普通 Card 的 `mainType=1`，但界面仍会读取该字段；`iconId=0` 只表示当前 Card 不增加额外图标。

`assetId` 使用字符串时，路径相对于当前 MOD 的 `assets/` 目录，并且必须是 `.png`：

```lua
assetId = "cards/continuous_shot_alpha.png"
```

对应文件位置为 `assets/cards/continuous_shot_alpha.png`。

## 战术卡

战术卡主要通过 `skillList` 结算。`连续射击α`（Card `2061`）会造成 2 点伤害，并创造 1 张 `连续射击β`。它使用 Skill `206101`，Skill 再依次执行创建 Card 和造成伤害的两个 Effect。

```lua
cardId = 2061
targetIds = { 40 }
costEffect = 8012
skillList = { 206101 }
upgrade = 2062
extend = {
    linkCards = { 2097 },
}
```

`upgrade=2062` 表示这张 Card 的升级目标是 Card `2062`。Rogue 升级等流程会用这组关系找到升级后的 Card；升级目标必须另外提供一条完整 `card_def` row。

`extend.linkCards={2097}` 让 Card 详情把 `连续射击β` 作为关联 Card 展示。它不负责创建 Card；真正创建 `2097` 的是 Skill `206101` 引用的 Effect `1534`。

战术卡如果没有专属结构，只需要使用前面讲过的必填字段和共用结算字段。消耗卡再按需要增加 `extend.stackFinArea`。

## 无人机卡

无人机卡会进入战场并成为持续存在的 Card。除了派出时的 Skill，它还需要基础 HP、攻击 Skill、方向和模型。

### 基本案例：`运输无人机`

`运输无人机`（Card `2023`）支付 1 点能量并选择己方可放置位置。派出后抽 1 张牌，并以 2 点 HP、1 点基础攻击（`attkSkill=501`）留在战场。

```lua
{
    cardId = 2023,
    name = "运输无人机",
    rare = 3,
    type = { 4 },
    tagMap = {
        [4] = 1,
    },
    targetIds = { 21 },
    costEffect = 8012,
    skillList = { 202301 },
    attkSkill = 501,
    dir = 6,
    hp = 2,
    upgrade = 2024,
    assetId = 11002,
    mainType = 1,
    mainTag = { "无人机" },
    extend = {
        modelId = "drone_ace1_defense_s",
    },
}
```

```text
Card 2023：运输无人机（派出时抽 1 张 Card；2 点 HP；基础攻击造成 1 点伤害）
├─ targetIds → Target 21：选择己方放置位置
├─ skillList → Skill 202301：派出时抽 1 张 Card
├─ hp=2：进入战场时的基础 HP
├─ attkSkill=501：基础攻击造成 1 点伤害
├─ dir=6：进入战场时的方向
└─ extend.modelId：创建和显示无人机模型
```

#### `attkSkill`：常用基础攻击 Skill

`attkSkill` 填写 [`battle_skill_def.skillId`](battle_skill_def.md)。
内部有设置提供一组固定伤害 Skill，可直接用于普通无人机的基础攻击：

| `attkSkill` | 基础攻击结果 |
| --- | --- |
| `500`～`511` | 依次造成 0～11 点伤害 |
| `515` | 造成 15 点伤害 |
| `520` | 造成 20 点伤害 |

例如，`attkSkill=501` 使用 Skill `501`，基础攻击造成 1 点伤害；`attkSkill=505` 则造成 5 点伤害。

这些数字是现有 Skill 的编号约定，运行时仍会执行对应 Skill 引用的 Effect。不要据此填写并不存在的 `512`～`514`。需要其他数值或特殊攻击行为时，应新增 [`battle_skill_def`](battle_skill_def.md) row，再把新 `skillId` 填到 `attkSkill`。

`extend.modelId` 是创建无人机模型的必需数据。填写不存在的模型 ID 时，Card row 可能可以安装，但无人机创建、预加载或显示会失败。

### 组合案例：`连击无人机`

`连击无人机`（Card `2037`）：连击 1；方向连接生效时获得 +2/+0。它用 `staticList` 提供连击，用 `dirSkillList` 提供与方向相关的攻击加成：

```lua
staticList = { 203752 }
attkSkill = 501
dir = 6
dirSkillList = { 203751 }
hp = 2
extend = {
    modelId = "drone_ace1_attack_s",
}
```

Static Skill `203752` 提供“连击 1”。`dirSkillList` 中的 `203751` 也是 Static Skill，在方向规则成立时为自身增加 2 点攻击。

`dirSkillList` 虽然名字包含 `Skill`，这里实际可以引用 `static_skill_def.id`。Static Skill 自身的目标、Condition 和持续规则见 [`static_skill_def` 配置参考](static_skill_def.md)。

### `stackcard`：允许集成到哪些 Card

`stackcard` 是可接受当前 Card 集成的目标 Card ID 列表。列表为空时，当前 Card 不能通过这条规则集成到其他 Card。

`武装组件`（Card `2147`）：派出时抽 1 张牌；方向连接生效时获得 +1/+1。它只允许集成到 `stackcard` 列出的武装 Card：

```lua
stackcard = {
    7617,
    7618,
    7619,
    7620,
    7621,
    7622,
    7623,
    7624,
    7625,
    7626,
    7627,
    7628,
    7629,
    7631,
    7632,
    10463,
    10464,
    2155,
    2156,
    2177,
    2178,
    10465,
    10466,
    10467,
    10468,
    10469,
    10681,
    10682,
    10683,
}
```

运行时会逐项比较目标 Card 的 `cardId`。这里不是 Tag 列表，也不会自动包含同类型的新 Card。

### `stackcardSkill`：集成后提供什么异能

`stackcardSkill` 填写集成时要附加到宿主 Card 的 Skill 或 Static Skill ID。移除该集成 Card 时，对应异能也会从宿主移除。

`海神武装`（Card `2177`）：自身具有连击 1；作为武装集成后，再向宿主提供连击 1。它通过 `stackcardSkill` 把 Static Skill `217751` 提供给宿主：

```lua
stackcardSkill = { 217751 }
```

运行时会先尝试按 `battle_skill_def.skillId` 查找；找不到时再按 `static_skill_def.id` 处理。不要让两个配置表使用同一个 ID 表达不同异能。

### `deviceStackIcon`：集成图标

`deviceStackIcon` 是集成 Card 的图标编号列表。`武装组件`和`海神武装`都使用图标 `7`：

```lua
deviceStackIcon = { 7 }
```

这项字段只负责 Card 的集成图标显示，不代替 `stackcard` 或 `stackcardSkill`。

### `areaSkillList`：Card 位于指定 Area 时监听 Skill

`areaSkillList` 不是无人机专属字段。它使用 `Area ID -> Skill ID 列表` 的映射，让 Card 位于指定 Area 时继续监听这些 Skill。

`紧急维修`（Card `7599`）：消耗；回复 3 点装甲。它位于 `Scrap`（area `4`）时，废弃另一张非同名 Card 会触发 Skill `759902`，将它返回手牌：

```lua
areaSkillList = {
    [4] = { 759902 },
}
```

同一张 Card 可以为多个 Area 配置不同列表。运行时只读取 Card 当前 `area` 对应的那一项。

### `extend.forceMove`：改写无人机离场位置

`extend.forceMove` 只在 Card 从指定 `old` Area 移动、且原本要进入 `Desk` 时，把目的地改成 `new`。

`原型无人机`（Card `2002`）：1 点 HP，基础攻击造成 1 点伤害。它离开无人机区且原本要进入 `Desk` 时，会改为进入 `Scrap`：

```lua
extend = {
    modelId = "drone_ace1_defense_s",
    forceMove = {
        old = 14,
        new = 4,
    },
}
```

`old=14` 是 `Drone`，`new=4` 是 `Scrap`。这条规则不会改变从其他 Area 发起的移动，也不会覆盖本来就不是去往 `Desk` 的移动。

## 机师卡

机师卡会选择一台可搭乘机体，并通过 Skill、Static Skill 与 `hero_def` 共同组成机师行为。

`夏洛`（Card `21064`）搭乘时和每个回合开始时，让所搭乘机体受到 1 点伤害，并获得“战术伤害增加 1”。

```lua
{
    cardId = 21064,
    name = "夏洛",
    rare = 2,
    type = { 3 },
    tagMap = {
        [8] = 1,
        [302] = 1,
    },
    targetIds = { 22 },
    costEffect = 8011,
    skillList = {
        2106401,
        2106402,
    },
    staticList = {
        2106451,
        2106452,
    },
    hp = 3,
    assetId = 305,
    mainType = 1,
    mainTag = { "无人机" },
    keywordList = {
        { keywordId = 1004 },
    },
    extend = {
        heroId = 21064,
    },
}
```

```text
Card 21064：夏洛（搭乘时和每个回合开始时，使搭乘机体受到 1 点伤害并获得战术伤害增加 1）
├─ targetIds → Target 22：选择可搭乘的己方机体
├─ skillList → Skill 2106401、2106402
├─ staticList → Static Skill 2106451、2106452
├─ hp=3：机师 Card 的基础 HP
└─ extend.heroId → hero_def 21064：机师资料与显示信息
```

`skillList` 负责主动或触发式结算，`staticList` 负责机师在有效期间持续提供的规则。两个列表可以同时存在，但引用的是不同配置表。

`extend.heroId` 填写 `hero_def.id`。客户端会用它读取机师资料和说明；不存在的 `heroId` 会导致机师 Card 无法完整显示。

`hp` 在无人机卡和机师卡中表示基础 HP。战斗中的当前 HP 可以被运行时数据覆盖，`card_def.hp` 不是每次显示都保持不变的最终值。

## `modelId` 与可用模型

`extend.modelId` 决定无人机 Card 创建和预加载哪个游戏模型。它只能引用客户端已经包含的模型，不能通过一个字符串把新模型导入游戏。

本页案例使用了两个当前 Core Card 已在使用的值：

| `modelId` | 代表 Card | Card 描述 |
| --- | --- | --- |
| `drone_ace1_defense_s` | `运输无人机`（Card `2023`） | 派出时抽 1 张牌；2 点 HP；基础攻击造成 1 点伤害 |
| `drone_ace1_attack_s` | `连击无人机`（Card `2037`） | 连击 1；方向连接生效时获得 +2/+0 |

这张表不是完整模型目录。模型资源会随客户端版本变化，不能把 `card_def.model` 全表或历史 Card 中出现过的字符串直接当成稳定候选。

MOD 首版只能复用游戏已经提供、并在目标版本中确认能正常加载的模型。需要新增自定义模型时，不能只修改 `modelId`，还需要独立的资源导入能力。

## 在 MOD 中新增 `card_def`

Card 配置文件放在：

```text
config/card_def/config/*.lua
```

安装键是 `cardId`。下面是一条只填写 8 个必填字段的最小批次：

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            name = "示例：火力脉冲",
            rare = 1,
            type = { 4 },
            tagMap = {
                [3] = 1,
                [31] = 1,
            },
            targetIds = { 40 },
            costEffect = 8012,
            skillList = { 910001 },
        },
    },
}
```

省略的字段会获得作者适配器默认值。例如 `useConditions={0}`、`staticList={}`、`extraCost={}`、`hp=0`、`assetId=10001`、`mainType=1` 和 `extend={}`。

新增 `cardId` 后，其他配置可以通过该 ID 引用它：

```text
act_card_pool_def.base_pool.cardId → 910001
reward_def 中的 Card 奖励          → 910001
另一张 Card 的 upgrade            → 910001
另一张 Card 的 extend.linkCards   → 910001
battle_effect_def 的创建 Card      → 910001
```

只安装 `card_def.config` 会让 Card 可以被查询，不会自动把它加入卡池或奖励。要让玩家实际获得它，还需要把 `cardId` 加入对应的 `act_card_pool_def` 或 `reward_def` 配置链。

安装成功只证明 row 结构、必填字段和字段类型通过检查。
引用的 Target、Effect、Skill、Static Skill、Tag、图片与模型仍要在实际显示和战斗结算中验证。
