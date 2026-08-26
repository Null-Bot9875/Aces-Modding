# Version-one manual testing checklist

This checklist validates Card, Node, and Enemy authoring from a MOD-author perspective. Results remain separate for all three content types even though Node and Enemy share one integrated example.

Automated checks, successful configuration queries, and development-environment runs prove only parts of the path. Version-one authoring is human-validated only after every item on this page passes.

## Test preparation

- Record the full game version.
- Use a dedicated test save rather than a normal play save.
- Exit the game before testing.
- Enable only the single example MOD required by the current test.
- After changing enabled state or files, apply the selection, exit, and cold-start.
- Keep the matching `Player.log` from every run.
- Remove account details, personal directories, and other sensitive information before sharing logs.

Use only `Pass`, `Fail`, or `Pending` for results. A failed item also records the actual result and the screenshot or log location.

## A. Card: `card-pack`

Installation directory:

```text
Mods/example.cardpack/
```

Confirm that `mod.json` is directly inside this directory and that only `example.cardpack` is enabled.

| Check | Expected result | Result |
| --- | --- | --- |
| MOD manager discovery | `example.cardpack` appears with no Blocking issue | Pending |
| Cold-start load | The game starts normally and `Player.log` contains `Example Card Pack loaded` | Pending |
| Reward appearance | A new Rogue run with `baseId=501` shows `Example: Fire Drone` and Core Card `2000` in a `rewardId=10003` choice | Pending |
| Deck addition | Selecting the example adds Card `910001` to the current Rogue deck | Pending |
| Restart persistence | The Card remains after restarting and continuing the same run | Pending |
| Battle behavior | The Card can be drawn, assigned a valid target, and played successfully | Pending |
| Post-play area | A successful play removes the Card from hand and puts it in `desk(area=3)` | Pending |
| Disable recovery | After disabling the MOD, cold-starting, and creating a new run, the test Card no longer appears | Pending |

`card-pack` overrides Core `rewardId=10003` and is limited to a test save. Keep it disabled or remove it from `Mods/` after testing.

## B. Node: `complete-mod`

Installation directory:

```text
Mods/aces.example.nodeenemy/
```

Confirm that only `aces.example.nodeenemy` is enabled.

| Check | Expected result | Result |
| --- | --- | --- |
| MOD manager discovery | `aces.example.nodeenemy` appears with no Blocking issue | Pending |
| Cold-start load | The game starts normally and `Player.log` contains `Node and chain enemy example loaded` | Pending |
| Map reachability | Position `230001` is reachable in a new local-mode EP `1061` run | Pending |
| Node replacement | Position `230001` displays `MOD 行动链演示` instead of Core Node `4315` | Pending |
| Node content | Name, subheading, description, and options display correctly | Pending |
| Battle entry | Entering the Node starts the battle normally | Pending |
| Battle completion | The battle can finish, continue the flow, and settle its reward | Pending |
| Disable recovery | After disabling the MOD, cold-starting, and creating a new EP `1061` run, position `230001` returns to Core Node `4315` | Pending |

## C. Enemy: `complete-mod`

Enemy and Node are exercised in the same play session, but their results remain separate.

| Check | Expected result | Result |
| --- | --- | --- |
| Enemy active | The Node battle uses Enemy `11999` | Pending |
| Name boundary | `MOD 修复点射核心` is identifiable; any local `自成长核心` label matches the documented `baseId=7366` reuse | Pending |
| Turn 1 | Uses Core Card `21007` (`自我修复`) | Pending |
| Turn 2 | Uses Core Card `21006` (`试探点射`) | Pending |
| Turn 3 | Uses Core Card `21007` again | Pending |
| Turn 4 | Uses Core Card `21006` again | Pending |
| Behavior settlement | Target selection, effect settlement, and turn progression remain normal across all four turns | Pending |

## Result record

```text
Game version:
Test date:
Card: Pass / Fail / Pending
Node: Pass / Fail / Pending
Enemy: Pass / Fail / Pending
Disable recovery: Pass / Fail / Pending
Player.log:
Screenshots or video:
Notes:
```

For any failed item, retain the original example files and make a separate copy before further edits. See [Troubleshooting](debugging.md) for the diagnostic order.
