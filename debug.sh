rm ./builder/target/bootloader.img
rm -r target/x86_64-bootloader
cargo xbuild --target ./x86_64-bootloader.json
cd ./builder && cargo run ../target/x86_64-bootloader/debug/robustloader ../kernel.elf # TODO: remove this example non existent kernel.elf
cd ../ && qemu-system-x86_64 ./builder/target/bootloader.img &
gdb -ex "target remote localhost:1234" -ex "symbol-file ./target/x86_64-bootloader/debug/robustloader"
