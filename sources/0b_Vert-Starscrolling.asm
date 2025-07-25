; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF mouse_handler
	XREF sine_table

	XDEF start_0b_vert_starscrolling


	INCDIR "include3.5:"

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


SYS_TAKEN_OVER			SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1


	INCDIR "custom-includes-aga:"


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE	
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU FALSE
screen_fader_enabled		EQU FALSE
text_output_enabled		EQU FALSE

open_border_enabled		EQU TRUE

	IFEQ open_border_enabled
dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_SETCLR
	ELSE
dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR
	ENDC

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
	IFEQ open_border_enabled
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
	ELSE
pf1_x_size3			EQU 32
pf1_y_size3			EQU 1
pf1_depth3			EQU 1
	ENDC
pf1_colors_number		EQU 61

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 0

spr_number			EQU 8
spr_x_size1			EQU 0
spr_x_size2			EQU 64
spr_depth			EQU 2
spr_colors_number		EQU 0	; 16
spr_odd_color_table_select	EQU 4
spr_even_color_table_select	EQU 4
spr_used_number			EQU 8

audio_memory_size		EQU 0

disk_memory_size		EQU 0

extra_memory_size		EQU 0

ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
ciab_ta_time			EQU 0
ciab_tb_time			EQU 0
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
ciab_ta_continuous_enabled	EQU FALSE
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $136

pixel_per_line			EQU 32
visible_pixels_number		EQU 352
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 16	; 1x
spr_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))

	IFEQ open_border_enabled
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon3_bits3			EQU bplcon3_bits1|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon3_bits4			EQU bplcon3_bits2|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM
	ELSE
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_OVERSCAN_32_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon3_bits3			EQU bplcon3_bits1|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon3_bits4			EQU bplcon3_bits2|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM
	ENDC

cl2_display_x_size		EQU 352
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU visible_lines_number

	IFEQ open_border_enabled
cl2_hstart1			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
	ELSE
cl2_hstart1			EQU display_window_hstart-4
	ENDC
cl2_vstart1			EQU MINROW
cl2_hstart2			EQU 0
cl2_vstart2			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 256

; Logo
lg_image_x_size			EQU 256
lg_image_plane_width		EQU lg_image_x_size/8
lg_image_y_size			EQU 87
lg_image_depth			EQU 16

lg_image_x_center		EQU (visible_pixels_number-lg_image_x_size)/2
lg_image_y_center		EQU (visible_lines_number-lg_image_y_size)/2
lg_image_x_position		EQU display_window_hstart+10+lg_image_x_center
lg_image_y_position		EQU display_window_vstart+lg_image_y_center

; Vert-Starscrolling
vss_image_x_size		EQU 64
vss_image_plane_width		EQU vss_image_x_size/8
vss_image_y_size		EQU 56
vss_image_depth			EQU 6

vss_star_x_size			EQU 16
vss_star_y_size1		EQU 24
vss_star_y_size2		EQU 40
vss_star_y_size3		EQU 56

vss_z_planes_number		EQU 3
vss_z_plane1_speed		EQU 1
vss_z_plane2_speed		EQU 2
vss_z_plane3_speed		EQU 3

vss_random_x_max		EQU cl2_display_width-((vss_star_x_size*2)/8)
vss_random_y_max		EQU cl2_display_y_size+vss_star_y_size3
vss_y_restart			EQU cl2_display_y_size+vss_star_y_size3

vss_stars_per_plane_number	EQU 6

vss_bplam_table_number		EQU 2
vss_bplam_buffer_number		EQU 3
vss_bplam_buffer_x_size		EQU 44
vss_bplam_buffer_y_size		EQU cl2_display_y_size+(vss_star_y_size3*2)+1

vss_copy_blit_x_size		EQU 32
vss_copy_blit_width		EQU vss_copy_blit_x_size/8
vss_copy_blit_y_size		EQU vss_star_y_size1
vss_copy_blit_depth		EQU 1

; Clear-Blit
vss_clear_blit_x_size		EQU cl2_display_x_size
vss_clear_blit_y_size		EQU cl2_display_y_size

; Image-Fader
if_rgb8_start_color		EQU 1
if_rgb8_color_table_offset	EQU 1
if_rgb8_colors_number		EQU pf1_colors_number-1

; Image-Fader-In
ifi_rgb8_fader_speed_max	EQU 4
ifi_rgb8_fader_radius		EQU ifi_rgb8_fader_speed_max
ifi_rgb8_fader_center		EQU ifi_rgb8_fader_speed_max+1
ifi_rgb8_fader_angle_speed	EQU 1

; Image-Fader-Out
ifo_rgb8_fader_speed_max	EQU 3
ifo_rgb8_fader_radius		EQU ifo_rgb8_fader_speed_max
ifo_rgb8_fader_center		EQU ifo_rgb8_fader_speed_max+1
ifo_rgb8_fader_angle_speed	EQU 1

; Image-Pixel-Fader
ipf_source_size			EQU 32
ipf_destination_size_min	EQU 1

