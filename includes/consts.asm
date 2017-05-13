;-----------;
; CONSTANTS ;
;-----------;
.EQU	DEFAULT_MOTORSPEED = 115

; Custom flag register
.DEF	FLAGR = R15             ; Use R15 as flag register
.EQU    AUTO = 0                ; Auto mode flag
.EQU	CAL = 1                 ; Calibration mode flag
.EQU	RACE = 2                ; Race mode flag
.EQU	TURN = 3                ; Turn flag
.EQU	HIGHTURN = 4            ; High-side turn flag (to distinguish between left and right turns)

; Min and max for TIMER1 value that can be looked up i BRAKE_LENGTH lookup table
.EQU	MIN_CYCLES = 560        ; Minimum value for number of cycles in BRAKE_LENGTH lookup table
                                ; Equivalent to 4.36 m/s (TIMER1, prescaler = 64)
.EQU	MAX_CYCLES = 1212       ; Maximum value for number of cycles in BRAKE_LENGTH lookup table
                                ; Equivalent to 2.01 m/s (TIMER1, prescaler = 64)
;Strain gauge turn thresholds
.EQU    UPPER_THRESHOLD = 20    ; Threshold for strain gauge to detect turn entry
.EQU    LOWER_THRESHOLD = 15    ; Threshold for strain gauge to detect turn exit
