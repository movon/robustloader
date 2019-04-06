ENTRY(_start)

SECTIONS {
    . = 0x500;
    /* buffer for loading kernel header */
    _kernel_buffer = .;
    . += 512;
    /* page tables */
    . = ALIGN(0x1000);
    __page_table_start = .;
    _pmlt4 = .;  /* Allocate a buffer for the page map level 4 table */   
    . += 0x1000;
    _pdpt = .;  /* Allocate a buffer for the page directory table pointer */
    . += 0x1000;
    _pdt = .;   /* Allocate a buffer for the page directory table */
    . += 0x1000;
    _pt = .;    /* Allocate a buffer for the page table */
    . += 0x1000;
    __page_table_end = .;
    __bootloader_start = .;
    _e820_memory_map_start = .;
    _e820_memory_map_num_entries = .;
    . += 4;
    _e820_memory_map_entries = .;
    . += 0x1000; /* Make a buffer for the entries. It contains 512 entries of size 8 bytes */
    _e820_memory_map_end = .;
    _stack_start = .;
    . = 0x7c00;
    _stack_end = .;

    .bootloader :
    {
        /* first stage */
        *(.boot-first-stage)

        /* rest of bootloader */
        _rest_of_bootloader_start_addr = .;
        *(.boot)
        *(.text .text.*)
        *(.rodata .rodata.*)
        *(.data .data.*)
        *(.got)
        . = ALIGN(512);
        _rest_of_bootloader_end_addr = .;
    }

    _kernel_info_block_start = .;
    _kib_kernel_size = .;
    . += 512; /* kernel info block */
    _kernel_info_block_end = .;

    __bootloader_end = .;
    _kernel_start_addr = .;
}
