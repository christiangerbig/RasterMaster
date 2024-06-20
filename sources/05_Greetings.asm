; ##############################
; # Programm: 05_Greetings.asm #
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
  XREF COLOR00HIGHBITS
  XREF COLOR00LOWBITS
  XREF COLOR255BITS
  XREF nop_second_copperlist
  XREF mouse_handler
  XREF sine_table


  XDEF start_05_greetings


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

requires_68030                     EQU FALSE
requires_68040                     EQU FALSE
requires_68060                     EQU FALSE
requires_fast_memory               EQU FALSE
requires_multiscan_monitor         EQU FALSE

workbench_start_enabled            EQU FALSE
workbench_fade_enabled             EQU FALSE
text_output_enabled                EQU FALSE

sys_taken_over
pass_global_references
pass_return_code
open_border_enabled                EQU FALSE ;Immer FALSE, da Overscan-Playfield

tb31612_quick_clear_enabled        EQU TRUE ;Solle TRUE sein, wenn Hintergrundeffekt aktiviert ist
tb31612_restore_cl_cpu_enabled     EQU FALSE
tb31612_restore_cl_blitter_enabled EQU TRUE

DMABITS                            EQU DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
INTENABITS                         EQU INTF_SETCLR

CIAAICRBITS                        EQU CIAICRF_SETCLR
CIABICRBITS                        EQU CIAICRF_SETCLR

COPCONBITS                         EQU COPCONF_CDANG

pf1_x_size1                        EQU 0
pf1_y_size1                        EQU 0
pf1_depth1                         EQU 0
pf1_x_size2                        EQU 512
pf1_y_size2                        EQU 256+32
pf1_depth2                         EQU 1
pf1_x_size3                        EQU 512
pf1_y_size3                        EQU 256+32
pf1_depth3                         EQU 1
pf1_colors_number                  EQU 0 ;256

pf2_x_size1                        EQU 0
pf2_y_size1                        EQU 0
pf2_depth1                         EQU 0
pf2_x_size2                        EQU 0
pf2_y_size2                        EQU 0
pf2_depth2                         EQU 0
pf2_x_size3                        EQU 0
pf2_y_size3                        EQU 0
pf2_depth3                         EQU 0
pf2_colors_number                  EQU 0
pf_colors_number                   EQU pf1_colors_number+pf2_colors_number
pf_depth                           EQU pf1_depth3+pf2_depth3

extra_pf_number                    EQU 1
extra_pf1_x_size                   EQU 448
extra_pf1_y_size                   EQU 32+(32)
extra_pf1_depth                    EQU 1

spr_number                         EQU 0
spr_x_size1                        EQU 0
spr_y_size1                        EQU 0
spr_x_size2                        EQU 0
spr_y_size2                        EQU 0
spr_depth                          EQU 0
spr_colors_number                  EQU 0

audio_memory_size                  EQU 0

disk_memory_size                   EQU 0

chip_memory_size                   EQU 0
CIAA_TA_time                       EQU 0
CIAA_TB_time                       EQU 0
CIAB_TA_time                       EQU 0
CIAB_TB_time                       EQU 0
CIAA_TA_continuous_enabled         EQU FALSE
CIAA_TB_continuous_enabled         EQU FALSE
CIAB_TA_continuous_enabled         EQU FALSE
CIAB_TB_continuous_enabled         EQU FALSE

beam_position                      EQU $136

pixel_per_line                     EQU 448
visible_pixels_number              EQU 352
visible_lines_number               EQU 256
MINROW                             EQU VSTART_256_lines

pf_pixel_per_datafetch             EQU 64 ;4x
DDFSTRTBITS                        EQU DDFSTART_overscan_64_pixel
DDFSTOPBITS                        EQU DDFSTOP_overscan_16_pixel

display_window_HSTART              EQU HSTART_44_chunky_pixel
display_window_VSTART              EQU MINROW
DIWSTRTBITS                        EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP               EQU HSTOP_44_chunky_pixel
display_window_VSTOP               EQU VSTOP_256_lines
DIWSTOPBITS                        EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

pf1_plane_width                    EQU pf1_x_size3/8
extra_pf1_plane_width              EQU extra_pf1_x_size/8
data_fetch_width                   EQU pixel_per_line/8
pf1_plane_moduli                   EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

BPLCON0BITS                        EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON1BITS                        EQU BPLCON1F_PF1H4+BPLCON1F_PF2H4+BPLCON1F_PF1H1+BPLCON1F_PF2H1 ;Damit die Bitplane die gleiche Startposition wie CWAIT hat
BPLCON2BITS                        EQU 0
BPLCON3BITS1                       EQU 0
BPLCON3BITS2                       EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON3BITS3                       EQU BPLCON3BITS1+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
BPLCON3BITS4                       EQU BPLCON3BITS2+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
BPLCON4BITS                        EQU 0
DIWHIGHBITS                        EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                          EQU FMODEF_BPL32+FMODEF_BPAGEM

cl1_HSTART                         EQU $00
cl1_VSTART                         EQU $03 ;Damit die CPU die Zeiger COP1LC in der CL für den Einsprung des Char-Blits vor dem Ausführen der CMOVE-Befehlen ändert

cl2_display_x_size                 EQU 352
cl2_display_width                  EQU cl2_display_x_size/8
cl2_display_y_size                 EQU visible_lines_number
  IFEQ open_border_enabled
cl2_HSTART1                        EQU display_window_HSTART-(5*CMOVE_slot_period)-4
  ELSE
cl2_HSTART1                        EQU display_window_HSTART-(4*CMOVE_slot_period)-4
  ENDC
cl2_VSTART1                        EQU MINROW
cl2_HSTART2                        EQU $00
cl2_VSTART2                        EQU beam_position&$ff

sine_table_length                  EQU 256

; **** Twisted-Bars3.16.1.2 ****
tb31612_bars_number                EQU 3
tb31612_bar_height                 EQU 32
tb31612_y_radius                   EQU 56
tb31612_y_center                   EQU (cl2_display_y_size-tb31612_bar_height)/2
tb31612_y_angle_speed              EQU 4
tb31612_y_angle_step               EQU 6
tb31612_y_distance                 EQU sine_table_length/tb31612_bars_number

; **** Clear-Blit ****
tb31612_clear_blit_x_size          EQU 16
  IFEQ open_border_enabled
tb31612_clear_blit_y_size          EQU cl2_display_y_size*(cl2_display_width+6)
  ELSE
tb31612_clear_blit_y_size          EQU cl2_display_y_size*(cl2_display_width+5)
  ENDC

; **** Restore-Blit ****
tb31612_restore_blit_x_size        EQU 16
tb31612_restore_blit_width         EQU tb31612_restore_blit_x_size/8
tb31612_restore_blit_y_size        EQU cl2_display_y_size

; **** Wave-Center-Bar ****
wcb_bar_height                     EQU 80
wcb_y_center                       EQU (cl2_display_y_size-wcb_bar_height)/2

; **** Wave-Effect ****
we_y_radius                        EQU 48
we_y_angle_speed                   EQU 1
we_y_angle_step                    EQU 2
we_y_radius_angle_speed            EQU 2
we_y_radius_angle_step             EQU 4

; **** Sine-Scrolltext ****
ss_image_x_size                    EQU 320
ss_image_plane_width               EQU ss_image_x_size/8
ss_image_depth                     EQU 1
ss_origin_character_x_size         EQU 32
ss_origin_character_y_size         EQU 32

ss_text_character_x_size           EQU 16
ss_text_character_width            EQU ss_text_character_x_size/8
ss_text_character_y_size           EQU ss_origin_character_y_size
ss_text_character_depth            EQU ss_image_depth

ss_sine_character_x_size           EQU 16
ss_sine_character_width            EQU ss_sine_character_x_size/8
ss_sine_character_y_size1          EQU extra_pf1_y_size
ss_sine_character_y_size2          EQU ss_text_character_y_size
ss_sine_character_depth            EQU pf1_depth3

ss_horiz_scroll_window_x_size      EQU visible_pixels_number+(ss_text_character_x_size*2)
ss_horiz_scroll_window_width       EQU ss_horiz_scroll_window_x_size/8
ss_horiz_scroll_window_y_size      EQU ss_text_character_y_size
ss_horiz_scroll_window_depth       EQU ss_image_depth
ss_horiz_scroll_speed              EQU 4

ss_text_character_x_restart        EQU ss_horiz_scroll_window_x_size-ss_text_character_x_size
ss_text_character_y_restart        EQU ss_text_character_y_size/2
ss_text_character_x_shift_max      EQU ss_text_character_x_size
ss_text_characters_number          EQU ss_horiz_scroll_window_x_size/ss_text_character_x_size

ss_text_x_position                 EQU 32
ss_text_y_position                 EQU ss_text_character_y_size/2
ss_text_y_center                   EQU (visible_lines_number-ss_text_character_y_size)/2

ss_text_columns_x_size             EQU 8
ss_text_columns_per_word           EQU 16/ss_text_columns_x_size
ss_text_columns_number             EQU visible_pixels_number/ss_text_columns_x_size

ss_colorrun_height                 EQU ss_text_character_y_size
ss_colorrun_y_pos                  EQU (wcb_bar_height-ss_text_character_y_size)/2

ss_copy_character_blit_x_size      EQU ss_text_character_x_size
ss_copy_character_blit_y_size      EQU ss_text_character_y_size*ss_text_character_depth

ss_horiz_scroll_blit_x_size        EQU ss_horiz_scroll_window_x_size
ss_horiz_scroll_blit_y_size        EQU ss_horiz_scroll_window_y_size*ss_horiz_scroll_window_depth

ss_copy_column_blit_x_size1        EQU ss_sine_character_x_size
ss_copy_column_blit_y_size1        EQU ss_sine_character_y_size1*ss_sine_character_depth

ss_copy_column_blit_x_size2        EQU ss_sine_character_x_size
ss_copy_column_blit_y_size2        EQU ss_sine_character_y_size2*ss_sine_character_depth

; **** Barfield ****
bf_bars_planes_number              EQU 6
bf_bars_per_plane                  EQU 1
bf_bar_height                      EQU 40
bf_y_center                        EQU (visible_lines_number+bf_bar_height)/2
bf_z_speed                         EQU 8

bf_destination_bar_y_size          EQU 4
bf_source_bar_y_size               EQU 40

