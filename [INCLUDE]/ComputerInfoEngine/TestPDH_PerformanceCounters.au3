#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=PerformanceCountersTest.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_After=del TestPDH_PerformanceCounters_Obfuscated.au3
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/om /cn=0 /cs=0 /sf=1 /sv=1
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#obfuscator_ignore_funcs _PDH_UnInit
; ===============================================================================================================================
; <TestPDH_PerformanceCounters.au3>
;
; GUI Interface to testing PDH Performance Counters.
;	NOTE: It's a bit sloppy looking, but it works..
;
; Author: Ascend4nt
; ===============================================================================================================================

#include <_PDH_PerformanceCounters.au3>

;  -  KODA GUI INCLUDES  -
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
;

;  -  GLOBAL VARIABLES FOR ADLIB GUI UPDATES  -
Global $hPDH_QueryHandle,$aPDH_CountersArray,$bPDH_Updating=True

;  -  ADLIB FUNCTION FOR GUI UPDATES  -
Func _AdlibFunc()
	If $bPDH_Updating Or Not IsArray($aPDH_CountersArray) Or $hPDH_QueryHandle<1 Then Return
	Local $iListViewSelection
	$bPDH_Updating=True
	If _PDH_UpdateCounters($hPDH_QueryHandle,$aPDH_CountersArray,1,2,0,3,1,-1) Then
		; After _PDH_UpdateCounters() call, @extended = # of changes since last call, @error = # of invalidated handles
		;Local $iChangedCounters=@extended,$iInvalidatedHandles=@error
		For $i=1 to UBound($aPDH_CountersArray)-1
			GUICtrlSetData($aPDH_CountersArray[$i][4], _
			  $aPDH_CountersArray[$i][0]&'|'&$aPDH_CountersArray[$i][1]&'|'&$aPDH_CountersArray[$i][2]&'|'&$aPDH_CountersArray[$i][3])
		Next
	EndIf
	$bPDH_Updating=False
EndFunc

;	- FORMAT GET-INFO string	-
Func _FormatGetInfo($hPDHCounter)
	Dim $aCounterInfo=_PDH_GetCounterInfo($hPDHCounter)
	If @error Then Return SetError(@error,@extended,"")
	Local $sPCName=""
	If StringLeft($aCounterInfo[6],2)<>"\\" Then
		If $aCounterInfo[7]<>"" Then
			; Sometimes a \\ isn't added for the name.. (or is always added? - need to test this further)
			If StringLeft($aCounterInfo[7],2)<>'\\' Then $sPCName='\\'
			$sPCName&=$aCounterInfo[7]
		Else
			$sPCName='\\'&@ComputerName
		EndIf
	EndIf
	Local $sFormattedStr="PDH Counter Info For Handle " & $hPDHCounter&":"&@CRLF& _
		"--------------------------------------------------------------"&@CRLF& _
		"Counter Type: 0x" &Hex($aCounterInfo[0]) &",  CStatus: 0x"&Hex($aCounterInfo[1])&@CRLF& _
		"Scale Factor: " &$aCounterInfo[2]&",  Default Scale: " &$aCounterInfo[3]& _
		",  Counter User-Data: " &$aCounterInfo[4]&",  Query User Data: " &$aCounterInfo[5]&@CRLF& _
		"--------------------------------------------------------------"&@CRLF& _
		"Non-Localized Counter Path= "&_PDH_CounterNameToNonLocalStr($aCounterInfo[6])&@CRLF& _
		"Non-Localized Counter Path *with* PC Name= "&_PDH_CounterNameToNonLocalStr($sPCName&$aCounterInfo[6],True)&@CRLF& _
		"--------------------------------------------------------------"&@CRLF& _
		"Full Counter Path: " &$aCounterInfo[6]&@CRLF&"Machine Name (optional): "&$aCounterInfo[7]&@CRLF& _
		"Object Name: "&$aCounterInfo[8]&@CRLF&"Instance Name (optional): "&$aCounterInfo[9]&@CRLF& _
		"Parent Instance Name (optional): "&$aCounterInfo[10]&@CRLF&"Instance Index (0 means no index): "&$aCounterInfo[11]&@CRLF& _
		"Counter Name: "&$aCounterInfo[12]&@CRLF&"Counter Explanation Text: "&$aCounterInfo[13]
	Return $sFormattedStr
