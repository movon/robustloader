extern crate xmas_elf;

use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use xmas_elf::ElfFile;

const BOOTLOADER_SECTION: &str = ".bootloader";
const IMAGE_FILENAME: &str = "target/bootloader.img";


fn read_file_bytes(path: &str) -> Vec<u8> {
    let mut elf_bytes   = Vec::new();
    File::open(path).and_then(|mut f| f.read_to_end( &mut elf_bytes)).expect("Failed to read file");
    elf_bytes
}

fn read_elf(bytes: &Vec<u8>) -> ElfFile {
    let elf_file: ElfFile = ElfFile::new(bytes).expect("Failed to parse ELF");
    elf_file
}

fn write_section_to_file(elf_file: &ElfFile, section_name: &str, filename: &str) {
    let section = elf_file.find_section_by_name(section_name).expect("Could not find section");
    let bootloader_bytes = section.raw_data(&elf_file);
    let mut file = OpenOptions::new()
        .write(true)
        .append(true)
        .create(true)
        .open(filename)
        .expect("Failed to open file");
    file.write(&bootloader_bytes).expect("Failed to write data to file");
}

fn main() {
    let elf_bytes = read_file_bytes("C:\\dev\\robustloader\\target\\x86_64-bootloader\\release\\robustloader");
	let elf = read_elf(&elf_bytes);

    write_section_to_file(&elf, BOOTLOADER_SECTION, IMAGE_FILENAME);
    println!("Elf: {:#?}", elf);
}