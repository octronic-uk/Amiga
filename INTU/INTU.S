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
    section text
;-------------------------------------------------------------------------------

main:
    move.w  #FALSE,vMainDone
    ; Open Intuition Lib
    pea     vIntuLibName
    jsr     exec_open_lib
    addq.l  #4,sp
    move.l  d0,vIntuBase
    ; Open Screen and Intu
    jsr     intu_open_screen
    jsr     intu_open_window
    jsr     intu_set_menu_strip
    jsr     intu_get_user_port_handle
    ; Print some text
    pea     vRequesterText
    move.l  #5,-(sp)
    move.l  #5,-(sp)
    jsr     intu_print_itext
    add.l   #12,sp
    ; Show requester
    jsr     intu_auto_request
_main_loop:
    move.l  vUserPortPtr,-(sp)
    jsr     exec_get_msg
    addq.l  #4,sp
    move.l  d0,vIntuMsgPtr

    jsr     message_handler
    cmpi.w  #TRUE,vMainDone
    beq     _main_close
    jmp     _main_loop
_main_close:
    jsr     intu_clear_menu_strip
    jsr     intu_close_screen
    ; Close Intuition Lib
    lea     vIntuBase,a1
    jsr     exec_close_lib
    addq.l  #4,sp
    ; Close Application
    rts

; Exec Routines ----------------------------------------------------------------

exec_open_lib:
    movea.l 4(sp),a1
    movea.l EXEC_BASE,a6
    jsr     EXEC_OPEN_LIB(a6)
    rts

exec_close_lib:
    movea.l 4(sp),a1
    movea.l EXEC_BASE,a6
    jsr     EXEC_CLOSE_LIB(a6)
    rts

exec_get_msg:
    movea.l 4(sp),a0
    movea.l EXEC_BASE,a6
    jsr     EXEC_GET_MSG(a6)
    rts

; Intuition Routines -----------------------------------------------------------

intu_open_screen:
    move.l  vIntuBase,a6
    lea     vScreenDef,a0
    jsr     INTU_OPEN_SCREEN(a6)
    move.l  d0,vScreenPtr
    rts

intu_close_screen:
    move.l  vIntuBase,a6
    lea     vScreenPtr,a0
    jsr     INTU_CLOSE_SCREEN(a6)
    rts

intu_open_window:
    move.l  vIntuBase,a6
    move.l  vScreenPtr,vWindowDef_ScreenPtr
    lea     vWindowDef,a0
    jsr     INTU_OPEN_WINDOW(a6)
    move.l  d0,vWindowPtr
    rts

intu_get_user_port_handle:
    movea.l vWindowPtr,a0
    move.l  86(a0),vUserPortPtr
    rts

intu_close_window:
    move.l  vIntuBase,a6
    move.l  vWindowPtr,a0
    jsr     INTU_CLOSE_WINDOW(a6)
    rts

intu_auto_request:
    move.l  vWindowPtr,a0
    lea     vRequesterText,a1
    lea     vRequesterLeftText,a2
    lea     vRequesterRightText,a3
    move.l  #0,d0
    move.l  #0,d1
    move.l  #50,d2
    move.l  #50,d3
    move.l  vIntuBase,a6
    jsr     INTU_AUTO_REQUEST(a6)
    rts

intu_set_menu_strip:
    movea.l vIntuBase,a6
    movea.l vWindowPtr,a0
    lea     vMenuPtr,a1
    jsr     INTU_SET_MENU_STRIP(a6)
    rts

intu_clear_menu_strip:
    movea.l vIntuBase,a6
    movea.l vWindowPtr,a0
    jsr     INTU_CLEAR_MENU_STRIP(a6)
    rts

intu_get_rast_port:
    movea.l vWindowPtr,a0
    move.l  50(a0),d0
    rts

intu_print_itext:
    jsr     intu_get_rast_port
    movea.l d0,a0               ; RastPort to a0
    movea.l vIntuBase,a6
    movea.l 12(sp),a1           ; Text struct pointer
    move.l  8(sp),d0            ; X
    move.l  4(sp),d1            ; Y
    jsr     INTU_PRINT_ITEXT(a6)
    rts

; App Routines -----------------------------------------------------------------

message_handler:
    cmpi.l  #0,vIntuMsgPtr
    beq     _message_handler_done
    movea.l vIntuMsgPtr,a0
    move.l  20(a0),d6
    cmpi.l  #IDCMP_CLOSEWINDOW,d6
    move.w  #TRUE,vMainDone
    beq     _message_handler_done
_message_handler_done: 
    rts

;-------------------------------------------------------------------------------
    section data
;-------------------------------------------------------------------------------
    even
