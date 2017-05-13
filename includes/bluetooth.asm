;--------------------;
; BLUETOOTH PROTOCOL ;
;--------------------;
; Running continuously in main

RCALL   RECEIVE ; Received byte always placed in R17 (see sub-routines)

CPI		R17, 0x55
BREQ	set_command
CPI		R17, 0xAA
BREQ	get_command

RJMP	main

set_command:
    RCALL   RECEIVE
    
    CPI		R17, 0x10
    BREQ	set_ocr
    CPI		R17, 0x11
    BREQ	set_stop
    CPI		R17, 0x12
    BREQ	set_auto
        
    RJMP	main

get_command:
    RCALL   RECEIVE
    CPI		R17, 0x02			
    BREQ	get_ocr
    CPI		R17, 0x03
    BREQ    get_speed
    CPI     R17, 0x04
    BREQ	get_position
    CPI		R17, 0x05
    BREQ	get_straingauge
    CPI		R17, 0x06
    BREQ	get_tracklength
    CPI		R17, 0x07
    BREQ	get_numturns

    RJMP main

;--------------;
; SET ROUTINES ;
;--------------;
set_ocr:
    RCALL   RECEIVE
    OUT		OCR2, R17 ; Set motor speed to received byte
    RJMP	main

set_stop:
    LDI		R16, 0 ; Stop motor
    OUT		OCR2, R16
    RJMP	main

set_auto:
    LDI     R16, (1<<AUTO) ; Set AUTO flag
    OR      FLAGR, R16
    LDI		R17, DEFAULT_MOTORSPEED ; Start motor
    OUT		OCR2, R17
    RJMP	main

;--------------------;
; GET/REPLY ROUTINES ;
;--------------------;
get_ocr:
    IN      R17, OCR2
    RCALL   TRANSMIT
    RJMP	main

get_speed:
    LDS     R17, SPEEDH
    RCALL   TRANSMIT
    LDS     R17, SPEEDL
    RCALL   TRANSMIT
    RJMP    main

get_position:
    LDS     R17, CARPOSH
    RCALL   TRANSMIT
    LDS     R17, CARPOSL
    RCALL   TRANSMIT
    RJMP	main

get_straingauge:
    LDS     R17, ADCH
    RCALL   TRANSMIT
    RJMP	main

get_tracklength:
    LDS     R17, TRACKLENH
    RCALL   TRANSMIT
    LDS     R17, TRACKLENL
    RCALL   TRANSMIT
    RJMP	main

get_numturns:
    LDS     R17, NUM_TURNS
    RCALL   TRANSMIT
    RJMP	main
