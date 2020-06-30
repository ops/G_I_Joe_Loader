;;;
;;; Host definitions for G.I. Joe loader
;;;
;;; March 2020 ops
;;;

        .include "cbm_kernal.inc"

        .if .def (__VIC20__)
            .include "vic20.inc"
            SERIAL_OUT = VIA2_PCR
            SERIAL_IN  = VIA1_PA1
            CLOCK_OUT_BIT = 1 << 1
            DATA_OUT_BIT  = 1 << 5
            CLOCK_IN_BIT  = 1 << 0
            DATA_IN_BIT   = 1 << 1
        .elseif .def (__C16__)
            .include "c16.inc"
            SERIAL_OUT = $01
            SERIAL_IN  = $01
            CLOCK_OUT_BIT = 1 << 1
            DATA_OUT_BIT  = 1 << 0
            CLOCK_IN_BIT  = 1 << 6
            DATA_IN_BIT   = 1 << 7
        .elseif .def (__C64__)
            .include "c64.inc"
            SERIAL_OUT = CIA2_PRA
            SERIAL_IN  = CIA2_PRA
            CLOCK_OUT_BIT = 1 << 4
            DATA_OUT_BIT  = 1 << 5
            CLOCK_IN_BIT  = 1 << 6
            DATA_IN_BIT   = 1 << 7
        .elseif .def (__C128__)
            .include "c128.inc"
            SERIAL_OUT = CIA2_PRA
            SERIAL_IN  = CIA2_PRA
            CLOCK_OUT_BIT = 1 << 4
            DATA_OUT_BIT  = 1 << 5
            CLOCK_IN_BIT  = 1 << 6
            DATA_IN_BIT   = 1 << 7
        .else
            .error "Unsupported target"
        .endif
