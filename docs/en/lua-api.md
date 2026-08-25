# Available Lua APIs

Lua APIs handle loading, logging, and lifecycle behavior beyond configuration content.

The first documentation set will cover:

- `Mod.CreateController()`;
- `self.Info`;
- `Log`, `LogWarning`, and `LogError`;
- `OnLoad`, `OnGameReady`, `OnUpdate`, and `OnUnload`;
- `require` scoped to the current MOD.

## Current status

The API tutorial and copyable examples are in preparation. Do not infer parameters or call order from function names.

Use only interfaces explicitly documented on this page. An internal game object may be reachable from Lua but can change or disappear after an update and should not become a MOD dependency.
