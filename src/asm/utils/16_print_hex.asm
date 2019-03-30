.code16
							# Use dx as the parameter value to print
print_hex_16:
	mov bx, 5 				# start writing at the end of our string
print_hex_loop_16:
	mov al, dl
	and al, 0xf 			# Take the last byte
	add al, '0' 			# Add to make ascii value
	cmp al, '9'
	jbe less_then_a
	add al, 7
less_then_a:
	mov [HEX_OUT + bx], al 	# Write the byte
	dec bx 					# Because we are writing from the end
	cmp bx, 1 				# check if we filled all 4 bytes
	je end_print_hex_16
	ror dx, 4
	jmp print_hex_loop_16

end_print_hex_16:
	lea si, HEX_OUT
	call print_string_16
	ret

HEX_OUT: .asciz "0x0000"