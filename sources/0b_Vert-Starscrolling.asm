; #######################################
; # Programm: 0b_Vert-Starscrolling.asm #
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

  XDEF start_0b_vert_starscrolling


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


SYS_TAKEN_OVER              SET 1
PASS_GLOBAL_REFERENCES      SET 1
PASS_RETURN_CODE            SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu            EQU FALSE  
requires_040_cpu            EQU FALSE
requires_060_cpu            EQU FALSE
requires_fast_memory        EQU FALSE
requires_multiscan_monitor  EQU FALSE

workbench_start_enabled     EQU FALSE
screen_fader_enabled      EQU FALSE
text_output_enabled         EQU FALSE

open_border_enabled EQU TRUE

  IFEQ open_border_enabled
dma_bits                    EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_SETCLR
  ELSE
dma_bits                    EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_SETCLR
  ENDC
intena_bits                 EQU INTF_SETCLR

ciaa_icr_bits               EQU CIAICRF_SETCLR
ciab_icr_bits               EQU CIAICRF_SETCLR

copcon_bits                 EQU 0

pf1_x_size1                 EQU 0
pf1_y_size1                 EQU 0
pf1_depth1                  EQU 0
pf1_x_size2                 EQU 0
pf1_y_size2                 EQU 0
pf1_depth2                  EQU 0
  IFEQ open_border_enabled
pf1_x_size3                 EQU 0
pf1_y_size3                 EQU 0
pf1_depth3                  EQU 0
  ELSE
pf1_x_size3                 EQU 32
pf1_y_size3                 EQU 1
pf1_depth3                  EQU 1
  ENDC
pf1_colors_number           EQU 61

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

pf_extra_number             EQU 0

spr_number                  EQU 8
spr_x_size1                 EQU 0
spr_x_size2                 EQU 64
spr_depth                   EQU 2
spr_colors_number           EQU 0 ;16
spr_odd_color_table_select  EQU 4
spr_even_color_table_select EQU 4
spr_used_number             EQU 8

audio_memory_size           EQU 0

disk_memory_size            EQU 0

extra_memory_size           EQU 0

ciaa_ta_time                EQU 0
ciaa_tb_time                EQU 0
ciab_ta_time                EQU 0
ciab_tb_time                EQU 0
ciaa_ta_continuous_enabled  EQU FALSE
ciaa_tb_continuous_enabled  EQU FALSE
ciab_ta_continuous_enabled  EQU FALSE
ciab_tb_continuous_enabled  EQU FALSE

beam_position               EQU $136

  IFNE open_border_enabled 
pixel_per_line              EQU 32
 ENDC
visible_pixels_number       EQU 352
visible_lines_number        EQU 256
MINROW                      EQU VSTART_256_LINES

  IFNE open_border_enabled 
pf_pixel_per_datafetch      EQU 16 ;1x
  ENDC
spr_pixel_per_datafetch     EQU 64 ;4x

display_window_hstart       EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart       EQU MINROW
display_window_hstop        EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop        EQU VSTOP_256_LINES

  IFNE open_border_enabled 
pf1_plane_width             EQU pf1_x_size3/8
data_fetch_width            EQU pixel_per_line/8
pf1_plane_moduli            EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

  IFEQ open_border_enabled
diwstrt_bits                EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
bplcon0_bits                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1               EQU BPLCON3F_SPRES0
bplcon3_bits2               EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon3_bits3               EQU bplcon3_bits1+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon3_bits4               EQU bplcon3_bits2+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon4_bits                EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits                EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits                  EQU FMODEF_SPR32+FMODEF_SPAGEM
  ELSE
diwstrt_bits                EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
ddfstrt_bits                EQU DDFSTART_OVERSCAN_32_PIXEL
ddfstop_bits                EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon1_bits                EQU 0
bplcon2_bits                EQU 0
bplcon3_bits1               EQU BPLCON3F_SPRES0
bplcon3_bits2               EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon3_bits3               EQU bplcon3_bits1+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon3_bits4               EQU bplcon3_bits2+BPLCON3F_BANK0+BPLCON3F_BANK1+BPLCON3F_BANK2
bplcon4_bits                EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits                EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits                  EQU FMODEF_SPR32+FMODEF_SPAGEM
  ENDC

cl2_display_x_size          EQU 352
cl2_display_width           EQU cl2_display_x_size/8
cl2_display_y_size          EQU visible_lines_number
  IFEQ open_border_enabled
cl2_hstart1                 EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
  ELSE
cl2_hstart1                 EQU display_window_hstart-4
  ENDC
cl2_vstart1                 EQU MINROW
cl2_hstart2                 EQU $00
cl2_vstart2                 EQU beam_position&$ff

