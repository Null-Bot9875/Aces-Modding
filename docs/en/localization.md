# Localization

A MOD has two separate localization areas:

- `locales/<language>/mod.json`: name and description in the MOD manager;
- `language/language.csv`: player-facing text inside Card, Enemy, and Node configuration.

## Configuration text in `language.csv`

File location:

```text
<mod-root>/language/language.csv
```

The file must use the same 20-column header as the game:

```csv
键值,来源,原文,筛选值,状态,游戏内显示,最后修改时间,备注,zh_cn,zh_tw,en_us,ja_jp,ko_kr,de_de,ru_ru,fr_fr,pt_br,vi_vn,es_es,none
```

Example:

```csv
df2bbcfa8d261352a9cbe8157edc4d1c5,[MOD:example.cardpack][配置表:card_def][表格:config][字段:name][安装键:910001],火花无人机,910001,已翻译,是,,,,,Spark Drone,,,,,,,,,
```

Rules:

- `键值` must correspond to `原文`.
- An empty current-language column falls back to the original configuration text.
- A missing file is valid and uses original text everywhere.
- Header, column count, key, or CSV structure errors discard the entire language map for that MOD; configuration still installs and falls back to original text.
- Every MOD language map is independent and is not written into Core or another MOD.
- No additional JSON file is required.

No author-side generator or updater for `language.csv` is currently provided. Manual edits must retain the complete header and an existing valid key format.

After a language change, MOD configuration is reinstalled for the new language. Missing translations continue to fall back to the author text.
