;;;
;;; Host init code for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

PTR             := $9E
nbytes           = 25

        .include "hostdefs.inc"

        .import __GIJ_DRIVECODE_LOAD__
        .import __GIJ_DRIVECODE_RUN__
        .import __GIJ_DRIVECODE_SIZE__
        .import drive_code_main
        .export gij_load_init

        .segment "GIJ_INITCODE"

gij_load_init:
        lda     #<__GIJ_DRIVECODE_LOAD__
        ldx     #>__GIJ_DRIVECODE_LOAD__
        sta     PTR
        stx     PTR+1

@loop:  jsr     init_mem_write
        ldy     #$00
:       lda     (PTR),y
        jsr     CIOUT
        iny
        cpy     #nbytes
        bne     :-
        jsr     UNLSN

        tya
        clc
        adc     PTR
        sta     PTR
        bcc     :+
        inc     PTR+1
:       cmp     #<(__GIJ_DRIVECODE_LOAD__ + __GIJ_DRIVECODE_SIZE__)
        lda     PTR+1
        sbc     #>(__GIJ_DRIVECODE_LOAD__ + __GIJ_DRIVECODE_SIZE__)
        bcc     @loop

        jsr     mem_exec

        .if .def (__C64__) || .def (__C128__)
        lda     SERIAL_OUT
        and     #%11000111
        .endif
        .if .def (__VIC20__)
        lda     VIA1_PA1
        and     #%01111111
        sta     VIA1_PA1
        lda     SERIAL_OUT
        and     #%11011101
        .endif
        .if .def (__C16__)
        lda     SERIAL_OUT
        and     #%11111000
        .endif
        sta     SERIAL_OUT
        rts

send_m_cmd:
        pha
        lda     DEVNUM
        jsr     LISTEN
        lda     #$6F
        jsr     SECOND
        lda     #'m'
        jsr     CIOUT
        lda     #'-'
        jsr     CIOUT
        pla
        jmp     CIOUT

init_mem_write:
        lda     #'w'
        jsr     send_m_cmd
        lda     PTR
        sec
        sbc     #<(__GIJ_DRIVECODE_LOAD__ - __GIJ_DRIVECODE_RUN__)
        php
        jsr     CIOUT
        plp
        lda     PTR+1
        sbc     #>(__GIJ_DRIVECODE_LOAD__ - __GIJ_DRIVECODE_RUN__)
        jsr     CIOUT
        lda     #nbytes
        jmp     CIOUT

mem_exec:
        lda     #'e'
        jsr     send_m_cmd
        lda     #<drive_code_main
        jsr     CIOUT
        lda     #>drive_code_main
        jsr     CIOUT
        jmp     UNLSN
