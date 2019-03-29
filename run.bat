cargo xbuild --target x86_64-bootloader.json
cd builder
cargo run ..\target\x86_64-bootloader\debug\robustloader
cd ..
"C:\Program Files\qemu\qemu-system-x86_64.exe" builder\target\bootloader.img