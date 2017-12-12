;  ______   ______   __  __    
; /\  __ \ /\  ___\ /\ \_\ \  
; \ \  __ \\ \___  \\ \  __ \  
;  \ \_\ \_\\/\_____\\ \_\ \_\ 
;   \/_/\/_/ \/_____/ \/_/\/_/ 
;      ash@octronic.co.uk      
;
;   SortVis.S
;       Sorting algorithm visualiser. 

;-------------------------------------------------------------------------------
    section text
;-------------------------------------------------------------------------------

main:
    move.w  #FALSE,vMainDone
    ; Open Intuition Lib
    pea     vIntuLibNameStr
    jsr     exec_open_lib
    addq.l  #4,sp
    move.l  d0,vIntuBase
    ; Open Screen and Intu
    jsr     intu_open_screen
    jsr     intu_open_window
    jsr     intu_set_menu_strip
    jsr     intu_get_user_port_handle
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

; Show requester
; Usage
;   jsr     intu_auto_request
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
    lea     vFileMenu,a1
    jsr     INTU_SET_MENU_STRIP(a6)
    rts

intu_clear_menu_strip:
    movea.l vIntuBase,a6
    movea.l vWindowPtr,a0
    jsr     INTU_CLEAR_MENU_STRIP(a6)
    rts

intu_get_rast_port:
    movea.l vWindowPtr,a0
    movea.l  50(a0),a0
    rts

; Print some text
; Usage:
;    pea     vRequesterText
;    move.l  #5,-(sp)
;    move.l  #5,-(sp)
;    jsr     intu_print_itext
;    add.l   #12,sp
intu_print_itext:
    jsr     intu_get_rast_port
    movea.l vIntuBase,a6
    movea.l 12(sp),a1           ; Text struct pointer
    move.l  8(sp),d0            ; X
    move.l  4(sp),d1            ; Y
    jsr     INTU_PRINT_ITEXT(a6)
    rts

;   Usage
;       pea     ImageStruct
;       move.w  X,-(sp)
;       move.w  Y,-(sp)
;       jsr     intu_draw_image
;       add.l  #12,sp
intu_draw_image:
    jsr     intu_get_rast_port  ; a0
    movea.l 12(sp),a1            ; image struct
    movea.l vIntuBase,a6        ; intu
    move.l  8(sp),d0            ; X
    move.l  4(sp),d1            ; Y
    jsr     INTU_DRAW_IMAGE(a6)
    rts


;-------------------------------------------------------------------------------
    section data
;-------------------------------------------------------------------------------
    even
vIntuLibNameStr:  
    dc.b    "intuition.library",0

    even
vScreenTitleStr:       
    dc.b    "Octronic SortVis v1.0",0 

    even
vWindowTitleStr:       
    dc.b    "Setup Visualisation",0

; Screen Definition ------------------------------------------------------------

    even
vScreenDef:
vScreenDef_X:           dc.w    0
vScreenDef_Y:           dc.w    0
vScreenDef_W:           dc.w    320 
vScreenDef_H:           dc.w    200
vScreenDef_Depth:       dc.w    4 
vScreenDef_DetailPen:   dc.b    0
vScreenDef_BlockPen:    dc.b    1
vScreenDef_ViewMode:    dc.w    2
vScreenDef_ScreenType:  dc.w    15
vScreenDef_Font:        dc.l    0
vScreenDef_Title:       dc.l    vScreenTitleStr
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
vWindowDef_Gadget:      dc.l    vSoundCheckboxGadget
vWindowDef_Graphics:    dc.l    0
vWindowDef_Title:       dc.l    vWindowTitleStr
vWindowDef_ScreenPtr:   dc.l    0
vWindowDef_Bitmap:      dc.l    0
vWindowDef_MinW:        dc.w    100 
vWindowDef_MinH:        dc.w    100
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
    dc.l    vRequesterLeftStr
    dc.l    0

    even
vRequesterLeftStr:     
    dc.b    "Left Text",0

    even
vRequesterRightText:
    dc.b    2   ; FG Colour
    dc.b    0   ; BG Colour
    dc.b    0   ; Normal text representation
    even
    dc.w    5,3  ; X/Y pos
    dc.l    0   ; Charset
    dc.l    vRequesterRightStr
    dc.l    0

    even
vRequesterRightStr:
    dc.b    "Right Text",0

; File Menu --------------------------------------------------------------------

    even
