// Don't use standard library because it won't exist on our OS
#![no_std]
// Don't create an entry point - we will make it ourselves
#![no_main]
// Include experimnental assembly feature
#![feature(asm)]
// Include global assembly feature which is subject to change
#![feature(global_asm)]
#![feature(lang_items)]
#![feature(nll)]
#![feature(const_fn)]
#![feature(step_trait)]

use core::panic::PanicInfo;
use core::fmt::Write;
use core::mem::size_of;
use core::slice;

global_asm!(include_str!("asm/stages/stage_1.asm"));
global_asm!(include_str!("asm/stages/stage_2.asm"));
global_asm!(include_str!("asm/stages/stage_3.asm"));

// Panic implementation is required because no standard lib
// Diverging function marked by "never" type, never returns
#[panic_handler]
#[no_mangle]
fn panic(_info: &PanicInfo) -> ! {
    // On panic - halt the system
    loop {}
}


extern "C" {
	static _e820_memory_map_num_entries: u32;
	static _e820_memory_map_entries: usize;
    static _kib_kernel_size: usize;
    static __page_table_start: usize;
    static __page_table_end: usize;
    static __bootloader_start: usize;
    static __bootloader_end: usize;
}

mod printer;

/*
    Entry point with linux convention
    Normally, the compiler generates them for us and calls our main() function,
    but we don't use stdlib and the main wrapping, so we need to make them by ourselves
*/
#[no_mangle] // don't mangle the name of this function
pub unsafe extern "C" fn stage_4() -> ! {
    // this function is the entry point, since the linker looks for a function
    // named `_start` by default
    // set stack segment
    asm!("mov bx, 0x00
          mov ss, bx" ::: "bx" : "intel");
    printer::Printer.clear_screen();
    write!(printer::Printer, "RUNNING FROM RUST YEAH  :D :))))))) !!!!\t@#!@#!@#!@#!@#!@#\n\n\n\n").unwrap();
	write!(printer::Printer, "kernel size: 0x{:x}\n", _kib_kernel_size).unwrap();
	write!(printer::Printer, "0x{:x}\n", _e820_memory_map_num_entries).unwrap();

    parse_mmap();

    loop {}
}

struct MemoryBlock {
	base_address: u64,
	region_length: u64,
    region_type: u32,
	extended_attribute: u32,
}


enum MemoryBlockType {
	Usable(MemoryBlock),
	Reserved(MemoryBlock),
    ACPIreclaimable(MemoryBlock),
    APCInvs(MemoryBlock),
    BadMemory(MemoryBlock),
}

fn parse_mmap() {
	let memory_map: *const MemoryBlock = unsafe { _e820_memory_map_entries as *const _ };
    let memory_array = unsafe { slice::from_raw_parts(memory_map, (_e820_memory_map_num_entries as usize) * size_of::<MemoryBlockType>()) };
    let num_entries = unsafe { _e820_memory_map_num_entries };
    let mut index = 0;
    for i in 0 .. num_entries {
        let base_address: u64 = unsafe { (*memory_map).extended_attribute as u64 };
        write!(printer::Printer, "0x{:x}", base_address).unwrap();
    }
}