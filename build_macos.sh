#!/bin/sh

set -e

mkdir -p .build

cc -o .build/Asunder_debug -std=c99 -Wall -Wextra -pedantic -nostdlib -DDEBUG=1 -x objective-c main_macos.c -lSystem -framework AppKit -Wl,-e,_start

[ "$1" = "run" ] && ./.build/Asunder_debug
[ "$1" = "release" ] && cc -o .build/Asunder -std=c99 -Wall -Wextra -pedantic -nostdlib -O2 -DDEBUG=0 -x objective-c main_macos.c -lSystem -framework AppKit -Wl,-e,_start
