; #######################################
; # Programm: 04_Twisted-Space-Bars.asm #
; # Autor:    Christian Gerbig          #
; # Datum:    21.12.2023                #
; # Version:  1.3 beta                  #
; # CPU:      68020+                    #
; # FASTMEM:  -                         #
; # Chipset:  AGA                       #
; # OS:       3.0+                      #
; #######################################

  SECTION code_and_variables,CODE

  MC68040


  XREF color00_bits
  XREF mouse_handler
  XREF sine_table

  XDEF start_04_twisted_space_bars


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


SYS_TAKEN_OVER                 SET 1
PASS_GLOBAL_REFERENCES         SET 1
PASS_RETURN_CODE               SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu               EQU FALSE  
requires_040_cpu               EQU FALSE
requires_060_cpu               EQU FALSE
requires_fast_memory           EQU FALSE
requires_multiscan_monitor     EQU FALSE

workbench_start_enabled        EQU FALSE
screen_fader_enabled         EQU FALSE
text_output_enabled            EQU FALSE

open_border_enabled            EQU FALSE ;Sollte FALSE sein, weil bereits durch Bitplanes der Border geöffnet wird.

tb_quick_clear_enabled         EQU FALSE ;Immer FALSE, da COLOR255 nicht die Hintergrundfarbe ist und die Sprites sonst verdeckt werde sowie die Laufschriftfarben falsch dargestellt werdenn!!!
tb_restore_cl_cpu_enabled      EQU TRUE
tb_restore_cl_blitter_enabled  EQU FALSE

dma_bits                       EQU DMAF_BLITTER+DMAF_SPRITE+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
intena_bits                    EQU INTF_SETCLR

ciaa_icr_bits                  EQU CIAICRF_SETCLR
ciab_icr_bits                  EQU CIAICRF_SETCLR

copcon_bits                    EQU 0

pf1_x_size1                    EQU 0
pf1_y_size1                    EQU 0
pf1_depth1                     EQU 0
pf1_x_size2                    EQU 384
pf1_y_size2                    EQU 256
pf1_depth2                     EQU 4
pf1_x_size3                    EQU 384
pf1_y_size3                    EQU 256
pf1_depth3                     EQU 4
pf1_colors_number              EQU 0 ;16

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

pf_extra_number                EQU 0

spr_number                     EQU 8
spr_x_size1                    EQU 0
spr_x_size2                    EQU 64
spr_depth                      EQU 2
spr_colors_number              EQU 16
spr_odd_color_table_select     EQU 1
spr_even_color_table_select    EQU 1
spr_used_number                EQU 8

audio_memory_size              EQU 0

disk_memory_size               EQU 0

extra_memory_size              EQU 0

chip_memory_size               EQU 0
ciaa_ta_time                   EQU 0
ciaa_tb_time                   EQU 0
ciab_ta_time                   EQU 0
ciab_tb_time                   EQU 0
ciaa_ta_continuous_enabled     EQU FALSE
ciaa_tb_continuous_enabled     EQU FALSE
ciab_ta_continuous_enabled     EQU FALSE
ciab_tb_continuous_enabled     EQU FALSE

beam_position                  EQU $136

pixel_per_line                 EQU 320
visible_pixels_number          EQU 320
visible_lines_number           EQU 256
MINROW                         EQU VSTART_256_LINES

pf_pixel_per_datafetch         EQU 64 ;4x
spr_pixel_per_datafetch        EQU 64 ;4x

display_window_hstart          EQU HSTART_40_CHUNKY_PIXEL
display_window_vstart          EQU MINROW
display_window_hstop           EQU HSTOP_320_PIXEL
display_window_vstop           EQU VSTOP_256_LINES

pf1_plane_width                EQU pf1_x_size3/8
data_fetch_width               EQU pixel_per_line/8
pf1_plane_moduli               EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits                   EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                   EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
ddfstrt_bits                   EQU DDFSTART_320_PIXEL
ddfstop_bits                   EQU DDFSTOP_320_PIXEL_4X
bplcon0_bits                   EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon1_bits                   EQU 0
bplcon2_bits                   EQU 0
bplcon3_bits1                  EQU BPLCON3F_SPRES0
bplcon3_bits2                  EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits                   EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits               EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)+DIWHIGHF_hstart1+DIWHIGHF_HSTOP1
fmode_bits                     EQU FMODEF_BPL32+FMODEF_BPAGEM+FMODEF_SPR32+FMODEF_SPAGEM+FMODEF_SSCAN2

cl2_display_x_size             EQU 320
cl2_display_width              EQU cl2_display_x_size/8
cl2_display_y_size             EQU visible_lines_number
  IFEQ open_border_enabled
cl2_hstart1                    EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
  ELSE
cl2_hstart1                    EQU display_window_hstart-4
  ENDC
cl2_vstart1                    EQU MINROW
cl2_hstart2                    EQU $00
cl2_vstart2                    EQU beam_position&CL_Y_WRAP

sine_table_length              EQU 256

; **** Background-Image ****
bg_image_x_size                EQU 256
bg_image_plane_width           EQU bg_image_x_size/8
bg_image_y_size                EQU 256
bg_image_depth                 EQU 16
bg_image_x_position            EQU 0
bg_image_y_position            EQU MINROW

; **** Twisted-Bars ****
tb_bars_number                 EQU 6
tb_bar_height                  EQU 14

; **** Twisted-Bars3.1.3 ****
tb313_y_radius_min             EQU (tb_bar_height+2)*4
tb313_y_radius_max             EQU cl2_display_y_size-(tb_bar_height+2)
tb313_y_radius                 EQU ((tb313_y_radius_max-tb313_y_radius_min)/2)
tb313_y_radius_center          EQU ((tb313_y_radius_max-tb313_y_radius_min)/2)+tb313_y_radius_min
tb313_y_radius_speed           EQU 3
tb313_y_radius_step            EQU 1
tb313_y_center                 EQU (cl2_display_y_size-(tb_bar_height+2))/2
tb313_y_angle_speed            EQU 2
tb313_y_angle_step             EQU 1
tb313_y_distance               EQU sine_table_length/tb_bars_number

