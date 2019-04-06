.section .boot, "awx"
.intel_syntax noprefix
.code32


# This stage checks for 64 bit, Sets up paging and enters long mode

stage_3:
	call check_cpuid_support
	call check_long_mode_support
	call setup_pae_paging
	call enable_paging

	lea si, paging_enabled_str
	call print_string_32
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

check_long_mode_support:
	push edx

	mov eax, 0x80000000				# Check if extendeded cpuid functions are available
	cpuid 							# which we need to check if long mode is supported
	cmp eax, 0x80000001				# It returns the highest function
	jb long_mode_not_supported

	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29 				# Check if long mode is supported
	jz long_mode_not_supported

	pop edx
	ret

long_mode_not_supported:
	lea esi, long_mode_not_supported_str
	call print_string_32
	hlt

setup_pae_paging:
	# This function sets the first entry in _pmlt4 to point to the address 
	# of the first entry in _pdpt with rw + present bit
	# Then it sets the first entry in _pdpt to point to the address of _pdt
	# with rw + present
	# At last, it sets every entry(512 entries) in _pdt to rw + present + huge which
	# means every entry is a page of 2mb which identity allocates the first gigabyte 
	push ecx
	mov ecx, 0

	lea eax, _pdpt		# Load the adress of the page table diretory pointer into eax
	or eax, 0x3 		# present + read write page attributes
	mov [_pmlt4], eax	# map the first entry in the page map level 4 table to the adress
						# of the page table directory pointer with rw and present attributes
	lea eax, _pdt		
	or eax, 0x3
	mov [_pdpt], eax

map_pdt_table:
	mov eax, 0x200000	# 2mb
	mul ecx 			# multiply eax by the current offset
	or eax, 0b10000011  # mark the entry with present + readwrite + huge
	mov [_pdt + ecx * 8], eax # sizeof _pdt entry is 8 and there are 512 entries

	inc ecx
	cmp ecx, 512
	jne map_pdt_table

	pop ecx
	ret


enable_paging:
	# This function enables paging by writing the address of _pmlt4 to cr3
	# setting the pae flag in cr4
	# setting the long mode bit in EFER
	# and setting the paging bit in cr0

	push ecx

	lea eax, _pmlt4
	mov cr3, eax

	mov eax, cr4
	or eax, 1 << 5 	# Enable the PAE flag in cr4 (The physical address extesion)
	mov cr4, eax

	mov ecx, 0xc0000080 # Set the long mode bit in EFER MSR (Extended Feature Enable Register)
	rdmsr 				# Read model specific register specified in ecx into edx:eax
	or eax, 1 << 8		# Enable long mode bit
	wrmsr 				# Write into model specific register

	mov eax, cr0	 	# Enable paging 
	or eax, 1 << 31
	mov cr0, eax

	pop ecx
	ret


.include "src/asm/utils/32_print_string.asm"

cpuid_not_supported_str:		.asciz	"cpuid is not supported, no way to check long mode"
long_mode_not_supported_str:	.asciz	"long mode is not supported!"
paging_enabled_str:				.asciz  "Paging is officaly enabled!"


	
