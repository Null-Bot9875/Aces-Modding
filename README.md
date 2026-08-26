# Aces Modding

[English](README.en.md)

本仓库提供 Aces Card、Enemy 和 Node MOD 的作者资料。

这套资料面向以配置为主的内容 MOD，无需修改游戏本体，也无需先学习完整的游戏源码。

> 当前为本地人工验收候选。`card-pack` 和 Node+Enemy 联合示例已经加入，Card、Node、Enemy 仍需分别完成人工测试。公开发布前还需确定 [LICENSE](LICENSE.md)。

## 第一版计划覆盖

- 复用游戏已有 Skill、Target 和费用 Effect 的新 Card；
- 新敌人和行动方式；
- 包含敌人、奖励等内容的新 Node；
- 把这些内容组合成一段可以游玩的完整内容。

## 从哪里开始

| 目标 | 从这里进入 |
| --- | --- |
| 第一次制作 MOD | [从这里开始](docs/zh-cn/getting-started.md) |
| 测试 Node 与 Enemy 的完整引用链 | [Node 与 Enemy 完整示例](examples/complete-mod/README.md) |
| 只制作卡牌 | [card-pack 模板](templates/card-pack/README.md) |
| 学习 Enemy 配置 | [Enemy 配置教学](docs/zh-cn/content/enemy.md) |
| 学习 Node 配置 | [Node 配置教学](docs/zh-cn/content/node.md) |
| 进行首版人工测试 | [人工测试清单](docs/zh-cn/manual-testing.md) |
| MOD 没有加载或效果不对 | [调试指南](docs/zh-cn/debugging.md) |

`templates/enemy-pack` 和 `templates/node-pack` 尚未提供独立可运行文件。联合示例完成人工验证后，再从已验证结构中拆分这两个模板。

## 文档

- [文档目录](docs/zh-cn/README.md)
- [MOD 包由什么组成](docs/zh-cn/mod-package.md)
- [通用配置格式](docs/zh-cn/configuration.md)
- [PNG 资源](docs/zh-cn/assets.md)
- [多语言](docs/zh-cn/localization.md)
- [Card 配置教学](docs/zh-cn/content/card.md)
- [Enemy 配置教学](docs/zh-cn/content/enemy.md)
- [Node 配置教学](docs/zh-cn/content/node.md)
- [首版人工测试清单](docs/zh-cn/manual-testing.md)
- [可以使用的 Lua API](docs/zh-cn/lua-api.md)
- [当前可以使用什么](docs/zh-cn/status.md)
- [当前限制](docs/zh-cn/limitations.md)

中文是默认文档语言，英文页面与中文页面保持对应。代码标识、文件名和配置字段不会翻译。

## 当前还不能使用

- Steam Workshop 发布；
- YooAsset MOD Package；
- 热重载或运行中卸载；
- 文档没有列出的额外玩法 Hook。

依赖这些能力的 MOD，可在 GitHub Issues 中选择“能力请求”，说明目标内容。

## 遇到问题

打开本仓库的 GitHub Issues 页面，根据情况选择：

- “MOD 作者体验反馈”：不知道下一步该做什么，或者文档难以理解；
- “缺陷报告”：按文档操作后得到错误结果；
- “能力请求”：现有 Card、Enemy、Node 内容无法实现目标设计。
