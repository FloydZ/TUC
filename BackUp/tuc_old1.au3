#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)

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
#include <ListviewConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <GuiStatusBar.au3>
#include <GDIPlus.au3>
#include <GuiComboBox.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <Color.au3>
#include <Timers.au3>
#include "[INCLUDE]\VisualisierungEngine\Font_1.au3"
#include "[INCLUDE]\VisualisierungEngine\GDIP.au3"
#include "[INCLUDE]\VisualisierungEngine\MemFont.au3"
#include "[INCLUDE]\XMLEngine\_XMLDomWrapper.au3"
#include "[INCLUDE]\MusicEngine\Bass.au3";BASS
#include "[INCLUDE]\MusicEngine\BASSFX.au3";BASS
#include "[INCLUDE]\MusicEngine\BassMix.au3";BASS
#include "[INCLUDE]\MusicEngine\BassExt.au3";BASS
#include "[INCLUDE]\DSEngine\DSEngine.au3";VIDEO
#include "[INCLUDE]\PaintEngine\TIG.au3";TRAY ICON
#include "[INCLUDE]\NewsTickerEngine\NewsTicker.au3"







;;
#region Startup
_GDIPlus_Startup()
Dim $Form2 = GUICreate("Form2", 200, 100, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST)
_WinAPI_SetLayeredWindowAttributes($Form2, 0xFFFFFFFF)
If @error Then MsgBox(0, "", @error)
Dim $hGraphic, $hBitmap, $hGfxBuffer, $R, $B, $G
Dim $Mode_Loading = 0
Dim $InternalMode = 0;um sicherzustellen, dass durch die _DrawLoadingScreenText immer geschrieben wird
Dim $LoadingText = ""
Dim $hGraphic = _GDIPlus_GraphicsCreateFromHWND($Form2)
Dim $hBitmap = _GDIPlus_BitmapCreateFromGraphics(200, 100, $hGraphic)
Dim $hGfxBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
Dim $Brush = _GDIPlus_PenCreate(0xFF00007F, 2)
GUISetState(@SW_SHOW)
Dim $aPoints[7][2]
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
Global $bPoints[7][2]
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
Global $cPoints[7][2]
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
#endregion Startup
#region Vars Constants
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
;=======
Dim Const $TUC_TUCINIDIR = @ScriptDir & "\TUC.ini"
Dim Const $TUC_OPT_SHELL32 = "shell32.dll"
Dim Const $TUC_GUI_FILE_SCAN_PE = @TempDir & "\TUP\ScanEngine\DUMPPE.exe"
Dim $IMAGE_FILE_MACHINE_I386 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_I386.XML"
Dim $IMAGE_FILE_MACHINE_AMD64 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_AMD64.XML"
Dim $IMAGE_FILE_MACHINE_IA64 = @ScriptDir & "\SignatureEngine\IMAGE_FILE_MACHINE_IA64.XML"
Dim $PLATFORM_INDEPENDENT = @ScriptDir & "\SignatureEngine\PLATFORM_INDEPENDENT.XML"
#endregion Vars Constants
#region CTRL
_DrawTextOnLoadingScreen("Loading Variables into MEM...")
Dim $Form, $hSlider, $sSlider, $Statusbar, $ExplorerView, $play, $SEARCHGUI, $SEARCHINPUT, $SEARCHBUTTON
Dim $hTicker ;NewsTocker
;Buttons
Dim $Button[20]
;MEnus
Dim $ExplorerView_Menu
Dim $Treeview_Menu[1];MSN
Dim $Treeview_Menu_Item[1]
Dim $VideoLabel_Menu
Dim $VideoLabel_Menu_Item
;$CheckBoxes
;	-> Stores the ID of the $CheckBoxes
Dim $CheckBoxes[1]
;$ComboBoxes
;	-> Stores the ID of the $ComboBoxes
Dim $ComboBoxes[1]
;CTRL
Dim $Combo[6]
Dim $Checkbox[1]
Dim $MusicButton[5]
Dim $Edit[2]
Dim $Input[5]
Dim $NormalButton[16]
Dim $Treeview[2]
Dim $ListView[2]
Dim $Tab[1], $TabSheet[3]
Dim $Group[6]
Dim $Label[1]
Dim $Radio[1]
Dim $Slider[1]
#endregion CTRL
#region Vars
;Andere Vars

Global $Status = IniRead($TUC_TUCINIDIR,"MAIN","Status",1)
Dim Const $BufferSize = 0x20000;für md5...
Dim $Treeview_VAR = IniRead($TUC_TUCINIDIR,"SCAN","TreeView_Var",1); um zwischen edit treview hinundher zu schalten
Dim $VOL = IniRead($TUC_TUCINIDIR,"MUSIC","Volumen",100)
Dim $TIMER;TImer
Dim $TimerStart = False;Um zu überprüfen ob ein Timer schon gestartet wurde
Dim $MusicHandle ;Musix
Dim $StartupArrayMusic;Um für anfang an Die Listview zu füllen
Dim $StartupArrayVideo;Um für anfang an Die Listview zu füllen
Dim $aaArray; Zwischenspeicher für die SuchMuster
Dim $Signature;Signature Array
Dim $Section;NANA
Dim $hSliderStatus = 0 ; wurde eingeführt weil man via winexist keine 100% angabe über die existenz des GUI bekommt
Dim $FILE
Dim $sDrive, $sDir, $sFile, $sExt
#endregion Vars
#region ExtProgramm
_DrawTextOnLoadingScreen("Checking if it´s first Startup...")
If IniRead($TUC_TUCINIDIR, "MAIN","FirstStartup",0) = 0 Then _FirstStartup()
_DrawTextOnLoadingScreen("Reading .INI")

$StartupArrayMusic = IniReadSection(@ScriptDir & "\TUC.ini", "MusicListview")
$StartupArrayVideo = IniReadSection(@ScriptDir & "\TUC.ini", "VideoListview")

$Signature = _GetSignature(@ScriptDir & "\[INCLUDE]\SignatureEngine\packsig1.ini")

_DrawTextOnLoadingScreen("Loading DSEngine.dll...")
If IniRead($TUC_TUCINIDIR,"VIDEO","DLLLoaded",0) <> "1" Then
	Engine_Startup(@ScriptDir & "\[INCLUDE]\DSEngine\DSEngine_UDF.dll")
	IniWrite($TUC_TUCINIDIR, "VIDEO", "DLLLOADED", 1)
EndIf
_DrawTextOnLoadingScreen("Loading BASS.dll..")
_BASS_STARTUP(@ScriptDir & "\[INCLUDE]\MusicEngine\bass.dll")
_BASS_FX_Startup(@ScriptDir & "\[INCLUDE]\MusicEngine\bass_fx.dll")
_BASS_MIX_Startup(@ScriptDir & "\[INCLUDE]\MusicEngine\bassmix.dll")
_BASS_EXT_Startup(@ScriptDir & "\[INCLUDE]\MusicEngine\bassExt.dll")
_BASS_Init(0, -1, 44100, 0, "")
_BASS_PluginLoad("bass_fx.dll", 0)
_BASS_PluginLoad("bassmix.dll", 0)
_BASS_PluginLoad("bassExt.dll", 0)
_BASS_SetConfig($BASS_CONFIG_UPDATEPERIOD, 10)
_BASS_SetConfig($BASS_CONFIG_BUFFER, 250);DOTO
_DrawTextOnLoadingScreen("Creating TEMP Dir...")
;
;
_DrawTextOnLoadingScreen("Loading External Programms...")
Dim $hImage = _GUIImageList_Create(16, 16, 5, 1, 12)
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
#endregion ExtProgramm
#region WritingIni
#endregion


;TEST
Global $iniDir = IniRead($TUC_TUCINIDIR,"COMPRESSOR","COMPRESSORINI",0)
Global $Compressors = IniReadSectionNames($iniDir)
;TEST
Func _FirstStartup()
	IniWrite(@ScriptDir & "\TUC.ini","MAIN","Volumen",100)
	IniWrite(@ScriptDir & "\TUC.ini","MAIN","TreeView_Var",1)
EndFunc   ;==>_FirstStartup

_DrawTextOnLoadingScreen(0)
GUIDelete($Form2)
_GDIPlus_GraphicsDispose($hGraphic)



