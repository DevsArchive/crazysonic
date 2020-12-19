; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_Rxjas:	
		dc.w SME_Rxjas_A-SME_Rxjas, SME_Rxjas_1A-SME_Rxjas	
		dc.w SME_Rxjas_25-SME_Rxjas, SME_Rxjas_30-SME_Rxjas	
		dc.w SME_Rxjas_3B-SME_Rxjas	
SME_Rxjas_A:	dc.b 3	
		dc.b $F0, $B, 0, 0, $E8	
		dc.b $F0, $B, 8, 0, 0	
		dc.b $10, 1, 0, $38, $FC	
SME_Rxjas_1A:	dc.b 2	
		dc.b $F0, $F, 0, $C, $F0	
		dc.b $10, 1, 0, $38, $FC	
SME_Rxjas_25:	dc.b 2	
		dc.b $F0, 3, 0, $1C, $FC	
		dc.b $10, 1, 8, $38, $FC	
SME_Rxjas_30:	dc.b 2	
		dc.b $F0, $F, 8, $C, $F0	
		dc.b $10, 1, 8, $38, $FC	
SME_Rxjas_3B:	dc.b 3	
		dc.b $F0, $B, $20, $20, $E8	
		dc.b $F0, $B, $20, $2C, 0	
		dc.b $10, 1, $20, $38, $FC	
		even