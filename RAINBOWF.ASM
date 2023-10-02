***************************************************
*  First Demo: Rainbow Family with Fu"r Elise
***************************************************

***************************************************
* System Equates
*

SETVBV  equ $e45c
XITVBV  equ $e462
CIOV    equ $e456

VBLKDV  equ $224

AUDF1   equ $d200
AUDC1   equ $d201
AUDCTL  equ $d208
SKCTL   equ $d20f

DLPTRLS equ $230
DLPTRHS equ $231

MEMTOPL equ $02e5
MEMTOPH equ $02e6
RAMTOP  equ $6a

VDSLSTL equ $200
VDSLSTH equ $201

COLPF2  equ $d018

WSYNC   equ $d40a
VCOUNT  equ $d40b
NMIEN   equ $d40e

DOSVEC  equ $0a

RTCLK1  equ $12
RTCLK2  equ $13
RTCLK3  equ $14

PALNTS  equ $62

RUNAD   equ $2e0
INITAD  equ $2e2

CONSOL  equ $d01f

***************************************************
* Definition Note/Frequency and duration

a1      equ 255

e2      equ 255
g2      equ 255
gis2    equ 255
a2      equ 255
ais2    equ 254
b2      equ 253
c3      equ 251 ; Low C
cis3    equ 230
d3      equ 217
dis3    equ 204
e3      equ 193
f3      equ 182
fis3    equ 173
g3      equ 162
gis3    equ 153
a3      equ 144
ais3    equ 136
b3      equ 128
c4      equ 126 ; Middle C
cis4    equ 114
d4      equ 108
dis4    equ 102
e4      equ 96
f4      equ 91
fis4    equ 85
g4      equ 81
gis4    equ 76
a4      equ 72
ais4    equ 68
b4      equ 64
c5      equ 63
cis5    equ 57
d5      equ 53
dis5    equ 50
e5      equ 47
f5      equ 45
fis5    equ 42
g5      equ 40
gis5    equ 37
a5      equ 35
ais5    equ 33
b5      equ 32
c6      equ 31
cis6    equ 31
d6      equ 30
dis6    equ 30
e6      equ 29
f6      equ 28
fis6    equ 28
g6      equ 27
gis6    equ 27
a6      equ 26
ais6    equ 26
b6      equ 25
c7      equ 24
d7      equ 23
e7      equ 22
f7      equ 21

pause    equ 1     ;Code Pause
p        equ pause ;Short for Pause
begin    equ 2     ;Code Begin
thend    equ 3     ;Code End

dura     equ 5     ;Duration Sixteenth PALequ3, NTSCequ4
t        equ dura  ;Thirteens Note
s        equ t*2   ;Sixteenth Note
e        equ s*2   ;Eighth Note 
q        equ e*2   ;Quarter Note 
h        equ q*2   ;Half Note
w        equ h*2   ;Whole Note

***********************************************************
* Main
*
        blk dos $2200

init    lda >mytopadr  ;check free memory
        cmp MEMTOPH
        bmi memok
* error message not enough free RAM
        lda <msgerr
        sta $0344
        lda >msgerr
        sta $0345
        jsr print
* jump to DOS
        jmp (DOSVEC)

* success message
memok   lda <msgok
        sta $0344
        lda >msgok
        sta $0345
        jsr print
* and end
        rts

print   ldx #$00
        lda #$09   ; put line
        sta $0342
        lda #$00
        sta $0349
        lda #$FF
        sta $0348
        jsr CIOV
        rts

msgerr  dta c'Not enough free RAM - remove cartridge',b($9b)
msgok   dta c'Loading RAINBOW FAMILY ...',b($9b)

        blk dos INITAD
        dta a(init)

        blk dos $2200

start   lda DLPTRLS     ;save DL pointer
        sta dlsavls
        lda DLPTRHS
        sta dlsavhs

        lda <dladr     ;set new DL pointer
        sta DLPTRLS
        lda >dladr
        sta DLPTRHS

        jsr muson
        jsr colon

