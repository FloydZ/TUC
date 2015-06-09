#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)
Opt("GUIOnEventMode", 1)
OnAutoItExitRegister("_Exit")

; MultiSelect im Explorer
; Dragndrop between einzelnen ctrls
; VARS immer mal wieder freigeben
;VARS
;$TUC_was_wo_wie  für Variabeln im GUI
;z.B:
;	$TUC_GUI_VIDEOENGINE_HALLOWELT
;	$TUC_OPT_REG_LOADDS
;				http://social.msdn.microsoft.com/Search/en-us?query=name+name
;	Loops
;		1. MAIN
;		2. Scan
;		3. Music/Video
;		4. COMPRESS
;		16. WIM
;======================================================================================

#include <GuiListView.au3>
#include <Constants.au3>
#include <File.au3>
#include <GuiTab.au3>
#include <GuiEdit.au3>
#include <GuiTreeView.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <SliderConstants.au3>
#include <ProgressConstants.au3>
#include <GuiStatusBar.au3>
#include <GDIPlus.au3>
#include <GuiComboBox.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <Color.au3>
#include <Timers.au3>
#Include <WinAPI.au3>
#include "[INCLUDE]\GUIScrollbars_Ex.au3"
#include "[INCLUDE]\VisualisierungEngine\VisualisierungEngine.au3"
#include "[INCLUDE]\XMLEngine\_XMLDomWrapper.au3"
#include "[INCLUDE]\MusicEngine\BASSFX.au3";BASS
#include "[INCLUDE]\MusicEngine\BassMix.au3";BASS
#include "[INCLUDE]\MusicEngine\BassExt.au3";BASS
#include "[INCLUDE]\DSEngine\DSEngine.au3";VIDEO
#include "[INCLUDE]\PaintEngine\TIG.au3";TRAY ICON
#include "[INCLUDE]\NewsTickerEngine\NewsTicker.au3"
#include "[INCLUDE]\ExplorerEngine\ExplorerEngine.au3"
#include "[INCLUDE]\MediaPlayerEngine\MediaPlayerEngine.au3"
#include "[INCLUDE]\CompressionEngine\CompressionEngine.au3"
#include "[INCLUDE]\ConvertEngine\ConvertEngine.au3"
#include "[INCLUDE]\PEEngine\PEEngine.au3"
#include "[INCLUDE]\ComputerInfoEngine\ComputerInfoEngine.au3"


#Region Startup
_GDIPlus_Startup()
Local $Form2 = GUICreate("Form2", 200, 100, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST)
_WinAPI_SetLayeredWindowAttributes($Form2, 0xFFFFFFFF)
If @error Then MsgBox(0, "", @error)
Local $hGraphic, $hBitmap, $hGfxBuffer, $R, $B, $G
Local $Mode_Loading = 0
Local $InternalMode = 0 ;um sicherzustellen, dass durch die _DrawLoadingScreenText immer geschrieben wird
Local $LoadingText = ""
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($Form2)
$hBitmap = _GDIPlus_BitmapCreateFromGraphics(200, 100, $hGraphic)
$hGfxBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
Local $Brush = _GDIPlus_PenCreate(0xFF00007F, 2)

Local $hBrushINT = _GDIPlus_BrushCreateSolid(0xFF00007F)
Local $hFormat = _GDIPlus_StringFormatCreate()
Local $hFamily = _GDIPlus_FontFamilyCreate("Arial")
Local $hFont = _GDIPlus_FontCreate($hFamily, 10, 2)
Local $tLayout = _GDIPlus_RectFCreate(0, 83, 200, 100)
	
