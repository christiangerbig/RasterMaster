; ###################################
; # Programm: 0a_Zic-Zac-Plasma.asm #
; # Autor:    Christian Gerbig      #
; # Datum:    21.12.2023            #
; # Version:  1.3 beta              #
; # CPU:      68020+                #
; # FASTMEM:  -                     #
; # Chipset:  AGA                   #
; # OS:       3.0+                  #
; ###################################

  SECTION code_and_variables,CODE

  MC68040

  XREF COLOR00BITS
  XREF mouse_handler
  XREF sine_table_512


  XDEF start_0a_zig_zag_plasma


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

requires_68030             EQU FALSE  
requires_68040             EQU FALSE
requires_68060             EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start            EQU FALSE
workbench_fade             EQU FALSE
text_output                EQU FALSE

sys_taken_over
pass_global_references
pass_return_code

DMABITS                    EQU DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
INTENABITS                 EQU INTF_SETCLR

CIAAICRBITS                EQU CIAICRF_SETCLR
CIABICRBITS                EQU CIAICRF_SETCLR

COPCONBITS                 EQU TRUE

pf1_x_size1                EQU 0
pf1_y_size1                EQU 0
pf1_depth1                 EQU 0
pf1_x_size2                EQU 0
pf1_y_size2                EQU 0
pf1_depth2                 EQU 0
pf1_x_size3                EQU 32
pf1_y_size3                EQU 1
pf1_depth3                 EQU 1
pf1_colors_number          EQU 0 ;256

pf2_x_size1                EQU 0
pf2_y_size1                EQU 0
pf2_depth1                 EQU 0
pf2_x_size2                EQU 0
pf2_y_size2                EQU 0
pf2_depth2                 EQU 0
pf2_x_size3                EQU 0
pf2_y_size3                EQU 0
pf2_depth3                 EQU 0
pf2_colors_number          EQU 0
pf_colors_number           EQU pf1_colors_number+pf2_colors_number
pf_depth                   EQU pf1_depth3+pf2_depth3

extra_pf_number            EQU 0

spr_number                 EQU 0
spr_x_size1                EQU 0
spr_y_size1                EQU 0
spr_x_size2                EQU 0
spr_y_size2                EQU 0
spr_depth                  EQU 0
spr_colors_number          EQU 0

audio_memory_size          EQU 0

disk_memory_size           EQU 0

extra_memory_size          EQU 0

AGA_OS_Version             EQU 39

CIAA_TA_value              EQU 0
CIAA_TB_value              EQU 0
CIAB_TA_value              EQU 0
CIAB_TB_value              EQU 0
CIAA_TA_continuous         EQU FALSE
CIAA_TB_continuous         EQU FALSE
CIAB_TA_continuous         EQU FALSE
CIAB_TB_continuous         EQU FALSE

beam_position              EQU $136

pixel_per_line             EQU 32
visible_pixels_number      EQU 376
visible_lines_number       EQU 256
MINROW                     EQU VSTART_256_lines

pf_pixel_per_datafetch     EQU 16 ;1x
DDFSTRTBITS                EQU DDFSTART_overscan_32_pixel
DDFSTOPBITS                EQU DDFSTOP_overscan_32_pixel_min

display_window_HSTART      EQU HSTART_44_chunky_pixel
display_window_VSTART      EQU MINROW
DIWSTRTBITS                EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP       EQU HSTOP_44_chunky_pixel
display_window_VSTOP       EQU VSTOP_256_lines
DIWSTOPBITS                EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width            EQU pf1_x_size3/8
data_fetch_width           EQU pixel_per_line/8
pf1_plane_moduli           EQU -pf1_plane_width+(pf1_plane_width-data_fetch_width)

BPLCON0BITS                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                EQU TRUE
BPLCON2BITS                EQU TRUE
BPLCON3BITS1               EQU TRUE
BPLCON3BITS2               EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                EQU TRUE
DIWHIGHBITS                EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                  EQU TRUE

cl2_display_x_size         EQU 456
cl2_display_width          EQU cl2_display_x_size/8
cl2_display_y_size         EQU visible_lines_number-2
cl2_HSTART1                EQU $00
cl2_VSTART1                EQU MINROW
cl2_HSTART2                EQU $00
cl2_VSTART2                EQU beam_position&$ff