; Image-Pixel-Fader-In
ipfi_delay			EQU 6
ipfi_delay_radius		EQU ipfi_delay
ipfi_delay_center		EQU ipfi_delay+1
ipfi_delay_angle_speed	EQU 1

; Image-Pixel-Fader-Out
ipfo_delay			EQU 8
ipfo_delay_radius		EQU ipfo_delay
ipfo_delay_center		EQU ipfo_delay+1
ipfo_delay_angle_speed		EQU 1

; Effects-Handler
eh_trigger_number_max		EQU 5


color_step1			EQU 256/(vss_star_y_size3/2)
color_step2			EQU 128/(vss_star_y_size2/2)
color_step3			EQU 64/(vss_star_y_size1/2)
color_values_number1		EQU vss_star_y_size3/2
color_values_number2		EQU vss_star_y_size2/2
color_values_number3		EQU vss_star_y_size1/2
segments_number1		EQU 1
segments_number2		EQU 1
segments_number3		EQU 1

ct_size1			EQU color_values_number1*segments_number1
ct_size2			EQU color_values_number2*segments_number2
ct_size3			EQU color_values_number3*segments_number3

vss_bplam_table_size		EQU vss_image_x_size*vss_image_y_size
vss_bplam_buffer_size		EQU vss_bplam_buffer_x_size*vss_bplam_buffer_y_size

chip_memory_size		EQU ((vss_bplam_table_size*vss_bplam_table_number)+(vss_bplam_buffer_size*vss_bplam_buffer_number))*BYTE_SIZE


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAIT			RS.L 1
	IFEQ open_border_enabled 
cl2_ext1_BPL1DAT		RS.L 1
	ENDC
cl2_ext1_BPLCON4_1		RS.L 1
cl2_ext1_BPLCON4_2		RS.L 1
cl2_ext1_BPLCON4_3		RS.L 1
cl2_ext1_BPLCON4_4		RS.L 1
cl2_ext1_BPLCON4_5		RS.L 1
cl2_ext1_BPLCON4_6		RS.L 1
cl2_ext1_BPLCON4_7		RS.L 1
cl2_ext1_BPLCON4_8		RS.L 1
cl2_ext1_BPLCON4_9		RS.L 1
cl2_ext1_BPLCON4_10		RS.L 1
cl2_ext1_BPLCON4_11		RS.L 1
cl2_ext1_BPLCON4_12		RS.L 1
cl2_ext1_BPLCON4_13		RS.L 1
cl2_ext1_BPLCON4_14		RS.L 1
cl2_ext1_BPLCON4_15		RS.L 1
cl2_ext1_BPLCON4_16		RS.L 1
cl2_ext1_BPLCON4_17		RS.L 1
cl2_ext1_BPLCON4_18		RS.L 1
cl2_ext1_BPLCON4_19		RS.L 1
cl2_ext1_BPLCON4_20		RS.L 1
cl2_ext1_BPLCON4_21		RS.L 1
cl2_ext1_BPLCON4_22		RS.L 1
cl2_ext1_BPLCON4_23		RS.L 1
cl2_ext1_BPLCON4_24		RS.L 1
cl2_ext1_BPLCON4_25		RS.L 1
cl2_ext1_BPLCON4_26		RS.L 1
cl2_ext1_BPLCON4_27		RS.L 1
cl2_ext1_BPLCON4_28		RS.L 1
cl2_ext1_BPLCON4_29		RS.L 1
cl2_ext1_BPLCON4_30		RS.L 1
cl2_ext1_BPLCON4_31		RS.L 1
cl2_ext1_BPLCON4_32		RS.L 1
cl2_ext1_BPLCON4_33		RS.L 1
cl2_ext1_BPLCON4_34		RS.L 1
cl2_ext1_BPLCON4_35		RS.L 1
cl2_ext1_BPLCON4_36		RS.L 1
cl2_ext1_BPLCON4_37		RS.L 1
cl2_ext1_BPLCON4_38		RS.L 1
cl2_ext1_BPLCON4_39		RS.L 1
cl2_ext1_BPLCON4_40		RS.L 1
cl2_ext1_BPLCON4_41		RS.L 1
cl2_ext1_BPLCON4_42		RS.L 1
cl2_ext1_BPLCON4_43		RS.L 1
cl2_ext1_BPLCON4_44		RS.L 1

cl2_extension1_size		RS.B 0

	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size*cl2_display_y_size

cl2_WAIT1			RS.L 1
cl2_INTREQ			RS.L 1

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size

cl2_size1			EQU copperlist2_size
cl2_size2			EQU copperlist2_size
cl2_size3			EQU copperlist2_size


; Sprite0 additional structure
	RSRESET

spr0_extension1			RS.B 0

spr0_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr0_extension1_size		RS.B 0

; Sprite0 main structure
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry		RS.B spr0_extension1_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite0_size			RS.B 0

; Sprite1 additional structure
	RSRESET

spr1_extension1	RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr1_extension1_size		RS.B 0

; Sprite1 main structure
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite1_size			RS.B 0

; Sprite2 additional structure
	RSRESET

