# 游戏配置参考

当前提供 Aces `1.0.8` 对应的游戏配置压缩包：

- [aces-game-config-1.0.8.zip](aces-game-config-1.0.8.zip)

配置包用于查询现有 ID、对照游戏已有 row 结构，以及追踪 Card、Node 和 Enemy 配置之间的引用关系。包内文件是只读参考，不是可直接安装的 MOD；制作 MOD 时仍应从仓库模板开始。

## 收录配置

Card 与奖励入口：

- `card_def`
- `act_card_pool_def`
- `reward_def`

Node 与 Enemy：

- `act_node_def`
- `act_node_refresh_def`
- `robot_def`
- `robot_chain_def`

战斗行为：

- `battle_skill_def`
- `static_skill_def`
- `battle_target_def`
- `battle_effect_def`
- `battle_condition_def`

## 筛选原则

只收录以下两类配置表：

1. 当前公开 Card、Node、Enemy 模板直接使用的配置表。
2. 追踪 `Card -> Skill / Static Skill -> Target / Effect / Condition` 所需的战斗配置表。

完整多语言、角色、商店、剧情、资源、活动外围配置、服务端配置和其他未进入当前 MOD 作者文档范围的配置不收录。

筛选发生在配置表层级。已收录的配置表保留完整 row，不再按 ID 零散裁剪，避免查询引用时缺少必要的对照项。配置包中存在某种 row，不代表当前 MOD 功能已经支持完整复刻该内容。

## 使用方式

解压后，在 `data/` 中按配置表名打开对应的 `.lua` 文件：

- `*_schema`：字段结构；单表文件通常使用 `config_schema`。
- `*_source`：当前版本的游戏配置 rows；单表文件通常使用 `config_source`。

参考现有 row 时，只复制实际需要的字段和值，不要把整份生成文件放进 MOD。MOD 文件结构、安装方式和可用范围以 [`docs/zh-cn/config`](../docs/zh-cn/config/) 及 [`templates`](../templates/) 中的说明为准。

本目录不展开保存全部配置；每个游戏版本只保留对应的精选配置压缩包。
