use core::fmt::{Result, Write};
use core::slice;
use core::sync::atomic::{AtomicUsize, Ordering};

const VGA_BUFFER: *mut u8 = 0xb8000 as *mut _;
const MAX_ROWS: usize = 25;
const MAX_COLS: usize = 80;
const SCREEN_SIZE: usize = MAX_ROWS * MAX_COLS;
const WHITE_ON_RED: u8 = 0x4f;
const VGA_CELL_SIZE: usize = 2;

pub static CURRENT_OFFSET: AtomicUsize = AtomicUsize::new(160);

pub struct Printer;

impl Printer {
    pub fn clear_screen(&mut self) {
        let vga_buffer = Self::vga_buffer();
        for byte in vga_buffer {
            *byte = 0;
        }
        CURRENT_OFFSET.store(0, Ordering::Relaxed);
    }

    fn vga_buffer() -> &'static mut [u8] {
        unsafe { slice::from_raw_parts_mut(VGA_BUFFER, SCREEN_SIZE * VGA_CELL_SIZE) }
    }
}

impl Write for Printer {
    fn write_str(&mut self, s: &str) -> Result {
        let vga_buffer = Self::vga_buffer();
        for mut byte in s.bytes() {
            // byte should be mutable because we don't want to print specials chars
            let index = match byte as char {
                '\n'    =>  { byte = ' ' as u8;
                            CURRENT_OFFSET.fetch_add((CURRENT_OFFSET.load(Ordering::Relaxed) % MAX_ROWS) * VGA_CELL_SIZE, Ordering::Relaxed) 
                            },
                '\t'    =>  { byte = ' ' as u8;
                            CURRENT_OFFSET.fetch_add(VGA_CELL_SIZE * 4, Ordering::Relaxed)
                            },
                _       =>  CURRENT_OFFSET.fetch_add(VGA_CELL_SIZE, Ordering::Relaxed),    
            };
            // let index = CURRENT_OFFSET.fetch_add(VGA_CELL_SIZE, Ordering::Relaxed);
            vga_buffer[index] = byte;
            vga_buffer[index + 1] = WHITE_ON_RED;
        }

        Ok(())
    }
}
