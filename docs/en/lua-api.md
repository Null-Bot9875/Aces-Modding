# Available Lua APIs

Lua APIs handle loading, logging, and lifecycle behavior beyond configuration content.

## Minimal entry point

The root `main.lua` must return an object created by `Mod.CreateController()`:

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("loaded", self.Info.id)
end

return Main
```

A valid Controller is required even for a configuration-only MOD.

## `self.Info`

`self.Info` contains read-only information:

| Field | Source |
| --- | --- |
| `id` | Normalized `mod.json.id` |
| `name` | `mod.json.name` |
| `author` | `mod.json.author` |
| `version` | `mod.json.version` |
| `description` | `mod.json.description` |

The complete `self.Info` object cannot be replaced.

## Logging

```lua
self:Log("loaded")
self:LogWarning("fallback used")
self:LogError("operation failed")
```

Log entries include the MOD ID. `LogError` records an error and traceback; developer-log display depends on current runtime settings.

## Lifecycle

### Client

```text
load main.lua
  -> OnLoad()
  -> game preload_complete
  -> OnGameReady()
  -> OnUpdate(deltaTime) from the next frame
  -> OnUnload() during shutdown
```

Every callback is optional.

### LocalServer

A separate Controller is created when `local_server/main.lua` exists:

```text
load local_server/main.lua
  -> OnLoad()
  -> OnUpdate(deltaTime) from the next frame
  -> OnUnload() when LocalServer stops
```

LocalServer does not call `OnGameReady` and does not share Lua state with the Client Controller.

## Callback errors

- Entry loading, entry return contract, and `OnLoad` belong to startup.
- A startup failure stops the current MOD startup and enters recovery.
- Controllers already started receive `OnUnload` in reverse order.
- Runtime `OnGameReady`, `OnUpdate`, and `OnUnload` callbacks are error-isolated.
- After the first `OnUpdate` failure, that Controller receives no further `OnUpdate` calls.
- Other active Controllers continue running.

## `require`

### Current MOD

```lua
local Utils = require("scripts.utils")
```

This resolves:

```text
scripts/utils.lua
```

### Another enabled MOD

```lua
local Api = require("another.mod:scripts.api")
```

The target MOD must exist in the current runtime list. `dependencies` produces manager warnings only and does not perform runtime loading automatically.

### Core

```lua
local EventManager = require("core:common/event/EventManager")
```

## Module path rules

- `.` becomes a directory separator.
- A `.lua` extension is removed.
- Paths normalize to `/`.
- Absolute paths, `..`, and invalid characters are rejected.
- Regular modules search the current MOD only and do not fall back to Core.
- Module results are cached by MOD and path.
- A failed load removes the cache entry, allowing a corrected file to retry on the next launch.

## File environment

Every MOD Lua file has an isolated `_G` and module cache, but can still read globals, classes, and C# types exposed by the host environment.

This environment provides namespace and loading isolation; it is not a security sandbox for hostile code. Only interfaces explicitly documented on this page belong to the MOD compatibility contract. Reachable internal objects may change after a game update.
