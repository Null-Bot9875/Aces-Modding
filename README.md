# Aces Modding

[English](README.en.md)

想为 Aces 制作自己的卡牌、敌人和 Node？从这里开始。

这套资料面向以配置为主的内容 MOD，无需修改游戏本体，也无需先学习完整的游戏源码。

> 当前是作者资料预览版。标记为“准备中”的教程、模板和示例还不能直接用于制作 MOD。

## 可制作内容

- 新卡牌及其效果；
- 新敌人和行动方式；
- 包含敌人、奖励等内容的新 Node；
- 把这些内容组合成一段可以游玩的完整内容。

## 从哪里开始

| 目标 | 从这里进入 |
| --- | --- |
| 第一次制作 MOD | [从这里开始](docs/zh-cn/getting-started.md) |
| 先看一个完整 MOD，再照着修改 | [完整示例](examples/complete-mod/README.md) |
| 只制作卡牌 | [card-pack 模板](templates/card-pack/README.md) |
| 只制作敌人 | [enemy-pack 模板](templates/enemy-pack/README.md) |
| 从零制作一个 Node | [node-pack 模板](templates/node-pack/README.md) |
| MOD 没有加载或效果不对 | [调试指南](docs/zh-cn/debugging.md) |

`examples/complete-mod` 是用来阅读和修改的完整成品示例；`templates/node-pack` 是从零开始时复制的空白模板。两者用途不同。

## 文档

- [文档目录](docs/zh-cn/README.md)
- [MOD 包由什么组成](docs/zh-cn/mod-package.md)
- [Card 配置教学](docs/zh-cn/content/card.md)
- [Enemy 配置教学](docs/zh-cn/content/enemy.md)
- [Node 配置教学](docs/zh-cn/content/node.md)
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
