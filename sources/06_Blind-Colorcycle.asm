; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF mouse_handler
	XREF sine_table

	XDEF start_06_blind_colorcycle


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

bcc512_bplam_table_length_256	EQU TRUE
bcc514_bplam_table_length_256	EQU TRUE

	IFEQ open_border_enabled
dma_bits			EQU DMAF_COPPER|DMAF_SETCLR
	ELSE
dma_bits			EQU DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR
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
pf1_colors_number		EQU 0	; 129

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

pf_pixel_per_datafetch		EQU 32	; 2x

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

; Blind-Colorcycle5.1.2
bcc512_bar_height		EQU 64
bcc512_bars_number		EQU 4
bcc512_lamella_height		EQU 16
bcc512_lamellas_number		EQU visible_lines_number/bcc512_lamella_height
bcc512_step1			EQU 1
bcc512_step2			EQU 1
bcc512_step3_min		EQU 1
bcc512_step3_max		EQU 16
bcc512_step3			EQU bcc512_step3_max-bcc512_step3_min
bcc512_step3_radius		EQU bcc512_step3
bcc512_step3_center		EQU bcc512_step3+bcc512_step3_min
bcc512_step3_angle_speed	EQU 2
bcc512_speed			EQU 1

; Blind-Colorcycle5.1.4
bcc514_bar_height		EQU 64
bcc514_bars_number		EQU 4
bcc514_lamella_height		EQU 16
bcc514_lamellas_number		EQU visible_lines_number/bcc514_lamella_height
bcc514_step1			EQU 2
bcc514_step2_min		EQU 0
bcc514_step2_max		EQU 8
bcc514_step2			EQU bcc514_step2_max-bcc514_step2_min
bcc514_step2_radius		EQU bcc514_step2
bcc514_step2_center		EQU bcc514_step2+bcc514_step2_min
bcc514_step2_angle_speed	EQU 1
bcc514_step2_angle_step		EQU 4
bcc514_speed			EQU 2

; Blind-Fader
bf_lamella_height		EQU 16
bf_lamellas_number		EQU visible_lines_number/bf_lamella_height
bf_step1			EQU 1
bf_step2			EQU 1
bf_speed			EQU 2

bf_registers_table_length	EQU bf_lamella_height*4

; Effects-Handler
eh_trigger_number_max		EQU 5

color_step1			EQU 256/(bcc512_bar_height/2)
color_values_number1		EQU bcc512_bar_height/2
segments_number1		EQU bcc512_bars_number

ct_size1			EQU color_values_number1*segments_number1

bcc_bplam_table_size		EQU ct_size1*2

extra_memory_size		EQU bcc_bplam_table_size*BYTE_SIZE


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

cl2_size1			EQU 0
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

; Blind-Colorcycle5.1.2
bcc512_active			RS.W 1
bcc512_bplam_table_start	RS.W 1
bcc512_step3_angle		RS.W 1

; Blind-Colorcycle5.1.4
bcc514_active			RS.W 1
bcc514_bplam_table_start	RS.W 1
bcc514_step2_angle		RS.W 1

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


start_06_blind_colorcycle


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Blind-Colorcycle5.1.2
	moveq	#FALSE,d1
	move.w	d1,bcc512_active(a3)
	moveq	#0,d0
	move.w	d0,bcc512_bplam_table_start(a3)
	move.w	#sine_table_length/4,bcc512_step3_angle(a3) ; 90°

; Blind-Colorcycle5.1.4
	move.w	d1,bcc514_active(a3)
	move.w	d0,bcc514_bplam_table_start(a3)
	move.w	d0,bcc514_step2_angle(a3) ; 0 °

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
	bsr	bcc_init_mirror_bplam_table
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
	CPU_INIT_COLOR_LOW COLOR00,1
	rts


; Blind-Colorcycle
	INIT_MIRROR_BPLAM_TABLE.B bcc,1,1,segments_number1,color_values_number1,extra_memory,a3


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
	move.l	cl2_construction2(a3),a0 
	bsr.s	cl2_init_bplcon4_chunky
	bsr.s	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bra	set_second_copperlist


	COP_INIT_BPLCON4_CHUNKY cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE,NOOP<<16


	COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2


	COPY_COPPERLIST cl2,2


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
	bsr	blind_colorcycle512
	bsr	blind_colorcycle514
	IFEQ open_border_enabled
		bsr	blind_fader_in
		bsr	blind_fader_out
	ENDC
	jsr	mouse_handler
	tst.l	d0			; exit ?
	bne.s	beam_routines_exit
	tst.w	stop_fx_active(a3)
	bne.s	beam_routines
