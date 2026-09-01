# `card-pack` Template

Use this template to add one tactical Card with its own Skill and Effect:

```text
Card 910001: Example: Overloaded Shot
  -> Skill 990801: active resolution
  -> Effect 990701: deal 4 damage to the selected enemy unit
```

The Card is added to existing Card pool `10003`. Existing Cards in that pool are preserved.

If this is your first MOD, read [Start Making a MOD](../../docs/en/getting-started.md) first.

## Included Files

```text
card-pack/
  mod.json
  main.lua
  locales/en_us/mod.json
  config/
    card_def/config/cards.lua
    battle_skill_def/config/skills.lua
    battle_effect_def/config/effects.lua
    act_card_pool_def/base_pool/cards.lua
```

- Card: `910001`
- Custom Skill: `990801`
- Custom Effect: `990701`
- Existing Target: `40`, select one enemy unit
- Existing cost Effect: `8012`, spend 1 Power
- Card pool: `10003`
- Compatible base: `baseId=501`
- No `assetId` is provided, so installation fills the default image `10001`

## Add the Card to an Existing Pool

Normal Card rewards select candidates from Card pool `10003`. Add the new Card by appending entries to that pool:

```lua
return {
    installKey = "poolId",
    installValue = 10003,
    operation = "append",
    rows = rows,
}
```

The default operation for `act_card_pool_def.base_pool` is `append`. The template still writes it explicitly so the behavior is clear. Existing pool members are preserved and the MOD Card is added.

## Increase Appearance Chance

`act_card_pool_def.base_pool` has no separate `weight` field. Add the same member more than once to increase its chance. This template adds 10 copies:

```lua
local CARD_POOL_ENTRY_COPIES = 10
```

Each entry adds one random slot. The final reward candidates are deduplicated by `cardId`, so the same Card will not appear ten times in one reward.

This increases the chance but does not guarantee an appearance. Set `CARD_POOL_ENTRY_COPIES` to `1` for a normal chance, or adjust it for your balance target.

## What to Change After Copying

- Change `mod.json.id`, name, author, and version.
- Replace the new Card, Skill, and Effect IDs to avoid conflicts with other MODs.
- Change the Card name, cost, Target, Skill, and Effect.
- Adjust `CARD_POOL_ENTRY_COPIES`.
- Confirm that `baseId`, `poolId`, and reused IDs still exist in the target game version.

## Installation and Test

1. Copy the whole directory to `Mods/aces.example.cardpack/` beside the game executable.
2. Enable **Custom Card Template** in the MOD manager, apply the selection, and restart the game.
3. Start a new Rogue run with `baseId=501`. An existing run may already contain the old pool state.
4. Enter a normal Card reward that uses pool `10003`.
5. Confirm that existing Cards remain and **Example: Overloaded Shot** can appear.
6. Select the Card and confirm that it enters the current deck.
7. Draw and play it in a later battle. Select exactly one enemy target.
8. Confirm that the target takes 4 damage and the Card leaves the hand normally.
9. Disable the MOD, restart, and begin a new run. The example Card should no longer appear.

## Completion Checklist

- Existing Cards remain in Card pool `10003`.
- **Example: Overloaded Shot** can appear as a reward, enter the deck, and be played.
- The Card selects one enemy target and deals 4 damage.
- The default image displays correctly. If you replace `assetId`, confirm that the new resource exists in the target version.
- After disabling the MOD and starting a new run, the example Card no longer appears.

Playing the Card is still required to verify target selection, resolution, and image display. See [Installation and Verification](../../docs/en/getting-started.md#installation-and-verification) for the shared checklist.

Field references:

- [`card_def` Configuration Reference](../../docs/en/config/card_def.md)
- [`battle_skill_def` Configuration Reference](../../docs/en/config/battle_skill_def.md)
- [`battle_effect_def` Configuration Reference](../../docs/en/config/battle_effect_def.md)
