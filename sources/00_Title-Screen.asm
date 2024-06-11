; #################################
; # Programm: 00_Title-Sreen.asm  #
; # Autor:    Christian Gerbig    #
; # Datum:    01.12.2023          #
; # Version:  1.2 beta            #
; # CPU:      68020+              #
; # FASTMEM:  -                   #
; # Chipset:  AGA                 #
; # OS:       3.0+                #
; #################################

  SECTION code_and_variables,CODE

  MC68040

  XREF COLOR00BITS
  XREF pt_track_channel_volumes
  XREF pt_track_channel_periods
  XREF pt_audchan1temp
  XREF pt_audchan2temp
  XREF pt_audchan3temp
  XREF pt_audchan4temp


  XDEF start_00_title_screen
  XDEF mouse_handler
  XDEF sine_table
  XDEF bg_image_data


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

requires_68030              EQU FALSE  
requires_68040              EQU FALSE
requires_68060              EQU FALSE
requires_fast_memory        EQU FALSE
requires_multiscan_monitor  EQU FALSE

workbench_start             EQU FALSE
workbench_fade              EQU FALSE
text_output                 EQU FALSE

sys_taken_over
pass_global_references
pass_return_code

DMABITS                     EQU DMAF_SPRITE+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
INTENABITS                  EQU INTF_SETCLR

CIAAICRBITS                 EQU CIAICRF_SETCLR
CIABICRBITS                 EQU CIAICRF_SETCLR

COPCONBITS                  EQU TRUE

pf1_x_size1                 EQU 0
pf1_y_size1                 EQU 0
pf1_depth1                  EQU 0
pf1_x_size2                 EQU 0
pf1_y_size2                 EQU 0
pf1_depth2                  EQU 0
pf1_x_size3                 EQU 384
pf1_y_size3                 EQU 256
pf1_depth3                  EQU 7
pf1_colors_number           EQU 128

pf2_x_size1                 EQU 0
pf2_y_size1                 EQU 0
pf2_depth1                  EQU 0
pf2_x_size2                 EQU 0
pf2_y_size2                 EQU 0
pf2_depth2                  EQU 0
pf2_x_size3                 EQU 0
pf2_y_size3                 EQU 0
pf2_depth3                  EQU 0
pf2_colors_number           EQU 0
pf_colors_number            EQU pf1_colors_number+pf2_colors_number
pf_depth                    EQU pf1_depth3+pf2_depth3

extra_pf_number             EQU 0

spr_number                  EQU 8
spr_x_size1                 EQU 0
spr_x_size2                 EQU 64
spr_depth                   EQU 2
spr_colors_number           EQU 0 ;16
spr_odd_color_table_select  EQU 8
spr_even_color_table_select EQU 8
spr_used_number             EQU 8

audio_memory_size           EQU 0

disk_memory_size            EQU 0

extra_memory_size           EQU 0

chip_memory_size            EQU 0

AGA_OS_Version              EQU 39

CIAA_TA_value               EQU 0
CIAA_TB_value               EQU 0
CIAB_TA_value               EQU 0
CIAB_TB_value               EQU 0
CIAA_TA_continuous          EQU FALSE
CIAA_TB_continuous          EQU FALSE
CIAB_TA_continuous          EQU FALSE
CIAB_TB_continuous          EQU FALSE

beam_position               EQU $136

pixel_per_line              EQU 336
visible_pixels_number       EQU 352
visible_lines_number        EQU 256
MINROW                      EQU VSTART_256_lines

pf_pixel_per_datafetch      EQU 16 ;1x
DDFSTRTBITS                 EQU DDFSTART_320_pixel
DDFSTOPBITS                 EQU DDFSTOP_overscan_16_pixel
spr_pixel_per_datafetch     EQU 64 ;4x

display_window_HSTART       EQU HSTART_352_pixel
display_window_VSTART       EQU MINROW
DIWSTRTBITS                 EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP        EQU HSTOP_352_pixel
display_window_VSTOP        EQU VSTOP_256_lines
DIWSTOPBITS                 EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width             EQU pf1_x_size3/8
data_fetch_width            EQU pixel_per_line/8
pf1_plane_moduli            EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                 EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                 EQU TRUE
BPLCON2BITS                 EQU BPLCON2F_PF2P2
BPLCON3BITS1                EQU BPLCON3F_SPRES0
BPLCON3BITS2                EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                 EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
DIWHIGHBITS                 EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                   EQU FMODEF_SPR32+FMODEF_SPAGEM

cl2_display_x_size          EQU 0
cl2_display_width           EQU cl2_display_x_size/8
cl2_display_y_size          EQU visible_lines_number
cl2_HSTART1                 EQU display_window_HSTART-(pf1_depth3*CMOVE_slot_period)-(1*CMOVE_slot_period)-4
cl2_VSTART1                 EQU MINROW
cl2_HSTART2                 EQU $00
cl2_VSTART2                 EQU beam_position&$ff

