data segment 
    buffer db 160 dup(?)
    random db 12,23,24,18,16,19,17,5,9,13,12,2,4,24,24,1,13,16,24,1,15,22,1,9,1,21,17,24,16,2,23,21,19,7,4,23,18,6,13,14,1,15,9,12,24,24,4,21,3,8,11,4,16,13,13,16,22,21,17,20,24,0,2,17,17,4,5,6,15,1,24,16,5,23,24,11,23,3,22,18,10,4,4,14,8,19,11,16,12,11,5,10,1,2,8,6,8,1,2,20,3,14,2,9,6,4,5,15,4,23,14,9,1,12,8,21,21,13,9,10,8,16,18,19,23,15,24,6,22,11,1,21,14,9,16,24,16,17,19,22,14,2,20,16,1,11,16,18,13,12,0,18,14,17,17,2,1,5,15,22,0,17,20,10,10,6,14,6,18,8,12,6,13,12,14,20,18,1,15,0,10,22,15,14,10,23,18,7,15,7,12,6,13,3,14,24,15,22,0,21,0,5,23,0,19,14,10,21,8,20,14,2,4,6,2,8,21,17,11,6,1,5,0,5,7,11,17,10,19,6,4,6,12,21,7,22,4,19,17,10,19,21,19,8,4,17,14,19,22,22,3,13,11,17,23,0,19
    begin dw ?
data ends

program segment
    assume cs:program, ds:data, ss:stack_

start:
    ; sets the segments registers
    mov ax,data
    mov ds,ax
    mov ax,stack_
    mov ss,ax
    mov sp,offset top

draw:
    mov cx,80

    xor ax,ax
    mov es,ax
    xor bx,bx

    ;0000:046ch contains cpu 55 ms ticks since system start
    mov bl,es:[046ch]
    mov al,random[bx]
    mov dx,160
    mul dx
    mov begin,ax

    cld
    ; copy screen buffer to buffer
    push ds
    push ds
    pop es

    ; segment 0xb800 begins with screen buffer
    mov si,begin

    mov ax,0b800h
    mov ds,ax
    mov di,offset buffer
    
    ; movsw (es:di <- ds:si)
    rep movsw

    pop ds
    
    ; hide line
    mov cx,80
    mov es,ax
    
    mov al,' '
    mov ah,90h ; light blue

    mov di,begin

    ; stosw(word: es:di <- ax)
    rep stosw

    ; wait for around 1 second
    ; int 15h -> 86h(wait)

    mov cl,0fh
    mov dx,4240h       ; f4240h = 1000000 microseconds = 1 second
    mov ah,86h
    int 15h            ; wait
    
    ; reset to previous state
    mov cx,80
    mov ax,0b800h
    mov es,ax
    mov di,begin
    mov si,offset buffer

    ; movsw (es:di <- ds:si)
    rep movsw

    ; check for character in buffer (was there a keystroke? If yes, end program)
    mov ah,01h
    int 16h
    jz draw


    ; clear the input buffer
    xor ah,ah
    int 16h

    ; exit(0)
    mov ah,4ch
    xor al,al
    int 21h

program ends

stack_ segment 
    dw 100h dup(?)
    top Label word
stack_ ends

end start
