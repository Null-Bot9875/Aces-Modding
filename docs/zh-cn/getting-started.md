# 开始制作 MOD

第一次制作 MOD 时，直接复制最接近目标的模板，不要从空目录开始：

- [`card-pack`](../../templates/card-pack/README.md)：新增一张 Card，并接上 Skill、Effect 和 Card 池。
- [`node-pack`](../../templates/node-pack/README.md)：新增一个三选一事件节点。
- [`enemy-pack`](../../templates/enemy-pack/README.md)：新增一个可进入的战斗节点，以及使用行动链的 Enemy。

## 最小目录结构

游戏只扫描 `Mods/` 下的直属子目录。一个 MOD 至少需要 `mod.json` 和 `main.lua`；配置 Lua 必须放在固定路径中：

```text
游戏目录/
└─ Mods/
   └─ your.mod.id/
      ├─ mod.json
      ├─ main.lua
      └─ config/
         └─ 配置表名/
            └─ Sheet 名/
               └─ 文件.lua
```

例如新增 Card 的文件位置是：

```text
config/card_def/config/cards.lua
```

配置路径必须完整使用 `config/<配置表名>/<Sheet 名>/<文件>.lua`。游戏会自动读取这些文件，不需要在 `main.lua` 中逐个 `require`。

所有 Lua 文件使用 UTF-8 without BOM。

## `mod.json`

```json
{
  "id": "author.example",
  "name": "示例 MOD",
  "author": "作者名",
  "version": "0.1.0",
  "supportedGameVersions": [
    "1.0"
  ],
  "description": "这个 MOD 做了什么。"
}
```

- `id` 使用小写字母、数字和点，例如 `author.example`。
- 不同 MOD 不能使用相同的 `id`。
- `supportedGameVersions` 使用 `major.minor` 格式。当前模板填写 `1.0`。
- MOD 目录名建议与 `id` 相同，方便安装和排查；实际运行身份以 `mod.json.id` 为准。

## `main.lua`

只提供配置时，入口可以保持很小：

```lua
local Main = Mod.CreateController()

function Main:OnLoad()
    self:Log("示例 MOD 已加载")
end

return Main
```

`main.lua` 必须存在。配置文件由游戏单独扫描，不需要从这里加载。

## 配置文件

每个配置 Lua 返回一个安装批次：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990001,
            -- 当前配置表要求的其他字段
        },
    },
}
```

不同配置表使用不同的 `installKey`。节点池、Card 池和行动池等分组配置还会使用 `installValue` 与 `operation`。不要把某张表的批次结构直接套到另一张表；从对应的[配置参考](config/)或模板复制完整写法。

没有自动缺省适配的配置表，必须填写 Schema 要求的完整字段。仓库中的模板和配置参考已经按各表当前要求提供完整 row。

## 修改模板的顺序

1. 复制整个模板目录。
2. 修改目录名和 `mod.json.id`、名称、作者、版本。
3. 更换模板中所有新增 ID，并同步修改引用这些 ID 的字段。
4. 先保持游戏已有的 Card、Target、资源和节点池引用不变，确认基础链路可以运行。
5. 一次只替换一层内容；例如先换 Effect，再换 Skill，最后调整 Card。

模板中的数字不是保留号段。新增 ID 必须避开当前游戏配置和其他已安装 MOD；复用已有 ID 时，也要确认它仍存在于目标游戏版本。

可以使用以下参考包查询当前版本已有内容：

- [`game-config`](../../game-config/README.md)：查询现有配置 ID、row 和引用关系。
- [`game-lua`](../../game-lua/README.md)：查询当前版本 Lua 的读取与结算逻辑。

## 安装和验证

1. 退出游戏，将整个 MOD 目录复制到游戏可执行文件同级的 `Mods/`。
2. 启动游戏，在 MOD 管理器中启用 MOD，并应用选择。
3. 冷启动游戏。
4. 新建战局，再检查 Card 池、节点池、地图和奖励等内容。
5. 按模板 README 的检查步骤确认实际游戏结果。

配置在启动时安装；已经生成的地图、节点和奖励候选还可能保存在进行中的战局里。因此修改配置、启用或停用 MOD 后，都应冷启动并新建战局，不要用旧战局判断新配置是否生效。

检查分为三层：

1. **安装成功**：MOD 管理器没有阻塞问题，冷启动时没有配置安装错误。
2. **实际生效**：进入对应奖励、节点或战斗，确认引用链和游戏结果正确。
3. **停用恢复**：停用 MOD、冷启动并新建战局后，MOD 新增内容不再出现，游戏已有内容仍能正常使用。

安装成功只证明目录、Lua 和配置字段可以被读取。Card、Reward、Enemy、资源 ID 等引用不会在安装时全部递归检查，仍要通过实际生效步骤确认。
