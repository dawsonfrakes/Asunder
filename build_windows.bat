@echo off

where /q cl || call vcvars64 || goto :error

mkdir .build 2>nul

cl -Fe.build\Asunder.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000 -Isrc\modules^
 src\platform\main_windows.cpp -I%VK_SDK_PATH%\Include kernel32.lib user32.lib ws2_32.lib dwmapi.lib winmm.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
