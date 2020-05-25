.model tiny
.code
org 100h

public scan_code_to_ascii

start:
	mov ax, 0042h
	call scan_code_to_ascii
	mov ax, 4c00h
	int 21h

;--------------------------------------------------;
;Input
;	al - scan code
;	ah - >0 = shift, 0 = no shift
;Output
;	al - ascii code
;--------------------------------------------------;
scan_code_to_ascii proc

	push di

	cmp ah, 0h
	jne shift
	mov di, ax
	mov al, byte ptr cs:[offset no_shifted_ascii - 1 + di]
	jmp return
shift:
	
	mov ah, 0h
	mov di, ax
	mov al, byte ptr cs:[offset shifted_ascii - 1 + di]

return:
	pop di
	ret
	endp
.data
no_shifted_ascii: 	db ' 1234567890-+  qwertyuiop[]  asdfghjkl;"` \zxcvbnm,./ *               789 456 1230.'
shifted_ascii:		db ' !@#$%^&*()_=  QWERTYUIOP{}  ASDFGHJKL:', 27h,'~ |ZXCVBNM<>?                 789 456 1230.'

end	start