sine_table_length           EQU 256

; **** Logo ****
lg_image_x_size             EQU 256
lg_image_plane_width        EQU lg_image_x_size/8
lg_image_y_size             EQU 87
lg_image_depth              EQU 16

lg_image_x_center           EQU (visible_pixels_number-lg_image_x_size)/2
lg_image_y_center           EQU (visible_lines_number-lg_image_y_size)/2
lg_image_x_position         EQU display_window_hstart+10+lg_image_x_center
lg_image_y_position         EQU display_window_vstart+lg_image_y_center

; **** Vert-Starscrolling ****
vss_image_x_size            EQU 64
vss_image_plane_width       EQU vss_image_x_size/8
vss_image_y_size            EQU 56
vss_image_depth             EQU 6

vss_star_x_size             EQU 16
vss_star_y_size1            EQU 24
vss_star_y_size2            EQU 40
vss_star_y_size3            EQU 56

vss_z_planes_number         EQU 3
vss_z_plane1_speed          EQU 1
vss_z_plane2_speed          EQU 2
vss_z_plane3_speed          EQU 3

vss_random_x_max            EQU cl2_display_width-((vss_star_x_size*2)/8)
vss_random_y_max            EQU cl2_display_y_size+vss_star_y_size3
vss_y_restart               EQU cl2_display_y_size+vss_star_y_size3

vss_stars_per_plane_number  EQU 6

vss_switch_table_number     EQU 2
vss_switch_buffer_number    EQU 3
vss_switch_buffer_x_size    EQU 44
vss_switch_buffer_y_size    EQU cl2_display_y_size+(vss_star_y_size3*2)+1

vss_copy_blit_x_size        EQU 32
vss_copy_blit_width         EQU vss_copy_blit_x_size/8
vss_copy_blit_y_size        EQU vss_star_y_size1
vss_copy_blit_depth         EQU 1

; **** Clear-Blit ****
vss_clear_blit_x_size       EQU cl2_display_x_size
vss_clear_blit_y_size       EQU cl2_display_y_size

; **** Image-Fader ****
if_start_color              EQU 1
if_color_table_offset       EQU 1
if_colors_number            EQU pf1_colors_number-1

ifi_fader_speed_max         EQU 4
ifi_fader_radius            EQU ifi_fader_speed_max
ifi_fader_center            EQU ifi_fader_speed_max+1
ifi_fader_angle_speed       EQU 1

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
eh_trigger_number_max       EQU 5


color_step1                 EQU 256/(vss_star_y_size3/2)
color_step2                 EQU 128/(vss_star_y_size2/2)
color_step3                 EQU 64/(vss_star_y_size1/2)
color_values_number1        EQU vss_star_y_size3/2
color_values_number2        EQU vss_star_y_size2/2
color_values_number3        EQU vss_star_y_size1/2
segments_number1            EQU 1
segments_number2            EQU 1
segments_number3            EQU 1

ct_size1                    EQU color_values_number1*segments_number1
ct_size2                    EQU color_values_number2*segments_number2
ct_size3                    EQU color_values_number3*segments_number3

vss_switch_table_size       EQU vss_image_x_size*vss_image_y_size
vss_switch_buffer_size      EQU vss_switch_buffer_x_size*vss_switch_buffer_y_size

chip_memory_size            EQU ((vss_switch_table_size*vss_switch_table_number)+(vss_switch_buffer_size*vss_switch_buffer_number))*BYTE_SIZE


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
cl2_ext1_BPLCON4_41   RS.L 1
cl2_ext1_BPLCON4_42   RS.L 1
cl2_ext1_BPLCON4_43   RS.L 1
cl2_ext1_BPLCON4_44   RS.L 1

cl2_extension1_size   RS.B 0

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

cl2_size1          EQU copperlist2_size
cl2_size2          EQU copperlist2_size
cl2_size3          EQU copperlist2_size


; ** Sprite0-Zusatzstruktur **
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr1_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr2_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr3_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr4_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr5_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr6_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

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
spr7_ext1_planedata   RS.L (spr_pixel_per_datafetch/16)*lg_image_y_size

spr7_extension1_size  RS.B 0

; ** Sprite7-Hauptstruktur **
  RSRESET

spr7_begin            RS.B 0

spr7_extension1_entry RS.B spr7_extension1_size

spr7_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_size          RS.B 0


