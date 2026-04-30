# Scoop

## 默认平台

默认安装平台为 Windows；本文件中的安装命令默认在 Windows PowerShell 中执行。

## 当前记录

- 来源：本机命令扫描
- 当前版本：待补充
- 包 ID：待补充

## 安装方式

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

## 备注

- 已检测到本机存在 `scoop` 命令。
