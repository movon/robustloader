rm ./builder/target/bootloader.img
rm -r target/x86_64-bootloader
cargo xbuild --target ./x86_64-bootloader.json --release
cd ./builder && cargo run ../target/x86_64-bootloader/release/robustloader ../kernel.elf # TODO: remove this example non existent kernel.elf
cd ../ && qemu-system-x86_64 ./builder/target/bootloader.img
