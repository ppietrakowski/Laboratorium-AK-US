; half tones
; c - cis d - dis e - eis f - fis g - gis a - ais

data segment
    FileHandler dw ?
    OpenFailMsg db 'Nie udalo otworzyc sie pliku.','$'
    NoArgsMsg db 'Podaj nazwe pliku jako argument!','$'
    FileName db 16 dup(0)
    Char db 0
data ends


assume cs:code,ss:stack_,ds:data

code segment

; Enable speaker counter for data writing and speaker enable
EnableSound proc
    in 	al,61h
	or	al,00000011b
	out	61h,al
    ret
EnableSound endp

DisableSound proc
    in 	al,61h
	and	al,11111100b
	out	61h,al
    ret
DisableSound endp

; Returns in ax the divisor of note
; @param al note symbol
GetNote proc
    cmp al,'C'
    je PlayDo

    cmp al,'D'
    je PlayRe

    cmp al,'E'
    je PlayMi

    cmp al,'F'
    je PlayFa

    cmp al,'G'
    je PlaySo

    cmp al,'A'
    je PlayLa

    cmp al,'H'
    je PlaySi

    cmp al,'P'
    je PlayPause

    cmp al,'a'
    je PlayAis
    
    cmp al,'c'
    je PlayCis

    cmp al,'d'
    je PlayDis

    cmp al,'e'
    je PlayEis

    cmp al,'f'
    je PlayFis

    cmp al,'g'
    je PlayGis

    jmp PlayPause
PlayDo:
    mov ax,34546 ; 1.19MHz/33Hz
    jmp Note

PlayRe:
    mov ax,30811 ; 1.19MHz/37Hz
    jmp Note

PlayMi:
    mov ax,27805 ; 1.19MHz/41Hz
    jmp Note

PlayFa:
    mov ax,25909 ; 1.19MHz/44Hz
    jmp Note

PlaySo:
    mov ax,23265 ; 1.19MHz/49Hz
    jmp Note

PlayLa:
    mov ax,20727 ; 1.19MHz/55Hz
    jmp Note

PlaySi:
    mov ax,18387 ; 1.19MHz/62Hz
    jmp Note

PlayCis:
    mov ax,34000 ; 1.19MHz/35Hz
    jmp Note

PlayDis:
    mov ax,30512 ; 1.19MHz/39Hz
    jmp Note

PlayEis:
    mov ax,28333 ; 1.19MHz/42Hz
    jmp Note

PlayFis:
    mov ax,25869 ; 1.19MHz/46Hz
    jmp Note

PlayGis:
    mov ax,22885 ; 1.19MHz/52Hz
    jmp Note

PlayAis:
    mov ax,20517 ; 1.19MHz/58Hz
    jmp Note


PlayPause:
    mov ax,1 ; don't generate below 18,2Hz(1,19MHz/65535Hz)
    
Note:
    ret
GetNote endp

ReadByte proc
    mov ah,3fh
    mov al,0
    mov bx,FileHandler
    mov dx,offset Char
    mov cx,1
    int 21h
    jc Exit

    mov al,Char

    cmp al,'Q'
    je EndOfFile
    inc si
    ret

EndOfFile:
    mov ah,3eh
    mov al,0
    mov bx,FileHandler
    call Exit

ReadByte endp

Exit proc
    mov ah,3eh
    xor al,al
    mov bx,FileHandler
    int 21h
    call DisableSound
    mov ax,4c00h
    int 21h
    
Exit endp

ExitNoArgs proc
    pop ds
    mov ax,0900h
    mov dx,offset NoArgsMsg
    int 21h
    mov ax,4c00h
    int 21h
ExitNoArgs endp

SendToController proc
    ; send to counter 16-bits
	out	42h,al
	mov	al,ah		
	out	42h,al
    ret
SendToController endp

; Delays by al parameter
; 1 - as full note
; 2 - as half note
; 4 - as quarter note
; 8 - as half quarter note
Delay proc
    cmp al,1
    je _fullnote
    cmp al,2
    je _halfNote

    cmp al,4
    je _quarterNote

    cmp al,8
    je _halfquarterNote

    mov ax,1
    jmp _notValid
; 0,5 s
_fullnote:
    mov cx,7
    mov dx,0A120h
    jmp callDelay

_halfNote:
    mov cx,3
    mov dx,0D090h
    jmp callDelay

_quarterNote:
    mov cx,1
    mov dx,0E848h
    jmp callDelay

_halfquarterNote:
    mov cx,0
    mov dx,0F424h
    jmp callDelay

callDelay:
    xor al,al
    mov ah,86h
    int 15h
_notValid:
    ret
Delay endp

start:
    mov ax,data 
	mov ds,ax 
	mov ax,stack_ 
	mov ss,ax 
	mov sp,offset Top

    ;get filename from argument
    xor cx,cx
    mov ah,62h
    int 21h             ;bx now contains cmd line (80h -> length, 82h+ -> contents)

    ;copy to filename
    push ds
    push ds
    mov di,offset FileName
    mov ds,bx
    mov cl,ds:[0080h]   ;length of args
    cmp cl,0
    je ExitNoArgs
    
    dec cl ; includes space
    pop es
    mov si,82h
    ; (es:di <- ds:si)
    rep movsb

    pop ds
    
    ;open file
    xor cx,cx
    mov ah,3dh
    mov al,0        ; open file (3d) read-only (00) with filename under ds:dx
    mov dx,offset FileName
    int 21h
    jc OpenFailed
    mov FileHandler,ax
    xor si,si

PlayMelody:
    call ReadByte
    call GetNote

    push ax
    xor ah,ah

    call ReadByte

    ; get tone
    sub al,'0'
    xor cx,cx
    mov cl,al
    pop ax
    shr ax,cl
    
    call SendToController
    call EnableSound

    xor ah,ah

    call ReadByte
    sub al,'0'

    ; get duration
    call Delay

    call DisableSound
    jmp PlayMelody

OpenFailed:
    mov dx,offset OpenFailMsg
    mov ah,09h
    mov al,0
    int 21h
    call Exit

code ends

segment stack_ stack
    dw 100h dup(0) 
    Top label word
stack_ ends
end start