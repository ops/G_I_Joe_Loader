# G.I. Joe Loader

The first time I saw Commodore 64 game **G.I. Joe** in 1985 I was fascinated.
Not that the game was so great but the loader was amazing: the music was
playing, sprites moving on the screen and the game was loading at the
same time.

Now, after 35 years, I decided to find out how it was done.

Here is the source code of the loader as a reusable library for
[CC65](https://cc65.github.io/) compiler suite.
The code running on the host machine has been rewritten but the code
for disk drive is unmodified. This way the loader works on SD2IEC
devices as well.
While rewriting the host part I also ported it to other Commodore machines.
Loader works on VIC-20, C16, Plus/4, C64 and C128.

Feel free to use this code in your own products.

# How to use the loader in your programs

## Compile library

Makefile is provided for Linux. Add correct `target` parameter depending on
your platform.

```
        make target=vic20
        make target=c64
        make target=c16
        make target=c128
```

## Example code

Import needed symbols.

```
        ; Import linker generated symbols
        .import __GIJ_HOSTCODE_LOAD__
        .import __GIJ_HOSTCODE_RUN__
        .import __GIJ_HOSTCODE_SIZE__

        ; Import symbols from the library
        .import gij_load_init
        .import gij_load
```

Initialise drive code and relocate host code.

```
        ; Upload drive code and run it
        jsr     gij_load_init

        ; Copy host code to the target location
        ldx     #$00
:       lda     __GIJ_HOSTCODE_LOAD__,x
        sta     __GIJ_HOSTCODE_RUN__,x
        inx
        cpx     #< __GIJ_HOSTCODE_SIZE__
        bne    :-
```

And finally load a file from disk.

```
        ; Load file
        ldx     #'g' ; filename 1st char
        ldy     #'i' ; filename 2nd char
        jsr     gij_load
        rts
```

## Compile and link

```
        cl65 -C mydemo.cfg mycode.s -o mydemo gijoe-loader.lib
```

Example linker config file:

```
        MEMORY {
               MAIN:     file = %O, start = %S,     size = $0400;
               # Host resident code fits nicely into tape buffer.
               TBUFFR:   file = %O, start = $0334,  size = $00BF;
               DRIVERAM: file = %O, start = $0500,  size = $01A9;
        }

        SEGMENTS {
               CODE:          load = MAIN, type = ro;
               GIJ_HOSTCODE:  load = MAIN, type = ro,  run = TBUFFR,   define = yes;
               GIJ_DRIVECODE: load = MAIN, type = ro,  run = DRIVERAM, define = yes;
               GIJ_INITCODE:  load = MAIN, type = ro;
        }
```
