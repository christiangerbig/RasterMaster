; #####################################
; # Programm: 06_Blind-Colorcycle.asm #
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

  XREF COLOR00BITS
  XREF mouse_handler
  XREF sine_table


  XDEF start_06_blind_colorcycle


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
pass_global_references
pass_return_code
open_border                    EQU TRUE

bcc512_switch_table_length_256 EQU TRUE
bcc514_switch_table_length_256 EQU TRUE

  IFEQ open_border
DMABITS                        EQU DMAF_COPPER+DMAF_SETCLR
  ELSE
DMABITS                        EQU DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
  ENDC
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
  IFEQ open_border
pf1_x_size3                    EQU 0
pf1_y_size3                    EQU 0
pf1_depth3                     EQU 0
  ELSE
pf1_x_size3                    EQU 32
pf1_y_size3                    EQU 1
pf1_depth3                     EQU 1
  ENDC
pf1_colors_number              EQU 0 ;129

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

extra_pf_number                EQU 0

spr_number                     EQU 0
spr_x_size1                    EQU 0
spr_y_size1                    EQU 0
spr_x_size2                    EQU 0
spr_y_size2                    EQU 0
spr_depth                      EQU 0
spr_colors_number              EQU 0

audio_memory_size              EQU 0

disk_memory_size               EQU 0

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

  IFNE open_border 
pixel_per_line                 EQU 32
  ENDC
visible_pixels_number          EQU 352
visible_lines_number           EQU 256
MINROW                         EQU VSTART_256_lines

  IFNE open_border 
pf_pixel_per_datafetch         EQU 32 ;2x
DDFSTRTBITS                    EQU DDFSTART_overscan_32_pixel
DDFSTOPBITS                    EQU DDFSTOP_overscan_32_pixel_min
  ENDC

display_window_HSTART          EQU HSTART_44_chunky_pixel
display_window_VSTART          EQU MINROW
DIWSTRTBITS                    EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP           EQU HSTOP_44_chunky_pixel
display_window_VSTOP           EQU VSTOP_256_lines
DIWSTOPBITS                    EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

  IFNE open_border 
pf1_plane_width                EQU pf1_x_size3/8
data_fetch_width               EQU pixel_per_line/8
pf1_plane_moduli               EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

BPLCON0BITS                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
;BPLCON1BITS                    EQU TRUE
;BPLCON2BITS                    EQU TRUE
BPLCON3BITS1                   EQU TRUE
BPLCON3BITS2                   EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                    EQU TRUE
DIWHIGHBITS                    EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
;FMODEBITS                      EQU TRUE

cl2_display_x_size             EQU 352
cl2_display_width              EQU cl2_display_x_size/8
cl2_display_y_size             EQU visible_lines_number
  IFEQ open_border
cl2_HSTART1                    EQU display_window_HSTART-(1*CMOVE_slot_period)-4
  ELSE
cl2_HSTART1                    EQU display_window_HSTART-4
  ENDC
cl2_VSTART1                    EQU MINROW
cl2_HSTART2                    EQU $00
cl2_VSTART2                    EQU beam_position&$ff

sine_table_length              EQU 256

; **** Blind-Colorcycle5.1.2 ****
bcc512_bar_height              EQU 64
bcc512_bars_number             EQU 4
bcc512_lamella_height          EQU 16
bcc512_lamellas_number         EQU visible_lines_number/bcc512_lamella_height
bcc512_step1                   EQU 1
bcc512_step2                   EQU 1
bcc512_step3_min               EQU 1
bcc512_step3_max               EQU 16
bcc512_step3                   EQU bcc512_step3_max-bcc512_step3_min
bcc512_step3_radius            EQU bcc512_step3
bcc512_step3_center            EQU bcc512_step3+bcc512_step3_min
bcc512_step3_angle_speed       EQU 2
bcc512_speed                   EQU 1

