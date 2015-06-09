#include <_PDH_ProcessGetRelatives.au3>
; ===============================================================================================================================
; <TestPDH_ProcessGetRelatives.au3>
;
;	Test of <_PDH_ProcessGetRelatives.au3>
;
; Author: Ascend4nt
; ===============================================================================================================================

Local $iTimer=TimerInit()
Local $aParentProcess=_PDH_ProcessGetParent()
ConsoleWrite("Time for _PDH_ProcessGetParent():"&TimerDiff($iTimer)&" ms"&@CRLF)
If @error Then
	ConsoleWrite("Error getting parent process ID info, @error="&@error&@CRLF)
Else
	ConsoleWrite("For process ID#"&@AutoItPID&", Parent Process is '"&$aParentProcess[0]&"', with ID#"&$aParentProcess[1]&@CRLF)
	MsgBox(0,"Parent Process Info","For process ID#"&@AutoItPID&", Parent Process is '"&$aParentProcess[0]&"', with ID#"&$aParentProcess[1])
EndIf

MsgBox(0,"About to open/close two processes","Notepad and Paint will be opened and closed to get 'children' info."&@CRLF& _
	"If things run quickly, you will not even notice or see them pop up - but the results will be retrieved regardless")

$iNotepadPID=Run("notepad.exe")
$iPaintPID=Run("mspaint.exe")

$iTimer=TimerInit()
Local $aChildProcesses=_PDH_ProcessGetChildren()
Local $iExt=@extended
ConsoleWrite("Time for _PDH_ProcessGetChildren():"&TimerDiff($iTimer)&" ms"&@CRLF)
If $iExt=0 Then
	ConsoleWrite("No Child Processes found for PID#"&@AutoItPID&@CRLF)
Else
	ProcessClose($iNotepadPID)
	ProcessClose($iPaintPID)
	Local $sOutputStr=""
	For $i=0 To UBound($aChildProcesses)-1
		$sOutputStr&="Child Process found: Process ID#"&$aChildProcesses[$i][1]&", name: '"&$aChildProcesses[$i][0]&"'"&@CRLF
	Next
	$sOutputStr&=@CRLF&"[Original PID's retrieved from Run() for: Notepad:"&$iNotepadPID&", Paint:"&$iPaintPID&"]"
	ConsoleWrite("All ("&$iExt&") Child processes found via PDH for PID#"&@AutoItPID&':'&@CRLF&$sOutputStr&@CRLF)
	MsgBox(0,"("&$iExt&") Child Processes found via PDH for PID#"&@AutoItPID&' (all closed):',$sOutputStr)
EndIf
