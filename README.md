# easy-versatilepb
Package to easily compile C or ARM assembly, link, and run on a versatilepb QEMU machine. Includes code for read/write to UART0 with SVC/SWI, following handlers used by KoMoDo.

| Code 	| Operation                                                          	|
|------	|--------------------------------------------------------------------	|
| 0    	| Output the single character in R0 to UART0                         	|
| 1    	| Read in, to R0, a single character typed in UART0                  	|
| 2    	| Halt execution                                                     	|
| 3    	| Print a string, whose start address is in R0, to UART0             	|
| 4    	| Print out, to UART0, in decimal, the (signed) integer stored in R0 	|