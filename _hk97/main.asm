; ===========================================================================
; Hong Kong 97
; ===========================================================================

HK97_Dead		EQU	$FFFFC960
HK97_Pal_Change		EQU	$FFFFC961
HK97_Chin_Frame		EQU	$FFFFC964
HK97_Bullet_Count	EQU	$FFFFC966
HK97_Car_Count		EQU	$FFFFC968
HK97_Boss_Active	EQU	$FFFFC96A

; ===========================================================================

HongKong97:
		jsr	CBSnd_Stop
		stopDAC
		moveq	#$FFFFFF81,d0
		jsr	PlaySample

		jsr	Pal_FadeFrom
		jsr	ClearScreen
		jsr	ClearPLC

		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

@ClearObjects:
		move.l	d0,(a1)+
		dbf	d1,@ClearObjects

		moveq	#$1B,d0
		jsr	PalLoad1

		lea	(MapUnc_HK97Title).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		lea	(ArtNem_HK97Title).l,a0
		jsr	NemDec

		jsr	Pal_FadeTo

@TitleLoop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		tst.b	($FFFFF605).w
		beq.s	@TitleLoop

; ===========================================================================

		jsr	Pal_FadeFrom
		jsr	ClearScreen

		moveq	#$1C,d0
		jsr	PalLoad1

		lea	(MapUnc_HK97Intro1).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		lea	(ArtNem_HK97Intro1).l,a0
		jsr	NemDec

		jsr	Pal_FadeTo

@Intro1Loop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		tst.b	($FFFFF605).w
		beq.s	@Intro1Loop

; ===========================================================================

		jsr	Pal_FadeFrom
		jsr	ClearScreen

		moveq	#$1D,d0
		jsr	PalLoad1

		lea	(MapUnc_HK97Intro2).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		lea	(ArtNem_HK97Intro2).l,a0
		jsr	NemDec

		jsr	Pal_FadeTo

@Intro2Loop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		tst.b	($FFFFF605).w
		beq.s	@Intro2Loop

; ===========================================================================

		jsr	Pal_FadeFrom
		jsr	ClearScreen

		moveq	#$1E,d0
		jsr	PalLoad1

		lea	(MapUnc_HK97Intro3).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		lea	(ArtNem_HK97Intro3).l,a0
		jsr	NemDec

		jsr	Pal_FadeTo

@Intro3Loop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		tst.b	($FFFFF605).w
		beq.s	@Intro3Loop

; ===========================================================================

		jsr	Pal_FadeFrom
		jsr	ClearScreen

		moveq	#$1F,d0
		jsr	PalLoad1

		lea	(MapUnc_HK97Intro4).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		lea	(ArtNem_HK97Intro4).l,a0
		jsr	NemDec

		jsr	Pal_FadeTo

@Intro4Loop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		tst.b	($FFFFF605).w
		beq.s	@Intro4Loop

; ===========================================================================

		jsr	Pal_FadeFrom
		jsr	ClearScreen

		moveq	#$20,d0
		jsr	PalLoad1

		jsr	(RandomNumber).l
		andi.l	#7,d0
		cmpi.w	#5,d0
		ble.s	@NoCap
		subq.w	#5,d0

@NoCap:
		bra.s	@LoadBackground

; ===========================================================================

@Backgrounds:
		dc.l	ArtNem_HK97LevelBG1, MapUnc_HK97LevelBG1
		dc.l	ArtNem_HK97LevelBG2, MapUnc_HK97LevelBG2
		dc.l	ArtNem_HK97LevelBG3, MapUnc_HK97LevelBG3
		dc.l	ArtNem_HK97LevelBG4, MapUnc_HK97LevelBG4
		dc.l	ArtNem_HK97LevelBG5, MapUnc_HK97LevelBG5
		dc.l	ArtNem_HK97LevelBG6, MapUnc_HK97LevelBG6

; ===========================================================================

@LoadBackground:
		mulu.w	#8,d0
		movea.l	@Backgrounds(pc,d0.w),a0
		addq.w	#4,d0
		movea.l	@Backgrounds(pc,d0.w),a1

		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		jsr	ShowVDPGraphics

		move.l	#$40000000,($C00004).l
		jsr	NemDec

		moveq	#$23,d0
		jsr	LoadPLC

