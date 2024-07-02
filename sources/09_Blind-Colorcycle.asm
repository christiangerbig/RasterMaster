; #####################################
; # Programm: 09_Blind-Colorcycle.asm #
; # Autor:    Christian Gerbig        #
; # Datum:    21.12.2023              #
; # Version:  1.3 beta                #
; # CPU:      68020+                  #
; # FASTMEM:  -                       #
; # Chipset:  AGA                     #
; # OS:       3.0+                    #
; #####################################

  SECTION code_and_variables,CODE

  MC68040


  XREF color00_bits
  XREF mouse_handler
  XREF sine_table

  XDEF start_09_blind_colorcycle


DEF_SYS_TAKEN_OVER
DEF_PASS_GLOBAL_REFERENCES
DEF_PASS_RETURN_CODE


; ** Library-Includes V.3.x nachladen **
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


; ** Konstanten **
  INCLUDE "equals.i"

requires_030_cpu           EQU FALSE
requires_040_cpu           EQU FALSE
requires_060_cpu           EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start_enabled    EQU FALSE
workbench_fade_enabled     EQU FALSE
text_output_enabled        EQU FALSE

open_border_enabled        EQU TRUE

  IFEQ open_border_enabled
dma_bits                   EQU DMAF_COPPER+DMAF_SETCLR
  ELSE
dma_bits                   EQU DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
  ENDC
intena_bits                EQU INTF_SETCLR

ciaa_icr_bits              EQU CIAICRF_SETCLR
ciab_icr_bits              EQU CIAICRF_SETCLR

copcon_bits                EQU 0

pf1_x_size1                EQU 0
pf1_y_size1                EQU 0
pf1_depth1                 EQU 0
pf1_x_size2                EQU 0
pf1_y_size2                EQU 0
pf1_depth2                 EQU 0
  IFEQ open_border_enabled
pf1_x_size3                EQU 0
pf1_y_size3                EQU 0
pf1_depth3                 EQU 0
  ELSE
pf1_x_size3                EQU 32
pf1_y_size3                EQU 1
pf1_depth3                 EQU 1
  ENDC
pf1_colors_number          EQU 0 ;129

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

chip_memory_size           EQU 0
ciaa_ta_time               EQU 0
ciaa_tb_time               EQU 0
ciab_ta_time               EQU 0
ciab_tb_time               EQU 0
ciaa_ta_continuous_enabled EQU FALSE
ciaa_tb_continuous_enabled EQU FALSE
ciab_ta_continuous_enabled EQU FALSE
ciab_tb_continuous_enabled EQU FALSE

beam_position              EQU $136

  IFNE open_border_enabled 
pixel_per_line             EQU 32
  ENDC
visible_pixels_number      EQU 320
visible_lines_number       EQU 240
MINROW                     EQU VSTART_240_LINES

  IFNE open_border_enabled 
pf_pixel_per_datafetch     EQU 16 ;1x
DDFSTRT_bits               EQU DDFSTART_320_pixel
DDFSTOP_bits               EQU DDFSTOP_STANDARD_MIN
  ENDC

display_window_hstart      EQU HSTART_40_CHUNKY_PIXEL
display_window_vstart      EQU MINROW
diwstrt_bits               EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
display_window_hstop       EQU HSTOP_320_pixel
display_window_vstop       EQU VSTOP_240_lines
diwstop_bits               EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)

  IFNE open_border_enabled 
pf1_plane_width            EQU pf1_x_size3/8
data_fetch_width           EQU pixel_per_line/8
pf1_plane_moduli           EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

bplcon0_bits               EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1              EQU 0
bplcon3_bits2              EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits               EQU 0
diwhigh_bits               EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)+DIWHIGHF_hstart1+DIWHIGHF_HSTOP1

cl2_display_x_size         EQU 320
cl2_display_width          EQU cl2_display_x_size/8
cl2_display_y_size         EQU visible_lines_number
  IFEQ open_border_enabled
cl2_hstart1                EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
  ELSE
cl2_hstart1                EQU display_window_hstart-4
  ENDC
cl2_vstart1                EQU MINROW
cl2_hstart2                EQU $00
cl2_vstart2                EQU beam_position&$ff

sine_table_length          EQU 256

