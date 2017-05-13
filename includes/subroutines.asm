;-------------------;
;   SUB-ROUTINES 	;
;-------------------;
; Number of cycles are including RCALL and RET

;-------------;
; DELAY 1 SEC ;
;-------------;
; 16 million cycles (1 sec @ 16 MHz clock frequency)
DELAY_1SEC: 
	PUSH	R23
    PUSH	R24
    PUSH	R25
    
    LDI		R23, 62
	outer_loop: 
		LDI		R24, low(64514)
		LDI		R25, high(64514)
		inner_loop:
			SBIW	R25:R24, 1
			BRNE	inner_loop
	
	DEC		R23
    NOP
    NOP
	BRNE	outer_loop
    
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
;----------------;
; CONSTANT SPEED ;
;----------------;
CONSTANT_SPEED:
    .EQU TARGET_CYCLES_UPPER = 1500 ; 1.95 m/s
    .EQU TARGET_CYCLES_LOWER = 1400 ; 2.12 m/s
    
    .EQU ACCEL_OCR = 200 ; Set OCR2 to this value if accelerating
    .EQU DECEL_OCR = 50  ; Set OCR2 to this value if decelerating
    .EQU HOLD_OCR = 120  ; Set OCR2 to this value if speed is within thresholds

    PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
    
    ; Load timer value (low byte first)
    IN R16, TCNT1L
    IN R17, TCNT1H
    
    ; Load previous timer value and store current
    LDS R18, SPEEDL
    LDS R19, SPEEDH
    STS SPEEDL, R16
    STS SPEEDH, R17
    
    ; Calculate average
    ADD R16, R18
    ADC R17, R19
    BRCS inc_speed ; If addition overflows, speed is very low
    LSR R17
    ROR R16
    
    ; Compare with lower threshold (high speed)
    LDI R18, low(TARGET_CYCLES_LOWER)
    LDI R19, high(TARGET_CYCLES_LOWER)
    SUB R18, R16
    SBC R19, R17 ; R19:R18 - R17:R16 (if carry is NOT set, reduce speed)
    
    BREQ hold_speed ; Return if value within limits
    BRCC dec_speed ; Branch if R17:R16 is less than target
    
    ; Compare with upper threshold (low speed)
    LDI R18, low(TARGET_CYCLES_UPPER)
    LDI R19, high(TARGET_CYCLES_UPPER)
    SUB R18, R16
    SBC R19, R17
    BRCS inc_speed ; If carry is set (R16:R17 > R19:R18), increase speed
    
    RJMP konstant_hastighed_end ; Safety instruction. Should never actually run.
    
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
    
    ; Pop registers and return
    POP R19
    POP R18
    POP R17
    POP R16
    RET

;------------------------;
; INCREMENT CAR POSITION ;
;------------------------;
INC_CARPOS:
    PUSH R24
    PUSH R25
    
    ; Load car position
    LDS R24, CARPOSL
    LDS R25, CARPOSH
    
    ; Increment
    ADIW R25:R24, 1
    
    ; Save car position
    STS CARPOSL, R24
    STS CARPOSH, R25
    
    POP R25
    POP R24
    RET
    
;----------------------------;
; SAVE TURN POSITION TO SRAM ;
;----------------------------;  
SAVE_TURN_POS:
    PUSH R24
    PUSH R25
    
    LDS R24, CARPOSL
    LDS R25, CARPOSH
    
    ; Save high byte first!
    ST Y+, R25
    ST Y+, R24
    
    POP R25
    POP R24
    
    RET   
    
;--------------------;
; RESET CAR POSITION ;
;--------------------;
RESET_CARPOS:
    PUSH R16
    
    LDI R16, 0
    STS CARPOSL, R16
    STS CARPOSH, R16
    
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
    
    ; Entrance threshold for HIGH side turn
    LDI R17, UPPER_THRESHOLD
    ADD R16, R17
    STS STRAIN_HIGH_IN, R16
    
    ; Entrance threshold for LOW side turn
    LDS R16, STRAINOFFSET
    SUB R16, R17
    STS STRAIN_LOW_IN, R16
    
    ; Exit threshold for HIGH side turn
    LDS R16, STRAINOFFSET
    LDI R17, LOWER_THRESHOLD
    ADD R16, R17
    STS STRAIN_HIGH_OUT, R16
    
    ; Exit threshold for HIGH side turn
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
    
    LD R16, Y+ ; Remember: Positions are stored big endian (High byte in lowest memory location)
    LD R17, Y+
    
    STS TURNPOSH, R16
    STS TURNPOSL, R17
    
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
    PUSH R17
    
    ; Transmit track length
    LDS R17, TRACKLENH
    RCALL TRANSMIT
    LDS R17, TRACKLENL
    RCALL TRANSMIT
    RCALL TRANSMIT_NEWLINE
    
    ; Transmit number of turns
    LDS R17, NUM_TURNS
    RCALL TRANSMIT
    RCALL TRANSMIT_NEWLINE
        
    POP R17
    RET
;--------------------;
; TRANSMIT STRING    ;
;--------------------;
; Place strings in CSEG and end with a 0-byte
; Load address into ZH:ZL (left shifted once) before calling subroutine
TRANSMIT_STRING:
    PUSH    R17
    
    send_again:
        LPM     R17, Z+
        CPI     R17, 0
        BREQ    end_transmit_string
        
        RCALL   TRANSMIT
        RJMP    send_again    
    
    end_transmit_string:
    POP     R17
    RET
    
TRANSMIT_NEWLINE:
    PUSH    R17
    
    LDI     R17, 0x0D ; \r
    RCALL   TRANSMIT
    LDI     R17, 0x0A ; \n
    RCALL   TRANSMIT

    POP     R17
    RET
;------------------------;
; BLUETOOTH TRANSMIT R17 ;
;------------------------;    
TRANSMIT:
    SBIS UCSRA, UDRE
    RJMP Transmit		; Wait for UDR to be empty
    OUT  UDR, R17		; Send R17
    RET
    
;-----------------------;
; BLUETOOTH RECEIVE R17 ;
;-----------------------;    
RECEIVE:
    SBIS UCSRA, RXC     ; Check if byte received
	RJMP Receive        ; If not, keep checking
	IN	R17, UDR        ; Received byte placed in R17
	RET
