extern crate xmas_elf;

use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use xmas_elf::ElfFile;
use std::env;

const BOOTLOADER_SECTION: &str = ".bootloader";
const IMAGE_FILENAME: &str = "target/bootloader.img";


fn read_file_bytes(path: &str) -> Vec<u8> {
    let mut bytes = Vec::new();
    File::open(path).and_then(|mut f| f.read_to_end( &mut bytes)).expect("Failed to read file");
    bytes
}

fn parse_elf(bytes: &Vec<u8>) -> ElfFile {
    let elf_file: ElfFile = ElfFile::new(bytes).expect("Failed to parse ELF");
    elf_file
}

fn write_section_to_file(elf_file: &ElfFile, section_name: &str, filename: &str) {
    let section = elf_file.find_section_by_name(section_name).expect("Could not find section");
    let bootloader_bytes = section.raw_data(&elf_file);
    let mut file = OpenOptions::new()
        .write(true)
        .append(false)
        .create(true)
        .open(filename)
        .expect("Failed to create file");
    file.write(&bootloader_bytes).expect("Failed to write data to file");
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        panic!("Usage: {} <bootloader elf file path>", &args[0]);
    }

    let elf_file_path = &args[1];

    let elf_bytes = read_file_bytes(elf_file_path);
	let elf = parse_elf(&elf_bytes);

    write_section_to_file(&elf, BOOTLOADER_SECTION, IMAGE_FILENAME);
    println!("Wrote the {} section to file {}!", BOOTLOADER_SECTION, IMAGE_FILENAME);
}