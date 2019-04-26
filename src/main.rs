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
use core::{slice, fmt};

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
    write!(printer::Printer, "RUNNING FROM RUST YEAH  :D :))))))) !!!!").unwrap();
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

// In order to use the `{}` marker, the trait `fmt::Display` must be implemented
// manually for the type.
impl fmt::Display for MemoryBlock {
    // This trait requires `fmt` with this exact signature.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        // Write strictly the first element into the supplied output
        // stream: `f`. Returns `fmt::Result` which indicates whether the
        // operation succeeded or failed. Note that `write!` uses syntax which
        // is very similar to `println!`.
        write!(f, "base_address: 0x{:x}\n", self.base_address).unwrap();
        write!(f, "region_length: 0x{:x}\n", self.region_length).unwrap();
        write!(f, "extended_attribute: 0x{:x}\n", self.extended_attribute).unwrap();
        write!(f, "region_type: 0x{:x}\n", self.region_type).unwrap();
        Ok(())
    }
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
    let num_entries :usize = unsafe { _e820_memory_map_num_entries  as usize};
    for i in 0 .. num_entries {
        write!(printer::Printer, " -- memory_entry {}: {}\n\n",i, memory_array[i]);
    }
}