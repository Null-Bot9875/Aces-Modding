# `card_def` Configuration Reference

> `card_def` defines Card name, color, targets, costs, and resolution entry, plus battle fields specific to tactical, drone, and pilot Cards.

This page covers tactical, drone, and pilot Cards. Items and Chips use other tables.

## Basic Structure of `card_def`

**Continuous Shot α** (Card `2061`) is a white tactical Card. After paying 1 Power and selecting one enemy unit, it deals 2 damage and adds **Continuous Shot β** to hand. The linked Card is consumed, deals 2 damage, and creates **Continuous Shot γ**.

```lua
{
    cardId = 2061,
    name = "Continuous Shot α",
    tag = { "Tactical" },
    descLua = {
        { desc = "desc_2061_1" },
    },
    targetIds = { 40 },
    costEffect = 8012,
    extraCost = {},
    skillList = { 206101 },
    staticList = {},
    attkSkill = 0,
    dir = 0,
    dirSkillList = {},
    areaSkillList = {},
    hp = 0,
    useConditions = { 0 },
    stackcard = {},
    stackcardSkill = {},
    extend = {
        linkCards = { 2097 },
    },
    tagMap = {
        [3] = 1,
        [31] = 1,
    },
    upgrade = 2062,
    assetId = 5097,
    mainType = 1,
    type = { 4 },
    mainTag = { "Tactical" },
    subTag = { "Basic" },
    iconId = 0,
    rare = 3,
    deviceStackIcon = {},
    keywordList = {},
}
```

```text
Card 2061: Continuous Shot α
├─ targetIds → Target 40: select 1 enemy unit
├─ costEffect → Effect 8012: spend 1 Power
└─ skillList → Skill 206101: Multi-shot
   ├─ Effect 1534: create Card 2097, Continuous Shot β
   └─ Effect 8026: deal 2 damage to the selected enemy
```

Eight fields are required:

| Field | Type | Purpose |
| --- | --- | --- |
| `cardId` | positive int | Card ID and installation key |
| `name` | string | Display name |
| `rare` | int | Rarity |
| `type` | int[] | Card colors; not the tactical/drone/pilot category |
| `tagMap` | dict&lt;int,int&gt; | Runtime Tags used for Card type and filters |
| `targetIds` | int[] | Targets selected when using the Card; see [`battle_target_def`](battle_target_def.md) |
| `costEffect` | int | Base cost Effect; see [`battle_effect_def`](battle_effect_def.md) |
| `skillList` | int[] | Skills used by the Card; see [`battle_skill_def`](battle_skill_def.md) |

A row with a missing or invalid required field cannot be installed.

## How a Card Is Used and Resolved

```text
useConditions
    ↓
costEffect + extraCost
    ↓
targetIds
    ↓
skillList / attkSkill / dirSkillList / type-specific fields
    ↓
stackFinArea
```

### `useConditions`: Can the Card Be Used Now?

`useConditions` is a list of [`battle_condition_def.id`](battle_condition_def.md). The default `{0}` adds no use Condition.

Some Cards use `extend.conditionTarget` to automatically find an object before checking the Condition:

```lua
useConditions = { 2138 },
extend = {
    conditionTarget = 60,
},
```

`conditionTarget` is a Target ID. Use it only when the Condition must inspect a selected object.

### `costEffect` and `extraCost`: Paying Costs

`costEffect` is one base cost Effect. `costEffect=8012` spends 1 Power.

`extraCost` is a list of additional cost Effects; it does not replace `costEffect`.

Card `11029` spends 20 Nano as an extra cost:

```lua
costEffect = 8011,
extraCost = { 4742 },
```

### `targetIds`: Selecting Targets

`targetIds={40}` selects one enemy unit through Target `40`. `{0}` adds no target selection.

These Targets collect choices during Card use. Each Effect still uses its own `targetId`, so one Card may select an enemy while different Effects act on self, that enemy, or another object.

### Entering Resolution

Tactical Cards normally execute `skillList`. Drone and pilot Cards also use type-specific fields such as `attkSkill`, `staticList`, `dirSkillList`, `hp`, and `extend`.

These fields are not one universal list of Skills. They are read at different timing points depending on Card type and Area.

### `extend.stackFinArea`: Destination After Resolution

After a tactical Card resolves on the Stack, it normally moves to `Desk` (Area `3`). A consumed Card can override that destination.

```lua
extend = {
    stackFinArea = {
        old = 2,
        new = 4,
    },
},
```

