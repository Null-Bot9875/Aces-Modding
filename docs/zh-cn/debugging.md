# 遇到问题时如何排查

## MOD 没有出现在管理器中

依次检查：

1. MOD 是否位于游戏可执行文件同级的 `Mods/`；
2. `mod.json` 是否直接位于 `Mods/<folder>/`；
3. 是否多套了一层解压目录；
4. `mod.json` 是否为合法 JSON；
5. `id` 是否符合小写点分格式；
6. `supportedGameVersions` 是否包含当前 `major.minor`；
7. 是否安装了另一个相同 `id` 的 MOD。

## MOD 出现但无法启用

检查管理器显示的 Blocking 问题：

- 缺少必填文件；
- manifest 字段错误；
- Lua 文件不是 UTF-8 without BOM；
- Lua 语法错误；
- 重复 MOD ID；
- 配置批次路径、返回值或 row 错误。

`dependencies` 的缺失、未启用或顺序问题通常是 warning，不会自动调整 MOD 顺序。

## 启用后启动失败

已启用 MOD 在发现、Lua 编译、配置安装、入口加载、入口返回值或 `OnLoad` 阶段失败时：

1. 当前启动停止；
2. 配置安装回滚；
3. 故障 MOD 不会被自动禁用；
4. 下一次启动不执行第三方配置和 Controller；
5. 登录阶段打开 MOD 管理器；
6. 调整启用状态或顺序并应用后，清除待处理故障；
7. 再次重启。

完整 traceback 保存在 `Player.log`。弹窗摘要可能只显示 MOD ID、阶段和截断后的错误信息。

## 配置内容没有出现

检查：

- 文件路径是否为 `config/<module>/<sheet>/<file>.lua`；
- `module`、`sheet` 名称是否正确；
- 批次是否 `return` table；
- `rows` 是否为 table；
- 没有专用适配器的表是否提交完整 row；
- `installKey` 是否是目标配置已有索引；
- 组索引是否填写 `installValue`；
- 配置 ID 是否被后加载 MOD 覆盖。

## Card 没有出现在奖励中

安装 `card_def.config` 不会自动修改奖励池。还需要：

- 将 Card 加入目标卡池；
- 让奖励引用该卡池；
- 使用满足 `baseId`、等级和活动条件的新 Rogue 战役；
- 冷启动后再创建战役。

可直接对照 [`card-pack`](../../templates/card-pack/README.md)。

## 图片不显示

检查：

- 文件是否位于当前 MOD 的 `assets/`；
- `assetId` 是否为相对于 `assets/` 的 `.png` 路径；
- 路径是否包含绝对路径、`..` 或手写 `mod://`；
- 修改图片后是否完成重新启动；
- Core 数字资源 ID 是否真实存在。

## 运行中回调报错

- `OnGameReady` 或 `OnUnload` 报错会记录日志；
- `OnUpdate` 首次报错后，该 Controller 停止接收后续更新；
- 其他 Controller 不受影响；
- 修正 Lua 后需要重新启动。

## 提交缺陷报告

保留以下信息：

- 游戏版本；
- MOD ID 和版本；
- MOD 目录树；
- 操作步骤；
- 期望结果和实际结果；
- 弹窗中的故障阶段；
- 对应 `Player.log`。

提交前移除账号、绝对路径中的个人信息和其他敏感内容。
