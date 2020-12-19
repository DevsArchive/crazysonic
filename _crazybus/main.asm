; ===========================================================================
; CrazyBus
; ===========================================================================

; Variables
CBSnd_Motor_Mode	EQU	$FFFFC9C0
CrazyBus_Mode		EQU	$FFFFCA00
CB_DMA_Word		EQU	$FFFFFF00
CB_Bus_Sel_Part		EQU	$FFFFFF02
CB_Bus_Sel_ID		EQU	$FFFFFF04
CB_Current_Bus		EQU	$FFFFFF06
CB_Title_Started	EQU	$FFFFFF10
CB_VSync_Flag		EQU	$FFFFFF12
CB_X_Pos		EQU	$FFFFFF20
CBSnd_Backup_Beep	EQU	$FFFFFFB3
CBSnd_Honk		EQU	$FFFFFFB4
CBSnd_MotorCounter	EQU	$FFFFFFB6
CBSnd_Rng_Seed1		EQU	$FFFFFFB8
CBSnd_Rng_Seed2		EQU	$FFFFFFBC
CBSnd_Counter		EQU	$FFFFFFC2
CBSnd_Paused		EQU	$FFFFFFC4
CBSnd_Sound_ID		EQU	$FFFFFFC5
CBSnd_Stopped		EQU	$FFFFFFC6

; Sound IDs
CBSNDID_TITLE		EQU	0
CBSNDID_MENU		EQU	1
CBSNDID_HONK		EQU	2
CBSNDID_BUS		EQU	3
CBSNDID_COUNT		EQU	4
CBSNDID_CNTDONE		EQU	5
CBSNDID_STOP		EQU	6

; ===========================================================================

CBTxt_VersionNo:
		dc.b	"2.00r030", $FF
CBTxt_BuildDate:
		dc.b	"19/30/2010", $FF
CBTxt_Codename:
		dc.b	"(Monohime)", $FF
		even

; ===========================================================================

CrazyBus:
		move	#$2700,sr
		lea	($FFFFFE00).w,sp

		lea	($FFFFF700).w,a1
		move.w	#$3F,d1

@ClearCamera:
		move.l	#0,(a1)+
		dbf	d1,@ClearCamera

		move.l	#$40000000,($C00004).l
		move.w	#$7FFF,d1

@ClearVRAM:
		move.w	#0,($C00000).l
		dbf	d1,@ClearVRAM

		nop
		stopDAC
		nop
		stopZ80

		jsr	VDPSetupGame

		move.w	#$4EF9,(HInt_Jump).w
		move.l	#HInt_CrazyBus,(HInt_Addr).w
		move.w	#$4EF9,(VInt_Jump).w
		move.l	#VInt_CrazyBus,(VInt_Addr).w
		move	#$2300,sr

		moveq	#0,d0
		move.b	(CrazyBus_Mode).w,d0
		move.b	@GameModeIDs(pc,d0.w),($FFFFF600).w

@MainLoop:
		moveq	#0,d0
		move.b	($FFFFF600).w,d0
		lsl.w	#2,d0
		movea.l	@GameModes(pc,d0.w),a0
		jsr	(a0)
		bra.s	@MainLoop

; ===========================================================================

@GameModeIDs:
		dc.b	0, 4, 4, 0

@GameModes:
		dc.l	CB_SegaScreen
		dc.l	CB_LegalScreens
		dc.l	CB_TitleScreen
		dc.l	CB_BusSelection
		dc.l	CB_CountdownScreen
		dc.l	CB_Level

; ===========================================================================
; Sega screen
; ===========================================================================

CB_SegaScreen:
		move	#$2300,sr
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArt1BPP_CBFont).l,a0
		move.w	#CBArt1BPP_CBFont_End-CBArt1BPP_CBFont-1,d1
		move.w	#0,d2
		lea	($FF0000).l,a1
		jsr	CB_Load1BPPArt

		lea	(CBArtKos_Buttons).l,a0
		lea	($FF0000).l,a1
		movea.w	#$20,a2
		jsr	CB_LoadKosArt
		lea	(CBArtKos_SegaLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadKosArt

		move.l	#$461A0003,d0
		moveq	#$B,d1
		moveq	#3,d2
		move.w	#$100,d4
		jsr	CB_GenTilemap

		moveq	#0,d0
		jsr	CB_LoadPal

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.b	#CBSNDID_BUS,d0
		jsr	CBSnd_Play
		move.w	#2,(CBSnd_Motor_Mode).w

		move.w	#$C8,d0

@Scroll:
		move.w	d0,d1
		neg.w	d1
		move.w	d1,($FFFFCC00).w
		move.w	d0,d1
		divu.w	#3,d1
		clr.w	d1
		swap	d1
		tst.w	d1
		bne.s	@DoLoop
		jsr	CB_VSync

@DoLoop:
		dbf	d0,@Scroll

		moveq	#1,d0
		jsr	CB_LoadPal
		
		move.b	#CBSNDID_HONK,d0
		jsr	CBSnd_Play
		move.w	#5,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop
		move.w	#5,d2
		jsr	CB_Delay
		move.b	#CBSNDID_HONK,d0
		jsr	CBSnd_Play
		move.w	#10,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop

		bsr.s	CB_SegaPalCycle

		move.b	#1,($FFFFF600).w
		tst.b	(CrazyBus_Mode).w
		beq.s	@End
		move.b	#2,($FFFFF600).w

@End:
		rts

; ===========================================================================
; Sega logo palette cycle
; ===========================================================================

CB_SegaPalCycle:
		move.w	#4-1,d0

@Loop:
		move.w	d0,d1
		mulu.w	#$20,d1
		lea	(@Colors).l,a0
		lea	($FFFFFB00).l,a1
		adda.w	d1,a0

		move.w	#$20/4-1,d2

@SetColors:
		move.l	(a0)+,(a1)+
		dbf	d2,@SetColors

		move.w	#10,d2
		jsr	CB_Delay

		dbf	d0,@Loop
		rts

; ===========================================================================

@Colors:
		incbin	"_crazybus/palette/segalogocycle.bin"
		even

; ===========================================================================
; Legal screens
; ===========================================================================

CB_LegalScreens:
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArtKos_TomScripts).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadKosArt

		lea	($FF0000).l,a1
		lea	(CBMapEni_TomScripts).l,a0
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$40820003,d0
		moveq	#$25,d1
		moveq	#$18,d2
		move.w	#$100,d4
		jsr	CB_LoadTilemap

		moveq	#2,d0
		jsr	CB_LoadPal

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#70,d2
		jsr	CB_Delay

		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArtKos_BusLogos).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadKosArt

		lea	($FF0000).l,a1
		lea	(CBMapEni_BusLogos).l,a0
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$40040003,d0
		moveq	#$22,d1
		moveq	#$1B,d2
		move.w	#$100,d4
		jsr	CB_LoadTilemap

		moveq	#3,d0
		jsr	CB_LoadPal

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#70,d2
		jsr	CB_Delay

		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArtKos_LegalBG).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadKosArt
		lea	(CBArtKos_LegalFG).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2560,a2
		jsr	CB_LoadKosArt

		moveq	#4,d0
		jsr	CB_LoadPal
		move.w	#0,($FFFFFB02).w
		move.w	#$E,($FFFFFB22).w
		move.w	#$EEE,($FFFFFB60).w

		bsr.w	CB_DrawLegalBG

		lea	(CBTxt_LegalChitChat).l,a1
		move.l	#$40820003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalSeparator).l,a1
		move.l	#$41020003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalCopyright).l,a1
		move.l	#$41820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalRights).l,a1
		move.l	#$42020003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalContact).l,a1
		move.l	#$42820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		move.l	#$43820003,d0
		moveq	#$24,d1
		moveq	#$10,d2
		move.w	#$612B,d4
		jsr	CB_GenTilemap

		lea	(CBTxt_Version).l,a1
		move.l	#$4C820003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_VersionNo).l,a1
		move.l	#$4C8A0003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_Dash).l,a1
		move.l	#$4C9C0003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_BuildDate).l,a1
		move.l	#$4CA00003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_Codename).l,a1
		move.l	#$4CB60003,d0
		move.w	#2,d3
		jsr	CB_DrawText

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#75,d2
		jsr	CB_Delay

		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArtKos_LegalFGEs).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2560,a2
		jsr	CB_LoadKosArt

		bsr.w	CB_DrawLegalBG

		lea	(CBTxt_LegalChitChatEs).l,a1
		move.l	#$40820003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalSeparator).l,a1
		move.l	#$41020003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalCopyrightEs).l,a1
		move.l	#$41820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalRightsEs).l,a1
		move.l	#$42020003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_LegalContactEs).l,a1
		move.l	#$42820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		move.l	#$43820003,d0
		moveq	#$24,d1
		moveq	#$10,d2
		move.w	#$612B,d4
		jsr	CB_GenTilemap

		lea	(CBTxt_Version).l,a1
		move.l	#$4C820003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_VersionNo).l,a1
		move.l	#$4C8A0003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_Dash).l,a1
		move.l	#$4C9C0003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_BuildDate).l,a1
		move.l	#$4CA00003,d0
		move.w	#2,d3
		jsr	CB_DrawText
		lea	(CBTxt_Codename).l,a1
		move.l	#$4CB60003,d0
		move.w	#2,d3
		jsr	CB_DrawText

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#75,d2
		jsr	CB_Delay

		move.b	#0,(CB_Title_Started).w
		move.b	#2,($FFFFF600).w
		rts

; ===========================================================================
; Draw legal background
; ===========================================================================

CB_DrawLegalBG:
		lea	($FF0000).l,a1
		lea	(CBMapEni_LegalBG).l,a0
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync

		subq.w	#4,sp
		move.l	#0,(sp)

@Row:
		cmpi.w	#$1C,(sp)
		beq.s	@End

@Block:
		cmpi.w	#$28,2(sp)
		bne.s	@Draw
		move.w	#0,2(sp)
		addq.w	#7,(sp)
		bra.s	@Row

@Draw:
		lea	($FF0000).l,a1
		move.w	(sp),d2
		move.w	2(sp),d1
		jsr	CB_GetBGPlaneLoc
		moveq	#9,d1
		moveq	#6,d2
		move.w	#$4100,d4
		jsr	CB_LoadTilemap
		addi.w	#10,2(sp)
		bra.s	@Block

@End:
		move.l	#0,(sp)
		addq.w	#4,sp
		rts

; ===========================================================================
; Title screen
; ===========================================================================

