#!/usr/bin/env bash

temp_dir=$(mktemp -d);                  # Temporary files directory
mcpu='arm926ej-s';                      # ARM9 CPU for use with versatilepb QEMU machine
inputfile="$1"
inputfile_nodir=$(basename "$inputfile")
inputfile_base="${inputfile_nodir%.*}"
inputfile_ext="${inputfile_nodir##*.}"
file_linker='linker.ld'
file_bootstrap='bootstrap.s'
file_svc_handler='svc_handler.c'

if [ -z "$inputfile" ]; then
    echo 'Please supply input source code file.'
    exit 1
fi

case "$inputfile_ext" in
    c)
        arm-none-eabi-gcc -c -g -mcpu="$mcpu" "$inputfile" -o "$temp_dir/input.o" || \
        ( echo "Could not compile input file '$inputfile'" 1>&2; false ) || exit 2
        ;;
    s)
        arm-none-eabi-as --warn --fatal-warnings -mcpu="$mcpu" "$inputfile" -o "$temp_dir/input.o" || \
        ( echo "Could not assemble input file '$inputfile'" 1>&2; false ) || exit 2
        ;;
    *)
        echo "Unrecognised source code file extension '.$inputfile_ext'" >&2
        exit 3
esac

arm-none-eabi-as --warn --fatal-warnings -mcpu="$mcpu" "$file_bootstrap" -o "$temp_dir/bootstrap.o" && \
arm-none-eabi-gcc -c -Wall -O2 -nostdlib -nostartfiles -ffreestanding -mcpu="$mcpu" "$file_svc_handler" -o "$temp_dir/svc_handler.o" && \
arm-none-eabi-ld "$temp_dir/bootstrap.o" "$temp_dir/svc_handler.o" "$temp_dir/input.o" -T "$file_linker" -o "$temp_dir/$inputfile_base.elf" && \
arm-none-eabi-objdump -D "$temp_dir/$inputfile_base.elf" > "$temp_dir/$inputfile_base.list" && \
arm-none-eabi-objcopy "$temp_dir/$inputfile_base.elf" -O binary "$temp_dir/$inputfile_base.bin" && \
echo "Compilation Successful: output/$inputfile_base.bin" || \
( echo "Compilation Failed." 1>&2; false ) || exit 4

mv "$temp_dir/$inputfile_base.list" "output/$inputfile_base.list"
mv "$temp_dir/$inputfile_base.bin" "output/$inputfile_base.bin"

# Cleanup
rm -r "$temp_dir"