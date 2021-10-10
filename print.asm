len:
        lea rax, [rdi - 1]

.loop:
        inc rax
        cmp byte [rax], 0
        jne .loop

        sub rax, rdi
        ret

print_str:
        call len
        mov rdx, rax
        mov rsi, rdi
        mov edi, 1
        mov eax, edi
        syscall
        ret

print_ch:
        mov eax, 1
        mov edi, eax
        mov edx, eax 
        syscall
        ret
