@echo off
chcp 65001 >nul
setlocal

REM 启动本地 Redis（日迹项目用：Token 黑名单 / 缓存 / 限流）
set REDIS_HOME=C:\Users\15067\.workbuddy\tools\redis

if not exist "%REDIS_HOME%\redis-server.exe" (
    echo [ERROR] Redis not found at %REDIS_HOME%
    echo         Edit REDIS_HOME in this script.
    pause
    exit /b 1
)

cd /d "%REDIS_HOME%"
echo [INFO] Starting Redis on 127.0.0.1:6379 ...
start "" redis-server.exe redis.windows.conf
timeout /t 2 >nul
redis-cli.exe ping
echo [OK] If you see PONG above, Redis is ready.