keyinit lda #$08        ;Prepare console key
        sta CONSOL

        lda RTCLK3
        adc #$08
waitl   cmp RTCLK3
        bne waitl

        lda RTCLK2
        sta RTCLK2S

keyloop lda RTCLK2
        cmp RTCLK2S
        beq chkkeys
        sta RTCLK2S
        jsr swtchm

chkkeys lda #$02         ;Check SELECT key
        bit CONSOL
        bne keyopt

        jsr swtchm
        jmp keyinit

keyopt  lda #$04         ;Check OPTION key
        bit CONSOL
        bne keystrt

        jsr mirrow
        jmp keyinit

keystrt lda #$01        ;Check START key
        bit CONSOL
        bne keyloop

        jsr musoff
        jsr coloff

        lda dlsavls      ;restore DL pointer
        sta DLPTRLS
        lda dlsavhs
        sta DLPTRHS

        rts

RTCLK2S dta b($00)

***************************************************
* ANTIC interrupt

savanil dta b($00) ;Old ANTIC interrupt low
savanih dta b($00) ;Old ANTIC interrupt high

swtchm  lda >dmadr4
        cmp dlm1+1
        beq setfrst
        lda #$20
        clc
        adc dlm1+1
        sta dlm1+1
        lda #$20
        clc
        adc dlm2+1
        sta dlm2+1
        rts

setfrst lda <dmadr1
        sta dlm1
        lda >dmadr1
        sta dlm1+1
        lda <dmadr1+$0fa0
        sta dlm2
        lda >dmadr1+$0fa0
        sta dlm2+1
        rts

antici  pha
        lda RTCLK3
        lda RTCLK3
        lda RTCLK3
        lda RTCLK3
        lsr @
        lsr @
        adc VCOUNT
        asl @
        sta COLPF2
        pla
        rti

colon   lda VDSLSTL
        sta savanil
        lda VDSLSTH
        sta savanih
        lda <antici
        sta VDSLSTL
        lda >antici
        sta VDSLSTH
        lda #$c0
        sta NMIEN
        rts

coloff  lda #$40
        sta NMIEN
        lda savanil
        sta VDSLSTL
        lda savanih
        sta VDSLSTH
        rts


***************************************************
* Move routines
* 200 = $C8 lines, 40 = $28 Bytes per line

* mirrow
mirrow  lda dlm1
        sta mladr1+1
        sta mladr2+1
        sta mladr3+1
        sta mladr4+1

        lda dlm1+1
        sta mladr1+2
        sta mladr2+2
        sta mladr3+2
        sta mladr4+2

        ldy #$00
mloop2  tya
        pha

        ldx #$00
        ldy #$27

mloop1  equ *
mladr1  lda $FFFF,x
        pha
mladr2  lda $FFFF,y
* mirrow byte
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
        lsr @
        rol bufml1+1
bufml1  lda #$FF
mladr3  sta $FFFF,x

        pla
* mirrow byte
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
        lsr @
        rol bufml2+1
bufml2  lda #$FF
mladr4  sta $FFFF,y

        dey
        inx
        cpx #$14
        bne mloop1

        lda mladr1+1
        clc
        adc #$28
        sta mladr1+1
        sta mladr2+1
        sta mladr3+1
        sta mladr4+1

        lda mladr1+2
        adc #$00
        sta mladr1+2
        sta mladr2+2
        sta mladr3+2
        sta mladr4+2

        pla
        tay
        iny
        cpy #$c8
        beq mend
        jmp mloop2
mend    rts


***************************************************
* VBI routine
*

musvbi  cld
        ldx #0
munxkn  jsr muxply
        jsr muxhul
        inx
        cpx #4
        bne munxkn
        jmp XITVBV

***************************************************
* Music control switch on
*

