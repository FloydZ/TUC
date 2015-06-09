Func _Create_VideoGUI($Form, $FILE = "")
	#Region ### START Koda GUI section ### FORm=C:\Users\omasgehstock\Desktop\MeineScripts\FinalPacker\DSEngine\MovieEngine.kxf
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
	#EndRegion ### END Koda GUI section ###
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
		$len = Engine_GetLength()
		$pos = Engine_GetPosition()
		GUICtrlSetData($Slider1, ($pos / $len * 100))
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