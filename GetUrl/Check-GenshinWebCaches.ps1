try {
    [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(936)
} catch {

}

Write-Host "=== 开始检测原神路径与缓存文件 ==="

# --------------------------
# 1. 获取日志路径
# --------------------------
function Get-LogPath {
    $base = Join-Path $env:USERPROFILE "AppData\LocalLow\miHoYo"
    $globalPath = Join-Path $base "Genshin Impact\output_log.txt"
    $chinaPath  = Join-Path $base "原神\output_log.txt"

    Write-Host "[检查路径] 基础路径: $base"

    if (Test-Path $globalPath) {
        Write-Host "[找到日志] 国际服日志: $globalPath"
        return $globalPath
    }
    elseif (Test-Path $chinaPath) {
        Write-Host "[找到日志] 国服日志: $chinaPath"
        return $chinaPath
    }
    else {
        Write-Host "[错误] 未找到 output_log.txt，请确认原神至少启动过一次。" -ForegroundColor Yellow
        return $null
    }
}

# --------------------------
# 2. 从日志解析游戏目录
# --------------------------
function Extract-GameDir($logContent) {
    $regex = "([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))"
    $match = [regex]::Match($logContent, $regex)

    if ($match.Success) {
        $path = $match.Groups[1].Value
        Write-Host "[解析路径] 游戏目录为: $path"
        return $path
    }

    Write-Host "[错误] 无法从日志中解析游戏路径。" -ForegroundColor Yellow
    return $null
}

# --------------------------
# 3. 获取最新版本 webCaches
# --------------------------
function Get-LatestCacheVersion($gameDir) {
    $webCaches = Join-Path $gameDir "webCaches"
    Write-Host "[检查] webCaches 路径: $webCaches"

    if (!(Test-Path $webCaches)) {
        throw "未找到 webCaches 目录，请确认游戏是否启动过并打开过祈愿界面。"
    }

    $dirs = Get-ChildItem $webCaches -Directory | Sort-Object LastWriteTime -Descending

    if ($dirs.Count -eq 0) {
        throw "webCaches 中未找到任何版本文件夹。"
    }

    Write-Host "[版本] 最新缓存版本为: $($dirs[0].Name)"
    return $dirs[0].Name
}

# --------------------------
# 4. 从缓存文件中提取祈愿链接
# --------------------------
function Extract-GachaLogUrl($cacheFile) {
    Write-Host "[读取缓存] $cacheFile"

    if (!(Test-Path $cacheFile)) {
        throw "缓存文件不存在：$cacheFile"
    }

    # 保持原逻辑：按字节读，然后用 ISO-8859-1 解码
    $bytes = Get-Content $cacheFile -Encoding Byte -Raw
    $content = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($bytes)

    $regex = "https:\/\/.+?&auth_appid=webview_gacha&.+?authkey=.+?&game_biz=hk4e_(cn|global|os)"
    $match = [regex]::Matches($content, $regex) | Select-Object -Last 1

    if ($match) {
        Write-Host "[找到链接] $($match.Value)"
        return $match.Value
    }

    return $null
}

# --------------------------
# 主流程（加异常捕获 & 防闪退）
# --------------------------
try {
    $logPath = Get-LogPath
    if (-not $logPath) {
        Write-Host "`n[终止] 因为未找到日志文件，脚本结束。" -ForegroundColor Red
        return
    }

    # 尽量用系统默认编码读取（通常是 GBK/ANSI）
    $logContent = Get-Content -LiteralPath $logPath -Raw -Encoding Default
    $gameDir = Extract-GameDir $logContent
    if (-not $gameDir) {
        Write-Host "`n[终止] 无法解析游戏目录，脚本结束。" -ForegroundColor Red
        return
    }

    $cacheVer = Get-LatestCacheVersion $gameDir

    $cacheFile = Join-Path $gameDir "webCaches\$cacheVer\Cache\Cache_Data\data_2"
    Write-Host "[最终缓存文件路径] $cacheFile"

    if (!(Test-Path $cacheFile)) {
        Write-Host "`n[错误] 未找到缓存文件: $cacheFile" -ForegroundColor Red
        return
    }

    $url = Extract-GachaLogUrl $cacheFile

    if ($url) {
        Set-Clipboard -Value $url
        Write-Host "`n==== 成功 ====" -ForegroundColor Green
        Write-Host "祈愿链接已复制到剪贴板：" 
        Write-Host $url -ForegroundColor Cyan
    }
    else {
        Write-Host "`n[错误] 未在缓存中找到祈愿记录链接，请确认已打开祈愿记录页面。" -ForegroundColor Red
    }
}
catch {
    Write-Host "`n[异常] $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host "`n脚本执行完毕，按任意键退出..."
    try {
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch {
        # 在某些宿主环境（比如 VSCode 终端）可能不支持 ReadKey，忽略即可
    }
}
