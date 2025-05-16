; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF color00_high_bits
	XREF color00_low_bits
	XREF color255_bits
	XREF nop_second_copperlist
	XREF mouse_handler
	XREF sine_table

	XDEF start_05_greetings


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

open_border_enabled		EQU FALSE ; always FALSE because of overscan playfield

; Twisted-Bars
tb31612_quick_clear_enabled	EQU TRUE ; always TRUE because of enabled background effect
tb31612_restore_cl_cpu_enabled	EQU FALSE

dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU COPCONF_CDANG

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 512
pf1_y_size2			EQU 256+32
pf1_depth2			EQU 1
pf1_x_size3			EQU 512
pf1_y_size3			EQU 256+32
pf1_depth3			EQU 1
pf1_colors_number		EQU 0	; 256

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

pf_extra_number			EQU 1
extra_pf1_x_size		EQU 448
extra_pf1_y_size		EQU 32+32
extra_pf1_depth			EQU 1

spr_number			EQU 0
spr_x_size1			EQU 0
spr_y_size1			EQU 0
spr_x_size2			EQU 0
spr_y_size2			EQU 0
spr_depth			EQU 0
spr_colors_number		EQU 0

audio_memory_size		EQU 0

disk_memory_size		EQU 0

chip_memory_size		EQU 0

ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
ciab_ta_time			EQU 0
ciab_tb_time			EQU 0
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
ciab_ta_continuous_enabled	EQU FALSE
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $136

pixel_per_line			EQU 448
visible_pixels_number		EQU 352
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
extra_pf1_plane_width		EQU extra_pf1_x_size/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTART_OVERSCAN_64_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_16_PIXEL
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU BPLCON1F_PF1H4|BPLCON1F_PF2H4|BPLCON1F_PF1H1|BPLCON1F_PF2H1 ;Damit die Bitplane die gleiche Startposition wie CWAIT hat
bplcon2_bits			EQU 0
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon3_bits3			EQU bplcon3_bits1|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon3_bits4			EQU bplcon3_bits2|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_BPL32|FMODEF_BPAGEM

cl1_hstart			EQU $00
cl1_vstart			EQU $03	; Damit die CPU die Zeiger COP1LC in der CL für den Einsprung des Char-Blits vor dem Ausführen der CMOVE-Befehlen ändert

cl2_display_x_size		EQU 352
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU visible_lines_number
	IFEQ open_border_enabled
cl2_hstart1			EQU display_window_hstart-(5*CMOVE_SLOT_PERIOD)-4
	ELSE
cl2_hstart1			EQU display_window_hstart-(4*CMOVE_SLOT_PERIOD)-4
	ENDC
cl2_vstart1			EQU MINROW
cl2_hstart2			EQU $00
cl2_vstart2			EQU beam_position&$ff

sine_table_length		EQU 256

; Twisted-Bars3.16.1.2
tb31612_bars_number		EQU 3
tb31612_bar_height		EQU 32
tb31612_y_radius		EQU 56
tb31612_y_center		EQU (cl2_display_y_size-tb31612_bar_height)/2
tb31612_y_angle_speed		EQU 4
tb31612_y_angle_step		EQU 6
tb31612_y_distance		EQU sine_table_length/tb31612_bars_number

; Clear-Blit
tb31612_clear_blit_x_size	EQU 16
	IFEQ open_border_enabled
tb31612_clear_blit_y_size	EQU cl2_display_y_size*(cl2_display_width+6)
	ELSE
tb31612_clear_blit_y_size	EQU cl2_display_y_size*(cl2_display_width+5)
	ENDC

; Restore-Blit
tb31612_restore_blit_x_size	EQU 16
tb31612_restore_blit_width	EQU tb31612_restore_blit_x_size/8
tb31612_restore_blit_y_size	EQU cl2_display_y_size

; Wave-Center-Bar
wcb_bar_height			EQU 80
wcb_y_center			EQU (cl2_display_y_size-wcb_bar_height)/2

; Wave-Effect
we_y_radius			EQU 48
we_y_angle_speed		EQU 1
we_y_angle_step			EQU 2
we_y_radius_angle_speed		EQU 2
we_y_radius_angle_step		EQU 4

; Sine-Scrolltext
ss_image_x_size			EQU 320
ss_image_plane_width		EQU ss_image_x_size/8
ss_image_depth			EQU 1
ss_origin_char_x_size		EQU 32
ss_origin_char_y_size		EQU 32

ss_text_char_x_size		EQU 16
ss_text_char_width		EQU ss_text_char_x_size/8
ss_text_char_y_size		EQU ss_origin_char_y_size
ss_text_char_depth		EQU ss_image_depth

ss_sine_char_x_size		EQU 16
ss_sine_char_width		EQU ss_sine_char_x_size/8
ss_sine_char_y_size1		EQU extra_pf1_y_size
ss_sine_char_y_size2		EQU ss_text_char_y_size
ss_sine_char_depth		EQU pf1_depth3

ss_horiz_scroll_window_x_size	EQU visible_pixels_number+(ss_text_char_x_size*2)
ss_horiz_scroll_window_width	EQU ss_horiz_scroll_window_x_size/8
ss_horiz_scroll_window_y_size	EQU ss_text_char_y_size
ss_horiz_scroll_window_depth	EQU ss_image_depth
ss_horiz_scroll_speed		EQU 4

ss_text_char_x_restart		EQU ss_horiz_scroll_window_x_size-ss_text_char_x_size
ss_text_char_y_restart		EQU ss_text_char_y_size/2
ss_text_char_x_shift_max	EQU ss_text_char_x_size
ss_text_chars_number		EQU ss_horiz_scroll_window_x_size/ss_text_char_x_size

ss_text_x_position		EQU 32
ss_text_y_position		EQU ss_text_char_y_size/2
ss_text_y_center		EQU (visible_lines_number-ss_text_char_y_size)/2

ss_text_columns_x_size		EQU 8
ss_text_columns_per_word	EQU 16/ss_text_columns_x_size
ss_text_columns_number		EQU visible_pixels_number/ss_text_columns_x_size

ss_colorrun_height		EQU ss_text_char_y_size
ss_colorrun_y_pos		EQU (wcb_bar_height-ss_text_char_y_size)/2

ss_copy_char_blit_x_size	EQU ss_text_char_x_size
ss_copy_char_blit_y_size	EQU ss_text_char_y_size*ss_text_char_depth

ss_horiz_scroll_blit_x_size	EQU ss_horiz_scroll_window_x_size
ss_horiz_scroll_blit_y_size	EQU ss_horiz_scroll_window_y_size*ss_horiz_scroll_window_depth

ss_copy_column_blit_x_size1	EQU ss_sine_char_x_size
ss_copy_column_blit_y_size1	EQU ss_sine_char_y_size1*ss_sine_char_depth

ss_copy_column_blit_x_size2	EQU ss_sine_char_x_size
ss_copy_column_blit_y_size2	EQU ss_sine_char_y_size2*ss_sine_char_depth

; Barfield
bf_bars_planes_number		EQU 6
bf_bars_per_plane		EQU 1
bf_bar_height			EQU 40
bf_y_center			EQU (visible_lines_number+bf_bar_height)/2
bf_z_speed			EQU 8

bf_destination_bar_y_size	EQU 4
bf_source_bar_y_size		EQU 40

bf_z_planes_number		EQU (bf_source_bar_y_size-bf_destination_bar_y_size)/2
bf_z_plane1			EQU 30
bf_y_min			EQU 0
bf_y_max			EQU visible_lines_number+bf_bar_height
bf_z_min			EQU 0
bf_d				EQU 64

; Chunky-Columns-Fader-In
ccfi_mode1			EQU 0
ccfi_mode2			EQU 1
ccfi_mode3			EQU 2
ccfi_mode4			EQU 3
ccfi_delay_speed		EQU 1
ccfi_columns_delay1		EQU 2
ccfi_columns_delay2		EQU 27

; Chunky-Columns-Fader-Out
ccfo_mode1			EQU 0
ccfo_mode2			EQU 1
ccfo_mode3			EQU 2
ccfo_mode4			EQU 3
ccfo_delay_speed		EQU 1
ccfo_columns_delay		EQU 1

; Effects-Handler
eh_trigger_number_max		EQU 9


color_step1			EQU 256/(tb31612_bar_height/2)
color_step2			EQU 256/(wcb_bar_height/2)
color_step3			EQU 256/ss_colorrun_height
color_step4			EQU 256/(bf_bar_height/2)
color_values_number1		EQU tb31612_bar_height/2
color_values_number2		EQU wcb_bar_height/2
color_values_number3		EQU ss_colorrun_height
color_values_number4		EQU bf_bar_height/2
segments_number1		EQU tb31612_bars_number
segments_number2		EQU 2
segments_number3		EQU 1
segments_number4		EQU 1*2

