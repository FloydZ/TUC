#include <_PDH_TaskMgrSysStats.au3>
#include <_PDH_ProcessAllCounters.au3>
;~ #include <_WinTimeFunctions.au3>	; _WinTime_LocalFileTimeFormat()	; included in <_PDH_ProcessAllCounters.au3>
#include <_WinAPI_GetPerformanceInfo.au3>	; Gather System Cache info.

;	-- KODA GUI INCLUDES --
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

;~ #include <Array.au3>		; _ArrayDisplay()	; (for debug purposes)

; Still to-do: Monitor/edit new processes (duh).  Possibly use _ListView_Manage.au3 ??

; ===============================================================================================================================
; <TestPDH_TaskManager.au3>
;
;	WORK-IN-PROGRESS!!!!
; Trial at creating a mockup Task Manager screen..
;
;
; Dependencies:
;	<_PDH_TaskMgrSysStats.au3>
;	<_PDH_ProcessAllCounters.au3>
;	<_WinAPI_GetPerformanceInfo.au3>	; Grab System Cache and Commit Charge Peak values using this (XP+ func)
;	<_WinTimeFunctions.au3>	; _WinTime_LocalFileTimeFormat()
;	(+GUI Constants files)
;
; Indirect Dependencies:
;	<_PDH_PerformanceCounters.au3>	; Core Performance Counters module
;
;
; See also:
;	<TestPDH_ProcessLoop.au3>
;
; Reference:
;	'Memory Performance Information (Windows)' on MSDN
;		@ http://msdn.microsoft.com/en-us/library/aa965225%28v=VS.85%29.aspx
;	(Most info is available via Process function calls, however some things aren't
;	 for example: 'Private Working Set' is only available using Performance Counters)
;
; Author: Ascend4nt
; ===============================================================================================================================


; ===============================================================================================================================
;	--------------------		GLOBAL VARIABLES		--------------------
; ===============================================================================================================================

;  -  GLOBAL VARIABLES FOR ADLIB GUI UPDATES  -
Global $bPDH_Updating=True
; PDH Handles, Counters, & Arrays
Global $hPDH_TMQueryHandle,$aPDH_Processes,$aPDH_TMPerfStats
Global $iPDH_LastProcCount=0,$iPDH_LastLastPID=0
; GUI Controls
Global $RTHandle,$RTProcesses,$RTThreads,$RCCLimit,$RCCPeak,$RCCTotal
Global $RPMAvailable,$RPMSysCache,$RPMTotal,$RKMNonpaged,$RKMPaged,$RKMTotal
Global $RPFAvailable,$RPFInUse,$RPFPeak,$RPFTotal,$RPFUsage
; GUI-related variables
Global $aPDHTM_CPUValues,$aLVProcesses

;  - GLOBAL VARIABLE FOR HOTKEY PRESS -
Global $bHotKeyPressed=False


; ===============================================================================================================================
;	--------------------		INTERNAL FUNCTIONS		--------------------
; ===============================================================================================================================

Func _CleanExit($iExitCode=0)
	_PDH_ProcessAllUnInit()
	_PDH_FreeQueryHandle($hPDH_TMQueryHandle)
	_PDH_UnInit()
	Exit $iExitCode
EndFunc


; ===============================================================================================================================
;	--------------------		HOTKEY/ADLIB FUNCTIONS		--------------------
; ===============================================================================================================================

; HotKey for escaping app..
Func _EscPressed()
	$bHotKeyPressed=True
EndFunc

;  -  ADLIB FUNCTION FOR GUI UPDATES  -
Func _AdlibFunc()
	If $bPDH_Updating Then Return
	If Not IsArray($aPDH_Processes) Or Not IsArray($aPDH_TMPerfStats) Or Not IsPtr($hPDH_TMQueryHandle) Then Return
	$bPDH_Updating=True
	Local $iListViewSelection,$aMemStats,$iNewCount

	; Gather the Process Information Counter values
	For $i=1 To 2
		$aPDH_Processes=_PDH_ProcessAllUpdateCounters()
		If @error Then ExitLoop
		; CPU Usage - error gathering info? (-1 if yes)
		If $aPDH_Processes[0][3]<>-1 Then ExitLoop
		ConsoleWrite("CPU Usage error (change in processes likely).. sleeping and retrying"&@CRLF)
		Sleep(50)
	Next

	If @error Then
		ConsoleWriteError("_PDH_ProcessAllUpdateCounters call error, @error="&@error&@CRLF)
	Else
		$iNewCount=$aPDH_Processes[0][0]
		; Info Gathered, but New/changed processes since last Adlib update?
		If $iNewCount<>$iPDH_LastProcCount Or $aPDH_Processes[$iNewCount][1]<>$iPDH_LastLastPID Then
			; Could put the formatted string in another column - or set it when adding it to a display list
			;	but for now, replacing the value where it sits
			For $i=1 To $aPDH_Processes[0][0]
				$aPDH_Processes[$i][5]=_WinTime_LocalFileTimeFormat($aPDH_Processes[$i][5],4,1,True)
			Next
		EndIf
	EndIf

	; Gather the Task-Manager-specific Counter values
	_PDH_TaskMgrSysStatsUpdateCounters($hPDH_TMQueryHandle,$aPDH_TMPerfStats)
	If @error Then ConsoleWriteError("_PDH_TaskMgrSysStatsUpdateCounters call error, @error="&@error&@CRLF)