; ** Konstanten für die Größe der Spritestrukturen **
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
spr0_y_size2     EQU sprite0_size/(spr_x_size2/8)
spr1_x_size2     EQU spr_x_size2
spr1_y_size2     EQU sprite1_size/(spr_x_size2/8)
spr2_x_size2     EQU spr_x_size2
spr2_y_size2     EQU sprite2_size/(spr_x_size2/8)
spr3_x_size2     EQU spr_x_size2
spr3_y_size2     EQU sprite3_size/(spr_x_size2/8)
spr4_x_size2     EQU spr_x_size2
spr4_y_size2     EQU sprite4_size/(spr_x_size2/8)
spr5_x_size2     EQU spr_x_size2
spr5_y_size2     EQU sprite5_size/(spr_x_size2/8)
spr6_x_size2     EQU spr_x_size2
spr6_y_size2     EQU sprite6_size/(spr_x_size2/8)
spr7_x_size2     EQU spr_x_size2
spr7_y_size2     EQU sprite7_size/(spr_x_size2/8)



  RSRESET

  INCLUDE "variables-offsets.i"

save_a7                         RS.L 1

; **** Vert-Starscrolling ****
vss_switch_table                RS.L 1
vss_switch_table_mask           RS.L 1

vss_switch_buffer_construction1 RS.L 1
vss_switch_buffer_construction2 RS.L 1
vss_switch_buffer_display       RS.L 1

; **** Image-Fader ****
if_colors_counter               RS.W 1
if_copy_colors_active           RS.W 1

ifi_active                      RS.W 1
ifi_fader_angle                 RS.W 1

ifo_active                      RS.W 1
ifo_fader_angle                 RS.W 1

; **** Image-Pixel-Fader ****
ipf_mask                        RS.L 1
ipf_variable_destination_size   RS.W 1

ipfi_active                     RS.W 1
ipfi_delay_counter              RS.W 1
ipfi_delay_angle                RS.W 1

ipfo_active                     RS.W 1
ipfo_delay_counter              RS.W 1
ipfo_delay_angle                RS.W 1

; **** Effects-Handler ****
eh_trigger_number               RS.W 1

; **** Main ****
fx_active                       RS.W 1

variables_size                  RS.B 0


start_0b_vert_starscrolling

  INCLUDE "sys-wrapper.i"

  CNOP 0,4
init_own_variables

; **** Vert-Starscrolling ****
  move.l  chip_memory(a3),a0
  move.l  a0,vss_switch_table(a3) ;Vorlage der Sterne
  add.l   #vss_switch_table_size,a0
  move.l  a0,vss_switch_table_mask(a3) ;Maske der Sterne
  add.l   #vss_switch_table_size,a0

  move.l  a0,vss_switch_buffer_construction1(a3)
  add.l   #vss_switch_buffer_size,a0
  move.l  a0,vss_switch_buffer_construction2(a3)
  add.l   #vss_switch_buffer_size,a0
  move.l  a0,vss_switch_buffer_display(a3)

; **** Image-Fader ****
  moveq   #0,d0
  move.w  d0,if_colors_counter(a3)
  moveq   #FALSE,d1
  move.w  d1,if_copy_colors_active(a3)

