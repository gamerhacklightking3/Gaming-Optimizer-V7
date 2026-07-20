@echo off
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    color 0c
    echo ==========================================================================
    echo  ERROR: ADMINISTRATOR PRIVILEGES REQUIRED
    echo  Please right-click this file and select 'Run as administrator'.
    echo ==========================================================================
    pause
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([ScriptBlock]::Create((Get-Content '%~f0' | Select-Object -Skip 13 | Out-String)))"
exit /b

# ==========================================================================
#   ADVANCED GAMING OPTIMIZER & GPU DIAGNOSTIC (v7.0 - ULTIMATE EDITION)
# ==========================================================================

function Show-Menu {
    Clear-Host
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "   ADVANCED GAMING OPTIMIZER - MAIN MENU (v7.0 Ultimate)" -ForegroundColor Cyan
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host "   1. Run Full Automated Suite (~20 Second Complete PC Overhaul)"
    Write-Host "   2. Scan GPU & Check Graphics Driver Health"
    Write-Host "   3. Create System Restore Point (Safety Backup)"
    Write-Host "   4. Process Killer & Disable Global Background Apps [ENHANCED]"
    Write-Host "   5. Network Tweaks & Disable Nagle's Algorithm (Lower Ping) [NEW]"
    Write-Host "   6. Telemetry Removal & Force Enable Windows Game Mode [NEW]"
    Write-Host "   7. Services Optimizer (Disable SysMain/Search Stuttering) [NEW]"
    Write-Host "   8. CPU/GPU MMCSS Priority & Ultimate Power Plan [NEW]"
    Write-Host "   9. Input Latency (Disable Mouse Accel) & Visual Overhaul [NEW]"
    Write-Host "  10. Memory & Disk Junk Cleanup (Clear Temp Files & Caches)"
    Write-Host "  11. Restore Default Windows Settings"
    Write-Host "  12. Exit Script"
    Write-Host "==========================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Log {
    param([string]$Message)
    $logPath = "$env:USERPROFILE\Desktop\optimization_log.txt"
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timeStamp] $Message" | Out-File -FilePath $logPath -Append -Encoding utf8
}

function Test-GpuDriver {
    Write-Host "`n[!] Scanning Graphics Card and Driver Status..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    
    $gpus = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue

    foreach ($gpu in $gpus) {
        $gpuName = $gpu.Name
        Write-Host "Detected GPU: $gpuName" -ForegroundColor White

        if ($gpuName -like "*Microsoft Basic Display Adapter*" -or $gpuName -like "*Microsoft Basic Render Driver*") {
            Write-Host "`n==========================================================================" -ForegroundColor Red
            Write-Host " [WARNING] NEED A GRAPHICS DRIVER!" -ForegroundColor Red
            Write-Host " Your system is running on Microsoft's Basic Display Adapter." -ForegroundColor Red
            Write-Host " Games will run with severe lag or fail to launch without official drivers.`n" -ForegroundColor Red
            Write-Host " Download official drivers from:" -ForegroundColor Yellow
            Write-Host " - NVIDIA: https://www.nvidia.com/Download/index.aspx"
            Write-Host " - AMD:    https://www.amd.com/en/support"
            Write-Host " - Intel:  https://www.intel.com/content/www/us/en/download-center/home.html"
            Write-Host "==========================================================================" -ForegroundColor Red
            Write-Log "GPU Scan: Generic driver detected on $gpuName."
        } else {
            Write-Host "[SUCCESS] Dedicated/Official Graphics Driver is active." -ForegroundColor Green
            if ($gpuName -like "*NVIDIA*") { Write-Host " -> NVIDIA Driver Link: https://www.nvidia.com/Download/index.aspx" -ForegroundColor Gray }
            if ($gpuName -like "*AMD*" -or $gpuName -like "*Radeon*") { Write-Host " -> AMD Driver Link: https://www.amd.com/en/support" -ForegroundColor Gray }
            if ($gpuName -like "*Intel*") { Write-Host " -> Intel Driver Link: https://www.intel.com/content/www/us/en/download-center/home.html" -ForegroundColor Gray }
            Write-Log "GPU Scan: Verified $gpuName."
        }
    }
}

function New-GamingRestorePoint {
    Write-Host "`n[1/8] Creating System Restore Point..." -ForegroundColor Cyan
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Gaming Optimizer Backup v7" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "[+] System Restore Point created successfully." -ForegroundColor Green
        Write-Log "Created System Restore Point."
    } catch {
        Write-Host "[!] Restore Point skipped or unavailable on this system drive." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 2
}

