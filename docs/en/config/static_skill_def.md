# `static_skill_def` Configuration Reference

> `static_skill_def` defines continuous abilities. While the source remains in a valid Area, the ability continuously changes battle Attr on Cards or Players.

## Basic Structure of `static_skill_def`

**Promotion Order** (Card `2016`) gives a friendly target unit +2/+2, then makes it attack once:

```lua
{
    id = 201651,
    name = "Promotion Order",
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

```text
Card 2016: Promotion Order
└─ Skill 201601
   ├─ Effect 1511: add Static Skill 201651 to the target
   │  └─ Static Skill 201651: target continuously gains +2/+2
   └─ Effect 1512: target attacks once
```

```text
Source is in srcArea={14}
└─ Read candidates from targetArea={14}
   └─ flag.self=1 keeps only the source
      └─ Apply effect: attkAdd=2, hpAddDrone=2
```

### Required Fields

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | int | Unique Static Skill ID |
| `name` | string | Name |
| `srcArea` | list[int] | Areas where the source enables the ability |
| `targetArea` | list[int] | Areas searched for candidate targets |
| `effect` | table | Attr continuously applied to targets |

### Optional Fields and Defaults

| Field | Default | Meaning |
| --- | --- | --- |
| `desc` | `""` | No separate ability description |
| `flag` | `{}` | No source relation, camp, position, or removal rule |
| `conditionList` | `{}` | No candidate Condition |
| `conditionListSelf` | `{}` | No source Condition |
| `visibility` | `0` | Do not display a separate ability description |
| `keywordList` | `{}` | No keywords |
| `disable` | `1` | Stop when the source is silenced |
| `showEffects` | `{}` | No continuous visual effect |

`flag={}` does not mean self-only. Use `flag={self=1}` when only the source should be affected.

## How a Static Skill Enters Battle

### Carried by a Card through `staticList`

Card `7000` carries Static Skill `700051` and retains it after transformation:

```lua
staticList = { 700051 },
```

The ability is active while the Card remains in one of its `srcArea` values.

### Added or Removed by an Effect

`event=60` adds a Static Skill; `value` is its ID:

```lua
event = 60,
targetId = 613,
value = 201651,
```

`event=61` removes a Static Skill:

```lua
event = 61,
targetId = 100,
value = 1034051,
```

See [`battle_effect_def`](battle_effect_def.md).

## How a Static Skill Selects Targets and Applies

```text
srcArea: is the source in an active Area?
└─ conditionListSelf: does the source pass its Conditions?
   └─ targetArea: collect candidates
      └─ flag: filter by relation, camp, and position
         └─ conditionList: check each candidate
            └─ effect: apply Attr to passing targets
```

When the source leaves every `srcArea`, fails `conditionListSelf`, or is disabled by another rule, Attr added by this Static Skill is removed from its targets.

### Source Areas: `srcArea`

```lua
srcArea = { 14 },
```

Area `14` is the battlefield unit Area. See [Battle Areas](../concepts/areas.md).

### Candidate Areas: `targetArea`

```lua
targetArea = { 2, 6 },
```

This collects candidates from Hand and Stack. `flag` and `conditionList` still filter them.

### Source Only: `flag.self=1`

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = { self = 1 },
conditionList = { 0 },
conditionListSelf = {},
```

`self=1` keeps only the source. `self=0` excludes it. Omitting `self` adds no source-identity filter.

### Filter Targets with `conditionList`

