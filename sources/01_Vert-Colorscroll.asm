; #####################################
; # Programm: 01_Vert-Colorscroll.asm #
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


  XDEF start_01_vert_colorscroll


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

requires_68030                  EQU FALSE  
requires_68040                  EQU FALSE
requires_68060                  EQU FALSE
requires_fast_memory            EQU FALSE
requires_multiscan_monitor      EQU FALSE

workbench_start_enabled         EQU FALSE
workbench_fade_enabled          EQU FALSE
text_output_enabled             EQU FALSE

sys_taken_over
pass_global_references
pass_return_code
open_border_enabled             EQU TRUE

vcs3112_switch_table_length_256 EQU TRUE
vcs3121_switch_table_length_256 EQU TRUE
vcs3122_switch_table_length_256 EQU TRUE
vcs3111_switch_table_length_256 EQU TRUE

  IFEQ open_border_enabled
DMABITS                         EQU DMAF_COPPER+DMAF_SETCLR
  ELSE
DMABITS                         EQU DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
  ENDC
INTENABITS                      EQU INTF_SETCLR

CIAAICRBITS                     EQU CIAICRF_SETCLR
CIABICRBITS                     EQU CIAICRF_SETCLR

COPCONBITS                      EQU 0

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
pf1_colors_number               EQU 0 ;256

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

AGA_OS_Version                  EQU 39

CIAA_TA_time                    EQU 0
CIAA_TB_time                    EQU 0
CIAB_TA_time                    EQU 0
CIAB_TB_time                    EQU 0
CIAA_TA_continuous_enabled      EQU FALSE
CIAA_TB_continuous_enabled      EQU FALSE
CIAB_TA_continuous_enabled      EQU FALSE
CIAB_TB_continuous_enabled      EQU FALSE

beam_position                   EQU $136

  IFNE open_border_enabled 
pixel_per_line                  EQU 32
  ENDC
visible_pixels_number           EQU 352
visible_lines_number            EQU 280
MINROW                          EQU VSTART_overscan_PAL

  IFNE open_border_enabled 
pf_pixel_per_datafetch          EQU 16 ;1x
DDFSTRTBITS                     EQU DDFSTART_overscan_32_pixel
DDFSTOPBITS                     EQU DDFSTOP_overscan_32_pixel_min
  ENDC

display_window_HSTART           EQU HSTART_44_chunky_pixel
display_window_VSTART           EQU MINROW
DIWSTRTBITS                     EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP            EQU HSTOP_44_chunky_pixel
display_window_VSTOP            EQU MINROW+visible_lines_number
DIWSTOPBITS                     EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

  IFNE open_border_enabled 
pf1_plane_width                 EQU pf1_x_size3/8
data_fetch_width                EQU pixel_per_line/8
pf1_plane_moduli                EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

BPLCON0BITS                     EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1                    EQU 0
BPLCON3BITS2                    EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                     EQU 0
DIWHIGHBITS                     EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)

cl2_display_x_size              EQU 352
cl2_display_width               EQU cl2_display_x_size/8
cl2_display_y_size              EQU visible_lines_number
  IFEQ open_border_enabled
cl2_HSTART1                     EQU display_window_HSTART-(1*CMOVE_slot_period)-4
  ELSE
cl2_HSTART1                     EQU display_window_HSTART-4
  ENDC
cl2_VSTART1                     EQU MINROW
cl2_HSTART2                     EQU $00
cl2_VSTART2                     EQU beam_position&$ff

sine_table_length               EQU 256

; **** Vert-Colorscroll3.1.1.2 ****
vcs3112_bar_height              EQU 128
vcs3112_bars_number             EQU 2
vcs3112_step1_min               EQU 1
vcs3112_step1_max               EQU 2
vcs3112_step1                   EQU vcs3112_step1_max-vcs3112_step1_min
vcs3112_step1_radius            EQU vcs3112_step1
vcs3112_step1_center            EQU vcs3112_step1+vcs3112_step1_min
vcs3112_step1_angle_speed       EQU 1
vcs3112_step1_angle_step        EQU 1
vcs3112_step2                   EQU 5
vcs3112_speed                   EQU 2