spr2_extension1			RS.B 0

spr2_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr2_extension1_size		RS.B 0

; Sprite2 main structure
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size

spr2_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite2_size			RS.B 0

; Sprite3 additional structure
	RSRESET

spr3_extension1			RS.B 0

spr3_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr3_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr3_extension1_size		RS.B 0

; Sprite3 main structure
	RSRESET

spr3_begin			RS.B 0

spr3_extension1_entry		RS.B spr3_extension1_size

spr3_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite3_size			RS.B 0

; Sprite4 additional structure
	RSRESET

spr4_extension1			RS.B 0

spr4_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr4_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr4_extension1_size		RS.B 0

; Sprite4 main structure
	RSRESET

spr4_begin			RS.B 0

spr4_extension1_entry		RS.B spr4_extension1_size

spr4_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite4_size			RS.B 0

; Sprite5 additional structure
	RSRESET

spr5_extension1			RS.B 0

spr5_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr5_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr5_extension1_size		RS.B 0

; Sprite5 main structure
	RSRESET

spr5_begin			RS.B 0

spr5_extension1_entry		RS.B spr5_extension1_size

spr5_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite5_size			RS.B 0

; Sprite6 additional structure
	RSRESET

spr6_extension1			RS.B 0

spr6_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr6_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr6_extension1_size		RS.B 0

; Sprite6 main structure
	RSRESET

spr6_begin			RS.B 0

spr6_extension1_entry		RS.B spr6_extension1_size

spr6_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite6_size			RS.B 0

; Sprite7 additional structure
	RSRESET

spr7_extension1			RS.B 0

spr7_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr7_ext1_planedata		RS.L (spr_pixel_per_datafetch/WORD_BITS)*lg_image_y_size

spr7_extension1_size		RS.B 0

; Sprite7 main structure
	RSRESET

spr7_begin			RS.B 0

spr7_extension1_entry		RS.B spr7_extension1_size

spr7_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite7_size			RS.B 0


spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU 0
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU 0
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU 0
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU 0
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU 0
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU 0
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU 0
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU 0

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU sprite0_size/(spr_x_size2/4)
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/(spr_x_size2/4)
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/(spr_x_size2/4)
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/(spr_x_size2/4)
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/(spr_x_size2/4)
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/(spr_x_size2/4)
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/(spr_x_size2/4)
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/(spr_x_size2/4)


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; Vert-Starscrolling
vss_bplam_table			RS.L 1
vss_bplam_table_mask		RS.L 1

vss_bplam_buffer_construction1	RS.L 1
vss_bplam_buffer_construction2	RS.L 1
vss_bplam_buffer_display	RS.L 1

; Image-Fader
if_rgb8_colors_counter		RS.W 1
if_rgb8_copy_colors_active	RS.W 1

; Image-Fader-In
ifi_rgb8_active			RS.W 1
ifi_rgb8_fader_angle		RS.W 1

; Image-Fader-Out
ifo_rgb8_active			RS.W 1
ifo_rgb8_fader_angle		RS.W 1

; Image-Pixel-Fader
ipf_mask			RS.L 1
ipf_destination_size		RS.W 1

; Image-Pixel-Fader-In
ipfi_active			RS.W 1
ipfi_delay_counter		RS.W 1
ipfi_delay_angle		RS.W 1

; Image-Pixel-Fader-Out
ipfo_active			RS.W 1
ipfo_delay_counter		RS.W 1
ipfo_delay_angle		RS.W 1

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_0b_vert_starscrolling


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Vert-Starscrolling
	move.l	chip_memory(a3),a0
	move.l	a0,vss_bplam_table(a3)	; stars
	add.l	#vss_bplam_table_size,a0
	move.l	a0,vss_bplam_table_mask(a3) ; stars masks
	add.l	#vss_bplam_table_size,a0

	move.l	a0,vss_bplam_buffer_construction1(a3)
	add.l	#vss_bplam_buffer_size,a0
	move.l	a0,vss_bplam_buffer_construction2(a3)
	add.l	#vss_bplam_buffer_size,a0
	move.l	a0,vss_bplam_buffer_display(a3)

; Image-Fader
	moveq	#TRUE,d0
	move.w	d0,if_rgb8_colors_counter(a3)
	moveq	#FALSE,d1
	move.w	d1,if_rgb8_copy_colors_active(a3)

; Image-Fader-In
	move.w	d1,ifi_rgb8_active(a3)
	moveq	#sine_table_length/4,d2
	move.w	d2,ifi_rgb8_fader_angle(a3) ; 90°

; Image-Fader-Out
	move.w	d1,ifo_rgb8_active(a3)
	move.w	d2,ifo_rgb8_fader_angle(a3) ; 90°

; Image-Pixel-Fader
	move.l	d0,ipf_mask(a3)
	move.w	#ipf_destination_size_min,ipf_destination_size(a3)

; Image-Pixel-Fader-In
	move.w	d1,ipfi_active(a3)
	move.w	d0,ipfi_delay_counter(a3)
	move.w	d2,ipfi_delay_angle(a3) ; 90°