; **** Twisted-Bars3.1.2 ****
tb312_y_radius_min             EQU (tb_bar_height+2)*4
tb312_y_radius_max             EQU cl2_display_y_size-16-(tb_bar_height+2)
tb312_y_radius                 EQU ((tb312_y_radius_max-tb312_y_radius_min)/2)
tb312_y_radius_center          EQU ((tb312_y_radius_max-tb312_y_radius_min)/2)+tb312_y_radius_min
tb312_y_radius_speed           EQU 4
tb312_y_radius_step            EQU 6
tb312_y_center                 EQU (cl2_display_y_size-tb_bar_height)/2
tb312_y_angle_speed            EQU 5
tb312_y_angle_step             EQU 3
tb312_y_distance               EQU sine_table_length/tb_bars_number

; ***** Clear-Blit ****
tb_clear_blit_x_size           EQU 16
  IFEQ open_border_enabled
tb_clear_blit_y_size           EQU cl2_display_y_size*(cl2_display_width+2)
  ELSE
tb_clear_blit_y_size           EQU cl2_display_y_size*(cl2_display_width+1)
  ENDC

; **** Restore-Blit ****
tb_restore_blit_x_size         EQU 16
tb_restore_blit_width          EQU tb_restore_blit_x_size/8
tb_restore_blit_y_size         EQU cl2_display_y_size

; **** Horiz-Scrolltext ****
hst_image_x_size               EQU 320
hst_image_plane_width          EQU hst_image_x_size/8
hst_image_depth                EQU 4
hst_origin_character_x_size    EQU 32
hst_origin_character_y_size    EQU 32

hst_text_character_x_size      EQU 16
hst_text_character_width       EQU hst_text_character_x_size/8
hst_text_character_y_size      EQU hst_origin_character_y_size
hst_text_character_depth       EQU hst_image_depth

hst_horiz_scroll_window_x_size EQU visible_pixels_number+hst_text_character_x_size
hst_horiz_scroll_window_width  EQU hst_horiz_scroll_window_x_size/8
hst_horiz_scroll_window_y_size EQU hst_text_character_y_size
hst_horiz_scroll_window_depth  EQU hst_image_depth
hst_horiz_scroll_speed         EQU 3

hst_text_character_x_restart   EQU hst_horiz_scroll_window_x_size
hst_text_characters_number     EQU hst_horiz_scroll_window_x_size/hst_text_character_x_size

hst_text_x_position            EQU 32
hst_text_y_position            EQU (visible_lines_number-hst_text_character_y_size)/2

hst_copy_blit_x_size           EQU hst_text_character_x_size
hst_copy_blit_y_size           EQU hst_text_character_y_size*hst_text_character_depth

hst_horiz_scroll_blit_x_size   EQU hst_horiz_scroll_window_x_size
hst_horiz_scroll_blit_y_size   EQU hst_horiz_scroll_window_y_size*hst_horiz_scroll_window_depth

; **** Sprites-Fader ****
sprf_rgb8_start_color               EQU 1
sprf_rgb8_color_table_offset        EQU 1
sprf_rgb8_colors_number             EQU spr_colors_number-1

sprfi_rgb8_fader_speed_max          EQU 4
sprfi_rgb8_fader_radius             EQU sprfi_rgb8_fader_speed_max
sprfi_rgb8_fader_center             EQU sprfi_rgb8_fader_speed_max+1
sprfi_rgb8_fader_angle_speed        EQU 2

sprfo_rgb8_fader_speed_max          EQU 10
sprfo_rgb8_fader_radius             EQU sprfo_rgb8_fader_speed_max
sprfo_rgb8_fader_center             EQU sprfo_rgb8_fader_speed_max+1
sprfo_rgb8_fader_angle_speed        EQU 1

; **** Chunky-Columns-Fader ****
ccfi_mode1                     EQU 0
ccfi_mode2                     EQU 1
ccfi_mode3                     EQU 2
ccfi_mode4                     EQU 3
ccfi_delay                     EQU 1
ccfi_delay_speed               EQU 1

ccfo_mode1                     EQU 0
ccfo_mode2                     EQU 1
ccfo_mode3                     EQU 2
ccfo_mode4                     EQU 3
ccfo_delay                     EQU 1
ccfo_delay_speed               EQU 1

; **** Effects-Handler ****
eh_trigger_number_max          EQU 9


pf1_plane_x_offset          EQU 1*pf_pixel_per_datafetch
pf1_plane_y_offset          EQU 0


  INCLUDE "except-vectors-offsets.i"


  INCLUDE "extra-pf-attributes.i"


  INCLUDE "sprite-attributes.i"


  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_size RS.B 0


  RSRESET

cl2_extension1        RS.B 0

cl2_ext1_WAIT         RS.L 1
  IFEQ open_border_enabled 
cl2_ext1_BPL1DAT      RS.L 1
  ENDC
cl2_ext1_BPLCON4_1    RS.L 1
cl2_ext1_BPLCON4_2    RS.L 1
cl2_ext1_BPLCON4_3    RS.L 1
cl2_ext1_BPLCON4_4    RS.L 1
cl2_ext1_BPLCON4_5    RS.L 1
cl2_ext1_BPLCON4_6    RS.L 1
cl2_ext1_BPLCON4_7    RS.L 1
cl2_ext1_BPLCON4_8    RS.L 1
cl2_ext1_BPLCON4_9    RS.L 1
cl2_ext1_BPLCON4_10   RS.L 1
cl2_ext1_BPLCON4_11   RS.L 1
cl2_ext1_BPLCON4_12   RS.L 1
cl2_ext1_BPLCON4_13   RS.L 1
cl2_ext1_BPLCON4_14   RS.L 1
cl2_ext1_BPLCON4_15   RS.L 1
cl2_ext1_BPLCON4_16   RS.L 1
cl2_ext1_BPLCON4_17   RS.L 1
cl2_ext1_BPLCON4_18   RS.L 1
cl2_ext1_BPLCON4_19   RS.L 1
cl2_ext1_BPLCON4_20   RS.L 1
cl2_ext1_BPLCON4_21   RS.L 1
cl2_ext1_BPLCON4_22   RS.L 1
cl2_ext1_BPLCON4_23   RS.L 1
cl2_ext1_BPLCON4_24   RS.L 1
cl2_ext1_BPLCON4_25   RS.L 1
cl2_ext1_BPLCON4_26   RS.L 1
cl2_ext1_BPLCON4_27   RS.L 1
cl2_ext1_BPLCON4_28   RS.L 1
cl2_ext1_BPLCON4_29   RS.L 1
cl2_ext1_BPLCON4_30   RS.L 1
cl2_ext1_BPLCON4_31   RS.L 1
cl2_ext1_BPLCON4_32   RS.L 1
cl2_ext1_BPLCON4_33   RS.L 1
cl2_ext1_BPLCON4_34   RS.L 1
cl2_ext1_BPLCON4_35   RS.L 1
cl2_ext1_BPLCON4_36   RS.L 1
cl2_ext1_BPLCON4_37   RS.L 1
cl2_ext1_BPLCON4_38   RS.L 1
cl2_ext1_BPLCON4_39   RS.L 1
cl2_ext1_BPLCON4_40   RS.L 1

