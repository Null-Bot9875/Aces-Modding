# `battle_condition_def` Configuration Reference

> `battle_condition_def` performs one battle check: select a side or supplied target, calculate a value, and test it against an allowed range.

## Basic Structure of `battle_condition_def`

Card `21070` grants +2/+2 only to a unit carrying at least one pilot:

```text
Card 21070
└─ staticList={2107052}
   ├─ conditionList={2310}: target unit carries at least 1 pilot
   └─ effect: +2/+2
```

Condition `2310`:

```lua
{
    id = 2310,
    target = 1,
    type = 11,
    minValue = 1,
    maxValue = -1,
    args = {
        valueKey = "heroCount",
    },
}
```

Read a Condition in four parts:

```text
Which side: target=1, use the checking side
What to check: type=11, read a Value
Allowed range: minValue=1, maxValue=-1, at least 1
How to calculate: args.valueKey="heroCount", count pilots on the target unit
```

| Field | Type | Rule |
| --- | --- | --- |
| `id` | int | Required unique Condition ID |
| `target` | int | Required; `1` checking side, `2` opposing side |
| `type` | int | Required; selects the object and calculation |
| `minValue` | int | Required; meaning depends on `type` |
| `maxValue` | int | Required; meaning depends on `type` |
| `args` | lua | Required parameters for the selected `type`; use `{}` when none |

`target` selects the side used for Player, unit, or battlefield data. It does not supply a battle Card UID or Stack ID. Types that inspect a Card or Stack still require the referencing system to provide one.

Whether `minValue`, `maxValue`, and `-1` are used depends on the selected `type`.

## How `battle_condition_def` Is Used

| Table | Reference field |
| --- | --- |
| [`card_def`](card_def.md) | `useConditions` |
| [`robot_chain_def`](robot_chain_def.md) | `actions[].useConditions` |
| [`battle_target_def`](battle_target_def.md) | `conditionList` |
| [`static_skill_def`](static_skill_def.md) | `conditionListSelf`, `conditionList` |

## Available `type` Values

