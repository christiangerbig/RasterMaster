; ############################################
; # Programm: 03_Twisted-Colorcycle-Bars.asm #
; # Autor:    Christian Gerbig               #
; # Datum:    21.12.2023                     #
; # Version:  1.3 beta                       #
; # CPU:      68020+                         #
; # FASTMEM:  -                              #
; # Chipset:  AGA                            #
; # OS:       3.0+                           #
; ############################################

  SECTION code_and_variables,CODE

  MC68040


  XREF color00_bits
  XREF mouse_handler

  XDEF start_03_twisted_colorcycle_bars
  XDEF sine_table_512


  INCDIR "Daten:include3.5/"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "dos/dos.i"

  INCLUDE "graphics/gfxbase.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "libraries/any_lib.i"

  INCLUDE "hardware/adkbits.i"
  INCLUDE "hardware/blit.i"
  INCLUDE "hardware/cia.i"
  INCLUDE "hardware/custom.i"
  INCLUDE "hardware/dmabits.i"
  INCLUDE "hardware/intbits.i"

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


SYS_TAKEN_OVER                  SET 1
PASS_GLOBAL_REFERENCES          SET 1
PASS_RETURN_CODE                SET 1
COLOR_GRADIENT_RGB8             SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu                EQU FALSE
requires_040_cpu                EQU FALSE
requires_060_cpu                EQU FALSE
requires_fast_memory            EQU FALSE
requires_multiscan_monitor      EQU FALSE

workbench_start_enabled         EQU FALSE
workbench_fade_enabled          EQU FALSE
text_output_enabled             EQU FALSE

open_border_enabled             EQU TRUE

tccb_quick_clear_enabled        EQU TRUE
tccb_restore_cl_cpu_enabled     EQU TRUE
tccb_restore_cl_blitter_enabled EQU FALSE

  IFEQ open_border_enabled
dma_bits                        EQU DMAF_BLITTER+DMAF_COPPER+DMAF_SETCLR
  ELSE
dma_bits                        EQU DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+MAF_SETCLR
  ENDC
intena_bits                     EQU INTF_SETCLR

ciaa_icr_bits                   EQU CIAICRF_SETCLR
ciab_icr_bits                   EQU CIAICRF_SETCLR

copcon_bits                     EQU 0

pf1_x_size1                     EQU 0
pf1_y_size1                     EQU 0
pf1_depth1                      EQU 0
pf1_x_size2                     EQU 0
pf1_y_size2                     EQU 0
pf1_depth2                      EQU 0
  IFEQ open_border_enabled
pf1_x_size3                     EQU 0
pf1_y_size3                     EQU 0
pf1_depth3                      EQU 0
  ELSE
pf1_x_size3                     EQU 32
pf1_y_size3                     EQU 1
pf1_depth3                      EQU 1
  ENDC
pf1_colors_number               EQU 161

pf2_x_size1                     EQU 0
pf2_y_size1                     EQU 0
pf2_depth1                      EQU 0
pf2_x_size2                     EQU 0
pf2_y_size2                     EQU 0
pf2_depth2                      EQU 0
pf2_x_size3                     EQU 0
pf2_y_size3                     EQU 0
pf2_depth3                      EQU 0
pf2_colors_number               EQU 0
pf_colors_number                EQU pf1_colors_number+pf2_colors_number
pf_depth                        EQU pf1_depth3+pf2_depth3

extra_pf_number                 EQU 0

spr_number                      EQU 0
spr_x_size1                     EQU 0
spr_y_size1                     EQU 0
spr_x_size2                     EQU 0
spr_y_size2                     EQU 0
spr_depth                       EQU 0
spr_colors_number               EQU 0

audio_memory_size               EQU 0

disk_memory_size                EQU 0

chip_memory_size                EQU 0
ciaa_ta_time                    EQU 0
ciaa_tb_time                    EQU 0
ciab_ta_time                    EQU 0
ciab_tb_time                    EQU 0
ciaa_ta_continuous_enabled      EQU FALSE
ciaa_tb_continuous_enabled      EQU FALSE
ciab_ta_continuous_enabled      EQU FALSE
ciab_tb_continuous_enabled      EQU FALSE

beam_position                   EQU $136

  IFNE open_border_enabled 