; Image-Pixel-Fader-Out
	move.w	d1,ipfo_active(a3)
	move.w	d0,ipfo_delay_counter(a3)
	move.w	d2,ipfo_delay_angle(a3) ; 90°

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	init_colors
	bsr.s	init_sprites
	bsr	vss_convert_image_data
	bsr	vss_init_bplam_table_mask
	bsr	vss_init_xy_coordinates
	bsr	init_first_copperlist
	bra	init_second_copperlist


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 2
	CPU_INIT_COLOR_HIGH COLOR00,16,spr_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 2
	CPU_INIT_COLOR_LOW COLOR00,16,spr_rgb8_color_table
	rts


; Logo
	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bra.s	lg_init_attached_sprites_cluster

	INIT_SPRITE_POINTERS_TABLE

	INIT_ATTACHED_SPRITES_CLUSTER lg,spr_pointers_display,lg_image_x_position,lg_image_y_position,spr_x_size2,lg_image_y_size,,BLANK

	CONVERT_IMAGE_TO_BPLCON4_CHUNKY.B vss,vss_bplam_table,a3


; Vert-Starscrolling
	CNOP 0,4
vss_init_bplam_table_mask
	MOVEF.L vss_image_plane_width*(vss_image_depth-1),d3
	lea	vss_image_mask,a0	; plane 1
	move.l	vss_bplam_table_mask(a3),a1
	moveq	#vss_image_y_size-1,d7
vss_init_bplam_table_mask_loop1
	moveq	#vss_image_plane_width-1,d6 ; number of bytes per line
vss_init_bplam_table_mask_loop2
	move.b	(a0)+,d0
	moveq	#BYTE_BITS-1,d5
vss_init_bplam_table_mask_loop3
	add.b	d0,d0			; next bit
	scs	d2
	move.b	d2,(a1)+		; mask
	dbf	d5,vss_init_bplam_table_mask_loop3
	dbf	d6,vss_init_bplam_table_mask_loop2
	add.l	d3,a0			; next line in plane 1
	dbf	d7,vss_init_bplam_table_mask_loop1
	rts

	CNOP 0,4
vss_init_xy_coordinates
	move.l	#$0000ffff,d3
	move.w	#vss_random_x_max,d4
	move.w	#vss_random_y_max,d5
	lea	vss_xy_coordinates(pc),a0
	moveq	#vss_z_planes_number-1,d7
vss_init_xy_coordinates_loop1
	move.w	VHPOSR-DMACONR(a6),d1	; f(x)
	move.w	VHPOSR-DMACONR(a6),d2	; f(y)
	moveq	#vss_stars_per_plane_number-1,d6
vss_init_xy_coordinates_loop2
	mulu.w	VHPOSR-DMACONR(a6),d1	; f(x)*a
	move.w	VHPOSR-DMACONR(a6),d0
	swap	d0
	move.b	CIATODLOW(a4),d0
	lsl.w	#8,d0
	move.b	CIATODLOW(a5),d0	; b
	add.l	d0,d1			; (f(x)*a)+b
	and.l	d3,d1			; only low word
	mulu.w	VHPOSR-DMACONR(a6),d2	; f(y)*a
	divu.w	d4,d1			; [(f(x)*a)+b]/mod
	move.w	VHPOSR-DMACONR(a6),d0
	swap	d0
	move.b	CIATODLOW(a4),d0
	lsl.w	#8,d0
	move.b	CIATODMID(a5),d0	; b
	add.l	d0,d2			; (f(y)*a)+b
	swap	d1			; division remainder
	and.l	d3,d2			; only low word
	move.w	d1,d0			; random number
	divu.w	d5,d2			; [(f(y)*a)+b]/mod
	lsl.w	#3,d0			; x coordinate
	move.w	d0,(a0)+
	swap	d2			; division remainder
	move.w	d2,(a0)+		; y coordinate
	dbf	d6,vss_init_xy_coordinates_loop2
	subq.w	#16/BYTE_BITS,d4	; reduce x max
	dbf	d7,vss_init_xy_coordinates_loop1
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0 
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_sprite_pointers
	bsr.s	cl1_init_colors
	IFEQ open_border_enabled
		COP_MOVEQ 0,COPJMP2
		bsr	cl1_set_sprite_pointers
		rts
	ELSE
		bsr	cl1_init_bitplane_pointers
		COP_MOVEQ 0,COPJMP2
		bsr	cl1_set_sprite_pointers
		bra	cl1_set_bitplane_pointers
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
cl1_init_colors
	COP_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_HIGH_BANK 1
	COP_INIT_COLOR_HIGH COLOR00,29

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_LOW_BANK 1
	COP_INIT_COLOR_LOW COLOR00,29
	rts


	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction1(a3),a0 
	bsr.s	cl2_init_bplcon4_chunky
	bsr.s	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bra	set_second_copperlist


	COP_INIT_BPLCON4_CHUNKY cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE


	COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2


	COPY_COPPERLIST cl2,3


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr.s	vss_swap_bplam_buffers
	bsr	effects_handler
	bsr	if_rgb8_copy_color_table
	bsr	image_pixel_fader_in
	bsr	image_pixel_fader_out
	bsr	ipf_random_pixel_data_copy
	bsr	vert_starscrolling
	bsr	vss_clear_bplam_buffer
	bsr	vss_copy_bplam_buffer
	bsr	image_fader_in
	bsr	image_fader_out
	jsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s   beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,3


	SET_COPPERLIST cl2


	CNOP 0,4
