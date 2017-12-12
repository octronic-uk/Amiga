;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   BubbleSort.S

; Usage   
;    pea     table
;    move.w  #table_sz,-(sp)
;    jsr     sort
;    addq.l  #BUBBLE_SORT_ALIGN,sp
;    rts
;
; Register Usage
; 	d0 - Number of elements
; 	d1 - Dirty flag
; 	d2 - Number of elements (work)
; 	d3 - Swap work register
; 	d4 - Iteration Counter
;   d5 - Comparison Counter
;   d6 - Swap counter
;
; 	a0 - Address of table
; 	a1 - Address of table (work)

_BUBBLE_SORT_TABLE_ADDR equ 6
_BUBBLE_SORT_TABLE_SZ   equ 4
BUBBLE_SORT_ALIGN       equ 6

;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

BubbleSort:
    movea.l _BUBBLE_SORT_TABLE_ADDR(sp),a0  ; Load pointer with address
    move.w  _BUBBLE_SORT_TABLE_SZ(sp),d0    ; Number in the counter
    clr.l	d4					            ; Clear iteration counter
    clr.l   d5                              ; Clear Comparison Counter
    clr.l   d6                              ; Clear Swap Counter
_sort_setup:
    movea.l a0,a1                           ; Copy table pointer to work reg
    move.l  d0,d2                           ; Copy number of elements to work reg      
    subq.l  #2,d2                           ; Correct counter value
    sub.l   d4,d2                           ; Ignore sorted elements at the end
    clr.l   d1                              ; Erase dirty flag
_sort_loop:
    move.w  (a1),d3                         ; Temp store n1
    addq.l  #1,d5                           ; Increment comparison counter
    cmp.w   2(a1),d3                        ; compare n2 with n1
    ble     _sort_loop_skip_swap            ; Skip if sorted
    move.w  2(a1),(a1)                      ; Put n2 into n1
    move.w  d3,2(a1)                        ; Move n1 into n2
    moveq.l #1,d1                           ; Set dirty flag
    addq.l  #1,d6                           ; Increment swap counter
_sort_loop_skip_swap:
    addq.l  #2,a1                           ; Move to next list index
    dbra    d2,_sort_loop                   ; Decrement the loop counter
	addq.w	#1,d4                           ; Increment iter counter
    cmpi.w  #0,d1                           ; Check dirty flag
    bne     _sort_setup                     ; perform sort again
_sort_done:
    rts
