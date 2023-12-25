@if not exist .bin (mkdir .bin & attrib +h .bin)
clang -o .bin/main.exe main.c^
 -g -gcodeview^
 -m64 -std=c99 -Wall -Wextra -pedantic -Wvla -Wshadow -Wunused-macros^
 -Wconversion -Wsign-conversion -Wimplicit-fallthrough -Wcomment -Wcast-align -Wextra-semi -Wdeclaration-after-statement^
 -fuse-ld=lld -ffast-math -fno-exceptions -fno-strict-aliasing^
 -Wl,-subsystem,windows -Wl,-entry,_start -Wl,-pdb=^
 -nostdlib -lkernel32 -luser32 -lgdi32