vIntuLibName:  
    dc.b    "intuition.library",0

    even
vScreenTitle:       
    dc.b    "Ash's Screen",0 

    even
vWindowTitle:       
    dc.b    "Ash's Window",0

; Screen Definition ------------------------------------------------------------

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

; Window Definition ------------------------------------------------------------

    even
vWindowDef: 
vWindowDef_X:           dc.w    10
vWindowDef_Y:           dc.w    10
vWindowDef_W:           dc.w    200
vWindowDef_H:           dc.w    150
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
vWindowDef_MaxW:        dc.w    320
vWindowDef_MaxH:        dc.w    200
vWindowDef_ScreenType:  dc.w    15

; Requester --------------------------------------------------------------------

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
    dc.b    "Hi, This is a requester!",0

    even
vRequesterLeftText:     
    dc.b    2       ; FG Colour
    dc.b    0       ; BG Colour
    dc.b    0       ; Normal text representation
    even
    dc.w    5,3     ; X/y pos
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

; File Menu --------------------------------------------------------------------

    even
vMenuPtr:
    even
    dc.l    0                   ; Next Menu
    dc.w    0,0,50,10           ; X/Y/W/H of Title
    dc.w    1                   ; Menu Enabled
    dc.l    vMenuTextPtr        ; Text pointer
    dc.l    vMenuItem1          ; First Menu Item
    dc.w    0,0,0,0             ; Reserved

    even
vMenuTextPtr:   
    dc.b    "File",0

    even
vMenuItem1:
    dc.l    0                   ; Next Menu Entry
    dc.w    0,0,90,10           ; X/Y/W/H
    dc.w    %10011111           ; Mode Flag
    dc.l    0                   ; No Connection
    dc.l    vMenuItem1TextPtr   ; Text pointer
    dc.l    0                   ; No drawing when clicked
    dc.b    'Q'                 ; Shortcut Amiga-Q
    even
    dc.l    0                   ; No Submenu
    dc.w    0                   ; Next Select

    even
vMenuItem1TextPtr: 
    dc.b    0,1                 ; Colours
    dc.b    0                   ; Mode: Overwrite
    even
    dc.w    5,3                 ; X/Y Position
    dc.l    0                   ; Charset
    dc.l    vMenuItem1StrPtr    ; String pointer
    dc.b    0

    even
vMenuItem1StrPtr:
    dc.b    " Quit",0

;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------
    even
vIntuBase:          ds.l    1

    even
vScreenPtr:         ds.l    1

    even
vWindowPtr:         ds.l    1

    even
vUserPortPtr:       ds.l    1

    even
vIntuMsgPtr:        ds.l    1

    even
vMainDone:          ds.w    1

;-------------------------------------------------------------------------------
;   Constants
;-------------------------------------------------------------------------------

; Application Specific

TRUE                    equ 1
FALSE                   equ 0

; Exec Library

EXEC_BASE               equ 4
EXEC_GET_MSG            equ -372
EXEC_OPEN_LIB           equ -408
EXEC_CLOSE_LIB          equ -414
; Intuition Library

INTU_CLEAR_MENU_STRIP   equ -54
INTU_CLOSE_SCREEN       equ -66
INTU_CLOSE_WINDOW       equ -72
INTU_OPEN_SCREEN        equ -198
INTU_OPEN_WINDOW        equ -204
INTU_PRINT_ITEXT        equ -216
INTU_SET_MENU_STRIP     equ -264
INTU_AUTO_REQUEST       equ -348

; IDCMP

IDCMP_SIZEVERIFY        equ $000001 
IDCMP_NEWSIZE           equ $000002
IDCMP_REFRESHWINDOW     equ $000004
IDCMP_MOUSEBUTTONS      equ $000008
IDCMP_MOUSEMOVE         equ $000010
IDCMP_GADGETDOWN        equ $000020
IDCMP_GADGETUP          equ $000040
IDCMP_REQSET            equ $000080
IDCMP_MENUPICK          equ $000100
IDCMP_CLOSEWINDOW       equ $000200
IDCMP_RAWKEY            equ $000400
IDCMP_REQVERIFY         equ $000800
IDCMP_REQCLEAR          equ $001000
IDCMP_MENUVERIFY        equ $002000
IDCMP_NEWPREFS          equ $004000
IDCMP_DISKINSERTED      equ $008000
IDCMP_DISKREMOVED       equ $010000
IDCMP_WBENCHMESSAGE     equ $020000
IDCMP_ACTIVEWINDOW      equ $040000
IDCMP_INACTlVEWINDOW    equ $080000
IDCMP_DELTAMOVE         equ $100000
;-------------------------------------------------------------------------------
    end
;-------------------------------------------------------------------------------
