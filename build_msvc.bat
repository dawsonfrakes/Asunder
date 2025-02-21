@echo off

where /q cl || call vcvars64.bat || goto :error

if not exist .build mkdir .build

cl -Fe.build\Asunder.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000 -DDEBUG=1^
 platform\main_windows.c kernel32.lib^
 -link -incremental:no -nodefaultlib -subsystem:console -entry:WinMainCRTStartup -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

if "%1"=="run" ( .build\Asunder.exe
) else if "%1"=="release" (
	cl -Fe.build\Asunder.exe -nologo -W4 -WX -wd4127 -O2 -Oi -J -EHa- -GR- -GS- -Gs0x10000000 -DDEBUG=0^
	platform\main_windows.c kernel32.lib^
	-link -incremental:no -nodefaultlib -subsystem:windows -stack:0x10000000,0x10000000 -heap:0,0 || goto :error
) else if "%1"=="debug" ( where /q remedybg && start remedybg .build\Asunder.exe || start raddbg .build\Asunder.exe
) else if "%1"=="doc" ( start qrenderdoc .build\Asunder.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