beam_routines_exit
	move.w	custom_error_code(a3),d1
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	CNOP 0,4
blind_colorcycle512
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)	
	tst.w	bcc512_active(a3)
	bne	blind_colorcycle512_quit
	move.w	bcc512_step3_angle(a3),d1
	move.w	d1,d0		
	addq.b	#bcc512_step3_angle_speed,d0
	move.w	d0,bcc512_step3_angle(a3)
	lea	sine_table,a0	
	move.l	(a0,d1.w*4),d4		; cos(w)
	MULUF.L bcc512_step3_radius*2,d4,d0 ; r'=r*cow(w)/2^15
	swap	d4
	ADDF.W	bcc512_step3_center,d4
	move.w	bcc512_bplam_table_start(a3),d3
	move.w	d3,d0		
	IFEQ bcc512_bplam_table_length_256
		addq.b	#bcc512_speed,d0
	ELSE
		MOVEF.W bcc512_bplam_table_size-1,d7 ; overflow
		addq.w	#bcc512_speed,d0 ; increase table start
		and.w	d7,d0		; remove overflow
	ENDC
	move.w	d0,bcc512_bplam_table_start(a3) 
	move.l	extra_memory(a3),a0	; BPLAM table
	move.l	cl2_construction2(a3),a1 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE+(((cl2_display_width/2)-1)*LONGWORD_SIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ; 2nd quadrant
	lea	LONGWORD_SIZE(a1),a2	; 1st quadrant
	move.w	#(cl2_extension1_size*(bcc512_lamellas_number/2)*bcc512_lamella_height)-LONGWORD_SIZE,a3
	lea	cl2_extension1_size(a1),a4 ; 3rd quadrant
	lea	cl2_extension1_size(a2),a5 ; 4th quadrant
	move.w	#cl2_extension1_size,a6
	move.w	#(cl2_extension1_size*(bcc512_lamellas_number/2)*bcc512_lamella_height)+4,a7
	IFEQ bcc512_bplam_table_length_256
		moveq	#(cl2_display_width/2)-1,d7 ; number of columns
	ELSE
		swap	d7 		; high word: overflow
		move.w	#(cl2_display_width/2)-1,d7 ; low word: loop counter
	ENDC
blind_colorcycle512_loop1
	move.w	d3,d2			; table start
	IFNE bcc512_bplam_table_length_256
		swap	d7
	ENDC
	moveq	#(bcc512_lamellas_number/2)-1,d6
blind_colorcycle512_loop2
	move.w	d2,d1			; table start
	moveq	#bcc512_lamella_height-1,d5
blind_colorcycle512_loop3
	move.b	(a0,d1.w),d0		; BPLAM
	move.b	d0,(a1)			; BPLCON4 high
	sub.l	a6,a1			; 2nd quadrant penultimate line in cl
	move.b	d0,(a2)			; BPLCON4 high
	sub.l	a6,a2			; 1st quadrant penultimate line in cl
	move.b	d0,(a4)			; BPLCON4 high
	add.l	a6,a4			; 3rd quadrant next line in cl
	move.b	d0,(a5)			; BPLCON4 high
	IFEQ bcc512_bplam_table_length_256
		subq.b	#bcc512_step1,d1 ; next entry
	ELSE
		subq.w	#bcc512_step1,d1 ; next entry
		and.w	d7,d1		; remove overflow
	ENDC
	add.l	a6,a5			; 4th quadrant next line in cl
	dbf	d5,blind_colorcycle512_loop3
	IFEQ bcc512_bplam_table_length_256
		subq.b	#bcc512_step2,d2 ; next entry
	ELSE
		subq.w	#bcc512_step2,d2 ; next entry
		and.w	d7,d2		; remove overflow
	ENDC
	dbf	d6,blind_colorcycle512_loop2
	IFEQ bcc512_bplam_table_length_256
		sub.b	d4,d3		; next entry
	ELSE
		sub.w	d4,d3		; next entry
		and.w	d7,d3		; remove overflow
		swap	d7
	ENDC
	add.l	a3,a1			; 2nd quadrant penultimate column
	add.l	a7,a2			; 1st quadrant next column
	sub.l	a7,a4			; 3rd quadrant penultimate column
	sub.l	a3,a5			; 4th quadrant next column
	dbf	d7,blind_colorcycle512_loop1
blind_colorcycle512_quit
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
blind_colorcycle514
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)	
	tst.w	bcc514_active(a3)
	bne	blind_colorcycle514_quit
	move.w	bcc514_step2_angle(a3),d4
	move.w	d4,d0
	move.w	bcc514_bplam_table_start(a3),d3
	addq.b	#bcc514_step2_angle_speed,d0
	move.w	d0,bcc514_step2_angle(a3)
	move.w	d3,d0		
	IFEQ bcc514_bplam_table_length_256
		addq.b	#bcc514_speed,d0
	ELSE
		MOVEF.W bcc514_bplam_table_size-1,d7 ; overflow
		addq.w	#bcc514_speed,d0 ; increase table start
		and.w	d7,d0		; remove overflow
	ENDC
	move.w	d0,bcc514_bplam_table_start(a3) 
	move.l	extra_memory(a3),a0	; BPLAM table
	move.l	cl2_construction2(a3),a1 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE+(((cl2_display_width/2)-1)*LONGWORD_SIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ; 2nd quadrant
	lea	LONGWORD_SIZE(a1),a2	; 1st quadrant
	lea	sine_table,a3
	lea	cl2_extension1_size(a1),a4 ; 3rd quadrant
	lea	cl2_extension1_size(a2),a5 ; 4th quadrant
	move.w	#cl2_extension1_size,a6
	move.w	#(cl2_extension1_size*(bcc514_lamellas_number/2)*bcc514_lamella_height)+4,a7
	IFEQ bcc514_bplam_table_length_256
		moveq	#(cl2_display_width/2)-1,d7 ; number of columns
	ELSE
		swap	d7
		move.w	#(cl2_display_width/2)-1,d7 ; number of columns
	ENDC
blind_colorcycle514_loop1
	move.w	d3,d2			; table start
	IFNE bcc514_bplam_table_length_256
		swap d7
	ENDC
	moveq	#(bcc514_lamellas_number/2)-1,d6
blind_colorcycle514_loop2
	move.w	d2,d1			; table start
	moveq	#bcc514_lamella_height-1,d5
blind_colorcycle514_loop3
	move.b	(a0,d1.w),d0		; BPLAM-Wert
	move.b	d0,(a1)			; BPLCON4 high
	sub.l	a6,a1			; 2nd quadrant penultimate line in CL
	move.b	d0,(a2)			; BPLCON4 high
	sub.l	a6,a2			; 1st quadrant penultimate line in CL
	move.b	d0,(a4)			; BPLCON4 high
	add.l	a6,a4			; 3rd quadrant next line in cl
	move.b	d0,(a5)			; BPLCON4 high
	IFEQ bcc514_bplam_table_length_256
		subq.b	#bcc514_step1,d1 ; next entry
	ELSE
		subq.w	#bcc514_step1,d1 ; next entry
		and.w	d7,d1		; remove overflow
	ENDC
	add.l	a6,a5			; 4th quadrant next line in cl
	dbf	d5,blind_colorcycle514_loop3
	IFEQ bcc514_bplam_table_length_256
		subq.b	#bcc514_step1,d2 ; next entry
	ELSE
		subq.w	#bcc514_step1,d2 ; next entry
		and.w	d7,d2		; remove overflow
	ENDC
	dbf	d6,blind_colorcycle514_loop2
	move.l	(a3,d4.w*4),d0
	MULUF.L bcc514_step2_radius*2,d0
	swap	d0
	addq.b	#bcc514_step2_angle_step,d4
	add.w	#bcc514_step2_center,d0
	IFEQ bcc514_bplam_table_length_256
		sub.b	d0,d3		; next entry
	ELSE
		sub.w	d0,d3		; next entry
		and.w	d7,d3		; remove overflow
		swap	d7
	ENDC
	ADDF.W	(cl2_extension1_size*(bcc514_lamellas_number/2)*bcc514_lamella_height)-LONGWORD_SIZE,a1 ; 2nd quadrant penultimate column
	add.l	a7,a2		; 1st quadrant next column
	sub.l	a7,a4		; 3rd quadrant penultimate column
	SUBF.W	(cl2_extension1_size*(bcc514_lamellas_number/2)*bcc514_lamella_height)-LONGWORD_SIZE,a5 ; 4th quadrant next column
	dbf	d7,blind_colorcycle514_loop1
blind_colorcycle514_quit
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


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
			add.l	d4,a1	; next line in cl
		ENDC
		IFNE cl2_size2
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
			add.l	d4,a1	; next line in cl
		ENDC
		IFNE cl2_size2
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
	beq.s	eh_start_blind_colorscroll512
	subq.w	#1,d0
	beq.s	eh_stop_blind_colorscroll512
	subq.w	#1,d0
	beq.s	eh_start_blind_colorscroll514
	subq.w	#1,d0
	beq.s	eh_stop_blind_colorscroll514
	subq.w	#1,d0
	beq.s	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_blind_colorscroll512
	clr.w	bcc512_active(a3)
	clr.w	bfi_active(a3)
	rts
	CNOP 0,4
eh_stop_blind_colorscroll512
	clr.w	bfo_active(a3)
	rts
	CNOP 0,4
eh_start_blind_colorscroll514
	move.w	#FALSE,bcc512_active(a3)
	clr.w	bcc514_active(a3)
	clr.w	bfi_active(a3)
	rts
	CNOP 0,4
eh_stop_blind_colorscroll514
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
	INCLUDE "RasterMaster:colortables/07_bcc512_Colorgradient.ct"


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
