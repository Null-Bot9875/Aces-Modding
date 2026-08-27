# 静态异能配置

> 静态异能在来源满足区域和条件时，持续把一组 Attr 作用到目标；来源失效后，
> 对应 Attr 会随之移除。

`static_skill_def.config` 是静态异能配置表。它与
[`battle_skill_def.config`](skill_def.md) 的区别是：触发式异能在指定时机执行 Effect，
静态异能则持续修改 Card 或玩家的战斗属性。

## 静态异能的基本结构

游戏内 Wiki Card `晋升指令`（Card `2016`）的文本是：

> 目标己方无人机获得 +2/+2，进行一次攻击。

Card 的 Skill 先执行 Effect `1511`，向目标无人机添加静态异能 `201651`。
下面只列出理解这项静态异能需要关注的字段：

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
}
```

这项静态异能的实际效果主要由以下字段决定：

- `srcArea={14}`：静态异能的生效区域是战场机体区域；
- `targetArea={14}`：静态异能生效时，从战场机体区域查找需要生效的目标；
- `flag.self=1`：只保留拥有这项异能的无人机自身；
- `effect`：为目标增加 2 点攻击和 2 点装甲上限。

完整结算关系是：

```text
Card 2016：晋升指令
  └─ Skill 201601
       ├─ Effect 1511：向目标添加静态异能 201651
       │    └─ 静态异能 201651：目标自身获得 +2/+2
       └─ Effect 1512：该目标进行一次攻击
