;-------------------;
;   SUB-ROUTINES 	;
;-------------------;

; Antal cycles er angivet inklusiv RCALL og RET

;-------------;
; DELAY 1 SEC ;
; 16e6 cycles ;
;-------------;

DELAY_1SEC: ; Præcis 16.000.000 instruktioner (inkl. return)
	PUSH	R23
    PUSH	R24
    PUSH	R25
    
    LDI		R23, 62 ;Load 61 into R23 (16 MHz = 61 loops, 1 MHz = 4 loops)
	outer_loop: 
		LDI		R24, low(64514) ;Clear R24 and R25 to use for a 16-bit word
		LDI		R25, high(64514)
		inner_loop: ; 4 instructions per loop if no overflow
			SBIW	R25:R24, 1 ;Subtract 1 from 16-bit word in R25:R24
			BRNE	inner_loop ;Unless R25:R24 overflows, go back to inner_loop
	
	DEC		R23 ;Decrement R23
    NOP
    NOP
	BRNE	outer_loop ;Unless R23 overflows go back to outer_loop
    
    LDI R23, 47
    fine_adjust_loop:
        DEC R23
        BRNE fine_adjust_loop

    NOP
    NOP
    POP		R25
    POP		R24
    POP		R23
    
	RET
;--------------------;
; KONSTANT HASTIGHED ;
;--------------------;
KONSTANT_HASTIGHED:
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
    POP R19
    POP R18
    POP R17
    POP R16
    RET

;------------------;
; INCREMENT BILPOS ;
; 17 instruktioner ;
;------------------;
INC_BILPOS:
    PUSH R24
    PUSH R25
    
    ; Hent position
    LDS R24, BILPOSL
    LDS R25, BILPOSH
    
    ; Increment
    ADIW R25:R24, 1
    
    ; Gem position
    STS BILPOSL, R24
    STS BILPOSH, R25
    
    POP R25
    POP R24
    RET
    
;----------------------------;
; SAVE TURN POSITION TO SRAM ;
;----------------------------;  
SAVE_TURN_POS:
    PUSH R24
    PUSH R25
    
    LDS R24, BILPOSL
    LDS R25, BILPOSH
    
    ; Gem high byte først
    ST Y+, R25
    ST Y+, R24
    
    POP R25
    POP R24
    
    RET   
    
;--------------;
; RESET BILPOS ;
; 12 instruk.  ;
;--------------;
RESET_BILPOS:
    PUSH R16
    
    ; Skriv 0 til BILPOSL og BILPOSH
    LDI R16, 0
    STS BILPOSL, R16
    STS BILPOSH, R16
    
    POP R16
    RET

;-----------------------------;
; SET STRAIN GAUGE THRESHOLDS ;
;-----------------------------;

SET_THRESHOLDS:
    PUSH R16
    PUSH R17
    
    IN R16, ADCH
    STS STRAINOFFSET, R16
    
    ; Indgangstærksel til HIGH side sving
    LDI R17, UPPER_THRESHOLD
    ADD R16, R17
    STS STRAIN_HIGH_IN, R16
    
    ; Indgangstærskel til LOW side sving
    LDS R16, STRAINOFFSET
    SUB R16, R17
    STS STRAIN_LOW_IN, R16
    
    ; Udgangstærskel til HIGH side sving
    LDS R16, STRAINOFFSET
    LDI R17, LOWER_THRESHOLD
    ADD R16, R17
    STS STRAIN_HIGH_OUT, R16
    
    ; Udgangstærskel til LOW side sving
    LDS R16, STRAINOFFSET
    SUB R16, R17
    STS STRAIN_LOW_OUT, R16
    
    POP R17
    POP R16
    RET

;-------------------------;
; LOAD NEXT TURN POSITION ;
;-------------------------;

LOAD_NEXT_TURN:
    PUSH R16
    PUSH R17
    
    LD R16, Y+ ; Husk at positioner er gemt som HIGH:LOW, så
    LD R17, Y+ ; R16 er HIGH, R17 er LOW
    
    STS SVINGPOSH, R16
    STS SVINGPOSL, R17
    
    POP R17
    POP R16
    RET

;---------------------------;
; INCREMENT NUMBER OF TURNS ;
;---------------------------;
INC_NUM_TURNS:
    PUSH R16
    
    LDS R16, NUM_TURNS
    INC R16
    STS NUM_TURNS, R16
    
    POP R16
    RET

;---------------------------;
; TRANSMIT CALIBRATION DATA ;
;---------------------------;
TRANSMIT_CAL:
    PUSH ZL
    PUSH ZH
    PUSH R17
    
    ; Send banens længde
    LDI ZL, low(tracklen_message<<1)
    LDI ZH, high(tracklen_message<<1)
    RCALL TRANSMIT_STRING
    RCALL TRANSMIT_NEWLINE
    LDS R17, TRACKLENH
    RCALL TRANSMIT
    LDS R17, TRACKLENL
    RCALL TRANSMIT
    RCALL TRANSMIT_NEWLINE
    
    ; Send antal sving
    LDI ZL, low(numturns_message<<1)
    LDI ZH, high(numturns_message<<1)
    RCALL TRANSMIT_STRING
    RCALL TRANSMIT_NEWLINE
    LDS R17, NUM_TURNS
    RCALL TRANSMIT
    RCALL TRANSMIT_NEWLINE
        
    POP R17
    POP ZH
    POP ZL
    RET
;------------------;
; TRANSMIT STRING  ;
; End with 0x00    ;
; Address in ZH:ZL ;
;------------------;
TRANSMIT_STRING:
    PUSH R17
    
    send_again:
        LPM R17, Z+
        CPI R17, 0
        BREQ end_transmit_string
        
        RCALL TRANSMIT
        RJMP send_again    
    
    end_transmit_string:
    POP R17
    RET
    
TRANSMIT_NEWLINE:
    PUSH R17
    
    LDI R17, 0x0D ; \r
    RCALL TRANSMIT
    LDI R17, 0x0A ; \n
    RCALL TRANSMIT

    POP R17
    RET
;------------------------;
; BLUETOOTH TRANSMIT R17 ;
;------------------------;    
TRANSMIT:
    SBIS UCSRA, UDRE	;Is UDR empty?
    RJMP Transmit		;if not, wait some more
    OUT  UDR, R17		;Send R17 to UDR
    RET
    
;-----------------------;
; BLUETOOTH RECEIVE R17 ;
;-----------------------;    
RECEIVE:
    SBIS UCSRA, RXC
	RJMP Receive        ; Vent på at modtage byte
	IN	R17, UDR
	RET