ct_size1			EQU color_values_number1*segments_number1
ct_size2			EQU color_values_number2*segments_number2
ct_size3			EQU color_values_number3*segments_number3
ct_size4			EQU color_values_number4*segments_number4

tb31612_bplam_table_size	EQU ct_size1*2
wcb_bplam_table_size		EQU ct_size2

pf1_plane_x_offset		EQU 0
pf1_plane_y_offset		EQU ss_text_y_position


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_extension1			RS.B 0

cl1_ext1_WAIT			RS.L 1
cl1_ext1_COP1LCH		RS.L 1
cl1_ext1_COP1LCL		RS.L 1
cl1_ext1_COPJMP1		RS.L 1

cl1_extension1_size		RS.B 0


; Character
	RSRESET

cl1_extension2			RS.B 0

cl1_ext2_WAITBLIT		RS.L 1
cl1_ext2_BLTCON0		RS.L 1
cl1_ext2_BLTCON1		RS.L 1
cl1_ext2_BLTAFWM		RS.L 1
cl1_ext2_BLTALWM		RS.L 1
cl1_ext2_BLTAPTH		RS.L 1
cl1_ext2_BLTAPTL		RS.L 1
cl1_ext2_BLTDPTH		RS.L 1
cl1_ext2_BLTDPTL		RS.L 1
cl1_ext2_BLTAMOD		RS.L 1
cl1_ext2_BLTDMOD		RS.L 1
cl1_ext2_BLTSIZE		RS.L 1

cl1_extension2_size		RS.B 0


; Horiz scroll
	RSRESET

cl1_extension3			RS.B 0

cl1_ext3_WAITBLIT		RS.L 1
cl1_ext3_DMACON			RS.L 1
cl1_ext3_BLTCON0		RS.L 1
cl1_ext3_BLTCON1		RS.L 1
cl1_ext3_BLTAFWM		RS.L 1
cl1_ext3_BLTALWM		RS.L 1
cl1_ext3_BLTAPTH		RS.L 1
cl1_ext3_BLTAPTL		RS.L 1
cl1_ext3_BLTDPTH		RS.L 1
cl1_ext3_BLTDPTL		RS.L 1
cl1_ext3_BLTAMOD		RS.L 1
cl1_ext3_BLTDMOD		RS.L 1
cl1_ext3_BLTSIZE		RS.L 1

cl1_extension3_size		RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_extension1_entry		RS.B cl1_extension1_size
cl1_extension2_entry		RS.B cl1_extension2_size
cl1_extension3_entry		RS.B cl1_extension3_size

cl1_ext3_COPJMP2		RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAITBLIT		RS.L 1
cl2_ext1_BLTBMOD		RS.L 1
cl2_ext1_BLTAMOD		RS.L 1
cl2_ext1_BLTDMOD		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_BLTCON0		RS.L 1
cl2_ext2_BLTALWM		RS.L 1
cl2_ext2_BLTAPTH		RS.L 1
cl2_ext2_BLTAPTL		RS.L 1
cl2_ext2_BLTDPTH		RS.L 1
cl2_ext2_BLTDPTL		RS.L 1
cl2_ext2_BLTSIZE		RS.L 1
cl2_ext2_WAITBLIT		RS.L 1

cl2_extension2_size		RS.B 0


	RSRESET

cl2_extension3			RS.B 0

cl2_ext3_BLTCON0		RS.L 1

cl2_extension3_size		RS.B 0


	RSRESET

cl2_extension4			RS.B 0

cl2_ext4_BLTALWM		RS.L 1
cl2_ext4_BLTBPTH		RS.L 1
cl2_ext4_BLTBPTL		RS.L 1
cl2_ext4_BLTAPTH		RS.L 1
cl2_ext4_BLTAPTL		RS.L 1
cl2_ext4_BLTDPTH		RS.L 1
cl2_ext4_BLTDPTL		RS.L 1
cl2_ext4_BLTSIZE		RS.L 1
cl2_ext4_WAITBLIT		RS.L 1

cl2_extension4_size		RS.B 0


	RSRESET

cl2_extension5			RS.B 0

cl2_ext5_COP1LCH		RS.L 1
cl2_ext5_COP1LCL		RS.L 1

cl2_extension5_size		RS.B 0


	RSRESET

cl2_extension6			RS.B 0

cl2_ext6_DMACON			RS.L 1
cl2_ext6_BLTCON0		RS.L 1
cl2_ext6_BLTALWM		RS.L 1
cl2_ext6_BLTDPTH		RS.L 1
cl2_ext6_BLTDPTL		RS.L 1
cl2_ext6_BLTDMOD		RS.L 1
cl2_ext6_BLTADAT		RS.L 1
cl2_ext6_BLTSIZV		RS.L 1
cl2_ext6_BLTSIZH		RS.L 1

cl2_extension6_size		RS.B 0


	RSRESET

cl2_extension7			RS.B 0

cl2_ext7_WAIT			RS.L 1
	IFEQ tb31612_quick_clear_enabled
cl2_ext7_BPLCON3_1		RS.L 1
cl2_ext7_COLOR31_high RS.L 1
cl2_ext7_BPLCON3_2		RS.L 1
cl2_ext7_COLOR31_low		RS.L 1
	ELSE
cl2_ext7_BPLCON3_1		RS.L 1
cl2_ext7_COLOR00_high RS.L 1
cl2_ext7_BPLCON3_2		RS.L 1
cl2_ext7_COLOR00_low		RS.L 1
	ENDC
	IFEQ open_border_enabled 
cl2_ext7_BPL1DAT		RS.L 1
	ENDC
cl2_ext7_BPLCON4_1		RS.L 1
cl2_ext7_BPLCON4_2		RS.L 1
cl2_ext7_BPLCON4_3		RS.L 1
cl2_ext7_BPLCON4_4		RS.L 1
cl2_ext7_BPLCON4_5		RS.L 1
cl2_ext7_BPLCON4_6		RS.L 1
cl2_ext7_BPLCON4_7		RS.L 1
cl2_ext7_BPLCON4_8		RS.L 1
cl2_ext7_BPLCON4_9		RS.L 1
cl2_ext7_BPLCON4_10		RS.L 1
cl2_ext7_BPLCON4_11		RS.L 1
cl2_ext7_BPLCON4_12		RS.L 1
cl2_ext7_BPLCON4_13		RS.L 1
cl2_ext7_BPLCON4_14		RS.L 1
cl2_ext7_BPLCON4_15		RS.L 1
cl2_ext7_BPLCON4_16		RS.L 1
cl2_ext7_BPLCON4_17		RS.L 1
cl2_ext7_BPLCON4_18		RS.L 1
cl2_ext7_BPLCON4_19		RS.L 1
cl2_ext7_BPLCON4_20		RS.L 1
cl2_ext7_BPLCON4_21		RS.L 1
cl2_ext7_BPLCON4_22		RS.L 1
cl2_ext7_BPLCON4_23		RS.L 1
cl2_ext7_BPLCON4_24		RS.L 1
cl2_ext7_BPLCON4_25		RS.L 1
cl2_ext7_BPLCON4_26		RS.L 1
cl2_ext7_BPLCON4_27		RS.L 1
cl2_ext7_BPLCON4_28		RS.L 1
cl2_ext7_BPLCON4_29		RS.L 1
cl2_ext7_BPLCON4_30		RS.L 1
cl2_ext7_BPLCON4_31		RS.L 1
cl2_ext7_BPLCON4_32		RS.L 1
cl2_ext7_BPLCON4_33		RS.L 1
cl2_ext7_BPLCON4_34		RS.L 1
cl2_ext7_BPLCON4_35		RS.L 1
cl2_ext7_BPLCON4_36		RS.L 1
cl2_ext7_BPLCON4_37		RS.L 1
cl2_ext7_BPLCON4_38		RS.L 1
cl2_ext7_BPLCON4_39		RS.L 1
cl2_ext7_BPLCON4_40		RS.L 1
cl2_ext7_BPLCON4_41		RS.L 1
cl2_ext7_BPLCON4_42		RS.L 1
cl2_ext7_BPLCON4_43		RS.L 1
cl2_ext7_BPLCON4_44		RS.L 1

cl2_extension7_size		RS.B 0

	IFNE tb31612_quick_clear_enabled
		IFNE tb31612_restore_cl_cpu_enabled
			RSRESET

cl2_extension8			RS.B 0

