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
    jsr     copy_images_to_chip_ram
    move.w  #FALSE,vMainDone
    ; Open Intuition Lib
    pea     vIntuLibNameStr
    jsr     exec_open_lib
    addq.l  #4,sp
    move.l  d0,vIntuBase
    ; Open WBScreen
    jsr     intu_open_workbench
    ; Open Window
    jsr     intu_open_window
    ; Set menu
    jsr     intu_set_menu_strip
    ; Get user port
    jsr     intu_get_user_port_handle
    ; Get rast port
    jsr     intu_get_rast_port 
    move.l  d0,vRastPortPtr
    ; Draw border
    pea     vSoundBorder
    move.l  #SOUND_GADGET_X,-(sp)
    move.l  #SOUND_GADGET_Y,-(sp)
    jsr     intu_draw_border
    add.l   #12,sp
_main_loop:
    ; Get Messages
    move.l  vUserPortPtr,-(sp)
    jsr     exec_get_msg
    addq.l  #4,sp
    move.l  d0,vIntuMsgPtr
    ; Handle Messages
    jsr     message_handler
    ; Should close?
    cmpi.w  #TRUE,vMainDone
    beq     _main_close
    jmp     _main_loop
_main_close:
    jsr     intu_clear_menu_strip
    jsr     intu_close_window
    ; Close Intuition Lib
    move.l  vIntuBase,-(sp)
    jsr     free_resources
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
_message_handler_check_window_close:
    cmpi.l  #IDCMP_CLOSEWINDOW,d6
    bne     _message_handler_check_menu_pick
    jsr     message_handler_window_close
    jmp     _message_handler_done
_message_handler_check_menu_pick:
    cmpi.l  #IDCMP_MENUPICK,d6
    bne     _message_handler_done
    jsr     message_handler_menu_pick
    jmp     _message_handler_done
_message_handler_done: 
    rts

message_handler_window_close:
    move.w  #TRUE,vMainDone
    rts

message_handler_menu_pick:
    ; Get value
    move.w  24(a0),d7
    ; Right click and let go
    cmpi.w  #$FFFF,d7
    beq     _message_handler_menu_click_done
    ; Get menu, title, item and submenu
    ; Title
    clr.l   d6
    move.w  d7,d6   
    andi.l  #$0000001F,d6
    ; item
    clr.l   d5
    move.w  d7,d5   
    lsr     #5,d5
    andi.l  #$0000003F,d5
    ; sub menu
    move.w  d7,d4   
    clr.l   d4
    lsr     #8,d4
    lsr     #3,d4
    andi.l  #$0000001F,d4
    ; Check for file menu
    cmpi.w  #1,d7
_message_handler_menu_click_done:
    rts

message_handler_file_menu:
    rts

copy_images_to_chip_ram:
    ; Allocate chip ram for On Switch
    move.l  #IMG_SIZE,-(sp)
    move.l  #MEMF_CHIP,-(sp)
    jsr     exec_alloc_mem
    addq.l  #8,sp
    move.l  d0,vSwitchOnImageDataChipPtr
    ; Setup Copy Data
    move.l  #12,d0
    movea.l #vSwitchOnImageData,a0 
    movea.l vSwitchOnImageDataChipPtr,a1
_copy_switch_on_data:
    move.l (a0)+,(a1)+
    dbra    d0,_copy_switch_on_data
    ; Update image struct
    move.l  vSwitchOnImageDataChipPtr,vSwitchOnImageDataPtr
    ; Allocate chip ram for Off Switch
    move.l  #IMG_SIZE,-(sp)
    move.l  #MEMF_CHIP,-(sp)
    jsr     exec_alloc_mem
    addq.l  #8,sp
    move.l  d0,vSwitchOffImageDataChipPtr
    ; Setup Copy Data
    move.l  #12,d0
    movea.l #vSwitchOffImageData,a0 
    movea.l vSwitchOffImageDataChipPtr,a1
_copy_switch_off_data:
    move.l (a0)+,(a1)+
    dbra    d0,_copy_switch_off_data
    ; Update image struct
    move.l  vSwitchOffImageDataChipPtr,vSwitchOffImageDataPtr
    rts

free_resources:
    ; Free Switch On 
    move.l  vSwitchOnImageDataChipPtr,-(sp) 
    move.l  #IMG_SIZE,-(sp)
    jsr     exec_free_mem
    addq.l  #8,sp
    ; Free Switch Off
    move.l  vSwitchOffImageDataChipPtr,-(sp) 
    move.l  #IMG_SIZE,-(sp)
    jsr     exec_free_mem
    addq.l  #8,sp
    ; Ok
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

