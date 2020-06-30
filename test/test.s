;;;
;;; Simple test code for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

        .segment "LOADADDR"
        .export  __LOADADDR__: absolute = 1
        .addr *+2

       .include "cbm_kernal.inc"

        .if .def (__VIC20__)
          .include "vic20.inc"
          COLOR_MEM := $9600
          FN_CH1 = '1'
          FN_CH2 = 'e'
        .endif

        .if .def (__C64__)
          .include "c64.inc"
          FN_CH1 = '0'
          FN_CH2 = '4'
        .endif

        .if .def (__C128__)
          .include "c128.inc"
          FN_CH1 = '0'
          FN_CH2 = '4'
        .endif

        .if .def (__C16__)
          .include "c16.inc"
          FN_CH1 = '0'
          FN_CH2 = 'c'
        .endif

        .segment "CODE"

        .import gij_load_init
        .import gij_load

        .addr   Next
        .word   $ffff           ; Line number
        .byte   $9E             ; SYS token
        .byte   <(((Start /  1000) .mod 10) + '0')
        .byte   <(((Start /   100) .mod 10) + '0')
        .byte   <(((Start /    10) .mod 10) + '0')
        .byte   <(((Start /     1) .mod 10) + '0')
        .byte   $00             ; End of BASIC line
Next:   .word   0               ; BASIC end marker
Start:

        jsr     gij_load_init

        jsr     CLRSCR

        .if .def (__VIC20__)
        ; Fill color memory
        ldx     #$00
        lda     CHARCOLOR
:       sta     COLOR_MEM,x
        sta     COLOR_MEM+$0100,x
        inx
        bne     :-
        .endif

        ; Delay, make sure drive code is running and ready
        ldy     #30
:       dex
        bne     :-
        dey
        bne     :-

        ldx     #FN_CH1
        ldy     #FN_CH2

        jsr     gij_load
        rts