pixel_per_line                  EQU 32
  ENDC
visible_pixels_number           EQU 352
visible_lines_number            EQU 256

MINROW                          EQU VSTART_256_LINES

  IFNE open_border_enabled 
pf_pixel_per_datafetch          EQU 16 ;1x
  ENDC

display_window_hstart           EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart           EQU MINROW
display_window_hstop            EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop            EQU VSTOP_256_LINES

  IFNE open_border_enabled 
pf1_plane_width                 EQU pf1_x_size3/8
data_fetch_width                EQU pixel_per_line/8
pf1_plane_moduli                EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

  IFEQ open_border_enabled
diwstrt_bits                    EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                    EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
bplcon0_bits                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1                   EQU 0
bplcon3_bits2                   EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon3_bits3                   EQU bplcon3_bits1+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon3_bits4                   EQU bplcon3_bits2+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon4_bits                    EQU 0
diwhigh_bits                    EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
  ELSE
diwstrt_bits                    EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                    EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
ddfstrt_bits                    EQU DDFSTART_OVERSCAN_32_PIXEL
ddfstop_bits                    EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1                   EQU 0
bplcon3_bits2                   EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon3_bits3                   EQU bplcon3_bits1+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon3_bits4                   EQU bplcon3_bits2+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon4_bits                    EQU 0
diwhigh_bits                    EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
  ENDC

cl1_display_x_size              EQU 352
cl1_display_width               EQU cl1_display_x_size/8
cl1_display_y_size              EQU visible_lines_number
  IFEQ open_border_enabled
cl1_hstart1                     EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
  ELSE
cl1_hstart1                     EQU display_window_hstart-4
  ENDC
cl1_vstart1                     EQU MINROW
cl1_hstart2                     EQU $00
cl1_vstart2                     EQU beam_position&$ff

sine_table_length               EQU 512

; **** Twisted-Colorcycle-Bars ****
tccb_bars_number                EQU 10
tccb_bar_height                 EQU 32
tccb_y_radius                   EQU (cl1_display_y_size-tccb_bar_height)/2
tccb_y_center                   EQU (cl1_display_y_size-tccb_bar_height)/2
tccb_y_radius_angle_speed       EQU 5
tccb_y_radius_angle_step        EQU 1
tccb_y_angle_speed              EQU 3
tccb_y_angle_step               EQU 2
tccb_y_distance                 EQU 16

; **** Clear-Blit ****
tccb_clear_blit_x_size          EQU 16
  IFEQ open_border_enabled
tccb_clear_blit_y_size          EQU cl1_display_y_size*(cl1_display_width+2)
  ELSE
tccb_clear_blit_y_size          EQU cl1_display_y_size*(cl1_display_width+1)
  ENDC

; **** Restore-Blit ****
tccb_restore_blit_x_size        EQU 16
tccb_restore_blit_width         EQU tccb_restore_blit_x_size/8
tccb_restore_blit_y_size        EQU cl1_display_y_size

; **** Colorcycle  ****
cc_speed                        EQU 4
cc_step                         EQU 64

; **** Blind-Fader ****
bf_lamella_height               EQU 16
bf_lamellas_number              EQU visible_lines_number/bf_lamella_height
bf_step1                        EQU 1
bf_step2                        EQU 1
bf_speed                        EQU 2

bf_registers_table_length       EQU bf_lamella_height*4

; **** Effects-Handler ****
eh_trigger_number_max           EQU 3


color_x_step                    EQU 1
color_y_step                    EQU 255/(tccb_bar_height/2)
color_x_values_number           EQU 255
color_y_values_number           EQU tccb_bar_height/2
segments_number                 EQU 5

ct_size                         EQU color_y_values_number*segments_number*color_x_values_number

tccb_switch_table_size          EQU tccb_bar_height*tccb_bars_number


  INCLUDE "except-vectors-offsets.i"


  INCLUDE "extra-pf-attributes-structure.i"


  INCLUDE "sprite-attributes-structure.i"


  RSRESET

cl1_extension1      RS.B 0

cl1_ext1_WAIT       RS.L 1
  IFEQ open_border_enabled 
cl1_ext1_BPL1DAT    RS.L 1
  ENDC
