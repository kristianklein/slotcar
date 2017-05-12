.INCLUDE "m32Adef.inc"
.INCLUDE "pindef.asm" ; Pindefinitioner
.INCLUDE "consts.asm" ; Konstanter
.INCLUDE "macro.asm" ; Macros
; Rækkefølgen af nedenstående includes er vigtig da der skiftes mellem
; DSEG og CSEG!
.INCLUDE "vars.asm" ; Variable (DSEG)
.INCLUDE "vectortable.asm" ; Reset/interrupt vector table
.INCLUDE "lookup.asm" ; Lookup tabeller
.INCLUDE "setup.asm" ; Setup af I/O, ADC, PWM, timers, interrupts mm.

;-------------------;
;     MAIN LOOP	    ;
;-------------------;
main:
    .INCLUDE "bluetooth.asm" ; Bluetooth protokol

.INCLUDE "isr.asm" ; Interrupt service routines
.INCLUDE "subroutines.asm" ; Sub-routiner (funktioner)
