.INCLUDE "m32Adef.inc"
.EQU F_CPU = 16000000 ; 1 MHz, change this when fuse bits have been set
;-------------------;
;  PIN DEFINITIONS  ;
;-------------------;
.EQU	RED_LED_DDR = DDRB
.EQU	RED_LED_PORT = PORTB
.EQU	RED_LED = PINB4

.EQU	GREEN_LED_DDR = DDRB
.EQU	GREEN_LED_PORT = PORTB
.EQU	GREEN_LED = PINB3

.EQU	STRAIN_GAUGE_DDR = DDRA
.EQU	STRAIN_GAUGE_PIN = PINA
.EQU	STRAIN_GAUGE_PORT = PORTA
.EQU	STRAIN_GAUGE = PINA0

.EQU	FINISH_LINE_DDR = DDRD
.EQU	FINISH_LINE_PIN = PIND
.EQU	FINISH_LINE_PORT = PORTD
.EQU	FINISH_LINE = PIND2

.EQU	DISTANCE_DDR = DDRD
.EQU	DISTANCE_PIN = PIND
.EQU	DISTANCE_PORT = PORTD
.EQU	 DISTANCE = PIND3

.EQU	MOTOR_DDR = DDRD
.EQU	 MOTOR_PIN = PIND
.EQU	MOTOR_PORT = PORTD
.EQU	MOTOR = PIND7

.EQU	DEFAULT_MOTORSPEED = 115

.DEF	FLAGR = R5		; Flagregister til at bestemme om bilen er i sving eller ej.
.EQU	TURNF = 0		; bit 0 i flagregister.
.EQU	CONSTF = 1
.EQU	RACEF = 2
.EQU	CALIF = 3

.EQU	 MIN_CYCLES = 577;560;583	;Højeste hastighed
.EQU	 MAX_CYCLES = 1435;1220;1525	;Mindste hastighed

;-------------------;
;  Variables	    ;
;-------------------;
	

; Setup af sving_ticks
.DSEG
sving:		.BYTE	200		; Reservér 200 pladser til sving_ticks
/*SPEEDL:		.BYTE	1
SPEEDH:		.BYTE	1
Timer1L:	.BYTE	1
Timer1H:	.BYTE	1
*/
.CSEG


;-------------------;
;   VECTOR TABLE    ;
;-------------------;
.ORG	0x00
JMP		reset

.ORG	0x02
JMP		finish_line_interrupt; (INT0, PD2)

.ORG	0x04
JMP		distance_interrupt ; (INT1, PD3)

