#include "Font_1.au3"
;#include "GDIP.au3"
;#include "MemFont.au3"

Func _DrawVisual()
	$fTime = TimerDiff($iTimer)
	Switch $fTime
		Case 0 To 30
			Sleep(9)
		Case Else
			$aMsg = GUIGetCursorInfo($Form)
			$iTimer = TimerInit()
			Switch $iVisual
				Case 1
					_Visual_TextWaveform($hPath_AutoIt, $aBounds_AutoIt[2] / 30)
				Case 2
					_Visual_Phase()
				Case 3
					_Visual_WaveLines()
				Case 4
					_Visual_ColorNoise()
				Case 5
					_Visual_Circle()
				Case 6
					_Visual_SpaceWave()
				Case 7
					_Visual_StarField()
				Case 8
					_Visual_FFT()
				Case 9
					_Visual_FFT3D()
				Case 10
					_Visual_WaveOsci()
				Case 11
					_Visual_WaveLaser()
				Case 12
					_Visual_WaveProjector()
				Case 13
					_Visual_LevelMeter3D()
				Case 14
					_Visual_WaterWave(0, 0, $iWidth, $iHeight)
				Case 15
					_Visual_Wurmhole()
				Case 16
					_Visual_Test()
			EndSwitch
			If $iVisual <> $iVisualNext Then
				$iVisual = $iVisualNext
				_PrepareVisual($iVisual)
			EndIf
	EndSwitch
EndFunc   ;==>_DrawVisual
Func _Visual_Test()
	If Not $MusicHandle Then Return -1
	;_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $values[4] = [1, 1, 100, 100]
	$values[0] = 210 - _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3 * 100
	$values[1] = 210 - _BASS_EXT_Level2dB(_Bass_HiWord($iLong) / 32768) ^ 3 * 100
	Local $iColor = _SetColor($aColorStep1, $aColor1, 1)
	Local $iAlpha = 0x05 + 0x20 * _BASS_EXT_Level2dB(_Bass_HiWord($iLong) / 32768) ^ 3
	_GDIPlus_PenSetColor($hPen1, BitOR(BitXOR($iColor, 0xFF000000), BitShift($iAlpha, -24)))
	Local $size = $iHeight / 2 + (_BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 6 * $iHeight / 2)
	Local $halfSize = $size / 2
	Local $majorR = $halfSize - 100
	Local $minorR = $values[0] / 10
	Local $diff = $majorR - $minorR
	Local $s = $diff / $minorR
	Local $theta = 0
	Local $angleMuliplier = $values[1] / 10
	Local $radiusEffect = $values[2] / 2 + $minorR
	Local $steps = $values[3] * 2
	Local $oldx, $oldY
	Local $mult, $X, $y
	Local $hPath = _GDIPlus_PathCreate(0)
	;_GDIPlus_PathAddEllipse($hPath,$iWidth/2-$majorR/2, $iHeight/2-$majorR/2,$majorR,$majorR)
	;_GDIPlus_PathAddEllipse($hPath,$iWidth/2-$majorR/2, $iHeight/2-$majorR/2,$majorR,$majorR)
	For $i = 0 To $steps
		$mult = $angleMuliplier * $theta
		$X = $diff * Sin($mult) + $radiusEffect * Sin($mult * $s) + $iWidth / 2
		$y = $diff * Cos($mult) - $radiusEffect * Cos($mult * $s) + $iHeight / 2
		$theta += $PI * 4 / $steps
		If $oldx Then _GDIPlus_PathAddLine($hPath, $oldx, $oldY, $X, $y)
		$oldx = $X
		$oldY = $y
	Next
	;_GDIPlus_PathCloseFigures($hPath)
	_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath, $hPen1)
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	;_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath,$hBrush1)
	_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath, $hPen2)
	_GDIPlus_PathDispose($hPath)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_Test
Func _Visual_Wurmhole()
	If Not $MusicHandle Then Return -1
	Local $iR, $iX, $iY, $iMax, $iC, $iVal
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $aWave = _BASS_EXT_ChannelGetWaveform($MusicHandle, 180, 3)
	Local Static $iStep = 0
	$iStep += 0.01 + 0.1 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 5
	Local $iX = $iWidth / 2 + (Cos($iStep / 2) + Sin(($iStep + 2) / 4)) * ($iHeight / 20)
	Local $iY = $iHeight / 2 + (Sin($iStep / 3) + Cos(($iStep + 2) / 6)) * ($iHeight / 20)
	Local $iRad = $iHeight / 20
	Local $iAmp = $iHeight / 60
	Local $aCurve[360][2] = [[359]]
	If IsArray($aWave) Then
		For $i = 1 To 180
			If Not $aWave[$i][1] Then $aWave[$i][1] = Random(-0.0001, 0.0001)
			$aCurve[$i][0] = Round(Cos($i * $DegToRad) * $iRad + ($iAmp * $aWave[$i][1])) + $iX
			$aCurve[$i][1] = Round(Sin($i * $DegToRad) * $iRad + ($iAmp * $aWave[$i][1])) + $iY
		Next
		For $i = 181 To 359
			$aCurve[$i][0] = Round(Cos($i * $DegToRad) * $iRad + ($iAmp * $aWave[360 - $i][1])) + $iX
			$aCurve[$i][1] = Round(Sin($i * $DegToRad) * $iRad + ($iAmp * $aWave[360 - $i][1])) + $iY
		Next
	EndIf
	Local $fTransform = 0.1 + 0.1 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 5
	_GDIPlus_GraphicsResetTransform($hGfxTrans)
	_GDIPlus_GraphicsTranslateTransform($hGfxTrans, $iWidth / 2, $iHeight / 2)
	_GDIPlus_GraphicsRotateTransform($hGfxTrans, 3)
	_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -$iWidth / 2, -$iHeight / 2)
	_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -(($iX - ($iWidth / 2 - $iX) * $fTransform ^ 3 * 0.1) * $fTransform), -(($iY - ($iHeight / 2 - $iY) * $fTransform ^ 3 * 0.1) * $fTransform))
	_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
	Local $iColor = _SetColor($aColorStep1, $aColor1, 1 + 10 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 5)
	_GDIPlus_PenSetColor($hPen1, $iColor)
	_GDIPlus_BrushSetSolidColor($hBrush1, $iColor)
	_GDIPlus_GraphicsFillClosedCurve($hGfxBuffer, $aCurve, $hBrush1)
	_GDIPlus_GraphicsFillClosedCurve($hGfxBuffer, $aCurve, $hBrushTrans)
	_GDIPlus_GraphicsDrawClosedCurve($hGfxBuffer, $aCurve, $hPen1)
	_GDIPlus_GraphicsDrawClosedCurve($hGfxBuffer, $aCurve, $hPen2)
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_Wurmhole
Func _Visual_ColorNoise()
	If Not $MusicHandle Then Return -1
	Local Const $W = $iWidth, $H = $iHeight
	Local Const $W2 = $W / 2, $H2 = $H / 2
	Local Const $W6 = $W / 6, $H6 = $H / 6
	Local Static $i, $nAngle
	Local $level, $low, $high, $fps, $aWave
	Local $color1[3]
	Local $color2 = $color1
	Local $dist1 = $H2 - 40
	Local $dist2 = $H2 + 40
	Local Static $speed = 1
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	$nAngle += Cos($i / 16) / 4
	Local $hMatrix = _GDIPlus_MatrixCreate()
	_GDIPlus_MatrixTranslate($hMatrix, $W2, $H2)
	_GDIPlus_MatrixRotate($hMatrix, $nAngle, 0)
	_GDIPlus_MatrixTranslate($hMatrix, -$W2, -$H2)
	_GDIPlus_GraphicsSetTransform($hGfxTrans, $hMatrix)
	$level = _BASS_ChannelGetLevel($MusicHandle)
	$high = BitShift($level, 16)
	$low = BitAND($level, 0x0000FFFF)
	$aWave = _BASS_EXT_ChannelGetWaveformEx($MusicHandle, 512, 0, $dist1, $W, $H6, 0, $dist2, $W, $H6)
	$color1[0] = Hex(0xF0 * Sin($high) * 4, 2)
	$color1[1] = Hex(0xF0 * - Cos($high) * 4, 2)
	$color1[2] = Hex(0xF0 * Cos($high) * 4, 2)
	_GDIPlus_PenSetColor($hPen1, "0xA0" & Hex(_ColorSetRGB($color1), 6))
	$color2[0] = Hex(Cos($low) * 1024, 2)
	$color2[1] = Hex(Cos($low) * 1024, 2)
	$color2[2] = Hex(Cos($low) * 1024, 2)
	_GDIPlus_PenSetColor($hPen2, "0xA0" & Hex(_ColorSetRGB($color2), 6))
	DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen1, "ptr", $aWave[0], "int", $aWave[2])
	DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen2, "ptr", $aWave[1], "int", $aWave[2])
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsDrawImageRect($hGfxTrans, $hBmpBuffer, -$speed, -$speed, $W + 2 * $speed, $H + 2 * $speed)
	$speed += Sin($i / 8) * 1.5
	$i += 1
