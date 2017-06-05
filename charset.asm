	;
	; Show the available charset
	;
	; by Oscar Toledo G. http://nanochess.org/
	;
	; Creation date: Jun/05/2017.
	;

ss1:    mov ax,0x0002
        int 0x10
        mov ax,0xb800
        mov ds,ax
        mov es,ax
        cld
        mov di,0x0020
        mov cx,16
        mov ax,0x0700
ss3:    push cx
        mov cx,16
ss2:    stosw
        inc al
        loop ss2
        pop cx
        add di,0x00a0-0x0020
        loop ss3
        int 0x20

