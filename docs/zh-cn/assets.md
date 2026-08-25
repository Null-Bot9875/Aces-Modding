# PNG 资源

当前作者资源支持 Card 使用本 MOD `assets/` 目录内的 PNG。

## 目录与写法

```text
<mod-root>/
  assets/
    cards/
      fire_drone.png
```

Card 配置：

```lua
assetId = "cards/fire_drone.png"
```

加载时会转换为内部 URI：

```text
mod://<mod-id>/cards/fire_drone.png
```

作者配置中只写相对于 `assets/` 的路径，不直接填写 `mod://`。

## 允许的值

| `assetId` | 行为 |
| --- | --- |
| 省略 | 使用默认 Core 图片 `10001` |
| Core 数字资源 ID | 使用已有 Core Card 图片；加载时校验资源存在 |
| 相对 `.png` 路径 | 使用当前 MOD `assets/` 中的 PNG |

## 路径限制

以下写法会被拒绝：

- 绝对路径；
- 包含 `.` 或 `..` 路径段的越级路径；
- 非 `.png` 文件；
- 手写 `mod://` URI；
- 指向其他 MOD 的路径；
- 越过当前 MOD `assets/` 根目录的路径。

PNG 在会话中缓存。修改图片后需要重新启动游戏；当前不支持文件监控或热重载。
