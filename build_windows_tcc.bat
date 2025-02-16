@echo off

if not exist .build mkdir .build

if not exist .build\kernel32.def (
	tcc -impdef kernel32.dll -o .build\kernel32.def
	tcc -impdef user32.dll -o .build\user32.def
	tcc -impdef gdi32.dll -o .build\gdi32.def
	tcc -impdef opengl32.dll -o .build\opengl32.def
	tcc -impdef ws2_32.dll -o .build\ws2_32.def
	tcc -impdef dwmapi.dll -o .build\dwmapi.def
	tcc -impdef winmm.dll -o .build\winmm.def
	tcc -impdef ucrtbase.dll -o .build\ucrtbase.def
)

set CFLAGS="-DRENDER_API=RENDER_API_OPENGL"

tcc -o .build\Asunder.exe -g -nostdlib -DWinMainCRTStartup=_start -DDEBUG=1 %CFLAGS%^
 src\platform\main_windows.c^
 -L.build -lkernel32 -luser32 -lgdi32 -lopengl32 -lws2_32 -ldwmapi -lwinmm -lucrtbase -Wl,-subsystem,console || goto :error

if "%1"=="run" ( start .build\Asunder.exe
) else if "%1"=="release" (
	tcc -o .build\Asunder.exe -nostdlib -DWinMainCRTStartup=_start -DDEBUG=0 %CFLAGS%^
	 src\platform\main_windows.c^
	 -L.build -lkernel32 -luser32 -lgdi32 -lopengl32 -lws2_32 -ldwmapi -lwinmm -Wl,-subsystem,windows
)

:end
exit /b
:error
call :end
exit /b 1
