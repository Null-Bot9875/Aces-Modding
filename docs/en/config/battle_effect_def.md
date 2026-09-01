# `battle_effect_def` Configuration Reference

> `battle_effect_def` defines one battle Effect: select targets, execute an `event`, calculate its value, and choose client presentation.

## Basic Structure of `battle_effect_def`

**Continuous Shot α** (Card `2061`) deals 2 damage to one enemy unit and plays the `multi_attack_3` attack presentation:

```lua
{
    effectId = 8026,
    desc = "Deal 2 damage to any enemy",
    targetId = 40,
    event = 1000,
    value = 2,
    extend = {},
    playResultType = 1,
    customResultType = "multi_attack_3",
    dontUseCardTimeline = true,
    markTarget = "",
}
```

Five fields define resolution:

- `effectId`: unique Effect ID referenced by Cards, Skills, and other Effects.
- `targetId`: objects processed by this Effect; see [`battle_target_def`](battle_target_def.md).
- `event`: behavior to execute.
- `value`: main numeric value, interpreted by the selected `event`.
- `extend`: additional parameters used by that `event`; omit when unused.

`desc` is an author note, not player-facing text. `playResultType`, `customResultType`, `dontUseCardTimeline`, and `markTarget` affect presentation only; see [In-Game Effect Presentation](#in-game-effect-presentation).

## Available `event` Values

[`11 NewCard`](#event-11-newcard) · [`17 CardArea`](#event-17-cardarea) · [`21 CreateCard`](#event-21-createcard) · [`23 CreateDrone`](#event-23-createdrone) · [`24 CreateItem`](#event-24-createitem) · [`25 ReplaceDrone`](#event-25-replacedrone) · [`27 DestroyDrone`](#event-27-destroydrone) · [`30 Counteract`](#event-30-counteract) · [`60 StaticAdd`](#event-60-staticadd) · [`61 StaticRemove`](#event-61-staticremove) · [`100 Power`](#event-100-power) · [`102 PowerMax`](#event-102-powermax) · [`103 Hp`](#event-103-hp) · [`105 HpSet`](#event-105-hpset) · [`106 AttkAdd`](#event-106-attkadd) · [`107 PowerTmp`](#event-107-powertmp) · [`108 AIChainRemove`](#event-108-aichainremove) · [`109 ActorFinish`](#event-109-actorfinish) · [`110 AttrRemove`](#event-110-attrremove) · [`112 HpMaxSet`](#event-112-hpmaxset) · [`113 AttkSet`](#event-113-attkset) · [`120 SkillTrigger`](#event-120-skilltrigger) · [`200 Value`](#event-200-value) · [`201 Reward`](#event-201-reward) · [`202 Gold`](#event-202-gold) · [`400 Attk`](#event-400-attk) · [`1000 Damage`](#event-1000-damage) · [`1002 DamageBreak`](#event-1002-damagebreak)

### Event 11 NewCard

Draw Cards for a target Player. `value` is the draw count.

**Logistics Drone** (Card `2023`): draw 1 Card when deployed.

```lua
event = 11,
targetId = 100,
value = 1,
```

Use [`extend.valueType`](#extendvaluetype) for a dynamic count.

### Event 17 CardArea

Move Cards selected by `targetId` to Area `value`. See [Battle Areas](../concepts/areas.md).

Card `2006`: move a friendly target drone to Scrap.

```lua
event = 17,
targetId = 613,
value = 4,
```

#### Return to the Previous Grid: `lastPos`

```lua
event = 17,
targetId = 104,
value = 14,
extend = {
    lastPos = 1,
},
```

`lastPos=1` restores the recorded Grid only when returning to the Drone Area. Omitted or `0` does not read the old Grid.

#### Move to the Other Camp's Area: `moveTarget`

**White Hole** (Card `10788`) moves the highest-cost Card in the enemy Scrap Area to your Queue:

```lua
event = 17,
targetId = 928,
value = 15,
extend = {
    moveTarget = 1,
},
```

`moveTarget=1` uses the other camp's destination Area. Otherwise the Card moves to the matching Area owned by its own camp.

### Event 21 CreateCard

Create Cards for a target Player.

- `value`: amount to create.
- `extend.card`: fixed Card ID; required when neither `randomCards` nor the Target supplies a Card.
- `extend.randomCards`: choose a Card ID again for each created Card; overrides `card`.
- `extend.area`: destination Area; omitted creates into Hand.

**Module Prototype** creates one **Drone Prototype** in hand:

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    card = 2041,
},
```

#### Random Candidate List: `randomCards`

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    randomCards = { 2008, 2014, 2016, 2137, 2139, 2141, 2143, 2369 },
},
```

`randomCards` cannot be empty and overrides `card`.

#### Create into a Specific Area: `area`

```lua
event = 21,
targetId = 100,
value = 1,
extend = {
    card = 10786,
    area = 15,
},
```

### Event 23 CreateDrone

Create drone Cards on empty battlefield Grids selected by `targetId`.

- `extend.card`: fixed drone Card ID.
- `extend.randomCards`: choose a Card separately for each target Grid; overrides `card`.
- `extend.posCard`: map Grid position to Card ID; takes priority over both.

```lua
event = 23,
targetId = 518,
value = 1,
extend = {
    card = 2002,
},
```

Occupied or invalid Grids are skipped.

#### Random Card for Each Position: `randomCards`

```lua
event = 23,
targetId = 695,
value = 1,
extend = {
    randomCards = { 10050, 10497, 10184, 10045, 10394, 10502, 10180, 10506, 2204 },
},
```

#### Different Cards by Position: `posCard`

```lua
event = 23,
targetId = 612,
value = 1,
extend = {
    posCard = {
        [4] = 2414,
        [6] = 2415,
    },
},
```

A target Grid with no `posCard` entry creates nothing and does not fall back to `randomCards` or `card`.

### Event 24 CreateItem

Create one Battle Item for a target Player. `value` is the fixed item ID. `extend.randomCards` chooses one item ID and overrides `value`.

```lua
event = 24,
targetId = 100,
value = 1,
extend = {
    randomCards = {
        3001, 3002, 3003, 3004, 3005,
        3006, 3007, 3008, 3009, 3010,
        3011, 3012, 3013, 3014, 3015,
    },
},
```

The list cannot be empty and every ID must be a valid Battle Item.

### Event 25 ReplaceDrone

Replace target drones with another drone Card.

- `extend.card`: fixed replacement Card ID.
- `extend.switch`: current Card ID to replacement Card ID map; overrides `card`.
- `extend.force=1`: continue when an extra occupied position must be cleared; default `0` refuses.
- `extend.showTarget`: additional Target used by presentation only.

```lua
event = 25,
targetId = 510,
value = 1,
extend = {
    card = 21052,
    force = 1,
    showTarget = 542,
},
```

#### Switch by Current Card: `switch`

```lua
event = 25,
targetId = 870,
value = 1,
extend = {
    switch = {
        [10540] = 10541,
        [10541] = 10540,
    },
    force = 1,
},
```

A Card ID missing from `switch` is not replaced and does not fall back to `card`.

### Event 27 DestroyDrone

Destroy selected drones. `value` is conventionally `1` and does not set target count.

```lua
event = 27,
targetId = 613,
value = 1,
```

### Event 30 Counteract

Counteract the selected object. `value` is conventionally `1` and does not affect the counteraction.

```lua
event = 30,
targetId = 692,
value = 1,
```

### Event 60 StaticAdd

Add Static Skill `value` to each target.

- `extend.staticCount`: Target ID used to calculate repeated additions, not a direct count.
- `extend.A`, `extend.B`: additions equal `A + B × target count`; defaults `0` and `1`.
- `extend.round`: number of rounds before removal.

```lua
event = 60,
targetId = 510,
value = 200651,
```

#### Repeat by Target Count: `staticCount`

```lua
event = 60,
targetId = 103,
value = 710451,
extend = {
    staticCount = 512,
},
```

If Target `512` finds 3 units, the default formula adds Static Skill `710451` three times.

#### Limit Duration: `round`

```lua
event = 60,
targetId = 100,
value = 711751,
extend = {
    round = 1,
},
```

At the next round update, the count reaches `0` and the Static Skill is removed.

### Event 61 StaticRemove

Remove Static Skill `value` from each target:

```lua
event = 61,
targetId = 100,
value = 1034051,
```

### Event 100 Power

Change target Player Power. Positive adds; negative removes.

```lua
event = 100,
targetId = 100,
value = -1,
```

### Event 102 PowerMax

Change target Player maximum Power:

```lua
event = 102,
targetId = 100,
value = -2,
```

### Event 103 Hp

Restore or remove current HP from target Cards. Positive restores; negative removes.

```lua
event = 103,
targetId = 510,
value = 5,
```

### Event 105 HpSet

Set target Card current HP to `value`:

```lua
event = 105,
targetId = 103,
value = 8,
```

### Event 106 AttkAdd

Add or remove current Attack from target battlefield Cards. This example reads HP returned by earlier Effect `4516`:

```lua
event = 106,
targetId = 60,
value = 0,
extend = {
    valueType = "effectValue",
    effectId = 4516,
    key = "hp",
},
```

The source Effect must execute first.

### Event 107 PowerTmp

Change temporary Power for a target Player:

```lua
event = 107,
targetId = 100,
value = 1,
```

### Event 108 AIChainRemove

Remove actions from the beginning of the target Player's current action chain. If fewer actions remain, remove only those available.

```lua
event = 108,
targetId = 101,
value = 1,
```

### Event 109 ActorFinish

Automatically end the target Player's current priority:

```lua
event = 109,
targetId = 101,
value = 1,
```

Use this only in a resolution context that already has a current actor and priority.

### Event 110 AttrRemove

Remove Effect Attr `extend.attrTarget` from target Cards. See [Effect Attributes](../concepts/attrs.md).

```lua
event = 110,
targetId = 60,
value = 1,
extend = {
    attrTarget = "attkDelay",
},
```

### Event 112 HpMaxSet

Set target Card maximum HP directly:

```lua
event = 112,
targetId = 689,
value = 1,
```

### Event 113 AttkSet

Set current Attack directly; this is not an addition:

```lua
event = 113,
targetId = 683,
value = 1,
```

### Event 120 SkillTrigger

Trigger Skills on target Cards.

- `value` is not a Skill ID; existing entries use `1`.
- `extend.trigger` is an optional [Trigger ID](../concepts/triggers.md). When present, only Skills with that Trigger execute; omitted triggers all Skills on the target.

```lua
event = 120,
targetId = 835,
value = 1,
extend = {
    trigger = 123,
},
```

`trigger` is a Trigger ID, not a Skill ID.

### Event 200 Value

Calculate and record a value for later Effects in the same Skill.

```lua
event = 200,
targetId = 613,
value = 0,
extend = {
    valueType = "cardFieldValue",
    field = "attk",
    A = 0,
    B = 1,
},
```

A later Effect reads it through `valueType="effectValue"` and this `effectId`.

### Event 201 Reward

Record a victory Reward for a target Player. It is granted by the post-battle reward flow.

```lua
event = 201,
targetId = 100,
value = 4007,
```

`value` is an existing `reward_def` ID.

### Event 202 Gold

Change battle Gold for a target Player. A negative value cannot reduce it below `0`.

```lua
event = 202,
targetId = 100,
value = 10,
```

### Event 400 Attk

Make selected battlefield Cards attack. `value` is the attack count from `1` through `10`. Values above `10` are capped; nonpositive values do nothing.

```lua
event = 400,
targetId = 104,
value = 1,
```

### Event 1000 Damage

Deal normal damage to selected Cards or Players:

```lua
event = 1000,
targetId = 40,
value = 2,
```

### Event 1002 DamageBreak

Deal piercing damage:

```lua
event = 1002,
targetId = 106,
value = 7,
```

## `extend.valueType`

Supported Events may recalculate `value` before resolution:

```text
final value = A + B × source value
```

- `valueType`: source type.
- `A`: fixed addition, default `0`.
- `B`: source multiplier, default `1`.

Use only the types below with Events already known to support dynamic values. An unknown type makes the Effect fail.

### `valueType="cardFieldValue"`: Read Target Card Fields

Read one field from every Card selected by the Effect's `targetId`, sum the values, then apply the formula.

```lua
effectId = 4089,
event = 200,
targetId = 613,
value = 0,
extend = {
    valueType = "cardFieldValue",
    field = "attk",
    A = 0,
    B = 1,
},
```

Confirmed fields:

| `field` | Source value |
| --- | --- |
| `attk` | Current Attack |
| `hp` | Current HP |
| `cost` | Current cost |
| `chipValue` | Current Chip value |
| `hpDiff` | Maximum HP minus current HP |
| `configHp` | Initial HP from Card configuration |
| `configAttk` | Initial Attack from Card configuration |

Other names attempt to read a same-named battle property and use `0` when missing.

### `valueType="targetCount"`: Count Another Target

Count targets returned by `extend.targetId`, then apply the formula. This is separate from the Effect's top-level `targetId`.

```lua
event = 1000,
targetId = 109,
value = 0,
extend = {
    valueType = "targetCount",
    targetId = 754,
},
```

Top-level Target `109` receives damage; `extend.targetId=754` only provides the count.

### `valueType="effectValue"`: Read an Earlier Effect

Read a previously executed Effect from the same Skill without executing it again.

```lua
-- First: record target Attack
{
    effectId = 4089,
    event = 200,
    targetId = 613,
    value = 0,
    extend = {
        valueType = "cardFieldValue",
        field = "attk",
    },
}

-- Later: read Effect 4089
{
    effectId = 4090,
    event = 1000,
    targetId = 534,
    value = 1,
    extend = {
        valueType = "effectValue",
        effectId = 4089,
    },
}
```

Both Effects must be in the same Skill and the source must execute first. Optional `key` reads a named source field; a missing key reads as `0`.

### `valueType="effectValue_Count"`: Read an Earlier Count

Read `count` returned by an earlier Effect:

```lua
-- Move all Hand Cards to Desk and return count
{ effectId=4082, event=17, targetId=118, value=3 }

-- Draw the returned count
{
    effectId = 4083,
    event = 11,
    targetId = 100,
    value = 1,
    extend = {
        valueType = "effectValue_Count",
        effectId = 4082,
    },
}
```

Missing `count` reads as `0`.

### `valueType="effectValue_Cards"`: Count Earlier Cards

Count Cards returned by an earlier Effect, optionally keeping only Cards that pass `condition`:

```lua
-- Draw 4 and return the Card list
{ effectId=4108, event=11, targetId=100, value=4 }

-- Count Cards that pass Condition 2075
{
    effectId = 4109,
    event = 100,
    targetId = 100,
    value = 1,
    extend = {
        valueType = "effectValue_Cards",
        effectId = 4108,
        condition = { 2075 },
        A = 0,
        B = 1,
    },
}
```

Missing Card results count as `0`. See [`battle_condition_def`](battle_condition_def.md).

### `valueType="triggerData"`: Read Trigger Data

Read numeric field `triggerKey` from the current trigger request:

```lua
event = 103,
targetId = 510,
value = 1,
extend = {
    valueType = "triggerData",
    triggerKey = "powerCost",
    A = 0,
    B = -1,
},
```

The corresponding Trigger must actually provide that numeric field. Do not invent keys for a normal active Skill.

### Calculate per Damage Target: `targetValueType`

`Damage` and `DamageBreak` support `targetValueType="cardFieldValueWithTarget"`, calculating separately from each target's own field:

```lua
event = 1000,
targetId = 940,
value = 1,
extend = {
    targetValueType = "cardFieldValueWithTarget",
    field = "configAttk",
    A = 0,
    B = 1,
},
```

It does not sum fields across all targets. Do not place `cardFieldValueWithTarget` in normal `valueType`.

## In-Game Effect Presentation

Presentation fields do not change `targetId`, `event`, or final `value`.

### Automatic Presentation: `playResultType`

| Value | Type | Use |
| --- | --- | --- |
| `0` | `none` | No extra presentation |
| `1` | `attack` | Normal attack |
| `2` | `buff` | Buff |
| `3` | `debuff` | Debuff |
| `4` | `drone_move` | Defined but has no normal Timeline mapping; do not use |
| `5` | `backAttack` | Back attack |
| `6` | `fanAttack` | Fan or area attack |
| `7` | `penetratAttack` | Piercing attack |
| `8` | `selfExplode` | Single-target self-destruct |
| `9` | `switchMode` | Mode switch |
| `10` | `selfAoeExplode` | Area self-destruct |
| `11` | `carrierRemove` | Unit leaves play |
| `12` | `switchDisplay` | Replace displayed unit |
| `13` | `meleeAttack` | Melee attack |

```lua
event = 1000,
targetId = 614,
value = 3,
playResultType = 6,
```

Automatic selection uses existing client Timelines. Supported types may fall back to a generic presentation when a model lacks a dedicated one.

### Existing Presentation: `customResultType`

The client first tries:

```text
<modelId>_<mode>_<customResultType>
```

It then tries `customResultType` as a complete name, and finally falls back to `playResultType`.

```lua
event = 1000,
targetId = 40,
value = 2,
playResultType = 1,
customResultType = "multi_attack_3",
dontUseCardTimeline = true,
```

`dontUseCardTimeline=true` prevents the Card's dedicated Timeline from taking priority. It does not disable all Timelines or `customResultType`.

### Presentation Role: `markTarget`

`markTarget` places this Effect's entity in a Stack-level presentation group. Values are `src`, `target`, `assist`, `spawn`, and `victim`.

```lua
event = 27,
targetId = 613,
value = 1,
playResultType = 0,
customResultType = "drone_suck_single",
markTarget = "victim",
```

Omitted Effects with presentation default to the `target` group. This field never changes actual Effect targets.

### Inspect and Preview Timelines

Enable Developer Mode in settings and press BackQuote to open the console.

```text
timeline_list <modelId> [mode]
play_timeline <modelId> <mode> <timelineName>
```

The first lists available Timelines. The second previews one complete Timeline name in battle.

## Obsolete `event` Values

Do not use these in new MODs:

| `event` | Name |
| --- | --- |
| `10` | `Equip` |
| `12` | `CostCard` |
| `13` | `Shuffle` |
| `20` | `Copy` |
| `26` | `MoveDrone` |
| `28` | `Stackcard` |
| `29` | `Disintegrated` |
| `40` | `View` |
| `50` | `Option` |
| `62` | `StaticTarget` |
| `101` | `Shield` |
| `104` | `HpMax` |
| `111` | `PowerMaxSet` |
| `140` | `GridNoSet` |
| `999` | `Destroy` |
| `3001` | `ResultNoNewCard` |
| `3002` | `ResultShield` |

## Adding `battle_effect_def` in a MOD

Place the file at:

```text
config/battle_effect_def/config/effects.lua
```

Use `installKey="effectId"`:

```lua
return {
    installKey = "effectId",
    rows = {
        {
            effectId = 990701,
            targetId = 40,
            event = 1000,
            value = 2,
        },
    },
}
```

Effect `990701` selects one enemy unit and deals 2 normal damage. A Skill references it in execution order:

```lua
effect = { 990701 }
```

Card and Skill `costEffect` and `extraCost` may also reference the new `effectId`.