; Updating data

	If _PDH_UpdateCounters($hPDH_QueryHandle,$aPDH_CountersArray,1,2,0,3,1,-1) Then
		; After _PDH_UpdateCounters() call, @extended = # of changes since last call, @error = # of invalidated handles
		;Local $iChangedCounters=@extended,$iInvalidatedHandles=@error
		For $i=1 to UBound($aPDH_CountersArray)-1
			GUICtrlSetData($aPDH_CountersArray[$i][4], _
			  $aPDH_CountersArray[$i][0]&'|'&$aPDH_CountersArray[$i][1]&'|'&$aPDH_CountersArray[$i][2]&'|'&$aPDH_CountersArray[$i][3])
		Next
	EndIf


; Task Manager GUI - Update Processes Data ListView control..

; Process-specific values

; Minus 1 skips the 'Total' process (useless)
;~ For $i=1 To $aPDH_Processes[0][0]-1
;~ 	GUICtrlSetData($aPDH_Processes[$i][6],$aPDH_Processes[$i][0]&'|'&$aPDH_Processes[$i][1]&'|'& _
;~ 		$aPDH_Processes[$i][2]&'|'&$aPDH_Processes[$i][3]&'|'&$aPDH_Processes[$i][4]&' KB|'&$aPDH_Processes[$i][5])
;~ Next

; Task Manager GUI - Update Statistics controls

	$aMemStats=MemGetStats()
	GUICtrlSetData($RTHandle,$aPDH_TMPerfStats[1][1])
	GUICtrlSetData($RTThreads,$aPDH_TMPerfStats[2][1])
	GUICtrlSetData($RTProcesses,$aPDH_TMPerfStats[3][1])
	GUICtrlSetData($RCCLimit,$aPDH_TMPerfStats[5][1])
;	GUICtrlSetData($RCCPeak,"[unknown]")
	GUICtrlSetData($RCCTotal,$aPDH_TMPerfStats[4][1])
	GUICtrlSetData($RPMAvailable,$aPDH_TMPerfStats[6][1])
