#include <Array.au3>
#include <_PDH_ProcessCounters.au3>
#include <_PDH_ProcessAllCounters.au3>
; ===============================================================================================================================
; <TestPDH_ObjectTests.au3>
;
;	Simple tests of <_PDH_ObjectBaseCounters.au3>, <_PDH_ProcessCounters.au3>, and <_PDH_ProcessAllCounters.au3>
;
; Author: Ascend4nt
; ===============================================================================================================================


; ===============================================================================================================================
;	=====-------	OBJECT BASE TEST	-----======
; ===============================================================================================================================

MsgBox(0,"ObjectBase Tests","Click OK to commence tests")
;~ #cs
$sPCName=""		; "\\PCNAME"

_PDH_Init()

$obCounters=_PDH_ObjectBaseCreate(230,$sPCName,"784;1410;6;180;684","0;0;"&$_PDH_iCPUCount&";1024;"&$PDH_TIME_CONVERSION)
;~ $i=_PDH_ObjectBaseCreate("Process",$sPCName,"ID Process;Creating Process ID;% Processor Time;Working Set;Elapsed Time")	; same, but for English locale

; Create baseline & initial sleep between 1st collection and start of 'real' collection
_PDH_ObjectBaseCollectQueryData($obCounters)
Sleep(250)

ConsoleWrite("_PDH_ObjectBaseCreate result: @error="&@error&", @extended="&@extended&", IsArray($obCounters):"&IsArray($obCounters)&@CRLF)

;~ _ArrayDisplay($obCounters,"$obCounters Internal Structure")

