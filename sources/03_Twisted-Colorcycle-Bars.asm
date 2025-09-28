; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF mouse_handler

	XDEF start_03_twisted_colorcycle_bars
	XDEF sine_table_512


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
COLOR_GRADIENT_RGB8		SET 1


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

; Twisted-Colorcycle-Bars
tccb_quick_clear_enabled	EQU TRUE

	IFEQ open_border_enabled
dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_SETCLR
	ELSE
dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER+MAF_SETCLR
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
pf1_colors_number		EQU 161

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

pixel_per_line			EQU 32
visible_pixels_number		EQU 352
visible_lines_number		EQU 256

MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 16	; 1x

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
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon3_bits3			EQU bplcon3_bits1|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon3_bits4			EQU bplcon3_bits2|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
	ELSE
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_OVERSCAN_32_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon3_bits3			EQU bplcon3_bits1|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon3_bits4			EQU bplcon3_bits2|BPLCON3F_BANK0|BPLCON3F_BANK1|BPLCON3F_BANK2
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
	ENDC

cl1_display_x_size		EQU 352
cl1_display_width		EQU cl1_display_x_size/8
cl1_display_y_size		EQU visible_lines_number
	IFEQ open_border_enabled
cl1_hstart1			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
	ELSE
cl1_hstart1			EQU display_window_hstart-4
	ENDC
cl1_vstart1			EQU MINROW
cl1_hstart2			EQU 0
cl1_vstart2			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Twisted-Colorcycle-Bars
tccb_bars_number		EQU 10
tccb_bar_height			EQU 32
tccb_y_radius			EQU (cl1_display_y_size-tccb_bar_height)/2
tccb_y_center			EQU (cl1_display_y_size-tccb_bar_height)/2
tccb_y_radius_angle_speed	EQU 5
tccb_y_radius_angle_step	EQU 1
tccb_y_angle_speed		EQU 3
tccb_y_angle_step		EQU 2
tccb_y_distance			EQU 16

; Clear-Blit
tccb_clear_blit_x_size		EQU 16
	IFEQ open_border_enabled
tccb_clear_blit_y_size		EQU cl1_display_y_size*(cl1_display_width+2)
	ELSE
tccb_clear_blit_y_size		EQU cl1_display_y_size*(cl1_display_width+1)
	ENDC

; Restore-Blit
tccb_restore_blit_x_size	EQU 16
tccb_restore_blit_width		EQU tccb_restore_blit_x_size/8
tccb_restore_blit_y_size	EQU cl1_display_y_size

; Colorcycle
cc_speed			EQU 4
cc_step				EQU 64

; Blind-Fader
bf_lamella_height		EQU 16
bf_lamellas_number		EQU visible_lines_number/bf_lamella_height
bf_step1			EQU 1
bf_step2			EQU 1
bf_speed			EQU 2

bf_registers_table_length	EQU bf_lamella_height*4

; Effects-Handler
eh_trigger_number_max		EQU 3


color_x_step			EQU 1
color_y_step			EQU 255/(tccb_bar_height/2)
color_x_values_number		EQU 255
color_y_values_number		EQU tccb_bar_height/2
segments_number			EQU 5

ct_size				EQU color_y_values_number*segments_number*color_x_values_number

tccb_bplam_table_size		EQU tccb_bar_height*tccb_bars_number


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_extension1			RS.B 0

cl1_ext1_WAIT			RS.L 1
	IFEQ open_border_enabled 
cl1_ext1_BPL1DAT		RS.L 1
	ENDC