sine_table_length          EQU 512

; **** Zig-Zag-Plasma5 ****
zzp5_y_radius              EQU 64
zzp5_y_center              EQU 64
zzp5_y_radius_angle_speed  EQU 1
zzp5_y_angle_speed         EQU 1
zzp5_y_angle_step          EQU 9
zzp5_switch_table_step     EQU 1

zzp5_copy_blit_x_size      EQU 16
zzp5_copy_blit_width       EQU zzp5_copy_blit_x_size/8
zzp5_copy_blit_y_size      EQU cl2_display_y_size

; **** Vert-Shade-Bars ****
vsb_bar_height             EQU 16
vsb_bars_number            EQU 4
vsb_y_radius               EQU ((visible_lines_number+(zzp5_y_radius*2))-vsb_bar_height)/2
vsb_y_center               EQU ((visible_lines_number+(zzp5_y_radius*2))-vsb_bar_height)/2
vsb_y_radius_angle_speed   EQU 2
vsb_y_radius_angle_step    EQU 1
vsb_y_angle_speed          EQU 2
vsb_y_angle_step           EQU sine_table_length/vsb_bars_number

; **** Vert-Border-Fader ****
vbf_FPS                    EQU 50
vbf_y_position_center      EQU display_window_VSTART+(visible_lines_number/2)

vbfo_fader_speed_max       EQU 4
vbfo_fader_radius          EQU vbfo_fader_speed_max
vbfo_fader_center          EQU vbfo_fader_speed_max+1
vbfo_fader_angle_speed     EQU 2

; **** Effects-Handler ****
eh_trigger_number_max      EQU 3


color_step1                EQU 256/128
color_values_number1       EQU 128
segments_number1           EQU 2

ct_size1                   EQU color_values_number1*segments_number1

zzp5_switch_table_size1    EQU ct_size1
zzp5_switch_table_size2    EQU cl2_display_y_size+(zzp5_y_radius*2)

chip_memory_size           EQU zzp5_switch_table_size2*WORDSIZE


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

cl2_ext1_BPLCON4_1  RS.L 1
cl2_ext1_BPLCON4_2  RS.L 1
cl2_ext1_BPLCON4_3  RS.L 1
cl2_ext1_BPLCON4_4  RS.L 1
cl2_ext1_BPLCON4_5  RS.L 1
cl2_ext1_BPLCON4_6  RS.L 1
cl2_ext1_BPLCON4_7  RS.L 1
cl2_ext1_BPLCON4_8  RS.L 1
cl2_ext1_BPLCON4_9  RS.L 1
cl2_ext1_BPLCON4_10 RS.L 1
cl2_ext1_BPLCON4_11 RS.L 1
cl2_ext1_BPLCON4_12 RS.L 1
cl2_ext1_BPLCON4_13 RS.L 1
cl2_ext1_BPLCON4_14 RS.L 1
cl2_ext1_BPLCON4_15 RS.L 1
cl2_ext1_BPLCON4_16 RS.L 1
cl2_ext1_BPLCON4_17 RS.L 1
cl2_ext1_BPLCON4_18 RS.L 1
cl2_ext1_BPLCON4_19 RS.L 1
cl2_ext1_BPLCON4_20 RS.L 1
cl2_ext1_BPLCON4_21 RS.L 1
cl2_ext1_BPLCON4_22 RS.L 1
cl2_ext1_BPLCON4_23 RS.L 1
cl2_ext1_BPLCON4_24 RS.L 1
cl2_ext1_BPLCON4_25 RS.L 1
cl2_ext1_BPLCON4_26 RS.L 1
cl2_ext1_BPLCON4_27 RS.L 1
cl2_ext1_BPLCON4_28 RS.L 1
cl2_ext1_BPLCON4_29 RS.L 1
cl2_ext1_BPLCON4_30 RS.L 1
cl2_ext1_BPLCON4_31 RS.L 1
cl2_ext1_BPLCON4_32 RS.L 1
cl2_ext1_BPLCON4_33 RS.L 1
cl2_ext1_BPLCON4_34 RS.L 1
cl2_ext1_BPLCON4_35 RS.L 1
cl2_ext1_BPLCON4_36 RS.L 1
cl2_ext1_BPLCON4_37 RS.L 1
cl2_ext1_BPLCON4_38 RS.L 1
cl2_ext1_BPLCON4_39 RS.L 1
cl2_ext1_BPLCON4_40 RS.L 1
cl2_ext1_BPLCON4_41 RS.L 1
cl2_ext1_BPLCON4_42 RS.L 1
cl2_ext1_BPLCON4_43 RS.L 1
cl2_ext1_BPLCON4_44 RS.L 1
cl2_ext1_BPLCON4_45 RS.L 1
cl2_ext1_BPLCON4_46 RS.L 1
cl2_ext1_BPLCON4_47 RS.L 1
cl2_ext1_BPLCON4_48 RS.L 1
cl2_ext1_BPLCON4_49 RS.L 1
cl2_ext1_BPLCON4_50 RS.L 1
cl2_ext1_BPLCON4_51 RS.L 1
cl2_ext1_BPLCON4_52 RS.L 1
cl2_ext1_BPLCON4_53 RS.L 1
cl2_ext1_BPLCON4_54 RS.L 1
cl2_ext1_BPLCON4_55 RS.L 1
cl2_ext1_BPLCON4_56 RS.L 1
cl2_ext1_BPLCON4_57 RS.L 1

