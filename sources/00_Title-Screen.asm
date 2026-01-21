; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


; Imports
	XREF color00_bits
	XREF pt_track_notes_played_enabled
	XREF pt_track_volumes_enabled
	XREF pt_track_periods_enabled
	XREF pt_track_data_enabled
	XREF pt_audchan1temp
	XREF pt_audchan2temp
	XREF pt_audchan3temp
	XREF pt_audchan4temp
	XREF pt_oneshotlen

; Exports
	XDEF start_00_title_screen
	XDEF mouse_handler
	XDEF sine_table
	XDEF bg_image_data


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


	INCDIR "custom-includes-aga:"


SYS_TAKEN_OVER			SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
START_SECOND_COPPERLIST		SET 1


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

dma_bits			EQU DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR

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
pf1_x_size3			EQU 384
pf1_y_size3			EQU 256
pf1_depth3			EQU 7
pf1_colors_number		EQU 128

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
spr_odd_color_table_select	EQU 8
spr_even_color_table_select	EQU 8
spr_used_number			EQU 8

audio_memory_size		EQU 0

disk_memory_size		EQU 0

extra_memory_size		EQU 0

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

pixel_per_line			EQU 336
visible_pixels_number		EQU 352
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 16	; 1x
spr_pixel_per_datafetch		EQU 64	; 4x

display_window_hstart		EQU HSTART_352_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_352_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_320_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_16_PIXEL
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU BPLCON2F_PF2P2
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM

cl2_display_x_size		EQU 0
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU visible_lines_number
cl2_hstart1			EQU (ddfstrt_bits*2)-((pf1_depth3*CMOVE_SLOT_PERIOD)+(1*CMOVE_SLOT_PERIOD))

cl2_vstart1			EQU MINROW
cl2_hstart2			EQU 0
cl2_vstart2			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 256

; Background-Image
bg_image_x_size			EQU 352
bg_image_plane_width		EQU bg_image_x_size/8
bg_image_y_size			EQU 256
bg_image_depth			EQU 7

; Logo
lg_image_x_size			EQU 256
lg_image_plane_width		EQU lg_image_x_size/8
lg_image_y_size			EQU 75
lg_image_depth			EQU 16

lg_image_x_center		EQU (visible_pixels_number-lg_image_x_size)/2
lg_image_y_center		EQU (visible_lines_number-lg_image_y_size)/2
lg_image_x_position		EQU display_window_hstart+lg_image_x_center
lg_image_y_position		EQU display_window_vstart+lg_image_y_center

; Channelscope
cs_selected_chan		EQU 2
cs_scope_x_size			EQU 128

; Wobble-Display
wd_x_speed			EQU 1
wd_x_step			EQU 1
wd_table_length			EQU cs_scope_x_size

; Image-Fader
if_rgb8_start_color		EQU 1
if_rgb8_color_table_offset	EQU 1
if_rgb8_colors_number		EQU pf1_colors_number-1

ifi_rgb8_fader_speed_max	EQU 4
ifi_rgb8_fader_radius		EQU ifi_rgb8_fader_speed_max
ifi_rgb8_fader_center		EQU ifi_rgb8_fader_speed_max+1
ifi_rgb8_fader_angle_speed	EQU 4

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
ipfi_delay_angle_speed		EQU 1

; Image-Pixel-Fader-Out
ipfo_delay			EQU 24
ipfo_delay_radius		EQU ipfo_delay
ipfo_delay_center		EQU ipfo_delay+1
ipfo_delay_angle_speed		EQU 1

; Effects-Handler
eh_trigger_number_max		EQU 6


pf1_plane_x_offset		EQU 16
pf1_bpl1dat_x_offset		EQU 0


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; PT-Replay
	INCLUDE "music-tracker/pt-temp-channel.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAIT			RS.L 1
cl2_ext1_BPLCON1		RS.L 1
cl2_ext1_BPL7DAT		RS.L 1
cl2_ext1_BPL6DAT		RS.L 1
cl2_ext1_BPL5DAT		RS.L 1
cl2_ext1_BPL4DAT		RS.L 1
cl2_ext1_BPL3DAT		RS.L 1
cl2_ext1_BPL2DAT		RS.L 1
cl2_ext1_BPL1DAT		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B (cl2_extension1_size*cl2_display_y_size)+LONGWORD_SIZE

