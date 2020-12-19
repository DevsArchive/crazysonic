; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_a6XSv:	
		dc.w SME_a6XSv_A-SME_a6XSv, SME_a6XSv_1F-SME_a6XSv	
		dc.w SME_a6XSv_34-SME_a6XSv, SME_a6XSv_49-SME_a6XSv	
		dc.w SME_a6XSv_54-SME_a6XSv	
SME_a6XSv_A:	dc.b 4	
		dc.b 9, 0, 0, 0, $FA	
		dc.b 9, 0, 0, 1, 2	
		dc.b 1, 0, 0, 2, $FA	
		dc.b 1, 0, 0, 3, 2	
SME_a6XSv_1F:	dc.b 4	
		dc.b 7, 0, 0, 4, $FA	
		dc.b 7, 0, 0, 5, 2	
		dc.b $FF, 0, 0, 6, $FA	
		dc.b $FF, 0, 0, 7, 2	
SME_a6XSv_34:	dc.b 4	
		dc.b 6, 0, 0, 8, $FA	
		dc.b 6, 0, 0, 9, 2	
		dc.b $FE, 0, 0, $A, $FA	
		dc.b $FE, 0, 0, $B, 2	
SME_a6XSv_49:	dc.b 2	
		dc.b 5, 0, 0, $C, $FA	
		dc.b 5, 0, 0, $D, 2	
SME_a6XSv_54:	dc.b 4	
		dc.b 8, 0, 0, $E, $FA	
		dc.b 8, 0, 0, $F, 2	
		dc.b 0, 0, 0, $10, $FA	
		dc.b 0, 0, 0, $11, 2	
		even