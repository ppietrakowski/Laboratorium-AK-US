

data segment
    empty_str db '$'
    new_line db 10,13,'$'

    greeting db 'Podaj liczbe dziesietna z przedzialu <0, 65535>: ','$'
    empty_input_msg db 'Nie wprowadzono zadnej wartosci.','$'
    overflow_msg db 'Liczba zbyt duza, nie zmiescila sie w <0, 65535>','$'
    invalid_num_format_msg db 'Wprowadzono zly znak.$'

    hex_info db 'hex: $'
    bin_info db 'binarnie: $'
    dec_info db 'dziesietnie: $'

    max_buffer_size db 6
    buffer_length db ?
    number db 6 dup(0)

    hex_num db '0123456789abcdef'

    sum dw 0
data ends

program segment
    assume cs:program, ds:data, ss:stack_

;
; prints string, that is saved in dx, and adds a end-of-line character
;
println:
    mov ah,09h
    int 21h
    mov dx,offset new_line
    int 21h
    ret 

print:
    mov ah,09h
    int 21h
    ret

empty_input:
    mov dx,offset empty_input_msg
    call println

    jmp end_

invalid_char:
    mov dx,offset invalid_num_format_msg
    call println

    jmp end_

overflow:
    mov dx,offset overflow_msg
    call println

    jmp end_

start:
    ; sets the segments registers
    mov ax,data
    mov ds,ax
    mov ax,stack_
    mov ss,ax
    mov sp,offset top

    mov dx,offset greeting
    call print

    ; loading a number
    mov dx,offset max_buffer_size
    mov ah,0ah
    int 21h

    mov dx,offset empty_str
    call println

    ; check if len = 0
    cmp buffer_length,0h
    je empty_input

    ; load length
    mov cl,buffer_length
    
    ; zero the registers
    xor ch,ch
    xor si,si
    xor bx,bx

loop_:
    mov al,number[si]
    ;xor bx,bx
    cmp al,'0'
    jl invalid_char

    cmp al,'9'
    jg invalid_char
    sub al,'0'

    ; bx now temporary holds a number
    mov bl,al

    mov dx,10
    mov ax,sum
    mul dx

    jc overflow
    add ax,bx

    ; is not over 65535(max 16 bit value)
    jc overflow
    mov sum,ax
    inc si
    loop loop_

; casting that address to byte address
mov byte ptr number[si],'$'

; show decimal number
mov dx,offset dec_info
call print
mov dx,offset number
call println

; display binary

mov cx,16
mov bx,sum

mov dx,offset bin_info
call print

; int 21h code -> Display char (ds:dl)
mov ah,02h

binary_:
    mov dl,'0'
    rcl bx,1
    jnc dspl_bin_num
    inc dl
dspl_bin_num:
    int 21h
    loop binary_

mov dl,'b'
int 21h

; print hex
mov cx,4
mov bx,sum

mov dx,offset empty_str
call println

mov dx,offset hex_info
call print

mov ah,02h

hex:
    ; a mask for 4-bits
    mov si,000fh
    rol bx,4
    and si,bx
   
    
    mov dl,hex_num[si]
    int 21h
    loop hex

mov dl,'h'
int 21h

end_:
    mov ah,4ch
    mov al,0
    int 21h

program ends

stack_ segment
    dw 100h dup(0, 1, 2)
    top Label word
stack_ ends

end start