cl2_WAIT			RS.L 1
cl2_INTREQ			RS.L 1

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size

cl2_size1			EQU 0
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

spr1_extension1			RS.B 0

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

; Wobble-Display
wd_active			RS.W 1

; Image-Fader
if_rgb8_colors_counter		RS.W 1
if_rgb8_copy_colors_active	RS.W 1

ifi_rgb8_active			RS.W 1
ifi_rgb8_fader_angle		RS.W 1

ifo_rgb8_active			RS.W 1
ifo_rgb8_fader_angle		RS.W 1

; Image-Pixel-Fader
	RS_ALIGN_LONGWORD
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
	RS_ALIGN_LONGWORD
cl_end				RS.L 1
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_00_title_screen


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Wobble-Display
	moveq	#FALSE,d1
	move.w	d1,wd_active(a3)

; Image-Fader
	moveq	#TRUE,d0
	move.w	d0,if_rgb8_colors_counter(a3)
	move.w	d1,if_rgb8_copy_colors_active(a3)

	move.w	d1,ifi_rgb8_active(a3)
	moveq	#sine_table_length/4,d2
	move.w	d2,ifi_rgb8_fader_angle(a3) ; 90°

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
	bsr	init_sprites
	bsr	bg_copy_image_to_playfield
	bsr	init_first_copperlist
	bsr	init_second_copperlist
	rts


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 4
	CPU_INIT_COLOR_HIGH COLOR00,16,spr_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 4
	CPU_INIT_COLOR_LOW COLOR00,16,spr_rgb8_color_table
	rts


	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bsr.s	lg_init_attached_sprites_cluster
	rts


	INIT_SPRITE_POINTERS_TABLE


; Logo
	INIT_ATTACHED_SPRITES_CLUSTER lg,spr_pointers_display,lg_image_x_position,lg_image_y_position,spr_x_size2,lg_image_y_size,,BLANK

; Background-Image
	CNOP 0,4
bg_copy_image_to_playfield
	move.l	a4,-(a7)
	move.l	#bg_image_data+(pf1_plane_x_offset/8),a1 ; bitplane 1
	move.l	pf1_display(a3),a4	; destination
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 2
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 3
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 4
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 5
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 6
	bsr.s	bg_copy_image_data
	add.l	#bg_image_plane_width,a1 ; bitplane 7
	bsr.s	bg_copy_image_data
	move.l	(a7)+,a4
	rts

;Input
; a1.l		source: image
; a4.l		destination: bitplane
; Result
	CNOP 0,4
bg_copy_image_data
	move.l	a1,a0			; source
	move.l	(a4)+,a2		; destination
	MOVEF.W bg_image_y_size-1,d7
bg_copy_image_data_loop
	REPT pixel_per_line/WORD_BITS
		move.w	(a0)+,(a2)+	; copy 42 bytes
	ENDR
	ADDF.W	(bg_image_plane_width*(bg_image_depth-1))+WORD_SIZE,a0 ; next line in source
	ADDF.W	(pf1_plane_width*(pf1_depth3-1))+6,a2 ; next line in destination
	dbf	d7,bg_copy_image_data_loop
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0 
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_sprite_pointers
	bsr	cl1_init_colors
	bsr	cl1_init_bitplane_pointers
	COP_MOVEQ 0,COPJMP2
	bsr	cl1_set_sprite_pointers
	bsr	cl1_set_bitplane_pointers
	rts


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_SPRITE_POINTERS cl1


	CNOP 0,4
cl1_init_colors
	COP_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_HIGH_BANK 1
	COP_INIT_COLOR_HIGH COLOR00,32
	COP_SELECT_COLOR_HIGH_BANK 2
	COP_INIT_COLOR_HIGH COLOR00,32
	COP_SELECT_COLOR_HIGH_BANK 3
	COP_INIT_COLOR_HIGH COLOR00,32

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
	COP_SELECT_COLOR_LOW_BANK 1
	COP_INIT_COLOR_LOW COLOR00,32
	COP_SELECT_COLOR_LOW_BANK 2
	COP_INIT_COLOR_LOW COLOR00,32
	COP_SELECT_COLOR_LOW_BANK 3
	COP_INIT_COLOR_LOW COLOR00,32
	rts


	COP_INIT_BITPLANE_POINTERS cl1


	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0
	bsr.s	cl2_init_bpldat
	bsr	cl2_init_copper_interrupt
	COP_LISTEND
	move.l	a0,cl_end(a3)
	bsr	copy_second_copperlist
	rts


	CNOP 0,4
