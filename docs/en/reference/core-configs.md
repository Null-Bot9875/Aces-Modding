# Reusable Core configuration

This page is not a complete Core catalog. It lists only starting values used by the version-one examples whose reference relationships have been checked. An unlisted Core ID may still be readable, but it is outside the current public support commitment.

## Card starting combination

The regular tactical Card in `card-pack` reuses the behavior combination from Core Card `2012`, “Barrage”:

```lua
type = { 2 }
tagMap = { [3] = 1, [31] = 1 }
targetIds = { 40 }
costEffect = 8012
skillList = { 201201 }
```

| Configuration | Confirmed meaning | Current boundary |
| --- | --- | --- |
| Card `2012` | Core “Barrage”; source for the complete behavior combination above | `card-pack` uses `rare=1`, rather than copying Core Card `2012` and its `rare=3` |
| Skill `201201` | “Barrage”; deals 2 damage | Confirmed only in the Card combination above |
| Target `40` | Select one enemy unit when attacking | Other Targets are not yet organized as a public catalog |
| Effect `8012` | Reduce own energy by 1 | Other cost Effects are not yet organized as a public catalog |
| `tagMap` IDs `3` and `31` | Paired Tags used by Core Card `2012` | A complete Tag ID catalog is not yet public |
| Card `2000` | “Deploy Drone” | Used only as a Core comparison Card in the `card-pack` test reward |
| `baseId=501` | `ACE-001 White Dwarf` | Confirmed only for filtering the example Card pool |
| Reward `10003` | Test reward entry overridden by `card-pack` | This is a test-save approach, not a new reward ID, and should not be reused directly by distributed content |

This combination validates obtaining a regular tactical Card from a reward and playing it from hand. Custom Skills, Targets, cost Effects, units, drones, and device Cards are outside version one.

## Enemy starting combination

`complete-mod` builds a two-turn Enemy from the following Core content:

| Configuration | Confirmed meaning | Use in the example |
| --- | --- | --- |
| `baseId=7366` | Core base data for “Self-Growing Core” | Supplies base values, appearance, and some UI information |
| Card `21007` | “Self Repair” | Turn-one action with presentation reference `buff_1` |
| Card `21006` | “Probe Burst” | Turn-two action with presentation reference `attack_1` |
| `assetId="buff_1"` | Existing action presentation reference | Confirmed only with example Card `21007` |
| `assetId="attack_1"` | Existing action presentation reference | Confirmed only with example Card `21006` |

A similar Card name does not establish that the Card is suitable for Enemy use. After replacing an action Card, target selection, effect settlement, and turn progression still require separate battle checks.

## Node entry point and existing references

### Regular layer-one battle Group: `1401`

See the [EP 1061 Node Group catalog](node-groups.md) for all 44 Groups used by EP `1061`, their naming patterns, map positions, and current purposes. Regular layer-one battle positions use this chain:

```text
EP 1061 map positions 230021, 230022, 230031, and 230032
  -> refreshGroup 1401
  -> Core layer-one battle candidate pool
```

A custom battle Node can use `append` on `1401` to retain Core candidates. A temporarily higher `weight` can make the target Node easier to encounter during human testing. Weighted selection is not an absolute guarantee, and a test weight should not become the balance value for distributed content.

The following general rules apply to Group configuration:

| Configuration | Rule |
| --- | --- |
| Omitted `operation` or `operation="replace"` | Replaces all Core rows in the group; using it on a regular route Group removes the group's existing content |
| `operation="append"` | Retains Core rows and adds MOD rows; weighted selection does not guarantee the target Node |
| `weight` | Relative selection weight among candidates in the same group; it does not control probability when only one candidate exists |
| `limitBaseId={}` | Adds no unit restriction; retain an empty table in the version-one example |
| `nodeLimit=1` | Limits normal repetition of the same Node; runtime fallback can apply when all candidates reach their limits, so this is not an absolute no-repeat guarantee |

`1401` is an existing Core Group, not a reserved MOD range. Other Groups in the catalog may also serve as map entry points, but one Group can be reused by multiple positions or layers. Every use location must be checked before modification. Version one does not require creation of new Groups.

### Core references used by the Node row

| Configuration | Confirmed meaning | Current boundary |
| --- | --- | --- |
| `battleReward={100001}` | References reward group `100001` from `act_node_def.node_reward` | That group then references `reward_def`; this is not a direct reference to `reward_def 100001` |
| Option `10051` | “Start Battle” | Used as the only candidate in `optionRandom1` |
| `gridPoolList={200}` | Core battle Grid Pool `200` | Confirmed as an example value only; arbitrary Grid Pools are not promised |
| `conditionGroup=99` | Core unconditional placeholder condition group | Confirmed as an example value only; custom condition authoring is not covered |
| `skybox="Nebula_Coral_4K_3"` | Existing Core battle background reference | Confirmed as an example value only; a complete Skybox catalog is not provided |

## Finding more Core configuration

Once the same-version [`game-lua`](../../../game-lua/README.en.md) archive is available, complete Core rows can be found by configuration filename and ID. An unlisted value must meet all of the following requirements before use:

1. the referenced object exists in the same game version;
2. every upstream and downstream reference changes together;
3. the content does not depend on unpublished custom Skills, Targets, models, animation, audio, or map structures;
4. cold start, actual content entry, behavior settlement, and disable-recovery tests all pass.

A successful configuration query or loading check does not establish completed in-game validation.
