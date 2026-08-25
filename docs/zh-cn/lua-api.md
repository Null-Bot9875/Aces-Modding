# Lua API

正式 Lua API 是明确提供给 MOD 作者、并承诺兼容性的接口；能从 Lua 访问到的内部对象不自动成为正式 API。

第一版计划记录：

- `Mod.CreateController()`；
- `self.Info`；
- `Log`、`LogWarning`、`LogError`；
- `OnLoad`、`OnGameReady`、`OnUpdate`、`OnUnload`；
- 当前 MOD 范围内的 `require`。

TODO：逐项核对签名、调用时机、错误隔离、示例和版本承诺。`CS.*`、`ModHost`、`ModRuntime`、`Config.InstallMods`、`core:` 等内部入口不属于稳定契约。
