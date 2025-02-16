@echo off

if not exist .build mkdir .build

where /q cl || call vcvars64.bat || goto :error

set CFLAGS="-DRENDER_API=RENDER_API_OPENGL"

cl -Fe.build\Asunder.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000 -DDEBUG=1 %CFLAGS%^
 src\platform\main_windows.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -subsystem:console -entry:WinMainCRTStartup -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\Asunder.exe )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
