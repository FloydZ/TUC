
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>

_DrawTextOnLoadingScreen("Loading Constants into MEM...")
Dim Const $tagSHFILEINFO = "dword hIcon; int iIcon; DWORD dwAttributes; CHAR szDisplayName[255]; CHAR szTypeName[80];"
Dim Const $SHGFI_USEFILEATTRIBUTES = 0x10
Dim Const $SHGFI_SYSICONINDEX = 0x4000
Dim Const $SHGFI_SMALLICON = 0x1
Dim Const $SHGFI_LARGEICON = 0x0
Dim Const $FOLDERUP_ICON_INDEX = _GUIImageList_AddIcon(_GUIImageList_GetSystemImageList(), @SystemDir & "\shell32.dll", 132)
Dim Const $FOLDER_ICON_INDEX = _GUIImageList_GetFileIconIndex(@SystemDir, 0, 1)
Dim Const $NOICON_ICON_INDEX = _GUIImageList_GetFileIconIndex("nb lgl", 0, 0)
Select
	Case @OSBuild < 2195
		$tagNOTIFYICONDATAW_TEMP = "DWORD cbSize; HWND hWnd; UINT uID; UINT uFlags; UINT uCallbackMessage; ptr hIcon; WCHAR szTip[64];"
	Case Else
		$tagNOTIFYICONDATAW_TEMP = "DWORD cbSize; HWND hWnd; UINT uID; UINT uFlags; UINT uCallbackMessage; ptr hIcon; WCHAR szTip[128];" & _
				"DWORD dwState; DWORD dwStateMask; WCHAR szInfo[256]; UINT  uTimeout; WCHAR szInfoTitle[64]; DWORD dwInfoFlags;"
EndSelect
Dim Const $tagNOTIFYICONDATAW = $tagNOTIFYICONDATAW_TEMP
Dim Const $tagNOTIFYICONDATA = $tagNOTIFYICONDATAW
Dim Const $NIN_BALLOONSHOW = $WM_USER + 2
Dim Const $NIN_BALLOONHIDE = $WM_USER + 3
Dim Const $NIN_BALLOONTIMEOUT = $WM_USER + 4
Dim Const $NIN_BALLOONUSERCLICK = $WM_USER + 5
Dim Const $NIM_ADD = 0x00000000
Dim Const $NIM_MODIFY = 0x00000001
Dim Const $NIM_DELETE = 0x00000002
Dim Const $NIM_SETFOCUS = 0x00000003
Dim Const $NIM_SETVERSION = 0x00000004
Dim Const $NIF_MESSAGE = 0x00000001
Dim Const $NIF_ICON = 0x00000002
Dim Const $NIF_TIP = 0x00000004
Dim Const $NIF_STATE = 0x00000008
Dim Const $NIF_INFO = 0x00000010
Dim Const $NIF_GUID = 0x00000020
Dim Const $NIF_REALTIME = 0x00000040
Dim Const $NIF_SHOWTIP = 0x00000080
Dim Const $NIS_VISIBLE = 0x00000000
Dim Const $NIS_HIDDEN = 0x00000001
Dim Const $NIS_SHAREDICON = 0x00000002
Dim Const $NIIF_NONE = 0x00000000
Dim Const $NIIF_INFO = 0x00000001
Dim Const $NIIF_WARNING = 0x00000002
Dim Const $NIIF_ERROR = 0x00000003
Dim Const $NIIF_USER = 0x00000004
Dim Const $NIIF_NOSOUND = 0x00000010
Dim Const $NIIF_LARGE_ICON = 0x00000010
Dim Const $NIIF_RESPECT_QUIET_TIME = 0x00000080
Dim Const $NIIF_ICON_MASK = 0x0000000F
Dim Const $WM_TRAYICONPROC = $WM_USER + 100


