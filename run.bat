rem Run this file from the robustloader folder.

rem Delete cache in order to build again (fix for assembly files change)
rem NUL is equivalent to /dev/null
DEL /S /Q target\x86_64-bootloader > NUL
rem Compile the bootloader
cargo xbuild --target x86_64-bootloader.json || exit /b
cd builder || exit /b
rem Run the builder that takes the .bootloader section and writes it into an image
rem TODO: remove this non existent kernel.elf and replace it with the real kernel.elf
cargo run ..\target\x86_64-bootloader\debug\robustloader ..\kernel.elf || exit /b
cd .. || exit /b
rem Run that image in qemu
"C:\Program Files\qemu\qemu-system-x86_64.exe" builder\target\bootloader.img