.section .boot-first-stage
.global _start
.intel_syntax noprefix
.code16

_start:
	# clear all registers
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx

	# Setup the stack to be at _stack_end and make
	# direction of memory processing lowest-to-highest
	cld
	mov sp, _stack_end
	mov bp, sp

	lea si, REAL_MODE_MSG
	call print_string_16
	here:
	jmp here

.include "src/asm/utils/16_print_string.asm"
.include "src/asm/utils/16_read_disk.asm"

REAL_MODE_MSG:	.asciz 	"Started in 16 bit mode!"

.org 510

.word 0xaa55