GUISetState(@SW_SHOW)
Local $aPoints[7][2]
$aPoints[0][0] = 6
$aPoints[1][0] = 0
$aPoints[1][1] = 75
$aPoints[2][0] = 50
$aPoints[2][1] = 25
$aPoints[3][0] = 100
$aPoints[3][1] = 75
$aPoints[4][0] = 150
$aPoints[4][1] = 25
$aPoints[5][0] = 200
$aPoints[5][1] = 75
$aPoints[6][0] = 250
$aPoints[6][1] = 25
Local $bPoints[7][2]
$bPoints[0][0] = 6
$bPoints[1][0] = 0
$bPoints[1][1] = 82.5
$bPoints[2][0] = 50
$bPoints[2][1] = 32.5
$bPoints[3][0] = 100
$bPoints[3][1] = 82.5
$bPoints[4][0] = 150
$bPoints[4][1] = 32.5
$bPoints[5][0] = 200
$bPoints[5][1] = 82.5
$bPoints[6][0] = 250
$bPoints[6][1] = 32.5
Local $cPoints[7][2]
$cPoints[0][0] = 6
$cPoints[1][0] = 0
$cPoints[1][1] = 67.5
$cPoints[2][0] = 50
$cPoints[2][1] = 17.5
$cPoints[3][0] = 100
$cPoints[3][1] = 67.5
$cPoints[4][0] = 150
$cPoints[4][1] = 17.5
$cPoints[5][0] = 200
$cPoints[5][1] = 67.5
$cPoints[6][0] = 250
$cPoints[6][1] = 17.5
AdlibRegister("_DrawLoadingScreen", 25)
;AdlibRegister("_DrawTextOnLoadingScreen2",25)
#EndRegion Startup
#Region CTRL
_DrawTextOnLoadingScreen("Loading Variables into MEM...")
Global $Form, $hSlider, $sSlider, $Statusbar, $ExplorerView, $play, $SEARCHGUI, $SEARCHINPUT, $SEARCHBUTTON
Global $hTicker ;NewsTicker
;Buttons
Global $Button[20]
;MEnus
Global $ExplorerView_Menu
Global $Treeview_Menu[1] ;MSN
Global $Treeview_Menu_Item[1]
Global $VideoLabel_Menu
Global $VideoLabel_Menu_Item
;$CheckBoxes
;	-> Stores the ID of the $CheckBoxes
Global $CheckBoxes[1]
;$ComboBoxes
;	-> Stores the ID of the $ComboBoxes
Global $ComboBoxes[1]
;CTRL
Global $Combo[7]
Global $Checkbox[1]
Global $MusicButton[5]
Global $Edit[2]
Global $Input[5]
Global $NormalButton[20]
Global $Treeview[3]
Global $ListView[2]
Global $Tab[1], $TabSheet[4]
Global $Group[10]
Global $Label[1]
Global $Radio[1]
Global $Slider[1]
#EndRegion CTRL
#Region Vars
Global Const $TUC_TUCINIDIR = @ScriptDir & "\TUC.ini"
Global Const $TUC_OPT_SHELL32 = "shell32.dll"
Global Const $TUC_GUI_FILE_SCAN_PE = @TempDir & "\TUP\ScanEngine\DUMPPE.exe"
Global Const $IMAGE_FILE_MACHINE_I386 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_I386.XML"
Global Const $IMAGE_FILE_MACHINE_AMD64 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_AMD64.XML"
Global Const $IMAGE_FILE_MACHINE_IA64 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_IA64.XML"
Global Const $PLATFORM_INDEPENDENT = @ScriptDir & "\SignatureEngine\PLATFORM_INDEPENDENT.XML"

Global Const $COMPRESSOR_INI = IniRead($TUC_TUCINIDIR, "COMPRESSOR", "COMPRESSORINI", 0)
Global $COMPRESSORS = IniReadSectionNames($COMPRESSOR_INI)

Global $USER32 = DllOpen("user32.dll")

Global $Status = IniRead($TUC_TUCINIDIR, "MAIN", "Status", 0)
Global Const $BufferSize = 0x20000 ;für md5...
Global $Treeview_VAR = IniRead($TUC_TUCINIDIR, "SCAN", "TreeView_Var", 0) ; um zwischen edit treview hinundher zu schalten
Global $VOL = IniRead($TUC_TUCINIDIR, "MUSIC", "Volumen", 100)
Global $MusicHandle ;Musix
Global $StartupArrayMusic ;Um für anfang an Die Listview zu füllen
Global $StartupArrayVideo ;Um für anfang an Die Listview zu füllen
Global $Signature ;Signature Array
Global $Section ;NANA
Global $hSliderStatus = 0 ; wurde eingeführt weil man via winexist keine 100% angabe über die existenz des GUI bekommt
Global $FILE
Global $sDrive, $sDir, $sFile, $sExt

