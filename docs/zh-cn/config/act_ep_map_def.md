# `act_ep_map_def` 配置参考

> `act_ep_map_def` 定义地图骨架。一行代表一个节点位置，保存它属于哪个战役、生成什么节点，以及接下来连接到哪里。

## `act_ep_map_def` 的基本结构

EP `1061` 的节点位置 `230001` 位于第 1 层，使用节点池 `2001`，完成后可以进入三个后续位置。

```lua
{
    id = 230001,
    epId = 1061,
    refreshGroup = 2001,
    nextNode = {
        [230024] = 1,
        [230021] = 1,
        [230022] = 1,
    },
    layer = 1,
}
```

```text
节点位置 230001
├─ 属于 EP 1061 的第 1 层
├─ 节点池 2001 → 生成当前位置的节点
└─ 后续位置 → 230024 / 230021 / 230022
```

`act_ep_map_def` 有 5 个字段：

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `id` | int | 节点位置 ID；不是 `act_node_def.id` |
| `epId` | int | 节点位置所属的战役；正式地图使用 `1061` |
| `refreshGroup` | int | 节点池 ID，对应 `act_node_refresh_def.groupId` |
| `nextNode` | dict&lt;int,int&gt; | 后续节点位置；键是另一个 `act_ep_map_def.id`，值是连接类型 |
| `layer` | int | 地图显示和流程使用的层级 |

## 节点位置属于哪里

`id` 只标识地图上的节点位置。它与最终显示的 `act_node_def.id` 是两套 ID：同一个节点位置可以在不同战局中生成不同节点，也可以在结算后把当前节点替换为另一条内容。

`epId` 决定这行属于哪个战役，`layer` 决定它位于地图的哪一层。本文案例只使用正式地图 EP `1061`。

## 节点位置生成什么

`refreshGroup` 填写节点池 ID：

```text
act_ep_map_def.refreshGroup = 2001
└─ act_node_refresh_def.groupId = 2001
   └─ 从节点池中生成一个 act_node_def
```

节点池中有哪些节点、如何按权重选择，见 [`act_node_refresh_def` 配置参考](act_node_refresh_def.md)。节点池编号的阅读方法见 [节点池编号规则](../concepts/node-groups.md)。

## 节点位置连接到哪里

`nextNode` 的键是后续节点位置 ID，值是连接类型。EP `1061` 的普通路线连接使用 `1`：

```lua
nextNode = {
    [230024] = 1,
    [230021] = 1,
    [230022] = 1,
},
```

- 一个节点位置连接多个后续位置时，地图产生分支。
- 多个节点位置连接同一个后续位置时，路线产生汇合。
- 空表表示这行不继续连接其他节点位置。

`nextNode` 表示完成当前位置后的地图前进，不是节点替换。选择后、战斗成功后或战斗失败后的节点替换分别由 `act_option_def.replaceNode`、`act_node_def.finishReplaceNode` 和 `act_node_def.failReplaceNode` 处理。

## 修改已有路线

修改已有节点位置时，需要提交这一行的完整新内容。下面给节点位置 `230001` 增加第四条路线：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 230001,
            epId = 1061,
            refreshGroup = 2001,
            nextNode = {
                [230024] = 1,
                [230021] = 1,
                [230022] = 1,
                [990001] = 1,
            },
            layer = 1,
        },
    },
}
```

这里必须保留原来的三个连接。遗漏的字段或旧连接不会从原配置自动继承。

地图通常在新建战局时生成。修改路线、层级或节点池后，需要新建战局观察；已经写入存档的地图不会自动更新。

## 在 MOD 中新增 `act_ep_map_def`

配置文件放在：

```text
config/act_ep_map_def/config/*.lua
```

下面在 EP `1061` 新增节点位置 `990001`：

```lua
return {
    installKey = "id",
    rows = {
        {
            id = 990001,
            epId = 1061,
            refreshGroup = 990001,
            nextNode = {
                [230024] = 1,
            },
            layer = 1,
        },
    },
}
```

`installKey = "id"` 表示按节点位置 ID 安装。`refreshGroup = 990001` 还需要在 [`act_node_refresh_def`](act_node_refresh_def.md) 中提供同名 `groupId`；其他节点位置也需要通过 `nextNode` 连接到 `990001`，新位置才会进入可达路线。
