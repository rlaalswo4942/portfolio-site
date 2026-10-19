@echo off
if not exist "%~dp0setup.ps1" (
    echo setup.ps1 파일이 없습니다. 압축을 먼저 풀고, 압축 푼 폴더에서 실행.bat을 실행해주세요.
    pause
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if errorlevel 1 pause