;-------------------;
;       SETUP	    ;
;-------------------;
.ORG 0x002A
brems:		.DB	 256,254,253,252,251,250,249,248,247,246,245,244,243,242,241,240,239,238,237,236,235,234,234,233,232,231,230,229,228,227,226,225,224,223,223,222,221,220,219,218,217,216,216,215,214,213,212,211,210,210,209,208,207,206,206,205,204,203,202,202,201,200,199,198,198,197,196,195,195,194,193,192,192,191,190,189,189,188,187,186,186,185,184,184,183,182,181,181,180,179,179,178,177,177,176,175,175,174,173,173,172,171,171,170,169,169,168,167,167,166,166,165,164,164,163,162,162,161,161,160,159,159,158,158,157,156,156,155,155,154,154,153,152,152,151,151,150,150,149,148,148,147,147,146,146,145,145,144,144,143,143,142,141,141,140,140,139,139,138,138,137,137,136,136,135,135,134,134,133,133,132,132,131,131,130,130,129,129,129,128,128,127,127,126,126,125,125,124,124,123,123,123,122,122,121,121,120,120,119,119,119,118,118,117,117,116,116,116,115,115,114,114,113,113,113,112,112,111,111,111,110,110,109,109,109,108,108,107,107,107,106,106,106,105,105,104,104,104,103,103,102,102,102,101,101,101,100,100,100,99,99,98,98,98,97,97,97,96,96,96,95,95,95,94,94,94,93,93,93,92,92,92,91,91,91,90,90,90,89,89,89,88,88,88,87,87,87,86,86,86,85,85,85,84,84,84,84,83,83,83,82,82,82,81,81,81,81,80,80,80,79,79,79,79,78,78,78,77,77,77,77,76,76,76,75,75,75,75,74,74,74,73,73,73,73,72,72,72,72,71,71,71,71,70,70,70,70,69,69,69,68,68,68,68,67,67,67,67,66,66,66,66,65,65,65,65,64,64,64,64,64,63,63,63,63,62,62,62,62,61,61,61,61,60,60,60,60,60,59,59,59,59,58,58,58,58,58,57,57,57,57,56,56,56,56,56,55,55,55,55,55,54,54,54,54,53,53,53,53,53,52,52,52,52,52,51,51,51,51,51,50,50,50,50,50,49,49,49,49,49,48,48,48,48,48,48,47,47,47,47,47,46,46,46,46,46,45,45,45,45,45,45,44,44,44,44,44,43,43,43,43,43,43,42,42,42,42,42,42,41,41,41,41,41,40,40,40,40,40,40,39,39,39,39,39,39,38,38,38,38,38,38,37,37,37,37,37,37,37,36,36,36,36,36,36,35,35,35,35,35,35,34,34,34,34,34,34,34,33,33,33,33,33,33,33,32,32,32,32,32,32,32,31,31,31,31,31,31,30,30,30,30,30,30,30,30,29,29,29,29,29,29,29,28,28,28,28,28,28,28,27,27,27,27,27,27,27,27,26,26,26,26,26,26,26,25,25,25,25,25,25,25,25,24,24,24,24,24,24,24,24,23,23,23,23,23,23,23,23,22,22,22,22,22,22,22,22,21,21,21,21,21,21,21,21,21,20,20,20,20,20,20,20,20,19,19,19,19,19,19,19,19,19,18,18,18,18,18,18,18,18,18,17,17,17,17,17,17,17,17,17,16,16,16,16,16,16,16,16,16,16,15,15,15,15,15,15,15,15,15,15,14,14,14,14,14,14,14,14,14,13,13,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,6,6,6,6,5,5,5,5,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; 2 m/s ;255,254,253,252,251,250,249,248,247,246,245,244,243,242,241,240,239,238,237,236,235,234,234,233,232,231,230,229,228,227,226,225,225,224,223,222,221,220,219,219,218,217,216,215,214,214,213,212,211,210,210,209,208,207,206,206,205,204,203,202,202,201,200,199,199,198,197,196,196,195,194,194,193,192,191,191,190,189,189,188,187,186,186,185,184,184,183,182,182,181,180,180,179,178,178,177,176,176,175,174,174,173,172,172,171,171,170,169,169,168,168,167,166,166,165,164,164,163,163,162,162,161,160,160,159,159,158,157,157,156,156,155,155,154,154,153,152,152,151,151,150,150,149,149,148,148,147,147,146,146,145,145,144,143,143,142,142,141,141,140,140,139,139,138,138,138,137,137,136,136,135,135,134,134,133,133,132,132,131,131,130,130,130,129,129,128,128,127,127,126,126,126,125,125,124,124,123,123,122,122,122,121,121,120,120,120,119,119,118,118,117,117,117,116,116,115,115,115,114,114,113,113,113,112,112,112,111,111,110,110,110,109,109,108,108,108,107,107,107,106,106,106,105,105,104,104,104,103,103,103,102,102,102,101,101,101,100,100,100,99,99,99,98,98,98,97,97,97,96,96,96,95,95,95,94,94,94,93,93,93,92,92,92,91,91,91,90,90,90,90,89,89,89,88,88,88,87,87,87,86,86,86,86,85,85,85,84,84,84,84,83,83,83,82,82,82,82,81,81,81,80,80,80,80,79,79,79,79,78,78,78,77,77,77,77,76,76,76,76,75,75,75,75,74,74,74,74,73,73,73,73,72,72,72,72,71,71,71,71,70,70,70,70,69,69,69,69,68,68,68,68,68,67,67,67,67,66,66,66,66,65,65,65,65,65,64,64,64,64,63,63,63,63,63,62,62,62,62,61,61,61,61,61,60,60,60,60,60,59,59,59,59,58,58,58,58,58,57,57,57,57,57,56,56,56,56,56,55,55,55,55,55,54,54,54,54,54,54,53,53,53,53,53,52,52,52,52,52,51,51,51,51,51,51,50,50,50,50,50,49,49,49,49,49,49,48,48,48,48,48,47,47,47,47,47,47,46,46,46,46,46,46,45,45,45,45,45,45,44,44,44,44,44,44,43,43,43,43,43,43,42,42,42,42,42,42,42,41,41,41,41,41,41,40,40,40,40,40,40,40,39,39,39,39,39,39,38,38,38,38,38,38,38,37,37,37,37,37,37,37,36,36,36,36,36,36,36,35,35,35,35,35,35,35,34,34,34,34,34,34,34,33,33,33,33,33,33,33,33,32,32,32,32,32,32,32,31,31,31,31,31,31,31,31,30,30,30,30,30,30,30,30,29,29,29,29,29,29,29,29,28,28,28,28,28,28,28,28,27,27,27,27,27,27,27,27,27,26,26,26,26,26,26,26,26,25,25,25,25,25,25,25,25,25,24,24,24,24,24,24,24,24,24,23,23,23,23,23,23,23,23,23,22,22,22,22,22,22,22,22,22,21,21,21,21,21,21,21,21,21,21,20,20,20,20,20,20,20,20,20,20,19,19,19,19,19,19,19,19,19,19,18,18,18,18,18,18,18,18,18,18,17,17,17,17,17,17,17,17,17,17,17,16,16,16,16,16,16,16,16,16,16,15,15,15,15,15,15,15,15,15,15,15,14,14,14,14,14,14,14,14,14,14,14,14,13,13,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;  1,6 m/s ; 255,254,253,252,251,250,249,247,246,245,244,243,242,241,240,239,238,237,236,234,233,232,231,230,229,228,227,226,225,224,223,222,221,220,219,218,217,216,216,215,214,213,212,211,210,209,208,207,206,205,204,204,203,202,201,200,199,198,197,197,196,195,194,193,192,191,191,190,189,188,187,187,186,185,184,183,183,182,181,180,179,179,178,177,176,176,175,174,173,173,172,171,170,170,169,168,167,167,166,165,165,164,163,163,162,161,160,160,159,158,158,157,156,156,155,154,154,153,152,152,151,150,150,149,149,148,147,147,146,145,145,144,144,143,142,142,141,140,140,139,139,138,138,137,136,136,135,135,134,133,133,132,132,131,131,130,130,129,128,128,127,127,126,126,125,125,124,124,123,123,122,121,121,120,120,119,119,118,118,117,117,116,116,115,115,114,114,113,113,112,112,111,111,111,110,110,109,109,108,108,107,107,106,106,105,105,104,104,104,103,103,102,102,101,101,100,100,100,99,99,98,98,97,97,97,96,96,95,95,95,94,94,93,93,92,92,92,91,91,90,90,90,89,89,88,88,88,87,87,87,86,86,85,85,85,84,84,84,83,83,82,82,82,81,81,81,80,80,80,79,79,78,78,78,77,77,77,76,76,76,75,75,75,74,74,74,73,73,73,72,72,72,71,71,71,70,70,70,69,69,69,68,68,68,67,67,67,66,66,66,66,65,65,65,64,64,64,63,63,63,62,62,62,62,61,61,61,60,60,60,60,59,59,59,58,58,58,58,57,57,57,56,56,56,56,55,55,55,55,54,54,54,53,53,53,53,52,52,52,52,51,51,51,51,50,50,50,50,49,49,49,49,48,48,48,48,47,47,47,47,46,46,46,46,45,45,45,45,44,44,44,44,43,43,43,43,42,42,42,42,42,41,41,41,41,40,40,40,40,39,39,39,39,39,38,38,38,38,38,37,37,37,37,36,36,36,36,36,35,35,35,35,35,34,34,34,34,33,33,33,33,33,32,32,32,32,32,31,31,31,31,31,30,30,30,30,30,30,29,29,29,29,29,28,28,28,28,28,27,27,27,27,27,26,26,26,26,26,26,25,25,25,25,25,24,24,24,24,24,24,23,23,23,23,23,23,22,22,22,22,22,22,21,21,21,21,21,21,20,20,20,20,20,20,19,19,19,19,19,19,18,18,18,18,18,18,17,17,17,17,17,17,16,16,16,16,16,16,16,15,15,15,15,15,15,14,14,14,14,14,14,14,13,13,13,13,13,13,13,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,10,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0

