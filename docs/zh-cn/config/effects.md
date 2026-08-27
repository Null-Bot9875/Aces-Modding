> Effect 定义一次战斗结算：目标、事件、数值、附加参数和游戏内表现。

## Effect 的基本结构

`8026` 的游戏内结果是：选择一个敌方单位，对其造成 2 点伤害，并使用 `multi_attack_3` 攻击表现。

来源 Card（游戏内 Wiki）：`连续射击α`（Card `2061`）

Card 文本：造成 2 点伤害。将 1 张[连续射击β]加入你的手牌。

```lua
{
    effectId = 8026,
    desc = "对任意敌方造成2伤害", -- 可选，仅为备注
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

阅读 Effect 配置时，先看三个核心字段：

```text
效果目标：targetId=40，选择一个敌方单位
效果事件：event=1000，造成 Damage
效果值：value=2，基础伤害为 2
```

其余字段负责 ID、备注、动态参数和客户端表现，不改变上面三项的基础含义。

## 基本信息

`effectId` 是供其他配置引用的唯一 ID；`desc` 是可选备注，只用于作者阅读和检索，不会显示为 Card 或 Effect 的玩家文案。

| 字段         | 类型     | 必填与起始值          | 含义           | 引用关系                                   |
| ---------- | ------ | --------------- | ------------ | -------------------------------------- |
| `effectId` | int    | 必填，无默认值         | Effect 唯一 ID | Card、Skill 和部分 `extend` 配置可以引用；见下方引用入口 |
| `desc`     | string | 非必填；省略时自动补 `""` | 备注           | 无                                      |

### `effectId` 的引用入口

以下字段直接引用 `battle_effect_def.config.effectId`：

| 引用字段 | 作用 |
| --- | --- |
| `card_def.config.costEffect` | Card 的主要费用 Effect |
| `card_def.config.extraCost` | Card 的额外费用 Effect 列表 |
| `battle_skill_def.config.effect` | Skill 按顺序执行的 Effect 列表 |
| `battle_skill_def.config.costEffect` | Skill 的主要费用 Effect |
| `battle_skill_def.config.extraCost` | Skill 的额外费用 Effect 列表 |

## 可选字段默认值

没有额外参数或特殊表现时，可以省略对应的可选字段。省略后使用以下默认值：

```lua
desc = ""
extend = {}
playResultType = 0
customResultType = ""
dontUseCardTimeline = false
markTarget = ""
```

## 逻辑配置

Effect 的逻辑由三个必填字段和一个可选字段组成：

| 字段         | 作用        | 是否必填      | 示例            |
| ---------- | --------- | --------- | ------------- |
| `targetId` | 效果作用于谁    | 是         | `40`：选择一个敌方单位 |
| `event`    | 对目标产生什么效果 | 是         | `1000`：造成伤害   |
| `value`    | 效果的基础数值   | 是         | `2`：基础伤害为 2   |
| `extend`   | 额外参数      | 否，默认 `{}` |               |

例如：`targetId=40, event=1000, value=2` 表示选择一个敌方单位，对其造成 2 点伤害。

### 效果目标：`targetId`

`targetId` 填写 Target ID，用来决定 Effect 作用于谁。可以使用现有 Target 配置，也可以使用同一个 MOD 新增的自定义 Target。Target 的配置方法见 [Target 配置参考](targets.md)。

### 效果事件：`event`

`event` 决定 Effect 会做什么。每个 Event 都有自己的 `value` 含义和 `extend` 规则，必须放在一起配置。下面每一节都同时说明这三个字段，并给出一份合法样例。

案例优先选用游戏内 Wiki 已收录的 Card，方便直接在游戏内查看和对照。
没有对应 Wiki Card 案例时，会明确标注来源 Card 未被 Wiki 收录，或注明该 Effect 来自系统 Skill。

`extend` 参数只对对应 Event 生效。同名参数不能随意复制到其他 Event；没有列出的参数应直接省略。

#### 快速索引

| 分类      | Event                                                                                                                                                                                                                                                    |
| ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 抽牌      | [`11 NewCard`](#event-11)                                                                                                                                                                                                                                |
| 移动      | [`17 CardArea`](#event-17)                                                                                                                                                                                                                               |
| 创建      | [`21 CreateCard`](#event-21)、[`23 CreateDrone`](#event-23)、[`24 CreateItem`](#event-24)                                                                                                                                                                  |
| 替换与破坏   | [`25 ReplaceDrone`](#event-25)、[`27 DestroyDrone`](#event-27)                                                                                                                                                                                            |
| 静态异能    | [`60 StaticAdd`](#event-60)、[`61 StaticRemove`](#event-61)                                                                                                                                                                                               |
| 属性修改    | [`100 Power`](#event-100)、[`102 PowerMax`](#event-102)、[`103 Hp`](#event-103)、[`105 HpSet`](#event-105)、[`106 AttkAdd`](#event-106)、[`107 PowerTmp`](#event-107)、[`110 AttrRemove`](#event-110)、[`112 HpMaxSet`](#event-112)、[`113 AttkSet`](#event-113) |
| 反制与战斗流程 | [`30 Counteract`](#event-30)、[`108 AIChainRemove`](#event-108)、[`109 ActorFinish`](#event-109)、[`120 SkillTrigger`](#event-120)                                                                                                                          |
| 记录与奖励   | [`200 Value`](#event-200)、[`201 Reward`](#event-201)、[`202 Gold`](#event-202)                                                                                                                                                                            |
| 攻击与伤害   | [`400 Attk`](#event-400)、[`1000 Damage`](#event-1000)、[`1002 DamageBreak`](#event-1002)                                                                                                                                                                  |

#### event-11

**抽取 Card（`NewCard`）**

从指定目标抽取 Card。

- `value`：抽取数量。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `8022`

来源 Card（游戏内 Wiki）：`运输无人机`（Card `2023`）

Card 文本：派出时，抽 1 张牌。→

```lua
event = 11,
targetId = 100,
value = 1,
```


#### event-17

**移动 Card（`CardArea`）**

将 `targetId` 选中的 Card 移动到 `value` 指定的区域。先分清两个问题：

```text
移动哪张 Card：由 targetId 决定
移动到哪个区域：由 value 决定
```

- `value`：目的地区域 ID。例如 `2` 是手牌、`3` 是弃牌堆、`4` 是废弃区、`14` 是战场无人机区域、`15` 是储卡区。完整列表见 [战斗区域参考](../concepts/areas.md)。
- `extend`：普通区域移动不需要填写。

##### eg: Effect `1504`：废弃目标己方无人机

来源 Card（游戏内 Wiki）：`叹息长阶`（Card `2006`）

Card 文本：废弃目标己方无人机，你的主将机体获得 +2/+0。

```lua
event = 17,
targetId = 613,
value = 4,
```

这段配置会把 Target `613` 选中的己方无人机移到废弃区。

##### 特殊用法：返回原战场格子

当前只有 Skill `000102`（复生）引用的 Effect `9043` 使用 `lastPos`。它会读取无人机离开战场前记录的格子，让无人机返回原来的位置。这不是常规移动配置，普通的 `CardArea` Effect 不需要填写。

来源 Card：无。Effect `9043` 由系统 Skill `000102`（复生）使用。

Card 文本：无。

Effect `9043` 的相关配置：

```lua
event = 17,
targetId = 104,
value = 14,
extend = {
    lastPos = 1,
},
```

其中，`value=14` 表示移动到战场无人机区域，`lastPos=1` 表示使用离开战场前记录的格子。`lastPos` 不填写时默认为 `0`，不会读取原来的格子。

##### 特殊用法：移动到对方阵营的区域

Effect `5708` 使用 `moveTarget`，把选中的 Card 移到对方阵营的目标区域。

来源 Card：`白洞`（Card `10788`）

Card 文本：不会成为敌方战术的目标；回合开始时，将敌方废弃区里费用最高的卡牌加入储卡区。离场时，对你的主将造成 20 伤害。→

游戏内 Wiki：未收录该 Card。

```lua
event = 17,
targetId = 928,
value = 15,
extend = {
    moveTarget = 1,
},
```

这段配置会把敌方废弃区中费用最高的 Card 移到己方储卡区。`value=15` 表示储卡区，`moveTarget=1` 表示使用另一方的目标区域。
`moveTarget` 不填写时默认为 `0`，Card 仍然移动到其所属阵营的目标区域。


#### event-21

**创建 Card（`CreateCard`）**

创建指定 Card。

- `value`：创建数量。
- `extend`：决定创建哪张 Card，以及创建后进入哪个区域：

  - `card`（整数）：要创建的 Card ID。固定创建时必须填写。Target 的结果是玩家而不是具体 Card，且没有填写 `randomCards` 时，也必须填写。
  - `randomCards`（可选，整数列表）：每创建一张 Card，都会从列表中重新随机选择一个 Card ID；填写后会覆盖 `card`。列表不能是空表。
  - `area`（可选，整数）：创建后的目标区域 ID；省略时进入手牌。可用区域见 [战斗区域参考](../concepts/areas.md)。

当 `targetId` 直接选中一张已有 Card 时，创建 ID 会沿用该目标 Card；`randomCards` 仍然拥有最高优先级。

##### eg: Effect `1527`

来源 Card（游戏内 Wiki）：`原型组件`（Card `2039`）

Card 文本：派出时，将 1 张[原型无人机]加入你的手牌。←：+2/+0。

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    card = 2041,
},
```


