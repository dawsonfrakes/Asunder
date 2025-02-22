#!/bin/sh

set -e

mkdir -p .build

${CC:-cc} -Wall -Wextra -pedantic -o .build/Asunder -nostdlib -DDEBUG=1 -fno-stack-protector platform/main_unix.c