vFileMenu:
    even
    dc.l    0                   ; Next Menu
    dc.w    0,0,50,10           ; X/Y/W/H of Title
    dc.w    1                   ; Menu Enabled
    dc.l    vFileMenuStr        ; Text pointer
    dc.l    vFileQuitMenuItem   ; First Menu Item
    dc.w    0,0,0,0             ; Reserved

    even
vFileMenuStr:   
    dc.b    "File",0

    even
vFileQuitMenuItem:
    dc.l    0                       ; Next Menu Entry
    dc.w    0,0,90,10               ; X/Y/W/H
    dc.w    %10011111               ; Mode Flag
    dc.l    0                       ; No Connection
    dc.l    vFileQuitMenuItemText   ; Text pointer
    dc.l    0                       ; No drawing when clicked
    dc.b    'Q'                     ; Shortcut Amiga-Q
    even
    dc.l    0                       ; No Submenu
    dc.w    0                       ; Next Select

    even
vFileQuitMenuItemText: 
    dc.b    0,1                     ; Colours
    dc.b    0                       ; Mode: Overwrite
    even
    dc.w    5,3                     ; X/Y Position
    dc.l    0                       ; Charset
    dc.l    vFileQuitMenuItemStr    ; String pointer
    dc.b    0

    even
vFileQuitMenuItemStr:
    dc.b    "Quit",0

    even
vSoundCheckboxGadget:
    dc.l    0                       ; Next Gadget
    dc.w    40,50                   ; X/Y Position
    dc.w    32,13                   ; Hitbox W/H
    dc.w    4                       ; Flags: Image | Invert
    dc.w    $102                    ; Activation Flags ToggleSelect/GadgetImmediate
    dc.w    1                       ; Type: Boolean
    dc.l    vCheckboxOnImage        ; Gadget Image
    dc.l    0                       ; No new gadget
    dc.l    vSoundCheckboxText      ; Text
    dc.l    0                       ; No Exclude
    dc.l    0                       ; No Special Info
    dc.w    1                       ; Gadget ID
    dc.l    0                       ; User Data

    even
vSoundCheckboxText: 
    dc.b    0,1                     ; Colours
    dc.b    0                       ; Mode: Overwrite
    even
    dc.w    -8,-14                  ; X/Y Position
    dc.l    0                       ; Charset
    dc.l    vSoundCheckboxStr       ; String pointer
    dc.l    0

    even
vSoundCheckboxStr:
    dc.b    "Sound",0

    even
vCheckboxOnImage:
    dc.w 0,0                        ; No offset
    dc.w 32,13                      ; 32x13 pixels
    dc.w 1                          ; Mode 1
    dc.l vCheckboxOnImageData       ; Pointer to the data
    dc.b 2                          ; FG Red
    dc.b 1                          ; BG white
    dc.l 0                          ; Nothing else
                        
    even
vCheckboxOnImageData:
    dc.l %00000000000000000000000000000000 
    dc.l %00000000011100000000000000000000 
    dc.l %00000000111110000011101001000000 
    dc.l %00000000111110000010101101000000 
    dc.l %00000000011110000010101011000000 
    dc.l %00000000000111000011101001000000 
    dc.l %00000000000011100000000000000000 
    dc.l %00000000000001110000000000000000 
    dc.l %00000000000111111111100000000000 
    dc.l %00000000001111111111110000000000 
    dc.l %00000000001111111111110000000000 
    dc.l %00000000000110000001100000000000 
    dc.l %00000000000000000000000000000000

    even
vCheckboxOffImage:
    dc.w 0,0                        ; No offset
    dc.w 32,13                      ; 32x13 pixels
    dc.w 1                          ; Mode 1
    dc.l vCheckboxOffImageData      ; Pointer to the data
    dc.b 2                          ; BG red
    dc.b 1                          ; FG white
    dc.l 0                          ; Nothing else

    even
vCheckboxOffImageData:
    dc.l %00000000000000000000000000000000 
    dc.l %00000000000000000000111000000000 
    dc.l %00011101110111000001111100000000 
    dc.l %00010101000100000001111100000000 
    dc.l %00010101100110000001111000000000 
    dc.l %00011101000100000011100000000000 
    dc.l %00000000000000000111000000000000 
    dc.l %00000000000000001110000000000000 
    dc.l %00000000000111111111100000000000 
    dc.l %00000000001111111111110000000000 
    dc.l %00000000001111111111110000000000 
    dc.l %00000000000110000001100000000000 
    dc.l %00000000000000000000000000000000

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
INTU_DRAW_IMAGE         equ -114
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
