#include "../game/game.c"
#include "../basic/unix.h"

noreturn_def _start(void) {
	write(STDOUT_FILENO, "Hello, world!\n", 14);
	exit(0);
}