$iTimer=TimerInit()
$aCounterList=_PDH_ObjectBaseUpdateCounters($obCounters)
ConsoleWrite("_PDH_ObjectBaseUpdateCounters called, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

If IsArray($aCounterList) Then
	$aCounterList[0][0]="Counter Name"
	$aCounterList[0][1]="Process ID"
	$aCounterList[0][2]="Parent PID"
	$aCounterList[0][3]="% CPU Usage"
	$aCounterList[0][4]="Working Set Size (KB)"
	$aCounterList[0][5]="Process Creation Time +/- 1s"	; formerly "Elapsed Time (in seconds)"
	_ArrayDisplay($aCounterList,"$aCounterList update #1")
EndIf

; Add Counters
_PDH_ObjectBaseAddCounters($obCounters,174,1024)
;~ _PDH_ProcessAllAddCounters("Virtual Bytes")	; same, but for English locale

; Virtual Bytes shouldn't require a baseline-sleep, so we'll skip it here.

;~ _ArrayDisplay($obCounters,"$obCounters Internal Structure, now with Virtual Bytes")

$iTimer=TimerInit()
$aCounterList=_PDH_ObjectBaseUpdateCounters($obCounters)
ConsoleWrite("_PDH_ProcessAllUpdateCounters called again, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

If IsArray($aCounterList) Then
	$aCounterList[0][0]="Counter Name"
	$aCounterList[0][1]="Process ID"
	$aCounterList[0][2]="Parent PID"
	$aCounterList[0][3]="% CPU Usage"
	$aCounterList[0][4]="Working Set Size (KB)"
	$aCounterList[0][5]="Process Creation Time +/- 1s"	; formerly "Elapsed Time (in seconds)"
	$aCounterList[0][6]="Virtual (K)Bytes"
	_ArrayDisplay($aCounterList,"$aCounterList update #2")
EndIf

_PDH_ObjectBaseDestroy($obCounters)
_PDH_UnInit()
;~ #ce


; ===============================================================================================================================
;	=====-------	PROCESS (INDIVIDUAL,LOCAL) TEST	-----======
; ===============================================================================================================================

MsgBox(0,"ProcessObject Tests (Local-machine only)","Click OK to commence tests")
;~ #cs
$sProcess="autoit3.exe"
;~ $iProcessID=ProcessExists($sProcess)
$iProcessID=@AutoItPID

_PDH_Init()
$poCounter=_PDH_ProcessObjectCreate($sProcess,$iProcessID)

ConsoleWrite("_PDH_ProcessObjectCreate result: @error="&@error&", @extended="&@extended&", IsArray?:"&IsArray($poCounter)&@CRLF)

;~ _ArrayDisplay($poCounter,"$poCounter Internal Structure (for '"&$sProcess&"', PID #"&$iProcessID&')')

$iTimer=TimerInit()
_PDH_ProcessObjectAddCounters($poCounter,"1410;6;180;684")
;~ _PDH_ProcessObjectAddCounters($poCounter, "Creating Process ID;% Processor Time;Working Set;Elapsed Time")	; same, but for English locale
ConsoleWrite("_PDH_ProcessObjectAddCounters called, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

; Create baseline & initial sleep between 1st collection and start of 'real' collection
_PDH_ProcessObjectCollectQueryData($poCounter)
Sleep(250)

;~ _ArrayDisplay($poCounter,"$poCounter Internal Structure with added Counters (for '"&$sProcess&"', PID #"&$iProcessID&')')

$iTimer=TimerInit()
$aCounterVals=_PDH_ProcessObjectUpdateCounters($poCounter)
ConsoleWrite("_PDH_ProcessObjectUpdateCounters called, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

_ArrayDisplay($aCounterVals,"Counter Values (Parent PID, % CPU Usage, Working Set Sz, Elapsed Time)")

ConsoleWrite("Individual value: PPID:"&_PDH_ProcessObjectUpdateCounters($poCounter,0)&@CRLF)

; Remove counters
_PDH_ProcessObjectRemoveCounters($poCounter,"6;684")	; "6;Elapsed Time"  ; % Processor Time, Elapsed Time (in English!)

;~ _ArrayDisplay($poCounter,"$poCounter Internal Structure, minus % Processor Time, Elapsed Time")

_PDH_ProcessObjectDestroy($poCounter)
_PDH_UnInit()
;~ #ce


; ===============================================================================================================================
;	=====-------	PROCESS ALL (LOCAL) TEST	-----======
; ===============================================================================================================================

MsgBox(0,"ProcessAll Tests (Local-machine only)","Click OK to commence tests")

;~ #cs
_PDH_Init()
_PDH_ProcessAllInit("1410;6;180;684","0;"&$_PDH_iCPUCount&";1024;"&$PDH_TIME_CONVERSION)
;~ _PDH_ProcessAllInit("Creating Process ID;% Processor Time;Working Set;Elapsed Time")	; same, but for English locale

ConsoleWrite("_PDH_ProcessAllInit called, @error="&@error&", @extended="&@extended&@CRLF)
ConsoleWrite("Internal Values: $_PDHPCA_bInit="&$_PDHPCA_bInit&" IsArray($_PDHPCA_aCounters):"&IsArray($_PDHPCA_aCounters)&@CRLF)
;~ _ArrayDisplay($_PDHPCA_aCounters,"Internal $_PDHPCA_aCounters")

; Create baseline & initial sleep between 1st collection and start of 'real' collection
_PDH_ProcessAllCollectQueryData()
Sleep(250)

$iTimer=TimerInit()
$aCounterList=_PDH_ProcessAllUpdateCounters()
ConsoleWrite("_PDH_ProcessAllUpdateCounters called, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

If IsArray($aCounterList) Then
	If $aCounterList[0][3]=-1 Then ConsoleWrite("--- CPU Usage not obtained! -----"&@CRLF)
	$aCounterList[0][0]="Process Name"
	$aCounterList[0][1]="Process ID"
	$aCounterList[0][2]="Parent PID"
	$aCounterList[0][3]="% CPU Usage"
	$aCounterList[0][4]="Working Set Size (KB)"
	$aCounterList[0][5]="Process Creation Time +/- 1s"	; formerly "Elapsed Time (in seconds)"
	_ArrayDisplay($aCounterList,"$aCounterList update #1")
EndIf

; Add Counters
_PDH_ProcessAllAddCounters(174,1024)
;~ _PDH_ProcessAllAddCounters("Virtual Bytes")	; same, but for English locale

; Virtual Bytes shouldn't require a baseline-sleep, so we'll skip it here.

;~ _ArrayDisplay($_PDHPCA_aCounters,"Internal $_PDHPCA_aCounters now with Virtual Bytes")
$iTimer=TimerInit()
$aCounterList=_PDH_ProcessAllUpdateCounters()
ConsoleWrite("_PDH_ProcessAllUpdateCounters called again, @error="&@error&", @extended="&@extended&", Time elapsed:"&TimerDiff($iTimer)&" ms"&@CRLF)

If IsArray($aCounterList) Then
	If $aCounterList[0][3]=-1 Then ConsoleWrite("--- CPU Usage not obtained! -----"&@CRLF)
	$aCounterList[0][0]="Process Name"
	$aCounterList[0][1]="Process ID"
	$aCounterList[0][2]="Parent PID"
	$aCounterList[0][3]="% CPU Usage"
	$aCounterList[0][4]="Working Set Size (KB)"
	$aCounterList[0][5]="Process Creation Time +/- 1s"	; formerly "Elapsed Time (in seconds)"
	$aCounterList[0][6]="Virtual (K)Bytes"
	_ArrayDisplay($aCounterList,"$aCounterList update #2")
EndIf

_PDH_ProcessAllUnInit()
_PDH_UnInit()
;~ #ce