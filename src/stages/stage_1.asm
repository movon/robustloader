.section .boot-first-stage
.global _start
.intel_syntax noprefix
.code16

_start:
	
	mov ax, 0


.org 510

.word 0xaa55