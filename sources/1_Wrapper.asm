; Requirements
; 68020+
; AGA PAL
; 3.0+


	MC68040


; Imports
	XREF color00_bits
	XREF start_10_credits
	XREF sc_start

; Exports
	XDEF start_1_pt_replay


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
WRAPPER				SET 1
PASS_GLOBAL_REFERENCES		SET 1
PASS_RETURN_CODE		SET 1
CUSTOM_MEMORY_USED		SET 1
PROTRACKER_VERSION_3		SET 1


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

CUSTOM_MEMORY_CHIP		EQU $00000000
CUSTOM_MEMORY_FAST		EQU $00000001

; PT-Replay
pt_ciatiming_enabled		EQU TRUE
pt_usedfx			EQU %1001010100000000
pt_usedefx			EQU %0000000000000000
pt_mute_enabled			EQU FALSE
pt_music_fader_enabled		EQU FALSE
pt_fade_out_delay		EQU 2	; ticks
pt_track_notes_played_enabled	EQU FALSE
pt_track_volumes_enabled	EQU FALSE
pt_track_periods_enabled	EQU FALSE
pt_track_data_enabled		EQU FALSE
pt_split_module_enabled		EQU TRUE
	IFD PROTRACKER_VERSION_3
pt_metronome_enabled		EQU FALSE
pt_metrochanbits		EQU pt_metrochan1
pt_metrospeedbits		EQU pt_metrospeed4th
	ENDC

dma_bits			EQU DMAF_COPPER|DMAF_SETCLR

	IFEQ pt_ciatiming_enabled
intena_bits			EQU INTF_EXTER|INTF_SETCLR
	ELSE
intena_bits			EQU INTF_VERTB|INTF_EXTER|INTF_SETCLR
	ENDC

ciaa_icr_bits			EQU CIAICRF_SETCLR
	IFEQ pt_ciatiming_enabled
ciab_icr_bits			EQU CIAICRF_TA|CIAICRF_TB|CIAICRF_SETCLR
	ELSE
ciab_icr_bits			EQU CIAICRF_TB|CIAICRF_SETCLR
	ENDC

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

	IFD PROTRACKER_VERSION_2 
audio_memory_size		EQU 0
	ENDC
	IFD PROTRACKER_VERSION_3
audio_memory_size		EQU 1*WORD_SIZE
	ENDC

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0

	IFEQ pt_ciatiming_enabled
ciab_cra_bits			EQU CIACRBF_LOAD
	ENDC
ciab_crb_bits			EQU CIACRBF_LOAD|CIACRBF_RUNMODE Oneshot mode
ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
	IFEQ pt_ciatiming_enabled