cl2_init_bpldat
	movem.l a4-a5,-(a7)
	move.l	#bg_image_data+(pf1_BPL1DAT_x_offset/8),a1 ; bitplane 1
	move.w	#BPL5DAT,a2
	move.w	#BPL6DAT,a4
	move.w	#BPL7DAT,a5
	move.l	#(((cl2_vstart1<<24)|(((cl2_hstart1/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.w	#BPL1DAT,d1
	move.w	#BPL2DAT,d2
	move.w	#BPL3DAT,d3
	move.w	#BPL4DAT,d4
	move.l	#(((CL_Y_WRAPPING<<24)|(((cl2_hstart1/4)*2)<<16))|$10000)|$fffe,d5 ; CWAIT
	move.l	#$01000000,d6
	MOVEF.W cl2_display_y_size-1,d7
cl2_init_bpldat_loop
	move.l	d0,(a0)+		; CWAIT
	COP_MOVEQ 0,BPLCON1
	move.w	a5,(a0)+		; BPL7DAT
	move.w	bg_image_plane_width*6(a1),(a0)+ ; 1st word bitplane 7
	move.w	a4,(a0)+		; BPL6DAT
	move.w	bg_image_plane_width*5(a1),(a0)+ ; 1st word bitplane 6
	move.w	a2,(a0)+		; BPL5DAT
	move.w	bg_image_plane_width*4(a1),(a0)+ ; 1st word bitplane 5
	move.w	d4,(a0)+		; BPL4DAT
	move.w	bg_image_plane_width*3(a1),(a0)+ ; 1st word bitplane 4
	move.w	d3,(a0)+		; BPL3DAT
	move.w	bg_image_plane_width*2(a1),(a0)+ ; 1st word bitplane 3
	move.w	d2,(a0)+		; BPL2DAT
	move.w	bg_image_plane_width*1(a1),(a0)+ ; 1st word bitplane 2
	move.w	d1,(a0)+		; BPL1DAT
	move.w	(a1),(a0)+		; 1st word bitplane 1
	ADDF.W	bg_image_plane_width*bg_image_depth,a1 ; next line in source
	cmp.l	d5,d0			; rasterline $ff ?
	bne.s   cl2_init_bpldat_skip
	COP_WAIT CL_X_WRAPPING_7_BITPLANES_1X,CL_Y_WRAPPING ; patch cl
cl2_init_bpldat_skip
	add.l	d6,d0			; next line
	dbf	d7,cl2_init_bpldat_loop
	movem.l (a7)+,a4-a5
	rts


	COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bsr.s	beam_routines
	rts


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr	effects_handler
	bsr	ipf_random_pixel_data_copy
	bsr	fetch_channels_data
	bsr	wobble_display
	bsr	image_fader_in
	bsr	image_fader_out
	bsr	if_rgb8_copy_color_table
	bsr	image_pixel_fader_in
	bsr	image_pixel_fader_out
	jsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s	beam_routines quit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines quit
	move.l	cl_end(a3),COP2LC-DMACONR(a6)
	move.w	d0,COPJMP2-DMACONR(a6)
	move.l	cl_end(a3),COP1LC-DMACONR(a6)
	move.w	d0,COPJMP1-DMACONR(a6)
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	CNOP 0,4
fetch_channels_data
	move.l	#PAL_CLOCK_CONSTANT/PAL_FPS,d6
	IFEQ cs_selected_chan-1
		lea	pt_audchan1temp(pc),a0
		lea	cs_audchandata(pc),a2
		MOVEF.W cs_scope_x_size-1,d7
	ENDC
	IFEQ cs_selected_chan-2
		lea	pt_audchan2temp(pc),a0
		lea	cs_audio_channel_data(pc),a2
		MOVEF.W cs_scope_x_size-1,d7
	ENDC
	IFEQ cs_selected_chan-3
		lea	pt_audchan3temp(pc),a0
		lea	cs_audio_channel_data(pc),a2
		MOVEF.W cs_scope_x_size-1,d7
	ENDC
	IFEQ cs_selected_chan-4
		lea	pt_audchan4temp(pc),a0
		lea	cs_audio_channel_data(pc),a2
		MOVEF.W cs_scope_x_size-1,d7
	ENDC
	bsr.s	fetch_sample_data
	rts