sine_table_length           EQU 256

; **** Background-Image ****
bg_image_x_size             EQU 352
bg_image_plane_width        EQU bg_image_x_size/8
bg_image_y_size             EQU 256
bg_image_depth              EQU 7

; **** Logo ****
lg_image_x_size             EQU 256
lg_image_plane_width        EQU lg_image_x_size/8
lg_image_y_size             EQU 75
lg_image_depth              EQU 16

lg_image_x_center           EQU (visible_pixels_number-lg_image_x_size)/2
lg_image_y_center           EQU (visible_lines_number-lg_image_y_size)/2
lg_image_x_position         EQU display_window_HSTART+lg_image_x_center
lg_image_y_position         EQU display_window_VSTART+lg_image_y_center

; **** Channelscope ****
cs_selected_channel         EQU 2
cs_scope_x_size             EQU 128

; **** Wobble-Display ****
wd_x_speed                  EQU 1
wd_x_step                   EQU 1
wd_table_length             EQU cs_scope_x_size

; **** Image-Fader ****
if_start_color              EQU 1
if_color_table_offset       EQU 1
if_colors_number            EQU pf1_colors_number-1

ifi_fader_speed_max         EQU 4
ifi_fader_radius            EQU ifi_fader_speed_max
ifi_fader_center            EQU ifi_fader_speed_max+1
ifi_fader_angle_speed       EQU 4

ifo_fader_speed_max         EQU 3
ifo_fader_radius            EQU ifo_fader_speed_max
ifo_fader_center            EQU ifo_fader_speed_max+1
ifo_fader_angle_speed       EQU 1

; **** Image-Pixel-Fader ****
ipf_source_size             EQU 32
ipf_destination_size        EQU 1

ipfi_delay                  EQU 6
ipfi_delay_radius           EQU ipfi_delay
ipfi_delay_center           EQU ipfi_delay+1
ipfi_delay_angle_speed      EQU 1

ipfo_delay                  EQU 8
ipfo_delay_radius           EQU ipfo_delay
ipfo_delay_center           EQU ipfo_delay+1
ipfo_delay_angle_speed      EQU 1

; **** Effects-Handler ****
eh_trigger_number_max       EQU 6


pf1_bitplanes_x_offset      EQU 16
pf1_BPL1DAT_x_offset        EQU 0


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enthält **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enthält **
; -----------------------------------------------------------------------
  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_SIZE RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAIT       RS.L 1
cl2_ext1_BPLCON1    RS.L 1
cl2_ext1_BPL7DAT    RS.L 1
cl2_ext1_BPL6DAT    RS.L 1
cl2_ext1_BPL5DAT    RS.L 1
cl2_ext1_BPL4DAT    RS.L 1
cl2_ext1_BPL3DAT    RS.L 1
cl2_ext1_BPL2DAT    RS.L 1
cl2_ext1_BPL1DAT    RS.L 1

cl2_extension1_SIZE RS.B 0

  RSRESET

cl2_begin        RS.B 0

cl2_extension1_entry RS.B (cl2_extension1_SIZE*cl2_display_y_size)+4

cl2_WAIT         RS.L 1
cl2_INTREQ       RS.L 1

cl2_end          RS.L 1

copperlist2_SIZE RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1        EQU 0
cl1_size2        EQU 0
cl1_size3        EQU copperlist1_SIZE
cl2_size1        EQU 0
cl2_size2        EQU copperlist2_SIZE
cl2_size3        EQU copperlist2_SIZE


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

; ** Sprite3-Zusatzstruktur **
; ----------------------------
  RSRESET

spr3_extension1       RS.B 0

spr3_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr3_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr3_extension1_SIZE  RS.B 0

; ** Sprite3-Hauptstruktur **
; ---------------------------
  RSRESET

spr3_begin            RS.B 0

spr3_extension1_entry RS.B spr3_extension1_SIZE

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

; ** Sprite5-Zusatzstruktur **
; ----------------------------
  RSRESET

spr5_extension1       RS.B 0

spr5_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr5_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr5_extension1_SIZE  RS.B 0

; ** Sprite5-Hauptstruktur **
; ---------------------------
  RSRESET

spr5_begin            RS.B 0

spr5_extension1_entry RS.B spr5_extension1_SIZE

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

; ** Sprite7-Zusatzstruktur **
; ----------------------------
  RSRESET

spr7_extension1       RS.B 0

spr7_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr7_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr7_extension1_SIZE  RS.B 0

; ** Sprite7-Hauptstruktur **
; ---------------------------
  RSRESET