; **** Blind-Colorcycle5.2.4.2 ****
bcc_5242_bar_height        EQU 64
bcc_5242_bars_number       EQU 4
bcc_5242_lamella_height    EQU 16
bcc_5242_lamellas_number   EQU visible_lines_number/bcc_5242_lamella_height
bcc_5242_step1             EQU 1
bcc_5242_step2_min         EQU 1
bcc_5242_step2_max         EQU 17
bcc_5242_step2             EQU bcc_5242_step2_max-bcc_5242_step2_min
bcc_5242_step2_radius      EQU bcc_5242_step2
bcc_5242_step2_center      EQU bcc_5242_step2+bcc_5242_step2_min
bcc_5242_step2_angle_speed EQU 2
bcc_5242_step2_angle_step  EQU 1
bcc_5242_step3             EQU 1
bcc_5242_speed             EQU 1

; **** Blind-Fader ****
bf_lamella_height          EQU 16
bf_lamellas_number         EQU visible_lines_number/bf_lamella_height
bf_step1                   EQU 1
bf_step2                   EQU 1
bf_speed                   EQU 2

bf_registers_table_length  EQU bf_lamella_height*4

; **** Effects-Handler ****
eh_trigger_number_max      EQU 3


color_step1                EQU 256/(bcc_5242_bar_height/2)
color_values_number1       EQU bcc_5242_bar_height/2
segments_number1           EQU bcc_5242_bars_number

ct_size1                   EQU color_values_number1*segments_number1

bcc_5242_switch_table_size EQU ct_size1*2

extra_memory_size          EQU bcc_5242_switch_table_size*BYTE_SIZE


; ## Makrobefehle ##
  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enthält **
  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enthält **
  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_size RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAIT       RS.L 1
  IFEQ open_border_enabled 
cl2_ext1_BPL1DAT    RS.L 1
  ENDC
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

cl2_extension1_size RS.B 0

  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_size*cl2_display_y_size

cl2_WAIT1            RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_size     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_size

cl2_size1          EQU 0
cl2_size2          EQU copperlist2_size
cl2_size3          EQU copperlist2_size


; ** Konstanten für die Größe der Spritestrukturen **
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
  INCLUDE "variables-offsets.i"

; **** Blind-Colorcycle ****
bcc_5242_switch_table_start RS.W 1
bcc_5242_step2_angle        RS.W 1

; **** Blind-Fader ****
  IFEQ open_border_enabled
bf_registers_table_start    RS.W 1

bfi_active                  RS.W 1

bfo_active                  RS.W 1
  ENDC

; **** Effects-Handler ****
eh_trigger_number           RS.W 1

; **** Main *****
fx_active                   RS.W 1

variables_size              RS.B 0


start_09_blind_colorcycle

  INCLUDE "sys-wrapper.i"

; ** Eigene Variablen initialisieren **
  CNOP 0,4
init_own_variables

; **** Blind-Colorcycle5.2.4.2 ****
  moveq   #0,d0
  move.w  d0,bcc_5242_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,bcc_5242_step2_angle(a3)
  moveq   #FALSE,d1

; **** Blind-Fader ****
  IFEQ open_border_enabled
    move.w  d0,bf_registers_table_start(a3)

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
  bsr.s   init_color_registers
  bsr     bcc5242_init_mirror_switch_table
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farbregister initialisieren **
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLOR_HIGH_BANK 0
  CPU_INIT_COLOR_HIGH COLOR00,32,pf1_color_table
  CPU_SELECT_COLOR_HIGH_BANK 1
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 2
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 3
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 4
  CPU_INIT_COLOR_HIGH COLOR00,1

  CPU_SELECT_COLOR_LOW_BANK 0
  CPU_INIT_COLOR_LOW COLOR00,32,pf1_color_table
  CPU_SELECT_COLOR_LOW_BANK 1
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 2
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 3
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 4
  CPU_INIT_COLOR_LOW COLOR00,1
  rts

; **** Blind-Colorcycle ****
; ** Referenz-Switchtabelle initialisieren **
  INIT_MIRROR_SWITCH_TABLE.B bcc5242,1,1,segments_number1,color_values_number1,extra_memory,a3


; ** 1. Copperliste initialisieren **
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  IFEQ open_border_enabled
    COP_MOVEQ TRUE,COPJMP2
    rts
  ELSE
    bsr.s   cl1_init_bitplane_pointers
    COP_MOVEQ TRUE,COPJMP2
    bra     cl1_set_bitplane_pointers
  ENDC

  IFEQ open_border_enabled
    COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES
  ELSE
    COP_INIT_PLAYFIELD_REGISTERS cl1
    COP_INIT_BITPLANE_POINTERS cl1
    COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
  ENDC

