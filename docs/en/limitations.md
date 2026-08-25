# Current limitations

The following are not currently available:

- Steam Workshop publishing;
- YooAsset MOD Packages;
- hot reload or runtime unloading;
- custom audio, Prefabs, AssetBundles, and similar resources;
- additional gameplay hooks beyond configuration content packs;
- simplified author formats for custom Skills, Targets, and cost Effects;
- cross-MOD `mod://` image dependencies;
- internal game interfaces not listed in the documentation.

The current Card tutorial covers regular tactical Cards that reuse existing Skills, Targets, and cost Effects.

Configuration tables without an author adapter can still submit complete rows through the [General configuration format](configuration.md), but actual gameplay consumption must be established by the in-game verification in the matching content tutorial.

For MODs that depend on one of these capabilities, choose “Capability request” in GitHub Issues and describe the intended content and current blocker.