Func _SHLV_PopulateLocalListView($hListView1, ByRef $DIRECTORY_LOCAL)
	If Not IsHWnd($hListView1) Then $hListView1 = GUICtrlGetHandle($hListView1)
	If $DIRECTORY_LOCAL = "" Then
		Local $drives = DriveGetDrive("ALL")
		_GUICtrlListView_BeginUpdate($hListView1)
		_GUICtrlListView_DeleteAllItems($hListView1)
		For $i = 1 To $drives[0]
			_GUICtrlListView_AddItem($hListView1, StringUpper($drives[$i]) & "\", _GUIImageList_GetFileIconIndex($drives[$i] & "\"))
		Next
		_GUICtrlListView_EndUpdate($hListView1)
		Return
	EndIf
	If StringRight($DIRECTORY_LOCAL, 1) <> "\" Then $DIRECTORY_LOCAL &= "\"
	If DriveStatus(StringLeft($DIRECTORY_LOCAL, 3)) <> "READY" Then Return 0 * MsgBox(16 + 8192, 'Error on Drive Access', "Drive " & StringLeft($DIRECTORY_LOCAL, 3) & " not ready!")
	$files = _SHLV__FileListToArray2($DIRECTORY_LOCAL, "*.*", 2)
	_GUICtrlListView_BeginUpdate($hListView1)
	_GUICtrlListView_DeleteAllItems($hListView1)
	Local $foldercount = 0
	_GUICtrlListView_AddItem($hListView1, "< .. >", $FOLDERUP_ICON_INDEX)
	If IsArray($files) Then
		_GUICtrlListView_SetItemCount($hListView1, $files[0] + 1)
		$foldercount = $files[0] + 1
		For $i = 1 To $files[0]
			$item = _GUICtrlListView_AddItem($hListView1, $files[$i], $FOLDER_ICON_INDEX)
			_GUICtrlListView_AddSubItem($hListView1, $item, __SHLV_FormatFilesize(DirGetSize($DIRECTORY_LOCAL & $files[$i], 2)), 2)
		Next
	EndIf
	$files = _SHLV__FileListToArray2($DIRECTORY_LOCAL, "*.*", 1)
	_GUICtrlListView_EndUpdate($hListView1)
	_GUICtrlListView_BeginUpdate($hListView1)
	If IsArray($files) Then
		_GUICtrlListView_SetItemCount($hListView1, $files[0] + $foldercount)
		For $i = 1 To $files[0]
			$item = _GUICtrlListView_AddItem($hListView1, $files[$i], _GUIImageList_GetFileIconIndex($files[$i]))
			_GUICtrlListView_AddSubItem($hListView1, $item, __SHLV_FileDateString2Calc(FileGetTime($DIRECTORY_LOCAL & $files[$i], 0, 1)), 1)
			_GUICtrlListView_AddSubItem($hListView1, $item, __SHLV_FormatFilesize(FileGetSize($DIRECTORY_LOCAL & $files[$i])), 2)
		Next
	EndIf
	_GUICtrlListView_EndUpdate($hListView1)
EndFunc   ;==>_SHLV_PopulateLocalListView
Func __SHLV_FormatFilesize($size)
	Select
		Case $size > 1000
			Return Round($size / 1024, 1) & " KB"
		Case $size > 1048500
			Return Round($size / 1048576, 1) & " MB"
		Case Else
			Return $size & " Byte"
	EndSelect
EndFunc   ;==>__SHLV_FormatFilesize
Func _GUIImageList_GetSystemImageList($bLargeIcons = False)
	Local $dwFlags, $hIml, $FileInfo = DllStructCreate($tagSHFILEINFO)
	$dwFlags = BitOR($SHGFI_USEFILEATTRIBUTES, $SHGFI_SYSICONINDEX)
	If Not ($bLargeIcons) Then
		$dwFlags = BitOR($dwFlags, $SHGFI_SMALLICON)
	EndIf
;~    '// Load the image list - use an arbitrary file extension for the
;~    '// call to SHGetFileInfo (we don't want to touch the disk, so use
;~    '// FILE_ATTRIBUTE_NORMAL && SHGFI_USEFILEATTRIBUTES).
	$hIml = _WinAPI_SHGetFileInfo(".txt", $FILE_ATTRIBUTE_NORMAL, _
			DllStructGetPtr($FileInfo), DllStructGetSize($FileInfo), $dwFlags)
	Return $hIml
EndFunc   ;==>_GUIImageList_GetSystemImageList
Func _WinAPI_SHGetFileInfo($pszPath, $dwFileAttributes, $psfi, $cbFileInfo, $uFlags)
	Local $return = DllCall("shell32.dll", "DWORD*", "SHGetFileInfo", "str", $pszPath, "DWORD", $dwFileAttributes, "ptr", $psfi, "UINT", $cbFileInfo, "UINT", $uFlags)
	If @error Then Return SetError(@error, 0, 0)
	Return $return[0]
EndFunc   ;==>_WinAPI_SHGetFileInfo
Func _GUIImageList_GetFileIconIndex($sFileSpec, $bLargeIcons = False, $bForceLoadFromDisk = False)
	Local $dwFlags, $FileInfo = DllStructCreate($tagSHFILEINFO)
	$dwFlags = $SHGFI_SYSICONINDEX
	If $bLargeIcons Then
		$dwFlags = BitOR($dwFlags, $SHGFI_LARGEICON)
	Else
		$dwFlags = BitOR($dwFlags, $SHGFI_SMALLICON)
	EndIf
;~ ' We choose whether to access the disk or not. If you don't
;~ ' hit the disk, you may get the wrong icon if the icon is
;~ ' not cached. But the speed is very good!
	If Not $bForceLoadFromDisk Then
		$dwFlags = BitOR($dwFlags, $SHGFI_USEFILEATTRIBUTES)
	EndIf
;~ ' sFileSpec can be any file. You can specify a
;~ ' file that does not exist and still get the
;~ ' icon, for example sFileSpec = "C:\PANTS.DOC"
	Local $lR = _WinAPI_SHGetFileInfo( _
			$sFileSpec, $FILE_ATTRIBUTE_NORMAL, DllStructGetPtr($FileInfo), DllStructGetSize($FileInfo), _
			$dwFlags _
			)
	If ($lR = 0) Then
		Return SetError(1, 0, -1)
	Else
		Return DllStructGetData($FileInfo, "iIcon")
	EndIf
EndFunc   ;==>_GUIImageList_GetFileIconIndex
Func __SHLV_FileDateString2Calc($filedate)
	Return StringRegExpReplace($filedate, "(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})", "$1/$2/$3 $4:$5:$6")
EndFunc   ;==>__SHLV_FileDateString2Calc
Func __SHLV_CalcDate2FileDateString($calcdate)
	Return StringRegExpReplace($calcdate, "(\d{4})/(\d{2})/(\d{2}) (\d{2})(IMG:http://www.autoitscript.com/forum/style_emoticons/autoit/sad.gif) \d{2})(IMG:http://www.autoitscript.com/forum/style_emoticons/autoit/sad.gif) \d{2})", "$1$2$3$4$5$6")
EndFunc   ;==>__SHLV_CalcDate2FileDateString
Func _Browse($data)
	If StringInStr(FileGetAttrib($DIRECTORY_LOCAL & $data), "D") Then
		$DIRECTORY_LOCAL &= $data
		_SHLV_PopulateLocalListView($ExplorerView, $DIRECTORY_LOCAL)
	ElseIf StringRegExp($data, "\A[A-Za-z]:\\\Z") Then
		$DIRECTORY_LOCAL = $data
		_SHLV_PopulateLocalListView($ExplorerView, $DIRECTORY_LOCAL)
	ElseIf $data = "< .. >" Then
		Local $slash = StringInStr($DIRECTORY_LOCAL, "\", 1, -2)
		If $slash Then
			$DIRECTORY_LOCAL = StringLeft($DIRECTORY_LOCAL, $slash)
		ElseIf StringRegExp($DIRECTORY_LOCAL, "\A[A-Za-z]:\\\Z") Then
			$DIRECTORY_LOCAL = ""
		EndIf
		_SHLV_PopulateLocalListView($ExplorerView, $DIRECTORY_LOCAL)
	Else
		;Hier wird bei einem Doppelklick alles ausgeführt
		$Ext = StringRight($data, 4)
		Switch $Ext
			Case ".txt"
				MsgBox(0, "", "TXT")
			Case ".mp3"
				_LoadMusic($DIRECTORY_LOCAL & $data)
				$i = _GUICtrlListView_AddItem($ListView[0], $data)
				_GUICtrlListView_AddSubItem($ListView[0], $i, $DIRECTORY_LOCAL, 1)
			Case ".wmv"
				_LoadVideo($DIRECTORY_LOCAL & $data)
				$i = _GUICtrlListView_AddItem($ListView[1], $data)
				_GUICtrlListView_AddSubItem($ListView[1], $i, $DIRECTORY_LOCAL, 1)
			Case ".avi"
				_LoadVideo($DIRECTORY_LOCAL & $data)
				$i = _GUICtrlListView_AddItem($ListView[1], $data)
				_GUICtrlListView_AddSubItem($ListView[1], $i, $DIRECTORY_LOCAL, 1)
			Case Else
				ShellExecute($DIRECTORY_LOCAL & $data, "", $DIRECTORY_LOCAL & $DIRECTORY_LOCAL)
		EndSwitch
	EndIf
EndFunc   ;==>_Browse
Func _SHLV__FileListToArray2($sPath, $sFilter = "*", $iFlag = 0)
	Local $hSearch, $sFile, $asFileList
	If Not FileExists($sPath) Then Return SetError(1, 1, "")
	If (StringInStr($sFilter, "\")) Or (StringInStr($sFilter, "/")) Or (StringInStr($sFilter, ":")) Or (StringInStr($sFilter, ">")) Or (StringInStr($sFilter, "<")) Or (StringInStr($sFilter, "|")) Or (StringStripWS($sFilter, 8) = "") Then Return SetError(2, 2, "")
	If Not ($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 3, "")
	If (StringMid($sPath, StringLen($sPath), 1) = "\") Then $sPath = StringTrimRight($sPath, 1) ; needed for Win98 for x:\  root dir
	$hSearch = FileFindFirstFile($sPath & "\" & $sFilter)
	If $hSearch = -1 Then Return SetError(4, 4, "")
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then
			SetError(0)
			ExitLoop
		EndIf
		If $iFlag = 1 And StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") <> 0 Then ContinueLoop
		If $iFlag = 2 And StringInStr(FileGetAttrib($sPath & "\" & $sFile), "D") = 0 Then ContinueLoop
		$asFileList &= $sFile & @CR
	WEnd
	FileClose($hSearch)
	If Not $asFileList Then
		Dim $asFileList[1] = [0]
		Return SetError(1, 0, $asFileList)
	EndIf
	Return StringSplit(StringTrimRight($asFileList, 1), @CR)
EndFunc   ;==>_SHLV__FileListToArray2