cl1_ext1_BPLCON4_1		RS.L 1
cl1_ext1_BPLCON4_2		RS.L 1
cl1_ext1_BPLCON4_3		RS.L 1
cl1_ext1_BPLCON4_4		RS.L 1
cl1_ext1_BPLCON4_5		RS.L 1
cl1_ext1_BPLCON4_6		RS.L 1
cl1_ext1_BPLCON4_7		RS.L 1
cl1_ext1_BPLCON4_8		RS.L 1
cl1_ext1_BPLCON4_9		RS.L 1
cl1_ext1_BPLCON4_10		RS.L 1
cl1_ext1_BPLCON4_11		RS.L 1
cl1_ext1_BPLCON4_12		RS.L 1
cl1_ext1_BPLCON4_13		RS.L 1
cl1_ext1_BPLCON4_14		RS.L 1
cl1_ext1_BPLCON4_15		RS.L 1
cl1_ext1_BPLCON4_16		RS.L 1
cl1_ext1_BPLCON4_17		RS.L 1
cl1_ext1_BPLCON4_18		RS.L 1
cl1_ext1_BPLCON4_19		RS.L 1
cl1_ext1_BPLCON4_20		RS.L 1
cl1_ext1_BPLCON4_21		RS.L 1
cl1_ext1_BPLCON4_22		RS.L 1
cl1_ext1_BPLCON4_23		RS.L 1
cl1_ext1_BPLCON4_24		RS.L 1
cl1_ext1_BPLCON4_25		RS.L 1
cl1_ext1_BPLCON4_26		RS.L 1
cl1_ext1_BPLCON4_27		RS.L 1
cl1_ext1_BPLCON4_28		RS.L 1
cl1_ext1_BPLCON4_29		RS.L 1
cl1_ext1_BPLCON4_30		RS.L 1
cl1_ext1_BPLCON4_31		RS.L 1
cl1_ext1_BPLCON4_32		RS.L 1
cl1_ext1_BPLCON4_33		RS.L 1
cl1_ext1_BPLCON4_34		RS.L 1
cl1_ext1_BPLCON4_35		RS.L 1
cl1_ext1_BPLCON4_36		RS.L 1
cl1_ext1_BPLCON4_37		RS.L 1
cl1_ext1_BPLCON4_38		RS.L 1
cl1_ext1_BPLCON4_39		RS.L 1
cl1_ext1_BPLCON4_40		RS.L 1
cl1_ext1_BPLCON4_41		RS.L 1
cl1_ext1_BPLCON4_42		RS.L 1
cl1_ext1_BPLCON4_43		RS.L 1
cl1_ext1_BPLCON4_44		RS.L 1

cl1_extension1_size		RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_extension1_entry		RS.B cl1_extension1_size*cl1_display_y_size

cl1_WAIT1			RS.L 1
cl1_INTREQ			RS.L 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0


cl1_size1			EQU copperlist1_size
cl1_size2			EQU copperlist1_size
cl1_size3			EQU copperlist1_size

cl2_size1			EQU 0
cl2_size2			EQU 0
cl2_size3			EQU 0


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

em_color_table			RS.L ct_size
em_bplam_table			RS.B tccb_bplam_table_size
extra_memory_size		RS.B 0


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; Colorcycle
cc_color_table_start		RS.L 1

; Twisted-Colorcycle-Bars
tccb_y_angle			RS.W 1
tccb_y_radius_angle		RS.W 1

; Blind-Fader
	IFEQ open_border_enabled
bf_registers_table_start	RS.W 1

bfi_active			RS.W 1

bfo_active			RS.W 1
	ENDC

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_03_twisted_colorcycle_bars


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Colorcycle
	moveq	#0,d0
	move.l	d0,cc_color_table_start(a3)
	moveq	#FALSE,d1

; Twisted-Colorcycle-Bars
	move.w	d0,tccb_y_angle(a3)	; 0°
	move.w	d0,tccb_y_radius_angle(a3) ; 0°

; Blind-Fader
	IFEQ open_border_enabled
		move.w	d0,bf_registers_table_start(a3)

		move.w	d1,bfi_active(a3)

		move.w	d1,bfo_active(a3)
	ENDC

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	tccb_init_color_table
	IFEQ tccb_quick_clear_enabled
		IFNE 256-pf_colors_number
			bsr	init_colors
		ENDC
	ENDC
	bsr	tccb_init_mirror_bplam_table
	bra	init_first_copperlist


; Twisted-Colorcycle-Bars
	CNOP 0,4
