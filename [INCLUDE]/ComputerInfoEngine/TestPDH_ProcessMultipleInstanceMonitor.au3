#include <Array.au3>
#include <_PDH_ProcessCounters.au3>

;   --------------------    HOTKEY FUNCTION & VARIABLE --------------------

Global $bHotKeyPressed=False

Func _EscPressed()
    $bHotKeyPressed=True
EndFunc


;   --------------------    MAIN PROGRAM CODE   --------------------

HotKeySet("{Esc}", "_EscPressed")

_PDH_Init()
Local $hSplash,$sSplashText,$sProcess,$iBadCounters=0
Local $aProcesses,$aCounters,$iTemp,$iProcIndex,$iTotal,$iLastPID=0,$iCounterValue

$sProcess="explorer.exe"
$aProcesses=ProcessList($sProcess)
$iTotal=$aProcesses[0][0]
If @error Or $iTotal=0 Then Exit _PDH_UnInit()

MsgBox(0, "Process count",$iTotal,1)

Dim $aCounters[$iTotal]	; Hold the counters in the array

; Create all the process counters
For $i = 0 to $iTotal-1
    $aCounters[$i]=_PDH_ProcessObjectCreate($sProcess,$aProcesses[$i+1][1])
	If @error Then $iBadCounters+=1
    _PDH_ProcessObjectAddCounters($aCounters[$i],6) ; "% Processor Time"
	; Create baseline (initial sleep will come AFTER all collected)
	_PDH_ProcessObjectCollectQueryData($aCounters[$i])
Next
$iLastPID=$aProcesses[$i][1]

; at least some good counters? Then enter loop
If $iBadCounters<>$iTotal Then
	; 2nd part of baseline-sleep model (before 'real' collection of counters begins)
	Sleep(250)

	$hSplash=SplashTextOn("'"&$sProcess&"' Processes Info","",360,160,Default,Default,16)
	Do
		; Check for new processes
		$aProcesses=ProcessList($sProcess)
		If @error Or $aProcesses[0][0]=0 Then ExitLoop
		; If more processess than we currently have, or last PID doesn't match, we better add new ones
		;	(note: terminated ones are caught elsewhere
		If $aProcesses[0][0]>$iTotal Or $aProcesses[$aProcesses[0][0]][1]<>$iLastPID Then
			$iTemp=$aProcesses[0][0]
			; Move backwards to find a PID that matches up
			For $iTemp=$aProcesses[0][0] To 1 Step -1
				If $iLastPID=$aProcesses[$iTemp][1] Then
					ConsoleWrite("Last total:"&$iTotal&", new total:"&$aProcesses[0][0]&", match to Last PID found at $iTemp="&$iTemp&@CRLF)
					$iProcIndex=$iTemp+1	; set location in ProcessList where to start adding new counters from (1 past match)
					; Found a match, now to calculate how many new Counters to add
					$iTemp=$aProcesses[0][0]-$iTemp
					If $iTemp<=0 Then ExitLoop
					ConsoleWrite("_New counters calculated [new total-$iTemp]="&$iTemp&@CRLF)
					; Resize the array to accomomodate the new counters
					ReDim $aCounters[$iTotal+$iTemp]
					; Add in the new counters
					For $i=$iTotal To $iTotal+$iTemp-1
						$aCounters[$i]=_PDH_ProcessObjectCreate($sProcess,$aProcesses[$iProcIndex][1])
						_PDH_ProcessObjectAddCounters($aCounters[$i],6) ; "% Processor Time"
						; Create baseline (initial sleep will come AFTER all collected)
						_PDH_ProcessObjectCollectQueryData($aCounters[$i])
						$iProcIndex+=1
					Next
					$iTotal+=$iTemp
					ConsoleWrite("New Counters added, new Total:"&$iTotal&@CRLF)
					; 2nd part of baseline-sleep model, required for new additions as well
					Sleep(250)
					ExitLoop
				EndIf
			Next
		EndIf
		$sSplashText=""
		; Update all Process counters
		$i=0
		Do
			$iCounterValue=_PDH_ProcessObjectUpdateCounters($aCounters[$i],0)
			If @error=1 Or @error=32 Then
				ConsoleWrite("Process died. removing. New total:"&$iTotal-1&@CRLF)
;~ 				_PDH_ProcessObjectDestroy($aCounters[$i])	; it's dead, and already destroyed if @error=1 or =32
				_ArrayDelete($aCounters,$i)	; Shift the array contents around
				$iTotal-=1	; 1 less!
				$i-=1		; to compensate for the upcoming increment
				If $iTotal=0 Then ExitLoop 2	; did they all die!?
			Else
				If Not @error Then $iCounterValue=Round($iCounterValue/$_PDH_iCPUCount)
				$sSplashText&="PID #"&_PDH_ProcessObjectGetPID($aCounters[$i])&" = "&$iCounterValue&"% CPU Usage"&@CRLF
			EndIf
			$i+=1
		Until $i=$iTotal
		$iLastPID=_PDH_ProcessObjectGetPID($aCounters[$iTotal-1])
		$sSplashText&="[Esc] exits"
        ControlSetText($hSplash,"","[CLASS:Static; INSTANCE:1]",$sSplashText)
#cs
		If 1 Then
			$aProcesses=ProcessList($sProcess)
			Dim $aTemp[$aProcesses[0][0]+1][2]
			$iTemp=0
			$aTemp[0][0]="ProcessList"
			$aTemp[0][1]="CounterList"
			For $i=1 To $aProcesses[0][0]
				$aTemp[$i][0]=$aProcesses[$i][1]
				If $iTemp<$iTotal Then $aTemp[$i][1]=_PDH_ProcessObjectGetPID($aCounters[$iTemp])
				$iTemp+=1
			Next
			_ArrayDisplay($aTemp,"List compare")
		EndIf
#ce
		Sleep(100)
    Until $bHotKeyPressed Or $iTotal=0
	WinClose($hSplash)
EndIf

; Destroy all the Process counters
For $i = 0 to $iTotal-1
    $aCounters[$i]=_PDH_ProcessObjectDestroy($aCounters[$i])
Next

_PDH_UnInit()