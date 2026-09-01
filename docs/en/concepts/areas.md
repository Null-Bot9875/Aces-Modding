# Battle Area Reference

> An Area ID identifies the battle area containing a Card, unit, or player.

## Where Area IDs are used

| Field | Purpose |
| --- | --- |
| `battle_target_def.config.area` | Area ID list used to search for Targets |
| `battle_effect_def.config.value` | A single Area ID for `event=17`, the destination of a Card move |

## Area enum

| ID | Runtime name | Area | Description |
| --- | --- | --- | --- |
| `0` | `None` | None | Not assigned to an area |
| `1` | `Pool` | Deck | Card in the deck |
| `2` | `Hand` | Hand | Card in hand |
| `3` | `Desk` | Discard pile | Card in the discard pile |
| `4` | `Scrap` | Scrap area | Card in the scrap area |
| `5` | `Equip` | Equipment area | Legacy design; do not use |
| `6` | `Stack` | Resolution stack | Card entering resolution |
| `7` | `Base` | Unit base area | Area containing a unit |
| `8` | `Player` | Player or pilot | Area containing a player or pilot |
| `9` | `Ready` | Ready area | Card in the ready area |
| `10` | `Shuffle` | Shuffle area | Temporary area used while shuffling |
| `11` | `Slot` | Device slot | Legacy design; do not use |
| `12` | `Trap` | Trap area | Legacy design; do not use |
| `13` | `Grid` | Battlefield grid | Grid on the battlefield |
| `14` | `Drone` | Units or drones in play | Unit or drone Card in play |
| `15` | `Queue` | Card storage | Card waiting for later resolution |
