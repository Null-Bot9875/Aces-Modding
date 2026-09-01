# Round Stage Reference

Round stages are also Trigger IDs `1`–`7`. They describe the order of a player's turn.

| ID | Runtime name | Stage |
| --- | --- | --- |
| `1` | `RESET` | Reset step |
| `2` | `MAINTAIN` | Maintain step |
| `3` | `NEWCARD` | Draw step |
| `4` | `MAIN1` | Main phase 1 |
| `5` | `ATTK` | Attack phase |
| `6` | `FINISH` | End phase |
| `7` | `CLEANUP` | Cleanup step |

Use these IDs in `battle_skill_def.trigger`; see [Trigger Reference](triggers.md) for configuration details.
