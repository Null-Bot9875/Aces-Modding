# 一个 MOD 包含什么

## 目录结构

MOD 放在游戏可执行文件同级的 `Mods/`。加载器只扫描 `Mods/` 的直属子目录。

```text
<mod-root>/
  mod.json                         # 必填
  main.lua                         # 必填
  local_server/main.lua            # 可选
  locales/<language>/mod.json      # 可选：管理器名称和说明
  config/<module>/<sheet>/*.lua    # 可选：配置批次
  language/language.csv            # 可选：配置文本翻译
  assets/<folders>/*.png           # 可选：当前用于 Card PNG
```

所有 `.lua`、`.json` 和 `.csv` 文本使用 UTF-8 without BOM。

## `mod.json`

最小示例：

```json
{
  "id": "author.example",
  "name": "Example MOD",
  "author": "MOD Author",
  "version": "0.1.0",
  "supportedGameVersions": ["1.0"]
}
```

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `id` | 是 | 转为小写后匹配 `^[a-z0-9]+(\.[a-z0-9]+)+$` |
| `name` | 是 | MOD 管理器默认显示名称 |
| `author` | 是 | 作者或组织名称 |
| `version` | 是 | MOD 自身版本 |
| `supportedGameVersions` | 是 | 非空数组；每项使用 `major.minor` |
| `description` | 否 | MOD 管理器默认说明 |
| `dependencies` | 否 | 依赖的 MOD ID 数组 |

安装多个相同 `id` 的 MOD 时，所有重复实例都会被阻止加载。`dependencies` 只产生缺失、未启用或顺序不正确的警告，不会自动调整顺序。

## `main.lua`

入口必须返回 `Mod.CreateController()` 创建的对象：

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("Example MOD loaded")
end

return Main
```

即使 MOD 只包含配置，也需要根目录 `main.lua`。

## `config/`

目录本身声明目标配置：

```text
config/<module>/<sheet>/<file>.lua
```

例如：

```text
config/card_def/config/cards.lua
```

文件名只用于排序和错误定位。批次格式见[通用配置格式](configuration.md)。

## `language/` 与 `locales/`

- `language/language.csv`：翻译配置字段中的玩家可见文本；
- `locales/<language>/mod.json`：翻译 MOD 管理器中的名称和说明。

两者用途不同。配置多语言见[多语言](localization.md)。

## `assets/`

当前作者资源支持 Card 使用本 MOD 目录内的 PNG：

```text
assets/cards/example.png
```

Card 配置中写：

```lua
assetId = "cards/example.png"
```

完整规则见[PNG 资源](assets.md)。

## 加载顺序

1. Core 配置先加载；
2. 已启用 MOD 按管理器顺序加载；
3. 同一 MOD 内按规范化配置路径排序；
4. 同一批次内按 `rows` 顺序处理；
5. 后处理的完整定义覆盖先处理定义。

管理器保存的是下一次启动使用的顺序和启用状态，不会在当前进程热卸载或重新安装 MOD。
