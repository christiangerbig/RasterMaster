; ##############################
; # Programm: 1_Wrapper.asm    #
; # Autor:    Christian Gerbig #
; # Datum:    21.12.2023       #
; # Version:  1.3 beta         #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

  SECTION code_and_variables,CODE

  MC68040

  XREF COLOR00BITS
  XREF sc_start
  XREF start_10_credits


  XDEF start_1_pt_replay


; ** Library-Includes V.3.x nachladen **
; --------------------------------------
  ;INCDIR  "OMA:include/"
  INCDIR "Daten:include3.5/"

  INCLUDE "dos/dos.i"
  INCLUDE "dos/dosextens.i"
  INCLUDE "libraries/dos_lib.i"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "graphics/GFXBase.i"
  INCLUDE "graphics/videocontrol.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "intuition/intuition.i"
  INCLUDE "intuition/intuition_lib.i"

  INCLUDE "resources/cia_lib.i"

  INCLUDE "hardware/adkbits.i"
  INCLUDE "hardware/blit.i"
  INCLUDE "hardware/cia.i"
  INCLUDE "hardware/custom.i"
  INCLUDE "hardware/dmabits.i"
  INCLUDE "hardware/intbits.i"

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


; ** Konstanten **
; ----------------

  INCLUDE "equals.i"

requires_68030             EQU FALSE
requires_68040             EQU FALSE
requires_68060             EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start_enabled    EQU FALSE
workbench_fade_enabled     EQU FALSE
text_output_enabled        EQU FALSE

sys_taken_over
wrapper
pass_global_references
pass_return_code
custom_memory_used
custom_memory_chip         EQU $00000000
custom_memory_fast         EQU $00000001

pt_v3.0b
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-equals.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-equals.i"
  ENDC
pt_ciatiming_enabled       EQU TRUE
pt_finetune_enabled        EQU FALSE
  IFD pt_v3.0b
pt_metronome_enabled       EQU FALSE
  ENDC
pt_mute_enabled            EQU FALSE
pt_track_volumes_enabled   EQU FALSE
pt_track_periods_enabled   EQU FALSE
pt_music_fader_enabled     EQU FALSE
pt_split_module_enabled    EQU TRUE
pt_usedfx                  EQU %1001010100000000
pt_usedefx                 EQU %0000000000000000

DMABITS                    EQU DMAF_COPPER+DMAF_SETCLR

  IFEQ pt_ciatiming_enabled
INTENABITS                 EQU INTF_EXTER+INTF_SETCLR
  ELSE
INTENABITS                 EQU INTF_VERTB+INTF_EXTER+INTF_SETCLR
  ENDC

CIAAICRBITS                EQU CIAICRF_SETCLR
  IFEQ pt_ciatiming_enabled
CIABICRBITS                EQU CIAICRF_TA+CIAICRF_TB+CIAICRF_SETCLR
  ELSE
CIABICRBITS                EQU CIAICRF_TB+CIAICRF_SETCLR
  ENDC

COPCONBITS                 EQU 0

pf1_x_size1                EQU 0
pf1_y_size1                EQU 0
pf1_depth1                 EQU 0
pf1_x_size2                EQU 0
pf1_y_size2                EQU 0
pf1_depth2                 EQU 0
pf1_x_size3                EQU 0
pf1_y_size3                EQU 0
pf1_depth3                 EQU 0
pf1_colors_number          EQU 0 ;1

pf2_x_size1                EQU 0
pf2_y_size1                EQU 0
pf2_depth1                 EQU 0
pf2_x_size2                EQU 0
pf2_y_size2                EQU 0
pf2_depth2                 EQU 0
pf2_x_size3                EQU 0
pf2_y_size3                EQU 0
pf2_depth3                 EQU 0
pf2_colors_number          EQU 0
pf_colors_number           EQU pf1_colors_number+pf2_colors_number
pf_depth                   EQU pf1_depth3+pf2_depth3

extra_pf_number            EQU 0

spr_number                 EQU 0
spr_x_size1                EQU 0
spr_y_size1                EQU 0
spr_x_size2                EQU 0
spr_y_size2                EQU 0
spr_depth                  EQU 0
spr_colors_number          EQU 0

  IFD pt_v2.3a
audio_memory_size          EQU 0
  ENDC
  IFD pt_v3.0b
audio_memory_size          EQU 2
  ENDC

disk_memory_size           EQU 0

extra_memory_size          EQU 0

chip_memory_size           EQU 0
  IFEQ pt_ciatiming_enabled
CIABCRABITS                EQU CIACRBF_LOAD
  ENDC
