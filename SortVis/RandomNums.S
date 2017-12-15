
;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

;   pea     table_output_address
;   move.w  #NumberOfElements
;   jsr     TableRNG
;   addq.l  #6,sp
rng_table:
    jsr     rng_seed
    movea.l 6(sp),a0
    move.w  4(sp),d0
_rng_table_next:
    move.w  d0,-(sp)
    jsr     rng_get
    move.w  vRngState,(a0)+
    move.w  (sp)+,d0
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