EndFunc


;  -  MAIN FUNCTION FOR TESTING  -
Func TestPerformanceCounters()
	Local $aRet, $iTimer,$sCounterWildcardPath,$sDisplayStr
	Local $iLastSelectedListItem
	;Local $hPDHQueryHandle,$aPDHCountersArray	; used in Global var's instead
	Local $aPDHCounterList

	If Not _PDH_Init() Then Return

While 1
	; Was there a manually entered path which resulted in a valid array during last GUI session?
	If Not IsArray($aPDHCounterList) Then
		; Loop due to issues with 'Browse Counters Dialog' returning invalid paths on rare occassions
		While 1
			$sCounterWildcardPath=_PDH_BrowseCounters("Choose a single or wildcard counter")
			If $sCounterWildcardPath="" Then Return _PDH_UnInit()
			; Sometimes an invalid path is returned - another issue with the 'Browse Counters Dialog'
			If Not _PDH_ValidatePath($sCounterWildcardPath) And Not StringInStr($sCounterWildcardPath,'*') Then
				_PDH_DebugWriteErr("Invalid path received from 'Browse Counters Dialog': "&$sCounterWildcardPath)
				ContinueLoop
			EndIf
			; If they selected one specific thing, change *Instance* into a wildcard (*) [Fixed to only adjust instance before the '\']
;~ 			$sCounterWildcardPath=StringRegExpReplace($sCounterWildcardPath,"\([^\)]+\)\\","(*)\\")
			; Still no wildcards? Must not have been an option for Instance
			If Not StringInStr($sCounterWildcardPath,'*',1) Then
				Dim $aPDHCounterList[2]
				$aPDHCounterList[0]=1
				$aPDHCounterList[1]=$sCounterWildcardPath
			Else
;~ 				ConsoleWrite(", Converted Counter Path:"&$sCounterWildcardPath&"'"&@CRLF)
				$iTimer=TimerInit()
				$aPDHCounterList=_PDH_GetCounterList($sCounterWildcardPath)
				ConsoleWrite("_PDH_GetCounterList() call time:" & TimerDiff($iTimer) & " ms" & @CRLF)
				If $aPDHCounterList[0]=0 Or Not _PDH_ValidatePath($aPDHCounterList[1]) Then
					_PDH_DebugWriteErr("Invalid path received from 'Browse Counters Dialog': "&$sCounterWildcardPath)
					ContinueLoop
				EndIf
			EndIf
			; No errors - continue on
			ExitLoop
		WEnd
	EndIf
	; $aPDHCounterList is an array now

	; Get new PDH Query Handle
	$iTimer=TimerInit()
	$hPDH_QueryHandle=_PDH_GetNewQueryHandle(1234)
	ConsoleWrite("_PDH_GetNewQueryHandle() call time:" & TimerDiff($iTimer) & " ms" & @CRLF)

	If Not $hPDH_QueryHandle Then Return _PDH_UnInit()

	If $aPDHCounterList[0]=1 And Not StringInStr($aPDHCounterList[1],'*',1) Then
		Dim $aPDH_CountersArray[2][5]
		$aPDH_CountersArray[0][0]=1
		$aPDH_CountersArray[1][0]=$aPDHCounterList[1]
		$aPDH_CountersArray[1][1]=_PDH_AddCounter($hPDH_QueryHandle,$aPDHCounterList[1],9876)
	Else
		$iTimer=TimerInit()
		; Go through array and add them one by one to the PDH Query Handle
		; Add all listed Counters's Handles to the Query and put the Handles in a 2D array,
		;	1st column contains name, 2nd contains handle. 1 at end = add bottom row (for title info)
		;	add 3 additional columns too (counter value, delta change, & Control ID)
		$aPDH_CountersArray=_PDH_AddCountersByArray($hPDH_QueryHandle,$aPDHCounterList,1,-1,1,3)

		ConsoleWrite("Time to call _PDH_AddCountersByArray:" & TimerDiff($iTimer) & " ms" & @CRLF)
	EndIf

	; Free up the memory used by this array, now that we have allocated a new one
	$aPDHCounterList=0

	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_CollectQueryData($hPDH_QueryHandle)
	Sleep(250)

	; Caption the bottom elements (useful for _ArrayDisplay())
	$aPDH_CountersArray[0][0]="Counter Full Name"
	$aPDH_CountersArray[0][1]="Counter Handle"
	$aPDH_CountersArray[0][2]="Counter Value"
	$aPDH_CountersArray[0][3]="Delta Change Since Last Refresh"
	$iTimer=TimerInit()
	_PDH_UpdateCounters($hPDH_QueryHandle,$aPDH_CountersArray,1,2,0,3,1,-1,True)
	ConsoleWrite("Time for 1st call to _PDH_UpdateCounters:" & TimerDiff($iTimer) & " ms" & @CRLF)
; ---------------------------------------------------------------------------------------------------------------
	;  -  KODA GUI  -
	#Region ### START Koda GUI section ###
	$ListAndEdit = GUICreate("PDH Query Handle ("&$hPDH_QueryHandle&") Counters ["&(UBound($aPDH_CountersArray)-1)&" total]", _
		669, 677, 191, 125, _
	BitOR($WS_MINIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_GROUP,$WS_BORDER,$WS_CLIPSIBLINGS))
	$ListViewLabel = GUICtrlCreateLabel("WildcardPath '"&$sCounterWildcardPath&"'", 2, 8, 660, 20, $SS_CENTER)
	GUICtrlSetFont(-1, 10, 800, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKHEIGHT)
	$ctListView = GUICtrlCreateListView("Counter Full Name|Counter Handle|Counter Value|Delta Change Since Last Refresh", _
		2, 37, 660, 361,-1,$LVS_EX_GRIDLINES+$LVS_EX_FULLROWSELECT)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT)
	$ctEditBoxLabel = GUICtrlCreateLabel("PDH Counter Info Output", 2, 406, 660, 20, $SS_CENTER)
	GUICtrlSetFont(-1, 10, 800, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT)
	$ctEditOutput = GUICtrlCreateEdit("", 2, 432, 660, 193, _
		BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$ES_WANTRETURN,$WS_HSCROLL,$WS_VSCROLL))
	GUICtrlSetFont(-1, 10, 400, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT)
	$BrowseCountersButton = GUICtrlCreateButton("Browse More Counters", 16, 632, 177, 36, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont(-1, 10, 800, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	$ManualEntryButton = GUICtrlCreateButton("Manual Entry", 255, 632, 153, 36, 0)
	GUICtrlSetFont(-1, 10, 800, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	$ExitButton = GUICtrlCreateButton("E&xit", 480, 632, 161, 36, 0)
	GUICtrlSetFont(-1, 10, 800, 0, "Default")
	GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

	Local $aAccelerators[2][2]=[["{Enter}",$BrowseCountersButton],["{ESC}",$ExitButton]]
	GUISetAccelerators($aAccelerators,$ListAndEdit)
	; Setup listview & get Control ID's
	For $i=1 to UBound($aPDH_CountersArray)-1
		$aPDH_CountersArray[$i][4]=GUICtrlCreateListViewItem($aPDH_CountersArray[$i][0]&'|'&$aPDH_CountersArray[$i][1]&'|'& _
			$aPDH_CountersArray[$i][2]&'|'&$aPDH_CountersArray[$i][3],$ctListView)
	Next
	; Initialize Edit Box with 1st item in list
	GUICtrlSetData($ctEditBoxLabel,$aPDH_CountersArray[1][0])
	GUICtrlSetData($ctEditOutput,_FormatGetInfo($aPDH_CountersArray[1][1]))	;_PDH_GetCounterInfo($aPDH_CountersArray[1][1]))
	$iLastSelectedListItem=$aPDH_CountersArray[1][4]
	; Show GUI
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	; Enable Adlib updating
	$bPDH_Updating=False
	AdlibRegister("_AdlibFunc",500)

	; Get Message Loop
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE,$ExitButton
				; Cleanup and get outta here
				$bPDH_Updating=True
				GUIDelete($ListAndEdit)
				AdlibUnRegister("_AdlibFunc")
				ExitLoop 2	; Exit inner and outer loop (to _PDH_UnInit() call)
			Case $GUI_EVENT_PRIMARYUP,$GUI_EVENT_SECONDARYUP
				; In case it was a ListView click, check the last vs. current selection
				Local $iListViewSelection=GUICtrlRead($ctListView)
				; Difference Detected? Find the right element in array
				If $iLastSelectedListItem<>$iListViewSelection Then
					ConsoleWrite("New ID from ctListView:" & $iListViewSelection & @CRLF)
					For $i=1 to UBound($aPDH_CountersArray)-1
						; Found a match for the selected item? Set the data and Exit Loop
						If $aPDH_CountersArray[$i][4]=$iListViewSelection Then
							GUICtrlSetData($ctEditBoxLabel,$aPDH_CountersArray[$i][0])
							GUICtrlSetData($ctEditOutput,_FormatGetInfo($aPDH_CountersArray[$i][1]))	;_PDH_GetCounterInfo($aPDH_CountersArray[$i][1]))
							ExitLoop
						EndIf
					Next
					$iLastSelectedListItem=$iListViewSelection
				EndIf
			; Column Headings clicked.. now, how to figure out which..?
			Case $ctListView
				ConsoleWrite("ListView heading clicked somewhere. Value:"&GUICtrlRead($ctListView,1)&@CRLF)
			Case $BrowseCountersButton
				; Cleanup and continue outer loop
				$bPDH_Updating=True
				AdlibUnRegister("_AdlibFunc")
				GUIDelete($ListAndEdit)
				For $i=1 to UBound($aPDH_CountersArray)-1
					GUICtrlDelete($aPDH_CountersArray[$i][3])
				Next
				ExitLoop
			Case $ManualEntryButton
				$bPDH_Updating=True
				Local $sNewWildcardPath=InputBox("Manual Counter Wildcard Path Entry", _
					"Enter New Full, WildCard (*), or Non-Localized Counter Path."&@CRLF&"Examples:\Object(*)\*, Object(Instance)\*, Object(*)\Counter","","",360,140,Default,Default,0,$ListAndEdit)
				If $sNewWildcardPath="" Then
					$bPDH_Updating=False
					ContinueLoop
				EndIf
				; Wildcards (*) entered? [at the end of path sections]?
				If StringRegExp($sNewWildcardPath,"\*(\)|\\|$)") Then
					$iTimer=TimerInit()
					$aPDHCounterList=_PDH_GetCounterList($sNewWildcardPath)
					ConsoleWrite("_PDH_GetCounterList() call time:" & TimerDiff($iTimer) & " ms" & @CRLF)
				Else
					Dim $aPDHCounterList[2]
					If _PDH_ValidatePath($sNewWildcardPath) Then
						$aPDHCounterList[0]=1
						$aPDHCounterList[1]=$sNewWildcardPath
					Else
						$aPDHCounterList[0]=0
					EndIf
				EndIf
				If @error Or $aPDHCounterList[0]=0 Then
					MsgBox(48,"Error Getting Counter List", $sNewWildcardPath & @CRLF & _
						"The above path has caused an error on calling _PDH_Get_CounterList()" & @CRLF & _
						"@error="&@error&",  PDH Last Error ="&@extended&@CRLF&@CRLF& _
						"Format of counters: \\MACHINE\Object(Instance)\Counter"&@CRLF& _
						"    NOTE: \\MACHINE prefix is optional",0,$ListAndEdit)
					$aPDHCounterList=0
				Else
					$sCounterWildcardPath=$sNewWildcardPath
					; Cleanup and continue to outer loop
					AdlibUnRegister("_AdlibFunc")
					GUIDelete($ListAndEdit)
					For $i=1 to UBound($aPDH_CountersArray)-1
						GUICtrlDelete($aPDH_CountersArray[$i][3])
					Next
					ExitLoop
				EndIf
				$bPDH_Updating=False
		EndSwitch
	WEnd
; ---------------------------------------------------------------------------------------------------------------
	; Free Query Handle (and associated Counter Handles)
	_PDH_FreeQueryHandle($hPDH_QueryHandle)
WEnd
	; UnInit & Close PDH Query Handle
	_PDH_UnInit($hPDH_QueryHandle)

	Return
EndFunc

;  -  MAIN FUNCTION CALL  -

TestPerformanceCounters()