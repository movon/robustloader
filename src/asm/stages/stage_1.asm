.section .boot-first-stage
.global _start
.intel_syntax noprefix
.code16

_start:
	# clear all registers and store the boot drive
	mov [BOOT_DRIVE], dl # The BIOS stores the boot drive in dl
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx

	# Setup the stack to be at _stack_end and make
	# direction of memory processing lowest-to-highest
	cld
	lea sp, _stack_end
	mov bp, sp

	lea si, REAL_MODE_MSG
	call print_string_16

	# Load the kernel from boot drive into es:bx. In our case it is 0:0x1000
	lea si, READ_KERNEL_MSG
	call print_string_16

	mov dl, [BOOT_DRIVE]
	xor ax, ax
	mov es, ax
	mov bx, 0x1000
	call read_disk_16

here_loop:
	jmp here_loop



.include "src/asm/utils/16_print_string.asm"
.include "src/asm/utils/16_read_disk.asm"
.include "src/asm/utils/16_print_hex.asm"

BOOT_DRIVE:			.byte	0
REAL_MODE_MSG:		.asciz 	"Started in 16 bit mode!"
READ_KERNEL_MSG:	.asciz	"Started reading kernel!"

.org 510

.word 0xaa55