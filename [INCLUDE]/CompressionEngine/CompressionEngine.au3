;CompressionEngine.au3



Func _PrepareCompression()
	$FILE = FileOpenDialog("Select a File", "", "ALL (*.*)", 1 + 2)
	If $FILE Then
		GUICtrlSetData($Input[3], $FILE)
		
		GUICtrlSetState($Combo[3], $GUI_ENABLE)
		GUICtrlSetState($Combo[5], $GUI_ENABLE)
	
		GUICtrlSetData($Combo[5],"|Action")
		
		_PathSplit($FILE, $sDrive, $sDir, $sFile, $sExt)
		
		GUICtrlSetData($Input[4], $sDrive & $SDir & $sFile)
		
		ConsoleWrite("Selected File EXT: " & $sExt & @CRLF)
		Switch $sExt
			Case ".exe" Or ".dll"
				GUICtrlSetData($Combo[5], "PE Compression |Archive Compression ", "Action")
			Case ".jpg" Or ".bmp" Or ".ico"
				GUICtrlSetData($Combo[5], "Picture Compression (Lossless)|Picture Compression (Lossy) |Archive Compression ", "Action")
			Case ".mp3" Or ".m4a" Or ".wmp"
				GUICtrlSetData($Combo[5], "Music Compression | Convert |Archive Compression ", "Action")
			Case ".7z"; Or ".7z" Or ".zip"
				GUICtrlSetData($Combo[5], "Decompress |Optimize |Convert ", "Action")
		EndSwitch
	EndIf
EndFunc ;==>_PrepareCompression

Func _Set_Archiver_for_Compression($Type = "Archiver")
	;$iniDir
	;	-> Stores the Name of the Ini file
	;$Compressors
	;	-> Stores the Name of the compressors.
	
	GUICtrlSetData($Combo[3],"|")
	
	$String = "Compressor |"
	For $X = 1 To $Compressors[0]
		$ret = IniRead($COMPRESSOR_DIR, $Compressors[$x], "Type", -1)
		If $ret = $Type Then $String &= $Compressors[$X] & " |"
	Next
	$ret = 0
	_GUICtrlComboBox_DeleteString($Combo[3], 0)
	GUICtrlSetData($Combo[3], $String, "Compressor")
	
EndFunc ;==>_Set_Archiver_for_Compression

