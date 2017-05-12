;------------;
; INTERRUPTS ;
;------------;
;----------------;
; DISTANCESENSOR ;
;----------------;
distance_interrupt:
    PUSH R16
    IN R16, SREG
    PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
    
	;------------;
    ; FLAG CHECK ;
    ;------------;
    
    ; Tjek AUTOF
    SBRS FLAGR, AUTOF
    RJMP end_distance
    
    ; Increment BILPOS
    RCALL INC_BILPOS
    
    ;Tjek RACEF
    SBRS FLAGR, RACEF
    RJMP check_calibration ; Hvis RACEF ikke er sat, tjek CALIF
    
    ;-----------;
    ; RACE MODE ;
    ;-----------;
    
    ; Tjek om bilens position er >= positionen af næste sving
    LDS R16, BILPOSL
    LDS R17, BILPOSH
    
    LDS R18, SVINGPOSL
    LDS R19, SVINGPOSH
    
    SUB R18, R16
    SBC R19, R17
    
    BRCC check_TURNF ; Hvis SVINGPOS er større end BILPOS, lad være med at toggle TURNF
    
    toggle_turnf:
        LDI R16, (1<<TURNF)
        EOR FLAGR, R16
    
    check_TURNF:
        SBRS FLAGR, TURNF
        RJMP calc_distance_to_turn ; Hvis TURNF ikke er sat, beregn længden til næste sving
        
        RCALL KONSTANT_HASTIGHED
        RJMP end_distance
        
    calc_distance_to_turn:
        ; Distancen (i antal ticks) ligger allerede i R19:R18
        STS SVING_DIST, R18 ; Gem afstanden til næste sving i SRAM (kun low byte, hvis high byte er > 0 brancher vi nedenfor)
        CPI R19, 1 ; Hvis afstanden til næste sving er >= 256 (2.5 meter!), så kan vi roligt give gas
        BRSH accelerate
        ; Ellers går vi bare videre til at beregne bremselængden
        
    calc_brake_length:
        IN R16, TCNT1L ; Hent timerværdi
        IN R17, TCNT1H
        
        LDI R18, low(MAX_CYCLES)
        LDI R19, high(MAX_CYCLES)
        
        CP R16, R18 ; Sammenlign timerværdi med MAX_CYCLES (lav hastighed, mest sandsynligt)
        CPC R17, R19
        BRSH brake_length_min
        
        LDI R18, low(MIN_CYCLES)
        LDI R19, high(MIN_CYCLES)
        
        CP R16, R18 ; Sammenlign timerværdi med MIN_CYCLES (høj hastighed)
        CPC R17, R19
        BRLO brake_length_max
        

        RJMP lookup
        
        brake_length_max:
            LDI R16, 255
            RJMP compare_brake_length ; Brancher disse to rigtigt?
        brake_length_min:
            LDI R16, 0
            RJMP compare_brake_length
            
        lookup:
            LDI R18, low(MIN_CYCLES)
            LDI R19, high(MIN_CYCLES)
            
            SUB R16, R18 ; Træk MIN_CYCLES fra timerværdien, så den kan slås op i lookup table
            SBC R17, R19
            
            LDI ZL, low(BRAKE_LENGTH<<1) ; Initialiser Z til starten af lookup table
            LDI ZH, high(BRAKE_LENGTH<<1)
            
            ADD ZL, R16 ; Sæt pointeren det rigtige sted i lookup tabellen
            ADC ZH, R17
            
            LPM R16, Z ; Hent bremselængden i ticks fra lookup table
            
            LDS R18, OPTIMIZER ; Træk OPTIMIZER-værdien fra bremselængden
            SUB R16, R18
            
    compare_brake_length: ; Bremselængden (i ticks) ligger i R16
        ; Sammenlign bremselængde og afstand til sving
        LDS R17, SVING_DIST
        CP R16, R17
        BRLO brake ; Hvis bremselængden er større end eller lig med afstanden til næste sving
        RJMP accelerate
        
    brake:
        LDI R16, 0
        OUT OCR2, R16
        RJMP end_distance
    
    accelerate:
        LDI R16, 0xFF
        OUT OCR2, R16
        RJMP end_distance
            
    ;------------------;
    ; CALIBRATION MODE ;
    ;------------------;
    
    ; Tjek CALIF
    check_calibration:
        SBRS FLAGR, CALIF
        RJMP end_distance; RETI hvis CALIF ikke er sat
        
    ; Tjek TURNF (for kalibrering)
    SBRS FLAGR, TURNF
    RJMP check_strain_entrance ; TURNF ikke sat. Check om bilen er kommet ind i et sving.
    
    ; TURNF er sat. Tjek om vi er kommet ud af svinget igen.
    SBRS FLAGR, HIGHTURNF
    RJMP check_strain_exit_LOW ; Hvis HIGHTURNF ikke er sat, er vi i et LOW side sving 
    
    check_strain_exit_HIGH:
        IN R16, ADCH
        LDS R17, STRAIN_HIGH_OUT
        CP R16, R17
        BRLO turn_exit
        RJMP end_distance
    
    check_strain_exit_LOW:
        IN R16, ADCH
        LDS R17, STRAIN_LOW_OUT
        CP R16, R17
        BRSH turn_exit ; Hvis ADCH overskrider tærsklen, afslut svinget
        RJMP end_distance
    
    turn_exit:
        LDI R16, (0xFF)^(1<<TURNF) ; Bit maske
        AND FLAGR, R16 ; Clear TURNF
        RCALL SAVE_TURN_POS ; Gem udgang af sving i SRAM
        RJMP end_distance
    
    check_strain_entrance:
        ; Tjek om ADCH er højere end den øvre tærskel
        IN R16, ADCH
        LDS R17, STRAIN_HIGH_IN
        CP R16, R17
        BRSH turn_entrance_HI
        
        ; Tjek om ADCH er lavere end den nedre tærksel
        LDS R17, STRAIN_LOW_IN
        CP R16, R17
        BRLO turn_entrance_LOW
        
        RJMP end_distance ; Returner hvis tærsklen ikke er brudt
    
    turn_entrance_HI:
        LDI R16, (1<<TURNF)|(1<<HIGHTURNF)
        OR FLAGR, R16 ; Sæt TURNF og HIGHTURNF
        RCALL SAVE_TURN_POS
        RCALL INC_NUM_TURNS
        RJMP end_distance
        
    turn_entrance_LOW:
        LDI R16, (1<<TURNF)
        OR FLAGR, R16 ; Sæt TURNF
        LDI R16, (0xFF)^(1<<HIGHTURNF)
        AND FLAGR, R16 ; Clear HIGHTURNF 
        RCALL SAVE_TURN_POS
        RCALL INC_NUM_TURNS
        RJMP end_distance
    
    end_distance:
    ; Reset TIMER1
    LDI R16, 0
    OUT TCNT1H, R16
    OUT TCNT1L, R16
    
    POP R19
    POP R18
    POP R17
    POP R16
    OUT SREG, R16
    POP R16
    
    
    RETI
    
