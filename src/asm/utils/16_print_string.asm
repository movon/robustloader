.code16
# Function to print a string in 16 bits
# Accepts the pointer to the string in si
print_string_16:
	push ax
	push si
	push cx
	mov ah, 0x0e	# Set the scrolling teletype for printing

print_string_loop_16:
	# Check if reached null terminator
	mov cl, 0
	cmp [si], cl
	je print_string_endloop_16

	mov al, [si]
	int 0x10
	inc si
	jmp print_string_loop_16

print_string_endloop_16:
	pop cx
	pop si
	pop ax
	ret
