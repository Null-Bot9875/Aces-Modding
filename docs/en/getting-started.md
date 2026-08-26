# Getting started

This tutorial uses the `card-pack` human-validation candidate to complete a first local configuration MOD.

The template overrides Core `rewardId=10003` and is limited to a dedicated test save. See the [manual testing checklist](manual-testing.md) for the complete version-one record.

## Preparation

- Confirm the game version. `mod.json.supportedGameVersions` uses `major.minor`, such as `1.0`.
- Use a text editor that supports UTF-8 without BOM.
- Exit the game before copying or changing MOD files.
- Use a new Rogue run so that the test reward does not affect a normal save.

## 1. Copy the template

The `Mods/` directory is located beside the game executable:

```text
<game-root>/
  <game-executable>.exe
  Mods/
```

Copy the entire [`templates/card-pack`](../../templates/card-pack/README.en.md) directory to:

```text
<game-root>/Mods/example.cardpack/
```

`mod.json` must be directly inside that directory:

```text
Mods/example.cardpack/mod.json            # correct
Mods/example.cardpack/card-pack/mod.json  # incorrect
```

## 2. Change the MOD identity

Open `mod.json` and change at least:

```json
{
  "id": "author.examplecard",
  "name": "Example Card Pack",
  "author": "MOD Author",
  "version": "0.1.0",
  "supportedGameVersions": ["1.0"]
}
```

The ID is normalized to lowercase and must contain at least two parts separated by `.`. The recommended format is `author-or-organization.project`.

The folder name may differ from the ID, but matching names make troubleshooting easier.

## 3. Change the example Card

Open:

```text
config/card_def/config/cards.lua
```

For the first edit, change only:

- `cardId`: use a positive integer not used by another MOD;
- `name`: change the display name;
- `rare`: retain the example or reference an existing Card;
- `type`, `tagMap`, `targetIds`, `costEffect`, and `skillList`: retain the example values.

Change the matching `cardId` in:

```text
config/act_card_pool_def/base_pool/cards.lua
```

## 4. Enable and cold-start

1. Launch the game and open the MOD manager.
2. Enable the new MOD ID.
3. Apply the selection.
4. Exit and restart the game.

The current version loads MODs during cold start. Changes to enabled state, order, or configuration require a restart; runtime hot reload is not available.

A successful `main.lua` load writes:

```text
Example Card Pack loaded
```

## 5. Verify the Card

The template uses test pool `990001` to override existing reward `10003`:

1. Start a new Rogue run with `baseId=501`.
2. Reach a card reward that resolves to `rewardId=10003`.
3. The choices should contain the example Card and Core Card `2000`.
4. Select the example Card and confirm that it enters the current Rogue deck.
5. Restart and continue the same run, then confirm that the Card remains present.
6. Draw the Card in battle, select a valid target, and play it.
7. Save the matching `Player.log`.

After testing, disable the template, cold-start, and create a new run, then confirm that the example Card no longer appears. A distributed MOD should replace the test override for `rewardId=10003` with its final content design.

## Next steps

- [MOD package structure](mod-package.md)
- [General configuration format](configuration.md)
- [Card configuration tutorial](content/card.md)
- [PNG assets](assets.md)
- [Localization](localization.md)
- [Troubleshooting](debugging.md)
- [Version-one manual testing checklist](manual-testing.md)