`old=2` means the Card came from Hand. `new=4` sends it to Scrap after Stack resolution. This does not change how the Skill executes.

## Card Display and Classification Fields

| Field | Type | Default | Purpose |
| --- | --- | --- | --- |
| `name` | string | required | Card name |
| `descLua` | lua | `{}` | Description parts; existing Cards often use language keys |
| `assetId` | int or string | `10001` | Existing image ID or relative PNG path under this MOD's `assets/` |
| `rare` | int | required | Rarity display |
| `type` | int[] | required | Colors: `1` green, `2` red, `3` blue, `4` white |
| `tagMap` | dict&lt;int,int&gt; | required | Runtime Tags; `3` tactical, `4` drone, `8` pilot |
| `mainType` | int | `1` | Top-level UI category; normal Cards keep `1` |
| `tag` | string[] | `{}` | Text Tags |
| `mainTag` | string[] | `{}` | Main label text |
| `subTag` | string[] | `{}` | Secondary label text |
| `iconId` | int | `0` | Additional icon ID |
| `keywordList` | table[] | `{}` | Detail keywords using `keywordId` and optional `isSelf=1` |

`type` controls color only. Use `tagMap`, not color, to identify tactical, drone, or pilot Cards.

`tagMap` is runtime classification. `tag`, `mainTag`, and `subTag` are displayed text and do not replace it.

A string `assetId` is relative to the current MOD's `assets/` directory and must be a `.png` path:

```lua
assetId = "cards/continuous_shot_alpha.png"
```

This resolves to `assets/cards/continuous_shot_alpha.png`.

## Tactical Cards

Tactical Cards mainly resolve through `skillList`:

```lua
cardId = 2061,
targetIds = { 40 },
costEffect = 8012,
skillList = { 206101 },
upgrade = 2062,
extend = {
    linkCards = { 2097 },
},
```

`upgrade=2062` links the upgraded Card. Card `2062` must be provided as a complete `card_def` entry.

`extend.linkCards={2097}` displays **Continuous Shot β** as a related Card. It does not create that Card; Effect `1534` performs creation.

Consumed tactical Cards add `extend.stackFinArea` when needed.

## Drone Cards

Drone Cards enter the battlefield and remain in play. In addition to deployment Skills, they need base HP, an attack Skill, direction, and a model.

### Basic Example: Logistics Drone

**Logistics Drone** (Card `2023`) spends 1 Power, selects a friendly placement Grid, draws 1 Card on deployment, and remains with 2 HP and a 1-damage basic attack.

```lua
{
    cardId = 2023,
    name = "Logistics Drone",
    rare = 3,
    type = { 4 },
    tagMap = {
        [4] = 1,
    },
    targetIds = { 21 },
    costEffect = 8012,
    skillList = { 202301 },
    attkSkill = 501,
    dir = 6,
    hp = 2,
    upgrade = 2024,
    assetId = 11002,
    mainType = 1,
    mainTag = { "Drone" },
    extend = {
        modelId = "drone_ace1_defense_s",
    },
}
```

```text
Card 2023: Logistics Drone
├─ targetIds → Target 21: friendly placement Grid
├─ skillList → Skill 202301: draw 1 Card on deployment
├─ hp=2: base HP
├─ attkSkill=501: 1-damage basic attack
├─ dir=6: battlefield direction
└─ extend.modelId: model creation and display
```

#### `attkSkill`: Common Basic Attack Skills

| `attkSkill` | Basic attack result |
| --- | --- |
| `500`–`511` | Deal 0–11 damage respectively |
| `515` | Deal 15 damage |
| `520` | Deal 20 damage |

For example, `501` deals 1 damage and `505` deals 5. These are existing Skill IDs, not a formula; do not invent missing IDs `512` through `514`. Create a new [`battle_skill_def`](battle_skill_def.md) entry for other behavior.

`extend.modelId` is required to create and display a drone. A missing model may allow configuration installation but fail creation, preload, or display.

### Combined Example: Multi-strike Drone

**Multi-strike Drone** (Card `2037`) has Combo 1 and gains +2/+0 while its direction connection is active:

```lua
staticList = { 203752 },
attkSkill = 501,
dir = 6,
dirSkillList = { 203751 },
hp = 2,
extend = {
    modelId = "drone_ace1_attack_s",
},
```

`staticList` provides Combo. `dirSkillList` may reference `static_skill_def.id` even though its name contains `Skill`. See [`static_skill_def`](static_skill_def.md).

### `stackcard`: Allowed Integration Hosts