vss_swap_bplam_buffers
	move.l	vss_bplam_buffer_construction1(a3),a0
	move.l	vss_bplam_buffer_display(a3),vss_bplam_buffer_construction1(a3)
	move.l	vss_bplam_buffer_construction2(a3),a1
	move.l	a0,vss_bplam_buffer_construction2(a3)
	move.l	a1,vss_bplam_buffer_display(a3)
	rts


	CNOP 0,4
vert_starscrolling
	movem.l a3-a5,-(a7)
	move.l	a7,save_a7(a3)	
	bsr	vert_starscrolling_init
	move.l	#((vss_bplam_buffer_x_size-(vss_copy_blit_width+2))<<16)|(vss_image_x_size-(vss_copy_blit_width+2)),d2 ; Moduli
	moveq	#vss_z_plane1_speed,d3
	MOVEF.W vss_y_restart,d4
	moveq	#vss_star_x_size,d5	; offset next star
	lea	vss_xy_coordinates(pc),a0
	move.l	vss_bplam_table(a3),a1
	add.l	#(vss_z_planes_number-1)*vss_star_x_size,a1 ; last star
	move.l	vss_bplam_table_mask(a3),a2 ; Maske
	add.l	#(vss_z_planes_number-1)*vss_star_x_size,a2 ; mask
	move.l	vss_bplam_buffer_construction2(a3),a4 ; destination: buffer
	move.w	#BC0F_SRCA|BC0F_SRCB|BC0F_SRCC|BC0F_DEST+NANBC|NABC|ABNC|ABC,a3 ; minterm D=A+B
	move.w	#((vss_copy_blit_y_size)<<6)|((vss_copy_blit_x_size+16)/WORD_BITS),a5
	move.w	#(16<<6)|(16/WORD_BITS),a7 ; addition value blit size
	moveq	#vss_z_planes_number-1,d7
vert_starscrolling_loop1
	WAITBLIT
	move.l	d2,BLTCMOD-DMACONR(a6)
	swap	d2			; swap moduli
	move.l	d2,BLTAMOD-DMACONR(a6)
	swap	d7			
	moveq	#vss_stars_per_plane_number-1,d6
vert_starscrolling_loop2
	moveq	#0,d0
	move.w	(a0)+,d0		; x
	moveq	#0,d1
	move.w	(a0),d1			; y
	ror.l	#4,d0			; adjust bits
	sub.w	d3,d1			; decrease y
	bpl.s	vert_starscrolling_skip
	add.w	d4,d1			; reset y
vert_starscrolling_skip
	move.w	d1,(a0)+
	MULUF.W vss_bplam_buffer_x_size/2,d1,d7 ; y offset in buffer
	add.w	d0,d1			; x offset+y offset
	swap	d0			; shift
	add.w	d1,d1			; xy offset
	add.l	a4,d1			; add playfield address
	WAITBLIT
	move.w	d0,BLTCON1-DMACONR(a6)
	add.w	a3,d0			; add minterm
	move.w	d0,BLTCON0-DMACONR(a6)
	move.l	d1,BLTCPT-DMACONR(a6)	; playfield read
	move.l	a1,BLTBPT-DMACONR(a6)	; star
	move.l	a2,BLTAPT-DMACONR(a6)	; starmask
	move.l	d1,BLTDPT-DMACONR(a6)	; playfield write
	move.w	a5,BLTSIZE-DMACONR(a6)
	dbf	d6,vert_starscrolling_loop2
	subq.w	#WORD_SIZE,d2		; change moduli
	addq.w	#1,d3			; next velocity
	swap	d2			; swap moduli
	swap	d7			; loop counter
	subq.w	#WORD_SIZE,d2		; swap moduli
	sub.l	d5,a1			; next star
	sub.l	d5,a2			; next star mask
	add.w	a7,a5			; change blit size
	dbf	d7,vert_starscrolling_loop1
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a5
	rts
	CNOP 0,4
vert_starscrolling_init
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#$ffff0000,BLTAFWM-DMACONR(a6) ; Maske
	rts


	CNOP 0,4
vss_clear_bplam_buffer
	move.l	vss_bplam_buffer_construction1(a3),a0
	WAITBLIT
	move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	add.l	#vss_bplam_buffer_x_size*vss_star_y_size3,a0 ; skip n lines
	move.l	a0,BLTDPT-DMACONR(a6)
	moveq	#vss_bplam_buffer_x_size-cl2_display_width,d0
	move.w	d0,BLTDMOD-DMACONR(a6)
	move.w	#(bplcon4_bits&$ff00)+(bplcon4_bits>>8),BLTADAT-DMACONR(a6)
	move.w	#((vss_clear_blit_y_size)<<6)|(vss_clear_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	rts


	CNOP 0,4