cl1_ext1_BPLCON4_1  RS.L 1
cl1_ext1_BPLCON4_2  RS.L 1
cl1_ext1_BPLCON4_3  RS.L 1
cl1_ext1_BPLCON4_4  RS.L 1
cl1_ext1_BPLCON4_5  RS.L 1
cl1_ext1_BPLCON4_6  RS.L 1
cl1_ext1_BPLCON4_7  RS.L 1
cl1_ext1_BPLCON4_8  RS.L 1
cl1_ext1_BPLCON4_9  RS.L 1
cl1_ext1_BPLCON4_10 RS.L 1
cl1_ext1_BPLCON4_11 RS.L 1
cl1_ext1_BPLCON4_12 RS.L 1
cl1_ext1_BPLCON4_13 RS.L 1
cl1_ext1_BPLCON4_14 RS.L 1
cl1_ext1_BPLCON4_15 RS.L 1
cl1_ext1_BPLCON4_16 RS.L 1
cl1_ext1_BPLCON4_17 RS.L 1
cl1_ext1_BPLCON4_18 RS.L 1
cl1_ext1_BPLCON4_19 RS.L 1
cl1_ext1_BPLCON4_20 RS.L 1
cl1_ext1_BPLCON4_21 RS.L 1
cl1_ext1_BPLCON4_22 RS.L 1
cl1_ext1_BPLCON4_23 RS.L 1
cl1_ext1_BPLCON4_24 RS.L 1
cl1_ext1_BPLCON4_25 RS.L 1
cl1_ext1_BPLCON4_26 RS.L 1
cl1_ext1_BPLCON4_27 RS.L 1
cl1_ext1_BPLCON4_28 RS.L 1
cl1_ext1_BPLCON4_29 RS.L 1
cl1_ext1_BPLCON4_30 RS.L 1
cl1_ext1_BPLCON4_31 RS.L 1
cl1_ext1_BPLCON4_32 RS.L 1
cl1_ext1_BPLCON4_33 RS.L 1
cl1_ext1_BPLCON4_34 RS.L 1
cl1_ext1_BPLCON4_35 RS.L 1
cl1_ext1_BPLCON4_36 RS.L 1
cl1_ext1_BPLCON4_37 RS.L 1
cl1_ext1_BPLCON4_38 RS.L 1
cl1_ext1_BPLCON4_39 RS.L 1
cl1_ext1_BPLCON4_40 RS.L 1
cl1_ext1_BPLCON4_41 RS.L 1
cl1_ext1_BPLCON4_42 RS.L 1
cl1_ext1_BPLCON4_43 RS.L 1
cl1_ext1_BPLCON4_44 RS.L 1

cl1_extension1_size RS.B 0


  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_extension1_entry RS.B cl1_extension1_size*cl1_display_y_size

cl1_WAIT1            RS.L 1
cl1_INTREQ           RS.L 1

cl1_end              RS.L 1

copperlist1_size     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
cl1_size1            EQU copperlist1_size
cl1_size2            EQU copperlist1_size
cl1_size3            EQU copperlist1_size

cl2_size1            EQU 0
cl2_size2            EQU 0
cl2_size3            EQU 0


; ** Konstanten für die Größe der Spritestrukturen **
spr0_x_size1          EQU spr_x_size1
spr0_y_size1          EQU 0
spr1_x_size1          EQU spr_x_size1
spr1_y_size1          EQU 0
spr2_x_size1          EQU spr_x_size1
spr2_y_size1          EQU 0
spr3_x_size1          EQU spr_x_size1
spr3_y_size1          EQU 0
spr4_x_size1          EQU spr_x_size1
spr4_y_size1          EQU 0
spr5_x_size1          EQU spr_x_size1
spr5_y_size1          EQU 0
spr6_x_size1          EQU spr_x_size1
spr6_y_size1          EQU 0
spr7_x_size1          EQU spr_x_size1
spr7_y_size1          EQU 0

spr0_x_size2          EQU spr_x_size2
spr0_y_size2          EQU 0
spr1_x_size2          EQU spr_x_size2
spr1_y_size2          EQU 0
spr2_x_size2          EQU spr_x_size2
spr2_y_size2          EQU 0
spr3_x_size2          EQU spr_x_size2
spr3_y_size2          EQU 0
spr4_x_size2          EQU spr_x_size2
spr4_y_size2          EQU 0
spr5_x_size2          EQU spr_x_size2
spr5_y_size2          EQU 0
spr6_x_size2          EQU spr_x_size2
spr6_y_size2          EQU 0
spr7_x_size2          EQU spr_x_size2
spr7_y_size2          EQU 0


  RSRESET

