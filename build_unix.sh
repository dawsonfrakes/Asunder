#!/bin/sh

set -e

mkdir -p .build

c++ -std=c++11 -Wall -Wextra -pedantic -g -DDEBUG=1 -DRENDER_API=RENDER_API_OPENGL -o .build/Asunder src/platform/main_unix.cpp -lX11

[ "$1" = "run" ] && ./.build/Asunder
