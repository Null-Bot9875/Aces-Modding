# Trigger Reference

> Trigger decides when a Skill in `battle_skill_def` is checked. `triggerEx` further filters that check.

## Basic Trigger Structure

**Logistics Drone** (Card `2023`): when this Card is deployed, draw 1 Card.

```text
Card 2023: Logistics Drone
└─ Skill 202301
   ├─ trigger = 123
   ├─ triggerEx.self = 1
   └─ effect = { 8022 }: draw 1 Card
```

```lua
trigger = 123,
triggerEx = {
    self = 1,
},
effect = {
    8022,
},
```

`trigger=123` checks the Skill after a unit is deployed. `triggerEx.self=1` keeps only deployment events produced by the Card that owns the Skill. The Skill executes `effect` only when both conditions pass.

Trigger IDs and Effect `event` IDs are different enums. `trigger` decides when a Skill is checked; `event` decides what an Effect resolves.

`trigger=0` does not listen to battle events. A Card or another configuration calls that Skill directly by Skill ID.

## `triggerEx`: Filter a Trigger Check

Use an empty table when no extra filter is needed:

```lua
triggerEx = {},
```

`triggerEx` does not create a new Trigger. When several fields are present, all of them must pass.

Not every field reads data carried by the Trigger. `condition` checks the Card that owns the Skill, `roundMod` checks the current round, and `nodeShowType` checks the current Node. Do not use a field when the selected Trigger does not provide the data it needs.