; **** Vert-Colorscroll3.1.2.1 ****
vcs3121_bar_height              EQU 128
vcs3121_bars_number             EQU 2
vcs3121_step1_min               EQU 0
vcs3121_step1_max               EQU 1
vcs3121_step1                   EQU vcs3121_step1_max-vcs3121_step1_min
vcs3121_step1_radius            EQU vcs3121_step1
vcs3121_step1_center            EQU vcs3121_step1+vcs3121_step1_min
vcs3121_step1_angle_speed       EQU 2
vcs3121_step1_angle_step        EQU 5
vcs3121_step2                   EQU 4
vcs3121_speed                   EQU 2

; **** Vert-Colorscroll3.1.2.2 ****
vcs3122_bar_height              EQU 128
vcs3122_bars_number             EQU 2
vcs3122_step1                   EQU 1
vcs3122_step2_min               EQU 0
vcs3122_step2_max               EQU 4
vcs3122_step2                   EQU vcs3122_step2_max-vcs3122_step2_min
vcs3122_step2_radius            EQU vcs3122_step2
vcs3122_step2_center            EQU vcs3122_step2+vcs3122_step2_min
vcs3122_step2_angle_speed       EQU 2
vcs3122_step2_angle_step        EQU 1
vcs3122_speed                   EQU 2

; **** Vert-Colorscroll3.1.1.1 ****
vcs3111_bar_height              EQU 128
vcs3111_bars_number             EQU 2
vcs3111_step1                   EQU 1
vcs3111_step2_min               EQU 5
vcs3111_step2_max               EQU 13
vcs3111_step2                   EQU vcs3111_step2_max-vcs3111_step2_min
vcs3111_step2_radius            EQU vcs3111_step2
vcs3111_step2_center            EQU vcs3111_step2+vcs3111_step2_min
vcs3111_step2_angle_speed       EQU 2
vcs3111_step2_angle_step        EQU 6
vcs3111_speed                   EQU 4

; **** Blind-Fader ****
bf_lamella_height               EQU 14
bf_lamellas_number              EQU visible_lines_number/bf_lamella_height
bf_step1                        EQU 1
bf_step2                        EQU 1
bf_speed                        EQU 2

bf_registers_table_length       EQU bf_lamella_height*6

; **** Effects-Handler ****
eh_trigger_number_max           EQU 9


color_step1                     EQU 256/(vcs3112_bar_height/2)
color_values_number1            EQU vcs3112_bar_height/2
segments_number1                EQU vcs3112_bars_number*2

ct_size1                        EQU color_values_number1*segments_number1

vcs_switch_table_size           EQU ct_size1

extra_memory_size               EQU vcs_switch_table_size*BYTESIZE


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** CIA-ICR-Register-Bits-Namen **
; ---------------------------------
; CIAICR_TA
; CIAICR_TB
; CIAICR_ALRM
; CIAICR_SP
; CIAICR_FLG
; CIAICR_IR
; CIAICR_SETCLR


; ** DMACON-Register-Bits-Namen **
; --------------------------------
; DMA_SETCLR
; DMA_AUDIO (alle 4 Audio-Kanäle)
; DMA_AUD0
; DMA_AUD1
; DMA_AUD2
; DMA_AUD3
; DMA_DISK
; DMA_SPRITE
; DMA_BLITTER
; DMA_COPPER
; DMA_RASTER
; DMA_MASTER
; DMA_BLITHOG
; DMA_ALL (alle DMA-Kanäle)


; ** INTENA-Register-Bits-Namen **
; --------------------------------
; INT_SETCLR
; INT_INTEN
; INT_EXTER
; INT_DSKSYNC
; INT_RBF
; INT_AUD3
; INT_AUD2
; INT_AUD1
; INT_AUD0
; INT_BLIT
; INT_VERTB
; INT_COPER
; INT_PORTS
; INT_SOFTINT
; INT_DSKBLK
; INT_TBE


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
cl2_ext1_BPLCON4_41 RS.L 1
cl2_ext1_BPLCON4_42 RS.L 1
cl2_ext1_BPLCON4_43 RS.L 1
cl2_ext1_BPLCON4_44 RS.L 1

