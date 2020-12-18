# easy-versatilepb
Package to easily compile C or ARM assembly, link, and run on a versatilepb QEMU machine. Includes code for read/write to UART0 with SVC/SWI, following handlers used by KoMoDo.

---

## How-to
```bash
$> git clone https://github.com/etylermoss/easy-versatilepb.git
$> cd easy-versatilepb
$> ./easy-versatilepb-build example/main.s main.bin
$> ./easy-versatilepb-run main.bin

#  Hello World!
```

## Dependencies
In order to cross-compile for the ARM9 architecture / ARM926EJ-S CPU, you must have installed the following packages:
| Name                                         	| Link(s)                                                                                                                                                             	|
|----------------------------------------------	|---------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| arm-none-eabi-gcc                            	| [Arch Linux](https://www.archlinux.org/packages/community/x86_64/arm-none-eabi-gcc/), [Ubuntu 18.04](https://packages.ubuntu.com/bionic/gcc-arm-none-eabi)           	|
| arm-none-eabi-binutils                       	| [Arch Linux](https://www.archlinux.org/packages/community/x86_64/arm-none-eabi-binutils/), [Ubuntu 18.04](https://packages.ubuntu.com/bionic/binutils-arm-none-eabi) 	|
| arm-none-eabi-newlib                         	| [Arch Linux](https://www.archlinux.org/packages/community/x86_64/arm-none-eabi-newlib/), [Ubuntu 18.04](https://packages.ubuntu.com/bionic/libnewlib-arm-none-eabi)  	|
| arm-none-eabi-gdb / gdb-multiarch (optional) 	| [Arch Linux](https://www.archlinux.org/packages/community/x86_64/arm-none-eabi-gdb/), [Ubuntu 18.04](https://packages.ubuntu.com/bionic/gdb-multiarch)               	|

## Full arguments
```txt
./easy-versatilepb-build INPUT OUTPUT{.elf, .list, .bin}
    -h, --help, * )
        Print usage information.

./easy-versatilepb-run INPUT
    -gdb )
        QEMU will listen for an incoming connection from gdb
        on TCP port 1234. Execution will not start until told
        to do so by GDB.
    -h, --help, * )
        Print usage information.
    Note: If you do not halt execution (with SVC 2), QEMU will not quit as
    the machine is still technically running, even if it has run out of
    instructions. In the terminal, press CTRL+A, then type "x", to quit QEMU.
```

## Basic Hello World example
See the file *easy-versatilepb/example/main.s* for a full working example. The key points are that the entry point file must contain a label `main`, and this label must be declared *global*, so it is accessible by the linker, by using `.global main`.
```assembly
// easy-versatilepb/example/main.s

.global main

.func
main:
        ...     // Your assembly here
.endfunc
```
Using a C file as the entry point requires no special setup, though various library functions will not work due to the nature of being 'bare metal', e.g no <stdio.h>.

## Syntax
The build script for this project uses GNU Assembler, so Assembly files using the original ARM syntax (like that which is used in KoMoDo) will need to be translated. This is a relatively easy process to do, e.g:
```
hello   DEFB "Hello World!",0
        ALIGN
```
Becomes:
```
hello:  .string "Hello World!"
        .align 4
```
See [Migrating ARM syntax assembly code to GNU syntax](https://developer.arm.com/documentation/dui0742/g/Migrating-ARM-syntax-assembly-code-to-GNU-syntax/Overview-of-differences-between-ARM-and-GNU-syntax-assembly-code?lang=en).

## Installation
At the moment there is no installation script / file / package, however if you want to use this anywhere on the system you can use the following commands:
```bash
$> git git clone https://github.com/etylermoss/easy-versatilepb.git
$> sudo mv easy-versatilepb /opt/easy-versatilepb
$> sudo ln -s /opt/easy-versatilepb/easy-versatilepb-build /usr/local/bin/
$> sudo ln -s /opt/easy-versatilepb/easy-versatilepb-run /usr/local/bin/
```
Use `~/.local/bin/` instead of `/usr/local/bin/` to install for just the current user (you may also need to place the installation directory somewhere other than `/opt/` assuming limited permissions).

## SVC/SWI Codes

Replicates functionality in Manchester KoMoDo, instead of *SWI* use *SVC* (the former being outdated, though still works).

| Code 	| Operation                                                          	|
|------	|--------------------------------------------------------------------	|
| 0    	| Output the single character in R0 to UART0                         	|
| 1    	| Read in, to R0, a single character typed in UART0                  	|
| 2    	| Halt execution                                                     	|
| 3    	| Print a string, whose start address is in R0, to UART0             	|
| 4    	| Print out, to UART0, in decimal, the (signed) integer stored in R0 	|