.section .boot, "awx"
.intel_syntax noprefix
.code16

# This stage sets the target operating mode, loads the kernel from disk,
# creates an e820 memory map, enters protected mode, and jumps to the
# third stage.



stage_2:
    lea si, second_stage_start_str
    call print_string_16
    hang2:
    jmp hang2


second_stage_start_str: .asciz "Booting (second stage)...\r\n"

