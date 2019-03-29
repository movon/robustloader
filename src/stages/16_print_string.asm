; Function to print a string in 16 bits
; Accepts the pointer to the string in bx
16_print_string:
	pusha
	mov ah, 0x0e	; Set the scrolling teletype for printing

16_print_string_loop:
	; Check if reached null terminator
	cmp [bx], byte 0
	je 16_print_string_endloop

	mov al, [bx]
	int 0x10
	inc bx
	jmp 16_print_string_loop

16_print_string_endloop:
	popa
	ret