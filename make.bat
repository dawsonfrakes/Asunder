@if not exist .bin (mkdir .bin & attrib +h .bin)

@rem Error on new comment style (// comment) because clang's -Wcomment doesn't warn with -std=c99
@findstr /n /o "\/\/" windows_main.c && (echo BAD COMMENT STYLE & exit /b)

clang -o .bin/Asunder.exe windows_main.c^
 -g -gcodeview^
 -DRENDERER_OPENGL=1^
 -m64 -march=native^
 -std=c99 -Wall -Wextra -pedantic -Wvla -Wshadow -Wunused-macros -Wconversion -Wsign-conversion^
 -Wextra-semi-stmt -Wdeclaration-after-statement -Wimplicit-fallthrough^
 -fuse-ld=lld -ffast-math -fno-strict-aliasing -fno-exceptions -mno-stack-arg-probe^
 -Wl,-subsystem,windows -Wl,-pdb=^
 -Xlinker -stack=0x1000,0x1000 -Xlinker -heap=0,0^
 -nostdlib -lkernel32 -luser32 -lgdi32 -lopengl32
