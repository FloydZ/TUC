;CreateGUI.au3


#Region MainButton
Dim $Form = GUICreate("TUC 0.0.0.1 ", 540, 255, -1, -1, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
GUISetBkColor(0xA9A9A9)
$Group1 = GUICtrlCreateGroup("", -3, -4, 60, 235)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
Dim $y = 4, $z = 0
For $X = 0 To 8
	If $z <> 0 Then $z += 1
	$Button[$z] = GUICtrlCreateButton("", 0, $y, 27, 25, $BS_ICON)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	;GUICtrlSetOnEvent(-1,"_MainButtonClicked")
	$z += 1
	$Button[$z] = GUICtrlCreateButton("", 27, $y, 27, 25, $BS_ICON)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	;GUICtrlSetOnEvent(-1,"_MainButtonClicked")
	$y += 25
Next
GUICtrlSetImage($Button[0], $TUC_OPT_SHELL32, 16, 0) ;MAIN
GUICtrlSetImage($Button[1], $TUC_OPT_SHELL32, 281, 0) ;SCAN
GUICtrlSetImage($Button[2], $TUC_OPT_SHELL32, 224, 0) ;VideoMusic
GUICtrlSetImage($Button[3], $TUC_OPT_SHELL32, 20, 0) ;COMPRESS
GUICtrlSetImage($Button[4], $TUC_OPT_SHELL32, 25, 0) ;CONVERT
GUICtrlSetImage($Button[5], $TUC_OPT_SHELL32, 181, 0) ;ComputerInfo
GUICtrlSetImage($Button[16], $TUC_OPT_SHELL32, 137, 0) ;OPT
GUICtrlSetImage($Button[17], $TUC_OPT_SHELL32, 40, 0) ;GREETS

GUICtrlSetOnEvent($Button[0], "_CreateMain")
GUICtrlSetOnEvent($Button[1], "_CreateScan")
GUICtrlSetOnEvent($Button[2], "_CreateVideoMusic")
GUICtrlSetOnEvent($Button[3], "_CreateCompress")
GUICtrlSetOnEvent($Button[4], "_CreateConvert")
GUICtrlSetOnEvent($Button[5], "_CreateComputerInfo")


GUICtrlSetOnEvent($Button[16], "_CreateOption")

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlCreateGroup("", -99, -99, 1, 1)
#EndRegion MainButton
#Region Statusbar
Dim $part[9] = [68, 93, 118, 143, 205, 240, 300, 400, -1]
$Statusbar = _GUICtrlStatusBar_Create($Form, $part)
$hStatusbar = GUICtrlGetHandle($Statusbar)
_GUICtrlStatusBar_SetText($Statusbar, "Loaded...")
_GUICtrlStatusBar_SetText($Statusbar, "00:00:00", 4)
_GUICtrlStatusBar_SetText($Statusbar, $VOL, 5)
_GUICtrlStatusBar_SetText($Statusbar, "BPM", 6)
_GUICtrlStatusBar_SetText($Statusbar, "NewsTicker", 7)
$MusicButton[0] = GUICtrlCreateButton(" ", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[0], $TUC_OPT_SHELL32, 246, 0) ;MAIN
$MusicButton0 = GUICtrlGetHandle($MusicButton[0])
_GUICtrlStatusBar_EmbedControl($Statusbar, 1, $MusicButton0)
$MusicButton[1] = GUICtrlCreateButton("+", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[1], $TUC_OPT_SHELL32, 245, 0) ;MAIN
$MusicButton1 = GUICtrlGetHandle($MusicButton[1])
_GUICtrlStatusBar_EmbedControl($Statusbar, 2, $MusicButton1)
$MusicButton[2] = GUICtrlCreateButton(">>", 0, 0, -1, -1, $BS_ICON)
GUICtrlSetImage($MusicButton[2], $TUC_OPT_SHELL32, 244, 0) ;MAIN
$MusicButton2 = GUICtrlGetHandle($MusicButton[2])
_GUICtrlStatusBar_EmbedControl($Statusbar, 3, $MusicButton2)
$Input[0] = GUICtrlCreateCombo("Search...", 0, 0, -1, -1)
$Input0 = GUICtrlGetHandle($Input[0])
_GUICtrlStatusBar_EmbedControl($Statusbar, 8, $Input0)
;$Slider[0] = GUICtrlCreateSlider(510, 160, 33, 84, BitOR($TBS_VERT, $TBS_AUTOTICKS, $TBS_BOTH, $TBS_NOTICKS))
;GUICtrlSetBkColor(-1, 0xA9A9A9)
;Dim $hGraphics = _GDIPlus_GraphicsCreateFromHWND(GUICtrlGetHandle($Label))
;Dim $hBmpBuffer = _GDIPlus_BitmapCreateFromGraphics(100, 20, $hGraphics)
;Dim $hGfxBuffer = _GDIPlus_ImageGetGraphicsContext($hBmpBuffer)
#EndRegion Statusbar
#Region Main Explorer
Dim $ExplorerView = GUICtrlCreateListView("Name|Datum|Größe", 60, 0, 481, 233)
;GUICtrlSetState(-1,$GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
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
#EndRegion Main Explorer
#Region SCAN
$Edit[0] = GUICtrlCreateEdit("", 60, 26, 460, 204, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_HSCROLL, $WS_VSCROLL, $ES_READONLY, $WS_GROUP))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetBkColor(-1, 0x000000)
GUICtrlSetColor(-1, 0x00FF00)
$font = "Comic Sans MS"
GUICtrlSetFont(-1, 8, "", "", $font, 100)
GUICtrlSetData($Edit[0], "                                                              -=[TUP]=-" & @CRLF & _
		"                                                       (c) by Omasgehstock" & @CRLF)
$Treeview[0] = GUICtrlCreateTreeView(60, 26, 478, 204, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $WS_GROUP))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE)
$Treeview_Menu[0] = GUICtrlCreateContextMenu($Treeview[0])
$Treeview_Menu_Item[0] = GUICtrlCreateMenuItem("Look up on MSDN", $Treeview_Menu[0])
;GUICtrlCreateMenuItem("Back", $Treeview_Menu[0])
$Edit[1] = GUICtrlCreateEdit("Noch nicht Fertig", 60, 26, 245, 204, BitOR($WS_HSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_HIDE) ;SIGN
$Input[1] = GUICtrlCreateInput("", 60, 3, 430, 20, $ES_READONLY)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[0] = GUICtrlCreateButton("...", 457 + 24 + 10, 1, 25, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "_SetScanWithFileOpenDialog")

$NormalButton[1] = GUICtrlCreateButton("<>", 457 + 24 + 14 + 20, 1, 25, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GuictrlsetonEvent(-1, "_SwitchViews_Scan")

$NormalButton[3] = GUICtrlCreateButton("H", 462 + 24 + 14 + 20, 26, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[4] = GUICtrlCreateButton("E", 462 + 24 + 14 + 20, 46, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[5] = GUICtrlCreateButton("P", 462 + 24 + 14 + 20, 66, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[6] = GUICtrlCreateButton("S", 462 + 24 + 14 + 20, 86, 20, 20)
GUICtrlSetState(-1, $GUI_HIDE)
#EndRegion SCAN
#Region MusicVideo
$Tab[0] = GUICtrlCreateTab(60, 0, 455, 235)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetOnEvent(-1, "_Music_SetTab")

$TabSheet[0] = GUICtrlCreateTabItem("Explorer")
GUICtrlSetState(-1, $GUI_SHOW)

$TabSheet[1] = GUICtrlCreateTabItem("Music")
$ListView[0] = GUICtrlCreateListView("Name|Dir|BPM", 60, 20, 455, 214)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
_GUICtrlListView_SetColumnWidth($ListView[0], 0, 200)
_GUICtrlListView_SetColumnWidth($ListView[0], 1, 0)
_GUICtrlListView_SetColumnWidth($ListView[0], 2, 100)
GUICtrlSetState(-1, $GUI_HIDE)

$TabSheet[2] = GUICtrlCreateTabItem("Video")
$ListView[1] = GUICtrlCreateListView("Name|Dir", 60, 20, 455, 214)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetState(-1, $GUI_HIDE)


GUICtrlCreateTabItem("")

$Label[0] = GUICtrlCreateLabel("00000000000", 0, 240, 538, 200, $SS_BLACKRECT)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)


;$Input[2] = GUICtrlCreateInput("Search...", 206, 5, 120, 19)
;GUICtrlSetState(-1, $GUI_HIDE)
$VideoLabel_Menu = GUICtrlCreateContextMenu($Label[0])
$VideoLabel_Menu_Item = GUICtrlCreateMenuItem("Load into Media Player", $VideoLabel_Menu)
$NormalButton[12] = GUICtrlCreateButton("", 457 + 24 + 14 + 20, 0, 25, 25, $BS_ICON)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetImage(-1, $TUC_OPT_SHELL32, 281, 0) ;SCAN
GUICtrlSetOnEvent(-1, "_SearchForFilesGUI")

$NormalButton[13] = GUICtrlCreateButton("NIX", 457 + 24 + 14 + 20, 25, 25, 25, $BS_ICON)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
$NormalButton[14] = GUICtrlCreateButton("NIX", 457 + 24 + 14 + 20, 50, 25, 25, $BS_ICON)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
$NormalButton[15] = GUICtrlCreateButton(">>", 457 + 24 + 14 + 20, 75, 25, 25, $BS_ICON)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetOnEvent(-1, "_Music_SetSize")

;Muss noch verbessert werden
For $X = 1 To $StartupArrayMusic[0][0]
	If FileExists($StartupArrayMusic[$X][1] & $StartupArrayMusic[$X][0]) Then
		$i = _GUICtrlListView_AddItem($ListView[0], $StartupArrayMusic[$X][0])
		_GUICtrlListView_AddSubItem($ListView[0], $i, $StartupArrayMusic[$X][1], 1)
	EndIf
Next
Dim $XX = 0 ;Als Counter für "_GetBPM_ForListView" damit keine For schleife verwendet wird
;AdlibRegister("_GetBPM_ForListView", 5000)
For $X = 1 To $StartupArrayVideo[0][0]
	If FileExists($StartupArrayVideo[$X][1] & $StartupArrayVideo[$X][0]) Then
		$i = _GUICtrlListView_AddItem($ListView[1], $StartupArrayVideo[$X][0])
		_GUICtrlListView_AddSubItem($ListView[1], $i, $StartupArrayVideo[$X][1], 1)
	EndIf
Next
#EndRegion MusicVideo
#Region Compression
$Group[1] = GUICtrlCreateGroup(" Input File/Folder ", 60, 0, 480, 42)
GUICtrlSetState(-1, $GUI_HIDE)
$Input[3] = GUICtrlCreateInput("", 65, 15, 445, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[9] = GUICtrlCreateButton("...", 512, 13, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GuictrlsetonEvent(-1, "_PrepareCompression")

GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[2] = GUICtrlCreateGroup(" Compressor ", 60, 42, 480, 60)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[3] = GUICtrlCreateCombo("Compressor", 65, 78, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "_Compressor_ActivateControles")

$Checkbox[0] = GUICtrlCreateCheckbox("Use it:", 291, 80, 55, 17)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "_Compressor_ActivatePreComp")

$Combo[4] = GUICtrlCreateCombo("PreCompression", 354, 78, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
$Combo[5] = GUICtrlCreateCombo("Action", 65, 58, 175, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "_Compressor_ActivateType")

GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[3] = GUICtrlCreateGroup(" Options ", 60, 102, 480, 88)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group[4] = GUICtrlCreateGroup(" Output ", 60, 190, 480, 41)
GUICtrlSetState(-1, $GUI_HIDE)
$Input[4] = GUICtrlCreateInput("", 65, 204, 420, 20)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetState(-1, $GUI_DISABLE)
$NormalButton[10] = GUICtrlCreateButton("...", 487, 202, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "_Compressor_SelectSaveFile")

$NormalButton[11] = GUICtrlCreateButton("", 512, 202, 25, 25, $BS_ICON) ;Create
GUICtrlSetOnEvent(-1, "_Compressor_SetExecutCompression")
;GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetImage($NormalButton[11], $TUC_OPT_SHELL32, 253, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)

#EndRegion Compression
#Region Convert
$Group[6] = GUICtrlCreateGroup(" Input File/Folder ", 60, 0, 480, 42)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[2] = GUICtrlCreateButton("...", 512, 13, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "_Convert_SetControlesWithFileOpenDialog")

$Combo[0] = GUICtrlCreateCombo("", 65, 15, 445, 20)
GUICtrlSetState(-1, $GUI_HIDE)

$Group[7] = GUICtrlCreateGroup(" Output ", 60, 191, 480, 41)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[16] = GUICtrlCreateButton("", 512, 202, 25, 25, $BS_ICON) ;Create
GUICtrlSetImage($NormalButton[12], $TUC_OPT_SHELL32, 253, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$NormalButton[17] = GUICtrlCreateButton("...", 487, 202, 25, 25, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$Combo[1] = GUICtrlCreateCombo("", 65, 204, 420, 20)
GUICtrlSetState(-1, $GUI_HIDE)

GUICtrlCreateGroup("", -99, -99, 1, 1)
#Endregion
#Region ComputerInfo
	$TreeView[2] = GUICtrlCreateTreeView( 60, 25, 255, 205)
	GUICtrlSetState(-1, $GUI_HIDE)
	;GUICtrlSetOnEvent(-1, "_ComputerInfo_TreeViewClick")
	
	$Combo[6] = GUICtrlCreateCombo("", 60, 3, 255, 20, $CBS_NOINTEGRALHEIGHT)
	GUICtrlSetState(-1, $GUI_HIDE)
#endregion
#Region Option
$Treeview[1] = GUICtrlCreateTreeView(70, 6, 291, 235, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $WS_GROUP))
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetColor(-1, 0x0000C0)
_GUICtrlTreeView_SetNormalImageList($Treeview[1], $hImage)

$TreeViewItem_MAIN = _GUICtrlTreeView_Add($Treeview[1], 0, "[MAIN]")
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_MAIN, "Save Position on Exit", 2, 2)
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_MAIN, "Save Volumen on Exit")
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_MAIN, "Save blabla on Exit")

$TreeViewItem_SCAN = _GUICtrlTreeView_Add($Treeview[1], 0, "[SCAN]")
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_SCAN, "Save Position", 9, 9)
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_SCAN, "Save Scan to File", 9, 9)

$TreeViewItem_MUSIC = _GUICtrlTreeView_Add($Treeview[1], 0, "[MUSIC/VIDEO]")
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_MUSIC, "Save selected Music", 10, 10)
_GUICtrlTreeView_AddChild($Treeview[1], $TreeViewItem_MUSIC, "Save selected Videos", 11, 11)

$TreeViewItem_COMPRESS = _GUICtrlTreeView_Add($Treeview[1], 0, "[COMPRESS]")

$Group[5] = GUICtrlCreateGroup("Options", 366, 0, 165, 241)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
#EndRegion Option
#Region THX
#EndRegion THX


#Region Icon
Opt("TrayIconHide", 0)
_TIG_CreateTrayGraph(0, 10)
If @error Then MsgBox(0, "Create", @error)
$Save = TrayCreateItem("Save")
#EndRegion Icon
#Region Menu
#EndRegion Menu


Func _DeleteCTRL()
	_GUICtrlStatusBar_ShowHide($Statusbar, @SW_HIDE)
	WinMove($Form, "", Default, Default, Default, 284, 1)
		GUICtrlSetState($ExplorerView, $GUI_HIDE) ;MAIN

	For $x = 0 To UBound($Edit) - 1 
		GUICtrlSetState($Edit[$x], $GUI_HIDE)
	Next	
	For $x = 0 To UBound($Input) - 1 
		GUICtrlSetState($Input[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($NormalButton) - 1 
		GUICtrlSetState($NormalButton[$x], $GUI_HIDE)
	Next	
	For $x = 0 To UBound($Treeview) - 1 
		GUICtrlSetState($Treeview[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($Tab) - 1 
		GUICtrlSetState($Tab[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($ListView) - 1 
		GUICtrlSetState($ListView[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($Group) - 1 
		GUICtrlSetState($Group[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($Combo) - 1 
		GUICtrlSetState($Combo[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($Checkbox) - 1 
		GUICtrlSetState($Checkbox[$x], $GUI_HIDE)
	Next
	For $x = 0 To UBound($Label) - 1 
		GUICtrlSetState($Label[$x], $GUI_HIDE)
	Next
	For $X = 3 To 6
		GUICtrlSetState($NormalButton[$X], $GUI_HIDE)
	Next

	If IsArray($CheckBoxes) Then
		For $X = 0 To UBound($CheckBoxes) - 1
			GuictrlsetState($CheckBoxes[$X], $GUI_HIDE) ;Die alten werden gelöscht
		Next
	EndIf	
	If IsArray($ComboBoxes) Then 
		For $X = 0 To UBound($ComboBoxes) - 1
			GuictrlsetState($ComboBoxes[$X], $GUI_HIDE)
		Next
	EndIf
	

	;For $x = 0 to UBound($Radio)
	;	GUICtrlSetState($Radio[$x], $GUI_HIDE);Compress
	;Next
	_GUICtrlStatusBar_Resize($Statusbar)
	_GUICtrlStatusBar_ShowHide($Statusbar, @SW_SHOW)
EndFunc ;==>_DeleteCTRL

Func _Music_SetTab()
	Switch GUICtrlRead($Tab[0])
		Case 0
			GUICtrlSetState($ListView[0], $GUI_HIDE) ;Music
			GUICtrlSetState($ListView[1], $GUI_HIDE) ;Music
			GUICtrlSetState($ExplorerView, $GUI_SHOW)
		Case 1
			GUICtrlSetState($ListView[0], $GUI_SHOW) ;Music
			GUICtrlSetState($ListView[1], $GUI_HIDE) ;Music
			GUICtrlSetState($ExplorerView, $GUI_HIDE)
		Case 2
			GUICtrlSetState($ListView[0], $GUI_HIDE) ;Music
			GUICtrlSetState($ListView[1], $GUI_SHOW) ;Music
			GUICtrlSetState($ExplorerView, $GUI_HIDE)
	EndSwitch
EndFunc
Func _Music_SetSize()
	If GUICtrlRead($NormalButton[15]) = ">>" Then
		GUICtrlSetData($NormalButton[15], "<<")
		WinMove($Form, "", Default, Default, Default, 500, 1)
		_GUICtrlStatusBar_Resize($Statusbar)
		GUICtrlSetState($Label[0],$GUI_SHOW)
	Else
		GUICtrlSetData($NormalButton[15], ">>")
		WinMove($Form, "", Default, Default, Default, 290, 1)
		_GUICtrlStatusBar_Resize($Statusbar)
		GUICtrlSetState($Label[0],$GUI_HIDE)
	EndIf
EndFunc
Func _Compressor_SelectSaveFile()
	GUICtrlSetData($Input[4], FileSaveDialog("Where you want to save you file", "", "ALL (*.*)"))
EndFunc
Func _Compressor_SetExecutCompression()
	_Execute_Compression(GUICtrlRead($Input[3]), GUICtrlRead($Input[4]))
EndFunc
Func _Compressor_ActivatePreComp()
	If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then
		GUICtrlSetState($Combo[4], $GUI_ENABLE)
	Else
		GUICtrlSetState($Combo[4], $GUI_DISABLE)
	EndIf
EndFunc
Func _Compressor_ActivateType()
	If GUICtrlRead($Combo[5]) = "Archive Compression " Then
		_Set_Archiver_for_Compression("Archiver")
	ElseIf GUICtrlRead($Combo[5]) = "PE Compression " Then
		_Set_Archiver_for_Compression("Single File Compressor")
		GUICtrlSetData($Input[4], StringTrimRight(GUICtrlRead($Input[3]), 4))
	EndIf
EndFunc
Func _Compressor_ActivateControles()
	If _GUICtrlComboBox_GetCurSel($Combo[3]) <> 0 Then _Set_Controls_For_Compression(GUICtrlRead($Combo[3]))
EndFunc
Func _Convert_SetControlesWithFileOpenDialog()
	_Convert_SetControles(FileOpenDialog("Select a File", "", "Video (*.avi;*.mpeg)| Audio (*.mp3) | All Media Stuff (*.avi; *.mpeg; *.mp3)", 1))
EndFunc



Func _SearchForFilesGUI()
	$OKBottomDlg = GUICreate("Dialog", 312, 144, 505, 319)
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
				GUIDelete($OKBottomDlg)
				ExitLoop
			Case $Button3
				GUICtrlSetData($Input2, FileSelectFolder("Select a Folder", "", 7))
			Case $Button1

		EndSwitch
	WEnd
EndFunc ;==>_SearchForFilesGUI


Func _CreateSearch()
	$SEARCHGUI = GUICreate("Search", 227, 70, -1, -1, $WS_DLGFRAME, "", $Form)
	$SEARCHINPUT = GUICtrlCreateInput("Input1", 7, 7, 179, 21)
	$SEARCHBUTTON = GUICtrlCreateButton("OK", 191, 5, 28, 25, 0)
	GUISetState(@SW_SHOW)
EndFunc ;==>_CreateSearch

Func _CreateMain()
	If $Status = 0 Then Return 0
	_DeleteCTRL()
	$Status = 0
	GUICtrlSetPos($ExplorerView, 60, 0, 481, 233)	
	GUICtrlSetState($ExplorerView, $GUI_SHOW)
EndFunc ;==>_CreateMain

Func _CreateScan()
	If $Status = 1 Then Return 0
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
EndFunc ;==>_CreateScan

Func _CreateVideoMusic()
	If $Status =2 Then Return 0
	_DeleteCTRL()
	$Status = 2
	GUICtrlSetState($Group[0],$GUI_SHOW)
	GUICtrlSetState($Tab[0], $GUI_SHOW)
	GUICtrlSetState($Input[2], $GUI_SHOW) ;Music
	GUICtrlSetState($ListView[0], $GUI_SHOW) ;Music
	GUICtrlSetState($ListView[1], $GUI_SHOW) ;Music
	GUICtrlSetState($NormalButton[12], $GUI_SHOW) ;Music
	GUICtrlSetState($NormalButton[13], $GUI_SHOW) ;Music
	GUICtrlSetState($NormalButton[14], $GUI_SHOW) ;Music
	GUICtrlSetState($NormalButton[15], $GUI_SHOW) ;Music
	GUICtrlSetPos($ExplorerView, 60, 20, 455, 214)
	GUICtrlSetState($ExplorerView, $GUI_SHOW)

EndFunc ;==>_CreateVideoMusic

Func _CreateCompress()
	If $Status = 3 Then Return 0
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
	GUICtrlSetState($Input[4], $GUI_SHOW) ;Compress
	GUICtrlSetState($NormalButton[10], $GUI_SHOW) ;Compress
	GUICtrlSetState($NormalButton[11], $GUI_SHOW) ;Compress
	
	If IsArray($CheckBoxes) Then
		For $X = 0 To UBound($CheckBoxes) - 1
			GuictrlsetState($CheckBoxes[$X], $GUI_SHOW) ;Die alten werden gelöscht
		Next
	EndIf	
	If IsArray($ComboBoxes) Then 
		For $X = 0 To UBound($ComboBoxes) - 1
			GuictrlsetState($ComboBoxes[$X], $GUI_SHOW)
		Next
	EndIf
EndFunc ;==>_CreateCompress

Func _CreateConvert()
	If $Status = 4 Then Return 0
	_DeleteCTRL()
	$Status = 4
	
	GUICtrlSetState($NormalButton[2], $GUI_SHOW) ;Convert
	GUICtrlSetState($NormalButton[16], $GUI_SHOW) ;Convert
	GUICtrlSetState($NormalButton[17], $GUI_SHOW) ;Convert
	GUICtrlSetState($Group[6], $GUI_SHOW) ;Convert
	GUICtrlSetState($Group[7], $GUI_SHOW) ;Convert
	GUICtrlSetState($Combo[0], $GUI_SHOW) ;Convert
	GUICtrlSetState($Combo[1], $GUI_SHOW) ;Convert
EndFunc

Func _CreateComputerInfo()
	If $Status = 5 Then Return 0
	_DeleteCTRL()
	$Status = 5
	
	GUICtrlSetState($TreeView[2], $GUI_SHOW) ;Convert
	GUICtrlSetState($Combo[6], $GUI_SHOW) ;Convert
	
	_ComputerInfo_FillTreeView()
EndFunc

Func _CreateOption()
	If $Status = 16 Then Return 0
	_DeleteCTRL()
	$Status = 16
	GUICtrlSetState($Treeview[1], $GUI_SHOW) ;Option
	GUICtrlSetState($Group[5], $GUI_SHOW) ;Optio
EndFunc ;==>_CreateOption