#include <_PDH_PerformanceCounters.au3>
; ===============================================================================================================================
; <PDH_HardDiskUsageExample.au3>
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
; --------------------  WRAPPER FUNCTIONS --------------------
; ===================================================================================================================

; Physical Disk - Write (bytes) Counters

Func _PDH_GetDiskWriteCounters($hPDHQuery,$sPCName="")
	Local $aDiskWriteList,$aDiskWriteCounters,$iTotalDisks

	; Strip first '\' from PC Name, if passed
	If $sPCName<>"" And StringLeft($sPCName,2)="\\" Then $sPCName=StringTrimLeft($sPCName,1)

	; Physical Disk - Disk Write Bytes/sec (":234\222\(*)") or English: "\PhysicalDisk(*)\Disk Write Bytes/sec"
	$aDiskWriteList=_PDH_GetCounterList(":234\222\(*)"&$sPCName)
	If @error Then Return SetError(@error,@extended,"")

	; start at element 1 (element 0 countains count), -1 = to-end-of-array
	$aDiskWriteCounters=_PDH_AddCountersByArray($hPDHQuery,$aDiskWriteList,1,-1)
	If @error Then Return SetError(@error,@extended,"")

	$iTotalDisks=UBound($aDiskWriteCounters)-1
	Return SetExtended($iTotalDisks,$aDiskWriteCounters)
EndFunc

; Physical Disk - Read (bytes) Counters

Func _PDH_GetDiskReadCounters($hPDHQuery,$sPCName="")
	Local $aDiskReadList,$aDiskReadCounters,$iTotalDisks

	; Strip first '\' from PC Name, if passed
	If $sPCName<>"" And StringLeft($sPCName,2)="\\" Then $sPCName=StringTrimLeft($sPCName,1)

	; Physical Disk - Disk Read Bytes/sec (":234\220\(*)") or English: "\PhysicalDisk(*)\Disk Read Bytes/sec"
	$aDiskReadList=_PDH_GetCounterList(":234\220\(*)"&$sPCName)
	If @error Then Return SetError(@error,@extended,"")

	; start at element 1 (element 0 countains count), -1 = to-end-of-array
	$aDiskReadCounters=_PDH_AddCountersByArray($hPDHQuery,$aDiskReadList,1,-1)
	If @error Then Return SetError(@error,@extended,"")

	$iTotalDisks=UBound($aDiskReadCounters)-1
	Return SetExtended($iTotalDisks,$aDiskReadCounters)
EndFunc


; ===================================================================================================================
; --------------------  MISC FUNCTION --------------------
; ===================================================================================================================


; ====================================================================================================
; Func _AddCommas($sString)
;
; Simple function - does what it says. Adds commas to a number/string and returns the result.
;
; Author: Ascend4nt
; ====================================================================================================

Func _AddCommas($sString)
	Local $iLen=StringLen($sString)
	If $iLen<=3 Then Return $sString
	Local $iMod=Mod($iLen,3),$sLeft
	If Not $iMod Then $iMod=3
	$sLeft=StringLeft($sString,$iMod)
	$sString=StringTrimLeft($sString,$iMod)
	Return $sLeft&StringRegExpReplace($sString,"(...)",",$1")
EndFunc


; ===================================================================================================================
;	--------------------	MAIN PROGRAM CODE	--------------------
; ===================================================================================================================
#include <Array.au3>

HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()
Local $hPDHQuery,$aDiskWriteCounters,$aDiskReadCounters,$iTotalDisks,$hSplash,$aDrivesPerDisk,$aMaxReadWritesPerDisk
Local $iCounterValue,$sSplashText,$sPCName=""	; $sPCName="\\AnotherPC"
Local $iMaxWriteValue=0,$iMaxReadValue=0

$hPDHQuery=_PDH_GetNewQueryHandle()
$aDiskWriteCounters=_PDH_GetDiskWriteCounters($hPDHQuery,$sPCName)
$iTotalDisks=@extended
$aDiskReadCounters=_PDH_GetDiskReadCounters($hPDHQuery,$sPCName)

; successful? Then enter loop
If @error=0 And @extended=$iTotalDisks Then
	; Extract the drive letters assigned to each physical disk
	Dim $aDrivesPerDisk[$iTotalDisks]
	Dim $aMaxReadWritesPerDisk[$iTotalDisks][2]
	For $i=0 To $iTotalDisks-1
		; Initialize Disk info strings
		$aDrivesPerDisk[$i]=StringRegExpReplace($aDiskWriteCounters[$i][0],'[^(]+\((\d+\s+[^)]+)\)\\.*','$1')
		$aDrivesPerDisk[$i]="Physical Drive #"&StringLeft($aDrivesPerDisk[$i],1)&" [Letters: "&StringReplace(StringMid($aDrivesPerDisk[$i],3),' ',', ')&']'
		; Initialize min/max values per disk
		$aMaxReadWritesPerDisk[$i][0]=0
		$aMaxReadWritesPerDisk[$i][1]=0
	Next
;~ 	_ArrayDisplay($aDrivesPerDisk,"Drives per disk")

	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_CollectQueryData($hPDHQuery)
	Sleep(250)

	$hSplash=SplashTextOn("Disk Usage Information ["&$iTotalDisks&" total Physical Disks]","",550,70+$iTotalDisks*45,Default,Default,16,Default,10)
	; Start loop
	Do
		_PDH_CollectQueryData($hPDHQuery)
		$sSplashText=""
		For $i=0 To $iTotalDisks-1
			$sSplashText&=$aDrivesPerDisk[$i]&':'&@CRLF
			; True means do *not* call _PDH_CollectQueryData for each update.  Only once per Query handle is needed
			$iCounterValue=_PDH_UpdateCounter($hPDHQuery,$aDiskReadCounters[$i][1],0,True)
			$sSplashText&="Read:"&_AddCommas($iCounterValue)&" bytes/sec"
			If $aMaxReadWritesPerDisk[$i][0]<$iCounterValue Then $aMaxReadWritesPerDisk[$i][0]=$iCounterValue
			If $iMaxReadValue<$iCounterValue Then $iMaxReadValue=$iCounterValue

			$iCounterValue=_PDH_UpdateCounter($hPDHQuery,$aDiskWriteCounters[$i][1],0,True)
			$sSplashText&=", Written:"&_AddCommas($iCounterValue)&" bytes/sec"&@CRLF
			If $aMaxReadWritesPerDisk[$i][1]<$iCounterValue Then $aMaxReadWritesPerDisk[$i][1]=$iCounterValue
			$sSplashText&="Max Read:"&_AddCommas($aMaxReadWritesPerDisk[$i][0])&" bytes/sec, Max Write:"&_AddCommas($aMaxReadWritesPerDisk[$i][1])&" bytes/sec"&@CRLF
			If $iMaxWriteValue<$iCounterValue Then $iMaxWriteValue=$iCounterValue
		Next
		$sSplashText&="Overall - Read Maximum:"&_AddCommas($iMaxReadValue)&" bytes/sec, "& _
			"Write Maximum:"&_AddCommas($iMaxWriteValue)&" bytes/sec"&@CRLF&"[Esc] exits"
		ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
		Sleep(200)
	Until $bHotKeyPressed
EndIf

_PDH_FreeQueryHandle($hPDHQuery)
_PDH_UnInit()