EndFunc   ;==>_Visual_ColorNoise
Func _Visual_WaterWave($iX1, $iY1, $iX2, $iY2)
	If Not $MusicHandle Then Return -1
	Local $hPath = _GDIPlus_PathCreate(0)
	;Local $iLong = _BASS_ChannelGetLevel($hStream)
	;Local $fLevelL = _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 2 /5
	Local $fMax = 0
	Local $aWave = _BASS_EXT_ChannelGetWaveform($MusicHandle, 128, 3)
	For $i = 1 To $aWave[0][0]
		If Abs($aWave[$i][1]) > $fMax Then
			$fMax = Abs($aWave[$i][1])
			$aWater[1] = $aWave[$i][1]
		EndIf
	Next
	Local $fD = 4
	Local $iR = 50 * $fD + 4
	Local $iPersp = $iWidth * 1.5
	Local $fO
	Local $iAmp = 8
	For $i = 50 To 1 Step -1
		$iR -= $fD
		$fO = $aWater[$i] * $iAmp
		_GDIPlus_PathAddEllipse($hPath, $iWidth / 2 - $iR / 2, $iHeight / 2 - $iR / 2 - $fO, $iR, $iR)
		$aWater[$i] = $aWater[$i - 1]
		;ConsoleWrite(0.00001*$i^2 & @CRLF)
		If $aWater[$i] > 0 Then
			$aWater[$i] -= 0.00001 * $i ^ 2
		ElseIf $aWater[$i] < 0 Then
			$aWater[$i] += 0.00001 * $i ^ 2
		EndIf
	Next
	Local $aP_Warp[5][2] = [[4, 0],[$iX1, $iY1],[$iX2, $iY1],[$iX1 - $iPersp, $iY2],[$iX2 + $iPersp, $iY2]]
	_GDIPlus_PathWarp($hPath, 0, $aP_Warp, $iX1, $iY1, $iX2 - $iX1, $iY2 - $iY1)
	_GDIPlus_PathBrushSetCenterColor($hBrushWW, _SetColor($aColorStep1, $aColor1, 1))
	;_GDIPlus_PathBrushSetCenterColor($hBrushWW, 0xFF0000FF)
	Local $hPen1 = _GDIPlus_PenCreate2($hBrushWW)
	Local $hPen2 = _GDIPlus_PenCreate2($hBrushWW, 4)
	;_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
	_GDIPlus_GraphicsDrawImage($hGfxExt, $hBmpTrans, 0, 0)
	;_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath, $hBrushWW)
	_GDIPlus_GraphicsDrawPath($hGfxExt, $hPath, $hPen1)
	_GDIPlus_GraphicsDrawPath($hGfxTrans, $hPath, $hPen2)
	_GDIPlus_PenDispose($hPen1)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_GraphicsDrawImage($hGfxTrans2, $hBmpExt, 0, 0)
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans2, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
	_GDIPlus_PathDispose($hPath)
EndFunc   ;==>_Visual_WaterWave
Func _CreateWaterWaveBrush($iX1, $iY1, $iX2, $iY2)
	Local $iR = 50 * 4 + 4
	Local $iPersp = $iWidth * 1.5
	Local $hPath = _GDIPlus_PathCreate(0)
	_GDIPlus_PathAddEllipse($hPath, $iWidth / 2 - $iR / 2, $iHeight / 2 - $iR / 2, $iR, $iR)
	Local $aP_Warp[5][2] = [[4, 0],[$iX1, $iY1],[$iX2, $iY1],[$iX1 - $iPersp, $iY2],[$iX2 + $iPersp, $iY2]]
	_GDIPlus_PathWarp($hPath, 0, $aP_Warp, $iX1, $iY1, $iX2 - $iX1, $iY2 - $iY1)
	Local $aPoints = _GDIPlus_PathGetPoints($hPath)
	_GDIPlus_PathDispose($hPath)
	Local $hBrush = _GDIPlus_PathBrushCreate($aPoints)
	;_GDIPlus_PathBrushSetCenterColor($hBrush, 0xFF0000FF)
	Local $aColor[$aPoints[0][0] + 1]
	$aColor[0] = $aPoints[0][0]
	For $i = 1 To $aColor[0]
		$aColor[$i] = 0xFF000000
	Next
	_GDIPlus_PathBrushSetSurroundColorsWithCount($hBrush, $aColor)
	Local $aBlend[4][2] = [[3, 0],[0, 0],[0.8, 0.3],[1, 1]]
	_GDIPlus_PathBrushSetBlend($hBrush, $aBlend)
	Return $hBrush