;	GUICtrlSetData($RPMSysCache,"[unknown]")
; The one constant in all this (can't alter unless physically install more memory - while machine is OFF):
;	GUICtrlSetData($RPMTotal,$aMemStats[1])
	GUICtrlSetData($RKMNonpaged,$aPDH_TMPerfStats[8][1])
	GUICtrlSetData($RKMPaged,$aPDH_TMPerfStats[7][1])
	GUICtrlSetData($RKMTotal,$aPDH_TMPerfStats[7][1]+$aPDH_TMPerfStats[8][1])
	GUICtrlSetData($RPFAvailable,$aMemStats[4])
	GUICtrlSetData($RPFInUse,$aMemStats[3]-$aMemStats[4])
	GUICtrlSetData($RPFPeak,$aPDH_TMPerfStats[10][1])
	; Unlikely to change, but possible:
	GUICtrlSetData($RPFTotal,$aMemStats[3])
	GUICtrlSetData($RPFUsage,$aPDH_TMPerfStats[9][1])

	; Move index to CPU's section (+ 'Total CPU' counters)
	; Update CPU Usage Listview
	$iIndex=$aPDH_TMPerfStats[0][0]+1
	For $i=0 To $aPDH_TMPerfStats[0][0]
		GUICtrlSetData($aPDHTM_CPUValues[$i],'|'&$aPDH_TMPerfStats[$i+1][1]&" %")
	Next

	$bPDH_Updating=False
EndFunc


; ===============================================================================================================================
;	--------------------		MAIN PROGRAM CODE		--------------------
; ===============================================================================================================================

;Local $iTimer
Local $i,$iIndex,$aMemStats,$iMsg
; HotKey initialization
;HotKeySet("{Esc}", "_EscPressed")

; ---------------------------------------------------------------------------------------
; Initialize PDH system (required, although _PDH_GetNewQueryHandle() will also perform this on 1st call)
; ---------------------------------------------------------------------------------------

_PDH_Init()

; ---------------------------------------------------------------------------------------
; - First gather Process Information Counters -
; ---------------------------------------------------------------------------------------

_PDH_ProcessAllInit("1410;6;180;684","0;"&$_PDH_iCPUCount&";1024;"&$PDH_TIME_CONVERSION)
;~ _PDH_ProcessAllInit("Creating Process ID;% Processor Time;Working Set;Elapsed Time")	; same, but for English locale
If @error Then _CleanExit(-1)


; ---------------------------------------------------------------------------------------
; - Gather Task-Manager-specific Counters -
; ---------------------------------------------------------------------------------------

$hPDH_TMQueryHandle=_PDH_GetNewQueryHandle()
$aPDH_TMPerfStats=_PDH_TaskMgrSysStatsAddCounters($hPDH_TMQueryHandle,"",1)
If @error Then _CleanExit(-1)

; ---------------------------------------------------------------------------------------------------
; - Create baseline & initial sleep between 1st collection and start of 'real' collection
; ---------------------------------------------------------------------------------------------------
_PDH_ProcessAllCollectQueryData()
_PDH_CollectQueryData($hPDH_TMQueryHandle)
Sleep(250)


$aPDH_Processes=_PDH_ProcessAllUpdateCounters()
_PDH_TaskMgrSysStatsUpdateCounters($hPDH_TMQueryHandle,$aPDH_TMPerfStats)
If @error Then _CleanExit(-1)

; Could put the formatted string in another column - or set it when adding it to a display list
;	but for now, replacing the value where it sits
For $i=1 To $aPDH_Processes[0][0]
	$aPDH_Processes[$i][5]=_WinTime_LocalFileTimeFormat($aPDH_Processes[$i][5],4,1,True)
Next


; Set index to start of CPU Usages (+ 'Total CPU' counters)
$iIndex=$aPDH_TMPerfStats[0][0]+1
$aMemStats=MemGetStats()

; ---------------------------------------------------------------------------------------
; - Create the GUI (Controls auto-update when the Adlib function is set to run) -
; ---------------------------------------------------------------------------------------

;	-- KODA GUI Interface --
#Region ### START Koda GUI section ###
$TaskMgr_PDH = GUICreate("TaskMgr (PDH)", 713, 667, 220, 143, BitOR($WS_MINIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_GROUP,$WS_BORDER,$WS_CLIPSIBLINGS))
$ProcessesList = GUICtrlCreateLabel("Processes List [NOTE: STATIC Values, Read once at start]", 6, 8, 698, 20, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "Default")
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKHEIGHT)
$ListView1 = GUICtrlCreateListView("Process Name|PID|Parent PID|% CPU|Mem Usage|Creation Time (+/- 1 sec)", 6, 37, 700, 377)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT)
$ExitButton = GUICtrlCreateButton("E&xit", 282, 624, 161, 36, 0)
GUICtrlSetFont(-1, 10, 800, 0, "Default")
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
$Totals = GUICtrlCreateGroup("Totals", 16, 424, 169, 89)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$Handles = GUICtrlCreateLabel("Handles", 22, 440, 43, 17)
$Threads = GUICtrlCreateLabel("Threads", 22, 464, 43, 17)
$Processes = GUICtrlCreateLabel("Processes", 22, 488, 53, 17)

; Total Handles
;$RTHandle = GUICtrlCreateLabel("", 88, 440, 84, 17, $SS_RIGHT)
$RTHandle=GUICtrlCreateLabel($aPDH_TMPerfStats[1][1], 88, 440, 84, 17, $SS_RIGHT)

; Total Threads
;$RTThreads = GUICtrlCreateLabel("", 88, 464, 84, 17, $SS_RIGHT)
$RTThreads=GUICtrlCreateLabel($aPDH_TMPerfStats[2][1], 88, 464, 84, 17, $SS_RIGHT)

; Total Processes
;$RTProcesses = GUICtrlCreateLabel("", 88, 488, 84, 17, $SS_RIGHT)
$RTProcesses=GUICtrlCreateLabel($aPDH_TMPerfStats[3][1], 88, 488, 84, 17, $SS_RIGHT)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$CommitCharge = GUICtrlCreateGroup("Commit Charge (K)", 16, 528, 169, 89)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$CCTotal = GUICtrlCreateLabel("Total", 22, 544, 28, 17)
$CCLimit = GUICtrlCreateLabel("Limit", 22, 568, 25, 17)
$CCPeak = GUICtrlCreateLabel("Peak", 22, 592, 29, 17)

