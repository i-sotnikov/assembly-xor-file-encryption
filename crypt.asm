        format ELF64 executable 3
        entry start

CHUNK_SIZE = 1024 * 1

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

        mov edi, eax
        call sys_fstat_size
        mov rbx, rax                 ; size(TARGET)

        ; open KEYFILE for reading
        mov rdi, [rbp + 24]          ; argv[1] (KEYFILE)
        call sys_open_r
        test rax, rax
        js keyfile_error
        push rax                     ; [rbp - 16] (fd for KEYFILE)

        mov edi, eax
        call sys_fstat_size          ; size(KEYFILE) in RAX
        test rbx, rbx                ; if size(TARGET) = 0
        jz target_size_error
        cmp rax, CHUNK_SIZE          ; if size(KEYFILE) < CHUNK_SIZE
        jl keyfile_size_error
        
        ; create OUTPUT
        mov rdi, [rbp + 40]          ; argv[3] (OUTPUT)
        call sys_creat
        push rax                     ; [rbp - 24] (fd for OUTPUT)

        sub rsp, 8                   ; for number of bytes read from TARGET

.read_target_loop:
        mov edi, [rbp - 8]           ; fd for TARGET
        mov rsi, read_buffer 
        mov edx, CHUNK_SIZE
        call sys_read
        test rax, rax
        jz sys_exit_0
        mov [rsp], eax               ; bytes read from TARGET
.read_keyfile_loop:
        mov edi, [rbp - 16]          ; fd for KEYFILE 
        mov rsi, write_buffer
        mov edx, [rsp]
        call sys_read
        cmp eax, [rsp]
        jl .read_keyfile_reset

        xor ebx, ebx
.xor_loop:
        movzx eax, byte [read_buffer + ebx]
        xor [write_buffer + ebx], al
        inc ebx
        cmp ebx, [rsp]
        jl .xor_loop

        mov edi, [rbp - 24]         ; fd for OUTPUT
        mov rsi, write_buffer
        mov edx, [rsp]
        call sys_write

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
        mov edi, [rbp - 8]
        call sys_close
        mov rdi, keyfile_error_msg
        jmp die 

target_error:
        mov rdi, target_error_msg
        jmp die

keyfile_size_error:
        mov edi, [rbp - 8]
        call sys_close
        mov edi, [rbp - 16]
        call sys_close
        mov rdi, keyfile_size_error_msg
        jmp die

target_size_error:
        mov edi, [rbp - 8]
        call sys_close
        mov edi, [rbp - 16]
        call sys_close
        mov rdi, target_size_error_msg
        jmp die

segment readable
usage_msg              db 'Usage: crypt KEYFILE TARGET OUTPUT', 0x0a, 0x0
keyfile_error_msg      db 'Failed to open KEYFILE', 0x0a, 0x0
target_error_msg       db 'Failed to open TARGET', 0x0a, 0x0
keyfile_size_error_msg db 'ERROR: size(KEYFILE) < CHUNK_SIZE (1 KiB)', 0x0a, 0x0
target_size_error_msg  db 'ERROR: size(TARGET) = 0', 0x0a, 0x0

segment readable writeable
read_buffer  rb CHUNK_SIZE
write_buffer rb CHUNK_SIZE
statbuf      rb STATBUF_SIZE
