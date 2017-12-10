;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   INTU.S
;       Some Amiga/Intuition Exercises

;-------------------------------------------------------------------------------
;   Constants
;-------------------------------------------------------------------------------
EXEC_BASE           equ 4
EXEC_GET_MSG        equ -372
EXEC_OPEN_LIB       equ -408
EXEC_CLOSE_LIB      equ -414
INT_CLOSE_SCREEN    equ -66
INT_CLOSE_WINDOW    equ -72
INT_OPEN_SCREEN     equ -198
INT_OPEN_WINDOW     equ -204
INT_AUTO_REQUEST    equ -348
;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------
main:
    jsr     int_open
    jsr     int_open_screen
    jsr     int_open_window
    jsr     int_get_user_port_handle
    jsr     int_auto_request
_main_loop:
    jsr     int_get_msg
    jmp     _main_loop
_main_close:
    jsr     int_close_screen
    jsr     int_close
    rts

int_open:
    move.l  EXEC_BASE,a6
    lea     vIntuitionLibName,a1
    jsr     EXEC_OPEN_LIB(a6)
    move.l  d0,vIntuitionBase
    rts

int_close:
    move.l  EXEC_BASE,a6
    move.l  vIntuitionBase,a1
    jsr     EXEC_CLOSE_LIB(a6)
    rts

int_open_screen:
    move.l  vIntuitionBase,a6
    lea     vScreenDef,a0
    jsr     INT_OPEN_SCREEN(a6)
    move.l  d0,vScreenHandle
    rts

int_close_screen:
    move.l  vIntuitionBase,a6
    lea     vScreenHandle,a0
    jsr     INT_CLOSE_SCREEN(a6)
    rts

int_open_window:
    move.l  vIntuitionBase,a6
    move.l  vScreenHandle,vWindowDef_ScreenPtr
    lea     vWindowDef,a0
    jsr     INT_OPEN_WINDOW(a6)
    move.l  d0,vWindowHandle
    rts

int_get_user_port_handle:
    movea.l vWindowHandle,a0
    move.l  86(a0),vUserPortHandle
    rts

int_get_msg:
    movea.l vUserPortHandle,a0
    movea.l EXEC_BASE,a6
    jsr     INT_GET_MSG(a6)
    move.l  d0,vIntuMsgHandle
    rts

int_close_window:
    move.l  vIntuitionBase,a6
    move.l  vWindowHandle,a0
    jsr     INT_CLOSE_WINDOW(a6)
    rts

int_auto_request:
    move.l  vWindowHandle,a0
    lea     vRequesterText,a1
    lea     vRequesterLeftText,a2
    lea     vRequesterRightText,a3
    move.l  #0,d0
    move.l  #0,d1
    move.l  #50,d2
    move.l  #50,d3
    move.l  vIntuitionBase,a6
    jsr     INT_AUTO_REQUEST(a6)
    rts
;-------------------------------------------------------------------------------
    section data
;-------------------------------------------------------------------------------
    even
vIntuitionLibName:  

    dc.b    "intuition.library",0
    even
vScreenTitle:       
    dc.b    "Ash's Screen",0 
    even
vWindowTitle:       
    dc.b    "Ash's Window",0
    even
vScreenDef:
vScreenDef_X:           dc.w    0
vScreenDef_Y:           dc.w    0
vScreenDef_W:           dc.w    320 
vScreenDef_H:           dc.w    200
vScreenDef_Depth:       dc.w    2
vScreenDef_DetailPen:   dc.b    0
vScreenDef_BlockPen:    dc.b    1
vScreenDef_ViewMode:    dc.w    2
vScreenDef_ScreenType:  dc.w    15
vScreenDef_Font:        dc.l    0
vScreenDef_Title:       dc.l    vScreenTitle
vScreenDef_Gadgets:     dc.l    0
vScreenDef_Bitmap:      dc.l    0
    even
vWindowDef: 
vWindowDef_X:           dc.w    10
vWindowDef_Y:           dc.w    20
vWindowDef_W:           dc.w    100
vWindowDef_H:           dc.w    100
vWindowDef_FGColour:    dc.b    1
vWindowDef_BGColour:    dc.b    3
vWindowDef_IDCMP:       dc.l    $200
vWindowDef_Type:        dc.l    $100f
vWindowDef_Gadget:      dc.l    0
vWindowDef_Graphics:    dc.l    0
vWindowDef_Title:       dc.l    vWindowTitle
vWindowDef_ScreenPtr:   dc.l    0
vWindowDef_Bitmap:      dc.l    0
vWindowDef_MinW:        dc.w    50 
vWindowDef_MinH:        dc.w    50
vWindowDef_MaxW:        dc.w    200
vWindowDef_MaxH:        dc.w    200
vWindowDef_ScreenType:  dc.w    15

    even
vRequesterText:  
    dc.b    2       ; FG Colour
    dc.b    0       ; BG Colour
    dc.b    0       ; Normal text representation
    even
    dc.w    10,10   ; X/Y pos
    dc.l    0       ; Charset
    dc.l    vRequesterTextStr
    dc.l    0

    even
vRequesterTextStr:  
    dc.b    "This is a requester, bitch!",0

    even
vRequesterLeftText:     
    dc.b    2       ; FG Colour
    dc.b    0       ; BG Colour
    dc.b    0       ; Normal text representation
    even
    dc.w    5,3   ; X/y pos
    dc.l    0       ; Charset
    dc.l    vRequesterLeftTextStr
    dc.l    0

    even
vRequesterLeftTextStr:     
    dc.b    "Left Text",0

    even
vRequesterRightText:
    dc.b    2   ; FG Colour
    dc.b    0   ; BG Colour
    dc.b    0   ; Normal text representation
    even
    dc.w    5,3  ; X/Y pos
    dc.l    0   ; Charset
    dc.l    vRequesterRightTextStr
    dc.l    0

    even
vRequesterRightTextStr:
    dc.b    "Right Text",0

;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------
    even
vIntuitionBase:         ds.l    1
    even
vScreenHandle:          ds.l    1
    even
vWindowHandle:          ds.l    1
    even
vUserPortHandle:        ds.l    1
    even
vIntuMsgHandle:         ds.l    1
;-------------------------------------------------------------------------------
    end
;-------------------------------------------------------------------------------
