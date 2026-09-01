# `battle_skill_def` Configuration Reference

> `battle_skill_def` defines when a Skill executes and which Effects it executes.

A Skill with `trigger=0` is called directly by a Card or another configuration. A Skill with a nonzero `trigger` listens to a battle Trigger and executes after its filters pass.

Both paths execute the Effect IDs in `effect` in order.

## Basic Structure of `battle_skill_def`

**Module Prototype** (Card `2039`): when deployed, add one **Drone Prototype** to hand.

```lua
{
    skillId = 203901,
    name = "Module Prototype",
    tag = "Drone",
    desc = "When deployed, add 1 [Drone Prototype] to your hand.",
    effect = { 1527 },
    tagMap = {
        [4] = 1,
    },
    trigger = 123,
    triggerEx = {
        self = 1,
    },
    stack = 1,
    srcCardId = 2039,
    visibility = 1,
}
```

```text
Card 2039: Module Prototype
└─ skillList = { 203901 }
   └─ Skill 203901: Module Prototype
      ├─ trigger=123: check when a unit is deployed
      ├─ triggerEx.self=1: respond only to this Card
      ├─ stack=1: enter the Stack when triggered
      └─ effect={1527}
         └─ Effect 1527: add Card 2041 to hand
```

The Skill first checks `trigger` and `triggerEx`, then uses `stack` to decide how the triggered resolution enters the Stack, and finally executes Effect `1527`.

`skillId` is the unique reference ID. `name`, `tag`, and `desc` are text fields. `effect` is a list of Effect IDs.

A new Skill requires `skillId`, `name`, `effect`, and `trigger`. Other fields use defaults when omitted.

## `trigger`: How a Skill Enters Execution

`trigger=0` does not listen to battle events. Other Trigger IDs wait for the matching timing point.

See [Trigger Reference](../concepts/triggers.md) for Trigger IDs, timing, and `triggerEx`. Trigger IDs are not Effect `event` IDs.

### `trigger=0`: Active Execution

An active Skill is called by Skill ID from a Card or another configuration. The caller decides the targets, then the Skill executes `effect`.

**Promotion Order** (Card `2016`): a friendly target unit gains +2/+2 and attacks once.

```lua
{
    skillId = 201601,
    name = "Promotion Order",
    tag = "Order",
    desc = "A target friendly drone gains +2/+2 and attacks once.",
    effect = { 1511, 1512 },
    useConditions = { 0 },
    trigger = 0,
}
```

Card `2016` calls Skill `201601` through `skillList`. The Skill does not wait for a Trigger and executes Effects `1511` and `1512` in order.

`useConditions` is a list of Battle Condition IDs checked for active use. The default `{0}` adds no Condition. See [`battle_condition_def`](battle_condition_def.md).

`costEffect` is one Effect ID used as the activation cost and defaults to `0`. `extraCost` is a list of additional cost Effect IDs and defaults to `{}`.

Current published Skills have no nondefault `costEffect` or `extraCost` examples, so new content should keep these defaults unless a verified use is available.

### Nonzero `trigger`: Listen to a Trigger

`trigger` selects the timing point. `triggerEx` filters an event that already occurred; it does not create a timing point.

#### `triggerEx.self`: Respond Only to This Card

**Module Prototype** adds a Card only when it is deployed itself:

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
```

`self=1` requires the event source to be the Card that owns this Skill. Without it, similar friendly events may also pass.

#### `triggerEx.srcTag`: Filter Source Tags

Card `11020`: when you use a tactical Card, this unit gains +0/+1.

```lua
{
    skillId = 1102001,
    effect = { 9055 },
    trigger = 115,
    triggerEx = {
        srcTag = { 3 },
    },
}
```

`trigger=115` listens to Card use. `srcTag={3}` keeps only source Cards with the tactical Tag.

#### `triggerEx.condition`: Check the Owning Card

**ACE-001 WhiteDwarf** (Card `6201`): when its circuit reaches 3 and a tactical Card is used, reduce the next drone Card's cost by 1 until the end of the turn.

```lua
{
    skillId = 220102,
    effect = { 4209 },
    trigger = 115,
    triggerEx = {
        condition = { 2025 },
        srcTag = { 3 },
    },
}
```

`condition={2025}` checks the Card that owns the Skill. `srcTag={3}` also requires a tactical source Card.

See [Trigger Reference](../concepts/triggers.md) for source player, Target, Area, Attr, and other filters.

#### Limiting Trigger Count

`extend.triggerCount` limits how many times a Skill may trigger. Add `triggerEx.countReset=1` to reset the count each round.

Card `2703` has four Skills. The first tactical, drone, pilot, and wingman Card used each round each grants +3 Attack:

```lua
skillList = { 270301, 270302, 270303, 270304 },
```

| Skill | `srcTag` | Card type |
| --- | --- | --- |
| `270301` | `{3}` | Tactical |
| `270302` | `{4}` | Drone |
| `270303` | `{8}` | Pilot |
| `270304` | `{7}` | Wingman |

Skill `270301`:

```lua
{
    skillId = 270301,
    effect = { 4442 },
    trigger = 115,
    triggerEx = {
        srcTag = { 3 },
        countReset = 1,
    },
    stack = 1,
    extend = {
        triggerCount = 1,
    },
}
```

Each of the four Skills has its own counter, so each Card type gets one trigger opportunity per round.

#### `stack`: Enter the Stack When Triggered

- `stack=1`: enter the Stack when triggered; this is the default.
- `stack=0`: resolve without entering the Stack.

Card `1001` restores all Power at the start of your turn and uses `stack=0`:

```lua
{
    skillId = 100101,
    effect = { 9002, 9003 },
    trigger = 1,
    triggerEx = {},
    stack = 0,
}
```

**Module Prototype** uses `stack=1` when deployed:

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
stack = 1,
```

