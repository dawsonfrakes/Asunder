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
)

tcc -o .build\Asunder.exe -nostdlib -DWinMainCRTStartup=_start platform\main_windows.c -L.build -lkernel32 -luser32 -lgdi32 -lopengl32 -lws2_32 -ldwmapi -lwinmm