reset:
    ;--------------;
    ; Input/Output ;
    ;--------------;
    
	; Set RED_LED as output and low
	SBI		RED_LED_DDR, RED_LED
	CBI		RED_LED_PORT, RED_LED
	
	; Set GREEN_LED as output and low
	SBI		GREEN_LED_DDR, GREEN_LED
	CBI		GREEN_LED_PORT, GREEN_LED
	
	; Set FINISH_LINE as input without internal pull-up
	CBI		FINISH_LINE_DDR, FINISH_LINE
	CBI		FINISH_LINE_PORT, FINISH_LINE
	
	; Set DISTANCE as input without internal pull-up
	CBI		DISTANCE_DDR, DISTANCE
	CBI		DISTANCE_PORT, DISTANCE
	
	; Set STRAIN_GAUGE as input without internal pull_up
	CBI		STRAIN_GAUGE_DDR, STRAIN_GAUGE
	CBI		STRAIN_GAUGE_PORT, STRAIN_GAUGE
	
	; Set MOTOR PWM as output and low
	SBI		MOTOR_DDR, MOTOR
	CBI		MOTOR_PORT, MOTOR

	; Initialiser FLAGR = 0x00.
	LDI		R16,0x00
	MOV		FLAGR,R16	

; Opsætning af stack pointer
	LDI		R16, low(RAMEND)
	OUT		SPL, R16
	LDI		R16, high(RAMEND)
	OUT		SPH, R16	
	