Func _Set_Controls_For_Compression($NR)
	;ConsoleWrite("0")
	;$iniDir
	;	-> Stores the Namecof the Ini file
	;$Compressors
	;	-> Stores the Name of the compressors.
	;$NR
	;	-> Stores the Current selection of the user of the combo box
	;	-> Used to find the Compressor in the ini
	ConsoleWrite("Compressor = " & $NR & @CRLF)
	;Section
	;	-> Stores the Section Values zu dem passenden Compressor
	
	$Section = IniReadSection($COMPRESSOR_DIR, $NR)
	;_ArrayDisplay($Section)
	;$Mode
	;	-> Stores the Mode of the type of the compressor
	;	-> 1 = Only Comboboxes Gut um Ranges darzustellen
	;	-> 2 = für beides also Checkboxes u  Comboboxes
	;	-> 3 = für komplexere sachen kommt nocht
	;$Mode = $Section[8][1]
	;MsgBox(0,"MODE", $Mode)
	;MsgBox(0,"UBound($CheckBoxes)",UBound($CheckBoxes))
	;_ArrayDisplay($CheckBoxes)
	For $X = 0 To UBound($CheckBoxes) - 1
		GUICtrlDelete($CheckBoxes[$X]) ;Die alten werden gelöscht
		If @error Then Exit
	Next
	For $X = 0 To UBound($ComboBoxes) - 1
		GUICtrlDelete($ComboBoxes[$X])
		If @error Then Exit
	Next
	Switch $Section[8][1] ;Mode
		Case 1
			;Nothing
		Case 2
			;MAXCTRL
			;	-> Stores the Numbers of the max Ctls, based on the Counter of the ini FIle
			$MAXCTRL = ($Section[0][0] - 8) / 3
			ReDim $CheckBoxes[$MAXCTRL + 1]
			ReDim $ComboBoxes[$MAXCTRL + 1]
			GUICtrlDelete($Group[3])
			$Group[3] = GUICtrlCreateGroup(" Options ",60, 102, 480, 88)
			Local $Width = 65
			Local $hight = 115
			Local $Limit = 500
			For $X = 0 To $MAXCTRL - 1 ;Max
				$CheckBoxes[$X] = GUICtrlCreateCheckbox($Section[9 + (3 * $X)][1], $Width, $hight, 50, 20)
				GUICtrlSetTip(-1, $Section[11 + (3 * $X)][1])
				If @error Then Return -1
				If $Section[11 + (3 * $X)][0] = "Range" & $X + 1 Then
					Local $String = ""
					$pos = StringInStr($Section[11 + (3 * $X)][1], "-") ;Check if theres a -
					If $pos <> 0 Then ; something found
						$max = StringRight($Section[11 + (3 * $X)][1], StringLen($Section[11 + (3 * $X)][1]) - $pos) ;Gets the max
						$min = StringLeft($Section[11 + (3 * $X)][1], $pos) ; min if starts from 0 or 1
						For $y = $min To $max
							$String &= $y & " |"
						Next
					Else ;if nothing found"
						;ConsoleWrite("(StringLen($Section[11 + (3 * $X)][1])/2) - 1:" & Round(StringLen($Section[11 + (3 * $X)][1])/2) - 1)
						For $z = 1 To Round((StringLen($Section[11 + (3 * $X)][1]) / 2) - 1)
							$pos = StringInStr($Section[11 + (3 * $X)][1], ";", 0, $z)
							If $pos <> 0 Then ; something found
								$String &= StringMid($Section[11 + (3 * $X)][1], $pos - 1, 1) & " |"
							EndIf
						Next
						$String &= StringRight($Section[11 + (3 * $X)][1], 1) ;fügt noch das letzte Zeichen hinzu
					EndIf
					
					$ComboBoxes[$X] = GUICtrlCreateCombo("", $Width, $hight + 20, 45, 17)
					GUICtrlSetData(-1, $String, "1")
					;GUICtrlSetState($CheckBoxes[$X], $GUI_DISABLE)
					GUICtrlSetState($CheckBoxes[$X], $GUI_CHECKED)
				EndIf
				$Width += 50
				If $Width > $Limit Then
					$hight += 45
					$Width = 65
					;ConsoleWrite("Compressor Height: " & $hight & " Compressor Weight: " & $Width & @CRLF)
					;If $hight > 200 Then
					;	ConsoleWrite("Init ScrollBars" & @CRLF)
					;	_GUIScrollbars_Generate(GUICtrlGetHandle($Group[3]),0 , 1000 ,0 ,0 ,True)
					;	If @error Then MsgBox(0,"Error", "Couldn´t Init the ScrollBars"& @CRLF & @error )
					;	
					;	;_GUIScrollBars_ShowScrollBar(GUICtrlGetHandle($Group[3]), $SB_HORZ, False)
					;Endif
				EndIf
			Next
			GUICtrlCreateGroup("", -99, -99, 1, 1)
			
			;_ArrayDisplay($CheckBoxes,"Secound")
			;_ArrayDisplay($ComboBoxes,"Secound")
	EndSwitch
	;News Ticker
	;$News = $Section[1][0] & ": " & $Section[1][1] & "|" & $Section[2][0] & ": " & $Section[2][1] & "|" & $Section[3][0] & ": " & $Section[3][1] & "|" & $Section[4][0] & ": " & $Section[4][1]
	;	MsgBox(0,"",$News)
	;_GUICtrlNewsTicker_NewsSet($hTicker, $News)
	;_GUICtrlNewsTicker_SetState($hTicker, 1, 1000)
EndFunc ;==>_Set_Controls_For_Compression