; Input
; d6.l	clock constant = PAL clock constant/PAL frequency
; d7.w	Number of samplebytes to fetch
; a0.l	 temporary audio channel structure
; a2.l	 table with channel amplitudes
; Result
	CNOP 0,4
fetch_sample_data
	tst.b	n_notetrigger(a0)	; new note ?
	bne.s	fetch_sample_data_skip1
	move.l	n_start(a0),n_currentstart(a0)
	move.l	n_length(a0),n_currentlength(a0)
	clr.w	n_chandatapos(a0)	; reset position in channel data
	move.b	#FALSE,n_notetrigger(a0)
fetch_sample_data_skip1
	move.w	n_currentperiod(a0),d0
	beq.s	fetch_sample_data_quit
	moveq	#0,d1
	move.w	n_currentvolume(a0),d1
	moveq	#0,d2
	move.w	n_chandatapos(a0),d2
	move.l	d2,d5			; position in sample data
	move.l	d6,d3			; clock constant
	divu.w	d0,d3			; samplebytes per frame = clock constant/note period
	moveq	#0,d4
	ext.l	d3
	move.w	n_currentlength(a0),d4
	MULUF.W WORD_SIZE,d4		; length in bytes
	move.l	n_currentstart(a0),a1
fetch_sample_data_loop
	move.b	(a1,d2.l),d0		; fetch audio data
	ext.w	d0
	muls.w	d1,d0			; amplitude = (audio data*current volume)/volume max
	asr.w	#6,d0
	move.w	d0,(a2)+
	addq.w	#BYTE_SIZE,d2		; next audio data
	cmp.w	d4,d2			; end of sample data ?
	blo.s	fetch_sample_data_skip2
	moveq	#0,d2			; reset position in channel data
fetch_sample_data_skip2
	dbf	d7,fetch_sample_data_loop
	add.l	d3,d5			; next reset position in channel data
	cmp.l	d4,d5			; end of sample data ?
	blt.s	fetch_sample_data_skip3
	move.w	n_replen(a0),d0
	cmp.w	#pt_oneshotlen,d0	; oneshot sample ?
	beq.s	fetch_sample_data_skip6
fetch_sample_data_skip3
	cmp.l	n_loopstart(a0),a1	; loop already played ?
	bne.s	fetch_sample_data_skip5
fetch_sample_data_skip4
	sub.l	d4,d5			; loop start
	cmp.l	d4,d5			; end of sample data ?
	bge.s	fetch_sample_data_skip4
	bra.s	fetch_sample_data_skip7
	CNOP 0,4
fetch_sample_data_skip5
	move.l	n_loopstart(a0),n_currentstart(a0)
fetch_sample_data_skip6
	move.w	d0,n_currentlength(a0)
	moveq	#0,d5			; reset position in channel data
fetch_sample_data_skip7
	move.w	d5,n_chandatapos(a0)
fetch_sample_data_quit
	rts


	CNOP 0,4
wobble_display
	tst.w	wd_active(a3)
	bne.s	wobble_display_quit
	MOVEF.W $ff,d3			; scrolling mask H0-H7
	moveq	#cl2_extension1_size,d4
	IFGE visible_lines_number-212
		move.w	#(cl2_display_y_size-(CL_Y_WRAPPING-cl2_vstart1))-1,d5
	ENDC
	MOVEF.W wd_table_length-1,d6	; overflow 360°
	lea	cs_audio_channel_data(pc),a0
	move.l	cl2_construction2(a3),a1
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON1+WORD_SIZE,a1
	MOVEF.W cl2_display_y_size-1,d7
wobble_display_loop
	move.w	(a0,d2.w*2),d0		; x shift
	PF_SOFTSCROLL_64PIXEL_LORES d0,d1,d3
	move.w	d0,(a1)			; BPLCON1
	IFGE visible_lines_number-212
		cmp.w	d5,d7		; line $ff ?
		bne.s	wobble_display_skip
		addq.w	#LONGWORD_SIZE,a1 ; skip CWAIT
wobble_display_skip
	ENDC
	addq.w	#wd_x_step,d2
	add.l	d4,a1			; next line
	and.w	d6,d2			; remove overflow
	dbf	d7,wobble_display_loop
wobble_display_quit
	rts


	CNOP 0,4