EndFunc   ;==>_CreateWaterWaveBrush
Func _Visual_LevelMeter3D()
	If Not $MusicHandle Then Return -1
	;_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $fLL = _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 2
	Local $fLR = _BASS_EXT_Level2dB(_Bass_HiWord($iLong) / 32768) ^ 2
	Local Static $fLevelL = 0
	Local Static $fLevelR = 0
	$fLevelL -= 0.02
	$fLevelR -= 0.02
	If $fLevelL < 0 Then $fLevelL = 0
	If $fLevelR < 0 Then $fLevelR = 0
	If $fLL > $fLevelL Then $fLevelL = $fLL
	If $fLR > $fLevelR Then $fLevelR = $fLR
	Local $fSize = 0.19
	Local $iSizeM = $iWidth / 8
	Local Static $iStep = 0
	$iStep += 1
	Local $fXPos = (MouseGetPos(0) - $iSizeM) / $iWidth
	Local $fYPos = (MouseGetPos(1) - $iSizeM / 2) / $iHeight
	If $fXPos < 0 Then $fXPos = 0
	If $fYPos < 0 Then $fYPos = 0
	If $fXPos * $iWidth + $iSizeM * 2 > $iWidth Then $fXPos = ($iWidth - $iSizeM * 2) / $iWidth
	If $fYPos * $iHeight + $iSizeM > $iHeight Then $fYPos = ($iHeight - $iSizeM) / $iHeight
	If $fXPos = 0.375 Or $fXPos = 0.25 Or $fXPos = 0.5 Then $fXPos += 0.01
	Local $hPathLF = _GDIPlus_PathCreate(0)
	Local $hPathRF = _GDIPlus_PathCreate(0)
	Local $hPathL = _GDIPlus_PathCreate(0)
	Local $hPathML = _GDIPlus_PathCreate(0)
	Local $hPathMR = _GDIPlus_PathCreate(0)
	Local $hPathR = _GDIPlus_PathCreate(0)
	Local $aP_WarpL[5][2] = [[4, 0],[$iWidth * $fXPos, 0],[$iWidth / 2 - $iWidth / 2 * $fSize + $iWidth * $fSize * $fXPos, $iHeight / 2 - $iHeight / 2 * $fSize],[$iWidth * $fXPos, $iHeight],[$iWidth / 2 - $iWidth / 2 * $fSize + $iWidth * $fSize * $fXPos, $iHeight / 2 + $iHeight / 2 * $fSize]]
	Local $aP_WarpM = $aP_WarpL
	Local $aP_WarpR = $aP_WarpL
	$aP_WarpM[1][0] += $iSizeM
	$aP_WarpR[1][0] += $iSizeM * 2
	$aP_WarpM[2][0] += $iSizeM * $fSize
	$aP_WarpR[2][0] += $iSizeM * 2 * $fSize
	$aP_WarpM[3][0] += $iSizeM
	$aP_WarpR[3][0] += $iSizeM * 2
	$aP_WarpM[4][0] += $iSizeM * $fSize
	$aP_WarpR[4][0] += $iSizeM * 2 * $fSize
	_GDIPlus_PathAddRectangle($hPathL, $iWidth - $iWidth * $fLevelL, $iHeight * $fYPos, $iWidth * $fLevelL, $iSizeM)
	_GDIPlus_PathAddRectangle($hPathML, $iWidth - $iWidth * $fLevelL, $iHeight * $fYPos, $iWidth * $fLevelL, $iSizeM)
	_GDIPlus_PathAddRectangle($hPathMR, $iWidth - $iWidth * $fLevelR, $iHeight * $fYPos, $iWidth * $fLevelR, $iSizeM)
	_GDIPlus_PathAddRectangle($hPathR, $iWidth - $iWidth * $fLevelR, $iHeight * $fYPos, $iWidth * $fLevelR, $iSizeM)
	_GDIPlus_PathWarp($hPathL, 0, $aP_WarpL, 0, 0, $iWidth, $iHeight)
	_GDIPlus_PathWarp($hPathML, 0, $aP_WarpM, 0, 0, $iWidth, $iHeight)
	_GDIPlus_PathWarp($hPathMR, 0, $aP_WarpM, 0, 0, $iWidth, $iHeight)
	_GDIPlus_PathWarp($hPathR, 0, $aP_WarpR, 0, 0, $iWidth, $iHeight)
	Local $aDataL = _GDIPlus_PathGetData($hPathL)
	Local $aDataML = _GDIPlus_PathGetData($hPathML)
	Local $aDataMR = _GDIPlus_PathGetData($hPathMR)
	Local $aDataR = _GDIPlus_PathGetData($hPathR)
	If IsArray($aDataL) And IsArray($aDataML) And IsArray($aDataMR) And IsArray($aDataR) Then
		Switch $iHeight * $fYPos
			Case 0 To $iHeight / 2 - $iSizeM - 1
				_AddRectangle($hPathLF, $aDataL, $aDataML, 4, 3, 3, 4)
				_AddRectangle($hPathRF, $aDataMR, $aDataR, 4, 3, 3, 4)
			Case $iHeight / 2 + 1 To $iHeight
				_AddRectangle($hPathLF, $aDataL, $aDataML, 1, 2, 2, 1)
				_AddRectangle($hPathRF, $aDataMR, $aDataR, 1, 2, 2, 1)
		EndSwitch
		Switch $iWidth * $fXPos
			Case 0 To $iWidth / 2 - $iSizeM - 1
				_GDIPlus_PathAddPath($hPathLF, $hPathML)
			Case $iWidth / 2 + 1 To $iWidth
				_GDIPlus_PathAddPath($hPathLF, $hPathL)
		EndSwitch
		Switch $iWidth * $fXPos + $iSizeM
			Case 0 To $iWidth / 2 - $iSizeM - 1
				_GDIPlus_PathAddPath($hPathRF, $hPathR)
			Case $iWidth / 2 + 1 To $iWidth
				_GDIPlus_PathAddPath($hPathRF, $hPathMR)
		EndSwitch
		_AddRectangle($hPathLF, $aDataL, $aDataML, 1, 4, 4, 1)
		_AddRectangle($hPathRF, $aDataMR, $aDataR, 1, 4, 4, 1)
		Switch $iWidth * $fXPos + $iSizeM
			Case 0 To $iWidth / 2
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPathLF, $hBrush1)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPathLF, $hPen1)
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPathRF, $hBrush2)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPathRF, $hPen2)
			Case Else
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPathRF, $hBrush2)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPathRF, $hPen2)
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPathLF, $hBrush1)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPathLF, $hPen1)
		EndSwitch
	EndIf
	_GDIPlus_PathDispose($hPathLF)
	_GDIPlus_PathDispose($hPathRF)
	_GDIPlus_PathDispose($hPathL)
	_GDIPlus_PathDispose($hPathML)
	_GDIPlus_PathDispose($hPathMR)
	_GDIPlus_PathDispose($hPathR)
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_LevelMeter3D
Func _AddRectangle($hPath, $aData1, $aData2, $iI1, $iI2, $iI3, $iI4)
	_GDIPlus_PathAddLine($hPath, $aData1[$iI1][0], $aData1[$iI1][1], $aData1[$iI2][0], $aData1[$iI2][1])
	_GDIPlus_PathAddLine($hPath, $aData2[$iI3][0], $aData2[$iI3][1], $aData2[$iI4][0], $aData2[$iI4][1])
	_GDIPlus_PathCloseFigures($hPath)
