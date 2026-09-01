# `battle_target_def` Configuration Reference

> `battle_target_def` defines one target selection: choose candidate camps and Areas, apply flags and Conditions, then determine result count.

## Basic Structure of `battle_target_def`

**Continuous Shot α** (Card `2061`) selects one enemy unit and deals 2 damage:

```lua
{
    id = 40,
    actor = 1,
    target = 2,
    area = { 14 },
    flag = {},
    conditionList = { 0 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

```text
target=2: search the enemy camp
└─ area={14}: battlefield units only
   └─ flag={}, conditionList={0}: no extra filter
      └─ minValue=1, maxValue=1: select 1 target
```

```text
Continuous Shot α (Card 2061)
├─ targetIds={40}: select Target 40 when playing the Card
└─ Skill 206101
   └─ Effect 8026
      └─ targetId=40: damage the unit selected by Target 40
```

`card_def.targetIds` collects targets during Card use and saves each result with its Target ID. `battle_effect_def.targetId` selects which saved result an Effect reads.

When the Card and Effect reference the same Target ID, the Effect reuses the saved selection and does not ask the player again. If no saved result exists, the Effect calculates the Target separately; it asks the player only when automatic selection is impossible.

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | int | Unique Target ID |
| `actor` | int | Initiator; current entries use `1` |
| `target` | int | Candidate camp |
| `area` | int[] | Candidate Areas |
| `flag` | table | Selection and filtering rules |
| `conditionList` | int[] | Condition IDs applied to candidates |
| `conditionType` | int | Combination rule for `conditionList` |
| `minValue` | int | Minimum result count |
| `maxValue` | int | Maximum result count |

Target IDs are referenced by `card_def.config.targetIds`, `battle_skill_def.config.targetIds`, and `battle_effect_def.config.targetId`. Card and Skill use lists; Effect uses one ID.

## Building the Candidate Set

### `target`: Candidate Camp

`target` uses the camp of the source Card or Skill as its reference:

| Value | Camp |
| --- | --- |
| `1` | Friendly |
| `2` | Enemy |
| `3` | Both |

Target `104` selects one friendly battlefield unit:

```lua
{ id=104, target=1, area={14}, flag={}, conditionList={0}, conditionType=1, minValue=1, maxValue=1 }
```

Target `40` selects one enemy battlefield unit:

```lua
{ id=40, target=2, area={14}, flag={}, conditionList={0}, conditionType=1, minValue=1, maxValue=1 }
```

Target `629` selects all battlefield units from both camps:

```lua
{ id=629, target=3, area={14}, flag={}, conditionList={0}, conditionType=1, minValue=-1, maxValue=-1 }
```

`target=3` only expands the candidate camps. `flag.self` and other rules still decide whether the source itself remains.

### `area`: Candidate Areas

`area` is a list of Area IDs. See [Battle Areas](../concepts/areas.md).

Target `40` searches only Area `14`, the battlefield unit Area:

```lua
{ id=40, target=2, area={14}, minValue=1, maxValue=1 }
```

Target `114` combines Player and battlefield unit Areas and returns every friendly candidate:

```lua
{ id=114, target=1, area={8,14}, flag={}, conditionList={0}, conditionType=1, minValue=1, maxValue=-1 }
```

`area` decides where to search. Identity, position, and count are handled by later fields.

## `flag`: Selection and Filtering Rules

Read a flag together with `target`, `area`, Conditions, and count fields.

[`self`](#self) · [`selfPlayer`](#selfplayer) · [`hero`](#hero) · [`selfRound`](#selfround) · [`side`](#side) · [`colNext`](#colnext) · [`sameRow`](#samerow) · [`colTarget`](#coltarget) · [`rowOne`](#rowone) · [`colOne`](#colone) · [`seq`](#seq) · [`randNum`](#randnum) · [`sort`](#sort) · [`sortType`](#sorttype) · [`attkTarget`](#attktarget)

### `self`

`self=1` keeps only the source itself. Target `103` selects the source unit:

```lua
{ id=103, target=1, area={14}, flag={self=1}, conditionList={0}, minValue=1, maxValue=1 }
```

`self=0` removes the source. Target `134` keeps every other battlefield unit from both camps:

```lua
{ id=134, target=3, area={14}, flag={self=0}, conditionList={0}, minValue=0, maxValue=-1 }
```

### `selfPlayer`

`selfPlayer=1` selects the Player belonging to the source camp, normally with `target=1, area={8}`:

```lua
{ id=100, target=1, area={8}, flag={selfPlayer=1}, conditionList={0}, minValue=1, maxValue=1 }
```

### `hero`

`hero=1` keeps only units carrying a pilot:

```lua
{ id=1225, target=1, area={14}, flag={hero=1}, conditionList={0}, minValue=0, maxValue=-1 }
```

### `selfRound`

`selfRound=1` keeps units currently in their own round. Target `940` also uses Condition `2016` to keep normal drones:

```lua
{ id=940, target=3, area={14}, flag={selfRound=1}, conditionList={2016}, conditionType=1, minValue=-1, maxValue=-1 }
```

### `side`

`side=1` keeps units horizontally or vertically adjacent to the source:

```lua
{ id=123, target=1, area={14}, flag={side=1}, conditionList={0}, minValue=0, maxValue=-1 }
```

### `colNext`

`colNext=1` keeps units behind the source in the same column:

```lua
{ id=127, target=1, area={14}, flag={colNext=1}, conditionList={0}, minValue=0, maxValue=1 }
```

### `sameRow`

`sameRow=1` keeps candidates in the same row as the source:

```lua
{ id=405, target=1, area={14}, flag={sameRow=1}, conditionList={0}, minValue=-1, maxValue=-1 }
```

### `colTarget`

`colTarget=1` keeps opposing units in the source column:

```lua
{ id=113, target=2, area={14}, flag={colTarget=1}, conditionList={0}, minValue=-1, maxValue=-1 }
```

### `rowOne`

`rowOne=1` requires all results in a multi-select to come from one row. Target `102` selects up to 3 enemy units in one row:

```lua
{ id=102, target=2, area={14}, flag={rowOne=1}, conditionList={0}, minValue=1, maxValue=3 }
```

### `colOne`

`colOne=1` requires all results in a multi-select to come from one column:

```lua
{ id=503, target=2, area={14}, flag={colOne=1}, conditionList={0}, minValue=1, maxValue=3 }
```

### `seq`

`seq=1` takes candidates in the Area's existing order. Target `24` selects the first Card in the enemy Queue:

```lua
{ id=24, target=2, area={15}, flag={seq=1}, conditionList={0}, minValue=1, maxValue=1 }
```

### `randNum`

`randNum` is the number randomly taken from candidates and must be read with `minValue` and `maxValue`.

```lua
-- Randomly select 1 enemy battlefield unit
{ id=525, target=2, area={14}, flag={randNum=1}, conditionList={0}, minValue=1, maxValue=1 }

