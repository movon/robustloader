extern crate xmas_elf;

use std::fs::File;
use std::io::Read;
use xmas_elf::ElfFile;

fn read_file_bytes(path: &str) -> Vec<u8> {
    let mut elf_bytes   = Vec::new();
    File::open(path).and_then(|mut f| f.read_to_end( &mut elf_bytes)).expect("Failed to read file");
    elf_bytes
}

fn read_elf(bytes: &Vec<u8>) -> ElfFile {
    let elf_file: ElfFile = ElfFile::new(bytes).expect("Failed to parse ELF");
    elf_file
}

fn main() {
    let elf_bytes = read_file_bytes("C:\\dev\\robustloader\\target\\x86_64-bootloader\\release\\robustloader");
	let elf = read_elf(&elf_bytes);
    println!("Elf: {:#?}", elf);
}