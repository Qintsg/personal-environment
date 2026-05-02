param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$OutputFile = 'SOFTWARE_STATUS.md'
)

$ErrorActionPreference = 'Stop'

$appRoot = Join-Path $RepoRoot 'apps'
$outputPath = Join-Path $RepoRoot $OutputFile

function Get-FirstMatch {
    param(
        [string]$Content,
        [string]$Pattern
    )

    $match = [regex]::Match($Content, $Pattern, 'Multiline')
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return ''
}

function ConvertTo-PlainValue {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return '待补充'
    }

    $plain = $Value.Trim() -replace '^`|`$', ''
    if ([string]::IsNullOrWhiteSpace($plain)) {
        return '待补充'
    }
    return $plain
}

function Escape-TableCell {
    param([string]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return ($Value.Trim() -replace '\|', '\|' -replace "`r?`n", '<br>')
}

function Get-InstallStatus {
    param(
        [string]$Source,
        [string]$Version
    )

    if ($Source -eq '待补充' -and $Version -eq '待补充') {
        return '状态待补充'
    }

    $state = '已安装'
    if ($Source -match '本机命令扫描') {
        $state = '已检测到本机命令'
    }

    if ($Version -eq '待补充') {
        return "$state（来源：$Source；版本待补充）"
    }

    return "$state（来源：$Source；版本：$Version）"
}

function Get-Description {
    param(
        [string]$Slug,
        [string]$Title,
        [string]$Source,
        [string]$Version,
        [string]$Content
    )

    $descriptionOverrides = @{
        'android-studio' = 'Android 官方 IDE，当前通过 JetBrains Toolbox 管理安装。'
        'azure-cli' = 'Microsoft Azure 命令行工具。'
        'bun' = 'JavaScript 运行时与包管理工具。'
        'cargo-binstall' = '用于安装 Rust 预编译二进制包的 Cargo 工具。'
        'cargo-update' = '用于批量更新 Cargo 全局安装包的命令行工具。'
        'chatgpt' = 'OpenAI ChatGPT 桌面应用或 Store 应用记录。'
        'codex' = 'OpenAI Codex 桌面应用记录；npm CLI 另见 @openai/codex。'
        'docker-desktop' = 'Docker Desktop 桌面容器环境。'
        'dotnet-sdk' = '.NET SDK 与本机 dotnet 工具链记录。'
        'git' = 'Git 版本控制工具。'
        'go' = 'Go 语言工具链。'
        'java' = 'Java/JDK 工具链记录。'
        'jetbrains-toolbox' = 'JetBrains IDE 统一安装和更新管理器。'
        'microsoft-365' = 'Microsoft Office / Microsoft 365 桌面应用套件。'
        'neovim' = 'Neovim 编辑器及本机配置入口。'
        'nodejs' = 'Node.js JavaScript 运行时记录。'
        'nodejs-lts' = '通过 Scoop 记录的 Node.js LTS 安装项。'
        'npm' = 'Node.js 默认包管理器。'
        'pnpm' = '高性能 Node.js 包管理器。'
        'powershell' = 'PowerShell 运行时和配置入口。'
        'python' = 'Python 运行时与包管理环境记录。'
        'rust' = 'Rustup/Rust 工具链记录。'
        'scoop' = 'Windows 命令行包管理器。'
        'ubuntu-2404' = 'WSL Ubuntu 24.04 发行版。'
        'uv' = 'Astral 的 Python 包和工具管理器。'
        'visual-studio-code' = 'Visual Studio Code 编辑器及用户配置记录。'
        'visual-studio-code-insiders' = 'Visual Studio Code Insiders 编辑器及用户配置记录。'
        'wezterm' = 'WezTerm 终端模拟器及模块化配置入口。'
        'winget' = 'Windows Package Manager / App Installer。'
        'wsl' = 'Windows Subsystem for Linux。'
        'yarn' = 'Node.js Yarn 包管理器。'
    }

    if ($descriptionOverrides.ContainsKey($Slug)) {
        return $descriptionOverrides[$Slug]
    }

    if ($Slug -like 'npm-*') {
        return '全局 npm 包，用于命令行或开发工作流。'
    }

    if ($Source -match 'cargo install') {
        return '通过 Cargo 安装的 Rust 命令行工具。'
    }

    if ($Source -match 'dotnet tool') {
        return '通过 dotnet tool 安装的 .NET 全局工具。'
    }

    if ($Source -match 'JetBrains Toolbox') {
        return 'JetBrains 系列开发工具，当前通过 Toolbox 管理。'
    }

    $remarks = [regex]::Matches($Content, '(?m)^- (.+)$') | ForEach-Object { $_.Groups[1].Value.Trim() }
    foreach ($remark in $remarks) {
        if ($remark -match '^(来源：|当前版本：|包 ID：)') {
            continue
        }
        if ($remark -match '^(当前记录来自|后续可补充|不在仓库中记录|npm 清单中未返回版本号|winget 清单未直接匹配)') {
            continue
        }
        return $remark.TrimEnd('。') + '。'
    }

    if ($Version -and $Version -ne '待补充') {
        return "本机记录的 $Title 安装项，当前版本 $Version。"
    }

    return "本机记录的 $Title 安装项。"
}

if (-not (Test-Path -LiteralPath $appRoot)) {
    throw "apps directory not found: $appRoot"
}

$docs = Get-ChildItem -LiteralPath $appRoot -Directory |
    Where-Object { $_.Name -ne '_inventory' } |
    ForEach-Object {
        $installDoc = Join-Path $_.FullName 'install.md'
        if (Test-Path -LiteralPath $installDoc) {
            Get-Item -LiteralPath $installDoc
        }
    } |
    Sort-Object { $_.Directory.Name }

$rows = foreach ($doc in $docs) {
    $slug = $doc.Directory.Name
    $relativeDoc = 'apps/' + $slug + '/install.md'
    $content = Get-Content -LiteralPath $doc.FullName -Raw

    $title = Get-FirstMatch $content '^#\s+(.+)$'
    if ([string]::IsNullOrWhiteSpace($title)) {
        $title = $slug
    }

    $source = ConvertTo-PlainValue (Get-FirstMatch $content '^- 来源：(.+)$')
    $version = ConvertTo-PlainValue (Get-FirstMatch $content '^- 当前版本：(.+)$')
    $packageId = ConvertTo-PlainValue (Get-FirstMatch $content '^- 包 ID：(.+)$')
    $status = Get-InstallStatus $source $version
    $description = Get-Description $slug $title $source $version $content

    [pscustomobject]@{
        Title = $title
        RelativeDoc = $relativeDoc
        PackageId = $packageId
        Status = $status
        Description = $description
    }
}

$generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 软件包本机安装状态总览') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("生成时间：$generatedAt") | Out-Null
$lines.Add('') | Out-Null
$lines.Add("数据来源：``apps/*/install.md``，共 $($rows.Count) 项。本机安装状态基于仓库中最近一次导出的来源和版本记录，不代表重新实时扫描。") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| 软件/包名称 | ID | 本机安装状态 | 简介 |') | Out-Null
$lines.Add('| --- | --- | --- | --- |') | Out-Null

foreach ($row in $rows) {
    $nameCell = '[' + (Escape-TableCell $row.Title) + '](' + $row.RelativeDoc + ')'
    $line = '| ' + $nameCell +
        ' | ' + (Escape-TableCell $row.PackageId) +
        ' | ' + (Escape-TableCell $row.Status) +
        ' | ' + (Escape-TableCell $row.Description) +
        ' |'
    $lines.Add($line) | Out-Null
}

$content = ($lines -join "`n") + "`n"
Set-Content -LiteralPath $outputPath -Value $content -Encoding UTF8

Write-Host "Generated $OutputFile with $($rows.Count) item(s)."