cl2_extension1_size   RS.B 0


  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_size*cl2_display_y_size

cl2_WAIT             RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_size     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
cl1_size1       EQU 0
cl1_size2       EQU 0
cl1_size3       EQU copperlist1_size

cl2_size1       EQU copperlist2_size
cl2_size2       EQU copperlist2_size
cl2_size3       EQU copperlist2_size


; ** Sprite0-Zusatzstruktur **
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr0_extension1_size  RS.B 0

; ** Sprite0-Hauptstruktur **
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_size

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_size          RS.B 0

; ** Sprite1-Zusatzstruktur **
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr1_extension1_size  RS.B 0

; ** Sprite1-Hauptstruktur **
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_size

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_size          RS.B 0

; ** Sprite2-Zusatzstruktur **
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr2_extension1_size  RS.B 0

; ** Sprite2-Hauptstruktur **
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_size

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_size          RS.B 0

; ** Sprite3-Zusatzstruktur **
  RSRESET

spr3_extension1       RS.B 0

spr3_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr3_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr3_extension1_size  RS.B 0

; ** Sprite3-Hauptstruktur **
  RSRESET

spr3_begin            RS.B 0

spr3_extension1_entry RS.B spr3_extension1_size

spr3_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_size          RS.B 0

; ** Sprite4-Zusatzstruktur **
  RSRESET

spr4_extension1       RS.B 0

spr4_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr4_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr4_extension1_size  RS.B 0

; ** Sprite4-Hauptstruktur **
  RSRESET

spr4_begin            RS.B 0

spr4_extension1_entry RS.B spr4_extension1_size

spr4_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_size          RS.B 0

; ** Sprite5-Zusatzstruktur **
  RSRESET

spr5_extension1       RS.B 0

spr5_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr5_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr5_extension1_size  RS.B 0

; ** Sprite5-Hauptstruktur **
  RSRESET

spr5_begin            RS.B 0

spr5_extension1_entry RS.B spr5_extension1_size

spr5_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_size          RS.B 0

; ** Sprite6-Zusatzstruktur **
  RSRESET

spr6_extension1       RS.B 0

spr6_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr6_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr6_extension1_size  RS.B 0

; ** Sprite6-Hauptstruktur **
  RSRESET

spr6_begin            RS.B 0

spr6_extension1_entry RS.B spr6_extension1_size

spr6_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_size          RS.B 0

; ** Sprite7-Zusatzstruktur **
  RSRESET

spr7_extension1       RS.B 0

spr7_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr7_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*bg_image_y_size

spr7_extension1_size  RS.B 0

; ** Sprite7-Hauptstruktur **
  RSRESET

spr7_begin            RS.B 0

spr7_extension1_entry RS.B spr7_extension1_size

spr7_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_size          RS.B 0


; ** Konstanten für die Größe der Spritestrukturen **
spr0_x_size1    EQU spr_x_size1
spr0_y_size1    EQU 0
spr1_x_size1    EQU spr_x_size1
spr1_y_size1    EQU 0
spr2_x_size1    EQU spr_x_size1
spr2_y_size1    EQU 0
spr3_x_size1    EQU spr_x_size1
spr3_y_size1    EQU 0
spr4_x_size1    EQU spr_x_size1
spr4_y_size1    EQU 0
spr5_x_size1    EQU spr_x_size1
spr5_y_size1    EQU 0
spr6_x_size1    EQU spr_x_size1
spr6_y_size1    EQU 0
spr7_x_size1    EQU spr_x_size1
spr7_y_size1    EQU 0

spr0_x_size2    EQU spr_x_size2
spr0_y_size2    EQU sprite0_size/(spr_pixel_per_datafetch/4)
spr1_x_size2    EQU spr_x_size2
spr1_y_size2    EQU sprite1_size/(spr_pixel_per_datafetch/4)
spr2_x_size2    EQU spr_x_size2
spr2_y_size2    EQU sprite2_size/(spr_pixel_per_datafetch/4)
spr3_x_size2    EQU spr_x_size2
spr3_y_size2    EQU sprite3_size/(spr_pixel_per_datafetch/4)
spr4_x_size2    EQU spr_x_size2
spr4_y_size2    EQU sprite4_size/(spr_pixel_per_datafetch/4)
spr5_x_size2    EQU spr_x_size2
spr5_y_size2    EQU sprite5_size/(spr_pixel_per_datafetch/4)
spr6_x_size2    EQU spr_x_size2
spr6_y_size2    EQU sprite6_size/(spr_pixel_per_datafetch/4)
spr7_x_size2    EQU spr_x_size2
spr7_y_size2    EQU sprite7_size/(spr_pixel_per_datafetch/4)


  RSRESET

  INCLUDE "variables-offsets.i"

; **** Horiz-Scrolltext ****
hst_image                  RS.L 1
hst_enabled                RS.W 1
hst_text_table_start       RS.W 1
hst_text_BLTCON0_bits      RS.W 1
hst_character_toggle_image RS.W 1

; **** Twisted-Bars3.1.3 ****
tb313_active               RS.W 1
tb313_y_angle              RS.W 1
tb313_y_radius_angle       RS.W 1