#### event-23

**创建无人机（`CreateDrone`）**

创建指定无人机。

- `value`：可以填写任意整数；该值没有实际作用，不影响创建数量。
- `extend`：决定每个目标空格创建哪台无人机：

  - `card`（整数）：要创建的无人机 Card ID。固定创建时必须填写；使用 `randomCards` 或 `posCard` 时可以省略。
  - `randomCards`（可选，整数列表）：每个目标空格分别从列表中随机选择一个无人机 Card ID；填写后会覆盖 `card`。列表不能是空表。
  - `posCard`（可选，位置映射表）：按战场位置指定无人机 Card ID，例如 `{ [4]=2414, [6]=2415 }`。它的优先级高于 `randomCards` 和 `card`；命中的目标位置没有对应条目时，该位置不会创建无人机。

目标格必须为空，并且允许安装所选无人机，否则该位置会被跳过。

##### eg: Effect `1500`

来源 Card（游戏内 Wiki）：`无人机派出`（Card `2000`）

Card 文本：在第一行的所有空格中派出 1/1 的[原型无人机]。

```lua
event = 23,
targetId = 518,
value = 1,
extend = {
    card = 2002,
},
```


#### event-24

**创建战斗道具（`CreateItem`）**

从候选列表中创建战斗道具。

- `value`：直接创建指定战斗道具时，填写战斗道具 ID；配置了 `randomCards` 时，可以填写任意整数，该值不参与随机选择。
- `extend`：固定创建时省略；需要随机创建时填写：

  - `randomCards`（可选，整数列表）：从列表中随机选择一个战斗道具 ID，并覆盖 `value`。列表不能是空表，列表中的每个 ID 都必须是有效的战斗道具 ID。

