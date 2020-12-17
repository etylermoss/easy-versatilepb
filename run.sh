#!/usr/bin/env bash

gdb='-S -gdb'
port='1234'

if [ -z "$1" ]; then
    echo 'Please supply input ARM binary file.'
    exit 1
fi

if [ -n "$3" ]; then
    port="$3"
fi

gdb="$gdb tcp::$port"

if [ "$2" != '-gdb' ]; then
    gdb=''
fi

qemu-system-arm -M versatilepb $gdb -m 128M -nographic -no-reboot -audiodev none,id=none -kernel "$1"