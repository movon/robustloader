.section .boot, "awx"
.intel_syntax noprefix
.code32

# This stage checks for 64 bit, Sets up paging and enters long mode

stage_3:
	call check_cpuid_support
	h:
		jmp h


check_cpuid_support:
	push ebx
	pushfd 					# Save the flags

	pushfd 		
	pop eax 				# Store the flag values in eax
	mov ebx, eax

	xor eax, 1 << 21 		# Flip the id bit

	push eax				# Push the modified flags
	popfd 		

	pushfd
	pop eax					# Store the modified flags in eax again

	xor eax, ebx			# Compare the modified and the original flags
	jz cpuid_not_supported	# If the bit wasn't set, cpuid is not supported

	popfd 					# Restore state
	pop ebx
	ret

cpuid_not_supported:
	lea esi, cpuid_not_supported_str 	# Look at top of screen with print string 32
	call print_string_32
	hlt

check_available_long_mode:

.include "src/asm/utils/32_print_string.asm"

cpuid_not_supported_str:	.asciz	"cpuid is not supported, no way to check long mode"


	
