param(
    [string]$Action = "start"
)

$backendPath = "a:\Workspace\AiAgent\q-ai-agent"
$frontendPath = "a:\Workspace\AiAgent\qiu-agent-frontend"

function Start-Backend {
    Write-Host "`n[启动后端服务]" -ForegroundColor Cyan
    Write-Host "路径: $backendPath" -ForegroundColor Gray
    
    $backendProcess = Start-Process -FilePath "mvnw.cmd" -ArgumentList "spring-boot:run" -WorkingDirectory $backendPath -PassThru -NoNewWindow
    Write-Host "后端服务已启动，进程ID: $($backendProcess.Id)" -ForegroundColor Green
    
    return $backendProcess
}

function Start-Frontend {
    Write-Host "`n[启动前端服务]" -ForegroundColor Cyan
    Write-Host "路径: $frontendPath" -ForegroundColor Gray
    
    $frontendProcess = Start-Process -FilePath "npm.cmd" -ArgumentList "run dev" -WorkingDirectory $frontendPath -PassThru -NoNewWindow
    Write-Host "前端服务已启动，进程ID: $($frontendProcess.Id)" -ForegroundColor Green
    
    return $frontendProcess
}

function Wait-ForServices {
    Write-Host "`n[等待服务启动...]" -ForegroundColor Cyan
    
    $maxWaitSeconds = 30
    $waitInterval = 2
    $elapsedSeconds = 0
    
    while ($elapsedSeconds -lt $maxWaitSeconds) {
        try {
            $backendResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -Method Get -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($backendResponse.StatusCode -eq 200) {
                Write-Host "后端服务已就绪 (http://localhost:8080)" -ForegroundColor Green
                break
            }
        } catch {
            Write-Host "等待后端服务启动... $elapsedSeconds/$maxWaitSeconds 秒" -ForegroundColor Yellow
        }
        
        Start-Sleep -Seconds $waitInterval
        $elapsedSeconds += $waitInterval
    }
    
    Write-Host "`n[所有服务启动完成!]" -ForegroundColor Green
    Write-Host "后端服务: http://localhost:8080" -ForegroundColor White
    Write-Host "前端服务: http://localhost:5173" -ForegroundColor White
    Write-Host "`n按任意键停止服务..." -ForegroundColor Yellow
    
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Stop-AllServices {
    Write-Host "`n[停止所有服务]" -ForegroundColor Cyan
    
    $javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
    if ($javaProcesses) {
        foreach ($process in $javaProcesses) {
            if ($process.Path -match "mvnw" -or $process.CommandLine -match "spring-boot") {
                Write-Host "停止后端服务 (PID: $($process.Id))" -ForegroundColor Yellow
                $process | Stop-Process -Force
            }
        }
    }
    
    $nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
    if ($nodeProcesses) {
        foreach ($process in $nodeProcesses) {
            if ($process.CommandLine -match "vite") {
                Write-Host "停止前端服务 (PID: $($process.Id))" -ForegroundColor Yellow
                $process | Stop-Process -Force
            }
        }
    }
    
    Write-Host "`n[所有服务已停止]" -ForegroundColor Green
}

switch ($Action) {
    "start" {
        Write-Host "======================================" -ForegroundColor Cyan
        Write-Host "   Q-AI-Agent 一键启动脚本" -ForegroundColor Green
        Write-Host "======================================" -ForegroundColor Cyan
        
        Start-Backend
        Start-Frontend
        Wait-ForServices
        Stop-AllServices
        break
    }
    "stop" {
        Stop-AllServices
        break
    }
    default {
        Write-Host "用法:" -ForegroundColor Cyan
        Write-Host "  .\start-all.ps1 start   - 启动所有服务" -ForegroundColor White
        Write-Host "  .\start-all.ps1 stop    - 停止所有服务" -ForegroundColor White
        break
    }
}