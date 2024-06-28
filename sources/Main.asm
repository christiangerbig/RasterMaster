; ##############################
; # Programm: Main.asm         #
; # Autor:    Christian Gerbig #
; # Datum:    23.04.2024       #
; # Version:  1.6              #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

; V.1.0 Beta
; Erstes Release

; V.1.1 Beta
; Credits-Part: Logo scrollt jetzt von der linken Seite ein.
;               Text geändert.

; V1.2 Beta
; Main: Hintergrundfarbe ist nun global
; Credits-Part: Text geändert
; Title-Part: Grass´wip-Logo eingefügt

; V.1.3 Beta
; Title-Part: Grass' Logo und Title-Screen eingefügt.
;             Image-Fader nur mit 127 Farben.
; Teil 3-Twisted-Bars überarbeitet und den neuen Teil 04-twisted-colorcycle-bars
; eingefügt.
; Credits-Part: Text geändert und Grass' Logo eingefügt.
;               Image-Fader nur mit 127 Farben.
; Alle FX-Paletten an Title-Screen angepasst.

; V.1.4 Beta
; Intro-Part: Overscan DIW-Werte korrigiert.
; Credits-Part: Grass' Font eingefügt.
;               Text geändert.
;               Overscan DIW-Werte korrigiert. Sprites werden jetzt am linken
;               Rand korrekt dargestellt
; Erneut alle FX-Paletten an Title-Screen angepasst.

; V.1.5 Beta
; Twisted-Colorcycle-Bars: Vertikale Farbverläufe werden nun nicht mehr berechnet,
;                          sondern es wird eine Tabelle eingelesen
; Twisted-Space-Bars: Grass' Hintergrund hinzugefügt

; V.1.6 Beta
; Twisted-Space-Bars: Grass' Font hinzugefügt und sie Farben der Bars angepasst.

; V.1.7 Beta
; Twisted-Space-Bars: Columns-Fader verbessert.
; Credits: Grass´Font hinzugefügt. Columns-Fader verbessert.

; V.1.8 Beta
; Vert-Starscrolling: Grass' Logo hinzugefügt.

; V.1.9 Beta
; WB-Icon hinzugefügt und WB-Start+WB-Fader aktiviert

; V.1.0
; Bootable-Disk

; V.1.1
; Bei allen Image-Fadern entfällt der Color-Cache

; V.1.2
; Twisted-Bars: Bugfix, die Höhe des Clear-Blts war zu gering.

; V.1.3
; Code komplett umgestellt und normiert
; Mouse-Handler für Fast-Exit ausgelagert

; V.1.4 (finale Version)
; Code optimiert
; Disk-Icon mit NO_POSITION versehen
; Demo-Icon mit NO_POSITION versehen und Credits ergänzt

; V.1.5
; Image-Fader optimiert

; V.1.6 (auf A1200/060 mit Indivision wird Logo unregelmäßig mit falschen Farben dargestellt)
; Überarbeitete includes eingebunden
; Space-Bars: Chunky-Columns-Fader wird anstatt Pattern-Position 50 schon ab Pattern-
;             Position 48 getriggert, da sonst keine 50 FPS mit parallel
;             laufendem Sprite-Fader
;             Beam-Position $133 anstatt $136
; Die Nop-Copperliste2 wird einmal im Main-Teil generiert und exportiert.


  SECTION code_and_variables,CODE

  MC68040

  XDEF color00_bits
  XDEF color00_high_bits
  XDEF color00_low_bits
  XDEF color255_bits
  XDEF nop_second_copperlist

  XREF start_0_pt_replay
  XREF start_1_pt_replay


; ** Library-Includes V.3.x nachladen **
; --------------------------------------
  INCDIR "Daten:include3.5/"

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

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


; ** Konstanten **
; ----------------

  INCLUDE "equals.i"

requires_68030             EQU FALSE  
requires_68040             EQU FALSE
requires_68060             EQU FALSE
requires_fast_memory       EQU FALSE
requires_multiscan_monitor EQU FALSE

workbench_start_enabled    EQU TRUE
workbench_fade_enabled     EQU TRUE
text_output_enabled        EQU FALSE

own_display_set_second_copperlist
pass_global_references
pass_return_code

dma_bits                   EQU DMAF_COPPER+DMAF_MASTER+DMAF_SETCLR
intena_bits                EQU INTF_INTEN+INTF_SETCLR

ciaa_icr_bits              EQU CIAICRF_SETCLR
ciab_icr_bits              EQU CIAICRF_SETCLR

copcon_bits                EQU 0

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

audio_memory_size          EQU 0

disk_memory_size           EQU 0

extra_memory_size          EQU 0

chip_memory_size           EQU 0
ciaa_ta_time               EQU 0
ciaa_tb_time               EQU 0
ciab_ta_time               EQU 0
ciab_tb_time               EQU 0
ciaa_ta_continuous_enabled EQU FALSE
ciaa_tb_continuous_enabled EQU FALSE
ciab_ta_continuous_enabled EQU FALSE
ciab_tb_continuous_enabled EQU FALSE

beam_position              EQU $136

bplcon0_bits               EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1              EQU 0
bplcon3_bits2              EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits               EQU 0
color00_bits               EQU $001122
color00_high_bits          EQU $012
color00_low_bits           EQU $012
color255_bits              EQU color00_bits

cl1_hstart                 EQU $00
cl1_vstart                 EQU beam_position&$ff


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


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_begin        RS.B 0

cl2_end          RS.L 1

copperlist2_SIZE RS.B 0


; ** Konstanten für die größe der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE
cl2_size1          EQU 0
cl2_size2          EQU 0
cl2_size3          EQU copperlist2_SIZE

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

variables_SIZE RS.B 0


  INCLUDE "sys-wrapper.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_color_registers
  bsr     init_first_copperlist
  bra     init_second_copperlist

; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLOR_HIGH_BANK 0
  CPU_INIT_COLOR_HIGH COLOR00,1,pf1_color_table

  CPU_SELECT_COLOR_LOW_BANK 0
  CPU_INIT_COLOR_LOW COLOR00,1,pf1_color_table
  rts


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_copper_interrupt
  COP_LIST_END
  rts

  COP_INIT_PLAYFIELD_REGISTERS cl1,BLANK

  COP_INIT_COPPER_INTERRUPT cl1,cl1_HSTART,cl1_VSTART,YWRAP

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_display(a3),a0
  COP_LIST_END
  lea     nop_second_copperlist(pc),a1
  move.l  a0,(a1)
  rts


; ## Hauptprogramm ##
; -------------------
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bsr    start_0_pt_replay
  tst.l  d0                  ;Ist ein Fehler aufgetreten ?
  bne.s  no_start_1_pt_replay ;Ja -> verzweige
  jmp    start_1_pt_replay
  CNOP 0,4
no_start_1_pt_replay
  rts

; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


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
  DC.L color00_bits


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"

nop_second_copperlist DC.L 0


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; ** Programmversion für Version-Befehl **
; ----------------------------------------
program_version DC.B "$VER: RSE-RasterMaster 1.6 23.4.24)",TRUE
  EVEN

  END
