;-----------;
; VARIABLES ;
;-----------;
.DSEG
TURNS:              .BYTE	200		; Reserve 200 bytes for turn positions
TURNPOSL:           .BYTE   1       ; Position of next turn (low byte)
TURNPOSH:           .BYTE   1       ; Position of next turn (high byte)
CARPOSL:            .BYTE   1       ; Car position (low byte)
CARPOSH:            .BYTE   1       ; Car position (high byte)
TURN_DIST:          .BYTE   1       ; Distance to next turn
NUM_TURNS:          .BYTE   1       ; Number of turns on the track
TRACKLENL:          .BYTE   1       ; Track length (low byte)
TRACKLENH:          .BYTE   1       ; Track length (high byte)

STRAINOFFSET:       .BYTE   1       ; Strain gauge offset value
STRAIN_HIGH_IN:     .BYTE   1       ; Strain gauge entrance threshold (high side)
STRAIN_HIGH_OUT:    .BYTE   1       ; Strain gauge exit threshold (high side)
STRAIN_LOW_IN:      .BYTE   1       ; Strain gauge entrance threshold (low side)
STRAIN_LOW_OUT:     .BYTE   1       ; Strain gauge exit threshold (low side)

SPEEDL:	            .BYTE	1       ; Speed from previous measurement (low byte) *used for smoothing*
SPEEDH:             .BYTE	1       ; Speed from previous measurement (high byte)
OPTIMIZER:          .BYTE   1       ; This value increases each lap and is subtracted 
                                    ; from the brake length to drive faster into turns
