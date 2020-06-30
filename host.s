;;;
;;; Host loader code for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

C0_D0           := $9E
C1_D0           := $9F
PTR             := $AE
DATA            := $B7

        .include "hostdefs.inc"
        .include "shared.inc"

        .export gij_load

        .segment "GIJ_HOSTCODE"

gij_load:
        stx     PTR             ; save filename 1st char
        sty     PTR+1           ; save filename 2nd char
        lda     SERIAL_OUT
        and     #$FF - (CLOCK_OUT_BIT | DATA_OUT_BIT)
        sta     C0_D0
        eor     #CLOCK_OUT_BIT
        sta     C1_D0
        eor     #(CLOCK_OUT_BIT | DATA_OUT_BIT)
        sta     SERIAL_OUT      ; C0,D1
        jsr     wait_drive_ready
        jsr     send_byte       ; filename length (ignored by drive code)
        lda     PTR
        jsr     send_byte       ; filename 1st char
        lda     PTR+1
        jsr     send_byte       ; filename 2nd char
        jsr     wait_drive_ready
        jsr     receive_byte
        sta     PTR             ; start addr low
        jsr     receive_byte
        sta     PTR+1           ; start addr hi

        ldy     #$00
@loop:  jsr     receive_byte
        cmp     #ESC_BYTE
        bne     @store
        jsr     receive_byte
        cmp     #ESC_BYTE
        beq     @store
        cmp     #DRIVE_OK
        beq     @out_ok
        cmp     #DRIVE_ERROR
        beq     @out_err
        jsr     wait_drive_ready
        jmp     @loop
@store: sta     (PTR),y
        iny
        bne     @loop
        inc     PTR+1
        jmp     @loop
@out_ok:
        clc                     ; Update end addr
        tya
        adc     PTR
        sta     PTR
        bcc     :+
        inc     PTR+1
        clc
@out_err:
:       rts

receive_byte:
        jsr     receive_two_bits
        jsr     receive_two_bits
        jsr     receive_two_bits
        jsr     receive_two_bits
        lda     DATA
        rts

receive_two_bits:
        ldx     C1_D0
        jsr     @r_bit
        nop
        pha
        pla
        ldx     C0_D0
@r_bit: lda     SERIAL_IN
        stx     SERIAL_OUT
        .if .def (__C64__) || .def (__C128__) || .def (__C16__)
        asl
        .endif
        .if .def (__VIC20__)
        lsr
        lsr
        .endif
        ror     DATA
        rts

send_byte:
        sta     DATA
        jsr     send_two_bits
        jsr     send_two_bits
        jsr     send_two_bits
        jsr     send_two_bits
        rts

send_two_bits:
        lda     C1_D0
        jsr     @s_bit
        nop
        lda     C0_D0
@s_bit: lsr     DATA
        bcc     :+
        ora     #DATA_OUT_BIT
:       sta     SERIAL_OUT
        rts

wait_drive_ready:
        jsr     @delay

        lda     #CLOCK_IN_BIT
:       bit     SERIAL_IN
        beq     :-

        lda     C0_D0
        sta     SERIAL_OUT

@delay: ldx     #$32
:       dex
        bne     :-
        rts