muson   ldx #3          ;4 Register

muson1  lda #0          ;Reset POKEY and Var.
        sta AUDF1,X     ;AUDF/C 1/2
        sta AUDF1+4,X   ;AUDF/C 3/4
        sta mudur1,X    ;Duration:=0
        sta muhpt1,X    ;Huell:=BEGIN 
        lda voctbl,X    ;Note:=BEGIN
        sta mupnt1l,X
        lda voctbh,X
        sta mupnt1h,X
        dex
        bpl muson1

        lda #3          ;Reset POKEY
        sta SKCTL
        lda #0
        sta AUDCTL

        lda VBLKDV      ;Save VBI Vector
        sta savvbl
        lda VBLKDV+1
        sta savvbh

        ldy <musvbi    ;Set VBI Vector
        ldx >musvbi
        lda #7
        jsr SETVBV

        rts

***************************************************
* Music control switch off
*

musoff  ldy savvbl      ;alter VBI-Vektor, LSB
        ldx savvbh      ;MSB
        lda #7          ;fuer Deferred VBI
        jsr SETVBV      ;>>>

        lda #0          ;Sound aus !
        ldx #3          ;alle 4 Kanaele
musof1  sta AUDF1,X     ;AUDF/C 1/2
        sta AUDF1+4,X   ;AUDF/C 3/4
        dex             ;schon alle vier
        bpl musof1      ;nein, weiter ->

        rts

***************************************************
* Einen Kanal spielen
* pruefen der Tondauer, evtl. neue Note besorgen,
* Test auf ENDE, START, PAUSE
*

muxply  lda mudur1,X    ;ist Kanal noch aktiv?
        beq muxneu      ;nein, dann neue Note

        dec mudur1,X    ;sonst nur Tondauer - 1
        bne muxpen      ;Ton laeuft noch --->

muxneu  lda #0          ;Flag fuer Pause vorerst
        sta mupau1,X    ;zuruecknehmen
        sta muhpt1,X    ;Huellk. Zeiger auf Anf. 

        lda mupnt1l,X   ;Zeiger in Noten- 
        sta muxnadr+1   ;tabelle     
        lda mupnt1h,X       
        sta muxnadr+2
muxnadr lda $ffff       ;Tonhoehe der Note
        cmp #begin      ;ist START-Befehl?
        bne muxn1       ;nein ->

        lda voctbl,X    ;Notenzeiger auf Tabellen-
        sta mupnt1l,X   ;anfang richten
        lda voctbh,X
        sta mupnt1h,X

        jmp muxneu      ;und von Vorne ==>

muxn1   cmp #thend      ;ist ENDE-Befehl?
        beq muxpau      ;ja, dann Pause imitieren ->

        pha             ;Tonhoehe merken
        lda #$01        ;Dauer aus Notentabelle
        clc
        adc mupnt1l,x
        sta mupnt1l,x
        sta muxdadr+1
        lda #$00
        adc mupnt1h,x
        sta mupnt1h,x
        sta muxdadr+2
muxdadr lda $ffff       ; Dauer lesen
        sta mudur1,X    ;in Zaehler f. Notendauer

        lda #$01        ;Noten Zeiger auf
        clc             ;naechste Note
        adc mupnt1l,X
        sta mupnt1l,X
        lda #$00
        adc mupnt1h,X
        sta mupnt1h,X

        txa             ;fuer POKEY Adressen
        asl @           ;Index mal 2
        tay
        pla             ;Tonhoehe wieder holen
        cmp #pause      ;war es ein PAUSE Befehl?
        beq muxpau      ;ja ,dann Pausenbearbeitung

        sta AUDF1,Y     ;sonst Note an POKEY
muxpen  rts

muxpau  lda #pause      ;Huellk. ausschalten
        sta mupau1,X
        rts

***************************************************
* Huellkurvengenerator
* Lautstaerke fuer einen Kanal wird gemaess
* Huellkurve eingestellt
*

