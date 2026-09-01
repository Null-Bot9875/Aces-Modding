# Effect Attribute Reference

> Attr is a numeric value, status, or rule marker attached to a Card during battle.

`Pierce` is a Card Tag and damage event, not an Attr.

## Where Attr names are used

| Field | Purpose |
| --- | --- |
| `battle_effect_def.config.extend.attrTarget` | Attr name to remove for `event=110` |
| `battle_skill_def.config.triggerEx.attr` | Attr name matched by `trigger=131` |

`event=110` only removes an existing Attr of the same name from the target Card.

## Common Attr

| Attr | In-game name | Effect |
| --- | --- | --- |
| `attkShield` | Shield | Negates the next damage, then is removed |
| `attkDelay` | Delay | Skips the next attack, then is removed |
| `attkTwice` | Combo | Each point adds one extra resolution to an attack; max 30 |
| `costVal` | Energy cost | Modifies Card energy cost |
| `attkAdd` | Attack | Modifies unit attack |
| `hpAddDrone` | Armor | Modifies unit maximum HP |
| `damage` | Damage taken | Modifies damage received |
| `damageAdd` | Damage | Modifies damage dealt by the Card |
| `noOtherChoose` | Cannot be targeted by enemies | Enemy cannot select this Card |
| `droneMove` | Consume | Moves a unit from Drone to the specified [Area](areas.md) instead of discard |

## Specialized Attr

Reuse these only after checking their existing Card/Skill/Condition requirements.

| Attr | In-game name | Effect | Existing use |
| --- | --- | --- | --- |
| `attkShieldEx` | Golden Seal | Negates one damage and removes the Skill providing it | One existing Card only |
| `stanceAdd` | Sword Stance | Adds Sword Stance damage | One existing Card only |
| `deathAdd` | BlackDwarf death marker | Records hits for its Skill | BlackDwarf only |
| `boomAdd` | Self-destruct countdown marker | Records self-destruct countdown | Destructive Timer / Timed Fuze |
| `negaAdd` | Derogatory narrative | Modifies remaining counters | ACE-004 Elysium only |

## Legacy designs

Do not use: `deadTrigger`, `attkBack`, `relive`, `noChoose`.
