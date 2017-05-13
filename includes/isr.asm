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
    
    ; Check AUTO flag
    SBRS FLAGR, AUTO
    RJMP end_distance
    
    ; Increment CARPOS
    RCALL INC_CARPOS
    
    ; Check RACE flag
    SBRS FLAGR, RACE
    RJMP check_calibration ; If RACE flag not set, check CAL flag
    
    ;-----------;
    ; RACE MODE ;
    ;-----------;
    
    ; Check if cars position >= position of next turn
    LDS R16, CARPOSL
    LDS R17, CARPOSH
    
    LDS R18, TURNPOSL
    LDS R19, TURNPOSH
    
    SUB R18, R16
    SBC R19, R17
    
    BRCC check_TURN_flag ; If TURNPOS > CARPOS, skip toggling TURN flag
    
    toggle_turn_flag:
        LDI R16, (1<<TURN)
        EOR FLAGR, R16
    
    check_TURN_flag:
        SBRS FLAGR, TURN
        RJMP calc_distance_to_turn ; If TURN flag is not set, calculate distance to next turn
        
        RCALL CONSTANT_SPEED
        RJMP end_distance
        
    calc_distance_to_turn:
        ; Distance (number of ticks) is already in R19:R18
        STS TURN_DIST, R18 ; Save low byte in SRAM (high byte not needed, see next line)
        CPI R19, 1 ; If distance to next turn is >= 256, just accelerate
        BRSH accelerate
        ; If distance < 256, calculate brake distance
        
    calc_brake_length:
        IN R16, TCNT1L ; Load TIMER1 value
        IN R17, TCNT1H
        
        LDI R18, low(MAX_CYCLES)
        LDI R19, high(MAX_CYCLES)
        
        CP R16, R18 ; Compare TIMER1 with MAX_CYCLES (high num of cycles = low speed)
        CPC R17, R19
        BRSH brake_length_min
        
        LDI R18, low(MIN_CYCLES)
        LDI R19, high(MIN_CYCLES)
        
        CP R16, R18 ; Compare TIMER1 with MIN_CYCLES (high speed)
        CPC R17, R19
        BRLO brake_length_max
        

        RJMP lookup
        
        brake_length_max:
            LDI R16, 255
            RJMP compare_brake_length
        brake_length_min:
            LDI R16, 0
            RJMP compare_brake_length
            
        lookup:
            LDI R18, low(MIN_CYCLES)
            LDI R19, high(MIN_CYCLES)
            
            SUB R16, R18 ; Subtract MIN_CYCLES from TIMER1 value, to prepare for lookup
            SBC R17, R19
            
            LDI ZL, low(BRAKE_LENGTH<<1) ; Initialize Z-pointer to start of lookup table
            LDI ZH, high(BRAKE_LENGTH<<1)
            
            ADD ZL, R16 ; Place pointer at approriate address in lookup table
            ADC ZH, R17
            
            LPM R16, Z ; Load brake length (number of ticks to reach 2.0 m/s)
            
            LDS R18, OPTIMIZER ; Subtract OPTIMIZER value from brake length
            SUB R16, R18
            
    compare_brake_length: ; Brake length is now stored in R16
        ; Compare brake length to distance to next turn
        LDS R17, TURN_DIST
        CP R16, R17
        BRLO brake ; If brake length >= distance to next turn, brake!
        RJMP accelerate ; Else accelerate
        
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
    
    ; Check CAL flag
    check_calibration:
        SBRS FLAGR, CAL
        RJMP end_distance; RETI if CAL flag is not set
        
    ; Check TURN flag
    SBRS FLAGR, TURN
    RJMP check_strain_entrance ; TURN flag is not set. Check if car is in a turn.
    
    ; TURN flag is set. Check if car has exited the turn.
    SBRS FLAGR, HIGHTURN
    RJMP check_strain_exit_LOW ; If HIGHTURN flag is not set, we are in a low-side turn
    
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
        BRSH turn_exit ; If ADCH exceeds threshold, exit turn
        RJMP end_distance
    
    turn_exit:
        LDI R16, (0xFF)^(1<<TURN) ; Bit mask
        AND FLAGR, R16 ; Clear TURN flag
        RCALL SAVE_TURN_POS ; Save position of turn exit
        RJMP end_distance
    
    check_strain_entrance:
        ; Check if ADCH is above upper threshold
        IN R16, ADCH
        LDS R17, STRAIN_HIGH_IN
        CP R16, R17
        BRSH turn_entrance_HI
        
        ; Check if ADCH is below lower threshold
        LDS R17, STRAIN_LOW_IN
        CP R16, R17
        BRLO turn_entrance_LOW
        
        RJMP end_distance ; Return if threshold have not been exceeded
    
    turn_entrance_HI:
        LDI R16, (1<<TURN)|(1<<HIGHTURN)
        OR FLAGR, R16 ; Set TURN flag and HIGHTURN flag
        RCALL SAVE_TURN_POS
        RCALL INC_NUM_TURNS
        RJMP end_distance
        
    turn_entrance_LOW:
        LDI R16, (1<<TURN)
        OR FLAGR, R16 ; Set TURN flag
        LDI R16, (0xFF)^(1<<HIGHTURN)
        AND FLAGR, R16 ; Clear HIGHTURN flag
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
    
;--------------------;
; FINISH LINE SENSOR ;
;--------------------;
finish_line_interrupt:
    PUSH R16
    IN R16, SREG
    PUSH R16
    
    ; Check AUTO flag
    SBRS FLAGR, AUTO
    RJMP end_finish_line ; Return if AUTO mode is not activated
    
    ; Check RACE flag
    SBRS FLAGR, RACE
    RJMP check_cal_flag ; If RACE flag is not set, check CAL flag
    
    reset_and_return:
        ; Reset Y-pointer and load first turn position
        LDI YL, low(TURNS)
        LDI YH, high(TURNS)
        RCALL LOAD_NEXT_TURN
        
        ; Increment OPTIMIZER (to go faster each lap)
        LDS R16, OPTIMIZER
        INC R16
        STS OPTIMIZER, R16
        
        ; Reset car position and return
        RCALL RESET_CARPOS
        RJMP end_finish_line
    
    ; Check CAL flag
    check_cal_flag:
        SBRS FLAGR, CAL
        RJMP set_calif
        
    ; Clear CAL flag and set RACE flag
    LDI R16, (0xFF)^(1<<CAL)
    AND FLAGR, R16
    LDI R16, (1<<RACE)
    OR FLAGR, R16
    
    ; Initialize OPTIMIZER
    LDI R16, 0
    STS OPTIMIZER, R16
    
    ; Save track length (in number of ticks)
    LDS R16, CARPOSL
    LDS R17, CARPOSH
    STS TRACKLENL, R16
    STS TRACKLENH, R17
    
    RJMP reset_and_return    
    
    set_calif:
        LDI R16, (1<<CAL)
        OR FLAGR, R16
        
        ; Measure strain gauge offset and calculate thresholds
        RCALL SET_THRESHOLDS
    
    end_finish_line:
    POP R16
    OUT SREG, R16
    POP R16
    
    RETI
