#define STDOUT_FILENO 1

#if OS == OS_LINUX
#define SYS_read 0
#define SYS_write 1
#define SYS_open 2
#define SYS_close 3
#define SYS_stat 4
#define SYS_exit 60

#if CPU == CPU_X64
#define SYSCALL1(N, A1) __asm__ ("syscall" :: "a" (N), "D" (A1))
#define SYSCALL3_RET(N, A1, A2, A3, R) __asm__ ("syscall" : "=r" (R) : "a" (N), "D" (A1), "S" (A2), "d" (A3))
#endif
#endif

sintptr write(sint fd, void* data, uintptr count) {
	sintptr result;
	SYSCALL3_RET(SYS_write, fd, data, count, result);
	return result;
}

noreturn_def exit(s32 status) {
	SYSCALL1(SYS_exit, status);
	unreachable;
}