; initialisér antal motorticks. (Dette skal gøres før dette interrupt)
	LDI		R16, 0x00
	MOV		R9, R16
	MOV		R10, R16
	MOV		R15, R16

	
	


	;--------------------;
    ; Timer1				 ;
    ;--------------------;
	LDI		R16, (1<<CS11)|(1<<CS10)
	OUT		TCCR1B, R16		; Prescaler = 64


    ;-----------;              
    ; BLUETOOTH ;
    ;-----------;
	LDI		R16, (1<<TXEN)|(1<<RXEN) ; Enable transmit/receive
	OUT		UCSRB, R16
	LDI		R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL) ; Set character size = 8 bits
	OUT		UCSRC, R16
	LDI		R16, 103		;16MHz Sætter baudrate til 9600, med U2X = 0 og error = 0,2%
	;LDI		R16, 12		;1 MHz
	OUT		UBRRL, R16 
	;SBI		UCSRA, U2X		;bruges til 1MHz baudrate



	;------------;
	; Set up ADC ;
	;------------;
	;--------------------------------------------;
	; REFS1 REFS0 ADLAR MUX4 MUX3 MUX2 MUX1 MUX0 ;
    ;   7     6     5    4    3    2    1    0   ;
    ;--------------------------------------------;
	LDI		R16, 0b00100000 ; AREF, left adjusted, ADC0, 
						; 0b11100000 to use 2.56V reference (MÅ KUN
						; BRUGES NÅR DER IKKE ER SPÆNDING PÅ AREF! Der
						; skal tilgengæld være en afkoblingskondensator
						; til GND)
	OUT		ADMUX, R16
	
	;---------------------------------------------;
	; ADEN ADSC ADATE ADIF ADIE ADPS2 ADPS1 ADPS0 ;
	;  7    6     5    4    3     2     1     0   ;
	;---------------------------------------------;
	LDI		R16, 0b11100111 ; Enable, start conversion, auto-trigger, prescaler = 128
	OUT		ADCSRA, R16		; ADC_frekvens = 125 kHz
	
	;-------------------;
	; ADTS2 ADTS1 ADTS0 ;
	;   7     6     5   ;
	;-------------------;
	LDI		R16, 0b00000000 ; Set trigger-source to free running mode
	OUT		SFIOR, R16


;-----------------------------MACROSETUP---------------------------------------------------
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

;-----------------------------Testsetup til racemode---------------------------------------

	; Midlertidig setup af y-pointer
	LDI		YL,LOW(sving)		
	LDI		YH,HIGH(sving)


	RCALL	delay_1sec
	RCALL	delay_1sec



	;-----;
    ; PWM ;
    ;-----;
    
    ; Set up PWM on OC2
	; No prescaler (PWM frequency = 1 MHz / 256 = 3900 Hz)
    ; Change prescaler when fuse bits for 16 MHz clock has been set!
	LDI		R16, 0b01101001 ; (1<<WGM20)|(1<<COM21)|(1<<WGM21)|(1<<CS20)
	OUT		TCCR2, R16
	
	; Set motor speed
	LDI		R16, DEFAULT_MOTORSPEED
	OUT		OCR2, R16 ; Output compare register - OC2 pin is set LOW when
                  ; the value in OCR2 matches the value in the
                  ; timer/counter register (TCNT2)
    
		;------------;
    ; INTERRUPTS ;
    ;------------;
    
    ; Enable interrupts
	LDI		R16, (1<<INT0)|(1<<INT1) ; Enable INT0 and INT1
	OUT		GICR, R16
	LDI		R16, (1<<ISC01)|(1<<ISC11) ; Set INT0 and INT1 to trigger on falling edge
	OUT		MCUCR, R16
	SEI ; Enable global interrupts
;-------------------;
;     MAIN LOOP	    ;
;-------------------;

