# Aces Modding

[English](README.en.md)

这是 Aces 的 MOD 作者资料仓库。当前提交先建立公开项目的大结构，供本地 MOD Alpha 阶段整理作者体验和收集反馈；它还不是一套已经完成的正式 SDK。

## 第一版范围

第一版面向以配置为主的内容包 MOD，重点覆盖：

- `card-pack`：卡牌内容；
- `enemy-pack`：敌人及其行动链内容；
- `node-pack`：把敌人、奖励等内容组织进可游玩的 Node。

中文文档是维护源和默认入口，英文文档与中文目录保持对应。代码标识、文件名和配置字段不翻译。

## 仓库结构

- `docs/`：入门、内容配置、Lua API、调试、兼容性和限制；
- `templates/`：三类内容包模板；
- `examples/`：跨 Card、Enemy、Node 的完整示例；
- `game-lua/`：随游戏发布的 Lua 源码参考区；
- `tools/`：校验、打包和诊断工具；
- `.github/`：反馈、缺陷和能力请求模板。

## 当前状态

本仓库目前只有结构和边界说明。模板、示例与字段级教程在完成运行链路验证前均视为 TODO，不能据此判断某项能力已经正式支持。详见 [项目状态](docs/zh-cn/status.md)。

## 第一版暂不包含

- Steam Workshop 发布链路；
- YooAsset MOD Package 与作者侧 Package Builder；
- 热重载或运行中卸载；
- 配置内容包之外的额外玩法 Hook。

## 发布前关键 TODO

- 固化 Card、Enemy、Node 的作者侧配置契约；
- 验证 Enemy 与 Node 在 Client、LocalServer 和实际游玩中的一致加载；
- 提供一个可完成游玩的 `node-pack` 示例；
- 完成详细中文教程，再同步英文翻译；
- 确认仓库许可证和 `game-lua/` 的源码分发边界；
- 补齐校验、打包和版本兼容工具。