| Field | Value | Purpose | Applicable Trigger |
| --- | --- | --- | --- |
| `self` | `0` or `1` | Require or exclude the Card that owns the Skill as the event source | [106](#106-core-armor-decreased), [107](#107-damage-received), [109](#109-effect-damage), [111](#111-card-moved), [115](#115-card-used), [117](#117-static-skill-added), [120](#120-power-decreased), [123](#123-unit-deployed), [124](#124-unit-destroyed-by-an-attack), [125](#125-unit-damaged-core-armor), [126](#126-unit-destroyed), [127](#127-unit-warcry), [128](#128-unit-moved), [129](#129-unit-finished-an-attack), [130](#130-stack-card-added), [131](#131-static-attr-added), [132](#132-circuit-count-increased), [133](#133-circuit-count-decreased), [135](#135-pilot-entered-a-battle-card), [136](#136-static-attr-removed), [138](#138-unit-with-attack-finished-an-attack) |
| `src` | `1`, `2`, or `3` | Source player: `1` friendly, `2` enemy, `3` both; omitted responds only to friendly events | [All automatic Triggers](#available-triggers) |
| `srcTag` | Tag ID list | Source Card must have every listed Tag | Same entries as `self`; the Trigger must carry a source Card |
| `srcCondition` | Battle Condition ID list | Check the source Card with [`battle_condition_def`](../config/battle_condition_def.md) | Same entries as `self`; the Trigger must carry a source Card |
| `condition` | Battle Condition ID list | Check the Card that owns the Skill | Automatic Triggers; the Skill must have an owning Card |
| `valueCondition` | Battle Condition ID list | Check the numeric value carried by the Trigger | [106](#106-core-armor-decreased), [107](#107-damage-received), [109](#109-effect-damage), [119](#119-damage-attempted), [120](#120-power-decreased), [125](#125-unit-damaged-core-armor) |
| `moveSrc` | Area ID | Area the Card moved from | [111](#111-card-moved) |
| `moveTarget` | Area ID | Area the Card moved into | [111](#111-card-moved) |
| `roundMod` | positive integer | Allow one trigger for each interval of friendly rounds | [All automatic Triggers](#available-triggers) |
| `roundModStart` | positive integer | First valid position in the `roundMod` cycle | [All automatic Triggers](#available-triggers) |
| `attr` | Attr name | Attr that was added or removed | [131](#131-static-attr-added), [136](#136-static-attr-removed) |
| `nodeShowType` | `showType` list | Pass only when the current Node has one of these `showType` values | Automatic Triggers; see [100](#100-battle-started) |
| `targetId` | Target ID | Build Skill targets from data carried by the Trigger | Confirmed examples: [111](#111-card-moved), [123](#123-unit-deployed), [138](#138-unit-with-attack-finished-an-attack) |
| `countReset` | `1` | Reset the `extend.triggerCount` counter | Confirmed examples: [115](#115-card-used), [123](#123-unit-deployed), [134](#134-deck-reset) |

`targetId` is not a filter. It uses the Card, Grid, Player, or Stack carried by the Trigger to build Skill targets through [`battle_target_def`](../config/battle_target_def.md).

`countReset` is also not a filter. It works only with `extend.triggerCount`; whether the counter can reset each round also depends on the object that owns the Skill.

## Available Triggers

In the table, **common** means `src`, `condition`, `roundMod`, `roundModStart`, and `nodeShowType`. These fields do not require an event Card, although `condition` still requires the Skill to have an owning Card.

IDs `1` through `7` are also RoundStage IDs. See [Round Stages](round-stages.md).

| ID | Runtime name | Timing | Supported `triggerEx` |
| --- | --- | --- | --- |
| [`0`](#0-active-execution) | `Active` | Called directly by another configuration | none |
| [`1`](#1-reset-step) | `RESET` | Reset step of the friendly turn | common |
| [`2`](#2-maintain-step) | `MAINTAIN` | Maintain step of the friendly turn | common |
| [`3`](#3-draw-step) | `NEWCARD` | Draw step of the friendly turn | common |
| [`4`](#4-main-phase-1) | `MAIN1` | Main phase 1 of the friendly turn | common |
| [`5`](#5-attack-phase) | `ATTK` | Attack phase of the friendly turn | common |
| [`6`](#6-end-phase) | `FINISH` | End phase of the friendly turn | common |
| [`7`](#7-cleanup-step) | `CLEANUP` | Cleanup step of the friendly turn | common |
| [`100`](#100-battle-started) | `GameStart` | Battle starts | common |
| [`105`](#105-core-armor-restored) | `HPAdd` | Core armor is actually restored | common |
| [`106`](#106-core-armor-decreased) | `HPDec` | Core armor is actually reduced | common, `self`, source Card, `valueCondition` |
| [`107`](#107-damage-received) | `Damage` | A target completes Damage resolution | common, `self`, source Card, `valueCondition` |
| [`108`](#108-card-drawn) | `NewCard` | A Card is drawn | common |
| [`109`](#109-effect-damage) | `EffectDamage` | An Effect actually deals damage | common, `self`, source Card, `valueCondition` |
| [`111`](#111-card-moved) | `CardMove` | A Card moves between Areas | common, `self`, source Card, `moveSrc`, `moveTarget`, `targetId` |
| [`112`](#112-core-armor-destroyed) | `Destroy` | Core armor is destroyed | common |
| [`115`](#115-card-used) | `UseCard` | A Card is used | common, `self`, source Card, `countReset` |
| [`117`](#117-static-skill-added) | `NewStatic` | A Card gains a Static Skill | common, `self`, source Card |
| [`119`](#119-damage-attempted) | `TryDamage` | Damage resolution is attempted | common, `valueCondition` |
| [`120`](#120-power-decreased) | `PowerDec` | Power is actually reduced | common, `self`, source Card, `valueCondition` |
| [`123`](#123-unit-deployed) | `DroneSet` | A unit enters the Drone Area and finishes placement | common, `self`, source Card, `targetId`, `countReset` |
| [`124`](#124-unit-destroyed-by-an-attack) | `DroneDestory` | A unit destroys another unit by attack or Effect | common, `self`, source Card |
| [`125`](#125-unit-damaged-core-armor) | `DroneDamage` | A unit actually damages core armor | common, `self`, source Card, `valueCondition` |
| [`126`](#126-unit-destroyed) | `DroneBeDestory` | A unit is destroyed | common, `self`, source Card |
| [`127`](#127-unit-warcry) | `DroneRoar` | A deployed unit checks its own Warcry Skill | common, `self`, source Card |
| [`128`](#128-unit-moved) | `DroneMove` | A unit changes Grid position in the Drone Area | common, `self`, source Card |
| [`129`](#129-unit-finished-an-attack) | `DroneAttk` | A unit finishes an attack | common, `self`, source Card |
| [`130`](#130-stack-card-added) | `StackcardAdd` | A Card gains one stacked Card | common, `self`, source Card |
| [`131`](#131-static-attr-added) | `StaticAttrAdd` | A Card gains a static Attr | common, `self`, source Card, `attr` |
| [`132`](#132-circuit-count-increased) | `DirCountAdd` | A unit's circuit count increases | common, `self`, source Card |
| [`133`](#133-circuit-count-decreased) | `DirCountDec` | A unit's circuit count decreases | common, `self`, source Card |
| [`134`](#134-deck-reset) | `PoolReset` | The deck resets and receives Cards | common, `countReset` |
| [`135`](#135-pilot-entered-a-battle-card) | `HeroCardAdd` | A pilot enters a Card | common, `self`, source Card |
| [`136`](#136-static-attr-removed) | `StaticAttrRemove` | A Card loses a static Attr | common, `self`, source Card, `attr` |
| [`137`](#137-unit-attack-replaced) | `DroneAttkReplace` | Check for a replacement Skill before a normal attack | `condition`, `roundMod`, `roundModStart`, `nodeShowType` |
| [`138`](#138-unit-with-attack-finished-an-attack) | `DroneAttkWithPower` | A unit with Attack greater than 0 finishes an attack | common, `self`, source Card, `targetId` |

## Trigger Details

The following sections list only the data carried by each Trigger. Use the `triggerEx` table above for the complete field rules.

## `0`: Active Execution

`Active` does not listen to a phase or battle event. A Card, Effect, or another configuration calls the Skill directly by Skill ID. Keep `triggerEx={}` when no extra data is needed.

## `1`: Reset Step

`RESET` triggers when the friendly turn enters its reset step. It carries no event Card or value; common fields are available.

Card `10602`, Skill `1060201`: at the start of the turn, if the commander's unit has no more than 20 armor, unsheathe Card `10611`.

```lua
trigger = 1,
triggerEx = {
    condition = { 2230 },
},
```

`condition` checks the current state of the Card that owns the Skill. It does not read an event source from the round Trigger.

Card `10757`, Skill `1075701`: enter its special mode at the start of the third round.

```lua
trigger = 1,
triggerEx = {
    roundMod = 4,
    roundModStart = 4,
},
```

These values place the first passing position at the start of the third friendly round and continue with the same cycle.

## `2`: Maintain Step

`MAINTAIN` triggers when the friendly turn enters its maintain step. It carries no event Card or value; common fields are available.

## `3`: Draw Step

`NEWCARD` triggers when the friendly turn enters its draw step. It carries no event Card or value. It is different from [108](#108-card-drawn), which triggers for an individual drawn Card.

## `4`: Main Phase 1

`MAIN1` triggers when the friendly turn enters main phase 1. It carries no event Card or value; common fields are available.

## `5`: Attack Phase

`ATTK` triggers when the friendly turn enters its attack phase. It carries no event Card or value and does not identify which units will attack this round.

## `6`: End Phase

`FINISH` triggers when the friendly turn enters its end phase. It carries no event Card or value; common fields are available.

## `7`: Cleanup Step

`CLEANUP` triggers when the friendly turn enters its cleanup step. It carries no event Card or value; common fields are available.

## `100`: Battle Started

`GameStart` triggers once for each side after battle setup completes. It carries no event Card or value; common fields are available.

Chip `5104`, Skill `1510401`: at the start of an elite battle, deal 20 Damage to the enemy commander.

```lua
trigger = 100,
triggerEx = {
    nodeShowType = { 2, 3 },
},
```

`nodeShowType` checks the current Node's `showType`; it is not data carried by `GameStart` itself.

## `105`: Core Armor Restored

`HPAdd` triggers after core armor actually increases. It carries neither a source Card nor the restored value. Only common fields are available; `valueCondition` cannot filter the amount.

## `106`: Core Armor Decreased

`HPDec` triggers after core armor actually decreases. It carries the core Card and armor change. Common fields, `self`, `srcTag`, `srcCondition`, and `valueCondition` are available.

The source Card is the core Card whose armor decreased, not the Card that dealt damage.

## `107`: Damage Received

`Damage` triggers after Damage passes shield and other interception rules and enters actual reduction. Fully prevented `0` Damage triggers only [119](#119-damage-attempted).

It carries the damaged Card and Damage value. Common fields, `self`, `srcTag`, `srcCondition`, and `valueCondition` are available. The source Card is the damaged Card. Use [109](#109-effect-damage) to inspect the source of the damaging Effect.

## `108`: Card Drawn

`NewCard` triggers once for each drawn Card, but it does not carry that Card. Only common fields are available; `self`, `srcTag`, and `srcCondition` cannot filter which Card was drawn.

## `109`: Effect Damage

`EffectDamage` triggers after an Effect actually deals nonzero damage. It carries the Effect's source Card and actual damage value. Common fields, `self`, `srcTag`, `srcCondition`, and `valueCondition` are available.

## `111`: Card Moved

`CardMove` triggers when a Card moves from one Area to another. Special paths that do not count as a real move, such as revival, do not trigger it.

It carries the moved Card, source Area, and destination Area. Common fields, `self`, `srcTag`, `srcCondition`, `moveSrc`, `moveTarget`, and `targetId` are available. See [Battle Areas](areas.md).

Card `7108`, Skill `710801`: when this Card leaves the Drone Area, deploy Card `71081` on its original Grid.

```lua
trigger = 111,
triggerEx = {
    moveSrc = 14,
    self = 1,
    targetId = 103,
},
```

`moveSrc=14` requires the Card to leave the Drone Area. `targetId=103` preserves the original Grid from the move event for the Skill's Effect.

**Emergency Repair** (Card `7599`, Skill `759902`): while this Card is in the Scrap Area, return it to hand after another differently named Card is scrapped.

```lua
trigger = 111,
triggerEx = {
    moveTarget = 4,
    srcCondition = { 2079 },
},
```

`moveTarget=4` requires a Card to enter the Scrap Area. `srcCondition` checks that moved Card.

## `112`: Core Armor Destroyed

`Destroy` triggers when core armor reaches zero or an Effect directly destroys the player. It carries neither the destroyed Card nor the damage source. Use [126](#126-unit-destroyed) for a destroyed unit Card.

## `115`: Card Used

`UseCard` triggers after a Card completes its use entry. It carries the used Card and the Power spent. `self`, `srcTag`, and `srcCondition` can read the source Card; no public field directly filters the Power cost.

To limit triggers per round, use both `extend.triggerCount` and `triggerEx.countReset=1`. See [Limiting Trigger Count](../config/battle_skill_def.md#limiting-trigger-count).

## `117`: Static Skill Added

`NewStatic` triggers when a Card gains a Static Skill. It carries the Card and Static Skill ID. `self`, `srcTag`, and `srcCondition` can read the source Card; no public field directly filters the Static Skill ID.

## `119`: Damage Attempted

`TryDamage` triggers when Damage resolution starts, even when a shield or another rule reduces the final damage to `0`. It carries the attempted value but no source Card. Common fields and `valueCondition` are available.

## `120`: Power Decreased

`PowerDec` triggers after an Effect actually reduces Power. It carries the Power change and the Effect's source Card. Common fields, `self`, `srcTag`, `srcCondition`, and `valueCondition` are available.

## `123`: Unit Deployed

`DroneSet` triggers after a unit enters the Drone Area and finishes placement. It carries the deployed Card and Grid. Common fields, `self`, `srcTag`, `srcCondition`, `targetId`, and `countReset` are available.

See [Basic Trigger Structure](#basic-trigger-structure) for the `self=1` example on **Logistics Drone**.

Card `2031`, Skill `203101`: when another drone is deployed, this Card gains +1/+0.

```lua
trigger = 123,
triggerEx = {
    self = 0,
    srcCondition = { 2016 },
},
```

`self=0` excludes this Card's own deployment. `srcCondition` checks the deployed Card.

Card `10750`, Skill `1075002`: when an enemy unit is deployed, deal 1 Damage to it.

```lua
trigger = 123,
triggerEx = {
    src = 2,
    srcCondition = { 2016 },
    targetId = 103,
},
```

`src=2` keeps only enemy events. `targetId=103` uses the deployment event to target the newly deployed unit.

Card `10184`, Skill `1018402`: when a unit is deployed, this Card gains +2/+0, at most once per round.

```lua
trigger = 123,
triggerEx = {
    countReset = 1,
},
extend = {
    triggerCount = 1,
},
```

`triggerCount=1` allows one trigger in the current count period. `countReset=1` resets the counter for the next round.

## `124`: Unit Destroyed by an Attack

`DroneDestory` triggers when a unit destroys another unit through an attack or Effect. It carries the destroying unit Card. Common fields, `self`, `srcTag`, and `srcCondition` are available.

The destroyed unit is not the source Card. Use [126](#126-unit-destroyed) to listen to that unit.

## `125`: Unit Damaged Core Armor

`DroneDamage` triggers after a unit actually damages core armor. It carries the attacking unit Card and armor change. Common fields, `self`, `srcTag`, `srcCondition`, and `valueCondition` are available.

## `126`: Unit Destroyed

`DroneBeDestory` triggers after a unit is destroyed, including direct destruction and damage that reduces it to `0`. It carries the destroyed unit Card and its original Grid. Common fields, `self`, `srcTag`, and `srcCondition` are available.

## `127`: Unit Warcry

`DroneRoar` checks the deployed unit's own Warcry Skill after it is deployed through the Stack and finishes placement. It carries the deployed unit Card. `self`, `srcTag`, `srcCondition`, `condition`, `roundMod`, `roundModStart`, and `nodeShowType` are available.

## `128`: Unit Moved

`DroneMove` triggers after a unit changes Grid position within the Drone Area and related Static Skills refresh. It carries the moved unit Card and new Grid. Common fields, `self`, `srcTag`, and `srcCondition` are available.

Unlike [111](#111-card-moved), it does not provide `moveSrc` or `moveTarget`.

## `129`: Unit Finished an Attack

`DroneAttk` triggers after a unit finishes an attack, even if the attack dealt no damage. It carries the attacking unit Card and Grid. Common fields, `self`, `srcTag`, and `srcCondition` are available.

## `130`: Stack Card Added

`StackcardAdd` triggers after a Card gains one stacked Card. It carries the receiving Card and the configuration ID of the added Card. `self`, `srcTag`, and `srcCondition` can read the receiving Card.

## `131`: Static Attr Added

`StaticAttrAdd` triggers after a Card in a battle Area gains a static Attr. It carries the changed Card, Grid, and Attr name. Common fields, `self`, `srcTag`, `srcCondition`, and `attr` are available. See [Effect Attributes](attrs.md).

Card `10611`, Skill `1061101`: when the commander's unit gains Delay, scrap this Card, remove Delay from the commander, and grant it +5/+0.

```lua
trigger = 131,
triggerEx = {
    attr = "attkDelay",
    srcTag = { 6 },
},
```

`attr="attkDelay"` keeps only the Delay Attr. `srcTag={6}` further limits the changed Card.

## `132`: Circuit Count Increased

`DirCountAdd` triggers after a unit's circuit count refreshes and the new value is greater than the old value. It carries that unit Card. Common fields, `self`, `srcTag`, and `srcCondition` are available.

## `133`: Circuit Count Decreased

`DirCountDec` triggers after a unit's circuit count refreshes and the new value is less than the old value. It carries that unit Card. Common fields, `self`, `srcTag`, and `srcCondition` are available.

## `134`: Deck Reset

`PoolReset` triggers after the deck resets and actually receives at least one Card. An empty reset does not trigger it. It carries only the player who owns the deck, not a Card. Common fields are available; `self`, `srcTag`, and `srcCondition` are not.

Use `countReset=1` with `extend.triggerCount` to reset a per-round count.

## `135`: Pilot Entered a Battle Card

`HeroCardAdd` triggers after a pilot enters a Card in a battle Area and its Skill and Static Skill additions finish. It carries the receiving Card, Grid, and pilot Card ID. `self`, `srcTag`, and `srcCondition` can read the receiving Card.

`self=1` means the pilot entered the Card that owns the Skill. It does not check the pilot Card itself.

## `136`: Static Attr Removed

`StaticAttrRemove` triggers after a Card in a battle Area loses a static Attr. It carries the changed Card, Grid, and Attr name. Common fields, `self`, `srcTag`, `srcCondition`, and `attr` are available.

## `137`: Unit Attack Replaced

`DroneAttkReplace` checks the attacking unit's own replacement Skill before a normal attack. When matched, the replacement Skill executes and the normal attack does not.

It carries no event Card or value. `condition`, `roundMod`, `roundModStart`, and `nodeShowType` are available. Do not use `self`, `srcTag`, `srcCondition`, or `valueCondition` here.

## `138`: Unit with Attack Finished an Attack

`DroneAttkWithPower` triggers after a unit with Attack greater than `0` finishes an attack. It is checked after [129](#129-unit-finished-an-attack).

It carries the attacking unit Card and Grid. Common fields, `self`, `srcTag`, `srcCondition`, and `targetId` are available.

## Where Trigger Is Configured

Skill trigger entry is configured in [`battle_skill_def.trigger`](../config/battle_skill_def.md#trigger-how-a-skill-enters-execution). Filters are configured in `battle_skill_def.triggerEx`.

A Static Skill may listen to a Trigger through [`static_skill_def.flag.removeTrigger.trigger`](../config/static_skill_def.md#automatic-removal-with-flagremovetrigger) and use the same filters in `static_skill_def.flag.removeTrigger.triggerEx`.

`battle_effect_def.extend.trigger` is used only by an Effect with `event=120`. It specifies the Trigger Skill to execute; it is not another Trigger definition. See [Event 120: SkillTrigger](../config/battle_effect_def.md#event-120-skilltrigger).
