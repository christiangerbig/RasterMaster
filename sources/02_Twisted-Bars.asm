; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF color00_high_bits
	XREF color00_low_bits
	XREF mouse_handler
	XREF sine_table

	XDEF start_02_twisted_bars


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

; Twisted-Bars
tb_quick_clear_enabled		EQU TRUE

	IFEQ open_border_enabled
dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_SETCLR
	ELSE
dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|MAF_SETCLR
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
pf1_colors_number		EQU 0	; 193

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

; Twisted-Sine-Bars3.1.5
tb315_bars_number		EQU 4
tb315_bar_height		EQU 48
tb315_y_radius			EQU (cl2_display_y_size-80-tb315_bar_height)/2
tb315_y_center			EQU (cl2_display_y_size-80-tb315_bar_height)/2
tb315_y_angle_speed		EQU 3
tb315_y_angle_speed2		EQU 2
tb315_y_angle_step		EQU 2
tb315_y_distance		EQU sine_table_length/tb315_bars_number

; Wave-Effect
we_y_radius			EQU 80
we_y_center			EQU 40
we_y_radius_angle_speed		EQU 4
we_y_radius_angle_step		EQU 8
we_y_angle_speed		EQU 4
we_y_angle_step			EQU 2

; Clear-Blit
tb_clear_blit_x_size		EQU 16
	IFEQ open_border_enabled
tb_clear_blit_y_size		EQU cl2_display_y_size*(cl2_display_width+2)
	ELSE
tb_clear_blit_y_size		EQU cl2_display_y_size*(cl2_display_width+1)
	ENDC

; Restore-Blit
tb_restore_blit_x_size		EQU 16
tb_restore_blit_width		EQU tb_restore_blit_x_size/8
tb_restore_blit_y_size		EQU cl2_display_y_size

; Blind-Fader
bf_lamella_height		EQU 16
bf_lamellas_number		EQU cl2_display_y_size/bf_lamella_height
bf_step1			EQU 1
bf_step2			EQU 1
bf_speed			EQU 2

bf_registers_table_length	EQU bf_lamella_height*4

; Effects-Handler
eh_trigger_number_max		EQU 3


color_step1			EQU 256/(tb315_bar_height/2)
color_values_number1		EQU tb315_bar_height/2
segments_number1		EQU tb315_bars_number*2

ct_size1			EQU color_values_number1*segments_number1

tb315_bplam_table_size		EQU ct_size1*BYTE_SIZE

extra_memory_size		EQU tb315_bplam_table_size*BYTE_SIZE


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

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; Twisted-Bars3.1.5
tb315_y_angle			RS.W 1
tb315_y_angle_speed_angle RS.W 1

; Wave-Effect
we_y_radius_angle		RS.W 1
we_y_angle			RS.W 1

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


	SECTION	code,CODE


start_02_twisted_bars


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Twisted-Bars3.1.5
	moveq	#TRUE,d0
	move.w	d0,tb315_y_angle(a3)
	moveq	#FALSE,d1
	move.w	d0,tb315_y_angle_speed_angle(a3) ; 0°

; Wave-Effect
	move.w	d0,we_y_radius_angle(a3) ; 0 °
	move.w	d0,we_y_angle(a3)	; 0 °

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
	bsr	init_colors
	bsr	tb315_init_bplam_table
	bsr	init_first_copperlist
	bra	init_second_copperlist


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
	CPU_INIT_COLOR_HIGH COLOR00,1

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
	CPU_INIT_COLOR_LOW COLOR00,1

	IFEQ tb_quick_clear_enabled
		CPU_SELECT_COLOR_HIGH_BANK 7,bplcon3_bits3
		CPU_INIT_COLOR_HIGH COLOR31,1,pf1_rgb8_color_table
		CPU_SELECT_COLOR_LOW_BANK 7,bplcon3_bits4
		CPU_INIT_COLOR_LOW COLOR31,1,pf1_rgb8_color_table
	ENDC
	rts


