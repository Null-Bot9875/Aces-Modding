# 更新记录

## 未发布

- 暂时移除英文镜像；中文结构和内容稳定后再补充英文版本。
- 取消 `examples` 分类，将 Node+Enemy 联合内容迁入 `templates/node-pack`。
- 删除尚未提供可运行工具的 `tools` 目录。
- 加入 Aces `1.0.8` 游戏 Lua 参考压缩包。
- 加入 Aces `1.0.8` 精选游戏配置参考压缩包，收录 Card、Node、Enemy 及其战斗行为依赖表。

- 建立 Aces Modding 公开仓库骨架。
- 确定初始内容范围以 Card、Enemy、Node 配置内容包为核心。
- 建立中英文镜像文档、模板、示例、工具和 Lua 参考目录。
- 把公开文档改为 MOD 作者视角，并把完整示例改名为 `complete-mod`。
- 约定 `game-lua` 随游戏版本提供一份同版本 Lua 文件压缩包。
- 公开文档统一改用无人称的客观陈述。
- 完成 Getting Started、通用配置、Card、Lua API、调试、资源和多语言基础文档，并提供可直接试用的 `card-pack` 模板。
- 加入可安装的 Node+Enemy `complete-mod` 人工验收候选、详细配置教学和 Card/Node/Enemy 人工测试清单。
- `enemy-pack` 与 `node-pack` 改为等待联合示例人工验证后再拆分，避免发布未经验证的独立结构。
- 加入可复用 Core 配置、示例配置字段参考和 EP `1061` 当前使用的全部 44 个 Node Group 目录。
- 加入同层级的 Target、Condition、Effect 字段级参考，说明现有类型、组合规则、结算链、案例和扩展边界。
