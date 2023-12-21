@if not exist .bin (mkdir .bin & attrib +h .bin)
clang -o .bin/Asunder.exe main.c^
 -g -gcodeview^
 -m64 -march=native^
 -std=c99 -Wall -Wextra -pedantic -Wvla -Wshadow -Wextra-semi -Wimplicit-fallthrough -Wunused-macros -Wconversion -Wsign-conversion^
 -fuse-ld=lld -ffast-math -fno-exceptions -fno-strict-aliasing -mno-stack-arg-probe^
 -Wl,-subsystem,windows -Wl,-pdb= -Xlinker -stack=0x1000,0x1000 -Xlinker -heap=0,0^
 -nostdlib -lkernel32 -luser32 -lgdi32