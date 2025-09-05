; Requirements
; 68020+
; AGA PAL
; 3.0+


; History/Changes

; V.1.0 Beta
; - 1st release

; V.1.1 Beta
; - Credits part: logo now scrolls in from left
; text changed

; V1.2 Beta
; - Main: background color now global
; - Credits-Part: text changed
; - Title-Part: Grass´wip logo included

; V.1.3 Beta
; - Title-Part: Grass' logo and title screen included
; Image fader only with 127 colors
; - Part 3-Twisted-Bars revised and the new part 04-twisted-colorcycle-bars
; included
; - All FX palettes now match the title screen palette

; V.1.4 Beta
; - Intro-Part: Overscan DIW values corrected
; - Credits-Part: Grass' font included
;               text changed
;               Overscan DIW values corrected. Sprites now displayed properly
;               at left border
; - Again all FX palettes now match the title screen palette

; V.1.5 Beta
; - Twisted-Colorcycle-Bars: vertical color gradient now from a loaded table
; - Twisted-Space-Bars: Grass' background image included

; V.1.6 Beta
; - Twisted-Space-Bars: Grass' font included and bar colors adapted

; V.1.7 Beta
; - Twisted-Space-Bars: Colums fader improved
; - Credits: Grass´ font included and columns fader improved

; V.1.8 Beta
; - Vert-Starscrolling: Grass' Logo hinzugefügt.

; V.1.9 Beta
; - WB icon included and WB start and WB fader ativated

; V.1.0
; - Bootable disk created

; V.1.1
; - All image faders now without color cache

; V.1.2
; - Twisted-Bars: Bugfix, height of clear blit was not correct

; V.1.3
; - code revised
; - mouse handler exported for fast exit

; V.1.4 (finale Version)
; - Code optimized
; - Disk icon with NO_POSITION
; - Demo icon with NO_POSITION and credits included

; V.1.5
; - image fader optimized

; V.1.6 (A1200/060 with Indivision: Logo sometimes displayed with wrong colors)
; - compiled with new includes
; - Space-Bars: Chunky columns fader now triggered not at patternjposition 50
;             alreday at pattern position 48, because otherwise 50 FPS are not
;             guaranteed
;             Beamp osition $133 changed to $136
; - Nop copperliste2 is initialized only once in the main part and exported


	MC68040


	XDEF color00_bits
	XDEF color00_high_bits
	XDEF color00_low_bits
	XDEF color255_bits

	XREF start_0_pt_replay
	XREF start_1_pt_replay


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
SET_SECOND_COPPERLIST		SET 1


	INCDIR "custom-includes-aga:"


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE	
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU TRUE
screen_fader_enabled		EQU TRUE
text_output_enabled		EQU FALSE

dma_bits			EQU DMAF_COPPER|DMAF_MASTER|DMAF_SETCLR

intena_bits			EQU INTF_INTEN|INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
pf1_colors_number		EQU 0	; 1

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

bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0
color00_bits			EQU $001122
color00_high_bits		EQU $012
color00_low_bits		EQU $012
color255_bits			EQU color00_bits

cl1_hstart			EQU 0
cl1_vstart			EQU beam_position&CL_Y_WRAPPING


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_BPLCON3_2			RS.L 1
cl1_WAIT1			RS.L 1
cl1_WAIT2			RS.L 1
cl1_INTREQ			RS.L 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU 0
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

variables_size			RS.B 0


	SECTION code,CODE


start


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables
	rts


	CNOP 0,4
init_main
	bsr.s	init_colors
	bsr	init_first_copperlist
	bra	init_second_copperlist


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,1,pf1_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,1,pf1_rgb8_color_table
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_copper_interrupt
	COP_LISTEND
	rts


	COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK


	COP_INIT_COPINT cl1,cl1_hstart,cl1_vstart,YWRAP


	CNOP 0,4
init_second_copperlist
	move.l	cl2_display(a3),a0
	COP_LISTEND
	rts


	CNOP 0,4
main
	bsr	start_0_pt_replay
	tst.l	d0			; any error ?
	bne.s	main_quit
	jmp	start_1_pt_replay
	CNOP 0,4
main_quit
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


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


	DC.B "$VER: "
	DC.B "RSE-RasterMaster "
	DC.B "1.6 "
	DC.B "(23.4.24)",0
	EVEN

	END
