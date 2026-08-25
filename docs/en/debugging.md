# Troubleshooting

## MOD missing from the manager

Check in order:

1. The MOD is inside `Mods/` beside the game executable.
2. `mod.json` is directly inside `Mods/<folder>/`.
3. The archive did not create an extra nested directory.
4. `mod.json` is valid JSON.
5. The ID uses the lowercase dotted format.
6. `supportedGameVersions` contains the current `major.minor`.
7. No other installed MOD uses the same ID.

## MOD appears but cannot be enabled

Check Blocking issues shown by the manager:

- Missing required files;
- invalid manifest fields;
- Lua files not encoded as UTF-8 without BOM;
- Lua syntax errors;
- duplicate MOD IDs;
- invalid configuration batch path, return value, or row.

Missing, disabled, or incorrectly ordered `dependencies` normally produce warnings and do not reorder MODs automatically.

## Startup fails after enabling

When an enabled MOD fails during discovery, Lua compilation, configuration installation, entry loading, entry return contract, or `OnLoad`:

1. The current startup stops.
2. Configuration installation rolls back.
3. The failing MOD is not disabled automatically.
4. The next launch runs no third-party configuration or Controllers.
5. The MOD manager opens during the login phase.
6. Applying an adjusted enabled state or order clears the pending failure.
7. Another restart applies the new selection.

The complete traceback is stored in `Player.log`. The dialog may show only the MOD ID, failure stage, and a bounded error summary.

## Configuration content is missing

Check:

- The path is `config/<module>/<sheet>/<file>.lua`.
- `module` and `sheet` names match the target configuration.
- The batch returns a table.
- `rows` is a table.
- Tables without an author adapter provide complete rows.
- `installKey` selects an existing target index.
- Group indexes include `installValue`.
- A later MOD did not replace the same configuration ID.

## Card missing from rewards

Installing `card_def.config` does not modify rewards automatically. A playable path also requires:

- Adding the Card to a target card pool;
- making a reward reference that pool;
- starting a new Rogue run that satisfies the `baseId`, level, and activity conditions;
- creating the run after a cold start.

Compare against the [`card-pack`](../../templates/card-pack/README.en.md).

## Image missing

Check:

- The file is inside the current MOD `assets/` directory.
- `assetId` is a `.png` path relative to `assets/`.
- The path contains no absolute root, `..`, or handwritten `mod://`.
- The game was restarted after the image changed.
- A numeric Core asset ID actually exists.

## Runtime callback error

- `OnGameReady` and `OnUnload` failures are logged.
- After the first `OnUpdate` failure, that Controller receives no further updates.
- Other Controllers continue running.
- Corrected Lua takes effect after a restart.

## Bug report evidence

Keep:

- Game version;
- MOD ID and version;
- MOD directory tree;
- reproduction steps;
- expected and actual results;
- failure stage from the dialog;
- matching `Player.log`.

Remove account details, personal information in absolute paths, and other sensitive content before submission.
