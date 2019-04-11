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
    static mmap_ent: usize;
    static _memory_map: usize;
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
    write!(printer::Printer, "RUNNING FROM RUST YEAH  :D :))))))) !!!!@#!@#!@#!@#!@#!@#").unwrap();
    loop {}
}