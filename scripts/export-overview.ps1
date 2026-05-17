param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$OutputFile = 'SOFTWARE_OVERVIEW.md'
)

$ErrorActionPreference = 'Stop'

$appRoot = Join-Path $RepoRoot 'apps'
$outputPath = Join-Path $RepoRoot $OutputFile

$manualDownloads = @{
    'autodesk-dwg-trueview' = 'https://www.autodesk.com/products/dwg-trueview/overview'
    'chatgpt' = 'https://openai.com/chatgpt/download/'
    'codex' = 'https://openai.com/codex/'
    'devtoys' = 'https://devtoys.app/download'
    'easyconnect' = 'https://www.sangfor.com.cn/product-and-solution/sangfor-easyconnect'
    'foundry-vtt' = 'https://foundryvtt.com/purchase/'
    'gaomon-tablet' = 'https://www.gaomon.net/download/'
    'iis-express' = 'https://www.microsoft.com/download/details.aspx?id=48264'
    'led-control-system' = 'http://www.zoehoo.com/'
    'microsoft-365' = 'https://www.microsoft.com/microsoft-365/download-office'
    'micyou' = 'https://micyou.top/'
    'neo4j-desktop' = 'https://neo4j.com/download/'
    'npcap' = 'https://npcap.com/#download'
    'nvidia-cudnn' = 'https://developer.nvidia.com/cudnn/downloads'
    'nvidia-nsight-compute' = 'https://developer.nvidia.com/nsight-compute'
    'nvidia-nsight-systems' = 'https://developer.nvidia.com/nsight-systems'
    'nvidia-nsight-visual-studio-edition' = 'https://developer.nvidia.com/nsight-visual-studio-edition'
    'oopz' = 'https://apps.microsoft.com/detail/xpffvvn4zmzjdf'
    'openfrp-launcher' = 'https://www.openfrp.net/download'
    'pixpin' = 'https://pixpinapp.com/'
    'redis-on-windows' = 'https://github.com/tporadowski/redis/releases'
    'reinamanager' = 'https://github.com/huoshen80/ReinaManager/releases'
    'sangfor-vnc' = 'https://sangforvnc.software.informer.com/download/'
    'sspu-all-in-one' = 'https://github.com/Qintsg/SSPU-all-in-one/releases'
    'sql-server-localdb' = 'https://www.microsoft.com/sql-server/sql-server-downloads'
    'sunlogin' = 'https://sunlogin.oray.com/download'
    'think-control' = 'http://www.creator.com.cn'
    'thunder' = 'https://dl.xunlei.com/'
    'usbpcap' = 'https://desowin.org/usbpcap/'
    'vbcable' = 'https://vb-audio.com/Cable/'
    'watt-toolkit' = 'https://steampp.net/'
    'winhance' = 'https://github.com/memstechtips/Winhance/releases'
    'wps-office' = 'https://www.wps.cn/product/wpswindows'
    'xiaoai-service' = 'https://apps.microsoft.com/detail/9mw76kfhnz0c'
    'xuexitong' = 'https://app.chaoxing.com/'
}

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

    $plain = $Value.Trim()
    $plain = $plain -replace '^`|`$', ''
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

function Escape-CodeText {
    param([string]$Value)

    $escaped = $Value.Trim()
    $escaped = $escaped -replace '&', '&amp;'
    $escaped = $escaped -replace '<', '&lt;'
    $escaped = $escaped -replace '>', '&gt;'
    $escaped = $escaped -replace '\|', '\|'
    return $escaped
}

function Get-CodeBlocks {
    param([string]$Content)

    $blocks = New-Object System.Collections.Generic.List[string]
    $matches = [regex]::Matches($Content, '(?ms)^```[^\r\n]*\r?\n(.*?)\r?\n```')
    foreach ($match in $matches) {
        $block = $match.Groups[1].Value.Trim()
        if (-not [string]::IsNullOrWhiteSpace($block)) {
            $blocks.Add($block) | Out-Null
        }
    }
    return $blocks
}

