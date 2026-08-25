# 多语言

MOD 有两类独立的多语言内容：

- `locales/<language>/mod.json`：MOD 管理器中的名称和说明；
- `language/language.csv`：Card、Enemy、Node 等配置字段中的玩家可见文本。

## 配置文本 `language.csv`

文件位置：

```text
<mod-root>/language/language.csv
```

必须使用与游戏相同的 20 列表头：

```csv
键值,来源,原文,筛选值,状态,游戏内显示,最后修改时间,备注,zh_cn,zh_tw,en_us,ja_jp,ko_kr,de_de,ru_ru,fr_fr,pt_br,vi_vn,es_es,none
```

示例：

```csv
df2bbcfa8d261352a9cbe8157edc4d1c5,[MOD:example.cardpack][配置表:card_def][表格:config][字段:name][安装键:910001],火花无人机,910001,已翻译,是,,,,,Spark Drone,,,,,,,,,
```

关键规则：

- `键值` 必须与 `原文` 对应；
- 当前语言列为空时回退到配置中的原文；
- 文件缺失时正常安装，全部使用原文；
- 表头、列数、键值或 CSV 结构错误时，放弃该 MOD 的整份语言映射，但配置内容继续安装并回退原文；
- 每个 MOD 的语言映射独立，不会写入 Core 或其他 MOD；
- 不需要提交额外 JSON。

当前没有作者侧自动生成或更新 `language.csv` 的工具。直接编辑时应保持完整表头和现有有效键值格式。

语言切换后，MOD 配置会按新语言重新安装。缺失翻译仍回退作者原文。