; **** Twisted-Bars3.1.2 ****
tb312_active               RS.W 1
tb312_y_angle              RS.W 1
tb312_y_radius_angle       RS.W 1

; **** Sprites-Fader ****
sprf_rgb8_colors_counter        RS.W 1
sprf_rgb8_copy_colors_active    RS.W 1

sprfi_rgb8_active               RS.W 1
sprfi_rgb8_fader_angle          RS.W 1

sprfo_rgb8_active               RS.W 1
sprfo_rgb8_fader_angle          RS.W 1

; **** Chunky-Columns-Fader ****
ccfi_active                RS.W 1
ccfi_current_mode          RS.W 1
ccfi_start                 RS.W 1
ccfi_delay_counter         RS.W 1
ccfi_delay_reset           RS.W 1

ccfo_active                RS.W 1
ccfo_current_mode          RS.W 1
ccfo_start                 RS.W 1
ccfo_delay_counter         RS.W 1
ccfo_delay_reset           RS.W 1

; **** Effects-Handler ****
eh_trigger_number          RS.W 1

; **** Main ****
fx_active                  RS.W 1

variables_size             RS.B 0


start_04_twisted_space_bars

  INCLUDE "sys-wrapper.i"

  CNOP 0,4
init_main_variables

; **** Horiz-Scrolltext ****
  lea     hst_image_data,a0
  move.l  a0,hst_image(a3)
  moveq   #FALSE,d1
  move.w  d1,hst_enabled(a3)
  moveq   #0,d0
  move.w  d0,hst_text_table_start(a3)
  move.w  d0,hst_text_bltcon0_bits(a3)
  move.w  d0,hst_character_toggle_image(a3)

; **** Twisted-Bars3.1.3 ****
  move.w  d1,tb313_active(a3)
  move.w  d0,tb313_y_angle(a3)
  move.w  d0,tb313_y_radius_angle(a3)

; **** Twisted-Bars3.1.2 ****
  move.w  d1,tb312_active(a3)
  move.w  d0,tb312_y_angle(a3)
  move.w  d0,tb312_y_radius_angle(a3)