; **** Blind-Colorcycle5.1.4 ****
bcc514_bar_height              EQU 64
bcc514_bars_number             EQU 4
bcc514_lamella_height          EQU 16
bcc514_lamellas_number         EQU visible_lines_number/bcc514_lamella_height
bcc514_step1                   EQU 2
bcc514_step2_min               EQU 0
bcc514_step2_max               EQU 8
bcc514_step2                   EQU bcc514_step2_max-bcc514_step2_min
bcc514_step2_radius            EQU bcc514_step2
bcc514_step2_center            EQU bcc514_step2+bcc514_step2_min
bcc514_step2_angle_speed       EQU 1
bcc514_step2_angle_step        EQU 4
bcc514_speed                   EQU 2

; **** Blind-Fader ****
bf_lamella_height              EQU 16
bf_lamellas_number             EQU visible_lines_number/bf_lamella_height
bf_step1                       EQU 1
bf_step2                       EQU 1
bf_speed                       EQU 2

bf_registers_table_length      EQU bf_lamella_height*4

; **** Effects-Handler ****
eh_trigger_number_max          EQU 5


color_step1                    EQU 256/(bcc512_bar_height/2)
color_values_number1           EQU bcc512_bar_height/2
segments_number1               EQU bcc512_bars_number

ct_size1                       EQU color_values_number1*segments_number1

bcc_switch_table_size          EQU ct_size1*2

extra_memory_size              EQU bcc_switch_table_size*BYTESIZE


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
  IFEQ open_border 
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
cl2_ext1_BPLCON4_41 RS.L 1
cl2_ext1_BPLCON4_42 RS.L 1
cl2_ext1_BPLCON4_43 RS.L 1
cl2_ext1_BPLCON4_44 RS.L 1

cl2_extension1_SIZE RS.B 0

  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_SIZE*cl2_display_y_size

cl2_WAIT1            RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1              EQU 0
cl1_size2              EQU 0
cl1_size3              EQU copperlist1_SIZE

cl2_size1              EQU 0
cl2_size2              EQU copperlist2_SIZE
cl2_size3              EQU copperlist2_SIZE


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1           EQU spr_x_size1
spr0_y_size1           EQU 0
spr1_x_size1           EQU spr_x_size1
spr1_y_size1           EQU 0
spr2_x_size1           EQU spr_x_size1
spr2_y_size1           EQU 0
spr3_x_size1           EQU spr_x_size1
spr3_y_size1           EQU 0
spr4_x_size1           EQU spr_x_size1
spr4_y_size1           EQU 0
spr5_x_size1           EQU spr_x_size1
spr5_y_size1           EQU 0
spr6_x_size1           EQU spr_x_size1
spr6_y_size1           EQU 0
spr7_x_size1           EQU spr_x_size1
spr7_y_size1           EQU 0

spr0_x_size2           EQU spr_x_size2
spr0_y_size2           EQU 0
spr1_x_size2           EQU spr_x_size2
spr1_y_size2           EQU 0
spr2_x_size2           EQU spr_x_size2
spr2_y_size2           EQU 0
spr3_x_size2           EQU spr_x_size2
spr3_y_size2           EQU 0
spr4_x_size2           EQU spr_x_size2
spr4_y_size2           EQU 0
spr5_x_size2           EQU spr_x_size2
spr5_y_size2           EQU 0
spr6_x_size2           EQU spr_x_size2
spr6_y_size2           EQU 0
spr7_x_size2           EQU spr_x_size2
spr7_y_size2           EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                   RS.L 1

; **** Blind-Colorcycle5.1.2 ****
bcc512_state              RS.W 1
bcc512_switch_table_start RS.W 1
bcc512_step3_angle        RS.W 1

; **** Blind-Colorcycle5.1.4 ****
bcc514_state              RS.W 1
bcc514_switch_table_start RS.W 1
bcc514_step2_angle        RS.W 1

; **** Blind-Fader ****
  IFEQ open_border
bf_registers_table_start  RS.W 1

bfi_state                 RS.W 1

bfo_state                 RS.W 1
  ENDC

; **** Effects-Handler ****
eh_trigger_number         RS.W 1

