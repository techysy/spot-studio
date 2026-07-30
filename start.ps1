param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "start"
)

$scriptPath = $PSScriptRoot
$pidFile = Join-Path $scriptPath "server.pid"
$port = 8080

function Get-LanIP {
    try {
        $adapters = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual, Dhcp -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
        $list = @()
        foreach ($a in $adapters) { $list += $a.IPAddress }
        if ($list.Count -eq 0) { return @("localhost") }
        return $list
    } catch {
        return @("localhost")
    }
}

function Stop-Server {
    if (Test-Path $pidFile) {
        $raw = Get-Content $pidFile -Raw -ErrorAction SilentlyContinue
        if ($raw) {
            $oldPid = $raw.Trim()
            if ($oldPid) {
                try { Stop-Process -Id ([int]$oldPid) -Force -ErrorAction SilentlyContinue } catch {}
            }
        }
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }
}

function Start-Server {
    Stop-Server

    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) {
        Write-Host "  [ERROR] Python not found" -ForegroundColor Red
        return $false
    }

    $tryPort = $port
    while ($true) {
        $inUse = Test-NetConnection -ComputerName localhost -Port $tryPort -WarningAction SilentlyContinue -InformationLevel Quiet
        if (-not $inUse) { break }
        $tryPort++
        if ($tryPort -gt 9999) {
            Write-Host "  [ERROR] No port available" -ForegroundColor Red
            return $false
        }
    }

    $logOut = Join-Path $scriptPath "server_stdout.log"
    $logErr = Join-Path $scriptPath "server_stderr.log"
    $proc = $null
    try {
        $proc = Start-Process python -ArgumentList "`"$scriptPath\server.py`" $tryPort" -WorkingDirectory $scriptPath -WindowStyle Hidden -PassThru -RedirectStandardOutput $logOut -RedirectStandardError $logErr
    } catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    if (-not $proc) {
        Write-Host "  [ERROR] Failed to launch python" -ForegroundColor Red
        return $false
    }

    $proc.Id | Out-File -FilePath $pidFile -Encoding ASCII
    Start-Sleep -Seconds 2

    $alive = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
    if (-not $alive) {
        Write-Host "  [ERROR] Server exited immediately" -ForegroundColor Red
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
        return $false
    }

    $lanIPs = Get-LanIP
    Write-Host ""
    Write-Host "  Server running (PID: $($proc.Id))" -ForegroundColor Green
    Write-Host "  Local:    http://localhost:${tryPort}/spot-studio.html" -ForegroundColor White
    foreach ($ip in $lanIPs) {
        Write-Host "  Network:  http://${ip}:${tryPort}/spot-studio.html" -ForegroundColor White
    }
    return $true
}

function Show-Status {
    if (-not (Test-Path $pidFile)) {
        Write-Host "  Server: stopped" -ForegroundColor Gray
        return
    }
    $rawPid = Get-Content $pidFile -Raw -ErrorAction SilentlyContinue
    if (-not $rawPid) {
        Write-Host "  Server: stopped" -ForegroundColor Yellow
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
        return
    }
    $rawPid = $rawPid.Trim()
    if (-not $rawPid) {
        Write-Host "  Server: stopped" -ForegroundColor Yellow
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
        return
    }
    $proc = $null
    try { $proc = Get-Process -Id ([int]$rawPid) -ErrorAction SilentlyContinue } catch {}
    if ($proc) {
        $lanIPs = Get-LanIP
        Write-Host ""
        Write-Host "  Server: running (PID: $rawPid)" -ForegroundColor Green
        Write-Host "  Local:    http://localhost:${port}/spot-studio.html" -ForegroundColor White
        foreach ($ip in $lanIPs) {
            Write-Host "  Network:  http://${ip}:${port}/spot-studio.html" -ForegroundColor White
        }
    } else {
        Write-Host "  Server: stopped (stale)" -ForegroundColor Yellow
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }
}

Clear-Host
Write-Host ""
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host "    spot-studio" -ForegroundColor Green
Write-Host "    GPX track + waypoint tool" -ForegroundColor DarkGray
Write-Host "  ========================================" -ForegroundColor DarkCyan
Write-Host ""

switch ($Action.ToLower()) {
    "start" {
        Start-Server
        Write-Host ""
        pause
    }
    "restart" {
        Stop-Server
        Write-Host "  Old server stopped" -ForegroundColor Green
        Start-Server
        Write-Host ""
        pause
    }
    "stop" {
        Stop-Server
        Write-Host "  Server stopped" -ForegroundColor Green
    }
    "status" {
        Show-Status
    }
    default {
        do {
            Write-Host "  [S] Start    [R] Restart    [T] Stop    [C] Status    [Q] Quit" -ForegroundColor White
            Write-Host ""
            $rawInput = Read-Host "  Option"
            if (-not $rawInput) { continue }
            $choice = $rawInput.ToUpper().Trim()
            switch ($choice) {
                "S" { Start-Server; Write-Host "" }
                "R" { Stop-Server; Write-Host "  Old server stopped" -ForegroundColor Green; Start-Server; Write-Host "" }
                "T" { Stop-Server; Write-Host "  Server stopped" -ForegroundColor Green; Write-Host "" }
                "C" { Show-Status; Write-Host "" }
                "Q" { exit }
            }
        } while ($true)
    }
}