; Twisted-Bars
	INIT_bplam_table.B tb315,1,1,color_values_number1*segments_number1,extra_memory,a3


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0 
	bsr.s	cl1_init_playfield_props
	IFEQ open_border_enabled
		COP_MOVEQ 0,COPJMP2
		rts
	ELSE
		bsr.s	cl1_init_bitplane_pointers
		COP_MOVEQ 0,COPJMP2
		bra	cl1_set_bitplane_pointers
	ENDC

	IFEQ open_border_enabled
		COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANES
	ELSE
		COP_INIT_PLAYFIELD_REGISTERS cl1
		COP_INIT_BITPLANE_POINTERS cl1
		COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
	ENDC


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction1(a3),a0 
	bsr.s	cl2_init_bplcon4_chunky
	bsr.s	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bra	set_second_copperlist


	COP_INIT_BPLCON4_CHUNKY cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,tb_quick_clear_enabled,FALSE,NOOP<<16


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
	bsr	effects_handler
	bsr	tb_clear_second_copperlist
	bsr	tb315_get_yz_coordinates
	bsr	we_get_y_coordinates
	bsr	tb315_set_background_bars
	bsr	tb315_set_foreground_bars
	IFNE tb_quick_clear_enabled
		bsr	tb_restore_second_copperlist
	ENDC
	IFEQ open_border_enabled
		bsr	blind_fader_in
		bsr	blind_fader_out
	ENDC
	bsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s   beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,3


	SET_COPPERLIST cl2


	CLEAR_BPLCON4_CHUNKY tb,cl2,construction1,extension1,quick_clear_enabled


; Twisted-Bars3.1.5
	CNOP 0,4
tb315_get_yz_coordinates
	move.w	tb315_y_angle_speed_angle(a3),d1
	move.w	d1,d0
	addq.b	#tb315_y_angle_speed2,d0
	move.w	d0,tb315_y_angle_speed_angle(a3)
	lea	sine_table(pc),a0 
	move.l	(a0,d1.w*4),d1		; sin(w)
	MULUF.L tb315_y_angle_speed*2,d1,d0 ; y' = (yr*sin(w))/2^15
	swap	d1
	move.w	tb315_y_angle(a3),d2	; 1st y angle
	move.w	d2,d0		
	add.b	d1,d0			; next y angle
	move.w	d0,tb315_y_angle(a3)	
	moveq	#tb315_y_distance,d3
	lea	tb315_yz_coordinates(pc),a1
	move.w	#tb315_y_center,a2
	moveq	#cl2_display_width-1,d7
tb315_get_yz_coordinates_loop1
	moveq	#tb315_bars_number-1,d6
tb315_get_yz_coordinates_loop2
	move.l	(a0,d2.w*4),d0		; sin(w)
	moveq	#-(sine_table_length/4),d1 ; - 90°
	add.w	d2,d1			; y angle - 90°
	ext.w	d1
	move.w	d1,(a1)+		; z vector
	MULUF.L tb315_y_radius*2,d0,d1	; y' = (yr*sin(w))/2^15
	swap	d0
	add.w	a2,d0			; y' + y center
	MULUF.W cl2_extension1_size/4,d0,d1 ; y offset in cl
	move.w	d0,(a1)+
	add.b	d3,d2			; y distance to next bar
	dbf	d6,tb315_get_yz_coordinates_loop2
	addq.b	#tb315_y_angle_step,d2
	dbf	d7,tb315_get_yz_coordinates_loop1
	rts


; Wave-Effect
	CNOP 0,4
we_get_y_coordinates
	move.w	we_y_radius_angle(a3),d2 ; 1st y radius angle
	move.w	d2,d0		
	move.w	we_y_angle(a3),d3	; 1st y angle
	addq.b	#we_y_radius_angle_speed,d0
	move.w	d0,we_y_radius_angle(a3) 
	move.w	d3,d0
	addq.b	#we_y_angle_speed,d0
	move.w	d0,we_y_angle(a3)	
	lea	sine_table(pc),a0 
	lea	we_y_coordinates(pc),a1
	move.w	#we_y_center,a2
	moveq	#cl2_display_width-1,d7 ; number of columns
we_get_y_coordinates_loop
	move.l	(a0,d2.w*4),d0	;sin(w)
	MULUF.L we_y_radius*2,d0,d1
	swap	d0			; yr' = (yr*sin(w))/2^15
	muls.w	WORD_SIZE(a0,d3.w*4),d0	; y' = (yr'*sin(w))/2^15
	swap	d0
	add.w	a2,d0			; y' + y center
	addq.b	#we_y_radius_angle_step,d2
	MULUF.W cl2_extension1_size/4,d0,d1 ; y offset in cl
	move.w	d0,(a1)+
	addq.b	#we_y_angle_step,d3
	dbf	d7,we_get_y_coordinates_loop
	rts


	CNOP 0,4
