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

	# Initialize the stack to be at _stack_end and make
	# direction of memory processing lowest-to-highest
	cld
	lea sp, _stack_end
	mov bp, sp

	# Announce real mode :)
	lea si, REAL_MODE_MSG
	call print_string_16


	# Enale a20 line - https://wiki.osdev.org/A20_Line
	call enable_a20

    lea si, ENTER_PROTECTED_MODE_STR
    call print_string_16


enter_protected_mode:
	# Push old segments
    push ds
    push es
	# disable interrupts
	cli
	# load GDT register with start address of Global Descriptor Table
    lgdt [gdt32info]

	# set PE (Protection Enable) bit in CR0 (Control Register 0)
	mov eax, cr0
	or al, 1       
	mov cr0, eax

	jmp protected_mode

protected_mode:
	mov bx, 0x10
    mov ds, bx # set data segment
    mov es, bx # set extra segment

    # Leave protected mode
    and al, 0xfe    # clear protected mode bit
    mov cr0, eax
	# load DS, ES, FS, GS, SS, ESP

unreal_mode:
	pop es
	pop ds
	sti


here_loop:
	jmp here_loop


	# Load stage 2 code from disk into 0:_rest_of_bootloader_start_addr
	call load_stage2


enable_a20:
    # enable A20-Line via IO-Port 92, might not work on all motherboards
    in al, 0x92
    test al, 2
    jnz enable_a20_end
    or al, 2
    and al, 0xFE
    out 0x92, al
enable_a20_end:
	ret


load_stage2:
	# Load the kernel from boot drive into es:bx. In our case it is 0:_kernel_start_addr
	# that is defined in the linker
	lea si, READ_KERNEL_MSG
	call print_string_16

	mov dl, [BOOT_DRIVE]
	mov dh, 0x15
	xor ax, ax
	mov es, ax
	lea bx, _kernel_start_addr
	call read_disk_16
	ret




.include "src/asm/utils/16_print_string.asm"
.include "src/asm/utils/16_read_disk.asm"
.include "src/asm/utils/16_print_hex.asm"

BOOT_DRIVE:			.byte	0
ENTER_PROTECTED_MODE_STR:		.asciz 	"Entering protected mode!\r\n"
REAL_MODE_MSG:		.asciz 	"Started in 16 bit mode!\r\n"
READ_STAGE2_MSG:	.asciz	"Started reading stage 2!\r\n"


gdt32info:
   .word gdt32_end - gdt32 - 1  # last byte in table
   .word gdt32                  # start of table

gdt32:
    # entry 0 is always unused
    .quad 0
codedesc:
    .byte 0xff
    .byte 0xff
    .byte 0
    .byte 0
    .byte 0
    .byte 0x9a
    .byte 0xcf
    .byte 0
datadesc:
    .byte 0xff
    .byte 0xff
    .byte 0
    .byte 0
    .byte 0
    .byte 0x92
    .byte 0xcf
    .byte 0
gdt32_end:

.org 510

.word 0xaa55