cl2_ext8_WAITBLIT		RS.L 1
cl2_ext8_BLTDPTH		RS.L 1
cl2_ext8_BLTDPTL		RS.L 1
cl2_ext8_BLTDMOD		RS.L 1
cl2_ext8_BLTADAT		RS.L 1
cl2_ext8_BLTSIZE		RS.L 1

cl2_extension8_size		RS.B 0
		ENDC
	ENDC

	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size
cl2_extension2_entry		RS.B cl2_extension2_size*(visible_pixels_number/WORD_BITS)
cl2_extension3_entry		RS.B cl2_extension3_size*(visible_pixels_number/WORD_BITS)
cl2_extension4_entry		RS.B cl2_extension4_size*(ss_text_columns_number-(visible_pixels_number/WORD_BITS))
cl2_extension5_entry		RS.B cl2_extension5_size
cl2_extension6_entry		RS.B cl2_extension6_size
cl2_extension7_entry		RS.B cl2_extension7_size*cl2_display_y_size
	IFNE tb31612_quick_clear_enabled
		IFNE tb31612_restore_cl_cpu_enabled
cl2_extension8_entry		RS.B cl2_extension8_size
		ENDC
	ENDC

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
spr0_y_size2			EQU 0
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU 0
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU 0
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU 0
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU 0
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU 0
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU 0
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU 0


	RSRESET

em_bplam_table1			RS.B tb31612_bplam_table_size
em_bplam_table2			RS.B wcb_bplam_table_size
	RS_ALIGN_LONGWORD
em_color_table1			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table2			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table3			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table4			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table5			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_table6			RS.L bf_source_bar_y_size*2*(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)
em_color_buffer			RS.L cl2_display_y_size+(bf_bar_height*2)
extra_memory_size		RS.B 0


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; Sine-Scrolltext
ss_image			RS.L 1
ss_enabled RS.W 1
ss_text_table_start		RS.W 1
ss_text_char_x_shift		RS.W 1
ss_char_toggle_image		RS.W 1

; Twisted-Bars3.16.1.2
tb31612_y_angle			RS.W 1

; Wave-Effect
we_radius_y_angle		RS.W 1
we_y_angle			RS.W 1

; Barfield
bf_active			RS.W 1
bf_z_restart_active		RS.W 1

; Chunky-Columns-Fader
	RS_ALIGN_LONGWORD
ccf_fader_columns_mask		RS.L 1

ccfi_active			RS.W 1
ccfi_current_mode		RS.W 1
ccfi_start			RS.W 1
ccfi_columns_delay_counter	RS.W 1
ccfi_columns_delay_reset	RS.W 1

ccfo_active			RS.W 1
ccfo_current_mode		RS.W 1
ccfo_start			RS.W 1
ccfo_columns_delay_counter	RS.W 1
ccfo_columns_delay_reset	RS.W 1

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_05_greetings


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Sine-Scrolltext
	lea	ss_image_data,a0
	move.l	a0,ss_image(a3)
	moveq	#FALSE,d1
	move.w	d1,ss_enabled(a3)
	moveq	#0,d0
	move.w	d0,ss_text_table_start(a3)
	move.w	d0,ss_text_char_x_shift(a3)
	move.w	d0,ss_char_toggle_image(a3)

; Twisted-Bars3.16.1.2
	move.w	d0,tb31612_y_angle(a3) ; 0°

; Wave-Effect
	move.w	d0,we_radius_y_angle(a3) ; 0 °
	move.w	d0,we_y_angle(a3) ; 0°

; Barfield
	move.w	d1,bf_active(a3)
	move.w	d0,bf_z_restart_active(a3)

; Chunky-Columns-Fader
	lea	wcb_fader_columns_mask(pc),a0
	move.l	a0,ccf_fader_columns_mask(a3)

; Chunky-Columns-Fader-In
	move.w	d1,ccfi_active(a3)
	moveq	#ccfi_mode2,d2
	move.w	d2,ccfi_current_mode(a3)
	move.w	d0,ccfi_start(a3)
	move.w	d0,ccfi_columns_delay_counter(a3)
	moveq	#ccfi_columns_delay1,d2
	move.w	d2,ccfi_columns_delay_reset(a3)

; Chunky-Columns-Fader-Out
	move.w	d1,ccfo_active(a3)
	moveq	#ccfo_mode2,d2
	move.w	d2,ccfo_current_mode(a3)
	move.w	d0,ccfo_start(a3)
	move.w	d0,ccfo_columns_delay_counter(a3)
	moveq	#ccfo_columns_delay,d2
	move.w	d2,ccfo_columns_delay_reset(a3)

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	tb31612_init_color_table
	bsr	wcb_init_color_table
	bsr	ss_init_color_table
	bsr	init_colors
	bsr	tb31612_init_mirror_bplam_table
	bsr	tb31612_get_yz_coords
	bsr	wcb_init_bplam_table
	bsr	ss_init_chars_offsets
	bsr	bf_init_color_table
	bsr	bf_init_color_table_ptrs
	bsr	bf_scale_bar_size
	bsr	init_first_copperlist
	bra	init_second_copperlist


; Twisted-Bars
	CNOP 0,4
tb31612_init_color_table
	lea	tb31612_bars_color_table(pc),a0
	lea	pf1_rgb8_color_table(pc),a1
	MOVEF.W (color_values_number1*segments_number1)-1,d7
tb31612_init_color_table_loop
	move.l	(a0)+,d0		; RGB8
	move.l	d0,(a1)+		; COLOR00
	move.l	d0,(a1)+		; COLOR01
	dbf	d7,tb31612_init_color_table_loop
	rts


; Wave-Center-Bar
	CNOP 0,4
wcb_init_color_table
	lea	wcb_bar_color_table(pc),a0
	lea	pf1_rgb8_color_table+(color_values_number1*segments_number1*QUADWORD_SIZE)(pc),a1
	MOVEF.W (color_values_number2*segments_number2)-1,d7
wcb_init_color_table_loop
	move.l	(a0)+,(a1)		; COLOR00
	addq.w	#8,a1
	dbf	d7,wcb_init_color_table_loop
	rts


; Sine-Scrolltext
	CNOP 0,4
ss_init_color_table
	lea	ss_color_table(pc),a0
	lea	pf1_rgb8_color_table+((1+(((color_values_number1*segments_number1)+ss_colorrun_y_pos)*2))*LONGWORD_SIZE)(pc),a1
	MOVEF.W (color_values_number3*segments_number3)-1,d7
ss_init_color_table_loop
	move.l	(a0)+,(a1)		; COLOR01
	addq.w	#8,a1
	dbf	d7,ss_init_color_table_loop
	rts


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
	CPU_SELECT_COLOR_HIGH_BANK 1
	CPU_INIT_COLOR_HIGH COLOR00,32
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
	CPU_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
	CPU_SELECT_COLOR_LOW_BANK 1
	CPU_INIT_COLOR_LOW COLOR00,32
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


; Twisted-Bars3.16.1.2
	INIT_MIRROR_bplam_table.B tb31612,0,2,segments_number1,color_values_number1,extra_memory,a3


; Wave-Center-Bar/Sine-Scrolltext
	INIT_bplam_table.B wcb,color_values_number1*segments_number1*2,2,color_values_number2*2,extra_memory,a3,em_bplam_table2


; Sine-Scrolltext
	INIT_CHARS_OFFSETS.W ss


; Barfield
	CNOP 0,4