vss_copy_bplam_buffer
	move.l	vss_bplam_buffer_construction2(a3),a0
	add.l	#vss_bplam_buffer_x_size*vss_star_y_size3,a0 ; skip n lines
	move.l	cl2_construction2(a3),a1 
	ADDF.W cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE,a1
	move.w	#cl2_extension1_size,a2
	MOVEF.W cl2_display_y_size-1,d7
vss_copy_bplam_buffer_loop
	movem.l (a0)+,d0-d6		; fetch 28x BPLAM
	move.b	d0,LONGWORD_SIZE*3(a1)	; BPLCON4 high
	swap	d0
	move.b	d0,LONGWORD_SIZE*1(a1)
	lsr.l	#8,d0
	move.b	d0,(a1)
	swap	d0
	move.b	d0,LONGWORD_SIZE*2(a1)
	move.b	d1,LONGWORD_SIZE*7(a1)
	swap	d1
	move.b	d1,LONGWORD_SIZE*5(a1)
	lsr.l	#8,d1
	move.b	d1,LONGWORD_SIZE*4(a1)
	swap	d1
	move.b	d1,LONGWORD_SIZE*6(a1)
	move.b	d2,LONGWORD_SIZE*11(a1)
	swap	d2
	move.b	d2,LONGWORD_SIZE*9(a1)
	lsr.l	#8,d2
	move.b	d2,LONGWORD_SIZE*8(a1)
	swap	d2
	move.b	d2,LONGWORD_SIZE*10(a1)
	move.b	d3,LONGWORD_SIZE*15(a1)
	swap	d3
	move.b	d3,LONGWORD_SIZE*13(a1)
	lsr.l	#8,d3
	move.b	d3,LONGWORD_SIZE*12(a1)
	swap	d3
	move.b	d3,LONGWORD_SIZE*14(a1)
	move.b	d4,LONGWORD_SIZE*19(a1)
	swap	d4
	move.b	d4,LONGWORD_SIZE*17(a1)
	lsr.l	#8,d4
	move.b	d4,LONGWORD_SIZE*16(a1)
	swap	d4
	move.b	d4,LONGWORD_SIZE*18(a1)
	move.b	d5,LONGWORD_SIZE*23(a1)
	swap	d5
	move.b	d5,LONGWORD_SIZE*21(a1)
	lsr.l	#8,d5
	move.b	d5,LONGWORD_SIZE*20(a1)
	swap	d5
	move.b	d5,LONGWORD_SIZE*22(a1)
	move.b	d6,LONGWORD_SIZE*27(a1)
	swap	d6
	move.b	d6,LONGWORD_SIZE*25(a1)
	lsr.l	#8,d6
	move.b	d6,LONGWORD_SIZE*24(a1)
	swap	d6
	move.b	d6,LONGWORD_SIZE*26(a1)
	movem.l (a0)+,d0-d3		; fetch 16x BPLAM
	move.b	d0,LONGWORD_SIZE*31(a1)
	swap	d0
	move.b	d0,LONGWORD_SIZE*29(a1)
	lsr.l	#8,d0
	move.b	d0,LONGWORD_SIZE*28(a1)
	swap	d0
	move.b	d0,LONGWORD_SIZE*30(a1)
	move.b	d1,LONGWORD_SIZE*35(a1)
	swap	d1
	move.b	d1,LONGWORD_SIZE*33(a1)
	lsr.l	#8,d1
	move.b	d1,LONGWORD_SIZE*32(a1)
	swap	d1
	move.b	d1,LONGWORD_SIZE*34(a1)
	move.b	d2,LONGWORD_SIZE*39(a1)
	swap	d2
	move.b	d2,LONGWORD_SIZE*37(a1)
	lsr.l	#8,d2
	move.b	d2,LONGWORD_SIZE*36(a1)
	swap	d2
	move.b	d2,LONGWORD_SIZE*38(a1)
	add.l	a2,a1			;next line in cl
	move.b	d3,(LONGWORD_SIZE*43)-cl2_extension1_SIZE(a1)
	swap	d3
	move.b	d3,(LONGWORD_SIZE*41)-cl2_extension1_SIZE(a1)
	lsr.l	#8,d3
	move.b	d3,(LONGWORD_SIZE*40)-cl2_extension1_SIZE(a1)
	swap	d3
	move.b	d3,(LONGWORD_SIZE*42)-cl2_extension1_SIZE(a1)
	dbf	d7,vss_copy_bplam_buffer_loop
	rts


	CNOP 0,4
image_fader_in
	movem.l a4-a6,-(a7)
	tst.w	ifi_rgb8_active(a3)
	bne.s	image_fader_in_quit
	move.w	ifi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	addq.w	#ifi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s	image_fader_in_skip
	MOVEF.W sine_table_length/2,d0
