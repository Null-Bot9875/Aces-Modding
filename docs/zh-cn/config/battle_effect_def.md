# `battle_effect_def` 配置参考

> `battle_effect_def` 定义一次战斗 Effect：选择目标、执行 `event`、计算数值，并指定客户端表现。

## `battle_effect_def` 的基本结构

`连续射击α`（Card `2061`）：对一个敌方单位造成 2 点伤害，并播放 `multi_attack_3` 攻击表现。→

```lua
{
    effectId = 8026,
    desc = "对任意敌方造成2伤害",
    targetId = 40,
    event = 1000,
    value = 2,
    extend = {},
    playResultType = 1,
    customResultType = "multi_attack_3",
    dontUseCardTimeline = true,
    markTarget = "",
}
```

一行 Effect 先由五个字段决定结算逻辑：

- `effectId`：Effect 的唯一 ID，供 Card、Skill 和其他 Effect 引用。
- `targetId`：选择本次结算要处理的对象。Target 的写法见 [Target 配置参考](battle_target_def.md)。
- `event`：决定对目标执行什么行为。
- `value`：当前 `event` 使用的主要数值；不同 `event` 的含义不同。
- `extend`：当前 `event` 需要的额外参数；不需要时可以省略。

`desc` 是供作者阅读的备注，不会成为玩家文案。`playResultType`、`customResultType`、`dontUseCardTimeline` 和 `markTarget` 只影响客户端表现，见“Effect 的游戏内表现”。

## 可用 `event`

先根据要实现的行为选择 `event`，再在同一小节确认它需要的 `targetId`、`value` 和 `extend`。

