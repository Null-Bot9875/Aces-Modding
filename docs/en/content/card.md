# Card configuration tutorial

The current Card authoring scope covers regular tactical Cards played from hand that reuse existing game Skills, Targets, cost effects, and Tags.

This page does not claim support for custom Skills, Targets, cost effects, audio, drones, units, devices, or every complex Card type.

## Minimal Card

File location:

```text
config/card_def/config/cards.lua
```

Contents:

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            name = "Example: Fire Drone",
            rare = 1,
            type = { 2 },
            tagMap = { [3] = 1, [31] = 1 },
            targetIds = { 40 },
            costEffect = 8012,
            skillList = { 201201 },
        },
    },
}
```

## Eight required fields

| Field | Type | Rule |
| --- | --- | --- |
| `cardId` | Positive integer | Card query and installation key; new content should avoid ID conflicts |
| `name` | string | Original display name stored in configuration |
| `rare` | int | Rarity value; reference a same-version Core Card |
| `type` | list | List of Card type IDs |
| `tagMap` | map | `tagId -> value`; every Tag must already exist |
| `targetIds` | list | List of existing Target IDs |
| `costEffect` | int | Existing cost Effect ID |
| `skillList` | list | List of existing Skill IDs |

Core references in `tagMap`, `targetIds`, `costEffect`, and `skillList` are checked during installation. A missing reference fails and rolls back the complete MOD configuration installation pass.

## Automatic defaults

The Card author adapter supplies fixed defaults for omitted fields:

```lua
tag = {}
descLua = {}
extraCost = {}
staticList = {}
attkSkill = 0
dir = 0
dirSkillList = {}
areaSkillList = {}
hp = 0
useConditions = { 0 }
stackcard = {}
stackcardSkill = {}
extend = {}
limitBaseIds = {}
upgrade = 0
slotType = { 0 }
initCard = 0
pvpReplace = 0
assetId = 10001
mainType = 1
mainTag = {}
subTag = {}
iconId = 0
deviceStackIcon = {}
keywordList = {}
```

Explicit empty lists and numeric values are not replaced by defaults.

## Card image

`assetId` accepts three forms:

```lua
-- Omitted: use default Core image 10001

assetId = 10001
-- Use an existing Core Card image

assetId = "cards/fire_drone.png"
-- Use assets/cards/fire_drone.png from the current MOD
```

See [PNG assets](../assets.md) for complete relative-path restrictions.

## Add the Card to a reward

Installing `card_def.config` makes the Card queryable, but does not add the Card to a reward or deck automatically.

The [`card-pack`](../../../templates/card-pack/README.en.md) uses two additional batches for an operable test:

1. `act_card_pool_def.base_pool` creates test pool `990001`.
2. `reward_def.config` overrides test reward `10003` so it reads that pool.

The card pool batch uses group replacement:

```lua
return {
    installKey = "poolId",
    installValue = 990001,
    rows = {
        {
            cardId = 910001,
            baseId = 501,
            poolId = 990001,
            minBaseLevel = 1,
            maxBaseLevel = 10,
            limitActIds = { -1 },
        },
    },
}
```

`installValue=990001` operates on that pool group only. An omitted `operation` defaults to full-group `replace`.

## In-game verification

Card completion criteria:

1. Cold start has no MOD configuration or loading error.
2. A normal Rogue reward contains the Card.
3. Selection adds the Card to the current Rogue deck.
4. The Card remains after restarting the same save.
5. The Card can be drawn, assigned a valid target, and played in battle.
6. A regular tactical Card leaves the hand and enters `desk(area=3)` after a successful play.

A Card being queryable through `Config.Get` alone does not establish in-game completion.

## Localization

`name` retains the original text. Translations belong in `language/language.csv`; see [Localization](../localization.md).

## Capability requests

For custom Skills, Targets, cost Effects, or Card types not covered by this page, choose “Capability request” in GitHub Issues and describe the intended player-visible result.
