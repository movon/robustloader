use goblin::{error, Object};
use std::path::Path;
use std::env;
use std::fs::File;
use std::io::Read;

fn run () -> error::Result<()> {
    for (i, arg) in env::args().enumerate() {
		println!("{} {}", i, arg);
        if i == 1 {
            let path = Path::new(arg.as_str());
            let mut fd = File::open(path)?;
            let mut buffer = Vec::new();
            fd.read_to_end(&mut buffer)?;
            println!("Reading binary");
            match Object::parse(&buffer)? {
                Object::Elf(elf) => {
                    println!("elf: {:#?}", &elf);
                },
                Object::PE(pe) => {
                    println!("pe: {:#?}", &pe);
           			println!("PE: {}", (&pe));
                },
                Object::Mach(mach) => {
                    println!("mach: {:#?}", &mach);
                },
                Object::Archive(archive) => {
                    println!("archive: {:#?}", &archive);
                },
                Object::Unknown(magic) => { println!("unknown magic: {:#x}", magic) }
            }
        }
    }
    Ok(())
}

fn main() {
	run().expect("Error in parsing");
	println!("Hello world");
}