#region MainButton
Dim $Form = GUICreate("TUC 0.0.0.1 ", 538, 267, -1, -1, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
GUISetBkColor(0xA9A9A9)
$Group1 = GUICtrlCreateGroup("", -3, 0, 69, 238)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
Dim $y = 8, $z = 0
For $X = 0 To 8
	If $z <> 0 Then $z += 1
	$Button[$z] = GUICtrlCreateButton("", 0, $y, 27, 25, $BS_ICON)
	GUICtrlSetResizing(-1,$GUI_DOCKALL)
	;GUICtrlSetOnEvent(-1,"_MainButtonClicked")
	$z += 1
	$Button[$z] = GUICtrlCreateButton("", 32, $y, 27, 25, $BS_ICON)
	GUICtrlSetResizing(-1,$GUI_DOCKALL)
	;GUICtrlSetOnEvent(-1,"_MainButtonClicked")
	$y += 25
Next
GUICtrlSetImage($Button[0], $TUC_OPT_SHELL32, 16, 0);MAIN
GUICtrlSetImage($Button[1], $TUC_OPT_SHELL32, 281, 0);SCAN
GUICtrlSetImage($Button[2], $TUC_OPT_SHELL32, 224, 0);SCAN
GUICtrlSetImage($Button[3], $TUC_OPT_SHELL32, 20, 0);COMPRESS
GUICtrlSetImage($Button[16], $TUC_OPT_SHELL32, 137, 0);OPT
GUICtrlSetImage($Button[17], $TUC_OPT_SHELL32, 40, 0);GREETS
GUICtrlCreateGroup("", -99, -99, 1, 1)
#endregion MainButton
#region Statusbar
Dim $part[9] = [68, 93, 118, 143, 205, 240, 300,400, -1]
$Statusbar = _GUICtrlStatusBar_Create($Form, $part)
$hStatusbar = GUICtrlGetHandle($Statusbar)
_GUICtrlStatusBar_SetText($Statusbar, "Loaded...")
_GUICtrlStatusBar_SetText($Statusbar, "00:00:00", 4)
_GUICtrlStatusBar_SetText($Statusbar, $VOL, 5)
_GUICtrlStatusBar_SetText($Statusbar, "BPM", 6)
_GUICtrlStatusBar_SetText($Statusbar, "NewsTicker", 7)
$MusicButton[0] = GUICtrlCreateButton(" ", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[0], $TUC_OPT_SHELL32, 246, 0);MAIN
$MusicButton0 = GUICtrlGetHandle($MusicButton[0])
_GUICtrlStatusBar_EmbedControl($Statusbar, 1, $MusicButton0)
$MusicButton[1] = GUICtrlCreateButton("+", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[1], $TUC_OPT_SHELL32, 246, 0);MAIN
$MusicButton1 = GUICtrlGetHandle($MusicButton[1])
_GUICtrlStatusBar_EmbedControl($Statusbar, 2, $MusicButton1)
$MusicButton[2] = GUICtrlCreateButton(">>", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[2], $TUC_OPT_SHELL32, 246, 0);MAIN
$MusicButton2 = GUICtrlGetHandle($MusicButton[2])
_GUICtrlStatusBar_EmbedControl($Statusbar, 3, $MusicButton2)
$Input[0] = GUICtrlCreateCombo("Search...",0,0,-1,-1)
$Input0 = GUICtrlGetHandle($Input[0])
_GUICtrlStatusBar_EmbedControl($Statusbar, 8, $Input0)
;$Slider[0] = GUICtrlCreateSlider(510, 160, 33, 84, BitOR($TBS_VERT, $TBS_AUTOTICKS, $TBS_BOTH, $TBS_NOTICKS))
;GUICtrlSetBkColor(-1, 0xA9A9A9)
;Dim $hGraphics = _GDIPlus_GraphicsCreateFromHWND(GUICtrlGetHandle($Label))
;Dim $hBmpBuffer = _GDIPlus_BitmapCreateFromGraphics(100, 20, $hGraphics)
;Dim $hGfxBuffer = _GDIPlus_ImageGetGraphicsContext($hBmpBuffer)
#endregion Statusbar
#region Main Explorer
Dim $ExplorerView = GUICtrlCreateListView("Name|Datum|Größe", 72, 4, 459, 235)
;GUICtrlSetState(-1,$GUI_HIDE)
$ExplorerView_Menu = GUICtrlCreateContextMenu($ExplorerView)
GUICtrlCreateMenuItem("Delete", $ExplorerView_Menu)
GUICtrlCreateMenuItem("Back", $ExplorerView_Menu)
Dim $SHELLLISTVIEWHANDLE = GUICtrlGetHandle($ExplorerView) ; Get the Handle
GUICtrlSendMsg($ExplorerView, 0x101E, 0, 200)
GUICtrlSendMsg($ExplorerView, 0x101E, 1, 75)
GUICtrlSendMsg($ExplorerView, 0x101E, 2, 50)
GUIRegisterMsg($WM_NOTIFY, "_SHLV_WM_NOTIFY")
_GUICtrlListView_SetImageList($ExplorerView, _GUIImageList_GetSystemImageList(), 1)
Dim $DIRECTORY_LOCAL = "" ; Start with Selection of drives
_SHLV_PopulateLocalListView($SHELLLISTVIEWHANDLE, $DIRECTORY_LOCAL)
#endregion Main Explorer
#region SCAN
$Edit[0] = GUICtrlCreateEdit("", 72, 30, 440, 210, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_HSCROLL, $WS_VSCROLL, $ES_READONLY, $WS_GROUP))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetColor(-1, 0x00FF00)
$font = "Comic Sans MS"
GUICtrlSetFont(-1, 8, "", "", $font, 100)
GUICtrlSetData($Edit[0], "                                                              -=[TUP]=-" & @CRLF & _
		"                                                       (c) by Omasgehstock" & @CRLF)
