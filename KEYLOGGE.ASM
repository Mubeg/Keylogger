.model tiny
.code
org 100h

extrn draw_ramka:proc
extrn scan_code_to_ascii:proc

start:

	mov ax, 0h
	mov ds, ax
	mov si, 08h*4h
	mov ax, cs
	mov es, ax
	mov di, offset old_08h
	cld			; inc, not dec
	movsw			; save old int 08 func
	movsw			; for dw

	mov di, offset old_09h
	movsw			; save old int 09 func
	movsw			; for dw

	mov di, 08*4h
	mov ax, 0h
	mov es, ax

	mov ax, offset int_08_timer_replace
	stosw	
	mov ax, cs
	stosw

	mov ax, offset int_09_keyboard_replace
	stosw
	mov ax, cs
	stosw

	int 09h		; debug check
	jmp stay_resident

int_09_keyboard_replace:
		
		push ax

		mov ah, 02h
		int 16h		;	do #below#

		;		mov di, 0040
		;		mov es, di
		;		mov di, 0017		; 0040:0017 handeled after old int 09 is done
		;		mov ah, byte ptr es:[di]; 0040:0017 = [ins|caps|num|scr|Alt|ctrl|lshift|rshift]	

		mov ah, al	; int 16h 02h -> al
		and ah, 00000011b	; ah = 0 if shift is up else -> ah != 0

		in al, 60h
		cmp al, 80h
		jae action_key_up
	
		call scan_code_to_ascii	; ah = 'bool' is_shift_down, al = scan_code

		mov byte ptr cs:[offset last_key], al	; place al to print in int 08h

action_key_up:
		pop ax
	
		db 0eah		; jmp far
old_09h		dd 0bedabedah

int_08_timer_replace:
		
		pushf
		call dword ptr cs:[old_08h]
		push ax bx cx es
		
		mov ax, 0h
		mov bx, 0303h
		mov cx, 000eh
		call draw_ramka

		db 0bbh			; mov bx, ...
last_key:	dw 0eadh		; 'global' var

		mov ax, 0b800h		
		mov es, ax
		mov word ptr es:[0a2h], bx

		pop es cx bx ax
		
		iret

stay_resident:
	mov ax, 3100h
	int 21h
.data
old_08h		dd 0bedabedah

end	start