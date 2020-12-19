; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_sMiRW:	
		dc.w SME_sMiRW_1A-SME_sMiRW, SME_sMiRW_1B-SME_sMiRW	
		dc.w SME_sMiRW_30-SME_sMiRW, SME_sMiRW_45-SME_sMiRW	
		dc.w SME_sMiRW_5A-SME_sMiRW, SME_sMiRW_6A-SME_sMiRW	
		dc.w SME_sMiRW_7A-SME_sMiRW, SME_sMiRW_8F-SME_sMiRW	
		dc.w SME_sMiRW_A4-SME_sMiRW, SME_sMiRW_B9-SME_sMiRW	
		dc.w SME_sMiRW_CE-SME_sMiRW, SME_sMiRW_DE-SME_sMiRW	
		dc.w SME_sMiRW_EE-SME_sMiRW	
SME_sMiRW_1A:	dc.b 0	
SME_sMiRW_1B:	dc.b 4	
		dc.b 9, 0, 0, 0, $FC	
		dc.b 9, 0, 0, 1, 4	
		dc.b 1, 0, 0, 2, $FC	
		dc.b 1, 0, 0, 3, 4	
SME_sMiRW_30:	dc.b 4	
		dc.b 9, 0, 0, 4, $FB	
		dc.b 9, 0, 0, 5, 3	
		dc.b 1, 0, 0, 6, $FB	
		dc.b 1, 0, 0, 7, 3	
SME_sMiRW_45:	dc.b 4	
		dc.b 8, 0, 0, 8, $FB	
		dc.b 8, 0, 0, 9, 3	
		dc.b 0, 0, 0, $A, $FB	
		dc.b 0, 0, 0, $B, 3	
SME_sMiRW_5A:	dc.b 3	
		dc.b 8, 0, 0, $C, $FB	
		dc.b 8, 0, 0, $D, 3	
		dc.b 0, 0, 0, $E, $FB	
SME_sMiRW_6A:	dc.b 3	
		dc.b 8, 0, 0, $F, $FB	
		dc.b 8, 0, 0, $10, 3	
		dc.b 0, 0, 0, $11, $FB	
SME_sMiRW_7A:	dc.b 4	
		dc.b $A, 0, 0, $12, $FC	
		dc.b $A, 0, 0, $13, 4	
		dc.b 2, 0, 0, $14, $FC	
		dc.b 2, 0, 0, $15, 4	
SME_sMiRW_8F:	dc.b 4	
		dc.b 2, 0, $10, 0, $FD	
		dc.b 2, 0, $10, 1, 5	
		dc.b $A, 0, $10, 2, $FD	
		dc.b $A, 0, $10, 3, 5	
SME_sMiRW_A4:	dc.b 4	
		dc.b 2, 0, $18, 4, 0	
		dc.b 2, 0, $18, 5, $F8	
		dc.b $A, 0, $18, 6, 0	
		dc.b $A, 0, $18, 7, $F8	
SME_sMiRW_B9:	dc.b 4	
		dc.b 5, 0, $18, 8, 1	
		dc.b 5, 0, $18, 9, $F9	
		dc.b $D, 0, $18, $A, 1	
		dc.b $D, 0, $18, $B, $F9	
SME_sMiRW_CE:	dc.b 3	
		dc.b 8, 0, 8, $C, 1	
		dc.b 8, 0, 8, $D, $F9	
		dc.b 0, 0, 8, $E, 1	
SME_sMiRW_DE:	dc.b 3	
		dc.b 5, 0, $18, $F, 1	
		dc.b 5, 0, $18, $10, $F9	
		dc.b $D, 0, $18, $11, 1	
SME_sMiRW_EE:	dc.b 4	
		dc.b 2, 0, $18, $12, $FF	
		dc.b 2, 0, $18, $13, $F7	
		dc.b $A, 0, $18, $14, $FF	
		dc.b $A, 0, $18, $15, $F7	
		even