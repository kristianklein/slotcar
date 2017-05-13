.INCLUDE "includes/m32Adef.inc"
.INCLUDE "includes/pindef.asm" ; Pin definitions
.INCLUDE "includes/consts.asm" ; Constants
.INCLUDE "includes/macro.asm" ; Macros
.INCLUDE "includes/vars.asm" ; Variables (DSEG)
.INCLUDE "includes/vectortable.asm" ; Reset/interrupt vector table
.INCLUDE "includes/lookup.asm" ; Lookup tables (CSEG)
.INCLUDE "includes/setup.asm" ; Setup I/O, ADC, PWM, timers, interrupts etc.

;-------------------;
;     MAIN LOOP	    ;
;-------------------;
main:
    .INCLUDE "includes/bluetooth.asm" ; Bluetooth protocol
    RJMP main

.INCLUDE "includes/isr.asm" ; Interrupt service routines
.INCLUDE "includes/subroutines.asm" ; Sub-routines (functions)