cl2_extension1_SIZE RS.B 0

  RSRESET

cl2_begin            RS.B 0

cl2_WAIT             RS.L 1
cl2_extension1_entry RS.B cl2_extension1_SIZE*cl2_display_y_size

cl2_WAIT1            RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1            EQU 0
cl1_size2            EQU 0
cl1_size3            EQU copperlist1_SIZE

cl2_size1            EQU 0
cl2_size2            EQU copperlist2_SIZE
cl2_size3            EQU copperlist2_SIZE


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1       EQU spr_x_size1
spr0_y_size1       EQU 0
spr1_x_size1       EQU spr_x_size1
spr1_y_size1       EQU 0
spr2_x_size1       EQU spr_x_size1
spr2_y_size1       EQU 0
spr3_x_size1       EQU spr_x_size1
spr3_y_size1       EQU 0
spr4_x_size1       EQU spr_x_size1
spr4_y_size1       EQU 0
spr5_x_size1       EQU spr_x_size1
spr5_y_size1       EQU 0
spr6_x_size1       EQU spr_x_size1
spr6_y_size1       EQU 0
spr7_x_size1       EQU spr_x_size1
spr7_y_size1       EQU 0

spr0_x_size2       EQU spr_x_size2
spr0_y_size2       EQU 0
spr1_x_size2       EQU spr_x_size2
spr1_y_size2       EQU 0
spr2_x_size2       EQU spr_x_size2
spr2_y_size2       EQU 0
spr3_x_size2       EQU spr_x_size2
spr3_y_size2       EQU 0
spr4_x_size2       EQU spr_x_size2
spr4_y_size2       EQU 0
spr5_x_size2       EQU spr_x_size2
spr5_y_size2       EQU 0
spr6_x_size2       EQU spr_x_size2
spr6_y_size2       EQU 0
spr7_x_size2       EQU spr_x_size2
spr7_y_size2       EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                   RS.L 1

; **** Zig-Zag-Plasma5 ****
zzp5_y_radius_angle       RS.W 1
zzp5_y_angle              RS.W 1

; **** Vert-Shade-Bars ****
vsb_state                 RS.W 1
vsb_y_radius_angle        RS.W 1
vsb_y_angle               RS.W 1

; **** Vert-Border-Fader ****
vbf_fader_angle           RS.W 1
vbf_display_window_VSTART RS.W 1
vbf_display_window_VSTOP  RS.W 1

vbfo_state                RS.W 1

; **** Effects-Handler ****
eh_trigger_number         RS.W 1

; **** Main ****
fx_state                  RS.W 1

variables_SIZE            RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_0a_zig_zag_plasma
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Zig-Zag-Plasma5 ****
  moveq   #TRUE,d0
  move.w  d0,zzp5_y_radius_angle(a3)
  move.w  d0,zzp5_y_angle(a3)

