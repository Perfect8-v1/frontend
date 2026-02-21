@echo off
REM Fallback: drop this file in any folder and double-click to export structure to struktur.txt
chcp 65001 >nul
tree /f > "struktur.txt"
echo Skrev filstruktur till struktur.txt
pause