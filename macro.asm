;-------;
; MACRO ;
;-------;

.macro receive
receive1:
	SBIS UCSRA, RXC
	RJMP receive1
	IN	@0, UDR
.endmacro

.macro	transmit
transmit1:
	SBIS UCSRA, UDRE	;Is UDR empty?
    RJMP transmit1		;if not, wait some more
    OUT  UDR, @0		;Send R17 to UDR
   
.endmacro

.macro	load_data
	LDI R16, @0
	ST Y+, R16
	LDI R16, @1
	ST	Y+, R16
.endmacro