muxhul  lda mupau1,X    ;Flag fuer Pause?
        cmp #pause      ;Ist auf Pause?
        bne muxh1       ;nein -> normale Huellk.

        lda #0          ;Pause: Lautstaerke auf Null
        pha             ;Lautstaerke merken
        beq muxh2       ;(immer!) an Pokey ->

muxh1   lda mhltbl,X    ;Huellkurven Basisadresse
        sta muxhadr+1   ;in Zeropage Register
        lda mhltbh,X    ;MSB
        sta muxhadr+2
        ldy muhpt1,X    ;aktueller Zeiger in Hk.
muxhadr lda $ffff,Y     ;neuer Stuetzpunkt
        cmp #thend      ;ist Huellk. zu Ende?
        beq muxhen      ;ja, dann fertig!

        pha             ;Stuetzpunkt merken          
        iny             ;HK-Zeiger weiterschalten    
        tya             ;und abspeichern              
        sta muhpt1,X

muxh2   txa             ;Offset fuer Pokey-Register
        asl @           ;Index mal 2
        tay
        pla             ;Hk-Stuetzpunkt
        ora #%10100000  ;POKEY-Modus: reiner Ton   
        sta AUDC1,Y     ;an POKEY geben            

muxhen  rts


***************************************************
* Variables
*

dlsavls dta b($00)               ;Old DL LSB
dlsavhs dta b($00)               ;OLd DL MSB

mupnt1l dta b($00,$00,$00,$00)   ;Note table Low
mupnt1h dta b($00,$00,$00,$00)   ;Note table High

mudur1  dta b($00,$00,$00,$00)   ;Counter duration  
mupau1  dta b($00,$00,$00,$00)   ;Flag for Pause        
muhpt1  dta b($00,$00,$00,$00)   ;Huell Curve
savvbl  dta b($00)               ;Old VBI LSB
savvbh  dta b($00)               ;Old BLI LSB

***************************************************
* Base Address for Note and Huell table
*

voctbl  dta l(voice1,voice2,voice3,voice4)
voctbh  dta h(voice1,voice2,voice3,voice4)
mhltbl  dta l(huell1,huell2,huell3,huell4)
mhltbh  dta h(huell1,huell2,huell3,huell4)

***************************************************
* Note Table
*

        icl 'RAINBOW1.ICL'
        icl 'RAINBOW2.ICL'
        icl 'RAINBOW3.ICL'
        icl 'RAINBOW4.ICL'

***************************************************
* Huell Curve Table
*

huell1  equ *
huell2  equ *
huell3  equ *
huell4  equ *
        dta b(7,10,10,10,8,9,6,7)
        dta b(4,4,5,5,5,2,2,2,3,3,3,1,1,1,0,thend)

*        dta b(2,6,10,10,9,8,7,6
*        dta b(5,5,4,4,4,3,2,2,2,1,0,thend)

***********************************************************
* Display List
*
        blk dos $2f00
dladr   dta b($70,$70)
        dta b($20, $80)
        dta b($cf)
dlm1    dta a(dmadr1)

        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)

        dta b($cf)
dlm2    dta a(dmadr1+$0fa0)

        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)
        dta b($8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f)

        dta b($41),a(dladr)

***********************************************************
*  Display Memory
*
        blk dos $3000+$60
dmadr1  equ *
        ins 'KRISTIN.AT8'

        blk dos $5000+$60
dmadr2  equ *
        ins 'ISABEL3.AT8'

        blk dos $7000+$60
dmadr3  equ *
        ins 'TOBIAS.AT8'

        blk dos $9000+$60
dmadr4  equ *
        ins 'HOLGER.AT8'


***********************************************************
*  top address for initial mem check
mytopadr equ *

***********************************************************
*  Run address
*
        blk dos RUNAD
        dta a(start)

        end
