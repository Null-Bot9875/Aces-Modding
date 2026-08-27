# `static_skill_def` 配置参考

> `battle_skill_def` 会在指定 Trigger 出现时执行 Effect。
`static_skill_def` 不等待 Trigger，而是在来源有效期间持续改变 Card 或 Player 的战斗属性。


## `static_skill_def` 的基本结构

`晋升指令`（Card `2016`）：目标己方无人机获得 +2/+2，随后进行一次攻击。→

```lua
{
    id = 201651,
    name = "晋升指令",
    desc = "+2/+2",
    srcArea = { 14 },
    targetArea = { 14 },
    effect = {
        attkAdd = 2,
        hpAddDrone = 2,
    },
    flag = {
        self = 1,
    },
    conditionList = { 0 },
    conditionListSelf = {},
    visibility = 0,
    keywordList = {},
    disable = 1,
    showEffects = {
        "mecha_common_uav_buffhold_01",
    },
}
```

这张 Card、Skill、Effect 和 Static Skill 的结算关系是：

```text
Card 2016：晋升指令
  └─ Skill 201601
       ├─ Effect 1511：向目标添加 Static Skill 201651
       │    └─ Static Skill 201651：目标自身持续获得 +2/+2
       └─ Effect 1512：该目标进行一次攻击
```

Static Skill `201651` 的处理过程是：

```text
来源位于 srcArea={14}
  └─ 从 targetArea={14} 取得候选目标
       └─ flag.self=1，只保留来源自身
            └─ 向目标应用 effect：attkAdd=2、hpAddDrone=2
```

### 必填字段

在 MOD 中新增 `static_skill_def` 时，以下五个字段必须填写：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | int | Static Skill 的唯一 ID |
| `name` | string | Static Skill 名称 |
| `srcArea` | list[int] | 来源位于哪些 Area 时，Static Skill 生效 |
| `targetArea` | list[int] | 生效时，从哪些 Area 取得候选目标 |
| `effect` | table | 持续应用到目标的 Attr |

### 可以省略的字段

其他字段没有使用时可以省略。安装 MOD 时会补成以下值：

| 字段 | 缺省值 | 含义 |
| --- | --- | --- |
| `desc` | `""` | 不提供单独显示的异能说明 |
| `flag` | `{}` | 不增加来源关系、阵营、位置或移除规则 |
| `conditionList` | `{}` | 不检查候选目标的 Condition |
| `conditionListSelf` | `{}` | 不检查异能来源的 Condition |
| `visibility` | `0` | 不单独显示异能说明 |
| `keywordList` | `{}` | 不显示关联关键字 |
| `disable` | `1` | 来源被沉默时，Static Skill 停止生效 |
| `showEffects` | `{}` | 不播放持续特效 |

`flag={}` 不表示“只作用于来源自身”。只需要影响来源自身时，仍要明确填写 `flag={self=1}`。

## 静态异能如何进入战斗

Static Skill 可以由 Card 自带，也可以由 Effect 在战斗中添加或移除。

### Card 通过 `staticList` 自带

`邓肯23`（Card `7000`）：自带覆膜，并在变身后保留。→

```lua
staticList = { 700051 },
```

Card 位于这项 Static Skill 的 `srcArea` 时，异能开始生效；离开全部生效区域后，异能停止生效。

### Effect 添加或移除

`event=60` 添加 Static Skill，`value` 填写 Static Skill ID。

`晋升指令`（Card `2016`）：向选择的己方无人机添加 Static Skill `201651`。→

```lua
event = 60,
targetId = 613,
value = 201651,
```

`event=61` 移除 Static Skill，`value` 同样填写 Static Skill ID。

`重整旗鼓`（Card `10326`）：取消主将的疾驰协议费用限制。→

```lua
event = 61,
targetId = 100,
value = 1034051,
```

这段配置会从目标 Player 移除 Static Skill `1034051`。Effect 的完整字段见 [`battle_effect_def` 配置参考](battle_effect_def.md)。

## 静态异能如何确定目标并生效

Static Skill 按以下顺序处理来源、候选目标和 Attr：

