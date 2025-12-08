# Check-GenshinPath.ps1
# 用于排查原神祈愿链接获取失败时的路径问题
# 会输出：日志路径、解析到的 gameDir、webCaches 路径、最新缓存版本和 data_2 路径

# --- 解决 PowerShell 中文显示问题（UTF-8） ---
try {
    chcp 65001 > $null 2>&1 | Out-Null
} catch {}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Host "=== 原神路径诊断脚本（Genshin Path Debug） ===`n"

try {
    # 1. 构造日志路径（对应 getLogPath）
    $userProfile = $env:USERPROFILE
    $basePath   = Join-Path $userProfile 'AppData\LocalLow\miHoYo'
    $globalLog  = Join-Path $basePath 'Genshin Impact\output_log.txt'
    $chinaLog   = Join-Path $basePath '原神\output_log.txt'

    Write-Host "[1] USERPROFILE: $userProfile"
    Write-Host "[1] basePath   : $basePath"

    $logPath = $null
    if (Test-Path -LiteralPath $globalLog) {
        $logPath = $globalLog
    } elseif (Test-Path -LiteralPath $chinaLog) {
        $logPath = $chinaLog
    }

    if (-not $logPath) {
        Write-Host "`n[结果] 未找到原神日志文件（output_log.txt）。"
        Write-Host "请确认游戏至少启动过一次，然后再运行本脚本。"
        return
    }

    Write-Host "`n[2] 日志文件路径:"
    Write-Host "    $logPath"

    # 2. 从日志中解析 gameDir（对应 extractGameDir）
    $logContent = Get-Content -LiteralPath $logPath -Raw -Encoding UTF8

    $regex = '([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))'
    $match = [regex]::Match($logContent, $regex)

    if (-not $match.Success) {
        Write-Host "`n[结果] 无法从日志中解析游戏目录（gameDir）。"
        Write-Host "请将本脚本输出与日志文件路径反馈给开发者。"
        return
    }

    $gameDir = $match.Groups[1].Value
    Write-Host "`n[3] 解析到的游戏目录 gameDir:"
    Write-Host "    $gameDir"

    # 3. 计算 webCaches 路径（对应 getLatestCacheVersion 的前半部分）
    $webCachesPath = Join-Path $gameDir 'webCaches'
    $webCachesExists = Test-Path -LiteralPath $webCachesPath

    Write-Host "`n[4] webCaches 目录信息:"
    Write-Host "    路径   : $webCachesPath"
    Write-Host "    是否存在: $webCachesExists"

    if (-not $webCachesExists) {
        Write-Host "`n[结果] 未找到 webCaches 目录。"
        Write-Host "可能原因："
        Write-Host "  - 游戏刚重装或移动过目录，还没完整启动一次；"
        Write-Host "  - 使用了清理工具 / 手动删除了 webCaches；"
        Write-Host "  - 解析到的 gameDir 不是当前正在使用的游戏安装目录。"
        return
    }

    # 4. 找到最新的版本子目录（对应 getLatestCacheVersion 的后半部分）
    $subdirs = Get-ChildItem -LiteralPath $webCachesPath -Directory -ErrorAction SilentlyContinue
    if (-not $subdirs -or $subdirs.Count -eq 0) {
        Write-Host "`n[结果] webCaches 目录中没有任何子文件夹（版本目录）。"
        return
    }

    $latest = $subdirs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $cacheVersion = $latest.Name

    Write-Host "`n[5] 最新 webCaches 版本目录:"
    Write-Host "    名称     : $cacheVersion"
    Write-Host "    完整路径 : $($latest.FullName)"
    Write-Host "    修改时间 : $($latest.LastWriteTime)"

    # 5. 计算 data_2 缓存文件路径（对应你的 Node 逻辑）
    $cacheRoot    = Join-Path $webCachesPath $cacheVersion
    $cacheFile    = Join-Path $cacheRoot 'Cache\Cache_Data\data_2'
    $cacheExists  = Test-Path -LiteralPath $cacheFile

    Write-Host "`n[6] 祈愿缓存文件 data_2 信息:"
    Write-Host "    路径   : $cacheFile"
    Write-Host "    是否存在: $cacheExists"

    Write-Host "`n=== 诊断完成，如需反馈请截图以上所有内容发送给开发者 ==="

} catch {
    Write-Host "`n[错误] 脚本执行过程中出现异常："
    Write-Host $_.Exception.Message
}