cl2_extension1_SIZE RS.B 0

  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_SIZE*cl2_display_y_size

cl2_WAIT             RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1               EQU 0
cl1_size2               EQU 0
cl1_size3               EQU copperlist1_SIZE

cl2_size1               EQU 0
cl2_size2               EQU copperlist2_SIZE
cl2_size3               EQU copperlist2_SIZE


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1            EQU spr_x_size1
spr0_y_size1            EQU 0
spr1_x_size1            EQU spr_x_size1
spr1_y_size1            EQU 0
spr2_x_size1            EQU spr_x_size1
spr2_y_size1            EQU 0
spr3_x_size1            EQU spr_x_size1
spr3_y_size1            EQU 0
spr4_x_size1            EQU spr_x_size1
spr4_y_size1            EQU 0
spr5_x_size1            EQU spr_x_size1
spr5_y_size1            EQU 0
spr6_x_size1            EQU spr_x_size1
spr6_y_size1            EQU 0
spr7_x_size1            EQU spr_x_size1
spr7_y_size1            EQU 0

spr0_x_size2            EQU spr_x_size2
spr0_y_size2            EQU 0
spr1_x_size2            EQU spr_x_size2
spr1_y_size2            EQU 0
spr2_x_size2            EQU spr_x_size2
spr2_y_size2            EQU 0
spr3_x_size2            EQU spr_x_size2
spr3_y_size2            EQU 0
spr4_x_size2            EQU spr_x_size2
spr4_y_size2            EQU 0
spr5_x_size2            EQU spr_x_size2
spr5_y_size2            EQU 0
spr6_x_size2            EQU spr_x_size2
spr6_y_size2            EQU 0
spr7_x_size2            EQU spr_x_size2
spr7_y_size2            EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                    RS.L 1

; **** Vert-Colorscroll3.1.1.2 ****
vcs3112_active             RS.W 1
vcs3112_switch_table_start RS.W 1
vcs3112_step1_angle        RS.W 1

; **** Vert-Colorscroll3.1.2.1 ****
vcs3121_active             RS.W 1
vcs3121_switch_table_start RS.W 1
vcs3121_step1_angle        RS.W 1

; **** Vert-Colorscroll3.1.2.2 ****
vcs3122_active             RS.W 1
vcs3122_switch_table_start RS.W 1
vcs3122_step2_angle        RS.W 1

; **** Vert-Colorscroll3.1.1.1 ****
vcs3111_active             RS.W 1
vcs3111_switch_table_start RS.W 1
vcs3111_step2_angle        RS.W 1

; **** Blind-Fader ****
  IFEQ open_border_enabled
bf_registers_table_start   RS.W 1

bfi_active                 RS.W 1

bfo_active                 RS.W 1
  ENDC

; **** Effects-Handler ****
eh_trigger_number          RS.W 1

; **** Main ****
fx_active                  RS.W 1

variables_SIZE             RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_01_vert_colorscroll
  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Vert-Colorscroll3.1.1.2 ****
  moveq   #FALSE,d1
  move.w  d1,vcs3112_active(a3)
  moveq   #0,d0
  move.w  d0,vcs3112_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,vcs3112_step1_angle(a3)

; **** Vert-Colorscroll3.1.2.1 ****
  move.w  d1,vcs3121_active(a3)
  move.w  d0,vcs3121_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,vcs3121_step1_angle(a3)

; **** Vert-Colorscroll3.1.2.2 ****
  move.w  d1,vcs3122_active(a3)
  move.w  d0,vcs3122_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,vcs3122_step2_angle(a3)

; **** Vert-Colorscroll3.1.1.1 ****
  move.w  d1,vcs3111_active(a3)
  move.w  d0,vcs3111_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,vcs3111_step2_angle(a3)

; **** Blind-Fader ****
  IFEQ open_border_enabled
    move.w  d0,bf_registers_table_start(a3)

    move.w  d1,bfi_active(a3)

    move.w  d1,bfo_active(a3)
  ENDC

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr     init_color_registers
  bsr     vcs_init_switch_table
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

