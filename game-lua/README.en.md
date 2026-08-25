# Game Lua files

Each game version is released with one matching archive in this directory:

```text
aces-game-lua-<game-version>.zip
```

The source tree is not expanded in this directory; only this archive is stored here.

The game package contains the same readable Lua source stored as `.lua.bytes` files inside its asset packages. This archive restores the normal `.lua` extension and keeps the original directory layout, avoiding manual unpacking, extraction, and renaming. It is not the result of decompilation or decryption.

Use these files to study existing game code. When creating a MOD, depend only on interfaces explicitly listed in the [Lua API documentation](../docs/en/lua-api.md).
