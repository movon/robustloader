.section .boot, "awx"
.intel_syntax noprefix
.code16

# This stage sets the target operating mode, loads the kernel from disk,
# creates an e820 memory map, enters protected mode, and jumps to the
# third stage.



stage_2:
    lea si, second_stage_start_str
    call print_string_16

    lea si, return_32_bit_mode_str
    call print_string_16

    call get_system_memory_map
    h:
    	jmp h

get_system_memory_map:
	xor bp, bp
	xor eax, eax
	mov ax, 0xe820 		# Get system memory map
	mov edx, 0x534D4150 # Magic
	mov ecx, 24			# Sizeof SYSTEM_MEMORY_MAP_ENTRY
	xor ebx, ebx
	lea di, SYSTEM_MEMORY_MAP_ENTRY

	int 0x15
	jc memory_map_error 	# Carry on first call means function not supported

	cmp eax, 0x534D4150
	jnz memory_map_error 	# On a good call eax must hold this value

	cmp ebx, 0
	jz memory_map_error 	# On first call if ebx is 0 the list is worthless

system_memory_map_after_int:
	inc bp
	xor eax, eax
	mov ax, 0xe820
	mov edx, 0x534D4150 	# Some BIOS destroy this register...
	add di, 24 				
	mov ecx, 24
	# Preserve ebx for next call

	int 0x15
	jc system_memory_map_end # On subsequent calls this means we reached end of list

	cmp ebx, 0
	jz system_memory_map_end

	jmp system_memory_map_after_int

system_memory_map_end:
	inc bp
	mov [SYSTEM_MEMORY_MAP_ENTRY_COUNT], bp
	clc
	ret

memory_map_error:
	call leave_protected_mode
	lea si, memory_map_error_str
	call print_string_16
	xor dx, dx
	mov ah, dl
	call print_hex_16
memory_map_hang:
	jmp memory_map_hang


second_stage_start_str: .asciz "Booting (second stage)...\r\n"
return_32_bit_mode_str:	.asciz "Returning to protected mode!\r\n"
memory_map_error_str:	.asciz "Error getting memory map, Code: "

SYSTEM_MEMORY_MAP_ENTRY_COUNT:
	.word 0
SYSTEM_MEMORY_MAP_ENTRY:
	.quad 0		# Base address
	.quad 0		# Length of region. If it's 0 ignore the this entry
	.word 0		# The type of region - 1 for usable RAM
	.word 0		# Extended attribute field. Unused for us kept for alignment
