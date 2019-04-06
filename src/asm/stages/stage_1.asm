.section .boot-first-stage, "awx"
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

	# Enale a20 line - https://wiki.osdev.org/A20_Line
	call enable_a20

    lea si, ENTER_PROTECTED_MODE_STR
    call print_string_16

    # enter protected mode for better segment registers
    call enter_protected_mode

    # leave protcted mode to load stage 2 from disk
    call leave_protected_mode

	# Load stage 2 code from disk into 0:_rest_of_bootloader_start_addr
	call load_stage2

enter_protected_mode:
	# save old segments
    mov [CURR_DS], ds
    mov [CURR_ES], es
	# disable interrupts
	cli

	# load GDT register with start address of Global Descriptor Table
    lgdt [gdt32info]

	# set PE (Protection Enable) bit in CR0 (Control Register 0)
	mov eax, cr0
	or al, 1       
	mov cr0, eax

	# Set bx to equal to dataseg offset in gdt32 struct
	lea bx, datadesc
	lea ax, gdt32
	sub bx, ax
    mov ds, bx # set data segment
    mov es, bx # set extra segment

    ret

leave_protected_mode:

    # Leave protected mode
    and al, 0xfe    # clear protected mode bit
    mov cr0, eax

	mov es, [CURR_ES]
	mov ds, [CURR_DS]
	sti

	ret

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
	# Load the rest of the bootloader from boot drive into es:bx

    # check_int13h_extensions
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc no_int13h_extensions

    # load_rest_of_bootloader_from_disk
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    lea eax, _rest_of_bootloader_start_addr

    # start of memory buffer
    mov [DAP_BUFFER_ADDR], ax

    # number of disk blocks to load
    lea ebx, _kernel_info_block_end
    sub ebx, eax # end - start
    shr ebx, 9 # divide by 512 (block size)
    mov [DAP_BLOCKS], bx

    # number of start block
    lea ebx, _start
    sub eax, ebx
    shr eax, 9 # divide by 512 (block size)
    mov [DAP_START_LBA], eax


    call read_disk_16
    # jump_to_second_stage
    lea eax, stage_2
    jmp eax

no_int13h_extensions:
    lea si, no_int13h_extensions_str
    jmp real_mode_error

real_mode_error:
    call print_string_16
    jmp hang

hang:
    jmp hang

.include "src/asm/utils/16_print_string.asm"
.include "src/asm/utils/16_read_disk.asm"
.include "src/asm/utils/16_print_hex.asm"

# Strings are short because we can't fit them in 512 bytes
ENTER_PROTECTED_MODE_STR:	.asciz 	"32 bit Mode!\r\n"
no_int13h_extensions_str: 	.asciz 	"No int13h!\r\n"

BOOT_DRIVE:					.byte	0
CURR_ES:					.word	0
CURR_DS:					.word	0

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