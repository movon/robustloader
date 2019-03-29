rem Run this file from the robustloader folder.

rem Compile the bootloader
cargo xbuild --target x86_64-bootloader.json --release
cd builder
rem Run the builder that takes the .bootloader section and writes it into an image
cargo run ..\target\x86_64-bootloader\release\robustloader
cd ..
rem Run that image in qemu
"C:\Program Files\qemu\qemu-system-x86_64.exe" builder\target\bootloader.img