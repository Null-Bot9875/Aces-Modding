# PNG assets

The current author asset path supports Card PNG files inside the MOD `assets/` directory.

## Directory and configuration

```text
<mod-root>/
  assets/
    cards/
      fire_drone.png
```

Card configuration:

```lua
assetId = "cards/fire_drone.png"
```

The loader converts the path to an internal URI:

```text
mod://<mod-id>/cards/fire_drone.png
```

Author configuration contains only the path relative to `assets/`, not a handwritten `mod://` URI.

## Accepted values

| `assetId` | Behavior |
| --- | --- |
| Omitted | Use default Core image `10001` |
| Numeric Core asset ID | Use an existing Core Card image; existence is checked during loading |
| Relative `.png` path | Use a PNG inside the current MOD `assets/` directory |

## Path restrictions

The following values are rejected:

- Absolute paths;
- traversal paths containing `.` or `..` path segments;
- files without a `.png` extension;
- handwritten `mod://` URIs;
- paths targeting another MOD;
- paths outside the current MOD `assets/` root.

PNG files are cached for the session. Image changes require a restart; file watching and hot reload are not available.
