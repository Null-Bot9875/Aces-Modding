# What a MOD package contains

## Directory structure

A MOD is placed in `Mods/` beside the game executable. Only direct child directories of `Mods/` are scanned.

```text
<mod-root>/
  mod.json                         # required
  main.lua                         # required
  local_server/main.lua            # optional
  locales/<language>/mod.json      # optional: manager name and description
  config/<module>/<sheet>/*.lua    # optional: configuration batches
  language/language.csv            # optional: configuration text translations
  assets/<folders>/*.png           # optional: currently used for Card PNGs
```

All `.lua`, `.json`, and `.csv` text files use UTF-8 without BOM.

## `mod.json`

Minimal example:

```json
{
  "id": "author.example",
  "name": "Example MOD",
  "author": "MOD Author",
  "version": "0.1.0",
  "supportedGameVersions": ["1.0"]
}
```

| Field | Required | Rule |
| --- | --- | --- |
| `id` | Yes | After lowercase normalization, must match `^[a-z0-9]+(\.[a-z0-9]+)+$` |
| `name` | Yes | Default display name in the MOD manager |
| `author` | Yes | Author or organization |
| `version` | Yes | MOD version |
| `supportedGameVersions` | Yes | Non-empty array; every entry uses `major.minor` |
| `description` | No | Default description in the MOD manager |
| `dependencies` | No | Array of required MOD IDs |

Installing several MODs with the same ID blocks all duplicate instances. `dependencies` produces warnings for missing, disabled, or incorrectly ordered dependencies; it does not reorder MODs automatically.

## `main.lua`

The entry point must return an object created by `Mod.CreateController()`:

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("Example MOD loaded")
end

return Main
```

A root `main.lua` is required even for a configuration-only MOD.

## `config/`

The directory declares the target configuration:

```text
config/<module>/<sheet>/<file>.lua
```

Example:

```text
config/card_def/config/cards.lua
```

The filename is used only for ordering and error locations. See [General configuration format](configuration.md).

## `language/` and `locales/`

- `language/language.csv`: translates player-facing text in configuration fields;
- `locales/<language>/mod.json`: translates the name and description shown in the MOD manager.

These directories serve different purposes. See [Localization](localization.md).

## `assets/`

The current author asset path supports Card PNG files inside the MOD:

```text
assets/cards/example.png
```

Card configuration:

```lua
assetId = "cards/example.png"
```

See [PNG assets](assets.md) for the full rules.

## Loading order

1. Core configuration loads first.
2. Enabled MODs load in MOD manager order.
3. Batches inside one MOD are ordered by normalized path.
4. Rows inside one batch are processed in listed order.
5. A later complete definition replaces an earlier definition with the same installation key.

The MOD manager saves the order and enabled state for the next launch. It does not hot-unload or reinstall MODs in the current process.
