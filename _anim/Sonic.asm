; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
		dc.w BusAni_Walk-BusAniData
		dc.w BusAni_Run-BusAniData
		dc.w BusAni_Roll-BusAniData
		dc.w BusAni_Roll2-BusAniData
		dc.w BusAni_Push-BusAniData
		dc.w BusAni_Wait-BusAniData
		dc.w BusAni_Balance-BusAniData
		dc.w BusAni_LookUp-BusAniData
		dc.w BusAni_Duck-BusAniData
		dc.w BusAni_Warp1-BusAniData
		dc.w BusAni_Warp2-BusAniData
		dc.w BusAni_Warp3-BusAniData
		dc.w BusAni_Warp4-BusAniData
		dc.w BusAni_Stop-BusAniData
		dc.w BusAni_Float1-BusAniData
		dc.w BusAni_Float2-BusAniData
		dc.w BusAni_Spring-BusAniData
		dc.w BusAni_LZHang-BusAniData
		dc.w BusAni_Leap1-BusAniData
		dc.w BusAni_Leap2-BusAniData
		dc.w BusAni_Surf-BusAniData
		dc.w BusAni_Bubble-BusAniData
		dc.w BusAni_Death1-BusAniData
		dc.w BusAni_Drown-BusAniData
		dc.w BusAni_Death2-BusAniData
		dc.w BusAni_Shrink-BusAniData
		dc.w BusAni_Hurt-BusAniData
		dc.w BusAni_LZSlide-BusAniData
		dc.w BusAni_Blank-BusAniData
		dc.w BusAni_Float3-BusAniData
		dc.w BusAni_Float4-BusAniData
		dc.w BusAni_Submarine-BusAniData
BusAni_Walk:	dc.b $FF, 1, 2, $FF, 0
BusAni_Run:	dc.b $FF, 1, 2, $FF, 0
BusAni_Roll:	dc.b $FE, 1, 9, $A, $B, $FF, 0
BusAni_Roll2:	dc.b $FE, 1, 9, $A, $B, $FF, 0
BusAni_Push:	dc.b 1, 1, $FF, 0
BusAni_Wait:	dc.b 1, 1, $FF, 0
BusAni_Balance:	dc.b 1, 1, $FF, 0
BusAni_LookUp:	dc.b 1, 1, $FF, 0
BusAni_Duck:	dc.b 1, 1, $FF, 0
BusAni_Warp1:	dc.b 1, 1, $FF, 0
BusAni_Warp2:	dc.b 1, 1, $FF, 0
BusAni_Warp3:	dc.b 1, 1, $FF, 0
BusAni_Warp4:	dc.b 1, 1, $FF, 0
BusAni_Stop:	dc.b 1, 1, $FF, 0
BusAni_Float1:	dc.b 1, 1, $FF, 0
BusAni_Float2:	dc.b 1, 1, $FF, 0
BusAni_Spring:	dc.b 1, 1, $FF, 0
BusAni_LZHang:	dc.b 1, 1, $FF, 0
BusAni_Leap1:	dc.b 1, 1, $FF, 0
BusAni_Leap2:	dc.b 1, 1, $FF, 0
BusAni_Surf:	dc.b 1, 1, $FF, 0
BusAni_Bubble:	dc.b 1, 1, $FF, 0
BusAni_Death1:	dc.b 1, 1, $FF, 0
BusAni_Drown:	dc.b 1, 1, $FF, 0
BusAni_Death2:	dc.b 1, 1, $FF, 0
BusAni_Shrink:	dc.b 1, 1, $FF, 0
BusAni_Hurt:	dc.b 1, 1, $FF, 0
BusAni_LZSlide:	dc.b 1, 1, $FF, 0
BusAni_Blank:	dc.b 1, 1, $FF, 0
BusAni_Float3:	dc.b 1, 1, $FF, 0
BusAni_Float4:	dc.b 1, 1, $FF, 0
BusAni_Submarine:
		dc.b 1, $D, $FF, 0
		even