;-----------------;
; MÅLSTREGSSENSOR ;
;-----------------;
finish_line_interrupt:
    PUSH R16
    IN R16, SREG
    PUSH R16
    
    ; Tjek AUTOF
    SBRS FLAGR, AUTOF
    RJMP end_finish_line ; Hvis auto-mode ikke er aktiveret, returner.
    
    ; Tjek RACEF
    SBRS FLAGR, RACEF
    RJMP check_calif ; Hvis race-flaget ikke er sat, check kalibrerings-flaget
    
    reset_and_return:
        ; Reset Y-pointeren og hent første sving
        LDI YL, low(SVING)
        LDI YH, high(SVING)
        RCALL LOAD_NEXT_TURN
        
        ; Incrementer OPTIMIZER
        LDS R16, OPTIMIZER
        INC R16
        STS OPTIMIZER, R16
        
        ; DEBUGGING: Stop car and send calibration data via bluetooth
        RCALL TRANSMIT_CAL
        
        ; Reset bilposition og returner
        RCALL RESET_BILPOS
        RJMP end_finish_line
    
    ; Check CALIF
    check_calif:
        SBRS FLAGR, CALIF
        RJMP set_calif
        
    ; Clear CALIF og sæt RACEF
    LDI R16, (0xFF)^(1<<CALIF)
    AND FLAGR, R16
    LDI R16, (1<<RACEF)
    OR FLAGR, R16
    
    ; Initialiser OPTIMIZER
    LDI R16, 0
    STS OPTIMIZER, R16
    
    ; Gem banens længde
    LDS R16, BILPOSL
    LDS R17, BILPOSH
    STS TRACKLENL, R16
    STS TRACKLENH, R17
    
    RJMP reset_and_return    
    
    set_calif:
        LDI R16, (1<<CALIF)
        OR FLAGR, R16
        
        ; Mål strain gauge offset og beregn tærsklerne
        RCALL SET_THRESHOLDS
    
    end_finish_line:
    POP R16
    OUT SREG, R16
    POP R16
    
    RETI
