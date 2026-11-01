@echo off
chcp 65001 >nul
echo Crown Gambit Demo zh-CN patch installer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_zh_demo.ps1"
pause
