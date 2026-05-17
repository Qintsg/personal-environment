# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

这是一个用于记录和同步 Windows 个人电脑环境的清单仓库。核心内容不是应用源码，而是软件安装记录、可公开配置片段、包管理器导出结果和环境恢复说明。仓库目标是在更换设备、重装系统或回溯配置时，快速恢复一套可用的工作环境。

## 常用命令

以下命令默认从仓库根目录运行。当前仓库脚本是 PowerShell，若 Claude Code 运行在 Git Bash/MSYS2 中，使用 `powershell.exe` 调用；若已经在 PowerShell 中，可直接运行 `.\scripts\...` 形式的脚本命令。

```bash
# 同步本机软件包清单、包管理器原始导出和可恢复 install.md 记录
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/export-packages.ps1

# 在同步软件包时为新的 winget 可导入包创建 app 目录；运行后需要人工复核运行库和系统组件
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/export-packages.ps1 -AddNewWingetDocs

# 同步白名单内的常用配置文件，并在写入前做通用脱敏
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/export-configs.ps1

# 根据 apps/*/install.md 生成软件与包总览
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/export-overview.ps1

# 根据 apps/*/install.md 生成本机安装状态总览
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/export-status-overview.ps1
```

仓库根目录未配置传统应用项目的 build、lint 或 test 命令；没有根级 `package.json`、`pyproject.toml`、`Cargo.toml`、`go.mod` 或 `.sln`。如果只修改 Markdown 或导出清单，主要验证方式是重新运行相关生成脚本并复核产生的 Markdown/JSON 变化。

## 主要结构

- `apps/`：按“一个软件一个目录”记录工具软件。每个软件目录至少包含 `install.md`，Windows 是默认安装平台。配置文件可直接放在软件目录下，复杂配置放在 `config/` 子目录，插件或扩展列表使用 `extensions.md`。
- `apps/_inventory/`：由同步脚本生成的包管理器和系统清单原始导出，用于完整复核，不等同于逐项可恢复的安装文档。
- `docs/`：维护规则文档，包括程序存放规则、软件记录规范和配置存放规则。
- `scripts/`：同步和总览生成脚本。`export-packages.ps1` 更新包清单与部分 `install.md`，`export-configs.ps1` 导出白名单配置，`export-overview.ps1` 和 `export-status-overview.ps1` 从 `apps/*/install.md` 汇总生成总览。
- `README.md`：仓库目标、目录约定、同步脚本和文档索引。

## 软件记录约定

`apps/<slug>/install.md` 的目录名使用小写英文、数字和连字符。文档应包含软件名称、默认平台、当前记录、安装方式和备注；安装命令优先记录可复现的包管理器命令，例如 `winget`、`scoop`、`choco`、`npm install -g`、`cargo install`、`dotnet tool install --global`。无法确认包管理器来源的软件先记录为手动安装，并说明后续需要补充来源。

`export-packages.ps1` 默认会保存完整 `winget export` 清单，但只更新已存在的 winget 软件目录，避免自动加入大量运行库和 Store 组件。只有显式传入 `-AddNewWingetDocs` 时才会为新的 winget 可导入包创建目录。

## 配置同步约定

`export-configs.ps1` 只读取脚本中列出的白名单路径，并在写入前替换用户目录、邮箱和常见凭据字段。高风险凭据或运行态目录使用 `credentials-skipped.md` / `config-skipped.md` 记录跳过原因，而不是保存原始内容。

新增配置时遵循 `docs/配置存放规则.md`：单文件配置直接放入对应软件目录，多文件配置放入 `config/` 子目录，命令导出的环境或配置可保留原格式，例如 `go-env.json`、`rustup-show.md`。

## 生成物复核

运行同步脚本后优先复核：

- `apps/package-export-summary.md`：本次包清单导出的范围、更新过的 `install.md` 和跳过项。
- `apps/config-export-summary.md`：本次配置导出的范围和脱敏处理说明。
- `SOFTWARE_OVERVIEW.md`：由 `apps/*/install.md` 生成的软件与包总览。
- `SOFTWARE_STATUS.md`：由 `apps/*/install.md` 生成的本机安装状态总览。

## 规则文件说明

仓库根目录当前没有 `.cursor/rules/`、`.cursorrules` 或 `.github/copilot-instructions.md`。`apps/codex/AGENTS.md` 和 `apps/opencode/config/AGENTS.md` 是被同步出来的工具配置，不是本仓库的根级协作规则。
