// Don't use standard library because it won't exist on our OS
#![no_std]
// Don't create an entry point - we will make it ourselves
#![no_main]
// Include experimnental assembly feature
#![feature(asm)]
// Include global assembly feature which is subject to change
#![feature(global_asm)]
use core::panic::PanicInfo;

global_asm!(include_str!("asm/stages/stage_1.asm"));

// Panic implementation is required because no standard lib
// Diverging function marked by "never" type, never returns
#[panic_handler]
#[no_mangle]
fn panic(_info: &PanicInfo) -> ! {
    // On panic - halt the system
    loop {}
}

/*
    Entry point with linux convention
    Normally, the compiler generates them for us and calls our main() function,
    but we don't use stdlib and the main wrapping, so we need to make them by ourselves
*/
#[no_mangle] // don't mangle the name of this function
pub extern "C" fn main_loop() -> ! {
    // this function is the entry point, since the linker looks for a function
    // named `_start` by default
    loop {}
}