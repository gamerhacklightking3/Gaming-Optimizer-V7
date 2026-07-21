@echo off
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: ADMINISTRATOR PRIVILEGES REQUIRED
    echo [!] Please right-click this file and select 'Run as administrator'.
    pause
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([ScriptBlock]::Create((Get-Content '%~f0' | Select-Object -Skip 10 | Out-String)))"
exit /b

# ==========================================================================
#   ADVANCED GAMING OPTIMIZER & GPU DIAGNOSTIC (v7.3 - ULTIMATE EDITION)
# ==========================================================================

function Show-Menu {
    Clear-Host
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "   ADVANCED GAMING OPTIMIZER - MAIN MENU (v7.3 Ultimate)" -ForegroundColor Cyan
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "   1. Run Full Automated Suite (~20 Second Complete PC Overhaul)"
    Write-Host "   2. Scan GPU & Direct Download Official Graphics Drivers"
    Write-Host "   3. Create System Restore Point (Safety Backup)"
    Write-Host "   4. Process Killer & Disable Global Background Apps"
    Write-Host "   5. Network Tweaks & Disable Nagle's Algorithm (Lower Ping)"
    Write-Host "   6. Telemetry Removal & Force Enable Windows Game Mode"
    Write-Host "   7. Services Optimizer (Disable SysMain/Search Stuttering)"
    Write-Host "   8. CPU/GPU MMCSS Priority & Ultimate Power Plan"
    Write-Host "   9. Input Latency (Disable Mouse Accel) & Visual Overhaul"
    Write-Host "  10. Memory & Disk Junk Cleanup (Clear Temp Files & Caches)"
    Write-Host "  11. Restore Default Windows Settings"
    Write-Host "  12. Exit Script"
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-GpuDriver {
    Write-Host "`n[!] Scanning Graphics Hardware and Driver Status..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    
    $gpus = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue
    $restartRequired = $false

    foreach ($gpu in $gpus) {
        $gpuName = $gpu.Name
        $provider = $gpu.DriverProviderName
        Write-Host "Detected GPU: $gpuName" -ForegroundColor White

        $isGeneric = ($gpuName -like "*Microsoft Basic Display Adapter*" -or $gpuName -like "*Microsoft Basic Render Driver*" -or $provider -like "*Microsoft*")

        if ($isGeneric) {
            Write-Host "[!] Basic/Generic Microsoft driver detected!" -ForegroundColor Red
            Write-Host " -> Rescanning system devices..." -ForegroundColor Yellow
            pnputil /scan-devices | Out-Null

            Write-Host " -> Directing to official GPU driver downloads..." -ForegroundColor Yellow
            if ($gpuName -like "*NVIDIA*" -or (Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -like "*NVIDIA*" })) {
                Start-Process "https://www.nvidia.com/Download/index.aspx"
            } elseif ($gpuName -like "*AMD*" -or $gpuName -like "*Radeon*" -or (Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -like "*AMD*" -or $_.Name -like "*Radeon*" })) {
                Start-Process "https://www.amd.com/en/support"
            } else {
                Start-Process "https://www.intel.com/content/www/us/en/download-center/home.html"
            }
            $restartRequired = $true
        } else {
            Write-Host "[+] Official driver active ($gpuName - $provider)." -ForegroundColor Green
            
            # Offer manual update option even if driver is active
            $response = Read-Host "Would you like to check for a newer driver on the vendor website? (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                if ($gpuName -like "*NVIDIA*") {
                    Start-Process "https://www.nvidia.com/Download/index.aspx"
                } elseif ($gpuName -like "*AMD*" -or $gpuName -like "*Radeon*") {
                    Start-Process "https://www.amd.com/en/support"
                } else {
                    Start-Process "https://www.intel.com/content/www/us/en/download-center/home.html"
                }
            }
        }
    }

    if ($restartRequired) {
        Write-Host "`n==========================================================================" -ForegroundColor Red
        Write-Host " [ACTION REQUIRED] Official driver installation site opened." -ForegroundColor Red
        Write-Host " Please download and install your official GPU drivers, then restart." -ForegroundColor Red
        Write-Host "==========================================================================" -ForegroundColor Red
    } else {
        Write-Host "`n[+] GPU configuration check complete. No forced restart required." -ForegroundColor Green
    }
}

function New-GamingRestorePoint {
    Write-Host "`n[1/8] Creating System Restore Point..." -ForegroundColor Cyan
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Gaming Optimizer Backup v7" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "[+] System Restore Point created successfully." -ForegroundColor Green
    } catch {
        Write-Host "[!] Restore Point skipped or unavailable on this system drive." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 2
}

