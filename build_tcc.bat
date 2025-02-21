@echo off

if not exist .build mkdir .build
if not exist .build\kernel32.def tcc -impdef kernel32.dll -o .build\kernel32.def

tcc -o .build\Asunder.exe -DWinMainCRTStartup=_start -DDEBUG=1 platform\main_windows.c -L.build -lkernel32 || goto :error

if "%1"=="run" .build\Asunder.exe

:error
exit /b 1
