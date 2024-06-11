; ##############################
; # Programm: 10_Credits.asm   #
; # Autor:    Christian Gerbig #
; # Datum:    21.12.2023       #
; # Version:  1.3 beta         #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

  SECTION code_and_variables,CODE

  MC68040

  XREF COLOR00BITS
  XREF mouse_handler
  XREF sine_table
  XREF bg_image_data

  XDEF start_10_credits


; ** Library-Includes V.3.x nachladen **
; --------------------------------------
  ;INCDIR  "OMA:include/"
  INCDIR "Daten:include3.5/"

  INCLUDE "dos/dos.i"
  INCLUDE "dos/dosextens.i"
  INCLUDE "libraries/dos_lib.i"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "graphics/GFXBase.i"
  INCLUDE "graphics/videocontrol.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "intuition/intuition.i"
  INCLUDE "intuition/intuition_lib.i"

  INCLUDE "resources/cia_lib.i"

  INCLUDE "hardware/adkbits.i"
  INCLUDE "hardware/blit.i"
  INCLUDE "hardware/cia.i"
  INCLUDE "hardware/custom.i"
  INCLUDE "hardware/dmabits.i"
  INCLUDE "hardware/intbits.i"

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


; ** Konstanten **
; ----------------

  INCLUDE "equals.i"

requires_68030                 EQU FALSE  
requires_68040                 EQU FALSE
requires_68060                 EQU FALSE
requires_fast_memory           EQU FALSE
requires_multiscan_monitor     EQU FALSE

workbench_start                EQU FALSE
workbench_fade                 EQU FALSE
text_output                    EQU FALSE

sys_taken_over
own_display_set_second_copperlist
pass_global_references
pass_return_code

DMABITS                        EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
INTENABITS                     EQU INTF_SETCLR

CIAAICRBITS                    EQU CIAICRF_SETCLR
CIABICRBITS                    EQU CIAICRF_SETCLR

COPCONBITS                     EQU TRUE

pf1_x_size1                    EQU 0
pf1_y_size1                    EQU 0
pf1_depth1                     EQU 0
pf1_x_size2                    EQU 0
pf1_y_size2                    EQU 0
pf1_depth2                     EQU 0
pf1_x_size3                    EQU 384
pf1_y_size3                    EQU 256
pf1_depth3                     EQU 7
pf1_colors_number              EQU 128

pf2_x_size1                    EQU 0
pf2_y_size1                    EQU 0
pf2_depth1                     EQU 0
pf2_x_size2                    EQU 0
pf2_y_size2                    EQU 0
pf2_depth2                     EQU 0
pf2_x_size3                    EQU 0
pf2_y_size3                    EQU 0
pf2_depth3                     EQU 0
pf2_colors_number              EQU 0
pf_colors_number               EQU pf1_colors_number+pf2_colors_number
pf_depth                       EQU pf1_depth3+pf2_depth3

extra_pf_number                EQU 2
extra_pf1_x_size               EQU 192
extra_pf1_y_size               EQU 256+(16*2)
extra_pf1_depth                EQU 1
extra_pf2_x_size               EQU 192
extra_pf2_y_size               EQU 256+(16*2)
extra_pf2_depth                EQU 1

spr_number                     EQU 8
spr_x_size1                    EQU 64
spr_x_size2                    EQU 64
spr_depth                      EQU 2
spr_colors_number              EQU 0 ;16*2
spr_odd_color_table_select     EQU 8
spr_even_color_table_select    EQU 9
spr_used_number                EQU 8
spr_swap_number                EQU 8

audio_memory_size              EQU 0

disk_memory_size               EQU 0

extra_memory_size              EQU 0

chip_memory_size               EQU 0

AGA_OS_Version                 EQU 39

CIAA_TA_value                  EQU 0
CIAA_TB_value                  EQU 0
CIAB_TA_value                  EQU 0
CIAB_TB_value                  EQU 0
CIAA_TA_continuous             EQU FALSE
CIAA_TB_continuous             EQU FALSE
CIAB_TA_continuous             EQU FALSE
CIAB_TB_continuous             EQU FALSE

beam_position                  EQU $136

pixel_per_line                 EQU 336
visible_pixels_number          EQU 352
visible_lines_number           EQU 256
MINROW                         EQU VSTART_256_lines

pf_pixel_per_datafetch         EQU 16 ;1x
DDFSTRTBITS                    EQU DDFSTART_320_pixel
DDFSTOPBITS                    EQU DDFSTOP_overscan_16_pixel
spr_pixel_per_datafetch        EQU 64 ;4x

display_window_HSTART          EQU HSTART_352_pixel
display_window_VSTART          EQU MINROW
DIWSTRTBITS                    EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP           EQU HSTOP_352_pixel
display_window_VSTOP           EQU MINROW+visible_lines_number
DIWSTOPBITS                    EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width                EQU pf1_x_size3/8
extra_pf1_plane_width          EQU extra_pf1_x_size/8
extra_pf2_plane_width          EQU extra_pf2_x_size/8
data_fetch_width               EQU pixel_per_line/8
pf1_plane_moduli               EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                    EQU TRUE
BPLCON2BITS                    EQU BPLCON2F_PF2P2
BPLCON3BITS1                   EQU BPLCON3F_SPRES0
BPLCON3BITS2                   EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                    EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
DIWHIGHBITS                    EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                      EQU FMODEF_SPR32+FMODEF_SPAGEM

cl1_display_x_size             EQU 0
cl1_display_width              EQU cl1_display_x_size/8
cl1_display_y_size             EQU visible_lines_number
cl1_HSTART1                    EQU display_window_HSTART-(pf1_depth3*CMOVE_slot_period)-4
cl1_VSTART1                    EQU MINROW
cl1_HSTART2                    EQU $00
cl1_VSTART2                    EQU beam_position&$ff

sine_table_length              EQU 256

