main:  
    pea     table
    move.w  #table_sz,-(sp)
    jsr     sort
    addq.l  #SORT_ALIGN,sp
    rts

; Register Usage
; 	d0 - Number of elements
; 	d1 - Dirty flag
; 	d2 - Number of elements (work)
; 	d3 - Swap work register
; 	d4 - Number of iterations performed
; 	a0 - Address of table
; 	a1 - Address of table (work)

; Return Values:
;	d0 - Number of iterations

TABLE_ADDR  equ 6
TABLE_SZ    equ 4
SORT_ALIGN  equ 6

sort:
    movea.l TABLE_ADDR(sp),a0   ; Load pointer with address
    move.w  TABLE_SZ(sp),d0     ; Number in the counter
    clr.l	d4					; Clear iteration counter
_sort_setup:
	addq.w	#1,d4
    movea.l a0,a1               ; Copy table pointer to work reg
    move.l  d0,d2               ; Copy number of elements to work reg      
    subq.l  #2,d2               ; Correct counter value
    clr.l   d1                  ; Erase dirty flag
_sort_loop:
    move.w  (a1),d3             ; Temp store n1
    cmp.w   2(a1),d3            ; compare n2 with n1
    ble     _sort_loop_skip_swap ; Skip if sorted
    move.w  2(a1),(a1)          ; Put n2 into n1
    move.w  d3,2(a1)            ; Move n1 into n2
    moveq.l #1,d1               ; Set dirty flag
_sort_loop_skip_swap:
    addq.l  #2,a1
    dbra    d2,_sort_loop       ; Decrement the loop counter
    cmpi.w  #0,d1               ; Check dirty flag
    bne     _sort_setup         ; perform sort again
_sort_done:
    rts

table: 
    dc.w  15,  9, 19, 11, 18
    dc.w  20, 24,  2,  4,  7
    dc.w   5, 14, 10, 17, 12
	dc.w  25,  8,  1, 23,  6
	dc.w   3, 21, 13, 22, 16
	
table_sz    equ 25

    end 