EndFunc   ;==>_AddRectangle
Func _Visual_WaveOsci()
	If Not $MusicHandle Then Return -1
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $aWave = _BASS_EXT_ChannelGetWaveformEx($MusicHandle, 512, 0, $iHeight * 0.42, $iWidth, $iHeight * 0.12, 0, $iHeight * 0.58, $iWidth, $iHeight * 0.12)
	If Not @error And IsArray($aWave) Then
		DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen1, "ptr", $aWave[0], "int", $aWave[2])
		DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen2, "ptr", $aWave[1], "int", $aWave[2])
	EndIf
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_WaveOsci
Func _Visual_FFT3D()
	If Not $MusicHandle Then Return -1
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	_BASS_EXT_ChannelGetFFT($MusicHandle, $aFFT3D, 6)
	If Not @error Then
		Local $hPath = _GDIPlus_PathCreate($FillModeAlternate)
		DllCall($ghGDIPDLL, "uint", "GdipAddPathPolygon", "hwnd", $hPath, "ptr", $aFFT3D[0], "int", $aFFT3D[1])
		Local $fPX = 0.2
		Local $fPX2 = 0.3
		Local $fPY = 0.7
		Local $aP_Warp[5][2] = [[4, 0],[$iWidth * $fPX2, -$iHeight * $fPY],[$iWidth * $fPX + $iWidth * $fPX2, 0],[0, $iHeight - $iHeight * $fPY],[$iWidth * $fPX, $iHeight]]
		_GDIPlus_PathWarp($hPath, 0, $aP_Warp, 0, 0, $iWidth, $iHeight, 1)
		_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath, $hBrush_FFT)
		_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath, $hPen1)
		_GDIPlus_PathDispose($hPath)
	EndIf
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_FFT3D
Func _CreateFFT3DBrush($iWidth, $iHeight)
	Local $hPath = _GDIPlus_PathCreate($FillModeAlternate)
	Local $hPath_Center = _GDIPlus_PathCreate($FillModeAlternate)
	_GDIPlus_PathAddRectangle($hPath, -$iWidth, $iHeight / 2, $iWidth * 3, $iHeight / 2)
	_GDIPlus_PathAddLine($hPath_Center, $iWidth / 2, $iHeight * 2, $iWidth / 2, $iHeight * 2 + 1)
	Local $fPX = 0.2
	Local $fPX2 = 0.3
	Local $fPY = 0.7
	Local $aP_Warp[5][2] = [[4, 0],[$iWidth * $fPX2, -$iHeight * $fPY],[$iWidth * $fPX + $iWidth * $fPX2, 0],[0, $iHeight - $iHeight * $fPY],[$iWidth * $fPX, $iHeight]]
	_GDIPlus_PathWarp($hPath, 0, $aP_Warp, 0, 0, $iWidth, $iHeight, 1)
	_GDIPlus_PathWarp($hPath_Center, 0, $aP_Warp, 0, 0, $iWidth, $iHeight, 1)
	Local $hBrush = _GDIPlus_PathBrushCreateFromPath($hPath)
	Local $aPoint = _GDIPlus_PathGetLastPoint($hPath_Center)
	_GDIPlus_PathBrushSetCenterPoint($hBrush, $aPoint[0], $aPoint[1])
	Local $aBlend[6][2] = [[5, 0],[0xFFFF0000, 0],[0xFFFF0000, 0.15],[0xFFFFFF00, 0.2],[0xFF00FF00, 0.3],[0xFF00FF00, 1]]
	_GDIPlus_PathBrushSetPresetBlend($hBrush, $aBlend)
	_GDIPlus_PathDispose($hPath)
	_GDIPlus_PathDispose($hPath_Center)
	Return $hBrush
EndFunc   ;==>_CreateFFT3DBrush
Func _Visual_FFT()
	If Not $MusicHandle Then Return -1
	_GDIPlus_PenSetColor($hPen1, _SetColor($aColorStep1, $aColor1, 2))
	_GDIPlus_BrushSetSolidColor($hBrush1, _SetColor($aColorStep2, $aColor2, 1))
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	_BASS_EXT_ChannelGetFFT($MusicHandle, $aFFT, 6)
	If Not @error Then
		DllCall($ghGDIPDLL, "int", "GdipFillPolygon", "handle", $hGfxBuffer, "handle", $hBrush1, "ptr", $aFFT[0], "int", $aFFT[1], "int", "FillModeAlternate")
		DllCall($ghGDIPDLL, "int", "GdipDrawPolygon", "handle", $hGfxBuffer, "handle", $hPen1, "ptr", $aFFT[0], "int", $aFFT[1])
	EndIf
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_FFT
Func _Visual_StarField()
	If Not $MusicHandle Then Return -1
	Local $iR, $iX, $iY, $iMax, $iC, $iVal
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	$iC = 0x55 + 0xAA * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 6
	_GDIPlus_BrushSetSolidColor($hBrush1, BitOR(BitShift(0xFF, -24), BitShift($iC, -16), BitShift($iC, -8), 0xFF))
	_GDIPlus_BrushSetSolidColor($hBrush2, BitOR(BitShift(0xFF, -24), BitShift(0xFF, -16), BitShift($iC, -8), $iC))
	$iMax = _Bass_LoWord($iLong) / 32768
	For $i = 1 To 10 + 150 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3
		$iR = Random(1, 3, 1)
		Do
			$iX = Random($iWidth * 0.45 * $iMax, $iWidth - $iWidth * 0.45 * $iMax)
			$iY = Random($iHeight * 0.45 * $iMax, $iHeight - $iHeight * 0.45 * $iMax)
		Until $iX < $iWidth / 2 - 15 Or $iX > $iWidth / 2 + 15 Or $iY < $iHeight / 2 - 15 Or $iY > $iHeight / 2 + 15
		Switch Mod($i, 2)
			Case 0
				_GDIPlus_GraphicsFillEllipse($hGfxBuffer, $iX, $iY, $iR, $iR, $hBrush1)
			Case Else
				_GDIPlus_GraphicsFillEllipse($hGfxBuffer, $iX, $iY, $iR, $iR, $hBrush2)
		EndSwitch
	Next
	Local $fTransform = 0.01 + _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) / 10
	_GDIPlus_GraphicsResetTransform($hGfxTrans)
	_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
	_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_StarField