; **** Background-Image ****
bg_image_x_size                EQU 352
bg_image_plane_width           EQU bg_image_x_size/8
bg_image_y_size                EQU 256
bg_image_depth                 EQU 7

; **** Logo ****
lg_image_x_size                EQU 64
lg_image_plane_width           EQU lg_image_x_size/8
lg_image_y_size                EQU 256
lg_image_depth                 EQU 16

lg_image_x_position            EQU HSTART_320_pixel
lg_image_y_position            EQU display_window_VSTART

; **** Vert-Text-Scroll ****
vts_image_x_size               EQU 320
vts_image_plane_width          EQU vts_image_x_size/8
vts_image_depth                EQU 1
vts_image_colors_number        EQU 2

vts_buffer_x_size              EQU 192
vts_buffer_width               EQU vts_buffer_x_size/8
vts_buffer_y_size              EQU 256
vts_buffer_depth               EQU vts_image_depth
vts_buffer_x_position          EQU HSTOP_320_pixel-vts_buffer_x_size
vts_buffer_y_position          EQU display_window_VSTART

vts_origin_character_x_size    EQU 16
vts_origin_character_y_size    EQU 15
vst_origin_charcter_depth      EQU vts_image_depth

vts_text_character_x_size      EQU 16
vts_text_character_width       EQU vts_text_character_x_size/8
vts_text_character_y_size      EQU vts_origin_character_y_size+1
vts_text_character_depth       EQU vts_image_depth

vts_vert_scroll_speed          EQU 1

vts_text_character_y_restart   EQU visible_lines_number+vts_text_character_y_size
vts_text_characters_per_line   EQU vts_buffer_x_size/vts_text_character_x_size
vts_text_characters_per_column EQU (visible_lines_number+vts_text_character_y_size)/vts_text_character_y_size
vts_text_characters_number     EQU vts_text_characters_per_line*vts_text_characters_per_column

vts_copy_character_blit_x_size EQU vts_text_character_x_size
vts_copy_character_blit_y_size EQU vts_text_character_y_size*vts_text_character_depth

; **** Image-Fader ****
if_start_color                 EQU 1
if_color_table_offset          EQU 1
if_colors_number               EQU pf1_colors_number-1

ifi_fader_speed_max            EQU 3
ifi_fader_radius               EQU ifi_fader_speed_max
ifi_fader_center               EQU ifi_fader_speed_max+1
ifi_fader_angle_speed          EQU 3

ifo_fader_speed_max            EQU 3
ifo_fader_radius               EQU ifo_fader_speed_max
ifo_fader_center               EQU ifo_fader_speed_max+1
ifo_fader_angle_speed          EQU 1

; **** Scroll-Logo-Left ****
sll_x_radius                   EQU 88
sll_x_center                   EQU 88

; **** Scroll-Logo-Left-In ****
slli_x_angle_speed             EQU 1

; **** Scroll-Logo-Left-Out ****
sllo_x_angle_speed             EQU 2

; **** Effects-Handler ****
eh_trigger_number_max          EQU 8


pf1_bitplanes_x_offset         EQU 16
pf1_BPL1DAT_x_offset           EQU 0


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enth�lt **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enth�lt **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enth�lt **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enth�lt **
; -----------------------------------------------------------------------
  RSRESET

cl1_extension1      RS.B 0

cl1_ext1_WAIT       RS.L 1
cl1_ext1_BPL7DAT    RS.L 1
cl1_ext1_BPL6DAT    RS.L 1
cl1_ext1_BPL5DAT    RS.L 1
cl1_ext1_BPL4DAT    RS.L 1
cl1_ext1_BPL3DAT    RS.L 1
cl1_ext1_BPL2DAT    RS.L 1
cl1_ext1_BPL1DAT    RS.L 1

cl1_extension1_SIZE RS.B 0

  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_extension1_entry RS.B (cl1_extension1_SIZE*cl1_display_y_size)+4

cl1_WAIT         RS.L 1
cl1_INTREQ       RS.L 1

cl1_end          RS.L 1

copperlist1_SIZE RS.B 0


; ** Konstanten f�r die gr��e der Copperlisten **
; -----------------------------------------------
cl1_size1           EQU 0
cl1_size2           EQU 0
cl1_size3           EQU copperlist1_SIZE
cl2_size1           EQU 0
cl2_size2           EQU 0
cl2_size3           EQU 0


; ** Sprite0-Zusatzstruktur **
; ----------------------------
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr0_extension1_SIZE  RS.B 0

; ** Sprite0-Hauptstruktur **
; ---------------------------
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_SIZE

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_SIZE          RS.B 0

; ** Sprite1-Zusatzstruktur **
; ----------------------------
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr1_extension1_SIZE  RS.B 0

; ** Sprite1-Hauptstruktur **
; ---------------------------
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_SIZE

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_SIZE          RS.B 0

; ** Sprite2-Zusatzstruktur **
; ----------------------------
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr2_extension1_SIZE  RS.B 0

; ** Sprite2-Hauptstruktur **
; ---------------------------
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_SIZE

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_SIZE          RS.B 0

; ** Sprite3-Hauptstruktur **
; ---------------------------
  RSRESET

spr3_begin            RS.B 0

spr3_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_SIZE          RS.B 0

; ** Sprite4-Zusatzstruktur **
; ----------------------------
  RSRESET

spr4_extension1       RS.B 0

spr4_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr4_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr4_extension1_SIZE  RS.B 0

; ** Sprite4-Hauptstruktur **
; ---------------------------
  RSRESET

spr4_begin            RS.B 0

spr4_extension1_entry RS.B spr4_extension1_SIZE

spr4_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_SIZE          RS.B 0

; ** Sprite5-Hauptstruktur **
; ---------------------------
  RSRESET

spr5_begin            RS.B 0

spr5_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_SIZE          RS.B 0

; ** Sprite6-Zusatzstruktur **
; ----------------------------
  RSRESET

spr6_extension1       RS.B 0

spr6_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr6_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr6_extension1_SIZE  RS.B 0