; **** Vert-Shade-Bars ****
  move.w  d0,vsb_state(a3)
  move.w  #sine_table_length/4,vsb_y_radius_angle(a3)
  move.w  d0,vsb_y_angle(a3)

; **** Vert-Border-Fader ****
  move.w  #sine_table_length/4,vbf_fader_angle(a3)
  move.w  #display_window_VSTART,vbf_display_window_VSTART(a3)
  move.w  #display_window_VSTOP,vbf_display_window_VSTOP(a3)

  moveq   #FALSE,d1
  move.w  d1,vbfo_state(a3)

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
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 0
  CPU_INIT_COLORHI COLOR00,32,pf1_color_table
  CPU_SELECT_COLORHI_BANK 1
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 2
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 3
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 4
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 5
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 6
  CPU_INIT_COLORHI COLOR00,32
  CPU_SELECT_COLORHI_BANK 7
  CPU_INIT_COLORHI COLOR00,32

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,32,pf1_color_table
  CPU_SELECT_COLORLO_BANK 1
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 2
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 3
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 4
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 5
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 6
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 7
  CPU_INIT_COLORLO COLOR00,32
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_bitplane_pointers
  COPMOVEQ TRUE,COPJMP2
  bra     cl1_set_bitplane_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1

  COP_INIT_BITPLANE_POINTERS cl1

  COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0 ;Aufbau-CL
  bsr.s   cl2_init_BPLCON4_registers
  bsr.s   cl2_init_copint
  COPLISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  CNOP 0,4
cl2_init_BPLCON4_registers
  move.l  #(BPLCON4<<16)+BPLCON4BITS,d0
  COPWAIT cl2_HSTART1,cl2_VSTART1
  move.w  #(cl2_display_width*cl2_display_y_size)-1,d7 ;Anzahl der Spalten
cl2_init_BPLCON4_registers_loop
  move.l  d0,(a0)+           ;BPLCON4
  dbf     d7,cl2_init_BPLCON4_registers_loop
  rts

  COP_INIT_COPINT cl2

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
  bsr     vert_border_fader_out
  bsr     vert_shade_bars
  bsr     zzp5_get_y_coordinates
  jsr     mouse_handler
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


; ** Bars in Puffer kopieren **
; -----------------------------
  CNOP 0,4
vert_shade_bars
  tst.w   vsb_state(a3)
  bne     no_vert_shade_bars
  move.w  vsb_y_radius_angle(a3),d2 ;Y-Radius-Winkel 
  move.w  d2,d0              
  MOVEF.W sine_table_length-1,d6 ;Überlauf
  addq.w  #vsb_y_radius_angle_speed,d0 ;nächster Y-Radius-Winkel
  move.w  vsb_y_angle(a3),d3 ;Y-Winkel
  and.w   d6,d0              ;Überlauf entfernen
  move.w  d0,vsb_y_radius_angle(a3) ;Y-Radius-Winkel retten
  move.w  d3,d0              
  addq.w  #vsb_y_angle_speed,d0 ;nächster Y-Winkel
  and.w   d6,d0              ;Überlauf entfernen
  move.w  d0,vsb_y_angle(a3) 
  MOVEF.W vsb_y_radius*4,d4
  MOVEF.W vsb_y_angle_step,d5
  lea     sine_table_512,a0 
  move.l  chip_memory(a3),a1 ;Zeiger auf Tabelle mit Farbummern der Linien
  move.w  #vsb_y_center,a2
  moveq   #vsb_bars_number-1,d7 ;Anzahl der Bars
