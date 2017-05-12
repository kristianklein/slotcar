;-----------;
; BLUETOOTH ;
;-----------;
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
        BREQ	set1_blink2		;Branch hvis det er en set1_blink2 kommand

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
