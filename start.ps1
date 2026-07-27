param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "start"
)

$scriptPath = $PSScriptRoot
$pidFile = "$scriptPath\server.pid"
$port = 8080

function Get-LanIP {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual, Dhcp | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
    $addresses = @()
    foreach ($adapter in $adapters) {
        $addresses += $adapter.IPAddress
    }
    if ($addresses.Count -eq 0) {
        $addresses = @("localhost")
    }
    return $addresses
}

function Show-Menu {
    Clear-Host
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "  spot-studio" -ForegroundColor Green
    Write-Host "  GPX 轨迹渲染 + 机位踩点" -ForegroundColor Gray
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [S] Start Server" -ForegroundColor Gray
    Write-Host "  [R] Restart Server" -ForegroundColor Gray
    Write-Host "  [T] Stop Server" -ForegroundColor Gray
    Write-Host "  [C] Check Status" -ForegroundColor Gray
    Write-Host "  [Q] Quit" -ForegroundColor Gray
    Write-Host ""
    $choice = Read-Host "Enter option (S/R/T/C/Q)"
    return $choice.ToUpper()
}

function Test-Python {
    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) {
        Write-Host "[ERROR] Python not found" -ForegroundColor Red
        return $false
    }
    return $true
}

function Test-Port {
    param([int]$Port)
    $conn = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue
    return $conn.TcpTestSucceeded
}

function Stop-ExistingServer {
    if (Test-Path $pidFile) {
        $oldPid = (Get-Content $pidFile -Raw).Trim()
        if ([int]::TryParse($oldPid, [ref]$null) -and (Get-Process -Id $oldPid -ErrorAction SilentlyContinue)) {
            Write-Host "Stopping existing server (PID: $oldPid)..." -ForegroundColor Yellow
            Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
        Remove-Item $pidFile -ErrorAction SilentlyContinue
    }
}

function Start-Server {
    if (-not (Test-Python)) {
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    Stop-ExistingServer

    # Check port availability
    if (Test-Port -Port $port) {
        Write-Host "[WARN] Port $port is already in use, trying $port+1..." -ForegroundColor Yellow
        $script:port = $port + 1
        if (Test-Port -Port $script:port) {
            Write-Host "[ERROR] Port $script:port also in use" -ForegroundColor Red
            return
        }
    }

    $lanIPs = Get-LanIP
    Write-Host ""
    Write-Host "Starting HTTP server on port $($script:port)..." -ForegroundColor Yellow

    $process = Start-Process -FilePath "python" -ArgumentList "-m http.server $($script:port) --directory $scriptPath" -WorkingDirectory $scriptPath -NoNewWindow -PassThru
    $process.Id | Out-File -FilePath $pidFile -Encoding UTF8
    Start-Sleep -Seconds 2

    if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
        Write-Host "Server started!" -ForegroundColor Green
        Write-Host "PID: $($process.Id)" -ForegroundColor White
        Write-Host "Local:    http://localhost:$($script:port)/spot-studio.html" -ForegroundColor White
        foreach ($ip in $lanIPs) {
            Write-Host "Network:  http://$ip`:$($script:port)/spot-studio.html" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "Press any key to open menu..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Run-Menu
    } else {
        Write-Host "Failed to start" -ForegroundColor Red
        Remove-Item $pidFile -ErrorAction SilentlyContinue
    }
}

function Restart-Server {
    Write-Host "Restarting server..." -ForegroundColor Yellow
    Stop-ExistingServer
    Write-Host "Old server stopped" -ForegroundColor Green
    Start-Server
}

function Stop-Server {
    Write-Host "Stopping server..." -ForegroundColor Yellow
    if (-not (Test-Path $pidFile)) {
        Write-Host "PID file not found" -ForegroundColor Yellow
        return
    }
    $serverPid = (Get-Content $pidFile -Raw).Trim()
    if ([int]::TryParse($serverPid, [ref]$null) -and (Get-Process -Id $serverPid -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $serverPid -Force -ErrorAction SilentlyContinue
        Write-Host "Stopped (PID: $serverPid)" -ForegroundColor Green
    } else {
        Write-Host "Process not found" -ForegroundColor Yellow
    }
    Remove-Item $pidFile -ErrorAction SilentlyContinue
}

function Get-Status {
    $lanIPs = Get-LanIP
    if (Test-Path $pidFile) {
        $serverPid = (Get-Content $pidFile -Raw).Trim()
        if ([int]::TryParse($serverPid, [ref]$null) -and (Get-Process -Id $serverPid -ErrorAction SilentlyContinue)) {
            Write-Host "Status:   Running (PID: $serverPid)" -ForegroundColor Green
            Write-Host "Local:    http://localhost:$port/spot-studio.html" -ForegroundColor White
            foreach ($ip in $lanIPs) {
                Write-Host "Network:  http://$ip`:$port/spot-studio.html" -ForegroundColor White
            }
        } else {
            Write-Host "Status:   Stopped (stale PID file)" -ForegroundColor Yellow
            Remove-Item $pidFile -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "Status:   Stopped" -ForegroundColor Gray
    }
}

function Run-Menu {
    do {
        $choice = Show-Menu
        switch ($choice) {
            "S" { Start-Server }
            "R" { Restart-Server }
            "T" { Stop-Server }
            "C" { Get-Status }
            "Q" { Write-Host "Exiting..." -ForegroundColor Gray; exit }
            default { Write-Host "Invalid option" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($choice -ne "Q")
}

switch ($Action.ToLower()) {
    "start"   { Start-Server }
    "restart" { Restart-Server }
    "stop"    { Stop-Server }
    "status"  { Get-Status }
    "menu"    { Run-Menu }
    default {
        Write-Host "Usage:" -ForegroundColor Cyan
        Write-Host "  .\start.ps1                    # Start (default)" -ForegroundColor White
        Write-Host "  .\start.ps1 -Action restart    # Restart" -ForegroundColor White
        Write-Host "  .\start.ps1 -Action stop       # Stop" -ForegroundColor White
        Write-Host "  .\start.ps1 -Action status     # Status" -ForegroundColor White
        Write-Host "  .\start.ps1 -Action menu       # Show menu" -ForegroundColor White
    }
}
