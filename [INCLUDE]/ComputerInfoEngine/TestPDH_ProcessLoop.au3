#include <Array.au3>
#include <_PDH_ProcessAllCounters.au3>
; ===============================================================================================================================
; <TestPDH_ProcessLoop.au3>
;
;	Test of <_PDH_ProcessAllCounters.au3>, displaying extended info on all processes.
;
; Author: Ascend4nt
; ===============================================================================================================================


; ===============================================================================================================================
;	--------------------  MAIN  --------------------
; ===============================================================================================================================

Global $bHotKeyPressed=False

Func _EscPressed()
	$bHotKeyPressed=True
EndFunc

; -------------------------------------------

HotKeySet("{Esc}", "_EscPressed")
TrayTip("Process Info Loop Started","Press ESC to exit on next pass",5000)

_PDH_Init()
Local $iTimer=TimerInit()
; Initialize Process Object with the following Counters:
;	1410 ("Creating Process ID"), 6 ("% Processor Time), 180 ("Working Set"), 684 ("Elapsed Time")
; AND set modifiers to:
;	0 (nothing), $_PDH_iCPUCount (for calculating CPU Usage Properly), 1024 (Bytes->KBytes), $PDH_TIME_CONVERSION (Elapsed->Creation Time)
_PDH_ProcessAllInit("1410;6;180;684","0;"&$_PDH_iCPUCount&";1024;"&$PDH_TIME_CONVERSION)
If @error Then Exit _PDH_UnInit()

ConsoleWrite("_PDH_ProcessAllInit call time:"&TimerDiff($iTimer)&" ms"&@CRLF)

; Create baseline & initial sleep between 1st collection and start of 'real' collection
_PDH_ProcessAllCollectQueryData()
Sleep(250)

Local $aProcessArray,$iLastCount=0,$iLastPID=0,$iNewCount

Do
	$iTimer=TimerInit()
	$aProcessArray=_PDH_ProcessAllUpdateCounters()
	If @error Then
		ConsoleWrite("_PDH_ProcessAllUpdateCounters() @error:"&@error&", @extended:"&@extended&@CRLF)
		ExitLoop
	EndIf
	ConsoleWrite("_PDH_ProcessAllUpdateCounters() call completed at:"&TimerDiff($iTimer)&" ms"&@CRLF)

	If $aProcessArray[0][3]=-1 Then ConsoleWrite("**CPU Usage** was not able to be obtained this go-around"&@CRLF)

	$iNewCount=$aProcessArray[0][0]
	; New/changed processes?
	If $iNewCount<>$iLastCount Or $aProcessArray[$iNewCount][1]<>$iLastPID Then
		ConsoleWrite("New/changed processes detected since last call. Last Count:"&$iLastCount&" Current count:"&$iNewCount& _
			" Previous Bottom-PID:"&$iLastPID&" Current Bottom-PID:"&$aProcessArray[$iNewCount][1]&@CRLF)
		$iLastCount=$iNewCount
		$iLastPID=$aProcessArray[$iNewCount][1]
	EndIf
	; Add an extra column for Converted Time, Take 1 off Row count (+1 though for header row [+2 to retain '_Total' row])
	ReDim $aProcessArray[$iNewCount+1][7]
	; Put a formatted time into the last column (keeping FileTime value in [5]
	For $i=1 To $iNewCount
		$aProcessArray[$i][6]=_WinTime_LocalFileTimeFormat($aProcessArray[$i][5],12,1,True)
	Next
	ConsoleWrite("_PDH_ProcessStats() call and optional Date/Time format completed, full elapsed time:"&TimerDiff($iTimer)&" ms"&@CRLF)
	$aProcessArray[0][0]="Process Name"
	$aProcessArray[0][1]="Process ID"
	$aProcessArray[0][2]="Parent PID"
	$aProcessArray[0][3]="CPU Usage"
	$aProcessArray[0][4]="Memory Usage (KB)"
	; Why +\- 1 second?  Because 'Elapsed Time' requires additional calculations to figure Creation time
	$aProcessArray[0][5]="Process Creation FileTime +\- 1 sec"
	$aProcessArray[0][6]="Process Creation Time +\- 1 sec"
	_ArrayDisplay($aProcessArray)
Until $bHotKeyPressed
_PDH_ProcessAllUnInit()
_PDH_UnInit()