Func _Visual_WaveProjector()
	If Not $MusicHandle Then Return -1
	Local $iC = _SetColor($aColorStep1, $aColor1, 1)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $iC1 = 0x01 + 0x15 * _Bass_LoWord($iLong) / 32768
	Local $iC2 = 0x77 + 0x88 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	_GDIPlus_PenSetColor($hPen1, BitOR(BitXOR($iC, 0xFF000000), BitShift($iC2, -24)))
	_GDIPlus_PenSetColor($hPen2, BitOR(BitXOR($iC, 0xFF000000), BitShift($iC1, -24)))
	_GDIPlus_BrushSetSolidColor($hBrush1, BitOR(BitXOR($iC, 0xFF000000), BitShift($iC1, -24)))
	Switch IsArray($aWave)
		Case True
			Local $iPos = _BASS_Mixer_ChannelGetPosition($hStream, $BASS_POS_BYTE)
			If $iPos < $iBytes Then
				Local $iSec = _BASS_ChannelBytes2Seconds($hStream, $iPos)
				Local $iOffset = $iWaveRes * ($iSec - 0.5)
				If $iOffset > 0 Then
					Local $hPath = _DrawWaveToPath($aWave[0], $aWave[2], $iWidth * 1.1, $iHeight, $iOffset, 0, $iWaveRes)
					Local $aP_Pers[5][2] = [[4, 0],[0, 0],[$iWidth, 0],[0, $iHeight],[$iWidth, $iHeight]]
					Local $aBounds = _GDIPlus_PathGetWorldBounds($hPath)
					Local $iMul = 1 + 0.3 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 6
					Local $hMatrix = _GDIPlus_MatrixCreate()
					_GDIPlus_MatrixTranslate($hMatrix, $iWidth / 2, $iHeight * 0.7)
					_GDIPlus_MatrixScale($hMatrix, $iMul, $iMul)
					_GDIPlus_MatrixTranslate($hMatrix, -$iWidth / 2, -$iHeight * 0.7)
					_GDIPlus_PathWarp($hPath, $hMatrix, $aP_Pers, $aBounds[0], -$iHeight, $aBounds[2], $iHeight * 2)
					_GDIPlus_MatrixDispose($hMatrix)
					_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath, $hBrush1)
					_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath, $hPen1)
					Local $aData = _GDIPlus_PathGetData($hPath)
					For $i = 1 To $aData[0][0] Step 1
						_GDIPlus_GraphicsDrawLine($hGfxBuffer, $iWidth / 2, $iHeight / 5, $aData[$i][0] + Random(-1, 5), $aData[$i][1], $hPen2)
					Next
					_GDIPlus_PathDispose($hPath)
				EndIf
			EndIf
	EndSwitch
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_WaveProjector
Func _Visual_WaveLaser()
	If Not $MusicHandle Then Return -1
	Local Static $iOldOffset = 0
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $aDataL, $aDataR, $iSegments = 0
	Switch IsArray($aWave)
		Case True
			Local $iPos = _BASS_Mixer_ChannelGetPosition($hStream, $BASS_POS_BYTE)
			If $iPos < $iBytes Then
				Local $iSec = _BASS_ChannelBytes2Seconds($hStream, $iPos)
				Local $iOffset = $iWaveRes * $iSec
				If $iOldOffset > $iOffset Then $iOldOffset = 0
				If $iOffset - $iOldOffset > 10 Then $iOldOffset = $iOffset - 10
				$iSegments = $iOffset - $iOldOffset
				If $iSegments > 1 Then
					Local $hPath_L = _DrawWaveToPath($aWave[0], $aWave[2], $iSegments, $iHeight / 2, $iOffset, 0, Ceiling($iSegments))
					Local $hPath_R = _DrawWaveToPath($aWave[1], $aWave[2], $iSegments, $iHeight / 2, $iOffset, $iHeight / 2, Ceiling($iSegments))
					Local $aP_Pers[5][2] = [[4, 0],[$iWidth * 0.7, 0],[$iWidth * 0.7 + $iSegments, 0],[$iWidth * 0.7, $iHeight],[$iWidth * 0.7 + $iSegments, $iHeight]]
					Local $aBounds = _GDIPlus_PathGetWorldBounds($hPath_L)
					_GDIPlus_PathWarp($hPath_L, 0, $aP_Pers, $aBounds[0], 0, $aBounds[2], $iHeight)
					$aBounds = _GDIPlus_PathGetWorldBounds($hPath_R)
					_GDIPlus_PathWarp($hPath_R, 0, $aP_Pers, $aBounds[0], 0, $aBounds[2], $iHeight)
					_GDIPlus_GraphicsResetTransform($hGfxTrans)
					_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -$iSegments * 2, 0)
					_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath_L, $hPen1)
					_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath_R, $hPen1)
					$aDataL = _GDIPlus_PathGetData($hPath_L)
					$aDataR = _GDIPlus_PathGetData($hPath_R)
					_GDIPlus_PathDispose($hPath_L)
					_GDIPlus_PathDispose($hPath_R)
					$iOldOffset = $iOffset
				EndIf
			EndIf
	EndSwitch
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	If $iSegments > 1 Then _GDIPlus_GraphicsDrawImageRectRect($hGfxBuffer, $hBmpTrans2, $iWidth * 0.7 + $iSegments, 0, $iWidth * 0.3 - $iSegments, $iHeight, $iWidth * 0.7 + $iSegments, 0, $iWidth * 0.3 - $iSegments, $iHeight)
	If IsArray($aDataL) Then
		For $i = 1 To $aDataL[0][0]
			If IsFloat($aDataL[$i][0]) And IsFloat($aDataL[$i][1]) Then _GDIPlus_GraphicsDrawLine($hGfxBuffer, $aDataL[$i][0], $aDataL[$i][1], $iWidth * 1.3, $iHeight * 0.4, $hPen2)
		Next
	EndIf
	If IsArray($aDataR) Then
		For $i = 1 To $aDataR[0][0]
			If IsFloat($aDataR[$i][0]) And IsFloat($aDataR[$i][1]) Then _GDIPlus_GraphicsDrawLine($hGfxBuffer, $aDataR[$i][0], $aDataR[$i][1], $iWidth * 1.3, $iHeight * 0.6, $hPen2)
		Next
	EndIf
	_GDIPlus_GraphicsDrawImage($hGfxTrans2, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans2, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_WaveLaser
Func _CreateWavePen($iColor, $iY1, $iY2, $iW = 2)
	Local $hBrush = _GDIPlus_LineBrushCreate(0, $iY2, 0, $iY1, 0, 0, 1)
	Local $aBlend[5][2] = [[4, 0],[BitXOR($iColor, 0xFF000000), 0],[BitXOR($iColor, 0xFF000000), 0.5],[$iColor, 0.6],[$iColor, 1]]
	_GDIPlus_PathBrushSetPresetBlend($hBrush, $aBlend)
	Local $hPen = _GDIPlus_PenCreate2($hBrush, $iW)
	_GDIPlus_PenSetMiterLimit($hPen, 0)
	_GDIPlus_BrushDispose($hBrush)
	Return $hPen
EndFunc   ;==>_CreateWavePen
Func _CreateWaveBrush($iColor, $iY1, $iY2)
	Local $hBrush = _GDIPlus_LineBrushCreate(0, $iY2, 0, $iY1, 0, 0, 1)
	Local $aBlend[5][2] = [[4, 0],[BitXOR($iColor, 0xFF000000), 0],[BitXOR($iColor, 0xFF000000), 0.3],[$iColor, 0.4],[$iColor, 1]]
	_GDIPlus_PathBrushSetPresetBlend($hBrush, $aBlend)
	Return $hBrush
EndFunc   ;==>_CreateWaveBrush
Func _DrawWaveToPath($pWave, $iCnt, $iW, $iH, $iOffset, $iYOffset, $iSegments, $fTension = 0.1)
	Local $hPath = _GDIPlus_PathCreate(0)
	Local $hPath1 = _GDIPlus_PathCreate(0)
	Local $hPath2 = _GDIPlus_PathCreate(0)
	If $iOffset + $iSegments > $iCnt Then $iSegments = $iCnt - $iOffset
	DllCall($ghGDIPDLL, "uint", "GdipAddPathCurve3", "hwnd", $hPath1, "ptr", $pWave, "int", $iCnt, "int", $iOffset, "int", $iSegments, "float", $fTension)
	Local $aP_Flip[5][2] = [[4, 0],[0, $iHeight / 4],[$iW, $iHeight / 4],[0, 0],[$iW, 0]]
	_GDIPlus_PathWarp($hPath1, 0, $aP_Flip, 0, 0, $iW, $iHeight / 4) ; flip
	_GDIPlus_PathReverse($hPath1)
	DllCall($ghGDIPDLL, "uint", "GdipAddPathCurve3", "hwnd", $hPath2, "ptr", $pWave, "int", $iCnt, "int", $iOffset, "int", $iSegments, "float", $fTension)
	Local $aP_YOff[5][2] = [[4, 0],[0, 0],[$iW, 0],[0, $iHeight / 4],[$iW, $iHeight / 4]]
	_GDIPlus_PathWarp($hPath2, 0, $aP_YOff, 0, -$iHeight / 4, $iW, $iHeight / 4) ; Y-Offset
	_GDIPlus_PathAddPath($hPath, $hPath1)
	_GDIPlus_PathAddPath($hPath, $hPath2)
	_GDIPlus_PathCloseFigure($hPath)
	Local $aP_YOffset[5][2] = [[4, 0],[0, 0],[$iW, 0],[0, $iH],[$iW, $iH]]
	Local $aBounds = _GDIPlus_PathGetWorldBounds($hPath)
	_GDIPlus_PathWarp($hPath, 0, $aP_YOffset, $iOffset, -$iYOffset, $aBounds[2], $iH) ; X & Y-Offset
	_GDIPlus_PathDispose($hPath1)
	_GDIPlus_PathDispose($hPath2)
	Return $hPath
EndFunc   ;==>_DrawWaveToPath
Func _Visual_SpaceWave()
	If Not $MusicHandle Then Return -1
	Local $iR
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	For $i = 10 To 10 + 100 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 5
		$iR = Random(1, 3, 1)
		_GDIPlus_GraphicsFillEllipse($hGfxBuffer, Random(0, $iWidth, 1), Random(0, $iHeight, 1), $iR, $iR, $hBrush1)
	Next
	Switch IsArray($aWave)
		Case True
			Local $iPos = _BASS_Mixer_ChannelGetPosition($hStream, $BASS_POS_BYTE)
			If $iPos < $iBytes Then
				Local $iSec = _BASS_ChannelBytes2Seconds($hStream, $iPos)
				Local $iOffset = $iWaveRes * $iSec
				Local $hPath_L = _DrawWaveToPath($aWave[0], $aWave[2], $iWidth, $iHeight / 2, $iOffset, 0, 5 * $iWaveRes)
				Local $hPath_R = _DrawWaveToPath($aWave[1], $aWave[2], $iWidth, $iHeight / 2, $iOffset, $iHeight / 2, 5 * $iWaveRes)
				Local $aP_Pers[5][2] = [[4, 0],[0, $iHeight],[$iWidth * 0.48, $iHeight * 0.2],[$iWidth, $iHeight],[$iWidth - $iWidth * 0.48, $iHeight * 0.2]]
				_GDIPlus_PathWarp($hPath_L, 0, $aP_Pers, 0, 0, $iWidth, $iHeight)
				_GDIPlus_PathWarp($hPath_R, 0, $aP_Pers, 0, 0, $iWidth, $iHeight)
				Local Static $iMove = 0
				Local $iX1 = $iWidth / 16 + Sin($iMove / 25 + 2 * 1.3) * $iWidth / 16
				Local $iY1 = $iHeight / 16 + Cos($iMove / 33 - 2 * 2.3) * $iHeight / 16
				Local $iX2 = $iWidth / 16 + Sin($iMove / 25 + 3 * 1.3) * $iWidth / 16
				Local $iY2 = $iHeight / 16 + Cos($iMove / 33 - 3 * 2.3) * $iHeight / 16
				$iMove += 3 * _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3
				Local $aP_Warp[5][2] = [[4, 0],[$iX1, $iY1],[$iWidth - $iX2, $iY2],[0, $iHeight],[$iWidth, $iHeight]]
				_GDIPlus_PathWarp($hPath_L, 0, $aP_Warp, 0, 0, $iWidth, $iHeight)
				_GDIPlus_PathWarp($hPath_R, 0, $aP_Warp, 0, 0, $iWidth, $iHeight)
				Local $aBounds = _GDIPlus_PathGetWorldBounds($hPath_L)
				Local $aBlendL[5][2] = [[4, 0],[0xFF000000, 0],[0xFF000000, $aBounds[1] / $iHeight],[0xFF00AA00, $aBounds[1] / $iHeight + 0.1],[0xFF00AA00, 1]]
				_GDIPlus_PathBrushSetPresetBlend($hBrush_WL, $aBlendL)
				$aBounds = _GDIPlus_PathGetWorldBounds($hPath_R)
				Local $aBlendR[5][2] = [[4, 0],[0xFF000000, 0],[0xFF000000, $aBounds[1] / $iHeight],[0xFFAA0000, $aBounds[1] / $iHeight + 0.1],[0xFFAA0000, 1]]
				_GDIPlus_PathBrushSetPresetBlend($hBrush_WR, $aBlendR)
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath_L, $hBrush_WL)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath_L, $hPen_WL)
				_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath_R, $hBrush_WR)
				_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath_R, $hPen_WR)
				_GDIPlus_PathDispose($hPath_L)
				_GDIPlus_PathDispose($hPath_R)
			EndIf
	EndSwitch
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_SpaceWave
Func _Visual_Circle()
	If Not $MusicHandle Then Return -1
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $p = 5 + _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 2 * $iHeight / 8
	Local $k1 = 30 + _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3 * 150
	Local Static $k = 10
	If $k1 > $k Then $k += 1
	If $k1 < $k Then $k -= 1
	Local $aWave = _BASS_EXT_ChannelGetWaveform($MusicHandle, 180, 2)
	If Not @error And IsArray($aWave) Then
		Local $aWaveL = $aWave[0]
		Local $aWaveR = $aWave[1]
		Local Static $t = 0
		Local $iXL = ($iWidth / 2) + Sin($t / 25 + 2 * 1.3) * $k
		Local $iYL = ($iHeight / 2) + Cos($t / 33 - 2 * 2.3) * $k
		Local $iXR = ($iWidth / 2) + Sin($t / 25 + 3 * 1.3) * $k
		Local $iYR = ($iHeight / 2) + Cos($t / 33 - 3 * 2.3) * $k
		$t += 1
		Local $iX, $iY
		Local $aCurveL[360][2] = [[359]]
		Local $aCurveR[360][2] = [[359]]
		For $i = 1 To 180
			$iX = Round(Cos($i * $DegToRad) * $p + ($p * $aWaveL[$i][1]))
			$iY = Round(Sin($i * $DegToRad) * $p + ($p * $aWaveL[$i][1]))
			$aCurveL[$i][0] = $iXL + $iX
			$aCurveL[$i][1] = $iYL + $iY
			$aCurveR[$i][0] = $iXR + $iX
			$aCurveR[$i][1] = $iYR + $iY
		Next
		For $i = 181 To 359
			$iX = Round(Cos($i * $DegToRad) * $p + ($p * $aWaveL[360 - $i][1]))
			$iY = Round(Sin($i * $DegToRad) * $p + ($p * $aWaveL[360 - $i][1]))
			$aCurveL[$i][0] = $iXL + $iX
			$aCurveL[$i][1] = $iYL + $iY
			$aCurveR[$i][0] = $iXR + $iX
			$aCurveR[$i][1] = $iYR + $iY
		Next
		_GDIPlus_GraphicsDrawClosedCurve($hGfxBuffer, $aCurveL, $hPen1)
		_GDIPlus_GraphicsFillClosedCurve($hGfxBuffer, $aCurveL, $hBrush1)
		_GDIPlus_GraphicsDrawClosedCurve($hGfxBuffer, $aCurveR, $hPen2)
		_GDIPlus_GraphicsFillClosedCurve($hGfxBuffer, $aCurveR, $hBrush2)
	EndIf
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_Circle
Func _Visual_WaveLines()
	If Not $MusicHandle Then Return -1
	_GDIPlus_PenSetColor($hPen1, _SetColor($aColorStep1, $aColor1, 1))
	_GDIPlus_PenSetColor($hPen2, _SetColor($aColorStep2, $aColor2, 2))
	_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $aWave = _BASS_EXT_ChannelGetWaveformEx($MusicHandle, 512, $iWidth / 2 - $iHeight * 0.2, $iHeight * 0.3, $iHeight * 0.4, $iHeight * 0.18, $iWidth / 2 - $iHeight * 0.2, $iHeight * 0.75, $iHeight * 0.4, $iHeight * 0.18)
	Local Static $iAngle = 0
	$iAngle += 1
	If $iAngle >= 360 Then $iAngle = 0
	Local $hMatrix = _GDIPlus_MatrixCreate()
	_GDIPlus_MatrixTranslate($hMatrix, $iWidth / 2, $iHeight / 2)
	_GDIPlus_MatrixRotate($hMatrix, -57.32 + Sin($iAngle * 3.14 / 180) * 8)
	_GDIPlus_MatrixTranslate($hMatrix, -$iWidth / 2, -$iHeight / 2)
	_GDIPlus_GraphicsSetTransform($hGfxTrans, $hMatrix)
	_GDIPlus_MatrixDispose($hMatrix)
	DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen1, "ptr", $aWave[0], "int", $aWave[2])
	DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen2, "ptr", $aWave[1], "int", $aWave[2])
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_WaveLines
Func _Visual_Phase()
	If Not $MusicHandle Then Return -1
	_GDIPlus_PenSetColor($hPen1, _SetColor($aColorStep1, $aColor1, 1))
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $fTransform = _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3 / 10
	_GDIPlus_GraphicsResetTransform($hGfxTrans)
	Local $hMatrix = _GDIPlus_MatrixCreate()
	_GDIPlus_MatrixTranslate($hMatrix, $iWidth / 2, $iHeight / 2)
	_GDIPlus_MatrixRotate($hMatrix, $fTransform * 10)
	_GDIPlus_MatrixTranslate($hMatrix, -$iWidth / 2, -$iHeight / 2)
	_GDIPlus_GraphicsSetTransform($hGfxTrans, $hMatrix)
	_GDIPlus_MatrixDispose($hMatrix)
	_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
	_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $aPhase = _BASS_EXT_ChannelGetPhaseDataEx($MusicHandle, 256, $iWidth / 2, $iHeight / 2, $iWidth / 2, $iHeight / 2)
	DllCall($ghGDIPDLL, "int", "GdipDrawCurve", "handle", $hGfxBuffer, "handle", $hPen1, "ptr", $aPhase[0], "int", $aPhase[1])
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_Phase
Func _Visual_TextWaveform($hPath, $iMax = 10)
	If Not $MusicHandle Then Return -1
	_GDIPlus_GraphicsDrawImage($hGfxBuffer, $hBmpTrans, 0, 0)
	Local $aData = _GDIPlus_PathGetData($hPath)
	Local $aWave = _BASS_EXT_ChannelGetWaveform($MusicHandle, $aData[0][0], 3)
	If $aWave[0][0] <> $aData[0][0] Then Return
	For $i = 1 To $aWave[0][0]
		$aData[$i][0] += $iMax * $aWave[$i][1]
		Switch Mod($i, 2)
			Case 0
				$aData[$i][1] += $iMax * $aWave[$i][1]
			Case Else
				$aData[$i][1] -= $iMax * $aWave[$i][1]
		EndSwitch
	Next
	Local $hPath_Clone = _GDIPlus_PathCreate2($aData, 0)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $fSize = _BASS_EXT_Level2dB(_Bass_LoWord($iLong) / 32768) ^ 3
	Local $hMatrix = _GDIPlus_MatrixCreate()
	_GDIPlus_MatrixTranslate($hMatrix, $iWidth / 2, $iHeight / 2)
	_GDIPlus_MatrixScale($hMatrix, 1 + $fSize, 1 + $fSize)
	_GDIPlus_MatrixTranslate($hMatrix, -$iWidth / 2, -$iHeight / 2)
	_GDIPlus_PathTransform($hPath_Clone, $hMatrix)
	_GDIPlus_MatrixDispose($hMatrix)
	_GDIPlus_GraphicsDrawPath($hGfxBuffer, $hPath_Clone, $hPen1)
	_GDIPlus_GraphicsFillPath($hGfxBuffer, $hPath_Clone, $hBrush1)
	_GDIPlus_PathDispose($hPath_Clone)
	_GDIPlus_GraphicsDrawImage($hGfxTrans, $hBmpBuffer, 0, 0)
	_GDIPlus_GraphicsFillRect($hGfxTrans, 0, 0, $iWidth, $iHeight, $hBrushTrans)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
