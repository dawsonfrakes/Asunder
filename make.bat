@if not exist .bin (mkdir .bin & attrib +h .bin)
clang -o .bin/Asunder.exe src/win_main.c^
 -g -gcodeview^
 -Wall -Wextra -pedantic -Wvla -Wshadow -Wunused-macros -Wconversion -Wsign-conversion -Wimplicit-fallthrough^
 -fuse-ld=lld -Wl,-subsystem,windows -Wl,-pdb=^
 -Xlinker -stack=0x1000,0x1000 -Xlinker -heap=0,0^
 -nostdlib -lkernel32 -luser32 -lgdi32