; **** Sprites-Fader ****
  move.w  d0,sprf_rgb8_colors_counter(a3)
  moveq   #FALSE,d1
  move.w  d1,sprf_rgb8_copy_colors_active(a3)

  move.w  d1,sprfi_rgb8_active(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,sprfi_rgb8_fader_angle(a3)

  move.w  d1,sprfo_rgb8_active(a3)
  move.w  d2,sprfo_rgb8_fader_angle(a3)

; **** Chunky-Columns-Fader ****
  move.w  d1,ccfi_active(a3)
  moveq   #ccfi_mode2,d2
  move.w  d2,ccfi_current_mode(a3)
  move.w  d0,ccfi_start(a3)
  move.w  d0,ccfi_delay_counter(a3)
  moveq   #ccfi_delay,d2
  move.w  d2,ccfi_delay_reset(a3)

  move.w  d1,ccfo_active(a3)
  moveq   #ccfo_mode2,d2
  move.w  d2,ccfo_current_mode(a3)
  move.w  d0,ccfo_start(a3)
  move.w  d0,ccfo_delay_counter(a3)
  moveq   #ccfo_delay,d2
  move.w  d2,ccfo_delay_reset(a3)

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
  CNOP 0,4
init_main
  bsr.s   tb_init_color_table
  bsr.s   init_colors
  bsr     init_sprites
  bsr     hst_init_characters_offsets
  bsr     hst_init_characters_x_positions
  bsr     hst_init_characters_images
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farbwerte der Bar initialisieren **
  CNOP 0,4
tb_init_color_table
  move.l  #color00_bits,d1
  lea     tb_color_gradient(pc),a0 ;Quelle Farbverlauf
  lea     tb_color_table(pc),a1 ;Ziel
  moveq   #tb_bar_height-1,d7 ;Anzahl der Zeilen
tb_init_color_table_loop1
  move.l  (a0)+,d0           ;RGB8-Farbwert
  move.l  d1,(a1)+           ;COLOR00
  moveq   #(spr_colors_number-1)-1,d6 ;Anzahl der Farbwerte pro Palettenabschnitt
tb_init_color_table_loop2
  move.l  d0,(a1)+           ;Farbwert eintragen
  dbf     d6,tb_init_color_table_loop2
  dbf     d7,tb_init_color_table_loop1
  rts

  CNOP 0,4
init_colors
  CPU_SELECT_COLOR_HIGH_BANK 0
  CPU_INIT_COLOR_HIGH COLOR00,16,pf1_rgb8_color_table
  CPU_SELECT_COLOR_HIGH_BANK 1
  CPU_INIT_COLOR_HIGH COLOR00,32,tb_color_table
  CPU_SELECT_COLOR_HIGH_BANK 2
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 3
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 4
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 5
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 6
  CPU_INIT_COLOR_HIGH COLOR00,32
  CPU_SELECT_COLOR_HIGH_BANK 7
  CPU_INIT_COLOR_HIGH COLOR00,32

  CPU_SELECT_COLOR_LOW_BANK 0
  CPU_INIT_COLOR_LOW COLOR00,16,pf1_rgb8_color_table
  CPU_SELECT_COLOR_LOW_BANK 1
  CPU_INIT_COLOR_LOW COLOR00,32,tb_color_table
  CPU_SELECT_COLOR_LOW_BANK 2
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 3
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 4
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 5
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 6
  CPU_INIT_COLOR_LOW COLOR00,32
  CPU_SELECT_COLOR_LOW_BANK 7
  CPU_INIT_COLOR_LOW COLOR00,32
  rts

  CNOP 0,4
init_sprites
  bsr.s   spr_init_ptrs_table
  bra.s   bg_init_attached_sprites_cluster

  INIT_SPRITE_POINTERS_TABLE

  INIT_ATTACHED_SPRITES_CLUSTER bg,spr_ptrs_display,bg_image_x_position,bg_image_y_position,spr_x_size2,bg_image_y_size,,,REPEAT

; **** Horiz-Scrolltext ****
; ** Offsets der Buchstaben im Characters-Pic berechnen **
  INIT_CHARACTERS_OFFSETS.W hst

; ** X-Positionen der Chars berechnen **
  INIT_CHARACTERS_X_POSITIONS hst,LORES

; ** Laufschrift initialisieren **
  INIT_CHARACTERS_IMAGES hst


  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 
  bsr.s   cl1_init_playfield_props
  bsr.s   cl1_init_sprite_ptrs
  bsr     cl1_init_colors
  bsr     cl1_init_plane_ptrs
  COP_MOVEQ TRUE,COPJMP2
  bsr     cl1_set_sprite_ptrs
  bsr     cl1_set_plane_ptrs
  bra     tb313_get_yz_coords2

  COP_INIT_PLAYFIELD_REGISTERS cl1

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_colors
  COP_INIT_COLOR_HIGH COLOR16,spr_colors_number,spr_rgb8_color_table

  COP_SELECT_COLOR_LOW_BANK 0
  COP_INIT_COLOR_LOW COLOR16,spr_colors_number,spr_rgb8_color_table
  rts

  COP_INIT_BITPLANE_POINTERS cl1

  COP_SET_SPRITE_POINTERS cl1,display,spr_number

  COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3

  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction1(a3),a0 
  bsr.s   cl2_init_bplcon4
  bsr.s   cl2_init_copper_interrupt
  COP_LISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,tb_quick_clear_enabled,FALSE

  COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2

  COPY_COPPERLIST cl2,3


  CNOP 0,4
main
  bsr.s   no_sync_routines
  bra.s   beam_routines


  CNOP 0,4
no_sync_routines
  rts


  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   swap_second_copperlist
  bsr.s   swap_playfield1
  bsr     effects_handler
  bsr     sprf_rgb8_copy_color_table
  tst.w   hst_enabled(a3)
  bne.s   no_horiz_scrolltext
  bsr     horiz_scrolltext
  bsr     hst_horiz_scroll
no_horiz_scrolltext
  bsr     tb_clear_second_copperlist
  bsr     chunky_columns_fader_in
  bsr     chunky_columns_fader_out
  bsr     tb_set_background_bars
  bsr     tb_set_foreground_bars
  bsr     tb313_get_yz_coords
  bsr     tb312_get_yz_coords
  IFNE tb_quick_clear_enabled
    bsr     restore_second_copperlist
  ENDC
  bsr     sprite_fader_in
  bsr     sprite_fader_out
  bsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


  SWAP_COPPERLIST cl2,3

  SWAP_PLAYFIELD pf1,2,pf1_depth3,pf1_plane_x_offset,pf1_plane_y_offset


; ** Laufschrift **
  CNOP 0,4
horiz_scrolltext
  movem.l a4-a5,-(a7)
  bsr.s   hst_init_copy_blit
  move.w  #(hst_copy_blit_y_size*64)+(hst_copy_blit_x_size/16),d4 ;BLTSIZE
  move.w  #hst_text_character_x_restart,d5
  lea     hst_characters_x_positions(pc),a0 ;X-Positionen der Chars
  lea     hst_characters_image_ptrs(pc),a1 ;Zeiger auf Adressen der Chars-Images
  move.l  pf1_construction2(a3),a2
  move.l  (a2),d3
  add.l   #(hst_text_x_position/8)+(hst_text_y_position*pf1_plane_width*pf1_depth3),d3 ;Y-Zentrierung + 32 Pixel überspringen
  lea     BLTAPT-DMACONR(a6),a2    ;Offset der Blitterregister auf Null setzen
  lea     BLTDPT-DMACONR(a6),a4
  lea     BLTSIZE-DMACONR(a6),a5
  bsr.s   hst_get_text_softscroll
  moveq   #hst_text_characters_number-1,d7 ;Anzahl der Chars
horiz_scrolltext_loop
  moveq   #0,d0              ;Langwort-Zugriff
  move.w  (a0),d0            ;X-Position
  move.w  d0,d2              
  lsr.w   #3,d0              ;X/8
  WAITBLIT
  move.l  (a1)+,(a2)         ;Char-Image
  add.l   d3,d0              ;X-Offset
  move.l  d0,(a4)            ;Playfield
  move.w  d4,(a5)            ;Blitter starten
  subq.w  #hst_horiz_scroll_speed,d2 ;X-Position verringern
  bpl.s   hst_no_new_character_image ;Wenn positiv -> verzweige
  move.l  a0,-(a7)
  bsr.s   hst_get_new_character_image
  move.l  d0,-4(a1)          ;Neues Bild für Character
  add.w   d5,d2              ;X-Pos Neustart
  move.l  (a7)+,a0
hst_no_new_character_image
  move.w  d2,(a0)+           
  dbf     d7,horiz_scrolltext_loop
  movem.l (a7)+,a4-a5
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  rts
  CNOP 0,4
hst_init_copy_blit
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLIT
  move.l  #(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;keine Ausmaskierung
  move.l  #((hst_image_plane_width-hst_text_character_width)<<16)+(pf1_plane_width-hst_text_character_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  rts

; ** Softscrollwert berechen **
  CNOP 0,4
hst_get_text_softscroll
  moveq   #hst_text_character_x_size-1,d0
  and.w   (a0),d0            ;X-Pos.&$f
  ror.w   #4,d0              ;Bits in richtige Position bringen
  or.w    #BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,d0 ;Minterm  D=A
  move.w  d0,hst_text_bltcon0_bits(a3) 
  rts

; ** Neues Image für Character ermitteln **
  GET_NEW_CHARACTER_IMAGE.W hst,hst_check_control_codes,NORESTART

  CNOP 0,4
hst_check_control_codes
  cmp.b   #ASCII_CTRL_S,d0
  beq.s   hst_stop_horiz_scrolltext
  rts
  CNOP 0,4
hst_stop_horiz_scrolltext
  move.w  #FALSE,hst_enabled(a3)
  moveq   #0,d0          ;Rückgabewert TRUE = Steuerungscode gefunden
  rts

; ** Laufschrift bewegen **
  CNOP 0,4
hst_horiz_scroll
  move.l  pf1_construction2(a3),a0
  WAITBLIT
  move.l  (a0),a0
  move.w  hst_text_bltcon0_bits(a3),BLTCON0-DMACONR(a6)
  add.l   #(hst_text_x_position/8)+(hst_text_y_position*pf1_plane_width*pf1_depth3),a0 ;Y-Zentrierung + 32 Pixel überspringen
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  addq.w  #2,a0              ;16 Pixel überspringen
  move.l  a0,BLTDPT-DMACONR(a6) ;Ziel
  move.l  #((pf1_plane_width-hst_horiz_scroll_window_width)<<16)+(pf1_plane_width-hst_horiz_scroll_window_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  move.w  #(hst_horiz_scroll_blit_y_size*64)+(hst_horiz_scroll_blit_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
  rts

; ** Copperliste löschen **
  CLEAR_BPLCON4_CHUNKY_SCREEN tb,cl2,construction1,extension1,quick_clear_enabled

; ** Hintere Stangen in Copperliste kopieren **
  CNOP 0,4
tb_set_background_bars
  movem.l a3-a6,-(a7)
  lea     tb_yz_coords(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2,a2
  move.w  #tb_bars_number*LONGWORD_SIZE,a3 ;Z + Y überspringen
  lea     tb_switch_table_background(pc),a5 ;Zeiger auf Tabelle mit Switchwerten
  lea     ccf_fader_columns_mask(pc),a6 ;Tabelle mit Status der Spalten
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb_set_background_bars_loop1
  tst.b   (a6)+              ;Spalte darstellen ?
  bne     tb_skip_column1    ;Nein -> verzweige
  moveq   #tb_bars_number-1,d6 ;Anzahl der Stangen
tb_set_background_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  bmi.s   tb_no_background_bar ;Wenn Z negativ -> verzweige
tb_set_background_bar
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  lea     (a2,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.W tb,cl2,extension1,bar_height
tb_no_background_bar
  dbf     d6,tb_set_background_bars_loop2
tb_no_column1
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,tb_set_background_bars_loop1
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
tb_skip_column1
  add.l   a3,a0              ;Z + Y überspringen
  bra.s   tb_no_column1

; ** Vordere Stangen in Copperliste kopieren **
  CNOP 0,4
tb_set_foreground_bars
  movem.l a3-a6,-(a7)
  lea     tb_yz_coords(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2,a2
  move.w  #tb_bars_number*LONGWORD_SIZE,a3 ;Z + Y überspringen
  lea     tb_switch_table_foreground(pc),a5 ;Zeiger auf Tabelle mit Switchwerten
  lea     ccf_fader_columns_mask(pc),a6 ;Tabelle mit Status der Spalten
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb_set_foreround_bars_loop1
  tst.b   (a6)+              ;Spalte darstellen ?
  bne     tb_skip_column2    ;Nein -> verzweige
  moveq   #tb_bars_number-1,d6 ;Anzahl der Stangen
tb_set_foreround_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  bpl.s   tb_no_foreground_bar ;Wenn Z positiv -> verzweige
tb_set_foreground_bar
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  lea     (a2,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.W tb,cl2,extension1,bar_height
tb_no_foreground_bar
  dbf     d6,tb_set_foreround_bars_loop2
tb_no_column2
  addq.w  #4,a2              ;nächste Spalte in CL
  dbf     d7,tb_set_foreround_bars_loop1
  movem.l (a7)+,a3-a6
  rts
  CNOP 0,4
tb_skip_column2
  add.l   a3,a0              ;Z + Y überspringen
  bra.s   tb_no_column2

; ** Y+Z-Koordinaten berechnen **
  CNOP 0,4
tb313_get_yz_coords
  tst.w   tb313_active(a3)
  bne.s   tb313_no_get_yz_coords
tb313_get_yz_coords2
  movem.l a4-a5,-(a7)
  moveq   #tb313_y_distance,d3
  move.w  tb313_y_angle(a3),d4 ;1. Y-Winkel
  move.w  d4,d0              
  move.w  tb313_y_radius_angle(a3),d5 ;1. Y-Radius-Winkel
  addq.b  #tb313_y_angle_speed,d0
  move.w  d0,tb313_y_angle(a3) 
  move.w  d5,d0
  addq.b  #tb313_y_radius_speed,d0
  move.w  d0,tb313_y_radius_angle(a3) 
  lea     sine_table(pc),a0 
  lea     tb_yz_coords(pc),a1 ;Zeiger auf Y+Z-Koords-Tabelle
  move.w  #tb313_y_center,a2
  move.w  #tb313_y_radius_center,a4
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb313_get_yz_coords_loop1
  move.w  d4,d2              ;Y-Winkel
  moveq   #tb_bars_number-1,d6 ;Anzahl der Stangen
tb313_get_yz_coords_loop2
  moveq   #-(sine_table_length/4),d1 ;- 90 Grad
  move.l  (a0,d5.w*4),d0     ;sin(w)
  add.w   d2,d1              ;Y-Winkel - 90 Grad
  ext.w   d1                 ;Vorzeichenrichtig auf ein Wort erweitern
  move.w  d1,(a1)+           ;Z-Vektor retten
  MULUF.L tb313_y_radius*2,d0,d1 ;yr'=(yr*sin(w))/2^15
  swap    d0
  add.w   a4,d0              ;y' + Y-Radius-Mittelpunkt
  muls.w  2(a0,d2.w*4),d0    ;y'=(yr*sin(w))/2^15
  swap    d0
  add.w   a2,d0              ;y' + Y-Mittelpunkt
  MULUF.W cl2_extension1_size/4,d0,d1 ;Y-Offset in CL
  move.w  d0,(a1)+           ;Y retten
  add.b   d3,d2              ;Y-Abstand zur nächsten Bar
  addq.b  #tb313_y_radius_step,d5 ;nächster Y-Radius-Winkel
  dbf     d6,tb313_get_yz_coords_loop2
  addq.b  #tb313_y_angle_step,d4 ;nächster Y-Winkel
  dbf     d7,tb313_get_yz_coords_loop1
  movem.l (a7)+,a4-a5
tb313_no_get_yz_coords
  rts

; ** Y+Z-Koordinaten berechnen **
  CNOP 0,4
tb312_get_yz_coords
  tst.w   tb312_active(a3)
  bne.s   tb312_no_get_yz_coords
  movem.l a4-a5,-(a7)
  moveq   #tb312_y_distance,d3
  move.w  tb312_y_angle(a3),d4 ;1. Y-Winkel
  move.w  d4,d0              
  move.w  tb312_y_radius_angle(a3),d5 ;1. Y-Radius-Winkel
  addq.b  #tb312_y_angle_speed,d0
  move.w  d0,tb312_y_angle(a3) 
  move.w  d5,d0
  addq.b  #tb312_y_radius_speed,d0
  move.w  d0,tb312_y_radius_angle(a3) 
  lea     sine_table(pc),a0 
  lea     tb_yz_coords(pc),a1 ;Zeiger auf Y+Z-Koords-Tabelle
  move.w  #tb312_y_center,a2
  move.w  #tb312_y_radius_center,a4
  moveq   #cl2_display_width-1,d7 ;Anzahl der Spalten
tb312_get_yz_coords_loop1
  move.l  (a0,d5.w*4),d0     ;sin(w)
  MULUF.L tb312_y_radius*2,d0,d1
  move.w  d4,d2              ;Y-Winkel
  swap    d0
  add.w   a4,d0              ;y' + Y-Radius-Mittelpunkt
  moveq   #tb_bars_number-1,d6 ;Anzahl der Stangen
tb312_get_yz_coords_loop2
  moveq   #-(sine_table_length/4),d1 ;- 90 Grad
  add.w   d2,d1              ;Y-Winkel - 90 Grad
  ext.w   d1                 ;Vorzeichenrichtig auf ein Wort erweitern
  move.w  d1,(a1)+           ;Z-Vektor retten
  move.w  2(a0,d2.w*4),d1    ;sin(w)
  muls.w  d0,d1              ;y'=(yr*sin(w))/2^15
  swap    d1
  add.w   a2,d1              ;y' + Y-Mittelpunkt
  MULUF.W cl2_extension1_size/4,d1,a5 ;Y-Offset in CL
  move.w  d1,(a1)+           ;Y retten
  add.b   d3,d2              ;Y-Abstand zur nächsten Bar
  dbf     d6,tb312_get_yz_coords_loop2
  addq.b  #tb312_y_angle_step,d4 ;nächster Y-Winkel
  addq.b  #tb312_y_radius_step,d5 ;nächster Y-Radius-Winkel
  dbf     d7,tb312_get_yz_coords_loop1
  movem.l (a7)+,a4-a5
tb312_no_get_yz_coords
  rts

; ** Copper-WAIT-Befehle wiederherstellen **
  IFNE tb_quick_clear_enabled
    RESTORE_BLCON4_CHUNKY_SCREEN tb,cl2,construction2,extension1,32
  ENDC


; ** Hintergrundbild einblenden **
  CNOP 0,4
sprite_fader_in
  tst.w   sprfi_rgb8_active(a3)     ;Sprites-Fader-In an ?
  bne.s   no_sprite_fader_in   ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfi_rgb8_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  ADDF.W  sprfi_rgb8_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfi_rgb8_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfi_rgb8_save_fader_angle
  move.w  d0,sprfi_rgb8_fader_angle(a3) 
  MOVEF.W sprf_rgb8_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L sprfi_rgb8_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfi_rgb8_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfi_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_rgb8_colors_number-1,d7 ;Anzahl der Farben
  bsr     sprf_rgb8_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_rgb8_colors_counter(a3) ;Sprites-Fader-In fertig ?
  bne.s   no_sprite_fader_in ;Nein -> verzweige
  move.w  #FALSE,sprfi_rgb8_active(a3) ;Sprites-Fader-In aus
no_sprite_fader_in
  rts

; ** Hintergrundbild ausblenden **
  CNOP 0,4
sprite_fader_out
  tst.w   sprfo_rgb8_active(a3)     ;Sprites-Fader-Out an ?
  bne.s   no_sprite_fader_out  ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfo_rgb8_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  ADDF.W  sprfo_rgb8_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfo_rgb8_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfo_rgb8_save_fader_angle
  move.w  d0,sprfo_rgb8_fader_angle(a3) 
  MOVEF.W sprf_rgb8_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L sprfo_rgb8_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfo_rgb8_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfo_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_rgb8_colors_number-1,d7 ;Anzahl der Farben
  bsr.s   sprf_rgb8_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_rgb8_colors_counter(a3) ;Sprites-Fader-Out fertig ?
  bne.s   no_sprite_fader_out ;Nein -> verzweige
  move.w  #FALSE,sprfo_rgb8_active(a3) ;Sprites-Fader-Out aus
no_sprite_fader_out
  rts

  RGB8_COLOR_FADER sprf

  COPY_RGB8_COLORS_TO_COPPERLIST sprf,spr,cl1,cl1_COLOR17_high1,cl1_COLOR17_low1

; ** Spalten einblenden **
  CNOP 0,4
chunky_columns_fader_in
  tst.w   ccfi_active(a3)    ;Chunky-Columns-Fader-In an ?
  bne.s   ccfi_no_chunky_columns_fader_in ;Nein -> verzweige
  subq.w  #ccfi_delay_speed,ccfi_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   ccfi_no_chunky_columns_fader_in ;Wenn > Null -> verzweige
  move.w  ccfi_delay_reset(a3),ccfi_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  ccfi_start(a3),d1  ;Startwert in Spalten-Statustabelle
  moveq   #cl2_display_width-1,d2 ;Anzahl der Spalten
  lea     ccf_fader_columns_mask(pc),a0 ;Tabelle mit Status der Spalten
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
  move.w  #FALSE,ccfi_active(a3)    ;Chunky-Columns-Fader-In aus
  rts

; ** Spalten ausblenden **
  CNOP 0,4
chunky_columns_fader_out
  tst.w   ccfo_active(a3)    ;Chunky-Columns-Fader-Out an ?
  bne.s   ccfo_no_chunky_columns_fader_out ;Neout -> verzweige
  subq.w  #ccfo_delay_speed,ccfo_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   ccfo_no_chunky_columns_fader_out ;Wenn > Null -> verzweige
  move.w  ccfo_delay_reset(a3),ccfo_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  ccfo_start(a3),d1  ;Startwert out Spalten-Statustabelle
  moveq   #cl2_display_width-1,d2 ;Anzahl der Spalten
  lea     ccf_fader_columns_mask(pc),a0 ;Tabelle mit Status der Spalten
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
  move.w  #FALSE,ccfo_active(a3) ;Chunky-Columns-Fader-Out aus
  rts


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
  beq.s   eh_start_sprite_fader_in
  subq.w  #1,d0
  beq.s   eh_start_twisted_bars313
  subq.w  #1,d0
  beq.s   eh_start_horiz_scrolltext
  subq.w  #1,d0
  beq.s   eh_stop_twisted_bars313
  subq.w  #1,d0
  beq.s   eh_start_twisted_bars312
  subq.w  #1,d0
  beq.s   eh_stop_twisted_bars312
  subq.w  #1,d0
  beq.s   eh_start_sprite_fader_out
  subq.w  #1,d0
  beq     eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_sprite_fader_in
  move.w  #sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
  moveq   #0,d0
  move.w  d0,sprfi_rgb8_active(a3)  ;Sprites-Fader-In an
  move.w  d0,sprf_rgb8_copy_colors_active(a3) ;Kopieren der Farben an
  rts
  CNOP 0,4
eh_start_twisted_bars313
  moveq   #0,d0
  move.w  d0,tb313_active(a3) ;Twisted-Bars3.1.3 an
  move.w  d0,ccfi_active(a3) ;Chunky-Columns-Fader-In an
  moveq   #1,d2
  move.w  d2,ccfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_horiz_scrolltext
  clr.w   hst_enabled(a3)    ;Horiz-Scrolltext an
  rts
  CNOP 0,4
eh_stop_twisted_bars313
  clr.w   ccfo_active(a3)    ;Chunky-Columns-Fader-Out an
  moveq   #1,d2
  move.w  d2,ccfo_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_twisted_bars312
  move.w  #FALSE,tb313_active(a3) ;Twisted-Bars 3.1.3 aus
  moveq   #0,d0
  move.w  d0,tb312_active(a3) ;Twisted-Bars 3.1.2 an
  move.w  d0,ccfi_start(a3)  ;Startwert zurücksetzen
  move.w  d0,ccfi_active(a3) ;Chunky-Columns-Fader-In an
  moveq   #1,d2
  move.w  d2,ccfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_stop_twisted_bars312
  moveq   #0,d0
  move.w  d0,ccfo_start(a3)  ;Startwert zurücksetzen
  move.w  d0,ccfo_active(a3) ;Chunky-Columns-Fader-Out an
  moveq   #1,d2
  move.w  d2,ccfo_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_sprite_fader_out
  move.w  #sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
  moveq   #0,d0
  move.w  d0,sprfo_rgb8_active(a3)  ;Sprites-Fader-Out an
  move.w  d0,sprf_rgb8_copy_colors_active(a3) ;Kopieren der Farben an
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
pf1_rgb8_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/32x32x16-Font.ct"

spr_rgb8_color_table
  REPT spr_colors_number
    DC.L color00_bits
  ENDR  

spr_ptrs_display
  DS.L spr_number

; **** Twisted-Bars ****
; ** Farbverlauf **
tb_color_gradient
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/05_tb_Colorgradient.ct"

; ** Farben der Bar **
tb_color_table
  DS.L spr_colors_number*tb_bar_height

; ** Tabellen mit Switchwerten der Bar **
tb_switch_table_background
  DC.W $0022,$0033,$0044,$0055,$0066,$0077,$0088,$0099,$00aa,$00bb,$00cc,$00dd,$00ee,$00ff

tb_switch_table_foreground
  DC.W $2022,$3033,$4044,$5055,$6066,$7077,$8088,$9099,$a0aa,$b0bb,$c0cc,$d0dd,$e0ee,$f0ff

; ** YZ-Koordinatentabelle **
tb_yz_coords
  DS.W tb_bars_number*cl2_display_width*2

; **** Horiz-Scrolltext ****
; ** ASCII-Buchstaben **
hst_ascii
  DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?'():\/ "
hst_ascii_end
  EVEN

; ** Offsets der einzelnen Chars **
  CNOP 0,2
hst_characters_offsets
  DS.W hst_ascii_end-hst_ascii
  
; ** X-Koordinaten der einzelnen Chars der Laufschrift **
hst_characters_x_positions
  DS.W hst_text_characters_number

; ** Tabelle für Chars-Image-Adressen **
  CNOP 0,4
hst_characters_image_ptrs
  DS.L hst_text_characters_number

; **** Sprites-Fader ****
; ** Zielfarbwerte für Sprites-Fader-In **
  CNOP 0,4
sprfi_rgb8_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/256x256x16-Nebula.ct"

; ** Zielfarbwerte für Sprites-Fader-Out **
sprfo_rgb8_color_table
  REPT spr_colors_number
    DC.L color00_bits
  ENDR


; **** Chunky-Columns-Fader ****
; ** Maske für die Spalten **
ccf_fader_columns_mask
  REPT cl2_display_width
    DC.B FALSE
  ENDR


  INCLUDE "sys-variables.i"


  INCLUDE "sys-names.i"


  INCLUDE "error-texts.i"

; **** Horiz-Scrolltext ****
; ** Text für Laufschrift **
hst_text
  REPT hst_text_characters_number/(hst_origin_character_x_size/hst_text_character_x_size)
    DC.B " "
  ENDR
  DC.B "TWISTED BARS IN OUTER SPACE!  REAL AGA POWER..."
hst_stop_text
  REPT hst_text_characters_number/(hst_origin_character_x_size/hst_text_character_x_size)
    DC.B " "
  ENDR
  DC.B ASCII_CTRL_S," "
  EVEN


; ** Grafikdaten nachladen **

; **** Background-Image ****
bg_image_data SECTION bg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/256x256x16-Nebula.rawblit"

; **** Horiz-Scrolltext ****
hst_image_data SECTION hst_gfx,DATA_C
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/fonts/32x32x16-Font.rawblit"

  END
