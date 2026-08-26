# EP 1061 Node Group catalog

This page publishes every `groupId` currently used by the EP `1061` map. A Node Group is an existing content entry point on the map. Regular content only needs to select an existing Group; creating a new Group is unnecessary.

Connection format:

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "append",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

`installValue` and the row `groupId` must match. `nodeId` must reference an installed complete Node. Regular content should normally use `append` to retain Core candidates, then set `weight` according to content balance. Human testing may use a temporarily high weight, but distributed content requires rebalancing.

## Naming and usage rules

EP `1061` currently references 44 distinct Groups. Existing IDs are organized as follows:

| Range | Current rule |
| --- | --- |
| `1401–1465` | Regular route content groups. The basic pattern is `1400 + (layer - 1) * 10 + usage suffix` |
| Suffix `1` | Primarily regular battle pools |
| Suffix `2` | Primarily random event pools |
| Suffix `3` | Primarily special battle pools |
| Suffix `4` | Fixed single Nodes whose exact purpose varies by layer |
| Suffix `5` | Used only by a few special positions and not a general type rule |
| `2001–2008` | Cross-layer functional Node Groups such as entry battle, shop, supply station, wormhole, and companion content |
| `2371–2376` | Fixed layer-seven ending sequence |
| `2100–2115` | Special story chain on `layer=9999`, not a regular map-layer position |

These rules describe the existing map; they are not a new-ID generation scheme. The map also contains reuse exceptions: `1431` is used on layers 3 and 4, while `1432` is used on layers 4, 5, and 6. Group selection must follow the actual tables below rather than deriving nonexistent Groups from an ID pattern.

## Regular route Groups

| Group | Layer | EP 1061 map positions | Current content pool |
| --- | --- | --- | --- |
| `1401` | 1 | `230021, 230022, 230031, 230032` | 12 candidates; mainly regular battles, plus “追踪信号” |
| `1402` | 1 | `230041, 230042, 230043, 230051, 230052, 230053` | 20 random-event candidates |
| `1404` | 1 | `230082` | Fixed “遇袭” |
| `1405` | 1 | `230061, 230062, 230063` | Three battle candidates: 装甲堡垒, 连击核心, 穿甲炮台 |
| `1411` | 2 | `231031, 231033, 231051, 231052, 231061, 231063` | Six regular battle candidates |
| `1412` | 2 | `231041, 231042, 231043, 231053, 231071` | 21 random-event candidates |
| `1413` | 2 | `231032, 231062` | Three special battle candidates |
| `1414` | 2 | `231082` | Fixed “夏洛” |
| `1421` | 3 | `232021, 232022, 232041, 232043, 232061, 232062` | Nine regular battle candidates |
| `1422` | 3 | `232031, 232032, 232033, 232051, 232053, 232063, 232071` | 23 random-event candidates |
| `1423` | 3 | `232052` | Fixed special battle “白矮星-鸣响” |
| `1424` | 3 | `232082` | Fixed battle “归来的猎户座” |
| `1431` | 3, 4 | `232073, 233021, 233022, 233023, 233041, 233051, 233061, 233062, 233063` | Nine regular battle candidates |
| `1432` | 4, 5, 6 | `233031, 233032, 233033, 233042, 233053, 234011, 234012, 234023, 234031, 234043, 234052, 235022, 235051, 235053` | 22 random-event candidates |
| `1433` | 4 | `233043` | Fixed special battle “猎户座-狂热” |
| `1434` | 4 | `233082` | Fixed “奥斯陆” |
| `1441` | 5 | `234001, 234002, 234003, 234013, 234021, 234033, 234042` | 17 regular battle candidates |
| `1443` | 5 | `234032, 234041` | Two special battle candidates: 白洞, 黑洞 |
| `1444` | 5 | `234060` | Fixed “铁木” |
| `1451` | 6 | `235021, 235023, 235041, 235043` | 21 battle candidates |
| `1453` | 6 | `235042, 235052` | Two special battle candidates: 猎户座-决斗, 伊米尔改-龙 |
| `1454` | 6 | `235071` | Fixed “希尔达” |
| `1465` | 7 | `236007` | Fixed ending Node “极境” |

A regular battle Node normally starts with the target layer's suffix-`1` Group. `replace` makes the custom Node occupy every position using that Group. `append` adds the custom Node to weighted selection alongside current candidates.

Replacing an event pool, special battle, or fixed Node changes the route's existing content structure. Version one provides only a battle-Node example, so these replacements still require separate human validation.

## Cross-layer functional Groups

| Group | Layer | EP 1061 map positions | Current content |
| --- | --- | --- | --- |
| `2001` | 1 | `230001` | Fixed entry battle “伊米尔改” |
| `2002` | 1–6 | `230072, 231072, 232042, 232072, 233052, 234022, 235062` | Fixed shop “商店-1” |
| `2003` | 2, 4, 5, 6 | `231073, 233072, 234051, 235032` | Fixed supply station |
| `2004` | 1 | `230024` | Fixed “虫洞” |
| `2007` | 2 | `231022` | Two companion candidates: “同行” and “同行？” |
| `2008` | 3 | `232023` | Fixed “追踪信号” |

`2005` and `2006` are not referenced by the current EP `1061` map and therefore are not selectable positions in this catalog. An unused number is not a free ID for MOD ownership.

## Layer-seven ending sequence

| Group | Map position | Current fixed Node |
| --- | --- | --- |
| `2371` | `236001` | 白矮星-鸣响 |
| `2372` | `236002` | 猎户座-决斗 |
| `2373` | `236003` | 白鸟-渐隐 |
| `2374` | `236004` | 伊米尔改-龙 |
| `2375` | `236005` | 十字星的残响 |
| `2376` | `236006` | 镜子 |

These Groups form a continuous ending chain followed by “极境” in `1465`. Replacing any of them can alter the ending flow, so they are not suitable as initial entry points for a regular battle Node.

## `layer=9999` special chain

| Group | Map position | Current fixed Node |
| --- | --- | --- |
| `2100` | `910001` | 一位掮客 |
| `2101` | `910011` | 将军 |
| `2102` | `910021` | 自成长核心 |
| `2103` | `910031` | 指挥船 |
| `2104` | `910041` | 熟悉的陌生人 |
| `2114` | `910042` | 合流1 |
| `2105` | `910051` | 火力中枢 |
| `2115` | `910052` | 补给站 |
| `2111` | `910012` | 意外的相遇 |

These positions are outside regular map layers and form a specially connected chain. A custom Node intended for the regular route should not select these Groups.

## `replace` and `append`

| Operation | Result |
| --- | --- |
| Omitted `operation` or `replace` | Removes Core rows from the target Group before installing MOD rows; every map position using the Group reads the new candidate pool |
| `operation="append"` | Retains Core rows and adds MOD rows; every position using the Group can select the custom Node by weight |

One Group may be reused by multiple positions or layers. Every listed position must be considered before modification. Disabling a MOD does not rewrite map results already stored in an existing run; recovery validation requires a cold start and a new EP `1061` run.
