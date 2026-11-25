@echo off
chcp 65001 >nul
setlocal

REM 启动后端（Spring Boot 3.2 + JDK 17）
REM 前置：MySQL 已运行、diary_platform 库已建、Redis 已启动

set JAVA_HOME=C:\Users\15067\.workbuddy\binaries\jdk17
set MAVEN_HOME=C:\Users\15067\Downloads\apache-maven-3.9.16
set APP_PORT=8080

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] JDK 17 not found at %JAVA_HOME%
    echo         Edit JAVA_HOME in this script.
    pause
    exit /b 1
)

set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "%~dp0..\backend"

echo [INFO] Java:
"%JAVA_HOME%\bin\java" -version
echo.
echo [INFO] Starting Spring Boot on port %APP_PORT% ...
echo        Swagger: http://localhost:%APP_PORT%/swagger-ui.html
echo        API doc: http://localhost:%APP_PORT%/v3/api-docs
echo.

REM 显式指定端口，避免被外部 SERVER_PORT 环境变量覆盖
call "%MAVEN_HOME%\bin\mvn.cmd" spring-boot:run -Dspring-boot.run.arguments=--server.port=%APP_PORT%

pause