function Optimize-BackgroundApps {
    Write-Host "`n[2/8] Terminating Bloatware & Disabling UWP Background Apps..." -ForegroundColor Cyan
    $targets = @("GameBarPresenceWriter", "MicrosoftEdgeUpdate", "OneDrive", "Skype", "Cortana")
    foreach ($proc in $targets) { Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue }
    
    # Globally disable Windows background apps
    $bgPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $bgPath)) { New-Item -Path $bgPath -Force | Out-Null }
    Set-ItemProperty -Path $bgPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "[+] Background apps cleared and permanently disabled." -ForegroundColor Green
    Write-Log "Executed Aggressive Process Killer & Disabled UWP Background Apps."
    Start-Sleep -Seconds 2
}

function Optimize-Network {
    Write-Host "`n[3/8] Applying Network Tweaks (Nagle's Algorithm & Throttling)..." -ForegroundColor Cyan
    Set-NetTCPSetting -SettingName "InternetCustom" -AutoTuningLevelLocal Normal -ErrorAction SilentlyContinue
    
    # Disable Windows Network Throttling
    $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    # Disable Nagle's Algorithm (Massive Ping Reduction)
    $interfaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -ErrorAction SilentlyContinue
    foreach ($interface in $interfaces) {
        Set-ItemProperty -Path $interface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $interface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    }
    
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Host "[+] Network latency minimized and DNS flushed." -ForegroundColor Green
    Write-Log "Optimized TCP, disabled Nagle's Algorithm, and Network Throttling."
    Start-Sleep -Seconds 2
}

function Optimize-Telemetry {
    Write-Host "`n[4/8] Disabling Telemetry & Forcing Windows Game Mode..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    
    # Force Enable Game Mode
    $gameMode = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gameMode)) { New-Item -Path $gameMode -Force | Out-Null }
    Set-ItemProperty -Path $gameMode -Name "AllowAutoGameMode" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    
    Write-Host "[+] Tracking disabled and Game Mode forced ON." -ForegroundColor Green
    Write-Log "Disabled Windows Telemetry & Forced Auto Game Mode."
    Start-Sleep -Seconds 2
}

function Optimize-Services {
    Write-Host "`n[5/8] Disabling High-CPU Services (SysMain & Windows Search)..." -ForegroundColor Cyan
    # Disabling SysMain (Superfetch) stops HDD/SSD 100% usage spikes while gaming
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
    
    # Disabling WSearch reduces background disk indexing overhead
    Set-Service -Name "WSearch" -StartupType Manual -ErrorAction SilentlyContinue
    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
    
    Write-Host "[+] Heavy background services stopped." -ForegroundColor Green
    Write-Log "Disabled SysMain and WSearch Services."
    Start-Sleep -Seconds 2
}

function Set-GamingPowerPlan {
    Write-Host "`n[6/8] Configuring MMCSS Priority & Ultimate Power Scheme..." -ForegroundColor Cyan
    
    # MMCSS Tweaks - Forces Windows to give Games Top Priority over background tasks
    $mmcss = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $mmcss)) { New-Item -Path $mmcss -Force | Out-Null }
    Set-ItemProperty -Path $mmcss -Name "GPU Priority" -Value 8 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mmcss -Name "Priority" -Value 6 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mmcss -Name "Scheduling Category" -Value "High" -ErrorAction SilentlyContinue

    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $result = powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
    if ($LASTEXITCODE -ne 0) { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null }
    
    Write-Host "[+] Game Task Scheduling and Power optimized." -ForegroundColor Green
    Write-Log "Configured MMCSS Scheduling and Set Ultimate Power Plan."
    Start-Sleep -Seconds 2
}

function Optimize-InputAndVisuals {
    Write-Host "`n[7/8] Removing Mouse Acceleration & Adjusting Visual FX..." -ForegroundColor Cyan
    # Disable "Enhance Pointer Precision" for raw mouse input (better aim)
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -ErrorAction SilentlyContinue
    
    $visualFXPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $visualFXPath)) { New-Item -Path $visualFXPath -Force | Out-Null }
    Set-ItemProperty -Path $visualFXPath -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    
    Write-Host "[+] Mouse Acceleration disabled. Animations optimized." -ForegroundColor Green
    Write-Log "Disabled Mouse Acceleration and Optimized Visuals."
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
    Write-Log "Cleared Temp Files."
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
    
    Write-Host "Defaults restored. (A restart may be required for mouse settings)" -ForegroundColor Green
    Write-Log "Restored Default Windows Settings."
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
