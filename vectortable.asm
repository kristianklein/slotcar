;-------------------;
;   VECTOR TABLE    ;
;-------------------;
.CSEG
.ORG	0x00
JMP		setup

.ORG	0x02
JMP		finish_line_interrupt; (INT0, PD2)

.ORG	0x04
JMP		distance_interrupt ; (INT1, PD3)