`stackcard` lists Card IDs that may accept this Card as an integrated Card. An empty list disallows integration through this rule.

The game compares each host's `cardId`; this is not a Tag list and does not automatically include new Cards of the same type.

### `stackcardSkill`: Ability Granted to the Host

`stackcardSkill` lists Skill or Static Skill IDs added to the host during integration and removed with the integrated Card.

```lua
stackcardSkill = { 217751 },
```

The game first searches `battle_skill_def.skillId`, then `static_skill_def.id`. Do not use the same ID in both tables for different abilities.

### `deviceStackIcon`: Integration Icon

```lua
deviceStackIcon = { 7 },
```

This field controls display only and does not replace `stackcard` or `stackcardSkill`.

### `areaSkillList`: Listen While in an Area

`areaSkillList` maps Area ID to Skill ID lists. The Card listens to those Skills while it remains in the matching Area.

**Emergency Repair** (Card `7599`) listens to Skill `759902` while in Scrap (Area `4`):

```lua
areaSkillList = {
    [4] = { 759902 },
}
```

One Card may define different lists for several Areas. Only the current `area` entry is read.

### `extend.forceMove`: Override Drone Exit Area

`forceMove` changes a Card's destination only when it leaves the specified `old` Area and would otherwise enter `Desk`.

**Drone Prototype** (Card `2002`) moves from Drone to Scrap instead of Desk:

```lua
extend = {
    modelId = "drone_ace1_defense_s",
    forceMove = {
        old = 14,
        new = 4,
    },
}
```

It does not affect moves from other Areas or moves already targeting something other than Desk.

## Pilot Cards

Pilot Cards select a unit they can board and combine Skills, Static Skills, and `hero_def`.

**Sharo** (Card `21064`) damages the boarded unit by 1 when boarding and at the start of each round, then grants tactical damage +1:

```lua
{
    cardId = 21064,
    name = "Sharo",
    rare = 2,
    type = { 3 },
    tagMap = {
        [8] = 1,
        [302] = 1,
    },
    targetIds = { 22 },
    costEffect = 8011,
    skillList = { 2106401, 2106402 },
    staticList = { 2106451, 2106452 },
    hp = 3,
    assetId = 305,
    mainType = 1,
    mainTag = { "Drone" },
    keywordList = {
        { keywordId = 1004 },
    },
    extend = {
        heroId = 21064,
    },
}
```

```text
Card 21064: Sharo
├─ targetIds → Target 22: friendly unit that can carry a pilot
├─ skillList → Skill 2106401, 2106402
├─ staticList → Static Skill 2106451, 2106452
├─ hp=3: base HP of the pilot Card
└─ extend.heroId → hero_def 21064: pilot data and display
```

`skillList` handles active and triggered resolution. `staticList` provides continuous rules. `extend.heroId` must reference an existing `hero_def.id` for complete pilot display.

## `modelId` and Available Models

`extend.modelId` selects an existing client model for drone creation and preload. A string cannot import a new model.

| `modelId` | Example Card | Result |
| --- | --- | --- |
| `drone_ace1_defense_s` | Logistics Drone (`2023`) | Draw 1 on deployment; 2 HP; 1-damage attack |
| `drone_ace1_attack_s` | Multi-strike Drone (`2037`) | Combo 1; +2/+0 with direction connection |

Browse screenshots in the [Game Model Catalog](../concepts/card-models.md). Models may change with the client version. Reuse only models confirmed in the target version.

Adding a custom model requires a separate asset import capability; changing `modelId` alone is not enough.

## Adding `card_def` in a MOD

Place files under:

```text
config/card_def/config/*.lua
```

Use `installKey="cardId"`. This minimum example provides the eight required fields:

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            name = "Example: Power Pulse",
            rare = 1,
            type = { 4 },
            tagMap = {
                [3] = 1,
                [31] = 1,
            },
            targetIds = { 40 },
            costEffect = 8012,
            skillList = { 910001 },
        },
    },
}
```

Omitted fields use defaults such as `useConditions={0}`, `staticList={}`, `extraCost={}`, `hp=0`, `assetId=10001`, `mainType=1`, and `extend={}`.

Other configuration may reference the new ID:

```text
act_card_pool_def.base_pool.cardId → 910001
Card rewards in reward_def         → 910001
Another Card's upgrade             → 910001
Another Card's extend.linkCards    → 910001
Create-Card Effects                → 910001
```

Installing only `card_def.config` makes the Card queryable but does not add it to a pool or reward. Add it through `act_card_pool_def` or `reward_def` before the player can obtain it.
