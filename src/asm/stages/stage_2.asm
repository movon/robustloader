.section .boot, "awx"
.intel_syntax noprefix
.code16

# This stage sets the target operating mode, loads the kernel from disk,
# creates an e820 memory map, enters protected mode, and jumps to the
# third stage.

stage_2:
    lea si, second_stage_start_str
    call print_string_16

set_target_operating_mode:
    # Some BIOSs assume the processor will only operate in Legacy Mode. We change the Target
    # Operating Mode to "Long Mode Target Only", so the firmware expects each CPU to enter Long Mode
    # once and then stay in it. This allows the firmware to enable mode-specifc optimizations.
    # We save the flags, because CF is set if the callback is not supported (in which case, this is
    # a NOP)
    pushf
    mov ax, 0xec00
    mov bl, 0x2
    int 0x15
    popf



    call get_system_memory_map

    lea si, return_32_bit_mode_str
    call print_string_16

    call enter_protected_mode 	# This function only sets the data segmentss
    push 0x8					# Push the code segment in the gdt
    lea eax, [stage_3] 			# Set the return address
    push eax					# Push the return address
    retf						# ref first pops the return address to eip and then pops again into cs
    
get_system_memory_map:
	xor bp, bp
	xor eax, eax
	mov ax, 0xe820 		# Get system memory map
	mov edx, 0x534D4150 # Magic
	mov ecx, 24			# Sizeof e820_memory_map_entry
	xor ebx, ebx
	lea di, _e820_memory_map_entries

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
	add di, 24 				# Sizeof e820_memory_map_entry
	mov ecx, 24
	# Preserve ebx for next call

	int 0x15
	jc system_memory_map_end # On subsequent calls this means we reached end of list

	cmp ebx, 0
	jz system_memory_map_end

	jmp system_memory_map_after_int

system_memory_map_end:
	inc bp
	mov _e820_memory_map_num_entries, bp
	clc 					# Clear the carry flag because we fail in the last call
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

# DOCUMENTATION:
#e820_memory_map_entry:
#	.quad 0		# Base address
#	.quad 0		# Length of region. If it's 0 ignore the this entry
#	.word 0		# The type of region - 1 for usable RAM
#	.word 0		# Extended attribute field. Unused for us kept for alignment