##### eg: Effect `5655`

来源 Card（游戏内 Wiki）：`商会信标`（Card `8562`）

Card 文本：派出时，随机获得 1 张道具牌。集成-商会：+0/+3。

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


#### event-25

**替换无人机（`ReplaceDrone`）**

将目标替换为指定无人机。

- `value`：可以填写任意整数；该值没有实际作用，不影响替换数量。
- `extend`：决定替换后的无人机和替换规则：

  - `card`（整数）：所有目标统一替换成的无人机 Card ID。没有填写 `switch` 时必须填写。
  - `switch`（可选，映射表）：按当前无人机 Card ID 决定替换后的 Card ID，例如 `{ [10540]=10541, [10541]=10540 }`。填写后优先于 `card`；当前 Card ID 不在映射中时，该目标不会替换，也不会回退到 `card`。
  - `force`（可选，`0/1`，默认 `0`）：控制新无人机需要额外占用位置、但该位置已经被占用时的处理。`0` 会拒绝这次替换；`1` 会继续替换并移走占用位置的 Card。普通替换省略即可。
  - `showTarget`（可选，整数）：客户端表现使用的 Target ID，用于额外收集并展示目标；

##### eg: Effect `9167`

来源 Card（游戏内 Wiki）：`武装觉醒`（Card `21053`）

Card 文本：消耗。摧毁你的所有无人机，你的主将机体切换为猎神模式。每以此法摧毁 1 台武装无人机，你的主将机体获得 1 点战术伤害；每以此法摧毁 1 台协同无人机，你的 EPM 增加 1。

这里是[武装觉醒]的其中一个效果，把猎户座替换为猎神模式。

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


#### event-27

**破坏无人机（`DestroyDrone`）**

破坏选中的无人机。`targetId` 必须使用能够选中无人机的 Target。

- `value`：可以填写任意整数；该值没有实际作用，不影响破坏数量。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `3014`

来源 Card（游戏内 Wiki）：`破限齐射`（Card `7547`）

Card 文本：摧毁一台己方无人机，对所有敌方机体造成该无人机攻击力的伤害。

```lua
event = 27,
targetId = 613, -- 选择一台己方无人机
value = 1,
```


#### event-30

**反制（`Counteract`）**

反制选中的对象。`targetId` 必须匹配可以被反制的目标。

- `value`：可以填写任意整数；该值没有实际作用，反制对象由 `targetId` 决定。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `4228`

来源 Card（游戏内 Wiki）：`见招拆招`（Card `10415`）

Card 文本：反制敌方下一张战术牌。此牌无法升级。

```lua
event = 30,
targetId = 692,
value = 1,
```


#### event-60

**添加静态异能（`StaticAdd`）**

向目标添加静态异能。

- `value`：要添加的[静态异能](static_def.md) ID。
- `extend`：普通添加可以省略；需要按目标数量重复添加或限制持续回合时，可以填写以下参数：

  - `staticCount`（可选，整数）：Target ID。游戏先查询这个 Target 当前能得到多少个目标，再以目标数量计算静态异能的添加次数；它不是直接填写的次数。
  - `A`（可选，数字，默认 `0`）：只与 `staticCount` 一起使用，作为添加次数的固定部分。
  - `B`（可选，数字，默认 `1`）：只与 `staticCount` 一起使用，作为目标数量的倍率。最终次数为 `A + B × 目标数量`；结果小于 `1` 时不添加。
  - `round`（可选，正整数）：静态异能保留的回合数；每次回合更新减 `1`，归零时移除。省略时不使用这一回合倒计时。

