#include <_PDH_PerformanceCounters.au3>
; ===============================================================================================================================
; <TestPDH_HDDWaitIdle.au3>
;
;	Example test of PDH Performance Counters: a simple wait-for-Idle example for Hard Drive activity.
;
; Reference:
;	'Monitoring HD read/write activity'
;		@ http://www.autoitscript.com/forum/index.php?showtopic=61403
;
; Author: Ascend4nt, based on original WMIcode in the thread Referenced above
; ===============================================================================================================================


; ===============================================================================================================================
;	--------------------  MAIN FUNCTION  --------------------
; ===============================================================================================================================

; ===================================================================================================================
; Func _PDH_HDDWaitIdle($iMinIdle=2000,$iTimeOut=10000)
;
; Function to wait for *all* Physical Hard Drives to become Idle for a certain amount of time.
;
; $iMinIdle = Minimum amount of time (in ms) that *all* HDD's should remain Idle for before returning
; $iTimeOut = Maximum time to wait overall for the Idling period.
;	If 0, this will run forever until $iMinIdle is reached.
;
; Returns:
;	Succes: True
;	Failure: False, with @error set:
;		@error = -1 = Timed Out
;		@error =  1 = invalid parameter
;		@error =  2 = Error adding Counter Handle or getting new Query (@extended contains @error code)
;		@error = 16 = PDH Performance Counters not Initialized (_PDH_Init() must be called)
;
; Author: Ascend4nt
; ===================================================================================================================

Func _PDH_HDDWaitIdle($iMinIdle=2000,$iTimeOut=10000)
	If $iMinIdle<1 Or $iTimeOut<0 Or ($iTimeOut And $iMinIdle>$iTimeOut) Then Return SetError(1,0,False)
	If Not $_PDH_bInit Then Return SetError(16,0,False)	; not initialized?
	Local $hQuery,$hCounter,$iTimer,$iIdleTimer,$bIdlePhaseStarted=False

	$hQuery=_PDH_GetNewQueryHandle()
	$hCounter=_PDH_AddCounter($hQuery,":234\198\(_Total)")	; "\PhysicalDisk(_Total)\Current Disk Queue Length"
	If @error Then
		Local $iErr=@error
		_PDH_FreeQueryHandle($hQuery)
		Return SetError(2,$iErr,False)
	EndIf
#cs
	; We forego the following, because 1. "Current Disk Queue Length" doesn't seem to require a baseline-sleep, and
	; 2. the main loop throws out errors anyway.
;~
	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_CollectQueryData($hQuery)
	Sleep(250)
#ce
	If $iTimeOut Then $iTimer=TimerInit()
	While 1
		If _PDH_UpdateCounter($hQuery,$hCounter)=0 Then
			If Not $bIdlePhaseStarted Then
				$iIdleTimer=TimerInit()
				$bIdlePhaseStarted=True
			ElseIf TimerDiff($iIdleTimer)>=$iMinIdle Then
				_PDH_FreeQueryHandle($hQuery)
				Return True
			EndIf
		Else
			$bIdlePhaseStarted=False
		EndIf
		If $iTimeOut And TimerDiff($iTimer)>=$iTimeOut Then ExitLoop
		Sleep(10)
	WEnd
	_PDH_FreeQueryHandle($hQuery)
	Return SetError(-1,0,False)
EndFunc

; ===============================================================================================================================
;	--------------------  MAIN CODE  --------------------
; ===============================================================================================================================

_PDH_Init()
$iTimer=TimerInit()
If _PDH_HDDWaitIdle() Then
	ConsoleWrite("Time elapsed: "&TimerDiff($iTimer)&" ms"&@CRLF)
	MsgBox(0,"Hard Drive Idled","Hard Drive Idle Time Minimum has been reached")
Else
	$iErr=@error
	$iExt=@extended
	ConsoleWrite("Error!: @error="&$iErr&", @extended="&$iExt&", Time elapsed: "&TimerDiff($iTimer)&" ms"&@CRLF)
	MsgBox(0,"Hard Drive Wait Failed","Failure error code:"&$iErr&", @extended="&$iExt&@CRLF)
EndIf
_PDH_UnInit()
