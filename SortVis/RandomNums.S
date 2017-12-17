
;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

;   pea     table_output_address
;   move.l  #NumberOfElements
;   jsr     rng_table
;   addq.l  #8,sp
rng_table:
    jsr     rng_seed
    movea.l 8(sp),a0
    move.l  4(sp),d0
    subq.l  #1,d0
_rng_table_next:
    move.l  d0,-(sp)
    jsr     rng_get
    andi.w  #$00FF,vRngState
    move.w  vRngState,d0
    lsr.w   #1,d0
    move.w  d0,(a0)+
    move.l  (sp)+,d0
    dbra    d0,_rng_table_next
    rts

rng_seed:
    move.l  #$9876fedc,d0
    move.l  #$abcd1234,d1
    move.w  JOY0DAT,d2
_rng_seed_loop   
    swap    d0
    add.l   d1,d0
    add.l   d0,d1
    dbf     d2,_rng_seed_loop 
    movem.l d0-d1,vRngState
    rts

rng_get:
    movem.l vRngState,d0-d1
    swap    d0
    add.l   d1,d0
    add.l   d0,d1
    movem.l d0-d1,vRngState
    rts

;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------

vRngState:  
    ds.l    2 

JOY0DAT     EQU $DFF00A	