CIABCRBBITS                EQU CIACRBF_LOAD+CIACRBF_RUNMODE ;Oneshot mode
CIAA_TA_time               EQU 0
CIAA_TB_time               EQU 0
  IFEQ pt_ciatiming_enabled
CIAB_TA_time               EQU 14187 ;= 0.709379 MHz * [20000 µs = 50 Hz duration for one frame on a PAL machine]
;CIAB_TA_time               EQU 14318 ;= 0.715909 MHz * [20000 µs = 50 Hz duration for one frame on a NTSC machine]
  ELSE
CIAB_TA_time               EQU 0
  ENDC
CIAB_TB_time               EQU 362 ;= 0.709379 MHz * [511.43 µs = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
                                   ;= 0.715909 MHz * [506.76 µs = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
CIAA_TA_continuous_enabled EQU FALSE
CIAA_TB_continuous_enabled EQU FALSE
  IFEQ pt_ciatiming_enabled
CIAB_TA_continuous_enabled EQU TRUE
  ELSE
CIAB_TA_continuous_enabled EQU FALSE
  ENDC
CIAB_TB_continuous_enabled EQU FALSE

beam_position              EQU $136

BPLCON0BITS                EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1               EQU 0
BPLCON3BITS2               EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                EQU 0

cl1_HSTART                 EQU $00
cl1_VSTART                 EQU beam_position&$ff

; **** Custom Memory ****
custom_memory_number       EQU 2
part_1_audio_memory_size1  EQU 11324 ;Song
part_1_audio_memory_size2  EQU 62362 ;Samples

; **** PT-Replay ****
pt_fade_out_delay          EQU 2 ;Ticks


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enthält **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enthält **
; -----------------------------------------------------------------------
  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_BPLCON3_2    RS.L 1
cl1_WAIT1        RS.L 1
cl1_WAIT2        RS.L 1
cl1_INTREQ       RS.L 1

cl1_end          RS.L 1

copperlist1_SIZE RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU 0

; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1       EQU spr_x_size1
spr0_y_size1       EQU 0
spr1_x_size1       EQU spr_x_size1
spr1_y_size1       EQU 0
spr2_x_size1       EQU spr_x_size1
spr2_y_size1       EQU 0
spr3_x_size1       EQU spr_x_size1
spr3_y_size1       EQU 0
spr4_x_size1       EQU spr_x_size1
spr4_y_size1       EQU 0
spr5_x_size1       EQU spr_x_size1
spr5_y_size1       EQU 0
spr6_x_size1       EQU spr_x_size1
spr6_y_size1       EQU 0
spr7_x_size1       EQU spr_x_size1
spr7_y_size1       EQU 0

spr0_x_size2       EQU spr_x_size2
spr0_y_size2       EQU 0
spr1_x_size2       EQU spr_x_size2
spr1_y_size2       EQU 0
spr2_x_size2       EQU spr_x_size2
spr2_y_size2       EQU 0
spr3_x_size2       EQU spr_x_size2
spr3_y_size2       EQU 0
spr4_x_size2       EQU spr_x_size2
spr4_y_size2       EQU 0
spr5_x_size2       EQU spr_x_size2
spr5_y_size2       EQU 0
spr6_x_size2       EQU spr_x_size2
spr6_y_size2       EQU 0
spr7_x_size2       EQU spr_x_size2
spr7_y_size2       EQU 0

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; ** Relative offsets for variables **
; ------------------------------------

; **** PT-Replay ****
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-variables-offsets.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-variables-offsets.i"
  ENDC

variables_SIZE RS.B 0


; **** PT-Replay ****
; ** PT-Song-Structure **
; -----------------------
  INCLUDE "music-tracker/pt-song-structure.i"

; ** Temporary channel structure **
; ---------------------------------
  INCLUDE "music-tracker/pt-temp-channel-structure.i"

; ** Custom Memory Entry-Structure **
; -----------------------------------
  RSRESET

custom_memory_entry      RS.B 0
cme_memory_size          RS.L 1
cme_memory_type          RS.L 1
cme_memory_pointer       RS.L 1
custom_memory_entry_SIZE RS.B 0


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------
start_1_pt_replay
  INCLUDE "sys-init.i"

; ** Custom-Memory-Table initialisieren **
; ----------------------------------------
  CNOP 0,4
init_custom_memory_table
  lea     custom_memory_table(pc),a0
  move.l  #part_1_audio_memory_size1,(a0)+ ;Speichergröße
  moveq   #custom_memory_fast,d2
  move.l  d2,(a0)+           ;Speicherart: vorrangig fast-memory
  moveq   #0,d0
  move.l  d0,(a0)+           ;Zeiger auf Speicherbereich = Null
  move.l  #part_1_audio_memory_size2,(a0)+ ;Speichergröße
  move.l  d0,(a0)+           ;Speicherart: chip-memory
  move.l  d0,(a0)            ;Zeiger auf Speicherbereich = Null
  rts

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables
; **** PT-Replay ****
  IFD pt_v2.3a
    PT2_INIT_VARIABLES NOPOINTERS
  ENDC
  IFD pt_v3.0b
    PT3_INIT_VARIABLES NOPOINTERS
  ENDC
  rts

; ** Globale Referenzen erweitern **
; ----------------------------------
  CNOP 0,4
extend_global_references_table
  move.l  global_references_table(a3),a0
  lea     custom_memory_table(pc),a1 ;Zeiger auf Custom-Memory-Tabelle
  move.l  a1,gr_custom_memory_table(a0) ;eintragen
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   pt_DetectSysFrequ
  bsr.s   pt_decrunch_audio_data
  bsr     pt_InitRegisters
  bsr     pt_InitAudTempStrucs
  bsr     pt_ExamineSongStruc
  IFEQ pt_finetune_enabled
    bsr     pt_InitFtuPeriodTableStarts
  ENDC
  bsr     init_color_registers
  bsr     init_CIA_timers
  bra     init_first_copperlist

; **** PT-Replay ****
; ** Detect system frequency NTSC/PAL **
; --------------------------------------
  PT_DETECT_SYS_FREQUENCY

; ** Audiodaten entpacken **
; --------------------------
  CNOP 0,4
pt_decrunch_audio_data
  lea     pt_auddata,a0      ;Quelle: gepackte Daten
  lea     custom_memory_table(pc),a2
  move.l  cme_memory_pointer(a2),a1 ;Ziel: entpackte Daten
  move.l  a1,pt_SongDataPointer(a3)
  movem.l a2-a6,-(a7)
  jsr     sc_start
  movem.l (a7)+,a2-a6
  ADDF.W  custom_memory_entry_size,a2 ;nächster Custom-Memory-Block
  lea     pt_audsmps,a0
  move.l  cme_memory_pointer(a2),a1
  move.l  a1,pt_SamplesDataPointer(a3)
  movem.l a2-a6,-(a7)
  jsr     sc_start
  movem.l (a7)+,a2-a6
  rts

; ** Audioregister initialisieren **
; ----------------------------------
   PT_INIT_REGISTERS

; ** Temporäre Audio-Kanal-Struktur initialisieren **
; ---------------------------------------------------
   PT_INIT_AUDIO_TEMP_STRUCTURES

; ** Höchstes Pattern ermitteln und Tabelle mit Zeigern auf Samples initialisieren **
; -----------------------------------------------------------------------------------
   PT_EXAMINE_SONG_STRUCTURE

  IFEQ pt_finetune_enabled
; ** FineTuning-Offset-Tabelle initialisieren **
; ----------------------------------------------
    PT_INIT_FINETUNING_PERIOD_TABLE_STARTS
  ENDC


; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 0
  CPU_INIT_COLORHI COLOR00,1,pf1_color_table

  CPU_SELECT_COLORLO_BANK 0
  CPU_INIT_COLORLO COLOR00,1,pf1_color_table
  rts

; ** CIA-Timer initialisieren **
; ------------------------------
  CNOP 0,4
init_CIA_timers
  PT_INIT_TIMERS
  rts

; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0 ;Darstellen-CL
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_copint
  COPLISTEND
  rts

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

  COP_INIT_COPINT cl1,cl1_HSTART,cl1_VSTART,YWRAP


; ** Custom-Memory belegen **
; ---------------------------
  CNOP 0,4
alloc_custom_memory
  move.l  global_references_table(a3),a2
  move.l  gr_custom_memory_table(a2),a2 ;Zeiger auf ersten Listeneintrag
  moveq   #custom_memory_number-1,d7 ;Anzahl der Speicherblöcke zum Belegen
alloc_custom_memory_loop
  move.l  (a2)+,d0           ;Größe der Speicherbereiches
  tst.l   (a2)+              ;Soll Chip-Memory reserviert werden ?
  bne.s   acm_alloc_memory ;Nein -> verzweige
acm_alloc_chip_memory
  bsr     do_alloc_chip_memory
  move.l  d0,(a2)+           ;Zeiger auf Speicherbereich
  beq.s   custom_memory_error ;Wenn NULL -> verzweige
  bra.s   alloc_next_custom_memory
  CNOP 0,4
acm_alloc_memory
  bsr     do_alloc_memory
  move.l  d0,(a2)+           ;Zeiger auf Speicherbereich
  beq.s   custom_memory_error ;Wenn NULL -> verzweige
alloc_next_custom_memory
  dbf     d7,alloc_custom_memory_loop
  moveq   #RETURN_OK,d0
  rts
  CNOP 0,4
custom_memory_error
  moveq   #CUSTOM_MEMORY_NO_MEMORY,d0
  move.w  d0,custom_error_code(a3)
  moveq   #RETURN_ERROR,d0
  rts

; ** CIA-Timer starten **
; -----------------------

  INCLUDE "continuous-timers-start.i"


; ## Hauptprogramm ##
; -------------------
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bra     start_10_credits

; ** Speicherbelegung für Custom-Memory freigeben **
; --------------------------------------------------
  CNOP 0,4
free_custom_memory
  move.l  global_references_table(a3),a2
  move.l  gr_custom_memory_table(a2),a2 ;Zeiger auf ersten Listeneintrag
  moveq   #custom_memory_number-1,d7 ;Anzahl der Speicherblöcke zum Freigeben
free_custom_memory_loop
  move.l  (a2),d0            ;Größe der Speicherbereiches
  addq.w  #8,a2              ;Speicherattribute überspringen
  move.l  (a2)+,d1           ;Zeiger auf Speicherbereich 
  beq.s   free_next_custom_memory ;Wenn NULL -> verzweige
  move.l  d1,a1              ;Zeiger auf Speicherbereich
  CALLEXEC FreeMem           ;Speicher freigeben
free_next_custom_memory
  dbf     d7,free_custom_memory_loop
  rts


; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

  IFEQ pt_ciatiming_enabled
; ** CIA-B timer A interrupt server **
; ------------------------------------
  CNOP 0,4
CIAB_TA_int_server
  ENDC

  IFNE pt_ciatiming_enabled
; ** Vertical blank interrupt server **
; -------------------------------------
  CNOP 0,4
VERTB_int_server
  ENDC

  IFEQ pt_music_fader_enabled
    bsr.s   pt_fade_out_music
    bra.s   pt_PlayMusic

; ** Musik ausblenden **
; ----------------------
    PT_FADE_OUT

    CNOP 0,4
  ENDC

; ** PT-replay routine **
; -----------------------
  IFD pt_v2.3a
    PT2_REPLAY pt_SetSoftInterrupt
  ENDC
  IFD pt_v3.0b
    PT3_REPLAY pt_SetSoftInterrupt
  ENDC

; ** 800 "Set Soft Interrupt" **
  CNOP 0,4
pt_SetSoftInterrupt
  move.w  #INTF_SOFTINT+INTF_SETCLR,_CUSTOM+INTREQ
  rts

; ** CIA-B Timer B interrupt server **
  CNOP 0,4
CIAB_TB_int_server
  PT_TIMER_INTERRUPT_SERVER

; ** Level-6-Interrupt-Server **
; ------------------------------
  CNOP 0,4
EXTER_int_server
  rts

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


; ** Timer stoppen **
; -------------------

  INCLUDE "continuous-timers-stop.i"


; ## System wieder in Ausganszustand zurücksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen für Tabellen und Strukturen ##
; -------------------------------------------------

  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
; ----------------------------------
  CNOP 0,4
pf1_color_table
  DC.L COLOR00BITS

; ** Tables for effect commands **
; --------------------------------
; ** "Invert Loop" **
  INCLUDE "music-tracker/pt-invert-table.i"

; ** "Vibrato/Tremolo" **
  INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

; ** "Arpeggio/Tone Portamento" **
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-period-table.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-period-table.i"
  ENDC

; ** Temporary channel structures **
; ----------------------------------
  INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

; ** Pointers to samples **
; -------------------------
  INCLUDE "music-tracker/pt-sample-starts-table.i"

; ** Pointers to priod tables for different tuning **
; ---------------------------------------------------
  INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Custom Memory ****
  CNOP 0,4
custom_memory_table
  DS.B custom_memory_entry_SIZE*custom_memory_number


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"


; ## Audiodaten nachladen ##
; --------------------------

; **** PT-Replay ****
  IFEQ pt_split_module_enabled
pt_auddata SECTION pt_audio,DATA
    INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/modules/mod.CR78-Song.song.stc"
pt_audsmps SECTION pt_audio2,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/modules/mod.CR78-Song.smps.stc"
  ELSE
pt_auddata SECTION pt_audio,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/RasterMaster/modules/mod.CR78-Song"
  ENDC

  END