; **** Vert-Colorscroll ****
; ** Referenz-Switchtabelle initialisieren **
; -------------------------------------------
  INIT_SWITCH_TABLE.B vcs,0,1,color_values_number1*segments_number1,extra_memory,a3


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  IFEQ open_border_enabled
    COPMOVEQ TRUE,COPJMP2
    rts
  ELSE
    bsr.s   cl1_init_bitplane_pointers
    COPMOVEQ TRUE,COPJMP2
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
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0 ;Aufbau-CL
  bsr.s   cl2_init_BPLCON4_registers
  bsr.s   cl2_init_copint
  COPLISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_HSTART1,cl2_VSTART1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE,NOOP<<16

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
  bsr     vert_colorscroll3112
  bsr     vert_colorscroll3121
  bsr     vert_colorscroll3122
  bsr     vert_colorscroll3111
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


; ** Copperlisten vertauschen **
; ------------------------------
  SWAP_COPPERLIST cl2,2


; ** Vert-Colorscroll3.1.1.2 **
; -----------------------------
  CNOP 0,4
vert_colorscroll3112
  tst.w   vcs3112_active(a3) ;Vert-Colorscroll3.1.1.2 an ?
  bne     no_vert_colorscroll3112 ;Nein -> verzweige
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  vcs3112_switch_table_start(a3),d2 ;Startwert in Farbtabelle 
  move.w  d2,d0              
  move.w  vcs3112_step1_angle(a3),d4 ;Y-Step-Winkel 
  IFEQ vcs3112_switch_table_length_256
    addq.b  #vcs3112_speed,d0 ;Startwert der Switchtabelle erhöhen
  ELSE
    MOVEF.W vcs3112_switch_table_size-1,d3 ;Anzahl der Einträge
    addq.w  #vcs3112_speed,d0 ;Startwert der Farbtabelle erhöhen
    and.w   d3,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,vcs3112_switch_table_start(a3) 
  move.w  d4,d0              
  addq.b  #vcs3112_step1_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,vcs3112_step1_angle(a3) 
  MOVEF.L (cl2_extension1_SIZE*(cl2_display_y_size/2))+4,d5
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table(pc),a3 
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(cl2_display_y_size/2))-4,a7
  moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
vert_colorscroll3112_loop1
  move.w  d2,d1              ;Startwert 
  MOVEF.W (cl2_display_y_size/2)-1,d6 ;Effekt für x Zeilen
vert_colorscroll3112_loop2
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  move.l  (a3,d4.w*4),d0     ;sin(w)
  MULUF.L vcs3112_step1_radius*2,d0 ;y'=(yr*sin(w))/2^15
  addq.b  #vcs3112_step1_angle_step,d4 ;nächster Y-Winkel
  swap    d0
  add.w   #vcs3112_step1_center,d0 ;+ Y-Mittelpunkt
  IFEQ vcs3112_switch_table_length_256
    sub.b   d0,d1            ;nächster Wert aus Tabelle
  ELSE
    sub.w   d0,d1            ;nächster Wert aus Tabelle
    and.w   d3,d1            ;Überlauf entfernen
  ENDC
  dbf     d6,vert_colorscroll3112_loop2
  IFEQ vcs3112_switch_table_length_256
    subq.b  #vcs3112_step2,d2 ;Startwert verringern
  ELSE
    subq.w  #vcs3112_step2,d2 ;Startwert verringern
    and.w   d3,d2            ;Überlauf entfernen
  ENDC
  add.l   a7,a1              ;2. Quadrant vorletzte Spalte
  add.l   d5,a2              ;1. Quadrant nächste Spalte
  sub.l   d5,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a7,a5              ;4. Quadrant nächste Spalte
  dbf     d7,vert_colorscroll3112_loop1
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
no_vert_colorscroll3112
  rts

; ** Vert-Colorscroll3.1.2.1 **
; -----------------------------
  CNOP 0,4