```

## Card、Effect 与静态异能

Card 可以通过 `staticList` 自带静态异能。Card 进入 `srcArea` 后，异能开始生效；

Effect 也可以在战斗中添加或移除静态异能：

- `event=60 StaticAdd`：`value` 填写要添加的静态异能 ID；
- `event=61 StaticRemove`：`value` 填写要移除的静态异能 ID。

完整写法见 [Effect 配置参考](effects.md)。

- Card 只要在场就始终拥有该静态异能：写入 Card 的 `staticList`；
- Card 在某个动作后才获得该静态异能：使用 `event=60` 添加；

## 必填字段与缺省值

新增静态异能只需要填写 5 个必填字段：

| 字段           | 类型        | 含义                       |
| ------------ | --------- | ------------------------ |
| `id`         | int       | 静态异能的唯一 ID               |
| `name`       | string    | 静态异能名称                   |
| `srcArea`    | list[int] | 静态异能的生效区域；来源离开这些区域后停止生效  |
| `targetArea` | list[int] | 静态异能生效时，从哪些 Area 查找目标    |
| `effect`     | table     | 持续作用于目标的 Attr            |

其他字段没有使用时可以省略，安装 MOD 时会补成以下缺省值：

| 字段 | 缺省值 | 含义 |
| --- | --- | --- |
| `desc` | `""` | 静态异能说明；需要单独显示异能说明时填写玩家文案 |
| `flag` | `{}` | 不按自身、阵营、位置或移除时机增加额外筛选 |
| `conditionList` | `{}` | 不检查目标 Condition |
| `conditionListSelf` | `{}` | 不检查异能来源 Condition |
| `flavorText` | `""` | 不填写详情中的背景描述 |
| `visibility` | `0` | 不单独显示异能说明 |
| `keywordList` | `{}` | 不展示关联关键字 |
| `disable` | `1` | 来源被沉默时，这项静态异能停止生效 |
| `showEffects` | `{}` | 不播放持续特效 |

`flag={}` 不等于“只作用于自身”。只需要影响异能来源自身时，仍需明确填写
`flag={self=1}`。

## 生效范围

### 静态异能的生效区域：`srcArea`

`srcArea` 填写静态异能的生效区域。拥有这项异能的对象进入其中一个区域时，静态异能开始生效；离开全部生效区域后，异能停止生效。

```lua
srcArea = { 14 },
```

Area `14` 是战场机体区域。Card 在手牌中时不会生效，派出到战场后开始生效，离开战场后停止生效。

### 查找目标的区域：`targetArea`

`targetArea` 填写静态异能生效时，从哪些区域查找目标。它只限定查找范围，最终保留哪些目标还要看 `flag` 和 `conditionList`。

```lua
targetArea = { 2, 6 },
```

这段配置从手牌区和抽牌堆查找目标。完整 Area 列表见 [战斗区域参考](../concepts/areas.md)。

## Effect

静态异能的 `effect` 是 `Attr 名称 -> 值` 的表，不是 `battle_effect_def.effectId` 列表。

```lua
effect = {
    attkAdd = 2,
    hpAddDrone = 2,
},
```

同一项静态异能可以同时填写多个 Attr。Attr 名称区分大小写；来源失效后，由这项静态异能添加的 Attr 会一并移除。

### 攻击、装甲与伤害

#### `attkAdd`：修改攻击

正值提高攻击，负值降低攻击。

##### eg: `晋升指令`（Static Skill `201651`）

文案：+2/+2

```lua
effect = {
    attkAdd = 2,
},
```

#### `hpAddDrone`：修改机体装甲上限

正值提高机体或无人机的装甲上限，负值降低装甲上限。

##### eg: `晋升指令`（Static Skill `201651`）

文案：+2/+2

```lua
effect = {
    hpAddDrone = 2,
},
```

#### `damage`：修改受到的 Damage

正值增加目标受到的 Damage，负值减少目标受到的 Damage。

##### eg: `白矮星`（Static Skill `201852`）

文案：受到的伤害减少 2。

```lua
effect = {
    damage = -2,
},
```

#### `damageAdd`：修改造成的 Damage

正值增加该 Card 造成的 Damage，负值减少该 Card 造成的 Damage。

##### eg: `电能灌注`（Static Skill `216951`）

文案：战术伤害增加 1。

```lua
effect = {
    damageAdd = 1,
},
```

### 能量与费用

#### `powerMax`：修改能量上限

正值提高 EPM，负值降低 EPM。目标通常是玩家所在的 Area `8`。

##### eg: `高能电容`（Static Skill `300251`）

文案：能量上限 +2。

```lua
targetArea = { 8 },
effect = {
    powerMax = 2,
},
```

#### `costVal`：增减 Card 费用

负值降低费用，正值提高费用。它是在原费用上增减，不会把费用固定成某个值。

##### eg: `紧急废弃`（Static Skill `206751`）

文案：下一张牌费用减少 2。

```lua
effect = {
    costVal = -2,
},
```

#### `costSet`：把 Card 费用固定为指定值

`costSet` 直接填写最终费用。需要“费用变为 1”时填写 `1`。

##### eg: `伟业`（Static Skill `800951`）

文案：战术 Card 费用变为 1，结算后进入废弃区。

```lua
effect = {
    costSet = 1,
},
```

### 攻击状态

#### `attkShield`：覆膜

填写 `1`。抵消下一次受到的伤害，触发后移除；多项覆膜不会累计层数。

##### eg: `覆膜`（Static Skill `202151`）

文案：覆膜。

```lua
effect = {
    attkShield = 1,
},
```

#### `attkShieldEx`：金印

填写 `1`。与覆膜不同，金印可以累计，每次触发只移除一层。

##### eg: `CE9842-琉璃光SP`（Static Skill `800152`）

文案：金印。

```lua
effect = {
    attkShieldEx = 1,
},
```

#### `attkDelay`：延缓

填写 `1`。目标跳过下一次攻击，触发后移除。

##### eg: `干扰射击`（Static Skill `201051`）

文案：延缓。

```lua
effect = {
    attkDelay = 1,
},
```

#### `attkPause`：无法攻击

大于 `0` 时，目标无法执行攻击。它不会像延缓一样在跳过一次攻击后自行移除。

##### eg: `杂念无人机`（Static Skill `800451`）

文案：无法攻击。

```lua
effect = {
    attkPause = 1,
},
```

#### `attkTwice`：连击

每 1 点使一次攻击额外结算 1 次，最多按 30 点计算。

##### eg: `狂风组件`（Static Skill `203051`）

文案：连击 1。

```lua
effect = {
    attkTwice = 1,
},
```

#### `attkTargetMiss`：不能成为攻击目标

大于 `0` 时，目标不能被选为攻击目标。它不等于完全无法被其他 Effect 选中。

##### eg: `潜航器`（Static Skill `1027251`）

文案：无法被选为攻击目标。

```lua
effect = {
    attkTargetMiss = 1,
},
```

#### `noOtherChoose`：不能被其他阵营选择

大于 `0` 时，敌方不能将该 Card 选为目标，所属方仍可选择。

##### eg: `白矮星`（Static Skill `201851`）

文案：无敌。

```lua
effect = {
    noOtherChoose = 1,
    damage = -99,
},
```

“无敌”由两个 Attr 共同完成：`noOtherChoose` 阻止敌方选择，`damage=-99` 大幅降低受到的 Damage。

### 异能、Tag 与移动规则

#### `disable`：沉默目标

填写 `1`。使目标身上允许被沉默的静态异能停止生效。它与配置顶层的 `disable` 不是同一个字段。

##### eg: `清净`（Static Skill `801151`）

文案：沉默。

```lua
effect = {
    disable = 1,
},
```

#### `skillAdd`：添加触发式异能

值填写 `battle_skill_def.config` 中的 Skill ID。

##### eg: `白矮星-新星模式`（Static Skill `201953`）

文案：每当派出机体时，抽 1 张牌。

```lua
effect = {
    skillAdd = 201901,
},
```

#### `tagAdd`：添加 Card Tag

值填写现有 Card Tag ID。

##### eg: `贯穿组件`（Static Skill `234251`）

文案：贯穿。

```lua
effect = {
    tagAdd = 409,
},
```

#### `droneMove`：改变机体离场后的去向

值填写目标 Area ID。机体原本要从战场移动到弃牌堆时，改为移动到该 Area。

##### eg: `极限解构`（Static Skill `1029053`）

文案：消耗。

```lua
effect = {
    droneMove = 4,
},
```

Area `4` 是废弃区。

#### `stackMove`：改变 Card 结算后的去向

值填写目标 Area ID，常用于让战术 Card 结算后进入废弃区。

##### eg: `伟业`（Static Skill `800951`）

文案：战术 Card 费用变为 1，结算后进入废弃区。

```lua
effect = {
    costSet = 1,
    stackMove = 4,
},
```

#### `stackcardFail`：禁止集成

大于 `0` 时，目标不能参与集成。

##### eg: `自集成`（Static Skill `404251`）

文案：无人机不能集成，但可以获得自身的集成能力。

```lua
effect = {
    stackcardFail = 1,
},
```

#### `stackcardSkillSelf`：启用自身集成能力

填写 `1`。让目标获得自身 Card 配置携带的集成能力。

##### eg: `自集成`（Static Skill `404251`）

文案：无人机不能集成，但可以获得自身的集成能力。

```lua
effect = {
    stackcardSkillSelf = 1,
},
```

### 方向与专用机制

#### `dirSelf`：方向异能作用于自身

大于 `0` 时，目标的方向异能也会作用于自身。

##### eg: `联结指令`（Static Skill `213951`）

文案：此无人机的方向异能对自身生效。

```lua
effect = {
    dirSelf = 1,
},
```

#### `dirLoop`：允许方向连接形成回路

大于 `0` 时，方向异能形成回路时不会发生短路。

##### eg: `回路拓扑优化`（Static Skill `402351`）

文案：己方全场无人机的方向异能不会发生短路。

```lua
effect = {
    dirLoop = 1,
},
```

#### `stanceAdd`：剑势伤害

修改剑势相关伤害，只适用于剑势体系。

##### eg: `枭首`（Static Skill `260753`）

文案：剑术伤害增加 1。

```lua
effect = {
    stanceAdd = 1,
},
```

#### `boomAdd`：自爆倒计时标记

只适用于现有自爆倒计时体系，不能单独完成自爆结算。

##### eg: `自爆倒计时`（Static Skill `752251`）

文案：将在指定回合自爆。

```lua
effect = {
    boomAdd = 1,
},
```

#### `deathAdd`：黑矮星受击标记

只适用于黑矮星相关 Skill 读取受击次数的机制。

##### eg: `垂死的银星`（Static Skill `1012652`）

文案：受击。

```lua
effect = {
    deathAdd = 1,
},
```

#### `negaAdd`：贬义叙述次数

修改“贬义叙述”的剩余反制次数，只适用于对应战斗机制。

##### eg: `贬义叙述`（Static Skill `1072059`）

文案：+4 次反制。

```lua
effect = {
    negaAdd = 4,
},
```

#### `attkBack`：背刺目标规则

大于 `0` 时，攻击使用背刺目标规则。当前只有测试配置，没有正式内容样例。

##### eg: `背刺测试`（Static Skill `105`）

```lua
effect = {
    attkBack = 1,
},
```

#### `relive`：复生

大于 `0` 时，机体死亡时触发一次复生，触发后移除该 Attr。当前只有测试配置。

##### eg: `复生测试`（Static Skill `106`）

```lua
effect = {
    relive = 1,
},
```

### 动态数值：`miscFunc`

`miscFunc` 根据目标数量、Card 字段或指示物数量计算一个 Attr 的值。

```text
最终 Attr 数值 = A + B × 来源数值
```

| 字段 | 含义 |
| --- | --- |
| `valueType` | 来源数值的取得方式 |
| `effectKey` | 计算结果写入哪个 Attr；省略时使用 `damageAdd` |
| `A` | 固定加值；省略时为 `0` |
| `B` | 来源数值的倍率；省略时为 `1` |

#### `valueType="targetCount"`：读取 Target 数量

`targetId` 填写 Target ID。来源数值是该 Target 当前找到的目标数量。

##### eg: `攻击中枢 阿克琉斯`（Static Skill `1070451`）

文案：此机体的攻击力为 11 - 己方场上机体数。

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

这项 Static Skill 只负责减去己方场上机体数；Card 的基础攻击是 `11`。

#### `valueType="cardFieldValue"`：读取目标 Card 字段

`name` 填写目标 Card 的字段名。来源数值是当前受影响 Card 的该字段值。

##### eg: `更强的无人机`（Static Skill `1800451`）

文案：双方无人机派出时，获得 1 倍于原本装甲数的额外装甲和上限。

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

#### `valueType="tokenCount"`：读取指示物数量

`token` 填写指示物 ID。省略 `src` 时读取当前目标的指示物；`src=true` 时读取异能来源的指示物。

当前没有正式 Static Skill 样例，以下只表示字段写法：

```lua
effect = {
    miscFunc = {
        valueType = "tokenCount",
        token = 9901,
        src = true,
        effectKey = "attkAdd",
        A = 0,
        B = 1,
    },
},
```

`targetCount` 可由战斗模拟预览。`cardFieldValue` 和 `tokenCount` 应在实际战斗中验证结果。

### 已有运行入口但没有正式 Static Skill 样例的字段

以下字段存在实际结算入口，但当前内容没有可照抄的 Static Skill。表中的代码只表示字段形状，使用前需要在实际战斗中验证完整规则。

| 字段 | 作用 | 写法示例 |
| --- | --- | --- |
| `attkMul` | 乘算攻击 | `effect={attkMul=2}` |
| `damageMul` | 乘算造成的 Damage | `effect={damageMul=2}` |
| `hpAddBase` | 修改玩家机体 CA 上限；目标使用玩家 Area `8` | `effect={hpAddBase=2}` |
| `noChoose` | 任何阵营都不能选择目标 | `effect={noChoose=1}` |
| `noCounteract` | Card 不能被反制 | `effect={noCounteract=1}` |
| `tagRemove` | 临时移除一个 Card Tag | `effect={tagRemove=409}` |
| `typeAdd` | 临时增加一个 Card 颜色 | `effect={typeAdd=2}` |
| `typeRemove` | 临时移除一个 Card 颜色 | `effect={typeRemove=2}` |
| `skillRemove` | 目标为玩家时，按 Tag 移除玩家触发式异能 | `effect={skillRemove={tag={9901}}}` |
| `costId` | 用另一个 Effect 替换 Card 的费用 Effect | `effect={costId=990701}` |
| `extraCost` | 增加额外费用 Effect | `effect={extraCost=990701}` |
| `extraCostRemove` | 忽略 Card 原有的额外费用 | `effect={extraCostRemove=1}` |
| `rollAdd` | 为玩家的检定结果加固定值 | `effect={rollAdd=1}` |
| `rollMul` | 将玩家的检定结果乘以指定值 | `effect={rollMul=2}` |
| `rollRep` | 把玩家的检定结果固定为指定值 | `effect={rollRep=6}` |
| `rollCond` | `cond` 成立时，把玩家检定结果替换为 `value` | `effect={rollCond={cond=9901,value=6}}` |
| `damageMax` | 限制一次受到的最大 Damage | `effect={damageMax=1}` |
| `powerRecover` | 修改能量回复量 | `effect={powerRecover=1}` |
| `powerDec` | 正值增加玩家的能量消耗或能量扣除量 | `effect={powerDec=1}` |
| `deadTrigger` | 机体死亡时执行指定 Skill | `effect={deadTrigger=990801}` |
| `gauge` | 修改玩家身上供 Condition 读取的量表值 | `effect={gauge=1}` |

## Flag

`flag` 决定目标与来源的关系、阵营和位置限制，也负责 Condition 组合、延迟激活和自动移除。没有对应规则时可以省略整个 `flag`。

### `self`：来源与目标的关系

- `self=1`：只保留来源自身；
- `self=0`：排除来源自身；
- 省略 `self`：不按来源关系筛选。

#### eg: `晋升指令`（Static Skill `201651`）

文案：目标己方无人机获得 +2/+2，进行一次攻击。

```lua
flag = {
    self = 1,
},
```

这项 Static Skill 由 Effect 添加到目标无人机，`self=1` 让 +2/+2 只作用于该无人机。

### `targetCamp`：目标阵营

- `targetCamp=0`：从来源所属阵营的全部玩家查找目标；
- `targetCamp=1`：从敌方阵营查找目标；
- 省略时只从来源所属玩家查找目标。

#### eg: `战区能量增幅`（Static Skill `401452`）

文案：所有敌方无人机获得 +1/+0。

```lua
flag = {
    targetCamp = 1,
},
```

### `selfPlayer`：目标所属玩家

该字段用于多人或共享阵营范围：

- `selfPlayer=1`：只保留来源所属玩家的目标；
- `selfPlayer=0`：排除来源所属玩家，只保留同阵营其他玩家的目标。

#### eg: `避战的`（Static Skill `1600351`、`1600352`）

文案：双方所有无人机攻击减少 2。

```lua
-- 作用于同阵营其他玩家
flag = {
    selfPlayer = 0,
},