; ** 2. Copperliste initialisieren **
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0 
  bsr.s   cl2_init_bplcon4_registers
  bsr.s   cl2_init_copper_interrupt
  COP_LISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE,NOOP<<16

  COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2

  COPY_COPPERLIST cl2,2


; ## Hauptprogramm ##
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bsr.s   no_sync_routines
  bra.s   beam_routines


; ## Routinen, die nicht mit der Bildwiederholfrequenz gekoppelt sind ##
  CNOP 0,4
no_sync_routines
  rts


; ## Rasterstahl-Routinen ##
  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   swap_second_copperlist
  bsr     effects_handler
  bsr.s   blind_colorcycle5242
  IFEQ open_border_enabled
    bsr     blind_fader_in
    bsr     blind_fader_out
  ENDC
  jsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


; ** Copperlisten vertauschen **
  SWAP_COPPERLIST cl2,2


; ** Jalouse-Effekt **
  CNOP 0,4
blind_colorcycle5242
  movem.l a4-a6,-(a7)
  move.w  bcc_5242_step2_angle(a3),d3 ;Winkel 
  move.w  d3,d0              
  move.w  bcc_5242_switch_table_start(a3),d4 ;Startwert in Farbtabelle 
  addq.b  #bcc_5242_step2_angle_speed,d0 ;nächster Winkel
  move.w  d0,bcc_5242_step2_angle(a3) ;neuen Winkel retten
  move.w  d4,d0              
  addq.b  #bcc_5242_speed,d0      ;Startwert der Farbtabelle erhöhen
  move.w  d0,bcc_5242_switch_table_start(a3) 
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2,a2
  move.w  #cl2_extension1_size,a4
  lea     sine_table,a5      
  move.w  #bcc_5242_step2_center,a6
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten in CL
blind_colorcycle5242_loop1
  move.w  d4,d2              ;Startwert 
  move.l  a2,a1              
  moveq   #bcc_5242_lamellas_number-1,d6 ;Anzahl der Lamellen
blind_colorcycle5242_loop2
  move.w  d2,d1              ;Startwert 
  moveq   #bcc_5242_lamella_height-1,d5 ;Höhe der Lamelle
blind_colorcycle5242_loop3
  move.b  (a0,d1.w),(a1)     ;Switchwert in CL kopieren
  addq.b  #bcc_5242_step1,d1      ;nächster Wert aus Tabelle
  add.l   a4,a1              ;nächste Zeile in CL
  dbf     d5,blind_colorcycle5242_loop3
  move.l  (a5,d3.w*4),d0     ;cos(w)
  MULUF.L bcc_5242_step2_radius*2,d0 ;r'=r*cow(w)/2^15
  swap    d0
  add.w   a6,d0              ;+ Mittelpunkt
  subq.b  #bcc_5242_step2_angle_step,d3
  add.b   d0,d2              ;Startwert erhöhen
  dbf     d6,blind_colorcycle5242_loop2
  addq.b  #bcc_5242_step3,d4      ;Startwert erhöhen
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,blind_colorcycle5242_loop1
  movem.l (a7)+,a4-a6
  rts


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
    MOVEF.W cl2_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl2_size1
      move.l  cl2_construction1(a3),a1 ;1. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
    ENDC
    IFNE cl2_size2
      move.l  cl2_construction2(a3),a2 ;2. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
    ENDC
    move.l  cl2_display(a3),a4 ;3. CL
    ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_in_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_in_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl2_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl2_size2
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
    MOVEF.W cl2_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl2_size1
      move.l  cl2_construction1(a3),a1 ;1. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
    ENDC
    IFNE cl2_size2
      move.l  cl2_construction2(a3),a2 ;2. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
    ENDC
    move.l  cl2_display(a3),a4 ;3. CL
    ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_out_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_out_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl2_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl2_size2
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
  clr.w   fx_active(a3)      ;Effekt beenden
  rts


; ## Interrupt-Routinen ##
  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
  CNOP 0,4
NMI_int_server
  rts


; ## Hilfsroutinen ##
  INCLUDE "help-routines.i"


; ## Speicherstellen für Tabellen und Strukturen ##
  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
  CNOP 0,4
pf1_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/0a_bcc5242_Colorgradient.ct"

; **** Blind-Fader ****
  IFEQ open_border_enabled
; ** Tabelle mit Registeradressen **
  CNOP 0,2
bf_registers_table
    REPT bf_registers_table_length/2
      DC.W NOOP
    ENDR
    REPT bf_registers_table_length/2
      DC.W BPL1DAT
    ENDR
  ENDC


; ## Speicherstellen allgemein ##
  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
  INCLUDE "error-texts.i"

  END