bf_z_planes_number                 EQU (bf_source_bar_y_size-bf_destination_bar_y_size)/2
bf_z_plane1                        EQU 30
bf_y_min                           EQU 0
bf_y_max                           EQU visible_lines_number+bf_bar_height
bf_z_min                           EQU 0
bf_d                               EQU 64

; **** Chunky-Columns-Fader ****
ccfi_mode1                         EQU 0
ccfi_mode2                         EQU 1
ccfi_mode3                         EQU 2
ccfi_mode4                         EQU 3
ccfi_delay_speed                   EQU 1
ccfi_columns_delay1                EQU 2
ccfi_columns_delay2                EQU 27

ccfo_mode1                         EQU 0
ccfo_mode2                         EQU 1
ccfo_mode3                         EQU 2
ccfo_mode4                         EQU 3
ccfo_delay_speed                   EQU 1
ccfo_columns_delay                 EQU 1

; **** Effects-Handler ****
eh_trigger_number_max              EQU 9


color_step1                        EQU 256/(tb31612_bar_height/2)
color_step2                        EQU 256/(wcb_bar_height/2)
color_step3                        EQU 256/ss_colorrun_height
color_step4                        EQU 256/(bf_bar_height/2)
color_values_number1               EQU tb31612_bar_height/2
color_values_number2               EQU wcb_bar_height/2
color_values_number3               EQU ss_colorrun_height
color_values_number4               EQU bf_bar_height/2
segments_number1                   EQU tb31612_bars_number
segments_number2                   EQU 2
segments_number3                   EQU 1
segments_number4                   EQU 1*2

ct_size1                           EQU color_values_number1*segments_number1
ct_size2                           EQU color_values_number2*segments_number2
ct_size3                           EQU color_values_number3*segments_number3
ct_size4                           EQU color_values_number4*segments_number4

tb31612_switch_table_size          EQU ct_size1*2
wcb_switch_table_size              EQU ct_size2

pf1_bitplane_x_offset              EQU 0
pf1_bitplane_y_offset              EQU ss_text_y_position


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Extra-Memory-Abschnitte **
; ----------------------------
  RSRESET

em_switch_table1 RS.B tb31612_switch_table_size
em_switch_table2 RS.B wcb_switch_table_size
  RS_ALIGN_LONGWORD
em_color_table1  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table2  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table3  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table4  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table5  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table6  RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_buffer  RS.L cl2_display_y_size+(bf_bar_height*2)
extra_memory_size RS.B 0


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

cl1_extension1      RS.B 0

cl1_ext1_WAIT       RS.L 1
cl1_ext1_COP1LCH    RS.L 1
cl1_ext1_COP1LCL    RS.L 1
cl1_ext1_COPJMP1    RS.L 1

cl1_extension1_SIZE RS.B 0


  RSRESET

cl1_extension2      RS.B 0

cl1_ext2_WAITBLIT   RS.L 1
cl1_ext2_BLTCON0    RS.L 1
cl1_ext2_BLTCON1    RS.L 1
cl1_ext2_BLTAFWM    RS.L 1
cl1_ext2_BLTALWM    RS.L 1
cl1_ext2_BLTAPTH    RS.L 1
cl1_ext2_BLTAPTL    RS.L 1
cl1_ext2_BLTDPTH    RS.L 1
cl1_ext2_BLTDPTL    RS.L 1
cl1_ext2_BLTAMOD    RS.L 1
cl1_ext2_BLTDMOD    RS.L 1
cl1_ext2_BLTSIZE    RS.L 1

cl1_extension2_SIZE RS.B 0


  RSRESET

cl1_extension3      RS.B 0

cl1_ext3_WAITBLIT   RS.L 1
cl1_ext3_DMACON     RS.L 1
cl1_ext3_BLTCON0    RS.L 1
cl1_ext3_BLTCON1    RS.L 1
cl1_ext3_BLTAFWM    RS.L 1
cl1_ext3_BLTALWM    RS.L 1
cl1_ext3_BLTAPTH    RS.L 1
cl1_ext3_BLTAPTL    RS.L 1
cl1_ext3_BLTDPTH    RS.L 1
cl1_ext3_BLTDPTL    RS.L 1
cl1_ext3_BLTAMOD    RS.L 1
cl1_ext3_BLTDMOD    RS.L 1
cl1_ext3_BLTSIZE    RS.L 1

cl1_extension3_SIZE RS.B 0

  RSRESET

cl1_begin            RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_extension1_entry RS.B cl1_extension1_SIZE
cl1_extension2_entry RS.B cl1_extension2_SIZE
cl1_extension3_entry RS.B cl1_extension3_SIZE

cl1_ext3_COPJMP2     RS.L 1

copperlist1_SIZE     RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAITBLIT   RS.L 1
cl2_ext1_BLTBMOD    RS.L 1
cl2_ext1_BLTAMOD    RS.L 1
cl2_ext1_BLTDMOD    RS.L 1

cl2_extension1_SIZE RS.B 0


  RSRESET

cl2_extension2      RS.B 0

cl2_ext2_BLTCON0    RS.L 1
cl2_ext2_BLTALWM    RS.L 1
cl2_ext2_BLTAPTH    RS.L 1
cl2_ext2_BLTAPTL    RS.L 1
cl2_ext2_BLTDPTH    RS.L 1
cl2_ext2_BLTDPTL    RS.L 1
cl2_ext2_BLTSIZE    RS.L 1
cl2_ext2_WAITBLIT   RS.L 1

cl2_extension2_SIZE RS.B 0


  RSRESET

cl2_extension3      RS.B 0

cl2_ext3_BLTCON0    RS.L 1

cl2_extension3_SIZE RS.B 0


  RSRESET

cl2_extension4      RS.B 0

cl2_ext4_BLTALWM    RS.L 1
cl2_ext4_BLTBPTH    RS.L 1
cl2_ext4_BLTBPTL    RS.L 1
cl2_ext4_BLTAPTH    RS.L 1
cl2_ext4_BLTAPTL    RS.L 1
cl2_ext4_BLTDPTH    RS.L 1
cl2_ext4_BLTDPTL    RS.L 1
cl2_ext4_BLTSIZE    RS.L 1
cl2_ext4_WAITBLIT   RS.L 1

cl2_extension4_SIZE RS.B 0


  RSRESET

cl2_extension5      RS.B 0

cl2_ext5_COP1LCH    RS.L 1
cl2_ext5_COP1LCL    RS.L 1

cl2_extension5_SIZE RS.B 0


  RSRESET

cl2_extension6      RS.B 0

cl2_ext6_DMACON     RS.L 1
cl2_ext6_BLTCON0    RS.L 1
cl2_ext6_BLTALWM    RS.L 1
cl2_ext6_BLTDPTH    RS.L 1
cl2_ext6_BLTDPTL    RS.L 1
cl2_ext6_BLTDMOD    RS.L 1
cl2_ext6_BLTADAT    RS.L 1
cl2_ext6_BLTSIZV    RS.L 1
cl2_ext6_BLTSIZH    RS.L 1

cl2_extension6_SIZE RS.B 0


  RSRESET

cl2_extension7        RS.B 0

cl2_ext7_WAIT         RS.L 1
  IFEQ tb31612_quick_clear_enabled
cl2_ext7_BPLCON3_1    RS.L 1
cl2_ext7_COLOR31_high RS.L 1
cl2_ext7_BPLCON3_2    RS.L 1
cl2_ext7_COLOR31_low  RS.L 1
  ELSE
cl2_ext7_BPLCON3_1    RS.L 1
cl2_ext7_COLOR00_high RS.L 1
cl2_ext7_BPLCON3_2    RS.L 1
cl2_ext7_COLOR00_low  RS.L 1
  ENDC
  IFEQ open_border_enabled 
cl2_ext7_BPL1DAT      RS.L 1
  ENDC
cl2_ext7_BPLCON4_1    RS.L 1
cl2_ext7_BPLCON4_2    RS.L 1
cl2_ext7_BPLCON4_3    RS.L 1
cl2_ext7_BPLCON4_4    RS.L 1
cl2_ext7_BPLCON4_5    RS.L 1
cl2_ext7_BPLCON4_6    RS.L 1
cl2_ext7_BPLCON4_7    RS.L 1
cl2_ext7_BPLCON4_8    RS.L 1
cl2_ext7_BPLCON4_9    RS.L 1
cl2_ext7_BPLCON4_10   RS.L 1
cl2_ext7_BPLCON4_11   RS.L 1
cl2_ext7_BPLCON4_12   RS.L 1
cl2_ext7_BPLCON4_13   RS.L 1
cl2_ext7_BPLCON4_14   RS.L 1
cl2_ext7_BPLCON4_15   RS.L 1
cl2_ext7_BPLCON4_16   RS.L 1
cl2_ext7_BPLCON4_17   RS.L 1
cl2_ext7_BPLCON4_18   RS.L 1
cl2_ext7_BPLCON4_19   RS.L 1
cl2_ext7_BPLCON4_20   RS.L 1
cl2_ext7_BPLCON4_21   RS.L 1
cl2_ext7_BPLCON4_22   RS.L 1
cl2_ext7_BPLCON4_23   RS.L 1
cl2_ext7_BPLCON4_24   RS.L 1
cl2_ext7_BPLCON4_25   RS.L 1
cl2_ext7_BPLCON4_26   RS.L 1
cl2_ext7_BPLCON4_27   RS.L 1
cl2_ext7_BPLCON4_28   RS.L 1
cl2_ext7_BPLCON4_29   RS.L 1
cl2_ext7_BPLCON4_30   RS.L 1
cl2_ext7_BPLCON4_31   RS.L 1
cl2_ext7_BPLCON4_32   RS.L 1
cl2_ext7_BPLCON4_33   RS.L 1
cl2_ext7_BPLCON4_34   RS.L 1
cl2_ext7_BPLCON4_35   RS.L 1
cl2_ext7_BPLCON4_36   RS.L 1
cl2_ext7_BPLCON4_37   RS.L 1
cl2_ext7_BPLCON4_38   RS.L 1
cl2_ext7_BPLCON4_39   RS.L 1
cl2_ext7_BPLCON4_40   RS.L 1
cl2_ext7_BPLCON4_41   RS.L 1
cl2_ext7_BPLCON4_42   RS.L 1
cl2_ext7_BPLCON4_43   RS.L 1
cl2_ext7_BPLCON4_44   RS.L 1

cl2_extension7_SIZE   RS.B 0

  IFNE tb31612_quick_clear_enabled
    IFEQ tb31612_restore_cl_blitter_enabled
      RSRESET

