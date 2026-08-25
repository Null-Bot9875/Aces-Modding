# 可以使用的 Lua API

Lua API 用来处理配置之外的加载、日志和生命周期逻辑。

第一批文档将介绍：

- `Mod.CreateController()`；
- `self.Info`；
- `Log`、`LogWarning`、`LogError`；
- `OnLoad`、`OnGameReady`、`OnUpdate`、`OnUnload`；
- 当前 MOD 范围内的 `require`。

## 当前状态

API 教程和可复制示例正在准备中。现在不要根据函数名猜测参数或调用顺序。

只使用本页明确写出的接口。即使某个游戏内部对象可以被 Lua 访问，也可能在更新后改变或消失，不应作为 MOD 依赖。