[`11 NewCard`](#event-11-newcard)、[`17 CardArea`](#event-17-cardarea)、[`21 CreateCard`](#event-21-createcard)、[`23 CreateDrone`](#event-23-createdrone)、[`24 CreateItem`](#event-24-createitem)、[`25 ReplaceDrone`](#event-25-replacedrone)、[`27 DestroyDrone`](#event-27-destroydrone)<br>
[`30 Counteract`](#event-30-counteract)、[`60 StaticAdd`](#event-60-staticadd)、[`61 StaticRemove`](#event-61-staticremove)、[`100 Power`](#event-100-power)、[`102 PowerMax`](#event-102-powermax)、[`103 Hp`](#event-103-hp)、[`105 HpSet`](#event-105-hpset)<br>
[`106 AttkAdd`](#event-106-attkadd)、[`107 PowerTmp`](#event-107-powertmp)、[`108 AIChainRemove`](#event-108-aichainremove)、[`109 ActorFinish`](#event-109-actorfinish)、[`110 AttrRemove`](#event-110-attrremove)、[`112 HpMaxSet`](#event-112-hpmaxset)、[`113 AttkSet`](#event-113-attkset)<br>
[`120 SkillTrigger`](#event-120-skilltrigger)、[`200 Value`](#event-200-value)、[`201 Reward`](#event-201-reward)、[`202 Gold`](#event-202-gold)、[`400 Attk`](#event-400-attk)、[`1000 Damage`](#event-1000-damage)、[`1002 DamageBreak`](#event-1002-damagebreak)

### Event 11 NewCard

让目标玩家从抽牌区抽取 Card。

- `targetId`：选择执行抽牌的玩家。
- `value`：抽取数量。
- `extend`：固定数量时可以省略；动态数量见 [`extend.valueType`](#extendvaluetype)。

`运输无人机`（Card `2023`）：派出时抽 1 张牌。→

```lua
event = 11,
targetId = 100,
value = 1,
```

### Event 17 CardArea

把 `targetId` 选中的 Card 移到 `value` 指定的战斗区域。

- `targetId`：选择要移动的 Card。
- `value`：目的地区域 ID，例如 `2` 是手牌、`3` 是弃牌堆、`4` 是废弃区、`14` 是战场无人机区域、`15` 是储卡区。完整列表见 [战斗区域参考](../concepts/areas.md)。
- `extend`：普通移动可以省略；返回原位置时使用 `lastPos`，移动到另一方的区域时使用 `moveTarget`。

`叹息长阶`（Card `2006`）：把目标己方无人机移到废弃区。→

```lua
event = 17,
targetId = 613,
value = 4,
```

#### 返回离场前的战场格子：`lastPos`

`复生`（Skill `000102`）：让无人机返回离场前记录的战场格子。→

```lua
event = 17,
targetId = 104,
value = 14,
extend = {
    lastPos = 1,
},
```

`lastPos = 1` 只在返回战场无人机区域时有意义。省略或填写 `0` 时，不读取原来的格子。

#### 移动到另一方的区域：`moveTarget`

`白洞`（Card `10788`）：把敌方废弃区中费用最高的 Card 移到己方储卡区。→

```lua
event = 17,
targetId = 928,
value = 15,
extend = {
    moveTarget = 1,
},
```

`moveTarget = 1` 使用另一方的目标区域。省略或填写 `0` 时，Card 移到其所属阵营的对应区域。

### Event 21 CreateCard

为目标玩家创建指定 Card。

- `targetId`：通常选择获得新 Card 的玩家；直接选中一张 Card 时，可以沿用该 Card 的 `cardId`。
- `value`：创建数量。
- `extend.card`：固定创建的 Card ID。没有使用 `randomCards`，且 Target 没有直接提供 Card 时必须填写。
- `extend.randomCards`：Card ID 列表。每创建一张 Card 都重新随机选择，并覆盖 `card`。
- `extend.area`：创建后的区域 ID；省略时进入手牌。

`原型组件`（Card `2039`）：派出时将 1 张 `原型无人机`加入手牌。→

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    card = 2041,
},
```

#### 从候选列表随机创建：`randomCards`

Effect `4522`：从八张指令 Card 中随机选择 1 张加入手牌。→

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    randomCards = { 2008, 2014, 2016, 2137, 2139, 2141, 2143, 2369 },
},
```

`randomCards` 不能是空表。它与 `card` 同时填写时，以 `randomCards` 为准。

#### 创建到指定区域：`area`

Effect `5757`：创建 1 张 `圣域崩塌`并放入储卡区。→

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    card = 10786,
    area = 15,
},
```

### Event 23 CreateDrone

在 `targetId` 选中的空战场格子中创建无人机。

- `targetId`：选择允许创建无人机的空格。
- `value`：运行时不决定创建数量；现有配置通常填写 `1`。
- `extend.card`：固定创建的无人机 Card ID。
- `extend.randomCards`：每个目标格分别随机选择一个无人机 Card ID，并覆盖 `card`。
- `extend.posCard`：按战场位置指定 Card ID，优先级高于 `randomCards` 和 `card`。

`无人机派出`（Card `2000`）：在第一行的所有空格派出 `原型无人机`。→

```lua
event = 23,
targetId = 518,
value = 1,
extend = {
    card = 2002,
},
```

目标格不是空格，或不能安装所选无人机时，该位置会被跳过。

#### 每个位置随机选择：`randomCards`

Effect `5868`：在随机位置派出 1 台随机僚机。→

```lua
event = 23,
targetId = 695,
value = 1,
extend = {
    randomCards = { 10050, 10497, 10184, 10045, 10394, 10502, 10180, 10506, 2204 },
},
```

#### 按位置创建不同无人机：`posCard`

Effect `1846`：在 `4` 号位创建 Card `2414`，在 `6` 号位创建 Card `2415`。→

```lua
event = 23,
targetId = 612,
value = 1,
extend = {
    posCard = {
        [4] = 2414,
        [6] = 2415,
    },
},
```

目标位置没有 `posCard` 条目时，该位置不会创建无人机，也不会回退到 `randomCards` 或 `card`。

### Event 24 CreateItem

为目标玩家创建一个战斗道具。

- `targetId`：选择获得战斗道具的玩家。
- `value`：直接创建时填写战斗道具 ID；使用 `randomCards` 时不参与随机结果。
- `extend.randomCards`：战斗道具 ID 列表。填写后从中随机选择一个，并覆盖 `value`。

`商会信标`（Card `8562`）：派出时随机获得 1 张道具牌。→

```lua
event = 24,
targetId = 100,
value = 1,
extend = {
    randomCards = {
        3001, 3002, 3003, 3004, 3005,
        3006, 3007, 3008, 3009, 3010,
        3011, 3012, 3013, 3014, 3015,
    },
},
```

`randomCards` 不能是空表，列表中的每个 ID 都必须是有效的战斗道具 ID。

### Event 25 ReplaceDrone

把目标无人机替换成另一张无人机 Card。

- `targetId`：选择要替换的战场无人机。
- `value`：运行时不决定替换数量；现有配置通常填写 `1`。
- `extend.card`：所有目标统一替换成的 Card ID。
- `extend.switch`：按当前 Card ID 映射替换后的 Card ID，并覆盖 `card`。
- `extend.force`：需要额外占位且格子被占用时，`1` 表示继续替换并移走占位 Card；默认 `0` 表示拒绝替换。
- `extend.showTarget`：客户端表现额外使用的 Target ID，不改变实际替换目标。

`武装觉醒`（Card `21053`）：把猎户座替换为猎神模式。→

```lua
event = 25,
targetId = 510,
value = 1,
extend = {
    card = 21052,
    force = 1,
    showTarget = 542,
},
```

#### 按当前 Card 双向切换：`switch`

Effect `5807`：让 Card `10540` 与 Card `10541` 相互翻转。→

```lua
event = 25,
targetId = 870,
value = 1,
extend = {
    switch = {
        [10540] = 10541,
        [10541] = 10540,
    },
    force = 1,
},
```

当前 Card ID 不在 `switch` 中时，该目标不会替换，也不会回退到 `card`。

### Event 27 DestroyDrone

破坏 `targetId` 选中的无人机。

- `targetId`：选择要破坏的战场无人机。
- `value`：运行时不决定破坏数量；现有配置通常填写 `1`。
- `extend`：不需要额外参数，可以省略。

`破限齐射`（Card `7547`）：破坏一台己方无人机。→

```lua
event = 27,
targetId = 613,
value = 1,
```

### Event 30 Counteract

反制 `targetId` 选中的对象。

- `targetId`：选择当前能够被反制的对象。
- `value`：运行时不参与反制；现有配置通常填写 `1`。
- `extend`：不需要额外参数，可以省略。

`见招拆招`（Card `10415`）：反制敌方下一张战术牌。→

```lua
event = 30,
targetId = 692,
value = 1,
```

### Event 60 StaticAdd

向目标添加 `value` 指定的静态异能。

- `targetId`：选择接收静态异能的 Player 或 Card。
- `value`：要添加的 [`static_skill_def`](static_skill_def.md) ID。
- `extend.staticCount`：用于计算重复添加次数的 Target ID，不是直接填写的次数。
- `extend.A`、`extend.B`：与 `staticCount` 配合，添加次数为 `A + B × 目标数量`；默认 `A = 0`、`B = 1`。
- `extend.round`：静态异能保留的回合数；省略时不使用回合倒计时。

`叹息长阶`（Card `2006`）：让主将获得静态异能 `200651`。→

```lua
event = 60,
targetId = 510,
value = 200651,
```

#### 按目标数量重复添加：`staticCount`

`斗争无人机`（Card `7104`）：己方场上每有 1 台机体，此机体获得 +1/+0。→

```lua
event = 60,
targetId = 103,
value = 710451,
extend = {
    staticCount = 512,
},
```

Target `512` 选择己方场上的全部机体。己方有 3 台机体时，默认公式得到 `0 + 1 × 3 = 3`，因此添加三次静态异能 `710451`。

#### 限制持续回合：`round`

`派遣指令`（Card `7116`）：使下一张无人机牌的能量消耗临时降低。→

```lua
event = 60,
targetId = 100,
value = 711751,
extend = {
    round = 1,
},
```

`round = 1` 表示回合更新时倒计时减为 `0` 并移除该静态异能。

### Event 61 StaticRemove

从目标移除 `value` 指定的静态异能。

- `targetId`：选择要移除静态异能的 Player 或 Card。
- `value`：要移除的 [`static_skill_def`](static_skill_def.md) ID。
- `extend`：不需要额外参数，可以省略。

`重整旗鼓`（Card `10326`）：移除静态异能 `1034051`。→

```lua
event = 61,
targetId = 100,
value = 1034051,
```

### Event 100 Power

增加或减少目标玩家的能量。

- `targetId`：选择能量发生变化的玩家。
- `value`：变化量；正数增加，负数减少。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`叹息长阶`（Card `2006`）：使用时消耗 1 点能量。→

```lua
event = 100,
targetId = 100,
value = -1,
```

### Event 102 PowerMax

增加或减少目标玩家的能量上限。

- `targetId`：选择能量上限发生变化的玩家。
- `value`：变化量；正数增加，负数减少。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`集火指令`（Card `10449`）：让自己的 EPM 减少 2。→

```lua
event = 102,
targetId = 100,
value = -2,
```

### Event 103 Hp

回复或扣减目标 Card 的当前 HP。

- `targetId`：选择 HP 发生变化的 Card。
- `value`：变化量；正数回复，负数扣减。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`修正`（Card `2346`）：让主将回复 5 CA。→

```lua
event = 103,
targetId = 510,
value = 5,
```

### Event 105 HpSet

把目标 Card 的当前 HP 直接设为指定值。

- `targetId`：选择要设置 HP 的 Card。
- `value`：设置后的当前 HP。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

Card `10604`：回合开始时把自身装甲设为 8。→

```lua
event = 105,
targetId = 103,
value = 8,
```

### Event 106 AttkAdd

增加或减少目标战场 Card 的当前攻击。

- `targetId`：选择攻击发生变化的战场 Card。
- `value`：变化量；正数增加，负数减少。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`锻刃`（Card `2677`）：废弃一台己方无人机后，让主将增加等同于该无人机 HP 的攻击。→

```lua
event = 106,
targetId = 60,
value = 0,
extend = {
    valueType = "effectValue",
    effectId = 4516,
    key = "hp",
},
```

这条 Effect 必须排在 Effect `4516` 之后，才能读取它返回的无人机 HP。

### Event 107 PowerTmp

增加或减少目标玩家的临时能量。

- `targetId`：选择临时能量发生变化的玩家。
- `value`：变化量。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`能源运输单元`（Card `11026`）：回合开始时获得 1 EP。→

```lua
event = 107,
targetId = 100,
value = 1,
```

### Event 108 AIChainRemove

从目标玩家当前行动链的开头移除行动。

- `targetId`：选择行动链所属的 Player。
- `value`：移除数量；行动不足时只移除当前已有的行动。
- `extend`：不需要额外参数，可以省略。

`神经元劫持`（Card `7603`）：破坏敌方首个行动链。→

```lua
event = 108,
targetId = 101,
value = 1,
```

### Event 109 ActorFinish

自动结束目标 Player 当前的优先权。

- `targetId`：选择当前行动上下文中的 Player。
- `value`：运行时不参与结算；现有配置通常填写 `1`。
- `extend`：不需要额外参数，可以省略。

`平等的`（Skill `1600901`）：自动结束当前优先权。→

```lua
event = 109,
targetId = 101,
value = 1,
```

这个 `event` 只适用于已经建立当前行动者和优先权的结算上下文。

### Event 110 AttrRemove

从目标 Card 移除 `extend.attrTarget` 指定的 Effect 属性。

- `targetId`：选择要移除属性的 Card。
- `value`：运行时不决定移除哪个属性；现有配置通常填写 `1`。
- `extend.attrTarget`：必填，要移除的属性名。可用名称见 [Effect 属性参考](../concepts/attrs.md)。

Card `10611`：让主将失去 `attkDelay`。→

```lua
event = 110,
targetId = 60,
value = 1,
extend = {
    attrTarget = "attkDelay",
},
```

### Event 112 HpMaxSet

把目标 Card 的 HP 上限直接设为指定值。

- `targetId`：选择要设置 HP 上限的 Card。
- `value`：设置后的 HP 上限。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`普照`（Card `8010`）：把场上所有无人机的 HP 上限设为 1。→

```lua
event = 112,
targetId = 689,
value = 1,
```

### Event 113 AttkSet

把目标 Card 的当前攻击直接设为指定值。这里是“设为”，不是在原值上增加或减少。

- `targetId`：选择要设置攻击的 Card。
- `value`：设置后的当前攻击。
- `extend`：固定数值时可以省略；动态数值见 [`extend.valueType`](#extendvaluetype)。

`点到为止`（Card `10459`）：把目标无人机的 ATK 设为 1。→

```lua
event = 113,
targetId = 683,
value = 1,
```

### Event 120 SkillTrigger

触发目标 Card 上符合条件的 Skill。

- `targetId`：选择包含待触发 Skill 的 Card。
- `value`：运行时不表示 Skill ID；现有配置通常填写 `1`。
- `extend.trigger`：可选的 [Trigger ID](../concepts/triggers.md)。填写后只触发 Trigger 相同的 Skill；省略时触发目标 Card 上的全部 Skill。

`供能再动`（Card `10507`）：让目标僚机再触发一次进场时能力。→

```lua
event = 120,
targetId = 835,
value = 1,
extend = {
    trigger = 123,
},
```

`trigger` 是 Trigger ID，不是 Skill ID。

### Event 200 Value

计算并记录一个数值，供同一次 Skill 中排在后面的 Effect 读取。

- `targetId`：选择本次计算要读取的对象。
- `value`：没有动态计算时的基础值。
- `extend`：通常使用 `valueType` 及其参数决定记录值。

`破限齐射`（Card `7547`）：记录目标己方无人机的当前攻击。→

```lua
event = 200,
targetId = 613,
value = 0,
extend = {
    valueType = "cardFieldValue",
    field = "attk",
    A = 0,
    B = 1,
},
```

后续 Effect 可以用 `valueType = "effectValue"` 和当前 `effectId` 读取记录值。

### Event 201 Reward

为目标玩家记录一条胜利奖励，实际发放发生在战斗结束后的奖励流程。

- `targetId`：选择获得奖励的玩家。
- `value`：`reward_def` 中已有的奖励 ID。
- `extend`：不需要额外参数，可以省略。

`刃型观测机`（Card `10176`）：战斗结束时记录奖励 `4007`。→

```lua
event = 201,
targetId = 100,
value = 4007,
```

### Event 202 Gold

增加或减少目标玩家在当前战斗中的 Gold。

- `targetId`：选择 Gold 发生变化的玩家。
- `value`：变化量；正数增加，负数减少。扣减超过当前 Gold 时只会减到 `0`。
- `extend`：不需要额外参数，可以省略。

`挖掘无人机`（Card `10431`）：派出时获得 10 Gold。→

```lua
event = 202,
targetId = 100,
value = 10,
```

### Event 400 Attk

让 `targetId` 选中的战场 Card 发起攻击。

- `targetId`：选择发起攻击的战场 Card。
- `value`：攻击次数，填写 `1` 至 `10`。超过 `10` 的部分不会执行；`0` 或负数不会发起攻击。
- `extend`：不需要额外参数，可以省略。

`攻击指令`（Card `10479`）：让一台己方机体进行 1 次攻击。→

```lua
event = 400,
targetId = 104,
value = 1,
```

### Event 1000 Damage

对 `targetId` 选中的目标造成普通伤害。

- `targetId`：选择可以承受伤害的 Card 或 Player。
- `value`：基础伤害。
- `extend`：固定伤害时可以省略；动态伤害见 [`extend.valueType`](#extendvaluetype)。

`连续射击α`（Card `2061`）：对一个敌方单位造成 2 点伤害。→

```lua
event = 1000,
targetId = 40,
value = 2,
```

### Event 1002 DamageBreak

对 `targetId` 选中的目标造成贯穿伤害。

- `targetId`：选择可以承受贯穿伤害的 Card 或 Player。
- `value`：基础伤害。
- `extend`：固定伤害时可以省略；动态伤害见 [`extend.valueType`](#extendvaluetype)。

`贯穿射击`（Card `2318`）：对中路造成 7 点贯穿伤害。→

```lua
event = 1002,
targetId = 106,
value = 7,
```

## `extend.valueType`

部分 `event` 会在结算前用 `extend.valueType` 重新计算 `value`。通用公式是：

```text
最终 value = A + B × 来源数值
```

- `valueType`：数值来源类型。
- `A`：固定加值，默认 `0`。
- `B`：来源数值的倍率，默认 `1`。

只在下面列出的用法和已经确认支持动态数值的 `event` 中使用 `valueType`。不存在的类型会让 Effect 执行失败。

### `valueType = "cardFieldValue"`：读取目标 Card 字段

读取 `targetId` 选中的所有 Card 的同一字段，先求和，再代入通用公式。

- `field`：必填，要读取的 Card 字段。
- `A`、`B`：可选，按通用公式计算。

`破限齐射`（Card `7547`）：记录目标己方无人机的当前攻击。→

```lua
effectId = 4089,
event = 200,
targetId = 613,
value = 0,
extend = {
    valueType = "cardFieldValue",
    field = "attk",
    A = 0,
    B = 1,
},
```

明确可读的字段包括：

| `field` | 来源数值 |
| --- | --- |
| `attk` | 当前攻击 |
| `hp` | 当前 HP |
| `cost` | 当前费用 |
| `chipValue` | 当前晶片数值 |
| `hpDiff` | HP 上限减当前 HP |
| `configHp` | Card 配置中的初始 HP |
| `configAttk` | Card 配置中的初始攻击 |

其他字段名会尝试读取目标 Card 的同名战斗属性；属性不存在时按 `0` 计算。

### `valueType = "targetCount"`：统计另一个 Target 的目标数量

查询 `extend.targetId` 当前能得到多少个目标，再代入通用公式。

- `targetId`：必填，用于计数的 Target ID。它不是当前 Effect 顶层的 `targetId`。
- `A`、`B`：可选，按通用公式计算。

Effect `4087`：伤害等于己方弃牌堆中的无人机数量。→

```lua
event = 1000,
targetId = 109,
value = 0,
extend = {
    valueType = "targetCount",
    targetId = 754,
},
```

顶层 `targetId = 109` 选择承受伤害的目标；`extend.targetId = 754` 只负责统计己方弃牌堆中的无人机数量。

### `valueType = "effectValue"`：读取前序 Effect 的结果

读取同一次 Skill 中已经执行过的 Effect，再代入通用公式。它不会重新执行被读取的 Effect。

- `effectId`：必填，要读取的前序 Effect ID。
- `key`：可选，读取前序结果中的指定字段；省略时读取前序 Effect 的主要 `value`。
- `A`、`B`：可选，按通用公式计算。

`破限齐射`（Card `7547`）：先记录目标无人机的攻击，再对所有敌方机体造成等量伤害。→

```lua
-- 先执行：记录目标无人机的攻击
{
    effectId = 4089,
    event = 200,
    targetId = 613,
    value = 0,
    extend = {
        valueType = "cardFieldValue",
        field = "attk",
    },
}

-- 后执行：读取 Effect 4089 的主要 value
{
    effectId = 4090,
    event = 1000,
    targetId = 534,
    value = 1,
    extend = {
        valueType = "effectValue",
        effectId = 4089,
    },
}
```

两条 Effect 必须属于同一次 Skill，而且被读取的 Effect 必须排在读取者前面。指定的 `key` 不存在时，该字段按 `0` 读取。

### `valueType = "effectValue_Count"`：读取前序处理数量

读取前序 Effect 返回的 `count`，再代入通用公式。

- `effectId`：必填，要读取的前序 Effect ID。
- `A`、`B`：可选，按通用公式计算。

Effect `4082` 与 `4083`：先弃置全部手牌，再按实际弃置数量抽取同样数量的 Card。→

```lua
-- 先执行：把全部手牌移到弃牌堆，并返回处理数量
{
    effectId = 4082,
    event = 17,
    targetId = 118,
    value = 3,
}

-- 后执行：把 Effect 4082 返回的 count 作为抽牌数量
{
    effectId = 4083,
    event = 11,
    targetId = 100,
    value = 1,
    extend = {
        valueType = "effectValue_Count",
        effectId = 4082,
    },
}
```

前序 Effect 没有返回 `count` 时，来源数量按 `0` 计算。

### `valueType = "effectValue_Cards"`：统计前序返回的 Card

读取前序 Effect 返回的 Card 列表，统计数量后代入通用公式。

- `effectId`：必填，要读取的前序 Effect ID。
- `condition`：可选的 Battle Condition ID 列表，只统计满足条件的 Card。写法见 [`battle_condition_def` 配置参考](battle_condition_def.md)。
- `A`、`B`：可选，按通用公式计算。

Effect `4108` 与 `4109`：先抽 4 张 Card，再按其中 `数据演算无人机`的数量回复 EP。→

```lua
-- 先执行：抽 4 张 Card，并返回 Card 列表
{
    effectId = 4108,
    event = 11,
    targetId = 100,
    value = 4,
}

-- 后执行：只统计满足 Condition 2075 的 Card
{
    effectId = 4109,
    event = 100,
    targetId = 100,
    value = 1,
    extend = {
        valueType = "effectValue_Cards",
        effectId = 4108,
        condition = { 2075 },
        A = 0,
        B = 1,
    },
}
```

前序 Effect 没有返回 Card 列表时，来源数量按 `0` 计算。

### `valueType = "triggerData"`：读取触发参数

从当前 Effect 的触发请求中读取一个数值字段，再代入通用公式。

- `triggerKey`：必填，触发请求中的字段名。
- `A`、`B`：可选，按通用公式计算。

Effect `4370`：按触发请求中的 `powerCost` 扣减主将 CA。→

```lua
event = 103,
targetId = 510,
value = 1,
extend = {
    valueType = "triggerData",
    triggerKey = "powerCost",
    A = 0,
    B = -1,
},
```

`triggerKey` 必须由对应 Trigger 实际传入，并且值必须可以参与数值计算。不要在普通主动 Skill 中自行猜测字段名。

### 对每个伤害目标分别计算：`targetValueType`

`Damage` 和 `DamageBreak` 可以使用 `targetValueType = "cardFieldValueWithTarget"`，让每个目标按自己的字段分别计算伤害。

Effect `5864`：每台无人机分别承受等同于自身初始攻击的伤害。→

```lua
event = 1000,
targetId = 940,
value = 1,
extend = {
    targetValueType = "cardFieldValueWithTarget",
    field = "configAttk",
    A = 0,
    B = 1,
},
```

`field` 的可用值与 `cardFieldValue` 相同。这个写法不会先把所有目标的字段相加，也不要把 `cardFieldValueWithTarget` 填到普通 `valueType` 中。

## Effect 的游戏内表现

表现字段只控制客户端演出，不改变 `targetId`、`event` 或最终 `value`。不需要特殊演出时，可以省略这些字段。

### 自动选择表现：`playResultType`

`playResultType` 指定表现类型。客户端再根据机体、形态和目标范围，从已有 Timeline 中选择具体表现。

| 值 | 类型 | 用途 |
| --- | --- | --- |
| `0` | `none` | 不指定额外表现 |
| `1` | `attack` | 普通攻击 |
| `2` | `buff` | Buff |
| `3` | `debuff` | Debuff |
| `4` | `drone_move` | 已定义，但没有普通 Timeline 映射；新 MOD 不要使用 |
| `5` | `backAttack` | 背击 |
| `6` | `fanAttack` | 扇形或范围攻击 |
| `7` | `penetratAttack` | 贯穿攻击 |
| `8` | `selfExplode` | 单体自爆 |
| `9` | `switchMode` | 切换形态 |
| `10` | `selfAoeExplode` | 范围自爆 |
| `11` | `carrierRemove` | 机体离场 |
| `12` | `switchDisplay` | 替换显示机体 |
| `13` | `meleeAttack` | 近战攻击 |

`残阳风暴`（Card `9931`）：对一行中的所有无人机造成 3 点伤害，并使用扇形范围攻击表现。→

```lua
event = 1000,
targetId = 614,
value = 3,
playResultType = 6,
```

自动选择只会使用客户端已经存在的 Timeline。机体缺少专属表现时，支持回退的类型会使用通用表现。

### 指定已有表现：`customResultType`

`customResultType` 指定已有 Timeline 名称或名称后缀。客户端优先尝试：

```text
<modelId>_<mode>_<customResultType>
```

如果这个名称不存在，再把 `customResultType` 当作完整名称查找；仍不存在时，回退到 `playResultType` 的自动选择。

`连续射击α`（Card `2061`）：造成 2 点伤害，并优先使用 `multi_attack_3` 表现。→

```lua
event = 1000,
targetId = 40,
value = 2,
playResultType = 1,
customResultType = "multi_attack_3",
dontUseCardTimeline = true,
```

`customResultType` 由具体的攻击、Buff 或 Debuff 表现读取，不只限于某三个固定数值。现有 Effect 主要使用 `multi_attack_3`、`fan_attack` 等短名称。

同一例子中的 `dontUseCardTimeline = true` 表示攻击表现不要优先使用这张 Card 的专属 Timeline。它不会禁用全部 Timeline，也不会阻止 `customResultType`。

### 标记表现角色：`markTarget`

`markTarget` 把本次 Effect 的实体放入堆叠级表现分组。可用值是 `src`、`target`、`assist`、`spawn` 和 `victim`。

Effect `3014`：破坏目标己方无人机，并把它标记为表现中的 `victim`。→

```lua
event = 27,
targetId = 613,
value = 1,
playResultType = 0,
customResultType = "drone_suck_single",
markTarget = "victim",
```

省略 `markTarget` 时，带表现的 Effect 默认归入 `target` 分组。`markTarget` 不会改变 Effect 实际选中的目标。

### 查询和预览 Timeline

在设置中开启“开发者模式”，按反引号键（BackQuote）打开控制台。

列出某个机体已有的 Timeline：

```text
timeline_list <modelId> [mode]
```

进入战斗后预览一个完整 Timeline 名称：

```text
play_timeline <modelId> <mode> <timelineName>
```

## 废弃 `event`

以下 `event` 不要用于新 MOD：

| `event` | 名称 |
| --- | --- |
| `10` | `Equip` |
| `12` | `CostCard` |
| `13` | `Shuffle` |
| `20` | `Copy` |
| `26` | `MoveDrone` |
| `28` | `Stackcard` |
| `29` | `Disintegrated` |
| `40` | `View` |
| `50` | `Option` |
| `62` | `StaticTarget` |
| `101` | `Shield` |
| `104` | `HpMax` |
| `111` | `PowerMaxSet` |
| `140` | `GridNoSet` |
| `999` | `Destroy` |
| `3001` | `ResultNoNewCard` |
| `3002` | `ResultShield` |

## 在 MOD 中新增 `battle_effect_def`

配置文件放在：

```text
config/battle_effect_def/config/effects.lua
```

每个文件返回一个批次，`installKey` 固定为 `effectId`：

```lua
return {
    installKey = "effectId",
    rows = {
        {
            effectId = 990701,
            targetId = 40,
            event = 1000,
            value = 2,
        },
    },
}
```

这段配置新增 Effect `990701`：选择一个敌方单位并造成 2 点普通伤害。

新增 ID 可以被 Card 或 Skill 引用。例如，Skill 的 `effect` 列表会按顺序执行其中的 Effect：

```lua
effect = { 990701 }
```

Card 和 Skill 的 `costEffect`、`extraCost` 也可以引用新增的 `effectId`。
