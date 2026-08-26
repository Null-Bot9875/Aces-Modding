# Aces Modding

[中文](README.md)

This repository provides author resources for Aces Card, Enemy, and Node MODs.

These resources focus on configuration-first content MODs. Modifying the game itself or studying the entire game codebase is not required.

> This is a local human-validation candidate. `card-pack` and the integrated Node-and-Enemy example are included, but Card, Node, and Enemy still require separate human tests. A public [LICENSE](LICENSE.md) must also be selected before publication.

## Version-one goals

- new Cards that reuse existing game Skills, Targets, and cost Effects;
- new enemies and action patterns;
- new Nodes containing enemies, rewards, and related content;
- complete playable content assembled from these pieces.

## Choose a starting point

| Goal | Start here |
| --- | --- |
| Create a first MOD | [Getting started](docs/en/getting-started.md) |
| Test the complete Node-to-Enemy reference chain | [Complete Node and Enemy example](examples/complete-mod/README.en.md) |
| Create cards only | [card-pack template](templates/card-pack/README.en.md) |
| Learn Enemy configuration | [Enemy configuration tutorial](docs/en/content/enemy.md) |
| Learn Node configuration | [Node configuration tutorial](docs/en/content/node.md) |
| Run version-one human tests | [Manual testing checklist](docs/en/manual-testing.md) |
| Diagnose loading or behavior problems | [Debugging guide](docs/en/debugging.md) |

`templates/enemy-pack` and `templates/node-pack` do not yet contain separate runnable files. Both templates will be extracted from the validated structure after the integrated example passes human testing.

## Documentation

- [Documentation index](docs/en/README.md)
- [What a MOD package contains](docs/en/mod-package.md)
- [General configuration format](docs/en/configuration.md)
- [PNG assets](docs/en/assets.md)
- [Localization](docs/en/localization.md)
- [Card configuration tutorial](docs/en/content/card.md)
- [Enemy configuration tutorial](docs/en/content/enemy.md)
- [Node configuration tutorial](docs/en/content/node.md)
- [Version-one manual testing checklist](docs/en/manual-testing.md)
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
