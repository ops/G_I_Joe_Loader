;;;
;;; Drive code for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

B4_JOB          := $04
B4_TRACK        := $0E
B4_SECTOR       := $0F
DATA            := $14
BUFFER4         := $0700
VIA1_PB         := $1800
VIA2_PB         := $1C00

        .include "shared.inc"

        .export drive_code_main

        .segment "GIJ_DRIVECODE"

drive_code_main:
        jsr     init
start:  jsr     get_filename
        lda     B4_TRACK
        sta     nchr1
        lda     B4_SECTOR
        sta     nchr2
        ldy     #1
@scan_directory:
        ldx     #18
        stx     B4_TRACK
        sty     B4_SECTOR
        jsr     read_sector
        ldy     #$02
@search_filename:
        lda     BUFFER4,y       ; Get file type
        and     #$83
        cmp     #$82            ; is it valid prg
        bne     @next
        lda     BUFFER4+3,y
        cmp     nchr1           ; compare filename 1st char
        bne     @next
        lda     BUFFER4+4,y
        cmp     nchr2           ; compare filename 2nd char
        bne     @next
        jmp     load_file
@next:  tya
        clc
        adc     #$20            ; move pointer to the next filename
        tay
        bcc     @search_filename
        ldy     BUFFER4+1       ; next sector
        bpl     @scan_directory
restart:
        lda     #$00
        sta     VIA1_PB
        ldx     #$FE
        jsr     send_byte
        ldx     #$FE
        jsr     send_byte
        ldx     #ESC_BYTE
        jsr     send_byte
        ldx     #DRIVE_ERROR
        jsr     send_byte
        jmp     start

load_file:
        lda     BUFFER4+1,y
        sta     B4_TRACK
        lda     BUFFER4+2,y
        sta     B4_SECTOR
@loop:  jsr     read_sector
        ldy     #$00
        lda     BUFFER4
        sta     B4_TRACK
        bne     @notlast
        ldy     BUFFER4+1
        iny
@notlast:
        sty     nchr1
        lda     BUFFER4+1
        sta     B4_SECTOR
        ldy     #$02
        lda     #$00
        sta     VIA1_PB
@bloop: ldx     BUFFER4,y
        cpx     #ESC_BYTE
        bne     :+
        jsr     send_byte
        ldx     #ESC_BYTE
:       jsr     send_byte
        iny
        cpy     nchr1
        bne     @bloop
        lda     BUFFER4
        beq     @out
        ldx     #ESC_BYTE
        jsr     send_byte
        ldx     #$C3
        jsr     send_byte
        lda     #$08
        sta     VIA1_PB
        jmp     @loop
@out:   ldx     #ESC_BYTE
        jsr     send_byte
        ldx     #DRIVE_OK
        jsr     send_byte
        jmp     start

get_filename:
        lda     #$08            ; CLK
        sta     VIA1_PB
        lda     VIA2_PB         ; Turn
        and     #$F7            ; led
        sta     VIA2_PB         ; off
        cli

        lda     #$01
@wait:  bit     VIA1_PB         ; wait until the host is ready
        beq     @wait

        sei
        lda     #$00
        sta     VIA1_PB         ; ack host
        jsr     receive_byte    ; filename length
        pha
        jsr     receive_byte    ; 1st char
        sta     B4_TRACK
        jsr     receive_byte    ; 2nd char
        sta     B4_SECTOR
        lda     #$08
        sta     VIA1_PB
        lda     VIA2_PB         ; Turn
        ora     #$08            ; led
        sta     VIA2_PB         ; on
        pla
        rts

read_sector:
        ldy     #$05            ; amount of retries when reading a sector
        sty     $8B
@retry: cli
        lda     #$80
        sta     B4_JOB
:       lda     B4_JOB
        bmi     :-
        cmp     #$01
        beq     @ok
        dec     $8B
        ldy     $8B
        bmi     @error
        cpy     #$02
        bne     @skip
        lda     #$C0            ; bump
        sta     B4_JOB
@skip:  lda     $16
        sta     $12
        lda     $17
        sta     $13
:       lda     B4_JOB
        bmi     :-
        bpl     @retry          ; branch always
@error: pla
        pla
        jmp     restart
@ok:    sei
        rts

send_byte:
        stx     DATA
        lda     #$04
        jsr     @send_two_bits
        jsr     @send_two_bits
        jsr     @send_two_bits
@send_two_bits:
        lsr     DATA
        ldx     #$02
        bcc     :+
        ldx     #$00
:       bit     VIA1_PB         ; wait until the host is
        bne     :-              ; ready to receive
        stx     VIA1_PB
        lsr     DATA
        ldx     #$02
        bcc     :+
        ldx     #$00
:       bit     VIA1_PB         ; wait until the host is
        beq     :-              ; ready to receive
        stx     VIA1_PB
        rts

receive_byte:
        ldy     #$04
@loop:  lda     #$04
:       bit     VIA1_PB         ; wait until the host sets
        beq     :-              ; data on the bus
        lda     VIA1_PB
        lsr
        ror     DATA
        lda     #$04
:       bit     VIA1_PB         ; wait until the host sets
        bne     :-              ; data on the bus
        lda     VIA1_PB
        lsr
        ror     DATA
        dey
        bne     @loop
        lda     DATA
        rts

init:   sei
        cld

        ldy     #$08
@loop:  lda     #$10            ; ATN acknowledge 1, C0,D0
        sta     VIA1_PB
:       dex
        bne     :-
        lda     #$00            ; ATN acknowledge 0, C0,D0
        sta     VIA1_PB
:       dex
        bne     :-
        dey
        bne     @loop

@loop2: lda     VIA1_PB
        and     #$05
        bne     @loop2          ; wait until DATA & CLK are set

        lda     VIA1_PB
        and     #$05
        bne     @loop2
        rts

nchr1:  .byte 0
nchr2:  .byte 0

        .byte 0, 0              ; padding