-- Randomly select up to 3 enemy battlefield units
{ id=1211, target=2, area={14}, flag={randNum=3}, conditionList={0}, minValue=-1, maxValue=3 }
```

### `sort`

`sort` orders candidates before count fields take the result:

| Value | Order |
| --- | --- |
| `minHp` | Lowest current HP first |
| `maxAttk` | Highest Attack first |
| `minAttk` | Lowest Attack first |
| `maxCost` | Highest Cost first |

```lua
-- Two enemy units with the lowest HP
{ id=304, target=2, area={14}, flag={sort="minHp"}, conditionList={0}, minValue=2, maxValue=2 }

-- One enemy unit with the highest Attack
{ id=775, target=2, area={14}, flag={sort="maxAttk"}, conditionList={0}, minValue=1, maxValue=1 }

-- One valid enemy unit with the lowest Attack
{ id=879, target=2, area={14}, flag={sort="minAttk"}, conditionList={2016}, conditionType=1, minValue=1, maxValue=1 }

-- One Scrap Area Card with the highest Cost
{ id=928, target=2, area={4}, flag={sort="maxCost"}, conditionList={0}, minValue=1, maxValue=1 }
```

### `sortType`

`sortType` extends `sort` and cannot be used alone.

`sortType="random"` randomly selects among candidates tied at the sorted value. `sortType="normal"` keeps normal order.

```lua
{
    id = 827,
    target = 2,
    area = { 14 },
    flag = { sort = "minHp", sortType = "random" },
    conditionList = { 2016 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

### `attkTarget`

`attkTarget` reuses existing attack selection shapes. Read it with the source, camp, and count fields:

| Value | Shape | Example Target |
| --- | --- | --- |
| `1` | Front unit in the same column first | `30` |
| `2` | Enemy fan | `117` |
| `3` | Middle lane | `106` |
| `4` | Three lanes | `138` |
| `5` | Back row behind a target | `31` |

```lua
-- Default attack target
{ id=30, target=2, area={14}, flag={attkTarget=1}, conditionList={0}, minValue=1, maxValue=1 }

-- All enemies in the fan
{ id=117, target=2, area={14}, flag={attkTarget=2}, conditionList={0}, minValue=0, maxValue=-1 }

-- All enemies in the middle lane
{ id=106, target=2, area={14}, flag={attkTarget=3}, conditionList={0}, minValue=0, maxValue=-1 }

-- Up to three enemies across three lanes
{ id=138, target=2, area={14}, flag={attkTarget=4}, conditionList={0}, minValue=1, maxValue=3 }

-- Back row behind the target
{ id=31, target=2, area={14}, flag={attkTarget=5}, conditionList={0}, minValue=1, maxValue=1 }
```

## `conditionList`: Filter Candidates Further

`conditionList` contains `battle_condition_def.config.id` values. The Target first builds candidates with `target`, `area`, and `flag`, then applies Conditions.

`conditionList={0}` adds no Condition. Existing configuration uses `conditionType=1`, which keeps a candidate only when every listed Condition passes.

Target `667` uses Conditions `2074` and `2016` to select one unit with Attack no greater than 3:

```lua
{
    id = 667,
    target = 3,
    area = { 14 },
    flag = {},
    conditionList = { 2074, 2016 },
    conditionType = 1,
    minValue = 1,
    maxValue = 1,
}
```

See [`battle_condition_def`](battle_condition_def.md).

## `minValue` and `maxValue`: Result Count

After filtering, sorting, or random selection, these fields limit the number of returned objects. Read negative values together with the complete selection rule.

| Use | Target | Key configuration | Result |
| --- | --- | --- | --- |
| Select 1 | `40` | `minValue=1`, `maxValue=1` | One enemy battlefield unit |
| Exactly 2 | `304` | `sort="minHp"`, both values `2` | Two enemy units with the lowest HP |
| All candidates | `113` | `colTarget=1`, both values `-1` | Every enemy in the source column |
| Randomly up to 3 | `1211` | `randNum=3`, `minValue=-1`, `maxValue=3` | Up to three enemy units |

With `sort`, candidates are ordered first and count fields take the result. Target `304` sorts by current HP and takes the first two.

## Adding `battle_target_def` in a MOD

Create:

```text
config/battle_target_def/config/targets.lua
```

Use `installKey="id"` and provide a complete Target row:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 900001,
            actor = 1,
            target = 2,
            area = { 14 },
            flag = {},
            conditionList = { 0 },
            conditionType = 1,
            minValue = 1,
            maxValue = 1,
        },
    },
}
```

Reference `900001` from the same MOD:

```text
card_def.config.targetIds         → { 900001 }
battle_skill_def.config.targetIds → { 900001 }
battle_effect_def.config.targetId → 900001
```
