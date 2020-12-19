; ===========================================================================
; Desert Bus
; ===========================================================================

DB_X_Offset		EQU	$FFFFCA90
DB_PalCyc_Index_1	EQU	$FFFFFFB0
DB_PalCyc_Index_2	EQU	$FFFFFFB2
DB_PalCyc_Index_3	EQU	$FFFFFFB4
DB_PalCyc_Index_4	EQU	$FFFFFFB6
DB_PalCyc_Index_5	EQU	$FFFFFFB8
DB_PalCyc_Index_6	EQU	$FFFFFFBA
DB_PalCyc_Index_7	EQU	$FFFFFFBE
DB_Move_Flag		EQU	$FFFFFFC0

; ===========================================================================

DesertBus:
		jsr	CBSnd_Stop
		stopZ80
		move.b	#$80,($A01FFF).l
		startZ80

		jsr	Pal_FadeFrom
		jsr	ClearPLC
		move.b	#0,(Disable_HScroll).w

		move.l	#$40000000,($C00004).l
		move.w	#$3FFF,d1

@ClearVRAM:
		move.l	#0,($C00000).l
		dbf	d1,@ClearVRAM

		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

@ClearObjects:
		move.l	d0,(a1)+
		dbf	d1,@ClearObjects

		lea	($C00004).l,a6
		move.w	#$8230,(a6)
		move.w	#$833C,(a6)
		move.w	#$8400,(a6)
		move.w	#$857C,(a6)
		move.w	#$9003,(a6)
		move.w	#$8B03,(a6)
		jsr	ClearScreen

		lea	(DesertBus_VRAM).l,a1
		move.l	#$40000000,($C00004).l
		move.w	#$7FFF,d1

@CopyVRAM:
		move.w	(a1)+,($C00000).l
		dbf	d1,@CopyVRAM

		jsr	DesertBus_HScroll

		move.w	#2,(DB_PalCyc_Index_4).w
		move.w	#1,(DB_PalCyc_Index_5).w
		move.w	#0,(DB_Move_Flag).w

		moveq	#$27,d0
		jsr	PalLoad1
		jsr	Pal_FadeTo

		moveq	#$FFFFFF84,d0
		jsr	PlaySample

@MainLoop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram
		jsr	DesertBus_HScroll
		jsr	DesertBus_PalCycle

		moveq	#0,d0
		move.b	($FFFFF604).w,d0
		btst	#2,d0
		beq.s	@CheckRight
		cmpi.l	#$CA,(DB_X_Offset).w
		bge.s	@CheckMove
		addi.l	#$50,(DB_X_Offset).w
		jmp	@CheckMove

@CheckRight:
		btst	#3,d0
		beq.s	@CheckMove
		cmpi.l	#-$A0,(DB_X_Offset).w
		ble.s	@CheckMove
		subi.l	#$50,(DB_X_Offset).w

@CheckMove:
		btst	#6,d0
		beq.s	@NoMove
		move.w	#1,(DB_Move_Flag).w
		jmp	@MainLoop

@NoMove:
		move.w	#0,(DB_Move_Flag).w
		jmp	@MainLoop

; ===========================================================================
; Handle horizontal scrolling
; ===========================================================================

DesertBus_HScroll:
		lea	($FFFFCC00).w,a1
		move.w	#$37,d1

@Sky:
		move.l	#$FEC0,(a1)+
		dbf	d1,@Sky

		move.w	#$A8,d1

@Road:
		move.l	(DB_X_Offset).w,d0
		move.l	d0,d4
		tst.l	d4
		bpl.s	@NotNeg
		neg.l	d0

@NotNeg:
		move.w	#$A8,d3
		sub.w	d1,d3
		mulu.w	d3,d0
		lsr.l	#7,d0
		tst.l	d4
		bpl.s	@NotNeg2
		neg.l	d0

@NotNeg2:
		subi.l	#$1B8,d0
		andi.w	#$FFFF,d0
		move.l	d0,(a1)+
		dbf	d1,@Road

		rts

; ===========================================================================
; Palette
; ===========================================================================

Pal_DesertBus:
		dc.w	$262,$C,$80,$666,$60,$20,$EEE,8,6,4,2,$AAA,$888,$444,$222,0
		dc.w	$282,$68,$222,$68,$68,$68,$28C,$68,$46,$68,$28C,$28C,$28C,$68,$68,$666
		dc.w	$282,$68,$68,$68,$222,$68,$68,$28C,$68,$46,$28C,$28C,$28C,$68,$68,$666
		dc.w	$2C2,$28C,$68,$46,$CC4,$CE8,$60,$8AC,$CC4,$666,$4CE,$666,$666,$666,$4CE,$4CE
