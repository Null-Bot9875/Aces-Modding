# RoundStage 回合阶段

> 回合开始 → 抽牌 → 玩家行动 → 机体攻击 → 回合结束。

配置里把回合开始和回合结束各拆成两步，因此一共有 7 个 RoundStage。

## 阶段对照

| ID | RoundStage | 玩家会看到什么 |
| --- | --- | --- |
| `1` | `RESET` | 新回合开始，系统准备本回合 |
| `2` | `MAINTAIN` | 处理回合开始时的能力 |
| `3` | `NEWCARD` | 当前玩家抽牌 |
| `4` | `MAIN1` | 当前玩家使用 Card |
| `5` | `ATTK` | 当前玩家的机体攻击 |
| `6` | `FINISH` | 处理回合结束时的能力 |
| `7` | `CLEANUP` | 清理手牌；战斗继续时切换到下一位玩家 |

## 配置中怎么使用

需要让 Skill 在某个阶段触发时，把对应 ID 填入 `battle_skill_def.trigger`。

例如，在抽牌阶段触发：

```lua
trigger = 3,
```

其他 Trigger 配置见 [Trigger 配置参考](triggers.md)。
