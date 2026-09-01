# Start Making a MOD

For your first MOD, copy the template closest to your goal instead of starting from an empty directory:

- [`card-pack`](../../templates/card-pack/README.en.md): add a Card and connect it to a Skill, Effect, and Card pool.
- [`node-pack`](../../templates/node-pack/README.en.md): add a three-choice event node.
- [`enemy-pack`](../../templates/enemy-pack/README.en.md): add a reachable battle node and an Enemy with an action chain.

## Directory Layout

The game scans only direct child directories under `Mods/`. A MOD needs at least `mod.json` and `main.lua`. Configuration Lua files must use the fixed path structure below:

```text
Game directory/
└─ Mods/
   └─ your.mod.id/
      ├─ mod.json
      ├─ main.lua
      └─ config/
         └─ configuration table/
            └─ sheet name/
               └─ file.lua
```

For example, a Card configuration file is placed at:

```text
config/card_def/config/cards.lua
```

The full path must follow `config/<table>/<sheet>/<file>.lua`.

The game reads these files automatically. Do not `require` each configuration file from `main.lua`.

All Lua files must use UTF-8 without BOM.

## `mod.json`

```json
{
  "id": "author.example",
  "name": "Example MOD",
  "author": "Author Name",
  "version": "0.1.0",
  "supportedGameVersions": [
    "1.0"
  ],
  "description": "What this MOD adds."
}
```

- `id` uses lowercase letters, digits, and dots, such as `author.example`.
- Two MODs cannot use the same `id`.
- `supportedGameVersions` uses the first two parts of the game version. For game version `1.0.8`, enter `1.0`.
- The MOD folder may use any name, but using the same value as `id`, such as `Mods/author.example/`, is recommended.

## `main.lua`

A configuration-only MOD can use a very small entry file:

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("Example MOD loaded")
end

return Main
```

`main.lua` must exist. The game scans configuration files separately, so they do not need to be loaded here.

## Configuration Files

Each configuration Lua file returns a set of rows to install:

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990001,
            -- Other fields required by this table
        },
    },
}
```

Different tables use different `installKey` values. Grouped configurations such as node pools, Card pools, and action pools also use `installValue` and `operation`. Do not copy one table's structure into another table. Start from the matching [configuration reference](config/) or template.

Some tables do not fill omitted fields automatically. Copy the complete structure from the matching reference or template, then change only what you need.

## Recommended Editing Order

1. Copy the entire template directory.
2. Change the folder name, `mod.json.id`, name, author, and version.
3. Replace every new ID used by the template and update all references to those IDs.
4. Keep existing Card, Target, resource, and node pool references at first so you can verify the basic chain.
5. Replace one layer at a time. For example, replace the Effect first, then the Skill, and finally the Card.

Template numbers are not reserved ranges. New IDs must not conflict with the current game configuration or other installed MODs. When reusing an existing ID, confirm that it still exists in the target game version.

Use these packages to inspect the current version:

- [`game-config`](../../game-config/README.en.md): existing configuration IDs, content, and references.
- [`game-lua`](../../game-lua/README.en.md): Lua code that reads and resolves the configuration.

## Installation and Verification

1. Exit the game and copy the entire MOD directory into `Mods/` beside the game executable.
2. Start the game, enable the MOD in the MOD manager, and apply the selection.
3. Fully restart the game.
4. Start a new run before checking Card pools, node pools, maps, or rewards.
5. Follow the verification steps in the template README.

Configuration is installed during startup. A running save may already contain generated maps, nodes, or reward candidates. After changing, enabling, or disabling a MOD, fully restart the game and start a new run. Do not use an old run to judge whether the new configuration works.

Check three things:

1. **Installation:** the MOD manager can enable the MOD, and the restart shows no configuration error.
2. **Game result:** enter the relevant reward, node, or battle and confirm the complete reference chain works.
3. **Disable recovery:** disable the MOD, restart, and begin a new run. The added content should disappear while existing game content still works.

A successful installation does not prove that every reference is valid. Enter the game and confirm that the Card, Reward, Enemy, and resources work as intended.
