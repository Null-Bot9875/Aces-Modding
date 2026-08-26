# Configuration and reference guide

This directory answers the two most common configuration questions:

- [Reusable Core configuration](core-configs.md): which existing Cards, Skills, Targets, Effects, and Enemy base data have been confirmed for version one;
- [EP 1061 Node Group catalog](node-groups.md): all 44 Groups used by the current map, including naming patterns, map positions, and existing purposes;
- [Configuration field reference](config-fields.md): what the fields used by the templates and complete example mean, which references must change together, and which fields should retain the example values during initial work.

Status labels:

| Label | Meaning |
| --- | --- |
| Used by an example | The current `card-pack` or `complete-mod` uses the value, with static configuration evidence |
| Meaning confirmed | Same-version configuration or runtime code confirms the referenced object and its basic purpose |
| Human validation pending | Full in-game operation from a MOD-author perspective is incomplete |
| Not promised in version one | The value may exist in Core but is outside the current public support scope |

An existing Core configuration is not automatically a formal MOD API. Version one promises only the documented configuration formats and reference scope. Other same-version Core values may be studied, but their complete reference chains and in-game behavior still require validation before MOD use.

Configuration workflow:

1. Copy a runnable structure from the [Card](../content/card.md), [Enemy](../content/enemy.md), or [Node](../content/node.md) tutorial.
2. Select a confirmed starting combination from [Reusable Core configuration](core-configs.md).
3. For a Node, select the target position from the [EP 1061 Node Group catalog](node-groups.md).
4. Change fields and synchronized references according to the [Configuration field reference](config-fields.md).
5. Complete in-game validation with the [Manual testing checklist](../manual-testing.md).

Complete Core rows will be supplied per game version in [`game-lua`](../../../game-lua/README.en.md). That archive is not available yet, so this directory lists only the verified version-one starting values.
