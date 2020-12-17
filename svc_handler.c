#include <stdint.h>

void halt ( void );

typedef volatile struct {
    uint32_t DR;
    uint32_t RSR_ECR;
    uint8_t reserved1[0x10];
    const uint32_t FR;
    uint8_t reserved2[0x4];
    uint32_t LPR;
    uint32_t IBRD;
    uint32_t FBRD;
    uint32_t LCR_H;
    uint32_t CR;
    uint32_t IFLS;
    uint32_t IMSC;
    const uint32_t RIS;
    const uint32_t MIS;
    uint32_t ICR;
    uint32_t DMACR;
} pl011_T;

enum {
    RXFE = 0x10,
    TXFF = 0x20,
};

pl011_T * const UART0 = (pl011_T *) 0x101F1000;

static void uart_send ( pl011_T *pl011, uint32_t c );
static void uart_send_string ( pl011_T *pl011, char * s );
static char uart_read ( pl011_T *pl011 );
static char *int_to_string(int32_t val_s);
char svc_handler ( uint32_t target, uint32_t *reg );

/** uart_send_string:
 *  Sends a single character to the serial port.
 */
static void uart_send ( pl011_T *pl011, uint32_t c )
{
    while ((pl011->FR & TXFF) != 0) {};
    pl011->DR = c;
}

/** uart_send_string:
 *  Sends a null terminated string to the serial port.
 */
static void uart_send_string ( pl011_T *pl011, char * s )
{
    while(*s != '\0')
    {
        while ((pl011->FR & TXFF) != 0) {};
        pl011->DR = *s;
        s++;
    }
}

/** uart_read:
 *  Pauses execution until a character is entered into the serial port,
 *  whereupon the character will be returned.
 */
static char uart_read ( pl011_T *pl011 )
{
    while ((pl011->FR & RXFE) != 0) {};
    return pl011->DR;
}

/** int_to_string:
 *  Converts int32_t into its (decimal) string representation.
 *  Code taken from https://stackoverflow.com/a/3982385.
 */
static char *int_to_string( int32_t val_s )
{
    static char str[12] = {0};

    int i = 0;
    int isNeg = val_s < 0;

    uint32_t val_u = isNeg ? -val_s : val_s;

    while(val_u != 0)
    {
        str[i++] = val_u%10+'0';
        val_u = val_u/10;
    }

    if(isNeg) str[i++] = '-';

    str[i] = '\0';

    for(int t = 0; t < i/2; t++)
    {
        str[t] ^= str[i-t-1];
        str[i-t-1] ^= str[t];
        str[t] ^= str[i-t-1];
    }

    if(val_s == 0)
    {
        str[0] = '0';
        str[1] = '\0';
    }   

    return &str[0];
}

/** svc_handler:
 *  Executes SVC (formerly SWI) routine specified by target, the currently
 *  implemented routines replicate those found in Manchester KoMoDo.
 *  0) Output the single character in R0 to UART0
 *  1) Read in, to R0, a single character typed in UART0
 *  2) Halt execution
 *  3) Print a string, whose start address is in R0, to UART0
 *  4) Print out, to UART0, in decimal, the (signed) integer stored in R0
 */
char svc_handler ( uint32_t target, uint32_t *reg )
{
    char * str;

    switch (target)
    {
        case 0:
            uart_send(UART0, reg[0]);
            break;
        case 1:
            return (int32_t) uart_read(UART0);
        case 2:
            halt();
            break;
        case 3:
            uart_send_string(UART0, (char*) reg[0]);
            break;
        case 4:
            str = int_to_string(reg[0]);
            uart_send_string(UART0, str);
            break;
    }

    return target;
}