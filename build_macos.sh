#!/bin/sh

set -e

mkdir -p .build

clang -std=c++11 -Wall -Wextra -pedantic -o .build/Asunder src/platform/main_macos.mm -nostdlib -lSystem -framework AppKit -Wl,-e,_start

[ "$1" = "run" ] && ./.build/Asunder
