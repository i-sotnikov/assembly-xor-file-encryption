O_RDONLY        = 0
O_WRONLY        = 1
CREAT_MODE      = 0644o
SEEK_SET        = 0
STATBUF_SIZE    = 144
ST_SIZE_OFFSET  = 48

sys_open_r:
        mov eax, 2
        mov esi, O_RDONLY
        syscall
        ret

sys_creat:
        mov eax, 85
        mov esi, CREAT_MODE
        syscall
        ret

sys_read:
        xor eax, eax
        syscall
        ret

sys_write:
        mov eax, 1
        syscall
        ret

sys_lseek_reset:
        mov eax, 8
        xor esi, esi
        mov edx, SEEK_SET
        syscall
        ret

sys_fstat_size:
        mov eax, 5
        mov rsi, statbuf
        syscall
        mov rax, qword [statbuf + ST_SIZE_OFFSET]
        ret

sys_exit_0:
        mov rsp, rbp
        pop rbp
        mov eax, 60
        xor edi, edi
        syscall

sys_exit_1:
        mov rsp, rbp
        pop rbp
        mov eax, 60
        mov edi, 1
        syscall