vert_shade_bars_loop
  move.w  2(a0,d2.w*4),d0    ;cos(w)
  muls.w  d4,d0              ;yr'=(yr*cos(w))/2*^15
  swap    d0
  muls.w  2(a0,d3.w*4),d0    ;y'=(yr'*sin(w))/2*^15
  swap    d0
  add.w   a2,d0              ;y' + Y-Mittelpunkt
  addq.b  #1,(a1,d0.w*2)     ;Farbnummer hochzählen
  addq.b  #2,2(a1,d0.w*2)    ;Farbnummer hochzählen
  addq.b  #3,4(a1,d0.w*2)    ;Farbnummer hochzählen
  addq.b  #4,6(a1,d0.w*2)    ;Farbnummer hochzählen
  addq.b  #5,8(a1,d0.w*2)    ;Farbnummer hochzählen
  addq.b  #6,10(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #7,12(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #8,14(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #8,16(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #7,18(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #6,20(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.b  #5,22(a1,d0.w*2)   ;Farbnummer hochzählen
  addq.w  #vsb_y_radius_angle_step,d2 ;nächster Y-Radius-Winkel
  addq.b  #4,24(a1,d0.w*2)   ;Farbnummer hochzählen
  and.w   d6,d2              ;Überlauf entfernen
  addq.b  #3,26(a1,d0.w*2)   ;Farbnummer hochzählen
  add.w   d5,d3              ;nächster Y-Winkel
  addq.b  #2,28(a1,d0.w*2)   ;Farbnummer hochzählen
  and.w   d6,d3              ;Überlauf entfernen
  addq.b  #1,30(a1,d0.w*2)   ;Farbnummer hochzählen
  dbf     d7,vert_shade_bars_loop
no_vert_shade_bars
  rts

; ** Y-Koordinaten berechnen und Bars setzen **
; ---------------------------------------------
  CNOP 0,4
zzp5_get_y_coordinates
  movem.l a3-a5,-(a7)
  move.l  a7,save_a7(a3)     
  bsr     zzp5_init_copy_blit
  MOVEF.W zzp5_y_center,d1
  move.w  zzp5_y_radius_angle(a3),d2 ;1. Winkel Y-Radius
  move.w  d2,d0              
  lea     sine_table_512,a0  
  move.w  2(a0,d2.w*4),d2    ;sin(w)
  asr.w   #8,d2              ;yr'=(yr*sin(w))/2^15
  addq.w  #zzp5_y_radius_angle_speed,d0 ;nächster Y-Radius-Winkel
  MOVEF.W sine_table_length-1,d6 ;Überlauf
  move.w  zzp5_y_angle(a3),d3 ;1. Y-Winkel
  and.w   d6,d0              ;Überlauf entfernen
  move.w  d0,zzp5_y_radius_angle(a3) 
  move.w  d3,d0              
  addq.w  #zzp5_y_angle_speed,d0 ;nächster Y-Winkel
  and.w   d6,d0              ;Überlauf entfernen
  move.w  d0,zzp5_y_angle(a3) 
  ;MOVEF.W zzp5_y_radius,d4
  move.w  #(zzp5_copy_blit_y_size*64)+(zzp5_copy_blit_x_size/16),d4 ;BLTSIZE
  moveq   #zzp5_y_angle_step,d5
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2,a2
  lea     BLTDPT-DMACONR(a6),a4
  lea     BLTSIZE-DMACONR(a6),a5
  move.l  chip_memory(a3),a7 ;Zeiger auf Tabelle mit Switchwerten
  lea     BLTAPT-DMACONR(a6),a3
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
zzp5_get_y_coordinates_loop
  move.w  d2,d0
  muls.w  2(a0,d3.w*4),d0    ;y'=(yr'*sin(w))/2^15
  swap    d0
  add.w   d1,d0              ;y' + Y-Mittelpunkt
  WAITBLITTER
  move.l  a2,(a4)            ;Ziel = Copperliste
  lea     (a7,d0.w*2),a1     ;Y-Offset in Switch-Tabelle
  move.l  a1,(a3)            ;Quelle = Switch-Tabelle
  move.w  d4,(a5)            ;Blitter starten
  add.w   d5,d3              ;nächster Y-Winkel
  addq.w  #4,a2              ;nächste Spalte in CL
  and.w   d6,d3              ;Überlauf entfernen
  dbf     d7,zzp5_get_y_coordinates_loop
  move.l  variables+save_a7(pc),a7 ;Stackpointer
  movem.l (a7)+,a3-a5
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  rts
  CNOP 0,4
zzp5_init_copy_blit
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.l  #(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;Ausmaskierung
  move.l  #cl2_extension1_SIZE-zzp5_copy_blit_width,BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  rts


; ** Coppereffekt ausfaden **
; ---------------------------
  CNOP 0,4
