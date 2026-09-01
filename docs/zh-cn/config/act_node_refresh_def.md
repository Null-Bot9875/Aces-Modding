# `act_node_refresh_def` 配置参考

> `act_node_refresh_def` 定义节点池：池里有哪些节点、哪些节点当前可以出现，以及如何从可用节点中选出一个。

## `act_node_refresh_def` 的基本结构

“十字星的残响”（节点 `1416`）位于节点池 `1413`，相对权重为 `30`，同一张地图通常最多生成一次。

```lua
{
    groupId = 1413,
    nodeId = 1416,
    weight = 30,
    limitBaseId = {},
    nodeLimit = 1,
}
```

```text
节点池 1413
└─ 节点 1416：十字星的残响
   ├─ weight = 30
   ├─ 不增加机体限制
   └─ nodeLimit = 1
```

| 字段 | 类型 | 作用 |
| --- | --- | --- |
| `groupId` | int | 节点池 ID，对应 `act_ep_map_def.refreshGroup` |
| `nodeId` | int | 加入节点池的节点，对应 `act_node_def.id` |
| `weight` | int | 与同一节点池其他可用节点比较的相对权重 |
| `limitBaseId` | int[] | 允许生成该节点的机体；空表表示不增加机体限制 |
| `nodeLimit` | int | 同一张地图中的出现次数限制 |

## 节点池如何选出节点

游戏先取得同一 `groupId` 下的所有 row，排除当前不可出现的节点，再按 `weight` 抽取一个。

`weight` 是相对权重，不是百分比。例如三个可用节点的权重为 `1`、`2`、`7` 时，它们按 `1:2:7` 参与抽取。

需要固定生成一个节点时，让节点池里只保留一个当前可用且 `weight > 0` 的节点。不要使用极高权重模拟固定结果。

## 哪些节点当前可以出现

判断顺序是：

```text
检查当前机体是否符合 limitBaseId
→ 检查节点出现次数是否达到 nodeLimit
→ 从剩余节点中按 weight 选择
```

### `limitBaseId`

空表表示不增加机体限制：

```lua
limitBaseId = {},
```

非空列表只允许指定机体：

```lua
limitBaseId = { 501, 503 },
```

没有任何节点符合当前机体时，这个节点池无法提供节点。仍被地图使用的节点池至少要保留一个当前机体可用的节点。

### `nodeLimit`

- `nodeLimit = 0`：不增加次数限制。
- `nodeLimit > 0`：限制同一张地图中通常可以出现的次数。
- `nodeLimit = -1`：这行不加入运行时节点池，不参与选择。

如果节点池中所有符合机体条件的节点都已经达到正数 `nodeLimit`，游戏会忽略次数限制重新选择一次，避免节点位置没有内容。因此正数 `nodeLimit` 不是任何情况下都绝对生效的硬上限。

## 修改已有节点池

配置文件放在：

```text
config/act_node_refresh_def/config/*.lua
```

### 追加节点

下面把节点 `990101` 追加到节点池 `1401`：

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "append",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 1,
        },
    },
}
```

`operation = "append"` 会保留原有节点池成员，再加入 MOD 节点。

`installValue` 必须与每一行的 `groupId` 相同。同一个文件只修改一个节点池；需要修改多个节点池时，分别建立批次文件。

### 替换节点池

```lua
return {
    installKey = "groupId",
    installValue = 1401,
    operation = "replace",
    rows = {
        {
            groupId = 1401,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 0,
        },
    },
}
```

`replace` 会清除目标节点池的原有成员，只安装当前 `rows`。一个节点池可能被多个节点位置复用，替换它会同时影响所有引用该 `groupId` 的位置。

修改节点池成员、权重或限制后，需要新建战局观察。已经生成的地图不会自动重新选择节点。

## 在 MOD 中新增 `act_node_refresh_def`

下面建立节点池 `990001`，里面只放节点 `990101`：

```lua
return {
    installKey = "groupId",
    installValue = 990001,
    operation = "append",
    rows = {
        {
            groupId = 990001,
            nodeId = 990101,
            weight = 1,
            limitBaseId = {},
            nodeLimit = 0,
        },
    },
}
```

新节点池通过 [`act_ep_map_def.refreshGroup`](act_ep_map_def.md#节点位置生成什么) 使用。节点 `990101` 需要先在 [`act_node_def`](act_node_def.md) 中提供。
