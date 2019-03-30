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

DAP:	
	.byte 0x10  # Size of dap
	.byte 0x0 	# Unused
DAP_BLOCKS:
	.word 0		# Number of sectors
DAP_BUFFER_ADDR:
	.word 0 	# Offset to memory buffer
DAP_BUFFER_SEG:
	.word 0 	# Segment of memory buffer
DAP_START_LBA:
	.quad 0		# Start logical block address