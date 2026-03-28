.global _start          # Entry point

.section .text
_start:
    # write(1, message, 14)
    mov $1, %rax        # syscall: sys_write
    mov $1, %rdi        # file descriptor: stdout
    mov $message, %rsi  # buffer
    mov $14, %rdx       # length
    syscall

    # exit(0)
    mov $60, %rax       # syscall: sys_exit
    xor %rdi, %rdi      # exit code 0
    syscall

.section .data
message: .ascii "Hello, world!\n"