image_fader_in
	movem.l a4-a6,-(a7)
	tst.w	ifi_rgb8_active(a3)
	bne.s	image_fader_in_quit
	move.w	ifi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	ifi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0 ; 180° ?
	ble.s	image_fader_in_skip
	MOVEF.W sine_table_length/2,d0
image_fader_in_skip
	move.w	d0,ifi_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ifi_rgb8_fader_radius*2,d0,d1	; y' = (yr*sin(w))/2^15
	swap	d0
	ADDF.W	ifi_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifi_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increment/decrement blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increment/decrement red
	lsr.l	#8,d0
	move.l	d0,a4			; increment/decrement green
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
	ADDF.W	ifo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s   image_fader_out_skip
	MOVEF.W sine_table_length/2,d0
image_fader_out_skip
	move.w	d0,ifo_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ifo_rgb8_fader_radius*2,d0,d1 ; y' = (yr*sin(w))/2^15
	swap	d0
	ADDF.W	ifo_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifo_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increment/decrement blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increment/decrement red
	lsr.l	#8,d0
	move.l	d0,a4			; increment/decrement green
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
	ADDF.W	ipfi_delay_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s	image_pixel_fader_in_skip1
	MOVEF.W sine_table_length/2,d0
image_pixel_fader_in_skip1
	move.w	d0,ipfi_delay_angle(a3)
	lea	sine_table(pc),a0 
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ipfi_delay_radius*2,d0,d1 ; delay' = (delay*sin(w))/2^16
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
	move.l	d3,d2		 	; low longword: size of source
	moveq	#0,d7 			; high longword: size of source
	moveq	#0,d5			; mask
	divu.l	d4,d7:d2		; F = source width/destination width
	move.w	d4,d7			; destination width
	subq.w	#1,d7			; loopend at false
image_pixel_fader_in_in_loop
	move.l	d1,d0			; F
	swap	d0			; /2^16 = bitmap position
	add.l	d2,d1			; increase F (p*F)
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
	bne.s	image_pixel_fader_out_quit
	subq.w	#1,ipfo_delay_counter(a3)
	bgt.s	image_pixel_fader_out_quit
	move.w	ipfo_delay_angle(a3),d2
	move.w	d2,d0
	ADDF.W	ipfo_delay_angle_speed,d0
	cmp.w	#sine_table_length/2,d0	; 180° ?
	ble.s	image_pixel_fader_out_skip1
	MOVEF.W sine_table_length/2,d0
image_pixel_fader_out_skip1
	move.w	d0,ipfo_delay_angle(a3)
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ipfo_delay_radius*2,d0,d1 ; delay' = (delay*sin(w))/2^16
	swap	d0
	ADDF.W	ipfo_delay_center,d0
	move.w	d0,ipfo_delay_counter(a3)
	moveq	#ipf_source_size,d3
	moveq	#0,d4
	swap	d3			; *2^16
	move.w	ipf_destination_size(a3),d4
	bgt.s	image_pixel_fader_out_skip2
	move.w	#FALSE,ipfo_active(a3)
	moveq	#0,d0
	move.l	d0,ipf_mask(a3)		; clear mask
	bra.s	image_pixel_fader_out_quit
	CNOP 0,4
image_pixel_fader_out_skip2
	moveq	#0,d1
	move.l	d3,d2		 	; low longword: size of source
	moveq	#0,d7 			; high longword: size of source
	moveq	#0,d5			; mask
	divu.l	d4,d7:d2		; F = source width / destination width
	move.w	d4,d7			; destination width
	subq.w	#1,d7			; loopend at false
image_pixel_fader_out_loop
	move.l	d1,d0			; F
	swap	d0			; /2^16 = bitmap position
	add.l	d2,d1			; increase F (p*F)
	bset	d0,d5			; set pixel in mask
	dbf	d7,image_pixel_fader_out_loop
	move.l	d5,ipf_mask(a3)
	subq.w	#1,d4			; increase destination width
	move.w	d4,ipf_destination_size(a3)
image_pixel_fader_out_quit
	rts


	CNOP 0,4