image_fader_in_skip
	move.w	d0,ifi_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table,a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ifi_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	addq.w	#ifi_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifi_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W if_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,if_rgb8_colors_counter(a3) ; fading-in finished ?
	bne.s	image_fader_in_quit
	move.w	#FALSE,ifi_rgb8_active(a3)
image_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
image_fader_out
	movem.l a4-a6,-(a7)
	tst.w	ifo_rgb8_active(a3)
	bne.s	image_fader_out_quit
	move.w	ifo_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	addq.w	#ifo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0 ; 180° ?
	ble.s	image_fader_out_skip
	MOVEF.W sine_table_length/2,d0
image_fader_out_skip
	move.w	d0,ifo_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table,a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ifo_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	addq.w	#ifo_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifo_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W if_rgb8_colors_number-1,d7
	bsr.s	if_rgb8_fader_loop
	move.w	d6,if_rgb8_colors_counter(a3) ; fading-out finished ?
	bne.s	image_fader_out_quit
	move.w	#FALSE,ifo_rgb8_active(a3)
image_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	RGB8_COLOR_FADER if


	COPY_RGB8_COLORS_TO_COPPERLIST if,pf1,cl1,cl1_COLOR00_high1,cl1_COLOR00_low1


	CNOP 0,4
image_pixel_fader_in
	tst.w	ipfi_active(a3)
	bne.s	image_pixel_fader_in_quit
	subq.w	#1,ipfi_delay_counter(a3)
	bgt.s	image_pixel_fader_in_quit
	move.w	ipfi_delay_angle(a3),d2
	move.w	d2,d0
	addq.w	#ipfi_delay_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s	image_pixel_fader_in_skip1
	MOVEF.W	sine_table_length/2,d0
image_pixel_fader_in_skip1
	move.w	d0,ipfi_delay_angle(a3)
	lea	sine_table,a0
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L	ipfi_delay_radius*2,d0,d1 ; delay'=(delay*sin(w))/2^16
	swap	d0
	addq.w	#ipfi_delay_center,d0
	move.w	d0,ipfi_delay_counter(a3)
	moveq	#ipf_source_size,d3
	moveq	#0,d4
	swap	d3			; *2^16
	move.w	ipf_destination_size(a3),d4
	cmp.w	#ipf_source_size,d4	; max ?
	ble.s	image_pixel_fader_in_skip2
	move.w	#FALSE,ipfi_active(a3)
	bra.s	image_pixel_fader_in_quit
	CNOP 0,4
image_pixel_fader_in_skip2
	moveq	#0,d1
	move.l	d3,d2		 	; low longword: source size
	moveq	#0,d7 			; high longword: source size
	moveq	#0,d5			; mask
	divu.l	d4,d7:d2		; F=source width/destination width
	move.w	d4,d7			; destination width
	subq.w	#1,d7			; loopend at false
image_pixel_fader_in_in_loop
	move.l	d1,d0			; F
	add.l	d2,d1			; increase F (p*F)
	swap	d0			; /2^16 = bitmap position
	bset	d0,d5			; set pixel in mask
	dbf	d7,image_pixel_fader_in_in_loop
	move.l	d5,ipf_mask(a3)
	addq.w	#1,d4			; increase destination width
	move.w	d4,ipf_destination_size(a3)
image_pixel_fader_in_quit
	rts


	CNOP 0,4
image_pixel_fader_out
	tst.w	ipfo_active(a3)
	bne.s	image_pixel_fader_quit
	subq.w	#1,ipfo_delay_counter(a3)
	bgt.s	image_pixel_fader_quit
	move.w	ipfo_delay_angle(a3),d2
	move.w	d2,d0
	addq.w	#ipfo_delay_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s	image_pixel_fader_skip1
	MOVEF.W sine_table_length/2,d0
image_pixel_fader_skip1
	move.w	d0,ipfo_delay_angle(a3)
	lea	sine_table,a0
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L	ipfo_delay_radius*2,d0,d1 ; delay'=(delay*sin(w))/2^16
	swap	d0
	ADDF.W	ipfo_delay_center,d0
	move.w	d0,ipfo_delay_counter(a3)
	moveq	#ipf_source_size,d3
	moveq	#0,d4
	swap	d3			; *2^16
	move.w	ipf_destination_size(a3),d4
	bgt.s	image_pixel_fader_skip2
	move.w	#FALSE,ipfo_active(a3)
	moveq	#0,d0
	move.l	d0,ipf_mask(a3)		; clear mask
	bra.s	image_pixel_fader_quit
	CNOP 0,4
image_pixel_fader_skip2
	moveq	#0,d1
	move.l	d3,d2		 	; low longword: source size
	moveq	#0,d7 			; high longword: source size
	moveq	#0,d5			; mask
	divu.l	d4,d7:d2		; F=source width/destination width
	move.w	d4,d7			; destination width
	subq.w	#1,d7			; loopend at false
image_pixel_fader_out_loop
	move.l	d1,d0			; F
	add.l	d2,d1			; increase F (p*F)
	swap	d0			; /2^16 = bitmap position
	bset	d0,d5			; set pixel in mask
	dbf	d7,image_pixel_fader_out_loop
	move.l	d5,ipf_mask(a3)
	subq.w	#1,d4			; decrease destination width
	move.w	d4,ipf_destination_size(a3)