; **** Main ****
fx_state                  RS.W 1

variables_SIZE            RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_06_blind_colorcycle
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Blind-Colorcycle5.1.2 ****
  moveq   #FALSE,d1
  move.w  d1,bcc512_state(a3)
  moveq   #TRUE,d0
  move.w  d0,bcc512_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,bcc512_step3_angle(a3)

; **** Blind-Colorcycle5.1.4 ****
  move.w  d1,bcc514_state(a3)
  move.w  d0,bcc514_switch_table_start(a3)
  move.w  d0,bcc514_step2_angle(a3)

; **** Blind-Fader ****
  IFEQ open_border
    move.w  d0,bf_registers_table_start(a3)

    move.w  d1,bfi_state(a3)

    move.w  d1,bfo_state(a3)
  ENDC

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr     init_color_registers
  bsr     bcc_init_mirror_switch_table
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
  CPU_INIT_COLORHI COLOR00,1

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,32,pf1_color_table
  CPU_SELECT_COLORLO_BANK 1
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 2
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 3
  CPU_INIT_COLORLO COLOR00,32
  CPU_SELECT_COLORLO_BANK 4
  CPU_INIT_COLORLO COLOR00,1
  rts

; **** Blind-Colorcycle ****
; ** Referenz-Switchtabelle initialisieren **
; -------------------------------------------
  INIT_MIRROR_SWITCH_TABLE.B bcc,1,1,segments_number1,color_values_number1,extra_memory,a3


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  IFEQ open_border
    COPMOVEQ TRUE,COPJMP2
    rts
  ELSE
    bsr.s   cl1_init_bitplane_pointers
    COPMOVEQ TRUE,COPJMP2
    bra     cl1_set_bitplane_pointers
  ENDC

  IFEQ open_border
    COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES
  ELSE
    COP_INIT_PLAYFIELD_REGISTERS cl1
    COP_INIT_BITPLANE_POINTERS cl1
    COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
  ENDC

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

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_HSTART1,cl2_VSTART1,cl2_display_x_size,cl2_display_y_size,open_border,FALSE,FALSE,NOOP<<16

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
  bsr     blind_colorcycle512
  bsr     blind_colorcycle514
  IFEQ open_border
    bsr     blind_fader_in
    bsr     blind_fader_out
  ENDC
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


; ** Jalouse-Effekt **
; --------------------
  CNOP 0,4
blind_colorcycle512
  tst.w   bcc512_state(a3)
  bne     no_blind_colorcycle512
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  bcc512_step3_angle(a3),d1 ;Winkel 
  move.w  d1,d0              
  addq.b  #bcc512_step3_angle_speed,d0 ;nächster Winkel
  move.w  d0,bcc512_step3_angle(a3) ;neuen Winkel retten
  lea     sine_table,a0      
  move.l  (a0,d1.w*4),d4     ;cos(w)
  MULUF.L bcc512_step3_radius*2,d4,d0 ;r'=r*cow(w)/2^15
  swap    d4
  ADDF.W  bcc512_step3_center,d4 ;+ Mittelpunkt
  move.w  bcc512_switch_table_start(a3),d3 ;Startwert in Farbtabelle 
  move.w  d3,d0              
  IFEQ bcc512_switch_table_length_256
    addq.b  #bcc512_speed,d0
  ELSE
    MOVEF.W bcc512_switch_table_size-1,d7 ;Anzahl der Einträge
    addq.w  #bcc512_speed,d0    ;Startwert der Farbtabelle erhöhen
    and.w   d7,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,bcc512_switch_table_start(a3) 
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  move.w  #(cl2_extension1_SIZE*(bcc512_lamellas_number/2)*bcc512_lamella_height)-4,a3
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(bcc512_lamellas_number/2)*bcc512_lamella_height)+4,a7
  IFEQ bcc512_switch_table_length_256
    moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
  ELSE
    swap    d7
    move.w  #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
  ENDC
