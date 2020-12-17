MEMORY
{
    ram     : ORIGIN = 0x00000000, LENGTH = 0x07FFFFFF
}
SECTIONS
{
    . = 0x10000;
    .text   : { *(.text*) }
    .data   : { *(.text*) }
    .bss    : { *(.text*) }
}