##### eg: Effect `1505`

来源 Card（游戏内 Wiki）：`叹息长阶`（Card `2006`）

Card 文本：废弃目标己方无人机，你的主将机体获得 +2/+0。

```lua
event = 60,
targetId = 510,
value = 200651,
```

##### 特殊用法：按目标数量重复添加

Effect `4036` 会根据己方场上的机体数量重复添加静态异能：

来源 Card（游戏内 Wiki）：`斗争无人机`（Card `7104`）

Card 文本：派出时，你的场上每有 1 台机体，此机体获得 +1/+0。

```lua
event = 60,
targetId = 103,
value = 710451,
extend = {
    staticCount = 512,
},
```

- `targetId=103`：静态异能添加给触发该 Effect 的机体。
- `value=710451`：每次添加使该机体获得 `1` 点攻击力。
- `staticCount=512`：Target `512` 选择己方场上的全部机体，机体数量就是重复添加次数。
- 省略 `A` 和 `B` 时，使用默认值 `A=0`、`B=1`。

例如己方场上有 `3` 台机体，添加次数就是 `0 + 1 × 3 = 3`，触发该 Effect 的机体共获得 `3` 点攻击力。

##### 特殊用法：限制持续回合

Effect `4043` 通过 `round=1` 让静态异能只保留 `1` 回合：

来源 Card（游戏内 Wiki）：`派遣指令`（Card `7116`）

Card 文本：本回合中，你的下一张无人机牌能量消耗减少 3。

```lua
event = 60,
targetId = 100,
value = 711751,
extend = {
    round = 1,
},
```

`round=1` 表示该静态异能会在回合更新时减为 `0` 并移除；不填写 `round` 时，不使用这一回合倒计时。


#### event-61

**移除静态异能（`StaticRemove`）**

从目标移除静态异能。

- `value`：要移除的[静态异能](static_def.md) ID。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `5090`

来源 Card（游戏内 Wiki）：`重整旗鼓`（Card `10326`）

Card 文本：消耗。取消主将的[延缓]，直到你的下个回合开始，你的主将机体受到的伤害减少 10。你的[防御协议]、[疾驰协议]和[疾驰幻影]视为未使用过。

```lua
event = 61,
targetId = 100,
value = 1034051,
```


#### event-100

**改变能量（`Power`）**

改变目标的能量。

- `value`：变化量。正数增加能量，负数减少能量。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `8012`

来源 Card（游戏内 Wiki）：`叹息长阶`（Card `2006`）

Card 文本：废弃目标己方无人机，你的主将机体获得 +2/+0。

费用说明：Effect `8012` 负责消耗 `1` 点能量。

```lua
event = 100,
targetId = 100,
value = -1,
```


#### event-102

**改变能量上限（`PowerMax`）**

改变能量上限或记录相关数值。

- `value`：基础变化值；这个例子填写 `-2`。
- `extend`：固定数值时可以省略；需要动态计算时填写 `valueType` 及其参数。

##### eg: Effect `5135`

来源 Card（游戏内 Wiki）：`集火指令`（Card `10449`）

Card 文本：消耗。保留。你的 EPM 减少 2，一台你的机体获得 +8/+0。

```lua
event = 102,
targetId = 100,
value = -2,
```


#### event-103

**改变 HP（`Hp`）**

回复或扣减目标的 HP。

- `value`：变化量。正数回复 HP，负数扣减 HP。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `1265`

来源 Card：`修正`（Card `2346`）

Card 文本：主将回复 5 CA。

游戏内 Wiki：未收录该 Card。

```lua
event = 103,
targetId = 510,
value = 5,
```


#### event-105

**设置 HP（`HpSet`）**

将目标的 HP 直接设为指定值。

- `value`：设置后的 HP。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `5336`

