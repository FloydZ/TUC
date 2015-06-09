#include <_PDH_PerformanceCounters.au3>
; ===============================================================================================================================
; <TestPDH_CPUUsage.au3>
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
; --------------------  WRAPPER FUNCTION --------------------
; ===================================================================================================================

Func _PDH_GetCPUCounters($hPDHQuery,$sPCName="")
	; Strip first '\' from PC Name, if passed
	If $sPCName<>"" And StringLeft($sPCName,2)="\\" Then $sPCName=StringTrimLeft($sPCName,1)
	; CPU Usage (per processor) (":238\6\(*)" or English: "\Processor(*)\% Processor Time")
	Local $aCPUsList=_PDH_GetCounterList(":238\6\(*)"&$sPCName)
	If @error Then Return SetError(@error,@extended,"")
	; start at element 1 (element 0 countains count), -1 = to-end-of-array
	Local $aCPUCounters=_PDH_AddCountersByArray($hPDHQuery,$aCPUsList,1,-1)
	If @error Then Return SetError(@error,@extended,"")
	Return SetExtended($aCPUsList[0],$aCPUCounters)
EndFunc


; ===================================================================================================================
;	--------------------	MAIN PROGRAM CODE	--------------------
; ===================================================================================================================


HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()
Local $hPDHQuery,$aCPUCounters,$iTotalCPUs,$hSplash
Local $iCounterValue,$sSplashText,$sPCName=""	; $sPCName="\\AnotherPC"

$hPDHQuery=_PDH_GetNewQueryHandle()
$aCPUCounters=_PDH_GetCPUCounters($hPDHQuery,$sPCName)
$iTotalCPUs=@extended

; successful? Then enter loop
If @error=0 And IsArray($aCPUCounters) Then
	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_CollectQueryData($hPDHQuery)
	Sleep(250)

	$hSplash=SplashTextOn("CPU Usage Information ["&$iTotalCPUs-1&" total CPU's]","",360,150,Default,Default,16)
	; Start loop
	Do
		_PDH_CollectQueryData($hPDHQuery)
		$sSplashText=""
		For $i=0 To $iTotalCPUs-1
			; True means do *not* call _PDH_CollectQueryData for each update.  Only once per Query handle is needed
			$iCounterValue=_PDH_UpdateCounter($hPDHQuery,$aCPUCounters[$i][1],0,True)
			If $i<>$iTotalCPUs-1 Then
				$sSplashText&="CPU #"&$i+1&" value:"&$iCounterValue&" %"&@CRLF
			Else
				$sSplashText&="Total Overall CPU Usage value:"& $iCounterValue&" %"
			EndIf
		Next
		$sSplashText&=@CRLF&"[Esc] exits"
		ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
		Sleep(500)
	Until $bHotKeyPressed
EndIf
_PDH_FreeQueryHandle($hPDHQuery)
_PDH_UnInit()
