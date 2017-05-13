;-------;
; MACRO ;
;-------;

; Initialize stack pointer
.MACRO  ISP
        LDI @0, low(@1)
        OUT SPL, @0
        LDI @0, high(@1)
        OUT SPH, @0
.ENDMACRO
