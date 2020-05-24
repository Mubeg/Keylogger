.model tiny
.code
org 100h

public draw_ramka

start:
	jmp return


top_left_corner		=  0c9h;  É
top_right_corner	=  0bbh;  »
bottom_right_corner	=  0bch;  ¼
bottom_left_corner	=  0c8h;  È
vertical_line		=  0bah;  º
horizontal_line		=  0cdh;  Í
space			=  0ffh;  ÿ

;------------------------------------------------------------------------------;
;	Params:                                                          
;		ah - x_left_up                                           
;		al - y_left_up                                           
;		bh - x_size (min = 2) - includes borders ; 0 = no_draw                                             
;		bl - y_size (min = 2) - includes borders ; 0 = no_draw                                           
;		cl - color                                               
;                                                                 
;
draw_ramka      proc

		cmp bh, 0
		jne not_ramka_end
		cmp bl, 0
		jne not_ramka_end
		ret
		
not_ramka_end:

		push es dx cx si di
                                          
		mov dx, 0b800h	; 0b800h - VM page
		mov es, dx 	; Set page

		push bx		; save data for calculations
		push ax
		
		mov bl, 0a0h    ; width hardcoded (50h -> [0040:004a] for not harcoded)
		mul bl		; al *= width
		pop bx
		add al, bh	; ax += bl (= ah_prev)
		add al, bh
		mov dx, ax	; dx = calculated shift
		mov di, dx	; save dx in di		

		pop ax		; ax = x_size, y_size

		push di		; save for dynamic use in spaces loop
		mov bh, cl	; set color code
		mov cx, 0h	; start col_counter
		mov bl, space	; set char code
		mov dx, 0 	; set line counter
load_with_spaces_col:
		
		cmp cl, al
		jae load_with_spaces_col_end	; if col_counter >= size -> break

		mov dx, 0	; zero line counter
load_with_spaces_line:

		cmp dl, ah
		jae load_with_spaces_line_end 	; if line_counter >= size -> break

		mov si, di
		add si, dx
		add si, dx
		mov word ptr es:[si], bx	; write the byte

		inc dx
		jmp load_with_spaces_line

load_with_spaces_line_end:
		
		mov bl, vertical_line
		mov si, di
		mov word ptr es:[si], bx	; draw left column
		
		dec dx
		add si, dx
		add si, dx
		mov word ptr es:[si], bx	; draw right column
	
		mov bl, space			; restore to spaces

		inc cx
		add di, 0a0h			; next column 
		jmp load_with_spaces_col		

load_with_spaces_col_end:

		sub di, 0a0h			; overcycled
		mov bl, bottom_left_corner
		mov word ptr es:[di], bx 	; since last di is in bot_left

		mov si, di
		pop di		; load saved value
		push si		; and save current

		mov bl, top_left_corner
		mov si, di
		mov word ptr es:[si], bx	; draw top_left
						
						
		mov bl, horizontal_line	
		pop dx		; load left_bot
		sub dx, di	; calc shift from top to bot
		mov cx, 1h	; set counter
draw_hor_line:
		cmp cl, ah
		jae draw_hor_line_end		; if counter >= x_size

		mov si, di
		add si, cx
		add si, cx
		mov word ptr es:[si], bx	; draw top_hor_line

		add si, dx
		mov word ptr es:[si], bx	; draw bot_hor_line

		inc cx
		jmp draw_hor_line
	
draw_hor_line_end:

		dec cx			; for last cell access
		mov bl, top_right_corner
		mov si, di
		add si, cx
		add si, cx
		mov word ptr es:[si], bx	; draw left_bott depend on cycle end (di is next to it)

		add si, dx
		mov bl, bottom_right_corner
		mov word ptr es:[si], bx	; draw right_top depend on si from cycle


		pop di si cx dx es 
		ret
		endp
;------------------------------------------------------------------------------;



return:
		mov ax, 4c00h
		int 21h

stay_resident:
		mov ax, 3100h
		int 21h

CR	equ 	13
LF	equ	10
CRLF	equ	CR, LF

end	start