; ** Sprite6-Hauptstruktur **
; ---------------------------
  RSRESET

spr6_begin            RS.B 0

spr6_extension1_entry RS.B spr6_extension1_SIZE

spr6_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_SIZE          RS.B 0

; ** Sprite7-Hauptstruktur **
; ---------------------------
  RSRESET

spr7_begin            RS.B 0

spr7_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_SIZE          RS.B 0


; ** Konstanten f�r die Gr��e der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1        EQU spr_x_size1
spr0_y_size1        EQU sprite0_SIZE/(spr_pixel_per_datafetch/4)
spr1_x_size1        EQU spr_x_size1
spr1_y_size1        EQU sprite1_SIZE/(spr_pixel_per_datafetch/4)
spr2_x_size1        EQU spr_x_size1
spr2_y_size1        EQU sprite2_SIZE/(spr_pixel_per_datafetch/4)
spr3_x_size1        EQU spr_x_size1
spr3_y_size1        EQU sprite3_SIZE/(spr_pixel_per_datafetch/4)
spr4_x_size1        EQU spr_x_size1
spr4_y_size1        EQU sprite4_SIZE/(spr_pixel_per_datafetch/4)
spr5_x_size1        EQU spr_x_size1
spr5_y_size1        EQU sprite5_SIZE/(spr_pixel_per_datafetch/4)
spr6_x_size1        EQU spr_x_size1
spr6_y_size1        EQU sprite6_SIZE/(spr_pixel_per_datafetch/4)
spr7_x_size1        EQU spr_x_size1
spr7_y_size1        EQU sprite7_SIZE/(spr_pixel_per_datafetch/4)

spr0_x_size2        EQU spr_x_size2
spr0_y_size2        EQU sprite0_SIZE/(spr_pixel_per_datafetch/4)
spr1_x_size2        EQU spr_x_size2
spr1_y_size2        EQU sprite1_SIZE/(spr_pixel_per_datafetch/4)
spr2_x_size2        EQU spr_x_size2
spr2_y_size2        EQU sprite2_SIZE/(spr_pixel_per_datafetch/4)
spr3_x_size2        EQU spr_x_size2
spr3_y_size2        EQU sprite3_SIZE/(spr_pixel_per_datafetch/4)
spr4_x_size2        EQU spr_x_size2
spr4_y_size2        EQU sprite4_SIZE/(spr_pixel_per_datafetch/4)
spr5_x_size2        EQU spr_x_size2
spr5_y_size2        EQU sprite5_SIZE/(spr_pixel_per_datafetch/4)
spr6_x_size2        EQU spr_x_size2
spr6_y_size2        EQU sprite6_SIZE/(spr_pixel_per_datafetch/4)
spr7_x_size2        EQU spr_x_size2
spr7_y_size2        EQU sprite7_SIZE/(spr_pixel_per_datafetch/4)


; ** Struktur, die alle Variablenoffsets enth�lt **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; **** Vert-Text-Scroll ****
vts_image                      RS.L 1
vts_variable_vert_scroll_speed RS.W 1
vts_text_table_start           RS.W 1

; **** Image-Fader ****
if_colors_counter              RS.W 1
if_copy_colors_state           RS.W 1

ifi_state                      RS.W 1
ifi_fader_angle                RS.W 1

ifo_state                      RS.W 1
ifo_fader_angle                RS.W 1

; **** Scroll-Logo-Left-In ****
slli_state                     RS.W 1
slli_x_angle                   RS.W 1

; **** Scroll-Logo-Left-Out ****
sllo_state                     RS.W 1
sllo_x_angle                   RS.W 1

; **** Effects-Handler ****
eh_trigger_number              RS.W 1

; **** Main ****
fx_state                       RS.W 1

variables_SIZE                 RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_10_credits
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Vert-Text-Scroll ****
  lea     vts_image_data,a0
  move.l  a0,vts_image(a3)
  moveq   #vts_vert_scroll_speed,d2
  moveq   #TRUE,d0
  move.w  d0,vts_variable_vert_scroll_speed(a3)
  move.w  d0,vts_text_table_start(a3)

; **** Image-Fader ****
  move.w  d0,if_colors_counter(a3)
  moveq   #FALSE,d1
  move.w  d1,if_copy_colors_state(a3)

; **** Image-Fader-In ****
  move.w  d1,ifi_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ifi_fader_angle(a3) ;90 Grad

; **** Image-Fader-Out ****
  move.w  d1,ifo_state(a3)
  move.w  d2,ifo_fader_angle(a3) ;90 Grad

; **** Scroll-Logo-Left ****
  move.w  d1,slli_state(a3)
  move.w  d0,slli_x_angle(a3) ;0 Grad

  move.w  d1,sllo_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,sllo_x_angle(a3) ;90 Grad

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausf�hren **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_color_registers
  bsr     init_sprites
  bsr     bg_copy_image_to_bitplane
  bsr     vts_init_characters_offsets
  bsr     vts_init_characters_x_positions
  bsr     vts_init_characters_y_positions
  bsr     vts_init_characters_images
  bra     init_first_copperlist

; ** Farben initialisieren **
; ---------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 4
  CPU_INIT_COLORHI COLOR00,16,spr_color_table_logo
  CPU_INIT_COLORHI COLOR16,16,spr_color_table_vert_text_scroll

  CPU_SELECT_COLORLO_BANK 4
  CPU_INIT_COLORLO COLOR00,16,spr_color_table_logo
  CPU_INIT_COLORLO COLOR16,16,spr_color_table_vert_text_scroll
  rts

; ** Sprites initialisieren **
; ----------------------------
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bsr.s   lg_init_sprites
  bsr     vts_init_sprites
  bra     spr_copy_structures

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; **** Logo ****
  CNOP 0,4