em_color_table    RS.L ct_size
em_switch_table   RS.B tccb_switch_table_size
extra_memory_size RS.B 0


  RSRESET

  INCLUDE "variables-offsets.i"

save_a7                  RS.L 1

; **** Colorcycle ****
cc_color_table_start     RS.L 1

; **** Twisted-Colorcycle-Bars ****
tccb_y_angle             RS.W 1
tccb_y_radius_angle      RS.W 1

; **** Blind-Fader ****
  IFEQ open_border_enabled
bf_registers_table_start RS.W 1

bfi_active               RS.W 1

bfo_active               RS.W 1
  ENDC

; **** Effects-Handler ****
eh_trigger_number        RS.W 1

; **** Main ****
fx_active                RS.W 1

variables_size           RS.B 0


start_03_twisted_colorcycle_bars

  INCLUDE "sys-wrapper.i"

  CNOP 0,4
init_own_variables

; **** Colorcycle ****
  moveq   #0,d0
  move.l  d0,cc_color_table_start(a3)

; **** Twisted-Colorcycle-Bars ****
  move.w  d0,tccb_y_angle(a3)
  move.w  d0,tccb_y_radius_angle(a3)

; **** Blind-Fader ****
  IFEQ open_border_enabled
    move.w  d0,bf_registers_table_start(a3)

    moveq   #FALSE,d1
    move.w  d1,bfi_active(a3)

    move.w  d1,bfo_active(a3)
  ENDC

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
  CNOP 0,4
init_all
  bsr.s   tccb_init_color_table
  IFEQ tccb_quick_clear_enabled
    IFNE 256-pf_colors_number
      bsr     init_color_registers
    ENDC
  ENDC
  bsr     tccb_init_mirror_switch_table
  bra     init_first_copperlist

; **** Twisted-Colorcycle-Bars ****
; ** Farbtabelle initialisieren **
  CNOP 0,4
tccb_init_color_table
  movem.l a4-a6,-(a7)
; ** vertikale Farbverläufe **
  lea     tccb_color_gradient(pc),a0 ;Quelle: Farbverläufe
  move.l  extra_memory(a3),a2 ;Ziel: Farbtabelle
  move.w  #color_x_values_number*segments_number*LONGWORD_SIZE,a4
  move.w  #color_x_values_number*1*LONGWORD_SIZE,a5
  moveq   #segments_number-1,d7 ;Anzahl der Segmente
tccb_init_color_table_loop1
  move.l  a2,a1              ;Zeiger auf Farbtabelle
  moveq   #color_y_values_number-1,d6 ;Anzahl der Farbwerte
tccb_init_color_table_loop2
  move.l  (a0)+,(a1)         ;RGB8-Wert kopieren
  add.l   a4,a1              ;nächste Zeile in Farbtabelle
  dbf     d6,tccb_init_color_table_loop2
  add.l   a5,a2              ;nächstes Segment
  dbf     d7,tccb_init_color_table_loop1
; ** horizontale Fabverläufe **
  INIT_COLOR_GRADIENT_GROUP_RGB8 color_x_values_number,tccb_bar_height/2,segments_number,color_x_step,extra_memory,a3,0,1
  movem.l (a7)+,a4-a6
  rts

  IFEQ tccb_quick_clear_enabled
    IFNE pf_colors_number-256
init_color_registers
      CPU_SELECT_COLOR_HIGH_BANK 7,bplcon3_bits3
      CPU_INIT_COLOR_HIGH COLOR31,1,pf1_color_table
      CPU_SELECT_COLOR_LOW_BANK 7,bplcon3_bits4
      CPU_INIT_COLOR_LOW COLOR31,1,pf1_color_table
      rts
    ENDC
  ENDC

  INIT_MIRROR_SWITCH_TABLE.B tccb,1,1,tccb_bars_number,color_y_values_number,extra_memory,a3,em_switch_table


  CNOP 0,4