ipf_random_pixel_data_copy
	movem.l a4-a5,-(a7)
	move.l	ipf_mask(a3),d1
	lea	spr_pointers_display(pc),a5
	move.l	(a5)+,a0		; Sprite0 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data,a1	; 1st quadword bitplane 1
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0		; Sprite1 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(lg_image_plane_width*2),a1 ; 1st quadword bitplane 3
	bsr	init_sprite_bitmap

	move.l	(a5)+,a0		; Sprite2 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+QUADWORD_SIZE,a1	; 2nd quadword bitplane 1
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0		; Sprite3 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+QUADWORD_SIZE+(lg_image_plane_width*2),a1 ; 2nd quadword bitplane 3
	bsr	init_sprite_bitmap

	move.l	(a5)+,a0		; Sprite4 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*2),a1 ; 3rd quadword
	bsr	init_sprite_bitmap
	move.l	(a5)+,a0		; Sprite5 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*2)+(lg_image_plane_width*2),a1 ; 3rd quadword bitplane 1
	bsr.s	init_sprite_bitmap

	move.l	(a5)+,a0		; Sprite6 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*3),a1 ; 4th quadword bitplane 3 bitplane 1
	bsr.s	init_sprite_bitmap
	move.l	(a5),a0			; Sprite7 structure
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	lea	lg_image_data+(QUADWORD_SIZE*3)+(lg_image_plane_width*2),a1 ; 4th quadword bitplane 3
	bsr.s	init_sprite_bitmap
	movem.l (a7)+,a4-a5
	rts


; Input
; a0.l	 destination: sprite structure
; a1.l	 source: bitplanes
; Result
	CNOP 0,4
init_sprite_bitmap
	move.w	#lg_image_plane_width-8,a2
	move.w	#(lg_image_plane_width*3)-8,a4
	MOVEF.W lg_image_y_size-1,d7
init_sprite_bitmap_loop
	move.l	(a1)+,d0 		; high longword: bitplane 1
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	move.l	(a1)+,d0	 	; low longword bitplane 1
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	add.l	a2,a1			; skip remaining lines in source
	move.l	(a1)+,d0 		; high longword: bitplane 2
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	move.l	(a1)+,d0	 	; low longword: bitplane 2
	and.l	d1,d0			; link with mask
	move.l	d0,(a0)+
	add.l	a4,a1			; skip remaining line and two bitplanes in source
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
	beq.s	eh_start_wobble_display
	subq.w	#1,d0
	beq.s	eh_start_image_pixel_fader_in
	subq.w	#1,d0
	beq.s	eh_start_image_pixel_fader_out
	subq.w	#1,d0
	beq.s	eh_start_image_fader_out
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
eh_start_wobble_display
	clr.w	wd_active(a3)
	rts
	CNOP 0,4
eh_start_image_pixel_fader_in
	clr.w	ipfi_active(a3)
	move.w	#1,ipfi_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_image_pixel_fader_out
	clr.w	ipfo_active(a3)
	move.w	#1,ipfo_delay_counter(a3) ; activate counter
	rts
	CNOP 0,4
eh_start_image_fader_out
	clr.w	ifo_rgb8_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	clr.w	if_rgb8_copy_colors_active(a3)
	rts
	CNOP 0,4
eh_stop_all
	clr.w	stop_fx_active(a3)
	rts



; Input
; Result
; d0.l	Return code
	CNOP 0,4
mouse_handler
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	bne.s	mouse_handler_skip
	moveq	#RETURN_WARN,d0
	rts
	CNOP 0,4
mouse_handler_skip
	moveq	#RETURN_OK,d0
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_interrupt_server
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
	INCLUDE "RasterMaster:colortables/256x75x16-Resistance.ct"


	CNOP 0,4
spr_pointers_display
	DS.L spr_number


	CNOP 0,4
sine_table
	INCLUDE "sine-table-256x32.i"


; Channelscope
	CNOP 0,2
cs_audio_channel_data
	DS.W cs_scope_x_size


; Image-Fader
	CNOP 0,4
ifi_rgb8_color_table
	INCLUDE "RasterMaster:colortables/352x256x128-RasterMaster.ct"

	CNOP 0,4
ifo_rgb8_color_table
	REPT pf1_colors_number
		DC.L color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Gfx data

; Background-Image
bg_image_data			SECTION bg_gfx,DATA
	INCBIN "RasterMaster:graphics/352x256x128-RasterMaster.rawblit"

; Logo
lg_image_data			SECTION lg_gfx,DATA
	INCBIN "RasterMaster:graphics/256x75x16-Resistance.rawblit"

	END