;   move.l  #mem_size,-(sp)
;   move.l  type,-(sp)
;   jsr     exec_alloc_mem
;   addq.l  #8,sp
;   move.l  d0,voutputptr
exec_alloc_mem:
    move.l  4(sp),d1 
    move.l  8(sp),d0
    movea.l EXEC_BASE,a6
    jsr     EXEC_ALLOC_MEM(a6)
    rts

;   move.l  address,-(sp) ; or pea
;   move.l  #size,-(sp)
;   jsr     exec_free_mem
;   addq.l  #8,sp
exec_free_mem:
    move.l  8(sp),a1
    move.l  4(sp),d0
    movea.l EXEC_BASE,a6
    jsr     EXEC_FREE_MEM(a6)
    rts

; Intuition Routines -----------------------------------------------------------

;   pea     ScreenDefinition
;   jsr     intu_open_screen
;   addq.l  #4,sp
;   move.l  d0,vScreenPtr
intu_open_screen:
    movea.l 4(sp),a0
    move.l  vIntuBase,a6
    jsr     INTU_OPEN_SCREEN(a6)
    rts

;   pea     vScreenPtr
;   jsr     intu_close_screen
;   addq.l  #4,sp
intu_close_screen:
    move.l  4(sp),a0
    move.l  vIntuBase,a6
    jsr     INTU_CLOSE_SCREEN(a6)
    rts

intu_open_window:
    move.l  vWBScreenPtr,vWindowDef_ScreenPtr
    lea     vWindowDef,a0
    move.l  vIntuBase,a6
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
;   pea     RequestText
;   pea     LeftText
;   pea     RightText
;   pea     WindowPointer
;   jsr     intu_auto_request
;   add.l   #16,sp
intu_auto_request:
    movea.l  4(sp),a0
    movea.l 12(sp),a1
    movea.l 16(sp),a2
    movea.l 8(sp),a3
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
    movea.l  vWindowPtr,a0
    move.l  50(a0),d0
    rts

; Print some text
; Usage:
;    pea     vRequesterText
;    move.l  #5,-(sp)
;    move.l  #5,-(sp)
;    jsr     intu_print_itext
;    add.l   #12,sp
intu_print_itext:
    movea.l vRastPortPtr,a0
    movea.l vIntuBase,a6
    movea.l 12(sp),a1           ; Text struct pointer
    move.l  8(sp),d0            ; X
    move.l  4(sp),d1            ; Y
    jsr     INTU_PRINT_ITEXT(a6)
    rts

;   Usage
;       pea     ImageStruct
;       move.l  X,-(sp)
;       move.l  Y,-(sp)
;       jsr     intu_draw_image
;       add.l  #12,sp
intu_draw_image:
    move.l  vRastPortPtr,a0        ; Rast Port
    move.l  12(sp),a1           ; image struct
    move.l  8(sp),d0            ; X
    move.l  4(sp),d1            ; Y
    movea.l vIntuBase,a6        ; intu
    jsr     INTU_DRAW_IMAGE(a6)
    rts

intu_open_workbench:
    move.l  vIntuBase,a6
    jsr     INTU_OPEN_WORKBENCH(a6)
    move.l  d0,vWBScreenPtr
    rts

intu_close_workbench:
    move.l  vIntuBase,a6
    jsr     INTU_CLOSE_WORKBENCH(a6)
    rts

;   pea     vWindowPtr
;   jsr     intu_viewport_address
;   addq.l  #4,sp
;   move.l  d0,vViewportPtr
intu_viewport_address:
    movea.l 4(sp),a0
    movea.l vIntuBase,a6
    jsr     INTU_VIEWPORT_ADDRESS(a6)
    rts

;   pea     vBorderStruct
;   move.l  #X,-(sp)
;   move.l  #Y,-(sp)
;   jsr     intu_draw_border
;   add.l   #12,sp
intu_draw_border:
    movea.l vRastPortPtr,a0
    movea.l 12(sp),a1
    move.l  8(sp),d0
    move.l  4(sp),d1
    movea.l vIntuBase,a6
    jsr     INTU_DRAW_BORDER(a6)
    rts

;-------------------------------------------------------------------------------
    section data
;-------------------------------------------------------------------------------

; Strings ----------------------------------------------------------------------

    even