Local $hImage = _GUIImageList_Create(16, 16, 5, 1, 12)
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 3) ; Verzeichnis-Icon 1
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 110) ; Verzeichnis-Icon mit Haken2
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 1) ; Datei-Icon3
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 5) ; Diskette4
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 7) ; Wechseldatenträger5
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 8) ; Festplatte6
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 11) ; CDROM7
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 12) ; Netzwerklaufwerk8
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 53) ; Unbekannt9

_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 281) ; Compression10
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 228) ; Music11
_GUIImageList_AddIcon($hImage, $TUC_OPT_SHELL32, 224) ; Video12
#EndRegion Vars
#Region ExtProgramm
_DrawTextOnLoadingScreen("Checking if it´s first Startup...")
If IniRead($TUC_TUCINIDIR, "MAIN", "FirstStartup", 0) = 0 Then _FirstStartup()
;
_DrawTextOnLoadingScreen("Extracting Software")
_7ZIPExtract("", @ScriptDir & "\[BIN]\[SIGNATURES]\Signatures.7z", @ScriptDir & "\[BIN]\[SIGNATURES]", 1, 1)

_DrawTextOnLoadingScreen("Reading .INI")

$StartupArrayMusic = IniReadSection(@ScriptDir & "\TUC.ini", "MusicListview")
$StartupArrayVideo = IniReadSection(@ScriptDir & "\TUC.ini", "VideoListview")

$Signature = _GetSignature(@ScriptDir & "\[BIN]\[SIGNATURES]\packsig1.ini")


If IniRead($TUC_TUCINIDIR, "VIDEO", "DLLLoaded", 0) <> "1" Then
	Engine_Startup(@ScriptDir & "\[BIN]\[VIDEO]\DSEngine_UDF.dll")
	IniWrite($TUC_TUCINIDIR, "VIDEO", "DLLLOADED", 1)
	_DrawTextOnLoadingScreen("Loading DSEngine.dll...")
EndIf
_DrawTextOnLoadingScreen("Loading BASS.dll..")
_BASS_STARTUP(@ScriptDir & "\[BIN]\[BASS]\bass.dll")
_BASS_FX_Startup(@ScriptDir & "\[BIN]\[BASS]\bass_fx.dll")
_BASS_MIX_Startup(@ScriptDir & "\[BIN]\[BASS]\bassmix.dll")
_BASS_EXT_Startup(@ScriptDir & "\[BIN]\[BASS]\bassExt.dll")
_BASS_Init(0, -1, 44100, 0, "")
_BASS_PluginLoad("bass_fx.dll", 0)
_BASS_PluginLoad("bassmix.dll", 0)
_BASS_PluginLoad("bassExt.dll", 0)
_BASS_SetConfig($BASS_CONFIG_UPDATEPERIOD, 10)
_BASS_SetConfig($BASS_CONFIG_BUFFER, 250) ;DOTO
_DrawTextOnLoadingScreen("Creating TEMP Dir...")
;
_DrawTextOnLoadingScreen("Loading External Programms...")

#EndRegion ExtProgramm


Func _FirstStartup()
	IniWrite(@ScriptDir & "\TUC.ini", "MAIN", "Volumen", 100)
	IniWrite(@ScriptDir & "\TUC.ini", "MAIN", "TreeView_Var", 1)
EndFunc ;==>_FirstStartup

_DrawTextOnLoadingScreen("")

;_GDIPlus_FontDispose($hFont)
;_GDIPlus_FontFamilyDispose($hFamily)
;_GDIPlus_StringFormatDispose($hFormat)
;_GDIPlus_PenDispose($Brush)
;_GDIPlus_BrushDispose($hBrushINT)
_GDIPlus_GraphicsDispose($hGraphic)


#Include "[INCLUDE]\CreateGUI.au3"
GUIRegisterMsg($WM_PAINT, "WM_PAINT")
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

GUIDelete($Form2)
GUISetState(@SW_SHOW)

While 1
	Sleep(50)
	If _IsPressed("0D",  $USER32) Then
		If GUICtrlGetState($Combo[6]) = $GUI_FOCUS Then MsgBox(0,"","JUHH")
	EndIf
WEnd




Func _CheckIfItunesInstalled()
	Return RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Apple Computer, Inc.\Itunes", "iTunesDefault")
EndFunc ;==>_CheckIfItunesInstalled
Func _CheckIfItunesWindowsIsOpenAndStop()
	If WinExists("iTunes") = 1 Then
		$iTunesApp = ObjCreate("iTunes.Application")
		$iTunesApp.PlayPause
	EndIf
