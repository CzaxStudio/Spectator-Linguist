; str_ops.s: A slightly longer assembly program for string length calculation and output (x86-64 Linux)

; Define constants for system calls (sys_call_number in RAX) and file descriptors (fd in RDI)
%define SYS_WRITE 1
%define SYS_EXIT  60
%define STDOUT    1

section .data
    ; Data section for initialized data
    message db "Hello, world! The length will be calculated.", 0xA, 0x0 ; The string: "Hello, world!...", newline, and a null terminator (0x0)
    msg_len_intro db "The string length is: ", 0xA ; Message to display before the length
    len_intro_len equ $ - msg_len_intro ; Calculate the length of the introduction message

section .bss
    ; BSS section for uninitialized data (will hold the calculated string length as a string)
    ; Max string length assumed to be representable in a few digits; define a buffer of 10 bytes
    str_length_buffer resb 10

section .text
    global _start       ; Make the _start symbol visible to the linker

_start:
    ; 1. Calculate the length of 'message'
    mov rdi, offset message ; Load effective address (pointer) of message into RDI
    call strlen             ; Call the strlen function
    ; The result (length) is returned in EAX/RAX (EAX is sufficient as length is likely within 32-bit range)

    ; 2. Store the numeric length as a string in str_length_buffer
    mov rsi, rax            ; Move the length (numeric) into RSI for the itoa conversion function
    mov rdi, offset str_length_buffer ; Load buffer address into RDI
    call itoa_simple        ; Call the itoa function to convert integer to ASCII string

    ; 3. Print the introduction message "The string length is: "
    mov rax, SYS_WRITE      ; System call number for 'write'
    mov rdi, STDOUT         ; File descriptor 1 (stdout)
    mov rsi, offset msg_len_intro ; Address of the introduction message
    mov rdx, len_intro_len  ; Length of the introduction message
    syscall                 ; Invoke OS to write

    ; 4. Print the calculated length (which is now a string in the buffer)
    mov rax, SYS_WRITE      ; System call number for 'write'
    mov rdi, STDOUT         ; File descriptor 1 (stdout)
    mov rsi, offset str_length_buffer ; Address of the length string buffer
    ; The 'itoa_simple' function returns the length of the formatted string in RCX
    mov rdx, rcx            ; Use the returned length
    syscall                 ; Invoke OS to write

    ; 5. Print the original "Hello, world!" string
    mov rax, SYS_WRITE      ; System call number for 'write'
    mov rdi, STDOUT         ; File descriptor 1 (stdout)
    mov rsi, offset message ; Address of original message
    ; The 'strlen' function returned length in RAX, which was backed up to RSI and then overwritten by syscall num.
    ; We know the length from manual count or can re-calculate, but let's hardcode for simplicity of this section.
    ; "Hello, world! The length will be calculated.\n" is 46 chars.
    mov rdx, 46             ; Length of the original message
    syscall

    ; 6. Exit the program
    mov rax, SYS_EXIT       ; System call number for 'exit'
    xor rdi, rdi            ; Exit code 0 (success)
    syscall                 ; Invoke OS to exit

; -----------------------------------------------------------------------------
; strlen function: Calculates the length of a null-terminated string.
; Input: RDI = pointer to string
; Output: RAX = length of string
; Clobbers: RAX, RCX
strlen:
    xor rax, rax            ; Start length counter at 0
.loop_strlen:
    cmp byte [rdi + rax], 0 ; Compare current byte with null terminator
    je .done_strlen         ; If null terminator found, we are done
    inc rax                 ; Increment length counter
    jmp .loop_strlen        ; Repeat loop
.done_strlen:
    ret                     ; Return to caller (length is in RAX)
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; itoa_simple function: Converts a non-negative integer to a string (ASCII).
; Only handles positive integers / zero.
; Input: RDI = buffer address, RSI = integer value
; Output: RCX = length of the output string in the buffer
; Clobbers: RAX, RBX, RCX, RDX, RDI, RSI (saves some state)
itoa_simple:
    push rbx                ; Save RBX (callee-saved register)
    mov rcx, rdi            ; Save the start of the buffer pointer
    add rcx, 9              ; Move pointer to the end of the buffer (max 10 chars, right-align)
    mov byte [rcx], 0xA     ; Add a newline character at the end of the buffer
    dec rcx                 ; Move pointer back before newline

    ; Handle case for 0
    cmp rsi, 0
    jne .not_zero
    mov byte [rcx], '0'
    mov rcx, 2              ; Length is 2 ('0' + newline)
    pop rbx
    ret

.not_zero:
    mov rax, rsi            ; Load number into RAX for division
    mov rbx, 10             ; Divisor is 10

.itoa_loop:
    xor rdx, rdx            ; Clear RDX (high part of dividend for DIV)
    div rbx                 ; Divide RAX by RBX: quotient in RAX, remainder in RDX
    add rdx, '0'            ; Convert digit (remainder) to ASCII character
    mov [rcx], dl           ; Store the digit character in the buffer
    dec rcx                 ; Move to the previous byte in the buffer
    cmp rax, 0              ; Check if quotient is zero
    jne .itoa_loop          ; If not zero, continue loop

    ; At this point, the buffer contains the digits reversed and right-aligned.
    ; We need to adjust the start pointer and calculate the length.
    inc rcx                 ; RCX now points to the first digit of the number
    sub rdi, rcx            ; Calculate length by subtracting final pointer from original pointer's end
    add rdi, 10             ; Total bytes used (including newline)
    mov rcx, rdi            ; Move final length to RCX for return
    pop rbx                 ; Restore RBX
    ret
; -----------------------------------------------------------------------------