vert_colorscroll3121
  tst.w   vcs3121_active(a3) ;Vert-Colorscroll3.1.2.1 an ?
  bne     no_vert_colorscroll3121 ;Nein -> verzweige
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  vcs3121_switch_table_start(a3),d2 ;Startwert in Farbtabelle 
  move.w  d2,d0              
  move.w  vcs3121_step1_angle(a3),d4 ;Y-Step-Winkel 
  IFEQ vcs3121_switch_table_length_256
    addq.b  #vcs3121_speed,d0 ;Startwert der Switchtabelle erhöhen
  ELSE
    MOVEF.W vcs3121_switch_table_size-1,d3 ;Anzahl der Einträge
    addq.w  #vcs3121_speed,d0 ;Startwert der Farbtabelle erhöhen
    and.w   d3,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,vcs3121_switch_table_start(a3) 
  move.w  d4,d0              
  addq.b  #vcs3121_step1_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,vcs3121_step1_angle(a3) 
  MOVEF.L (cl2_extension1_SIZE*(cl2_display_y_size/2))+4,d5
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table(pc),a3  
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(cl2_display_y_size/2))-4,a7
  moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
vert_colorscroll3121_loop1
  move.w  d2,d1              ;Startwert 
  MOVEF.W (cl2_display_y_size/2)-1,d6 ;Effekt für x Zeilen
vert_colorscroll3121_loop2
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  move.l  (a3,d4.w*4),d0     ;sin(w)
  MULUF.L vcs3121_step1_radius*2,d0 ;y'=(yr*sin(w))/2^15
  addq.b  #vcs3121_step1_angle_step,d4 ;nächster Y-Winkel
  swap    d0
  addq.w  #vcs3121_step1_center,d0 ;+ Y-Mittelpunkt
  IFEQ vcs3121_switch_table_length_256
    sub.b   d0,d1            ;Startwert verringern
  ELSE
    sub.w   d0,d1            ;Startwert verringern
    and.w   d3,d1            ;Überlauf entfernen
  ENDC
  dbf     d6,vert_colorscroll3121_loop2
  IFEQ vcs3121_switch_table_length_256
    subq.b  #vcs3121_step2,d2 ;nächster Wert aus Tabelle
  ELSE
    subq.w  #vcs3121_step2,d2 ;nächster Wert aus Tabelle
    and.w   d3,d2            ;Überlauf entfernen
  ENDC
  add.l   a7,a1              ;2. Quadrant vorletzte Spalte
  add.l   d5,a2              ;1. Quadrant nächste Spalte
  sub.l   d5,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a7,a5              ;4. Quadrant nächste Spalte
  dbf     d7,vert_colorscroll3121_loop1
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
no_vert_colorscroll3121
  rts

; ** Vert-Colorscroll 3.1.2.2 **
; ------------------------------
  CNOP 0,4
vert_colorscroll3122
  tst.w   vcs3122_active(a3) ;Vert-Colorscroll3.1.2.2 an ?
  bne     no_vert_colorscroll3122 ;Nein -> verzweige
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  vcs3122_switch_table_start(a3),d2 ;Startwert in Farbtabelle 
  move.w  d2,d0              
  move.w  vcs3122_step2_angle(a3),d4 ;Y-Step-Winkel 
  IFEQ vcs3122_switch_table_length_256
    addq.b  #vcs3122_speed,d0 ;Startwert der Switchtabelle erhöhen
  ELSE
    MOVEF.W vcs3122_switch_table_size-1,d3 ;Anzahl der Einträge
    addq.w  #vcs3122_speed,d0 ;Startwert der Farbtabelle erhöhen
    and.w   d3,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,vcs3122_switch_table_start(a3) 
  move.w  d4,d0              
  addq.b  #vcs3122_step2_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,vcs3122_step2_angle(a3) 
  MOVEF.L (cl2_extension1_SIZE*(cl2_display_y_size/2))+4,d5
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table(pc),a3  
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(cl2_display_y_size/2))-4,a7
  moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