```text
srcArea：来源当前是否位于生效区域
  └─ conditionListSelf：来源是否满足 Condition
       └─ targetArea：取得候选目标
            └─ flag：按来源关系、阵营和位置筛选
                 └─ conditionList：逐个检查候选目标
                      └─ effect：向通过筛选的目标应用 Attr
```

来源离开全部 `srcArea`、不再满足 `conditionListSelf`，或被对应规则关闭时，由这项 Static Skill 添加的 Attr 会从目标上移除。

### 来源的生效区域：`srcArea`

`srcArea` 决定 Static Skill 的来源何时生效。

```lua
srcArea = { 14 },
```

Area `14` 是战场机体区域。来源进入战场后生效，离开战场后停止。完整 Area 列表见[战斗区域参考](../concepts/areas.md)。

### 候选目标区域：`targetArea`

`targetArea` 决定 Static Skill 生效时去哪些 Area 取得候选目标。它只提供候选范围，最终目标还要经过 `flag` 和 `conditionList` 筛选。

```lua
targetArea = { 2, 6 },
```

这段配置从手牌区和抽牌堆取得候选 Card。

### 只作用于来源自身：`flag.self=1`

`晋升指令`（Card `2016`）：选择的己方无人机获得 +2/+2，并进行一次攻击。→

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = {
    self = 1,
},
conditionList = { 0 },
conditionListSelf = {},
```

```text
来源无人机进入 Area 14
  └─ Area 14 中的无人机成为候选
       └─ self=1，只保留来源无人机
```

`self=0` 表示排除来源自身。省略 `self` 时，不按来源与目标是否为同一对象进行筛选。

### 按目标 Condition 筛选：`conditionList`

`conditionList` 会逐个检查 `targetArea` 中的候选目标。某个候选不满足 Condition 时，只排除该候选，不影响其他目标。

`精英支援`（Chip `4011`）：僚机获得 +2/+2。→

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = {},
conditionList = { 61 },
conditionListSelf = {},
```

```text
来源位于 Area 14
  └─ Area 14 中的无人机成为候选
       └─ Condition 61 逐个检查候选
            └─ 只保留僚机
```

Condition `61` 在这里用于判断候选目标是否为僚机。Condition 自身的字段和完整用法见 [`battle_condition_def` 配置参考](battle_condition_def.md)。

### 按来源 Condition 开关整项异能：`conditionListSelf`

`conditionListSelf` 只检查拥有 Static Skill 的来源。来源不满足 Condition 时，整项异能不生效，也不会继续取得候选目标。

`魔王型核心`（Card `2354`）：达到回路 3 时，自身获得 +3/+0。→

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = {
    self = 1,
},
conditionList = { 0 },
conditionListSelf = { 2025 },
```

```text
来源位于 Area 14
  └─ Condition 2025 检查来源是否达到回路 3
       └─ 通过后只保留来源自身
```

`conditionListSelf` 不是 `conditionList` 的简写。前者决定整项异能是否开启，后者决定每个候选目标是否保留。

### 按战场位置筛选：`flag.gridCheck`

`gridCheck` 根据来源和候选目标的战场位置继续筛选。当前使用的 `side=1` 表示相邻位置。

`充能中枢-7`（Card `2450`）：相邻无人机获得 +2/+0，自身不获得。→

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = {
    self = 0,
    gridCheck = {
        side = 1,
    },
},
conditionList = { 0 },
conditionListSelf = {},
```

```text
Area 14 中的无人机成为候选
  └─ self=0，排除来源自身
       └─ gridCheck.side=1，只保留相邻无人机
```

### 阵营与所属 Player：`targetCamp`、`selfPlayer`

`targetCamp` 以来源所属阵营为参照，改变取得候选目标的阵营范围：

| 配置 | 结果 |
| --- | --- |
| 省略 `targetCamp` | 从来源所属 Player 取得候选 |
| `targetCamp=0` | 从来源所属阵营的全部 Player 取得候选 |
| `targetCamp=1` | 从敌方阵营取得候选 |

`行动代号：老兵`（Chip `5100`）：敌方普通无人机获得 +2/+2。→

```lua
flag = {
    targetCamp = 1,
},
```

