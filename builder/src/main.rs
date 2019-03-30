extern crate xmas_elf;

use std::fs::{File, OpenOptions};
use std::{
    io::{self, Read, Write},
    path::Path,
    process,
};
use xmas_elf::ElfFile;
use std::env;
use byteorder::{ByteOrder, LittleEndian};

const BLOCK_SIZE: usize = 512;
type KernelInfoBlock = [u8; BLOCK_SIZE];

const BOOTLOADER_SECTION: &str = ".bootloader";
const IMAGE_FILENAME: &str = "target/bootloader.img";


fn read_file_bytes(path: &str) -> Vec<u8> {
    let mut bytes = Vec::new();
    File::open(path).and_then(|mut f| f.read_to_end( &mut bytes)).expect(&format!("Failed to read file {}", path));
    bytes
}

fn parse_elf(bytes: &Vec<u8>) -> ElfFile {
    let elf_file: ElfFile = ElfFile::new(bytes).expect("Failed to parse ELF!");
    elf_file
}

fn write_section_to_file(elf_file: &ElfFile, section_name: &str, file: &mut File) {
    let section = elf_file.find_section_by_name(section_name).expect("Could not find section");
    let bootloader_bytes = section.raw_data(&elf_file);
    println!("length of bootloader_bytes: {}", bootloader_bytes.len());
    file.write_all(&bootloader_bytes).expect("Failed to write data to output file");
}

fn create_kernel_info_block(kernel_size: u64, maybe_package_size: Option<u64>) -> KernelInfoBlock {
    let kernel_size = if kernel_size <= u64::from(u32::max_value()) {
        kernel_size as u32
    } else {
        panic!("Kernel can't be loaded by BIOS bootloader because is too big")
    };

    let package_size = if let Some(size) = maybe_package_size {
        if size <= u64::from(u32::max_value()) {
            size as u32
        } else {
            panic!("Package can't be loaded by BIOS bootloader because is too big")
        }
    } else {
        0
    };

    let mut kernel_info_block = [0u8; BLOCK_SIZE];
    LittleEndian::write_u32(&mut kernel_info_block[0..4], kernel_size);
    LittleEndian::write_u32(&mut kernel_info_block[8..12], package_size);

    kernel_info_block
}


fn write_kernel_info_to_file(kernel_path: &str, file: &mut File) {
    let kernel_path = Path::new(&kernel_path);
    let kernel_file = match File::open(kernel_path) {
        Ok(file) => file,
        Err(err) => {
            writeln!(
                io::stderr(),
                "Failed to open kernel at {:?}: {}",
                kernel_path,
                err
            )
            .expect("Failed to write to stderr");
            process::exit(1);
        }
    };
    let kernel_size = kernel_file
        .metadata()
        .map(|m| m.len())
        .unwrap_or_else(|err| {
            writeln!(io::stderr(), "Failed to read size of kernel: {}", err)
                .expect("Failed to write to stderr");
            process::exit(1);
        });
    let kernel_info_block = create_kernel_info_block(kernel_size, None);
    file.write_all(&kernel_info_block).expect("could not write kernel info block!");
}
fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        panic!("Usage: {} <bootloader elf file path> <kernel elf file path>", &args[0]);
    }

    let elf_file_path = &args[1];
    let kernel_path = &args[2];

    println!("Reading ELF file {}", elf_file_path);
    let elf_bytes = read_file_bytes(elf_file_path);
    println!("Parsing ELF");
	let elf = parse_elf(&elf_bytes);

    let mut file = OpenOptions::new().write(true).append(false).create(true).open(IMAGE_FILENAME).expect(&format!("Failed to create file {}", IMAGE_FILENAME));
    println!("Writing the {} section to file {}", BOOTLOADER_SECTION, IMAGE_FILENAME);
    write_section_to_file(&elf, BOOTLOADER_SECTION, &mut file);
    println!("Succesfully wrote the {} section to file {}!", BOOTLOADER_SECTION, IMAGE_FILENAME);
    write_kernel_info_to_file(kernel_path, &mut file);
}