EndFunc ;==>_CheckIfItunesWindowsIsOpenAndStop


;Momentan noch im Gebrauch wird dann aber durch die Erweiterten FUnc in MusicEngine ersetzt
Func _LoadMusic($FILE = "")
	If $FILE = "" Then $FILE = FileOpenDialog("Open...", "", "MP3 Files (*.mp3)")
	_BASS_ChannelStop($MusicHandle)
	$MusicHandle = _BASS_StreamCreateFile(False, $FILE, 0, 0, $BASS_STREAM_DECODE)
	$MusicHandle = _BASS_FX_TempoCreate($MusicHandle, $BASS_STREAM_AUTOFREE)
	_BASS_ChannelSetVolume($MusicHandle, _GUICtrlStatusBar_GetText($Statusbar, 5))
	_BASS_ChannelPlay($MusicHandle, 1)
	;$Speed = _BASS_ChannelSetAttribute($MusicHandle,$BASS_ATTRIB_TEMPO,10);TEST damit es funktioniert muss $BASS_STREAM_DECODE flag gesetzt werden
	;MsgBox(0,"",$Speed)
	$iBytes = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)
	Local $iLength = _BASS_ChannelBytes2Seconds($MusicHandle, $iBytes)
	;$aWave = _BASS_EXT_ChannelGetWaveformDecode($MusicHandle, $iLength * $iWaveRes, $iHeight * 0.9, 0, $iLength, $iWaveRes, "_WaveformGetProc")
	$BPMHandle = _BASS_StreamCreateFile(False, $FILE, 0, 0, $BASS_STREAM_DECODE)
	$BPM = _BASS_FX_BPM_DecodeGet($BPMHandle, 0, $iLength, 0, 0)
	_BASS_StreamFree($BPMHandle)
	_GUICtrlStatusBar_SetText($Statusbar, "BPM: " & Round($BPM, 2), 6)
EndFunc ;==>_LoadMusic
Func _LoadVideo($FILE = "")
	If GUICtrlRead($NormalButton[15]) = ">>" Then
		GUICtrlSetData($NormalButton[15], "<<")
		WinMove($Form, "", Default, Default, Default, 500, 1)
		_GUICtrlStatusBar_Resize($Statusbar)
		GUICtrlSetState($Label[0],$GUI_SHOW)
	EndIf
	If $FILE = "" Then $FILE = FileOpenDialog("Open...", "", "Video Files (*.wmv; *.avi)")
	Engine_LoadFile($FILE, GUICtrlGetHandle($Label[0]))
	Engine_StartPlayback()
	_PathSplit($FILE, $sDrive, $sDir, $sFile, $sExt)
	_GUICtrlStatusBar_SetText($Statusbar, $sFile, 5)
EndFunc ;==>_LoadVideo