init_first_copperlist
  move.l  cl1_construction1(a3),a0 
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_color_registers
  IFEQ open_border_enabled
    bsr     cl1_init_bplcon4_registers
    bsr     cl1_init_copper_interrupt
    COP_LISTEND
  ELSE
    bsr     cl1_init_bitplane_pointers
    bsr     cl1_init_bplcon4_registers
    bsr     cl1_init_copper_interrupt
    COP_LISTEND
    bsr     cl1_set_bitplane_pointers
  ENDC
  bra     copy_first_copperlist
  
  IFEQ open_border_enabled
    COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES
  ELSE
    COP_INIT_PLAYFIELD_REGISTERS cl1
    COP_INIT_BITPLANE_POINTERS cl1
    COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
  ENDC

  CNOP 0,4
cl1_init_color_registers
  COP_INIT_COLOR_HIGH COLOR00,32,pf1_color_table
  COP_SELECT_COLOR_HIGH_BANK 1
  COP_INIT_COLOR_HIGH COLOR00,32
  COP_SELECT_COLOR_HIGH_BANK 2
  COP_INIT_COLOR_HIGH COLOR00,32
  COP_SELECT_COLOR_HIGH_BANK 3
  COP_INIT_COLOR_HIGH COLOR00,32
  COP_SELECT_COLOR_HIGH_BANK 4
  COP_INIT_COLOR_HIGH COLOR00,32
  COP_SELECT_COLOR_HIGH_BANK 5
  COP_INIT_COLOR_HIGH COLOR00,1

  COP_SELECT_COLOR_LOW_BANK 0
  COP_INIT_COLOR_LOW COLOR00,32,pf1_color_table
  COP_SELECT_COLOR_LOW_BANK 1
  COP_INIT_COLOR_LOW COLOR00,32
  COP_SELECT_COLOR_LOW_BANK 2
  COP_INIT_COLOR_LOW COLOR00,32
  COP_SELECT_COLOR_LOW_BANK 3
  COP_INIT_COLOR_LOW COLOR00,32
  COP_SELECT_COLOR_LOW_BANK 4
  COP_INIT_COLOR_LOW COLOR00,32
  COP_SELECT_COLOR_LOW_BANK 5
  COP_INIT_COLOR_LOW COLOR00,1
  rts

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl1,cl1_hstart1,cl1_vstart1,cl1_display_x_size,cl1_display_y_size,open_border_enabled,tccb_quick_clear_enabled,FALSE,NOOP<<16

  COP_INIT_COPINT cl1,cl1_hstart2,cl1_vstart2

  COPY_COPPERLIST cl1,3

  CNOP 0,4
main_routine
  bsr.s   no_sync_routines
  bra.s   beam_routines


  CNOP 0,4
no_sync_routines
  rts


  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   swap_first_copperlist
  bsr     effects_handler
  bsr     tccb_clear_first_copperlist
  bsr     colorcycle
  bsr     twisted_colorcycle_bars
  IFNE tccb_quick_clear_enabled
    bsr     tccb_restore_first_copperlist
  ENDC
  IFEQ open_border_enabled
    bsr     blind_fader_in
    bsr     blind_fader_out
  ENDC
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


  SWAP_COPPERLIST cl1,3


  CLEAR_BPLCON4_CHUNKY_SCREEN tccb,cl1,construction1,extension1,quick_clear_enabled

; ** Farbwerte der Bars ändern **
  CNOP 0,4
colorcycle
  movem.l a4-a6,-(a7)
  move.l  cc_color_table_start(a3),d3 ;Startwert 
  move.l  d3,d0              
  addq.l  #cc_speed,d0       ;nächster Farbwert
  cmp.l   #color_x_values_number*segments_number,d0
  blt.s   cc_no_restart_color_table1 ;Wenn >= NULL, dann verzweige
  sub.l   #color_x_values_number*segments_number,d0 ;Neustart
cc_no_restart_color_table1
  move.l  d0,cc_color_table_start(a3) ;Startwert retten
  move.w  #$0f0f,d4          ;Maske RGB-Nibbles
  moveq   #1*8,d5            ;Farbregister-Zähler
  move.l  extra_memory(a3),a1 ;Zeiger auf Farbtabelle
  move.l  cl1_construction2(a3),a2 
  ADDF.W  cl1_COLOR01_high1+2,a2
  move.w  #(color_x_values_number*segments_number)*4,a4
  move.w  #cc_step,a5
  move.w  #color_x_values_number*segments_number,a6 ;Neustart
  moveq   #tccb_bars_number-1,d7 ;Anzahl der Stangen
