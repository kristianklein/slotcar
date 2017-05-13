;-------------------;
;       SETUP	    ;
;-------------------;
setup:
    ;---------------;
    ; STACK POINTER ;
    ;---------------;
    ISP R16, RAMEND	

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
    ; Start TIMER1 in normal mode with prescaler = 64
	LDI		R16, (1<<CS11)|(1<<CS10)
	OUT		TCCR1B, R16

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
    ; Read ADC0 and left adjust result (8-bits in ADCH)
	LDI		R16, (1<<ADLAR)
	OUT		ADMUX, R16
	
    ; Enable, start conversion, auto-trigger, prescaler = 128 (f = 125 kHz)
	LDI		R16, (1<<ADEN)|(1<<ADSC)|(1<<ADATE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	OUT		ADCSRA, R16

    ;-----------;              
    ; BLUETOOTH ;
    ;-----------;
	LDI		R16, (1<<TXEN)|(1<<RXEN) ; Enable transmit/receive
	OUT		UCSRB, R16
	LDI		R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL) ; Set character size = 8 bits
	OUT		UCSRC, R16
	LDI		R16, 103 ; Set baud rate to 9600 (error = 0,2%)
	OUT		UBRRL, R16 

	;-----;
    ; PWM ;
    ;-----;
    ; Fast PWM, non-inverted mode, prescaler = 1 (f = 62.5 kHz)
	LDI		R16, 0b01101001 ; (1<<WGM20)|(1<<COM21)|(1<<WGM21)|(1<<CS20)
	OUT		TCCR2, R16

    ;---------------;
    ; MISCELLANEOUS ;
    ;---------------;
    ; Initialize custom flag register
	LDI		R16, 0 
	MOV		FLAGR, R16
