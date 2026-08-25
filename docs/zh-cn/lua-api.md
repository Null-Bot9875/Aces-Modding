# 可以使用的 Lua API

Lua API 用来处理配置之外的加载、日志和生命周期逻辑。

## 最小入口

根目录 `main.lua` 必须返回 `Mod.CreateController()` 创建的对象：

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("loaded", self.Info.id)
end

return Main
```

即使 MOD 只包含配置，也需要返回有效 Controller。

## `self.Info`

`self.Info` 是只读信息：

| 字段 | 来源 |
| --- | --- |
| `id` | `mod.json.id` 的规范化结果 |
| `name` | `mod.json.name` |
| `author` | `mod.json.author` |
| `version` | `mod.json.version` |
| `description` | `mod.json.description` |

不能替换整个 `self.Info`。

## 日志

```lua
self:Log("loaded")
self:LogWarning("fallback used")
self:LogError("operation failed")
```

日志会附带 MOD ID。`LogError` 会记录错误和 traceback；开发日志显示方式取决于当前运行设置。

## 生命周期

### Client

```text
加载 main.lua
  -> OnLoad()
  -> 游戏 preload_complete
  -> OnGameReady()
  -> 下一帧开始 OnUpdate(deltaTime)
  -> 退出时 OnUnload()
```

所有回调都是可选的。

### LocalServer

存在 `local_server/main.lua` 时，会创建独立 Controller：

```text
加载 local_server/main.lua
  -> OnLoad()
  -> 下一帧开始 OnUpdate(deltaTime)
  -> LocalServer 停止时 OnUnload()
```

LocalServer 不调用 `OnGameReady`，也不与 Client Controller 共享 Lua 状态。

## 回调错误

- 入口加载、入口返回值和 `OnLoad` 属于启动阶段；
- 启动阶段失败会停止本次 MOD 启动并进入恢复流程；
- 已经启动的 Controller 会按逆序执行 `OnUnload`；
- 运行中的 `OnGameReady`、`OnUpdate`、`OnUnload` 使用错误隔离；
- 某个 Controller 的 `OnUpdate` 首次失败后，该 Controller 不再接收后续 `OnUpdate`；
- 其他已启动 Controller 继续运行。

## `require`

### 当前 MOD

```lua
local Utils = require("scripts.utils")
```

查找当前 MOD：

```text
scripts/utils.lua
```

### 其他已启用 MOD

```lua
local Api = require("another.mod:scripts.api")
```

目标 MOD 必须存在于当前运行清单。`dependencies` 只产生管理器警告，不会自动完成运行时加载。

### Core

```lua
local EventManager = require("core:common/event/EventManager")
```

## 模块路径规则

- `.` 会转换为目录分隔；
- `.lua` 扩展名会被移除；
- 路径统一使用 `/`；
- 绝对路径、`..` 和非法字符会被拒绝；
- 普通模块只在当前 MOD 中查找，不自动回退 Core；
- 模块结果按 MOD 和路径缓存；
- 加载失败会撤销缓存，修正文件后可在下一次启动重试。

## 文件环境

每个 MOD Lua 文件有独立 `_G` 和模块缓存，但仍能读取宿主环境暴露的全局、类和 C# 类型。

该环境用于命名空间和加载隔离，不是用于执行敌意代码的安全沙箱。只有本页明确记录的接口属于 MOD 兼容合同；可访问的内部对象可能在游戏更新后改变。