来源 Card：`振剑-\`（Card `10604`）

Card 文本：机体能力。回合开始时，将此机体的装甲设置为 8。

游戏内 Wiki：未收录该 Card。

```lua
event = 105,
targetId = 103,
value = 8,
```


#### event-106

**改变攻击（`AttkAdd`）**

增加或减少目标的攻击。

- `value`：基础变化量。
- `extend`：固定数值时可以省略。下面的例子会读取同一次 Skill 中前一个 Effect 的结果：

  - `valueType="effectValue"`：使用前序 Effect 的结算结果动态计算本次攻击变化量。
  - `effectId=4516`：读取 Effect `4516` 废弃的无人机数据。
  - `key="hp"`：读取该无人机的 HP。

其他动态数值来源见下方“动态数值：`extend.valueType`”。

##### eg: Effect `4517`

来源 Card：`锻刃`（Card `2677`）。Effect `4516` 和 Effect `4517` 都属于这张 Card 的 Skill。

Card 文本：废弃 1 台己方无人机，主将获得该机体装甲数值的攻击力。

游戏内 Wiki：未收录该 Card。

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

Skill 会先执行 Effect `4516`，废弃一台己方无人机；Effect `4517` 再读取该无人机的 HP，并为主将增加等量攻击力。


#### event-107

**改变临时能量（`PowerTmp`）**

改变目标的临时能量。

- `value`：变化量。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `9071`

来源 Card（游戏内 Wiki）：`能源运输单元`（Card `11026`）

Card 文本：机体能力。覆膜。回合开始时，此机体获得 -0/-1，你获得 1 EP。

```lua
event = 107,
targetId = 100,
value = 1,
```


#### event-108

**移除 AI 行动链（`AIChainRemove`）**

从目标当前行动链的开头移除行动。Target 必须能够得到 Player。

- `value`：移除数量。行动链数量不足时，只移除当前已有的行动。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `4174`

来源 Card：`神经元劫持`（Card `7603`）

Card 文本：破坏敌方首个行动链。直到你的下个回合开始，敌方的 EPM 减少 1。

游戏内 Wiki：未收录该 Card。

```lua
event = 108,
targetId = 101,
value = 1,
```


#### event-109

**结束当前优先权（`ActorFinish`）**

自动结束当前优先权。该 Event 只用于匹配的行动上下文。

- `value`：可以填写任意整数；该值没有实际作用，不影响结束当前优先权。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `4230`

来源 Card：无。Effect `4230` 由系统 Skill `1600901`（平等的）使用。

Card 文本：无。

```lua
event = 109,
targetId = 101,
value = 1,
```


#### event-110

**移除 Effect 属性（`AttrRemove`）**

移除目标的指定 Effect 属性。

- `value`：可以填写任意整数；该值没有实际作用，要移除的属性由 `extend.attrTarget` 决定。
- `extend`：必须填写：

  - `attrTarget`（必填，字符串）：填写要移除的 Effect 属性名。属性名和填写规则见 [Effect 属性参考](../concepts/attrs.md)。

##### eg: Effect `4551`

来源 Card（游戏内 Wiki）：`振剑-\`（Card `10611`）

Card 文本：机体能力。当你的主将机体获得[延缓]时，废弃此机体；你的主将机体失去[延缓]，并获得 +5/+0。

```lua
event = 110,
targetId = 60,
value = 1,
extend = {
    attrTarget = "attkDelay",
},
```


#### event-112

**设置 HP 上限（`HpMaxSet`）**

将目标的 HP 上限直接设为指定值。

- `value`：设置后的 HP 上限。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `4360`

来源 Card：`普照`（Card `8010`）

Card 文本：消耗。重置场上所有无人机的攻击、血量和血量上限为 1。

游戏内 Wiki：未收录该 Card。

```lua
event = 112,
targetId = 689,
value = 1,
```


#### event-113

**设置攻击（`AttkSet`）**

将目标的当前攻击直接设为指定值。这里是“设为”，不是在原有攻击上增加或减少。

- `value`：设置后的当前攻击；需要动态计算时，会由 `extend.valueType` 计算最终值。
- `extend`：固定数值时省略即可。

##### eg: Effect `5146`

来源 Card（游戏内 Wiki）：`点到为止`（Card `10459`）

Card 文本：消耗。目标无人机的 ATK 设定为 1。

这张 Card 使用时选择一台敌方无人机，并消耗 `1` 点能量。Card 的 Skill 会按顺序执行两条 Effect：

1. Effect `5175`：移除目标已有的攻击增减属性；
2. Effect `5146`：将目标的当前攻击设为 `1`。

第一条 Effect 先清理目标已有的攻击变化，第二条 Effect 再完成 Card 文本中的“ATK 设定为 1”。

```lua
event = 113,
targetId = 683,
value = 1,
```

在这条 Effect 中：

- `targetId=683`：使用这张 Card 选择的敌方无人机；
- `value=1`：将该无人机的当前攻击设为 `1`；
- `extend`：不需要，直接省略。


#### event-120

**触发 Skill（`SkillTrigger`）**

触发目标 Card 上符合条件的 Skill。

- `value`：可以填写任意整数；该值没有实际作用，不表示 Skill ID。
- `extend`：可选参数：

  - `trigger`（可选，整数）：填写 [Trigger ID](../concepts/triggers.md)，只触发目标 Card 上 `trigger` 值相同的 Skill。省略时触发目标 Card 上的全部 Skill。它不是 Skill ID。

##### eg: Effect `5270`

来源 Card：`供能再动`（Card `10507`）

Card 文本：目标非特里格拉夫的僚机，启动 1 次进场时能力。

游戏内 Wiki：未收录该 Card。

```lua
event = 120,
targetId = 835,
value = 1,
extend = {
    trigger = 123,
},
```


#### event-200

**记录计算值（`Value`）**

记录或传递一个计算值。

- `value`：未使用动态计算时的基础值；这个例子填写 `0`。
- `extend`：通常填写动态数值参数。下面的例子会记录所有目标 Card 的攻击总和：

  - `valueType="cardFieldValue"`：从目标 Card 的字段读取数值。
  - `field="attk"`：读取攻击字段；多个目标时相加。
  - `A=0`：计算公式中的固定值。
  - `B=1`：字段总和的倍率。最终记录值为 `0 + 1 × 攻击总和`。

记录结果通常由同一次 Skill 中排在后面的 Effect 通过 `effectValue` 读取。

##### eg: Effect `4089`

来源 Card（游戏内 Wiki）：`破限齐射`（Card `7547`）

Card 文本：摧毁一台己方无人机，对所有敌方机体造成该无人机攻击力的伤害。

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


#### event-201

**处理胜利奖励（`Reward`）**

记录一条胜利奖励，实际发放由战斗结束后的奖励链路处理。

- `value`：奖励 ID。必须填写 `reward_def` 中存在的 ID。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `4747`

来源 Card（游戏内 Wiki）：`刃型观测机`（Card `10176`）

Card 文本：消耗。战斗结束时，获得 20 星核。选择 1 张伴生战术。

```lua
event = 201,
targetId = 100,
value = 4007,
```


#### event-202

**改变战斗 Gold（`Gold`）**

增加或减少战斗中的 Gold。

- `value`：变化量。正数增加 Gold，负数减少 Gold；扣减量超过当前 Gold 时，只会扣到 `0`。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `5115`

来源 Card（游戏内 Wiki）：`挖掘无人机`（Card `10431`）

Card 文本：机体能力。消耗。派出时，你获得 10 星核。↑：你的战术牌伤害增加 1。

```lua
event = 202,
targetId = 100,
value = 10,
```


#### event-400

**发起攻击（`Attk`）**

把目标 Card 的攻击加入攻击栈。Target 必须能够选中战场上的 Card。

- `value`：攻击次数，填写 `1` 至 `10`。超过 `10` 的部分不会执行；`0` 或负数不会发起攻击。
- `extend`：不需要额外参数，省略即可。

##### eg: Effect `1707`

来源 Card（游戏内 Wiki）：`攻击指令`（Card `10479`）

Card 文本：你的一台机体进行 1 次攻击。

```lua
event = 400,
targetId = 104,
value = 1,
```


#### event-1000

**造成普通伤害（`Damage`）**

对目标造成普通伤害。

- `value`：基础伤害。
- `extend`：固定伤害时可以省略；需要动态计算时填写 `valueType` 及其参数。

##### eg: Effect `8026`

来源 Card（游戏内 Wiki）：`连续射击α`（Card `2061`）

Card 文本：造成 2 点伤害。将 1 张[连续射击β]加入你的手牌。

```lua
event = 1000,
targetId = 40,
value = 2,
```


#### event-1002

**造成贯穿伤害（`DamageBreak`）**

对目标造成贯穿伤害。

- `value`：基础伤害。
- `extend`：固定伤害时可以省略；需要动态计算时填写 `valueType` 及其参数。

##### eg: Effect `1811`

来源 Card：`贯穿射击`（Card `2318`）

Card 文本：对中路进行 1 次伤害为 7 的贯穿攻击。

游戏内 Wiki：未收录该 Card。

```lua
event = 1002,
targetId = 106,
value = 7,
```

#### 其他旧 Event

以下 Event 属于旧设计，不作为新 MOD 的配置教学：`10 Equip`、`12 CostCard`、`13 Shuffle`、`20 Copy`、`26 MoveDrone`、`28 Stackcard`、`29 Disintegrated`、`40 View`、`50 Option`、`62 StaticTarget`、`101 Shield`、`104 HpMax`、`111 PowerMaxSet`、`140 GridNoSet`、`999 Destroy`。

`3001 ResultNoNewCard` 和 `3002 ResultShield` 是内部结算事件，不应直接配置。

### 动态数值：`extend.valueType`

部分 Event 支持用 `extend.valueType` 动态计算 `value`。只有对应 Event 的现有配置已经使用动态数值时，才应采用这套规则。

动态数值统一使用下面的计算公式：

```text
最终 value = A + B × 来源数值
```

- `valueType`（必填，字符串）：决定来源数值从哪里取得。
- `A`（可选，数字，默认 `0`）：固定加值。
- `B`（可选，数字，默认 `1`）：来源数值的倍率。

例如 `A=2, B=3`、来源数值为 `4` 时，最终 `value` 为 `2 + 3 × 4 = 14`。填写不存在的 `valueType` 会导致 Effect 执行失败。

#### `valueType="cardFieldValue"`：读取目标 Card 字段

读取所有目标 Card 的指定字段并求和，再代入通用公式。

- `field`（必填，字符串）：要读取的字段名。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：字段总和的倍率。

`field` 可以填写 `attk`、`hp`、`cost`、`chipValue`、`hpDiff`、`configHp` 和 `configAttk`：

- `attk`：当前攻击；
- `hp`：当前 HP；
- `cost`：当前费用；
- `chipValue`：当前晶片数值；
- `hpDiff`：HP 上限与当前 HP 的差值；
- `configHp`：Card 配置中的初始 HP；
- `configAttk`：Card 配置对应的初始攻击。

其他字段名会尝试读取目标 Card 的同名战斗属性；属性不存在时按 `0` 计算。该类型应配合能够选中 Card 的 `targetId` 使用。

#### `valueType="targetCount"`：统计 Target 数量

查询指定 Target 当前能够得到多少个目标，再代入通用公式。

- `targetId`（必填，整数）：用于统计数量的 Target ID，不是当前 Effect 顶层的 `targetId`。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：目标数量的倍率。

例如 `targetId=542, A=0, B=2` 表示“己方场上每有一个符合 Target `542` 的目标，最终 `value` 增加 `2`”。

#### `valueType="effectValue"`：读取前序 Effect 结果

读取同一次 Skill 中更早执行的 Effect，再代入通用公式。它不会重新执行被读取的 Effect。

- `effectId`（必填，整数）：要读取的前序 Effect ID。该 Effect 必须排在当前 Effect 前面。
- `key`（可选，字符串）：读取前序结果中的指定字段，例如 `"powerMax"`、`"count"` 或 `"costs"`；省略时读取前序 Effect 记录的主要 `value`。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：前序结果的倍率。

指定的 `effectId` 没有在当前 Skill 中先执行，或指定的 `key` 不存在时，无法得到预期数值。完整案例见文末“特殊用法：读取前序 Effect 的结果”。

#### `valueType="effectValue_Count"`：读取前序处理数量

读取同一次 Skill 中更早 Effect 返回的 `count`，再代入通用公式。

- `effectId`（必填，整数）：要读取的前序 Effect ID。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：`count` 的倍率。

这类配置通常用于“每移动、废弃或处理一张 Card，再执行一次后续效果”。前序 Effect 必须能够产生 `count`，并且必须排在当前 Effect 前面。

#### `valueType="effectValue_Cards"`：统计前序返回的 Card

读取同一次 Skill 中更早 Effect 返回的 Card 列表，统计数量后代入通用公式。

- `effectId`（必填，整数）：要读取的前序 Effect ID。
- `condition`（可选，整数列表）：Battle Condition ID 列表；只统计满足这些 Battle Condition 的 Card。写法见 [Battle Condition 配置参考](conditions.md)。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：Card 数量的倍率。

前序 Effect 必须能够返回 Card 列表，并且必须排在当前 Effect 前面。

#### `valueType="triggerData"`：读取触发参数

从当前 Skill 的触发请求中读取一个数值字段，再代入通用公式。

- `triggerKey`（必填，字符串）：触发请求中的字段名。
- `A`（可选，数字）：固定加值。
- `B`（可选，数字）：触发参数的倍率。

该类型依赖具体 Trigger 实际传入的数据。只有已经确认某条 Trigger 链路包含对应 `triggerKey` 时才应使用；普通主动 Skill 不应自行猜测字段名。

#### 对每个伤害目标分别计算：`targetValueType`

`Damage` 和 `DamageBreak` 还支持按每个目标分别计算伤害，写法如下：

```lua
extend = {
    targetValueType = "cardFieldValueWithTarget",
    field = "configAttk",
    A = 0,
    B = 1,
}
```

- `targetValueType="cardFieldValueWithTarget"`（必填，字符串）：对每个受伤目标分别读取字段，而不是先把所有目标的字段相加。
- `field`（必填，字符串）：读取该受伤目标的 Card 字段；可用字段与 `cardFieldValue` 相同。
- `A`（可选，数字）：每个目标伤害的固定加值。
- `B`（可选，数字）：每个目标字段值的倍率。

`targetValueType` 只改变 `Damage` 和 `DamageBreak` 对各个目标结算时的数值。不要把 `cardFieldValueWithTarget` 填入普通 `valueType`。

## 游戏内表现

表现配置只控制客户端演出，不改变 Effect 的目标、事件或数值。普通 Effect 不需要特殊演出时，省略表现字段即可。

### 自动选择：`playResultType`

`playResultType` 指定表现类型，客户端再根据机体、形态和目标范围，从已有 Timeline 中自动选择合适的表现。

| 值 | 类型 | 用途 |
| --- | --- | --- |
| `0` | `none` | 不指定额外表现 |
| `1` | `attack` | 普通攻击表现 |
| `2` | `buff` | Buff 表现 |
| `3` | `debuff` | Debuff 表现 |
| `5` | `backAttack` | 背击 |
| `6` | `fanAttack` | 扇形攻击 |
| `7` | `penetratAttack` | 贯穿攻击 |
| `8` | `selfExplode` | 单体自爆 |
| `9` | `switchMode` | 切换形态 |
| `10` | `selfAoeExplode` | 范围自爆 |
| `11` | `carrierRemove` | 机体离场 |
| `12` | `switchDisplay` | 替换显示机体 |
| `13` | `meleeAttack` | 近战攻击 |

最常用的是 `0`、`1`、`2` 和 `3`。其他值用于特定演出，确认需要对应表现时再填写。
值 `4` 当前不可用。

自动选择只会使用客户端已经存在的 Timeline。机体缺少专属表现时，支持回退的类型会使用对应的通用表现。

### 指定表现：`customResultType`

`customResultType` 用于指定一个已经存在的 Timeline。它只在 `playResultType=1`、`2` 或 `3` 时生效，因此仍需先填写正确的表现类型。

可以填写完整 Timeline 名称：

```lua
playResultType = 1,
customResultType = "common_normal_aoe_attack",
```

也可以只填写表现后缀：

```lua
playResultType = 1,
customResultType = "fan_aoe_attack",
```

填写后缀时，客户端会先查找：

```text
<modelId>_<mode>_<customResultType>
```

例如机体 `ace_3` 的形态 `1` 会查找 `ace_3_1_fan_aoe_attack`。名称不存在时，会回到 `playResultType` 的自动选择。

### 查询和预览 Timeline

在设置中开启“开发者模式”，按反引号键（BackQuote）打开控制台。

列出某个机体已经存在的 Timeline：

```text
timeline_list <modelId> [mode]
```

例如：

```text
timeline_list tm31r 1
```

进入战斗后，可以预览其中一个完整 Timeline 名称：

```text
play_timeline <modelId> <mode> <timelineName>
```

例如：

```text
play_timeline tm31r 1 tm31r_1_heavy_aoe_attack
```

## 新增完整 Effect 配置

文件位置：

```text
config/battle_effect_def/config/effects.lua
```

最小配置示例：新增一个对任选敌方单位造成 2 点伤害的 Effect。

参考来源 Card（游戏内 Wiki）：`连续射击α`（Card `2061`）

Card 文本：造成 2 点伤害。将 1 张[连续射击β]加入你的手牌。

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

这段配置会新增 Effect `990701`：选择一个敌方单位，造成 2 点伤害。

## 特殊用法：读取前序 Effect 的结果

通常，Effect ID 用来指定需要执行的 Effect。`extend.effectId` 的作用不同：它让当前 Effect 读取同一次 Skill 中更早 Effect 的结算结果，再用该结果计算自己的 `value`。它不会重新执行前面的 Effect。

来源 Card（游戏内 Wiki）：`破限齐射`（Card `7547`）

Card 文本：摧毁一台己方无人机，对所有敌方机体造成该无人机攻击力的伤害。

Effect `4089`、Effect `3014` 和 Effect `4090` 都属于这张 Card 的 Skill。

它的 Skill `754701` 按以下顺序执行三个 Effect：

```lua
effect = { 4089, 3014, 4090 }
```

执行过程是：

```text
Effect 4089：记录目标己方无人机的攻击力
      |
      `-- retMap.value
              |
Effect 3014：摧毁这台无人机
              |
Effect 4090：读取记录值，对所有敌方机体造成等量伤害
```

