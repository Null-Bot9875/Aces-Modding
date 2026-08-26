# Configuration field reference

This page covers the eight configuration types used by the current `card-pack` and `complete-mod`.

| Action label | Meaning |
| --- | --- |
| Must change | New content requires a new ID or player-facing value |
| Change by design | The field may change, but must use an existing valid reference |
| Change together | Other references must be updated at the same time |
| Retain initially | The field belongs to a complete row, but version one does not define a safe editing contract; retain the example value |

## Card: `card_def.config`

The Card author format requires only eight fields. The adapter supplies defaults for the remaining fields.

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `cardId` | int | Unique Card configuration ID and target of pool or other references | Must change; change together |
| `name` | string | Original Card name; translations may use `language/language.csv` | Must change |
| `rare` | int | Rarity value | Change by design; compare with a same-type Core Card |
| `type` | list<int> | Card type ID list | Use a confirmed combination initially |
| `tagMap` | dict<int,int> | Tag set in `tagId -> value` form | Use a confirmed combination initially |
| `targetIds` | list<int> | Selectable Target IDs | Change by design; every Target must exist |
| `costEffect` | int | Cost Effect applied when the Card is played | Change by design; the Effect must exist |
| `skillList` | list<int> | Skill IDs executed by the Card in order | Change by design; every Skill must exist |

See the [Card configuration tutorial](../content/card.md) for automatic defaults, image `assetId`, and installation checks. See [Reusable Core configuration](core-configs.md) for the currently confirmed combination.

## Card pool: `act_card_pool_def.base_pool`

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `cardId` | int | Candidate Card in this pool | Change together with `card_def.cardId` |
| `baseId` | int | Core unit base ID allowed to use this candidate | Retain `501` initially |
| `poolId` | int | Pool group ID; must match batch `installValue` | Must change; change together with the reward |
| `minBaseLevel` | int | Minimum unit level | Retain `1` initially |
| `maxBaseLevel` | int | Maximum unit level | Retain `10` initially |
| `limitActIds` | list<int> | Campaign scope restriction | Retain `{ -1 }` initially |

One pool may contain multiple rows. `replace` replaces the complete group sharing the same `poolId`.

## Card test reward: `reward_def.config`

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `id` | int | Reward configuration ID | Retain example `10003`; test saves only |
| `title` | string | Original reward title | Change by design |
| `icon` | string | Existing reward icon reference | Retain `image_decision` initially |
| `value` | lua | Reward contents; the example uses `value[1].card` | Change according to the table below |
| `cardId` | int | Card reference field attached to reward presentation | Retain `0` initially |
| `chipId` | int | Chip reference field attached to reward presentation | Retain `0` initially |
| `itemId` | int | Item reference field attached to reward presentation | Retain `0` initially |

Example `value`:

```lua
value = {
    {
        card = {
            count = 3,
            choose = 1,
            pool = { 990001 },
        },
    },
}
```

| Child field | Meaning |
| --- | --- |
| `count` | Number of candidates generated from the pool |
| `choose` | Number of candidates that may be selected |
| `pool` | Card pool ID list; change together with `base_pool.poolId` |

The example overrides `reward_def 10003`. It is a dedicated test-save mechanism, not a new reward ID for distributed content.

## Enemy: `robot_def.config`

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `id` | int | Unique Enemy configuration ID and target of the Node reference | Must change; change together with the Node |
| `name` | string | Original Enemy configuration name | Must change |
| `groupId` | int | Internal Enemy classification field | Retain `0` initially |
| `baseId` | int | Core unit base data, appearance, and some UI information | Change by design; use only validated values |
| `chainId` | int | Action chain used by the Enemy | Must change; change together with `sequence` |
| `newCards` | int | Draw or refill-related field in a complete Enemy row | Retain `0` initially |
| `noSuffle` | int | Shuffle-related switch in a complete Enemy row | Retain `0` initially |
| `roundAction` | int | Turn-action-related field in a complete Enemy row | Retain `-1` initially |
| `noCardCheck` | int | Card-check-related field in a complete Enemy row | Retain `2` initially |
| `roomRobot` | int | Room-Enemy-related field in a complete Enemy row | Retain `0` initially |
| `robotType` | int | Enemy type value | Retain `1` initially |

Complete enums for the final seven fields are not yet public. Reusing their values preserves the validated example structure but does not create separate behavior guarantees.

## Enemy turn sequence: `robot_chain_def.sequence`

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `chainId` | int | Action-chain group ID; must match batch `installValue` | Must change; change together with the Enemy |
| `seqType` | int | Sequence type | Retain `2` for the two-turn example |
| `round` | int | Loop position represented by this row | Enter `1`, `2` in order |
| `circle` | int | Loop length in the example | Retain `2` for the two-turn example |
| `poolId` | int | Action pool read during this turn | Must change; change together with the action pool |

Version one documents only the two-turn loop formed by `seqType=2` and `circle=2`; other sequence-type enums are not provided.

## Enemy action pool: `robot_chain_def.config`

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `id` | int | Unique action-row ID | Must change |
| `type` | int | Action-row type | Retain `1` initially |
| `poolId` | int | Action-pool group ID; must match batch `installValue` | Must change; change together with the sequence |
| `weight` | int | Relative selection weight in one action pool | Change by design |
| `useConditions` | list<int> | Conditions for using the action | Retain `{}` initially |
| `cardId` | int | Existing Card executed by the Enemy | Change by design; battle validation required |
| `assetId` | string | Existing action presentation reference | Validate together with the Card |
| `extend` | lua | Action extension parameters | Retain `{}` initially |