; Commit Charge Total
$RCCTotal = GUICtrlCreateLabel("", 58, 544, 114, 17, $SS_RIGHT)

; Commit Charge Limit
;$RCCLimit = GUICtrlCreateLabel("", 58, 568, 114, 17, $SS_RIGHT)
$RCCLimit=GUICtrlCreateLabel($aPDH_TMPerfStats[5][1], 58, 568, 114, 17, $SS_RIGHT)

;  Commit Charge Peak - Unknown how to retrieve this value
$RCCPeak = GUICtrlCreateLabel("[unknown]", 58, 592, 114, 17, $SS_RIGHT)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$PhysicalMemory = GUICtrlCreateGroup("Physical Memory (K)", 200, 424, 169, 89)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$PMTotal = GUICtrlCreateLabel("Total", 206, 440, 28, 17)
$PMAvailable = GUICtrlCreateLabel("Available", 206, 464, 47, 17)
$PMSysCache = GUICtrlCreateLabel("System Cache", 206, 488, 72, 17)

; Physical Memory: Total
$RPMTotal = GUICtrlCreateLabel("", 286, 440, 74, 17, $SS_RIGHT)

; Physical Memory: Available
$RPMAvailable = GUICtrlCreateLabel("", 286, 464, 74, 17, $SS_RIGHT)

; Physical Memory: System Cache - Unknown how to retrieve this value
$RPMSysCache = GUICtrlCreateLabel("[unknown]", 286, 488, 74, 17, $SS_RIGHT)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$KMMemory = GUICtrlCreateGroup("Kernel Memory (K)", 200, 528, 169, 89)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$KMTotal = GUICtrlCreateLabel("Total", 206, 544, 28, 17)
$KMPaged = GUICtrlCreateLabel("Paged", 206, 568, 35, 17)
$KMNonpaged = GUICtrlCreateLabel("Nonpaged", 206, 592, 54, 17)

; Kernel Memory: Total
$RKMTotal = GUICtrlCreateLabel("", 268, 544, 92, 17, $SS_RIGHT)

; Kernel Memory: Paged
$RKMPaged = GUICtrlCreateLabel("", 268, 568, 92, 17, $SS_RIGHT)

; Kernel Memory: Non-Paged
$RKMNonpaged = GUICtrlCreateLabel("", 268, 592, 92, 17, $SS_RIGHT)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$PageFile = GUICtrlCreateGroup("PageFile Usage (K)", 376, 432, 169, 137)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$PFTotal = GUICtrlCreateLabel("Total", 382, 448, 28, 17)
$PFAvailable = GUICtrlCreateLabel("Available", 382, 472, 47, 17)
$PFUsed = GUICtrlCreateLabel("In Use", 382, 496, 35, 17)
$PFPercent = GUICtrlCreateLabel("% Usage", 382, 520, 46, 17)
$PFPeak = GUICtrlCreateLabel("% Peak Usage", 382, 544, 74, 17)

