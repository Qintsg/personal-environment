# 软件目录索引

本目录按“一个软件一个文件夹”的方式记录工具软件。每个软件目录至少包含 `install.md`，其中 Windows 是默认安装平台。

当前已根据本机扫描结果生成 357 个软件目录，并对常见软件配置做了脱敏导出。

## 使用方式

- 查找软件：按目录名进入对应软件目录。
- 恢复安装：优先执行 `install.md` 中记录的包管理器命令。
- 补充配置：在软件目录内新增 `config.md`、`extensions.md` 或实际配置文件。
- 查看导出记录：参考 `config-export-summary.md`。
- 查看完整包清单：参考 `package-export-summary.md` 和 `_inventory/` 下的原始导出。

## 来源范围

- Windows 已安装程序注册表。
- `winget`、`scoop`、`choco` 已安装清单。
- `npm`、`cargo`、`dotnet tool` 全局工具清单。
- AppX、pip、pnpm、yarn、Go binary 和 PowerShell module 快照。

## 配置导出

- 配置文件直接放在对应软件目录下，复杂配置可放入 `config/` 子目录。
- 已脱敏内容使用 `<redacted>`、`<email>`、`%USERPROFILE%` 等占位符。
- 高风险凭据文件只记录跳过说明，不保存原始内容。

游戏、纯系统运行库和明显的系统内置组件默认不放入本目录，除非它们对环境恢复有实际意义。