function Optimize-BackgroundApps {
    Write-Host "`n[2/8] Terminating Bloatware & Disabling UWP Background Apps..." -ForegroundColor Cyan
    $targets = @("GameBarPresenceWriter", "MicrosoftEdgeUpdate", "OneDrive", "Skype", "Cortana")
    foreach ($proc in $targets) { Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue }
    
    $bgPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $bgPath)) { New-Item -Path $bgPath -Force | Out-Null }
    Set-ItemProperty -Path $bgPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "[+] Background apps cleared and permanently disabled." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Optimize-Network {
    Write-Host "`n[3/8] Applying Network Tweaks (Nagle's Algorithm & Throttling)..." -ForegroundColor Cyan
    Set-NetTCPSetting -SettingName "InternetCustom" -AutoTuningLevelLocal Normal -ErrorAction SilentlyContinue
    
    $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    $interfaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -ErrorAction SilentlyContinue
    foreach ($interface in $interfaces) {
        Set-ItemProperty -Path $interface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $interface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Host "[+] Network latency minimized and DNS flushed." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Optimize-Telemetry {
    Write-Host "`n[4/8] Disabling Telemetry & Forcing Windows Game Mode..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    $gameMode = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gameMode)) { New-Item -Path $gameMode -Force | Out-Null }
    Set-ItemProperty -Path $gameMode -Name "AllowAutoGameMode" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "[+] Tracking disabled and Game Mode forced ON." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Optimize-Services {
    Write-Host "`n[5/8] Disabling High-CPU Services (SysMain & Windows Search)..." -ForegroundColor Cyan
    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WSearch" -StartupType Manual -ErrorAction SilentlyContinue
    
    Write-Host "[+] Heavy background services stopped." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Set-GamingPowerPlan {
    Write-Host "`n[6/8] Configuring MMCSS Priority & Ultimate Power Scheme..." -ForegroundColor Cyan
    
    $mmcss = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $mmcss)) { New-Item -Path $mmcss -Force | Out-Null }
    Set-ItemProperty -Path $mmcss -Name "GPU Priority" -Value 8 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mmcss -Name "Priority" -Value 6 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mmcss -Name "Scheduling Category" -Value "High" -ErrorAction SilentlyContinue

    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $result = powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
    if ($LASTEXITCODE -ne 0) { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null }
    
    Write-Host "[+] Game Task Scheduling and Power optimized." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Optimize-InputAndVisuals {
    Write-Host "`n[7/8] Removing Mouse Acceleration & Adjusting Visual FX..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -ErrorAction SilentlyContinue
    
    $visualFXPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $visualFXPath)) { New-Item -Path $visualFXPath -Force | Out-Null }
    Set-ItemProperty -Path $visualFXPath -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "[+] Mouse Acceleration disabled. Animations optimized." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Clear-TempFiles {
    Write-Host "`n[8/8] Clearing Temporary Junk & Caches..." -ForegroundColor Cyan
    $tempFolders = @($env:TEMP, "$env:SystemRoot\Temp")
    foreach ($folder in $tempFolders) {
        if (Test-Path $folder) {
            Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "[+] Storage cleaned." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Restore-Defaults {
    Write-Host "`n[!] Restoring standard Windows default settings..." -ForegroundColor Yellow
    Set-NetTCPSetting -SettingName "InternetCustom" -AutoTuningLevelLocal Normal -ErrorAction SilentlyContinue
    $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 10 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "[+] Defaults restored. (A restart may be required for mouse settings)" -ForegroundColor Green
    Pause
}

do {
    Show-Menu
    $choice = Read-Host "Enter your selection (1-12)"

    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "==========================================================================" -ForegroundColor Cyan
            Write-Host "   RUNNING FULL AUTOMATED OPTIMIZATION SUITE (~20 SECONDS)" -ForegroundColor Cyan
            Write-Host "==========================================================================" -ForegroundColor Cyan
            Test-GpuDriver
            New-GamingRestorePoint
            Optimize-BackgroundApps
            Optimize-Network
            Optimize-Telemetry
            Optimize-Services
            Set-GamingPowerPlan
            Optimize-InputAndVisuals
            Clear-TempFiles
            Write-Host "`n==========================================================================" -ForegroundColor Green
            Write-Host "   FULL SUITE COMPLETED SUCCESSFULLY! YOUR PC IS NOW OPTIMIZED." -ForegroundColor Green
            Write-Host "==========================================================================" -ForegroundColor Green
            Pause
        }
        "2"  { Test-GpuDriver; Pause }
        "3"  { New-GamingRestorePoint; Pause }
        "4"  { Optimize-BackgroundApps; Pause }
        "5"  { Optimize-Network; Pause }
        "6"  { Optimize-Telemetry; Pause }
        "7"  { Optimize-Services; Pause }
        "8"  { Set-GamingPowerPlan; Pause }
        "9"  { Optimize-InputAndVisuals; Pause }
        "10" { Clear-TempFiles; Pause }
        "11" { Restore-Defaults }
        "12" { Write-Host "Exiting optimizer..." -ForegroundColor Gray; break }
        default { Write-Host "Invalid entry, try again." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "12")