main:
 ; Jespers bluetooth kode -------------------------------------------	
	receive R17			;Modtag Byte1
	CPI		R17, 0x55
	BREQ	set1					;Branch hvis det var en SET kommand
	CPI		R17, 0xAA
	BREQ	get1					;Branch hvis det er en GET kommand
	RJMP	main					;Loop hvis det var en fejl eller intet er modtaget

    set1: ;SET----------------------------------------------------------
        receive R17			;Modtag Byte2
        CPI		R17, 0x10
        BREQ	set1_hastighed2	;Branch hvis det er en set1_hastighed2 kommand
        CPI		R17, 0x11
        BREQ	set1_stop2			;Branch hvis det er en set1_stop2 kommand
        CPI		R17, 0x12
        BREQ	set1_auto2			;Branch hvis det er en set1_auto2 kommand
		CPI		R17, 0x13
        BREQ	set1_blink2		;Brand hvis det er en set1_blink2 kommand

        RJMP	main				;Loop tilbage til main, hvis protokol var forkert

    get1: ;GET-------------------------------------------------------------
		receive R17			;Modtag byte 2
		CPI		R17, 0x02			
        BREQ	get1_hastighed2	;Branch hvis det er en get1_hastighed2 kommand
		CPI		R17, 0x03
        BREQ	get1_position2		;Branch hvis det er en get1_position2 kommand
		CPI		R17, 0x05
        BREQ	get1_straingauge2	;Branch hvis det er en get1_straingauge2 kommand
		CPI		R17, 0x06
        BREQ	get1_positionssensor2;Branch hvis det er en get1_positionsensor2 kommand
		CPI		R17, 0x07
        BREQ	get1_maalstregssensor2;Branch hvis det er en get_1maalstregssensor2 kommand

        RJMP main				;Loop tilbage til main, hvis protokol var forkert
   
		;SET2-----------------------------------------------------------------------
		set1_hastighed2:
			receive R17		;Modtag byte3
			MOV		R2, R17			;Flyt modtaget byte over i R2
			OUT		OCR2, R2		;Output R2 til OCR2
			RJMP	main			;Loop tilbage til main

		set1_stop2:				;Se eksempel set1_hastighed2
			LDI		R17, 0			
			MOV		R2, R17
			OUT		OCR2, R2
			RJMP	main
		
		set1_auto2:				;Se eksempel set1_hastighed2
			LDI		R17, 120		;Midlertidig værdi - denne værdi skal starte automode
			MOV		R2, R17
			OUT		OCR2, R2
			RJMP	main

		set1_blink2:			;Se eksempel set1_hastighed2
			receive R17		
			MOV		R8, R17
			;Kode der sender R8 ud til en blink
			RJMP	main ;der mangler kode til blink

		;GET2-----------------------------------------------------------------------

        get1_hastighed2:
		MOV			R17, R8				;Flyt R2 (hastighed) over til R17 
		transmit	R17			;R17 sendes via bluetooth
		RJMP		main				;Loop til main

        get1_position2:			;Se eksempel get1_position2
		MOV			R17, R10			; highbyte position
		transmit	R17
		MOV			R17, R9				; lowbyte position
		transmit	R17
		RJMP		main

        get1_straingauge2:		;Se eksempel get1_position2
		MOV			R17, R11
		transmit	R17
		RJMP		main

        get1_positionssensor2:	;Se eksempel get1_position2
		MOV			R17, R12
		transmit	R17
		RJMP		main

        get1_maalstregssensor2:	;Se eksempel get1_position2
		MOV			R17, R15			; Omgange i stedet for målstregwsensor
		transmit	R17
		RJMP		main

distance_interrupt:
	; Benyttes til beregning

	PUSH	R16
	PUSH	R17
	PUSH	R18
	PUSH	R19
	PUSH	R20
	PUSH	R21
	PUSH	R22
	PUSH	R23


; Reset af timer1 værdi efter hvert interrupt 
	LDI		R22, 0x00
	IN		R16, TCNT1L				; Gem timer1 værdi i R16(lowbyte)
	IN		R17, TCNT1H				; Gem timer1 værdi i R17(lowbyte)
	;STS		Timer1L,R16
	;STS		Timer1H,R17
	;transmit	R17
	;transmit	R16
	OUT		TCNT1H, R22				; Nulstil timer1
	OUT		TCNT1L, R22				; Nulstil timer1




; R10:R9 indeholder antal motorticks. Forøg antal ticks med én.
	LDI		R22, 0x01		
	ADD		R9, R22
	LDI		R22, 0x00
	ADC		R10, R22				; Antal ticks = Antal ticks + 1


	SBRC	FLAGR, CALIF		;Hvis CALIF = 1, så ska den hoppe til kalibrering straingauge
	RJMP	kalibrering_straingauge

	SBRC	FLAGR, CONSTF		;Hvis CONSTF = 1, så skal den hoppe til slut
	RJMP	slut				;slut interrupt

	SBRS	FLAGR, RACEF			;Hvis RACEF = 0, så skal koden hoppe til slut		
	RJMP	slut				;slut interrupt


	
; Kopier postion til R21:R20. R21:R20 benyttes til beregning.
	MOV		R20,R9			
	MOV		R21,R10

; Setup af z-pointer til adresse af første bremselængde - 1961
	LDI		ZL,LOW((brems*2)-MIN_CYCLES)	; setup z-pointer low
	LDI		ZH,HIGH((brems*2)-MIN_CYCLES)	; setup z-pointer high

	