Chip `4011` gives wingmen +2/+2:

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = {},
conditionList = { 61 },
conditionListSelf = {},
```

Condition `61` checks each candidate and keeps only wingmen. A failing candidate is removed without disabling the ability for other candidates. See [`battle_condition_def`](battle_condition_def.md).

### Enable the Whole Ability with `conditionListSelf`

Card `2354` gains +3/+0 while its circuit count is at least 3:

```lua
srcArea = { 14 },
targetArea = { 14 },
flag = { self = 1 },
conditionList = { 0 },
conditionListSelf = { 2025 },
```

`conditionListSelf` checks the source and enables or disables the whole ability. `conditionList` checks each candidate separately.

### Filter by Battlefield Position: `flag.gridCheck`

Card `2450` gives adjacent drones +2/+0 but excludes itself:

```lua
flag = {
    self = 0,
    gridCheck = {
        side = 1,
    },
},
```

`gridCheck.side=1` keeps adjacent positions.

### Camp and Player: `targetCamp`, `selfPlayer`

`targetCamp` changes the candidate camp relative to the source:

| Value | Result |
| --- | --- |
| omitted | Source Player |
| `0` | All Players in the source camp |
| `1` | Enemy camp |

**Project: Veteran** (Chip `5100`) affects enemy normal drones:

```lua
flag = { targetCamp = 1 },
```

After expanding to several Players in one camp, `selfPlayer=1` keeps the source Player while `selfPlayer=0` keeps other Players in the same camp.

### Combining Several Conditions

`flag.conditionType` controls `conditionList`; `flag.conditionTypeSelf` controls `conditionListSelf`:

| Value | Combination |
| --- | --- |
| `1` or omitted | AND: every Condition passes |
| `2` | OR: any Condition passes |

Use `{}` for no Conditions. Existing `{0}` also means no Condition, but new content does not need the placeholder ID.

## `effect`: Continuous Attr

`effect` maps Attr names to values; it is not a list of Effect IDs.

```lua
effect = {
    attkAdd = 2,
    hpAddDrone = 2,
},
```

One Static Skill may apply several case-sensitive Attr names. When the source or target becomes invalid, those Attr values are removed. See [Effect Attributes](../concepts/attrs.md).

## `miscFunc`: Dynamic Attr Values

Use a fixed value such as `effect={attkAdd=2}` when possible. For values calculated from battle state, use `effect.miscFunc`:

```text
final Attr value = A + B × source value
```

| Field | Meaning |
| --- | --- |
| `valueType` | How to obtain the source value |
| `effectKey` | Attr that receives the result; defaults to `damageAdd` |
| `A` | Fixed addition; defaults to `0` |
| `B` | Source multiplier; defaults to `1` |

### `valueType="targetCount"`: Count a Target

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

This subtracts one Attack for each current target found by Target `110`.

### `valueType="cardFieldValue"`: Read a Card Field

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

This reads the target Card's `configHp` and writes the result to `hpAddDrone`.

## Static Skill Lifecycle

### Automatic Removal with `flag.removeTrigger`

`removeTrigger` removes a dynamically added Static Skill after a Trigger occurs a specified number of times:

| Field | Meaning |
| --- | --- |
| `trigger` | Trigger ID to listen to |
| `count` | Remove after this many occurrences; omitted means the first |
| `triggerEx` | Optional Trigger filter |

Card `2010` adds Delay until cleanup:

```lua
effect = { attkDelay = 1 },
flag = {
    removeTrigger = {
        trigger = 7,
        triggerEx = {},
        count = 1,
    },
},
```

Trigger `7` is the cleanup step. See [Trigger Reference](../concepts/triggers.md).

### Retain After Transformation: `flag.reserve`

`reserve=1` keeps the Static Skill when the source Card is replaced or transformed:

```lua
effect = { attkShield = 1 },
flag = { self = 1, reserve = 1 },
```

### Skip Duplicate Integration Processing: `flag.stackcard`

Existing configuration uses `stackcard=0`. When present, Card integration skips this Static Skill to avoid applying it twice.

```lua
flag = { self = 1, stackcard = 0 },
```

### Silencing the Source: `disable`

`disable` is a top-level field, not `effect.disable`:

| Value | Result |
| --- | --- |
| `1` | Stop while the source is silenced; default |
| `0` | Continue while the source is silenced |

## In-Game Display

Display fields do not change targets or Attr resolution.

### Description: `desc`, `visibility`

`desc` is player-facing text. `visibility=0` hides a separate ability entry; a positive value displays it in relevant battle details.

```lua
desc = "Your wingmen gain +2/+2.",
visibility = 6,
```

### Keywords: `keywordList`

```lua
keywordList = {
    { keywordId = 1004 },
},
```

Omit the field when no extra keyword is needed.

### Continuous Visual Effects: `showEffects`

| Effect name | Existing use |
| --- | --- |
| `mecha_common_uav_buffhold_01` | Continuous unit buff |
| `mecha_common_uav_buffhold_02` | Continuous Card, Power, or tactical buff |
| `mecha_common_uav_debuffhold_01` | Continuous unit debuff |
| `mecha_common_uav_debuffhold_02` | Alternate debuff presentation |

```lua
showEffects = {
    "mecha_common_uav_buffhold_01",
},
```

Omit `showEffects` for a numeric-only ability. Reuse only effect names shipped with the game.

## Legacy Design

- `effect.attkBack`
- `effect.relive`
- `effect.miscFunc.valueType="tokenCount"`
- `flag.active`
- `flag.targetSelection`

## Adding `static_skill_def` in a MOD

Place the file at:

```text
config/static_skill_def/config/statics.lua
```

Use `installKey="id"`. This example gives its source +2/+2 while in play:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990901,
            name = "Reinforced Armor",
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

A Card may carry it:

```lua
staticList = { 990901 },
```

An Effect may add it:

```lua
event = 60,
targetId = 613,
value = 990901,
```
