#include <_PDH_ProcessCounters.au3>
; ===============================================================================================================================
; <TestPDH_ProcessCounter.au3>
;
; Simple example of using <_PDH_ProcessCounters.au3>
;
; Author: Ascend4nt
; ===============================================================================================================================


; ===================================================================================================================
;	--------------------	HOTKEY FUNCTION & VARIABLE --------------------
; ===================================================================================================================


Global $bHotKeyPressed=False

Func _EscPressed()
	$bHotKeyPressed=True
EndFunc


; ===================================================================================================================
;	--------------------	MAIN PROGRAM CODE	--------------------
; ===================================================================================================================


HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()
Local $poCounter,$hSplash,$sProcess,$iProcessID
Local $iCounterValue,$sSplashText

#cs
;	-----	Other values that can be monitored:	-----

;~ $sProcess="Idle"		; 'System Idle Process'
;~ $iProcessID=0

;~ $sProcess="_Total"	; Accumulative total of all Process value(s)
;~ $iProcessID=0

;~ $sProcess="System"	; 'System' process
;~ $iProcessID=ProcessExists($sProcess)
#ce

$sProcess="autoit3"
If @AutoItX64 Then $sProcess&="_x64"	; setting to "autoit3_x64.exe" for 64-bit process :)
$sProcess&='.exe'
$iProcessID=@AutoItPID
;~ $iProcessID=ProcessExists($sProcess)

$poCounter=_PDH_ProcessObjectCreate($sProcess,$iProcessID)
_PDH_ProcessObjectAddCounters($poCounter,6)	; "% Processor Time"

; Successful? Do initial baseline, then enter a loop.
If @error=0 And IsArray($poCounter) Then
	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_ProcessObjectCollectQueryData($poCounter)
	Sleep(250)

	$iCounterValue=Round(_PDH_ProcessObjectUpdateCounters($poCounter,0)/$_PDH_iCPUCount)
	$sSplashText="Process '"&$sProcess&"' (PID #"&$iProcessID&")"&@CRLF&"CPU Usage:"&$iCounterValue&" %"&@CRLF&"[Esc] exits"
	$hSplash=SplashTextOn("Process Info",$sSplashText,360,100,Default,Default,16)

	; Now the loop
	Do
		Sleep(200)
		$iCounterValue=_PDH_ProcessObjectUpdateCounters($poCounter,0)
		If @error=32 Then ExitLoop		; Process can no longer be found
		$iCounterValue=Round($iCounterValue/$_PDH_iCPUCount)
		$sSplashText="Process '"&$sProcess&"' (PID #"&$iProcessID&")"&@CRLF&"CPU Usage:"&$iCounterValue&" %"&@CRLF&"[Esc] exits"
		ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
	Until $bHotKeyPressed
EndIf
_PDH_ProcessObjectDestroy($poCounter)
_PDH_UnInit()