; Kontrollér at Timer1 er i intervallet 1961-4745: Fra bremselængder ved 2 m/s til 5 m/s

	LDI		R18, low(MIN_CYCLES)			; low
	LDI		R19, high(MIN_CYCLES)			; high

	SUB		R18,R16
	SBC		R19,R17					; Mindst mulige timerværdi ved v = 5 m/s
	BRCS	tjek_max	
	; Load R19:R18 igen for at
	LDI		R18, low(MIN_CYCLES)			; low
	LDI		R19, high(MIN_CYCLES)			; high
	MOV		R16,R18					; Sæt R17:R16 = 1961 , hvis R17:R16 <= 1961.	
	MOV		R17,R19
tjek_max:
	LDI		R18, low(MAX_CYCLES)			; lowbyte
	LDI		R19, high(MAX_CYCLES)			; highbyte
	SUB		R18,R16
	SBC		R19,R17					; Mindst mulige timerværdi ved v = 2 m/s
	BRCC	set_zpointer
	; Load R19:R18 igen for at sætte R17:R16 = 4745
	LDI		R18, low(MAX_CYCLES)			; low
	LDI		R19, high(MAX_CYCLES)			; high
	MOV		R16,R18					; Sæt R17:R16 = 4745 , hvis R17:R16 <= 4745.	
	MOV		R17,R19
set_zpointer:
	ADD		ZL,R16					; Sæt z-pointer til korrekt sted i programmemory				
	ADC		ZH,R17					; z-pointer er 16 bit, derfor adderes carry for at undgå overflow af adresse.
	
; Bremselængde lægges i R17:R16	
	LPM		R16,Z					; Gem bremselængde i ticks i R16 (lowbyte)
	LDI		R17,0x00				; Bremselængde i ticks (highbyte = 0)

; R7:R6 indeholder antal ticks ved indgang/udgang til sving
; R21:R20 indeholder vores nuværende position i ticks.
	MOV		R22,R6			; Kopier position_sving til R22 (lowbyte)
	MOV		R23,R7			; Kopier position_sving til R23 (highbyte)

; Bestem position_afstand
	SUB		R22,R20			; position_afstand = position_sving - position_bil (lowbyte)
	SBC		R23,R21			; position_afstand = position_sving - position_bil (highbyte)
; Position_afstand gemt i R23:R22
; Hvis bilen er kørt forbi første position_sving -> skift til næste værdi i dataspace.
	
	BRCC	ikke_nyt_sving			;Branch hvis positiv
	
	LD		R7,Y+					;Hent sving_ticks i SRAM R7:R6
	LD		R6,Y+

	LDI		R26, (1<<TURNF)			;Toggle TURNF
	EOR		FLAGR,	R26
	LDI		R26,0x00
	;transmit	R26
	;transmit	R26
	

; Sammenligninger afstand til sving og bremselængde
ikke_nyt_sving:
; Hvis TURNF = 1 => set konstanthastighed og  hop til slut
	SBRC	FLAGR, TURNF	;TURNF
	RCALL	konstant_hastighed
	SBRC	FLAGR, TURNF	;TURNF
	RJMP	slut			;slut interrupt

	SUB		R22,R16			; position_afstand - bremselængde (lowbyte)
	SBC		R23,R17			; position_afstand - bremselængde (highbyte)
	

;Hvis R23:R22 er lavere end R17:R16, så er det tid til at bremse!
	BRCC	spring_over	
	RCALL	brake			; hop til brake, hvis carry=1
spring_over:
	BRCS	slut
	RCALL	accelerate		; Hop til accelerate, hvis carry = 0

