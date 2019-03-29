extern crate xmas_elf;

use std::fs::File;
use std::io::Read;

fn read_elf<'a>(path: &str) -> &'a xmas_elf::ElfFile<'a> {
    let mut elf_bytes:  Vec<u8>  = Vec::new();
    File::open(path).and_then(|mut f| f.read_to_end(&mut elf_bytes)).expect("Failed to read file");
    let elf_file = xmas_elf::ElfFile::new(&elf_bytes).expect("Failed to parse ELF");
    &elf_file
}

fn main() {
	let elf = read_elf("C:\\dev\\robustloader\\target\\x86_64-bootloader\\release\\robustloader");
    println!("Elf: {:#?}", elf);
}