lg_init_sprites
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a0           ;1. Sprite-Struktur (SPR0)
  ADDF.W  (spr_pixel_per_datafetch/4),a0 ;Sprite-Header �berspringen
  move.l  (a2),a1            ;2. Sprite-Struktur (SPR1)
  ADDF.W  (spr_pixel_per_datafetch/4),a1 ;Sprite-Header �berspringen
  lea     lg_image_data,a2   ;Zeiger auf Grafikdaten
  MOVEF.W lg_image_y_size-1,d7 ;H�he des Einzelsprites
lg_init_sprites_loop
  move.l  (a2)+,(a0)+        ;Plane0 64 Pixel
  move.l  (a2)+,(a0)+        ;Plane0
  move.l  (a2)+,(a0)+        ;Plane1 64 Pixel
  move.l  (a2)+,(a0)+        ;Plane1
  move.l  (a2)+,(a1)+        ;Plane2 64 Pixel
  move.l  (a2)+,(a1)+        ;Plane2
  move.l  (a2)+,(a1)+        ;Plane3 64 Pixel
  move.l  (a2)+,(a1)+        ;Plane3
  dbf     d7,lg_init_sprites_loop
  rts

; **** Vert-Scroll-Text ****
  CNOP 0,4
vts_init_sprites
  MOVEF.W vts_buffer_x_position*4,d3 ;X
  moveq   #vts_buffer_y_position,d4 ;Y
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  8(a2),a0           ;1. Sprite-Struktur (SPR2)
  move.l  16(a2),a1          ;2. Sprite-Struktur (SPR4)
  move.l  24(a2),a2          ;2. Sprite-Struktur (SPR6)
  move.w  d3,d0
  move.w  d4,d1
  MOVEF.W vts_buffer_y_size,d2 ;H�he
  add.w   d1,d2              ;H�he zu Y addieren
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPR2POS
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPR2CTL
  add.w   #spr_x_size2*4,d3
  move.w  d3,d0
  move.w  d4,d1
  MOVEF.W vts_buffer_y_size,d2 ;H�he
  add.w   d1,d2              ;H�he zu Y addieren
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a1)            ;SPR4POS
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPR4CTL
  add.w   #spr_x_size2*4,d3
  move.w  d3,d0
  move.w  d4,d1
  MOVEF.W vts_buffer_y_size,d2 ;H�he
  add.w   d1,d2              ;H�he zu Y addieren
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a2)            ;SPR6POS
  move.w  d2,spr_pixel_per_datafetch/8(a2) ;SPR6CTL
  rts

; ** Spritedaten kopieren **
; --------------------------
  COPY_SPRITE_STRUCTURES

; **** Background-Image ****
; ** Objekt ins Playfield kopieren **
; -----------------------------------
  CNOP 0,4
bg_copy_image_to_bitplane
  movem.l a3-a6,-(a7)
  move.l  #bg_image_data+(pf1_bitplanes_x_offset/8),a1 ;BP0
  move.l  pf1_display(a3),a3 ;Ziel
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP1
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP2
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP3
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP4
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP5
  bsr.s   bg_copy_image_data
  add.l   #bg_image_plane_width,a1 ;BP6
  bsr.s   bg_copy_image_data
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
bg_copy_image_data
  move.l  a1,a0              ;Quelle
  move.l  (a3)+,a2           ;Ziel
  MOVEF.W bg_image_y_size-1,d7 ;Anzahl der Zeilen
bg_copy_image_data_loop
  REPT pixel_per_line/16
    move.w  (a0)+,(a2)+     ;42 Bytes kopieren
  ENDR
  ADDF.W  (bg_image_plane_width*(bg_image_depth-1))+2,a0 ;n�chste Zeile in Quelle
  ADDF.W  (pf1_plane_width*(pf1_depth3-1))+6,a2 ;n�chste Zeile in Ziel
  dbf     d7,bg_copy_image_data_loop
  rts

; **** Vert-Text-Scroll ****
; ** Offsets der Buchstaben im Characters-Pic berechnen **
; --------------------------------------------------------
  INIT_CHARACTERS_OFFSETS.W vts

; ** X-Positionen der Chars berechnen **
; --------------------------------------
  INIT_CHARACTERS_X_POSITIONS vts,LORES,,text_characters_per_line

; ** Y-Positionen der Charss berechnen **
; ---------------------------------------
  INIT_CHARACTERS_Y_POSITIONS vts,text_characters_per_column

; ** Laufschrift initialisieren **
; --------------------------------
  INIT_CHARACTERS_IMAGES vts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  bsr.s   cl1_init_sprite_pointers
  bsr.s   cl1_init_color_registers
  bsr     cl1_init_bitplane_pointers
  bsr     cl1_init_BPLxDAT_registers
  bsr     cl1_init_copint
  COPLISTEND
  bsr     cl1_set_sprite_pointers
  bra     cl1_set_bitplane_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_color_registers
  COP_INIT_COLORHI COLOR00,32,pf1_color_table
  COP_SELECT_COLORHI_BANK 1
  COP_INIT_COLORHI COLOR00,32
  COP_SELECT_COLORHI_BANK 2
  COP_INIT_COLORHI COLOR00,32
  COP_SELECT_COLORHI_BANK 3
  COP_INIT_COLORHI COLOR00,32

  COP_SELECT_COLORLO_BANK 0
  COP_INIT_COLORLO COLOR00,32,pf1_color_table
  COP_SELECT_COLORLO_BANK 1
  COP_INIT_COLORLO COLOR00,32
  COP_SELECT_COLORLO_BANK 2
  COP_INIT_COLORLO COLOR00,32
  COP_SELECT_COLORLO_BANK 3
  COP_INIT_COLORLO COLOR00,32
  rts

  COP_INIT_BITPLANE_POINTERS cl1

  CNOP 0,4