function Format-InstallCommand {
    param(
        [string]$Slug,
        [string]$Content
    )

    $blocks = Get-CodeBlocks $Content
    if ($blocks.Count -gt 0) {
        $parts = New-Object System.Collections.Generic.List[string]
        foreach ($block in $blocks) {
            $lines = $block -split "\r?\n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            foreach ($line in $lines) {
                $parts.Add('<code>' + (Escape-CodeText $line) + '</code>') | Out-Null
            }
        }
        return ($parts -join '<br>')
    }

    if ($manualDownloads.ContainsKey($Slug)) {
        return '手动下载：[下载页](' + $manualDownloads[$Slug] + ')'
    }

    return '手动安装来源待确认'
}

function Add-Manager {
    param(
        [System.Collections.Generic.List[string]]$Managers,
        [string]$Manager
    )

    if (-not [string]::IsNullOrWhiteSpace($Manager) -and -not $Managers.Contains($Manager)) {
        $Managers.Add($Manager) | Out-Null
    }
}

function Get-PackageManagers {
    param(
        [string]$Source,
        [string]$InstallCommand
    )

    $managers = New-Object System.Collections.Generic.List[string]
    $sourceText = $Source.ToLowerInvariant()
    $commandText = $InstallCommand.ToLowerInvariant()

    if ($sourceText -match 'winget' -or $commandText -match '<code>winget(\.exe)?\s') { Add-Manager $managers 'winget' }
    if ($sourceText -match 'scoop' -or $commandText -match '<code>scoop(\.ps1)?\s') { Add-Manager $managers 'scoop' }
    if ($sourceText -match 'choco|chocolatey' -or $commandText -match '<code>choco(\.exe)?\s') { Add-Manager $managers 'choco' }
    if ($sourceText -match 'npm 全局包' -or $commandText -match '<code>npm(\.cmd)?\s') { Add-Manager $managers 'npm' }
    if ($sourceText -match 'pnpm' -or $commandText -match '<code>pnpm(\.cmd)?\s') { Add-Manager $managers 'pnpm' }
    if ($sourceText -match 'yarn' -or $commandText -match '<code>yarn(\.cmd)?\s') { Add-Manager $managers 'yarn' }
    if ($sourceText -match 'cargo install' -or $commandText -match '<code>cargo(\.exe)?\s') { Add-Manager $managers 'cargo' }
    if ($sourceText -match 'dotnet tool' -or $commandText -match '<code>dotnet(\.exe)?\s+tool\s') { Add-Manager $managers 'dotnet tool' }
    if ($sourceText -match '^uv$|uv tool' -or $commandText -match '<code>uv(\.exe)?\s') { Add-Manager $managers 'uv' }
    if ($sourceText -match '^pip$|pip ' -or $commandText -match '<code>pip(\.exe)?\s') { Add-Manager $managers 'pip' }
    if ($sourceText -match 'microsoft store|store 应用|msix' -or $commandText -match 'msstore|microsoft store') { Add-Manager $managers 'Microsoft Store / MSIX' }
    if ($sourceText -match 'jetbrains toolbox') { Add-Manager $managers 'JetBrains Toolbox' }
    if ($sourceText -match 'visual studio') { Add-Manager $managers 'Visual Studio Installer' }
    if ($commandText -match '<code>(set-executionpolicy|invoke-restmethod|irm|iwr)\b') { Add-Manager $managers 'PowerShell 脚本' }
    if ($sourceText -match '注册表扫描') { Add-Manager $managers '注册表扫描' }
    if ($sourceText -match '本机命令扫描') { Add-Manager $managers '本机命令扫描' }
    if ($commandText -match '手动下载|手动安装' -or $sourceText -match '官网下载|原安装包|组织提供') { Add-Manager $managers '手动下载' }

    if ($managers.Count -eq 0) {
        Add-Manager $managers (ConvertTo-PlainValue $Source)
    }

    return ($managers -join ' / ')
}

