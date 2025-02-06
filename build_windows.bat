@echo off

where /q cl || call vcvars64.bat || goto :error

cl -FeZ1X1.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000^
 src\platform\main_windows.c src\game\game.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows -stack:0x1000000,0x1000000 -heap:0,0 || goto :error

if "%1"=="run" ( start Z1X1.exe
) else if "%1"=="debug" ( start remedybg Z1X1.exe
) else if "%1"=="doc" ( start qrenderdoc Z1X1.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