cl1_init_BPLxDAT_registers
  movem.l a4-a5,-(a7)
  move.l  #bg_image_data+(pf1_BPL1DAT_x_offset/8),a1 ;BP0
  move.w  #BPL5DAT,a2
  move.w  #BPL6DAT,a4
  move.w  #BPL7DAT,a5
  move.l  #(((cl1_VSTART1<<24)|(((cl1_HSTART1/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.w  #BPL1DAT,d1
  move.w  #BPL2DAT,d2
  move.w  #BPL3DAT,d3
  move.w  #BPL4DAT,d4
  move.l  #(((cl_y_wrap<<24)|(((cl1_HSTART1/4)*2)<<16))|$10000)|$fffe,d5 ;WAIT-Befehl
  moveq   #1,d6
  ror.l   #8,d6              ;$01000000 = Additionswert
  MOVEF.W cl1_display_y_size-1,d7 ;Anzahl der Zeilen
cl1_init_BPLxDAT_registers_loop
  move.l  d0,(a0)+           ;WAIT x,y
  move.w  a5,(a0)+           ;BPL7DAT
  move.w  bg_image_plane_width*6(a1),(a0)+ ;Erste 16 Pixel Bitplane 7
  move.w  a4,(a0)+           ;BPL6DAT
  move.w  bg_image_plane_width*5(a1),(a0)+ ;Erste 16 Pixel Bitplane 6
  move.w  a2,(a0)+           ;BPL5DAT
  move.w  bg_image_plane_width*4(a1),(a0)+ ;Erste 16 Pixel Bitplane 5
  move.w  d4,(a0)+           ;BPL4DAT
  move.w  bg_image_plane_width*3(a1),(a0)+ ;Erste 16 Pixel Bitplane 4
  move.w  d3,(a0)+           ;BPL3DAT
  move.w  bg_image_plane_width*2(a1),(a0)+ ;Erste 16 Pixel Bitplane 3
  move.w  d2,(a0)+           ;BPL2DAT
  move.w  bg_image_plane_width*1(a1),(a0)+ ;Erste 16 Pixel Bitplane 2
  move.w  d1,(a0)+           ;BPL1DAT
  move.w  (a1),(a0)+         ;Erste 16 Pixel Bitplane 1
  ADDF.W  bg_image_plane_width*bg_image_depth,a1 ;n�chste Zeile in Playfield
  cmp.l   d5,d0              ;Rasterzeile 255 erreicht ?
  bne.s   no_patch_copperlist1 ;Nein -> verzweige
  COPWAIT cl_x_wrap_7_bitplanes_1x,cl_y_wrap ;Copperliste patchen
no_patch_copperlist1
  add.l   d6,d0              ;n�chste Zeile
  dbf     d7,cl1_init_BPLxDAT_registers_loop
  movem.l (a7)+,a4-a5
  rts

  COP_INIT_COPINT cl1,cl1_HSTART2,cl1_VSTART2

  COP_SET_SPRITE_POINTERS cl1,display,spr_number

  COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


; ** CIA-Timer starten **
; -----------------------

  INCLUDE "continuous-timers-start.i"


; ## Hauptprogramm ##
; -------------------
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bsr.s   no_sync_routines
  bra.s   beam_routines


; ## Routinen, die nicht mit der Bildwiederholfrequenz gekoppelt sind ##
; ----------------------------------------------------------------------
  CNOP 0,4
no_sync_routines
  rts


; ## Rasterstahl-Routinen ##
; --------------------------
  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   spr_swap_structures
  bsr.s   swap_extra_playfield
  bsr     effects_handler
  bsr     scroll_logo_left_in
  bsr     scroll_logo_left_out
  bsr     vert_text_scroll
  bsr     vts_copy_buffer
  bsr     image_fader_in
  bsr     image_fader_out
  bsr     if_copy_color_table
  jsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_state(a3)       ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


; ** Sprites vertauschen **
; -------------------------
  SWAP_SPRITES_STRUCTURES spr,spr_swap_number

; ** Puffer vertauschen **
; ------------------------
  CNOP 0,4
swap_extra_playfield
  move.l  extra_pf1(a3),d0
  move.l  extra_pf2(a3),extra_pf1(a3)
  move.l  d0,extra_pf2(a3)
  rts


; ** Vertical-Text-Scrolling-Routine **
; -------------------------------------
  CNOP 0,4
vert_text_scroll
  movem.l a4-a5,-(a7)
  bsr.s   vts_init_copy_blit
  MOVEF.W (vts_copy_character_blit_y_size*64)+(vts_copy_character_blit_x_size/16),d3 ;BLTSIZE
  MOVEF.W vts_text_character_y_restart,d4 ;Y-Neustart
  lea     vts_characters_y_positions(pc),a1 ;Y-Koords der Chars
  lea     vts_characters_image_pointers(pc),a2 ;Zeiger auf Adressen der Char-Images
  move.l  extra_pf1(a3),a4
  move.l  (a4),a4
  move.w  #vts_text_characters_per_line*4,a5
  moveq   #vts_text_characters_per_column-1,d7 ;Anzahl der Zeichen pro Spalte
vert_text_scroll_loop1
  moveq   #TRUE,d1           ;Langwort-Zugriff
  move.w  (a1),d1            ;Y
  move.w  d1,d2              ;Y retten
  MULUF.L extra_pf1_plane_width*extra_pf1_depth,d1,d0 ;Y-Offset in Playfield
  lea     vts_characters_x_positions(pc),a0 ;X-Koords der Chars
  moveq   #vts_text_characters_per_line-1,d6 ;Anzahl der Zeichen pro Zeile
vert_text_scroll_loop2
  moveq   #TRUE,d0           ;Langwort-Zugriff
  move.w  (a0)+,d0           ;X
  lsr.w   #3,d0              ;X/8
  add.l   d1,d0              ;X+Y-Offset
  add.l   a4,d0              ;Playfieldadresse addieren
  WAITBLITTER
  move.l  (a2)+,BLTAPT-DMACONR(a6) ;Char
  move.l  d0,BLTDPT-DMACONR(a6) ;Playfield
  move.w  d3,BLTSIZE-DMACONR(a6) ;Blitter starten
  dbf     d6,vert_text_scroll_loop2
  sub.w   vts_variable_vert_scroll_speed(a3),d2 ;Y-Position verringern
  bpl.s   vts_set_characters_y_position ;Wenn Y positiv -> verzweige