vIntuLibNameStr:  
    dc.b    "intuition.library",0

    even
vWindowTitleStr:       
    dc.b    "Octronic SortVis v1",0


; Window Definition ------------------------------------------------------------

    even
vWindowDef: 
vWindowDef_X:           dc.w    20
vWindowDef_Y:           dc.w    20
vWindowDef_W:           dc.w    600
vWindowDef_H:           dc.w    220
vWindowDef_FGColour:    dc.b    1
vWindowDef_BGColour:    dc.b    3
vWindowDef_IDCMP:       dc.l    $200
vWindowDef_Type:        dc.l    $100f
vWindowDef_Gadget:      dc.l    vSoundGadget
vWindowDef_Graphics:    dc.l    0
vWindowDef_Title:       dc.l    vWindowTitleStr
vWindowDef_ScreenPtr:   dc.l    0
vWindowDef_Bitmap:      dc.l    0
vWindowDef_MinW:        dc.w    100 
vWindowDef_MinH:        dc.w    100
vWindowDef_MaxW:        dc.w    640
vWindowDef_MaxH:        dc.w    256
vWindowDef_ScreenType:  dc.w    15

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
    dc.w    %010010110              ; Mode Flag
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
vSoundGadget:
    dc.l    vNumElementsGadget      ; Next Gadget
    dc.w    SOUND_GADGET_X
    dc.w    SOUND_GADGET_Y          ; X/Y Position
    dc.w    SOUND_GADGET_W
    dc.w    SOUND_GADGET_H          ; Hitbox W/H
    dc.w    6                       ; Flags: Image | Invert
    dc.w    $102                    ; Activation Flags ToggleSelect/GadgetImmediate
    dc.w    1                       ; Type: Boolean
    dc.l    vSwitchOnImage          ; Gadget Image
    dc.l    vSwitchOffImage         ; No new gadget
    dc.l    vSoundText              ; Text
    dc.l    0                       ; No Exclude
    dc.l    0                       ; No Special Info
    dc.w    1                       ; Gadget ID
    dc.l    0                       ; User Data

    even
vSoundText: 
    dc.b    1,2                     ; Colours
    dc.b    0                       ; Mode: Overwrite
    even
    dc.w    32,4                    ; X/Y Position
    dc.l    0                       ; Charset
    dc.l    vSoundStr               ; String pointer
    dc.l    0

    even
vSoundStr:
    dc.b    "Sound",0

    even
vSwitchOnImage:
    dc.w 0
    dc.w 0                  ; No offset
    dc.w 32
    dc.w 13                 ; 32x13 pixels
    dc.w 1                  ; Bitplanes
vSwitchOnImageDataPtr:
    dc.l vSwitchOnImageData ; Pointer to the data
    dc.b 1                  ; PlanePick
    dc.b 0                  ; PlaneOnOff
    dc.l 0                  ; Nothing else
                        
    even
vSwitchOnImageData:
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
vSwitchOffImage:
    dc.w 0
    dc.w 0                      ; No offset
    dc.w 32
    dc.w 13                     ; 32x13 pixels
    dc.w 1                      ; Mode 1
vSwitchOffImageDataPtr:
    dc.l vSwitchOffImageData    ; Pointer to the data
    dc.b 1                      ; PlanePick
    dc.b 0                      ; PlaneOnOff
    dc.l 0                      ; Nothing else

    even
vSwitchOffImageData:
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

    even
vSoundBorder:
    dc.w    0       ; Horizontal Distance
    dc.w    0       ; Vertical Distance
    dc.b    1       ; black Frame
    dc.b    0       ; Background (unused)
    dc.b    0       ; Mode: JAM1
    dc.b    5       ; 5 X/Y pairs used together
    dc.l    vSoundBorderCoords
    dc.l    0       ; No more structs

    even
vSoundBorderCoords:
    dc.w     -2, -2
    dc.w    SOUND_GADGET_W+2, -2
    dc.w    SOUND_GADGET_W+2, SOUND_GADGET_H+2
    dc.w     -2, SOUND_GADGET_H+2
    dc.w     -2, -2

    even
