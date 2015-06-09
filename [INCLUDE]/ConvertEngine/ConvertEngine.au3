;ConvertEngine.au3

Func _Convert_SetControles($File)
	GUICtrlSetData($Combo[0], $File, $File)
	_PathSplit($File, $sDrive, $sDir, $sFile, $sExt)
	
	Switch $sExt
		Case "*.mp3"
			_Convert_SetVideoControles()
		Case "*.avi"
	EndSwitch
EndFunc

Func _Convert_SetVideoControles()
	ReDim $CheckBoxes[5]
	ReDim $ComboBoxes[5]

	For $X = 0 To UBound($CheckBoxes) - 1
		GUICtrlDelete($CheckBoxes[$X]) ;Die alten werden gelöscht
		If @error Then Exit
	Next
	For $X = 0 To UBound($ComboBoxes) - 1
		GUICtrlDelete($ComboBoxes[$X])
		If @error Then Exit
	Next	
	
	
	
EndFunc