-- 作用于来源所属玩家
flag = {
    selfPlayer = 1,
},
```

### `gridCheck`：战场位置关系

`gridCheck` 在 `targetArea` 找到目标后，再按来源和目标的战场位置进行筛选。当前正式内容只使用 `side=1`，表示相邻位置。

#### eg: `充能中枢`（Static Skill `245051`）

文案：相邻无人机获得 +2/+0。

```lua
flag = {
    self = 0,
    gridCheck = {
        side = 1,
    },
},
```

### `stackcard`：集成时不重复计算

当前固定写作 `stackcard=0`。字段存在时，Card 进行集成相关处理时跳过这项静态异能，避免重复计算。

#### eg: `标准无人机β+`（Static Skill `208051`）

文案：+2/+0。

```lua
flag = {
    self = 1,
    stackcard = 0,
},
```

### `reserve`：变身后保留

`reserve=1` 表示来源 Card 被替换或变身后，保留这项 Static Skill。

#### eg: `邓肯23`（Static Skill `700051`）

文案：覆膜。

```lua
flag = {
    self = 1,
    reserve = 1,
},
```

### Condition 的组合方式

`conditionType` 控制 `conditionList`，`conditionTypeSelf` 控制 `conditionListSelf`。

- 值 `1`：全部 Condition 都满足；省略时也是 `1`；
- 值 `2`：满足任意一个 Condition。

空表 `{}` 和 `{0}` 都表示没有条件。新增配置推荐直接使用 `{}`，没有必要保留占位 ID `0`。

#### `conditionType` 的写法

当前正式内容中的多目标 Condition 都使用缺省的“全部满足”。需要“满足任意一个”时明确填写 `2`：

```lua
conditionList = { 60, 2138 },
flag = {
    conditionType = 2,
},
```

#### `conditionTypeSelf` 的写法

当前正式内容没有来源 Condition 的 OR 样例。字段写法如下：

```lua
conditionListSelf = { 2025, 2026 },
flag = {
    conditionTypeSelf = 2,
},
```

Condition ID 的含义和字段见 [Condition 配置参考](conditions.md)。

### `active`：满足条件后永久激活

`active.condition` 填写 Condition ID 列表。Static Skill 在条件满足前不会加入正常静态异能列表；第一次满足后完成激活，之后不会因为条件再次不满足而关闭。

当前没有正式内容样例，以下只表示字段写法：

```lua
flag = {
    active = {
        condition = { 9901 },
    },
},
```

需要随条件持续开启和关闭时，应使用 `conditionListSelf`，不要使用 `active`。

### `removeTrigger`：按 Trigger 自动移除

`removeTrigger` 让动态添加的 Static Skill 在指定 Trigger 出现一定次数后自动移除。

| 字段 | 含义 |
| --- | --- |
| `trigger` | 要监听的 Trigger ID |
| `count` | 出现多少次后移除；省略时第一次出现就移除 |
| `triggerEx` | 可选；进一步筛选这次 Trigger |

#### eg: `紧急废弃`（Static Skill `206751`）

Card 文案：废弃所有手牌。抽 2 张牌。下一张牌费用减少 2。

```lua
effect = {
    costVal = -2,
},
flag = {
    removeTrigger = {
        trigger = 115,
        count = 1,
    },
},
```

Trigger `115` 是使用 Card。触发一次后，这项费用修改被移除，因此只影响下一张 Card。`triggerEx` 的字段见 [触发式异能配置](skill_def.md)。

### `targetSelection`：等待外部选择目标

`targetSelection` 填写 Target ID。字段存在时，Static Skill 不再自动把 `effect` 应用到 `targetArea` 中的目标，而是等待其他战斗流程指定目标。

当前没有正式内容样例，战斗模拟也会跳过这类 Static Skill。MOD 配置暂不直接使用该字段。

## `conditionList` 与 `conditionListSelf`

两者检查的对象不同，`conditionListSelf` 不是 `conditionList` 的简写。

```text
先检查来源：conditionListSelf
  └─ 来源通过后，从 targetArea 查找候选目标
       └─ 对每个目标分别检查：conditionList
            └─ 通过的目标获得 effect