Version one does not provide the `type` enum, condition authoring, or custom `extend` rules.

## Node: `act_node_def.config`

`act_node_def.config` has no simplified author format and requires a complete row. Fields are divided into directly editable references and values that should initially remain unchanged.

### Directly editable or referenced fields

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `id` | int | Unique Node ID and target of the refresh-group reference | Must change; change together with the refresh row |
| `mainType` | int | Main Node classification | Retain `1` for the battle-Node example |
| `type` | int | Node type | Retain `1` for the battle-Node example |
| `showType` | int | Node display type | Retain example `1` |
| `name` | string | Original Node name | Must change |
| `subheading` | string | Original Node subtitle | Must change |
| `desc` | string | Original Node description | Must change |
| `summary` | string | Original Node summary | Must change |
| `battleReward` | list<int> | Reward group IDs from `act_node_def.node_reward` | Retain `{ 100001 }` initially |
| `robot` | int | Enemy ID used by the battle | Change together with `robot_def.id` |
| `gridPoolList` | list<int> | Player-side battle Grid Pool list | Retain `{ 200 }` initially |
| `optionRandom1` | list<map> | First option candidate group; each item has `id` and `weight` | Retain Option `10051` initially |
| `conditionGroup` | int | Node entry condition group | Retain `99` initially |
| `skybox` | string | Existing battle background reference | Retain `Nebula_Coral_4K_3` initially |

`battleReward` does not directly reference `reward_def`:

```text
act_node_def.config.battleReward
  -> act_node_def.node_reward
  -> reward_def.config
```

### Complete-row fields to retain initially

| Field | Type | Current scope |
| --- | --- | --- |
| `replaceNode` | lua | Node replacement rules; retain `{}` |
| `finishReplaceNode` | lua | Post-completion Node replacement rules; retain `{}` |
| `failReplaceNode` | lua | Post-failure Node replacement rules; retain `{}` |
| `finish` | int | Completion-state-related field; retain `0` |
| `finishReward` | list<int> | Non-battle completion reward field; retain `{ 0 }` |
| `winCondition` | list<int> | Battle win-condition references; retain `{}` |
| `conditionRewards` | dict<int,int> | Condition-to-reward mapping; retain `{}` |
| `robotChips` | list<int> | Enemy Chip references; retain `{}` |
| `robotGridPoolList` | list<int> | Enemy-side Grid Pools; retain `{}` |
| `robotInitGrid` | dict<int,int> | Enemy initial Grid setup; retain `{}` |
| `playerInitGrid` | dict<int,int> | Player initial Grid setup; retain `{}` |
| `battleExtend` | lua | Battle extension parameters; retain `{}` |
| `heroList` | list<int> | Participating-character-related list; retain `{}` |
| `shopId` | int | Shop Node reference; retain `0` for a battle Node |
| `optionType` | int | Option organization type; retain example `1` |
| `optionStatic` | list<int> | Static option list; retain `{ 0 }` |
| `optionRandom2` | list<map> | Second option candidate group; retain `{}` |
| `optionRandom3` | list<map> | Third option candidate group; retain `{}` |
| `heroIds` | list<int> | Player-side character restriction; retain `{}` |
| `enemyHeroIds` | list<int> | Enemy-side character restriction; retain `{}` |
| `dialogueId` | int | Dialogue reference; retain `0` |
| `dontShowEnemyEntrance` | int | Enemy entrance presentation switch; retain `0` |
| `useRetreat` | int | Retreat-related switch; retain `0` |
| `endTimeline` | string | Ending Timeline reference; retain an empty string |
| `showLink` | int | Map-link presentation switch; retain `0` |

Field names identify their broad feature areas but do not mean that version one opens those features for configuration. A capability request or a later dedicated tutorial is required before changing them.

## Existing Node Group: `act_node_refresh_def.config`

Version one uses existing EP `1061` Groups and does not require new Group definition. See the [EP 1061 Node Group catalog](node-groups.md) for all 44 existing Groups.

| Field | Type | Meaning | Action |
| --- | --- | --- | --- |
| `groupId` | int | Existing EP `1061` map entry Group | Select from the catalog and synchronize `installValue` |
| `nodeId` | int | Node produced by this entry point | Change together with `act_node_def.id` |
| `weight` | int | Relative candidate selection weight inside the group | Set for content balance; human testing may raise it temporarily |
| `limitBaseId` | list<int> | When non-empty, only listed unit base IDs may use the candidate | Retain `{}` in version one |
| `nodeLimit` | int | Normal repetition limit for the same Node | Retain `1` in version one |

See the [EP 1061 Node Group catalog](node-groups.md) for `replace`, `append`, every EP position, and disable-recovery rules.

## ID synchronization checklist

| Changed ID | Locations that must change together |
| --- | --- |
| Card `cardId` | `card_def.cardId`, pool `cardId`; if used as an Enemy action, action-pool `cardId` as well |
| Card pool `poolId` | `base_pool.installValue`, every row `poolId`, reward `value.card.pool` |
| Enemy `id` | `robot_def.id`, Node `robot` |
| Action-chain `chainId` | `robot_def.chainId`, `sequence.installValue`, every sequence-row `chainId` |
| Action-pool `poolId` | Sequence-row `poolId`, action-pool `installValue`, every action-row `poolId` |
| Action-row `id` | The corresponding action-row `id` |
| Node `id` | `act_node_def.id`, refresh-row `nodeId` |

Successful loading proves only that structure and references passed basic checks. Card, Enemy, and Node still require separate human in-game tests.