colorcycle_loop1
  lea     (a1,d3.l*4),a0     ;Offset in Farbtabelle
  moveq   #(tccb_bar_height/2)-1,d6 ;halbe Höhe der Bar
colorcycle_loop2
  move.l  (a0),d0            ;24 Bit-Farbwert
  move.l  d0,d2              
  RGB8_TO_RGB4_HIGH d0,d1,d4
  move.w  d0,(a2)            ;COLORxx High-Bits
  RGB8_TO_RGB4_LOW d2,d1,d4
  move.w  d2,cl1_COLOR01_low1-cl1_COLOR01_high1(a2) ;COLORxx Low-Bits
  add.l   a4,a0              ;nächste Zeile in Farbtabelle
  addq.w  #4,a2              ;nächstes Farbregister
  addq.b  #1*8,d5            ;Farbregisterzähler erhöhen
  bne.s   cc_no_restart_color_bank ;Nein -> verzweige
  addq.w  #4,a2              ;CMOVE überspringen
cc_no_restart_color_bank
  dbf     d6,colorcycle_loop2
  sub.l   a5,d3              ;nächster Wert aus Tabelle
  bge.s   cc_no_restart_color_table2 ;Wenn >= NULL, dann verzweige
  add.l   a6,d3              ;Neustart
cc_no_restart_color_table2
  dbf     d7,colorcycle_loop1
  movem.l (a7)+,a4-a6
  rts

; ** Y-Koordinaten berechnen und Bars setzen **
  CNOP 0,4
twisted_colorcycle_bars
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  tccb_y_radius_angle(a3),d4 ;Y-Radius-Winkel 
  move.w  d4,d0              
  MOVEF.W sine_table_length-1,d7 ;Überlauf
  addq.w  #tccb_y_radius_angle_speed,d0 ;nächster Y-Radius-Winkel
  move.w  tccb_y_angle(a3),d5 ;1. Y-Winkel
  and.w   d7,d0              ;Überlauf entfernen
  move.w  d0,tccb_y_radius_angle(a3) 
  move.w  d5,d0              
  addq.w  #tccb_y_angle_speed,d0 ;nächster Y-Winkel
  and.w   d7,d0              ;Überlauf entfernen
  move.w  d0,tccb_y_angle(a3) 
  lea     sine_table_512(pc),a0 
  move.l  cl1_construction2(a3),a2 
  ADDF.W cl1_extension1_entry+cl1_ext1_BPLCON4_1+2,a2
  move.l  extra_memory(a3),a5
  move.w  #tccb_y_distance,a3
  add.l   #em_switch_table,a5 ;Zeiger auf Tabelle mit Switchwerten
  move.w  #tccb_y_center,a6
  move.w  d5,a7              
  swap    d7                 ;Überlauf retten
  move.w  #cl1_display_width-1,d7 ;Anzahl der Spalten
tccb_get_y_coordinates_loop1
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  swap    d7                 ;Überlauf
  moveq   #tccb_bars_number-1,d6 ;Anzahl der Stangen