@WaitPLC:
		move.b	#$C,($FFFFF62A).w
		jsr	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	RunPLC_RAM
		tst.l	($FFFFF680).w	; are there any	items in the pattern load cue?
		bne.s	@WaitPLC	; if yes, branch

		moveq	#$23,d0
		jsr	PalLoad1
		moveq	#$24,d0
		jsr	PalLoad1

		move.b	#2,($FFFFD000).w

		move.b	#5,($FFFFD040).w
		move.b	#0,($FFFFD068).w

		move.b	#5,($FFFFD080).w
		move.b	#1,($FFFFD0A8).w

		move.b	#5,($FFFFD0C0).w
		move.b	#2,($FFFFD0E8).w

		move.b	#5,($FFFFD100).w
		move.b	#3,($FFFFD128).w

		move.b	#0,(HK97_Dead).w
		move.b	#0,(HK97_Pal_Change).w
		move.b	#0,(HK97_Bullet_Count).w
		move.b	#0,(HK97_Car_Count).w
		move.b	#0,(HK97_Boss_Active).w

		jsr	Pal_FadeTo

@LevelLoop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	RunPLC_RAM

		tst.b	(HK97_Pal_Change).w
		beq.s	@NoPalLoad
		moveq	#$20,d0
		cmpi.b	#1,(HK97_Pal_Change).w
		bne.s	@LoadPal
		moveq	#$21,d0

@LoadPal:
		jsr	PalLoad2
		move.b	#0,(HK97_Pal_Change).w

@NoPalLoad:
		tst.b	(HK97_Dead).w
		beq.s	@LevelLoop
		move.b	#0,(BSOD_Type).w
		jsr	BSODError

@WaitBSOD:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		andi.b	#$80,($FFFFF605).w
		beq.s	@WaitBSOD
		jmp	HongKong97

; ===========================================================================
; Chin object
; ===========================================================================

ObjChin:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjChin_Index(pc,d0.w),d1
		jmp	ObjChin_Index(pc,d1.w)

; ===========================================================================

ObjChin_Index:
		dc.w	ObjChin_Init-ObjChin_Index
		dc.w	ObjChin_Main-ObjChin_Index

; ===========================================================================

ObjChin_Init:
		addq.b	#2,$24(a0)
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_ObjChin,4(a0)
		move.w	#$2780,2(a0)
		move.b	#2,$18(a0)
		move.b	#$10,$19(a0)
		move.b	#4,1(a0)
		move.w	#156,8(a0)
		move.w	#184,$C(a0)

; ===========================================================================

ObjChin_Main:
		jsr	SpeedToPos
		move.b	($FFFFF604).w,d0
		btst	#1,d0
		beq.s	@CheckUp
		bclr	#0,$22(a0)
		move.w	#$200,$12(a0)
		move.b	#1,$1C(a0)
		bra.s	@CheckRight

@CheckUp:
		btst	#0,d0
		beq.s	@StopY
		bclr	#0,$22(a0)
		move.w	#-$200,$12(a0)
		move.b	#2,$1C(a0)
		bra.s	@CheckRight

@StopY:
		move.w	#0,$12(a0)

@CheckRight:
		btst	#3,d0
		beq.s	@CheckLeft
		bclr	#0,$22(a0)
		move.w	#$200,$10(a0)
		move.b	#3,$1C(a0)
		bra.s	@CheckShoot

@CheckLeft:
		btst	#2,d0
		beq.s	@StopX
		bset	#0,$22(a0)
		move.w	#-$200,$10(a0)
		move.b	#3,$1C(a0)
		bra.s	@CheckShoot

@StopX:
		move.w	#0,$10(a0)
		tst.w	$12(a0)
		bne.s	@CheckShoot
		bclr	#0,$22(a0)
		move.b	#0,$1C(a0)

@CheckShoot:
		cmpi.b	#4,(HK97_Bullet_Count).w
		bge.s	@CheckLeftBound
		move.b	($FFFFF605).w,d0
		btst	#6,d0
		beq.s	@CheckLeftBound
		jsr	SingleObjLoad
		bne.s	@CheckLeftBound
		move.b	#3,(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		subq.w	#8,$C(a1)

@CheckLeftBound:
		cmpi.w	#8,8(a0)
		bgt.s	@CheckRightBound
		move.w	#8,8(a0)

@CheckRightBound:
		cmpi.w	#320-8,8(a0)
		blt.s	@CheckTopBound
		move.w	#320-8,8(a0)

@CheckTopBound:
		cmpi.w	#8,$C(a0)
		bgt.s	@CheckBottomBound
		move.w	#8,$C(a0)

@CheckBottomBound:
		cmpi.w	#224-8-16,$C(a0)
		blt.s	@CheckCollision
		move.w	#224-8-16,$C(a0)

@CheckCollision:
		jsr	HK97_CheckObjCol
		tst.b	$2A(a0)
		bne.s	@Invincible
		tst.b	$2B(a0)
		beq.s	@Animate
		move.b	#1,(HK97_Dead).w
		bra.s	@Animate

@Invincible:
		subq.w	#1,$2C(a0)
		bpl.s	@Animate
		move.b	#0,$2A(a0)

