.global main                            /* Must declare main globally for linker */

hello:  .string "Hello World!"

.align 4

/** main: args(void) returns(void)
 *  Main assembly procedure
 */
.func
main:
        ADR R0, hello
        SVC 3                           /* Print out string starting at address in R0, see README.md */
        MOV R0, #'\n'
        SVC 0
        SVC 2
.endfunc