; Hent værdier fra SRAM tilbage
slut:
;kalibrering_straingauge:
	POP		R23
	POP		R22
	POP		R21
	POP		R20
	POP		R19
	POP		R18
	POP		R17
	POP		R16
	RETI	
			
	accelerate:	
		LDI		R16, 0xFF
		OUT		OCR2, R16
		RET

	brake:
		LDI		R16, 0x00
		OUT		OCR2, R16
		RET	

	konstant_hastighed:
		LDI		R25, 145	
		OUT		OCR2, R25
		RET
		
	kalibrering_straingauge:
		IN		R18,ADCH		; Load strain gauge værdi ind i R18
		;transmit R18
		SBRC	FLAGR,0;TURNF		; Skip næste linje, hvis sving flaget er cleared. 
		RJMP	udgang_sving	; Hvis sving flaget er sat => hop til udgang_sving

		; indgang_sving
		;---------------------------------------
		LDI		R21, 20
		MOV		R22, R4
		ADD		R22, R21 ;udregning upperthreshold1
		;transmit	R22

		MOV		R23, R22
		SUBI	R23, 40	  ;udregning af upperthreshold2
		;transmit	R23
		;-------------------------------------

		CP		R18,R22
		BRSH	upper			; branch til upper threshold(left), hvis R18 > 170
		CP		R18,R23
		BRLO	upper			; branch til upper threshold(right), hvis R18 < 116
		RJMP	slut		

	udgang_sving:
	;---------------------------
		LDI		R21, 10
		MOV		R22, R4
		ADD		R22, R21		;udregning lowerthreshold1
		;transmit	R22
		MOV		R23, R22
		SUBI	R23, 20			;udregning af lowerthreshold2
		;transmit	R23
		;----------------------------------------------
		CP		R18,R22			
		BRLO	lower			; branch til lower threshold(left), hvis R18 < 160
		CP		R18,R23	
		BRSH	lower			; branch til lower threshold(left), hvis R18 > 126
		RJMP	slut		

	upper:	
		LDI		R19,(1<<TURNF)	; sving flag = 1
		EOR		FLAGR,R19		; Toggle sving flag
		MOV		R21,R10			
		MOV		R20,R9			
		SUBI	R20,20
		LDI		R19,0x00
		SBC		R21,R19
		ST		Y+,R21			; Læg position highbyte i SRAM
		ST		Y+,R20			; Læg position lowbyte i SRAM
		RJMP	slut

	lower:
		LDI		R19,(1<<TURNF)	; sving flag = 1
		EOR		FLAGR,R19		; Toggle sving flag
		MOV		R21,R10			
		MOV		R20,R9			
		SUBI	R20,10
		LDI		R19,0x00
		SBC		R21,R19
		ST		Y+,R21			; Læg position highbyte i SRAM
		ST		Y+,R20			; Læg position lowbyte i SRAM
		RJMP	slut
				


finish_line_interrupt:
	PUSH	R16
	PUSH	R17

	INC		R15				;Inkrementer antal omgange
	; sikring_sving sikrer at vi ikke får den forkerte position af sving efter udgangen af det sidste sving inden målstregen.
	SBRC	FLAGR,CALIF
	RCALL	sikring_sving


	LDI		R16, 0x00		
	MOV		R10, R16		;Nulstil positionsensor(HIGH)
	MOV		R9, R16			;Nulstil positionsensor(LOW)
	
	; Sæt y-pointer op til at pege på starten af SRAM (Sving_tick værdier)
	LDI		YL,LOW(sving)			; Peger på starten af vores sving[0] (lowbyte)
	LDI		YH,HIGH(sving)			; Peger på starten af vores sving[0] (highbyte)


	LDI		R16, ((1<<CALIF)|(1<<RACEF))
	SBRC	FLAGR, CALIF			
	EOR		FLAGR, R16				;Sæt raceflag = 1 og kalibreringsflag = 0, hvis kalibreringsflag = 1



	MOV		R16, R15
	CPI		R16, 1
	BREQ	set_kalibreringsflag	;Branch if antal omgange = 1
	LD		R7,Y+					;Hent sving_ticks i SRAM R7:R6
	LD		R6,Y+				
	pop		R17
	POP		R16
    RETI

set_kalibreringsflag:
	LDI		R16, (1<<CALIF)
	OR		FLAGR, R16
	;-------------BESTEM STRAIN GAUGE OFFSET ------------:	
	IN R16, ADCH
    
    MOV R4, R16 ; Off-set in R4
	;transmit R16
	
	pop		R17
	POP		R16
    RETI		
