        format ELF64 executable 3
        entry start

segment readable executable

include 'print.asm'
include 'sys.asm'

start:
        push rbp
        mov rbp, rsp

        cmp byte [rbp + 8], 4        ; argc
        jne usage
        
        ; open TARGET for reading
        mov rdi, [rbp + 32]          ; argv[2] (TARGET)
        call sys_open_r
        test rax, rax
        js target_error
        push rax                     ; [rbp - 8] (fd for TARGET)

        mov rdi, rax
        call sys_fstat_size
        mov rbx, rax                 ; size(TARGET)

        ; open KEYFILE for reading
        mov rdi, [rbp + 24]          ; argv[1] (KEYFILE)
        call sys_open_r
        test rax, rax
        js keyfile_error
        push rax                     ; [rbp - 16] (fd for KEYFILE)

        mov rdi, rax
        call sys_fstat_size          ; size(KEYFILE) in RAX
        test rbx, rbx                ; if size(TARGET) = 0
        jz target_size_error
        test rax, rax                ; if size(KEYFILE) = 0
        jz keyfile_size_error
        
        ; create OUTPUT
        mov rdi, [rbp + 40]
        call sys_creat
        push rax                     ; [rbp - 24] (fd for OUTPUT)

.read_target_loop:
        mov rdi, [rbp - 8]           ; fd for TARGET
        mov rsi, read_buffer 
        call sys_read_byte
        test rax, rax
        jz sys_exit_0
.read_keyfile_loop:
        mov rdi, [rbp - 16]          ; fd for KEYFILE 
        mov rsi, write_buffer
        call sys_read_byte
        test rax, rax
        jz .read_keyfile_reset

        mov rax, [read_buffer]
        xor [write_buffer], rax
        mov rdi, [rbp - 24]         ; fd for OUTPUT
        call sys_write_byte

        jmp .read_target_loop
.read_keyfile_reset:
        call sys_lseek_reset
        jmp .read_keyfile_loop

die:
        call print_str
        jmp sys_exit_1

usage:
        mov rdi, usage_msg
        jmp die

keyfile_error:
        mov rdi, keyfile_error_msg
        jmp die 

target_error:
        mov rdi, target_error_msg
        jmp die

keyfile_size_error:
        mov rdi, keyfile_size_error_msg
        jmp die

target_size_error:
        mov rdi, target_size_error_msg
        jmp die

segment readable
usage_msg              db 'Usage: crypt KEYFILE TARGET OUTPUT', 0x0a, 0x0
keyfile_error_msg      db 'Failed to open KEYFILE', 0x0a, 0x0
target_error_msg       db 'Failed to open TARGET', 0x0a, 0x0
keyfile_size_error_msg db 'ERROR: size(KEYFILE) = 0', 0x0a, 0x0
target_size_error_msg  db 'ERROR: size(TARGET) = 0', 0x0a, 0x0

segment readable writeable
read_buffer  rq 1
write_buffer rq 1
statbuf      rb STATBUF_SIZE