image_pixel_fader_quit
	rts


	CNOP 0,4
ipf_random_pixel_data_copy
	movem.l a4-a5,-(a7)
	move.l	ipf_mask(a3),d1
	lea	spr_pointers_display(pc),a5
	move.l	(a5)+,a0		; Sprite0 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data,a1	; 1st quadword
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0		; Sprite1 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(lg_image_plane_width*2),a1 ; 1st quadword
	bsr	init_sprite_bitmap

	move.l	(a5)+,a0		; Sprite2 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+QUADWORD_SIZE,a1	; 2nd quadword
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0		; Sprite3 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+QUADWORD_SIZE+(lg_image_plane_width*2),a1 ; 2nd quadword
	bsr	init_sprite_bitmap

	move.l	(a5)+,a0		; Sprite4 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*2),a1 ; 3rd quadword
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0			; Sprite5 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*2)+(lg_image_plane_width*2),a1 ; 3rd quadword
	bsr.s	init_sprite_bitmap

	move.l	(a5)+,a0 ;Sprite6 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*3),a1 ; 4th quadword
	bsr.s	init_sprite_bitmap
	move.l	(a5),a0				; Sprite7 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*3)+(lg_image_plane_width*2),a1 ; 4th quadword
	bsr.s	init_sprite_bitmap
	movem.l (a7)+,a4-a5
	rts


	CNOP 0,4
init_sprite_bitmap
	move.w	#lg_image_plane_width-8,a2
	move.w	#(lg_image_plane_width*3)-8,a4
	MOVEF.W	lg_image_y_size-1,d7
init_sprite_bitmap_loop
	move.l	(a1)+,d0		; bitplane 1
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	move.l	(a1)+,d0		; bitplane 1
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	add.l	a2,a1			; skip remaining line in source
	move.l	(a1)+,d0		; bitplane 2
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	move.l	(a1)+,d0		; bitplane 2
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	add.l	a4,a1			; skip remainuíng line and 2 bitplanes in source
; Scramble mask
	move.w	VHPOSR-DMACONR(a6),d2
	ror.l	d2,d1
	move.w	VHPOSR-DMACONR(a6),d2
	rol.w	d2,d1
	dbf	d7,init_sprite_bitmap_loop
	rts


	CNOP 0,4
effects_handler
	moveq	#INTF_SOFTINT,d1
	and.w	INTREQR-DMACONR(a6),d1
	beq.s	effects_handler_quit
	move.w	eh_trigger_number(a3),d0
	cmp.w	#eh_trigger_number_max,d0
	bgt.s	effects_handler_quit
	move.w	d1,INTREQ-DMACONR(a6)
	addq.w	#1,d0
	move.w	d0,eh_trigger_number(a3)
	subq.w	#1,d0
	beq.s	eh_start_image_fader_in
	subq.w	#1,d0
	beq.s	eh_start_image_pixel_fader_in
	subq.w	#1,d0
	beq.s	eh_start_image_fader_out
	subq.w	#1,d0
	beq.s	eh_start_image_pixel_fader_out
	subq.w	#1,d0
	beq.s	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_image_fader_in
	clr.w	ifi_rgb8_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	clr.w	if_rgb8_copy_colors_active(a3)
	rts
	CNOP 0,4
eh_start_image_pixel_fader_in
	clr.w	ipfi_active(a3)
	move.w	#1,ipfi_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_image_fader_out
	clr.w	ifo_rgb8_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	clr.w	if_rgb8_copy_colors_active(a3)
	move.w	#1,ipfo_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_image_pixel_fader_out
	clr.w	ipfo_active(a3)
	rts
	CNOP 0,4
eh_stop_all
	clr.w	stop_fx_active(a3)
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_int_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	REPT pf1_colors_number
		DC.L color00_bits
	ENDR


	CNOP 0,4
spr_rgb8_color_table
	INCLUDE "RasterMaster:colortables/256x87x16-TheEnd.ct"


	CNOP 0,4
spr_pointers_display
	DS.L spr_number


; Vert-Starscrolling
	CNOP 0,2
vss_xy_coordinates
	DS.W vss_z_planes_number*vss_stars_per_plane_number*2


; Image-Fader
	CNOP 0,4
ifi_rgb8_color_table
	INCLUDE "RasterMaster:colortables/0c_vss_Colorgradient.ct"

	CNOP 0,4
ifo_rgb8_color_table
	REPT pf1_colors_number
		DC.L color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Gfx data

; Vert-Starscrolling
vss_image_data			SECTION vss_gfx,DATA
	INCBIN "RasterMaster:graphics/64x56x64-3D-Stars.rawblit"
vss_image_mask
	INCBIN "RasterMaster:graphics/64x56x64-3D-Stars-Mask.rawblit"

; Logo
lg_image_data			SECTION lg_gfx,DATA
	INCBIN "RasterMaster:graphics/256x87x16-TheEnd.rawblit"

	END
