# 首版人工测试清单

这份清单用于从 MOD 作者视角验证 Card、Node 和 Enemy。三类内容分别记录结果，即使 Node 与 Enemy 使用同一个联合示例。

自动检查、配置查询成功和开发环境运行只能证明部分链路。本页全部通过后，才表示首版作者流程完成人工验证。

## 测试准备

- 记录游戏完整版本号；
- 使用专门的测试存档，不使用正常游玩存档；
- 测试前退出游戏；
- 每次只启用当前测试所需的一个示例 MOD；
- 修改启用状态或文件后，应用选择、退出并冷启动；
- 保留每轮对应的 `Player.log`；
- 日志对外提交前移除账号、个人目录和其他敏感信息。

结果只填写：`通过`、`失败`、`待测`。失败项同时记录实际结果、截图或日志位置。

## A. Card：`card-pack`

安装目录：

```text
Mods/example.cardpack/
```

测试前确认 `mod.json` 直接位于该目录，并且只启用 `example.cardpack`。

| 检查项 | 预期结果 | 结果 |
| --- | --- | --- |
| MOD 管理器发现 | 显示 `example.cardpack`，没有 Blocking 问题 | 待测 |
| 冷启动加载 | 游戏正常进入，`Player.log` 出现 `Example Card Pack loaded` | 待测 |
| 奖励出现 | 使用 `baseId=501` 新建 Rogue 战役，`rewardId=10003` 的候选包含 `Example: Fire Drone` 和 Core Card `2000` | 待测 |
| 加入牌组 | 选择示例 Card 后，当前 Rogue 牌组出现 Card `910001` | 待测 |
| 重启持久化 | 重启并继续同一战役后，Card 仍在牌组中 | 待测 |
| 战斗行为 | Card 能抽取、选择合法目标并成功打出 | 待测 |
| 打出后区域 | 成功打出后离开手牌并进入 `desk(area=3)` | 待测 |
| 停用恢复 | 停用 MOD、冷启动并新建战役后，测试 Card 不再出现 | 待测 |

`card-pack` 会覆盖 Core `rewardId=10003`，只用于测试存档。测试结束后保持停用或移出 `Mods/`。

## B. Node：`complete-mod`

安装目录：

```text
Mods/aces.example.nodeenemy/
```

测试前确认只启用 `aces.example.nodeenemy`。

| 检查项 | 预期结果 | 结果 |
| --- | --- | --- |
| MOD 管理器发现 | 显示 `aces.example.nodeenemy`，没有 Blocking 问题 | 待测 |
| 冷启动加载 | 游戏正常进入，`Player.log` 出现 `Node and chain enemy example loaded` | 待测 |
| 地图可达 | 本地模式新建 EP `1061` 后，位置 `230001` 可到达 | 待测 |
| Node 替换 | 位置 `230001` 显示 `MOD 行动链演示`，不显示 Core Node `4315` | 待测 |
| Node 内容 | 名称、副标题、说明和选项正常显示 | 待测 |
| 进入战斗 | 进入 Node 后能够正常启动战斗 | 待测 |
| 战斗完成 | 战斗能够完成，流程继续并结算奖励 | 待测 |
| 停用恢复 | 停用 MOD、冷启动并新建 EP `1061` 后，位置 `230001` 恢复为 Core Node `4315` | 待测 |

## C. Enemy：`complete-mod`

Enemy 与 Node 在同一轮游玩中验证，但结果单独记录。

| 检查项 | 预期结果 | 结果 |
| --- | --- | --- |
| Enemy 生效 | Node 战斗使用 Enemy `11999` | 待测 |
| 名称边界 | 可识别 `MOD 修复点射核心`；界面局部显示 `自成长核心` 时与 `baseId=7366` 的复用说明一致 | 待测 |
| 第 1 回合 | 使用 Core Card `21007`（自我修复） | 待测 |
| 第 2 回合 | 使用 Core Card `21006`（试探点射） | 待测 |
| 第 3 回合 | 再次使用 Core Card `21007` | 待测 |
| 第 4 回合 | 再次使用 Core Card `21006` | 待测 |
| 行为结算 | 四回合中目标选择、效果结算和回合推进正常 | 待测 |

## 结果记录

```text
游戏版本：
测试日期：
Card：通过 / 失败 / 待测
Node：通过 / 失败 / 待测
Enemy：通过 / 失败 / 待测
停用恢复：通过 / 失败 / 待测
Player.log：
截图或录像：
备注：
```

任一失败项应保留原始示例文件，另复制一份再尝试修改。排查顺序见[调试指南](debugging.md)。
