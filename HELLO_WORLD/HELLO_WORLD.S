; Amiga programming example in assembler, using system calls.
; "Hello World" using the default output (usually console)
; Uses dos.library/PutStr() so requires kick 2.0+
; 14 processor instructions :-)
; Assembled with "vasm -Fhunkexe -o helloworld helloworld.s"
; Grzegorz Kraszewski, 2016
; Public Domain
; Description in Polish: http://krashan.ppa.pl/articles/amiga_asembler


; Offsets of system functions in respective jumptables of library bases.
; Loading proper system includes would be more elegant.

SysBase         EQU 4
OpenLibrary		EQU -552
CloseLibrary    EQU -414
PutStr			EQU -948

; Note: the program lacks proper startup code, so it will not run from Workbench

    lea	    DosName,A1		; dos.library name string
    moveq	#36,D0			; minimum required version (36 = Kick 2.0)
    movea.l SysBase,A6
    jsr	    OpenLibrary(A6)

    tst.l	D0			    ; zero if OpenLibrary() failed
    beq.s	NoDos			; if failed, skip to exit

    move.l	#Hello,D1		; string to print
    movea.l	D0,A6			; moving DOSBase to A6
    jsr	    PutStr(A6)

    movea.l	A6,A1			; DOSBase, library to close
    movea.l	SysBase,A6
    jsr	    CloseLibrary(A6)

NoDos:
    CLR.L	D0			    ; return 0 to the system
	RTS

; Data

DosName			dc.b		"dos.library",0
Hello			dc.b		"Hello World!",10,0
