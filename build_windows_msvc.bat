@echo off

if not exist .build mkdir .build

where /q cl || call vcvars64.bat || goto :error

cl -Fe.build\Asunder_debug.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000 -DDEBUG=1^
 main_windows.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -nodefaultlib -subsystem:console -entry:WinMainCRTStartup -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\Asunder_debug.exe
) else if "%1"=="debug" ( start remedybg .build\Asunder_debug.exe
) else if "%1"=="doc" ( start qrenderdoc .build\Asunder_debug.exe
) else if "%1"=="release" (
	cl -Fe.build\Asunder.exe -nologo -O2 -Oi -W4 -WX -J -EHa- -GR- -GS- -Gs0x10000000 -DDEBUG=0^
	 main_windows.c kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib^
	 -link -incremental:no -nodefaultlib -subsystem:windows -stack:0x10000000,0x10000000 -heap:0,0 || goto :error
)

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