```

### `conditionList`：逐个筛选目标

`conditionList` 对 `targetArea` 找到的每个候选目标分别检查。某个目标不满足条件，只会排除该目标，不影响其他目标。

#### eg: `精英支援`（Static Skill `401151`）

来源晶片：`精英支援`（Chip `4011`）

文案：僚机获得 +2/+2。

```lua
targetArea = { 14 },
effect = {
    attkAdd = 2,
    hpAddDrone = 2,
},
conditionList = { 61 },
```

Condition `61` 检查候选目标是否为僚机，因此战场上的主将不会获得加成。

### `conditionListSelf`：控制整项异能是否生效

`conditionListSelf` 只检查拥有这项 Static Skill 的来源。来源不满足条件时，整项异能不生效，也不会继续为任何目标添加 `effect`。

#### eg: `魔王型核心`（Static Skill `235451`）

文案：回路 3：+3/+0。

```lua
effect = {
    attkAdd = 3,
},
flag = {
    self = 1,
},
conditionListSelf = { 2025 },
```

Condition `2025` 检查来源机体的回路是否达到 3。条件不满足时，整项 +3/+0 关闭。

## 游戏内显示

### 异能说明：`visibility`

`visibility` 只控制是否单独展示静态异能说明，不改变结算：

- `visibility=0`：不单独显示；
- `visibility>0`：在战斗异能列表和相关详情中显示。

需要显示时，`desc` 应填写完整的玩家文案：

```lua
desc = "所有僚机获得 +2/+2。",
visibility = 1,
```

## 新增静态异能

文件位置：

```text
config/static_skill_def/config/statics.lua
```

下面新增静态异能 `990901`：拥有这项异能的机体在场时，自身获得 +2/+2。

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

机体 Card 可以直接引用：

```lua
staticList = { 990901 },
```

也可以由 Effect 在战斗中添加：

```lua
event = 60,
targetId = 613,
value = 990901,
```

前一种写法表示 Card 在场时自带 +2/+2；后一种写法表示结算 Effect 后，
目标己方无人机获得这项静态异能。

## `showEffects` 支持的持续特效

`showEffects` 填写客户端已经存在的持续特效名。当前配置中可以直接复用以下四项：

| 特效名 | 用途 | 现有样例 |
| --- | --- | --- |
| `mecha_common_uav_buffhold_01` | 机体持续增益 | `晋升指令`（Static Skill `201651`） |
| `mecha_common_uav_buffhold_02` | Card、能量或战术持续增益 | `电能灌注`（Static Skill `216951`） |
| `mecha_common_uav_debuffhold_01` | 机体持续减益 | `拘束手臂α`（Static Skill `234852`） |
| `mecha_common_uav_debuffhold_02` | 另一种持续减益表现 | `护卫机`（Static Skill `1007651`） |

#### eg: `晋升指令`（Static Skill `201651`）

```lua
showEffects = {
    "mecha_common_uav_buffhold_01",
},
```

只需要数值效果时可以省略 `showEffects`。安装 MOD 时不会校验特效资源名；填写其他名称时，必须确保对应资源已经随游戏提供。