Func _SHLV_WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $tInfo, $ItemText  ;$hListView1 = $SHELLLISTVIEWHANDLE
	Local $hListView1 = GUICtrlGetHandle($ExplorerView)
	Local $hListView2 = GUICtrlGetHandle($ListView[0])
	Local $hListView3 = GUICtrlGetHandle($ListView[1])
	Local $hTreeView1 = GUICtrlGetHandle($Treeview[2])
	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hListView1
			;MsgBox(1, "", $iCode)
			Switch $iCode
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					$ItemText = _GUICtrlListView_GetItemText($hListView1, _GUICtrlListView_GetSelectedIndices($hListView1), 0)
					_Browse($ItemText)
				Case $LVN_KEYDOWN
					Local $tagLVKEYDOWN = $tagNMHDR & "; USHORT wVKey; UINT flags;"
					$tNMHDR = DllStructCreate($tagLVKEYDOWN, $ilParam)
					;MsgBox(1, "", DllStructGetData($tNMHDR, "wVKey"))
					Switch DllStructGetData($tNMHDR, "wVKey")
						Case 0x27 ; rechte Pfeiltaste
							$ItemText = _GUICtrlListView_GetItemText($hListView1, _GUICtrlListView_GetSelectedIndices($hListView1), 0)
							_Browse($ItemText)
						Case 0x25 ;linke Pfeiltaste
							Local $slash = StringInStr($DIRECTORY_LOCAL, "\", 1, -2)
							If $slash Then
								$DIRECTORY_LOCAL = StringLeft($DIRECTORY_LOCAL, $slash)
							ElseIf StringRegExp($DIRECTORY_LOCAL, "\A[A-Za-z]:\\\Z") Then
								$DIRECTORY_LOCAL = ""
							EndIf
							_SHLV_PopulateLocalListView($ExplorerView, $DIRECTORY_LOCAL)
							;No return value
					EndSwitch
			EndSwitch
		Case $Statusbar
			Switch $iCode
				Case $NM_CLICK
					$tInfo = DllStructCreate($tagNMMOUSE, $ilParam)
					$hWndFrom = HWnd(DllStructGetData($tInfo, "hWndFrom"))
					$ItemSpec = DllStructGetData($tInfo, "ItemSpec")
					Switch $ItemSpec
						Case 4
							;MsgBox(0, 0, "Klick auf Timer")
						Case 5
							;MsgBox(0, 0, "Klick auf VOL")
							If IsHWnd($hSlider) = 0 Then
								$pos = WinGetPos($Form)
								$hSlider = GUICreate("", 50, 100, $pos[0] + 200, $pos[1] + 250 + 50, $WS_POPUP, $WS_EX_TOPMOST)
								$sSlider = GUICtrlCreateSlider(0, 0, 50, 100, BitOR($TBS_VERT, $TBS_AUTOTICKS, $TBS_BOTH, $TBS_NOTICKS))
								GUICtrlSetData($sSlider, _GUICtrlStatusBar_GetText($Statusbar, 5))
								GUISetState(@SW_SHOW, $hSlider)
								$hSliderStatus = 2
							Else
								GUIDelete($hSlider)
								$hSliderStatus = 0
							EndIf
						Case 6
							;MsgBox(0, 0, "Klick auf BPM")
							If IsHWnd($hSlider) = 0 Then
								$pos = WinGetPos($Form)
								$hSlider = GUICreate("", 50, 100, $pos[0] + 250, $pos[1] + 250 + 50, $WS_POPUP, $WS_EX_TOPMOST)
								$sSlider = GUICtrlCreateSlider(0, 0, 50, 100, BitOR($TBS_VERT, $TBS_AUTOTICKS, $TBS_BOTH, $TBS_NOTICKS))
								GUICtrlSetData(-1, 50)
								;GUICtrlSetData($sSlider, _GUICtrlStatusBar_GetText($StatusBar,5))
								GUISetState(@SW_SHOW, $hSlider)
								$hSliderStatus = 3
							Else
								GUIDelete($hSlider)
								$hSliderStatus = 0
							EndIf
					EndSwitch
			EndSwitch
		Case $hListView2
			Switch $iCode
				Case $NM_DBLCLK
					$Mark = _GUICtrlListView_GetSelectionMark($hListView2)
					_LoadMusic(_GUICtrlListView_GetItemText($hListView2, $Mark, 1) & _GUICtrlListView_GetItemText($hListView2, $Mark))
			EndSwitch
		Case $hListView3
			Switch $iCode
				Case $NM_DBLCLK
					$Mark = _GUICtrlListView_GetSelectionMark($hListView3)
					_LoadVideo(_GUICtrlListView_GetItemText($hListView3, $Mark, 1) & _GUICtrlListView_GetItemText($hListView3, $Mark))
			EndSwitch
		Case $hTreeView1
			Switch $iCode
				case $NM_CLICK 
					_ComputerInfo_DisplayInfo(_ComputerInfo_GetPidFromTreeViewItemHandle(_GUICtrlTreeView_GetSelection($hTreeView1)))
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc ;==>_SHLV_WM_NOTIFY
Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $Form) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc ;==>WM_NCHITTEST
Func WM_PAINT($hWnd, $uMsgm, $wParam, $lParam)
	;_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
	Return 'GUI_RUNDEFMSG'
EndFunc ;==>WM_PAINT
Func WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
    Local $iIDFrom = BitAND($wParam, 0x0000FFFF)
    Local $iCode = BitShift($wParam, 16)
	Local $hCombo = $Combo[6]
    Switch $iIDFrom
        Case $hCombo
            Switch $iCode
                Case $CBN_EDITCHANGE
                    _GUICtrlComboBox_AutoComplete($hCombo)
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc  ;==>WM_COMMAND