cl2_extension8      RS.B 0

cl2_ext8_WAITBLIT   RS.L 1
cl2_ext8_BLTDPTH    RS.L 1
cl2_ext8_BLTDPTL    RS.L 1
cl2_ext8_BLTDMOD    RS.L 1
cl2_ext8_BLTADAT    RS.L 1
cl2_ext8_BLTSIZE    RS.L 1

cl2_extension8_SIZE RS.B 0
    ENDC
  ENDC

  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_SIZE
cl2_extension2_entry RS.B cl2_extension2_SIZE*(visible_pixels_number/16)
cl2_extension3_entry RS.B cl2_extension3_SIZE*(visible_pixels_number/16)
cl2_extension4_entry RS.B cl2_extension4_SIZE*(ss_text_columns_number-(visible_pixels_number/16))
cl2_extension5_entry RS.B cl2_extension5_SIZE
cl2_extension6_entry RS.B cl2_extension6_SIZE
cl2_extension7_entry RS.B cl2_extension7_SIZE*cl2_display_y_size
  IFNE tb31612_quick_clear_enabled
    IFEQ tb31612_restore_cl_blitter_enabled
cl2_extension8_entry RS.B cl2_extension8_SIZE
    ENDC
  ENDC

cl2_WAIT1            RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1            EQU 0
cl1_size2            EQU 0
cl1_size3            EQU copperlist1_SIZE

cl2_size1            EQU copperlist2_SIZE
cl2_size2            EQU copperlist2_SIZE
cl2_size3            EQU copperlist2_SIZE


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1         EQU spr_x_size1
spr0_y_size1         EQU 0
spr1_x_size1         EQU spr_x_size1
spr1_y_size1         EQU 0
spr2_x_size1         EQU spr_x_size1
spr2_y_size1         EQU 0
spr3_x_size1         EQU spr_x_size1
spr3_y_size1         EQU 0
spr4_x_size1         EQU spr_x_size1
spr4_y_size1         EQU 0
spr5_x_size1         EQU spr_x_size1
spr5_y_size1         EQU 0
spr6_x_size1         EQU spr_x_size1
spr6_y_size1         EQU 0
spr7_x_size1         EQU spr_x_size1
spr7_y_size1         EQU 0

spr0_x_size2         EQU spr_x_size2
spr0_y_size2         EQU 0
spr1_x_size2         EQU spr_x_size2
spr1_y_size2         EQU 0
spr2_x_size2         EQU spr_x_size2
spr2_y_size2         EQU 0
spr3_x_size2         EQU spr_x_size2
spr3_y_size2         EQU 0
spr4_x_size2         EQU spr_x_size2
spr4_y_size2         EQU 0
spr5_x_size2         EQU spr_x_size2
spr5_y_size2         EQU 0
spr6_x_size2         EQU spr_x_size2
spr6_y_size2         EQU 0
spr7_x_size2         EQU spr_x_size2
spr7_y_size2         EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

save_a7                    RS.L 1

; **** Sine-Scrolltext ****
ss_image                   RS.L 1
ss_enabled RS.W 1
ss_text_table_start        RS.W 1
ss_text_character_x_shift  RS.W 1
ss_character_toggle_image  RS.W 1

; **** Twisted-Bars3.16.1.2 ****
tb31612_y_angle            RS.W 1

; **** Wave-Effect ****
we_radius_y_angle          RS.W 1
we_y_angle                 RS.W 1

; **** Barfield ****
bf_active                  RS.W 1
bf_z_restart_active        RS.W 1

; **** Chunky-Columns-Fader ****
  RS_ALIGN_LONGWORD
ccf_fader_columns_mask     RS.L 1

ccfi_active                RS.W 1
ccfi_current_mode          RS.W 1
ccfi_start                 RS.W 1
ccfi_columns_delay_counter RS.W 1
ccfi_columns_delay_reset   RS.W 1

ccfo_active                RS.W 1
ccfo_current_mode          RS.W 1
ccfo_start                 RS.W 1
ccfo_columns_delay_counter RS.W 1
ccfo_columns_delay_reset   RS.W 1

; **** Effects-Handler ****
eh_trigger_number          RS.W 1

; **** Main ****
fx_active                  RS.W 1

variables_SIZE             RS.B 0


start_05_greetings

  INCLUDE "sys-wrapper.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** Sine-Scrolltext ****
  lea     ss_image_data,a0
  move.l  a0,ss_image(a3)
  moveq   #FALSE,d1
  move.w  d1,ss_enabled(a3)
  moveq   #0,d0
  move.w  d0,ss_text_table_start(a3)
  move.w  d0,ss_text_character_x_shift(a3)
  move.w  d0,ss_character_toggle_image(a3)

; **** Twisted-Bars3.16.1.2 ****
  move.w  d0,tb31612_y_angle(a3)

; **** Wave-Effect ****
  move.w  d0,we_radius_y_angle(a3)
  move.w  d0,we_y_angle(a3)

; **** Barfield ****
  move.w  d1,bf_active(a3)
  move.w  d0,bf_z_restart_active(a3)

; **** Chunky-Columns-Fader ****
  lea     wcb_fader_columns_mask(pc),a0
  move.l  a0,ccf_fader_columns_mask(a3)

  move.w  d1,ccfi_active(a3)
  moveq   #ccfi_mode2,d2
  move.w  d2,ccfi_current_mode(a3)
  move.w  d0,ccfi_start(a3)
  move.w  d0,ccfi_columns_delay_counter(a3)
  moveq   #ccfi_columns_delay1,d2
  move.w  d2,ccfi_columns_delay_reset(a3)

  move.w  d1,ccfo_active(a3)
  moveq   #ccfo_mode2,d2
  move.w  d2,ccfo_current_mode(a3)
  move.w  d0,ccfo_start(a3)
  move.w  d0,ccfo_columns_delay_counter(a3)
  moveq   #ccfo_columns_delay,d2
  move.w  d2,ccfo_columns_delay_reset(a3)

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   tb31612_init_color_table
  bsr     wcb_init_color_table
  bsr     ss_init_color_table
  bsr     init_color_registers
  bsr     tb31612_init_mirror_switch_table
  bsr     tb31612_get_yz_coordinates
  bsr     wcb_init_switch_table
  bsr     ss_init_characters_offsets
  bsr     bf_init_color_table
  bsr     bf_init_color_table_pointers
  bsr     bf_scale_bar_size
  bsr     init_first_copperlist
  bra     init_second_copperlist

; **** Twisted-Bars ****
; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
tb31612_init_color_table
  lea     tb31612_bars_color_table(pc),a0
  lea     pf1_color_table(pc),a1
  MOVEF.W (color_values_number1*segments_number1)-1,d7
tb31612_init_color_table_loop
  move.l  (a0)+,d0           ;RGB8-Farbwert
  move.l  d0,(a1)+           ;COLOR00
  move.l  d0,(a1)+           ;COLOR01
  dbf     d7,tb31612_init_color_table_loop
  rts

; **** Wave-Center-Bar ****
; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
wcb_init_color_table
  lea     wcb_bar_color_table(pc),a0
  lea     pf1_color_table+(color_values_number1*segments_number1*2*LONGWORDSIZE)(pc),a1
  MOVEF.W (color_values_number2*segments_number2)-1,d7
wcb_init_color_table_loop
  move.l  (a0)+,(a1)         ;COLOR00
  addq.w  #8,a1
  dbf     d7,wcb_init_color_table_loop
  rts

; **** Sine-Scrolltext *****
; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
ss_init_color_table
  lea     ss_color_table(pc),a0
  lea     pf1_color_table+((1+(((color_values_number1*segments_number1)+ss_colorrun_y_pos)*2))*LONGWORDSIZE)(pc),a1
  MOVEF.W (color_values_number3*segments_number3)-1,d7
ss_init_color_table_loop
  move.l  (a0)+,(a1)         ;COLOR01
  addq.w  #8,a1
  dbf     d7,ss_init_color_table_loop
  rts

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

; **** Twisted-Bars3.16.1.2 ****
; ** Referenz-Switchtabelle für Twisted-Bars initialisieren **
; ------------------------------------------------------------
  INIT_MIRROR_SWITCH_TABLE.B tb31612,0,2,segments_number1,color_values_number1,extra_memory,a3

; **** Wave-Center-Bar/Sine-Scrolltext ****
; ** Referenz-Switchtabelle für Wave-Wave-Center-Bar initialisieren **
; ---------------------------------------------------------------
  INIT_SWITCH_TABLE.B wcb,color_values_number1*segments_number1*2,2,color_values_number2*2,extra_memory,a3,em_switch_table2

; **** Sine-Scrolltext ****
; ** Offsets der Buchstaben im Characters-Pic berechnen **
; --------------------------------------------------------
  INIT_CHARACTERS_OFFSETS.W ss

; **** Barfield ****
; ** Farbtabelle initialisieren **
; --------------------------------
  CNOP 0,4