spr7_begin            RS.B 0

spr7_extension1_entry RS.B spr7_extension1_SIZE

spr7_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_SIZE          RS.B 0


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1     EQU spr_x_size1
spr0_y_size1     EQU 0
spr1_x_size1     EQU spr_x_size1
spr1_y_size1     EQU 0
spr2_x_size1     EQU spr_x_size1
spr2_y_size1     EQU 0
spr3_x_size1     EQU spr_x_size1
spr3_y_size1     EQU 0
spr4_x_size1     EQU spr_x_size1
spr4_y_size1     EQU 0
spr5_x_size1     EQU spr_x_size1
spr5_y_size1     EQU 0
spr6_x_size1     EQU spr_x_size1
spr6_y_size1     EQU 0
spr7_x_size1     EQU spr_x_size1
spr7_y_size1     EQU 0

spr0_x_size2     EQU spr_x_size2
spr0_y_size2     EQU sprite0_SIZE/(spr_x_size2/8)
spr1_x_size2     EQU spr_x_size2
spr1_y_size2     EQU sprite1_SIZE/(spr_x_size2/8)
spr2_x_size2     EQU spr_x_size2
spr2_y_size2     EQU sprite2_SIZE/(spr_x_size2/8)
spr3_x_size2     EQU spr_x_size2
spr3_y_size2     EQU sprite3_SIZE/(spr_x_size2/8)
spr4_x_size2     EQU spr_x_size2
spr4_y_size2     EQU sprite4_SIZE/(spr_x_size2/8)
spr5_x_size2     EQU spr_x_size2
spr5_y_size2     EQU sprite5_SIZE/(spr_x_size2/8)
spr6_x_size2     EQU spr_x_size2
spr6_y_size2     EQU sprite6_SIZE/(spr_x_size2/8)
spr7_x_size2     EQU spr_x_size2
spr7_y_size2     EQU sprite7_SIZE/(spr_x_size2/8)


; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; **** Wobble-Display ****
wd_state                      RS.W 1

; **** Image-Fader ****
if_colors_counter             RS.W 1
if_copy_colors_state          RS.W 1

ifi_state                     RS.W 1
ifi_fader_angle               RS.W 1

ifo_state                     RS.W 1
ifo_fader_angle               RS.W 1

; **** Image-Pixel-Fader ****
  RS_ALIGN_LONGWORD
ipf_mask                      RS.L 1
ipf_variable_destination_size RS.W 1

ipfi_state                    RS.W 1
ipfi_delay_counter            RS.W 1
ipfi_delay_angle              RS.W 1

ipfo_state                    RS.W 1
ipfo_delay_counter            RS.W 1
ipfo_delay_angle              RS.W 1

; **** Effects-Handler ****
eh_trigger_number             RS.W 1

; **** Main ****
fx_state                      RS.W 1

variables_SIZE                RS.B 0


; **** PT-Replay ****
; ** Temporary channel structure **
; ---------------------------------
  INCLUDE "music-tracker/pt-temp-channel-structure.i"


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_00_title_screen
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Wobble-Display ****
  moveq   #FALSE,d1
  move.w  d1,wd_state(a3)

; **** Image-Fader ****
  moveq   #TRUE,d0
  move.w  d0,if_colors_counter(a3)
  move.w  d1,if_copy_colors_state(a3)

  move.w  d1,ifi_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ifi_fader_angle(a3) ;90 Grad

  move.w  d1,ifo_state(a3)
  move.w  d2,ifo_fader_angle(a3) ;90 Grad

