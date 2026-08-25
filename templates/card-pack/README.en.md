# card-pack template

This is the current template for a regular tactical Card. The example reuses existing game Skills, Targets, cost effects, and Tags; it does not add custom battle logic.

## Contents

```text
card-pack/
  mod.json
  main.lua
  config/
    card_def/config/cards.lua
    act_card_pool_def/base_pool/cards.lua
    reward_def/config/card_reward.lua
```

- Card `910001`: `Example: Fire Drone`
- Test card pool `990001`
- Existing reward override `10003`
- Compatible unit `baseId=501`
- `assetId` is omitted, so the default Core image `10001` is used

## Changes required before use

- Change the ID, name, author, and version in `mod.json`;
- change new Card and pool IDs to avoid conflicts with other MODs;
- change the Card display name and behavior references;
- remove or replace the test override for `rewardId=10003` before distribution.

## Test procedure

1. Copy the entire directory to `Mods/example.cardpack/` beside the game executable.
2. Enable `example.cardpack` in the MOD manager, apply the selection, and restart the game.
3. Start a new Rogue run with `baseId=501`.
4. Reach a card reward that resolves to `rewardId=10003`.
5. The reward choices should contain `Example: Fire Drone` and Core Card `2000`.
6. Select the example Card and confirm that it enters the current Rogue deck.
7. Restart and continue the same run, then confirm that the Card remains present.
8. Draw the Card in battle, select a valid target, and play it.

Disable the template after testing so that the test reward override does not continue affecting normal play.

See the [Card configuration tutorial](../../docs/en/content/card.md) for field details.