tccb_init_color_table
	movem.l a4-a6,-(a7)
; vertikale Farbverläufe
	lea	tccb_color_gradient(pc),a0
	move.l	extra_memory(a3),a2	; Destination: Color table
	move.w	#color_x_values_number*segments_number*LONGWORD_SIZE,a4
	move.w	#color_x_values_number*1*LONGWORD_SIZE,a5
	moveq	#segments_number-1,d7
tccb_init_color_table_loop1
	move.l	a2,a1			; color table
	moveq	#color_y_values_number-1,d6
tccb_init_color_table_loop2
	move.l	(a0)+,(a1)		; copy RGB8
	add.l	a4,a1			; next line in color table
	dbf	d6,tccb_init_color_table_loop2
	add.l	a5,a2			; next segment
	dbf	d7,tccb_init_color_table_loop1
	INIT_COLOR_GRADIENTS_RGB8 color_x_values_number,tccb_bar_height/2,segments_number,color_x_step,extra_memory,a3,0,1
	movem.l (a7)+,a4-a6
	rts


	IFEQ tccb_quick_clear_enabled
		IFNE pf_colors_number-256
init_colors
			CPU_SELECT_COLOR_HIGH_BANK 7,bplcon3_bits3
			CPU_INIT_COLOR_HIGH COLOR31,1,pf1_rgb8_color_table
			CPU_SELECT_COLOR_LOW_BANK 7,bplcon3_bits4
			CPU_INIT_COLOR_LOW COLOR31,1,pf1_rgb8_color_table
			rts
		ENDC
	ENDC

	INIT_MIRROR_BPLAM_TABLE.B tccb,1,1,tccb_bars_number,color_y_values_number,extra_memory,a3,em_bplam_table


	CNOP 0,4
init_first_copperlist
	move.l	cl1_construction1(a3),a0 
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_colors
	IFEQ open_border_enabled
		bsr	cl1_init_bplcon4_chunky
		bsr	cl1_init_copper_interrupt
		COP_LISTEND
	ELSE
		bsr	cl1_init_bitplane_pointers
		bsr	cl1_init_bplcon4_chunky
		bsr	cl1_init_copper_interrupt
		COP_LISTEND
		bsr	cl1_set_bitplane_pointers
	ENDC
	bra	copy_first_copperlist
	
	IFEQ open_border_enabled
		COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES
	ELSE
		COP_INIT_PLAYFIELD_REGISTERS cl1
		COP_INIT_BITPLANE_POINTERS cl1
		COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
	ENDC


	CNOP 0,4
cl1_init_colors
	COP_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
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
	COP_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
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


	COP_INIT_BPLCON4_CHUNKY cl1,cl1_hstart1,cl1_vstart1,cl1_display_x_size,cl1_display_y_size,open_border_enabled,tccb_quick_clear_enabled,FALSE,NOOP<<16


	COP_INIT_COPINT cl1,cl1_hstart2,cl1_vstart2


	COPY_COPPERLIST cl1,3


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
	bsr.s	swap_first_copperlist
	bsr.s	set_first_copperlist
	bsr	effects_handler
	bsr	tccb_clear_first_copperlist
	bsr	colorcycle
	bsr	twisted_colorcycle_bars
	IFNE tccb_quick_clear_enabled
		bsr	tccb_restore_first_copperlist
	ENDC
	IFEQ open_border_enabled
		bsr	blind_fader_in
		bsr	blind_fader_out
	ENDC
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s	beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl1,3


	SET_COPPERLIST cl1


	CLEAR_BPLCON4_CHUNKY tccb,cl1,construction1,extension1,quick_clear_enabled


	CNOP 0,4
colorcycle
	movem.l a4-a6,-(a7)
	move.l	cc_color_table_start(a3),d3
	move.l	d3,d0		
	addq.l	#cc_speed,d0		; next entry
	cmp.l	#color_x_values_number*segments_number,d0
	blt.s	colorcycle_skip1
	sub.l	#color_x_values_number*segments_number,d0 ; reset table start
