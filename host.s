;;;
;;; Host loader code for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

.ifdef NO_ZERO_PAGE
  end_address   := store+1
.else
  C0_D0         := $9E
  C1_D0         := $9F
  PTR           := $AE
  DATA          := $93
  end_address   := PTR
  start_address := $029F
.endif

        .include "hostdefs.inc"
        .include "shared.inc"

        .export gij_load
        .export start_address
        .export end_address

        .segment "GIJ_HOSTCODE"

gij_load:
.ifdef NO_ZERO_PAGE
        stx     @n1+1           ; save filename 1st char
        sty     @n2+1           ; save filename 2nd char
.else
        stx     PTR             ; save filename 1st char
        sty     PTR+1           ; save filename 2nd char
.endif
        lda     SERIAL_OUT
        and     #$FF - (CLOCK_OUT_BIT | DATA_OUT_BIT)
        sta     C0_D0
        eor     #CLOCK_OUT_BIT
        sta     C1_D0
        eor     #(CLOCK_OUT_BIT | DATA_OUT_BIT)
        sta     SERIAL_OUT      ; C0,D1
        jsr     wait_drive_ready
        jsr     send_byte       ; filename length (ignored by drive code)
.ifdef NO_ZERO_PAGE
@n1:    lda     #$00
.else
        lda     PTR
.endif
        jsr     send_byte       ; filename 1st char
.ifdef NO_ZERO_PAGE
@n2:    lda     #$00
.else
        lda     PTR+1
.endif
        jsr     send_byte       ; filename 2nd char
        jsr     wait_drive_ready
        jsr     receive_byte    ; start addr low
        sta     start_address
.ifdef NO_ZERO_PAGE
        sta     store+1
.else
        sta     PTR
.endif
        jsr     receive_byte    ; start addr hi
        sta     start_address+1
.ifdef NO_ZERO_PAGE
        sta     store+2
.else
        sta     PTR+1
.endif
        ldy     #$00
loop:   jsr     receive_byte
        cmp     #ESC_BYTE
        bne     store
        jsr     receive_byte
        cmp     #ESC_BYTE
        beq     store
        cmp     #DRIVE_OK
        beq     out_ok
        cmp     #DRIVE_ERROR
        beq     out_err
        jsr     wait_drive_ready
        jmp     loop
.ifdef NO_ZERO_PAGE
store:  sta    $0000,y
.else
store:  sta     (PTR),y
.endif
        iny
        bne     loop
.ifdef NO_ZERO_PAGE
        inc     store+2
.else
        inc     PTR+1
.endif
        bne     loop            ; Always branch (hopefully)
out_ok:
        clc                     ; Update end addr
        tya
.ifdef NO_ZERO_PAGE
        adc     store+1
        sta     store+1
        bcc     :+
        inc     store+2
.else
        adc     PTR
        sta     PTR
        bcc     :+
        inc     PTR+1
.endif
        clc
out_err:
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

.ifdef NO_ZERO_PAGE
C0_D0:  .byte $00
C1_D0:  .byte $00
DATA:   .byte $00
start_address: .word $0000
.endif