tccb_get_y_coordinates_loop2
  move.l  (a0,d4.w*4),d0     ;sin(w)
  MULUF.L tccb_y_radius*4,d0,d1 ;yr'=(yr*sin(w))/2^15
  swap    d0
  muls.w  2(a0,d5.w*4),d0    ;y'=(yr'*sin(w))/2^15
  swap    d0
  add.w   a6,d0              ;y' + Y-Mittelpunkt
  MULUF.W cl1_extension1_size/4,d0,d1 ;Y-Offset in CL
  lea     (a2,d0.w*4),a4     ;Y-Offset
  movem.l (a1)+,d0-d3        ;16 Switchwerte lesen
  move.b  d0,cl1_extension1_size*3(a4)
  swap    d0
  move.b  d0,cl1_extension1_size*1(a4)
  lsr.l   #8,d0
  move.b  d0,(a4)
  swap    d0
  move.b  d0,cl1_extension1_size*2(a4)
  move.b  d1,cl1_extension1_size*7(a4)
  swap    d1
  move.b  d1,cl1_extension1_size*5(a4)
  lsr.l   #8,d1
  move.b  d1,cl1_extension1_size*4(a4)
  swap    d1
  move.b  d1,cl1_extension1_size*6(a4)
  move.b  d2,cl1_extension1_size*11(a4)
  swap    d2
  move.b  d2,cl1_extension1_size*9(a4)
  lsr.l   #8,d2
  move.b  d2,cl1_extension1_size*8(a4)
  swap    d2
  move.b  d2,cl1_extension1_size*10(a4)
  addq.w  #tccb_y_radius_angle_step,d4 ;Y-Radius-Abstand zur nächsten Bar
  move.b  d3,cl1_extension1_size*15(a4)
  swap    d3
  move.b  d3,cl1_extension1_size*13(a4)
  lsr.l   #8,d3
  move.b  d3,cl1_extension1_size*12(a4)
  swap    d3
  move.b  d3,cl1_extension1_size*14(a4)
  movem.l (a1)+,d0-d3        ;16 Switchwerte lesen
  move.b  d0,cl1_extension1_size*19(a4)
  swap    d0
  move.b  d0,cl1_extension1_size*17(a4)
  lsr.l   #8,d0
  move.b  d0,cl1_extension1_size*16(a4)
  swap    d0
  move.b  d0,cl1_extension1_size*18(a4)
  and.w   d7,d4              ;Überlauf entfernen
  move.b  d1,cl1_extension1_size*23(a4)
  swap    d1
  move.b  d1,cl1_extension1_size*21(a4)
  lsr.l   #8,d1
  move.b  d1,cl1_extension1_size*20(a4)
  swap    d1
  move.b  d1,cl1_extension1_size*22(a4)
  add.w   a3,d5              ;Y-Abstand zu nächster Bar 
  move.b  d2,cl1_extension1_size*27(a4)
  swap    d2
  move.b  d2,cl1_extension1_size*25(a4)
  lsr.l   #8,d2
  move.b  d2,cl1_extension1_size*24(a4)
  swap    d2
  move.b  d2,cl1_extension1_size*26(a4)
  and.w   d7,d5              ;Überlauf entfernen
  move.b  d3,cl1_extension1_size*31(a4)
  swap    d3
  move.b  d3,cl1_extension1_size*29(a4)
  lsr.l   #8,d3
  move.b  d3,cl1_extension1_size*28(a4)
  swap    d3
  move.b  d3,cl1_extension1_size*30(a4)
  dbf     d6,tccb_get_y_coordinates_loop2
  move.w  a7,d5              ;Y-Winkel
  addq.w  #tccb_y_angle_step,d5 ;nächste Spalte
  and.w   d7,d5              ;Überlauf entfernen
  move.w  d5,a7              
  swap    d7                 ;Schleifenzähler
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,tccb_get_y_coordinates_loop1
  move.l  variables+save_a7(pc),a7 ;Stackpointer
  movem.l (a7)+,a3-a6
  rts

; ** Copper-WAIT-Befehle wiederherstellen **
  IFNE tccb_quick_clear_enabled
    RESTORE_BLCON4_CHUNKY_SCREEN tccb,cl1,construction2,extension1,32
  ENDC


  IFEQ open_border_enabled
; ** Blind-Fader-In **
    CNOP 0,4
blind_fader_in
    tst.w   bfi_active(a3)   ;Blind-Fader-In an ?
    bne.s   no_blind_fader_in ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Registeradresse 
    move.w  d2,d0            
    addq.w  #bf_speed,d0     ;Startwert der Tabelle erhöhen
    cmp.w   #bf_registers_table_length/2,d0 ;Ende der Tabelle erreicht ?
    ble.s   bf_no_restart_registers_table ;Nein -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfi_active(a3) ;Blind-Fader-In aus