CB_TitleScreen:
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus

		lea	(CBArtKos_HackTitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$B000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$44120003,d0
		moveq	#$14,d1
		moveq	#4,d2
		move.w	#$4580,d4
		jsr	CB_GenTilemap

		bra.s	@LoadedLogo
	
@CrazyBus:
		lea	(CBArtKos_TitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$1000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$44160003,d0
		moveq	#$11,d1
		moveq	#4,d2
		move.w	#$4080,d4
		jsr	CB_GenTilemap

@LoadedLogo:
		moveq	#5,d0
		jsr	CB_LoadPal
		moveq	#6,d0
		jsr	CB_LoadPal

		move.w	#5,d0
		jsr	CB_RandomRange
		lea	(CB_TitleData).l,a0
		mulu.w	#$12,d0
		adda.w	d0,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$1B40,a2
		jsr	CB_LoadKosArt
		movea.l	(sp)+,a0
		
		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$60000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		move.w	#$20DA,d4
		jsr	CB_LoadTilemap
		movea.l	(sp)+,a0

		movea.l	(a0)+,a2
		movea.w	#$FB20,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		movea.l	(a0)+,a1
		move.l	#$4C820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		move.w	(a0)+,($FFFFFB02).w

		tst.b	(CrazyBus_Mode).w
		bne.s	@HackCopyright

		lea	(CBTxt_TitleCopyright).l,a1
		move.l	#$4A820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Portions).l,a1
		move.l	#$4B020003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_PhotoCredits).l,a1
		move.l	#$4B820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MadeInVenezuela).l,a1
		move.l	#$4D820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		bra.s	@LoadedCopyright

@HackCopyright:
		lea	(CBTxt_HackTitleCopyright).l,a1
		move.l	#$4D840003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@LoadedCopyright:
		move.w	#0,($FFFFF614).w
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#10,d2
		jsr	CB_Delay

		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus2
		move.b	#CBSNDID_TITLE,d0
		jsr	CBSnd_Play
		bra.s	CB_TitleLoop

@CrazyBus2:
		tst.b	(CB_Title_Started).w
		bne.s	CB_TitleLoop
		move.b	#CBSNDID_TITLE,d0
		jsr	CBSnd_Play
		move.b	#1,(CB_Title_Started).w

CB_TitleLoop:
		jsr	CB_VSync
		addq.w	#1,($FFFFF614).w
		cmpi.w	#1800,($FFFFF614).w
		bgt.w	CB_TitleScreen

		move.w	($FFFFF614).w,d1
		divu.w	#$14,d1
		clr.w	d1
		swap	d1
		cmpi.w	#10,d1
		bgt.s	@BlankPressStart
		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus
		lea	(CBTxt_PressStart).l,a1
		move.l	#$48A60003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		bra.s	@LoadedText

@CrazyBus:
		lea	(CBTxt_PressStartEs).l,a1
		move.l	#$48A60003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@LoadedText:
		bra.s	@LoadedText2

@BlankPressStart:
		lea	(CBTxt_PressStartBlank).l,a1
		move.l	#$48A60003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@LoadedText2:
		tst.w	(CBSnd_Counter).w
		bne.s	@NoPalCycle
		movem.l	d0-d1,-(sp)
		move.w	#2,d0
		jsr	CB_RandomRange
		addq.w	#6,d0
		andi.w	#7,d0
		ror.w	#7,d0
		move.w	d0,d2
		move.l	d2,-(sp)
		move.w	#2,d0
		jsr	CB_RandomRange
		move.l	(sp)+,d2
		addq.w	#6,d0
		andi.w	#7,d0
		lsl.w	#5,d0
		or.w	d0,d2
		move.l	d2,-(sp)
		move.w	#2,d0
		jsr	CB_RandomRange
		move.l	(sp)+,d2
		addq.w	#6,d0
		andi.w	#7,d0
		lsl.w	#1,d0
		or.w	d0,d2
		move.w	d2,($FFFFFB4E).w
		movem.l	(sp)+,d0-d1

@NoPalCycle:
		move.b	($FFFFF605).w,d1
		btst	#7,d1
		beq.w	CB_TitleLoop

		jsr	CBSnd_Stop

		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus2
		jmp	GameReinitialize

@CrazyBus2:
		move.b	#3,($FFFFF600).w
		rts

; ===========================================================================

CB_TitleData:
		dc.l	CBArtKos_TitleBus1
		dc.l	CBMapEni_TitleBus1
		dc.l	CBPal_TitleBus1
		dc.l	CBTxt_CoverBus1
		dc.w	$CE
		dc.l	CBArtKos_TitleBus2
		dc.l	CBMapEni_TitleBus2
		dc.l	CBPal_TitleBus2
		dc.l	CBTxt_CoverBus2
		dc.w	$EC0
		dc.l	CBArtKos_TitleBus3
		dc.l	CBMapEni_TitleBus3
		dc.l	CBPal_TitleBus3
		dc.l	CBTxt_CoverBus3
		dc.w	$60E
		dc.l	CBArtKos_TitleBus4
		dc.l	CBMapEni_TitleBus4
		dc.l	CBPal_TitleBus4
		dc.l	CBTxt_CoverBus4
		dc.w	$EA
		dc.l	CBArtKos_TitleBus5
		dc.l	CBMapEni_TitleBus5
		dc.l	CBPal_TitleBus5
		dc.l	CBTxt_CoverBus5
		dc.w	$EE
		dc.l	CBArtKos_TitleBus6
		dc.l	CBMapEni_TitleBus6
		dc.l	CBPal_TitleBus6
		dc.l	CBTxt_CoverBus6
		dc.w	$EE0

; ===========================================================================
; Bus selection screen
; ===========================================================================

CB_BusSelection:
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		move.w	#0,($FFFFFB00).w

		move.w	#20,d2
		jsr	CB_Delay

		lea	(CBArt1BPP_CBFont).l,a0
		move.w	#CBArt1BPP_CBFont_End-CBArt1BPP_CBFont-1,d1
		move.w	#0,d2
		lea	($FF0000).l,a1
		jsr	CB_Load1BPPArt

		lea	(CBArtKos_Buttons).l,a0
		lea	($FF0000).l,a1
		movea.w	#$20,a2
		jsr	CB_LoadKosArt
		lea	(CBArtKos_MenuBG).l,a0
		lea	($FF0000).l,a1
		movea.w	#$1800,a2
		jsr	CB_LoadKosArt

		bsr.w	CB_LoadMenuBG

		lea	(CBTxt_Model).l,a1
		move.l	#$40860003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Origin).l,a1
		move.l	#$41860003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Height).l,a1
		move.l	#$42060003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SelectABus).l,a1
		move.l	#$44860003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Motor).l,a1
		move.l	#$46BA0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MotorValue).l,a1
		move.l	#$473C0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Rating).l,a1
		move.l	#$483A0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_RatingValue).l,a1
		move.l	#$48BC0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SwitchBusCtrl).l,a1
		move.l	#$49B80003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SwitchBus).l,a1
		move.l	#$4A380003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SelectBusCtrl).l,a1
		move.l	#$4B380003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SelectBus).l,a1
		move.l	#$4BB80003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		move.w	#$C00,($FFFFFB02).w
		moveq	#7,d0
		jsr	CB_LoadPal
		
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.b	#0,($FFFFFF06).w

		move.b	#CBSNDID_MENU,d0
		jsr	CBSnd_Play

		move.b	#0,d0
		move.b	#0,d1
		jsr	CB_LoadBusSelInfo
		move.b	#0,d0
		move.b	#1,d1
		jsr	CB_LoadBusSelInfo

		move.w	#0,($FFFFF614).w

CB_BusSelectLoop:
		jsr	CB_VSync

		move.b	($FFFFF605).w,d1
		btst	#2,d1
		beq.s	@CheckRight
		tst.b	(CB_Current_Bus).w
		beq.s	@WrapLeft
		subq.b	#1,(CB_Current_Bus).w
		bra.s	@SwitchLeft

@WrapLeft:
		move.b	#4,(CB_Current_Bus).w

@SwitchLeft:
		move.b	#0,d0
		bsr.w	CB_SwitchBus

@CheckRight:
		move.b	($FFFFF605).w,d1
		btst	#3,d1
		beq.s	@CheckFlashText
		cmpi.b	#4,(CB_Current_Bus).w
		bge.s	@WrapRight
		addq.b	#1,(CB_Current_Bus).w
		bra.s	@SwitchRight

@WrapRight:
		move.b	#0,(CB_Current_Bus).w

@SwitchRight:
		move.b	#1,d0
		bsr.w	CB_SwitchBus

@CheckFlashText:
		addq.w	#1,($FFFFF614).w
		cmpi.w	#10,($FFFFF614).w
		bgt.s	@ResetCounter
		beq.s	@FlashText
		bra.s	@CheckLoop

@FlashText:
		move.w	#3,d0
		jsr	CB_RandomRange
		lsl.w	#1,d0
		move.w	d0,d5
		move.w	d0,d3
		lea	(CBTxt_SelectABus).l,a1
		move.l	#$44860003,d0
		jsr	CB_DrawText
		move.w	d5,d3
		lea	(CBTxt_SwitchBus).l,a1
		move.l	#$4A380003,d0
		jsr	CB_DrawText
		move.w	d5,d3
		lea	(CBTxt_SelectBus).l,a1
		move.l	#$4BB80003,d0
		jsr	CB_DrawText
		bra.s	@CheckLoop

@ResetCounter:
		move.w	#0,($FFFFF614).w

@CheckLoop:
		move.b	($FFFFF605).w,d1
		btst	#7,d1
		beq.w	CB_BusSelectLoop

		jsr	CBSnd_Stop
		move.b	#4,($FFFFF600).w
		rts

; ===========================================================================
; Switch buses
; ===========================================================================

CB_SwitchBus:
		move.w	#1,d3
		tst.b	d0
		beq.w	@ScrollRight

@ScrollLeft:
		cmpi.w	#$200,d3
		bgt.w	@End
		subq.w	#1,($FFFFCC00).w
		move.w	d3,d2
		divu.w	#$10,d2
		clr.w	d2
		swap	d2
		tst.w	d2
		bne.s	@ChkDataLoadLeft1
		jsr	CB_VSync

@ChkDataLoadLeft1:
		cmpi.w	#216,d3
		bne.s	@ChkDataLoadLeft2
		move.l	d3,-(sp)
		move.b	(CB_Current_Bus).w,d0
		move.b	#1,d1
		jsr	CB_LoadBusSelInfo
		move.l	(sp)+,d3
		bra.s	@ScrollLeftLoop

@ChkDataLoadLeft2:
		cmpi.w	#312,d3
		bne.s	@ScrollLeftLoop
		move.l	d3,-(sp)
		move.b	(CB_Current_Bus).w,d0
		move.b	#0,d1
		jsr	CB_LoadBusSelInfo
		move.l	(sp)+,d3

@ScrollLeftLoop:
		addq.w	#1,d3
		bra.s	@ScrollLeft

@ScrollRight:
		cmpi.w	#$200,d3
		bgt.w	@End
		addq.w	#1,($FFFFCC00).w
		move.w	d3,d2
		divu.w	#$10,d2
		clr.w	d2
		swap	d2
		tst.w	d2
		bne.s	@ChkDataLoadRight1
		jsr	CB_VSync

@ChkDataLoadRight1:
		cmpi.w	#144,d3
		bne.s	@ChkDataLoadRight2
		move.l	d3,-(sp)
		move.b	(CB_Current_Bus).w,d0
		move.b	#0,d1
		jsr	CB_LoadBusSelInfo
		move.l	(sp)+,d3
		bra.s	@ScrollRightLoop

@ChkDataLoadRight2:
		cmpi.w	#296,d3
		bne.s	@ScrollRightLoop
		move.l	d3,-(sp)
		move.b	(CB_Current_Bus).w,d0
		move.b	#1,d1
		jsr	CB_LoadBusSelInfo
		move.l	(sp)+,d3

@ScrollRightLoop:
		addq.w	#1,d3
		bra.s	@ScrollRight

@End:
		rts

; ===========================================================================
; Load menu background
; ===========================================================================

CB_LoadMenuBG:
		lea	($FF0000).l,a1
		lea	(CBMapEni_MenuBG).l,a0
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync

		subq.w	#4,sp
		move.l	#0,(sp)

@Row:
		cmpi.w	#$20,(sp)
		beq.s	@End

@Block:
		cmpi.w	#$28,2(sp)
		bne.s	@Draw
		move.w	#0,2(sp)
		addq.w	#8,(sp)
		bra.s	@Row

@Draw:
		lea	($FF0000).l,a1
		move.w	(sp),d2
		move.w	2(sp),d1
		jsr	CB_GetBGPlaneLoc
		moveq	#9,d1
		moveq	#7,d2
		move.w	#$20C0,d4
		jsr	CB_LoadTilemap
		addi.w	#10,2(sp)
		bra.s	@Block

@End:
		move.l	#0,(sp)
		addq.w	#4,sp
		rts

; ===========================================================================
; Load bus selection info
; ===========================================================================

CB_LoadBusSelInfo:
		move.b	d0,(CB_Bus_Sel_ID).w
		move.b	d1,(CB_Bus_Sel_Part).w

		tst.b	(CB_Bus_Sel_Part).w
		bne.s	@LoadData

@ClearLogo:
		subq.w	#4,sp
		move.l	#0,(sp)

@ClearLogoRow:
		cmpi.w	#4,(sp)
		beq.s	@ClearLogoEnd

@ClearLogoTile:
		cmpi.w	#$10,2(sp)
		bne.s	@DoClearLogo
		move.w	#0,2(sp)
		addq.w	#1,(sp)
		bra.s	@ClearLogoRow

@DoClearLogo:
		lea	($C00000).l,a5
		move.w	(sp),d2
		addq.w	#1,d2
		move.w	2(sp),d1
		addi.w	#$16,d1
		jsr	CB_GetFGPlaneLoc
		move.l	d0,4(a5)
		move.w	#0,(a5)

		addq.w	#1,2(sp)
		bra.s	@ClearLogoTile

@ClearLogoEnd:
		move.l	#0,(sp)
		addq.w	#4,sp

@LoadData:
		lea	(CB_BusSelInfo).l,a0
		moveq	#0,d3
		move.b	(CB_Current_Bus).w,d3
		mulu.w	#$38,d3
		adda.w	d3,a0

		tst.b	(CB_Bus_Sel_Part).w
		bne.s	@Part1

		movea.l	(a0)+,a1
		move.l	#$473C0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$48BC0003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		movea.l	(a0)+,a1
		cmpa.l	#0,a1
		beq.w	@End
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadCompArt
		movea.l	(sp)+,a0
		
		movea.l	(a0)+,a2
		movea.w	#$FB60,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		move.w	(a0)+,d1
		move.w	(a0)+,d2
		jsr	CB_GetFGPlaneLoc
		move.w	(a0)+,d1
		move.w	(a0)+,d2
		move.w	#$6100,d4
		jsr	CB_GenTilemap

		bra.w	@End

@Part1:
		adda.w	#$18,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$2800,a2
		jsr	CB_LoadCompArt
		movea.l	(sp)+,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$45060003,d0
		moveq	#$17,d1
		moveq	#$E,d2
		move.w	#$4140,d4
		jsr	CB_LoadTilemap
		movea.l	(sp)+,a0
		
		movea.l	(a0)+,a2
		movea.w	#$FB40,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		movea.l	(a0)+,a1
		move.l	#$40860003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$41960003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$42160003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$42860003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$43060003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@End:
		rts

; ===========================================================================

CB_BusSelInfo:
		dc.l	CBTxt_Bus1Motor
		dc.l	CBTxt_Bus1Rating
		dc.l	CBArtComp_BusLogo1
		dc.l	CBPal_BusLogo1
		dc.w	$1B, 1
		dc.w	$A, 2
		dc.l	CBArtComp_BusImage1
		dc.l	CBMapEni_BusImage1
		dc.l	CBPal_BusImage1
		dc.l	CBTxt_Bus1Name
		dc.l	CBTxt_Bus1Origin
		dc.l	CBTxt_Bus1Height
		dc.l	CBTxt_Bus1Desc1
		dc.l	CBTxt_Bus1Desc2
		
		dc.l	CBTxt_Bus2Motor
		dc.l	CBTxt_Bus2Rating
		dc.l	CBArtComp_BusLogo2
		dc.l	CBPal_BusLogo2
		dc.w	$16, 1
		dc.w	$F, 3
		dc.l	CBArtComp_BusImage2
		dc.l	CBMapEni_BusImage2
		dc.l	CBPal_BusImage2
		dc.l	CBTxt_Bus2Name
		dc.l	CBTxt_Bus2Origin
		dc.l	CBTxt_Bus2Height
		dc.l	CBTxt_Bus2Desc1
		dc.l	CBTxt_Bus2Desc2
		
		dc.l	CBTxt_Bus3Motor
		dc.l	CBTxt_Bus3Rating
		dc.l	CBArtComp_BusLogo3
		dc.l	CBPal_BusLogo3
		dc.w	$1D, 1
		dc.w	8, 2
		dc.l	CBArtComp_BusImage3
		dc.l	CBMapEni_BusImage3
		dc.l	CBPal_BusImage3
		dc.l	CBTxt_Bus3Name
		dc.l	CBTxt_Bus3Origin
		dc.l	CBTxt_Bus3Height
		dc.l	CBTxt_Bus3Desc1
		dc.l	CBTxt_Bus3Desc2
		
		dc.l	CBTxt_Bus4Motor
		dc.l	CBTxt_Bus4Rating
		dc.l	0
		dc.l	0
		dc.w	0, 0
		dc.w	0, 0
		dc.l	CBArtComp_BusImage4
		dc.l	CBMapEni_BusImage4
		dc.l	CBPal_BusImage4
		dc.l	CBTxt_Bus4Name
		dc.l	CBTxt_Bus4Origin
		dc.l	CBTxt_Bus4Height
		dc.l	CBTxt_Bus4Desc1
		dc.l	CBTxt_Bus4Desc2
		
		dc.l	CBTxt_Bus5Motor
		dc.l	CBTxt_Bus5Rating
		dc.l	CBArtComp_BusLogo5
		dc.l	CBPal_BusLogo5
		dc.w	$19, 1
		dc.w	$C, 2
		dc.l	CBArtComp_BusImage5
		dc.l	CBMapEni_BusImage5
		dc.l	CBPal_BusImage5
		dc.l	CBTxt_Bus5Name
		dc.l	CBTxt_Bus5Origin
		dc.l	CBTxt_Bus5Height
		dc.l	CBTxt_Bus5Desc1
		dc.l	CBTxt_Bus5Desc2

; ===========================================================================
; Countdown screen
; ===========================================================================

CB_CountdownScreen:
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		lea	(CBArt1BPP_CBFont).l,a0
		move.w	#CBArt1BPP_CBFont_End-CBArt1BPP_CBFont-1,d1
		move.w	#0,d2
		lea	($FF0000).l,a1
		jsr	CB_Load1BPPArt

		lea	(CBArtKos_Buttons).l,a0
		lea	($FF0000).l,a1
		movea.w	#$20,a2
		jsr	CB_LoadKosArt

		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus

		lea	(CBArtKos_HackTitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$B000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$41920003,d0
		moveq	#$14,d1
		moveq	#4,d2
		move.w	#$4580,d4
		jsr	CB_GenTilemap

		bra.s	@LoadedLogo
	
@CrazyBus:
		lea	(CBArtKos_TitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$1000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$41960003,d0
		moveq	#$11,d1
		moveq	#4,d2
		move.w	#$4080,d4
		jsr	CB_GenTilemap

@LoadedLogo:
		moveq	#5,d0
		jsr	CB_LoadPal
		moveq	#6,d0
		jsr	CB_LoadPal

		lea	(CB_CountdownData).l,a0
		move.w	#5,d0
		jsr	CB_RandomRange
		mulu.w	#$E,d0
		adda.w	d0,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$1B40,a2
		jsr	CB_LoadKosArt
		movea.l	(sp)+,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$60000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		move.w	#$20DA,d4
		jsr	CB_LoadTilemap
		movea.l	(sp)+,a0

		movea.l	(a0)+,a2
		movea.w	#$FB20,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		move.w	(a0)+,($FFFFFB02).w

		tst.b	(CrazyBus_Mode).w
		bne.w	@Hack

		lea	(CBTxt_ControlsEs).l,a1
		move.l	#$44980003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MoveLeftEs).l,a1
		move.l	#$46880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MoveRightEs).l,a1
		move.l	#$47080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_HonkHornEs).l,a1
		move.l	#$47880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_ReturnToTitle).l,a1
		move.l	#$48080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_PreparingEs).l,a1
		move.l	#$4CA80003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		bra.w	@StartCountdown

@Hack:
		lea	(CBTxt_Controls).l,a1
		move.l	#$44980003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Preparing).l,a1
		move.l	#$4CA80003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		tst.b	(Sanic_Mode).w
		bne.w	@Sanic

		lea	(CBTxt_MoveLeft).l,a1
		move.l	#$46880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MoveRight).l,a1
		move.l	#$47080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_HonkHorn).l,a1
		move.l	#$47880003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		cmpi.b	#1,(CrazyBus_Mode).w
		beq.w	@StartCountdown

		lea	(CBTxt_Jump).l,a1
		move.l	#$48080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Pause).l,a1
		move.l	#$48880003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		bra.w	@StartCountdown

@Sanic:
		lea	(CBTxt_SanicJump).l,a1
		move.l	#$46880003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		cmpi.b	#1,(CrazyBus_Mode).w
		beq.w	@StartCountdown

		lea	(CBTxt_MoveLeft).l,a1
		move.l	#$46880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_MoveRight).l,a1
		move.l	#$47080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SanicJump).l,a1
		move.l	#$47880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_SanicSuperJump).l,a1
		move.l	#$48080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_GottaGoFast).l,a1
		move.l	#$48880003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Explode).l,a1
		move.l	#$49080003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Pause).l,a1
		move.l	#$49880003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@StartCountdown:
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

		move.w	#10,d2
		jsr	CB_Delay

		move.w	#$E,($FFFFFB62).w

		lea	(CBTxt_Count3_1).l,a1
		move.l	#$4AC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count3_2).l,a1
		move.l	#$4B420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count3_3).l,a1
		move.l	#$4BC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count3_2).l,a1
		move.l	#$4C420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count3_1).l,a1
		move.l	#$4CC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText

		move.b	#CBSNDID_COUNT,d0
		jsr	CBSnd_Play
		move.w	#10,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop
		move.w	#50,d2
		jsr	CB_Delay

		lea	(CBTxt_Count2_1).l,a1
		move.l	#$4AC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count2_2).l,a1
		move.l	#$4B420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count2_3).l,a1
		move.l	#$4BC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count2_4).l,a1
		move.l	#$4C420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count2_5).l,a1
		move.l	#$4CC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText

		move.b	#CBSNDID_COUNT,d0
		jsr	CBSnd_Play
		move.w	#10,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop
		move.w	#50,d2
		jsr	CB_Delay

		lea	(CBTxt_Count1_1).l,a1
		move.l	#$4AC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count1_2).l,a1
		move.l	#$4B420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count1_1).l,a1
		move.l	#$4BC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count1_1).l,a1
		move.l	#$4C420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count1_3).l,a1
		move.l	#$4CC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText

		move.b	#CBSNDID_COUNT,d0
		jsr	CBSnd_Play
		move.w	#10,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop
		move.w	#50,d2
		jsr	CB_Delay

		lea	(CBTxt_Count0_1).l,a1
		move.l	#$4AC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count0_2).l,a1
		move.l	#$4B420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count0_2).l,a1
		move.l	#$4BC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count0_2).l,a1
		move.l	#$4C420003,d0
		move.w	#6,d3
		jsr	CB_DrawText
		lea	(CBTxt_Count0_1).l,a1
		move.l	#$4CC20003,d0
		move.w	#6,d3
		jsr	CB_DrawText

		move.b	#CBSNDID_CNTDONE,d0
		jsr	CBSnd_Play
		move.w	#10,d2
		jsr	CB_Delay
		jsr	CBSnd_Stop
		move.w	#10,d2
		jsr	CB_Delay

		cmpi.b	#1,(CrazyBus_Mode).w
		beq.s	@CrazyBus2
		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus2
		jmp	GameReinitialize

@CrazyBus2:
		move.b	#5,($FFFFF600).w
		rts

; ===========================================================================

CB_CountdownData:
		dc.l	CBArtKos_CountdownImage1
		dc.l	CBMapEni_CountdownImage1
		dc.l	CBPal_CountdownImage1
		dc.w	$EE
		dc.l	CBArtKos_CountdownImage2
		dc.l	CBMapEni_CountdownImage2
		dc.l	CBPal_CountdownImage2
		dc.w	$4E
		dc.l	CBArtKos_CountdownImage3
		dc.l	CBMapEni_CountdownImage3
		dc.l	CBPal_CountdownImage3
		dc.w	$E0E
		dc.l	CBArtKos_CountdownImage4
		dc.l	CBMapEni_CountdownImage4
		dc.l	CBPal_CountdownImage4
		dc.w	$EA
		dc.l	CBArtKos_CountdownImage5
		dc.l	CBMapEni_CountdownImage5
		dc.l	CBPal_CountdownImage5
		dc.w	$E80
		dc.l	CBArtKos_CountdownImage6
		dc.l	CBMapEni_CountdownImage6
		dc.l	CBPal_CountdownImage6
		dc.w	$EE0

; ===========================================================================
; Level
; ===========================================================================

CB_Level:
		jsr	ClearScreen
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		move.b	#0,(CB_Title_Started).w

		move.b	#CBSNDID_BUS,d0
		jsr	CBSnd_Play

		move.w	#0,(CB_X_Pos).w

		lea	($FFFFAC00).w,a1
		move.w	#$FF,d1

@ClearSprites:
		move.l	#0,(a1)+
		dbf	d1,@ClearSprites

		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus
		move.b	#3,(CB_Current_Bus).w

@CrazyBus:
		moveq	#9,d0
		jsr	CB_LoadPal

		lea	(CBArt1BPP_CBFont).l,a0
		move.w	#CBArt1BPP_CBFont_End-CBArt1BPP_CBFont-1,d1
		move.w	#0,d2
		lea	($FF0000).l,a1
		jsr	CB_Load1BPPArt

		lea	(CBArtKos_Buttons).l,a0
		lea	($FF0000).l,a1
		movea.w	#$20,a2
		jsr	CB_LoadKosArt
		lea	(CBArtKos_Level).l,a0
		lea	($FF0000).l,a1
		movea.w	#$1B60,a2
		jsr	CB_LoadKosArt
		lea	(CBArtKos_Wheels).l,a0
		lea	($FF0000).l,a1
		movea.w	#$2000,a2
		jsr	CB_LoadKosArt
		
		moveq	#8,d0
		jsr	CB_LoadPal

		move.w	#7,d0
		jsr	CB_RandomRange
		andi.w	#7,d0
		ror.w	#7,d0
		move.w	d0,d2
		move.l	d2,-(sp)
		move.w	#7,d0
		jsr	CB_RandomRange
		move.l	(sp)+,d2
		andi.w	#7,d0
		lsl.w	#5,d0
		or.w	d0,d2
		move.l	d2,-(sp)
		move.w	#7,d0
		jsr	CB_RandomRange
		move.l	(sp)+,d2
		andi.w	#7,d0
		lsl.w	#1,d0
		or.w	d0,d2
		move.l	d2,-(sp)

		lea	($FF0000).l,a1
		lea	(CBMapEni_Level).l,a0
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		move.w	#$20DA,d4
		jsr	CB_LoadLevelTilemap

		moveq	#0,d0
		lea	(CB_BusData).l,a0
		move.b	(CB_Current_Bus).w,d0
		mulu.w	#$14,d0
		adda.w	d0,a0

		movea.l	(a0)+,a2
		movea.w	#$FB40,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		move.l	(sp)+,d2
		movea.l	(a0)+,a1
		cmpa.l	#0,a1
		beq.s	@NoColorStore
		move.w	d2,(a1)

@NoColorStore:
		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$2100,a2
		jsr	CB_LoadKosArt
		movea.l	(sp)+,a0

		tst.b	(CrazyBus_Mode).w
		bne.w	@Hack

		movea.l	(a0)+,a1
		move.l	#$42040003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		movea.l	(a0)+,a1
		move.l	#$42820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@Hack:
		lea	($FFFFD000).w,a1
		move.w	#$7FF,d1

@ClearObjects:
		move.w	#0,(a1)+
		dbf	d1,@ClearObjects

		move.w	#3,(CBSnd_Motor_Mode).w

		move.b	#$8E,($FFFFD000).w
		move.w	#-$8C,($FFFFD008).w
		move.w	#$BA,($FFFFD00C).w
		
		move.b	#$8E,($FFFFD040).w
		move.w	#$C9,($FFFFD04C).w
		move.b	#1,($FFFFD068).w
		
		move.b	#$8E,($FFFFD080).w
		move.w	#$C9,($FFFFD08C).w
		move.b	#1,($FFFFD0A8).w

		moveq	#0,d0
		lea	(CB_WheelXPos).l,a0
		move.b	(CB_Current_Bus).w,d0
		mulu.w	#4,d0
		adda.w	d0,a0
		move.w	(a0)+,($FFFFD048).w
		move.w	(a0)+,($FFFFD088).w

		jsr	BuildSprites
		jsr	ObjectsLoad

		move.w	#5,d0
		jsr	CB_RandomRange
		lea	(CB_LevelBGData).l,a0
		mulu.w	#$E,d0
		adda.w	d0,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		movea.w	#$2E80,a2
		jsr	CB_LoadKosArt
		movea.l	(sp)+,a0

		movea.l	(a0)+,a1
		move.l	a0,-(sp)
		movea.l	a1,a0
		lea	($FF0000).l,a1
		move.w	#0,d0
		jsr	EniDec
		jsr	CB_VSync
		lea	($FF0000).l,a1
		move.l	#$60000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		move.w	#$2174,d4
		jsr	CB_LoadTilemap
		movea.l	(sp)+,a0

		movea.l	(a0)+,a2
		movea.w	#$FB20,a3
		move.w	#7,d7
		jsr	CB_LoadPalDirect

		move.w	(a0)+,($FFFFFB02).w

		tst.b	(CrazyBus_Mode).w
		bne.w	@NoText

		lea	(CBTxt_Version).l,a1
		move.l	#$432C0003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_VersionNo).l,a1
		move.l	#$43360003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Codename).l,a1
		move.l	#$43B60003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_ReturnToTitle2).l,a1
		move.l	#$40820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_CurrentBus).l,a1
		move.l	#$41820003,d0
		move.w	#0,d3
		jsr	CB_DrawText
		lea	(CBTxt_Distance).l,a1
		move.l	#$43820003,d0
		move.w	#0,d3
		jsr	CB_DrawText

@NoText:
		tst.b	(CrazyBus_Mode).w
		beq.s	@CrazyBus2

		lea	(CBArtKos_HackTitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$B000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$40A40003,d0
		moveq	#$14,d1
		moveq	#4,d2
		move.w	#$6580,d4
		jsr	CB_GenTilemap

		bra.s	@LoadedLogo
	
@CrazyBus2:
		lea	(CBArtKos_TitleLogo).l,a0
		lea	($FF0000).l,a1
		movea.w	#$1000,a2
		jsr	CB_LoadKosArt
		
		move.l	#$40AA0003,d0
		moveq	#$11,d1
		moveq	#4,d2
		move.w	#$6080,d4
		jsr	CB_GenTilemap

@LoadedLogo:
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

CB_LevelLoop:
		jsr	BuildSprites
		jsr	ObjectsLoad

		bsr.s	CB_UpdateXPosText

		tst.b	(CrazyBus_Mode).w
		bne.s	@CheckEnd

		move.b	($FFFFF604).w,d0
		btst	#5,d0
		beq.s	CB_LevelLoop
		move.b	#2,($FFFFF600).w
		rts

@CheckEnd:
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.w	(CB_X_Pos).w,d0
		move.w	#$1FF,d1
		move.b	($FFFFFE57).w,d2
		addq.b	#1,d2
		mulu.w	d2,d1

		cmp.w	d0,d1
		bne.s	CB_LevelLoop
		jmp	GameReinitialize

; ===========================================================================

CB_UpdateXPosText:
		tst.b	(CrazyBus_Mode).w
		bne.w	@End

		lea	(CBTxt_DistanceBlank).l,a1
		move.l	#$43980003,d0
		move.w	#0,d3
		jsr	CB_DrawText

		moveq	#0,d0
		move.w	(CB_X_Pos).w,d0
		moveq	#0,d1
		moveq	#0,d3
		move.w	d0,d1

@GetDigitCount:
		divu.w	#10,d1
		swap	d1
		clr.w	d1
		swap	d1
		tst.w	d1
		beq.s	@DrawXPos
		addq.w	#1,d3
		bra.s	@GetDigitCount

@DrawXPos:
		moveq	#0,d1
		divu.w	#10,d0
		move.l	d0,d1
		swap	d0
		clr.w	d0
		swap	d0
		clr.w	d1
		swap	d1

		movem.l	d0-d1,-(sp)
		move.w	d3,d1
		addi.w	#$C,d1
		move.w	#7,d2
		jsr	CB_GetFGPlaneLoc
		move.l	d0,($C00004).l
		movem.l	(sp)+,d0-d1
		addi.w	#$30,d1
		move.w	d1,($C00000).l
		dbf	d3,@DrawXPos

@End:
		rts

; ===========================================================================

CB_WheelXPos:
		dc.w	-$6B, -$25
		dc.w	-$6D, -$24
		dc.w	-$6A, -$24
		dc.w	-$70, -$1A
		dc.w	-$72, -$22

; ===========================================================================

CB_BusData:
		dc.l	CBPal_Bus1
		dc.l	$FFFFFB4E
		dc.l	CBArtKos_Bus1
		dc.l	CBTxt_Bus1Maker
		dc.l	CBTxt_Bus1Name2
		
		dc.l	CBPal_Bus2
		dc.l	$FFFFFB42
		dc.l	CBArtKos_Bus2
		dc.l	CBTxt_Bus2Maker
		dc.l	CBTxt_Bus2Name2
		
		dc.l	CBPal_Bus3
		dc.l	$FFFFFB44
		dc.l	CBArtKos_Bus3
		dc.l	CBTxt_Bus3Maker
		dc.l	CBTxt_Bus3Name2
		
		dc.l	CBPal_Bus4
		dc.l	0
		dc.l	CBArtKos_Bus4
		dc.l	CBTxt_Bus4Maker
		dc.l	CBTxt_Bus4Name2
		
		dc.l	CBPal_Bus5
		dc.l	$FFFFFB44
		dc.l	CBArtKos_Bus5
		dc.l	CBTxt_Bus5Maker
		dc.l	CBTxt_Bus5Name2

; ===========================================================================

CB_LevelBGData:
		dc.l	CBArtKos_LevelBG1
		dc.l	CBMapEni_LevelBG1
		dc.l	CBPal_LevelBG1
		dc.w	$E
		
		dc.l	CBArtKos_LevelBG2
		dc.l	CBMapEni_LevelBG2
		dc.l	CBPal_LevelBG2
		dc.w	$E0E
		
		dc.l	CBArtKos_LevelBG3
		dc.l	CBMapEni_LevelBG3
		dc.l	CBPal_LevelBG3
		dc.w	$E0
		
		dc.l	CBArtKos_LevelBG4
		dc.l	CBMapEni_LevelBG4
		dc.l	CBPal_LevelBG4
		dc.w	$C06
		
		dc.l	CBArtKos_LevelBG5
		dc.l	CBMapEni_LevelBG5
		dc.l	CBPal_LevelBG5
		dc.w	$E00
		
		dc.l	CBArtKos_LevelBG6
		dc.l	CBMapEni_LevelBG6
		dc.l	CBPal_LevelBG6
		dc.w	$CE

; ===========================================================================
; Vertical interrupt
; ===========================================================================

VInt_CrazyBus:
		movem.l	d0-a6,-(sp)

		move.l	#$40000010,($C00004).l
		move.l	($FFFFF616).w,($C00000).l

		jsr	ReadJoypads

		lea	($C00004).l,a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(CB_DMA_Word).w
		move.w	(CB_DMA_Word).w,(a5)

		lea	($C00004).l,a5
		move.l	#$94009302,(a5)
		move.l	#$96E69500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(CB_DMA_Word).w
		move.w	(CB_DMA_Word).w,(a5)

		lea	($C00004).l,a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,($FFFFF640).w
		move.w	($FFFFF640).w,(a5)
		jsr	ProcessDMAQueue

		jsr	CBSnd_Update

		tst.w	(CB_VSync_Flag).w
		beq.s	@NoReset
		move.w	#0,(CB_VSync_Flag).w

@NoReset:
		addq.l	#1,($FFFFFE0C).w
		movem.l	(sp)+,d0-a6

HInt_CrazyBus:
		rte

; ===========================================================================
; Bus object
; ===========================================================================

CB_ObjBus:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	CB_ObjBus_Index(pc,d0.w),d1
		jmp	CB_ObjBus_Index(pc,d1.w)

; ===========================================================================

CB_ObjBus_Index:
		dc.w	CB_ObjBus_Init-CB_ObjBus_Index
		dc.w	CB_ObjBus_Main-CB_ObjBus_Index
		dc.w	CB_ObjBus_Wheel-CB_ObjBus_Index

; ===========================================================================

CB_ObjBus_Init:
		addq.b	#2,$24(a0)
		move.l	#CBMapSpr_ObjBus,4(a0)
		move.w	#$4108,2(a0)
		move.b	#$FF,$19(a0)
		move.b	#2,$18(a0)
		move.b	#4,1(a0)
		
		tst.b	$28(a0)
		beq.s	@End
		addq.b	#2,$24(a0)
		move.b	#1,$1A(a0)
		move.w	#$100,2(a0)
		move.b	#1,$18(a0)

@End:
		rts

; ===========================================================================

CB_ObjBus_Main:
		jsr	SpeedToPos
		move.b	($FFFFF604).w,d0
		btst	#2,d0
		beq.s	@CheckRight
		move.w	#-$100,$10(a0)
		subq.w	#1,(CB_X_Pos).w
		move.w	#1,(CBSnd_Motor_Mode).w
		bra.s	@CheckHonk

@CheckRight:
		btst	#3,d0
		beq.s	@StopXMove
		move.w	#$100,$10(a0)
		addq.w	#1,(CB_X_Pos).w
		move.w	#2,(CBSnd_Motor_Mode).w
		bra.s	@CheckHonk

@StopXMove:
		move.w	#0,$10(a0)
		move.w	#3,(CBSnd_Motor_Mode).w

@CheckHonk:
		move.b	#0,d1
		btst	#6,d0
		beq.s	@SetHonk
		move.b	#1,d1

@SetHonk:
		move.b	d1,(CBSnd_Honk).w
		move.w	#2,d2
		jsr	CB_Delay

CB_ObjBus_Draw:
		andi.w	#$1FF,8(a0)
		jmp	DisplaySprite

; ===========================================================================

CB_ObjBus_Wheel:
		jsr	SpeedToPos
		move.w	($FFFFD010).w,$10(a0)
		tst.w	$10(a0)
		beq.s	@Draw
		lea	(CBAniSpr_ObjBus).l,a1
		jsr	AnimateSprite

@Draw:
		bra.s	CB_ObjBus_Draw

; ===========================================================================

CBAniSpr_ObjBus:
		dc.w	@0-CBAniSpr_ObjBus
@0:
		dc.b	1, 1, 2, $FF
		even

; ===========================================================================

CBMapSpr_ObjBus:
		include	"_crazybus/mapspr/bus.asm"
		even

; ===========================================================================
; Palettes
; ===========================================================================

CB_PalIndex:
		dc.l	CBPal_SegaLogoDark
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_SegaLogo
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_TomScripts
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_BusLogos
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_Legal
		dc.w	$FB40
		dc.w	7
		dc.l	CBPal_TitleLogo
		dc.w	$FB40
		dc.w	7
		dc.l	CBPal_Default
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_BusSelect
		dc.w	$FB20
		dc.w	7
		dc.l	CBPal_Level
		dc.w	$FB00
		dc.w	7
		dc.l	CBPal_TitleLogo
		dc.w	$FB60
		dc.w	7

CBPal_SegaLogoDark:
		incbin	"_crazybus/palette/segalogodark.bin"
		even
CBPal_SegaLogo:
		incbin	"_crazybus/palette/segalogo.bin"
		even
CBPal_TomScripts:
		incbin	"_crazybus/palette/tomscripts.bin"
		even
CBPal_BusLogos:
		incbin	"_crazybus/palette/buslogos.bin"
		even
CBPal_Legal:
		incbin	"_crazybus/palette/legal.bin"
		even
CBPal_TitleLogo:
		incbin	"_crazybus/palette/titlelogo.bin"
		even
CBPal_Default:
		incbin	"_crazybus/palette/default.bin"
		even
CBPal_TitleBus1:
		incbin	"_crazybus/palette/titlebus1.bin"
		even
CBPal_TitleBus2:
		incbin	"_crazybus/palette/titlebus2.bin"
		even
CBPal_TitleBus3:
		incbin	"_crazybus/palette/titlebus3.bin"
		even
CBPal_TitleBus4:
		incbin	"_crazybus/palette/titlebus4.bin"
		even
CBPal_TitleBus5:
		incbin	"_crazybus/palette/titlebus5.bin"
		even
CBPal_TitleBus6:
		incbin	"_crazybus/palette/titlebus6.bin"
		even
CBPal_BusSelect:
		incbin	"_crazybus/palette/busselect.bin"
		even
CBPal_BusImage1:
		incbin	"_crazybus/palette/busimage1.bin"
		even
CBPal_BusImage2:
		incbin	"_crazybus/palette/busimage2.bin"
		even
CBPal_BusImage3:
		incbin	"_crazybus/palette/busimage3.bin"
		even
CBPal_BusImage4:
		incbin	"_crazybus/palette/busimage4.bin"
		even
CBPal_BusImage5:
		incbin	"_crazybus/palette/busimage5.bin"
		even
CBPal_BusLogo1:
		incbin	"_crazybus/palette/buslogo1.bin"
		even
CBPal_BusLogo2:
		incbin	"_crazybus/palette/buslogo2.bin"
		even
CBPal_BusLogo3:
		incbin	"_crazybus/palette/buslogo3.bin"
		even
CBPal_BusLogo5:
		incbin	"_crazybus/palette/buslogo5.bin"
		even
CBPal_CountdownImage1:
		incbin	"_crazybus/palette/countdown1.bin"
		even
CBPal_CountdownImage2:
		incbin	"_crazybus/palette/countdown2.bin"
		even
CBPal_CountdownImage3:
		incbin	"_crazybus/palette/countdown3.bin"
		even
CBPal_CountdownImage4:
		incbin	"_crazybus/palette/countdown4.bin"
		even
CBPal_CountdownImage5:
		incbin	"_crazybus/palette/countdown5.bin"
		even
CBPal_CountdownImage6:
		incbin	"_crazybus/palette/countdown6.bin"
		even
CBPal_Level:
		incbin	"_crazybus/palette/level.bin"
		even
CBPal_Bus1:
		incbin	"_crazybus/palette/bus1.bin"
		even
CBPal_Bus2:
		incbin	"_crazybus/palette/bus2.bin"
		even
CBPal_Bus3:
		incbin	"_crazybus/palette/bus3.bin"
		even
CBPal_Bus4:
		incbin	"_crazybus/palette/bus4.bin"
		even
CBPal_Bus5:
		incbin	"_crazybus/palette/bus5.bin"
		even
CBPal_LevelBG1:
		incbin	"_crazybus/palette/levelbg1.bin"
		even
CBPal_LevelBG2:
		incbin	"_crazybus/palette/levelbg2.bin"
		even
CBPal_LevelBG3:
		incbin	"_crazybus/palette/levelbg3.bin"
		even
CBPal_LevelBG4:
		incbin	"_crazybus/palette/levelbg4.bin"
		even
CBPal_LevelBG5:
		incbin	"_crazybus/palette/levelbg5.bin"
		even
CBPal_LevelBG6:
		incbin	"_crazybus/palette/levelbg6.bin"
		even

; ===========================================================================
; Art
; ===========================================================================

CBArtKos_Buttons:
		incbin	"_crazybus/artkos/buttons.bin"
		even
CBArtKos_SegaLogo:
		incbin	"_crazybus/artkos/segalogo.bin"
		even
CBArtKos_TomScripts:
		incbin	"_crazybus/artkos/tomscripts.bin"
		even
CBArtKos_BusLogos:
		incbin	"_crazybus/artkos/buslogos.bin"
		even
CBArtKos_LegalBG:
		incbin	"_crazybus/artkos/legalbg.bin"
		even
CBArtKos_LegalFG:
		incbin	"_crazybus/artkos/legalfg.bin"
		even
CBArtKos_LegalFGEs:
		incbin	"_crazybus/artkos/legalfges.bin"
		even
CBArtKos_TitleLogo:
		incbin	"_crazybus/artkos/titlelogo.bin"
		even
CBArtKos_TitleBus1:
		incbin	"_crazybus/artkos/titlebus1.bin"
		even
CBArtKos_TitleBus2:
		incbin	"_crazybus/artkos/titlebus2.bin"
		even
CBArtKos_TitleBus3:
		incbin	"_crazybus/artkos/titlebus3.bin"
		even
CBArtKos_TitleBus4:
		incbin	"_crazybus/artkos/titlebus4.bin"
		even
CBArtKos_TitleBus5:
		incbin	"_crazybus/artkos/titlebus5.bin"
		even
CBArtKos_TitleBus6:
		incbin	"_crazybus/artkos/titlebus6.bin"
		even
CBArtKos_MenuBG:
		incbin	"_crazybus/artkos/menubg.bin"
		even
CBArtComp_BusImage1:
		incbin	"_crazybus/artcomp/busimage1.bin"
		even
CBArtComp_BusImage2:
		incbin	"_crazybus/artcomp/busimage2.bin"
		even
CBArtComp_BusImage3:
		incbin	"_crazybus/artcomp/busimage3.bin"
		even
CBArtComp_BusImage4:
		incbin	"_crazybus/artcomp/busimage4.bin"
		even
CBArtComp_BusImage5:
		incbin	"_crazybus/artcomp/busimage5.bin"
		even
CBArtComp_BusLogo1:
		incbin	"_crazybus/artcomp/buslogo1.bin"
		even
CBArtComp_BusLogo2:
		incbin	"_crazybus/artcomp/buslogo2.bin"
		even
CBArtComp_BusLogo3:
		incbin	"_crazybus/artcomp/buslogo3.bin"
		even
CBArtComp_BusLogo5:
		incbin	"_crazybus/artcomp/buslogo5.bin"
		even
CBArtKos_CountdownImage1:
		incbin	"_crazybus/artkos/countdown1.bin"
		even
CBArtKos_CountdownImage2:
		incbin	"_crazybus/artkos/countdown2.bin"
		even
CBArtKos_CountdownImage3:
		incbin	"_crazybus/artkos/countdown3.bin"
		even
CBArtKos_CountdownImage4:
		incbin	"_crazybus/artkos/countdown4.bin"
		even
CBArtKos_CountdownImage5:
		incbin	"_crazybus/artkos/countdown5.bin"
		even
CBArtKos_CountdownImage6:
		incbin	"_crazybus/artkos/countdown6.bin"
		even
CBArtKos_Level:
		incbin	"_crazybus/artkos/level.bin"
		even
CBArtKos_Wheels:
		incbin	"_crazybus/artkos/wheels.bin"
		even
CBArtKos_Bus1:
		incbin	"_crazybus/artkos/bus1.bin"
		even
CBArtKos_Bus2:
		incbin	"_crazybus/artkos/bus2.bin"
		even
CBArtKos_Bus3:
		incbin	"_crazybus/artkos/bus3.bin"
		even
CBArtKos_Bus4:
		incbin	"_crazybus/artkos/bus4.bin"
		even
CBArtKos_Bus5:
		incbin	"_crazybus/artkos/bus5.bin"
		even
CBArtKos_LevelBG1:
		incbin	"_crazybus/artkos/levelbg1.bin"
		even
CBArtKos_LevelBG2:
		incbin	"_crazybus/artkos/levelbg2.bin"
		even
CBArtKos_LevelBG3:
		incbin	"_crazybus/artkos/levelbg3.bin"
		even
CBArtKos_LevelBG4:
		incbin	"_crazybus/artkos/levelbg4.bin"
		even
CBArtKos_LevelBG5:
		incbin	"_crazybus/artkos/levelbg5.bin"
		even
CBArtKos_LevelBG6:
		incbin	"_crazybus/artkos/levelbg6.bin"
		even
CBArtKos_HackTitleLogo:
		incbin	"_crazybus/artkos/hacktitlelogo.bin"
		even

; ===========================================================================
; Mappings
; ===========================================================================

CBMapEni_TomScripts:
		incbin	"_crazybus/mapeni/tomscripts.bin"
		even
CBMapEni_BusLogos:
		incbin	"_crazybus/mapeni/buslogos.bin"
		even
CBMapEni_LegalBG:
		incbin	"_crazybus/mapeni/legalbg.bin"
		even
CBMapEni_TitleBus1:
		incbin	"_crazybus/mapeni/titlebus1.bin"
		even
CBMapEni_TitleBus2:
		incbin	"_crazybus/mapeni/titlebus2.bin"
		even
CBMapEni_TitleBus3:
		incbin	"_crazybus/mapeni/titlebus3.bin"
		even
CBMapEni_TitleBus4:
		incbin	"_crazybus/mapeni/titlebus4.bin"
		even
CBMapEni_TitleBus5:
		incbin	"_crazybus/mapeni/titlebus5.bin"
		even
CBMapEni_TitleBus6:
		incbin	"_crazybus/mapeni/titlebus6.bin"
		even
CBMapEni_MenuBG:
		incbin	"_crazybus/mapeni/menubg.bin"
		even
CBMapEni_BusImage1:
		incbin	"_crazybus/mapeni/busimage1.bin"
		even
CBMapEni_BusImage2:
		incbin	"_crazybus/mapeni/busimage2.bin"
		even
CBMapEni_BusImage3:
		incbin	"_crazybus/mapeni/busimage3.bin"
		even
CBMapEni_BusImage4:
		incbin	"_crazybus/mapeni/busimage4.bin"
		even
CBMapEni_BusImage5:
		incbin	"_crazybus/mapeni/busimage5.bin"
		even
CBMapEni_CountdownImage1:
		incbin	"_crazybus/mapeni/countdown1.bin"
		even
CBMapEni_CountdownImage2:
		incbin	"_crazybus/mapeni/countdown2.bin"
		even
CBMapEni_CountdownImage3:
		incbin	"_crazybus/mapeni/countdown3.bin"
		even
CBMapEni_CountdownImage4:
		incbin	"_crazybus/mapeni/countdown4.bin"
		even
CBMapEni_CountdownImage5:
		incbin	"_crazybus/mapeni/countdown5.bin"
		even
CBMapEni_CountdownImage6:
		incbin	"_crazybus/mapeni/countdown6.bin"
		even
CBMapEni_LevelBG1:
		incbin	"_crazybus/mapeni/levelbg1.bin"
		even
CBMapEni_LevelBG2:
		incbin	"_crazybus/mapeni/levelbg2.bin"
		even
CBMapEni_LevelBG3:
		incbin	"_crazybus/mapeni/levelbg3.bin"
		even
CBMapEni_LevelBG4:
		incbin	"_crazybus/mapeni/levelbg4.bin"
		even
CBMapEni_LevelBG5:
		incbin	"_crazybus/mapeni/levelbg5.bin"
		even
CBMapEni_LevelBG6:
		incbin	"_crazybus/mapeni/levelbg6.bin"
		even
CBMapEni_Level:
		incbin	"_crazybus/mapeni/level.bin"
		even

; ===========================================================================
; Font
; ===========================================================================

CBArt1BPP_CBFont:
		incbin	"_crazybus/art1bpp/font.bin"
CBArt1BPP_CBFont_End:
		even

; ===========================================================================
; Strings
; ===========================================================================

CBTxt_LegalChitChat:
		dc.b	"CrazyBus(tm) - Legal chit-chat", $FF
		even
CBTxt_LegalSeparator:
		dc.b	"=====================================", $FF
		even
CBTxt_LegalCopyright:
		dc.b	"(C)2004-2010 by Tom Maneiro.", $FF
		even
CBTxt_LegalRights:
		dc.b	"Some rights reserved", $FF
		even
CBTxt_LegalContact:
		dc.b	"Contact: <tomman@tsdx.net.ve>", $FF
		even
CBTxt_LegalChitChatEs:
		dc.b	"CrazyBus(tm) - Bla-bla-bla legal", $FF
		even
CBTxt_LegalCopyrightEs:
		dc.b	"(C)2004-2010 por Tom Maneiro.", $FF
		even
CBTxt_LegalRightsEs:
		dc.b	"Algunos derechos reservados", $FF
		even
CBTxt_LegalContactEs:
		dc.b	"Contacto: <tomman@tsdx.net.ve>", $FF
		even
CBTxt_PressStartEs:
		dc.b	"Presiona ", 4, "!", $FF
		even
CBTxt_PressStart:
		dc.b	"Press ", 4, "!", $FF
		even
CBTxt_PressStartBlank:
		dc.b	"           ", $FF
		even
CBTxt_CoverBus1:
		dc.b	"   Cover bus: Busscar Panoramico DD  ", $FF
		even
CBTxt_CoverBus2:
		dc.b	"    Cover bus: Irizar Century 3.95   ", $FF
		even
CBTxt_CoverBus3:
		dc.b	"  Cover bus:  Marcopolo Andare Class ", $FF
		even
CBTxt_CoverBus4:
		dc.b	" Cover bus: Marcopolo Paradiso GV1450", $FF
		even
CBTxt_CoverBus5:
		dc.b	"   Cover bus: Busscar Panoramico DD  ", $FF
		even
CBTxt_CoverBus6:
		dc.b	" Cover bus: Marcopolo Paradiso 1800DD", $FF
		even
CBTxt_TitleCopyright:
		dc.b	"  (C)2004-2010 por Tom Scripts LTDA.", $FF
		even
CBTxt_HackTitleCopyright:
		dc.b	"    (C)1991 SEGA, 2015 Ralakimus", $FF
		even
CBTxt_Portions:
		dc.b	"Portions by: DevSter, Mairtrus, theelf", $FF
		even
CBTxt_PhotoCredits:
		dc.b	"Fotografias:  (C)2006-2009 Tom Maneiro", $FF
		even
CBTxt_MadeInVenezuela:
		dc.b	"HECHO EN VENEZUELA - MADE IN VENEZUELA", $FF
		even
CBTxt_Model:
		dc.b	"Modelo", $FF
		even
CBTxt_Origin:
		dc.b	"Origen: ??????????", $FF
		even
CBTxt_Height:
		dc.b	"Altura: 0.00m (SD)", $FF
		even
CBTxt_SelectABus:
		dc.b	"==>Selecciona un bus!<==", $FF
		even
CBTxt_Motor:
		dc.b	"Motor:", $FF
		even
CBTxt_MotorValue:
		dc.b	"000HP", $FF
		even
CBTxt_Rating:
		dc.b	"Puestos:", $FF
		even
CBTxt_RatingValue:
		dc.b	"00 (max)", $FF
		even
CBTxt_SwitchBusCtrl:
		dc.b	"[  <- ->  ]", $FF
		even
CBTxt_SwitchBus:
		dc.b	"Cambiar bus", $FF
		even
CBTxt_SelectBusCtrl:
		dc.b	"[    ", 4, "    ]", $FF
		even
CBTxt_SelectBus:
		dc.b	"Seleccionar", $FF
		even
CBTxt_Bus1Motor:
		dc.b	"360HP", $FF
		even
CBTxt_Bus1Rating:
		dc.b	"50 (max)", $FF
		even
CBTxt_Bus1Name:
		dc.b	"Century 3.95   ", $FF
		even
CBTxt_Bus1Origin:
		dc.b	"Espa", $A4, "a    ", $FF
		even
CBTxt_Bus1Height:
		dc.b	"3.95M (SD)", $FF
		even
CBTxt_Bus1Desc1:
		dc.b	"Autobus de lujo superior", $FF
		even
CBTxt_Bus1Desc2:
		dc.b	"Mejor con Mercedes-Benz ", $FF
		even
CBTxt_Bus2Motor:
		dc.b	"360HP", $FF
		even
CBTxt_Bus2Rating:
		dc.b	"52 (max)", $FF
		even
CBTxt_Bus2Name:
		dc.b	"Jum Buss 360   ", $FF
		even
CBTxt_Bus2Origin:
		dc.b	"Brasil    ", $FF
		even
CBTxt_Bus2Height:
		dc.b	"3.60M (SD)", $FF
		even
CBTxt_Bus2Desc1:
		dc.b	"Autobus muy duradero    ", $FF
		even
CBTxt_Bus2Desc2:
		dc.b	"Optimo con chasis Scania", $FF
		even
CBTxt_Bus3Motor:
		dc.b	"300HP", $FF
		even
CBTxt_Bus3Rating:
		dc.b	"40 (max)", $FF
		even
CBTxt_Bus3Name:
		dc.b	"E-NT6000       ", $FF
		even
CBTxt_Bus3Origin:
		dc.b	"Venezuela ", $FF
		even
CBTxt_Bus3Height:
		dc.b	"2.80M (SD)", $FF
		even
CBTxt_Bus3Desc1:
		dc.b	"Modelo para rutas cortas", $FF
		even
CBTxt_Bus3Desc2:
		dc.b	"Chasis personalizado    ", $FF
		even
CBTxt_Bus4Motor:
		dc.b	"200HP", $FF
		even
CBTxt_Bus4Rating:
		dc.b	"60 (max)", $FF
		even
CBTxt_Bus4Name:
		dc.b	"Autobus escolar", $FF
		even
CBTxt_Bus4Origin:
		dc.b	"??????????", $FF
		even
CBTxt_Bus4Height:
		dc.b	"2.50M (SD)", $FF
		even
CBTxt_Bus4Desc1:
		dc.b	"Clasico amarillo escolar", $FF
		even
CBTxt_Bus4Desc2:
		dc.b	"Configuracion variable  ", $FF
		even
CBTxt_Bus5Motor:
		dc.b	"340HP", $FF
		even
CBTxt_Bus5Rating:
		dc.b	"52 (max)", $FF
		even
CBTxt_Bus5Name:
		dc.b	"Paradiso GV1150", $FF
		even
CBTxt_Bus5Origin:
		dc.b	"Brasil    ", $FF
		even
CBTxt_Bus5Height:
		dc.b	"3.55M (SD)", $FF
		even
CBTxt_Bus5Desc1:
		dc.b	"Legendario de las vias  ", $FF
		even
CBTxt_Bus5Desc2:
		dc.b	"Favorito para Volvo     ", $FF
		even
CBTxt_ControlsEs:
		dc.b	"** CONTROLES **", $FF
		even
CBTxt_MoveLeftEs:
		dc.b	"<- Mover bus a la izquierda", $FF
		even
CBTxt_MoveRightEs:
		dc.b	"-> Mover bus a la derecha", $FF
		even
CBTxt_Controls:
		dc.b	"** CONTROLS **", $FF
		even
CBTxt_MoveLeft:
		dc.b	"<- Move left", $FF
		even
CBTxt_MoveRight:
		dc.b	"-> Move right", $FF
		even
CBTxt_HonkHorn:
		dc.b	1, "  Honk the horn", $FF
		even
CBTxt_Jump:
		dc.b	2, 3, " Jump", $FF
		even
CBTxt_SanicJump:
		dc.b	"^  Jump", $FF
		even
CBTxt_SanicSuperJump:
		dc.b	"v  Super jump", $FF
		even
CBTxt_GottaGoFast:
		dc.b	2, "  Gotta go fast", $FF
		even
CBTxt_Explode:
		dc.b	1, 3, " Explode", $FF
		even
CBTxt_Pause:
		dc.b	4, "  Pause", $FF
		even
CBTxt_HonkHornEs:
		dc.b	1, "  Tocar corneta", $FF
		even
CBTxt_ReturnToTitle:
		dc.b	3, "  Volver a la pantalla inicial", $FF
		even
CBTxt_PreparingEs:
		dc.b	"Preparate...", $FF
		even
CBTxt_Preparing:
		dc.b	"Preparing...", $FF
		even
CBTxt_Count3_1:
		dc.b	"333 ", $FF
		even
CBTxt_Count3_2:
		dc.b	"   3", $FF
		even
CBTxt_Count3_3:
		dc.b	" 33 ", $FF
		even
CBTxt_Count2_1:
		dc.b	" 22 ", $FF
		even
CBTxt_Count2_2:
		dc.b	"2  2", $FF
		even
CBTxt_Count2_3:
		dc.b	"  2 ", $FF
		even
CBTxt_Count2_4:
		dc.b	" 2  ", $FF
		even
CBTxt_Count2_5:
		dc.b	"2222", $FF
		even
CBTxt_Count1_1:
		dc.b	"  1 ", $FF
		even
CBTxt_Count1_2:
		dc.b	" 11 ", $FF
		even
CBTxt_Count1_3:
		dc.b	"1111", $FF
		even
CBTxt_Count0_1:
		dc.b	" 00 ", $FF
		even
CBTxt_Count0_2:
		dc.b	"0  0", $FF
		even
CBTxt_Version:
		dc.b	"ver.", $FF
		even
CBTxt_Dash:
		dc.b	"-", $FF
		even
CBTxt_Bus1Maker:
		dc.b	"[Irizar]", $FF
		even
CBTxt_Bus2Maker:
		dc.b	"[Busscar]", $FF
		even
CBTxt_Bus3Maker:
		dc.b	"[ENCAVA]", $FF
		even
CBTxt_Bus4Maker:
		dc.b	"[Generico]", $FF
		even
CBTxt_Bus5Maker:
		dc.b	"[Marcopolo]", $FF
		even
CBTxt_Bus1Name2:
		dc.b	"   Century 3.95", $FF
		even
CBTxt_Bus2Name2:
		dc.b	"   Jum Buss 360", $FF
		even
CBTxt_Bus3Name2:
		dc.b	"   E-NT6000", $FF
		even
CBTxt_Bus4Name2:
		dc.b	"   Autobus escolar", $FF
		even
CBTxt_Bus5Name2:
		dc.b	"   Paradiso GV1150", $FF
		even
CBTxt_ReturnToTitle2:
		dc.b	3, " = Regresar!", $FF
		even
CBTxt_CurrentBus:
		dc.b	"Tu autobus:", $FF
		even
CBTxt_Distance:
		dc.b	"Recorrido: 0", $FF
		even
CBTxt_DistanceBlank:
		dc.b	"     ", $FF
		even

; ===========================================================================
; Delay a number of frames
; ===========================================================================

CB_Delay:
		subq.w	#1,d2

@Wait:
		bsr.s	CB_VSync
		dbf	d2,@Wait
		rts

; ===========================================================================
; Vsync
; ===========================================================================

CB_VSync:
		move.w	#1,(CB_VSync_Flag).w

@Wait:
		tst.w	(CB_VSync_Flag).w
		bne.s	@Wait
		rts

; ===============================================================
; ---------------------------------------------------------------
; COMPER Decompressor
; ---------------------------------------------------------------
; INPUT:
;   a0  - Source Offset
;   a1  - Destination Offset
; ---------------------------------------------------------------
 
CompDec:
		move.l	a2,-(sp)

@newblock
		move.w	(a0)+,d0	; fetch description field
		moveq	#15,d3		; set bits counter to 16

@mainloop
		add.w	d0,d0		; roll description field
		bcs.s	@flag		; if a flag issued, branch
		move.w	(a0)+,(a1)+	; otherwise, do uncompressed data
		dbf	d3,@mainloop	; if bits counter remains, parse the next word
		bra.s	@newblock	; start a new block
 
; ---------------------------------------------------------------
@flag		moveq	#-1,d1		; init displacement
		move.b	(a0)+,d1	; load displacement
		add.w	d1,d1
		moveq	#0,d2		; init copy count
		move.b	(a0)+,d2	; load copy length
		beq.s	@end		; if zero, branch
		lea	(a1,d1),a2	; load start copy address

@loop		move.w	(a2)+,(a1)+	; copy given sequence
		dbf	d2,@loop	; repeat
		dbf	d3,@mainloop	; if bits counter remains, parse the next word
		bra.s	@newblock	; start a new block

@end		movea.l	(sp)+,a2
		rts

; ===========================================================================
; Load Kosinski art
; ===========================================================================

CB_LoadKosArt:
		movea.l	a1,a3
		jsr	KosDec
		bra.s	CB_LoadDecArt

CB_LoadCompArt:
		movea.l	a1,a3
		bsr.w	CompDec

CB_LoadDecArt:
		move.l	a3,d1
		andi.l	#$FFFFFF,d1
		move.l	a1,d3
		sub.l	a3,d3
		lsr.l	#1,d3
		move.w	a2,d2
		movea.l	a1,a3
		jsr	QueueDMATransfer
		movea.l	a3,a1
		bra.w	CB_VSync

; ===========================================================================
; Load 1BPP art
; ===========================================================================

CB_Load1BPPArt:
		move.w	d1,d3
		lsl.w	#1,d3
		move.l	d2,-(sp)

@Convert:
		moveq	#0,d0
		moveq	#0,d2
		move.b	(a0)+,d0
		move.b	d0,d2
		andi.b	#$F0,d0
		andi.b	#$F,d2
		lsr.b	#4,d0
		add.w	d0,d0
		add.w	d2,d2
		lea	(@ConvTable).l,a2
		adda.w	d0,a2
		move.w	(a2),(a1)+
		lea	(@ConvTable).l,a2
		adda.w	d2,a2
		move.w	(a2),(a1)+
		dbf	d1,@Convert

		move.l	(sp)+,d2
		move.l	#$FF0000,d1
		jsr	QueueDMATransfer
		bra.w	CB_VSync

; ===========================================================================

@ConvTable:
		dc.w	$0000
		dc.w	$0001
		dc.w	$0010
		dc.w	$0011
		dc.w	$0100
		dc.w	$0101
		dc.w	$0110
		dc.w	$0111
		dc.w	$1000
		dc.w	$1001
		dc.w	$1010
		dc.w	$1011
		dc.w	$1100
		dc.w	$1101
		dc.w	$1110
		dc.w	$1111

; ===========================================================================
; Load level tilemap
; ===========================================================================

CB_LoadLevelTilemap:
		lea	($C00000).l,a6

@Row:
		move.l	d0,4(a6)
		move.w	d1,d3

@Tile:
		move.w	(a1)+,d5
		move.w	d5,d6
		tst.w	d5
		beq.s	@Write
		add.w	d4,d5
		cmpi.w	#2,d6
		bne.s	@Write
		andi.w	#$FFF,d5

@Write:
		move.w	d5,(a6)
		dbf	d3,@Tile
		addi.l	#$800000,d0
		dbf	d2,@Row
		rts

; ===========================================================================
; Load a tilemap
; ===========================================================================

CB_LoadTilemap:
		lea	($C00000).l,a6

@Row:
		move.l	d0,4(a6)
		move.w	d1,d3

@Tile:
		move.w	(a1)+,d5
		add.w	d4,d5
		move.w	d5,(a6)
		dbf	d3,@Tile
		addi.l	#$800000,d0
		dbf	d2,@Row
		rts

; ===========================================================================
; Generate a tilemap
; ===========================================================================

CB_GenTilemap:
		lea	($C00000).l,a6

@Row:
		move.l	d0,4(a6)
		move.w	d1,d3

@Tile:
		move.w	d4,(a6)
		addq.w	#1,d4
		dbf	d3,@Tile
		addi.l	#$800000,d0
		dbf	d2,@Row
		rts

; ===========================================================================
; Get plane location VRAM address
; ===========================================================================

CB_GetBGPlaneLoc:
		moveq	#0,d0
		move.l	#$00036000,d0
		bra.s	CB_GetPlaneLoc

CB_GetFGPlaneLoc:
		moveq	#0,d0
		move.l	#$00034000,d0

CB_GetPlaneLoc:
		add.w	d1,d1
		add.w	d1,d0
		lsl.w	#7,d2
		add.w	d2,d0
		swap	d0
		rts

; ===========================================================================
; Draw text
; ===========================================================================

CB_DrawText:
		lea	($C00000).l,a5
		move.l	d0,4(a5)
		ror.w	#4,d3

@Loop:
		moveq	#0,d1
		move.b	(a1)+,d1
		cmpi.b	#$FF,d1
		beq.s	@End
		or.w	d3,d1
		move.w	d1,(a5)
		bra.s	@Loop

@End:
		rts

; ===========================================================================
; Load a palette
; ===========================================================================

CB_LoadPal:
		lea	(CB_PalIndex).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		move.w	(a1)+,d7

CB_LoadPalDirect:
		move.l	(a2)+,(a3)+
		dbf	d7,CB_LoadPalDirect
		rts

; ===========================================================================
; Initialize the sound driver
; ===========================================================================

CBSnd_Init:
		move.b	#0,(CBSnd_Paused).w
		move.b	#0,(CBSnd_Stopped).w
		move.b	#CBSNDID_STOP,(CBSnd_Sound_ID).w

CBSnd_Reset:
		move.l	#0,(CBSnd_Rng_Seed1).w
		move.l	#0,(CBSnd_Rng_Seed2).w
		move.w	#0,(CBSnd_Counter).w
		move.w	#0,(CBSnd_MotorCounter).w
		move.w	#0,(CBSnd_Motor_Mode).w
		rts

; ===========================================================================
; Unmute PSG
; ===========================================================================

CBSnd_Unmute:
		move.b	#0,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol
		move.b	#1,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol
		move.b	#2,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol
		rts

; ===========================================================================
; Mute PSG
; ===========================================================================

CBSnd_Mute:
		move.b	#0,d5
		move.b	#0,d0
		bsr.w	CBSnd_SetPSGVol
		move.b	#1,d5
		move.b	#0,d0
		bsr.w	CBSnd_SetPSGVol
		move.b	#2,d5
		move.b	#0,d0
		bsr.w	CBSnd_SetPSGVol
		move.b	#3,d5
		move.b	#0,d0
		bra.w	CBSnd_SetPSGVol

; ===========================================================================
; Stop sound
; ===========================================================================

CBSnd_Stop:
		bsr.w	CBSnd_Mute
		move.b	#CBSNDID_STOP,(CBSnd_Sound_ID).w
		move.b	#1,(CBSnd_Stopped).w
		bra.w	CBSnd_Reset

; ===========================================================================
; Play a sound
; ===========================================================================

CBSnd_Play:
		move.b	d0,(CBSnd_Sound_ID).w
		bsr.w	CBSnd_Mute
		bra.w	CBSnd_Reset

; ===========================================================================
; Update driver
; ===========================================================================

CBSnd_Update:
		cmpi.b	#CBSNDID_STOP,(CBSnd_Sound_ID).w
		beq.s	@Stop
		tst.b	(CBSnd_Paused).w
		beq.s	@Update

@Stop:
		bra.w	CBSnd_Mute

@Update:
		moveq	#0,d0
		move.b	(CBSnd_Sound_ID).w,d0
		lsl.w	#2,d0
		andi.w	#$7C,d0
		movea.l	@Sounds(pc,d0.w),a0
		jmp	(a0)
		
; ===========================================================================

@Sounds:
		dc.l	CBSnd_PlayTitle
		dc.l	CBSnd_PlayMenu
		dc.l	CBSnd_PlayHonk
		dc.l	CBSnd_PlayBusSounds
		dc.l	CBSnd_PlayCount
		dc.l	CBSnd_PlayCountDone

; ===========================================================================
; Title "music"
; ===========================================================================

CBSnd_PlayTitle:
		bsr.w	CBSnd_Unmute
		tst.w	(CBSnd_Counter).w
		beq.s	@Step
		subq.w	#1,(CBSnd_Counter).w
		rts

@Step:
		move.w	#9,(CBSnd_Counter).w

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#500,d0
		move.b	#0,d5
		bsr.w	CBSnd_SetPSGFreq

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#600,d0
		move.b	#1,d5
		bsr.w	CBSnd_SetPSGFreq

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#700,d0
		move.b	#2,d5
		bra.w	CBSnd_SetPSGFreq

; ===========================================================================
; Menu "music"
; ===========================================================================

CBSnd_PlayMenu:
		bsr.w	CBSnd_Unmute
		tst.w	(CBSnd_Counter).w
		beq.s	@Step
		subq.w	#1,(CBSnd_Counter).w
		rts

@Step:
		move.w	#9,(CBSnd_Counter).w

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#200,d0
		move.b	#0,d5
		bsr.w	CBSnd_SetPSGFreq

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#250,d0
		move.b	#1,d5
		bsr.w	CBSnd_SetPSGFreq

		move.w	#40,d0
		bsr.w	CB_RandomRange
		mulu.w	#10,d0
		addi.w	#325,d0
		move.b	#2,d5
		bra.w	CBSnd_SetPSGFreq

; ===========================================================================
; Play honking sound
; ===========================================================================

CBSnd_PlayHonk:
		move.b	#1,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol
		
		move.b	#2,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol

		move.b	#1,d5
		move.w	#630,d0
		bsr.w	CBSnd_SetPSGFreq
		
		move.b	#2,d5
		move.w	#980,d0
		bra.w	CBSnd_SetPSGFreq

; ===========================================================================
; Play and handle bus sounds
; ===========================================================================

CBSnd_PlayBusSounds:
		move.b	#2,d5
		move.w	#980,d0
		bsr.w	CBSnd_SetPSGFreq

@HandleMotorVolume:
		cmpi.w	#1,(CBSnd_Motor_Mode).w
		beq.s	@Moving
		move.w	#0,(CBSnd_MotorCounter).w
		cmpi.w	#2,(CBSnd_Motor_Mode).w
		beq.s	@Moving
		cmpi.w	#3,(CBSnd_Motor_Mode).w
		beq.s	@Idle

		move.b	#3,d5
		move.b	#0,d0
		jsr	CBSnd_SetPSGVol
		move.b	#0,d5
		move.b	#0,d0
		jsr	CBSnd_SetPSGVol
		bra.w	@HandleMotorFreq

@Moving:
		move.b	#0,d5
		move.b	#$D,d0
		jsr	CBSnd_SetPSGVol
		move.b	#3,d5
		move.b	#$C,d0
		jsr	CBSnd_SetPSGVol
		bra.w	@HandleMotorFreq

@Idle:
		move.b	#0,d5
		move.b	#9,d0
		jsr	CBSnd_SetPSGVol
		move.b	#3,d5
		move.b	#8,d0
		jsr	CBSnd_SetPSGVol

@HandleMotorFreq:
		move.b	#3,d5
		move.w	#7,d0
		jsr	CBSnd_SetPSGFreq

		addq.w	#1,(CBSnd_MotorCounter).w
		moveq	#0,d0
		move.w	(CBSnd_MotorCounter).w,d0
		divu.w	#3,d0
		clr.w	d0
		swap	d0
		tst.w	d0
		beq.s	@MotorFreq1
		cmpi.w	#1,d0
		beq.s	@MotorFreq2
		cmpi.w	#2,d0
		beq.s	@MotorFreq3
		bra.w	@CheckCounter

@MotorFreq1:
		move.b	#0,d5
		move.w	#75,d0
		jsr	CBSnd_SetPSGFreq
		bra.w	@CheckCounter

@MotorFreq2:
		move.b	#0,d5
		move.w	#50,d0
		jsr	CBSnd_SetPSGFreq
		bra.w	@CheckCounter

@MotorFreq3:
		move.b	#0,d5
		move.w	#25,d0
		jsr	CBSnd_SetPSGFreq

@CheckCounter:
		cmpi.w	#39,(CBSnd_MotorCounter).w
		ble.s	@HandleBackup
		move.w	#0,(CBSnd_MotorCounter).w

@HandleBackup:
		btst	#6,($FFFFD022).w
		bne.s	@NoBackup
		cmpi.w	#1,(CBSnd_Motor_Mode).w
		bne.s	@NoBackup
		cmpi.w	#20,(CBSnd_MotorCounter).w
		bgt.s	@NoBackup

		move.b	#1,d5
		move.b	#$D,d0
		jsr	CBSnd_SetPSGVol
		move.b	#1,d5
		move.w	#891,d0
		jsr	CBSnd_SetPSGFreq
		move.b	#0,(CBSnd_Backup_Beep).w
		bra.w	@CheckBackupBeep

@NoBackup:
		move.b	#1,d5
		move.b	#0,d0
		jsr	CBSnd_SetPSGVol
		move.b	#1,(CBSnd_Backup_Beep).w

@CheckBackupBeep:
		tst.b	(CBSnd_Honk).w
		beq.s	@NotHonking
		bra.w	CBSnd_PlayHonk

@NotHonking:
		tst.b	(CBSnd_Backup_Beep).w
		beq.s	@DontMuteBackup

		move.b	#1,d5
		move.b	#0,d0
		bsr.w	CBSnd_SetPSGVol

@DontMuteBackup:
		move.b	#2,d5
		move.b	#0,d0
		bra.w	CBSnd_SetPSGVol

; ===========================================================================
; Play countdown sound
; ===========================================================================

CBSnd_PlayCount:
		move.b	#1,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol
		
		move.b	#1,d5
		move.w	#750,d0
		bra.w	CBSnd_SetPSGFreq

; ===========================================================================
; Play countdown done sound
; ===========================================================================

CBSnd_PlayCountDone:
		move.b	#1,d5
		move.b	#$F,d0
		bsr.w	CBSnd_SetPSGVol

		move.b	#1,d5
		move.w	#971,d0

; ===========================================================================
; Set PSG frequency
; ===========================================================================

CBSnd_SetPSGFreq:
		andi.b	#3,d5
		cmpi.b	#3,d5
		beq.s	@Noise
		not.w	d0
		ori.b	#4,d5
		lsl.b	#5,d5
		move.b	d0,d1
		andi.b	#$F,d1
		or.b	d5,d1
		move.b	d1,($C00011).l
		lsr.w	#4,d0
		andi.b	#$3F,d0
		move.b	d0,($C00011).l
		rts

@Noise:
		andi.b	#7,d0
		ori.b	#$E0,d0
		move.b	d0,($C00011).l
		rts

; ===========================================================================
; Set PSG volume
; ===========================================================================

CBSnd_SetPSGVol:
		andi.b	#3,d5
		lsl.b	#5,d5
		ori.b	#$90,d5
		not.b	d0
		andi.b	#$F,d0
		or.b	d5,d0
		move.b	d0,($C00011).l
		rts

; ===========================================================================
; Generate a random number
; ===========================================================================

CB_Random:
		jsr	RandomNumber
		move.l	d0,d2
		movem.l	(CBSnd_Rng_Seed1).w,d0-d1
		andi.b	#$E,d0
		ori.b	#$20,d0
		add.l	d0,d2
		move.l	d1,d3
		add.l	d2,d2
		addx.l	d3,d3
		add.l	d2,d0
		addx.l	d3,d1
		swap	d3
		swap	d2
		move.w	d2,d3
		clr.w	d2
		add.l	d2,d0
		addx.l	d3,d1
		movem.l	d0-d1,(CBSnd_Rng_Seed1).w
		move.l	d1,d0
		rts

; ===========================================================================
; Generate a random number within a range
; ===========================================================================

CB_RandomRange:
		move.w	d0,d2
		beq.w	@End
		movem.w	d2,-(sp)
		bsr.s	CB_Random
		movem.w	(sp)+,d2
		clr.w	d0
		swap	d0
		divu.w	d2,d0
		clr.w	d0
		swap	d0

@End:
		rts

; ===========================================================================