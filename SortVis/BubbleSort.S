;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   BubbleSort.S

; Usage   
;   pea     table_of_words
;   move.w  #table_sz,-(sp)
;   pea     onComparisonFunction
;   pea     onSwapFunction
;   pea     onIterationFunction
;   jsr     sort
;   addq.l  #BUBBLE_SORT_ALIGN,sp
;
; Register Usage
; 	d0 - Number of elements
; 	d1 - Dirty flag
; 	d2 - Number of elements (work)
;
; 	a0 - Address of table
; 	a1 - Address of table (work)
;   a2 - Address of callback

_BUBBLE_SORT_TABLE_ADDR equ 18
_BUBBLE_SORT_TABLE_SZ   equ 16
_BUBBLE_SORT_ON_COMP    equ 12
_BUBBLE_SORT_ON_SWAP    equ 8 
_BUBBLE_SORT_ON_ITER    equ 4
BUBBLE_SORT_ALIGN       equ 18

;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

BubbleSort:
    ; Set event functions
    move.l  _BUBBLE_SORT_ON_ITER(sp),vBS_OnIterPtr
    move.l  _BUBBLE_SORT_ON_SWAP(sp),vBS_OnSwapPtr
    move.l  _BUBBLE_SORT_ON_COMP(sp),vBS_OnCompPtr

    move.w  _BUBBLE_SORT_TABLE_SZ(sp),d0    ; Number in the counter
    movea.l _BUBBLE_SORT_TABLE_ADDR(sp),a0  ; Load pointer with address

    clr.w	vBS_Iters               ; Clear iteration counter
    clr.w   vBS_Comps               ; Clear Comparison Counter
    clr.w   vBS_Swaps               ; Clear Swap Counter
_sort_setup:
    clr.w   vBS_Index               ; Clear array index
    clr.w   vBS_Dirty               ; Erase dirty flag
    move.w  d0,d1                   ; Copy number of elements to work reg      
    subq.w  #2,d1                   ; Correct counter value.
    sub.w   vBS_Iters,d1            ; Ignore sorted elements at the end
_sort_loop:
    move.w  vBS_Index,a1
    move.w  (a0,a1.w),vBS_ValA      ; store n1
    move.w  2(a0,a1.w),vBS_ValB     ; store n2
    addq.w  #1,vBS_Comps            ; Increment comparison counter

    movea.l vBS_OnCompPtr,a2
    movem.l d0-d2/a0-a2,-(sp)
    jsr     (a2)
    movem.l (sp)+,d0-d2/a0-a2

    move.w  vBS_ValA,d3
    move.w  vBS_ValB,d4
    cmp.w   d4,d3                   ; compare n2 with n1
    ble     _sort_loop_skip_swap    ; Skip if sorted
    move.w  vBS_ValB,(a0,a1.w)      ; Put n2 into n1
    move.w  vBS_ValA,2(a0,a1.w)     ; Move n1 into n2
    move.w  #1,vBS_Dirty            ; Set dirty flag
    addq.w  #1,vBS_Swaps            ; Increment swap counter

    movea.l vBS_OnSwapPtr,a2
    movem.l d0-d2/a0-a2,-(sp)
    jsr     (a2)
    movem.l (sp)+,d0-d2/a0-a2

_sort_loop_skip_swap:
    addq.w  #2,vBS_Index            ; Move to next list index
    dbra    d1,_sort_loop           ; Decrement the loop counter

	addq.w	#1,vBS_Iters            ; Increment iter counter

    movea.l vBS_OnIterPtr,a2
    movem.l d0-d2/a0-a2,-(sp)
    jsr     (a2)
    movem.l (sp)+,d0-d2/a0-a2

    cmpi.w  #0,vBS_Dirty            ; Check dirty flag
    bne     _sort_setup             ; perform sort again
_sort_done:
    rts

;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------

vBS_Iters:      ds.w    1
vBS_Comps:      ds.w    1
vBS_Swaps:      ds.w    1

vBS_ValA:       ds.w    1
vBS_ValB:       ds.w    1
vBS_Index:      ds.w    1
vBS_Dirty:      ds.w    1

vBS_OnSwapPtr:  ds.l    1
vBS_OnCompPtr:  ds.l    1
vBS_OnIterPtr:  ds.l    1