@Animate:
		lea	(Ani_ObjChin).l,a1
		jsr	AnimateSprite
		jsr	LoadChinDynPLC
		tst.b	$2A(a0)
		beq.s	@Display
		move.w	$2C(a0),d0
		lsr.w	#3,d0
		bcc.s	@End

@Display:
		jmp	DisplaySprite

@End:
		rts

; ===========================================================================
; Load Chin's DPLCs
; ===========================================================================

LoadChinDynPLC:
		moveq	#0,d0
		move.b	$1A(a0),d0	; load frame number
		cmp.b	(HK97_Chin_Frame).w,d0
		beq.s	locret2_13C96
		move.b	d0,(HK97_Chin_Frame).w
		lea	(ChinDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret2_13C96
		move.w	#$F000,d4
		move.l	#Art_Chin,d6

CPLCReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,CPLCReadEntry	; repeat for number of entries

locret2_13C96:
		rts

; ===========================================================================

Ani_ObjChin:
		dc.w	@0-Ani_ObjChin
		dc.w	@1-Ani_ObjChin
		dc.w	@2-Ani_ObjChin
		dc.w	@3-Ani_ObjChin
@0:
		dc.b	1, 1, $FF
@1:
		dc.b	3, 1, 2, $FF
@2:
		dc.b	3, 3, 4, $FF
@3:
		dc.b	3, 5, 6, 7, 8, 9, 8, 7, 6, $FF
		even

; ===========================================================================

Art_Chin:
		incbin	"_hk97/artunc/chin.bin"
		even
Map_ObjChin:
		include	"_hk97/mapspr/chin.asm"
		even
Pal_HK97Level:
		incbin	"_hk97/palette/level.bin"
		even
ChinDynPLC:
		include	"_hk97/mapspr/chindplc.asm"
		even

; ===========================================================================
; Bullet object
; ===========================================================================

ObjBullet:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjBullet_Index(pc,d0.w),d1
		jmp	ObjBullet_Index(pc,d1.w)

; ===========================================================================

ObjBullet_Index:
		dc.w	ObjBullet_Init-ObjBullet_Index
		dc.w	ObjBullet_Main-ObjBullet_Index

; ===========================================================================

ObjBullet_Init:
		addq.b	#2,$24(a0)
		tst.b	$28(a0)
		bne.s	@Enemy
		addq.b	#1,(HK97_Bullet_Count).w

@Enemy:
		move.b	#4,$16(a0)
		move.b	#4,$17(a0)
		move.l	#Map_ObjBullet,4(a0)
		move.w	#$2790,2(a0)
		tst.b	$28(a0)
		beq.s	@NotEnemy
		move.w	#$2792,2(a0)

@NotEnemy:
		move.b	#2,$18(a0)
		move.b	#8,$19(a0)
		move.b	#4,1(a0)
		move.b	#0,$1A(a0)
		move.b	#1,$20(a0)
		tst.b	$28(a0)
		beq.s	@NotEnemy2
		move.b	#3,$20(a0)

@NotEnemy2:
		move.w	#-$400,d0
		tst.b	$28(a0)
		beq.s	@NotEnemy3
		move.w	#$400,d0

@NotEnemy3:
		move.w	d0,$12(a0)

; ===========================================================================

ObjBullet_Main:
		tst.b	$2A(a0)
		bne.s	@Delete
		cmpi.w	#-8,$C(a0)
		ble.s	@Delete
		cmpi.w	#224+8,$C(a0)
		bge.s	@Delete
		jsr	SpeedToPos
		jmp	DisplaySprite

@Delete:
		tst.b	$28(a0)
		bne.s	@Enemy
		subq.b	#1,(HK97_Bullet_Count).w

@Enemy:
		jmp	DeleteObject

; ===========================================================================
; Ugly red object
; ===========================================================================

ObjUglyRed:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjUglyRed_Index(pc,d0.w),d1
		jmp	ObjUglyRed_Index(pc,d1.w)

; ===========================================================================

ObjUglyRed_Index:
		dc.w	ObjUglyRed_Init-ObjUglyRed_Index
		dc.w	ObjUglyRed_Main-ObjUglyRed_Index
		dc.w	ObjUglyRed_Accel-ObjUglyRed_Index

; ===========================================================================

ObjUglyRed_Init:
		addq.b	#2,$24(a0)
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_ObjUglyRed,4(a0)
		move.w	#$2450,2(a0)
		tst.b	$28(a0)
		beq.s	@GotBaseTile
		move.w	#$2420,2(a0)
		cmpi.b	#2,$28(a0)
		bne.s	@GotBaseTile
		move.w	#$23F0,2(a0)

@GotBaseTile:
		move.b	#2,$18(a0)
		move.b	#$10,$19(a0)
		move.b	#4,1(a0)
		move.b	#1,$1C(a0)
		move.b	#2,$20(a0)
		jsr	(RandomNumber).l
		andi.l	#$FFF,d0
		asr.l	#4,d0
		cmpi.w	#320-16,d0
		ble.s	@CheckLeft
		asr.w	#2,d0

@CheckLeft:
		tst.w	d0
		bpl.s	@SetX
		addi.w	#100,d0

@SetX:
		addq.w	#8,d0
		move.w	d0,8(a0)

		tst.b	$28(a0)
		beq.s	ObjUglyRed_Main
		cmpi.b	#1,$28(a0)
		beq.s	@MoveRight
		move.w	#-$10,$C(a0)
		move.w	8(a0),d1
		move.w	($FFFFD008).w,d2
		move.w	#$200,d0
		cmp.w	d2,d1
		bgt.s	@SetXVel
		move.w	#-$200,d0
		bra.s	@SetXVel

@MoveRight:
		move.w	#$200,d0

@SetXVel:
		move.w	d0,$10(a0)

; ===========================================================================

ObjUglyRed_Main:
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	ObjUglyRed_Subtypes(pc,d0.w),d1
		jmp	ObjUglyRed_Subtypes(pc,d1.w)

; ===========================================================================

ObjUglyRed_Subtypes:
		dc.w	ObjUglyRed_Subtype0-ObjUglyRed_Subtypes
		dc.w	ObjUglyRed_Subtype1-ObjUglyRed_Subtypes
		dc.w	ObjUglyRed_Subtype2-ObjUglyRed_Subtypes

; ===========================================================================

ObjUglyRed_Subtype0:
		jsr	SpeedToPos
		move.w	#$180,$12(a0)
		tst.b	$3A(a0)
		bne.s	@ObjCollide

		move.w	($FFFFD00C).w,d0
		move.w	$C(a0),d1
		subi.w	#$30,d0
		cmp.w	d1,d0
		blt.s	@ObjCollide

		move.w	($FFFFD008).w,d0
		move.w	8(a0),d1
		move.w	d1,d3
		move.b	($FFFFD017).w,d2
		ext.w	d2
		sub.w	d2,d0
		add.w	d2,d3
		cmp.w	d1,d0
		bgt.s	@ObjCollide
		cmp.w	d1,d3
		blt.s	@ObjCollide

		jsr	SingleObjLoad
		bne.s	@ObjCollide
		move.b	#3,(a1)
		move.b	#1,$28(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#1,$3A(a0)

@ObjCollide:
		bra.w	ObjUglyRed_ObjCollide

; ===========================================================================

ObjUglyRed_Subtype1:
		jsr	SpeedToPos
		move.w	#$200,$12(a0)
		move.b	#1,$2D(a0)
		tst.w	$10(a0)
		bpl.s	@GetAccel
		move.b	#0,$2D(a0)

@GetAccel:
		tst.b	$2D(a0)
		bne.s	@Left
		move.w	#$80,$2E(a0)
		move.b	#4,$24(a0)
		bra.s	@CheckShoot

@Left:
		move.w	#-$80,$2E(a0)
		move.b	#4,$24(a0)

@CheckShoot:
		tst.b	$3A(a0)
		bne.s	@ObjCollide

		move.w	($FFFFD00C).w,d0
		move.w	$C(a0),d1
		subi.w	#$30,d0
		cmp.w	d1,d0
		blt.s	@ObjCollide

		move.w	($FFFFD008).w,d0
		move.w	8(a0),d1
		move.w	d1,d3
		move.b	($FFFFD017).w,d2
		ext.w	d2
		sub.w	d2,d0
		add.w	d2,d3
		cmp.w	d1,d0
		bgt.s	@ObjCollide
		cmp.w	d1,d3
		blt.s	@ObjCollide

		jsr	SingleObjLoad
		bne.s	@ObjCollide
		move.b	#3,(a1)
		move.b	#1,$28(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#1,$3A(a0)

@ObjCollide:
		bra.w	ObjUglyRed_ObjCollide

; ===========================================================================

ObjUglyRed_Subtype2:
		jsr	SpeedToPos
		move.w	#$200,$12(a0)
		move.b	#1,$2D(a0)
		tst.w	$10(a0)
		bpl.s	@GetAccel
		move.b	#0,$2D(a0)

@GetAccel:
		moveq	#0,d1
		moveq	#0,d2
		move.w	8(a0),d1
		move.w	($FFFFD008).w,d2
		tst.b	$2D(a0)
		bne.s	@Left
		cmpi.w	#16,8(a0)
		ble.s	@CheckShoot
		cmp.w	d1,d2
		blt.w	ObjUglyRed_ObjCollide

@CheckShoot:
		move.w	#$30,$2E(a0)
		move.b	#4,$24(a0)
		jsr	SingleObjLoad
		bne.s	@ObjCollide
		move.b	#3,(a1)
		move.b	#1,$28(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

@ObjCollide:
		bra.s	ObjUglyRed_ObjCollide

@Left:
		cmpi.w	#320-16,8(a0)
		bge.s	@CheckShoot2
		cmp.w	d1,d2
		bgt.s	ObjUglyRed_ObjCollide

@CheckShoot2:
		move.w	#-$30,$2E(a0)
		move.b	#4,$24(a0)
		jsr	SingleObjLoad
		bne.s	@ObjCollide2
		move.b	#3,(a1)
		move.b	#1,$28(a1)
		move.w	8(a0),8(a1)
		subq.w	#4,8(a1)
		move.w	$C(a0),$C(a1)

@ObjCollide2:
		bra.s	ObjUglyRed_ObjCollide
; ===========================================================================

ObjUglyRed_Accel:
		jsr	SpeedToPos
		move.w	$2E(a0),d0
		add.w	d0,$10(a0)
		move.w	$10(a0),d0
		tst.w	d0
		bpl.s	@NoNeg
		neg.w	d0

@NoNeg:
		move.w	#$200,d1
		cmpi.b	#1,$28(a0)
		bne.s	@NotHoming
		move.w	#$500,d1

@NotHoming:
		cmp.w	d1,d0
		bge.s	@MaxedVel
		bra.s	ObjUglyRed_ObjCollide

@MaxedVel:
		move.b	#2,$24(a0)

; ===========================================================================

ObjUglyRed_ObjCollide:
		jsr	HK97_CheckObjCol
		tst.b	$2A(a0)
		beq.s	@Animate
		jsr	(RandomNumber).l
		andi.l	#$F,d0
		tst.b	d0
		bne.s	@CheckBomb
		jsr	SingleObjLoad
		bne.s	@CheckBomb
		move.b	#$8D,(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		bra.s	@Explode

@CheckBomb:
		jsr	(RandomNumber).l
		andi.l	#5,d0
		cmpi.b	#1,d0
		bne.s	@Explode
		jsr	SingleObjLoad
		bne.s	@Explode
		move.b	#$8D,(a1)
		move.b	#1,$28(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

@Explode:
		move.b	#6,(a0)
		move.b	#0,$24(a0)
		rts

@Animate:
		cmpi.w	#224+16,$C(a0)
		bge.s	@Delete
		lea	(Ani_ObjChin).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite

@Delete:
		jmp	DeleteObject

; ===========================================================================
; Spawner object
; ===========================================================================

ObjHK97Spawner:
		tst.b	(HK97_Boss_Active).w
		bne.s	@End
		cmpi.b	#3,$28(a0)
		beq.s	@CarSpawner
		tst.b	$2E(a0)
		beq.s	@ResetTimer
		subq.w	#1,$2C(a0)
		bpl.s	@End
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#4,(a1)
		move.b	$28(a0),$28(a1)

@ResetTimer:
		jsr	(RandomNumber).l
		tst.b	$2E(a0)
		bne.s	@CheckMax
		andi.l	#3,d0
		bra.s	@CheckMin

@CheckMax:
		andi.l	#7,d0
		cmpi.b	#4,d0
		ble.s	@CheckMin
		move.b	#4,d0

@CheckMin:
		cmpi.b	#1,d0
		ble.s	@SetTimer
		move.b	#2,d0

@SetTimer:
		mulu.w	#60,d0
		move.w	d0,$2C(a0)
		move.b	#1,$2E(a0)

@End:
		rts

@CarSpawner:
		tst.b	$2E(a0)
		beq.s	@ResetTimer2
		subq.w	#1,$2C(a0)
		bpl.s	@End
		move.b	#7,($FFFFD140).w
		move.b	#0,($FFFFD164).w
		addq.b	#1,(HK97_Car_Count).w
		cmpi.b	#4,(HK97_Car_Count).w
		blt.s	@ResetTimer2
		move.b	#1,($FFFFD168).w
		move.b	#1,(HK97_Pal_Change).w
		move.b	#1,(HK97_Boss_Active).w

@ResetTimer2:
		move.b	#1,$2E(a0)
		move.w	#7*60,$2C(a0)
		rts

; ===========================================================================
; Check object collision
; ===========================================================================

HK97_CheckObjCol:
		nop
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		lea	($FFFFD040).w,a1
		move.w	#$5F,d6

@ObjLoop:
		move.b	(a0),d0
		move.b	(a1),d1
		cmp.b	d0,d1
		beq.s	@NextObj
		tst.b	$20(a1)
		bne.s	@ProcessObj

@NextObj:
		lea	$40(a1),a1
		dbf	d6,@ObjLoop
		moveq	#0,d0
		rts

@ProcessObj:
		move.b	$16(a0),d2
		ext.w	d2
		move.w	$C(a0),d3
		move.w	d3,d4
		sub.w	d2,d3
		add.w	d2,d4
		move.b	$16(a1),d5
		ext.w	d5
		move.w	$C(a1),d2
		move.w	d2,d1
		sub.w	d5,d1
		add.w	d5,d2
		cmp.w	d2,d3
		bgt.w	@NextObj
		cmp.w	d1,d4
		blt.w	@NextObj

		move.b	$17(a0),d2
		ext.w	d2
		move.w	$8(a0),d3
		move.w	d3,d4
		sub.w	d2,d3
		add.w	d2,d4
		move.b	$17(a1),d5
		ext.w	d5
		move.w	8(a1),d2
		move.w	d2,d1
		sub.w	d5,d1
		add.w	d5,d2
		cmp.w	d2,d3
		bgt.w	@NextObj
		cmp.w	d1,d4
		blt.w	@NextObj

		cmpi.b	#7,(a0)
		beq.s	@Enemy
		cmpi.b	#4,(a0)
		bne.s	@NotEnemy

@Enemy:
		cmpi.b	#1,$20(a1)
		beq.s	@HitChinBullet
		rts

@NotEnemy:
		cmpi.b	#2,$20(a1)
		beq.s	@HitEnemy
		cmpi.b	#3,$20(a1)
		beq.s	@HitEnemyBullet
		cmpi.b	#4,$20(a1)
		beq.s	@HitSyringe
		rts

@HitEnemy:
		tst.b	$2A(a0)
		bne.s	@End
		move.b	#1,$2B(a0)

@End:
		rts

@HitChinBullet:
		move.b	#1,$2A(a0)
		move.b	#1,$2A(a1)
		rts

@HitSyringe:
		move.b	#1,$2A(a0)
		move.w	#10*60,$2C(a0)
		move.b	#1,$2A(a1)
		rts

@HitEnemyBullet:
		tst.b	$2A(a0)
		bne.s	@End
		move.b	#1,$2B(a0)
		move.b	#1,$2A(a1)
		rts

; ===========================================================================
; Explosion object
; ===========================================================================

ObjHK97Explosion:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjHK97Explosion_Index(pc,d0.w),d1
		jmp	ObjHK97Explosion_Index(pc,d1.w)

; ===========================================================================

ObjHK97Explosion_Index:
		dc.w	ObjHK97Explosion_Init-ObjHK97Explosion_Index
		dc.w	ObjHK97Explosion_Main-ObjHK97Explosion_Index

; ===========================================================================

ObjHK97Explosion_Init:
		addq.b	#2,$24(a0)
		move.b	#$10,$16(a0)
		move.b	#$10,$17(a0)
		move.l	#Map_ObjHK97Explosion,4(a0)
		move.w	#$2460,2(a0)
		move.b	#1,$18(a0)
		move.b	#$20,$19(a0)
		move.b	#4,1(a0)
		move.b	#0,$20(a0)

; ===========================================================================

ObjHK97Explosion_Main:
		subq.b	#1,$1E(a0)
		bpl.s	@Display
		move.b	#5,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#5,$1A(A0)
		beq.w	@Delete

@Display:
		jmp	DisplaySprite

@Delete:
		jmp	DeleteObject

; ===========================================================================
; Car/boss object
; ===========================================================================

ObjHK97CarBoss:
		tst.b	$28(a0)
		bne.w	ObjHK97Boss

ObjHK97Car:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjHK97Car_Index(pc,d0.w),d1
		jmp	ObjHK97Car_Index(pc,d1.w)

; ===========================================================================

ObjHK97Car_Index:
		dc.w	ObjHK97Car_Init-ObjHK97Car_Index
		dc.w	ObjHK97Car_Main-ObjHK97Car_Index

; ===========================================================================

ObjHK97Car_Init:
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#$1E,$17(a0)
		move.l	#Map_ObjHK97Car,4(a0)
		move.w	#$2680,2(a0)
		move.b	#2,$18(a0)
		move.b	#$3C,$19(a0)
		move.b	#4,1(a0)
		move.w	#-$180,$10(a0)
		move.b	#2,$20(a0)

		jsr	RandomNumber
		andi.l	#3,d0
		tst.w	d0
		bne.s	@NoCap
		move.w	#2,d0

@NoCap:
		mulu.w	#87,d0
		move.w	d0,$C(a0)
		move.w	#320+48,8(a0)

; ===========================================================================

ObjHK97Car_Main:
		jsr	SpeedToPos
		move.w	($FFFFD008).w,d0
		move.w	8(a0),d1
		cmp.w	d1,d0
		blt.s	@Display
		move.w	#-$300,$10(a0)

@Display:
		cmpi.w	#-48,8(a0)
		ble.s	@Delete
		jmp	DisplaySprite

@Delete:
		jmp	DeleteObject

; ===========================================================================

ObjHK97Boss:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjHK97Boss_Index(pc,d0.w),d1
		jmp	ObjHK97Boss_Index(pc,d1.w)

; ===========================================================================

ObjHK97Boss_Index:
		dc.w	ObjHK97Boss_Init-ObjHK97Boss_Index
		dc.w	ObjHK97Boss_Main-ObjHK97Boss_Index
		dc.w	ObjHK97Boss_Slam-ObjHK97Boss_Index
		dc.w	ObjHK97Boss_Dead-ObjHK97Boss_Index

; ===========================================================================

ObjHK97Boss_Init:
		addq.b	#2,$24(a0)
		move.b	#$28,$16(a0)
		move.b	#$24,$17(a0)
		move.l	#Map_ObjHK97Boss,4(a0)
		move.w	#$44A0,2(a0)
		move.b	#2,$18(a0)
		move.b	#$48,$19(a0)
		move.b	#4,1(a0)
		move.b	#2,$20(a0)

		move.w	#160,8(a0)
		move.w	#72,$C(a0)
		move.b	#-1,$2E(a0)
		move.b	#25,$2C(a0)
		move.b	#0,$34(a0)
		move.b	#$20,$32(a0)
		move.w	#-$100,$10(a0)

; ===========================================================================

ObjHK97Boss_Main:
		tst.b	$34(a0)
		bne.s	@Main
		subq.b	#1,$2C(a0)
		bpl.s	@Delay
		move.b	#1,$34(a0)

@Delay:
		jmp	ObjHK97Boss_ObjCollide

@Main:
		jsr	SpeedToPos
		jsr	ObjHK97Boss_Hover
		cmpi.w	#40,8(a0)
		bgt.s	@CheckRightBound
		neg.w	$10(a0)

@CheckRightBound:
		cmpi.w	#$118,8(a0)
		blt.s	@CheckSlam
		neg.w	$10(a0)

@CheckSlam:
		move.w	($FFFFD008).w,d0
		move.w	8(a0),d1
		move.w	d1,d2
		move.b	$17(a0),d3
		ext.w	d3
		lsr.w	#1,d3
		sub.w	d3,d1
		add.w	d3,d2
		cmp.w	d0,d1
		bgt.w	ObjHK97Boss_ObjCollide
		cmp.w	d0,d2
		blt.w	ObjHK97Boss_ObjCollide
		move.w	$10(a0),$30(a0)
		move.w	#0,$10(a0)
		move.b	#$19,$2C(a0)
		move.b	#4,$24(a0)
		jmp	ObjHK97Boss_ObjCollide

; ===========================================================================

ObjHK97Boss_Slam:
		jsr	SpeedtoPos
		cmpi.b	#3,$2D(a0)
		beq.s	@CheckSlamDone
		cmpi.b	#2,$2D(a0)
		beq.s	@CheckMoveUp
		tst.b	$2D(a0)
		bne.s	@CheckBottom
		jsr	ObjHK97Boss_Hover
		subq.b	#1,$2C(a0)
		bpl.s	ObjHK97Boss_ObjCollide
		move.w	#$C00,$12(a0)
		move.b	#1,$2D(a0)

@CheckBottom:
		cmpi.w	#180,$C(a0)
		blt.s	ObjHK97Boss_ObjCollide
		move.b	#2,$2D(a0)
		move.w	#0,$12(a0)
		move.b	#45,$2C(a0)

@CheckMoveUp:
		subq.b	#1,$2C(a0)
		bpl.s	ObjHK97Boss_ObjCollide
		move.w	#-$100,$12(a0)

@CheckSlamDone:
		cmpi.w	#72,$C(a0)
		bgt.s	ObjHK97Boss_ObjCollide
		move.w	$30(a0),$10(a0)
		move.b	#0,$2D(a0)
		move.b	#-1,$2E(a0)
		move.b	#2,$24(a0)

; ===========================================================================

ObjHK97Boss_ObjCollide:
		jsr	HK97_CheckObjCol
		tst.b	$2A(a0)
		beq.s	ObjHK97Boss_Display
		subq.b	#1,$32(a0)
		move.b	#0,$2A(a0)
		tst.b	$32(a0)
		beq.s	@Kill
		jmp	ObjHK97Boss_Display

@Kill:
		move.b	#$50,$2C(a0)
		move.b	#6,$24(a0)

; ===========================================================================

ObjHK97Boss_Dead:
		subq.b	#1,$2C(a0)
		bpl.s	@Explode
		move.b	#0,(HK97_Car_Count).w
		move.b	#2,(HK97_Pal_Change).w
		move.b	#0,(HK97_Boss_Active).w
		jmp	DeleteObject

@Explode:
		jmp	ObjHK97Boss_Explode

ObjHK97Boss_Display:
		jmp	DisplaySprite

; ===========================================================================

ObjHK97Boss_Hover:
		move.w	$12(a0),d0
		tst.w	d0
		bpl.s	@NotNeg
		neg.w	d0

@NotNeg:
		cmpi.w	#$380,d0
		blt.s	@GetAccel
		neg.b	$2E(a0)

@GetAccel:
		move.w	#$60,d0
		tst.b	$2E(a0)
		bpl.s	@Accel
		move.w	#-$60,d0

@Accel:
		add.w	d0,$12(a0)
		rts

; ===========================================================================

ObjHK97Boss_Explode:
		moveq	#0,d0
		move.b	($FFFFFE0F).w,d0
		andi.b	#3,d0
		bne.s	@End
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#6,0(a1)	; load explosion object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	#3,d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		tst.w	d0
		bpl.s	@RandomPos
		neg.w	d0

@RandomPos:
		move.w	d0,d3
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	#$20,d1
		divu.w	d3,d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		add.w	d0,8(a1)
		swap	d0
		moveq	#0,d1
		move.b	#$20,d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		add.w	d0,$C(a1)

@End:
		rts

; ===========================================================================
; Item object
; ===========================================================================

ObjHK97Item:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjHK97Item_Index(pc,d0.w),d1
		jmp	ObjHK97Item_Index(pc,d1.w)

; ===========================================================================

ObjHK97Item_Index:
		dc.w	ObjHK97Item_Init-ObjHK97Item_Index
		dc.w	ObjHK97Item_Main-ObjHK97Item_Index

; ===========================================================================

ObjHK97Item_Init:
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_Syringe,4(a0)
		move.w	#$2503,2(a0)
		tst.b	$28(a0)
		beq.s	@NotSyringe
		move.l	#Map_ObjHK97Bomb,4(a0)
		move.w	#$2520,2(a0)

@NotSyringe:
		move.b	#2,$18(a0)
		move.b	#$10,$19(a0)
		move.b	#4,1(a0)
		move.b	#4,$20(a0)
		tst.b	$28(a0)
		beq.s	@NotSyringe2
		move.b	#1,$1C(a0)
		move.b	#3,$20(a0)

@NotSyringe2:
		move.w	#$180,$12(a0)

; ===========================================================================

ObjHK97Item_Main:
		tst.b	$2A(a0)
		beq.s	@Display
		jmp	DeleteObject

@Display:
		jsr	SpeedToPos
		lea	(Ani_ObjHK97Item).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite

; ===========================================================================

Ani_ObjHK97Item:
		dc.w	@0-Ani_ObjHK97Item
		dc.w	@1-Ani_ObjHK97Item
@0:
		dc.b	3, 1, 2, 3, 4, 5, 6, 7, 8, 9, $A, $B, $C, $FF
@1:
		dc.b	3, 1, 2, 3, 4, $FF
		even

; ===========================================================================
; Data
; ===========================================================================

Map_ObjHK97Boss:
		include	"_hk97/mapspr/boss.asm"
		even
ArtNem_ChinBullet:
		incbin	"_hk97/artnem/bulletchin.bin"
		even
ArtNem_UglyRed3:
		incbin	"_hk97/artnem/uglyred3.bin"
		even
ArtNem_UglyRed2:
		incbin	"_hk97/artnem/uglyred2.bin"
		even
ArtNem_UglyRed1:
		incbin	"_hk97/artnem/uglyred1.bin"
		even
ArtNem_HK97Boss:
		incbin	"_hk97/artnem/boss.bin"
		even
ArtNem_EnemyBullet:
		incbin	"_hk97/artnem/bulletenemy.bin"
		even
ArtNem_HK97Explosion:
		incbin	"_hk97/artnem/explosion.bin"
		even
ArtNem_HK97Car:
		incbin	"_hk97/artnem/car.bin"
		even
ArtNem_HK97Bomb:
		incbin	"_hk97/artnem/bomb.bin"
		even
Map_ObjBullet:
		include	"_hk97/mapspr/bullet.asm"
		even
Map_Syringe:
		include	"_hk97/mapspr/syringe.asm"
		even
Map_ObjHK97Bomb:
		include	"_hk97/mapspr/bomb.asm"
		even
Map_ObjHK97Explosion:
		include	"_hk97/mapspr/explosion.asm"
		even
Map_ObjUglyRed:
		include	"_hk97/mapspr/uglyred.asm"
		even
Map_ObjHK97Car:
		include	"_hk97/mapspr/car.asm"
		even
ArtNem_Syringe:
		incbin	"_hk97/artnem/syringe.bin"
		even
Pal_HK97Boss:
		incbin	"_hk97/palette/boss.bin"
		even

; ===========================================================================