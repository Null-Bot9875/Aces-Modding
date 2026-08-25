# General configuration format

Configuration MODs add or replace rows in existing configuration tables through Lua files.

## File location

```text
config/<module>/<sheet>/<file>.lua
```

- `<module>`: target configuration, such as `card_def`;
- `<sheet>`: target sheet, such as `config`;
- `<file>.lua`: batch filename, used only for ordering and error locations.

`module` and `sheet` use letters, numbers, and underscores only.

## Minimal batch

```lua
return {
    rows = {
        {
            key = "example_key",
            text = "Example text",
        },
    },
}
```

Configuration tables without a dedicated author adapter require complete rows. Field names and types come from the matching configuration table in the same-version game Lua archive.

## `installKey`

`installKey` selects an existing query index in the target configuration.

### No `installKey`

```lua
return {
    rows = {
        { key = "example", text = "Example" },
    },
}
```

Every row is appended. The loader does not infer `id` or the first field.

### Regular index

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            -- complete row or an author row supported by this table
        },
    },
}
```

- Existing query key: replace the complete row at its original array position.
- New query key: append to the end of the array.

### Composite index

```lua
return {
    installKey = { "baseId", "level" },
    rows = {
        {
            baseId = 9001,
            level = 1,
            -- remaining complete fields
        },
    },
}
```

Field order must match the target query index.

### Group index

A group index operates on one complete group:

```lua
return {
    installKey = "poolId",
    installValue = 990001,
    operation = "replace",
    rows = {
        {
            poolId = 990001,
            cardId = 910001,
            -- remaining complete fields
        },
    },
}
```

- `installValue` is required.
- `operation` defaults to `replace`.
- `replace` removes the old group and writes the current `rows`.
- `append` keeps the old group and appends rows.
- One file operates on one target group.
- `replace` with empty `rows` clears the group.

## Card author adapter

Only `card_def.config` currently provides a simplified author format. It accepts eight required fields and fills the remaining fields with fixed defaults.

Other tables, including card pools, rewards, Enemy tables, and Node tables, require complete rows until their author tutorials explicitly state otherwise.

## IDs, overrides, and conflicts

- Configuration IDs retain the original type of the target table.
- Numeric IDs remain numeric; no `core:` or MOD ID prefix is added.
- `mod.json.id` identifies the MOD source and loading order only.
- When different MODs use the same configuration ID, the later complete definition wins.
- New content should use IDs that do not conflict with Core or another MOD.

## Transactions and failures

All batches for one MOD are read and normalized before installation begins.

- A batch failure restores sheets already changed by that MOD.
- Any enabled MOD installation failure restores all MOD configuration from the current installation pass.
- A partial Core-plus-MOD state is not published.
- Corrected files take effect after a restart.

This page defines installation format only. Whether a table is consumed by the intended gameplay is established by the in-game verification in the matching Card, Enemy, or Node tutorial.