Do not use the `stack` value of an active Skill to infer its caller's flow. A `trigger=0` Skill is controlled by its caller.

## `effect`: Effects to Execute

`effect` is a `list[int]` of [`battle_effect_def.effectId`](battle_effect_def.md). Effects execute in list order.

See [`battle_effect_def`](battle_effect_def.md) for `event`, `targetId`, `value`, `extend`, and Effect behavior.

### One Effect

**Module Prototype** executes Effect `1527`, adding Card `2041` to hand:

```lua
effect = { 1527 },
```

### Several Effects

Card `7547`: destroy a friendly drone and deal its Attack as damage to every enemy unit.

```lua
{
    skillId = 754701,
    effect = { 4089, 3014, 4090 },
    trigger = 0,
    playResultType = 1,
}
```

The order is required:

1. Effect `4089` records the target drone's Attack.
2. Effect `3014` destroys the target drone.
3. Effect `4090` reads the result of `4089` and damages every enemy unit.

Changing the order may remove data required by a later Effect.

### Skill-Level `playResultType`

Normal Skills omit `playResultType` and use the default `0`. Effects normally own their own resolution and client presentation.

Skill `754701` uses `playResultType=1`, meaning the whole Skill owns the attack presentation. Use this only when a Skill needs presentation outside its individual Effects.

See [`battle_effect_def`](battle_effect_def.md) for Effect presentation fields.

## Skill Text, Category, and Display

`name`, `tag`, and `desc` are strings. `visibility` decides whether the Skill appears separately in the battle Skill list.

### `tagMap`

`tagMap` is `dict[int,int]` structured Tag data.

When omitted or empty, the Skill uses its owning Card's `tagMap`. A nonempty Skill `tagMap` replaces that fallback and is not merged with Card Tags.

```lua
tagMap = {
    [4] = 1,
},
```

### `icon`

`icon` is the battle icon resource name. It is a string and defaults to `""`, meaning no independent icon.

Skill `1053201` uses:

```lua
icon = "1",
```

### `srcCardId`

`srcCardId` is the source Card used for triggered Skill Stack presentation. It is an int and defaults to `0`. It changes display only and is not required for execution.

```lua
srcCardId = 2039,
```

### `visibility`

`visibility` is an int display flag and defaults to `0`. It does not change Trigger or Effect resolution.

- `0`: do not show separately, such as a one-time resolution already described by its Card.
- `1`: show separately, such as a unit Skill that remains relevant.

### `keywordList`

`keywordList` is `list[dict[string,int]]` and defaults to `{}`. There is no current nonempty published example, so this reference does not invent a format.

## Legacy Design

`targetIds` (`list[int]`) is obsolete. Do not use it in new Skills.

## Adding `battle_skill_def` in a MOD

Place the file at:

```text
config/battle_skill_def/config/skills.lua
```

This example adds Skill `990801`: when its unit is deployed, enter the Stack and draw 1 Card.

```lua
return {
    installKey = "skillId",
    rows = {
        {
            skillId = 990801,
            name = "Deployment Supply",
            tag = "Drone",
            desc = "When deployed, draw 1 Card.",
            effect = { 8022 },
            tagMap = {
                [4] = 1,
            },
            trigger = 123,
            triggerEx = {
                self = 1,
            },
            stack = 1,
            srcCardId = 9908,
            visibility = 1,
        },
    },
}
```

Use `installKey="skillId"`. Effect `8022` is the existing draw-1-Card resolution.

Reference the Skill from Card `9908`:

```lua
skillList = { 990801 },
```