`selfPlayer` 用于已经扩展到同一阵营多个 Player 的候选范围：

| 配置 | 结果 |
| --- | --- |
| `selfPlayer=1` | 只保留来源所属 Player 的目标 |
| `selfPlayer=0` | 排除来源所属 Player，只保留同阵营其他 Player 的目标 |

`避战的`（Chip `6003`）：双方所有无人机攻击减少 2。→

```lua
-- Static Skill 1600351：同阵营的其他 Player
flag = {
    selfPlayer = 0,
},

-- Static Skill 1600352：来源所属 Player
flag = {
    selfPlayer = 1,
},
```

### 多个 Condition 的组合方式

`flag.conditionType` 控制 `conditionList`，`flag.conditionTypeSelf` 控制 `conditionListSelf`。

| 值 | 组合方式 |
| --- | --- |
| `1` 或省略 | 全部 Condition 都满足，即 AND |
| `2` | 满足任意一个 Condition，即 OR |

没有 Condition 时直接填写空表 `{}`。现有配置中的 `{0}` 同样表示没有 Condition，但新增配置不需要保留占位 ID `0`。

## `effect`：持续应用 Attr

`effect` 是“Attr 名称 → 值”的 table，不是 Effect ID 列表。

```lua
effect = {
    attkAdd = 2,
    hpAddDrone = 2,
},
```

这段配置同时增加 2 点攻击和 2 点装甲上限。同一项 Static Skill 可以填写多个 Attr；名称区分大小写。

来源失效或目标不再通过筛选时，这项 Static Skill 添加的 Attr 会从对应目标上移除。可用 Attr、值的含义和适用目标见 [Attr 参考](../concepts/attrs.md)。

## `miscFunc`：动态计算 Attr

固定数值直接写成 `effect={attkAdd=2}`。需要根据战斗状态计算数值时，在 `effect.miscFunc` 中填写计算规则。

```text
最终 Attr 数值 = A + B × 来源数值
```

| 字段 | 含义 |
| --- | --- |
| `valueType` | 来源数值的取得方式 |
| `effectKey` | 把结果写入哪个 Attr；省略时使用 `damageAdd` |
| `A` | 固定加值；省略时为 `0` |
| `B` | 来源数值倍率；省略时为 `1` |

### `valueType="targetCount"`：读取 Target 数量

`targetId` 填写 Target ID。该 Target 当前找到的目标数量就是来源数值。

`攻击中枢 阿克琉斯`（Card `10704`）：攻击力为 11 减去己方场上机体数。→

```lua
effect = {
    miscFunc = {
        valueType = "targetCount",
        effectKey = "attkAdd",
        targetId = 110,
        A = 0,
        B = -1,
    },
},
```

Card 的基础攻击是 `11`。这项 Static Skill 根据 Target `110` 的目标数量，持续提供对应的负攻击修正。

### `valueType="cardFieldValue"`：读取目标 Card 字段

`name` 填写要读取的 Card 字段名。当前受影响 Card 的该字段值就是来源数值。

`更强的无人机`（Skill `1800401`）：无人机派出时，获得等同于原本装甲的额外装甲和上限。→

```lua
effect = {
    miscFunc = {
        valueType = "cardFieldValue",
        name = "configHp",
        effectKey = "hpAddDrone",
        A = 0,
        B = 1,
    },
},
```

这项配置读取目标 Card 的 `configHp`，再把结果写入 `hpAddDrone`。

## 静态异能的生命周期

来源离开 `srcArea` 或不再满足 `conditionListSelf` 时，Static Skill 默认停止生效。以下字段用于增加额外的保留、移除和集成规则。

### 按 Trigger 自动移除：`flag.removeTrigger`

`removeTrigger` 让动态添加的 Static Skill 在指定 Trigger 出现一定次数后自动移除。

| 字段 | 含义 |
| --- | --- |
| `trigger` | 要监听的 Trigger ID |
| `count` | 出现多少次后移除；省略时第一次出现就移除 |
| `triggerEx` | 进一步筛选这次 Trigger；不需要时省略 |

`干扰射击`（Card `2010`）：造成 1 点伤害，受到伤害的机体获得延缓。→