tb315_set_background_bars
	movem.l a3-a6,-(a7)
	moveq	#tb315_bar_height,d4
	lea	tb315_yz_coordinates(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5	; BPLAM table
	lea	we_y_coordinates(pc),a6
	moveq	#cl2_display_width-1,d7	; number of columns
tb315_set_background_bars_loop1
	move.w	(a6)+,d0		; 2nd y offset
	move.l	a5,a1			; BPLAM table
	lea	(a2,d0.w*4),a3		; add 2nd y offset
	moveq	#tb315_bars_number-1,d6
tb315_set_background_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bpl.s	tb315_set_background_bars_skip1
	add.l	d4,a1			; skip BPLAM values
	bra	tb315_set_background_bars_skip2
	CNOP 0,4
tb315_set_background_bars_skip1
	lea	(a3,d0.w*4),a4		; add 1st y offset
	COPY_TWISTED_BAR.B tb315,cl2,extension1,bar_height
tb315_set_background_bars_skip2
	dbf	d6,tb315_set_background_bars_loop2
	addq.w	#LONGWORD_SIZE,a2	; next column
	dbf	d7,tb315_set_background_bars_loop1
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
tb315_set_foreground_bars
	movem.l a3-a6,-(a7)
	moveq	#tb315_bar_height,d4
	lea	tb315_yz_coordinates(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE,a2
	move.l	extra_memory(a3),a5	; BPLAM table
	lea	we_y_coordinates(pc),a6
	moveq	#cl2_display_width-1,d7	; number of columns
tb315_set_foreround_bars_loop1
	move.w	(a6)+,d0		; 2nd y offset
	move.l	a5,a1			; BPLAM table
	lea	(a2,d0.w*4),a3		; add 2nd y offset
	moveq	#tb315_bars_number-1,d6
tb315_set_foreround_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bmi.s	tb315_set_foreround_bars_skip1
	add.l	d4,a1			; skip BPLAM values
	bra	tb315_set_foreround_bars_skip2
	CNOP 0,4
tb315_set_foreround_bars_skip1
	lea	(a3,d0.w*4),a4		; add 1st y offset
	COPY_TWISTED_BAR.B tb315,cl2,extension1,bar_height
tb315_set_foreround_bars_skip2
	dbf	d6,tb315_set_foreround_bars_loop2
	addq.w	#4,a2			; next column
	dbf	d7,tb315_set_foreround_bars_loop1
	movem.l (a7)+,a3-a6
	rts


	IFNE tb_quick_clear_enabled
		RESTORE_BPLCON4_CHUNKY tb,cl2,construction2,extension1,32
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
		cmp.w	#bf_registers_table_length/2,d0 ; end of table ?
		ble.s	blind_fader_in_skip1
		move.w	#FALSE,bfi_active(a3)
blind_fader_in_skip1
		move.w	d0,bf_registers_table_start(a3)
		MOVEF.W bf_registers_table_length,d3
		MOVEF.W cl2_extension1_size,d4
		lea	bf_registers_table(pc),a0
		IFNE cl2_size1
			move.l	cl2_construction1(a3),a1
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
		ENDC
		IFNE cl2_size2
			move.l	cl2_construction2(a3),a2
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
		ENDC
		move.l	cl2_display(a3),a4
		ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
		moveq	#bf_lamellas_number-1,d7
blind_fader_in_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_in_loop2
		move.w	(a0,d1.w*2),d0	; register address
		IFNE cl2_size1
			move.w	d0,(a1)
			add.l	d4,a1	; next line
		ENDC
		IFNE cl2_size2
			move.w	d0,(a2)
			add.l	d4,a2	; next line
		ENDC
		move.w	d0,(a4)
		addq.w	#bf_step1,d1	; next entry
		add.l	d4,a4		; next line
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
		MOVEF.W cl2_extension1_size,d4
		moveq	#bf_step2,d5
		lea	bf_registers_table(pc),a0
		IFNE cl2_size1
			move.l	cl2_construction1(a3),a1
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
		ENDC
		IFNE cl2_size2
			move.l	cl2_construction2(a3),a2
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
		ENDC
		move.l	cl2_display(a3),a4
		ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
		moveq	#bf_lamellas_number-1,d7
blind_fader_out_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_out_loop2
		move.w	(a0,d1.w*2),d0	; register address
		IFNE cl2_size1
			move.w	d0,(a1)
			add.l	d4,a1	; next line
		ENDC
		IFNE cl2_size2
			move.w	d0,(a2)
			add.l	d4,a2	; next line
		ENDC
		move.w	d0,(a4)
		addq.w	#bf_step1,d1	; next entry
		add.l	d4,a4		; next line
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
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	INCLUDE "RasterMaster:colortables/03_tb_Colorgradient.ct"


; Twisted-Bars3.1.5
	CNOP 0,4
tb315_yz_coordinates
	DS.W tb315_bars_number*cl2_display_width*2


; Wave-Effect
	CNOP 0,2
we_y_coordinates
	DS.W cl2_display_width


; Blind-Fader
	IFEQ open_border_enabled
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
