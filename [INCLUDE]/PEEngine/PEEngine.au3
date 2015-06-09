;PEEngine.au3


Func _GetSignature($FILE)
	$Sections = IniReadSectionNames($FILE)
	Dim $SIG[$Sections[0]][3]
	For $X = 1 To $Sections[0]
		$Read = IniRead($FILE, $Sections[$X], "Signature", "00")
		$EP = IniRead($FILE, $Sections[$X], "ep_only", "00")
		$SIG[$X][0] = $Sections[$X]
		$SIG[$X][1] = $Read
		$SIG[$X][2] = $EP
		If $X = 1140 Then Return $SIG
	Next
EndFunc ;==>_GetSignature

Func _HexEncode($bInput)

	Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")

	DllStructSetData($tInput, 1, $bInput)

	Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
			"ptr", DllStructGetPtr($tInput), _
			"dword", DllStructGetSize($tInput), _
			"dword", 11, _
			"ptr", 0, _
			"dword*", 0)

	If @error Or Not $a_iCall[0] Then
		Return SetError(1, 0, "")
	EndIf

	Local $iSize = $a_iCall[5]
	Local $tOut = DllStructCreate("char[" & $iSize & "]")

	$a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
			"ptr", DllStructGetPtr($tInput), _
			"dword", DllStructGetSize($tInput), _
			"dword", 11, _
			"ptr", DllStructGetPtr($tOut), _
			"dword*", $iSize)

	If @error Or Not $a_iCall[0] Then
		Return SetError(2, 0, "")
	EndIf

	Return SetError(0, 0, DllStructGetData($tOut, 1))

EndFunc   ;==>_HexEncode

Func _SwitchViews_Scan()
	If $Treeview_VAR = 1 Then ;EDIT
		GUICtrlSetState($Treeview[0], $GUI_SHOW)
		GUICtrlSetState($Edit[0], $GUI_HIDE)
		GUICtrlSetState($Edit[1], $GUI_HIDE)
		$Treeview_VAR = 2
	ElseIf $Treeview_VAR = 2 Then ;TREEVIEW ALLG
		GUICtrlSetState($Treeview[0], $GUI_HIDE)
		GUICtrlSetState($Edit[0], $GUI_SHOW)
		GUICtrlSetState($Edit[1], $GUI_HIDE)
		For $X = 3 To 6
			GUICtrlSetState($NormalButton[$X], $GUI_SHOW)
		Next
		$Treeview_VAR = 3
	Else ;TREEVIEW SPEZ
		GUICtrlSetState($Edit[1], $GUI_SHOW)
		GUICtrlSetState($Treeview[0], $GUI_HIDE)
		GUICtrlSetState($Edit[0], $GUI_HIDE)
		For $X = 3 To 6
			GUICtrlSetState($NormalButton[$X], $GUI_HIDE)
		Next
		$Treeview_VAR = 1
	EndIf
EndFunc

Func _SetScanWithFileOpenDialog()
	$FILE = FileOpenDialog("Select a File", "", "eXecutables (*.exe;*.dll)", 1)
	_SetScan($FILE)
EndFunc

Func _SetScan($IntFile)
	If $FILE = "" Then Return 0
	_GUICtrlTreeView_DeleteAll($Treeview[0])

	
	GUICtrlSetData($Edit[0],_HexEncode(FileRead($IntFile, -1))) ;Dissamble
	_PopulateMiscTreeView($Treeview[0], $IntFile)
	GUICtrlSetData($Input[1], $IntFile)
EndFunc ;==>_SetScan

Func _CheckSIG()
	$String = GUICtrlRead($Edit[0])
	$MID = StringMid($String, 13, 47) & " " & StringMid($String, 89, 47)
	;_ArrayDisplay($Signature)
	For $X = 1 To UBound($Signature) - 1
		If StringRegExp($Signature[$X][1], "^" & StringReplace($MID, "?", "[[:xdigit:]]") & "(?:\s[[:xdigit:]]{2})*$") Then
			$MID &= _StringRepeat(" ??", (StringLen($Signature[$X][1]) - StringLen($MID)) / 3)
		EndIf
		_Compare($MID, $Signature[$X][1], "?") ;= 1 Then MsgBox(0,"","")
		;ConsoleWrite($MID & @lf & $Signature[$x][1] & @lf )
	Next
	MsgBox(0, "ERROR", "ERROR")
EndFunc ;==>_CheckSIG

