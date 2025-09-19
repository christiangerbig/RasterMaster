; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


	XREF color00_bits
	XREF mouse_handler
	XREF sine_table_512

	XDEF start_0a_zig_zag_plasma


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

dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR

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
pf1_x_size3			EQU 32
pf1_y_size3			EQU 1
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
visible_pixels_number		EQU 376
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 16	; 1x

display_window_hstart		EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU -pf1_plane_width+(pf1_plane_width-data_fetch_width)

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_OVERSCAN_32_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits			EQU 0

cl2_display_x_size		EQU 456
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU visible_lines_number-2
cl2_hstart1			EQU 0
cl2_vstart1			EQU MINROW
cl2_hstart2			EQU 0
cl2_vstart2			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Zig-Zag-Plasma5
zzp5_y_radius			EQU 64
zzp5_y_center			EQU 64
zzp5_y_radius_angle_speed	EQU 1
zzp5_y_angle_speed		EQU 1
zzp5_y_angle_step		EQU 9
zzp5_bplam_table_step		EQU 1

zzp5_copy_blit_x_size		EQU 16
zzp5_copy_blit_width		EQU zzp5_copy_blit_x_size/8
zzp5_copy_blit_y_size		EQU cl2_display_y_size

; Vert-Shade-Bars
vsb_bar_height			EQU 16
vsb_bars_number			EQU 4
vsb_y_radius			EQU ((visible_lines_number+(zzp5_y_radius*2))-vsb_bar_height)/2
vsb_y_center			EQU ((visible_lines_number+(zzp5_y_radius*2))-vsb_bar_height)/2
vsb_y_radius_angle_speed	EQU 2
vsb_y_radius_angle_step		EQU 1
vsb_y_angle_speed		EQU 2
vsb_y_angle_step		EQU sine_table_length/vsb_bars_number

; Vert-Border-Fader
vbf_FPS				EQU 50
vbf_y_position_center		EQU display_window_vstart+(visible_lines_number/2)

vbfo_fader_speed_max		EQU 4
vbfo_fader_radius		EQU vbfo_fader_speed_max
vbfo_fader_center		EQU vbfo_fader_speed_max+1
vbfo_fader_angle_speed		EQU 2

; Effects-Handler
eh_trigger_number_max		EQU 3

color_step1			EQU 256/128
color_values_number1		EQU 128
segments_number1		EQU 2

ct_size1			EQU color_values_number1*segments_number1

zzp5_bplam_table_size1		EQU ct_size1
zzp5_bplam_table_size2		EQU cl2_display_y_size+(zzp5_y_radius*2)

chip_memory_size		EQU zzp5_bplam_table_size2*WORD_SIZE


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
cl2_ext1_BPLCON4_45		RS.L 1
cl2_ext1_BPLCON4_46		RS.L 1
cl2_ext1_BPLCON4_47		RS.L 1
cl2_ext1_BPLCON4_48		RS.L 1
cl2_ext1_BPLCON4_49		RS.L 1
cl2_ext1_BPLCON4_50		RS.L 1
cl2_ext1_BPLCON4_51		RS.L 1
cl2_ext1_BPLCON4_52		RS.L 1
cl2_ext1_BPLCON4_53		RS.L 1
cl2_ext1_BPLCON4_54		RS.L 1
cl2_ext1_BPLCON4_55		RS.L 1
cl2_ext1_BPLCON4_56		RS.L 1
cl2_ext1_BPLCON4_57		RS.L 1

cl2_extension1_size		RS.B 0

	RSRESET

cl2_begin			RS.B 0

cl2_WAIT			RS.L 1
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

; Zig-Zag-Plasma5
zzp5_y_radius_angle		RS.W 1
zzp5_y_angle			RS.W 1

; Vert-Shade-Bars
vsb_active			RS.W 1
vsb_y_radius_angle		RS.W 1
vsb_y_angle			RS.W 1

; Vert-Border-Fader
vbf_fader_angle			RS.W 1
vbf_display_window_vstart	RS.W 1
vbf_display_window_vstop	RS.W 1

vbfo_active			RS.W 1

; Effects-Handler
eh_trigger_number		RS.W 1

; Main
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


start_0a_zig_zag_plasma


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Zig-Zag-Plasma5
	moveq	#TRUE,d0
	move.w	d0,zzp5_y_radius_angle(a3) ; 0°
	move.w	d0,zzp5_y_angle(a3)	; 0°

; Vert-Shade-Bars
	move.w	d0,vsb_active(a3)
	move.w	#sine_table_length/4,vsb_y_radius_angle(a3) ; 90°
	move.w	d0,vsb_y_angle(a3)	; 0°

