# easy-versatilepb
Package to easily compile C or ARM assembly, link, and run on a versatilepb QEMU machine. Includes code for read/write to UART0 with SVC/SWI, following handlers used by KoMoDo.

Note: Code quality of the bash scripts is not great.

---

## How-to
```bash
$> git clone https://github.com/etylermoss/easy-versatilepb.git
$> cd easy-versatilepb
$> ./easy-versatilepb-build example/main.s main.bin
$> ./easy-versatilepb-run main.bin

#  Hello World!
```

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
```

## Basic Hello World example
See the file easy-versatilepb/example/main.s for a full working example. The key points are that the entry point file must contain a label `main`, and this label must be declared *global*, so it is accessible by the linker, by using `.global main`.
```assembly
// easy-versatilepb/example/main.s

.global main

.func
main:
        ...
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

## SVC/SWI Codes

Replicates functionality in Manchester KoMoDo

| Code 	| Operation                                                          	|
|------	|--------------------------------------------------------------------	|
| 0    	| Output the single character in R0 to UART0                         	|
| 1    	| Read in, to R0, a single character typed in UART0                  	|
| 2    	| Halt execution                                                     	|
| 3    	| Print a string, whose start address is in R0, to UART0             	|
| 4    	| Print out, to UART0, in decimal, the (signed) integer stored in R0 	|