vts_new_characters_images
  sub.l   a5,a2              ;Zeiger auf Anfang setzen
  moveq   #vts_text_characters_per_line-1,d5 ;Anzahl der Chars in einer Zeile
vert_text_scroll_loop3
  bsr.s   vts_get_new_character_image
  move.l  d0,(a2)+           ;Neues Bild f�r Characteracter
  dbf     d5,vert_text_scroll_loop3
  add.w   d4,d2              ;Y-Neustart
vts_set_characters_y_position
  move.w  d2,(a1)+           ;Y-Pos. retten
  dbf     d7,vert_text_scroll_loop1
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  movem.l (a7)+,a4-a5
  rts
  CNOP 0,4
vts_init_copy_blit
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.l  #(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;keine Ausmaskierung
  move.l  #((vts_image_plane_width-vts_text_character_width)<<16)+(vts_buffer_width-vts_text_character_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  rts

; ** Neues Image f�r Character ermitteln **
; -----------------------------------------
  GET_NEW_CHARACTER_IMAGE.W vts

; ** Puffer in Sprite-Strukturen kopieren **
; ------------------------------------------
  CNOP 0,4
vts_copy_buffer
  move.l  a4,-(a7)
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  2*LONGWORDSIZE(a2),a0 ;1. Sprite-Struktur (SPR2)
  ADDF.W  (spr_pixel_per_datafetch/4),a0 ;Sprite-Header �berspringen
  move.l  4*LONGWORDSIZE(a2),a1 ;2. Sprite-Struktur (SPR4)
  ADDF.W  (spr_pixel_per_datafetch/4),a1 ;Sprite-Header �berspringen
  move.l  6*LONGWORDSIZE(a2),a2 ;3. Sprite-Struktur (SPR6)
  ADDF.W  (spr_pixel_per_datafetch/4),a2 ;Sprite-Header �berspringen
  move.l  extra_pf2(a3),a4   ;Zeiger auf Grafikdaten
  move.l  (a4),a4
  ADDF.W  vts_text_character_y_size*extra_pf1_plane_width*extra_pf1_depth,a4 ;n Zeilen �berspringen
  MOVEF.W vts_buffer_y_size-1,d7 ;H�he des Einzelsprites
vts_copy_buffer_loop
  move.l  (a4)+,(a0)+        ;Plane0 64 Pixel
  move.l  (a4)+,(a0)+        ;Plane0
  addq.w  #8,a0
  move.l  (a4)+,(a1)+        ;Plane0 64 Pixel
  move.l  (a4)+,(a1)+        ;Plane0
  addq.w  #8,a1
  move.l  (a4)+,(a2)+        ;Plane0 64 Pixel
  move.l  (a4)+,(a2)+        ;Plane0
  addq.w  #8,a2
  dbf     d7,vts_copy_buffer_loop
  move.l  (a7)+,a4
  rts


; ** Grafik einblenden **
; -----------------------
  CNOP 0,4
image_fader_in
  tst.w   ifi_state(a3)      ;Image-Fader-In an ?
  bne.s   no_image_fader_in  ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifi_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  ADDF.W  ifi_fader_angle_speed,d0 ;n�chster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifi_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifi_save_fader_angle
  move.w  d0,ifi_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Z�hler
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer f�r Farbwerte
  lea     ifi_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert f�r Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 l�schen
  move.l  d0,a2              ;Additions-/Subtraktionswert f�r Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert f�r Gr�n
  MOVEF.W if_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,if_colors_counter(a3) ;Image-Fader-In fertig ?
  bne.s   no_image_fader_in  ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In aus
no_image_fader_in
  rts

; ** Grafik ausblenden **
; -----------------------
  CNOP 0,4
image_fader_out
  tst.w   ifo_state(a3)      ;Image-Fader-Out an ?
  bne.s   no_image_fader_out ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifo_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  ADDF.W  ifo_fader_angle_speed,d0 ;n�chster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifo_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifo_save_fader_angle
  move.w  d0,ifo_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Z�hler
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer f�r Farbwerte
  lea     ifo_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert f�r Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 l�schen
  move.l  d0,a2              ;Additions-/Subtraktionswert f�r Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert f�r Gr�n
  MOVEF.W if_colors_number-1,d7 ;Anzahl der Farben
  bsr.s   if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,if_colors_counter(a3) ;Image-Fader-Out fertig ?
  bne.s   no_image_fader_out ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out aus
no_image_fader_out
  rts

  COLOR_FADER if

; ** Farbwerte in Copperliste kopieren **
; ---------------------------------------
  COPY_COLOR_TABLE_TO_COPPERLIST if,pf1,cl1,cl1_COLOR01_high1,cl1_COLOR01_low1

; ** Logo von links einscrollen **
; --------------------------------
  CNOP 0,4