; Vert-Border-Fader
	move.w	#sine_table_length/4,vbf_fader_angle(a3)
	move.w	#display_window_vstart,vbf_display_window_vstart(a3)
	move.w	#display_window_vstop,vbf_display_window_vstop(a3)

	moveq	#FALSE,d1
	move.w	d1,vbfo_active(a3)

; Effects-Handler
	move.w	d0,eh_trigger_number(a3)

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	init_colors
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


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0 
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_bitplane_pointers
	COP_MOVEQ 0,COPJMP2
	bra	cl1_set_bitplane_pointers


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_BITPLANE_POINTERS cl1


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0 
	bsr.s	cl2_init_bplcon4_chunky
	bsr.s	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bra	set_second_copperlist


	CNOP 0,4
cl2_init_bplcon4_chunky
	move.l	#(BPLCON4<<16)|bplcon4_bits,d0
	COP_WAIT cl2_hstart1,cl2_vstart1
	move.w	#(cl2_display_width*cl2_display_y_size)-1,d7 ; number of columns
cl2_init_bplcon4_chunky_loop
	move.l	d0,(a0)+		; BPLCON4
	dbf	d7,cl2_init_bplcon4_chunky_loop
	rts


	COP_INIT_COPINT cl2


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
	bsr	vert_border_fader_out
	bsr	vert_shade_bars
	bsr	zzp5_get_y_coordinates
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
vert_shade_bars
	tst.w	vsb_active(a3)
	bne	vert_shade_bars_quit
	move.w	vsb_y_radius_angle(a3),d2
	move.w	d2,d0		
	MOVEF.W sine_table_length-1,d6	; overflow 360°
	addq.w	#vsb_y_radius_angle_speed,d0
	move.w	vsb_y_angle(a3),d3
	and.w	d6,d0			; remove overflow
	move.w	d0,vsb_y_radius_angle(a3)
	move.w	d3,d0		
	addq.w	#vsb_y_angle_speed,d0
	and.w	d6,d0			; remove overflow
	move.w	d0,vsb_y_angle(a3) 
	MOVEF.W vsb_y_radius*4,d4
	MOVEF.W vsb_y_angle_step,d5
	lea	sine_table_512,a0 
	move.l	chip_memory(a3),a1	; lines colors table
	move.w	#vsb_y_center,a2
	moveq	#vsb_bars_number-1,d7
vert_shade_bars_loop
	move.w	2(a0,d2.w*4),d0		; cos(w)
	muls.w	d4,d0			; yr'=(yr*cos(w))/2*^15
	swap	d0
	muls.w	2(a0,d3.w*4),d0		; y'=(yr'*sin(w))/2*^15
	swap	d0
	add.w	a2,d0			; y' + y center
	addq.b	#1,(a1,d0.w*2)		; increase color number
	addq.b	#2,WORD_SIZE*1(a1,d0.w*2)
	addq.b	#3,WORD_SIZE*2(a1,d0.w*2)
	addq.b	#4,WORD_SIZE*3(a1,d0.w*2)
	addq.b	#5,WORD_SIZE*4(a1,d0.w*2)
	addq.b	#6,WORD_SIZE*5(a1,d0.w*2)
	addq.b	#7,WORD_SIZE*6(a1,d0.w*2)
	addq.b	#8,WORD_SIZE*7(a1,d0.w*2)
	addq.b	#8,WORD_SIZE*8(a1,d0.w*2)
	addq.b	#7,WORD_SIZE*9(a1,d0.w*2)
	addq.b	#6,WORD_SIZE*10(a1,d0.w*2)
	addq.b	#5,WORD_SIZE*11(a1,d0.w*2)
	addq.w	#vsb_y_radius_angle_step,d2
	addq.b	#4,WORD_SIZE*12(a1,d0.w*2)
	and.w	d6,d2			; remove overflow
	addq.b	#3,WORD_SIZE*12(a1,d0.w*2)
	add.w	d5,d3			; next y angle
	addq.b	#2,WORD_SIZE*14(a1,d0.w*2)
	and.w	d6,d3			; remove overflow
	addq.b	#1,WORD_SIZE*15(a1,d0.w*2)
	dbf	d7,vert_shade_bars_loop
vert_shade_bars_quit
	rts


	CNOP 0,4