vert_border_fader_out
  tst.w   vbfo_state(a3)     ;Vert-Border-Fader an ?
  bne.s   no_vert_border_fader_out ;Nein -> verzweige
  move.w  vbf_fader_angle(a3),d1 ;Fader-Winkel 
  move.w  d1,d0              
  subq.w  #vbfo_fader_angle_speed,d0 ;nächster Fader-Winkel
  move.w  d0,vbf_fader_angle(a3) 
  lea     sine_table_512,a0  
  move.l  (a0,d1.w*4),d0     ;sin(w)
  MULUF.L vbfo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  add.w   #vbfo_fader_center,d0 ;+ Fader-Mittelpunkt
  move.w  vbf_display_window_VSTART(a3),d2 ;Aktuelle VSTART-Position
  add.w   d0,d2              ;neue VSTART-Position
  cmp.w   #vbf_y_position_center,d2 ;Zielwert erreicht ?
  ble.s   vbfo_no_vert_start_position_max ;Nein -> verzweige
  MOVEF.W vbf_y_position_center,d2 ;Zielwert
vbfo_no_vert_start_position_max
  move.w  vbf_display_window_VSTOP(a3),d1 ;Aktuelle VSTOP-Position
  sub.w   d0,d1              ;neue VSTOP-Position
  move.w  d2,vbf_display_window_VSTART(a3) 
  cmp.w   #vbf_y_position_center,d1 ;Zielwert erreicht ?
  bge.s   vbfo_no_vert_stop_position_min ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,vbfo_state(a3)  ;Vert-Border-Fader aus
  MOVEF.W vbf_y_position_center,d1 ;Zielwert
vbfo_no_vert_stop_position_min
  move.w  d1,vbf_display_window_VSTOP(a3) retten
vbfo_set_window_vert_positions
  move.l  cl1_display(a3),a0 
  move.w  #DIWHIGHBITS&(~(DIWHIGHF_VSTART8+DIWHIGHF_VSTART9+DIWHIGHF_VSTART10+DIWHIGHF_VSTOP8+DIWHIGHF_VSTOP9+DIWHIGHF_VSTOP10)),d0 ;DIWHIGH-Bits 
  move.b  d2,cl1_DIWSTRT+2(a0) ;VSTART0-VSTART7 setzen
  lsr.w   #8,d2              ;VSTART8-VSTART10 in richtige Position bringen
  move.b  d1,cl1_DIWSTOP+2(a0) ;VSTOP0-VSTOP7 setzen
  move.b  d2,d1              ;VSTART8-VSTART10 einfügen
  or.w    d1,d0              ;HSTART/HSTOP-Bits einfügen
  move.w  d0,cl1_DIWHIGH+2(a0) ;VSTART/VSTOP-Bits setzen
no_vert_border_fader_out
  rts


; ** SOFTINT-Interrupts abfragen **
; ---------------------------------
  CNOP 0,4
effects_handler
  moveq   #INTF_SOFTINT,d1
  and.w   INTREQR-DMACONR(a6),d1   ;Wurde der SOFTINT-Interrupt gesetzt ?
  beq.s   no_effects_handler ;Nein -> verzweige
  addq.w  #1,eh_trigger_number(a3) ;FX-Trigger-Zähler hochsetzen
  move.w  eh_trigger_number(a3),d0 ;FX-Trigger-Zähler 
  cmp.w   #eh_trigger_number_max,d0 ;Maximalwert bereits erreicht ?
  bgt.s   no_effects_handler ;Ja -> verzweige
  move.w  d1,INTREQ-DMACONR(a6) ;SOFTINT-Interrupt löschen
  subq.w  #1,d0
  beq.s   eh_start_vert_shade_bars
  subq.w  #1,d0
  beq.s   eh_start_vert_border_fader_out
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_vert_shade_bars
  clr.w   vsb_state(a3)      ;Vert-Shade-Bars an
  rts
  CNOP 0,4
eh_start_vert_border_fader_out
  clr.w   vbfo_state(a3)     ;Vert-Border-Fader-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_state(a3)       ;Effekt beenden
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
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/0b_zzp5_Colorgradient.ct"


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

  END
