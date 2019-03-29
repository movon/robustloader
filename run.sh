cargo xbuild --target ./x86_64-bootloader.json
cd ./builder
cargo run ../target/x86_64-bootloader/debug/robustloader
cd ../
qemu-system-x86_64 ./builder/target/bootloader.img
