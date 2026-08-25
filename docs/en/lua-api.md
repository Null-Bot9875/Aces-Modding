# Lua API

The formal Lua API consists of interfaces explicitly provided to MOD authors with a compatibility commitment. Internal objects that happen to be reachable from Lua do not automatically become public API.

The planned version-one surface records:

- `Mod.CreateController()`;
- `self.Info`;
- `Log`, `LogWarning`, and `LogError`;
- `OnLoad`, `OnGameReady`, `OnUpdate`, and `OnUnload`;
- `require` scoped to the current MOD.

TODO: verify signatures, timing, error isolation, examples, and compatibility promises. Internal entries such as `CS.*`, `ModHost`, `ModRuntime`, `Config.InstallMods`, and `core:` are not stable contracts.
