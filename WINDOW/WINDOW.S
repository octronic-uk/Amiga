; Load the DOS library 'dos.library'

EXEC_BASE   EQU 4       ; Base address of the EXEC lib
OPEN_LIB    EQU -408    ; Offset of OpenLib
CLOSE_LIB   EQU -414    ; Offset of CloseLib
MODE_OLD    EQU 1005    ; DOS Old Mode??
ALLOC_ABS   EQU -$cc

DOS_OPEN    EQU -30
DOS_CLOSE   EQU -36
DOS_IOERR   EQU -132

;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

run:
    jsr     init
wait:
    jmp     wait

    bra     test

init:
    movea.l EXEC_BASE,a6   	    ; Base address in a6
    lea     dosLibraryName,a1   ; Address of library name
    moveq.l #0,d0           	; Version number
    jsr     OPEN_LIB(a6)
    move.l  d0,dosBase
    beq     error
    
    lea     consoleName,a1  	; Console Definition
    move.l  #MODE_OLD,d0    	; Mode
    bsr     DOS_Open
    beq     error
    move.l  d0,consoleHandle
    rts

test:
    bra quit

error:
    movea.l dosBase,a6
    jsr     DOS_IOERR(a6)
    move.l  d0,d5
    move.l  #-1,d7

quit:
    move.l  consoleHandle,d1
    movea.l dosBase,a6 
    jsr     DOS_CLOSE(a6)  
    movea.l dosBase,a1
    movea.l EXEC_BASE,a6
    jsr     CLOSE_LIB(a6)
    rts

DOS_Open:
    move.l  a1,d1
    move.l  d0,d2
    movea.l dosBase,a6
    jsr     DOS_OPEN(a6)
    tst.l   d0
    rts

DOS_Close:
    move.l  consoleHandle,d1    ; Handle Number in D1
    movea.l dosBase,a6          ; DOS Base Address
    jsr     DOS_CLOSE(a6)       ; Close the channel
    rts

;-------------------------------------------------------------------------------
    section data
;-------------------------------------------------------------------------------

    even
dosLibraryName:
    dc.b    'dos.library',0

    even
consoleName:
    dc.b    'CON:0/100/640,100/***Window***',0

;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------

    even
dosBase:
    ds.l    1

consoleHandle:
    ds.l    1