colorcycle_skip1
	move.l	d0,cc_color_table_start(a3)
	move.w	#RB_NIBBLES_MASK,d4
	moveq	#1<<3,d5		; color registers counter
	move.l	extra_memory(a3),a1	; color table
	move.l	cl1_construction2(a3),a2 
	ADDF.W	cl1_COLOR01_high1+WORD_SIZE,a2
	move.w	#(color_x_values_number*segments_number)*LONGWORD_SIZE,a4
	move.w	#cc_step,a5
	move.w	#color_x_values_number*segments_number,a6 ; reset
	moveq	#tccb_bars_number-1,d7
colorcycle_loop1
	lea	(a1,d3.l*4),a0		; color table offset
	moveq	#(tccb_bar_height/2)-1,d6
colorcycle_loop2
	move.l	(a0),d0			; RGB8
	move.l	d0,d2		
	RGB8_TO_RGB4_HIGH d0,d1,d4
	move.w	d0,(a2)			; color high
	RGB8_TO_RGB4_LOW d2,d1,d4
	move.w	d2,cl1_COLOR01_low1-cl1_COLOR01_high1(a2) ; color low
	add.l	a4,a0			; next line in coor table
	addq.w	#LONGWORD_SIZE,a2	; next color register
	addq.b	#1<<3,d5		; increment color register counter
	bne.s	colorcycle_skip2
	addq.w	#LONGWORD_SIZE,a2	; skip CMOVE
colorcycle_skip2
	dbf	d6,colorcycle_loop2
	sub.l	a5,d3			; next entry
	bge.s	colorcycle_skip3
	add.l	a6,d3			; reset table start
colorcycle_skip3
	dbf	d7,colorcycle_loop1
	movem.l (a7)+,a4-a6
	rts

	CNOP 0,4
twisted_colorcycle_bars
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)	
	move.w	tccb_y_radius_angle(a3),d4
	move.w	d4,d0		
	MOVEF.W sine_table_length-1,d7	; overflow 360°
	addq.w	#tccb_y_radius_angle_speed,d0
	move.w	tccb_y_angle(a3),d5
	and.w	d7,d0			; remove oeverflow
	move.w	d0,tccb_y_radius_angle(a3) 
	move.w	d5,d0		
	addq.w	#tccb_y_angle_speed,d0
	and.w	d7,d0			; remove overflow
	move.w	d0,tccb_y_angle(a3) 
	lea	sine_table_512(pc),a0 
	move.l	cl1_construction2(a3),a2 
	ADDF.W cl1_extension1_entry+cl1_ext1_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5
	move.w	#tccb_y_distance,a3
	add.l	#em_bplam_table,a5	; BPLAM table
	move.w	#tccb_y_center,a6
	move.w	d5,a7		
	swap	d7 			; high word: overflow
	move.w	#cl1_display_width-1,d7	; low word: loop counter
tccb_get_y_coordinates_loop1
	move.l	a5,a1			; BBPLAM table
	swap	d7		 	; low word: overflow
	moveq	#tccb_bars_number-1,d6