Func _DrawLoadingScreen()
	
	_GDIPlus_GraphicsClear($hGfxBuffer, 0xFFFFFFFF)
	;$aPoints[1][0] = 0;Startpunkt bleibt gleich
	If $Mode_Loading = 0 Then $aPoints[1][1] -= 1
	If $Mode_Loading = 1 Then $aPoints[1][1] += 1
	;$aPoints[2][0] = 50;bleibt gleich
	If $Mode_Loading = 0 Then $aPoints[2][1] += 1
	If $Mode_Loading = 1 Then $aPoints[2][1] -= 1
	;$aPoints[3][0] = 100
	If $Mode_Loading = 0 Then $aPoints[3][1] -= 1
	If $Mode_Loading = 1 Then $aPoints[3][1] += 1
	;$aPoints[4][0] = 150
	If $Mode_Loading = 0 Then $aPoints[4][1] += 1
	If $Mode_Loading = 1 Then $aPoints[4][1] -= 1
	;$aPoints[5][0] = 200
	If $Mode_Loading = 0 Then $aPoints[5][1] -= 1
	If $Mode_Loading = 1 Then $aPoints[5][1] += 1
	If $Mode_Loading = 0 Then $aPoints[6][1] += 1
	If $Mode_Loading = 1 Then $aPoints[6][1] -= 1
	For $X = 1 To 6
		If $Mode_Loading = 0 Then $aPoints[$X][0] -= 1
		If $Mode_Loading = 1 Then $aPoints[$X][0] += 1
	Next
	_GDIPlus_GraphicsDrawCurve($hGfxBuffer, $aPoints, $Brush)
	;======================================================================
	;$aPoints[1][0] = 0;Startpunkt bleibt gleich
	If $Mode_Loading = 0 Then $bPoints[1][1] -= 1
	If $Mode_Loading = 1 Then $bPoints[1][1] += 1
	;$bPoints[2][0] = 50;bleibt gleich
	If $Mode_Loading = 0 Then $bPoints[2][1] += 1
	If $Mode_Loading = 1 Then $bPoints[2][1] -= 1
	;$bPoints[3][0] = 100
	If $Mode_Loading = 0 Then $bPoints[3][1] -= 1
	If $Mode_Loading = 1 Then $bPoints[3][1] += 1
	;$bPoints[4][0] = 150
	If $Mode_Loading = 0 Then $bPoints[4][1] += 1
	If $Mode_Loading = 1 Then $bPoints[4][1] -= 1
	;$bPoints[5][0] = 200
	If $Mode_Loading = 0 Then $bPoints[5][1] -= 1
	If $Mode_Loading = 1 Then $bPoints[5][1] += 1
	If $Mode_Loading = 0 Then $bPoints[6][1] += 1
	If $Mode_Loading = 1 Then $bPoints[6][1] -= 1
	For $X = 1 To 6
		If $Mode_Loading = 0 Then $bPoints[$X][0] -= 1
		If $Mode_Loading = 1 Then $bPoints[$X][0] += 1
	Next
	_GDIPlus_GraphicsDrawCurve($hGfxBuffer, $bPoints, $Brush)
	;======================================================================
	;$aPoints[1][0] = 0;Startpunkt bleibt gleich
	If $Mode_Loading = 0 Then $cPoints[1][1] -= 1
	If $Mode_Loading = 1 Then $cPoints[1][1] += 1
	;$cPoints[2][0] = 50;bleibt gleich
	If $Mode_Loading = 0 Then $cPoints[2][1] += 1
	If $Mode_Loading = 1 Then $cPoints[2][1] -= 1
	;$cPoints[3][0] = 100
	If $Mode_Loading = 0 Then $cPoints[3][1] -= 1
	If $Mode_Loading = 1 Then $cPoints[3][1] += 1
	;$cPoints[4][0] = 150
	If $Mode_Loading = 0 Then $cPoints[4][1] += 1
	If $Mode_Loading = 1 Then $cPoints[4][1] -= 1
	;$cPoints[5][0] = 200
	If $Mode_Loading = 0 Then $cPoints[5][1] -= 1
	If $Mode_Loading = 1 Then $cPoints[5][1] += 1
	If $Mode_Loading = 0 Then $cPoints[6][1] += 1
	If $Mode_Loading = 1 Then $cPoints[6][1] -= 1
	For $X = 1 To 6
		If $Mode_Loading = 0 Then $cPoints[$X][0] -= 1
		If $Mode_Loading = 1 Then $cPoints[$X][0] += 1
	Next
	_GDIPlus_GraphicsDrawCurve($hGfxBuffer, $cPoints, $Brush)
	;====================================================================0
	If $aPoints[1][1] = 75 Then $Mode_Loading = 0
	If $aPoints[1][1] = 25 Then $Mode_Loading = 1
	$R = Log($cPoints[6][1]) * 0.1
	$G = Log($cPoints[5][1]) * 0.1
	$R = Log($cPoints[4][1]) * 0.1
	$iRGB = Hex($R) & Hex($G) & Hex($B)
	;_GDIPlus_PenSetColor($Brush,$iRGB)

	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $LoadingText, $hFont, $tLayout, $hFormat)
	;_GDIPlus_GraphicsDrawStringEx($hGfxBuffer, $LoadingText, $hFont, $aInfo[0], $hFormat, $hBrushINT)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
	Return $hBitmap
