
; ===============================================================
; Mega PCM Driver Include File
; (c) 2012, Vladikcomper
; ===============================================================

; ---------------------------------------------------------------
; Variables used in DAC table
; ---------------------------------------------------------------

; flags
panLR	= $C0
panL	= $80
panR	= $40
pcm	= 0
dpcm	= 4
loop	= 2
pri	= 1

; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------

z80word macro Value
	dc.w	((\Value)&$FF)<<8|((\Value)&$FF00)>>8
	endm

DAC_Entry macro Pitch,Offset,Flags
	dc.b	\Flags			; 00h	- Flags
	dc.b	\Pitch			; 01h	- Pitch
	dc.b	(\Offset>>15)&$FF	; 02h	- Start Bank
	dc.b	(\Offset\_End>>15)&$FF	; 03h	- End Bank
	z80word	(\Offset)|$8000		; 04h	- Start Offset (in Start bank)
	z80word	(\Offset\_End-1)|$8000	; 06h	- End Offset (in End bank)
	endm
	
IncludeDAC macro Name,Extension
\Name:
	if strcmp('\extension','wav')
		incbin	'dac/\Name\.\Extension\',$3A
	else
		incbin	'dac/\Name\.\Extension\'
	endc
\Name\_End:
	endm

; ---------------------------------------------------------------
; Driver's code
; ---------------------------------------------------------------

MegaPCM:
	incbin	'MegaPCM.z80'

; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

	DAC_Entry	$03, HK97Theme, pcm+loop	; $81	- Hong Kong 97
	DAC_Entry	$03, Beatles, pcm+loop		; $82	- Beatles
	DAC_Entry	$03, RickRoll, pcm+loop		; $83	- Rick Roll
	DAC_Entry	$03, Sanic, pcm+loop		; $84	- Sanic
	DAC_Entry	$03, Death, pcm+loop		; $85	- Death
	DAC_Entry	$03, PriceIsRight, pcm		; $86	- Price Is Right Fail
	DAC_Entry	$08, Kick, dpcm			; $87	- Kick
	DAC_Entry	$08, Snare, dpcm		; $88	- Snare
	DAC_Entry	$1B, Timpani, dpcm		; $89	- Timpani
	DAC_Entry	$03, BSOD, pcm			; $8A	- BSOD
	DAC_Entry	$03, Beatles420, pcm+loop	; $8B	- Beatles 420 Remix
	DAC_Entry	$03, JohnCena, pcm+loop		; $8C	- John Cena
	DAC_Entry	$03, HeMan, pcm+loop		; $8D	- He-Man
	DAC_Entry	$03, BobTheBuilder, pcm+loop	; $8E	- Bob The Builder

MegaPCM_End:

; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

	IncludeDAC	HK97Theme, bin
	IncludeDAC	Beatles, bin
	IncludeDAC	RickRoll, bin
	IncludeDAC	Sanic, bin
	IncludeDAC	Death, bin
	IncludeDAC	PriceIsRight, bin
	IncludeDAC	Kick, bin
	IncludeDAC	Snare, bin
	IncludeDAC	Timpani, bin
	IncludeDAC	BSOD, bin
	IncludeDAC	Beatles420, bin
	IncludeDAC	JohnCena, bin
	IncludeDAC	HeMan, bin
	IncludeDAC	BobTheBuilder, bin
	even

