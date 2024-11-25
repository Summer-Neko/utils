$LogFilePath = ""; $UrlRegex = 'https:\/\/aki-gm-resources\.aki-game\.com\/aki\/gacha\/index\.html#\/record\?[^ ]+'; $RegistryPaths = @('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\KRInstall Wuthering Waves', 'HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\KRInstall Wuthering Waves', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\KRInstall Wuthering Waves', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\KRInstall Wuthering Waves'); function Get-RegistryPath { param ([string]$KeyPath, [string]$ValueName) try { $value = Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction Stop; return $value.$ValueName } catch { Write-Host "$([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x6ce8)$([char]0x518c)$([char]0x8868)$([char]0x9879): $KeyPath" -ForegroundColor Yellow; return $null } }; function Extract-GachaUrl { param ([string]$LogFile); if (-Not (Test-Path $LogFile)) { throw "$([char]0x65e5)$([char]0x5fd7)$([char]0x6587)$([char]0x4ef6)$([char]0x4e0d)$([char]0x5b58)$([char]0x5728): $LogFile" }; $content = Get-Content -Path $LogFile -ErrorAction Stop; $matches = [regex]::Matches($content, $UrlRegex); if ($matches.Count -gt 0) { return $matches[$matches.Count - 1].Value } else { throw "$([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)" } }; function Get-LogFilePath { foreach ($regPath in $RegistryPaths) { $installPath = Get-RegistryPath -KeyPath $regPath -ValueName "InstallPath"; if ($installPath) { $logPath = Join-Path -Path $installPath -ChildPath 'Wuthering Waves Game\Client\Saved\Logs\Client.log'; if (Test-Path $logPath) { return $logPath } else { Write-Host "$([char]0x65e5)$([char]0x5fd7)$([char]0x6587)$([char]0x4ef6)$([char]0x4e0d)$([char]0x5b58)$([char]0x5728)$([char]0x4e8e): $logPath" -ForegroundColor Yellow } } }; Write-Host "$([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x6709)$([char]0x6548)$([char]0x7684)$([char]0x5b89)$([char]0x88c5)$([char]0x8def)$([char]0x5f84)$([char]0x0ff0)$([char]0x975e)$([char]0x56fd)$([char]0x670d)$([char]0x5b98)$([char]0x65b9)$([char]0x542f)$([char]0x52a8)$([char]0x5668)$([char]0x8bf7)$([char]0x624b)$([char]0x52a8)$([char]0x8f93)$([char]0x5165)$([char]0x6e38)$([char]0x620f)$([char]0x4e3b)$([char]0x7a0b)$([char]0x5e8f)$([char]0x28)$([char]0x57df)$([char]0x62c9)$([char]0x67cf)$([char]0x6bd4)$([char]0x5021)$([char]0x7684)$([char]0x6838)$([char]0x5fc3)$([char]0x6587)$([char]0x4ef6)$([char]0x76ee)$([char]0x5f55)" -ForegroundColor Cyan; Write-Host "$([char]0x793a)$([char]0x8303)$([char]0x8def)$([char]0x5f84): C:\Games\WutheringWaves\Wuthering Waves Game" -ForegroundColor Green; $manualBasePath = Read-Host "$([char]0x8bf7)$([char]0x8f93)$([char]0x5165)$([char]0x6e38)$([char]0x620f)$([char]0x4e3b)$([char]0x7a0b)$([char]0x5e8f)$([char]0x76ee)$([char]0x5f55)"; $manualLogPath = Join-Path -Path $manualBasePath -ChildPath 'Client\Saved\Logs\Client.log'; if (Test-Path $manualLogPath) { return $manualLogPath } else { throw "$([char]0x8f93)$([char]0x5165)$([char]0x7684)$([char]0x8def)$([char]0x5f84)$([char]0x65e0)$([char]0x6548)$([char]0x6216)$([char]0x65e5)$([char]0x5fd7)$([char]0x6587)$([char]0x4ef6)$([char]0x4e0d)$([char]0x5b58)$([char]0x5728): $manualLogPath" } }; try { $LogFilePath = Get-LogFilePath; $GachaUrl = Extract-GachaUrl -LogFile $LogFilePath; Write-Host "$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)$([char]0x63d0)$([char]0x53d6)$([char]0x6210)$([char]0x529f): $GachaUrl" -ForegroundColor Green; Set-Clipboard -Value $GachaUrl; Write-Host "$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)$([char]0x5df2)$([char]0x590d)$([char]0x5236)$([char]0x5230)$([char]0x526a)$([char]0x8d34)$([char]0x677f)$([char]0x21)" -ForegroundColor Cyan } catch { Write-Host "$([char]0x64cd)$([char]0x4f5c)$([char]0x5931)$([char]0x8d25): $_" -ForegroundColor Red }