Func _Compare($s1, $s2, $wildcard)
	$diff = StringLen($s2) - StringLen($s1)
	For $i = 1 To StringLen($s1)
		If (StringMid($s1, $i, 1) = StringMid($s2, $i, 1)) Or StringMid($s1, $i, 1) = $wildcard Or StringMid($s2, $i, 1) = $wildcard Then
			If $i = StringLen($s1) Then
				Return 1
			EndIf
			ContinueLoop
		Else
			Return 0
			ExitLoop
		EndIf
	Next
EndFunc ;==>_Compare

Func _PopulateMiscTreeView($hTreeViewControl, $sModule)
	DllCall("kernel32.dll", "dword", "SetErrorMode", "dword", 1) ; SEM_FAILCRITICALERRORS ; will handle errors
	Local $iLoaded
	Local $a_hCall = DllCall("kernel32.dll", "hwnd", "GetModuleHandleW", "wstr", $sModule)
	
	If @error Then
		Return SetError(1, 0, "")
	EndIf
	Local $pPointer = $a_hCall[0]
	If Not $a_hCall[0] Then
		$a_hCall = DllCall("kernel32.dll", "hwnd", "LoadLibraryExW", "wstr", $sModule, "hwnd", 0, "int", 1) ; DONT_RESOLVE_DLL_REFERENCES
		If @error Or Not $a_hCall[0] Then
			$a_hCall = DllCall("kernel32.dll", "hwnd", "LoadLibraryExW", "wstr", $sModule, "hwnd", 0, "int", 34) ; LOAD_LIBRARY_AS_IMAGE_RESOURCE|LOAD_LIBRARY_AS_DATAFILE
			
			If @error Or Not $a_hCall[0] Then
				Return SetError(2, 0, "")
			EndIf
			$iLoaded = 1
			$pPointer = $a_hCall[0] - 1
		Else
			$iLoaded = 1
			$pPointer = $a_hCall[0]
		EndIf
	EndIf
	Local $hModule = $a_hCall[0]
	Local $tIMAGE_DOS_HEADER = DllStructCreate("char Magic[2];" & _
			"ushort BytesOnLastPage;" & _
			"ushort Pages;" & _
			"ushort Relocations;" & _
			"ushort SizeofHeader;" & _
			"ushort MinimumExtra;" & _
			"ushort MaximumExtra;" & _
			"ushort SS;" & _
			"ushort SP;" & _
			"ushort Checksum;" & _
			"ushort IP;" & _
			"ushort CS;" & _
			"ushort Relocation;" & _
			"ushort Overlay;" & _
			"char Reserved[8];" & _
			"ushort OEMIdentifier;" & _
			"ushort OEMInformation;" & _
			"char Reserved2[20];" & _
			"dword AddressOfNewExeHeader", _
			$pPointer)
	Local $sMagic = DllStructGetData($tIMAGE_DOS_HEADER, "Magic")
	If Not ($sMagic == "MZ") Then
		If $iLoaded Then
			Local $a_iCall = DllCall("kernel32.dll", "int", "FreeLibrary", "hwnd", $hModule)
			If @error Or Not $a_iCall[0] Then
				Return SetError(5, 0, "")
			EndIf
		EndIf
		Return SetError(3, 0, "")
	EndIf
	Local $iAddressOfNewExeHeader = DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader")
	$pPointer += $iAddressOfNewExeHeader ; start of PE file header
	Local $tIMAGE_NT_SIGNATURE = DllStructCreate("dword Signature", $pPointer) ; IMAGE_NT_SIGNATURE = 17744
	If Not (DllStructGetData($tIMAGE_NT_SIGNATURE, "Signature") = 17744) Then
		If $iLoaded Then
			Local $a_iCall = DllCall("kernel32.dll", "int", "FreeLibrary", "hwnd", $hModule)
			If @error Or Not $a_iCall[0] Then
				Return SetError(5, 0, "")
			EndIf
		EndIf
		Return SetError(4, 0, "")
	EndIf
	$pPointer += 4 ; size of $tIMAGE_NT_SIGNATURE structure
	Local $tIMAGE_FILE_HEADER = DllStructCreate("ushort Machine;" & _
			"ushort NumberOfSections;" & _
			"dword TimeDateStamp;" & _
			"dword PointerToSymbolTable;" & _
			"dword NumberOfSymbols;" & _
			"ushort SizeOfOptionalHeader;" & _
			"ushort Characteristics", _
			$pPointer)
	$pPointer += 20 ; size of $tIMAGE_FILE_HEADER structure
	Local $tIMAGE_OPTIONAL_HEADER = DllStructCreate("ushort Magic;" & _
			"ubyte MajorLinkerVersion;" & _
			"ubyte MinorLinkerVersion;" & _
			"dword SizeOfCode;" & _
			"dword SizeOfInitializedData;" & _
			"dword SizeOfUninitializedData;" & _
			"dword AddressOfEntryPoint;" & _
			"dword BaseOfCode;" & _
			"dword BaseOfData;" & _
			"dword ImageBase;" & _
			"dword SectionAlignment;" & _
			"dword FileAlignment;" & _
			"ushort MajorOperatingSystemVersion;" & _
			"ushort MinorOperatingSystemVersion;" & _
			"ushort MajorImageVersion;" & _
			"ushort MinorImageVersion;" & _
			"ushort MajorSubsystemVersion;" & _
			"ushort MinorSubsystemVersion;" & _
			"dword Win32VersionValue;" & _
			"dword SizeOfImage;" & _
			"dword SizeOfHeaders;" & _
			"dword CheckSum;" & _
			"ushort Subsystem;" & _
			"ushort DllCharacteristics;" & _
			"dword SizeOfStackReserve;" & _
			"dword SizeOfStackCommit;" & _
			"dword SizeOfHeapReserve;" & _
			"dword SizeOfHeapCommit;" & _
			"dword LoaderFlags;" & _
			"dword NumberOfRvaAndSizes", _
			$pPointer)
	$hGeneralInfoTree = GUICtrlCreateTreeViewItem("General Information", $hTreeViewControl)
	GUICtrlSetColor($hGeneralInfoTree, 0x0000C0)
	GUICtrlSetState($hGeneralInfoTree, 512)
	Local $iMachine = DllStructGetData($tIMAGE_FILE_HEADER, "Machine")
	Local $sMachine
	Switch $iMachine
		Case 332
			$sMachine = "x86"
		Case 512
			$sMachine = "Intel IPF"
		Case 34404
			$sMachine = "x64"
	EndSwitch
	Local $iMagic = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "Magic")
	Local $sMagic
	Switch $iMagic
		Case 267
			$sMagic = "32-bit application"
		Case 523
			$sMagic = "64-bit application"
		Case 263
			$sMagic = "ROM image"
	EndSwitch
	GUICtrlCreateTreeViewItem("File size: " & FileGetSize($sModule) & " (Hex: " & Hex(FileGetSize($sModule)) & ") bytes", $hGeneralInfoTree)
	Local $aHashes = _GetHashes($sModule)
	GUICtrlCreateTreeViewItem("MD5: " & $aHashes[0], $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("SHA1: " & $aHashes[1], $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("TimeDateStamp: " & _EpochDecrypt(DllStructGetData($tIMAGE_FILE_HEADER, "TimeDateStamp")) & " UTC", $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("Made for: " & $sMachine & " machine", $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("Type: " & $sMagic, $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("AddressOfEntryPoint: " & Ptr(DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint")), $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("ImageBase: " & Ptr(DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase")), $hGeneralInfoTree)
	GUICtrlCreateTreeViewItem("CheckSum: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "CheckSum"), $hGeneralInfoTree)
	If Not ($iMagic = 267) Then
		If $iLoaded Then
			Local $a_iCall = DllCall("kernel32.dll", "int", "FreeLibrary", "hwnd", $hModule)
			If @error Or Not $a_iCall[0] Then
				Return SetError(5, 0, "")
			EndIf
		EndIf
		Return SetError(0, 1, 1) ; not 32-bit application. Structures are for 32-bit
	EndIf
	$hPEInfoTree = GUICtrlCreateTreeViewItem("PE Information", $hTreeViewControl)
	GUICtrlSetColor($hPEInfoTree, 0x0000C0)
	GUICtrlSetState($hPEInfoTree, 512)
	$MZHeader = GUICtrlCreateTreeViewItem("MZ Header", $hPEInfoTree)
	GUICtrlCreateTreeViewItem("BytesOnLastPage: " & DllStructGetData($tIMAGE_DOS_HEADER, "BytesOnLastPage"), $MZHeader)
	GUICtrlCreateTreeViewItem("Pages: " & DllStructGetData($tIMAGE_DOS_HEADER, "Pages"), $MZHeader)
	GUICtrlCreateTreeViewItem("Relocations: " & DllStructGetData($tIMAGE_DOS_HEADER, "Relocations"), $MZHeader)
	GUICtrlCreateTreeViewItem("SizeofHeader: " & DllStructGetData($tIMAGE_DOS_HEADER, "SizeofHeader"), $MZHeader)
	GUICtrlCreateTreeViewItem("MinimumExtra: " & DllStructGetData($tIMAGE_DOS_HEADER, "MinimumExtra"), $MZHeader)
	GUICtrlCreateTreeViewItem("MaximumExtra: " & DllStructGetData($tIMAGE_DOS_HEADER, "MaximumExtra"), $MZHeader)
	GUICtrlCreateTreeViewItem("SS: " & DllStructGetData($tIMAGE_DOS_HEADER, "SS"), $MZHeader)
	GUICtrlCreateTreeViewItem("SP: " & DllStructGetData($tIMAGE_DOS_HEADER, "SP"), $MZHeader)
	GUICtrlCreateTreeViewItem("Checksum: " & DllStructGetData($tIMAGE_DOS_HEADER, "Checksum"), $MZHeader)
	GUICtrlCreateTreeViewItem("IP: " & DllStructGetData($tIMAGE_DOS_HEADER, "IP"), $MZHeader)
	GUICtrlCreateTreeViewItem("CS: " & DllStructGetData($tIMAGE_DOS_HEADER, "CS"), $MZHeader)
	GUICtrlCreateTreeViewItem("Relocation: " & DllStructGetData($tIMAGE_DOS_HEADER, "Relocation"), $MZHeader)
	GUICtrlCreateTreeViewItem("Overlay: " & DllStructGetData($tIMAGE_DOS_HEADER, "Overlay"), $MZHeader)
	GUICtrlCreateTreeViewItem("OEMIdentifier: " & DllStructGetData($tIMAGE_DOS_HEADER, "OEMIdentifier"), $MZHeader)
	GUICtrlCreateTreeViewItem("OEMInformation: " & DllStructGetData($tIMAGE_DOS_HEADER, "OEMInformation"), $MZHeader)
	GUICtrlCreateTreeViewItem("AddressOfNewExeHeader: " & DllStructGetData($tIMAGE_DOS_HEADER, "BytesOnLastPage"), $MZHeader)
	GUICtrlCreateTreeViewItem("BytesOnLastPage: " & DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader"), $MZHeader)
	$PEHeader = GUICtrlCreateTreeViewItem("PE Header", $hPEInfoTree)
	$FileHeader = GUICtrlCreateTreeViewItem("File Header", $PEHeader)
	GUICtrlCreateTreeViewItem("Machine: " & $iMachine, $FileHeader)
	GUICtrlCreateTreeViewItem("NumberOfSections: " & DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections"), $FileHeader)
	GUICtrlCreateTreeViewItem("PointerToSymbolTable: " & DllStructGetData($tIMAGE_FILE_HEADER, "PointerToSymbolTable"), $FileHeader)
	GUICtrlCreateTreeViewItem("TimeDateStamp: " & DllStructGetData($tIMAGE_FILE_HEADER, "TimeDateStamp"), $FileHeader)
	GUICtrlCreateTreeViewItem("SizeOfOptionalHeader: " & DllStructGetData($tIMAGE_FILE_HEADER, "SizeOfOptionalHeader"), $FileHeader)
	GUICtrlCreateTreeViewItem("Characteristics: " & DllStructGetData($tIMAGE_FILE_HEADER, "Characteristics"), $FileHeader)
	GUICtrlCreateTreeViewItem("NumberOfSymbols: " & DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSymbols"), $FileHeader)
	$OptionalHeader = GUICtrlCreateTreeViewItem("Optional Header", $PEHeader)
	GUICtrlCreateTreeViewItem("Magic: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "Magic"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MajorLinkerVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MajorLinkerVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MinorLinkerVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MinorLinkerVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfCode: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfCode"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfInitializedData: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfInitializedData"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfUninitializedData: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfUninitializedData"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("AddressOfEntryPoint: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("BaseOfCode: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "BaseOfCode"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("BaseOfData: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "BaseOfData"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("ImageBase: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SectionAlignment: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SectionAlignment"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("FileAlignment: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "FileAlignment"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MajorOperatingSystemVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MajorOperatingSystemVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MinorOperatingSystemVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MinorOperatingSystemVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MajorImageVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MajorImageVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MinorImageVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MinorImageVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MajorSubsystemVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MajorSubsystemVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("MinorSubsystemVersion: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "MinorSubsystemVersion"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("Win32VersionValue: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "Win32VersionValue"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfImage: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfImage"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfHeaders: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeaders"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("CheckSum: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "CheckSum"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("Subsystem: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "Subsystem"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("DllCharacteristics: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "DllCharacteristics"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfStackReserve: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfStackReserve"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfStackCommit: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfStackCommit"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfHeapReserve: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeapReserve"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("SizeOfHeapCommit: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeapCommit"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("LoaderFlags: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "LoaderFlags"), $OptionalHeader)
	GUICtrlCreateTreeViewItem("NumberOfRvaAndSizes: " & DllStructGetData($tIMAGE_OPTIONAL_HEADER, "NumberOfRvaAndSizes"), $OptionalHeader)
	$pPointer += 96 ; size of $tIMAGE_OPTIONAL_HEADER structure
	$hExportedFuncTree = GUICtrlCreateTreeViewItem("Exported functions - none", $hTreeViewControl)
	GUICtrlSetColor($hExportedFuncTree, 0x0000C0)
	GUICtrlSetState($hExportedFuncTree, 512)
	$hImportsTree = GUICtrlCreateTreeViewItem("Imported functions - none", $hTreeViewControl)
	GUICtrlSetColor($hImportsTree, 0x0000C0)
	GUICtrlSetState($hImportsTree, 512)
	$hSectionsTree = GUICtrlCreateTreeViewItem("Sections", $hTreeViewControl)
	GUICtrlSetColor($hSectionsTree, 0x0000C0)
	GUICtrlSetState($hSectionsTree, 512)
	Local $hTreeViewExp[1]
	Local $hTreeViewImpModules[1]
	Local $hTreeViewImp[1]
	Local $hTreeViewSections[1]
	Local $iNumberOfSections = DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections")
	ReDim $hTreeViewSections[$iNumberOfSections + 1]
	GUICtrlSetData($hSectionsTree, "Sections (" & $iNumberOfSections & ")")
	; Export Directory
	Local $tIMAGE_DIRECTORY_ENTRY_EXPORT = DllStructCreate("dword VirtualAddress;" & _
			"dword Size", _
			$pPointer)
	If DllStructGetData($tIMAGE_DIRECTORY_ENTRY_EXPORT, "Size") Then
		Local $tIMAGE_EXPORT_DIRECTORY = DllStructCreate("dword Characteristics;" & _
				"dword TimeDateStamp;" & _
				"ushort MajorVersion;" & _
				"ushort MinorVersion;" & _
				"dword Name;" & _
				"dword Base;" & _
				"dword NumberOfFunctions;" & _
				"dword NumberOfNames;" & _
				"dword AddressOfFunctions;" & _
				"dword AddressOfNames;" & _
				"dword AddressOfNameOrdinals", _
				DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_DIRECTORY_ENTRY_EXPORT, "VirtualAddress"))
		Local $iBase = DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "Base")
		Local $iNumberOfExporedFunctions = DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "NumberOfFunctions")
		If $iNumberOfExporedFunctions Then
			ReDim $hTreeViewExp[$iNumberOfExporedFunctions]
			GUICtrlSetData($hExportedFuncTree, "Exported Functions (" & $iNumberOfExporedFunctions & ")")
		EndIf
		;Local $tBufferAddress = DllStructCreate("dword[" & DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "NumberOfFunctions") & "]", DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "AddressOfFunctions"))
		Local $tBufferNames = DllStructCreate("dword[" & DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "NumberOfNames") & "]", DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "AddressOfNames"))
		Local $tBufferNamesOrdinals = DllStructCreate("ushort[" & DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "NumberOfFunctions") & "]", DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "AddressOfNameOrdinals"))
		Local $iNumNames = DllStructGetData($tIMAGE_EXPORT_DIRECTORY, "NumberOfNames") ; number of functions exported by name
		Local $iFuncOrdinal
		Local $tFuncName, $sFuncName
		Local $iFuncAddress
		For $i = 1 To $iNumberOfExporedFunctions
			$hTreeViewExp[$i - 1] = GUICtrlCreateTreeViewItem("Ordinal " & $iBase + $i - 1, $hExportedFuncTree)
		Next
		For $i = 1 To $iNumNames
			$tFuncName = DllStructCreate("char[64]", DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tBufferNames, 1, $i))
			$sFuncName = DllStructGetData($tFuncName, 1) ; name of the function
			$iFuncOrdinal = $iBase + DllStructGetData($tBufferNamesOrdinals, 1, $i)
			;$iFuncAddress = DllStructGetData($tBufferAddress, 1, $i)
			GUICtrlSetData($hTreeViewExp[$iFuncOrdinal - $iBase], $iFuncOrdinal & "  " & $sFuncName) ; & "  " & Ptr($iFuncAddress))
		Next
	EndIf
	$pPointer += 8
	; Import Directory
	Local $tIMAGE_DIRECTORY_ENTRY_IMPORT = DllStructCreate("dword VirtualAddress;" & _
			"dword Size", _
			$pPointer)
	If DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "Size") Then
		Local $tIMAGE_IMPORT_MODULE_DIRECTORY
		Local $iOffset, $iOffset2, $tModuleName, $iBufferOffset, $sModuleName, $iInitialOffset, $tBufferOffset, $tBuffer, $sFunctionName
		Local $i, $j, $k
		While 1
			$i += 1
			$tIMAGE_IMPORT_MODULE_DIRECTORY = DllStructCreate("dword RVAOriginalFirstThunk;" & _ ; actually union
					"dword TimeDateStamp;" & _
					"dword ForwarderChain;" & _
					"dword RVAModuleName;" & _
					"dword RVAFirstThunk", _
					DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "VirtualAddress") + $iOffset)
			If Not DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk") Then ; the end
				ExitLoop
			EndIf
			If DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAOriginalFirstThunk") Then
				$iInitialOffset = DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAOriginalFirstThunk")
			Else
				$iInitialOffset = DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk")
			EndIf
			$tModuleName = DllStructCreate("char[64]", DllStructGetPtr($tIMAGE_DOS_HEADER) + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAModuleName"))
			$sModuleName = DllStructGetData($tModuleName, 1)
			ReDim $hTreeViewImpModules[$i + 1]
			$hTreeViewImpModules[$i] = GUICtrlCreateTreeViewItem($sModuleName, $hImportsTree)
			$iOffset2 = 0
			$j = 0
			While 1
				$j += 1
				$tBufferOffset = DllStructCreate("dword", $iInitialOffset + $iOffset2)
				$iBufferOffset = DllStructGetData($tBufferOffset, 1)
				If Not $iBufferOffset Then ; zero value is the end
					ExitLoop
				EndIf
				If BitShift($iBufferOffset, 24) Then ; MSB is set for imports by ordinal, otherwise not
					GUICtrlCreateTreeViewItem("Ordinal " & BitAND($iBufferOffset, 0xFFFFFF), $hTreeViewImpModules[$i])
					$iOffset2 += 4 ; size of $tBufferOffset
					ContinueLoop
				EndIf
				$tBuffer = DllStructCreate("ushort Ordinal; char Name[64]", DllStructGetPtr($tIMAGE_DOS_HEADER) + $iBufferOffset)
				$sFunctionName = DllStructGetData($tBuffer, "Name")
				GUICtrlCreateTreeViewItem($sFunctionName, $hTreeViewImpModules[$i])
				$iOffset2 += 4 ; size of $tBufferOffset
			WEnd
			GUICtrlSetData($hTreeViewImpModules[$i], $sModuleName & " (" & $j - 1 & ")")
			$k += $j - 1
			$iOffset += 20 ; size of $tIMAGE_IMPORT_MODULE_DIRECTORY
		WEnd
		GUICtrlSetData($hImportsTree, "Imported functions (" & $k & ")")
	EndIf
	$pPointer += 8
	#cs
		; Resource Directory
		Local $tIMAGE_DIRECTORY_ENTRY_RESOURCE = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Exception Directory
		Local $tIMAGE_DIRECTORY_ENTRY_EXCEPTION = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Security Directory
		Local $tIMAGE_DIRECTORY_ENTRY_SECURITY = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Base Relocation Directory
		Local $tIMAGE_DIRECTORY_ENTRY_BASERELOC = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Debug Directory
		Local $tIMAGE_DIRECTORY_ENTRY_DEBUG = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Description String
		Local $tIMAGE_DIRECTORY_ENTRY_COPYRIGHT = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Machine Value (MIPS GP)
		Local $tIMAGE_DIRECTORY_ENTRY_GLOBALPTR = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; TLS Directory
		Local $tIMAGE_DIRECTORY_ENTRY_TLS = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
		; Load Configuration Directory
		Local $tIMAGE_DIRECTORY_ENTRY_LOAD_CONFIG = DllStructCreate("dword VirtualAddress;" & _
		"dword Size", _
		$pPointer)
		$pPointer += 8
	#ce
	$pPointer += 72 ; instead of olive-green part
	$pPointer += 40 ; five more unused data directories
	Local $tIMAGE_SECTION_HEADER
	Local $iSizeOfRawData, $pPointerToRawData, $tRawData, $bRawData
	For $i = 0 To $iNumberOfSections - 1
		$tIMAGE_SECTION_HEADER = DllStructCreate("char Name[8];" & _
				"dword UnionOfData;" & _
				"dword VirtualAddress;" & _
				"dword SizeOfRawData;" & _
				"dword PointerToRawData;" & _
				"dword PointerToRelocations;" & _
				"dword PointerToLinenumbers;" & _
				"ushort NumberOfRelocations;" & _
				"ushort NumberOfLinenumbers;" & _
				"dword Characteristics", _
				$pPointer)
		$hTreeViewSections[$i] = GUICtrlCreateTreeViewItem(DllStructGetData($tIMAGE_SECTION_HEADER, "Name"), $hSectionsTree)
		GUICtrlCreateTreeViewItem("SizeOfRawData: " & DllStructGetData($tIMAGE_SECTION_HEADER, "SizeOfRawData") & " bytes", $hTreeViewSections[$i])
		GUICtrlCreateTreeViewItem("PointerToRawData: " & Ptr(DllStructGetData($tIMAGE_SECTION_HEADER, "PointerToRawData")), $hTreeViewSections[$i])
		GUICtrlCreateTreeViewItem("VirtualAddress: " & Ptr(DllStructGetData($tIMAGE_SECTION_HEADER, "VirtualAddress")), $hTreeViewSections[$i])
		GUICtrlCreateTreeViewItem("NumberOfRelocations: " & DllStructGetData($tIMAGE_SECTION_HEADER, "NumberOfRelocations"), $hTreeViewSections[$i])
		$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
	Next
	If $iLoaded Then
		Local $a_iCall = DllCall("kernel32.dll", "int", "FreeLibrary", "hwnd", $hModule)
		If @error Or Not $a_iCall[0] Then
			Return SetError(6, 0, "")
		EndIf
	EndIf
	Return SetError(0, 0, 1)
EndFunc ;==>_PopulateMiscTreeView

Func _GetHashes($sFile) ; Siao's originally
	Local $aHashArray[2] = [" ~unable to resolve~", " ~unable to resolve~"] ; predefining output
	Local $a_hCall = DllCall("kernel32.dll", "hwnd", "CreateFileW", _
			"wstr", $sFile, _
			"dword", 0x80000000, _ ; GENERIC_READ
			"dword", 1, _ ; FILE_SHARE_READ
			"ptr", 0, _
			"dword", 3, _ ; OPEN_EXISTING
			"dword", 0, _ ; SECURITY_ANONYMOUS
			"ptr", 0)
	
	If @error Or $a_hCall[0] = -1 Then
		Return SetError(1, 0, $aHashArray)
	EndIf
	Local $hFile = $a_hCall[0]
	$a_hCall = DllCall("kernel32.dll", "ptr", "CreateFileMapping", _
			"hwnd", $hFile, _
			"dword", 0, _ ; default security descriptor
			"dword", 2, _ ; PAGE_READONLY
			"dword", 0, _
			"dword", 0, _
			"ptr", 0)
	
	If @error Or Not $a_hCall[0] Then
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
		Return SetError(2, 0, $aHashArray)
	EndIf
	DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
	Local $hFileMappingObject = $a_hCall[0]
	$a_hCall = DllCall("kernel32.dll", "ptr", "MapViewOfFile", _
			"hwnd", $hFileMappingObject, _
			"dword", 4, _ ; FILE_MAP_READ
			"dword", 0, _
			"dword", 0, _
			"dword", 0)
	
	If @error Or Not $a_hCall[0] Then
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		Return SetError(3, 0, $aHashArray)
	EndIf
	Local $pFile = $a_hCall[0]
	Local $iBufferSize = FileGetSize($sFile)
	Local $a_iCall = DllCall("advapi32.dll", "int", "CryptAcquireContext", _
			"ptr*", 0, _
			"ptr", 0, _
			"ptr", 0, _
			"dword", 1, _ ; PROV_RSA_FULL
			"dword", 0xF0000000) ; CRYPT_VERIFYCONTEXT
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		Return SetError(5, 0, $aHashArray)
	EndIf
	Local $hContext = $a_iCall[1]
	$a_iCall = DllCall("advapi32.dll", "int", "CryptCreateHash", _
			"ptr", $hContext, _
			"dword", 0x00008003, _ ; CALG_MD5
			"ptr", 0, _ ; nonkeyed
			"dword", 0, _
			"ptr*", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(6, 0, $aHashArray)
	EndIf
	Local $hHashMD5 = $a_iCall[5]
	$a_iCall = DllCall("advapi32.dll", "int", "CryptHashData", _
			"ptr", $hHashMD5, _
			"ptr", $pFile, _
			"dword", $iBufferSize, _
			"dword", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashMD5)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(7, 0, $aHashArray)
	EndIf
	Local $tOutMD5 = DllStructCreate("byte[16]")
	$a_iCall = DllCall("advapi32.dll", "int", "CryptGetHashParam", _
			"ptr", $hHashMD5, _
			"dword", 2, _ ; HP_HASHVAL
			"ptr", DllStructGetPtr($tOutMD5), _
			"dword*", 16, _
			"dword", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashMD5)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(8, 0, $aHashArray)
	EndIf
	DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashMD5)
	$aHashArray[0] = Hex(DllStructGetData($tOutMD5, 1))
	$a_iCall = DllCall("advapi32.dll", "int", "CryptCreateHash", _
			"ptr", $hContext, _
			"dword", 0x00008004, _ ; CALG_SHA1
			"ptr", 0, _ ; nonkeyed
			"dword", 0, _
			"ptr*", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(9, 0, $aHashArray)
	EndIf
	Local $hHashSHA1 = $a_iCall[5]
	$a_iCall = DllCall("advapi32.dll", "int", "CryptHashData", _
			"ptr", $hHashSHA1, _
			"ptr", $pFile, _
			"dword", $iBufferSize, _
			"dword", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashSHA1)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(10, 0, $aHashArray)
	EndIf
	Local $tOutSHA1 = DllStructCreate("byte[20]")
	$a_iCall = DllCall("advapi32.dll", "int", "CryptGetHashParam", _
			"ptr", $hHashSHA1, _
			"dword", 2, _ ; HP_HASHVAL
			"ptr", DllStructGetPtr($tOutSHA1), _
			"dword*", 20, _
			"dword", 0)
	
	If @error Or Not $a_iCall[0] Then
		DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
		DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
		DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashSHA1)
		DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
		Return SetError(11, 0, $aHashArray)
	EndIf
	DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
	DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
	DllCall("advapi32.dll", "int", "CryptDestroyHash", "ptr", $hHashSHA1)
	$aHashArray[1] = Hex(DllStructGetData($tOutSHA1, 1))
	DllCall("advapi32.dll", "int", "CryptReleaseContext", "ptr", $hContext, "dword", 0)
	Return SetError(0, 0, $aHashArray)
EndFunc ;==>_GetHashes

Func _EpochDecrypt($iEpochTime)
	Local $iDayToAdd = Int($iEpochTime / 86400)
	Local $iTimeVal = Mod($iEpochTime, 86400)
	If $iTimeVal < 0 Then
		$iDayToAdd -= 1
		$iTimeVal += 86400
	EndIf
	Local $i_wFactor = Int((573371.75 + $iDayToAdd) / 36524.25)
	Local $i_xFactor = Int($i_wFactor / 4)
	Local $i_bFactor = 2442113 + $iDayToAdd + $i_wFactor - $i_xFactor
	Local $i_cFactor = Int(($i_bFactor - 122.1) / 365.25)
	Local $i_dFactor = Int(365.25 * $i_cFactor)
	Local $i_eFactor = Int(($i_bFactor - $i_dFactor) / 30.6001)
	Local $aDatePart[3]
	$aDatePart[2] = $i_bFactor - $i_dFactor - Int(30.6001 * $i_eFactor)
	$aDatePart[1] = $i_eFactor - 1 - 12 * ($i_eFactor - 2 > 11)
	$aDatePart[0] = $i_cFactor - 4716 + ($aDatePart[1] < 3)
	Local $aTimePart[3]
	$aTimePart[0] = Int($iTimeVal / 3600)
	$iTimeVal = Mod($iTimeVal, 3600)
	$aTimePart[1] = Int($iTimeVal / 60)
	$aTimePart[2] = Mod($iTimeVal, 60)
	Return SetError(0, 0, StringFormat("%.2d/%.2d/%.2d %.2d:%.2d:%.2d", $aDatePart[0], $aDatePart[1], $aDatePart[2], $aTimePart[0], $aTimePart[1], $aTimePart[2]))
EndFunc ;==>_EpochDecrypt