```lua
effect = {
    attkDelay = 1,
},
flag = {
    removeTrigger = {
        trigger = 7,
        triggerEx = {},
        count = 1,
    },
},
```

Trigger `7` 是清除步骤。出现一次后，这项延缓 Static Skill 自动移除。Trigger 的完整含义见 [Trigger 参考](../concepts/triggers.md)。

### 变身后保留：`flag.reserve`

`reserve=1` 表示来源 Card 被替换或变身后，保留这项 Static Skill。

`邓肯23`（Card `7000`）：自带覆膜，变身后仍保留。→

```lua
effect = {
    attkShield = 1,
},
flag = {
    self = 1,
    reserve = 1,
},
```

### 集成时不重复处理：`flag.stackcard`

现有配置固定写作 `stackcard=0`。字段存在时，Card 的集成流程会跳过这项 Static Skill，避免重复计算。

`标准无人机β+`（Card `2080`）：自身获得 +2/+0。→

```lua
flag = {
    self = 1,
    stackcard = 0,
},
```

### 来源被沉默时是否停止：`disable`

这里的 `disable` 是 `static_skill_def` 顶层字段，不是 `effect.disable`。

| 值 | 结果 |
| --- | --- |
| `1` | 来源被沉默时，Static Skill 停止生效；省略时使用该值 |
| `0` | 来源被沉默时，Static Skill 仍然生效 |

`精英支援`（Chip `4011`）：僚机获得 +2/+2，来源被沉默时仍然生效。→

```lua
disable = 0,
```

## 游戏内显示

显示字段不会改变 Static Skill 的结算目标或 Attr。

### 异能说明：`desc`、`visibility`

`desc` 填写玩家看到的异能说明。`visibility` 控制是否单独显示这段说明：

| 值 | 结果 |
| --- | --- |
| `0` | 不单独显示；省略时使用该值 |
| 大于 `0` | 在战斗异能列表和相关详情中显示 |

`精英支援`（Chip `4011`）：单独显示“你的僚机获得 +2/+2。”→

```lua
desc = "你的僚机获得+2/+2。",
visibility = 6,
```

### 关联关键字：`keywordList`

`keywordList` 填写需要随异能说明展示的关键字。每一项至少填写 `keywordId`：

```lua
keywordList = {
    { keywordId = 1004 },
},
```

不需要额外展示关键字时省略该字段。

### 持续特效：`showEffects`

`showEffects` 填写客户端已经存在的持续特效名：

| 特效名 | 当前用途 |
| --- | --- |
| `mecha_common_uav_buffhold_01` | 机体持续增益 |
| `mecha_common_uav_buffhold_02` | Card、能量或战术持续增益 |
| `mecha_common_uav_debuffhold_01` | 机体持续减益 |
| `mecha_common_uav_debuffhold_02` | 另一种持续减益表现 |

`晋升指令`（Card `2016`）：目标获得 +2/+2 时播放持续增益特效。→

```lua
showEffects = {
    "mecha_common_uav_buffhold_01",
},
```

只需要数值效果时可以省略 `showEffects`。填写其他名称前，需要确认对应特效已经随游戏提供。

## 旧设计

- `effect.attkBack`
- `effect.relive`
- `effect.miscFunc.valueType="tokenCount"`
- `flag.active`
- `flag.targetSelection`

## 在 MOD 中新增 `static_skill_def`

配置文件可以放在：

```text
config/static_skill_def/config/statics.lua
```

批次使用 `installKey="id"`。下面新增 Static Skill `990901`：来源在场时，自身获得 +2/+2。

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990901,
            name = "强化装甲",
            srcArea = { 14 },
            targetArea = { 14 },
            effect = {
                attkAdd = 2,
                hpAddDrone = 2,
            },
            flag = {
                self = 1,
            },
        },
    },
}
```

Card 可以通过 `staticList` 引用：

```lua
staticList = { 990901 },
```

Effect 也可以通过 `event=60` 添加：

```lua
event = 60,
targetId = 613,
value = 990901,
```

`staticList` 表示 Card 自带这项 Static Skill；`event=60` 表示 Effect 结算后，目标获得这项 Static Skill。