vNumElementsGadget:
    dc.l    0                       ; * to next gadget 
    dc.w    NUM_ELEMENTS_X          ; X,Y,W,H
    dc.w    NUM_ELEMENTS_Y          
    dc.w    NUM_ELEMENTS_W          
    dc.w    NUM_ELEMENTS_H          
    dc.w    0                       ; Flags: Normal
    dc.w    $802                    ; Activation $802 for long int
    dc.w    4                       ; Type: String gadget
    dc.l    vNumElementsBorder      ; Pointer to border
    dc.l    0                       ; No drawing
    dc.l    0                       ; No Text
    dc.l    0                       ; No exclude
    dc.l    vNumElementsStrInfo     ; * to StringInfo
    dc.w    2                       ; Gadget ID
    dc.l    0                       ; No User Data

    even
vNumElementsBorder:
    dc.w    0       ; Horizontal Distance
    dc.w    0       ; Vertical Distance
    dc.b    1       ; black Frame
    dc.b    0       ; Background (unused)
    dc.b    0       ; Mode: JAM1
    dc.b    5       ; 5 X/Y pairs used together
    dc.l    vNumElementsBorderCoords
    dc.l    0       ; No more structs

    even
vNumElementsBorderCoords:
    dc.w     -2, -2
    dc.w    NUM_ELEMENTS_W+2, -2
    dc.w    NUM_ELEMENTS_W+2, NUM_ELEMENTS_H+2
    dc.w     -2, NUM_ELEMENTS_H+2
    dc.w     -2, -2

    even
vNumElementsStrInfo:
    dc.l    vNumElementsStrBuffer   ; Pointer to text buffer
    dc.l    vNumElementsUndoBuffer  ; Pointer to undo buffer
    dc.w    0                       ; Cursor position
    dc.w    4                       ; Max # of chars
    dc.w    0                       ; Output txt from this character
    dc.w    0                       ; Char pos in undo buffer
    dc.w    0                       ; # of chars in text buffer
    dc.w    0                       ; # of chars visible in box 
    dc.w    0                       ; horizontal box offset 
    dc.w    0                       ; vertical box offset
    dc.l    0                       ; pointer to RastPort
    dc.l    0                       ; long with value of input (for integers)
    dc.l    0                       ; Standard keyboard table
;-------------------------------------------------------------------------------
    section bss
;-------------------------------------------------------------------------------
vIntuBase:                  ds.l    1
vWindowPtr:                 ds.l    1
vUserPortPtr:               ds.l    1
vIntuMsgPtr:                ds.l    1
vMainDone:                  ds.w    1
vWBScreenPtr:               ds.l    1
vViewportPtr:               ds.l    1
vRastPortPtr:               ds.l    1

vSwitchOnImageDataChipPtr:  ds.l    1
vSwitchOffImageDataChipPtr: ds.l    1

vNumElementsStrBuffer:      ds.b    5
vNumElementsUndoBuffer:     ds.b    5 

;-------------------------------------------------------------------------------
;   Constants
;-------------------------------------------------------------------------------

; Application Specific

TRUE                    equ 1
FALSE                   equ 0

; Exec Library

EXEC_BASE               equ 4
EXEC_ALLOC_MEM          equ -198 ; byteSize     d0, requirements d1 
EXEC_ALLOC_ABS          equ -204 ; byteSize     d0, location     a1
EXEC_FREE_MEM           equ -210 ; memoryBlock  a1, byteSize     d0 
EXEC_GET_MSG            equ -372
EXEC_OPEN_LIB           equ -408
EXEC_CLOSE_LIB          equ -414
; Intuition Library

INTU_CLEAR_MENU_STRIP   equ -54
INTU_CLOSE_SCREEN       equ -66
INTU_CLOSE_WINDOW       equ -72
INTU_CLOSE_WORKBENCH    equ -78
INTU_DRAW_BORDER        equ -108
INTU_DRAW_IMAGE         equ -114
INTU_OPEN_SCREEN        equ -198
INTU_OPEN_WINDOW        equ -204
INTU_OPEN_WORKBENCH     equ -210
INTU_PRINT_ITEXT        equ -216
INTU_SET_MENU_STRIP     equ -264
INTU_VIEWPORT_ADDRESS   equ -300
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

; Misc

CHIPMEM_LIMIT           equ $080000
MEMF_CHIP               equ 2
IMG_SIZE                equ 52


; Layout
SOUND_GADGET_X          equ 10
SOUND_GADGET_Y          equ 15
SOUND_GADGET_W          equ 80
SOUND_GADGET_H          equ 13

NUM_ELEMENTS_X          equ 100
NUM_ELEMENTS_Y          equ 15
NUM_ELEMENTS_W          equ 32
NUM_ELEMENTS_H          equ 8


;-------------------------------------------------------------------------------
    end
;-------------------------------------------------------------------------------
