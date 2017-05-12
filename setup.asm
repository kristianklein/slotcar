;-------------------;
;       SETUP	    ;
;-------------------;
setup:
    ;---------------;
    ; STACK POINTER ;
    ;---------------;
    LDI		R16, low(RAMEND)
    OUT		SPL, R16
    LDI		R16, high(RAMEND)
    OUT		SPH, R16	

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
    
	;--------;
    ; TIMER1 ;
    ;--------;
	LDI		R16, (1<<CS11)|(1<<CS10)
	OUT		TCCR1B, R16		; Prescaler = 64

    ;------------;
    ; INTERRUPTS ;
    ;------------;
    ; Enable interrupts INT0 and INT1 on falling edge
	LDI		R16, (1<<INT0)|(1<<INT1) ; Enable INT0 and INT1
	OUT		GICR, R16
	LDI		R16, (1<<ISC01)|(1<<ISC11) ; Set INT0 and INT1 to trigger on falling edge
	OUT		MCUCR, R16
	SEI ; Enable global interrupts

	;------------;
	; Set up ADC ;
	;------------;
	LDI		R16, (1<<ADLAR) ; AREF, left adjusted, ADC0, 
	OUT		ADMUX, R16
	
    ; Enable, start conversion, auto-trigger, prescaler = 128
	LDI		R16, (1<<ADEN)|(1<<ADSC)|(1<<ADATE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	OUT		ADCSRA, R16		; ADC_frekvens = 125 kHz

    ;-----------;              
    ; BLUETOOTH ;
    ;-----------;
	LDI		R16, (1<<TXEN)|(1<<RXEN) ; Enable transmit/receive
	OUT		UCSRB, R16
	LDI		R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL) ; Set character size = 8 bits
	OUT		UCSRC, R16
	LDI		R16, 103		;16MHz Sætter baudrate til 9600, med U2X = 0 og error = 0,2%
	OUT		UBRRL, R16 

	;-----;
    ; PWM ;
    ;-----;
    ; Fast PWM, non-inverted mode, prescaler = 1 (f_s = 62.5 kHz)
	LDI		R16, 0b01101001 ; (1<<WGM20)|(1<<COM21)|(1<<WGM21)|(1<<CS20)
	OUT		TCCR2, R16

    ;-----------;
    ; RACE MODE ;
    ;-----------;
    ; Initialiser FLAGR (normalvis til 0x00)
	LDI		R16, (1<<AUTOF) ; BEMÆRK! Her er AUTOF sat pga. debugging
	MOV		FLAGR,R16
	
    ; Initialisér antal motorticks
	;LDI		R16, 0x00
	;MOV		R9, R16
	;MOV		R10, R16
	;MOV		R15, R16
    ; IKKE NØDVENDIG LÆNGERE, DA DER ER OPRETTET EN VARIABEL

	; Midlertidig setup af y-pointer
	;LDI		YL,LOW(sving)	
	;LDI		YH,HIGH(sving)
    ; IKKE NØDVENDIG LÆNGERE, DA DEN INITIALISERES I FINISH_LINE_INTERRUPT

	RCALL	delay_1sec
	RCALL	delay_1sec
	
	; Set motor speed
	LDI		R16, DEFAULT_MOTORSPEED
	OUT		OCR2, R16
