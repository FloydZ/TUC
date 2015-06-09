#include <_PDH_ProcessCounters.au3>
; ===============================================================================================================================
; <TestPDH_ProcessCounterPoll.au3>
;
; Simple example of using <_PDH_ProcessCounters.au3>, this example using an Adlib function and another Process Counter.
;
; Author: Ascend4nt
; ===============================================================================================================================


; ===================================================================================================================
;	--------------------	GLOBAL VARIABLES (for Adlib & HotKey funcs)	--------------------
; ===================================================================================================================


Global $bHotKeyPressed=False,$bPollAllow=False,$bProcessGone=False
Global $poCounter,$sProcess,$iProcessID
Global $hSplash,$sSplashText=""


; ===================================================================================================================
;	--------------------	ADLIB FUNCTION --------------------
; ===================================================================================================================


; ===================================================================================================================
; Func _PollProcess()
;
; The Adlib update function
; ===================================================================================================================

Func _PollProcess()
	If Not $bPollAllow Or $bProcessGone Then Return
	$bPollAllow=False
	Local $aCounterVals=_PDH_ProcessObjectUpdateCounters($poCounter)
	If @error Then
		If @error=32 Then $bProcessGone=True
	Else
		; Build Splash Text based on Counter values gathered
		$sSplashText="Process '"&$sProcess&"' (PID #"&$iProcessID&")"&@CRLF& _
			"CPU Usage: "&Round($aCounterVals[0]/$_PDH_iCPUCount)&" %"&@CRLF& _		; Divide by CPU count
			"Memory (Working Set Size): "&Round($aCounterVals[1]/1024)&" KB"		; Round to Kilobytes
		$sSplashText&=@CRLF&"[Esc] exits"
		; Send to Splash window
		ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
	EndIf
	$bPollAllow=True
	Return
EndFunc


; ===================================================================================================================
;	--------------------	HOTKEY FUNCTION ([ESC] KEYPRESS) --------------------
; ===================================================================================================================

Func _EscPressed()
	$bHotKeyPressed=True
EndFunc


; ===================================================================================================================
;	--------------------	MAIN PROGRAM CODE	--------------------
; ===================================================================================================================


HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()

#cs
;	-----	Other values that can be monitored:	-----

;~ $sProcess="Idle"		; 'System Idle Process'
;~ $iProcessID=0

;~ $sProcess="_Total"	; Accumulative total of all Process value(s)
;~ $iProcessID=0

;~ $sProcess="System"	; 'System' process
;~ $iProcessID=ProcessExists($sProcess)
#ce

$sPCName=""		; "\\PCNAME"
$sProcess="autoit3"
If @AutoItX64 Then $sProcess&="_x64"	; setting to "autoit3_x64.exe" for 64-bit process :)
$sProcess&='.exe'
$iProcessID=@AutoItPID
;~ $iProcessID=ProcessExists($sProcess)

$hPDHQuery=_PDH_GetNewQueryHandle()

; Get the localized name for "Process"
$sProcessLocal=_PDH_GetCounterNameByIndex(230,$sPCName)


$poCounter=_PDH_ProcessObjectCreate($sProcess,$iProcessID)
_PDH_ProcessObjectAddCounters($poCounter,"6;180")	; "% Processor Time;Working Set"

; Everything kosher?
If @error=0 And IsArray($poCounter) Then
	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_ProcessObjectCollectQueryData($poCounter)
	Sleep(250)

	; Start Splash Window
	$hSplash=SplashTextOn("Process Info","",360,140,Default,Default,16)

	$bPollAllow=True	; enable _PollProcess to work

	; Set Splash text immediately by calling the Adlib process directly
	_PollProcess()

	; Enable _PollProcess Adlib function
	AdlibRegister("_PollProcess",250)	; poll the Process info every 250 ms

	; Enter the 'nothing' loop.  _PollProcess is called by AutoIt, so you can do whatever you want inside this loop
	While Not $bProcessGone And Not $bHotKeyPressed
		Sleep(10)
	WEnd

	; Kill the Adlib function
	$bPollAllow=False
	AdlibUnRegister("_PollProcess")
EndIf
_PDH_ProcessObjectDestroy($poCounter)
_PDH_UnInit()