| `type` | Name | Check |
| --- | --- | --- |
| [`1`](#type-1-hp) | `Hp` | HP of a target Card or base |
| [`2`](#type-2-power) | `Power` | Current Power of one side |
| [`5`](#type-5-handcard) | `HandCard` | Whether a supplied Card passes filters |
| [`8`](#type-8-stack) | `Stack` | Whether a supplied Stack passes filters |
| [`11`](#type-11-value) | `Value` | Battle value selected by `args.valueKey` |

### Type 1 Hp

Checks the current HP of a supplied Card. If no valid Card is supplied, it checks the base selected by `target`. Use `args.base=1` to explicitly require the base.

`minValue` and `maxValue` are inclusive. A negative bound is unrestricted; published configuration uses `-1`.

#### Current HP of a Target Card

Condition `1016`: target Card HP is between 1 and 5.

```lua
id = 1016,
target = 1,
type = 1,
minValue = 1,
maxValue = 5,
args = {},
```

This requires a battle Card UID from the reference site. Without one, the check falls back to the friendly base.

#### Base HP: `base`

Condition `2166`: friendly base HP is between 1 and 50.

```lua
id = 2166,
target = 1,
type = 1,
minValue = 1,
maxValue = 50,
args = { base = 1 },
```

`base` is checked by presence. Omit it when unused; do not use `base=0` to disable it.

#### Lost HP: `hpDiff`

Condition `2116`: the opposing base has lost no HP.

```lua
id = 2116,
target = 2,
type = 1,
minValue = -1,
maxValue = 0,
args = { hpDiff = 1 },
```

`hpDiff` changes the checked value to `hpMax-hp`. `0` means full HP.

### Type 2 Power

Checks current Power for the side selected by `target`. It needs no Card or Stack. Bounds are inclusive; published configuration uses `-1` for an unrestricted side.

Condition `2134`: friendly side has at least 1 Power.

```lua
id = 2134,
target = 1,
type = 2,
minValue = 1,
maxValue = -1,
args = {},
```

### Type 5 HandCard

Checks a supplied Card against filters in `args`. Despite the name, it does not verify that the Card is in hand. The reference site must supply a valid battle Card UID.

This type does not read `minValue` or `maxValue`, but complete rows still provide them.

| Argument | Example | Meaning |
| --- | --- | --- |
| `cardTag` | `cardTag={{4}}` | Match Tag combinations |
| `cardId` | `cardId={9201}` | Match any listed `card_def.cardId` |
| `noTag` | `noTag={502}` | Fail when the Card has any listed Tag |

#### Filter by Tag: `cardTag`

Condition `501` requires Tag `4`:

```lua
id = 501,
target = 1,
type = 5,
minValue = 0,
maxValue = -1,
args = { cardTag = { { 4 } } },
```

The outer list is OR and each inner list is AND. `{{6},{7}}` means Tag `6` or Tag `7`; `{{6,7}}` requires both.

#### Filter by Card ID: `cardId`

```lua
id = 2001,
target = 1,
type = 5,
minValue = 1,
maxValue = -1,
args = { cardId = { 9201 } },
```

This is the definition ID `card_def.cardId`, not the battle Card UID supplied by the reference site.

#### Exclude Tags: `noTag`

```lua
id = 603,
target = 1,
type = 5,
minValue = 1,
maxValue = -1,
args = { noTag = { 502 } },
```

When several filters are present, all must pass.

### Type 8 Stack

Checks a supplied Stack ID. A battle Card UID cannot replace it. Published examples use `target=1` and provide unused bounds `0` and `1`.

| `args.stack` value | Stack type |
| --- | --- |
| `1` | Command |
| `2` | Equipment |
| `3` | Activation |
| `4` | Attack |
| `5` | Passive trigger |
| `6` | Drone |
| `8` | Item |
| `9` | Pilot |

Condition `2089` requires a Command Stack:

```lua
id = 2089,
target = 1,
type = 8,
minValue = 0,
maxValue = 1,
args = { stack = { 1 } },
```

### Type 11 Value

`args.valueKey` selects a value, then inclusive `minValue` and `maxValue` check it. Only `-1` means unrestricted; other negative numbers remain real bounds.

| `valueKey` | Value | Target requirement |
| --- | --- | --- |
| [`roundRecord`](#valuekey-roundrecord) | Cards played by one player this round | none |
| [`cardCount`](#valuekey-cardcount) | Filtered Cards in specified Areas | none |
| [`droneCount`](#valuekey-dronecount) | Filtered Cards on one player's battlefield | `gridCheck` needs a target Card |
| [`attk`](#valuekey-attk) | Current Attack of target Card | target Card |
| [`hp`](#valuekey-hp) | Current HP of target Card | target Card |
| [`cost`](#valuekey-cost) | Current cost of target Card | target Card |
| [`dirCount`](#valuekey-dircount) | Circuits pointing to target Card | target Card |
| [`gold`](#valuekey-gold) | Current battle Gold of one player | none |
| [`heroCount`](#valuekey-herocount) | Pilots carried by target unit | target Card |
| [Card Attr name](#valuekey-card-attr) | Sum of matching Attr values | target Card |

#### valueKey roundRecord

Counts Cards actually played this round by the player selected with `target`.

```lua
id = 2090,
target = 2,
type = 11,
minValue = 2,
maxValue = -1,
args = { valueKey = "roundRecord" },
```

Add `cardTag` to count only matching played Cards:

```lua
args = {
    valueKey = "roundRecord",
    cardTag = { { 4 } },
},
```

#### valueKey cardCount

Counts filtered Cards in required `args.area`. See [Battle Areas](../concepts/areas.md).

Condition `2019`: friendly deck is empty.

```lua
id = 2019,
target = 1,
type = 11,
minValue = 0,
maxValue = 0,
args = {
    valueKey = "cardCount",
    area = { 1 },
},
```

Use `cardTag` or `cardId` for additional filters:

```lua
args = {
    valueKey = "cardCount",
    area = { 2 },
    cardTag = { { 430 } },
},
```

#### valueKey droneCount

Counts filtered Cards on the selected player's battlefield Grids. The name does not automatically limit results to drones; use `cardId`, `cardTag`, or `noTag`.

```lua
id = 2000,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = {
    valueKey = "droneCount",
    cardId = { 9201 },
},
```

#### Filter by Target Grid: `gridCheck`

`gridCheck` filters counted battlefield Cards relative to the supplied target Card's Grid. It requires a valid battle Card UID.

Condition `2243`: no enemy unit is in the target Card's column.

```lua
id = 2243,
target = 2,
type = 11,
minValue = 0,
maxValue = 0,
args = {
    valueKey = "droneCount",
    gridCheck = { colTarget = 1 },
},
```

#### valueKey attk

Current Attack of a supplied target Card:

```lua
id = 505,
target = 1,
type = 11,
minValue = 7,
maxValue = -1,
args = { valueKey = "attk" },
```

#### valueKey hp

Current HP of a supplied target Card:

```lua
id = 2107,
target = 1,
type = 11,
minValue = 0,
maxValue = 1,
args = { valueKey = "hp" },
```

#### valueKey cost

Current cost of a supplied target Card:

```lua
id = 2185,
target = 1,
type = 11,
minValue = 1,
maxValue = 1,
args = { valueKey = "cost" },
```

#### valueKey dirCount

Counts friendly circuits pointing to the supplied target Card:

```lua
id = 2024,
target = 1,
type = 11,
minValue = 2,
maxValue = -1,
args = { valueKey = "dirCount" },
```

#### valueKey gold

Current battle Gold of the player selected by `target`:

```lua
id = 2285,
target = 1,
type = 11,
minValue = 200,
maxValue = -1,
args = { valueKey = "gold" },
```

#### valueKey heroCount

Number of pilots carried by the supplied target unit:

```lua
id = 2310,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = { valueKey = "heroCount" },
```

#### valueKey Card Attr

If `valueKey` is not a fixed name above, it is treated as a Card Attr name and the matching Attr values on the target Card are summed.

```lua
id = 2012,
target = 1,
type = 11,
minValue = 1,
maxValue = -1,
args = { valueKey = "attkShield" },
```

Common names include `attkShield`, `attkTwice`, and `attkDelay`. See [Effect Attributes](../concepts/attrs.md).

## Legacy Design

Do not use these in new MODs:

| Configuration | Name |
| --- | --- |
| `type=9` | `Token` |
| `type=13` | `Gauge` |
| `Stack type=7` | `Trap` |

## Adding `battle_condition_def` in a MOD

Place the file at:

```text
config/battle_condition_def/config/conditions.lua
```

Use `installKey="id"`:

```lua
return {
    installKey = "id",
    rows = {
        -- Friendly side currently has at least 2 Power
        {
            id = 990501,
            target = 1,
            type = 2,
            minValue = 2,
            maxValue = -1,
            args = {},
        },
    },
}
```

Reference Condition `990501` from fields such as `card_def.useConditions`.
