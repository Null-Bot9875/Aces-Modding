# Effect 属性参考

> Attr 表示战斗中附加在 Card 上的数值、状态或规则标记，例如攻击力加成、延缓和无法被选中。

`贯穿` 是 Card Tag 和伤害事件，不属于 Attr。

## Attr 的引用入口

以下字段直接引用 Attr 名称：

| 引用字段 | 作用 |
| --- | --- |
| `battle_effect_def.config.extend.attrTarget` | `event=110` 时填写要移除的 Attr 名称 |
| `battle_skill_def.config.triggerEx.attr` | `trigger=131` 时填写要匹配的 Attr 名称，只响应增加该 Attr 的事件 |

`event=110` 只会移除目标 Card 已有的同名属性，不会新增或修改其他属性。

## 常用 Attr

这些 Attr 用于通用的数值、伤害、目标选择和 Card 移动规则，可以直接参考现有 Card 与 Skill 的用法。

| Attr 名称         | 游戏内名称   | 作用                                           |
| --------------- | ------- | -------------------------------------------- |
| `attkShield`    | 覆膜      | 抵消下一次受到的伤害，触发后移除该属性                          |
| `attkDelay`     | 延缓      | 跳过下一次攻击，触发后移除该属性                             |
| `attkTwice`     | 连击      | 每 1 点使一次攻击额外结算 1 次，最多按 30 点计算                |
| `costVal`       | 能量费用    | 修正 Card 的能量费用；负值降低费用，正值提高费用                  |
| `attkAdd`       | 攻击      | 修正机体的攻击；正值提高攻击，负值降低攻击                        |
| `hpAddDrone`    | 装甲      | 修正机体的生命上限；正值提高上限，负值降低上限                      |
| `damage`        | 受到伤害    | 修正目标受到的 Damage；正值增加伤害，负值减少伤害                 |
| `damageAdd`     | 伤害      | 修正该 Card 造成的 Damage；正值增加伤害，负值减少伤害            |
| `noOtherChoose` | 无法被敌方选中 | 敌方不能将该 Card 选为目标，所属方仍可选择                     |
| `droneMove`     | 消耗      | 机体从 Drone 移向弃牌堆时，改为移动到该值指定的 [Area](areas.md) |

## 专用 Attr

这些 Attr 与特定 Card、流派或战斗规则绑定。复用前应先查看“现有用途”，确认同时需要哪些 Skill 和 Condition。

| Attr 名称        | 游戏内名称   | 作用                         | 现有用途            |
| -------------- | ------- | -------------------------- | --------------- |
| `attkShieldEx` | 金印      | 抵消一次受到的伤害，并移除提供该属性的 Skill  | 琉璃光专用           |
| `stanceAdd`    | 剑势      | 增加剑势相关伤害                   | 菘猫专用            |
| `deathAdd`     | 黑矮星死亡标记 | 记录受击次数，供对应 Skill 读取        | 黑矮星专用           |
| `boomAdd`      | 倒计时自爆标记 | 记录自爆倒计时                    | 威胁时序仪、延时引信的自爆机制 |
| `negaAdd`      | 贬义叙述    | 修正“贬义叙述”的剩余反制次数            | 极境专用            |

## 旧设计

以下 Attr 属于旧设计，请勿用于新 MOD：

- `deadTrigger`
- `attkBack`
- `relive`
- `noChoose`
