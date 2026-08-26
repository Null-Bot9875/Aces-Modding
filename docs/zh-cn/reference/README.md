# 配置与引用参考

本目录集中回答配置制作中最常见的两个问题：

- [可复用的 Core 配置](core-configs.md)：第一版已经确认哪些现有 Card、Skill、Target、Effect 和 Enemy 基础数据可以引用；
- [EP 1061 Node Group 目录](node-groups.md)：当前地图使用的全部 44 个 Group、命名规律、地图位置和现有用途；
- [配置字段参考](config-fields.md)：模板与完整示例涉及哪些字段、字段之间如何联动、哪些字段首轮应保留示例值。

状态说明：

| 标记 | 含义 |
| --- | --- |
| 示例已采用 | 当前 `card-pack` 或 `complete-mod` 已经使用该值，并有静态配置证据 |
| 含义已确认 | 已从同版本配置或运行代码确认引用对象和基本作用 |
| 人工验证待完成 | 尚未完成 MOD 作者身份下的完整游戏内操作 |
| 首版不承诺 | Core 中可能存在，但没有进入第一版公开支持范围 |

Core 配置存在不等于正式 MOD API。第一版只承诺文档列出的配置格式与引用范围；同版本 Core 中的其他值可用于研究，但接入 MOD 前仍需验证完整引用链和游戏内行为。

配置制作顺序：

1. 从 [Card](../content/card.md)、[Enemy](../content/enemy.md) 或 [Node](../content/node.md) 教学复制可运行结构；
2. 在 [可复用的 Core 配置](core-configs.md) 中选择已确认的起始组合；
3. 制作 Node 时，从 [EP 1061 Node Group 目录](node-groups.md) 选择目标位置；
4. 按 [配置字段参考](config-fields.md) 修改字段并同步引用；
5. 按 [人工测试清单](../manual-testing.md) 完成游戏内验证。

完整 Core row 的查询资料将随游戏版本放入 [`game-lua`](../../../game-lua/README.md)。该压缩包目前尚未提供，因此本目录只列出已经核实的第一版起始值。
