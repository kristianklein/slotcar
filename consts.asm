;-----------;
; CONSTANTS ;
;-----------;
.EQU	DEFAULT_MOTORSPEED = 115

; Race flag register
.DEF	FLAGR = R5		; Flagregister til at bestemme om bilen er i sving eller ej.
.EQU    AUTOF = 0   ; 0 = free running, 1 = auto-mode
.EQU	CALIF = 1   ; 1 = Kalibreringsmode aktiveret (må ikke være 1 samtidig med RACEF)
.EQU	RACEF = 2   ; 1 = Race-mode aktiveret (må ikke være 1 samtidig med CALIF)
.EQU	TURNF = 3   ; 1 = Vi er i et sving. Kør med konstant hastighed.
.EQU	HIGHTURNF = 4  ; 0 = LOW side turn, 1 = HIGH side turn

.EQU	MIN_CYCLES = 560 ; Svarer til 4.36 m/s, bremselængde = 2.5 meter
.EQU	MAX_CYCLES = 1212 ; Svarer til 2.01 m/s, praktisk talt ingen bremselængde

.EQU    UPPER_THRESHOLD = 20 ; Hvor langt fra offsettet skal ADCH være for at gå ind i et sving
.EQU    LOWER_THRESHOLD = 15 ; Hvor langt fra offsettet skal ADCH være for at gå ud af et sving