EndFunc   ;==>_Visual_TextWaveform
Func _CreateAutoItText($hGraphics, $iWidth, $iHeight, $fSize, $bFont)
	Local $hPath = _GDIPlus_PathCreate(0)
	Local $hCollection = _GDIPlus_NewPrivateFontCollection()
	Local $tFont = DllStructCreate('byte[' & BinaryLen($bFont) & ']')
	DllStructSetData($tFont, 1, $bFont)
	_GDIPlus_PrivateAddMemoryFont($hCollection, DllStructGetPtr($tFont), DllStructGetSize($tFont))
	Local $hFormat = _GDIPlus_StringFormatCreate()
	Local $hFamily = _GDIPlus_CreateFontFamilyFromName('Microgramma Becker Bold Extd', $hCollection)
	Local $tLayout, $aInfo, $aBounds, $iXOff = 0, $iYOff = 0
	$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	$aBounds = _PathMeasureText("T ", $hFamily, $fSize, $hFormat)
	$iXOff += $aBounds[0] + $aBounds[2]
	$iYOff = $aBounds[1] + $aBounds[3]
	_GDIPlus_PathAddString($hPath, 'T ', $tLayout, $hFamily, 0, $fSize, $hFormat)
	$aBounds = _PathMeasureText("U ", $hFamily, $fSize * 0.7, $hFormat)
	$tLayout = _GDIPlus_RectFCreate($iXOff - $aBounds[0], $iYOff - $aBounds[1] - $aBounds[3], 0, 0)
	$iXOff += $aBounds[2] + $fSize * 0.06
	_GDIPlus_PathAddString($hPath, 'U ', $tLayout, $hFamily, 0, $fSize * 0.7, $hFormat)
	$aBounds = _PathMeasureText("C", $hFamily, $fSize, $hFormat)
	$tLayout = _GDIPlus_RectFCreate($iXOff - $aBounds[0], $iYOff - $aBounds[1] - $aBounds[3], 0, 0)
	$iXOff += $aBounds[2] + $fSize * 0.06
	_GDIPlus_PathAddString($hPath, 'C', $tLayout, $hFamily, 0, $fSize, $hFormat)
	$aBounds = _PathMeasureText(" ", $hFamily, $fSize * 0.7, $hFormat)
	$tLayout = _GDIPlus_RectFCreate($iXOff - $aBounds[0], $iYOff - $aBounds[1] - $aBounds[3], 0, 0)
	_GDIPlus_PathAddString($hPath, ' ', $tLayout, $hFamily, 0, $fSize * 0.7, $hFormat)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_DeletePrivateFontCollection($hCollection)
	_GDIPlus_StringFormatDispose($hFormat)
	$aBounds = _GDIPlus_PathGetWorldBounds($hPath)
	Local $fMul = $iWidth / 3 / $aBounds[2]
	Local $iX = $iWidth / 2 - $aBounds[0] * $fMul - $aBounds[2] / 2 * $fMul
	Local $iY = $iHeight / 2 - $aBounds[1] * $fMul - $aBounds[3] / 2 * $fMul
	Local $iW = $aBounds[2] * $fMul
	Local $iH = $aBounds[3] * $fMul
	Local $aPoints[5][2] = [[4, 0],[$iX, $iY],[$iX + $iW, $iY],[$iX, $iY + $iH],[$iX + $iW, $iY + $iH]]
	_GDIPlus_PathWarp($hPath, 0, $aPoints, $aBounds[0], $aBounds[1], $aBounds[2], $aBounds[3])
	Return $hPath
