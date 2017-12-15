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
;   rts
;
; Register Usage
; 	d0 - Number of elements
; 	d1 - Dirty flag
; 	d2 - Number of elements (work)
;
; 	a0 - Address of table
; 	a1 - Address of table (work)

_BUBBLE_SORT_TABLE_ADDR equ 18
_BUBBLE_SORT_TABLE_SZ   equ 16
_BUBBLE_SORT_ON_ITER    equ 12
_BUBBLE_SORT_ON_COMP    equ 8 
_BUBBLE_SORT_ON_SWAP    equ 4
BUBBLE_SORT_ALIGN       equ 18

;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

BubbleSort:
    ; Set event functions
    move.l  _BUBBLE_SORT_ON_SWAP(sp),vBS_OnSwapPtr
    move.l  _BUBBLE_SORT_ON_COMP(sp),vBS_OnCompPtr
    move.l  _BUBBLE_SORT_ON_ITER(sp),vBS_OnIterPtr

    movea.l _BUBBLE_SORT_TABLE_ADDR(sp),a0  ; Load pointer with address
    move.w  _BUBBLE_SORT_TABLE_SZ(sp),d0    ; Number in the counter

    clr.l	vBS_Iters               ; Clear iteration counter
    clr.l   vBS_Comps               ; Clear Comparison Counter
    clr.l   vBS_Swaps               ; Clear Swap Counter
_sort_setup:
    clr.w   vBS_Index               ; Clear array index
    clr.l   vBS_Dirty               ; Erase dirty flag
    ;movea.l a0,a1                   ; Copy table pointer to work reg
    move.l  d0,d1                   ; Copy number of elements to work reg      
    subq.l  #2,d1                   ; Correct counter value.
    sub.l   vBS_Iters,d1            ; Ignore sorted elements at the end
    move.w  vBS_Index,a1
_sort_loop:
    move.w  (a0,a1.w),vBS_ValA      ; store n1
    move.w  2(a0,a1.w),vBS_ValB     ; store n2
    addq.l  #1,vBS_Comps            ; Increment comparison counter
    jsr     vBS_OnCompPtr
    move.w  vBS_ValA,d3
    move.w  vBS_ValB,d4
    cmp.w   d3,d4       ; compare n2 with n1
    ble     _sort_loop_skip_swap    ; Skip if sorted
    move.w  vBS_ValB,(a0,a1.w)    ; Put n2 into n1
    move.w  vBS_ValA,2(a0,a1.w)   ; Move n1 into n2
    move.l  #1,vBS_Dirty            ; Set dirty flag
    addq.l  #1,vBS_Swaps            ; Increment swap counter
    jsr     vBS_OnSwapPtr
_sort_loop_skip_swap:
    addq.l  #1,vBS_Index            ; Move to next list index
    dbra    d1,_sort_loop           ; Decrement the loop counter
	addq.w	#1,vBS_Iters            ; Increment iter counter
    jsr     vBS_OnIterPtr
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