对应配置：

```lua
-- 先执行：记录目标无人机的攻击力
{
    effectId = 4089,
    targetId = 613,
    event = 200,
    value = 0,
    extend = {
        valueType = "cardFieldValue",
        field = "attk",
        A = 0,
        B = 1,
    },
}

-- 然后执行：摧毁目标无人机
{
    effectId = 3014,
    targetId = 613,
    event = 27,
    value = 1,
}

-- 最后执行：读取 4089 的记录值
{
    effectId = 4090,
    targetId = 534,
    event = 1000,
    value = 1,
    extend = {
        valueType = "effectValue",
        effectId = 4089,
    },
}
```

这里三个字段分别表示：

- `valueType="effectValue"`：使用前序 Effect 的结算结果计算当前数值；
- `effectId=4089`：读取 Effect `4089` 已经记录的攻击力；
- 省略 `key`：读取前序 Effect 记录的主要 `value`。

最终，Effect `4090` 的 `value` 会变成 Effect `4089` 记录的无人机攻击力，再交给 `Damage` 事件，对所有敌方机体造成等量伤害。

使用这类配置时，相关 Effect 必须属于同一次 Skill，并且被读取的 Effect 必须排在读取它的 Effect 前面。`effectValue_Count` 和 `effectValue_Cards` 也遵循相同顺序，分别读取前序结果中的数量或 Card 列表数量。