bf_init_color_table
	lea	bf_color_table(pc),a0
	move.l	extra_memory(a3),a2
	lea	em_color_table1(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop1
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop1

	lea	em_color_table2(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop2
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop2

	lea	em_color_table3(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop3
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop3

	lea	em_color_table4(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop4
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop4

	lea	em_color_table5(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop5
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop5

	lea	em_color_table6(a2),a1
	MOVEF.W (color_values_number4*segments_number4)-1,d7
bf_init_color_table_loop6
	move.l	(a0)+,(a1)		; COLOR01
	add.l	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,a1
	dbf	d7,bf_init_color_table_loop6
	rts


	CNOP 0,4
bf_init_color_table_ptrs
	move.l	extra_memory(a3),a0
	lea	bf_color_table_ptrs(pc),a1
	lea	em_color_table1(a0),a2
	move.l	a2,(a1)+
	lea	em_color_table2(a0),a2
	move.l	a2,(a1)+
	lea	em_color_table3(a0),a2
	move.l	a2,(a1)+
	lea	em_color_table4(a0),a2
	move.l	a2,(a1)+
	lea	(em_color_table5,a0),a2
	move.l	a2,(a1)+
	lea	(em_color_table6,a0),a2
	move.l	a2,(a1)
	rts


	CNOP 0,4
bf_scale_bar_size
	movem.l a4-a6,-(a7)
	move.w	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*4,a5
	lea	bf_color_table_ptrs(pc),a6
	moveq	#bf_bars_planes_number-1,d7 ; 1st loop counter
bf_scale_bar_size_loop1
	move.l	(a6),a4
	addq.w	#LONGWORD_SIZE,a4	; destination: color table
	MOVEF.L bf_source_bar_y_size-2,d5
	swap	d7 			; high word: 1st loop counter
	move.w	#((bf_source_bar_y_size-bf_destination_bar_y_size)/2)-1,d7 ; low word: 2nd loop counter
bf_scale_bar_size_loop2
	bsr.s	bf_refresh_bitmap_table
	bsr.s	bf_init_bitmap_lines_table
	move.l	a4,a2			; destination: color table
	MOVEF.L bf_bar_height,d0
	sub.w	d5,d0			; bar height-current bar height
	mulu.w	#(((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*2,d0 ; y centering
	move.l	(a6),a1			; source: color table
	add.l	d0,a2			; add y offset in color table
	bsr.s	bf_do_scale_bar_y_size
	subq.w	#2,d5			; decrease bar height
	addq.w	#LONGWORD_SIZE,a4	; skip 1line in color table
	dbf	d7,bf_scale_bar_size_loop2
	addq.w	#LONGWORD_SIZE,a6	; next color table
	swap	d7		 	; low word: 1st loop counter
	dbf	d7,bf_scale_bar_size_loop1
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
bf_refresh_bitmap_table
	moveq	#0,d0
	lea	bf_bitmap_lines_table(pc),a0
	move.w	#(bf_source_bar_y_size/LONGWORD_SIZE)-1,d6
bf_refresh_bitmap_table_loop
	move.l	d0,(a0)+
	dbf	d6,bf_refresh_bitmap_table_loop
	rts


	CNOP 0,4
bf_init_bitmap_lines_table
	lea	bf_bitmap_lines_table(pc),a0
	MOVEF.L bf_source_bar_y_size,d3
	moveq	#0,d4
	swap	d3			; *2^16
	move.w	d5,d4			; destination height in pixel
	move.l	d3,d2		 	; low longword: source height
	moveq	#0,d6 			; high longword: source height
	divu.l	d4,d6:d2		; F=source height/destination height
	moveq	#0,d1
	move.w	d4,d6			; destination height
	subq.w	#1,d6			; loop until false
bf_init_bitmap_lines_table_loop
	move.l	d1,d0			; F
	swap	d0			; /2^16 = bitmap position
	add.l	d2,d1			; increase F (p*F)
	addq.b	#1,(a0,d0.w)		; set pixel in table
	dbf	d6,bf_init_bitmap_lines_table_loop
	rts


	CNOP 0,4
bf_do_scale_bar_y_size
	lea	bf_bitmap_lines_table(pc),a0
	MOVEF.W bf_source_bar_y_size-1,d6
bf_do_scale_bar_y_size_loop
	tst.b	(a0)+			; check y zoom factor
	beq.s	bf_do_scale_bar_y_size_skip
	move.l	(a1),(a2)		; copy color
	add.l	a5,a2			; next line in color table
bf_do_scale_bar_y_size_skip
	add.l	a5,a1			; next color
	dbf	d6,bf_do_scale_bar_y_size_loop
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0 
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_plane_ptrs
	bsr	cl1_init_copperlist_branch
	bsr	cl1_init_copy_blit
	bsr	cl1_init_horiz_scroll_blit
	COP_MOVEQ 0,COPJMP2
	bra	cl1_set_plane_ptrs


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_BITPLANE_POINTERS cl1


	CNOP 0,4
cl1_init_copperlist_branch
	COP_WAIT cl1_HSTART,cl1_VSTART
	move.l	cl1_display(a3),d0 
	add.l	#cl1_extension3_entry,d0 ; skip character blit
	swap	d0
	COP_MOVE d0,COP1LCH
	swap	d0		
	COP_MOVE d0,COP1LCL
	COP_MOVEQ 0,COPJMP1
	rts


	CNOP 0,4
cl1_init_copy_blit
	COP_WAITBLIT
	COP_MOVEQ BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D=A
	COP_MOVEQ 0,BLTCON1
	COP_MOVEQ -1,BLTAFWM
	COP_MOVEQ -1,BLTALWM
	COP_MOVEQ 0,BLTAPTH
	COP_MOVEQ 0,BLTAPTL
	move.l	extra_pf1(a3),a1
	move.l	#(ss_text_char_x_restart/8)+(ss_text_char_y_restart*extra_pf1_plane_width*extra_pf1_depth),d0
	add.l	(a1),d0
	swap	d0
	COP_MOVE d0,BLTDPTH
	swap	d0		
	COP_MOVE d0,BLTDPTL
	COP_MOVEQ ss_image_plane_width-ss_text_char_width,BLTAMOD
	COP_MOVEQ extra_pf1_plane_width-ss_text_char_width,BLTDMOD
	COP_MOVEQ (ss_copy_char_blit_y_size*64)+(ss_copy_char_blit_x_size/WORD_BITS),BLTSIZE
	rts


	CNOP 0,4
cl1_init_horiz_scroll_blit
	COP_WAITBLIT
	COP_MOVEQ DMAF_BLITHOG|DMAF_SETCLR,DMACON
	COP_MOVEQ ((-ss_horiz_scroll_speed<<12)|BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC),BLTCON0 ; minterm D=A
	COP_MOVEQ 0,BLTCON1
	move.l	extra_pf1(a3),a1
	move.l	(a1),d0			; source
	add.l	#ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth,d0
	move.l	d0,d1			; 1st line
	COP_MOVEQ -1,BLTAFWM
	addq.l	#WORD_SIZE,d0		; 1st line, skip 16 pixel
	COP_MOVEQ -1,BLTALWM
	swap	d0
	COP_MOVE d0,BLTAPTH
	swap	d0		
	COP_MOVE d0,BLTAPTL
	swap	d1			; High
	COP_MOVE d1,BLTDPTH
	swap	d1		
	COP_MOVE d1,BLTDPTL
	COP_MOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTAMOD
	COP_MOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTDMOD
	COP_MOVEQ (ss_horiz_scroll_blit_y_size*64)+(ss_horiz_scroll_blit_x_size/WORD_BITS),BLTSIZE
	rts


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction1(a3),a0 
	bsr.s	cl2_init_sine_scroll_blits_const
	bsr	cl2_init_sine_scroll_blits
	bsr	cl2_init_copperlist_branch
	bsr	cl2_init_clear_blit
	bsr	cl2_init_bplcon4
	IFNE tb31612_restore_cl_cpu_enabled
		IFNE tb31612_quick_clear_enabled
			bsr	cl2_init_restore_blit
		ENDC
	ENDC
	bsr	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_playfield1
	bsr	set_playfield1
	clr.w	ss_enabled(a3)
	bsr	ss_horiz_scrolltext
	move.w	#FALSE,ss_enabled(a3)
	bsr	tb31612_clear_second_copperlist
	bsr	bf_clear_buffer
	IFNE tb31612_quick_clear_enabled
		IFNE tb31612_restore_cl_cpu_enabled
			bsr	tb31612_restore_second_copperlist
		ENDC
	ENDC
	bsr	ss_sine_scroll
	bsr	swap_second_copperlist
	bsr	swap_playfield1
	bsr	set_playfield1
	bsr	tb31612_clear_second_copperlist
	IFNE tb31612_quick_clear_enabled
		IFNE tb31612_restore_cl_cpu_enabled
			bsr	tb31612_restore_second_copperlist
		ENDC
	ENDC
	bsr	ss_sine_scroll
	bsr	swap_second_copperlist
	bsr	swap_playfield1
	bsr	set_playfield1
	bsr	tb31612_clear_second_copperlist
	IFNE tb31612_restore_cl_cpu_enabled
		IFNE tb31612_quick_clear_enabled
			bsr	tb31612_restore_second_copperlist
		ENDC
	ENDC
	bra	ss_sine_scroll


	CNOP 0,4
cl2_init_sine_scroll_blits_const
	COP_WAITBLIT
	COP_MOVEQ pf1_plane_width-ss_text_char_width,BLTBMOD
	COP_MOVEQ extra_pf1_plane_width-ss_text_char_width,BLTAMOD
	COP_MOVEQ pf1_plane_width-ss_text_char_width,BLTDMOD
	rts


	CNOP 0,4
cl2_init_sine_scroll_blits
	move.l	extra_pf1(a3),a1
	move.l	(a1),d2			; source1
	add.l	#visible_pixels_number/8,d2 ; end of line
	move.l	d2,d3
	add.l	#ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth,d3 ; source2
	moveq	#(visible_pixels_number/WORD_BITS)-1,d7
cl2_init_sine_scroll_blits_loop1
	COP_MOVEQ BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D=A
	MOVEF.W $ff>>(8-ss_text_columns_x_size),d1 ; mask
	COP_MOVE d1,BLTALWM
	swap	d2
	COP_MOVE d2,BLTAPTH		; scrolltext
	swap	d2
	COP_MOVE d2,BLTAPTL
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ (ss_copy_column_blit_y_size1*64)+(ss_copy_column_blit_x_size1/WORD_BITS),BLTSIZE
	COP_WAITBLIT
	COP_MOVEQ BC0F_SRCA|BC0F_SRCB|BC0F_DEST|NABNC|NABC|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D=A+B
	subq.l	#ss_sine_char_width,d2 ; next character in source1
	moveq	#(ss_text_columns_per_word-1)-1,d6
cl2_init_sine_scroll_blits_loop2
	IFEQ ss_text_columns_x_size-1
		MULUF.W 2,d1		; shift mask 1 bit left
	ELSE
		IFEQ ss_text_columns_x_size-2
			MULUF.W 4,d1	; shift mask 2 bits left
		ELSE
			lsl.w	#ss_text_columns_x_size,d1 ; shift mask n bits left
		ENDC
	ENDC
	COP_MOVE d1,BLTALWM
	swap	d3
	COP_MOVEQ 0,BLTBPTH
	COP_MOVEQ 0,BLTBPTL
	COP_MOVE d3,BLTAPTH		; scrolltext
	swap	d3
	COP_MOVE d3,BLTAPTL
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ (ss_copy_column_blit_y_size2*64)+(ss_copy_column_blit_x_size2/WORD_BITS),BLTSIZE
	COP_WAITBLIT
	dbf	d6,cl2_init_sine_scroll_blits_loop2
	subq.l	#ss_sine_char_width,d3 ; next character in source2
	dbf	d7,cl2_init_sine_scroll_blits_loop1
	rts


	CNOP 0,4
cl2_init_copperlist_branch
	COP_MOVE cl1_display(a3),COP1LCH
	COP_MOVE cl1_display+WORD_SIZE(a3),COP1LCL
	rts


	CNOP 0,4
cl2_init_clear_blit
	COP_MOVEQ DMAF_BLITHOG,DMACON
	COP_MOVEQ BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D=A
	COP_MOVEQ -1,BLTALWM
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ 2,BLTDMOD
	IFEQ tb31612_quick_clear_enabled
		COP_MOVEQ -2,BLTADAT	; source: BPLCON4
	ELSE
		COP_MOVEQ bplcon4_bits,BLTADAT ; source: BPLCON4
	ENDC
	COP_MOVEQ tb31612_clear_blit_y_size,BLTSIZV
	COP_MOVEQ tb31612_clear_blit_x_size/WORD_BITS,BLTSIZH
	rts


	COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,tb31612_quick_clear_enabled,TRUE


	IFNE tb31612_restore_cl_cpu_enabled
		IFNE tb31612_quick_clear_enabled
			CNOP 0,4
cl2_init_restore_blit
			COP_WAITBLIT
			COP_MOVEQ 0,BLTDPTH
			COP_MOVEQ 0,BLTDPTL
			COP_MOVEQ cl2_extension7_size-tb31612_restore_blit_width,BLTDMOD
			COP_MOVEQ -2,BLTADAT ; source: 2nd word of CWAIT
			COP_MOVEQ (tb31612_restore_blit_y_size*64)+(tb31612_restore_blit_x_size/WORD_BITS),BLTSIZE
			rts
		ENDC
	ENDC


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
	bsr	swap_playfield1
	bsr	set_playfield1
	bsr	effects_handler
	bsr	ss_horiz_scrolltext
	bsr	tb31612_clear_second_copperlist
	bsr	ss_sine_scroll
	bsr	chunky_columns_fader_in
	bsr	chunky_columns_fader_out
	bsr	tb31612_set_background_bars
	bsr	set_wave_center_bar
	bsr	tb31612_set_foreground_bars
	tst.w	bf_active(a3)
	bne.s	beam_routines_skip
	bsr	bf_clear_buffer
	bsr	bf_set_bars
beam_routines_skip
	bsr	bf_copy_buffer
	bsr	tb31612_get_yz_coords
	bsr	we_get_y_coords
	IFNE tb31612_quick_clear_enabled
		bsr	restore_second_copperlist
	ENDC
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s   beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.l	nop_second_copperlist,COP2LC-DMACONR(a6)
	move.w	d0,COPJMP2-DMACONR(a6)
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,3


	SWAP_PLAYFIELD pf1,2


	SET_PLAYFIELD pf1,pf1_depth3,pf1_plane_x_offset,pf1_plane_y_offset


	CNOP 0,4
ss_horiz_scrolltext
	tst.w	ss_enabled(a3)
	bne.s	ss_horiz_scrolltext_quit
	move.w	ss_text_char_x_shift(a3),d2
	MOVEF.L cl1_extension3_entry,d3	; jump in vertical scroll blit
	move.l	cl1_display(a3),a2 
	addq.w	#ss_horiz_scroll_speed,d2
	cmp.w	#ss_text_char_x_shift_max,d2
	blt.s	ss_horiz_scrolltext_skip
	bsr.s	ss_get_new_char_image
	move.w	d0,cl1_extension2_entry+cl1_ext2_BLTAPTL+WORD_SIZE(a2) ; character image
	swap	d0
	moveq	#0,d2			; reset x shift
	move.w	d0,cl1_extension2_entry+cl1_ext2_BLTAPTH+WORD_SIZE(a2)
	MOVEF.L cl1_extension2_entry,d3	; jump in character blit
ss_horiz_scrolltext_skip
	move.w	d2,ss_text_char_x_shift(a3) 
	add.l	a2,d3
	move.w	d3,cl1_extension1_entry+cl1_ext1_COP1LCL+WORD_SIZE(a2)
	swap	d3
	move.w	d3,cl1_extension1_entry+cl1_ext1_COP1LCH+WORD_SIZE(a2)
ss_horiz_scrolltext_quit
	rts


	GET_NEW_char_IMAGE.W ss


tb31612_clear_second_copperlist
	move.l	cl2_construction1(a3),a0
	ADDF.W	cl2_extension6_entry+WORD_SIZE,a0
	move.l	cl2_construction2(a3),d0
	add.l	#cl2_extension7_entry+cl2_ext7_WAIT+WORD_SIZE,d0
	move.w	d0,cl2_ext6_BLTDPTL(a0)
	swap	d0
	move.w	d0,cl2_ext6_BLTDPTH(a0)
	rts


	CNOP 0,4
ss_sine_scroll
	move.l	a4,-(a7)
	MOVEF.W ss_text_y_center,d2
	MOVEF.L cl2_extension2_size+cl2_extension3_size,d3
	MOVEF.L cl2_extension4_size,d4
	lea	we_y_coords(pc),a0
	move.l	pf1_construction2(a3),a1
	move.l	(a1),a1			; destination1
	add.l	#((visible_pixels_number+ss_text_x_position)-ss_text_char_x_size)/8,a1 ; end of line in destination1
	lea	ss_text_y_position*pf1_plane_width*pf1_depth3(a1),a2 ; destination2
	move.l	cl2_construction2(a3),a4
	ADDF.W	cl2_extension2_entry+WORD_SIZE,a4
	moveq	#(visible_pixels_number/WORD_BITS)-1,d7
ss_sine_scroll_loop1
	moveq	#0,d0
	move.w	(a0)+,d0		; y
	add.w	d2,d0			; add y center
	MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ; y offset in destination1
	add.l	a1,d0			; add destination1 address
	subq.w	#ss_sine_char_width,a1	; next character in destination1
	move.w	d0,cl2_ext2_BLTDPTL(a4) ; playfield write
	swap	d0
	add.l	d3,a4			; next blitter operation in cl
	move.w	d0,cl2_ext2_BLTDPTH-(cl2_extension2_size+cl2_extension3_size)(a4) ; playfield write
; !	moveq	#(tb31612_columns_per_word-1)-1,d6
; !ss_sine_scroll_loop2
	moveq	#0,d0
	move.w	(a0)+,d0		; y
	add.w	d2,d0			; add y center
	MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ; y offset in destination2
	add.l	a2,d0			; add destination2 address
	move.w	d0,cl2_ext4_BLTBPTL(a4) ; playfield read
	subq.w	#ss_sine_char_width,a2	; next chatacter in destination2
	move.w	d0,cl2_ext4_BLTDPTL(a4) ; playfield write
	swap	d0
	move.w	d0,cl2_ext4_BLTBPTH(a4) ; playfield read
	add.l	d4,a4			; next blitter operation in cl
	move.w	d0,cl2_ext4_BLTDPTH-cl2_extension4_size(a4) ; playfield write
; !	dbf	d6,ss_sine_scroll_loop2
	dbf	d7,ss_sine_scroll_loop1
	move.l	(a7)+,a4
	rts


	CNOP 0,4
tb31612_set_background_bars
	movem.l	a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	moveq	#tb31612_bar_height,d4
	lea	tb31612_yz_coords(pc),a0
	move.l	cl2_construction2(a3),a2
	ADDF.W	cl2_extension7_entry+cl2_ext7_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5	; BPLAM table
	lea	tb31612_fader_columns_mask(pc),a6
	lea	we_y_coords_end(pc),a7
	moveq	#cl2_display_width-1,d7	; number of columns
tb31612_set_background_bars_loop1
	tst.b   (a6)+			; display column ?
	beq.s	tb31612_set_background_bars_skip1
	ADDF.W  tb31612_bars_number*LONGWORD_SIZE,a0 ; skip z vector and y
	subq.w	#WORD_SIZE,a7		; skip 2nd y
	bra	tb31612_set_background_bars_skip4
	CNOP 0,4
tb31612_set_background_bars_skip1
	move.w	-(a7),d0		; 2nd y
	MULUF.W	cl2_extension7_size/4,d0,d1 ; 2nd y offset in cl
	move.l	a5,a1			; BPLAM table
	lea	(a2,d0.w*4),a3		; add 2nd y offset
	moveq	#tb31612_bars_number-1,d6
tb31612_set_background_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bpl.s	tb31612_set_background_bars_skip2
	add.l   d4,a1			; skip BPLAM values
	bra	tb31612_set_background_bars_skip3
	CNOP 0,4
tb31612_set_background_bars_skip2
	lea	(a3,d0.w*4),a4		; 1st y offset
	COPY_TWISTED_BAR.B tb31612,cl2,extension7,bar_height
tb31612_set_background_bars_skip3
	dbf	d6,tb31612_set_background_bars_loop2
tb31612_set_background_bars_skip4
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	dbf	d7,tb31612_set_background_bars_loop1
	move.l	variables+save_a7(pc),a7
	movem.l	(a7)+,a3-a6
	rts


	CNOP 0,4
set_wave_center_bar
	movem.l a4-a6,-(a7)
	moveq	#wcb_y_center,d4
	MOVEF.L cl2_extension7_size*40,d5
	lea	we_y_coords_end(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension7_entry+cl2_ext7_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5
	add.l	#em_bplam_table2,a5	; BPLAM table
	lea	wcb_fader_columns_mask(pc),a6
	moveq	#cl2_display_width-1,d7	; number of columns
set_center_bar_loop1
	move.w	-(a0),d0		; y
	tst.b	(a6)+			; display column ?
	bne	set_center_bar_skip
	add.w	d4,d0			; add y center
	MULUF.W cl2_extension7_size/4,d0,d1 ; y offset in cl
	move.l	a5,a1			; BPLAM table
	lea	(a2,d0.w*4),a4		; add y offset in cl
	MOVEF.W (wcb_bar_height/40)-1,d6
set_center_bar_loop2
	movem.l (a1)+,d0-d3		; fetch 16x BPLAM values
	move.b	d0,cl2_extension7_size*3(a4) ; BPLCON4 high
	swap	d0
	move.b	d0,cl2_extension7_size*1(a4)
	lsr.l	#8,d0
	move.b	d0,(a4)
	swap	d0
	move.b	d0,cl2_extension7_size*2(a4)
	move.b	d1,cl2_extension7_size*7(a4)
	swap	d1
	move.b	d1,cl2_extension7_size*5(a4)
	lsr.l	#8,d1
	move.b	d1,cl2_extension7_size*4(a4)
	swap	d1
	move.b	d1,cl2_extension7_size*6(a4)
	move.b	d2,cl2_extension7_size*11(a4)
	swap	d2
	move.b	d2,cl2_extension7_size*9(a4)
	lsr.l	#8,d2
	move.b	d2,cl2_extension7_size*8(a4)
	swap	d2
	move.b	d2,cl2_extension7_size*10(a4)
	move.b	d3,cl2_extension7_size*15(a4)
	swap	d3
	move.b	d3,cl2_extension7_size*13(a4)
	lsr.l	#8,d3
	move.b	d3,cl2_extension7_size*12(a4)
	swap	d3
	move.b	d3,cl2_extension7_size*14(a4)
	movem.l (a1)+,d0-d3		; fetch 16x BPLAM values
	move.b	d0,cl2_extension7_size*19(a4)
	swap	d0
	move.b	d0,cl2_extension7_size*17(a4)
	lsr.l	#8,d0
	move.b	d0,cl2_extension7_size*16(a4)
	swap	d0
	move.b	d0,cl2_extension7_size*18(a4)
	move.b	d1,cl2_extension7_size*23(a4)
	swap	d1
	move.b	d1,cl2_extension7_size*21(a4)
	lsr.l	#8,d1
	move.b	d1,cl2_extension7_size*20(a4)
	swap	d1
	move.b	d1,cl2_extension7_size*22(a4)
	move.b	d2,cl2_extension7_size*27(a4)
	swap	d2
	move.b	d2,cl2_extension7_size*25(a4)
	lsr.l	#8,d2
	move.b	d2,cl2_extension7_size*24(a4)
	swap	d2
	move.b	d2,cl2_extension7_size*26(a4)
	move.b	d3,cl2_extension7_size*31(a4)
	swap	d3
	move.b	d3,cl2_extension7_size*29(a4)
	lsr.l	#8,d3
	move.b	d3,cl2_extension7_size*28(a4)
	swap	d3
	move.b	d3,cl2_extension7_size*30(a4)
	movem.l (a1)+,d0-d1		; fetch 16x BPLAM values
	move.b	d0,cl2_extension7_size*35(a4)
	swap	d0
	move.b	d0,cl2_extension7_size*33(a4)
	lsr.l	#8,d0
	move.b	d0,cl2_extension7_size*32(a4)
	swap	d0
	move.b	d0,cl2_extension7_size*34(a4)
	add.l	d5,a4			; skip 40 lines in cl
	move.b	d1,(cl2_extension7_size*39)-(cl2_extension7_size*40)(a4)
	swap	d1
	move.b	d1,(cl2_extension7_size*37)-(cl2_extension7_size*40)(a4)
	lsr.l	#8,d1
	move.b	d1,(cl2_extension7_size*36)-(cl2_extension7_size*40)(a4)
	swap	d1
	move.b	d1,(cl2_extension7_size*38)-(cl2_extension7_size*40)(a4)
	dbf	d6,set_center_bar_loop2
set_center_bar_skip
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	dbf	d7,set_center_bar_loop1
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
tb31612_set_foreground_bars
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	moveq	#tb31612_bar_height,d4
	lea	tb31612_yz_coords(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension7_entry+cl2_ext7_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5	; BPLAM table
	lea	tb31612_fader_columns_mask(pc),a6
	lea	we_y_coords_end(pc),a7
	moveq	#cl2_display_width-1,d7 ; number of columns
tb31612_set_foreround_bars_loop1
	tst.b	(a6)+			; display column ?
	beq.s	tb31612_set_foreround_bars_skip1
	ADDF.W  tb31612_bars_number*LONGWORD_SIZE,a0 ; skip z vector and y
	subq.w	#WORD_SIZE,a7		; skip 2nd y
	bra	tb31612_set_foreground_bars_skip4
	CNOP 0,4
tb31612_set_foreround_bars_skip1
	move.w	-(a7),d0		; 2nd y
	MULUF.W cl2_extension7_size/4,d0,d1 ; 2nd y offset in cl
	move.l	a5,a1			; BPLAM table
	lea	(a2,d0.w*4),a3		; add 2nd y offset
	moveq	#tb31612_bars_number-1,d6
tb31612_set_foreround_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bmi.s	tb31612_set_foreground_bars_skip2
	add.l   d4,a1			; skip BPLAM values
	bra	tb31612_set_foreground_bars_skip3
	CNOP 0,4
tb31612_set_foreground_bars_skip2
	lea	(a3,d0.w*4),a4		;y offset
	COPY_TWISTED_BAR.B tb31612,cl2,extension7,bar_height
tb31612_set_foreground_bars_skip3
	dbf	d6,tb31612_set_foreround_bars_loop2
tb31612_set_foreground_bars_skip4
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	dbf	d7,tb31612_set_foreround_bars_loop1
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
bf_clear_buffer
	move.l	#color255_bits,d0
	move.l	extra_memory(a3),a0
	add.l	#em_color_buffer+(bf_bar_height*LONGWORD_SIZE),a0
	MOVEF.W visible_lines_number-1,d7
bf_clear_buffer_loop
	move.l	d0,(a0)+
	dbf	d7,bf_clear_buffer_loop
	rts


	CNOP 0,4
bf_set_bars
	movem.l a4-a6,-(a7)
	move.l	a7,save_a7(a3)
	MOVEF.W bf_y_max,d3
	MOVEF.L (((bf_source_bar_y_size-bf_destination_bar_y_size)/2)+1)*LONGWORD_SIZE,d4
	lea	bf_yz_coords(pc),a0
	move.l	extra_memory(a3),a2
	add.l	#em_color_buffer,a2
	lea	bf_color_table_ptrs(pc),a5
	move.w	#bf_y_center,a6
	move.w	#bf_z_plane1,a7
	moveq	#bf_bars_planes_number-1,d7
bf_set_bars_loop1
	moveq	#bf_bars_per_plane-1,d6
bf_set_bars_loop2
	move.w	(a0)+,d0		; y
	move.w	(a0)+,d1		; z
	ble.s	bf_set_bars_skip3
	MULSF.W bf_d,d0			; y*d
	moveq	#bf_d,d2
	add.w	d1,d2			; z+d
	divs.w	d2,d0			; y'=(y*d)/(z+d)
	add.w	a6,d0			; y' + y center
	bmi.s	bf_set_bars_skip3
	cmp.w	d3,d0			; y max ?
	bge.s	bf_set_bars_skip3
	move.l	(a5),a1
	subq.w	#LONGWORD_SIZE,a1	; color table
	moveq	#0,d2			; z planes counter
	moveq	#bf_z_planes_number-1,d5
bf_set_bars_loop3
	addq.w	#LONGWORD_SIZE,a1	; skip pointer color table
	add.w	a7,d2			; next z plane
	cmp.w	d2,d1			; z plane matching ?
	dblt	d5,bf_set_bars_loop3
	subq.w	#bf_z_speed,d1		; decrease y
	lea	(a2,d0.w*4),a4		; y offset in buffer
	move.w	d1,-WORD_SIZE(a0)	; z
	moveq	#bf_bar_height-1,d5
bf_set_bars_loop4
	move.l	(a1),d0			; RGB8
	beq.s	bf_set_bars_skip1
	move.l	d0,(a4)+		
bf_set_bars_skip1
	add.l	d4,a1			; next line in color table
	dbf	d5,bf_set_bars_loop4
	dbf	d6,bf_set_bars_loop2
bf_set_bars_skip2
	addq.w	#LONGWORD_SIZE,a5	; next pointer color table
	dbf	d7,bf_set_bars_loop1
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a4-a6
	rts
	CNOP 0,4
bf_set_bars_skip3
	tst.w	bf_z_restart_active(a3) ; reset z plane ?
	bne.s	bf_set_bars_skip2
	subq.w	#LONGWORD_SIZE,a0
	move.w	#bf_z_plane1*bf_z_planes_number,WORD_SIZE(a0) ; rearmost z plane
	bra.s	bf_set_bars_loop2


	CNOP 0,4
bf_copy_buffer
	movem.l a4-a5,-(a7)
	move.w	#RB_NIBBLES_MASK,d3
	move.l	extra_memory(a3),a0
	add.l	#em_color_buffer+(bf_bar_height*LONGWORD_SIZE),a0
	move.l	cl2_construction2(a3),a1 
	IFEQ tb31612_quick_clear_enabled
		ADDF.W	cl2_extension7_entry+cl2_ext7_COLOR31_high+WORD_SIZE,a1
		move.w	#bplcon3_bits3,a2 ; High-RGB-Werte
		move.w	#bplcon3_bits4,a4 ; Low-RGB-Werte
	ELSE
		ADDF.W	cl2_extension7_entry+cl2_ext7_COLOR00_high+WORD_SIZE,a1
		move.w	#bplcon3_bits1,a2 ; High-RGB-Werte
		move.w	#bplcon3_bits2,a4 ; Low-RGB-Werte
	ENDC
	move.w	#cl2_extension7_size,a5
	MOVEF.W visible_lines_number-1,d7
bf_copy_buffer_loop
	move.l	(a0)+,d0		; RGB8
	move.l	d0,d2		
	IFEQ tb31612_quick_clear_enabled
		move.w	a2,cl2_ext7_BPLCON3_1-cl2_ext7_COLOR31_high(a1) ; restore CMOVE
	ELSE
		move.w	a2,cl2_ext7_BPLCON3_1-cl2_ext7_COLOR00_high(a1) ; restore CMOVE
	ENDC
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a1)			; color high
	RGB8_TO_RGB4_LOW d2,d1,d3
	IFEQ tb31612_quick_clear_enabled
		move.w	d2,cl2_ext7_COLOR31_low-cl2_ext7_COLOR31_high(a1) ; color low
	ELSE
		move.w	d2,cl2_ext7_COLOR00_low-cl2_ext7_COLOR00_high(a1) ; color low
	ENDC
	add.l	a5,a1			; next line in cl
	IFEQ tb31612_quick_clear_enabled
		move.w	a4,cl2_ext7_BPLCON3_2-cl2_ext7_COLOR31_high-cl2_extension7_size(a1) ; restore CMOVE
	ELSE
		move.w	a4,cl2_ext7_BPLCON3_2-cl2_ext7_COLOR00_high-cl2_extension7_size(a1) ; restore CMOVE
	ENDC
	dbf	d7,bf_copy_buffer_loop
	movem.l (a7)+,a4-a5
	rts

	GET_TWISTED_BARS_YZ_COORDINATES tb31612,256,cl2_extension7_size


; Wave-Effect
	CNOP 0,4
we_get_y_coords
	move.w	we_radius_y_angle(a3),d2 ; 1st y radius angle
	move.w	d2,d0		
	move.w	we_y_angle(a3),d3	; 1st y angle
	addq.b	#we_y_radius_angle_speed,d0
	move.w	d0,we_radius_y_angle(a3) 
	move.w	d3,d0		
	addq.b	#we_y_angle_speed,d0
	move.w	d0,we_y_angle(a3)	
	lea	sine_table(pc),a0	
	lea	we_y_coords(pc),a1
	moveq	#cl2_display_width-1,d7	; number of columns
we_get_y_coords_loop
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L we_y_radius*4,d0,d1	; yr'=(yr*sin(w))/2^15
	swap	d0
	muls.w	2(a0,d3.w*4),d0		; y'=(yr'*sin(w))/2^15
	swap	d0
	move.w	d0,(a1)+		; y position
	addq.b	#we_y_radius_angle_step,d2
	addq.b	#we_y_angle_step,d3
	dbf	d7,we_get_y_coords_loop
	rts


	IFNE tb31612_quick_clear_enabled
		RESTORE_BLCON4_CHUNKY_SCREEN tb,cl2,construction2,extension7,32,,tb31612_restore_blit
		IFNE tb31612_restore_cl_cpu_enabled
tb31612_restore_blit
			move.l	cl2_construction1(a3),a0
			add.l	#cl2_extension8_entry+cl2_ext8_BLTDPTH+WORD_SIZE,a0
			move.l	cl2_construction2(a3),d0
			add.l	#cl2_extension7_entry+cl2_ext7_WAIT+WORD_SIZE,d0
			move.w	d0,cl2_ext8_BLTDPTL-cl2_ext8_BLTDPTH(a0)
			swap	d0
			move.w	d0,(a0)	; BLTDPTH
			rts
		ENDC
	ENDC


	CNOP 0,4
chunky_columns_fader_in
	tst.w	ccfi_active(a3)
	bne.s	chunky_columns_fader_in_quit
	subq.w	#ccfi_delay_speed,ccfi_columns_delay_counter(a3)
	bgt.s	chunky_columns_fader_in_quit
	move.w	ccfi_columns_delay_reset(a3),ccfi_columns_delay_counter(a3)
	move.w	ccfi_start(a3),d1
	moveq	#cl2_display_width-1,d2 ; number of columns
	move.l	ccf_fader_columns_mask(a3),a0
	move.w	ccfi_current_mode(a3),d0
	beq.s	ccfi_fader_mode_1
	subq.w	#1,d0			; Fader-In-Mode2 ?
	beq.s	ccfi_fader_mode_2
	subq.w	#1,d0			; Fader-In-Mode3 ?
	beq.s	ccfi_fader_mode_3
	subq.w	#1,d0			; Fader-In-Mode4 ?
	beq.s	ccfi_fader_mode_4
chunky_columns_fader_in_quit
	rts
; Fade in columns from left to right
	CNOP 0,4
ccfi_fader_mode_1
	clr.b	(a0,d1.w)		; state: fade in
	addq.w	#1,d1			; next column
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfi_fader_mode_skip
	move.w	d1,ccfi_start(a3)
	rts
; Fade in columns from right to left
	CNOP 0,4
ccfi_fader_mode_2
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#1,d1			; next column
	clr.b	cl2_display_width-1(a0,d0.w) ; state: fade in
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfi_fader_mode_skip
	move.w	d1,ccfi_start(a3)
	rts
; Fade in columns from right and left to center
	CNOP 0,4
ccfi_fader_mode_3
	clr.b	(a0,d1.w)		; state: fade in
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#1,d1			; next column
	lsr.w	#1,d2			; center in table
	clr.b	cl2_display_width-1(a0,d0.w) ; state: fade in
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfi_fader_mode_skip
	move.w	d1,ccfi_start(a3)
	rts
; Fade in every 2nd column from left and right
	CNOP 0,4
ccfi_fader_mode_4
	clr.b	(a0,d1.w)		; state: fade in
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#2,d1			; column after next
	clr.b	cl2_display_width-1(a0,d0.w) ; state: fade in
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfi_fader_mode_skip
	move.w	d1,ccfi_start(a3)
	rts
	CNOP 0,4
ccfi_fader_mode_skip
	move.w	#FALSE,ccfi_active(a3)
	rts


	CNOP 0,4
chunky_columns_fader_out
	tst.w	ccfo_active(a3)
	bne.s	chunky_columns_fader_out_quit
	subq.w	#ccfo_delay_speed,ccfo_columns_delay_counter(a3)
	bgt.s	chunky_columns_fader_out_quit
	move.w	ccfo_columns_delay_reset(a3),ccfo_columns_delay_counter(a3)
	move.w	ccfo_start(a3),d1
	moveq	#cl2_display_width-1,d2 ; number of columns
	move.l	ccf_fader_columns_mask(a3),a0
	move.w	ccfo_current_mode(a3),d0
	beq.s	ccfo_fader_mode_1
	subq.w	#1,d0			; Fader-Out-Mode2 ?
	beq.s	ccfo_fader_mode_2
	subq.w	#1,d0			; Fader-Out-Mode3 ?
	beq.s	ccfo_fader_mode_3
	subq.w	#1,d0			; Fader-Out-Mode4 ?
	beq.s	ccfo_fader_mode_4
chunky_columns_fader_out_quit
	rts
; Fade out columns from left to right
	CNOP 0,4
ccfo_fader_mode_1
	not.b	(a0,d1.w)		; state: fade out
	addq.w	#1,d1			; next column
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfo_fader_mode_skip
	move.w	d1,ccfo_start(a3)
	rts
; Fade out columns from right to left
	CNOP 0,4
ccfo_fader_mode_2
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#1,d1			; next column
	not.b	cl2_display_width-1(a0,d0.w) ; state: fade out
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfo_fader_mode_skip
	move.w	d1,ccfo_start(a3)
	rts
; Fade out columns from left and right
	CNOP 0,4
ccfo_fader_mode_3
	not.b	(a0,d1.w)		; state: fade out
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#1,d1			; next column
	lsr.w	#1,d2			; center of table
	not.b	cl2_display_width-1(a0,d0.w) ; state: fade out
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfo_fader_mode_skip
	move.w	d1,ccfo_start(a3)
	rts
; Fade out every 2nd column from left and right
	CNOP 0,4
ccfo_fader_mode_4
	not.b	(a0,d1.w)		; state: fade out
	move.w	d1,d0			; start
	neg.w	d0
	addq.w	#2,d1			; column after next
	not.b	cl2_display_width-1(a0,d0.w) ; state: fade out
	cmp.w	d2,d1			; finished ?
	bgt.s	ccfo_fader_mode_skip
	move.w	d1,ccfo_start(a3)
	rts
	CNOP 0,4
ccfo_fader_mode_skip
	move.w	#FALSE,ccfo_active(a3)
	rts


	CNOP 0,4
effects_handler
	moveq	#INTF_SOFTINT,d1
	and.w	INTREQR-DMACONR(a6),d1
	beq.s   effects_handler_quit
	move.w	eh_trigger_number(a3),d0
	cmp.w	#eh_trigger_number_max,d0
	bgt.s	effects_handler_quit
	move.w	d1,INTREQ-DMACONR(a6)
	addq.w	#1,d0
	move.w	d0,eh_trigger_number(a3)
	subq.w	#1,d0
	beq.s	eh_start_barfield
	subq.w	#1,d0
	beq.s	eh_start_wave_center_bar
	subq.w	#1,d0
	beq.s	eh_start_twisted_bars31612
	subq.w	#1,d0
	beq.s	eh_start_horiz_scrolltext
	subq.w	#1,d0
	beq.s	eh_stop_horiz_scrolltext
	subq.w	#1,d0
	beq.s	eh_stop_wave_center_bar
	subq.w	#1,d0
	beq.s	eh_stop_twisted_bars31612
	subq.w	#1,d0
	beq	eh_disable_barfield_z_restart
	subq.w	#1,d0
	beq	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_barfield
	clr.w	bf_active(a3)
	rts
	CNOP 0,4
eh_start_wave_center_bar
	clr.w	ccfi_active(a3)
	move.w	#1,ccfi_columns_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_twisted_bars31612
	lea	tb31612_fader_columns_mask(pc),a0
	move.l	a0,ccf_fader_columns_mask(a3)
	move.w	#ccfi_mode1,ccfi_current_mode(a3)
	clr.w	ccfi_start(a3)
	clr.w	ccfi_active(a3)
	move.w	#1,ccfi_columns_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_horiz_scrolltext
	clr.w	ss_enabled(a3)
	rts
	CNOP 0,4
eh_stop_horiz_scrolltext
	move.w	#FALSE,ss_enabled(a3)
	rts
	CNOP 0,4
eh_stop_wave_center_bar
	lea	wcb_fader_columns_mask(pc),a0
	move.l	a0,ccf_fader_columns_mask(a3)
	clr.w	ccfo_active(a3)
	move.w	#1,ccfo_columns_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_stop_twisted_bars31612
	lea	tb31612_fader_columns_mask(pc),a0
	move.l	a0,ccf_fader_columns_mask(a3)
	clr.w	ccfo_start(a3)
	clr.w	ccfo_active(a3)
	move.w	#1,ccfo_columns_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_disable_barfield_z_restart
	move.w	#FALSE,bf_z_restart_active(a3)
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
	DC.L color00_bits
	DS.L 256-2			; pf1_colors_number-2
	DC.L color255_bits


; Twisted-Bars3.16.1.2
	CNOP 0,4
tb31612_bars_color_table
	INCLUDE "RasterMaster:colortables/06_tb31612_Colorgradient.ct"

	CNOP 0,4
tb31612_yz_coords
	DS.W tb31612_bars_number*cl2_display_width*2

tb31612_fader_columns_mask
	REPT cl2_display_width
		DC.B FALSE
	ENDR


; Wave-Center-Bar
	CNOP 0,4
wcb_bar_color_table
	INCLUDE "RasterMaster:colortables/06_wcb_Colorgradient.ct"

wcb_fader_columns_mask
	REPT cl2_display_width
		DC.B FALSE
	ENDR


; Wave-Effect
	CNOP 0,2
we_y_coords
	DS.W cl2_display_width
we_y_coords_end


; Sine-Scrolltext
	CNOP 0,4
ss_color_table
	INCLUDE "RasterMaster:colortables/06_ss_Colorgradient.ct"

ss_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/ "
ss_ascii_end
	EVEN

	CNOP 0,2
ss_chars_offsets
	DS.W ss_ascii_end-ss_ascii


; Barfield
	CNOP 0,4
bf_color_table
	INCLUDE "RasterMaster:colortables/06_bf_Colorgradient.ct"

	CNOP 0,4
bf_color_table_ptrs
	DS.L bf_bars_planes_number

bf_bitmap_lines_table
	DS.B bf_source_bar_y_size
	EVEN

	CNOP 0,2
bf_yz_coords
	DC.W -900,3000			; z plane 1
	DC.W 600,2600			; z plane 2
	DC.W -300,2200			; z plane 3
	DC.W 150,1800			; z plane 4
	DC.W -200,1400			; z plane 5
	DC.W 600,1000			; z plane 6


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Sine-Scrolltext
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


; Gfx data

; Sine-Scrolltext
ss_image_data			SECTION ss_gfx,DATA_C
	INCBIN "RasterMaster:fonts/32x32x2-Font.rawblit"

	END