vert_colorscroll3122_loop1
  move.w  d2,d1              ;Startwert 
  MOVEF.W (cl2_display_y_size/2)-1,d6 ;Effekt für x Zeilen
vert_colorscroll3122_loop2
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  IFEQ vcs3122_switch_table_length_256
    subq.b   #vcs3122_step1,d1 ;Startwert verringern
  ELSE
    subq.w   #vcs3122_step1,d1 ;Startwert verringern
    and.w   d3,d1            ;Überlauf entfernen
  ENDC
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  dbf     d6,vert_colorscroll3122_loop2
  move.l  (a3,d4.w*4),d0     ;sin(w)
  MULUF.L vcs3122_step2*2,d0     ;y'=(yr*sin(w))/2^15
  addq.b  #vcs3122_step2_angle_step,d4 ;nächster Y-Winkel
  swap    d0
  addq.w  #vcs3122_step2_center,d0 ;+ Y-Mittelpunkt
  IFEQ vcs3122_switch_table_length_256
    sub.b   d0,d2            ;nächster Wert aus Tabelle
  ELSE
    sub.b   d0,d2            ;nächster Wert aus Tabelle
    and.w   d3,d2            ;Überlauf entfernen
  ENDC
  add.l   a7,a1              ;2. Quadrant vorletzte Spalte
  add.l   d5,a2              ;1. Quadrant nächste Spalte
  sub.l   d5,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a7,a5              ;4. Quadrant nächste Spalte
  dbf     d7,vert_colorscroll3122_loop1
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
no_vert_colorscroll3122
  rts

; ** Vert-Colorscroll 3.1.1.1 **
; ------------------------------
  CNOP 0,4