blind_colorcycle512_loop1
  move.w  d3,d2              ;Startwert 
  IFNE bcc512_switch_table_length_256
    swap    d7               
  ENDC
  moveq   #(bcc512_lamellas_number/2)-1,d6 ;Anzahl der Lamellen
blind_colorcycle512_loop2
  move.w  d2,d1              ;Startwert 
  moveq   #bcc512_lamella_height-1,d5 ;Höhe einer Lamelle
blind_colorcycle512_loop3
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  IFEQ bcc512_switch_table_length_256
    subq.b  #bcc512_step1,d1    ;nächster Wert aus Tabelle
  ELSE
    subq.w  #bcc512_step1,d1    ;nächster Wert aus Tabelle
    and.w   d7,d1            ;Überlauf entfernen
  ENDC
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  dbf     d5,blind_colorcycle512_loop3
  IFEQ bcc512_switch_table_length_256
    subq.b  #bcc512_step2,d2    ;nächster Wert aus Tabelle
  ELSE
    subq.w  #bcc512_step2,d2    ;nächster Wert aus Tabelle
    and.w   d7,d2            ;Überlauf entfernen
  ENDC
  dbf     d6,blind_colorcycle512_loop2
  IFEQ bcc512_switch_table_length_256
    sub.b   d4,d3            ;nächster Wert aus Tabelle
  ELSE
    sub.w   d4,d3            ;nächster Wert aus Tabelle
    and.w   d7,d3            ;Überlauf entfernen
    swap    d7
  ENDC
  add.l   a3,a1              ;2. Quadrant vorletzte Spalte
  add.l   a7,a2              ;1. Quadrant nächste Spalte
  sub.l   a7,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a3,a5              ;4. Quadrant nächste Spalte
  dbf     d7,blind_colorcycle512_loop1
  move.l  variables+save_a7(pc),a7
  movem.l (a7)+,a3-a6
no_blind_colorcycle512
  rts

; ** Jalouse-Effekt **
; --------------------
  CNOP 0,4
blind_colorcycle514
  tst.w   bcc514_state(a3)
  bne     no_blind_colorcycle514
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  bcc514_step2_angle(a3),d4
  move.w  d4,d0
  move.w  bcc514_switch_table_start(a3),d3 ;Startwert in Farbtabelle 
  addq.b  #bcc514_step2_angle_speed,d0
  move.w  d0,bcc514_step2_angle(a3)
  move.w  d3,d0              
  IFEQ bcc514_switch_table_length_256
    addq.b  #bcc514_speed,d0
  ELSE
    MOVEF.W bcc514_switch_table_size-1,d7 ;Anzahl der Einträge
    addq.w  #bcc514_speed,d0    ;Startwert der Farbtabelle erhöhen
    and.w   d7,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,bcc514_switch_table_start(a3) 
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table,a3
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(bcc514_lamellas_number/2)*bcc514_lamella_height)+4,a7
  IFEQ bcc514_switch_table_length_256
    moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
  ELSE
    swap    d7
    move.w  #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
  ENDC
blind_colorcycle514_loop1
  move.w  d3,d2              ;Startwert 
  IFNE bcc514_switch_table_length_256
    swap d7
  ENDC
  moveq   #(bcc514_lamellas_number/2)-1,d6 ;Anzahl der Lamellen
blind_colorcycle514_loop2
  move.w  d2,d1              ;Startwert 
  moveq   #bcc514_lamella_height-1,d5 ;Höhe einer Lamelle