Func _Execute_Compression($Input, $Output)
	If $Input = "" Then Return -1
	If $Output = "" Then Return -1
	Dim $cmd = ""
	For $X = 0 To UBound($CheckBoxes) - 1
		If GUICtrlRead($CheckBoxes[$X]) = $GUI_CHECKED Then
			If $ComboBoxes[$X] <> "" Then
				$cmd &= GUICtrlRead($CheckBoxes[$X], 1)
				$var = GUICtrlRead($ComboBoxes[$X])
				If $var <> "" Then $cmd &= $var
				$var = 0
			Else ;Nichts in der ComboBox ausgewählt
				MsgBox(0,"Error","Please select an command")
				Return -1
			EndIf
			$cmd &= " "
		EndIf
	Next
	
	;_ArrayDisplay($Section)
	
	$InputPos = StringInStr($Section[6][1], "input")
	$CommandPos = StringInStr($Section[6][1], "commands")
	$OutputPos = StringInStr($Section[6][1], "output")
	
	Local $command = @ScriptDir & "\[BIN]\[COMPRESSORS]\" & $Section[2][1] & ".exe "
	;ConsoleWrite("$InputPos: " & $InputPos & "  $CommandPos: " &  $CommandPos & "   $OutputPos: " & $OutputPos & @CRLF)
	If $InputPos > $CommandPos Then
		If $InputPos > $OutputPos Then
			$command &= $cmd & " " & $Output & " " & $Input 
		Else	
			$command &= $cmd & " " & $Input& " " & $Output
		EndIf	
	Else
		If $InputPos > $OutputPos Then
			$command &= $Output & " " & $Input & " " & $cmd
		Else	
			$command &= $Input & " " & $Output & " " & $cmd
		EndIf
	EndIf
	
	_7ZIPExtract("", @ScriptDir & "\[BIN]\[COMPRESSORS]\" & $Section[2][1] & ".7z", @ScriptDir & "\[BIN]\[COMPRESSORS]", 1, 1)

	;Run
	ConsoleWrite($command & @CRLF)
	Run($command)
	
	
	;Finish => Cleanup
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\", "*.exe")
	If IsArray($array) then
		For $X = 1 To $array[0]
			FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$X])
		Next
	EndIf
	
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\", "*.sfx")
	If IsArray($array) then
		For $X = 1 To $array[0]
			FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$X])
		Next
	EndIf
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\", "*.dll")
	If IsArray($array) then
		For $X = 1 To $array[0]
			If $array[$X] <> "7-zip32.dll" Then FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$X])
		Next
	EndIf
	
	;_ArrayDisplay($array)
	$array = 0
EndFunc ;==>_Execute_Compression

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPExtract
; Description ...: Extracts files from archive to the current directory or to the output directory
; Syntax.........: _7ZIPExtract($hWnd, $sArcName[, $sOutput = 0[, $sHide = 0[, $sOverwrite = 0[, $sRecurse = 1[, _
;				   				$sIncludeArc[, $sExcludeArc[, $sIncludeFile = 0[, $sExcludeFile = 0[, $sPassword = 0[, _
;								$sYes = 0]]]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sOutput      - Output directory
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sOverwrite   - Overwrite mode:   0 - Overwrite All existing files without prompt, _
;												     1 - Skip extracting of existing files, _
;												     2 - Auto rename extracting file, _
;												     3 - auto rename existing file
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeArc  - Include archive filenames
;				   $sExcludeArc  - Exclude archive filenames
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $Yes          - assume Yes on all queries
; Return values .: Success       - Returns the string with results
;                  Failure       - Returns 0 and and sets the @error flag to 1
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================

Func _7ZIPExtract($hWnd, $sArcName, $sOutput = 0, $sHide = 0, $sOverwrite = 0, $sRecurse = 1, $sIncludeArc = 0, $sExcludeArc = 0, _
			$sIncludeFile = 0, $sExcludeFile = 0, $sPassword = 0, $sYes = 0)
	
	$sArcName = '"' & $sArcName & '"'
	
	Local $iSwitch = ""
	
	If $sOutput Then $iSwitch = ' -o"' & $sOutput & '"'
	If $sHide Then $iSwitch &= " -hide"
	
	If $sPassword Then $iSwitch &= " -p" & $sPassword
	If $sYes Then $iSwitch &= " -y"
	
	Local $tOutBuffer = DllStructCreate("char[32768]")
	
	Local $hDLL_7ZIP = DllOpen(@ScriptDir & "\[BIN]\[COMPRESSORS]\7-zip32.dll") ;verbessern
	
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "e " & $sArcName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))
	
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc ;==>_7ZIPExtract