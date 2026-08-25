# 通用配置格式

配置型 MOD 通过 Lua 文件向现有配置表追加或替换 row。

## 文件位置

```text
config/<module>/<sheet>/<file>.lua
```

- `<module>`：目标配置名，例如 `card_def`；
- `<sheet>`：目标 sheet，例如 `config`；
- `<file>.lua`：批次文件名，只参与排序和错误定位。

`module` 和 `sheet` 只使用字母、数字和下划线。

## 最小批次

```lua
return {
    rows = {
        {
            key = "example_key",
            text = "Example text",
        },
    },
}
```

没有专用作者适配器的配置表必须提交完整 row。字段和类型参考同版本游戏 Lua 文件中的对应配置表。

## `installKey`

`installKey` 选择目标配置已有的查询索引。

### 省略 `installKey`

```lua
return {
    rows = {
        { key = "example", text = "Example" },
    },
}
```

所有 row 直接追加。加载器不会猜测 `id` 或第一字段。

### 普通索引

```lua
return {
    installKey = "cardId",
    rows = {
        {
            cardId = 910001,
            -- 完整 row 或该表允许的作者简化 row
        },
    },
}
```

- 查询键已存在：在原数组位置替换完整 row；
- 查询键不存在：追加到数组末尾。

### 复合索引

```lua
return {
    installKey = { "baseId", "level" },
    rows = {
        {
            baseId = 9001,
            level = 1,
            -- 其他完整字段
        },
    },
}
```

字段顺序必须与目标查询索引一致。

### 组索引

组索引操作一个完整分组：

```lua
return {
    installKey = "poolId",
    installValue = 990001,
    operation = "replace",
    rows = {
        {
            poolId = 990001,
            cardId = 910001,
            -- 其他完整字段
        },
    },
}
```

- `installValue` 必填；
- `operation` 默认是 `replace`；
- `replace` 会删除旧组，再写入当前 `rows`；
- `append` 保留旧组并追加；
- 一个文件只操作一个目标组；
- `replace` 配合空 `rows` 可以清空组。

## Card 专用适配

当前只有 `card_def.config` 提供作者简化格式。该表允许只填写 8 个必填字段，其余字段由固定默认值补齐。

其他表，包括卡池、奖励、Enemy 和 Node 相关表，在对应作者教程明确说明前都按完整 row 处理。

## ID、覆盖和冲突

- 配置 ID 保持目标表原有类型；
- 数字 ID 仍使用数字，不增加 `core:` 或 MOD ID 前缀；
- `mod.json.id` 只标识 MOD 来源和加载顺序；
- 不同 MOD 使用相同配置 ID 时，后加载的完整定义生效；
- 新内容应选择不与 Core 和其他 MOD 冲突的 ID。

## 事务与失败

一个 MOD 的全部批次先完成读取和规范化，再开始安装。

- 单个批次失败时，回滚该 MOD 已修改的 sheet；
- 任一已启用 MOD 安装失败时，回滚本轮所有 MOD 配置；
- 不会留下 Core 与部分 MOD 混合的半安装状态；
- 修正文件后需要重新启动游戏。

本页只说明安装格式。每张配置表是否会在目标玩法中生效，以对应 Card、Enemy、Node 教程的游戏内验证为准。