; Page File: Total
$RPFTotal = GUICtrlCreateLabel("", 462, 448, 72, 17, $SS_RIGHT)
; Page File: Available
$RPFAvailable = GUICtrlCreateLabel("", 462, 472, 72, 17, $SS_RIGHT)
; Page File: In Use
$RPFInUse = GUICtrlCreateLabel("", 462, 496, 72, 17, $SS_RIGHT)
; Page File: % Usage
$RPFUsage = GUICtrlCreateLabel("", 462, 520, 72, 17, $SS_RIGHT)
; Page File: % Peak Usage
$RPFPeak = GUICtrlCreateLabel("", 462, 544, 72, 17, $SS_RIGHT)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$LBCPUUsage = GUICtrlCreateLabel("CPU Usage", 554, 426, 157, 20, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUICtrlSetResizing(-1, $GUI_DOCKHEIGHT)
$CPUUsage = GUICtrlCreateListView("CPU #|% Usage", 554, 448, 145, 185)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
#EndRegion ### END Koda GUI section ###

; ---------------------------------------------------------------------------------------
; - Set initial values for GUI controls -
; ---------------------------------------------------------------------------------------

; Task-Manager specific values

; Set index to start of CPU Usages (+ 'Total CPU' counters)
$iIndex=$aPDH_TMPerfStats[0][0]+1
$aMemStats=MemGetStats()
;GUICtrlSetData($RTHandle,$aPDH_TMPerfStats[1][1])
;GUICtrlSetData($RTThreads,$aPDH_TMPerfStats[2][1])
;GUICtrlSetData($RTProcesses,$aPDH_TMPerfStats[3][1])
;GUICtrlSetData($RCCLimit,$aPDH_TMPerfStats[5][1])
GUICtrlSetData($RCCPeak,Round(_WinAPI_GetPerformanceInfo(2,True)/1024))
GUICtrlSetData($RCCTotal,$aPDH_TMPerfStats[4][1])
GUICtrlSetData($RPMAvailable,$aPDH_TMPerfStats[6][1])
GUICtrlSetData($RPMSysCache,Round(_WinAPI_GetPerformanceInfo(5,True)/1024))
; The one constant in all this (can't alter unless physically install more memory - while machine is OFF):
GUICtrlSetData($RPMTotal,$aMemStats[1])
GUICtrlSetData($RKMNonpaged,$aPDH_TMPerfStats[8][1])
GUICtrlSetData($RKMPaged,$aPDH_TMPerfStats[7][1])
GUICtrlSetData($RKMTotal,$aPDH_TMPerfStats[7][1]+$aPDH_TMPerfStats[8][1])
GUICtrlSetData($RPFAvailable,$aMemStats[4])
GUICtrlSetData($RPFInUse,$aMemStats[3]-$aMemStats[4])
GUICtrlSetData($RPFPeak,$aPDH_TMPerfStats[10][1])
; Unlikely to change, but possible:
GUICtrlSetData($RPFTotal,$aMemStats[3])
GUICtrlSetData($RPFUsage,$aPDH_TMPerfStats[9][1])

; CPU Usage values
Dim $aPDHTM_CPUValues[$aPDH_TMPerfStats[0][1]]
For $i=0 To $aPDH_TMPerfStats[0][1]-2
	$aPDHTM_CPUValues[$i]=GUICtrlCreateListViewItem($i&""&'|'&$aPDH_TMPerfStats[$iIndex][1]&" %",$CPUUsage)
	$iIndex+=1
Next
; Add 'total' too
$aPDHTM_CPUValues[$i]=GUICtrlCreateListViewItem("[Overall]"&'|'&$aPDH_TMPerfStats[$iIndex][1]&" %",$CPUUsage)

; Process-specific values
Dim $aLVProcesses[$aPDH_Processes[0][0]]

For $i=1 To $aPDH_Processes[0][0]
	$aLVProcesses[$i-1]=GUICtrlCreateListViewItem($aPDH_Processes[$i][0]&'|'&$aPDH_Processes[$i][1]&'|'& _
		$aPDH_Processes[$i][2]&'|'&$aPDH_Processes[$i][3]&'|'&$aPDH_Processes[$i][4]&' KB|'&$aPDH_Processes[$i][5],$ListView1)
Next


; ---------------------------------------------------------------------------------------
; - Enable Adlib updating -
; ---------------------------------------------------------------------------------------

$bPDH_Updating=False
;AdlibEnable("_AdlibFunc",500)
;AdlibRegister("_AdlibFunc",500)


; ---------------------------------------------------------------------------------------
; - The Message Loop -
; ---------------------------------------------------------------------------------------

$hActivehWnd=WinGetHandle("[ACTIVE]")		; (also same as 'GetForegroundWindow')
GUISetState(@SW_SHOW)
;  SWP_NOSIZE 0x0001, SWP_NOMOVE 0x0002, SWP_NOSENDCHANGING 0x0400, SWP_NOACTIVATE 0x0010, SWP_HIDEWINDOW 0x0080
;DllCall("user32.dll","int","SetWindowPos","hwnd",$TaskMgr_PDH,"hwnd",$hActivehWnd, _
	;"int",0,"int",0,"int",0,"int",0,"int",0x403)


While 1
	$iMsg = GUIGetMsg()
	Switch $iMsg
		Case $GUI_EVENT_CLOSE, $ExitButton
			; Stop the Adlib updates, delete the GUI, and exit loop
			$bPDH_Updating=True
;			AdlibDisable()
;			AdlibUnRegister("_AdlibFunc")
			GUIDelete($TaskMgr_PDH)
			ExitLoop
		Case $ListView1
			;
	EndSwitch
WEnd

; ---------------------------------------------------------------------------------------
; - PDH Cleanup and Exit -
; ---------------------------------------------------------------------------------------
_CleanExit()

;#ce
