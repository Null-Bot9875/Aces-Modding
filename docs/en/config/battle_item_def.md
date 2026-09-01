# `battle_item_def` Configuration Reference

> `battle_item_def` defines a Battle Item's display data, use count, and resolving Skill.

## Basic Structure of `battle_item_def`

**Transport Service** (Battle Item `3001`) draws 3 Cards when used:

```lua
{
    id = 3001,
    name = "Transport Service",
    assetId = 30011,
    assetId2 = 3001,
    type = { 1 },
    rare = 3,
    backAssetId = 1,
    useLimit = 1,
    desc = "Draw 3 Cards",
    useEffect = {},
    useSkillId = 300101,
    extend = {},
    keywordList = {},
}
```

```text
Battle Item 3001: Transport Service
└─ useSkillId → Skill 300101
   ├─ targetIds → Target 100: self
   └─ effect → Effect 3001: draw 3 Cards
```

Provide these fields for a new `battle_item_def` entry:

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | positive int | Battle Item ID and installation key |
| `name` | string | Item name |
| `assetId` | int | Detail image resource ID |
| `assetId2` | int | Battle item bar icon resource ID |
| `type` | int[] | Display category |
| `rare` | int | Rarity |
| `backAssetId` | int | Background resource ID |
| `useLimit` | int | Use count; use `1` for a normal one-use item |
| `desc` | string | Player-facing description |
| `useEffect` | table | Campaign inventory effect; battle items use `{}` |
| `useSkillId` | int | [`battle_skill_def.skillId`](battle_skill_def.md) executed on use |
| `extend` | table | Additional data; normal items use `{}` |
| `keywordList` | table[] | Detail keywords; use `{}` when unused |

## `useSkillId`: Resolution After Use

The main behavior comes from `useSkillId`. It references an active Skill, which controls target selection, Conditions, and Effect order.

Battle Item `3001` references Skill `300101`:

```lua
{
    skillId = 300101,
    name = "Transport Service",
    tag = "Item",
    desc = "Draw 3 Cards",
    effect = { 3001 },
    targetIds = { 100 },
    useConditions = { 0 },
    trigger = 0,
}
```

Target selection is configured in the Skill's `targetIds`, not in `battle_item_def`.

Effect `3001` performs the actual result:

```lua
{
    effectId = 3001,
    desc = "Draw 3 Cards",
    targetId = 100,
    event = 11,
    value = 3,
}
```

Define the complete Skill and Effect first, then place the Skill ID in `useSkillId`. See [`battle_skill_def`](battle_skill_def.md) and [`battle_effect_def`](battle_effect_def.md).

## Display and Use Fields

`name`, `desc`, `assetId`, `assetId2`, `rare`, `backAssetId`, `type`, and `keywordList` control item bar and detail display.

Current Battle Items use `type` values `1` through `5`. `backAssetId` normally matches `type`. Reuse the matching pair from an existing item image. `rare` controls rarity display.

`useEffect` is not a replacement for a battle Skill. It is used by campaign inventory items; battle items keep it empty:

```lua
useEffect = {},
```

Each `keywordList` item uses `keywordId`; use an empty table when none are needed.

## Adding `battle_item_def` in a MOD

Place files under:

```text
config/battle_item_def/config/*.lua
```

This example adds Battle Item `990601`, which executes Skill `99060101`:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990601,
            name = "Example: Emergency Supply",
            assetId = 30011,
            assetId2 = 3001,
            type = { 1 },
            rare = 3,
            backAssetId = 1,
            useLimit = 1,
            desc = "Draw 1 Card.",
            useEffect = {},
            useSkillId = 99060101,
            extend = {},
            keywordList = {},
        },
    },
}
```

Use `installKey="id"`. Provide Skill `99060101` in the same MOD under `battle_skill_def`.

Grant the item through [`reward_def`](reward_def.md#battleitem-grant-a-battle-item):

```lua
value = {
    { battleItem = { id = 990601, count = 1 } },
}
```
