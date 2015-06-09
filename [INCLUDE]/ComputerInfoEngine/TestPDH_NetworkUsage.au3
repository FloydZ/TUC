#include <_PDH_PerformanceCounters.au3>
; ===============================================================================================================================
; <TestPDH_NetworkUsage.au3>
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

Func _PDH_GetNetworkCounters($hPDHQuery,$sPCName="")
	Local $aNetworkSentList,$aNetworkSentCounters,$aNetworkRecvdList,$aNetworkSentCounters
	Local $aCombined,$iTotalAdapters,$aTemp
	; Strip first '\' from PC Name, if passed
	If $sPCName<>"" And StringLeft($sPCName,2)="\\" Then $sPCName=StringTrimLeft($sPCName,1)

	; Network - Bytes sent per second (":510\506\(*)") or English: "\Network Interface(*)\Bytes Sent/sec"
	$aNetworkSentList=_PDH_GetCounterList(":510\506\(*)"&$sPCName)
	; Network - Bytes received per second (":510\264\(*)") or English: "\Network Interface(*)\Bytes Received/sec"
	$aNetworkRecvdList=_PDH_GetCounterList(":510\264\(*)"&$sPCName)
	If @error Or Not IsArray($aNetworkSentList) Then Return SetError(@error,@extended,"")

	; start at element 1 (element 0 countains count), -1 = to-end-of-array
	$aNetworkSentCounters=_PDH_AddCountersByArray($hPDHQuery,$aNetworkSentList,1,-1)
	$aNetworkRecvdCounters=_PDH_AddCountersByArray($hPDHQuery,$aNetworkRecvdList,1,-1)
	If @error Or Not IsArray($aNetworkSentCounters) Then Return SetError(@error,@extended,"")

	$iTotalAdapters=UBound($aNetworkSentCounters)
	If $iTotalAdapters<>UBound($aNetworkRecvdCounters) Then Return SetError(-1,0,"")

	Dim $aCombined[$iTotalAdapters*2][2]
	For $i=0 To $iTotalAdapters-1
		; Convert full paths into LAN Adapter Names while copying over data (fixed to allow parentheses inside description)
		$aTemp=StringRegExp($aNetworkSentCounters[$i][0],"\\[^\(]+\((.+)\)\\",1)	; "\\[^\(]+\(([^\)]+)\)",1)
		If Not @error Then 	$aCombined[$i][0]=$aTemp[0]
		$aCombined[$i][1]=$aNetworkSentCounters[$i][1]
		$aCombined[$iTotalAdapters+$i][0]=$aCombined[$i][0]	; Should be the same name (only this is for 'received')
		$aCombined[$iTotalAdapters+$i][1]=$aNetworkRecvdCounters[$i][1]
	Next
	Return SetExtended($iTotalAdapters,$aCombined)
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


HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()
Local $hPDHQuery,$aSentRecvdCounters,$iTotalAdapters,$hSplash
Local $iCounterValue,$sSplashText,$sPCName=""	; $sPCName="\\AnotherPC"
Local $iMaxSendValue=0,$iMaxRecvValue=0

$hPDHQuery=_PDH_GetNewQueryHandle()
$aSentRecvdCounters=_PDH_GetNetworkCounters($hPDHQuery,$sPCName)
$iTotalAdapters=@extended

; successful? Then enter loop
If @error=0 And IsArray($aSentRecvdCounters) Then
	; Create baseline & initial sleep between 1st collection and start of 'real' collection
	_PDH_CollectQueryData($hPDHQuery)
	Sleep(250)

	$hSplash=SplashTextOn("Network Usage Information ["&$iTotalAdapters&" total Adapters]","",550,70+$iTotalAdapters*30,Default,Default,16,Default,10)
	; Start loop
	Do
		_PDH_CollectQueryData($hPDHQuery)
		$sSplashText=""
		For $i=0 To $iTotalAdapters-1
			$sSplashText&=$aSentRecvdCounters[$i][0]&':'&@CRLF
			; True means do *not* call _PDH_CollectQueryData for each update.  Only once per Query handle is needed
			$iCounterValue=_PDH_UpdateCounter($hPDHQuery,$aSentRecvdCounters[$i][1],0,True)
			$sSplashText&="SENT:"&_AddCommas($iCounterValue)&" bytes/sec"
			If $iMaxSendValue<$iCounterValue Then $iMaxSendValue=$iCounterValue
			$iCounterValue=_PDH_UpdateCounter($hPDHQuery,$aSentRecvdCounters[$iTotalAdapters+$i][1],0,True)
			$sSplashText&=", RECVD:"&_AddCommas($iCounterValue)&" bytes/sec"&@CRLF
			If $iMaxRecvValue<$iCounterValue Then $iMaxRecvValue=$iCounterValue
		Next
		$sSplashText&="SEND Maxium:"&_AddCommas($iMaxSendValue)&" bytes/sec, "& _
			"RECEIVE Maximum:"&_AddCommas($iMaxRecvValue)&" bytes/sec"&@CRLF&"[Esc] exits"
		ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
		Sleep(500)
	Until $bHotKeyPressed
EndIf
_PDH_FreeQueryHandle($hPDHQuery)
_PDH_UnInit()
