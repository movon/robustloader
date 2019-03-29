; Function to print a string in 16 bits
; Accepts the pointer to the string in si
16_print_string:
	pusha
	mov ah, 0x0e	; Set the scrolling teletype for printing

16_print_string_loop:
	; Check if reached null terminator
	cmp [si], byte 0
	je 16_print_string_endloop

	mov bl, GREEN_COLOR

	mov al, [si]
	int 0x10
	inc si
	jmp 16_print_string_loop

16_print_string_endloop:
	popa
	ret

GREEN_COLOR		db	0x2