$Treeview[0] = GUICtrlCreateTreeView(72, 30, 463, 211, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $WS_GROUP))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE)
$Treeview_Menu[0] = GUICtrlCreateContextMenu($Treeview[0])
$Treeview_Menu_Item[0] = GUICtrlCreateMenuItem("Look up on MSDN", $Treeview_Menu[0])
;GUICtrlCreateMenuItem("Back", $Treeview_Menu[0])
$Edit[1] = GUICtrlCreateEdit("Noch nicht Fertig", 72, 30, 233, 211, BitOR($WS_HSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE);SIGN
$Input[1] = GUICtrlCreateInput("", 72, 7, 422, 20, $ES_READONLY)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[0] = GUICtrlCreateButton("...", 457 + 24 + 14, 8, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[1] = GUICtrlCreateButton("<>", 457 + 24 + 14 + 20, 8, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[3] = GUICtrlCreateButton("H", 457 + 24 + 14 + 20, 30, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[4] = GUICtrlCreateButton("E", 457 + 24 + 14 + 20, 50, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[5] = GUICtrlCreateButton("P", 457 + 24 + 14 + 20, 70, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[6] = GUICtrlCreateButton("S", 457 + 24 + 14 + 20, 90, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
#endregion SCAN
#region MusicVideo
$Group[0] = GUICtrlCreateGroup("Convert", 331, 40, 200, 118)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[0] = GUICtrlCreateCombo(".mp3", 339, 416, 65, 25)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[1] = GUICtrlCreateCombo("44100", 339, 440, 65, 25)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[2] = GUICtrlCreateCombo("Bitrate", 339, 464, 65, 25)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[2] = GUICtrlCreateButton("Do", 340, 488, 51, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Tab[0] = GUICtrlCreateTab(67, 5, 440, 244)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
$TabSheet[0] = GUICtrlCreateTabItem("Explorer")
GUICtrlSetState(-1, $GUI_SHOW)
$TabSheet[1] = GUICtrlCreateTabItem("Music")
$ListView[0] = GUICtrlCreateListView("Name|Dir|BPM", 74, 29, 420, 212)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
_GUICtrlListView_SetColumnWidth($ListView[0], 0, 200)
_GUICtrlListView_SetColumnWidth($ListView[0], 1, 0)
_GUICtrlListView_SetColumnWidth($ListView[0], 2, 100)
GUICtrlSetState(-1, $GUI_HIDE)
$TabSheet[2] = GUICtrlCreateTabItem("Video")
$ListView[1] = GUICtrlCreateListView("Name|Dir", 74, 29, 420, 212)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetState(-1, $GUI_HIDE)
$Label[0] = GUICtrlCreateLabel("WEKFJNBÖWKWEFWEFKWBEFKBWELFKBWLEKJFBLJWEBFKLWBEFBBWBWBEFB", 332, 122, 200, 118, $SS_BLACKRECT)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateTabItem("")
;$Input[2] = GUICtrlCreateInput("Search...", 206, 5, 120, 19)
;GUICtrlSetState(-1, $GUI_HIDE)
$VideoLabel_Menu = GUICtrlCreateContextMenu($Label[0])
$VideoLabel_Menu_Item = GUICtrlCreateMenuItem("Load into Media Player", $VideoLabel_Menu)
$NormalButton[12] = GUICtrlCreateButton("S", 457 + 24 + 14 + 20, 30, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[13] = GUICtrlCreateButton("NIX", 457 + 24 + 14 + 20, 50, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[14] = GUICtrlCreateButton("NIX", 457 + 24 + 14 + 20, 70, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[15] = GUICtrlCreateButton(">>", 457 + 24 + 14 + 20, 90, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
;Muss noch verbessert werden
For $X = 1 To $StartupArrayMusic[0][0]
	If FileExists($StartupArrayMusic[$X][1] & $StartupArrayMusic[$X][0]) Then
		$i = _GUICtrlListView_AddItem($ListView[0], $StartupArrayMusic[$X][0])
		_GUICtrlListView_AddSubItem($ListView[0], $i, $StartupArrayMusic[$X][1], 1)
	EndIf
Next
DIm $XX = 0;Als Counter für "_GetBPM_ForListView" damit keine For schleife verwendet wird
;AdlibRegister("_GetBPM_ForListView", 5000)
For $X = 1 To $StartupArrayVideo[0][0]
	If FileExists($StartupArrayVideo[$X][1] & $StartupArrayVideo[$X][0]) Then
		$i = _GUICtrlListView_AddItem($ListView[1], $StartupArrayVideo[$X][0])
		_GUICtrlListView_AddSubItem($ListView[1], $i, $StartupArrayVideo[$X][1], 1)
	EndIf
Next
#endregion MusicVideo
#region Compression
$Group[1] = GUICtrlCreateGroup(" Input File/Folder ", 70, 0, 462, 44)
GUICtrlSetState(-1, $GUI_HIDE)
$Input[3] = GUICtrlCreateInput("", 83, 16, 415, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[9] = GUICtrlCreateButton("...", 503, 13, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[2] = GUICtrlCreateGroup(" Compressor ", 71, 42, 462, 70)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[3] = GUICtrlCreateCombo("Compression", 83, 83, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox[0] = GUICtrlCreateCheckbox("Use it:", 291, 86, 55, 17)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[4] = GUICtrlCreateCombo("PreCompression", 354, 83, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
$Combo[5] = GUICtrlCreateCombo("Action", 83, 58, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[3] = GUICtrlCreateGroup(" Options ", 72, 111, 462, 83)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[4] = GUICtrlCreateGroup(" Output ", 71, 194, 462, 45)
GUICtrlSetState(-1, $GUI_HIDE)
$Input[4] = GUICtrlCreateInput("", 83, 210, 390, 20)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
$NormalButton[10] = GUICtrlCreateButton("...", 475, 207, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[11] = GUICtrlCreateButton("", 503, 207, 25, 25, $BS_ICON);Create
;GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetImage($NormalButton[11], $TUC_OPT_SHELL32, 253, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#endregion Compression
#region Option
$TreeView[1] = GUICtrlCreateTreeView(70, 6, 291, 235, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $WS_GROUP))
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetColor(-1, 0x0000C0)
 _GUICtrlTreeView_SetNormalImageList($TreeView[1], $hImage)

$TreeViewItem_MAIN = _GUICtrlTreeView_Add($TreeView[1], 0, "[MAIN]")
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_MAIN, "Save Position on Exit",2,2)
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_MAIN, "Save Volumen on Exit")
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_MAIN, "Save blabla on Exit")
	
$TreeViewItem_SCAN = _GUICtrlTreeView_Add($TreeView[1], 0,"[SCAN]")
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_SCAN, "Save Position",9,9)
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_SCAN, "Save Scan to File",9,9)
	
$TreeViewItem_MUSIC = _GUICtrlTreeView_Add($TreeView[1], 0,"[MUSIC/VIDEO]")
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_MUSIC, "Save selected Music",10,10)
	_GUICtrlTreeView_AddChild($TreeView[1], $TreeViewItem_MUSIC, "Save selected Videos",11,11)
	
$TreeViewItem_COMPRESS = _GUICtrlTreeView_Add($TreeView[1], 0,"[COMPRESS]")

$Group[5] = GUICtrlCreateGroup("Options", 366, 0, 165, 241)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
#endregion
#region THX
#endregion

#region GDI
Dim $hBrush1 = _GDIPlus_BrushCreateSolid(0xFF00FF00)
Dim $hBrush2 = _GDIPlus_BrushCreateSolid(0xFFFFFAFA)
Dim $hBrush3 = _GDIPlus_BrushCreateSolid(0xAA8888AA)
Dim $hBrush4 = _GDIPlus_BrushCreateSolid(0xFFFF0000)
Dim $hFamily = _GDIPlus_FontFamilyCreate("Arial")
Dim $hFont = _GDIPlus_FontCreate($hFamily, 8, 2)

Global $iVisual = 1
Global $iVisualNext = $iVisual
Global $MusicHandle, $hStream, $aWave[1][1], $iBytes
Global $iWidth = 200
Global $iHeight = 118
Global $aColor1[3] = [0, 0, 0], $aColorStep1[3]
Global $aColor2[3] = [0, 0, 0], $aColorStep2[3]
_SetColor($aColorStep1, $aColor1, 255)
_SetColor($aColorStep1, $aColor1, 255)
_SetColor($aColorStep2, $aColor2, 255)
_SetColor($aColorStep2, $aColor2, 255)
Global $iWaveRes = 100; polygon segments per second
Global Const $PI = 3.14159265358979
Global Const $DegToRad = $PI / 180
Dim $hGraphics = _GDIPlus_GraphicsCreateFromHWND(GUICtrlGetHandle($Label[0]))
Dim $hBmpBuffer = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $hGraphics)
Dim $hGfxBuffer = _GDIPlus_ImageGetGraphicsContext($hBmpBuffer)
_GDIPlus_GraphicsSetSmoothingMode($hGfxBuffer, 2)
_GDIPlus_GraphicsClear($hGfxBuffer, 0xFF000000)
Dim $hBmpTrans = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $hGraphics)
Dim $hGfxTrans = _GDIPlus_ImageGetGraphicsContext($hBmpTrans)
_GDIPlus_GraphicsSetSmoothingMode($hGfxTrans, 2)
_GDIPlus_GraphicsClear($hGfxTrans, 0xFF000000)
Dim $hBmpTrans2 = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $hGraphics)
Dim $hGfxTrans2 = _GDIPlus_ImageGetGraphicsContext($hBmpTrans2)
_GDIPlus_GraphicsSetSmoothingMode($hGfxTrans2, 2)
_GDIPlus_GraphicsClear($hGfxTrans2, 0xFF000000)
Dim $hBmpExt = _GDIPlus_BitmapCreateFromGraphics($iWidth * 3, $iHeight * 3, $hGraphics)
Dim $hGfxExt = _GDIPlus_ImageGetGraphicsContext($hBmpExt)
_GDIPlus_GraphicsSetSmoothingMode($hGfxExt, 2)
_GDIPlus_GraphicsClear($hGfxExt, 0xFF000000)
Dim $hPen1 = _GDIPlus_PenCreate(0xFFFFFF00, 3)
Dim $hPen2 = _GDIPlus_PenCreate(0xFFFFFF00, 3)
Dim $hBrush1 = _GDIPlus_BrushCreateSolid(0xFF888800)
Dim $hBrush2 = _GDIPlus_BrushCreateSolid(0xFF888800)
Dim $hBrushTrans = _GDIPlus_BrushCreateSolid(0x60000000)
Dim $hBrush_WL = _CreateWaveBrush(0xFF00AA00, 0, $iHeight)
Dim $hPen_WL = _CreateWavePen(0xFF00FF00, 0, $iHeight)
Dim $hBrush_WR = _CreateWaveBrush(0xFFAA0000, 0, $iHeight)
Dim $hPen_WR = _CreateWavePen(0xFFFF0000, 0, $iHeight)
Dim $hBrush_FFT = _CreateFFT3DBrush($iWidth, $iHeight)
Dim $hBrushWW = _CreateWaterWaveBrush(0, 0, $iWidth, $iHeight)
Dim $hPath_AutoIt = _CreateAutoItText($hGraphics, $iWidth, $iHeight, 20, $bFont)
Dim $aBounds_AutoIt = _GDIPlus_PathGetWorldBounds($hPath_AutoIt)
Dim $aFFT = _BASS_EXT_CreateFFT(65, 10, 10, $iWidth - 20, $iHeight - 20, 0, True)
Dim $aFFT3D = _BASS_EXT_CreateFFT(50, 0, $iHeight * 0.6, $iWidth, $iHeight * 0.4, 0, True)
Dim $aWater[51]
#endregion GDI
#region Icon
Opt("TrayIconHide", 0)
_TIG_CreateTrayGraph(0, 10)
If @error Then MsgBox(0, "Create", @error)
$Save = TrayCreateItem("Save")
#endregion Icon
#region Menu
#endregion Menu
GUIRegisterMsg($WM_PAINT, "WM_PAINT")
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
;GUISetOnEvent($GUI_EVENT_CLOSE,"_Exit",$Form)
_PrepareVisual($iVisual)
Global $iTimer = TimerInit()


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit()
		Case $Button[0]
			_CreateMain()
			;==============================================================================
		Case $Button[1]
			_CreateScan()
			Case $NormalButton[0]
				$FILE = FileOpenDialog("Select a File", "", "eXecutables (*.exe;*.dll)", 1)
				_SetScan($FILE)
			Case $NormalButton[1]
				If $Treeview_VAR = 1 Then;EDIT
					GUICtrlSetState($Treeview[0], $GUI_SHOW)
					GUICtrlSetState($Edit[0], $GUI_HIDE)
					GUICtrlSetState($Edit[1], $GUI_HIDE)
					$Treeview_VAR = 2
				ElseIf $Treeview_VAR = 2 Then;TREEVIEW ALLG
					GUICtrlSetState($Treeview[0], $GUI_HIDE)
					GUICtrlSetState($Edit[0], $GUI_SHOW)
					GUICtrlSetState($Edit[1], $GUI_HIDE)
					For $X = 3 To 6
						GUICtrlSetState($NormalButton[$X], $GUI_SHOW)
					Next
					$Treeview_VAR = 3
				Else;TREEVIEW SPEZ
					GUICtrlSetState($Edit[1], $GUI_SHOW)
					GUICtrlSetState($Treeview[0], $GUI_HIDE)
					GUICtrlSetState($Edit[0], $GUI_HIDE)
					For $X = 3 To 6
						GUICtrlSetState($NormalButton[$X], $GUI_HIDE)
					Next
					$Treeview_VAR = 1
				EndIf
			;==============================================================================
		Case $Button[2]
			_CreateVideoMusic()
			Case $Tab[0]
				Switch GUICtrlRead ($Tab[0])
					Case 0
						GUICtrlSetState($ListView[0], $GUI_HIDE);Music
						GUICtrlSetState($ListView[1], $GUI_HIDE);Music
						GUICtrlSetState($ExplorerView, $GUI_SHOW)
					Case 1
						GUICtrlSetState($ListView[0], $GUI_SHOW);Music
						GUICtrlSetState($ListView[1], $GUI_HIDE);Music
						GUICtrlSetState($ExplorerView, $GUI_HIDE)
					Case 2
						GUICtrlSetState($ListView[0], $GUI_HIDE);Music
						GUICtrlSetState($ListView[1], $GUI_SHOW);Music
						GUICtrlSetState($ExplorerView, $GUI_HIDE)
				EndSwitch
			Case $NormalButton[12]
				_SearchForFilesGUI()
			Case $NormalButton[15]
				If GUICtrlRead($NormalButton[15]) = ">>" Then
					GUICtrlSetData($NormalButton[15], "<<")
					WinMove($Form,"",Default,Default,Default,500,1)
					_GUICtrlStatusBar_Resize($Statusbar)
				Else
					GUICtrlSetData($NormalButton[15], ">>")
					WinMove($Form,"",Default,Default,Default,290,1)
					_GUICtrlStatusBar_Resize($Statusbar)
				EndIf
			;=================================================================================
		Case $Button[3];COMPRESSIOM
			_CreateCompress()
			Case $NormalButton[9];Select a file for Compressiom
				_PrepareCompression()
			Case $NormalButton[10]
				GUICtrlSetData($Input[4], FileSaveDialog("Where you want to save you file", "", "ALL (*.*)"))
			Case $NormalButton[11]
				_Execute_Compression(GUICtrlRead($Input[3]), GUICtrlRead($Input[4]))
			Case $Checkbox[0]
				If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then
					GUICtrlSetState($Combo[4], $GUI_ENABLE)
				Else
					GUICtrlSetState($Combo[4], $GUI_DISABLE)
				EndIf
			Case $Combo[5]
				If GUICtrlRead($Combo[5]) = "Archive Compression " Then
					_Set_Archiver_for_Compression()
				EndIf
			Case $Combo[3]
				If _GUICtrlComboBox_GetCurSel($Combo[3]) <> 0 Then _Set_Controls_For_Compression(_GUICtrlComboBox_GetCurSel($Combo[3]))
				;=============================================================================
		Case $Button[16]
			_CreateOption()	
	EndSwitch
	;=====================================================================================================
WEnd



#cs Test Zwecke
	While 1
	;ConsoleWrite("hallo")
	$nMsg = GUIGetMsg()
	Switch $nMsg
	Case $GUI_EVENT_CLOSE
	_Exit()
	EndSwitch
	;_ButtonLoop($nMsg)
	;Sleep(10)
	WEnd
#ce


Func _DeleteCTRL()
	GUICtrlSetState($ExplorerView, $GUI_HIDE);MAIN
	GUICtrlSetState($Edit[0], $GUI_HIDE);ScanLoop
	GUICtrlSetState($Input[1], $GUI_HIDE);ScanLoop
	GUICtrlSetState($NormalButton[0], $GUI_HIDE);ScanLoop
	GUICtrlSetState($NormalButton[1], $GUI_HIDE);ScanLoop
	GUICtrlSetState($Treeview[0], $GUI_HIDE);ScanLoop
	GUICtrlSetState($Edit[1], $GUI_HIDE);ScanLoop
	For $X = 3 To 6
		GUICtrlSetState($NormalButton[$X], $GUI_HIDE)
	Next
	GUICtrlSetState($Group[0], $GUI_HIDE);Music
	GUICtrlSetState($Combo[0], $GUI_HIDE);Music
	GUICtrlSetState($Combo[1], $GUI_HIDE);Music
	GUICtrlSetState($Combo[2], $GUI_HIDE);Music
	GUICtrlSetState($NormalButton[2], $GUI_HIDE);Music
	GUICtrlSetState($Tab[0], $GUI_HIDE);Music
	GUICtrlSetState($Label[0], $GUI_HIDE);Music
	GUICtrlSetState($ListView[0], $GUI_HIDE);Music
	GUICtrlSetState($ListView[1], $GUI_HIDE);Music
	GUICtrlSetState($Input[2], $GUI_HIDE);Music
	GUICtrlSetState($NormalButton[12], $GUI_HIDE);Music
	GUICtrlSetState($NormalButton[13], $GUI_HIDE);Music
	GUICtrlSetState($NormalButton[14], $GUI_HIDE);Music
	GUICtrlSetState($NormalButton[15], $GUI_HIDE);Music
	
	GUICtrlSetState($Group[1], $GUI_HIDE);Compress
	GUICtrlSetState($Input[3], $GUI_HIDE);Compress
	GUICtrlSetState($NormalButton[9], $GUI_HIDE);Compress
	GUICtrlSetState($Group[2], $GUI_HIDE);Compress
	GUICtrlSetState($Combo[3], $GUI_HIDE);Compress
	GUICtrlSetState($Checkbox[0], $GUI_HIDE);Compress
	GUICtrlSetState($Combo[4], $GUI_HIDE);Compress
	GUICtrlSetState($Combo[5], $GUI_HIDE);Compress
	GUICtrlSetState($Group[3], $GUI_HIDE);Compress
	GUICtrlSetState($Group[4], $GUI_HIDE);Compress
	GUICtrlSetState($Input[4], $GUI_HIDE);Compress
	GUICtrlSetState($NormalButton[10], $GUI_HIDE);Compress
	GUICtrlSetState($NormalButton[11], $GUI_HIDE);Compress
	
	GUICtrlSetState($TreeView[1], $GUI_HIDE);Option
	GUICtrlSetState($Group[5], $GUI_HIDE);Optio 
	
	;For $x = 0 to UBound($Radio)
	;	GUICtrlSetState($Radio[$x], $GUI_HIDE);Compress
	;Next
EndFunc   ;==>_DeleteCTRL
Func _ButtonLoop(ByRef $nMsg);Momentan net ausgeführt
	_Set_Icon()
	;_Set_Bar($MusicHandle, "NAme")
	Switch $hSliderStatus
		Case 0 ;NOT
			;_BASS_StreamFree($BPMHandle)
		Case 1;TIME
		Case 2;VOL
			_BASS_ChannelSetVolume($MusicHandle, GUICtrlRead($sSlider))
			_GUICtrlStatusBar_SetText($Statusbar, GUICtrlRead($sSlider), 5)
		Case 3;Pitch
			$Text = _GUICtrlStatusBar_GetText($Statusbar, 6)
			_GUICtrlStatusBar_SetText($Statusbar, $Text + GUICtrlRead($sSlider) - 50, 6)
	EndSwitch
	;_DrawMusicBox($hGraphics, $MusicHandle, _BASS_ChannelGetLength($MusicHandle,$BASS_POS_BYTE), 100, 20, 1)
	Switch $nMsg
		Case $Button[0]
			_CreateMain()
		Case $Button[1]
			_CreateScan()
		Case $Button[2]
			_CreateVideoMusic()
		Case $Button[3]
			_CreateCompress()
		Case $Button[4]
			_LoadMusic()
		Case $SEARCHBUTTON
			If $SEARCHINPUT Then
				_SearchText(GUICtrlRead($Edit[0]), GUICtrlRead($SEARCHINPUT))
				GUIDelete($SEARCHGUI)
			EndIf
	EndSwitch
EndFunc   ;==>_ButtonLoop



Func _RunWait($sFilename, $sWorkingdir = "", $sFlag = "", $iIOFlag = "", $iTimeOut = 0)
	Local $aReturn[2]
	Local $pid = Run($sFilename, $sWorkingdir, $sFlag, $iIOFlag)
	If @error Then Return SetError(1, @error, 0)
	Local $iPWC = ProcessWaitClose($pid, $iTimeOut)
	$aReturn[0] = StdoutRead($pid)
	$aReturn[1] = StderrRead($pid)
	If Not $iPWC Then
		ProcessClose($pid)
		SetError(2)
	EndIf
	Return $aReturn
EndFunc   ;==>_RunWait



;-----------------------------------------------------------------------------------------------------------------------
;	Function		_LV_Search($LV, $What2Find [, $CaseSens=True [, $Partial=False]])
;	Description		search a term in every item and subitem of a given ListView
;	Parameter		$LV				ListView -ID
;					$What2Find		Search term
;					$CaseSens       Casesensitivity True (default) or False
;					$Partial        Partialsearch, Casesens will set to False also if given True
;	Return			Success			Array[0] = LV-Index
;									Array[1] = SubItem-Index
;					Failure			Return -1 and set @error : 	1 - ListView is empty
;																2 - $What2Find was not found
;	Requirements	#include <GuiListView.au3>
;	Author			BugFix (bugfix@autoit.de)
;-----------------------------------------------------------------------------------------------------------------------
Func _LV_Search($LV, $What2Find, $CaseSens = True, $Partial = False)
	$count = _GUICtrlListView_GetItemCount($LV)
	Local $aOut[2] = [-1, 0]
	If $count < 1 Then
		SetError(1)
		Return -1
	EndIf
	If $Partial Then $CaseSens = False
	$countSub = _GUICtrlListView_GetColumnCount($LV)
	For $i = 0 To $count - 1
		For $k = 0 To $countSub - 1
			If $CaseSens Then
				If _GUICtrlListView_GetItemText($LV, $i, $k) == $What2Find Then
					$aOut[0] = $i
					$aOut[1] = $k
					Return $aOut
				EndIf
			Else
				If Not $Partial Then
					If _GUICtrlListView_GetItemText($LV, $i, $k) = $What2Find Then
						$aOut[0] = $i
						$aOut[1] = $k
						Return $aOut
					EndIf
				Else
					If StringInStr(_GUICtrlListView_GetItemText($LV, $i, $k), $What2Find, 1) Then
						$aOut[0] = $i
						$aOut[1] = $k
						Return $aOut
					EndIf
				EndIf
			EndIf
		Next
	Next
	SetError(2)
	Return -1
EndFunc   ;==>_LV_Search
; #FUNCTION# =========================================================================================================
; Name...........: _StringSize
; Description ...: Returns size of rectangle required to display string - maximum permitted width can be chosen
; Syntax ........: _StringSize($sText[, $iSize[, $iWeight[, $iAttrib[, $sName[, $iWidth]]]]])
; Parameters ....: $sText   - String to display
;                  $iSize   - [optional] Font size in points - default AutoIt GUI default
;                  $iWeight - [optional] Font weight (400 = normal) - default AutoIt GUI default
;                  $iAttrib - [optional] Font attribute (0-Normal, 2-Italic, 4-Underline, 8 Strike - default AutoIt
;                  $sName   - [optional] Font name - default AutoIt GUI default
;                  $iWidth  - [optional] Width of rectangle - default is unwrapped width of string
; Requirement(s) : v3.2.12.1 or higher
; Return values .: Success - Returns array with details of rectangle required for text:
;                  |$array[0] = String formatted with @CRLF at required wrap points
;                  |$array[1] = Height of single line in selected font
;                  |$array[2] = Width of rectangle required to hold formatted string
;                  |$array[3] = Height of rectangle required to hold formatted string
;                  Failure - Returns 0 and sets @error:
;                  |1 - Incorrect parameter type (@extended = parameter index)
;                  |2 - Failure to create GUI to test label size
;                  |3 - DLL call error - extended set to indicate which
;                  |4 - Font too large for chosen width - longest word will not fit
; Author ........: Melba23
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
;=====================================================================================================================
Func _StringSize($sText, $iSize = Default, $iWeight = Default, $iAttrib = Default, $sName = "", $iWidth = 0)
	Local $avSize_Info[4], $aRet, $iLine_Width = 0, $iLast_Word, $iWrap_Count
	Local $hLabel_Handle, $hFont, $hDC, $oFont, $tSize = DllStructCreate("int X;int Y")
	; Check parameters are correct type
	If Not IsString($sText) Then Return SetError(1, 1, 0)
	If Not IsNumber($iSize) And $iSize <> Default Then Return SetError(1, 2, 0)
	If Not IsInt($iWeight) And $iWeight <> Default Then Return SetError(1, 3, 0)
	If Not IsInt($iAttrib) And $iAttrib <> Default Then Return SetError(1, 4, 0)
	If Not IsString($sName) Then Return SetError(1, 5, 0)
	If Not IsNumber($iWidth) Then Return SetError(1, 6, 0)
	; Create GUI to contain test labels, set to required font parameters
	Local $hGUI = GUICreate("", 1200, 500, 10, 10)
	If $hGUI = 0 Then Return SetError(2, 0, 0)
	GUISetFont($iSize, $iWeight, $iAttrib, $sName)
	; Store unwrapped text
	$avSize_Info[0] = $sText
	; Ensure EoL is @CRLF and break text into lines
	If StringInStr($sText, @CRLF) = 0 Then $sText = StringRegExpReplace($sText, "[\x0a|\x0d]", @CRLF)
	Local $asLines = StringSplit($sText, @CRLF, 1)
	; Draw label with unwrapped lines to check on max width
	Local $hText_Label = GUICtrlCreateLabel($sText, 10, 10)
	Local $aiPos = ControlGetPos($hGUI, "", $hText_Label)
	GUISetState(@SW_HIDE)
	GUICtrlDelete($hText_Label)
	; Store line height for this font size after removing label padding (always 8)
	$avSize_Info[1] = ($aiPos[3] - 8) / $asLines[0]
	; Store width and height of this label
	$avSize_Info[2] = $aiPos[2]
	$avSize_Info[3] = $aiPos[3] - 4 ; Reduce margin
	; Check if wrapping is required
	If $aiPos[2] > $iWidth And $iWidth > 0 Then
		; Set returned text element to null
		$avSize_Info[0] = ""
		; Set width element to max allowed
		$avSize_Info[2] = $iWidth
		; Set line count to zero
		Local $iLine_Count = 0
		; Take each line in turn
		For $j = 1 To $asLines[0]
			; Size this line unwrapped
			$hText_Label = GUICtrlCreateLabel($asLines[$j], 10, 10)
			$aiPos = ControlGetPos($hGUI, "", $hText_Label)
			GUICtrlDelete($hText_Label)
			; Check wrap status
			If $aiPos[2] < $iWidth Then
				; No wrap needed so count line and store
				$iLine_Count += 1
				$avSize_Info[0] &= $asLines[$j] & @CRLF
			Else
				; Wrap needed so need to count wrapped lines
				; Create label to hold line as it grows
				$hText_Label = GUICtrlCreateLabel("", 0, 0)
				; Initialise Point32 method
				$hLabel_Handle = ControlGetHandle($hGUI, "", $hText_Label)
				; Get DC with selected font
				$aRet = DllCall("User32.dll", "hwnd", "GetDC", "hwnd", $hLabel_Handle)
				If @error Or $aRet[0] = 0 Then Return SetError(3, 1, 0)
				$hDC = $aRet[0]
				$aRet = DllCall("user32.dll", "lparam", "SendMessage", "hwnd", $hLabel_Handle, "int", 0x0031, "wparam", 0, "lparam", 0) ; $WM_GetFont
				If @error Or $aRet[0] = 0 Then Return SetError(3, _StringSize_Error(2, $hLabel_Handle, $hDC, $hGUI), 0)
				$hFont = $aRet[0]
				$aRet = DllCall("GDI32.dll", "hwnd", "SelectObject", "hwnd", $hDC, "hwnd", $hFont)
				If @error Or $aRet[0] = 0 Then Return SetError(3, _StringSize_Error(3, $hLabel_Handle, $hDC, $hGUI), 0)
				$oFont = $aRet[0]
				; Zero counter
				$iWrap_Count = 0
				While 1
					; Set line width to 0
					$iLine_Width = 0
					; Initialise pointer for end of word
					$iLast_Word = 0
					For $i = 1 To StringLen($asLines[$j])
						; Is this just past a word ending?
						If StringMid($asLines[$j], $i, 1) = " " Then $iLast_Word = $i - 1
						; Increase line by one character
						Local $sTest_Line = StringMid($asLines[$j], 1, $i)
						; Place line in label
						GUICtrlSetData($hText_Label, $sTest_Line)
						; Get line length into size structure
						$iSize = StringLen($sTest_Line)
						DllCall("GDI32.dll", "int", "GetTextExtentPoint32", "hwnd", $hDC, "str", $sTest_Line, "int", $iSize, "ptr", DllStructGetPtr($tSize))
						If @error Then Return SetError(3, _StringSize_Error(4, $hLabel_Handle, $hDC, $hGUI), 0)
						$iLine_Width = DllStructGetData($tSize, "X")
						; If too long exit the loop
						If $iLine_Width >= $iWidth - Int($iSize / 2) Then ExitLoop
					Next
					; End of the line of text?
					If $i > StringLen($asLines[$j]) Then
						; Yes, so add final line to count
						$iWrap_Count += 1
						; Store line
						$avSize_Info[0] &= $sTest_Line & @CRLF
						ExitLoop
					Else
						; No, but add line just completed to count
						$iWrap_Count += 1
						; Check at least 1 word completed or return error
						If $iLast_Word = 0 Then Return SetError(4, _StringSize_Error(0, $hLabel_Handle, $hDC, $hGUI), 0)
						; Store line up to end of last word
						$avSize_Info[0] &= StringLeft($sTest_Line, $iLast_Word) & @CRLF
						; Strip string to point reached
						$asLines[$j] = StringTrimLeft($asLines[$j], $iLast_Word)
						; Trim leading whitespace
						$asLines[$j] = StringStripWS($asLines[$j], 1)
						; Repeat with remaining characters in line
					EndIf
				WEnd
				; Add the number of wrapped lines to the count
				$iLine_Count += $iWrap_Count
				; Clean up
				DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $hLabel_Handle, "hwnd", $hDC)
				If @error Then Return SetError(3, _StringSize_Error(5, $hLabel_Handle, $hDC, $hGUI), 0)
				GUICtrlDelete($hText_Label)
			EndIf
		Next
		; Convert lines to pixels and add reduced margin
		$avSize_Info[3] = ($iLine_Count * $avSize_Info[1]) + 4
	EndIf
	; Clean up
	GUIDelete($hGUI)
	; Return array
	Return $avSize_Info
EndFunc   ;==>_StringSize
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _StringSize_Error
; Description ...: Returns from error condition after DC and GUI clear up
; Syntax ........: _StringSize_Error($iExtended, $hLabel_Handle, $hDC, $hGUI)
; Parameters ....: $iExtended - required extended value to return
;                  $hLabel_Handle, $hDC, $hGUI - variables as set in _StringSize function
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _StringSize
; ===============================================================================================================================
Func _StringSize_Error($iExtended, $hLabel_Handle, $hDC, $hGUI)
	; Release DC if created
	DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $hLabel_Handle, "hwnd", $hDC)
	; Delete GUI
	GUIDelete($hGUI)
	; Return with extended set
	Return $iExtended
EndFunc   ;==>_StringSize_Error




Func _CheckIfItunesInstalled()
	Return RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Apple Computer, Inc.\Itunes", "iTunesDefault")
EndFunc   ;==>_CheckIfItunesInstalled
Func _CheckIfItunesWindowsIsOpenAndStop()
	If WinExists("iTunes") = 1 Then
		$iTunesApp = ObjCreate("iTunes.Application")
		$iTunesApp.PlayPause
	EndIf
EndFunc






Func _SetScan($IntFile)
	If $FILE = "" Then Return 0
	_GUICtrlTreeView_DeleteAll($Treeview[0])
	;_DISASM($IntFile)
	_PopulateMiscTreeView($Treeview[0], $IntFile)
	GUICtrlSetData($Input[1], $IntFile)
EndFunc   ;==>_SetScan
Func _Set_Bar($MusicHandle, $Name)
	If Not $MusicHandle Then Return -1
	$pos = Round( _BASS_ChannelBytes2Seconds($MusicHandle, _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)) / 60, 2)
	;ConsoleWrite("$Pos: " & $Pos & @LF
	_GUICtrlStatusBar_SetText($Statusbar, $pos, 4)
EndFunc   ;==>_Set_Bar
Func _Set_Icon()
	Local $Color
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $values[2]
	$values[0] = (_Bass_LoWord($iLong) / 32768) * 16
	$values[1] = (_Bass_HiWord($iLong) / 32768) * 16
	_TIG_SetBarColor(0xFF00ACFF)
	_TIG_UpdateTrayGraph($values[0])
	_TIG_SetBarColor(0xFF00FF00)
	_TIG_UpdateTrayGraph($values[1])
EndFunc   ;==>_Set_Icon





Func _GetBPM_ForListView()
		$FILE = $StartupArrayMusic[$XX][1] & $StartupArrayMusic[$X][0]
		$BPMHandle = _BASS_StreamCreateFile(False, $FILE, 0, 0, $BASS_STREAM_DECODE)
		$iBytes = _BASS_ChannelGetLength($BPMHandle, $BASS_POS_BYTE)
		$iLength = _BASS_ChannelBytes2Seconds($BPMHandle, $iBytes)
		$BPM = _BASS_FX_BPM_DecodeGet($BPMHandle, 0, $iLength, 0, 0)
		_BASS_StreamFree($BPMHandle)
		ConsoleWrite("$File: " & $FILE & " $iLength:" & $iLength & " $BPM:" & $BPM & " XX:" & $XX & " _GUICtrlListView_GetItemCount($ListView[0])" & _GUICtrlListView_GetItemCount($ListView[0] ) & @LF)
		_GUICtrlListView_AddSubItem($ListView[0], $XX, $BPM, 2)
		If $XX = _GUICtrlListView_GetItemCount($ListView[0]) Then 
			AdlibUnRegister("_GetBPM_ForListView")
			$XX = 0
		EndIf
		 $XX += 1
EndFunc   ;==>_GetBPM_ForListView
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
EndFunc   ;==>_GetSignature




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
	$aWave = _BASS_EXT_ChannelGetWaveformDecode($MusicHandle, $iLength * $iWaveRes, $iHeight * 0.9, 0, $iLength, $iWaveRes, "_WaveformGetProc")
	$BPMHandle = _BASS_StreamCreateFile(False, $FILE, 0, 0, $BASS_STREAM_DECODE)
	$BPM = _BASS_FX_BPM_DecodeGet($BPMHandle, 0, $iLength, 0, 0)
	_BASS_StreamFree($BPMHandle)
	_GUICtrlStatusBar_SetText($Statusbar, "BPM: " & Round($BPM, 2), 6)
EndFunc   ;==>_LoadMusic
Func _LoadVideo($FILE = "")
	If $FILE = "" Then $FILE = FileOpenDialog("Open...", "", "Video Files (*.wmv; *.avi)")
	Engine_LoadFile($FILE, GUICtrlGetHandle($Label[0]))
	Engine_StartPlayback()
	_PathSplit($FILE, $sDrive, $sDir, $sFile, $sExt)
	_GUICtrlStatusBar_SetText($Statusbar, $sFile, 5)
EndFunc   ;==>_LoadVideo



Func _SearchForFilesGUI()
$OKBottomDlg = GUICreate("Dialog", 312, 144, 505, 319)
GUISetIcon("D:\003.ico")
$GroupBox1 = GUICtrlCreateGroup(" Search ", 8, 1, 297, 107)
$Label1 = GUICtrlCreateLabel("Muster:", 20, 22, 39, 17)
$Input1 = GUICtrlCreateInput("*.mp3;*.m4a", 60, 19, 235, 21)
$Label2 = GUICtrlCreateLabel("Where:", 20, 51, 39, 17)
$Input2 = GUICtrlCreateInput("C:", 60, 48, 201, 21)
$Button3 = GUICtrlCreateButton("...", 266, 48, 25, 25, $WS_GROUP)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button1 = GUICtrlCreateButton("&OK", 230, 112, 75, 25, $WS_GROUP)
$Button2 = GUICtrlCreateButton("&Cancel", 142, 112, 75, 25, $WS_GROUP)
$Label3 = GUICtrlCreateLabel("Achtung, PC-Last ", 10, 117, 90, 17)
GUISetState(@SW_SHOW)
While 1
$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button3
			GUICtrlSetData($Input2, FileSelectFolder("Select a Folder", "", 7))
		Case $Button1
			Dim $Pattern = GUICtrlRead($Input1)
			Dim $len = StringLen($Pattern)
			Dim $oldx = 1
			Dim $aaArray[2]
			For $x = 0 to $len
				$f = StringMid($Pattern, $x ,1)
				If $f = ";" Then
					;ConsoleWrite("$x: " & $x & " $oldx: " & $oldx & @lf)
					_ArrayAdd($aaArray,StringMid($Pattern,$oldx,$x-$oldx))
					$oldx = $x
				EndIf
				If $x = $len Then _ArrayAdd($aaArray, StringMid($Pattern, $oldx+1))
			Next
				$aaArray[0] = GUICtrlRead($Input2)
				$aaArray[1] = FileFindFirstFile($aaArray[0] & "\*.*")
				If @error Then MsgBox(0,"ERROR", @error)
				;MsgBox(0,$aaArray[1],$aaArray[2])
			;	_ArrayDisplay($aaArray)
			AdlibRegister("_SearchForFiles")
EndSwitch
WEnd
EndFunc
Func _SearchForFiles()
; $aaArray[0] = SuchPfad
; $aaArray[1] = SuchHandle
; $aaArray[n] = SuchKriterium
$Found = FileFindNextFile($aaArray[1])
If @error Then AdlibUnRegister("_SearchForFiles")
For $x = 2 to UBound($aaArray) - 1
	;ConsoleWrite("$aaArray[$x]: " & $aaArray[$x] & @lf )
	;ConsoleWrite("$Found: " & $Found & @lf )
	If StringRight($Found,4) = $aaArray[$x] then
		ConsoleWrite("$Found: " & $Found & @lf )
	EndIf
Next
EndFunc




Func _PrepareCompression()
	$FILE = FileOpenDialog("Select a File", "", "ALL (*.*)", 1 + 2)
	If $FILE Then
		GUICtrlSetData($Input[3], $FILE)
		GUICtrlSetState($Combo[3], $GUI_ENABLE)
		GUICtrlSetState($Combo[5], $GUI_ENABLE)
		;GUICtrlSetData($Combo[5],"Action","Action")
		Switch StringRight($FILE, 4)
			Case ".exe" Or ".dll"
				GUICtrlSetData($Combo[5], "PE Compression |Archive Compression ", "Action")
			Case ".jpg" Or ".bmp" Or ".ico"
				GUICtrlSetData($Combo[5], "Picture Compression (Lossless)|Picture Compression (Lossy) |Archive Compression ", "Action")
			Case ".mp3" Or ".m4a" Or ".wmp"
				GUICtrlSetData($Combo[5], "Music Compression | Convert |Archive Compression ", "Action")
			Case ".rar" Or ".7z" Or ".zip"
				GUICtrlSetData($Combo[5], "Decompress |Optimize |Convert ", "Action")
		EndSwitch
	EndIf
EndFunc   ;==>_PrepareCompression
Func _Set_Archiver_for_Compression()
	;$iniDir
	;	-> Stores the Name of the Ini file
	;$Compressors
	;	-> Stores the Name of the compressors.
	$String = ""
	For $X = 1 To $Compressors[0]
		$String &= $Compressors[$X] & " |"
	Next
	GUICtrlSetData($Combo[3], $String)
EndFunc   ;==>_Set_Archiver_for_Compression
Func _Set_Controls_For_Compression($NR)
	;ConsoleWrite("0")
	;$iniDir
	;	-> Stores the Namecof the Ini file
	;$Compressors
	;	-> Stores the Name of the compressors.
	;$NR
	;	-> Stores the Current selection of the user of the combo box
	;	-> Used to find the Compressor in the ini
	;ConsoleWrite("$NR = " & $NR & @LF)
	;Section
	;	-> Stores the Section Values zu dem passenden Compressor
	$Section = IniReadSection($iniDir, $Compressors[$NR])
	;_ArrayDisplay($Section)
	;$Mode
	;	-> Stores the Mode of the type of the compressor
	;	-> 1 = Only Comboboxes Gut um Ranges darzustellen
	;	-> 2 = für beides also Checkboxes u  Comboboxes
	;	-> 3 = für komplexer sachen kommt nocht
	;$Mode = $Section[8][1]
	;MsgBox(0,"MODE", $Mode)
	;MsgBox(0,"UBound($CheckBoxes)",UBound($CheckBoxes))
	;_ArrayDisplay($CheckBoxes)
	For $X = 0 To UBound($CheckBoxes) - 1
		GUICtrlDelete($CheckBoxes[$X]);Die alten werden gelöscht
		If @error Then Exit
	Next
	For $X = 0 To UBound($ComboBoxes) - 1
		GUICtrlDelete($ComboBoxes[$X])
		If @error Then Exit
	Next
	Switch $Section[8][1];Mode
		Case 1
			;Nothing
		Case 2
			;MAXCTRL
			;	-> Stores the Numbers of the max Ctls, based on the Counter of the ini FIle
			$MAXCTRL = ($Section[0][0] - 8) / 3
			ReDim $CheckBoxes[$MAXCTRL + 1]
			ReDim $ComboBoxes[$MAXCTRL + 1]
			Dim $Width = 100
			Dim $hight = 125
			For $X = 0 To $MAXCTRL - 1;Max
				$CheckBoxes[$X] = GUICtrlCreateCheckbox($Section[9 + (3 * $X)][1], $Width, $hight, 100, 25)
				GUICtrlSetTip(-1, $Section[11 + (3 * $X)][1])
				If @error Then MsgBox(0, "", @error)
				If $Section[11 + (3 * $X)][0] = "Range" & $X + 1 Then
					$max = StringRight($Section[11 + (3 * $X)][1], 1); gets the max
					Dim $String = ""
					For $y = 1 To $max
						$String &= $y & " |"
					Next
					$ComboBoxes[$X] = GUICtrlCreateCombo("", $Width, $hight + 25, 100, 17)
					GUICtrlSetData(-1, $String, "Select a Level")
					GUICtrlSetState($CheckBoxes[$X], $GUI_DISABLE)
					GUICtrlSetState($CheckBoxes[$X], $GUI_CHECKED)
				EndIf
				$Width += 100
				If $Width > 400 Then
					$hight += 40
					$Width = 100
				EndIf
			Next
			;_ArrayDisplay($CheckBoxes,"Secound")
			;_ArrayDisplay($ComboBoxes,"Secound")
	EndSwitch
	;News Ticker
	;$News = $Section[1][0] & ": " & $Section[1][1] & "|" & $Section[2][0] & ": " & $Section[2][1] & "|" & $Section[3][0] & ": " & $Section[3][1] & "|" & $Section[4][0] & ": " & $Section[4][1]
	;	MsgBox(0,"",$News)
	;_GUICtrlNewsTicker_NewsSet($hTicker, $News)
	;_GUICtrlNewsTicker_SetState($hTicker, 1, 1000)
EndFunc   ;==>_Set_Controls_For_Compression
Func _Execute_Compression($Input, $Output)
	If $Input = "" Then Return -1
	If $Output = "" Then Return -1
	Dim $cmd = ""
	For $X = 0 To UBound($CheckBoxes) - 1
		If GUICtrlRead($CheckBoxes[$X]) = $GUI_CHECKED Then
			$cmd &= GUICtrlRead($CheckBoxes[$X], 1)
			If $ComboBoxes[$X] <> "" Then
				$var = GUICtrlRead($ComboBoxes[$X])
				If $var <> "" Then $cmd &= $var 
				$var = 0
			EndIf
			$cmd &= " "
		EndIf
	Next
	$InputPos = StringInStr($Section[6][1], "input")
	$CommandPos = StringInStr($Section[6][1], "commands")
	;ConsoleWrite("$InputPos: " & $InputPos & "  $CommandPos: " &  $CommandPos & @lf)
	If $InputPos > $CommandPos Then
		$cmd = $Section[2][1] & ".exe " & $cmd & " " & $Input
	Else
		$cmd = $Section[2][1] & ".exe " & $Input & " " & $cmd
	EndIf
	
	$return = _7ZIPExtract("", @ScriptDir & "\[BIN]\[COMPRESSORS]\" & $Section[2][1] & ".7z", @ScriptDir & "\[BIN]\[COMPRESSORS]",1,1)
	;MsgBox(0,$return ,@error & @LF & $Section[2][1] & ".7z")
	
	;Run
	
	;Finish => Cleanup
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\","*.exe")
	For $x = 1 To $array[0]
		FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$x])
	Next
	
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\","*.sfx")
	For $x = 1 To $array[0]
		FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$x])
	Next
	
	$array = _SHLV__FileListToArray2(@ScriptDir & "\[BIN]\[COMPRESSORS]\","*.dll")
	For $x = 1 To $array[0]
		If $array[$x] <> "7-zip32.dll" Then FileDelete(@ScriptDir & "\[BIN]\[COMPRESSORS]\" & $array[$x])
	Next
	;_ArrayDisplay($array)
	$array = 0
EndFunc   ;==>_Execute_Compression

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
	
	Local $hDLL_7ZIP = DllOpen(@ScriptDir & "\[BIN]\[COMPRESSORS]\7-zip32.dll");verbessern
	
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
											 "hwnd", $hWnd, _
											 "str", "e " & $sArcName & " " & $iSwitch, _
											 "ptr", DllStructGetPtr($tOutBuffer), _
											 "int", DllStructGetSize($tOutBuffer))

	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZIPExtract



#cs Draw Music
	Func _DrawMusicBox($len )
	If $MusicHandle = "" then Return -1
	_GDIPlus_GraphicsFillRect($hGraphics,0,0,100,20)
	Local $iLong = _BASS_ChannelGetLevel($MusicHandle)
	Local $values[2]
	$values[0] = (_Bass_LoWord($iLong) / 32768) * 100
	$values[1] = (_Bass_HiWord($iLong) / 32768) * 100
	$Pos = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE);Mode einführen
	$Vol = _BASS_ChannelGetVolume($MusicHandle)
	$timeString = Round ( _BASS_ChannelBytes2Seconds($MusicHandle, $Pos),2) & "/" &  Round(_BASS_ChannelBytes2Seconds($MusicHandle, $len) / 60, 2)
	$timeFormat = _GDIPlus_StringFormatCreate()
	$timeLayout = _GDIPlus_RectFCreate(23,2,100,20)
	$timeInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $timeString, $hFont, $timeLayout, $timeFormat)
	$volString = $Vol & "%"
	$volFormat = _GDIPlus_StringFormatCreate(0x0002)
	$volLayout = _GDIPlus_RectFCreate(85,0,15,20)
	$volInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $volString, $hFont, $volLayout, $volFormat)
	_GDIPlus_GraphicsFillRect($hGraphics,0,7.5,$Pos/$Len * 100,5,$hBrush3)
	_GDIPlus_GraphicsFillRect($hGraphics, $Vol,0,Abs($Vol -100) ,20,$hBrush4);Vol
	_GDIPlus_GraphicsFillRect($hGraphics,0,12.5,$values[0],7.5,$hBrush1);Unten
	_GDIPlus_GraphicsFillRect($hGraphics,0,0,$values[1],7.0,$hBrush1);Oben
	_GDIPlus_GraphicsDrawStringEx($hGraphics, $timeString, $hFont, $timeInfo[0], $timeFormat, $hBrush2);Zeit
	_GDIPlus_GraphicsDrawStringEx($hGraphics, $volString, $hFont, $volInfo[0], $volFormat, $hBrush2);Vol
	sleep(5)
	EndFunc
#ce
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
			GUICtrlSetData($hTreeViewExp[$iFuncOrdinal - $iBase], $iFuncOrdinal & "  " & $sFuncName); & "  " & Ptr($iFuncAddress))
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
EndFunc   ;==>_PopulateMiscTreeView
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
EndFunc   ;==>_GetHashes
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
EndFunc   ;==>_EpochDecrypt
Func _SearchText($1, $2, $case = 0)
	GUISetState(@SW_SHOW, $Form)
EndFunc   ;==>_SearchText






Func _DISASM($IntFile, $WHAT = " -disasm ")
	$cmd = $TUC_GUI_FILE_SCAN_PE & $WHAT & $IntFile
	;ConsoleWrite("$Cmd" & $Cmd & " $intFile" & $intFile & @lf)
	$DISASM = _RunWait($cmd, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD);Dissamble
	;$DISASM = StringTrimLeft($DISASM,stringInStr($DISASM,"RawData") + 22)
	;If StringInStr($DISASM,"RawData") <> 0 Then StringTrimLeft($DISASM, 1000)
	;$DISASM = _StringSize($DISASM[0])
	GUICtrlSetData($Edit[0], $DISASM[0]);Dissamble
EndFunc   ;==>_DISASM
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
EndFunc   ;==>_CheckSIG
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
EndFunc   ;==>_Compare




Func _CreateSearch()
	$SEARCHGUI = GUICreate("Search", 227, 70, -1, -1, $WS_DLGFRAME, "", $Form)
	$SEARCHINPUT = GUICtrlCreateInput("Input1", 7, 7, 179, 21)
	$SEARCHBUTTON = GUICtrlCreateButton("OK", 191, 5, 28, 25, 0)
	GUISetState(@SW_SHOW)
EndFunc   ;==>_CreateSearch
Func _CreateMain()
	_DeleteCTRL()
	$Status = 0
	GUICtrlSetPos($ExplorerView, 72, 4, 459, 235)
	GUICtrlSetState($ExplorerView, $GUI_SHOW)
EndFunc   ;==>_CreateMain
Func _CreateScan()
	_DeleteCTRL()
	$Status = 1
	GUICtrlSetState($NormalButton[0], $GUI_SHOW)
	GUICtrlSetState($NormalButton[1], $GUI_SHOW)
	GUICtrlSetState($Input[1], $GUI_SHOW)
	If $Treeview_VAR = 1 Then
		GUICtrlSetState($Treeview[0], $GUI_SHOW)
	ElseIf $Treeview_VAR = 2 Then
		GUICtrlSetState($Edit[0], $GUI_SHOW)
		For $X = 3 To 6
			GUICtrlSetState($NormalButton[$X], $GUI_SHOW)
		Next
	ElseIf $Treeview_VAR = 3 Then
		GUICtrlSetState($Edit[1], $GUI_SHOW)
	EndIf
EndFunc   ;==>_CreateScan
Func _CreateVideoMusic()
	_DeleteCTRL()
	$Status = 2
	;GUICtrlSetState($Group[0],$GUI_SHOW)
	;GUICtrlSetState($Combo[0],$GUI_SHOW)
	;GUICtrlSetState($Combo[1],$GUI_SHOW)
	;GUICtrlSetState($Combo[2],$GUI_SHOW)
	;GUICtrlSetState($NormalButton[2],$GUI_SHOW)
	GUICtrlSetState($Tab[0], $GUI_SHOW)
	;GUICtrlSetState($Label[0],$GUI_SHOW)
	GUICtrlSetState($Input[2], $GUI_SHOW);Music
	GUICtrlSetState($ListView[0], $GUI_SHOW);Music
	GUICtrlSetState($ListView[1], $GUI_SHOW);Music
	GUICtrlSetState($NormalButton[12], $GUI_SHOW);Music
	GUICtrlSetState($NormalButton[13], $GUI_SHOW);Music
	GUICtrlSetState($NormalButton[14], $GUI_SHOW);Music
	GUICtrlSetState($NormalButton[15], $GUI_SHOW);Music
	;GUICtrlSetState($ExplorerView, $GUI_SHOW)
	GUICtrlSetPos($ExplorerView, 74, 29, 420, 212)
EndFunc   ;==>_CreateVideoMusic
Func _CreateCompress()
	_DeleteCTRL()
	$Status = 3
	GUICtrlSetState($Group[1], $GUI_SHOW)
	GUICtrlSetState($Input[3], $GUI_SHOW)
	GUICtrlSetState($NormalButton[9], $GUI_SHOW)
	GUICtrlSetState($Group[2], $GUI_SHOW)
	GUICtrlSetState($Combo[3], $GUI_SHOW)
	GUICtrlSetState($Checkbox[0], $GUI_SHOW)
	GUICtrlSetState($Combo[4], $GUI_SHOW)
	GUICtrlSetState($Combo[5], $GUI_SHOW)
	GUICtrlSetState($Group[3], $GUI_SHOW)
	GUICtrlSetState($Group[4], $GUI_SHOW)
	GUICtrlSetState($Input[4], $GUI_SHOW);Compress
	GUICtrlSetState($NormalButton[10], $GUI_SHOW);Compress
	GUICtrlSetState($NormalButton[11], $GUI_SHOW);Compress
EndFunc   ;==>_CreateCompress
Func _CreateOption()
	_DeleteCTRL()
	$Status = 16
	GUICtrlSetState($TreeView[1], $GUI_SHOW);Option
	GUICtrlSetState($Group[5], $GUI_SHOW);Optio 
EndFunc
Func _CreateOptionCTRLS()

EndFunc


;;
#region Visualisierung
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
	Local $oldX, $oldY
	Local $mult, $X, $y
	Local $hPath = _GDIPlus_PathCreate(0)
	;_GDIPlus_PathAddEllipse($hPath,$iWidth/2-$majorR/2, $iHeight/2-$majorR/2,$majorR,$majorR)
	;_GDIPlus_PathAddEllipse($hPath,$iWidth/2-$majorR/2, $iHeight/2-$majorR/2,$majorR,$majorR)
	For $i = 0 To $steps
		$mult = $angleMuliplier * $theta
		$X = $diff * Sin($mult) + $radiusEffect * Sin($mult * $s) + $iWidth / 2
		$y = $diff * Cos($mult) - $radiusEffect * Cos($mult * $s) + $iHeight / 2
		$theta += $PI * 4 / $steps
		If $oldX Then _GDIPlus_PathAddLine($hPath, $oldX, $oldY, $X, $y)
		$oldX = $X
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
Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $Form) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc   ;==>WM_NCHITTEST
Func WM_PAINT($hWnd, $uMsgm, $wParam, $lParam)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmpBuffer, 0, 0)
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>WM_PAINT
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
			Case -3
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
#endregion Visualisierung
;;
#region _Media Play
Func _Create_VideoGUI($Form, $FILE = "")
	#region ### START Koda GUI section ### FORm=C:\Users\omasgehstock\Desktop\MeineScripts\FinalPacker\DSEngine\MovieEngine.kxf
	If $FILE = "" Then $FILE = FileOpenDialog("Open...", "", "Video Files (*.wmv; *.avi)")
	;If RegRead("HKEY_CURRENT_USER\Software\TUP\VideoEngine", "DllLoaded") <> "1"  Then
	;#include "DSEngine.au3"
	;Engine_Startup("DSEngine_UDF.dll")
	;RegWrite("HKEY_CURRENT_USER\Software\TUP\VideoEngine", "DllLoaded","REG_SZ","1")
	;EndIf
	$hWnd = GUICreate("", 394, 136, 420, 429, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
	$MenuItem1 = GUICtrlCreateMenu("Me&nuItem1")
	$StatusBar1 = _GUICtrlStatusBar_Create($hWnd)
	$Group1 = GUICtrlCreateGroup("", 8, 0, 377, 89)
	GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$Slow = GUICtrlCreateButton("<", 16, 8, 27, 25, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$BPause = GUICtrlCreateButton("Pause", 16, 40, 43, 41, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$back = GUICtrlCreateButton("<<", 72, 48, 25, 25, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$Slider1 = GUICtrlCreateSlider(40, 8, 310, 29, BitOR($TBS_BOTH, $TBS_NOTICKS))
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$Stop = GUICtrlCreateButton("Stop", 104, 48, 27, 25, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$FORward = GUICtrlCreateButton(">>", 136, 48, 27, 25, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	$Fast = GUICtrlCreateButton(">", 352, 8, 27, 25, $WS_GROUP)
	GUICtrlSetResizing(-1, $GUI_DOCKSTATEBAR)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	#endregion ### END Koda GUI section ###
	Global $play = GUICtrlCreateLabel("", 0, 0, 10, 10)
	$Menu = GUICtrlCreateContextMenu($play)
	GUICtrlCreateMenuItem("Fullscreen", $Menu)
	If $FILE <> "" Then
		_LoadMovie($hWnd, $FILE)
		_Resize($hWnd, $StatusBar1)
		_LoadMovie($hWnd, $FILE)
	EndIf
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE)
				GUISetState(@SW_SHOW, $Form)
				ExitLoop
			Case $GUI_EVENT_DROPPED
				_Drop($hWnd, $StatusBar1)
		EndSwitch
		$Len = Engine_GetLength()
		$pos = Engine_GetPosition()
		GUICtrlSetData($Slider1, ($pos / $Len * 100))
	WEnd
EndFunc   ;==>_Create_VideoGUI
Func _Drop($hWnd, $Statusbar)
	$FILE = @GUI_DragFile
	_PathSplit(@GUI_DragFile, $sDrive, $sDir, $sFile, $sExt)
	ConsoleWrite($sExt & @LF)
	_LoadMovie($hWnd, $FILE)
	_Resize($hWnd, $Statusbar)
	_LoadMovie($hWnd, $FILE)
EndFunc   ;==>_Drop
Func _LoadMovie($hWnd, $FILE = "")
	Engine_StopPlayback()
	Engine_LoadFile($FILE, GUICtrlGetHandle($play))
	Engine_StartPlayback()
	$State = 1
	ConsoleWrite(Engine_GetLength() & @LF)
EndFunc   ;==>_LoadMovie
Func _Resize($hWnd, $Statusbar)
	_GUICtrlStatusBar_Destroy($Statusbar)
	$size = Engine_GetVideoSize()
	WinMove($hWnd, "", Default, Default, $size[0], $size[1] + 180)
	;GUICtrlSetPos($Play,0,0, $size[0], $Size[1])
	GUICtrlDelete($play)
	$play = GUICtrlCreateLabel("", 0, 0, $size[0], $size[1])
	$Statusbar = _GUICtrlStatusBar_Create($hWnd)
EndFunc   ;==>_Resize
#endregion ### START Koda GUI section ### FORm=C:\Users\omasgehstock\Desktop\MeineScripts\FinalPacker\DSEngine\MovieEngine.kxf
;;
;;
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
Func _SHLV_WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $tInfo ;$hListView1 = $SHELLLISTVIEWHANDLE
	Local $hListView1 = GUICtrlGetHandle($ExplorerView)
	Local $hListView2 = GUICtrlGetHandle($ListView[0])
	Local $hListView3 = GUICtrlGetHandle($ListView[1])
	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hListView1
			;MsgBox(1, "", $iCode)
			Switch $iCode
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					Local $ItemText = _GUICtrlListView_GetItemText($hListView1, _GUICtrlListView_GetSelectedIndices($hListView1), 0)
					_Browse($ItemText)
				Case $LVN_KEYDOWN
					Local $tagLVKEYDOWN = $tagNMHDR & "; USHORT wVKey; UINT flags;"
					$tNMHDR = DllStructCreate($tagLVKEYDOWN, $ilParam)
					;MsgBox(1, "", DllStructGetData($tNMHDR, "wVKey"))
					Switch DllStructGetData($tNMHDR, "wVKey")
						Case 0x27; rechte Pfeiltaste
							Local $ItemText = _GUICtrlListView_GetItemText($hListView1, _GUICtrlListView_GetSelectedIndices($hListView1), 0)
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
					Local $tInfo = DllStructCreate($tagNMMOUSE, $ilParam)
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
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_SHLV_WM_NOTIFY
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
	$hBrushINT = _GDIPlus_BrushCreateSolid(0xFF00007F)
	$hFormat = _GDIPlus_StringFormatCreate()
	$hFamily = _GDIPlus_FontFamilyCreate("Arial")
	$hFont = _GDIPlus_FontCreate($hFamily, 10, 2)
	$tLayout = _GDIPlus_RectFCreate(0, 83, 200, 100)
	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphic, $LoadingText, $hFont, $tLayout, $hFormat)
	_GDIPlus_GraphicsDrawStringEx($hGfxBuffer, $LoadingText, $hFont, $aInfo[0], $hFormat, $hBrushINT)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
	Return $hBitmap
EndFunc   ;==>_DrawLoadingScreen
Func _DrawTextOnLoadingScreen($Text)
	If $Text Then
		ConsoleWrite("$Text" & $Text & @LF)
		$LoadingText = $Text
	EndIf
EndFunc   ;==>_DrawTextOnLoadingScreen



Func _Exit()
	IniWrite($TUC_TUCINIDIR,"MUSIC","Volumen",100)
	IniWrite($TUC_TUCINIDIR,"SCAN","TreeView_Var",1)
	IniWrite($TUC_TUCINIDIR,"SCAN","TreeView_Var_MAX",2);TEST
	IniWrite($TUC_TUCINIDIR, "VIDEO", "DLLLOADED", 0)
	IniWrite($TUC_TUCINIDIR,"COMPRESSOR","COMPRESSORINI",@ScriptDir & "\[BIN]\[COMPRESSORS]\COMPRESSORS.ini")
	$array = WinGetCaretPos()
	IniWrite($TUC_TUCINIDIR,"MAIN","X",$array[0])
	IniWrite($TUC_TUCINIDIR,"MAIN","Y",$array[1])
	IniWrite($TUC_TUCINIDIR,"MAIN","Status",$Status)
	IniWrite(@ScriptDir & "\TUC.ini","MAIN","FirstStartup",1)

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

	_BASS_Stop()
	_BASS_Free()
	Exit
EndFunc   ;==>_Exit