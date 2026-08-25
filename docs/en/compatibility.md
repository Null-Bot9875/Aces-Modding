# Game updates and MOD compatibility

When creating a MOD, depend only on configuration fields and Lua APIs explicitly listed in the documentation. Internal game names may be reachable but can change after a game update.

## Declare supported versions

`mod.json.supportedGameVersions` uses a `major.minor` array:

```json
{
  "supportedGameVersions": ["1.0"]
}
```

Entries such as `1.0.8` are invalid. A copied template must be changed to the target game version.

## Stable author contracts

- MOD package structure explicitly documented in this repository;
- [General configuration format](configuration.md);
- fields and reference rules explicitly listed in content tutorials;
- [Lua APIs](lua-api.md);
- the same-version `game-lua` archive, used as reference for existing implementation.

## Unstable implementation

- Internal game Lua objects not listed in the documentation;
- accidentally reachable C# types;
- Core configuration fields not described as author contracts;
- runtime absolute paths and internal cache names.

After a game update, check the [changelog](../../CHANGELOG.en.md) and compare configuration and calls against the matching `game-lua` archive. Format changes affecting MOD authors should be described in the changelog.