bf_init_color_table
  lea     bf_color_table(pc),a0
  move.l  extra_memory(a3),a2
  lea     em_color_table1(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop1
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop1

  lea     em_color_table2(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop2
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop2

  lea     em_color_table3(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop3
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop3

  lea     em_color_table4(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop4
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop4

  lea     em_color_table5(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop5
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop5

  lea     em_color_table6(a2),a1
  MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop6
  move.l  (a0)+,(a1)         ;COLOR01
  add.l   #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORDSIZE,a1
  dbf     d7,bf_init_color_table_loop6
  rts

; ** Tabelle mit Zeigern auf Farbtabellen initialisieren **
; ---------------------------------------------------------
  CNOP 0,4
bf_init_color_table_pointers
  move.l  extra_memory(a3),a0
  lea     bf_color_table_pointers(pc),a1
  lea     em_color_table1(a0),a2
  move.l  a2,(a1)+
  lea     em_color_table2(a0),a2
  move.l  a2,(a1)+
  lea     em_color_table3(a0),a2
  move.l  a2,(a1)+
  lea     em_color_table4(a0),a2
  move.l  a2,(a1)+
  lea     (em_color_table5,a0),a2
  move.l  a2,(a1)+
  lea     (em_color_table6,a0),a2
  move.l  a2,(a1)
  rts

; ** Bar schrittweise verkleinern **
; ----------------------------------
  CNOP 0,4
bf_scale_bar_size
  movem.l a4-a6,-(a7)
  move.w  #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*4,a5
  lea     bf_color_table_pointers(pc),a6 ;Tabelle mit Zeigern auf Farbtabellen
  moveq   #bf_bars_planes_number-1,d7 ;Anzahl der Z-Ebenen
bf_scale_bar_size_loop1
  move.l  (a6),a4
  addq.w  #4,a4              ;Ziel Tabelle mit Farbwerten
  MOVEF.L bf_source_bar_y_size-2,d5 ;variable Höhe des Zielbildes
  swap    d7                 
  move.w  #((bf_source_bar_y_size-bf_destination_bar_y_size)/2)-1,d7
bf_scale_bar_size_loop2
  bsr.s   bf_refresh_bitmap_table
  bsr.s   bf_init_bitmap_lines_table
  move.l  a4,a2              ;Farbtabelle = Ziel
  MOVEF.L bf_bar_height,d0
  sub.w   d5,d0              ;Höhe der Bar - aktuelle Höhe der Bar
  mulu.w  #(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*2,d0 ;*Anzahl der Abschnitte = Y-Zentrierung
  move.l  (a6),a1            ;Zeiger auf Farbtabelle (Quelle)
  add.l   d0,a2              ;+ Y-Offset in Farbtabelle
  bsr.s   bf_do_scale_bar_y_size
  subq.w  #2,d5              ;Höhe verringern
  addq.w  #4,a4              ;1 Zeile in Farbtabelle überspringen
  dbf     d7,bf_scale_bar_size_loop2
  addq.w  #4,a6              ;nächste Farbtabelle
  swap    d7                 ;Schleifenzähler
  dbf     d7,bf_scale_bar_size_loop1
  movem.l (a7)+,a4-a6
  rts

; ** Bitmap-Tabelle zurücksetzen **
; ---------------------------------
  CNOP 0,4
bf_refresh_bitmap_table
  moveq   #0,d0
  lea     bf_bitmap_lines_table(pc),a0 ;Zeiger auf Bitmap-Tabelle
  move.w  #(bf_source_bar_y_size/4)-1,d6 ;Anzahl der Langwörter
bf_refresh_bitmap_table_loop
  move.l  d0,(a0)+           ;1 Langwort löschen
  dbf     d6,bf_refresh_bitmap_table_loop
  rts

; ** Bitmap-Tabelle für die Zeilen initialisieren **
; --------------------------------------------------
  CNOP 0,4
bf_init_bitmap_lines_table
  lea     bf_bitmap_lines_table(pc),a0 ;Zeiger auf Bitmap-Tabelle
  MOVEF.L bf_source_bar_y_size,d3 ;Höhe des Quellbildes in Pixeln
  moveq   #TRUE,d4
  swap    d3                 ;*2^16
  move.w  d5,d4              ;Höhe des Zielbildes in Pixeln
  move.l  d3,d2              ;Höhe des Quellbildes untere 32 Bit
  moveq   #TRUE,d6           ;Höhe des Quellbildes obere 32 Bit
  divu.l  d4,d6:d2           ;F=Höhe des Quellbildes/Höhe der Zielbildes
  moveq   #TRUE,d1
  move.w  d4,d6              ;Höhe des Zielbilds 
  subq.w  #1,d6              ;wegen dbf
bf_init_bitmap_lines_table_loop
  move.l  d1,d0              ;F 
  swap    d0                 ;/2^16 = Bitmapposition
  add.l   d2,d1              ;F erhöhen (p*F)
  addq.b  #1,(a0,d0.w)       ;Pixel in Tabelle setzen
  dbf     d6,bf_init_bitmap_lines_table_loop
  rts

; ** Höhe der Bar skalieren **
; ----------------------------
  CNOP 0,4
bf_do_scale_bar_y_size
  lea     bf_bitmap_lines_table(pc),a0 ;Zeiger auf Bitmap-Tabelle
  MOVEF.W bf_source_bar_y_size-1,d6 ;Höhe des Quellbildes
bf_do_scale_bar_y_size_loop
  tst.b   (a0)+              ;Y-Vergrößerungsfaktor = NULL ?
  beq.s   bf_skip_line       ;Ja -> verzweige
  move.l  (a1),(a2)          ;Farbwert kopieren
  add.l   a5,a2              ;nächste Zeile in Farbtabelle
bf_skip_line
  add.l   a5,a1              ;nächster Farbwert
  dbf     d6,bf_do_scale_bar_y_size_loop
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  bsr.s   cl1_init_bitplane_pointers
  bsr     cl1_init_copperlist_branch
  bsr     cl1_init_copy_blit
  bsr     cl1_init_horiz_scroll_blit
  COPMOVEQ TRUE,COPJMP2
  bra     cl1_set_bitplane_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1

  COP_INIT_BITPLANE_POINTERS cl1

  CNOP 0,4
cl1_init_copperlist_branch
  COPWAIT cl1_HSTART,cl1_VSTART
  move.l  cl1_display(a3),d0 ;Darstellen-CL
  add.l   #cl1_extension3_entry,d0 ;Char-Blit überspringen
  swap    d0                 ;High
  COPMOVE d0,COP1LCH
  swap    d0                 ;Low
  COPMOVE d0,COP1LCL
  COPMOVEQ TRUE,COPJMP1
  rts

  CNOP 0,4
cl1_init_copy_blit
  COPWAITBLIT
  COPMOVEQ BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;Minterm D=A
  COPMOVEQ TRUE,BLTCON1
  COPMOVEQ FALSEW,BLTAFWM
  COPMOVEQ FALSEW,BLTALWM
  COPMOVEQ TRUE,BLTAPTH
  COPMOVEQ TRUE,BLTAPTL
  move.l  extra_pf1(a3),a1
  move.l  #(ss_text_character_x_restart/8)+(ss_text_character_y_restart*extra_pf1_plane_width*extra_pf1_depth),d0
  add.l   (a1),d0
  swap    d0                 ;High
  COPMOVE d0,BLTDPTH         ;Playfield
  swap    d0                 ;Low
  COPMOVE d0,BLTDPTL
  COPMOVEQ ss_image_plane_width-ss_text_character_width,BLTAMOD
  COPMOVEQ extra_pf1_plane_width-ss_text_character_width,BLTDMOD
  COPMOVEQ (ss_copy_character_blit_y_size*64)+(ss_copy_character_blit_x_size/16),BLTSIZE
  rts

  CNOP 0,4
cl1_init_horiz_scroll_blit
  COPWAITBLIT
  COPMOVEQ DMAF_BLITHOG+DMAF_SETCLR,DMACON ;BLTPRI an
  COPMOVEQ ((-ss_horiz_scroll_speed<<12)+BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC),BLTCON0 ;Minterm D=A
  COPMOVEQ TRUE,BLTCON1
  move.l  extra_pf1(a3),a1   ;Quelle
  move.l  (a1),d0 
  add.l   #ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth,d0
  move.l  d0,d1              ;Erste Zeile
  COPMOVEQ FALSEW,BLTAFWM
  addq.l  #2,d0              ;Erste Zeile, 16 Pixel überspringen
  COPMOVEQ FALSEW,BLTALWM
  swap    d0                 ;High
  COPMOVE d0,BLTAPTH
  swap    d0                 ;Low
  COPMOVE d0,BLTAPTL
  swap    d1                 ;High
  COPMOVE d1,BLTDPTH
  swap    d1                 ;Low
  COPMOVE d1,BLTDPTL
  COPMOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTAMOD
  COPMOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTDMOD
  COPMOVEQ (ss_horiz_scroll_blit_y_size*64)+(ss_horiz_scroll_blit_x_size/16),BLTSIZE
  rts

  COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction1(a3),a0 ;Aufbau-CL
  bsr.s   cl2_init_blit_steady_registers
  bsr.s   cl2_init_sine_scroll_blits
  bsr     cl2_init_copperlist_branch
  bsr     cl2_init_clear_blit
  bsr     cl2_init_BPLCON4_registers
  IFEQ tb31612_restore_cl_blitter_enabled
    IFNE tb31612_quick_clear_enabled
      bsr     cl2_init_restore_blit
    ENDC
  ENDC
  bsr     cl2_init_copint
  COPLISTEND
  bsr     copy_second_copperlist
;  bsr     swap_second_copperlist
  bsr     swap_playfield1
  bsr     ss_horiz_scrolltext_init
  bsr     tb31612_clear_second_copperlist
  bsr     bf_clear_buffer
  IFNE tb31612_quick_clear_enabled
    IFEQ tb31612_restore_cl_blitter_enabled
      bsr     tb31612_restore_second_copperlist
    ENDC
  ENDC
  bsr     sine_scroll
  bsr     swap_second_copperlist
  bsr     swap_playfield1
  bsr     tb31612_clear_second_copperlist
  IFNE tb31612_quick_clear_enabled
    IFEQ tb31612_restore_cl_blitter_enabled
      bsr     tb31612_restore_second_copperlist
    ENDC
  ENDC
  bsr     sine_scroll
  bsr     swap_second_copperlist
  bsr     swap_playfield1
  bsr     tb31612_clear_second_copperlist
  IFEQ tb31612_restore_cl_blitter_enabled
    IFNE tb31612_quick_clear_enabled
      bsr     tb31612_restore_second_copperlist
    ENDC
  ENDC
  bra     sine_scroll

  CNOP 0,4
cl2_init_blit_steady_registers
  COPWAITBLIT
  COPMOVEQ pf1_plane_width-ss_text_character_width,BLTBMOD
  COPMOVEQ extra_pf1_plane_width-ss_text_character_width,BLTAMOD
  COPMOVEQ pf1_plane_width-ss_text_character_width,BLTDMOD
  rts

  CNOP 0,4
cl2_init_sine_scroll_blits
  move.l  extra_pf1(a3),a1   ;Quellbild
  moveq   #visible_pixels_number/8,d2 ;Zeiger auf Ende der Zeile
  add.l   (a1),d2
  move.l  d2,d3              ;Quellbild
  add.l   #ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth,d3 ;Quellbild-2
  moveq   #(visible_pixels_number/16)-1,d7 ;Anzahl der Wörter
cl2_init_sine_scroll_blits_loop1
  COPMOVEQ BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;D=A
  MOVEF.W FALSEB>>(8-ss_text_columns_x_size),d1 ;Maske
  COPMOVE d1,BLTALWM         ;Maske
  swap    d2
  COPMOVE d2,BLTAPTH         ;Scrolltext
  swap    d2
  COPMOVE d2,BLTAPTL
  COPMOVEQ TRUE,BLTDPTH
  COPMOVEQ TRUE,BLTDPTL
  COPMOVEQ (ss_copy_column_blit_y_size1*64)+(ss_copy_column_blit_x_size1/16),BLTSIZE
  COPWAITBLIT

  COPMOVEQ BC0F_SRCA+BC0F_SRCB+BC0F_DEST+NABNC+NABC+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;D=A+B

  subq.l  #ss_sine_character_width,d2 ;nächster Char in Quellbild-1
  moveq   #ss_text_columns_per_word-2,d6 ;Anzahl der Spalten pro Wort
cl2_init_sine_scroll_blits_loop2
  IFEQ ss_text_columns_x_size-1
    MULUF.W 2,d1              ;Maske 1 Bit nach links verschieben
  ELSE
    IFEQ ss_text_columns_x_size-2
      MULUF.W 4,d1            ;Maske 2 Bits nach links verschieben
    ELSE
      lsl.w   #ss_text_columns_x_size,d1 ;Maske n Bits nach links verschieben
    ENDC
  ENDC
  COPMOVE d1,BLTALWM
  swap    d3
  COPMOVEQ TRUE,BLTBPTH
  COPMOVEQ TRUE,BLTBPTL
  COPMOVE d3,BLTAPTH         ;Scrolltext
  swap    d3
  COPMOVE d3,BLTAPTL
  COPMOVEQ TRUE,BLTDPTH
  COPMOVEQ TRUE,BLTDPTL
  COPMOVEQ (ss_copy_column_blit_y_size2*64)+(ss_copy_column_blit_x_size2/16),BLTSIZE
  COPWAITBLIT
  dbf     d6,cl2_init_sine_scroll_blits_loop2
  subq.l  #ss_sine_character_width,d3 ;nächster Char in Quellbild-2
  dbf     d7,cl2_init_sine_scroll_blits_loop1
  rts

  CNOP 0,4
cl2_init_copperlist_branch
  COPMOVE cl1_display(a3),COP1LCH
  COPMOVE cl1_display+2(a3),COP1LCL
  rts

  CNOP 0,4
cl2_init_clear_blit
  COPMOVEQ DMAF_BLITHOG,DMACON ;BLTPRI aus
  COPMOVEQ BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0 ;Minterm D=A
  COPMOVEQ FALSEW,BLTALWM    ;Maske aus
  COPMOVEQ TRUE,BLTDPTH
  COPMOVEQ TRUE,BLTDPTL
  COPMOVEQ 2,BLTDMOD
  IFEQ tb31612_quick_clear_enabled
    COPMOVEQ -2,BLTADAT      ;Quelle = BPLCON4-Bits
  ELSE
    COPMOVEQ BPLCON4BITS,BLTADAT ;Quelle = BPLCON4-Bits
  ENDC
  COPMOVEQ tb31612_clear_blit_y_size,BLTSIZV ;Anzahl der Zeilen
  COPMOVEQ tb31612_clear_blit_x_size/16,BLTSIZH ;Anzahl der Wörter & Blitter starten
  rts

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_HSTART1,cl2_VSTART1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,tb31612_quick_clear_enabled,TRUE

  IFEQ tb31612_restore_cl_blitter_enabled
    IFNE tb31612_quick_clear_enabled
      CNOP 0,4
cl2_init_restore_blit
      COPWAITBLIT
      COPMOVEQ TRUE,BLTDPTH
      COPMOVEQ TRUE,BLTDPTL
      COPMOVEQ cl2_extension7_SIZE-tb31612_restore_blit_width,BLTDMOD
      COPMOVEQ -2,BLTADAT ;Quelle = 2. Wort in CWAIT
      COPMOVEQ (tb31612_restore_blit_y_size*64)+(tb31612_restore_blit_x_size/16),BLTSIZE ;Anzahl der Zeilen
      rts
    ENDC
  ENDC

  COP_INIT_COPINT cl2,cl2_HSTART2,cl2_VSTART2

  COPY_COPPERLIST cl2,3


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
  bsr.s   swap_playfield1
  bsr     effects_handler
  bsr     ss_horiz_scrolltext
  bsr     tb31612_clear_second_copperlist
  bsr     sine_scroll
  bsr     chunky_columns_fader_in
  bsr     chunky_columns_fader_out
  bsr     tb31612_set_background_bars
  bsr     set_wave_center_bar
  bsr     tb31612_set_foreground_bars
  tst.w   bf_active(a3)
  bne.s   no_barfield
  bsr     bf_clear_buffer
  bsr     bf_set_bars
no_barfield
  bsr     bf_copy_buffer
  bsr     tb31612_get_yz_coordinates
  bsr     we_get_y_coordinates
  IFNE tb31612_quick_clear_enabled
    bsr     restore_second_copperlist
  ENDC
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.l  nop_second_copperlist,COP2LC-DMACONR(a6) ;2. Copperliste deaktivieren
  move.w  d0,COPJMP2-DMACONR(a6)
  move.w  custom_error_code(a3),d1
  rts


; ** Copperlisten vertauschen **
; ------------------------------
  SWAP_COPPERLIST cl2,3

; ** Playfields vertauschen **
; ----------------------------
  SWAP_PLAYFIELD pf1,2,pf1_depth3,pf1_bitplane_x_offset,pf1_bitplane_y_offset


; ** Laufschrift **
; -----------------
  CNOP 0,4
ss_horiz_scrolltext
  tst.w   ss_enabled(a3)
  bne.s   ss_no_horiz_scrolltext
ss_horiz_scrolltext_init
  move.w  ss_text_character_x_shift(a3),d2 ;X-Shift-Wert
  MOVEF.L cl1_extension3_entry,d3 ;Einsprung bei Vertical-Scroll-Blit
  move.l  cl1_display(a3),a2 
  addq.w  #ss_horiz_scroll_speed,d2 ;erhöhen
  cmp.w   #ss_text_character_x_shift_max,d2 ;X-Shift-Wert < Maximum ?
  blt.s   ss_set_character_x_shift ;Ja -> verzweige
ss_new_character_image
  bsr.s   ss_get_new_character_image
  move.w  d0,cl1_extension2_entry+cl1_ext2_BLTAPTL+2(a2) ;Character-Image
  swap    d0
  moveq   #TRUE,d2           ;X-Shift-Wert zurücksetzen
  move.w  d0,cl1_extension2_entry+cl1_ext2_BLTAPTH+2(a2)
  MOVEF.L cl1_extension2_entry,d3 ;Einsprung bei Charset-Blit
ss_set_character_x_shift
  move.w  d2,ss_text_character_x_shift(a3) 
ss_set_copper_jump_entry
  add.l   a2,d3
  move.w  d3,cl1_extension1_entry+cl1_ext1_COP1LCL+2(a2) ;Sprungadresse eintragen
  swap    d3                 ;High
  move.w  d3,cl1_extension1_entry+cl1_ext1_COP1LCH+2(a2)
ss_no_horiz_scrolltext
  rts

; ** Neues Image für Character ermitteln **
; -----------------------------------------
  GET_NEW_CHARACTER_IMAGE.W ss

; ** Copperliste löschen **
; -------------------------
tb31612_clear_second_copperlist
  move.l  cl2_construction1(a3),a0
  ADDF.W  cl2_extension6_entry+2,a0
  move.l  cl2_construction2(a3),d0
  add.l   #cl2_extension7_entry+cl2_ext7_WAIT+2,d0
  move.w  d0,cl2_ext6_BLTDPTL(a0) ;Ziel = Copperliste
  swap    d0                 ;High
  move.w  d0,cl2_ext6_BLTDPTH(a0)
  rts

; ** Sinus-Laufschrift **
; ------------------------
  CNOP 0,4
sine_scroll
  move.l  a4,-(a7)
  MOVEF.W ss_text_y_center,d2
  MOVEF.L cl2_extension2_SIZE+cl2_extension3_SIZE,d3
  MOVEF.L cl2_extension4_SIZE,d4
  lea     we_y_coordinates(pc),a0 ;Tabelle mit Y-Koords
  move.l  pf1_construction2(a3),a1 ;Zielbild
  move.l  (a1),a1
  add.l   #((visible_pixels_number+ss_text_x_position)-ss_text_character_x_size)/8,a1 ;Ende der Zeile in Zielbild
  lea     ss_text_y_position*pf1_plane_width*pf1_depth3(a1),a2 ;Zielbild-2
  move.l  cl2_construction2(a3),a4 ;Zeiger auf Copperliste
  ADDF.W  cl2_extension2_entry+2,a4
  moveq   #(visible_pixels_number/16)-1,d7 ;Anzahl der Wörter
sine_scroll_loop1
  moveq   #0,d0           ;Langwort-Zugriff
  move.w  (a0)+,d0           ;Y-Offset
  add.w   d2,d0              ;y' + Y-Mittelpunkt
  MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ;Y-Offset in Zielbild-1
  add.l   a1,d0              ;Zielbild + Y-Offset
  subq.w  #ss_sine_character_width,a1 ;nächter Char in Zielbild-1
  move.w  d0,cl2_ext2_BLTDPTL(a4) ;Playfield schreiben
  swap    d0                 ;High
  add.l   d3,a4              ;nächster Blit in CL
  move.w  d0,cl2_ext2_BLTDPTH-(cl2_extension2_SIZE+cl2_extension3_SIZE)(a4) ;Playfield schreiben
;  moveq   #tb31612_columns_per_word-2,d6 ;Anzahl der Spalten pro Wort
;sine_scroll_loop2
  moveq   #0,d0           ;Langwort-Zugriff
  move.w  (a0)+,d0           ;Y-Offset
  add.w   d2,d0              ;y' + Y-Mittelpunkt
  MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ;Y-Offset uin Zielbild-2
  add.l   a2,d0              ;Zielbild + Y-Offset
  move.w  d0,cl2_ext4_BLTBPTL(a4) ;Playfield lesen
  subq.w  #ss_sine_character_width,a2 ;nächster Char in Zielbild-2
  move.w  d0,cl2_ext4_BLTDPTL(a4) ;Playfield schreiben
  swap    d0                 ;High
  move.w  d0,cl2_ext4_BLTBPTH(a4) ;Playfield lesen
  add.l   d4,a4              ;nächster Blit in CL
  move.w  d0,cl2_ext4_BLTDPTH-cl2_extension4_SIZE(a4) ;Playfield schreiben
;  dbf     d6,sine_scroll_loop2
  dbf     d7,sine_scroll_loop1
  move.l  (a7)+,a4
  rts

; ** Hintere Stangen in Copperliste kopieren **
; ---------------------------------------------
  CNOP 0,4
tb31612_set_background_bars
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)
  moveq   #tb31612_bar_height,d4
  lea     tb31612_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension7_entry+cl2_ext7_BPLCON4_1+2,a2
  move.l  extra_memory(a3),a5 ;Zeiger auf Tabelle mit Switchwerten
  lea     tb31612_fader_columns_mask(pc),a6
  lea     we_y_coordinates_end(pc),a7 ;Ende der Y-Koords-Tabelle
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb31612_set_background_bars_loop1
  move.w  -(a7),d0           ;2. Y-Offset
  tst.b   (a6)+              ;Spalte darstellen ?
  bne     tb31612_skip_column1    ;Nein -> verzweige
  MULUF.W cl2_extension7_SIZE/4,d0,d1 ;Y-Offset in CL
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  lea     (a2,d0.w*4),a3     ;+ 2. Y-Offset
  moveq   #tb31612_bars_number-1,d6 ;Anzahl der Stangen
tb31612_set_background_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  bmi     tb31612_skip_background_bar ;Wenn Z negativ -> verzweige
tb31612_set_background_bar
  lea     (a3,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.B tb31612,cl2,extension7,bar_height
tb31612_no_background_bar
  dbf     d6,tb31612_set_background_bars_loop2
tb31612_no_column1
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,tb31612_set_background_bars_loop1
  move.l  variables+save_a7(pc),a7
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
tb31612_skip_column1
  ADDF.W  tb31612_bars_number*LONGWORDSIZE,a0 ;Z + Y überspringen
  bra.s   tb31612_no_column1
  CNOP 0,4
tb31612_skip_background_bar
  add.l   d4,a1              ;Switchwerte überspringen
  bra.s   tb31612_no_background_bar

; ** Wave-Center-Bar setzen **
; ----------------------------
  CNOP 0,4
set_wave_center_bar
  movem.l a4-a6,-(a7)
  moveq   #wcb_y_center,d4
  MOVEF.L cl2_extension7_SIZE*40,d5
  lea     we_y_coordinates_end(pc),a0 ;Ende der Y-Koords-Tab.
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension7_entry+cl2_ext7_BPLCON4_1+2,a2 
  move.l  extra_memory(a3),a5
  add.l   #em_switch_table2,a5 ;Zeiger auf Tabelle mit Switchwerten
  lea     wcb_fader_columns_mask(pc),a6
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
set_center_bar_loop1
  move.w  -(a0),d0           ;Y-Pos. 
  tst.b   (a6)+
  bne     wcb_skip_column
  add.w   d4,d0              ;y' + Y-Mittelpunkt
  MULUF.W cl2_extension7_SIZE/4,d0,d1 ;Y-Offset in CL
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  lea     (a2,d0.w*4),a4     ;+ Y-Offset in CL
  MOVEF.W (wcb_bar_height/40)-1,d6 ;Höhe der Bar
set_center_bar_loop2
  movem.l (a1)+,d0-d3        ;16 Switchwerte lesen
  move.b  d0,cl2_extension7_SIZE*3(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*1(a4)
  lsr.l   #8,d0
  move.b  d0,(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*2(a4)
  move.b  d1,cl2_extension7_SIZE*7(a4)
  swap    d1
  move.b  d1,cl2_extension7_SIZE*5(a4)
  lsr.l   #8,d1
  move.b  d1,cl2_extension7_SIZE*4(a4)
  swap    d1
  move.b  d1,cl2_extension7_SIZE*6(a4)
  move.b  d2,cl2_extension7_SIZE*11(a4)
  swap    d2
  move.b  d2,cl2_extension7_SIZE*9(a4)
  lsr.l   #8,d2
  move.b  d2,cl2_extension7_SIZE*8(a4)
  swap    d2
  move.b  d2,cl2_extension7_SIZE*10(a4)
  move.b  d3,cl2_extension7_SIZE*15(a4)
  swap    d3
  move.b  d3,cl2_extension7_SIZE*13(a4)
  lsr.l   #8,d3
  move.b  d3,cl2_extension7_SIZE*12(a4)
  swap    d3
  move.b  d3,cl2_extension7_SIZE*14(a4)
  movem.l (a1)+,d0-d3        ;weitere 16 Switchwerte lesen
  move.b  d0,cl2_extension7_SIZE*19(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*17(a4)
  lsr.l   #8,d0
  move.b  d0,cl2_extension7_SIZE*16(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*18(a4)
  move.b  d1,cl2_extension7_SIZE*23(a4)
  swap    d1
  move.b  d1,cl2_extension7_SIZE*21(a4)
  lsr.l   #8,d1
  move.b  d1,cl2_extension7_SIZE*20(a4)
  swap    d1
  move.b  d1,cl2_extension7_SIZE*22(a4)
  move.b  d2,cl2_extension7_SIZE*27(a4)
  swap    d2
  move.b  d2,cl2_extension7_SIZE*25(a4)
  lsr.l   #8,d2
  move.b  d2,cl2_extension7_SIZE*24(a4)
  swap    d2
  move.b  d2,cl2_extension7_SIZE*26(a4)
  move.b  d3,cl2_extension7_SIZE*31(a4)
  swap    d3
  move.b  d3,cl2_extension7_SIZE*29(a4)
  lsr.l   #8,d3
  move.b  d3,cl2_extension7_SIZE*28(a4)
  swap    d3
  move.b  d3,cl2_extension7_SIZE*30(a4)
  movem.l (a1)+,d0-d1        ;weitere 16 Switchwerte lesen
  move.b  d0,cl2_extension7_SIZE*35(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*33(a4)
  lsr.l   #8,d0
  move.b  d0,cl2_extension7_SIZE*32(a4)
  swap    d0
  move.b  d0,cl2_extension7_SIZE*34(a4)
  add.l   d5,a4              ;40 Zeilen überpspringen
  move.b  d1,(cl2_extension7_SIZE*39)-(cl2_extension7_SIZE*40)(a4)
  swap    d1
  move.b  d1,(cl2_extension7_SIZE*37)-(cl2_extension7_SIZE*40)(a4)
  lsr.l   #8,d1
  move.b  d1,(cl2_extension7_SIZE*36)-(cl2_extension7_SIZE*40)(a4)
  swap    d1
  move.b  d1,(cl2_extension7_SIZE*38)-(cl2_extension7_SIZE*40)(a4)
  dbf     d6,set_center_bar_loop2
wcb_skip_column
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,set_center_bar_loop1
  movem.l (a7)+,a4-a6
  rts

; ** Vordere Stangen in Copperliste kopieren **
; ---------------------------------------------
  CNOP 0,4
tb31612_set_foreground_bars
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)
  moveq   #tb31612_bar_height,d4
  lea     tb31612_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension7_entry+cl2_ext7_BPLCON4_1+2,a2
  move.l  extra_memory(a3),a5 ;Zeiger auf Tabelle mit Switchwerten
  lea     tb31612_fader_columns_mask(pc),a6
  lea     we_y_coordinates_end(pc),a7 ;Ende der Y-Koords-Tab.
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb31612_set_foreround_bars_loop1
  move.w  -(a7),d0           ;2. Y-Offset
  tst.b   (a6)+              ;Spalte darstellen ?
  bne     tb31612_skip_column2    ;Nein -> verzweige
  MULUF.W cl2_extension7_SIZE/4,d0,d1 ;Y-Offset in CL
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  lea     (a2,d0.w*4),a3     ;+ 2. Y-Offset
  moveq   #tb31612_bars_number-1,d6  ;Anzahl der Stangen
tb31612_set_foreround_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  bpl     tb31612_skip_foreground_bar ;Wenn Z positiv -> verzweige
tb31612_set_foreground_bar
  lea     (a3,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.B tb31612,cl2,extension7,bar_height
tb31612_no_foreground_bar
  dbf     d6,tb31612_set_foreround_bars_loop2
tb31612_no_column2
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,tb31612_set_foreround_bars_loop1
  move.l  variables+save_a7(pc),a7
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
tb31612_skip_column2
  ADDF.W  tb31612_bars_number*LONGWORDSIZE,a0 ;Z + Y überspringen
  bra.s   tb31612_no_column2
  CNOP 0,4
tb31612_skip_foreground_bar
  add.l   d4,a1              ;Switchwerte überspringen
  bra.s   tb31612_no_foreground_bar

; **** Barfield ****
; ** Farbwerte in Puffer löschen **
; ---------------------------------
  CNOP 0,4
bf_clear_buffer
  move.l  #COLOR255BITS,d0
  move.l  extra_memory(a3),a0
  add.l   #em_color_buffer+(bf_bar_height*LONGWORDSIZE),a0 ;Puffer
  MOVEF.W visible_lines_number-1,d7 ;Anzahl der Zeilen
bf_clear_buffer_loop
  move.l  d0,(a0)+           ;Farbwert löschen
  dbf     d7,bf_clear_buffer_loop
  rts

; ** Stangen kopieren **
; ----------------------
  CNOP 0,4
bf_set_bars
  movem.l a4-a6,-(a7)
  move.l  a7,save_a7(a3)
  MOVEF.W bf_y_max,d3
  MOVEF.L (((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*4,d4
  lea     bf_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  extra_memory(a3),a2
  add.l   #em_color_buffer,a2 ;Puffer
  lea     bf_color_table_pointers(pc),a5
  move.w  #bf_y_center,a6
  move.w  #bf_z_plane1,a7
  moveq   #bf_bars_planes_number-1,d7 ;Anzahl der Ebenen
bf_set_bars_loop1
  moveq   #bf_bars_per_plane-1,d6 ;Anzahl der Stangen pro Ebene
bf_set_bars_loop2
  move.w  (a0)+,d0           ;Y lesen
  move.w  (a0)+,d1           ;Z lesen
  ble.s   bf_restart_z_plane ;Wenn Z <= Null -> verzweige
  MULSF.W bf_d,d0            ;y*d
  moveq   #bf_d,d2
  add.w   d1,d2              ;z+d
  divs.w  d2,d0              ;y'=(y*d)/(z+d)
  add.w   a6,d0              ;y' + Y-Mittelpunkt
  bmi.s   bf_restart_z_plane ;Wenn Y < Y-Min -> verzweige
  cmp.w   d3,d0              ;Wenn Y > Y-Max -> verzweige
  bge.s   bf_restart_z_plane
bf_copy_bar
  move.l  (a5),a1
  subq.w  #4,a1              ;Zeiger auf Farbtabelle
  moveq   #TRUE,d2           ;Z-Planes
  moveq   #bf_z_planes_number-1,d5 ;Anzahl der Z-Ebenen
bf_set_bars_loop3
  addq.w  #4,a1              ;Farbtabelle überspringen
  add.w   a7,d2              ;nächste Z-Plane
  cmp.w   d2,d1              ;Z < Z-Ebene
  dblt    d5,bf_set_bars_loop3
bf_z_plane_found
  subq.w  #bf_z_speed,d1     ;Z-Koord reduzieren
  lea     (a2,d0.w*4),a4     ;Y-Offset in Puffer
  move.w  d1,-2(a0)          ;Z retten
  moveq   #bf_bar_height-1,d5 ;Höhe der Bar
bf_set_bars_loop4
  move.l  (a1),d0            ;RGB8-Farbwert
  beq.s   bf_no_rgb8_value   ;Wenn Null -> verzweige
  move.l  d0,(a4)+           
bf_no_rgb8_value
  add.l   d4,a1              ;nächste Zeile in Farbtabelle
  dbf     d5,bf_set_bars_loop4
  dbf     d6,bf_set_bars_loop2
bf_no_bar
  addq.w  #4,a5              ;nächste Farbtabelle
  dbf     d7,bf_set_bars_loop1
  move.l  variables+save_a7(pc),a7
  movem.l (a7)+,a4-a6
  rts
  CNOP 0,4
bf_restart_z_plane
  tst.w   bf_z_restart_active(a3) ;Z-Ebene zurücksetzen ?
  bne.s   bf_no_bar        ;Nein -> Keine Bar darstellen
  subq.w  #4,a0
  move.w  #bf_z_plane1*bf_z_planes_number,2(a0) ;Hinterste Z-Ebene setzen
  bra.s   bf_set_bars_loop2

; ** Farbwerte aus Puffer in Copperliste kopieren **
; --------------------------------------------------
  CNOP 0,4
bf_copy_buffer
  movem.l a4-a5,-(a7)
  move.w  #$0f0f,d3          ;Maske für RGB-Nibbles
  move.l  extra_memory(a3),a0
  add.l   #em_color_buffer+(bf_bar_height*4),a0 ;Puffer
  move.l  cl2_construction2(a3),a1 
    IFEQ tb31612_quick_clear_enabled
      ADDF.W  cl2_extension7_entry+cl2_ext7_COLOR31_high+2,a1
      move.w  #BPLCON3BITS3,a2 ;High-RGB-Werte
      move.w  #BPLCON3BITS4,a4 ;Low-RGB-Werte
    ELSE
      ADDF.W  cl2_extension7_entry+cl2_ext7_COLOR00_high+2,a1
      move.w  #BPLCON3BITS1,a2 ;High-RGB-Werte
      move.w  #BPLCON3BITS2,a4 ;Low-RGB-Werte
    ENDC
  move.w  #cl2_extension7_SIZE,a5
  MOVEF.W visible_lines_number-1,d7 ;Anzahl der Zeilen
bf_copy_buffer_loop
  move.l  (a0)+,d0
  move.l  d0,d2              
    IFEQ tb31612_quick_clear_enabled
      move.w  a2,cl2_ext7_BPLCON3_1-cl2_ext7_COLOR31_high(a1) ;CMOVE wiederherstellen
    ELSE
      move.w  a2,cl2_ext7_BPLCON3_1-cl2_ext7_COLOR00_high(a1) ;CMOVE wiederherstellen
    ENDC
  RGB8_TO_RGB4HI d0,d1,d3
  move.w  d0,(a1)            ;COLOR00 High-Wert
  RGB8_TO_RGB4LO d2,d1,d3
    IFEQ tb31612_quick_clear_enabled
      move.w  d2,cl2_ext7_COLOR31_low-cl2_ext7_COLOR31_high(a1) ;COLOR31 Low-Bits
    ELSE
      move.w  d2,cl2_ext7_COLOR00_low-cl2_ext7_COLOR00_high(a1) ;COLOR00 Low-Bits
    ENDC
  add.l   a5,a1              ;nächste Zeile in CL
    IFEQ tb31612_quick_clear_enabled
      move.w  a4,cl2_ext7_BPLCON3_2-cl2_ext7_COLOR31_high-cl2_extension7_SIZE(a1) ;CMOVE wiederherstellen
    ELSE
      move.w  a4,cl2_ext7_BPLCON3_2-cl2_ext7_COLOR00_high-cl2_extension7_SIZE(a1) ;CMOVE wiederherstellen
    ENDC
  dbf     d7,bf_copy_buffer_loop
  movem.l (a7)+,a4-a5
  rts

; ** Y+Z-Koordinaten berechnen **
; -------------------------------
  GET_TWISTED_BARS_YZ_COORDINATES tb31612,256,cl2_extension7_SIZE

; ** Y-Koordinaten für Wave-Effect berechnen **
; ---------------------------------------------
  CNOP 0,4
we_get_y_coordinates
  move.w  we_radius_y_angle(a3),d2 ;1. Winkel Y-Radius
  move.w  d2,d0              
  move.w  we_y_angle(a3),d3  ;1. Y-Winkel
  addq.b  #we_y_radius_angle_speed,d0 ;nächster Y-Radius-Winkel
  move.w  d0,we_radius_y_angle(a3) 
  move.w  d3,d0              
  addq.b  #we_y_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,we_y_angle(a3)  
  lea     sine_table(pc),a0  
  lea     we_y_coordinates(pc),a1 ;Y-Koords.
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
we_get_y_coordinates_loop
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L we_y_radius*4,d0,d1 ;yr'=(yr*sin(w))/2^15
  swap    d0
  muls.w  2(a0,d3.w*4),d0    ;y'=(yr'*sin(w))/2^15
  swap    d0
  move.w  d0,(a1)+           ;Y-Pos.
  addq.b  #we_y_radius_angle_step,d2 ;nächster Y-Radius-Winkel
  addq.b  #we_y_angle_step,d3 ;nächster Y-Winkel
  dbf     d7,we_get_y_coordinates_loop
  rts

; ** Copper-WAIT-Befehle wiederherstellen **
; ------------------------------------------
  IFNE tb31612_quick_clear_enabled
    RESTORE_BPLCON4_CHUNKY_SCREEN tb,cl2,construction2,extension7,32,,tb31612_restore_blit
    IFEQ tb31612_restore_cl_blitter_enabled
tb31612_restore_blit
      move.l  cl2_construction1(a3),a0 
      add.l   #cl2_extension8_entry+cl2_ext8_BLTDPTH+2,a0
      move.l  cl2_construction2(a3),d0
      add.l   #cl2_extension7_entry+cl2_ext7_WAIT+2,d0
      move.w  d0,cl2_ext8_BLTDPTL-cl2_ext8_BLTDPTH(a0) ;Ziel = Copperliste
      swap    d0                 ;High
      move.w  d0,(a0)            ;BLTDPTH
      rts
    ENDC
  ENDC


; ** Spalten einblenden **
; ------------------------
  CNOP 0,4
chunky_columns_fader_in
  tst.w   ccfi_active(a3)    ;Chunky-Columns-Fader-In an ?
  bne.s   ccfi_no_chunky_columns_fader_in ;Nein -> verzweige
  subq.w  #ccfi_delay_speed,ccfi_columns_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   ccfi_no_chunky_columns_fader_in ;Wenn > Null -> verzweige
  move.w  ccfi_columns_delay_reset(a3),ccfi_columns_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  ccfi_start(a3),d1  ;Startwert in Spalten-Statustabelle
  moveq   #cl2_display_width-1,d2 ;Anzahl der Spalten
  move.l  ccf_fader_columns_mask(a3),a0 ;Tabelle mit Status der Spalten
  move.w  ccfi_current_mode(a3),d0 ;Fader-In-Modus 
  beq.s   ccfi_mode1_column_fader_in ;Wenn Fader-In-Modus1 -> verzweige
  subq.w  #1,d0              ;Fader-In-Modus2 ?
  beq.s   ccfi_mode2_column_fader_in ;Ja -> verzweige
  subq.w  #1,d0              ;Fader-In-Modus3 ?
  beq.s   ccfi_mode3_column_fader_in ;Ja -> verzweige
  subq.w  #1,d0              ;Fader-In-Modus4 ?
  beq.s   ccfi_mode4_column_fader_in ;Ja -> verzweige
ccfi_no_chunky_columns_fader_in
  rts
; ** Spalten von links nach rechts einblenden **
  CNOP 0,4
ccfi_mode1_column_fader_in
  clr.b   (a0,d1.w)          ;Spaltenstatus = TRUE (einblenden)
  addq.w  #1,d1              ;nächste Spalte
  cmp.w   d2,d1              ;Alle Spalten eingeblendet ?
  bgt.s   ccfi_stop_column_fader_in ;Ja -> verzweige
  move.w  d1,ccfi_start(a3)  ;neuen Startwert retten
  rts
; ** Spalten von rechts nach links einblenden **
  CNOP 0,4
ccfi_mode2_column_fader_in
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #1,d1              ;nächste Spalte
  clr.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = TRUE (einblenden)
  cmp.w   d2,d1              ;Alle Spalten eingeblendet ?
  bgt.s   ccfi_stop_column_fader_in ;Ja -> verzweige
  move.w  d1,ccfi_start(a3)  ;neuen Startwert retten
  rts
; ** Spalten gleichzeitig von links und rechts zur Mitte hin einblenden **
  CNOP 0,4
ccfi_mode3_column_fader_in
  clr.b   (a0,d1.w)          ;Spaltenstatus = TRUE (einblenden)
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #1,d1              ;nächste Spalte
  lsr.w   #1,d2              ;Hälfte der Spalten = Mittelpunkt
  clr.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = TRUE (einblenden)
  cmp.w   d2,d1              ;Alle Spalten eingeblendet ?
  bgt.s   ccfi_stop_column_fader_in ;Ja -> verzweige
  move.w  d1,ccfi_start(a3)  ;neuen Startwert retten
  rts
; ** Jede 2. Spalte gleichzeitig von links und rechts einblenden **
  CNOP 0,4
ccfi_mode4_column_fader_in
  clr.b   (a0,d1.w)          ;Spaltenstatus = TRUE (einblenden)
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #2,d1              ;übernächste Spalte
  clr.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = TRUE (einblenden)
  cmp.w   d2,d1              ;Alle Spalten eingeblendet ?
  bgt.s   ccfi_stop_column_fader_in ;Ja -> verzweige
  move.w  d1,ccfi_start(a3)  ;neuen Startwert retten
  rts
  CNOP 0,4
ccfi_stop_column_fader_in
  moveq   #FALSE,d0
  move.w  d0,ccfi_active(a3) ;Chunky-Columns-Fader-In aus
  rts

; ** Spalten ausblenden **
; ------------------------
  CNOP 0,4
chunky_columns_fader_out
  tst.w   ccfo_active(a3)    ;Chunky-Columns-Fader-Out an ?
  bne.s   ccfo_no_chunky_columns_fader_out ;Neout -> verzweige
  subq.w  #ccfo_delay_speed,ccfo_columns_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   ccfo_no_chunky_columns_fader_out ;Wenn > Null -> verzweige
  move.w  ccfo_columns_delay_reset(a3),ccfo_columns_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  ccfo_start(a3),d1  ;Startwert out Spalten-Statustabelle
  moveq   #cl2_display_width-1,d2 ;Anzahl der Spalten
  move.l  ccf_fader_columns_mask(a3),a0 ;Tabelle mit Status der Spalten
  move.w  ccfo_current_mode(a3),d0 ;Fader-Out-Modus 
  beq.s   ccfo_mode1_column_fader_out ;Wenn Fader-Out-Modus1 -> verzweige
  subq.w  #1,d0              ;Fader-Out-Modus2 ?
  beq.s   ccfo_mode2_column_fader_out ;Ja -> verzweige
  subq.w  #1,d0              ;Fader-Out-Modus3 ?
  beq.s   ccfo_mode3_column_fader_out ;Ja -> verzweige
  subq.w  #1,d0              ;Fader-Out-Modus4 ?
  beq.s   ccfo_mode4_column_fader_out ;Ja -> verzweige
ccfo_no_chunky_columns_fader_out
  rts
; ** Spalten von links nach rechts ausblenden **
  CNOP 0,4
ccfo_mode1_column_fader_out
  not.b   (a0,d1.w)          ;Spaltenstatus = FALSE (ausblenden)
  addq.w  #1,d1              ;nächste Spalte
  cmp.w   d2,d1              ;Alle Spalten eoutgeblendet ?
  bgt.s   ccfo_stop_column_fader_out ;Ja -> verzweige
  move.w  d1,ccfo_start(a3)  ;neuen Startwert retten
  rts
; ** Spalten von rechts nach links ausblenden **
  CNOP 0,4
ccfo_mode2_column_fader_out
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #1,d1              ;nächste Spalte
  not.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = FALSE (ausblenden)
  cmp.w   d2,d1              ;Alle Spalten ausgeblendet ?
  bgt.s   ccfo_stop_column_fader_out ;Ja -> verzweige
  move.w  d1,ccfo_start(a3)  ;neuen Startwert retten
  rts
; ** Spalten gleichzeitig von links und rechts zur Mitte hin ausblenden **
  CNOP 0,4
ccfo_mode3_column_fader_out
  not.b   (a0,d1.w)          ;Spaltenstatus = FALSE (ausblenden)
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #1,d1              ;nächste Spalte
  lsr.w   #1,d2              ;Hälfte der Spalten = Mittelpunkt
  not.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = FALSE (ausblenden)
  cmp.w   d2,d1              ;Alle Spalten eoutgeblendet ?
  bgt.s   ccfo_stop_column_fader_out ;Ja -> verzweige
  move.w  d1,ccfo_start(a3)  ;neuen Startwert retten
  rts
; ** Jede 2. Spalte gleichzeitig von links und rechts ausblenden **
  CNOP 0,4
ccfo_mode4_column_fader_out
  not.b   (a0,d1.w)          ;Spaltenstatus = FALSE (ausblenden)
  move.w  d1,d0              ;Startwert retten
  neg.w   d0                 ;Vorzeichen umdrehen
  addq.w  #2,d1              ;übernächste Spalte
  not.b   cl2_display_width-1(a0,d0.w) ;Spaltenstatus = FALSE (ausblenden)
  cmp.w   d2,d1              ;Alle Spalten eoutgeblendet ?
  bgt.s   ccfo_stop_column_fader_out ;Ja -> verzweige
  move.w  d1,ccfo_start(a3)  ;neuen Startwert retten
  rts
  CNOP 0,4
ccfo_stop_column_fader_out
  moveq   #FALSE,d0
  move.w  d0,ccfo_active(a3) ;Chunky-Columns-Fader-Out aus
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
  beq.s   eh_start_barfield
  subq.w  #1,d0
  beq.s   eh_start_wave_center_bar
  subq.w  #1,d0
  beq.s   eh_start_twisted_bars31612
  subq.w  #1,d0
  beq.s   eh_start_horiz_scrolltext
  subq.w  #1,d0
  beq.s   eh_stop_horiz_scrolltext
  subq.w  #1,d0
  beq.s   eh_stop_wave_center_bar
  subq.w  #1,d0
  beq.s   eh_stop_twisted_bars31612
  subq.w  #1,d0
  beq     eh_disable_barfield_z_restart
  subq.w  #1,d0
  beq     eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_barfield
  clr.w   bf_active(a3)      ;Barfield an
  rts
  CNOP 0,4
eh_start_wave_center_bar
  clr.w   ccfi_active(a3)    ;Chunky-Columns-Fader-In an
  moveq   #1,d2
  move.w  d2,ccfi_columns_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_twisted_bars31612
  lea     tb31612_fader_columns_mask(pc),a0
  move.l  a0,ccf_fader_columns_mask(a3) ;Maske setzen
  moveq   #ccfi_mode1,d2
  move.w  d2,ccfi_current_mode(a3) ;Modus setzen
  moveq   #0,d0
  move.w  d0,ccfi_start(a3)  ;Startwert zurücksetzrn
  move.w  d0,ccfi_active(a3) ;Chunky-Columns-Fader-In an
  moveq   #1,d2
  move.w  d2,ccfi_columns_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_horiz_scrolltext
  clr.w   ss_enabled(a3)     ;Sine-Scrolltext an
  rts
  CNOP 0,4
eh_stop_horiz_scrolltext
  moveq   #FALSE,d1
  move.w  d1,ss_enabled(a3)  ;Sine-Scrolltext aus
  rts
  CNOP 0,4
eh_stop_wave_center_bar
  lea     wcb_fader_columns_mask(pc),a0
  move.l  a0,ccf_fader_columns_mask(a3) ;Maske setzen
  moveq   #0,d0
  move.w  d0,ccfo_active(a3) ;Chunky-Columns-Fader-Out an
  moveq   #1,d2
  move.w  d2,ccfo_columns_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_stop_twisted_bars31612
  lea     tb31612_fader_columns_mask(pc),a0
  move.l  a0,ccf_fader_columns_mask(a3) ;Maske setzen
  moveq   #0,d0
  move.w  d0,ccfo_start(a3)  ;Startwert zurücksetzen
  move.w  d0,ccfo_active(a3) ;Chunky-Columns-Fader-Out an
  moveq   #1,d2
  move.w  d2,ccfo_columns_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_disable_barfield_z_restart
  moveq   #FALSE,d0
  move.w  d0,bf_z_restart_active(a3) ;Barfield stoppen
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
  DC.L COLOR00BITS
  DS.L 256-2 ;pf1_colors_number-2
  DC.L COLOR255BITS

; **** Twisted-Bars3.16.1.2 ****
tb31612_bars_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/06_tb31612_Colorgradient.ct"

; ** YZ-Koordinatentabelle Twisted-Sine-Bars **
; ---------------------------------------------
tb31612_yz_coordinates
  DS.W tb31612_bars_number*cl2_display_width*2

; ** Maske für die Spalten **
; ---------------------------
tb31612_fader_columns_mask
  REPT cl2_display_width
    DC.B FALSE
  ENDR

; **** Wave-Center-Bar ****
  CNOP 0,4
wcb_bar_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/06_wcb_Colorgradient.ct"

; ** Maske für die Spalten **
; ---------------------------
wcb_fader_columns_mask
  REPT cl2_display_width
    DC.B FALSE
  ENDR

; **** Wave-Effect ****
; ** Y-Koordinatentabelle des Wave-Effect **
; ------------------------------------------
  CNOP 0,2
we_y_coordinates
  DS.W cl2_display_width
we_y_coordinates_end

; **** Sine-Scrolltext ****
  CNOP 0,4
ss_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/06_ss_Colorgradient.ct"

; ** ASCII-Buchstaben **
; ----------------------
ss_ASCII
  DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/ "
ss_ASCII_end
  EVEN

; ** Offsets der einzelnen Chars **
; ---------------------------------
  CNOP 0,2
ss_characters_offsets
  DS.W ss_ASCII_end-ss_ASCII

; **** Barfield ****
; ** Farbwerte **
; ---------------
  CNOP 0,4
bf_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/06_bf_Colorgradient.ct"

; ** Tabelle mit Zeigern auf Farbtabelle **
; -----------------------------------------
bf_color_table_pointers
  DS.L bf_bars_planes_number

; ** Bitmap-Tabelle für die Zeilen **
; -----------------------------------
bf_bitmap_lines_table
  DS.B bf_source_bar_y_size
  EVEN

; ** YZ-Koordinaten der Bars **
; -----------------------------
  CNOP 0,2
bf_yz_coordinates
  DC.W -900,3000             ;1. Ebene
  DC.W 600,2600              ;2. Ebene
  DC.W -300,2200             ;3. Ebene
  DC.W 150,1800              ;4. Ebene
  DC.W -200,1400             ;5. Ebene
  DC.W 600,1000              ;6. Ebene


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; **** Sine-Scrolltext ****
; ** Text für Laufschrift **
; --------------------------
ss_text
  DC.B "ARTSTATE  "
  DC.B "DESIRE  "
  DC.B "EPHIDRENA  "
  DC.B "FOCUS DESIGN  "
  DC.B "GHOSTOWN  "
  DC.B "NAH-KOLOR  "
  DC.B "PLANET JAZZ  "
  DC.B "SOFTWARE FAILURE  "
  DC.B "TEK  "
  DC.B "WANTED TEAM  "
  DC.B FALSE
  EVEN


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Sine-Scrolltext ****
ss_image_data SECTION ss_gfx,DATA_C
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/fonts/32x32x2-Font.rawblit"

  END
