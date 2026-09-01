# Aces Modding

> TODO：中文文档结构和内容稳定后，再补充英文版本。

本仓库提供《ACE Strategy: Mecha Nova》（NOVA）的 MOD 模板、配置参考和相关概念说明。

## 从哪里开始

- [开始制作 MOD](docs/zh-cn/getting-started.md)：目录结构、配置路径、安装流程和完成检查。
- [`templates/card-pack`](templates/card-pack/README.md)：Card MOD 模板。
- [`templates/enemy-pack`](templates/enemy-pack/README.md)：可进入的战斗节点，以及使用两回合行动链的 Enemy 模板。
- [`templates/node-pack`](templates/node-pack/README.md)：三选一事件节点模板。
- [`docs/zh-cn/config`](docs/zh-cn/config/)：制作 MOD 时可以直接参考的配置文件说明。
- [`docs/zh-cn/concepts`](docs/zh-cn/concepts/)：配置文件涉及的概念说明，例如 Trigger、Area 和 Attr。
- [`game-lua`](game-lua/README.md)：当前版本游戏 Lua 参考包。
- [`game-config`](game-config/README.md)：当前版本精选游戏配置参考包。

中文文档入口见 [`docs/zh-cn/README.md`](docs/zh-cn/README.md)。

## 当前状态

- 中文是当前唯一维护的文档语言。
- 中文配置参考和概念说明已覆盖当前公开模板需要的配置链。
- 模板提供完整可复制结构；实际表现仍需在目标游戏版本中验证。
- 当前仓库仅提供作者参考资料，不代表 Steam Workshop、热重载或运行中卸载已经可用。

## 许可

使用或分发前请先阅读 [LICENSE](LICENSE.md)。