EndFunc   ;==>_CreateAutoItText
Func _PathMeasureText($sText, $hFamily, $fSize, $hFormat)
	Local $hPath = _GDIPlus_PathCreate(0)
	Local $tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	_GDIPlus_PathAddString($hPath, $sText, $tLayout, $hFamily, 0, $fSize, $hFormat)
	Local $aBounds = _GDIPlus_PathGetWorldBounds($hPath)
	_GDIPlus_PathDispose($hPath)
	Return $aBounds
EndFunc   ;==>_PathMeasureText
Func _SetColor(ByRef $aStep, ByRef $aCol, $iCnt = 1)
	Local $aTrue[3] = [False, False, False]
	For $i = 0 To 2
		If $aCol[$i] < $aStep[$i] * 0xFF Then
			$aCol[$i] += $iCnt * $aStep[$i]
		ElseIf $aCol[$i] > $aStep[$i] * 0xFF Then
			$aCol[$i] -= $iCnt
		EndIf
		If $aCol[$i] < 0 Then $aCol[$i] = 0
		If $aCol[$i] > 255 Then $aCol[$i] = 255
		If $aCol[$i] >= $aStep[$i] * 0xFF - Ceiling($iCnt / 2) And $aCol[$i] <= $aStep[$i] * 0xFF + Ceiling($iCnt / 2) Then $aTrue[$i] = True
	Next
	If $aTrue[0] = True And $aTrue[1] = True And $aTrue[2] = True Then
		Do
			$aStep[0] = Random(0, 2, 1) / 2
			$aStep[1] = Random(0, 2, 1) / 2
			$aStep[2] = Random(0, 2, 1) / 2
		Until $aStep[0] = 1 Or $aStep[1] = 1 Or $aStep[2] = 1
	EndIf
	Return "0xFF" & Hex(_ColorSetRGB($aCol), 6)
