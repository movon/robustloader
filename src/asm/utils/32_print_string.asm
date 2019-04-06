.code32
# print a null terminated string pointed by ESI
# define VIDEO_MEMORY 0xb8000. To display a character in text mode, we need to set
# 2 bytes in the correct index in the Video Graphics Array(80x25). 
# First byte is the ascii code  and the second encodes the character attributes. 
# To find the index 0xb8000 + 2 * (row * 80 + col)
# WHITE_ON_BLACK equ 0x0f

print_string_32:
    pusha 
    mov edx, 0xb8000
print_string_32_loop:
    mov al, [esi]               # Store the char at ebx in AL
    mov ah, 0x0f                # Store the attributes in AH

    cmp al, 0                   # Check if we hit the null terminator
    je print_string_32_done

    mov [edx], ax               # Store the char and the attributes at the correct index in the VGA

    add esi, 1                  # Next char in string
    add edx, 2                  # Next cell in VGA

    jmp print_string_32_loop

print_string_32_done:
    popa 
    ret