; **** Image-Fader-In ****
  move.w  d1,ifi_active(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ifi_fader_angle(a3) ;90 Grad

; **** Image-Fader-Out ****
  move.w  d1,ifo_active(a3)
  move.w  d2,ifo_fader_angle(a3) ;90 Grad

; **** Image-Pixel-Fader ****
  moveq   #0,d0
  move.l  d0,ipf_mask(a3)
  moveq   #ipf_destination_size,d2
  move.w  d2,ipf_variable_destination_size(a3)

; **** Image-Pixel-Fader-In ****
  move.w  d1,ipfi_active(a3)
  move.w  d0,ipfi_delay_counter(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ipfi_delay_angle(a3) ;90 Grad

  move.w  d1,ipfo_active(a3)
  move.w  d0,ipfo_delay_counter(a3)
  move.w  d2,ipfo_delay_angle(a3) ;90 Grad

; **** Effects-Handler ****
  move.w  d0,eh_trigger_number(a3)

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
  CNOP 0,4
init_all
  bsr.s   init_color_registers
  bsr.s   init_sprites
  bsr     vss_convert_image_data
  bsr     vss_init_switch_table_mask
  bsr     vss_init_xy_coordinates
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farben initialisieren **
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLOR_HIGH_BANK 2
  CPU_INIT_COLOR_HIGH COLOR00,16,spr_color_table

  CPU_SELECT_COLOR_LOW_BANK 2
  CPU_INIT_COLOR_LOW COLOR00,16,spr_color_table
  rts

; **** Logo ****
; ** Sprites initialisieren **
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bra.s   lg_init_attached_sprites_cluster

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; ** Spritestruktur initialisieren **
  INIT_ATTACHED_SPRITES_CLUSTER lg,spr_pointers_display,lg_image_x_position,lg_image_y_position,spr_x_size2,lg_image_y_size,,BLANK

; ** Bilddaten in Switchwerte umwandeln **
  CONVERT_IMAGE_TO_BPLCON4_CHUNKY.B vss,vss_switch_table,a3

; ** Switchtabellenmaske initialisieren **
  CNOP 0,4
vss_init_switch_table_mask
  MOVEF.L vss_image_plane_width*(vss_image_depth-1),d3
  lea     vss_image_mask,a0  ;Plane0
  move.l  vss_switch_table_mask(a3),a1 ;Tabelle mit Switchwerten
  moveq   #vss_image_y_size-1,d7 ;Anzahl der Zeilen
vss_init_switch_table_mask_loop1
  moveq   #vss_image_plane_width-1,d6 ;Anzahl der Bytes pro Zeile
vss_init_switch_table_mask_loop2
  move.b  (a0)+,d0           ;8 Pixel lesen
  moveq   #8-1,d5            ;Länge eines Bytes in Pixeln
vss_init_switch_table_mask_loop3
  add.b   d0,d0              ;nächstes Bit
  scs     d2                 ;Wenn Übertragsbit gesetzt $ff setzen
  move.b  d2,(a1)+           ;Maskenwert eintragen
  dbf     d5,vss_init_switch_table_mask_loop3
  dbf     d6,vss_init_switch_table_mask_loop2
  add.l   d3,a0              ;nächste Zeile in Plane0
  dbf     d7,vss_init_switch_table_mask_loop1
  rts

; ** Stern-Koordinaten initialisieren **
  CNOP 0,4
vss_init_xy_coordinates
  move.l  #$0000ffff,d3
  move.w  #vss_random_x_max,d4
  move.w  #vss_random_y_max,d5
  lea     vss_xy_coordinates(pc),a0 ;Zeiger auf Tabelle mit XY-Koords
  moveq   #vss_z_planes_number-1,d7 ;Anzahl der Z-Ebenen
vss_init_xy_coordinates_loop1
  move.w  VHPOSR-DMACONR(a6),d1    ;f(x)
  move.w  VHPOSR-DMACONR(a6),d2    ;f(y)
  moveq   #vss_stars_per_plane_number-1,d6 ;Anzahl der Sterne pro Ebene
vss_init_xy_coordinates_loop2
  mulu.w  VHPOSR-DMACONR(a6),d1    ;f(x)*a
  move.w  VHPOSR-DMACONR(a6),d0
  swap    d0
  move.b  CIATODLOW(a4),d0
  lsl.w   #8,d0
  move.b  CIATODLOW(a5),d0   ;b
  add.l   d0,d1              ;(f(x)*a)+b
  and.l   d3,d1              ;Nur Bits 0-15
  mulu.w  VHPOSR-DMACONR(a6),d2    ;f(y)*a
  divu.w  d4,d1              ;[(f(x)*a)+b]/mod
  move.w  VHPOSR-DMACONR(a6),d0
  swap    d0
  move.b  CIATODLOW(a4),d0
  lsl.w   #8,d0
  move.b  CIATODMID(a5),d0   ;b
  add.l   d0,d2              ;(f(y)*a)+b
  swap    d1                 ;Rest der Division
  and.l   d3,d2              ;Nur Bits 0-15
  move.w  d1,d0              ;Zufallswert retten
  divu.w  d5,d2              ;[(f(y)*a)+b]/mod
  lsl.w   #3,d0              ;Zufallswert*8
  move.w  d0,(a0)+           ;X-Koord. retten
  swap    d2                 ;Rest der Division
  move.w  d2,(a0)+           ;Y-Koord. retten
  dbf     d6,vss_init_xy_coordinates_loop2
  subq.w  #16/8,d4           ;X-Max verringern
  dbf     d7,vss_init_xy_coordinates_loop1
  rts


  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 
  bsr.s   cl1_init_playfield_registers
  bsr.s   cl1_init_sprite_pointers
  bsr.s   cl1_init_color_registers
  IFEQ open_border_enabled
    COP_MOVEQ TRUE,COPJMP2
    bsr     cl1_set_sprite_pointers
    rts
  ELSE
    bsr     cl1_init_bitplane_pointers
    COP_MOVEQ TRUE,COPJMP2
    bsr     cl1_set_sprite_pointers
    bra     cl1_set_bitplane_pointers
  ENDC

  IFEQ open_border_enabled
    COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANESSPR
  ELSE
    COP_INIT_PLAYFIELD_REGISTERS cl1
    COP_INIT_BITPLANE_POINTERS cl1
    COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
  ENDC

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_color_registers
  COP_INIT_COLOR_HIGH COLOR00,32,pf1_color_table
  COP_SELECT_COLOR_HIGH_BANK 1
  COP_INIT_COLOR_HIGH COLOR00,29

  COP_SELECT_COLOR_LOW_BANK 0
  COP_INIT_COLOR_LOW COLOR00,32,pf1_color_table
  COP_SELECT_COLOR_LOW_BANK 1
  COP_INIT_COLOR_LOW COLOR00,29
  rts

  COP_SET_SPRITE_POINTERS cl1,display,spr_number


  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction1(a3),a0 
  bsr.s   cl2_init_bplcon4_registers
  bsr.s   cl2_init_copper_interrupt
  COP_LISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE

  COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2

  COPY_COPPERLIST cl2,3


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
  bsr.s   swap_second_copperlist
  bsr.s   vss_swap_switch_buffers
  bsr     effects_handler
  bsr     if_copy_color_table
  bsr     image_pixel_fader_in
  bsr     image_pixel_fader_out
  bsr     ipf_random_pixel_data_copy
  bsr     vert_starscrolling
  bsr     vss_clear_switch_buffer
  bsr     vss_copy_switch_buffer
  bsr     image_fader_in
  bsr     image_fader_out
  jsr     mouse_handler
  tst.l   d0                 ;Abbruch ?
  bne.s   fast_exit          ;Ja -> verzweige
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne.s   beam_routines      ;Nein -> verzweige
fast_exit
  move.w  custom_error_code(a3),d1
  rts


  SWAP_COPPERLIST cl2,3

; ** Switch-Puffer vertauschen **
  CNOP 0,4
vss_swap_switch_buffers
  move.l  vss_switch_buffer_construction1(a3),a0 ;Puffer Vertauschen
  move.l  vss_switch_buffer_display(a3),vss_switch_buffer_construction1(a3)
  move.l  vss_switch_buffer_construction2(a3),a1
  move.l  a0,vss_switch_buffer_construction2(a3)
  move.l  a1,vss_switch_buffer_display(a3)
  rts


; ** Sterne bewegen **
  CNOP 0,4
vert_starscrolling
  movem.l a3-a5,-(a7)
  move.l  a7,save_a7(a3)     
  bsr     vss_init_copy_blit      
  move.l  #((vss_switch_buffer_x_size-(vss_copy_blit_width+2))<<16)+(vss_image_x_size-(vss_copy_blit_width+2)),d2 ;Moduli
  moveq   #vss_z_plane1_speed,d3
  MOVEF.W vss_y_restart,d4
  moveq   #vss_star_x_size,d5 ;Offset für nächsten Stern
  lea     vss_xy_coordinates(pc),a0 ;Zeiger auf XY-Koords
  move.l  vss_switch_table(a3),a1 ;BOB
  add.l   #(vss_z_planes_number-1)*vss_star_x_size,a1 ;Zeiger auf letzten Stern
  move.l  vss_switch_table_mask(a3),a2 ;Maske
  add.l   #(vss_z_planes_number-1)*vss_star_x_size,a2 ;Zeiger auf letzte Maske
  move.l  vss_switch_buffer_construction2(a3),a4 ;Ziel = Puffer
  move.w  #BC0F_SRCA+BC0F_SRCB+BC0F_SRCC+BC0F_DEST+NANBC+NABC+ABNC+ABC,a3 ;Minterm D=A+B
  move.w  #(vss_copy_blit_y_size*64)+((vss_copy_blit_x_size+16)/16),a5
  move.w  #(16*64)+(16/16),a7 ;Additionswert für Blitgröße
  moveq   #vss_z_planes_number-1,d7 ;Anzahl der Ebenen
vert_starscrolling_loop1
  WAITBLIT
  move.l  d2,BLTCMOD-DMACONR(a6)
  swap    d2                 ;Moduli vertauschen
  move.l  d2,BLTAMOD-DMACONR(a6)
  swap    d7                 
  moveq   #vss_stars_per_plane_number-1,d6 ;Anzahl der Sterne pro Ebene
vert_starscrolling_loop2
  moveq   #0,d0
  move.w  (a0)+,d0           ;X-Koord. 
  moveq   #TRUE,d1
  move.w  (a0),d1            ;Y-Koord. 
  ror.l   #4,d0              ;Shift-Bits in richtige Position bringen
  sub.w   d3,d1              ;Y verringern
  bpl.s   vss_no_y_restart   ;Wenn positiv -> verzweige
  add.w   d4,d1              ;Y zurücksetzen
vss_no_y_restart
  move.w  d1,(a0)+           ;Y retten
  MULUF.W vss_switch_buffer_x_size/2,d1,d7 ;Y-Offset in Puffer
  add.w   d0,d1              ;X+Y-Offset
  swap    d0                 ;Shiftwert 
  add.w   d1,d1              ;*2 = XY-Offset
  add.l   a4,d1              ;+ Playfieldadresse
  WAITBLIT
  move.w  d0,BLTCON1-DMACONR(a6)
  add.w   a3,d0              ;+ Minterm
  move.w  d0,BLTCON0-DMACONR(a6)
  move.l  d1,BLTCPT-DMACONR(a6) ;Playfield lesen
  move.l  a1,BLTBPT-DMACONR(a6) ;Stern
  move.l  a2,BLTAPT-DMACONR(a6) ;Stern-Maske
  move.l  d1,BLTDPT-DMACONR(a6) ;Playfield schreiben
  move.w  a5,BLTSIZE-DMACONR(a6) ;Blitter starten
  dbf     d6,vert_starscrolling_loop2
  subq.w  #2,d2              ;Moduli ändern
  addq.w  #1,d3              ;nächste Geschwindigkeit
  swap    d2                 ;Moduli vertauschen
  swap    d7                 ;Schleifenzähler
  subq.w  #2,d2              ;Moduli ändern
  sub.l   d5,a1              ;nächster Stern
  sub.l   d5,a2              ;nächste Stern-Maske
  add.w   a7,a5              ;Blitgröße ändern
  dbf     d7,vert_starscrolling_loop1
  move.l  variables+save_a7(pc),a7 ;Stackpointer
  movem.l (a7)+,a3-a5
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  rts

; ** konstante Blitterregister initialisieren **
  CNOP 0,4
vss_init_copy_blit
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLIT
  move.l  #$ffff0000,BLTAFWM-DMACONR(a6) ;Maske
  rts

; ** Puffer löschen **
  CNOP 0,4
vss_clear_switch_buffer
  move.l  vss_switch_buffer_construction1(a3),a0 ;Zeiger auf Tabelle mit Switchwerten
  WAITBLIT
  move.l  #(BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;Maske aus
  add.l   #vss_switch_buffer_x_size*vss_star_y_size3,a0 ;n Zeilen überspringen
  move.l  a0,BLTDPT-DMACONR(a6)
  moveq   #vss_switch_buffer_x_size-cl2_display_width,d0
  move.w  d0,BLTDMOD-DMACONR(a6) ;D-Mod
  move.w  #(bplcon4_bits&$ff00)+(bplcon4_bits>>8),BLTADAT-DMACONR(a6)
  move.w  #(vss_clear_blit_y_size*64)+(vss_clear_blit_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
  rts

; ** Puffer mit Switchwerten in Copperliste kopieren **
; -----------------------------------------------------
  CNOP 0,4
vss_copy_switch_buffer
  move.l  vss_switch_buffer_construction2(a3),a0 ;Tabelle mit Switchwerten
  add.l   #vss_switch_buffer_x_size*vss_star_y_size3,a0 ;n Zeilen überspringen
  move.l  cl2_construction2(a3),a1 
  ADDF.W cl2_extension1_entry+cl2_ext1_BPLCON4_1+2,a1
  move.w  #cl2_extension1_size,a2
  MOVEF.W cl2_display_y_size-1,d7 ;Effekt für x Zeilen
vss_copy_switch_buffer_loop
  movem.l (a0)+,d0-d6        ;28 Switchwerte lesen
  move.b  d0,LONGWORD_SIZE*3(a1)
  swap    d0
  move.b  d0,LONGWORD_SIZE*1(a1)
  lsr.l   #8,d0
  move.b  d0,(a1)
  swap    d0
  move.b  d0,LONGWORD_SIZE*2(a1)
  move.b  d1,LONGWORD_SIZE*7(a1)
  swap    d1
  move.b  d1,LONGWORD_SIZE*5(a1)
  lsr.l   #8,d1
  move.b  d1,LONGWORD_SIZE*4(a1)
  swap    d1
  move.b  d1,LONGWORD_SIZE*6(a1)
  move.b  d2,LONGWORD_SIZE*11(a1)
  swap    d2
  move.b  d2,LONGWORD_SIZE*9(a1)
  lsr.l   #8,d2
  move.b  d2,LONGWORD_SIZE*8(a1)
  swap    d2
  move.b  d2,LONGWORD_SIZE*10(a1)
  move.b  d3,LONGWORD_SIZE*15(a1)
  swap    d3
  move.b  d3,LONGWORD_SIZE*13(a1)
  lsr.l   #8,d3
  move.b  d3,LONGWORD_SIZE*12(a1)
  swap    d3
  move.b  d3,LONGWORD_SIZE*14(a1)
  move.b  d4,LONGWORD_SIZE*19(a1)
  swap    d4
  move.b  d4,LONGWORD_SIZE*17(a1)
  lsr.l   #8,d4
  move.b  d4,LONGWORD_SIZE*16(a1)
  swap    d4
  move.b  d4,LONGWORD_SIZE*18(a1)
  move.b  d5,LONGWORD_SIZE*23(a1)
  swap    d5
  move.b  d5,LONGWORD_SIZE*21(a1)
  lsr.l   #8,d5
  move.b  d5,LONGWORD_SIZE*20(a1)
  swap    d5
  move.b  d5,LONGWORD_SIZE*22(a1)
  move.b  d6,LONGWORD_SIZE*27(a1)
  swap    d6
  move.b  d6,LONGWORD_SIZE*25(a1)
  lsr.l   #8,d6
  move.b  d6,LONGWORD_SIZE*24(a1)
  swap    d6
  move.b  d6,LONGWORD_SIZE*26(a1)
  movem.l (a0)+,d0-d3      ;16 Switchwerte lesen
  move.b  d0,LONGWORD_SIZE*31(a1)
  swap    d0
  move.b  d0,LONGWORD_SIZE*29(a1)
  lsr.l   #8,d0
  move.b  d0,LONGWORD_SIZE*28(a1)
  swap    d0
  move.b  d0,LONGWORD_SIZE*30(a1)
  move.b  d1,LONGWORD_SIZE*35(a1)
  swap    d1
  move.b  d1,LONGWORD_SIZE*33(a1)
  lsr.l   #8,d1
  move.b  d1,LONGWORD_SIZE*32(a1)
  swap    d1
  move.b  d1,LONGWORD_SIZE*34(a1)
  move.b  d2,LONGWORD_SIZE*39(a1)
  swap    d2
  move.b  d2,LONGWORD_SIZE*37(a1)
  lsr.l   #8,d2
  move.b  d2,LONGWORD_SIZE*36(a1)
  swap    d2
  move.b  d2,LONGWORD_SIZE*38(a1)
  add.l   a2,a1              ;nächste Zeile in CL
  move.b  d3,(LONGWORD_SIZE*43)-cl2_extension1_size(a1)
  swap    d3
  move.b  d3,(LONGWORD_SIZE*41)-cl2_extension1_size(a1)
  lsr.l   #8,d3
  move.b  d3,(LONGWORD_SIZE*40)-cl2_extension1_size(a1)
  swap    d3
  move.b  d3,(LONGWORD_SIZE*42)-cl2_extension1_size(a1)
  dbf     d7,vss_copy_switch_buffer_loop
  rts


; ** Grafik einblenden **
  CNOP 0,4
image_fader_in
  tst.w   ifi_active(a3)     ;Image-Fader-In an ?
  bne.s   no_image_fader_in  ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifi_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  addq.w  #ifi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifi_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifi_save_fader_angle
  move.w  d0,ifi_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  addq.w  #ifi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORD_SIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifi_color_table+(if_color_table_offset*LONGWORD_SIZE)(pc),a1 ;Sollwerte
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
  move.w  #FALSE,ifi_active(a3)  ;Image-Fader-In aus
no_image_fader_in
  rts

; ** Grafik ausblenden **
  CNOP 0,4
image_fader_out
  tst.w   ifo_active(a3)     ;Image-Fader-Out an ?
  bne.s   no_image_fader_out ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifo_fader_angle(a3),d2 ;Fader-Winkel 
  move.w  d2,d0
  addq.w  #ifo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifo_save_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifo_save_fader_angle
  move.w  d0,ifo_fader_angle(a3) 
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table,a0      
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  addq.w  #ifo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORD_SIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifo_color_table+(if_color_table_offset*LONGWORD_SIZE)(pc),a1 ;Sollwerte
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
  move.w  #FALSE,ifo_active(a3)  ;Image-Fader-Out aus
no_image_fader_out
  rts

  COLOR_FADER if

; ** Farbwerte in Copperliste kopieren **
  COPY_COLOR_TABLE_TO_COPPERLIST if,pf1,cl1,cl1_COLOR01_high1,cl1_COLOR01_low1

; ** Logo Pixelweise einblenden **
  CNOP 0,4
image_pixel_fader_in
  tst.w   ipfi_active(a3)    ;Image-Pixel-Fader-In an ?
  bne.s   no_image_pixel_fader_in ;FALSE -> verzweige
  subq.w  #1,ipfi_delay_counter(a3) ;Zähler verringern
  bgt.s   no_image_pixel_fader_in ;Wenn > Null -> verzweige
  move.w  ipfi_delay_angle(a3),d2 ;Winkel 
  move.w  d2,d0
  addq.w  #ipfi_delay_angle_speed,d0 ;nächster Winkel
  cmp.w   #sine_table_length/2,d0 ;<= 180 Grad ?
  ble.s   ipfi_save_delay_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ipfi_save_delay_angle
  move.w  d0,ipfi_delay_angle(a3) ;Winkel retten
  lea     sine_table,a0      
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
  move.w  #FALSE,ipfi_active(a3) ;Image-Pixel-Fader-In aus
  rts

; ** Logo Pixelweise ausblenden **
  CNOP 0,4
image_pixel_fader_out
  tst.w   ipfo_active(a3)    ;Image-Pixel-Fader-Out an ?
  bne.s   no_image_pixel_fader_out ;FALSE -> verzweige
  subq.w  #1,ipfo_delay_counter(a3) ;Zähler verringern
  bgt.s   no_image_pixel_fader_out ;Wenn > Null -> verzweige
  move.w  ipfo_delay_angle(a3),d2 ;Winkel 
  move.w  d2,d0
  addq.w  #ipfo_delay_angle_speed,d0 ;nächster Winkel
  cmp.w   #sine_table_length/2,d0 ;<= 180 Grad ?
  ble.s   ipfo_save_delay_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ipfo_save_delay_angle
  move.w  d0,ipfo_delay_angle(a3) ;Winkel retten
  lea     sine_table,a0      
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
  move.w  #FALSE,ipfo_active(a3) ;Image-Pixel-Fader-Out aus
  moveq   #0,d0
  move.l  d0,ipf_mask(a3)    ;Maske = NULL
  rts

; ** Objekt pixelweise ins Playfield kopieren **
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
  MOVEF.W  lg_image_y_size-1,d7 ;Anzahl der Zeilen
  move.w  #lg_image_plane_width-8,a2
  move.w  #(lg_image_plane_width*3)-8,a4
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
  beq.s   eh_start_image_fader_in
  subq.w  #1,d0
  beq.s   eh_start_image_pixel_fader_in
  subq.w  #1,d0
  beq.s   eh_start_image_fader_out
  subq.w  #1,d0
  beq.s   eh_start_image_pixel_fader_out
  subq.w  #1,d0
  beq.s   eh_stop_all
no_effects_handler
  rts
  CNOP 0,4
eh_start_image_fader_in
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #0,d0
  move.w  d0,ifi_active(a3) ;Image-Fader-In an
  move.w  d0,if_copy_colors_active(a3) ;Kopieren der Farnwerte an
  rts
  CNOP 0,4
eh_start_image_pixel_fader_in
  clr.w   ipfi_active(a3)    ;Image-Pixel-Fader-In an
  moveq   #1,d2
  move.w  d2,ipfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
eh_start_image_fader_out
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #0,d0
  move.w  d0,ifo_active(a3)  ;Image-Fader-Out an
  moveq   #1,d2
  move.w  d2,ipfo_delay_counter(a3) ;Verzögerungszähler aktivieren
  move.w  d0,if_copy_colors_active(a3) ;Kopieren der Farbwerte an
  rts
  CNOP 0,4
eh_start_image_pixel_fader_out
  clr.w   ipfo_active(a3)    ;Image-Pixel-Fader-Out an
  rts
  CNOP 0,4
eh_stop_all
  clr.w   fx_active(a3)      ;Effekt beenden
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
  REPT pf1_colors_number
    DC.L color00_bits
  ENDR

; ** Farben der Sprites **
spr_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/256x87x16-TheEnd.ct"

; ** Adressen der Sprites **
spr_pointers_display
  DS.L spr_number

; **** Vert-Starscrolling ****
; ** Tabelle mit XY-Koordinaten **
  CNOP 0,2
vss_xy_coordinates
  DS.W vss_z_planes_number*vss_stars_per_plane_number*2

; **** Image-Fader ****
; ** Zielfarbwerte für TImage-Fader-In **
  CNOP 0,4
ifi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/RasterMaster/colortables/0c_vss_Colorgradient.ct"

; ** Zielfarbwerte für Image-Fader-Out **
ifo_color_table
  REPT pf1_colors_number
    DC.L color00_bits
  ENDR


  INCLUDE "sys-variables.i"


  INCLUDE "sys-names.i"


  INCLUDE "error-texts.i"


; ## Grafikdaten nachladen ##

; **** Vert-Starscrolling ****
vss_image_data SECTION vss_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/64x56x64-3D-Stars.rawblit"
vss_image_mask
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/64x56x64-3D-Stars-Mask.rawblit"

; **** Logo ****
lg_image_data SECTION lg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/graphics/256x87x16-TheEnd.rawblit"

  END
