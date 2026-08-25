# Aces Modding

[中文](README.md)

Create custom cards, enemies, and Nodes for Aces from this repository.

These resources focus on configuration-first content MODs. Modifying the game itself or studying the entire game codebase is not required.

> This is currently a preview of the author resources. Tutorials, templates, and examples marked “In preparation” cannot yet be used directly to create a MOD.

## Content goals

- New cards and effects;
- new enemies and action patterns;
- new Nodes containing enemies, rewards, and related content;
- complete playable content assembled from these pieces.

## Choose a starting point

| Goal | Start here |
| --- | --- |
| Create a first MOD | [Getting started](docs/en/getting-started.md) |
| Read and modify a complete MOD | [Complete example](examples/complete-mod/README.en.md) |
| Create cards only | [card-pack template](templates/card-pack/README.en.md) |
| Create enemies only | [enemy-pack template](templates/enemy-pack/README.en.md) |
| Build a Node from scratch | [node-pack template](templates/node-pack/README.en.md) |
| Diagnose loading or behavior problems | [Debugging guide](docs/en/debugging.md) |

`examples/complete-mod` is a complete example to read and modify. `templates/node-pack` is a blank starting point for building a Node from scratch.

## Documentation

- [Documentation index](docs/en/README.md)
- [What a MOD package contains](docs/en/mod-package.md)
- [Card configuration tutorial](docs/en/content/card.md)
- [Enemy configuration tutorial](docs/en/content/enemy.md)
- [Node configuration tutorial](docs/en/content/node.md)
- [Available Lua APIs](docs/en/lua-api.md)
- [What is currently available](docs/en/status.md)
- [Current limitations](docs/en/limitations.md)

Chinese is the default documentation language. English pages mirror the Chinese pages. Code identifiers, filenames, and configuration fields are not translated.

## Not currently available

- Steam Workshop publishing;
- YooAsset MOD Packages;
- hot reload or runtime unloading;
- additional gameplay hooks not listed in the documentation.

For MODs that depend on one of these capabilities, open a “Capability request” in GitHub Issues and describe the intended content.

## Getting help

Open this repository’s GitHub Issues page and choose:

- “MOD author feedback” when the next step or documentation is unclear;
- “Bug report” when following the documentation produces the wrong result;
- “Capability request” when Card, Enemy, and Node content cannot express the intended design.