DesertBus_PalCyc1:
		dc.w	$68,$222,$68,$68,$68,$68,$68,$222,$68,$68,$68,$68,$68,$222,$68,$68
		dc.w	$68,$68,$68,$222,$222,$68,$68,$68,$68
DesertBus_PalCyc2:
		dc.w	$28C,$68,$46,$68,$68,$28C,$68,$46,$46,$68,$28C,$68,$68,$46,$68,$28C
DesertBus_PalCyc3:
		dc.w	$28C,$28C,$68,$68,$68,$28C,$28C,$68,$68,$68,$28C,$28C,$28C,$68,$68,$28C
DesertBus_PalCyc4:
		dc.w	$4CE,$666,$666,$666,$4CE,$4CE,$4CE,$4CE,$666,$666,$666,$4CE,$4CE,$4CE,$4CE,$666
		dc.w	$666,$666,$666,$4CE,$4CE,$4CE,$666,$666,$666,$666,$4CE,$4CE,$4CE,$666,$666,$666
		dc.w	$666,$4CE,$4CE,$4CE

; ===========================================================================
; Handle palette cycling
; ===========================================================================

DesertBus_PalCycle:
		tst.w	(DB_Move_Flag).w
		beq.w	@End

		addq.w	#1,(DB_PalCyc_Index_1).w
		cmpi.w	#5,(DB_PalCyc_Index_1).w
		blt.s	@NoPalCycCap1
		move.w	#0,(DB_PalCyc_Index_1).w

@NoPalCycCap1:
		lea	(DesertBus_PalCyc1).l,a0
		move.w	(DB_PalCyc_Index_1).w,d0
		mulu.w	#$A,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB22).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_2).w
		cmpi.w	#4,(DB_PalCyc_Index_2).w
		blt.s	@NoPalCycCap2
		move.w	#0,(DB_PalCyc_Index_2).w

@NoPalCycCap2:
		lea	(DesertBus_PalCyc2).l,a0
		move.w	(DB_PalCyc_Index_2).w,d0
		mulu.w	#8,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB2C).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_3).w
		cmpi.w	#4,(DB_PalCyc_Index_3).w
		blt.s	@NoPalCycCap3
		move.w	#0,(DB_PalCyc_Index_3).w

@NoPalCycCap3:
		lea	(DesertBus_PalCyc3).l,a0
		move.w	(DB_PalCyc_Index_3).w,d0
		mulu.w	#8,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB36).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_4).w
		cmpi.w	#5,(DB_PalCyc_Index_4).w
		blt.s	@NoPalCycCap4
		move.w	#0,(DB_PalCyc_Index_4).w

@NoPalCycCap4:
		lea	(DesertBus_PalCyc1).l,a0
		move.w	(DB_PalCyc_Index_4).w,d0
		mulu.w	#$A,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB42).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_5).w
		cmpi.w	#4,(DB_PalCyc_Index_5).w
		blt.s	@NoPalCycCap5
		move.w	#0,(DB_PalCyc_Index_5).w

@NoPalCycCap5:
		lea	(DesertBus_PalCyc2).l,a0
		move.w	(DB_PalCyc_Index_5).w,d0
		mulu.w	#8,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB4C).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_6).w
		cmpi.w	#4,(DB_PalCyc_Index_6).w
		blt.s	@NoPalCycCap6
		move.w	#0,(DB_PalCyc_Index_6).w

@NoPalCycCap6:
		lea	(DesertBus_PalCyc3).l,a0
		move.w	(DB_PalCyc_Index_6).w,d0
		mulu.w	#8,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB56).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		addq.w	#1,(DB_PalCyc_Index_7).w
		cmpi.w	#6,(DB_PalCyc_Index_7).w
		blt.s	@NoPalCycCap7
		move.w	#0,(DB_PalCyc_Index_7).w

@NoPalCycCap7:
		lea	(DesertBus_PalCyc4).l,a0
		move.w	(DB_PalCyc_Index_7).w,d0
		mulu.w	#$C,d0
		lea	(a0,d0.w),a0
		lea	($FFFFFB74).w,a1
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

@End:
		rts

; ===========================================================================
; Data
; ===========================================================================

Pal_Gray:
		incbin	"pallet/gray.bin"
		even

DesertBus_VRAM:
		incbin	"_desertbus/vram.bin"
		even

; ===========================================================================