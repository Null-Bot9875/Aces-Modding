# Trigger 配置参考

> Trigger 决定 `battle_skill_def` 中的 Skill 在何时执行。`triggerEx` 用于进一步筛选已经发生的 Trigger。

`trigger` 与 Effect 的 `event` 不是同一组编号：`trigger` 决定 Skill 何时执行，`event` 决定 Effect 执行什么结算。

## Trigger 的配置入口

| 配置字段 | 作用 |
| --- | --- |
| `battle_skill_def.config.trigger` | 填写 Trigger ID，决定 Skill 的触发时机 |
| `battle_skill_def.config.triggerEx` | 填写附加条件，进一步筛选可以触发该 Skill 的事件 |
| `battle_skill_def.config.extend.triggerCount` | 限制该 Skill 可以触发的次数 |
| `battle_effect_def.config.extend.trigger` | `event=120` 时填写 Trigger ID，只执行目标 Card 上 `trigger` 值相同的 Skill |

## Trigger 枚举

以下 Trigger 均可在现有 `battle_skill_def.config` 中找到完整 Skill 配置。

### 主动 Skill

| ID | 运行时名称 | 触发时机 | 可参考的 Skill |
| --- | --- | --- | --- |
| `0` | `Active` | 不随阶段或战斗事件自动触发，由 Card 或其他配置主动执行 | `101` 弃牌 |

### 回合阶段

| ID | 运行时名称 | 触发时机 | 可参考的 Skill |
| --- | --- | --- | --- |
| `1` | `RESET` | 回合开始的重置步骤 | `100101` 扩容引擎 |
| `2` | `MAINTAIN` | 维持步骤 | `401501` 整备效率提升 |
| `3` | `NEWCARD` | 抽牌步骤 | `100301` 资源探机 |
| `4` | `MAIN1` | 主要阶段 1 | `991901` “飞矢”弹道导弹 |
| `5` | `ATTK` | 攻击阶段 | `750301` 将军 |
| `6` | `FINISH` | 终结阶段 | `400701` 补充射击 |
| `7` | `CLEANUP` | 清除步骤 | `233302` 热启动 |

### 战斗事件

| ID | 运行时名称 | 触发时机 | 可参考的 Skill |
| --- | --- | --- | --- |
| `100` | `GameStart` | 战斗开始 | `400301` 预防性养护 |
| `106` | `HPDec` | 核心装甲减少 | `260201` 薮猫-防御姿态 |
| `107` | `Damage` | 目标实际受到 Damage | `204901` 反应装甲装填器 |
| `108` | `NewCard` | 抽到 Card | `757801` 推进器 |
| `109` | `EffectDamage` | 由 Effect 造成实际伤害 | `1405101` 激发协议 |
| `111` | `CardMove` | Card 在 Area 之间移动 | `402401` 载重投射算法 |
| `115` | `UseCard` | 使用 Card | `400401` 内存调度优化 |
| `119` | `TryDamage` | 尝试造成 Damage；即使最终没有实际扣除核心装甲也会触发 | `230001` 赝波招来 |
| `123` | `DroneSet` | 机体进入 Drone 区并完成放置 | `103` 无人机被召唤 |
| `124` | `DroneDestory` | 机体战斗破坏另一台机体 | `215501` 猎神武装 |
| `125` | `DroneDamage` | 机体对核心装甲造成伤害 | `250501` 激发式步枪 |
| `126` | `DroneBeDestory` | 机体被破坏 | `102` 复生 |
| `129` | `DroneAttk` | 机体完成一次攻击 | `2104601` 覆膜投射器 |
| `130` | `StackcardAdd` | 机体增加叠层 Card | `202901` 狂风组件 |
| `131` | `StaticAttrAdd` | Card 获得静态 Attr | `1061101` 振剑-“提神” |
| `132` | `DirCountAdd` | 机体回路数量增加 | `400901` 回路逸散监控 |
| `134` | `PoolReset` | 牌库重置 | `401801` 循环节能算法 |
| `135` | `HeroCardAdd` | 机师进入战斗区域 | `700802` 冬子 |
| `137` | `DroneAttkReplace` | 自身攻击时检查替换攻击的 Skill | `855201` 商会幽浮 |
| `138` | `DroneAttkWithPower` | 攻击力大于 0 的机体完成攻击 | `234102` 学习装置 |

## `triggerEx`

不需要附加筛选时填写空表：

```lua
triggerEx = {},
```

`triggerEx` 只筛选 Trigger 携带的信息，不会创建新的触发时机。所填字段必须与 `trigger` 能提供的信息匹配。

| 字段 | 填写方式 | 作用 |
| --- | --- | --- |
| `self` | `1` 或 `0` | `1` 表示事件来源必须是 Skill 所在 Card；`0` 表示事件来源不能是该 Card |
| `src` | `1`、`2` 或 `3` | 筛选事件来源阵营：`1` 为己方，`2` 为敌方，`3` 为双方；省略时只响应己方事件 |
| `srcTag` | Tag ID 列表 | 事件来源 Card 必须同时具有列表中的全部 Tag |
| `srcCondition` | Battle Condition ID 列表 | 使用 [Battle Condition](../config/conditions.md) 筛选事件来源 Card |
| `valueCondition` | Battle Condition ID 列表 | 使用 [Battle Condition](../config/conditions.md) 筛选 Trigger 携带的数值 |
| `targetId` | Target ID | 使用 [Target](../config/targets.md) 和本次 Trigger 携带的信息生成 Skill 目标 |
| `moveSrc` | Area ID | `trigger=111` 时，筛选 Card 移动前所在的 [Area](areas.md) |
| `moveTarget` | Area ID | `trigger=111` 时，筛选 Card 移动后进入的 [Area](areas.md) |
| `condition` | Battle Condition ID 列表 | 使用 [Battle Condition](../config/conditions.md) 筛选 Skill 所在 Card |
| `countReset` | `1` | 与 `extend.triggerCount` 配合，每回合重置触发次数 |
| `roundMod` | 正整数 | 每隔指定数量的己方回合允许触发一次 |
| `roundModStart` | 正整数 | 与 `roundMod` 配合，指定周期中的首次触发位置 |
| `attr` | Attr 名称 | 筛选 Trigger 携带的 [Attr](attrs.md)，例如 `attkDelay` |
| `nodeShowType` | `showType` 列表 | 只在当前 Node 的 `showType` 位于列表中时触发 |

## 触发次数

`extend.triggerCount` 限制 Skill 可以触发的次数。需要每回合重新计数时，同时填写 `triggerEx.countReset=1`。

Skill `402401`（载重投射算法）的配置如下：

```lua
trigger = 111,
triggerEx = {
    moveTarget = 4,
    countReset = 1,
},
extend = {
    triggerCount = 3,
},
```

这段配置在 Card 移入废弃区时触发，每回合最多执行 3 次，下一回合重新计数。
