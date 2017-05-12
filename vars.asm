;-----------;
; VARIABLES ;
;-----------;
.DSEG
SVING:          .BYTE	200		; Reservér 200 pladser til sving_ticks
SVINGPOSL:      .BYTE   1       ; Positionen for næste sving (low byte)
SVINGPOSH:      .BYTE   1       ; Positionen for næste sving (high byte)
BILPOSL:        .BYTE   1       ; Bilens position (low byte)
BILPOSH:        .BYTE   1       ; Bilens position (high byte)
SVING_DIST:     .BYTE   1       ; Afstand til næste sving-event
NUM_TURNS:      .BYTE   1       ; Antal sving på banen
TRACKLENL:      .BYTE   1       ; Banens længde (low byte)
TRACKLENH:      .BYTE   1       ; Banens længde (high byte)

STRAINOFFSET:   .BYTE   1       ; Strain gauge offset værdien
STRAIN_HIGH_IN: .BYTE   1       ; Strain gauge indgangstærskel (højresving)
STRAIN_HIGH_OUT: .BYTE   1       ; Strain gauge udgangstærskel (højresving)
STRAIN_LOW_IN:  .BYTE   1       ; Strain gauge ingangstærskel (venstresving)
STRAIN_LOW_OUT: .BYTE   1       ; Strain gauge udgangstærskel (venstresving)

SPEEDL:	        .BYTE	1       ; Sidst målte hastighed (low byte)
SPEEDH:         .BYTE	1       ; Sidst målte hastighed (high byte)
TIMER1L:	    .BYTE	1       ; TIMER1 værdi (low byte)
TIMER1H:	    .BYTE	1       ; TIMER1 værdi (high byte)
OPTIMIZER:      .BYTE   1       ; Hvor mange ticks der skal skæres af bremselængden hver runde