ciab_ta_time			EQU 14187 ; = 0.709379 MHz * [20000 탎 = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time			EQU 14318 ; = 0.715909 MHz * [20000 탎 = 50 Hz duration for one frame on a NTSC machine]
	ELSE
ciab_ta_time			EQU 0
	ENDC
ciab_tb_time			EQU 362 ; = 0.709379 MHz * [511.43 탎 = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
					; = 0.715909 MHz * [506.76 탎 = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
	IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled	EQU TRUE
	ELSE
ciab_ta_continuous_enabled	EQU FALSE
	ENDC
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $136

bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU 0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU 0

cl1_hstart			EQU 0
cl1_vstart			EQU beam_position&CL_Y_WRAPPING

; Custom Memory
custom_memory_number		EQU 2
part_1_audio_memory_size1	EQU 11324 ; song
part_1_audio_memory_size2	EQU 62362 ; samples


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; PT-Replay
	INCLUDE "music-tracker/pt-song.i"

	INCLUDE "music-tracker/pt-temp-channel.i"


; Custom-Memory
	RSRESET

custom_memory_entry		RS.B 0

cme_memory_size			RS.L 1
cme_memory_type			RS.L 1
cme_memory_pointer		RS.L 1

custom_memory_entry_size	RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_BPLCON3_2			RS.L 1
cl1_WAIT1			RS.L 1
cl1_WAIT2			RS.L 1
cl1_INTREQ			RS.L 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
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

	INCLUDE "main-variables.i"

; PT-Replay
	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-variables.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-variables.i"
	ENDC

variables_size			RS.B 0


	SECTION code,CODE


start_1_pt_replay


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_custom_memory_table
	lea	custom_memory_table(pc),a0
	move.l	#part_1_audio_memory_size1,(a0)+ ; memory size
	moveq	#CUSTOM_MEMORY_FAST,d2
	move.l	d2,(a0)+		; ype: fast memory
	moveq	#0,d0
	move.l	d0,(a0)+		; memory block
	move.l	#part_1_audio_memory_size2,(a0)+ ; memory suize
	moveq	#CUSTOM_MEMORY_CHIP,d2
	move.l	d2,(a0)+		; type chip memory
	move.l	d0,(a0)			; memory block
	rts


	CNOP 0,4
init_main_variables

; PT-Replay
	IFD PROTRACKER_VERSION_2 
		PT2_INIT_VARIABLES NOPOINTERS
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_INIT_VARIABLES NOPOINTERS
	ENDC
	rts


	CNOP 0,4
extend_global_references_table
	move.l	global_references_table(a3),a0
	lea	custom_memory_table(pc),a1
	move.l	a1,gr_custom_memory_table(a0)
	rts


	CNOP 0,4
init_main
	bsr.s	pt_DetectSysFrequ
	bsr.s	pt_decrunch_audio_data
	bsr	pt_InitRegisters
	bsr	pt_InitAudTempStrucs
	bsr	pt_ExamineSongStruc
	bsr	pt_InitFtuPeriodTableStarts
	bsr	init_colors
	bsr	init_CIA_timers
	bsr	init_first_copperlist
	rts


; PT-Replay
	PT_DETECT_SYS_FREQUENCY


	CNOP 0,4
pt_decrunch_audio_data
	lea	pt_auddata,a0		; source: crunched data
	lea	custom_memory_table(pc),a2
	move.l	cme_memory_pointer(a2),a1 ; destination: decrunched data
	move.l	a1,pt_Song(a3)
	movem.l a2-a6,-(a7)
	jsr	sc_start
	movem.l (a7)+,a2-a6
	ADDF.W	custom_memory_entry_size,a2 ; next custom memory block
	lea	pt_audsmps,a0
	move.l	cme_memory_pointer(a2),a1
	move.l	a1,pt_Samples(a3)
	movem.l a2-a6,-(a7)
	jsr	sc_start
	movem.l (a7)+,a2-a6
	rts

	PT_INIT_REGISTERS

	PT_INIT_AUDIO_TEMP_STRUCTURES

	PT_EXAMINE_SONG_STRUCTURE

	PT_INIT_FINETUNE_TABLE_STARTS


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,1,pf1_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,1,pf1_rgb8_color_table
	rts


	CNOP 0,4
init_CIA_timers
	PT_INIT_TIMERS
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
alloc_custom_memory
	move.l	global_references_table(a3),a2
	move.l	gr_custom_memory_table(a2),a2
	moveq	#custom_memory_number-1,d7
alloc_custom_memory_loop
	move.l	(a2)+,d0		; memory size
	CMPF.L	CUSTOM_MEMORY_CHIP,(a2)+ ; type chip memory ?
	bne.s	alloc_custom_memory_skip1
	bsr	do_alloc_chip_memory
	move.l	d0,(a2)+		; memory block
	bne.s	alloc_custom_memory_skip2
	bsr.s	alloc_custom_memory_fail
	bra.s	alloc_custom_memory_quit
	CNOP 0,4
alloc_custom_memory_skip1
	bsr	do_alloc_memory
	move.l	d0,(a2)+		; memory block
	bne.s	alloc_custom_memory_skip2
	bsr.s	alloc_custom_memory_fail
	bra.s	alloc_custom_memory_quit
	CNOP 0,4
alloc_custom_memory_skip2
	dbf	d7,alloc_custom_memory_loop
	moveq	#RETURN_OK,d0
alloc_custom_memory_quit
	rts
	CNOP 0,4
alloc_custom_memory_fail
	move.w	#CUSTOM_MEMORY_NO_MEMORY,custom_error_code(a3)
	moveq	#RETURN_ERROR,d0
	rts


	CNOP 0,4
main
	jsr	start_10_credits
	rts


	CNOP 0,4
free_custom_memory
	move.l	global_references_table(a3),a2
	move.l	gr_custom_memory_table(a2),a2
	moveq	#custom_memory_number-1,d7
free_custom_memory_loop
	move.l	(a2),d0			; memory size
	addq.w	#QUADWORD_SIZE,a2	; skip size and type
	move.l	(a2)+,d1		; memory block
	beq.s	free_custom_memory_skip
	move.l	d1,a1			; memory block
	CALLEXEC FreeMem
free_custom_memory_skip
	dbf	d7,free_custom_memory_loop
	rts


	INCLUDE "int-autovectors-handlers.i"

	IFEQ pt_ciatiming_enabled
		CNOP 0,4
ciab_ta_interrupt_server
	ELSE
		CNOP 0,4
vertb_interrupt_server
	ENDC


; PT-Replay
	IFEQ pt_music_fader_enabled
		bsr.s	pt_music_fader
		bsr.s	pt_PlayMusic
		rts

		PT_FADE_OUT_VOLUME

		CNOP 0,4
	ENDC

	IFD PROTRACKER_VERSION_2 
		PT2_REPLAY pt_SetSoftInterrupt
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_REPLAY pt_SetSoftInterrupt
	ENDC

	CNOP 0,4
pt_SetSoftInterrupt
	move.w	#INTF_SOFTINT|INTF_SETCLR,_CUSTOM|INTREQ
	rts

	CNOP 0,4
ciab_tb_interrupt_server
	PT_TIMER_INTERRUPT_SERVER

	CNOP 0,4
exter_interrupt_server
	rts

	CNOP 0,4
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits


; PT-Replay
	INCLUDE "music-tracker/pt-invert-table.i"

	INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-period-table.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-period-table.i"
	ENDC

	INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

	INCLUDE "music-tracker/pt-sample-starts-table.i"

	INCLUDE "music-tracker/pt-finetune-starts-table.i"


; Custom Memory
	CNOP 0,4
custom_memory_table
	DS.B custom_memory_entry_size*custom_memory_number


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Audio data

; PT-Replay
	IFEQ pt_split_module_enabled
pt_auddata			SECTION pt_audio,DATA
		INCBIN "RasterMaster:trackermodules/mod.CR78-Song.song.stc"
pt_audsmps			SECTION pt_audio2,DATA_C
		INCBIN "RasterMaster:trackermodules/mod.CR78-Song.smps.stc"
	ELSE
pt_auddata			SECTION pt_audio,DATA_C
		INCBIN "RasterMaster:trackermodules/mod.CR78-Song"
	ENDC

	END