scroll_logo_left_in
  tst.w   slli_state(a3)     ;Scroll-Logo-Left-In an ?
  bne     no_scroll_logo_left_in  ;Nein -> verzweige
  move.w  slli_x_angle(a3),d2 ;X-Winkel
  cmp.w   #sine_table_length/4,d2 ;90 Grad erreicht ?
  bgt.s   no_scroll_logo_left_in  ;Ja -> verzweige
  movem.l a4-a5,-(a7)
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d1      ;sin(w)
  MULUF.L sll_x_radius*2*4,d1,d0 ;x'=xr*sin(w)/2^16
  swap    d1
  add.w   #sll_x_center*4,d1
  MOVEF.W lg_image_x_position*4,d0
  sub.w   d1,d0              ;X-Zentrierung
  addq.w  #slli_x_angle_speed,d2 ;n�chsterX-Winkel
  move.w  d2,slli_x_angle(a3)
  moveq   #lg_image_y_position,d1 ;Y
  MOVEF.W lg_image_y_size,d2 ;H�he
  add.w   d1,d2              ;H�he zu Y addieren
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a0           ;1. Sprite-Struktur (SPR0)
  move.l  (a2),a1            ;2. Sprite-Struktur (SPR1)
  lea     spr_pointers_display(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a4           ;1. Sprite-Struktur (SPR0)
  move.l  (a2),a5            ;2. Sprite-Struktur (SPR1)
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPR0POS
  move.w  d1,(a4)
  move.w  d1,(a1)            ;SPR1POS
  move.w  d1,(a5)
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPR0CTL
  move.w  d2,spr_pixel_per_datafetch/8(a4)
  tas     d2                 ;Attached-Bit setzen
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPR1CTL
  move.w  d2,spr_pixel_per_datafetch/8(a5)
  movem.l (a7)+,a4-a5
no_scroll_logo_left_in
  rts

; ** Logo nach links ausscrollen **
; ---------------------------------
  CNOP 0,4
scroll_logo_left_out
  tst.w   sllo_state(a3)     ;Scroll-Logo-Left-Out an ?
  bne     no_scroll_logo_left_out ;Nein -> verzweige
  move.w  sllo_x_angle(a3),d2 ;X-Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad erreicht ?
  bgt.s   no_scroll_logo_left_out ;Ja -> verzweige
  movem.l a4-a5,-(a7)
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d1     ;cos(w)
  MULUF.L sll_x_radius*2*4,d1,d0 ;x'=xr*cos(w)/2^16
  swap    d1
  add.w   #sll_x_center*4,d1
  MOVEF.W lg_image_x_position*4,d0
  sub.w   d1,d0              ;X-Zentrierung
  addq.w  #sllo_x_angle_speed,d2 ;n�chsterX-Winkel
  move.w  d2,sllo_x_angle(a3) 
  moveq   #lg_image_y_position,d1 ;Y
  MOVEF.W lg_image_y_size,d2 ;H�he
  add.w   d1,d2              ;H�he zu Y addieren
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a0           ;1. Sprite-Struktur (SPR0)
  move.l  (a2),a1            ;2. Sprite-Struktur (SPR1)
  lea     spr_pointers_display(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a4           ;1. Sprite-Struktur (SPR0)
  move.l  (a2),a5            ;2. Sprite-Struktur (SPR1)
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPR0POS
  move.w  d1,(a4)
  move.w  d1,(a1)            ;SPR1POS
  move.w  d1,(a5)
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPR0CTL
  move.w  d2,spr_pixel_per_datafetch/8(a4)
  tas     d2                 ;Attached-Bit setzen
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPR1CTL
  move.w  d2,spr_pixel_per_datafetch/8(a5)
  movem.l (a7)+,a4-a5
no_scroll_logo_left_out
  rts


; ** SOFTINT-Interrupts abfragen **
; ---------------------------------
  CNOP 0,4
effects_handler
  moveq   #INTF_SOFTINT,d1
  and.w   INTREQR-DMACONR(a6),d1   ;Wurde der SOFTINT-Interrupt gesetzt ?
  beq.s   no_effects_handler ;Nein -> verzweige
  addq.w  #1,eh_trigger_number(a3) ;FX-Trigger-Z�hler hochsetzen
  move.w  eh_trigger_number(a3),d0 ;FX-Trigger-Z�hler 
  cmp.w   #eh_trigger_number_max,d0 ;Maximalwert bereits erreicht ?
  bgt.s   no_effects_handler ;Ja -> verzweige
  move.w  d1,INTREQ-DMACONR(a6) ;SOFTINT-Interrupt l�schen
  subq.w  #1,d0
  beq.s   eh_start_image_fader_in
  subq.w  #1,d0
  beq.s   eh_stop_image_fader_in
  subq.w  #1,d0
  beq.s   eh_start_scroll_logo_left_in
  subq.w  #1,d0
  beq.s   eh_start_vert_text_scroll
  subq.w  #1,d0
  beq.s   eh_stop_vert_text_scroll
  subq.w  #1,d0
  beq.s   eh_start_image_fader_out
  subq.w  #1,d0
  beq.s   eh_start_scroll_logo_left_out
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_image_fader_in
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  rts
  CNOP 0,4
eh_start_scroll_logo_left_in
  clr.w   slli_state(a3)     ;Scroll-Logo-Left-In an
  rts
  CNOP 0,4
eh_stop_image_fader_in
  moveq   #FALSE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In stoppen
  rts
  CNOP 0,4
eh_start_vert_text_scroll
  moveq   #vts_vert_scroll_speed,d0
  move.w  d0,vts_variable_vert_scroll_speed(a3) ;Geschwindigkeit setzen
  rts
  CNOP 0,4
eh_stop_vert_text_scroll
  clr.w   vts_variable_vert_scroll_speed(a3) ;Geschwindigkeit = Null
  rts
  CNOP 0,4
eh_start_image_fader_out
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  rts
  CNOP 0,4
eh_start_scroll_logo_left_out
  clr.w   sllo_state(a3)     ;Scroll-Logo-Left-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_state(a3)       ;Effekte beendet
  rts


; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


; ** Timer stoppen **
; -------------------

  INCLUDE "continuous-timers-stop.i"


; ## System wieder in Ausganszustand zur�cksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen f�r Tabellen und Strukturen ##
; -------------------------------------------------

  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
; ----------------------------------
  CNOP 0,4
pf1_color_table
  REPT pf1_colors_number
    DC.L COLOR00BITS
  ENDR

; ** Farben der Sprites **
; ------------------------
spr_color_table_logo
; ** Sprite0/1 **
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/64x256x16-Resistance.ct"

spr_color_table_vert_text_scroll
; ** Sprite0 **
  REPT 4
    DC.L COLOR00BITS
  ENDR
; ** Sprite2 **
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/16x15x2-Font.ct"
  REPT 2
    DC.L COLOR00BITS
  ENDR
; ** Sprite4 **
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/16x15x2-Font.ct"
  REPT 2
    DC.L COLOR00BITS
  ENDR
; ** Sprite6 **
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/16x15x2-Font.ct"
  REPT 2
    DC.L COLOR00BITS
  ENDR

; ** Adressen der Sprites **
; --------------------------
spr_pointers_construction
  DS.L spr_number

spr_pointers_display
  DS.L spr_number

; **** Vert-Text-Scroll ****
; ** ASCII-Buchstaben **
; ----------------------
vts_ASCII
  DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/&<>#* "
vts_ASCII_end
  EVEN

; ** Offsets der einzelnen Chars **
; ---------------------------------
  CNOP 0,2
vts_characters_offsets
  DS.W vts_ASCII_end-vts_ASCII
  
; ** X-Koordinaten der einzelnen Cgars der Laufschrift **
; -------------------------------------------------------
vts_characters_x_positions
  DS.W vts_text_characters_per_line

; ** Y-Koordinaten der einzelnen Chars der Laufschrift **
; -------------------------------------------------------
vts_characters_y_positions
  DS.W vts_text_characters_per_column

; ** Tabelle f�r Char-Image-Adressen **
; -------------------------------------
  CNOP 0,4
vts_characters_image_pointers
  DS.L vts_text_characters_number

; **** Image-Fader ****
; ** Zielfarbwerte f�r Image-Fader-In **
; --------------------------------------
  CNOP 0,4
ifi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/352x256x128-RasterMaster.ct"

; ** Zielfarbwerte f�r Image-Fader-Out **
; ---------------------------------------
ifo_color_table
  REPT pf1_colors_number
    DC.L COLOR00BITS
  ENDR


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen f�r Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen f�r Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; **** Vert-Textscroll ****
; ** Text f�r Laufschrift **
; --------------------------
vts_text
  REPT vts_text_characters_per_column*vts_text_characters_per_line
    DC.B " "
  ENDR
  DC.B "RASTER      "
  DC.B "MASTER      "
  DC.B "            "
  DC.B "            "
  DC.B "WAS BROUGHT "
  DC.B "            "
  DC.B "TO YOU BY   "
  DC.B "            "
  DC.B "RESISTANCE  "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "THE CREDITS "
  DC.B "            "
  DC.B "FOR THIS    "
  DC.B "            "
  DC.B "PRODUCTION  "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "CODING AND  "
  DC.B "            "
  DC.B "MUSIC       "
  DC.B "            "
  DC.B "            "
  DC.B ">DISSIDENT< "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "GRAPHICS    "
  DC.B "            "
  DC.B "            "
  DC.B ">GRASS<     "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "INTRO       "
  DC.B "            "
  DC.B "            "
  DC.B "8 SPRITES   "
  DC.B "            "
  DC.B "ON AN       "
  DC.B "            "
  DC.B "OVERSCAN    "
  DC.B "            "
  DC.B "DISPLAY WITH"
  DC.B "            "
  DC.B "128 COLORS  "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "COLOR       "
  DC.B "SCROLLS     "
  DC.B "            "
  DC.B "            "
  DC.B "WITH 256    "
  DC.B "            "
  DC.B "COLORS      "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "TWISTED BIG "
  DC.B "BARS        "
  DC.B "            "
  DC.B "WITH A WAVE "
  DC.B "            "
  DC.B "MOVEMENT    "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "TWISTED     "
  DC.B "COLORCYCLE  "
  DC.B "BARS        "
  DC.B "            "
  DC.B "WITH RGB8   "
  DC.B "            "
  DC.B "GRADIENTS   "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "TWISTED     "
  DC.B "SPACE BARS  "
  DC.B "            "
  DC.B "            "
  DC.B "IN FRONT OF "
  DC.B "            "
  DC.B "SPRITES WITH"
  DC.B "            "
  DC.B "A SCROLLTEXT"
  DC.B "            "
  DC.B "IN BETWEEN  "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "GREETINGS   "
  DC.B "            "
  DC.B "            "
  DC.B "3D-BARSFIELD"
  DC.B "            "
  DC.B "WITH A BARS "
  DC.B "            "
  DC.B "TWISTER PLUS"
  DC.B "            "
  DC.B "A SINE      "
  DC.B "            "
  DC.B "SCROLLTEXT  "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "BLIND COLOR "
  DC.B "CYCLES &    "
  DC.B "VERTICAL    "
  DC.B "COLOR       "
  DC.B "SCROLLS     "
  DC.B "            "
  DC.B "WITH RGB8   "
  DC.B "            "
  DC.B "GRADIENTS   "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "FOUR-PIXEL  "
  DC.B "PLASMA      "
  DC.B "            "
  DC.B "            "
  DC.B "WITH A SHADE"
  DC.B "            "
  DC.B "EFFECT      "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "VERTICAL    "
  DC.B "STAR        "
  DC.B "SCROLLING   "
  DC.B "            "
  DC.B "            "
  DC.B "WITH CHUNKY "
  DC.B "            "
  DC.B "STARS       "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "------------"
  DC.B "            "
  DC.B "CREDITS     "
  DC.B "            "
  DC.B "            "
  DC.B "LOGO AND    "
  DC.B "            "
  DC.B "SCROLLER AS "
  DC.B "            "
  DC.B "SPRITES     "
  DC.B "            "
  DC.B "ON AN       "
  DC.B "            "
  DC.B "OVERSCAN    "
  DC.B "            "
  DC.B "DISPLAY     "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "            "
  DC.B "RELEASED AT "
  DC.B "            "
  DC.B "NORDLICHT   "
  DC.B "            "
  DC.B "06.07.2024  "
  DC.B FALSE
  EVEN


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Logo ****
lg_image_data SECTION lg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/64x256x16-Resistance.rawblit"

; **** Vert-Text-Scroll ****
vts_image_data SECTION vts_gfx,DATA_C
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/fonts/16x15x2-Font.rawblit"
  DS.B vts_image_plane_width*vts_image_depth ;Leerzeile

  END