tccb_get_y_coordinates_loop2
	move.l	(a0,d4.w*4),d0		; sin(w)
	MULUF.L tccb_y_radius*4,d0,d1	; yr'=(yr*sin(w))/2^15
	swap	d0
	muls.w	WORD_SIZE(a0,d5.w*4),d0	; y'=(yr'*sin(w))/2^15
	swap	d0
	add.w	a6,d0			; y' + y center
	MULUF.W cl1_extension1_size/4,d0,d1 ; y offset in cl
	lea	(a2,d0.w*4),a4
	movem.l (a1)+,d0-d3		; fetch 16x BPLAM
	move.b	d0,cl1_extension1_size*3(a4) ; BPLCON4 high
	swap	d0
	move.b	d0,cl1_extension1_size*1(a4)
	lsr.l	#8,d0
	move.b	d0,(a4)
	swap	d0
	move.b	d0,cl1_extension1_size*2(a4)
	move.b	d1,cl1_extension1_size*7(a4)
	swap	d1
	move.b	d1,cl1_extension1_size*5(a4)
	lsr.l	#8,d1
	move.b	d1,cl1_extension1_size*4(a4)
	swap	d1
	move.b	d1,cl1_extension1_size*6(a4)
	move.b	d2,cl1_extension1_size*11(a4)
	swap	d2
	move.b	d2,cl1_extension1_size*9(a4)
	lsr.l	#8,d2
	move.b	d2,cl1_extension1_size*8(a4)
	swap	d2
	move.b	d2,cl1_extension1_size*10(a4)
	addq.w	#tccb_y_radius_angle_step,d4
	move.b	d3,cl1_extension1_size*15(a4)
	swap	d3
	move.b	d3,cl1_extension1_size*13(a4)
	lsr.l	#8,d3
	move.b	d3,cl1_extension1_size*12(a4)
	swap	d3
	move.b	d3,cl1_extension1_size*14(a4)
	movem.l (a1)+,d0-d3		; fetch 16x BPLAM
	move.b	d0,cl1_extension1_size*19(a4)
	swap	d0
	move.b	d0,cl1_extension1_size*17(a4)
	lsr.l	#8,d0
	move.b	d0,cl1_extension1_size*16(a4)
	swap	d0
	move.b	d0,cl1_extension1_size*18(a4)
	and.w	d7,d4			; remove overflow
	move.b	d1,cl1_extension1_size*23(a4)
	swap	d1
	move.b	d1,cl1_extension1_size*21(a4)
	lsr.l	#8,d1
	move.b	d1,cl1_extension1_size*20(a4)
	swap	d1
	move.b	d1,cl1_extension1_size*22(a4)
	add.w	a3,d5			; y distance to next bar
	move.b	d2,cl1_extension1_size*27(a4)
	swap	d2
	move.b	d2,cl1_extension1_size*25(a4)
	lsr.l	#8,d2
	move.b	d2,cl1_extension1_size*24(a4)
	swap	d2
	move.b	d2,cl1_extension1_size*26(a4)
	and.w	d7,d5			; remove overflow
	move.b	d3,cl1_extension1_size*31(a4)
	swap	d3
	move.b	d3,cl1_extension1_size*29(a4)
	lsr.l	#8,d3
	move.b	d3,cl1_extension1_size*28(a4)
	swap	d3
	move.b	d3,cl1_extension1_size*30(a4)
	dbf	d6,tccb_get_y_coordinates_loop2
	move.w	a7,d5			; y angle
	addq.w	#tccb_y_angle_step,d5	; next column
	and.w	d7,d5			; remove overflow
	move.w	d5,a7		
	swap	d7		 	; low word: loop counter
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	dbf	d7,tccb_get_y_coordinates_loop1
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	IFNE tccb_quick_clear_enabled
		RESTORE_BPLCON4_CHUNKY tccb,cl1,construction2,extension1,32
	ENDC


	IFEQ open_border_enabled
		CNOP 0,4
blind_fader_in
		move.l	a4,-(a7)
		tst.w	bfi_active(a3)
		bne.s	blind_fader_in_quit
		move.w	bf_registers_table_start(a3),d2
		move.w	d2,d0
		addq.w	#bf_speed,d0	; increase table start
		cmp.w	#bf_registers_table_length/WORD_SIZE,d0 ; end of table ?
		ble.s	blind_fader_in_skip1
		move.w	#FALSE,bfi_active(a3)
blind_fader_in_skip1
		move.w	d0,bf_registers_table_start(a3)
		MOVEF.W bf_registers_table_length,d3
		MOVEF.W cl1_extension1_size,d4
		lea	bf_registers_table(pc),a0
		IFNE cl1_size1
			move.l	cl1_construction1(a3),a1
			ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a1
		ENDC
		IFNE cl1_size2
			move.l	cl1_construction2(a3),a2
			ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a2
		ENDC
		move.l	cl1_display(a3),a4
		ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a4
		moveq	#bf_lamellas_number-1,d7