bf_no_restart_registers_table
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl1_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl1_size1
      move.l  cl1_construction1(a3),a1 ;1. CL
      ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a1
    ENDC
    IFNE cl1_size2
      move.l  cl1_construction2(a3),a2 ;2. CL
      ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a2
    ENDC
    move.l  cl1_display(a3),a4 ;3. CL
    ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_in_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_in_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl1_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl1_size2
      move.w  d0,(a2)        ;Adresse in 2. CL schreiben
      add.l   d4,a2          ;nächste Zeile in 2. CL
    ENDC
    move.w  d0,(a4)          ;Adresse in 3. CL schreiben
    addq.w  #bf_step1,d1     ;nächster Eintrag in Tabelle
    add.l   d4,a4            ;nächste Zeile in 3. CL
    cmp.w   d3,d1            ;Ende erreicht ?
    blt.s   bfi_no_restart_register_table1
    sub.w   d3,d1            ;Neustart
bfi_no_restart_register_table1
    dbf     d6,blind_fader_in_loop2
    add.w   d5,d2            ;Startwert erhöhen
    cmp.w   d3,d2            ;Ende erreicht ?
    blt.s   bfi_no_restart_register_table2
    sub.w   d3,d2            ;Neustart
bfi_no_restart_register_table2
    dbf     d7,blind_fader_in_loop1
    move.l  (a7)+,a4
no_blind_fader_in
    rts
  
; ** Blind-Fader-Out **
    CNOP 0,4
blind_fader_out
    tst.w   bfo_active(a3)   ;Blind-Fader-Out an ?
    bne.s   no_blind_fader_out ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Startwert der Tabelle 
    move.w  d2,d0            
    subq.w  #bf_speed,d0     ;Startwert der Tabelle verringern
    bpl.s   bfo_no_restart_registers_table ;Wenn positiv -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfo_active(a3) ;Blind-Fader-Out aus
bfo_no_restart_registers_table
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl1_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl1_size1
      move.l  cl1_construction1(a3),a1 ;1. CL
      ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a1
    ENDC
    IFNE cl1_size2
      move.l  cl1_construction2(a3),a2 ;2. CL
      ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a2
    ENDC
    move.l  cl1_display(a3),a4 ;3. CL
    ADDF.W  cl1_extension1_entry+cl1_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_out_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_out_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl1_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl1_size2
      move.w  d0,(a2)        ;Adresse in 2. CL schreiben
      add.l   d4,a2          ;nächste Zeile in 2. CL
    ENDC
    move.w  d0,(a4)          ;Adresse in 3. CL schreiben
    addq.w  #bf_step1,d1     ;nächster Eintrag in Tabelle
    add.l   d4,a4            ;nächste Zeile in 3. CL
    cmp.w   d3,d1            ;Ende erreicht ?
    blt.s   bfo_no_restart_register_table1
    sub.w   d3,d1            ;Neustart
bfo_no_restart_register_table1
    dbf     d6,blind_fader_out_loop2
    add.w   d5,d2            ;Startwert erhöhen
    cmp.w   d3,d2            ;Ende erreicht ?
    blt.s   bfo_no_restart_register_table2
    sub.w   d3,d2            ;Neustart
bfo_no_restart_register_table2
    dbf     d7,blind_fader_out_loop1
    move.l  (a7)+,a4
no_blind_fader_out
    rts
  ENDC

; ** SOFTINT-Interrupts abfragen **
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
  beq.s   eh_start_blind_fader_in
  subq.w  #1,d0
  beq.s   eh_start_blind_fader_out
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_blind_fader_in
  clr.w   bfi_active(a3)     ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_start_blind_fader_out
  clr.w   bfo_active(a3)     ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_active(a3)      ;Effekte beendet
  rts


  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
  CNOP 0,4
NMI_int_server
  rts


  INCLUDE "help-routines.i"


  INCLUDE "sys-structures.i"

  CNOP 0,4
pf1_color_table
  DC.L color00_bits
  DS.L pf1_colors_number-1

sine_table_512
  INCLUDE "sine-table-512x32.i"

; **** Twisted-Colorcycle-Bars ****
tccb_color_gradient
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/04_tcb_Colorgradient.ct"

; **** Blind-Fader ****
  IFEQ open_border_enabled
; ** Tabelle mit Registeradressen **
bf_registers_table
    REPT bf_registers_table_length/2
      DC.W NOOP
    ENDR
    REPT bf_registers_table_length/2
      DC.W BPL1DAT
    ENDR
  ENDC


  INCLUDE "sys-variables.i"


  INCLUDE "sys-names.i"


  INCLUDE "error-texts.i"

  END