function Get-Platform {
    param(
        [string]$Slug,
        [string]$Managers,
        [string]$InstallCommand
    )

    $crossPlatformSlugs = @(
        'bun',
        'cargo-binstall',
        'cargo-update',
        'dotnet-sdk',
        'go',
        'java',
        'nodejs',
        'npm',
        'pnpm',
        'rust',
        'tauri-cli',
        'trunk',
        'uv',
        'yarn'
    )
    $crossPlatformManagerPattern = 'npm|pnpm|yarn|cargo|dotnet tool|uv|pip'

    if ($Slug -in @('wsl', 'ubuntu-2404')) {
        return 'Windows / Linux'
    }

    if ($Slug -like 'npm-*' -or $Slug -in $crossPlatformSlugs -or $Managers -match $crossPlatformManagerPattern) {
        return 'Windows / Linux'
    }

    if ($InstallCommand -match 'wsl|ubuntu|linux') {
        return 'Windows / Linux'
    }

    return 'Windows'
}

function Get-Description {
    param(
        [string]$Slug,
        [string]$Title,
        [string]$Source,
        [string]$Version,
        [string]$Content
    )

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

$rows = New-Object System.Collections.Generic.List[object]
$missingManualLinks = New-Object System.Collections.Generic.List[string]

foreach ($doc in $docs) {
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
    $installCommand = Format-InstallCommand $slug $content
    $managers = Get-PackageManagers $source $installCommand
    $platform = Get-Platform $slug $managers $installCommand
    $description = Get-Description $slug $title $source $version $content

    if ($installCommand -eq '手动安装来源待确认') {
        $missingManualLinks.Add($slug) | Out-Null
    }

    $rows.Add([pscustomobject]@{
            Slug = $slug
            Title = $title
            RelativeDoc = $relativeDoc
            PackageId = $packageId
            Managers = $managers
            Platform = $platform
            InstallCommand = $installCommand
            Description = $description
        }) | Out-Null
}

$generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 软件与包总览') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("生成时间：$generatedAt") | Out-Null
$lines.Add('') | Out-Null
$lines.Add("数据来源：``apps/*/install.md``，共 $($rows.Count) 项。安装命令以当前仓库记录为准；缺少可复现包管理器命令的项目会在安装命令列给出手动下载页。") | Out-Null
$lines.Add('手动下载链接优先使用官网、Microsoft Store、GitHub Releases 或项目发布页；少量组织分发或停更软件只记录可定位来源，恢复前需要人工复核。') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| 软件/包名称 | ID | 包管理器 | 平台 | 安装命令 | 简介 |') | Out-Null
$lines.Add('| --- | --- | --- | --- | --- | --- |') | Out-Null

foreach ($row in $rows) {
    $nameCell = '[' + (Escape-TableCell $row.Title) + '](' + $row.RelativeDoc + ')'
    $line = '| ' + $nameCell +
        ' | ' + (Escape-TableCell $row.PackageId) +
        ' | ' + (Escape-TableCell $row.Managers) +
        ' | ' + (Escape-TableCell $row.Platform) +
        ' | ' + $row.InstallCommand +
        ' | ' + (Escape-TableCell $row.Description) +
        ' |'
    $lines.Add($line) | Out-Null
}

if ($missingManualLinks.Count -gt 0) {
    $lines.Add('') | Out-Null
    $lines.Add('## 待补充手动下载链接') | Out-Null
    $lines.Add('') | Out-Null
    foreach ($slug in $missingManualLinks) {
        $lines.Add("- $slug") | Out-Null
    }
}

$content = ($lines -join "`n") + "`n"
Set-Content -LiteralPath $outputPath -Value $content -Encoding UTF8

Write-Host "Generated $OutputFile with $($rows.Count) item(s)."
if ($missingManualLinks.Count -gt 0) {
    Write-Warning "Missing manual download links: $($missingManualLinks -join ', ')"
}
