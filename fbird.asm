        ;
        ; F-bird text game in a bootsector
        ;
        ; by Oscar Toledo G.
        ;
        ; Creation date: Jun/04/2017. A messy unoptimized thing.
        ; Revision date: Jun/05/2017. Better usage of graphic charset.
        ;

        use16

        mov ax,0x0002   ; Set 80x25 text mode
        int 0x10
        cld
        mov ax,0xb800   ; Point to video segment
        mov ds,ax
        mov es,ax
fb21:   mov di,pipe     ; Init variables in video segment (saves big bytes)
        xor ax,ax
        stosw
        stosw
        stosw
        mov al,0xa0
        stosw
        mov al,0x60
        stosw
        mov di,0x004a   ; Game title
        mov ax,0x0f46   ; 'F' in white, good old ASCII
        stosw
        mov al,0x2d     ; '-'
        stosw
        mov al,0x42     ; 'B'
        stosw
        mov al,0x49     ; 'I'
        stosw
        mov al,0x52     ; 'R'
        stosw
        mov al,0x44     ; 'D'
        stosw
        mov cx,80       ; Introduce 80 columns of scenery
fb1:    push cx
        call scroll_scenery
        pop cx
        loop fb1

fb23:   mov ah,0x01     ; Wait for a key
        int 0x16
        jz fb22
        xor ax,ax
        int 0x16
        jmp short fb23

fb22:   xor ax,ax
        int 0x16
        ;
        ; Main loop
        ;
fb12:   mov al,[bird]   ; Bird falls because of gravity
        add al,[grav]
        mov [bird],al
        and al,0xf8
        mov ah,0x14
        mul ah          ; Row into screen
        mov di,ax
        add di,$0020    ; Fixed column
        mov al,[frame]
        and al,4        ; Wing movement
        jz fb15
        mov al,[di-160]
        mov word [di-160],$0d1e
        add al,[di]
        shr al,1
        mov word [di],$0d14
        jmp short fb16

fb15:   mov al,[di]
        mov word [di],$0d1f
fb16:   add al,[di+2]
        shr al,1
        mov word [di+2],$0d10
        cmp al,0x20     ; Collision with scenery?
        jz fb19
        ;
        ; Stars and game over
        ;
        mov byte [di],$2a
        mov byte [di+2],$2a
        mov di,0x07CA   
        mov ax,0x0f42   ; 'B' in white, good old ASCII
        stosw
        mov al,0x4F     ; 'O'
        stosw
        mov al,0x4E     ; 'N'
        stosw
        mov al,0x4B     ; 'K'
        stosw
        mov al,0x21     ; '!'
        stosw
        mov cx,100
fb20:   push cx
        call wait_frame
        pop cx
        loop fb20
        jmp fb21

fb19:   call wait_frame ; Wait for frame
        inc byte [frame]
        mov al,[frame]
        and al,7       ; 8 frames?
        jnz fb17
        inc word [grav] ; Increase gravity
fb17:
        mov byte [di-160],$20   ; Delete bird from screen
        mov byte [di],$20
        mov byte [di+2],$20
        call scroll_scenery     ; Scroll scenery
        call scroll_scenery     ; Scroll scenery
        cmp byte [0x00a2],0xb0  ; Passed a column?
        jnz fb24
        inc word [score]        ; Increase score
        mov ax,[score]
        mov di,0x008e   ; Show current score
fb25:   mov dx,0        ; Extend AX to 32 bits
        mov bx,10       ; Divisor is 10
        div bx          ; Divide
        add dl,0x30     ; Convert remaining 0-9 to ASCII
        push ax
        mov al,dl
        mov ah,0x0c
        std
        stosw
        cld
        pop ax
        or ax,ax
        jnz fb25
fb24:   mov ah,0x01     ; Any key pressed?
        int 0x16
        jz fb12         ; No, go to main loop
        mov ah,0x00
        int 0x16        ; Get key
        cmp al,0x1b     ; Escape?
        jne fb4
        int 0x20        ; Exit to DOS or to oblivion (boot sector)
fb4:    mov ax,[bird]
        sub ax,0x10     ; Move bird two rows upward
        cmp ax,0x08
        jb fb18
        mov [bird],ax
fb18:   mov byte [grav],0       ; Reset gravity
        jmp fb12

        ;
        ; Scroll scenery one column at a time
        ;
scroll_scenery:
        ;
        ; Move whole screen
        ;
        mov si,0x00a2
        mov di,0x00a0
fb2:    mov cx,79
        repz
        movsw
        mov ax,0x0e20
        stosw
        lodsw
        cmp si,0x0fa2
        jnz fb2
        ;
        ; Insert houses
        ;
        mov word [0x0f9e],0x02df        ; Terrain
        in al,(0x40)
        and al,0x70
        jz fb5
        mov word [0x0efe],0x0408
        mov di,0x0e5e
        and al,0x20
        jz fb3
        mov word [di],0x0408
        sub di,0x00a0
fb3:    mov word [di],0x091e
        ;
        ; Check if it's time to insert a column
        ;
fb5:    dec word [next]
        mov bx,[next]
        cmp bx,0x03
        ja fb6
        jne fb8
        in al,(0x40)
        and ax,0x0007
        add al,0x04
        mov [tall],ax
fb8:    mov dl,0xdb
        mov cx,[tall]
        cmp bx,0x01
        jz fb7
        cmp bx,0x02
        jz fb7
        or bx,bx
        mov dl,0xb0
        jz fb7
        mov dl,0xb1
fb7:    mov di,0x013e
        mov ah,0x0a
        mov al,dl
fb9:    stosw
        add di,0x009e
        loop fb9
        mov al,0xc4
        stosw
        add di,0x009e*6+10
        mov al,0xdf     
        stosw
        add di,0x009e
fb10:   mov al,dl
        stosw
        add di,0x009e
        cmp di,0x0f00
        jb fb10
        or bx,bx
        jnz fb6
        mov ax,[pipe]
        inc ax          ; Increase total pipes shown
        mov [pipe],ax
        mov cl,3
        shr ax,cl
        mov ah,0x50     ; Decrease distance between pipes
        sub ah,al
        cmp ah,0x10
        ja fb11
        mov ah,0x10
fb11:   mov [next],ah
fb6:    ret

wait_frame:
        mov ah,0x00
        int 0x1a
        mov bx,dx
fb14:   push bx
        mov ah,0x00
        int 0x1a
        pop bx
        cmp bx,dx
        jz fb14
        ret

        db "nanochess 2017"     ; Guess who? :P

        db 0x55,0xaa    ; Bootable signature

pipe:   equ 0x0fa0
score:  equ 0x0fa2
grav:   equ 0x0fa4
next:   equ 0x0fa6
bird:   equ 0x0fa8
tall:   equ 0x0faa
frame:  equ 0x0fac