; **** Image-Pixel-Fader ****
  move.l  d0,ipf_mask(a3)
  moveq   #ipf_destination_size,d2
  move.w  d2,ipf_variable_destination_size(a3)

  move.w  d1,ipfi_state(a3)
  move.w  d0,ipfi_delay_counter(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ipfi_delay_angle(a3) ;90 Grad

  move.w  d1,ipfo_state(a3)
  move.w  d0,ipfo_delay_counter(a3)
  move.w  d2,ipfo_delay_angle(a3) ;90 Grad

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_color_registers
  bsr     init_sprites
  bsr     bg_copy_image_to_bitplane
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farben initialisieren **
; ---------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 4
  CPU_INIT_COLORHI COLOR00,16,spr_color_table

  CPU_SELECT_COLORLO_BANK 4
  CPU_INIT_COLORLO COLOR00,16,spr_color_table
  rts

; ** Sprites initialisieren **
; ----------------------------
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bra.s   lg_init_attached_sprites_cluster

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; **** Logo ****
; ** Spritestruktur initialisieren **
; -----------------------------------
  INIT_ATTACHED_SPRITES_CLUSTER lg,spr_pointers_display,lg_image_x_position,lg_image_y_position,spr_x_size2,lg_image_y_size,,BLANK

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
  ADDF.W  (bg_image_plane_width*(bg_image_depth-1))+2,a0 ;nächste Zeile in Quelle
  ADDF.W  (pf1_plane_width*(pf1_depth3-1))+6,a2 ;nächste Zeile in Ziel
  dbf     d7,bg_copy_image_data_loop
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  bsr.s   cl1_init_sprite_pointers
  bsr     cl1_init_color_registers
  bsr     cl1_init_bitplane_pointers
  COPMOVEQ TRUE,COPJMP2
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

  COP_SET_SPRITE_POINTERS cl1,display,spr_number

  COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0
  bsr.s   cl2_init_BPLxDAT_registers
  bsr     cl2_init_copint
  COPLISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  CNOP 0,4
cl2_init_BPLxDAT_registers
  movem.l a4-a5,-(a7)
  move.l  #bg_image_data+(pf1_BPL1DAT_x_offset/8),a1 ;BP0
  move.w  #BPL5DAT,a2
  move.w  #BPL6DAT,a4
  move.w  #BPL7DAT,a5
  move.l  #(((cl2_VSTART1<<24)|(((cl2_HSTART1/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.w  #BPL1DAT,d1
  move.w  #BPL2DAT,d2
  move.w  #BPL3DAT,d3
  move.w  #BPL4DAT,d4
  move.l  #(((cl_y_wrap<<24)|(((cl2_HSTART1/4)*2)<<16))|$10000)|$fffe,d5 ;WAIT-Befehl
  moveq   #1,d6
  ror.l   #8,d6              ;$01000000 = Additionswert
  MOVEF.W cl2_display_y_size-1,d7 ;Anzahl der Zeilen
cl2_init_BPLxDAT_registers_loop
  move.l  d0,(a0)+           ;WAIT x,y
  COPMOVEQ TRUE,BPLCON1
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
  ADDF.W  bg_image_plane_width*bg_image_depth,a1 ;nächste Zeile in Playfield
  cmp.l   d5,d0              ;Rasterzeile 255 erreicht ?
  bne.s   no_patch_copperlist2 ;Nein -> verzweige
  COPWAIT cl_x_wrap_7_bitplanes_1x,cl_y_wrap ;Copperliste patchen
no_patch_copperlist2
  add.l   d6,d0              ;nächste Zeile
  dbf     d7,cl2_init_BPLxDAT_registers_loop
  movem.l (a7)+,a4-a5
  rts

  COP_INIT_COPINT cl2,cl2_HSTART2,cl2_VSTART2

  COPY_COPPERLIST cl2,2


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
  bsr.s   swap_second_copperlist
  bsr     effects_handler
  bsr     ipf_random_pixel_data_copy
  bsr     get_channels_data
  bsr     wobble_display
  bsr     image_fader_in
  bsr     image_fader_out
  bsr     if_copy_color_table
  bsr     image_pixel_fader_in
  bsr     image_pixel_fader_out
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_state(a3)       ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


; ** Copperlisten vertauschen **
; ------------------------------
  SWAP_COPPERLIST cl2,2


; ** Daten eines bestimmten Kanals in Erfahrung bringen **
; --------------------------------------------------------
  CNOP 0,4
get_channels_data
  move.l  #PALCLOCKCONSTANT/PALFPS,d6 ;PAL-Clockkonstante / PAL-Frequenz
  IFEQ cs_selected_channel-1
    lea	    pt_audchan1temp(pc),a0 ;Zeiger auf temporäre Struktur des 1. Kanals
    lea     cs_audchandata(pc),a2
    MOVEF.W cs_scope_x_size-1,d7 ;Anzahl der Samplebytes zum Auslesen
  ENDC
  IFEQ cs_selected_channel-2
    lea	    pt_audchan2temp(pc),a0 ;Zeiger auf temporäre Struktur des 2. Kanals
    lea     cs_audio_channel_data(pc),a2
    MOVEF.W cs_scope_x_size-1,d7 ;Anzahl der Samplebytes zum Auslesen
  ENDC
  IFEQ cs_selected_channel-3
    lea	    pt_audchan3temp(pc),a0 ;Zeiger auf temporäre Struktur des 3. Kanals
    lea     cs_audio_channel_data(pc),a2
    MOVEF.W cs_scope_x_size-1,d7 ;Anzahl der Samplebytes zum Auslesen
  ENDC
  IFEQ cs_selected_channel-4
    lea	    pt_audchan4temp(pc),a0 ;Zeiger auf temporäre Struktur des 4. Kanals
    lea     cs_audio_channel_data(pc),a2
    MOVEF.W cs_scope_x_size-1,d7 ;Anzahl der Samplebytes zum Auslesen
  ENDC

; ** Routine get-sample-data **
; d6 ... PAL-Clockkonstante / PAL-Frequenz
; a0 ... Temporäre Struktur des Audiokanals
; a2 ... Zeiger auf Amplitudenwerte des Kanals
; d7 ... Anzahl der Samplebytes zum Auslesen
get_sample_data
  tst.b   n_note_trigger(a0) ;Neue Note angespielt ?
  bne.s   cs_no_new_note     ;Nein -> verzweige
  move.l  n_start(a0),n_current_start(a0) ;Aktuelle Startadresse des Samples
  move.l  n_length(a0),n_current_length(a0) ;Aktuelle Länge und Periode
  moveq   #TRUE,d0
  move.w  d0,n_channel_data_position(a0) ;Position in Sampledaten zurücksetzen
  moveq   #FALSE,d0
  move.b  d0,n_note_trigger(a0) ;Note Trigger Flag zurücksetzen
cs_no_new_note
  move.w  n_current_period(a0),d0 ;Aktuelle Periode 
  beq.s   no_get_sample_data ;Wenn NULL -> verzweige
  moveq   #TRUE,d2           ;Langwort-Zugriff
  move.w  n_channel_data_position(a0),d2 ;Position in Sampledaten
  move.l  d6,d3              ;PAL-Clockkonstante / PAL-Frequenz
  move.l  n_current_start(a0),a1 ;Aktuelle Startadresse des Samples
  divu.w  d0,d3              ;PAL-Clockkonstante / (PAL-Frequenz * aktuelle Periode) = Samplebytes pro PAL-Frame
  moveq   #TRUE,d4           ;Langwort-Zugriff
  move.w  n_current_length(a0),d4 ;Aktuelle Länge des Samples
  ext.l   d3                 ;Auf 32 Bit erweitern
  MULUF.W 2,d4               ;*2 = Länge in Bytes
  moveq   #TRUE,d1           ;Langwort-Zugriff
  move.w  n_current_volume(a0),d1 ;Aktuelle Kanallautstärke
  move.l  d2,d5              ;Position in Sampledaten retten
get_sample_data_loop
  move.b  (a1,d2.l),d0       ;Samplebyte lesen
  ext.w   d0                 ;Auf 16 Bit erweitern
  muls.w  d1,d0              ;Audiowert * aktuelle Lautstärke
  asr.w   #6,d0              ;/ maximale Lautstärke
  move.w  d0,(a2)+           ;Amplitudenwert
  addq.w  #1,d2              ;nächstes Samplebyte
  cmp.w   d4,d2              ;Ende des Samples erreicht ?
  blo.s   cs_no_read_restart ;Nein -> verzweige
  moveq   #TRUE,d2           ;Position in Sampledaten zurücksetzen
cs_no_read_restart
  dbf     d7,get_sample_data_loop
  add.l   d3,d5              ;nächste Position in Sampledaten
  cmp.l   d4,d5              ;Ende des Samples erreicht ?
  blt.s   cs_save_current_pos ;Nein -> verzweige
cs_check_reapeat_length
  move.w  n_replen(a0),d0    ;Wiederholungs-Länge 
  cmp.w   #1,d0              ;Länge = 1 Wort = einmaliges Abspielen ?
  beq.s   cs_restart_sample  ;Ja -> verzweige
cs_check_loop_start
  cmp.l   n_loopstart(a0),a1 ;Schleife bereits angespielt ?
  bne.s   cs_set_loop_start  ;Nein -> verzweige
cs_restart_loop
  sub.l   d4,d5              ;Position um Wiederholungs-Länge zurücksetzen
  cmp.l   d4,d5              ;Immer noch >= Wiederholungs-Länge ?
  bge.s   cs_restart_loop   ;Ja -> verzweige
  bra.s   cs_save_current_pos
  CNOP 0,4
cs_set_loop_start
  move.l  n_loopstart(a0),n_current_start(a0) ;Aktuelle Startadresse des Samples = Schleifenstart
cs_restart_sample
  move.w  d0,n_current_length(a0) ;Neue aktuelle Länge retten
  moveq   #TRUE,d5           ;Position in Sampledaten zurücksetzen
cs_save_current_pos
  move.w  d5,n_channel_data_position(a0) ;Neue Position retten
no_get_sample_data
  rts

; ** Schwabbel-Effekt **
; ----------------------
  CNOP 0,4
wobble_display
  tst.w   wd_state(a3)       ;Wobble-Display an ?
  bne.s   no_wobble_display  ;Nein -> verweige
  MOVEF.W $ff,d3             ;Scrolling-Maske H0-H7
  moveq   #cl2_extension1_SIZE,d4
  IFGE visible_lines_number-212
    move.w  #(cl2_display_y_size-(cl_y_wrap-cl2_VSTART1))-1,d5
  ENDC
  MOVEF.W wd_table_length-1,d6 ;Überlauf
  lea     cs_audio_channel_data(pc),a0 ;Tabelle mit Shiftwerten
  move.l  cl2_construction2(a3),a1
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON1+2,a1 ;Copperliste
  MOVEF.W cl2_display_y_size-1,d7 ;Anzahl der Zeilen
wobble_display_loop
  move.w  (a0,d2.w*2),d0     ;Shiftwert lesen
  BITPLANE_SOFTSCROLL_64PIXEL_LORES d0,d1,d3
  move.w  d0,(a1)            ;BPLCON1
  IFGE visible_lines_number-212
    cmp.w   d5,d7            ;Zeile $ff erreicht ?
    bne.s   wd_no_skip_wait_cmd ;Nein -> verzweige
    addq.w  #4,a1            ;CWAIT-Befehl überspringen
wd_no_skip_wait_cmd
  ENDC
  addq.w  #wd_x_step,d2      ;nächster Wert
  add.l   d4,a1              ;nächste Zeile in CL
  and.w   d6,d2              ;Überlauf entfernen
  dbf     d7,wobble_display_loop
no_wobble_display
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
  ADDF.W  ifi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifi_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifi_save_fader_angle
  move.w  d0,ifi_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifi_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
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
  ADDF.W  ifo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifo_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifo_save_fader_angle
  move.w  d0,ifo_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifo_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
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

; ** Logo Pixelweise einblenden **
; --------------------------------
  CNOP 0,4
image_pixel_fader_in
  tst.w   ipfi_state(a3)     ;Image-Pixel-Fader-In an ?
  bne.s   no_image_pixel_fader_in ;FALSE -> verzweige
  subq.w  #1,ipfi_delay_counter(a3) ;Zähler verringern
  bgt.s   no_image_pixel_fader_in ;Wenn > Null -> verzweige
  move.w  ipfi_delay_angle(a3),d2 ;Winkel 
  move.w  d2,d0
  ADDF.W  ipfi_delay_angle_speed,d0 ;nächster Winkel
  cmp.w   #sine_table_length/2,d0 ;<= 180 Grad ?
  ble.s   ipfi_save_delay_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ipfi_save_delay_angle
  move.w  d0,ipfi_delay_angle(a3) ;Winkel retten
  lea     sine_table(pc),a0 
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ipfi_delay_radius*2,d0,d1 ;delay'=(delay*sin(w))/2^16
  swap    d0
  addq.w  #ipfi_delay_center,d0 ;+ Mittelpunkt
  move.w  d0,ipfi_delay_counter(a3) ;Delay-Wert retten
  moveq   #ipf_source_size,d3 ;Breite des Quellbildes in Pixeln
  moveq   #TRUE,d4
  swap    d3                 ;*2^16
  move.w  ipf_variable_destination_size(a3),d4 ;Größe des Zielbildes in Pixeln
  cmp.w   #ipf_source_size,d4 ;Maximalwert erreicht ?
  bgt.s   ipfi_finished      ;Ja -> verzweige
  moveq   #TRUE,d1
  move.l  d3,d2              ;Größe des Quellbildes untere 32 Bit
  moveq   #TRUE,d7           ;Größe des Quellbildes obere 32 Bit
  moveq   #TRUE,d5           ;Maske
  divu.l  d4,d7:d2           ;F=Breite des Quellbildes/Breite der Zielbildes
  move.w  d4,d7              ;Breite des Zielbilds 
  subq.w  #1,d7              ;wegen dbf
image_pixel_fader_in_in_loop
  move.l  d1,d0              ;F 
  add.l   d2,d1              ;F erhöhen (p*F)
  swap    d0                 ;/2^16 = Bitmapposition
  bset    d0,d5              ;Bit in Maske setzen
  dbf     d7,image_pixel_fader_in_in_loop
  move.l  d5,ipf_mask(a3)    ;Maske retten
  addq.w  #1,d4              ;Breite des Zielbilds erhöhen
  move.w  d4,ipf_variable_destination_size(a3) ;Größe retten
no_image_pixel_fader_in
  rts
  CNOP 0,4
ipfi_finished
  moveq   #FALSE,d0
  move.w  d0,ipfi_state(a3)  ;Image-Pixel-Fader-In aus
  rts

; ** Logo Pixelweise ausblenden **
; --------------------------------
  CNOP 0,4
image_pixel_fader_out
  tst.w   ipfo_state(a3)     ;Image-Pixel-Fader-Out an ?
  bne.s   no_image_pixel_fader_out ;FALSE -> verzweige
  subq.w  #1,ipfo_delay_counter(a3) ;Zähler verringern
  bgt.s   no_image_pixel_fader_out ;Wenn > Null -> verzweige
  move.w  ipfo_delay_angle(a3),d2 ;Winkel 
  move.w  d2,d0
  ADDF.W  ipfo_delay_angle_speed,d0 ;nächster Winkel
  cmp.w   #sine_table_length/2,d0 ;<= 180 Grad ?
  ble.s   ipfo_save_delay_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ipfo_save_delay_angle
  move.w  d0,ipfo_delay_angle(a3) ;Winkel retten
  lea     sine_table(pc),a0  
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ipfo_delay_radius*2,d0,d1 ;delay'=(delay*sin(w))/2^16
  swap    d0
  ADDF.W  ipfo_delay_center,d0 ;+ Mittelpunkt
  move.w  d0,ipfo_delay_counter(a3) ;Delay-Wert retten
  moveq   #ipf_source_size,d3 ;Größe des Quellbildes in Pixeln
  moveq   #TRUE,d4
  swap    d3                 ;*2^16
  move.w  ipf_variable_destination_size(a3),d4 ;Größe des Zielbildes in Pixeln
  ble.s   ipfo_finished      ;Wenn Minimalwert erreicht -> verzweige
  moveq   #TRUE,d1
  move.l  d3,d2              ;Größe des Quellbildes untere 32 Bit
  moveq   #TRUE,d7           ;Größe des Quellbildes obere 32 Bit
  moveq   #TRUE,d5           ;Maske
  divu.l  d4,d7:d2           ;F=Breite des Quellbildes/Breite der Zielbildes
  move.w  d4,d7              ;Breite des Zielbilds 
  subq.w  #1,d7              ;wegen dbf
image_pixel_fader_out_loop
  move.l  d1,d0              ;F 
  add.l   d2,d1              ;F erhöhen (p*F)
  swap    d0                 ;/2^16 = Bitmapposition
  bset    d0,d5              ;Bit in Maske setzen
  dbf     d7,image_pixel_fader_out_loop
  move.l  d5,ipf_mask(a3)    ;Maske retten
  subq.w  #1,d4              ;Breite des Zielbilds erhöhen
  move.w  d4,ipf_variable_destination_size(a3) ;Breite retten
no_image_pixel_fader_out
  rts
  CNOP 0,4
ipfo_finished
  moveq   #FALSE,d0
  move.w  d0,ipfo_state(a3)  ;Image-Pixel-Fader-Out aus
  moveq   #TRUE,d0
  move.l  d0,ipf_mask(a3)    ;Maske = NULL
  rts

; ** Objekt pixelweise ins Playfield kopieren **
; ----------------------------------------------
  CNOP 0,4
ipf_random_pixel_data_copy
  movem.l a4-a5,-(a7)
  move.l  ipf_mask(a3),d1    ;Maske
  lea     spr_pointers_display(pc),a5 ;Zeiger auf Sprite-Strukturen
  move.l  (a5)+,a0           ;Sprite0-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data,a1   ;Zeiger auf Grafik (1. Spalte 64 Pixel)
  bsr     init_sprite_bitmap
  move.l  (a5)+,a0           ;Sprite1-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+(lg_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (1. Spalte 64 Pixel)
  bsr     init_sprite_bitmap

  move.l  (a5)+,a0           ;Sprite2-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+8,a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
  bsr     init_sprite_bitmap
  move.l  (a5)+,a0           ;Sprite3-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+8+(lg_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
  bsr     init_sprite_bitmap

  move.l  (a5)+,a0           ;Sprite4-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+16,a1 ;Zeiger auf Hintergrundbild (3. Spalte 64 Pixel)
  bsr     init_sprite_bitmap
  move.l  (a5)+,a0           ;Sprite5-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+16+(lg_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (3. Spalte 64 Pixel)
  bsr.s   init_sprite_bitmap

  move.l  (a5)+,a0 ;Sprite6-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+24,a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
  bsr.s   init_sprite_bitmap
  move.l  (a5),a0            ;Sprite7-Struktur
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  lea     lg_image_data+24+(lg_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
  bsr.s   init_sprite_bitmap
  movem.l (a7)+,a4-a5
  rts

  CNOP 0,4
init_sprite_bitmap
  move.w  #lg_image_plane_width-8,a2
  move.w  #(lg_image_plane_width*3)-8,a4
  MOVEF.W lg_image_y_size-1,d7 ;Anzahl der Zeilen
init_sprite_bitmap_loop
  move.l  (a1)+,d0           ;BP0 32 Bits
  and.l   d1,d0              ;Mit Maske verknüpfen
  move.l  d0,(a0)+           ;kopieren
  move.l  (a1)+,d0           ;BP0 32 Bits
  and.l   d1,d0              ;Mit Maske verknüpfen
  move.l  d0,(a0)+           ;kopieren
  add.l   a2,a1              ;Restliche Zeile in Quelle überspringen
  move.l  (a1)+,d0           ;BP1 32 Bits
  and.l   d1,d0              ;Mit Maske verknüpfen
  move.l  d0,(a0)+           ;kopieren
  move.l  (a1)+,d0           ;BP1 32 Bits
  and.l   d1,d0              ;Mit Maske verknüpfen
  move.l  d0,(a0)+           ;kopieren
  add.l   a4,a1              ;Restliche Zeile + zwei Folgeplanes in Quelle überspringen
  move.w  VHPOSR-DMACONR(a6),d2    ;Zufallswert ermitteln
  ror.l   d2,d1              ;Bits in Maske rotieren
  move.w  VHPOSR-DMACONR(a6),d2    ;Zufallswert ermitteln
  rol.w   d2,d1              ;Bits in Maske rotieren
  dbf     d7,init_sprite_bitmap_loop
  rts


; ** SOFTINT-Interrupts abfragen **
; ---------------------------------
  CNOP 0,4
effects_handler
  moveq   #INTF_SOFTINT,d1
  and.w   INTREQR-DMACONR(a6),d1   ;Wurde der SOFTINT-Interrupt gesetzt ?
  beq.s   no_check_effects_trigger ;Nein -> verzweige
  addq.w  #1,eh_trigger_number(a3) ;FX-Trigger-Zähler hochsetzen
  move.w  eh_trigger_number(a3),d0 ;FX-Trigger-Zähler 
  cmp.w   #eh_trigger_number_max,d0 ;Maximalwert bereits erreicht ?
  bgt.s   no_check_effects_trigger ;Ja -> verzweige
  move.w  d1,INTREQ-DMACONR(a6) ;SOFTINT-Interrupt löschen
  subq.w  #1,d0
  beq.s   eh_start_image_fader_in
  subq.w  #1,d0
  beq.s   eh_start_wobble_display
  subq.w  #1,d0
  beq.s   eh_start_image_pixel_fader_in
  subq.w  #1,d0
  beq.s   eh_start_image_pixel_fader_out
  subq.w  #1,d0
  beq.s   eh_start_image_fader_out
  subq.w  #1,d0
  beq.s   eh_stop_all
no_check_effects_trigger
  rts
  CNOP 0,4
eh_start_image_fader_in
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  rts
  CNOP 0,4
eh_start_wobble_display
  clr.w   wd_state(a3)       ;Wobble-Display an
  rts
  CNOP 0,4
eh_start_image_pixel_fader_in
  clr.w   ipfi_state(a3)     ;Image-Pixel-Fader-In an
  moveq   #1,d2
  move.w  d2,ipfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_image_pixel_fader_out
  clr.w   ipfo_state(a3)     ;Image-Pixel-Fader-Out an
  moveq   #1,d2
  move.w  d2,ipfo_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_image_fader_out
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_state(a3)       ;Effekte beendet
  rts

; ** Mouse-Handler **
; -------------------
  CNOP 0,4
mouse_handler
  btst    #CIAB_GAMEPORT0,CIAPRA(a4) ;Linke Maustaste gedrückt ?
  beq.s   mh_quit            ;Ja -> verzweige
  moveq   #RETURN_OK,d0
  rts
  CNOP 0,4
mh_quit
  moveq   #RETURN_WARN,d0    ;Abbruch
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


; ## System wieder in Ausganszustand zurücksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen für Tabellen und Strukturen ##
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
spr_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/256x75x16-Resistance.ct"

; ** Adressen der Sprites **
; --------------------------
spr_pointers_display
  DS.L spr_number

; ** Sinus / Cosinustabelle **
; ----------------------------
sine_table
  INCLUDE "sine-table-256x32.i"

; **** Channelscope ****
; Tabelle mit Sampledaten des Kanals **
; -------------------------------------
  CNOP 0,2
cs_audio_channel_data
  DS.W cs_scope_x_size

; **** Image-Fader ****
; ** Zielfarbwerte für Image-Fader-In **
; --------------------------------------
  CNOP 0,4
ifi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/352x256x128-RasterMaster.ct"

; ** Zielfarbwerte für Image-Fader-Out **
; ---------------------------------------
ifo_color_table
  REPT pf1_colors_number
    DC.L COLOR00BITS
  ENDR


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Background-Image ****
bg_image_data SECTION bg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/352x256x128-RasterMaster.rawblit"

; **** Logo ****
lg_image_data SECTION lg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/256x75x16-Resistance.rawblit"

  END