blind_colorcycle514_loop3
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  IFEQ bcc514_switch_table_length_256
    subq.b  #bcc514_step1,d1    ;nächster Wert aus Tabelle
  ELSE
    subq.w  #bcc514_step1,d1    ;nächster Wert aus Tabelle
    and.w   d7,d1            ;Überlauf entfernen
  ENDC
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  dbf     d5,blind_colorcycle514_loop3
  IFEQ bcc514_switch_table_length_256
    subq.b  #bcc514_step1,d2    ;nächster Wert aus Tabelle
  ELSE
    subq.w  #bcc514_step1,d2    ;nächster Wert aus Tabelle
    and.w   d7,d2            ;Überlauf entfernen
  ENDC
  dbf     d6,blind_colorcycle514_loop2
  move.l  (a3,d4.w*4),d0
  MULUF.L bcc514_step2_radius*2,d0
  swap    d0
  addq.b  #bcc514_step2_angle_step,d4
  add.w   #bcc514_step2_center,d0
  IFEQ bcc514_switch_table_length_256
    sub.b   d0,d3            ;nächster Wert aus Tabelle
  ELSE
    sub.w   d0,d3            ;nächster Wert aus Tabelle
    and.w   d7,d3            ;Überlauf entfernen
    swap    d7
  ENDC
  ADDF.W  (cl2_extension1_SIZE*(bcc514_lamellas_number/2)*bcc514_lamella_height)-4,a1              ;2. Quadrant vorletzte Spalte
  add.l   a7,a2              ;1. Quadrant nächste Spalte
  sub.l   a7,a4              ;3. Quadrant vorletzte Spalte
  SUBF.W  (cl2_extension1_SIZE*(bcc514_lamellas_number/2)*bcc514_lamella_height)-4,a5              ;4. Quadrant nächste Spalte
  dbf     d7,blind_colorcycle514_loop1
  move.l  variables+save_a7(pc),a7
  movem.l (a7)+,a3-a6
no_blind_colorcycle514
  rts


  IFEQ open_border
; ** Blind-Fader-In **
; --------------------
    CNOP 0,4
blind_fader_in
    tst.w   bfi_state(a3)    ;Blind-Fader-In an ?
    bne.s   no_blind_fader_in ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Registeradresse 
    move.w  d2,d0            
    addq.w  #bf_speed,d0     ;Startwert der Tabelle erhöhen
    cmp.w   #bf_registers_table_length/2,d0 ;Ende der Tabelle erreicht ?
    ble.s   bf_no_restart_registers_table ;Nein -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfi_state(a3) ;Blind-Fader-In aus
bf_no_restart_registers_table
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl2_extension1_SIZE,d4
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
; ---------------------
    CNOP 0,4
blind_fader_out
    tst.w   bfo_state(a3)    ;Blind-Fader-Out an ?
    bne.s   no_blind_fader_out ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Startwert der Tabelle 
    move.w  d2,d0            
    subq.w  #bf_speed,d0     ;Startwert der Tabelle verringern
    bpl.s   bfo_no_restart_registers_table ;Wenn positiv -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfo_state(a3) ;Blind-Fader-Out aus
bfo_no_restart_registers_table
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl2_extension1_SIZE,d4
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
  beq.s   eh_start_blind_colorscroll512
  subq.w  #1,d0
  beq.s   eh_stop_blind_colorscroll512
  subq.w  #1,d0
  beq.s   eh_start_blind_colorscroll514
  subq.w  #1,d0
  beq.s   eh_stop_blind_colorscroll514
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_blind_colorscroll512
  moveq   #TRUE,d0
  move.w  d0,bcc512_state(a3) ;Blind-Colorscroll5.1.2 an
  move.w  d0,bfi_state(a3)   ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_blind_colorscroll512
  clr.w   bfo_state(a3)      ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_start_blind_colorscroll514
  moveq   #FALSE,d0
  move.w  d0,bcc512_state(a3) ;Blind-Colorscroll5.1.2 aus
  moveq   #TRUE,d0
  move.w  d0,bcc514_state(a3) ;Blind-Colorscroll5.1.4 an
  move.w  d0,bfi_state(a3)   ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_blind_colorscroll514
  clr.w   bfo_state(a3)      ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_state(a3)       ;Alle Effekte beendet
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
  INCLUDE "Daten:Asm-Sources.AGA/RasterMaster/colortables/07_bcc512_Colorgradient.ct"

; **** Blind-Fader ****
  IFEQ open_border
; ** Tabelle mit Registeradressen **
; ----------------------------------
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
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

  END