EndFunc ;==>_DrawLoadingScreen
Func _DrawTextOnLoadingScreen($Text)
	If $Text Then
		ConsoleWrite("$Text: " & $Text & @CRLF)
		$LoadingText = $Text
	EndIf
EndFunc ;==>_DrawTextOnLoadingScreen


Func _Exit()
	IniWrite($TUC_TUCINIDIR, "MUSIC", "Volumen", 100)
	IniWrite($TUC_TUCINIDIR, "SCAN", "TreeView_Var", 1)
	IniWrite($TUC_TUCINIDIR, "SCAN", "TreeView_Var_MAX", 2) ;TEST
	IniWrite($TUC_TUCINIDIR, "VIDEO", "DLLLOADED", 0)
	IniWrite($TUC_TUCINIDIR, "COMPRESSOR", "COMPRESSORINI", @ScriptDir & "\[BIN]\[COMPRESSORS]\COMPRESSORS.ini")
	$array = WinGetCaretPos()
	IniWrite($TUC_TUCINIDIR, "MAIN", "X", $array[0])
	IniWrite($TUC_TUCINIDIR, "MAIN", "Y", $array[1])
	IniWrite($TUC_TUCINIDIR, "MAIN", "Status", $Status)
	IniWrite(@ScriptDir & "\TUC.ini", "MAIN", "FirstStartup", 1)
	
	; GDIPlus freigeben
	;_GDIPlus_BrushDispose($Brush1_Icon)
	;_GDIPlus_BrushDispose($Brush2_Icon)
	;_GDIPlus_GraphicsDispose($hGraphics_Icon)
	;_GDIPlus_BitmapDispose($hBitmap_Icon)
	;_GDIPlus_Shutdown()
	For $X = 1 To _GUICtrlListView_GetItemCount($ListView[0]) - 1
		$Name = _GUICtrlListView_GetItem($ListView[0], $X)
		$Dir = _GUICtrlListView_GetItem($ListView[0], $X, 1)
		IniWrite($TUC_TUCINIDIR, "MusicListview", $Name[3], $Dir[3])
	Next
	For $X = 1 To _GUICtrlListView_GetItemCount($ListView[1]) - 1
		$Name = _GUICtrlListView_GetItem($ListView[1], $X)
		$Dir = _GUICtrlListView_GetItem($ListView[1], $X, 1)
		IniWrite($TUC_TUCINIDIR, "VideoListview", $Name[3], $Dir[3])
	Next
	
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[SIGNATURES]\", "*.ini") ;deleting Dirs
	If IsArray($array) Then
		For $X = 1 To $array[0]
			FileDelete(@ScriptDir & "\[BIN]\[SIGNATURES]\" & $array[$X])
		Next
	EndIf
	If IsArray($array) Then
		$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[SIGNATURES]\", "*.xml") ;deleting Dirs
		For $X = 1 To $array[0]
			FileDelete(@ScriptDir & "\[BIN]\[SIGNATURES]\" & $array[$X])
		Next
	EndIf
	If IsArray($array) Then
		$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[SIGNATURES]\", "*.txt") ;deleting Dirs
		For $X = 1 To $array[0]
			FileDelete(@ScriptDir & "\[BIN]\[SIGNATURES]\" & $array[$X])
		Next
	EndIf
	_BASS_Stop()
	_BASS_Free()
	Exit
EndFunc ;==>_Exit