vert_colorscroll3111
  tst.w   vcs3111_active(a3) ;Vert-Colorscroll3.1.1.2 an ?
  bne     no_vert_colorscroll3111 ;Nein -> verzweige
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  move.w  vcs3111_switch_table_start(a3),d2 ;Startwert in Farbtabelle 
  move.w  d2,d0              
  move.w  vcs3111_step2_angle(a3),d4 ;Y-Step-Winkel 
  IFEQ vcs3111_switch_table_length_256
    addq.b  #vcs3111_speed,d0 ;Startwert der Farbtabelle erhöhen
  ELSE
    MOVEF.W vcs3111_switch_table_size-1,d3 ;Anzahl der Einträge
    addq.w  #vcs3111_speed,d0 ;Startwert der Farbtabelle erhöhen
    and.w   d3,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,vcs3111_switch_table_start(a3) 
  move.w  d4,d0              
  addq.b  #vcs3111_step2_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,vcs3111_step2_angle(a3) 
  MOVEF.L (cl2_extension1_SIZE*(cl2_display_y_size/2))+4,d5
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORDSIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORDSIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table(pc),a3 
  lea     cl2_extension1_SIZE(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_SIZE(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_SIZE,a6
  move.w  #(cl2_extension1_SIZE*(cl2_display_y_size/2))-4,a7
  moveq   #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
vert_colorscroll_loop1
  move.w  d2,d1              ;Startwert 
  MOVEF.W (cl2_display_y_size/2)-1,d6 ;Effekt für x Zeilen
vert_colorscroll_loop2
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  IFEQ vcs3111_switch_table_length_256
    subq.b  #vcs3111_step1,d1 ;nächster Wert aus Tabelle
  ELSE
    subq.w  #vcs3111_step1,d1 ;nächster Wert aus Tabelle
    and.w   d3,d1            ;Überlauf entfernen
  ENDC
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  dbf     d6,vert_colorscroll_loop2
  move.l  (a3,d4.w*4),d0     ;sin(w)
  MULUF.L vcs3111_step2_radius*2,d0 ;y'=(yr*sin(w))/2^15
  addq.b  #vcs3111_step2_angle_step,d4 ;nächster Y-Winkel
  swap    d0
  add.w   #vcs3111_step2_center,d0 ;+ Y-Mittelpunkt
  IFEQ vcs3111_switch_table_length_256
    sub.b   d0,d2            ;Startwert verringern
  ELSE
    sub.w   d0,d2            ;Startwert verringern
    and.w   d3,d2            ;Überlauf entfernen
  ENDC
  add.l   a7,a1              ;2. Quadrant vorletzte Spalte
  add.l   d5,a2              ;1. Quadrant nächste Spalte
  sub.l   d5,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a7,a5              ;4. Quadrant nächste Spalte
  dbf     d7,vert_colorscroll_loop1
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
no_vert_colorscroll3111
  rts


  IFEQ open_border_enabled
; ** Blind-Fader-In **
; --------------------
    CNOP 0,4
blind_fader_in
    tst.w   bfi_active(a3)   ;Blind-Fader-In an ?
    bne.s   no_blind_fader_in ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Registeradresse 
    move.w  d2,d0            
    addq.w  #bf_speed,d0     ;Startwert der Tabelle erhöhen
    cmp.w   #bf_registers_table_length/2,d0 ;Ende der Tabelle erreicht ?
    ble.s   bfi_not_finished ;Nein -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfi_active(a3) ;Blind-Fader-In aus
bfi_not_finished
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl2_extension1_SIZE,d4
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
    addq.w  #bf_step2,d2     ;Startwert erhöhen
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
    tst.w   bfo_active(a3)   ;Blind-Fader-Out an ?
    bne.s   no_blind_fader_out ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Startwert der Tabelle 
    move.w  d2,d0            
    subq.w  #bf_speed,d0     ;Startwert der Tabelle verringern
    bpl.s   bfo_not_finished ;Wenn positiv -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfo_active(a3) ;Blind-Fader-Out aus
bfo_not_finished
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
  beq.s   eh_start_vert_colorscroll3112
  subq.w  #1,d0
  beq.s   eh_stop_vert_colorscroll3112
  subq.w  #1,d0
  beq.s   eh_start_vert_colorscroll3121
  subq.w  #1,d0
  beq.s   eh_stop_vert_colorscroll3121
  subq.w  #1,d0
  beq.s   eh_start_vert_colorscroll3122
  subq.w  #1,d0
  beq.s   eh_stop_vert_colorscroll3122
  subq.w  #1,d0
  beq.s   eh_start_vert_colorscroll3111
  subq.w  #1,d0
  beq.s   eh_stop_vert_colorscroll3111
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_vert_colorscroll3112
  moveq   #0,d0
  move.w  d0,vcs3112_active(a3) ;Vert-Colorscroll3.1.1.2 an
  move.w  d0,bfi_active(a3)  ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_vert_colorscroll3112
  clr.w   bfo_active(a3)     ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_start_vert_colorscroll3121
  moveq   #FALSE,d1
  move.w  d1,vcs3112_active(a3) ;Vert-Colorscroll3.1.1.2 aus
  moveq   #0,d0
  move.w  d0,vcs3121_active(a3) ;Vert-Colorscroll3.1.2.1 an
  move.w  d0,bfi_active(a3)  ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_vert_colorscroll3121
  clr.w   bfo_active(a3)     ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_start_vert_colorscroll3122
  moveq   #FALSE,d1
  move.w  d1,vcs3121_active(a3) ;Vert-Colorscroll3.1.2.1 aus
  moveq   #0,d0
  move.w  d0,vcs3122_active(a3) ;Vert-Colorscroll3.1.2.2 an
  move.w  d0,bfi_active(a3)  ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_vert_colorscroll3122
  clr.w   bfo_active(a3)     ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_start_vert_colorscroll3111
  moveq   #FALSE,d1
  move.w  d1,vcs3122_active(a3) ;Vert-Colorscroll3.1.2.2 aus
  moveq   #0,d0
  move.w  d0,vcs3111_active(a3) ;Vert-Colorscroll3.1.1.1 an
  move.w  d0,bfi_active(a3)  ;Blind-Fader-In an
  rts
  CNOP 0,4
eh_stop_vert_colorscroll3111
  clr.w   bfo_active(a3)     ;Blind-Fader-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_active(a3)      ;Effekte beendet
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
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/02_vcs3112_Colorgradient.ct"

; **** Blind-Fader ****
  IFEQ open_border_enabled
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
