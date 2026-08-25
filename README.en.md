# Aces Modding

[中文](README.md)

This repository is the author-facing MOD workspace for Aces. The initial commit establishes the public project structure for the local MOD Alpha and early feedback. It is not yet a finished or stable SDK.

## Version-one scope

Version one focuses on configuration-first content packs:

- `card-pack`: card content;
- `enemy-pack`: enemies and their action chains;
- `node-pack`: playable Nodes that assemble enemies, rewards, and related content.

Chinese is the maintained source and default documentation language. English files mirror the Chinese structure. Code identifiers, filenames, and configuration fields remain unchanged.

## Repository map

- `docs/`: getting started, content configuration, Lua API, debugging, compatibility, and limitations;
- `templates/`: templates for the three content-pack types;
- `examples/`: an integrated Card-to-Enemy-to-Node example;
- `game-lua/`: reference area for Lua source distributed with the game;
- `tools/`: validation, packaging, and diagnostics;
- `.github/`: feedback, bug, and capability-request templates.

## Current status

The repository currently contains structure and boundary notes only. Templates, examples, and field-level tutorials remain TODO until their runtime paths are verified. See [Project status](docs/en/status.md).

## Not included in version one

- Steam Workshop publishing;
- YooAsset MOD Packages or an author-side Package Builder;
- hot reload or runtime unloading;
- additional gameplay hooks beyond configuration content packs.

## Critical TODOs before release

- Freeze the author-facing Card, Enemy, and Node configuration contracts;
- verify consistent Enemy and Node loading across Client, LocalServer, and real gameplay;
- provide one playable `node-pack` example;
- finish the detailed Chinese tutorials, then synchronize the English translations;
- decide the repository license and the source-distribution boundary for `game-lua/`;
- add validation, packaging, and compatibility tools.
