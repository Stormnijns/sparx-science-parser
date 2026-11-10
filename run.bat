@echo off
cd /d "%~dp0"
lua -e "package.path = package.path .. ';src/?.lua;src/?/init.lua' ; dofile('src/Main.lua')"
pause