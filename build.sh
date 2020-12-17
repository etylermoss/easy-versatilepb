#!/usr/bin/env bash

SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
LINKER="$SCRIPT_PATH/src/linker.ld"
BOOTSTRAP="$SCRIPT_PATH/src/bootstrap.s"
SVC_HANDLER="$SCRIPT_PATH/src/svc_handler.c"

temp_dir=$(mktemp -d);                  # Temporary files directory
mcpu='arm926ej-s';                      # ARM9 CPU for use with versatilepb QEMU machine
inputfile="$1"
inputfile_nodir=$(basename "$inputfile")
inputfile_base="${inputfile_nodir%.*}"
inputfile_ext="${inputfile_nodir##*.}"
outputs=${@:2}

function clean_exit {
    rm -r "$temp_dir"
    exit $1
}

# Ensure input file was supplied
if [ -z "$inputfile" ]; then
    echo 'Please supply input source code file.' 1>&2
    clean_exit 1
fi

# Ensure output file(s) were supplied
if [ "$#" -lt 2 ]; then
    echo 'No output file(s) specified.' 1>&2
    clean_exit 2
fi

# Compile/Assemble input file source code
case "$inputfile_ext" in
    c)
        arm-none-eabi-gcc -c -g -mcpu="$mcpu" "$inputfile" -o "$temp_dir/input.o" || \
        ( echo "Could not compile input file '$inputfile'" 1>&2; false ) || clean_exit 3
        ;;
    s)
        arm-none-eabi-as --warn --fatal-warnings -mcpu="$mcpu" "$inputfile" -o "$temp_dir/input.o" || \
        ( echo "Could not assemble input file '$inputfile'" 1>&2; false ) || clean_exit 3
        ;;
    *)
        echo "Unrecognised source code file extension '.$inputfile_ext'" >&2
        clean_exit 4
esac

arm-none-eabi-as --warn --fatal-warnings -mcpu="$mcpu" "$BOOTSTRAP" -o "$temp_dir/bootstrap.o" && \
arm-none-eabi-gcc -c -Wall -O2 -nostdlib -nostartfiles -ffreestanding -mcpu="$mcpu" "$SVC_HANDLER" -o "$temp_dir/svc_handler.o" && \
arm-none-eabi-ld "$temp_dir/bootstrap.o" "$temp_dir/svc_handler.o" "$temp_dir/input.o" -T "$LINKER" -o "$temp_dir/$inputfile_base.elf" && \
arm-none-eabi-objdump -D "$temp_dir/$inputfile_base.elf" > "$temp_dir/$inputfile_base.list" && \
arm-none-eabi-objcopy "$temp_dir/$inputfile_base.elf" -O binary "$temp_dir/$inputfile_base.bin" || \
( echo "Compilation Failed." 1>&2; false ) || clean_exit 5

for o in $outputs
do
    o_nodir=$(basename "$o")
    o_ext="${o_nodir##*.}"

    case $o_ext in
        elf)
            mv "$temp_dir/$inputfile_base.elf" "$o"
            ;;
        list)
            mv "$temp_dir/$inputfile_base.list" "$o"
            ;;
        bin)
            mv "$temp_dir/$inputfile_base.bin" "$o"
            ;;
        *)
            echo "Unrecognised output file format / extension, must be .elf, .list, or .bin." 1>&2
            clean_exit 6
        ;;
    esac
done

echo "Compilation Successful: $outputs"

# Cleanup
clean_exit 0