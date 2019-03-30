.code16
# Uses DAP to read from the disk
read_disk_16:
	mov ah, 0x42
	mov dl, [BOOT_DRIVE]
	lea si, DAP
	int 0x13
	jc disk_error
done:
	lea si, DISK_SUCCESS_MESSAGE
	call print_string_16
	ret			
disk_error:				# Print the return code of interrupt
	lea si, DISK_ERROR_MESSAGE
	call print_string_16
	xor dx, dx
	mov dl, ah
	call print_hex_16 	# See http://www.ctyme.com/intr/rb-0606.htm#Table234 for return code meaning
	hlt

DISK_ERROR_MESSAGE:		.asciz "Disk error message! Return Code: "
DISK_SUCCESS_MESSAGE:	.asciz "Reading disk succeeded!\r\n"

SECTORS:			.byte 0