sikring_sving:
; Flyt position af bil (R10:R9) til R19:R18
	MOV		R18, R9			
	MOV		R19, R10
	; Gem position af Y-pointer i R21:R20
	MOV		R20,YL
	MOV		R21,YH
	
	; Sæt Y-pointer op til at pege på starten af SRAM (Sving_tick værdier)
	LDI		YL,LOW(sving)			; Peger på starten af vores sving[0] (lowbyte)
	LDI		YH,HIGH(sving)			; Peger på starten af vores sving[0] (highbyte)

	LD		R7,Y+
	LD		R6,Y+
	; Læg værdi fra første sving til det samlede antal motorticks på en hel bane.
	ADD		R18, R6
	ADC		R19, R7
	
	; Sæt Y-pointer til at være efter udgangen af det sidste sving på banen.
	MOV		YL,R20
	MOV		YH,R21
	
	; Læg R19:R18 i SRAM (Denne værdi bruges som afstanden til indgangen af første sving efter målstregen, 
	; indtil bilen kører over målstregen og positionen nustilles.
	ST		Y+, R19
	ST		Y+, R18
	
	; Nulstil sving_flag, idet vi indlæser det samme sving to gange. Dvs. vi får to indgange efterfulgt af hinanden. 
	LDI		R19,0b11111110
	AND		FLAGR,R19			; Nulstil TURNF
	
	RET

;-------------------;
;   SUB-ROUTINES 	;
;-------------------;
delay_1sec:
	PUSH	R23
    PUSH	R24
    PUSH	R25
    
    LDI		R23, 61 ;Load 61 into R23 (16 MHz = 61 loops, 1 MHz = 4 loops)
	outer_loop: 
		LDI		R24, low(65535) ;Clear R24 and R25 to use for a 16-bit word
		LDI		R25, high(65535)
		inner_loop: ; 4 instructions per loop if no overflow
			SBIW	R25:R24, 1 ;Subtract 1 from 16-bit word in R25:R24
			BRNE	inner_loop ;Unless R25:R24 overflows, go back to inner_loop
	
	DEC		R23 ;Decrement R23
	BRNE	outer_loop ;Unless R23 overflows go back to outer_loop
    
    POP		R25
    POP		R24
    POP		R23
    
	RET
/*
konstant_hastighed:
    ; VIGTIGT ;
    ; Definer følgende variable i datasegmentet:
    ; .DSEG
    ; SPEEDL: .BYTE 1
    ; SPEEDH: .BYTE 1
    ;
    ; Antal cycles mellem hvert tick ved den
    ; ønskede hastighed (1220 cycles = 2 m/s)
    ; Anvender TIMER1!
    .EQU TARGET_CYCLES_UPPER = 1500 ; 1.95 m/s
    .EQU TARGET_CYCLES_LOWER = 1400 ; 2.12 m/s
    
    .EQU ACCEL_OCR = 140 ; Hvad skal OCR sættes til når den skal accelerere
    .EQU DECEL_OCR = 50 ; Hvad skal OCR sættes til når den skal decelerere
    .EQU HOLD_OCR = 120 ; Hvad skal OCR indstilles til når den kører den rigtige hastighed
    
    ; Push de anvendte registre
    PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
	IN	R16,SREG
	PUSH R16
    
    ; Indlæs timerværdien (low byte først)
    ;IN R16, TCNT1L
    ;IN R17, TCNT1H
    LDS	R16,Timer1L
	LDS	R17,Timer1H
	transmit R17
    ; Load previous timer value and store current
    LDS R18, SPEEDL
    LDS R19, SPEEDH
    STS SPEEDL, R16
    STS SPEEDH, R17
    
    ; Find gennemsnit
    ADD R16, R18
    ADC R17, R19
    BRCS inc_speed ; Hvis addition overflower (timerværdi > 63700 ca.)
    LSR R17
    ROR R16
    
    ; Send data
    ;MOV R18, R17 ; Gem high byte, så den kan gendannes efter send
    ;RCALL Transmit ; Send high byte
    ;MOV R17, R16
    ;RCALL Transmit ; Send low byte
    ;MOV R17, R18 ; Gendan high byte til R17
    
    ; Sammenlign med nedre tærskel (for høj hastighed)
    LDI R18, low(TARGET_CYCLES_LOWER)
    LDI R19, high(TARGET_CYCLES_LOWER)
    SUB R18, R16
    SBC R19, R17 ; R19:R18 - R17:R16 (hvis carry IKKE er sat, skal hastigheden sænkes)
    
    ; Øg/reducer hastighed (afhængig af afstanden fra den ønskede værdi)
    BREQ hold_speed ; Afslut hvis hastigheden er lig tærskel
    BRCC dec_speed ; Branch hvis R17:R16 er mindre end target (sænk hastighed)
    
    ; Sammenlign med øvre tærskel (for lav hastighed)
    LDI R18, low(TARGET_CYCLES_UPPER)
    LDI R19, high(TARGET_CYCLES_UPPER)
    SUB R18, R16
    SBC R19, R17
    BRCS inc_speed ; Hvis carry er sat (R16:R17 større end R19:R18), skal hastigheden øges!)
    
    RJMP konstant_hastighed_end ; Denne instruktion burde aldrig køre, men bare for en sikkerhedsskyld :)
    
    inc_speed:    
        LDI R17, ACCEL_OCR
        OUT OCR2, R17
        
        RJMP konstant_hastighed_end
    
    dec_speed:
        LDI R17, DECEL_OCR
        OUT OCR2, R17
        
        RJMP konstant_hastighed_end
    
    hold_speed:
        LDI R17, HOLD_OCR
        OUT OCR2, R17
        
        RJMP konstant_hastighed_end
    
    konstant_hastighed_end:
    ; Reset timer
    LDI R16, 0
    OUT TCNT1H, R16
    OUT TCNT1L, R16
    
    ; Pop registre og returner
	POP R16
	OUT	SREG,R16
    POP R19
    POP R18
    POP R17
    POP R16
    RET
	*/