EndFunc   ;==>_SetColor
Func _PrepareVisual($iIndex)
	Local $fTransform
	Switch $iVisual
		Case 1 ; Text Waveform
			$fTransform = 0.005
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), ($iHeight * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetColor($hPen1, 0xFFFFFF00)
			_GDIPlus_PenSetWidth($hPen1, 3)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0xFF888800)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x60000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 2 ; phase dynamic
			$fTransform = 0.1
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 3)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x11000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 3
			$fTransform = 0.01
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_PenSetWidth($hPen2, 2)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x20000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 4
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_PenSetWidth($hPen1, 4)
			_GDIPlus_PenSetWidth($hPen2, 2)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
		Case 5
			$fTransform = 0.08
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 1)
			_GDIPlus_PenSetWidth($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0xFF00FF00)
			_GDIPlus_PenSetColor($hPen2, 0xFFFF0000)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0x2000FF00)
			_GDIPlus_BrushSetSolidColor($hBrush2, 0x20FF0000)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x20000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 6
			$fTransform = 0.02
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight * 0.2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x40000000)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0xFFFFFFFF)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 7
			$fTransform = 0.5
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0xFFFFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrush2, 0xFFFFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x20000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 2)
		Case 8
			$fTransform = -0.05
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), 0)
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x20000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 9
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, 5, 0)
			_GDIPlus_PenSetWidth($hPen1, 1)
			_GDIPlus_PenSetColor($hPen1, 0xFF222222)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 10
			$fTransform = 0.05
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_PenSetWidth($hPen2, 2)
			_GDIPlus_PenSetColor($hPen1, 0xFF00FF00)
			_GDIPlus_PenSetColor($hPen2, 0xFFFF0000)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x15000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 11
			$fTransform = 0.01
			_GDIPlus_GraphicsResetTransform($hGfxTrans2)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans2, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans2, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_PenSetWidth($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0xFFFFFFFF)
			_GDIPlus_PenSetColor($hPen2, 0xFFFFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0xAA000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans2, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 12
			$fTransform = 0.02
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 4 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 1)
			_GDIPlus_PenSetWidth($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0x66FFFFFF)
			_GDIPlus_PenSetColor($hPen2, 0x05FFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0x20FFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0xAA000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 13
			$fTransform = 0.001
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 4 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_PenSetWidth($hPen2, 2)
			_GDIPlus_PenSetMiterLimit($hPen1, 1)
			_GDIPlus_PenSetMiterLimit($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0xFF00FF00)
			_GDIPlus_PenSetColor($hPen2, 0xFFFF0000)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0xFF00AA00)
			_GDIPlus_BrushSetSolidColor($hBrush2, 0xFFAA0000)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x66000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
		Case 14
			$fTransform = 0.02
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 8 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
			$fTransform = 1
			_GDIPlus_GraphicsResetTransform($hGfxTrans2)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans2, -($iWidth / 2 * $fTransform), ($iHeight / 8 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans2, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans2, 0)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x55000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans2, 0xFF000000)
		Case 15
			_GDIPlus_PenSetWidth($hPen1, 6)
			_GDIPlus_PenSetWidth($hPen2, 4)
			_GDIPlus_PenSetMiterLimit($hPen1, 1)
			_GDIPlus_PenSetMiterLimit($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0xFF00AAFF)
			_GDIPlus_PenSetColor($hPen2, 0xCCFFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x66000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 3)
		Case 16
			$fTransform = 0.05
			_GDIPlus_GraphicsResetTransform($hGfxTrans)
			_GDIPlus_GraphicsTranslateTransform($hGfxTrans, -($iWidth / 2 * $fTransform), -($iHeight / 2 * $fTransform))
			_GDIPlus_GraphicsScaleTransform($hGfxTrans, 1 + $fTransform, 1 + $fTransform)
			_GDIPlus_PenSetWidth($hPen1, 2)
			_GDIPlus_PenSetWidth($hPen2, 1)
			_GDIPlus_PenSetMiterLimit($hPen1, 1)
			_GDIPlus_PenSetMiterLimit($hPen2, 1)
			_GDIPlus_PenSetColor($hPen1, 0x2000AAFF)
			_GDIPlus_PenSetColor($hPen2, 0x50FFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrush1, 0xFFFFFFFF)
			_GDIPlus_BrushSetSolidColor($hBrush2, 0xFFAA0000)
			_GDIPlus_BrushSetSolidColor($hBrushTrans, 0x10000000)
			_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
			_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
			_GDIPlus_GraphicsSetInterpolationMode($hGfxTrans, 1)
	EndSwitch
EndFunc   ;==>_PrepareVisual
Func _WaveformGetProc($handle, $percent)
	ToolTip("Get Waveform: " & $percent & "%")
EndFunc   ;==>_WaveformGetProc
Func _SelectInterface()
	Local $iDevice = -1
	Local $i = 0, $aInfo, $sDevice = "", $iCnt = 0
	While 1
		$aInfo = _BASS_GetDeviceInfo($i)
		If @error Then ExitLoop
		If $aInfo[1] And BitAND($aInfo[2], $BASS_DEVICE_ENABLED) Then
			$sDevice &= "|" & $i & ":" & $aInfo[0]
			$iCnt += 1
		EndIf
		$i += 1
	WEnd
	If $iCnt = 1 Then Return 1
	If $iCnt < 1 Then Return -1
	Opt("GUIOnEventMode", 0)
	Local $hWnd = GUICreate("Select sound device", 300, 90)
	GUICtrlCreateLabel("select sound device", 10, 10, 280, 20)
	Local $hCombo = GUICtrlCreateCombo("", 10, 40, 280, 20)
	GUICtrlSetData($hCombo, $sDevice)
	GUISetState()
	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case - 3
				ExitLoop
			Case $hCombo
				$iDevice = StringRegExpReplace(GUICtrlRead($hCombo), "(\d+)(.*)", "\1")
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete($hWnd)
	Opt("GUIOnEventMode", 1)
	Return $iDevice
EndFunc   ;==>_SelectInterface