zzp5_get_y_coordinates
	movem.l a3-a5,-(a7)
	move.l	a7,save_a7(a3)	
	bsr	zzp5_get_y_coordinates_init
	MOVEF.W zzp5_y_center,d1
	move.w	zzp5_y_radius_angle(a3),d2 ; 1st radius y angle
	move.w	d2,d0		
	lea	sine_table_512,a0	
	move.w	2(a0,d2.w*4),d2		; sin(w)
	asr.w	#8,d2			; yr'=(yr*sin(w))/2^15
	addq.w	#zzp5_y_radius_angle_speed,d0
	MOVEF.W sine_table_length-1,d6	; overflow 360°
	move.w	zzp5_y_angle(a3),d3	; 1st y angle
	and.w	d6,d0			; remove overflow
	move.w	d0,zzp5_y_radius_angle(a3) 
	move.w	d3,d0		
	addq.w	#zzp5_y_angle_speed,d0
	and.w	d6,d0			; remove overflow
	move.w	d0,zzp5_y_angle(a3) 
	;MOVEF.W zzp5_y_radius,d4
	move.w	#((zzp5_copy_blit_y_size)<<6)|(zzp5_copy_blit_x_size/WORD_BITS),d4 ; BLTSIZE
	moveq	#zzp5_y_angle_step,d5
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE,a2
	lea	BLTDPT-DMACONR(a6),a4
	lea	BLTSIZE-DMACONR(a6),a5
	move.l	chip_memory(a3),a7	; BPLAM table
	lea	BLTAPT-DMACONR(a6),a3
	moveq	#cl2_display_width-1,d7 ; number of columns
zzp5_get_y_coordinates_loop
	move.w	d2,d0
	muls.w	2(a0,d3.w*4),d0		; y'=(yr'*sin(w))/2^15
	swap	d0
	add.w	d1,d0			; y' + y center
	WAITBLIT
	move.l	a2,(a4)			; destination: cl
	lea	(a7,d0.w*2),a1		; offset in BPLAM table
	move.l	a1,(a3)			; BPLAM table
	move.w	d4,(a5)			; start blit operation
	add.w	d5,d3			; next y angle
	addq.w	#LONGWORD_SIZE,a2	; next column in cl
	and.w	d6,d3			; remove overflow
	dbf	d7,zzp5_get_y_coordinates_loop
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a5
	rts
	CNOP 0,4
zzp5_get_y_coordinates_init
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#(BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	move.l	#cl2_extension1_size-zzp5_copy_blit_width,BLTAMOD-DMACONR(a6) ; A&D moduli
	rts


	CNOP 0,4
vert_border_fader_out
	tst.w	vbfo_active(a3)
	bne.s	vert_border_fader_out_quit
	move.w	vbf_fader_angle(a3),d1
	move.w	d1,d0		
	subq.w	#vbfo_fader_angle_speed,d0
	move.w	d0,vbf_fader_angle(a3) 
	lea	sine_table_512,a0	
	move.l	(a0,d1.w*4),d0		; sin(w)
	MULUF.L vbfo_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	add.w	#vbfo_fader_center,d0
	move.w	vbf_display_window_vstart(a3),d2
	add.w	d0,d2			; new VSTART
	cmp.w	#vbf_y_position_center,d2 ; destination reached ?
	ble.s	vert_border_fader_out_skip1
	MOVEF.W vbf_y_position_center,d2 ; destination
vert_border_fader_out_skip1
	move.w	vbf_display_window_vstop(a3),d1
	sub.w	d0,d1			; new VSTOP
	move.w	d2,vbf_display_window_vstart(a3) 
	cmp.w	#vbf_y_position_center,d1 ; destination reached ?
	bge.s	vert_border_fader_out_skip2
	move.w	#FALSE,vbfo_active(a3)
	MOVEF.W vbf_y_position_center,d1 ; destination
vert_border_fader_out_skip2
	move.w	d1,vbf_display_window_vstop(a3)
	move.l	cl1_display(a3),a0 
	move.w	#diwhigh_bits&(~(DIWHIGHF_VSTART8+DIWHIGHF_VSTART9+DIWHIGHF_vstart10+DIWHIGHF_VSTOP8+DIWHIGHF_VSTOP9+DIWHIGHF_VSTOP10)),d0 ; DIWHIGH
	move.b	d2,cl1_DIWSTRT+WORD_SIZE(a0) ; VSTART0-VSTART7
	lsr.w	#8,d2			; adjust bits
	move.b	d1,cl1_DIWSTOP+WORD_SIZE(a0) ; VSTOP0-VSTOP7
	move.b	d2,d1			; merge with VSTART8-VSTART10
	or.w	d1,d0			; merge with HSTART/HSTOP
	move.w	d0,cl1_DIWHIGH+WORD_SIZE(a0) ; VSTART/VSTOP
vert_border_fader_out_quit
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
	beq.s	eh_start_vert_shade_bars
	subq.w	#1,d0
	beq.s	eh_start_vert_border_fader_out
	subq.w	#1,d0
	beq.s	eh_stop_all
effects_handler_quit
	rts
	CNOP 0,4
eh_start_vert_shade_bars
	clr.w	vsb_active(a3)
	rts
	CNOP 0,4
eh_start_vert_border_fader_out
	clr.w	vbfo_active(a3)
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
	INCLUDE "RasterMaster:colortables/0b_zzp5_Colorgradient.ct"


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"

	END