blind_fader_in_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_in_loop2
		move.w	(a0,d1.w*2),d0	; register address
		IFNE cl1_size1
			move.w	d0,(a1)
			add.l	d4,a1	; next line in cl
		ENDC
		IFNE cl1_size2
			move.w	d0,(a2)
			add.l	d4,a2	; next line in cl
		ENDC
		move.w	d0,(a4)
		addq.w	#bf_step1,d1	; next entry
		add.l	d4,a4		; next line in cl
		cmp.w	d3,d1		; end of table ?
		blt.s	blind_fader_in_skip2
		sub.w	d3,d1		; reset table start
blind_fader_in_skip2
		dbf	d6,blind_fader_in_loop2
		addq.w	#bf_step2,d2	; increase table start
		cmp.w	d3,d2		; end of table ?
		blt.s	blind_fader_in_skip3
		sub.w	d3,d2		; reset table start
blind_fader_in_skip3
		dbf	d7,blind_fader_in_loop1
blind_fader_in_quit
		move.l	(a7)+,a4
		rts


		CNOP 0,4
blind_fader_out
		move.l	a4,-(a7)
		tst.w	bfo_active(a3)
		bne.s	blind_fader_out_quit
		move.w	bf_registers_table_start(a3),d2
		move.w	d2,d0
		subq.w	#bf_speed,d0	; decrease table start
		bpl.s	blind_fader_out_skip1
		move.w	#FALSE,bfo_active(a3)
blind_fader_out_skip1
		move.w	d0,bf_registers_table_start(a3)
		MOVEF.W bf_registers_table_length,d3
		MOVEF.W cl1_extension1_size,d4
		moveq	#bf_step2,d5
		lea	bf_registers_table(pc),a0
		IFNE cl1_size1
			move.l	cl1_construction1(a3),a1
			ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a1
		ENDC
		IFNE cl1_size2
			move.l	cl1_construction2(a3),a2
			ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a2
		ENDC
		move.l	cl1_display(a3),a4
		ADDF.W	cl1_extension1_entry+cl1_ext1_BPL1DAT,a4
		moveq	#bf_lamellas_number-1,d7
blind_fader_out_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_out_loop2
		move.w	(a0,d1.w*2),d0	; register address
		IFNE cl1_size1
			move.w	d0,(a1)
			add.l	d4,a1	; next line in cl
		ENDC
		IFNE cl1_size2
			move.w	d0,(a2)
			add.l	d4,a2	; next line in cl
		ENDC
		move.w	d0,(a4)
		addq.w	#bf_step1,d1	; next entry
		add.l	d4,a4		; next line in cl
		cmp.w	d3,d1		; end of table ?
		blt.s	blind_fader_out_skip2
		sub.w	d3,d1		; reset table start
blind_fader_out_skip2
		dbf	d6,blind_fader_out_loop2
		add.w	d5,d2		; increase table start
		cmp.w	d3,d2		; end of table ?
		blt.s	blind_fader_out_skip3
		sub.w	d3,d2		; reset table start
blind_fader_out_skip3
		dbf	d7,blind_fader_out_loop1
blind_fader_out_quit
		move.l	(a7)+,a4
		rts
	ENDC


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
	beq.s	eh_start_blind_fader_in
	subq.w	#1,d0
	beq.s	eh_start_blind_fader_out
	subq.w	#1,d0
	beq.s	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_blind_fader_in
	clr.w	bfi_active(a3)
	rts
	CNOP 0,4
eh_start_blind_fader_out
	clr.w	bfo_active(a3)
	rts
	CNOP 0,4
eh_stop_all
	clr.w	stop_fx_active(a3)
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits
	DS.L pf1_colors_number-1


	CNOP 0,4
sine_table_512
	INCLUDE "sine-table-512x32.i"


; Twisted-Colorcycle-Bars
	CNOP 0,4
tccb_color_gradient
	INCLUDE "RasterMaster:colortables/04_tcb_Colorgradient.ct"


; Blind-Fader
	IFEQ open_border_enabled
; Tabelle mit Registeradressen
		CNOP 0,2
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
