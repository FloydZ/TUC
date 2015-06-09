#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include "_PDH_TaskMgrSysStats.au3"
#include "_PDH_ProcessAllCounters.au3"
#include "_PDH_PerformanceCounters.au3"
#include "_WinAPI_GetPerformanceInfo.au3"	; Gather System Cache info.
#include "_WinAPI_GetSystemInfo.au3"
Local $aPDH_Processes, $String = "Search...|"

Func _ComputerInfo_FillTreeView()
	
	_PDH_Init()  
	_PDH_ProcessAllInit("1410;6;180;684","0;"&$_PDH_iCPUCount&";1024;"&$PDH_TIME_CONVERSION)
	$aPDH_Processes=_PDH_ProcessAllUpdateCounters()
	
	_GUICtrlTreeView_BeginUpdate($TreeView[2])
	_GUICtrlTreeView_DeleteAll($TreeView[2])
	For $i=3 To $aPDH_Processes[0][0]
		$aPDH_Processes[$i][5]=_WinTime_LocalFileTimeFormat($aPDH_Processes[$i][5],4,1,True);SchönHeitsGründe
		$String &= $aPDH_Processes[$i][0] & "|" 
		
		$Ret = _ComputerInfo_HasParent($i)
		If  $Ret = False Then
			_GUICtrlTreeView_Add($TreeView[2], 0, $aPDH_Processes[$i][1] & "  " & $aPDH_Processes[$i][0])
		Else
			_GUICtrlTreeView_AddChildFirst($TreeView[2], $Ret,  $aPDH_Processes[$i][1] & "  " & $aPDH_Processes[$i][0])
		EndIf
	Next
	_GUICtrlTreeView_EndUpdate($TreeView[2])
	GUICtrlSetData($Combo[6], $String, "Search...")
	
	;_ArrayDisplay($aPDH_Processes)
	;MsgBox(0,"",$String)
EndFunc

Func _ComputerInfo_HasParent($NR)
	$Sibling = _GUICtrlTreeView_GetFirstItem($TreeView[2])
	Do
		$Sibling = 	_GUICtrlTreeView_GetNext($TreeView[2], $Sibling)
		If $aPDH_Processes[$NR][2] = _ComputerInfo_GetPidFromTreeViewItemHandle($Sibling) Then Return $Sibling
	Until $Sibling = 0	
	Return False
EndFunc

Func _ComputerInfo_GetPidFromTreeViewItemHandle($Handle)
	$Text = _GUICtrlTreeView_GetText($Treeview[2], $Handle)
	Return StringMid($Text,1,StringInStr($Text, "  ", 2, 1, 1, 7))
EndFunc

Func _ComputerInfo_DisplayInfo($PID)
	$Index = _ComputerInfo_GetArrayIndexFromPID($PID)
	
EndFunc

Func _ComputerInfo_GetArrayIndexFromPID($PID)
	For $i=3 To $aPDH_Processes[0][0]
		If $aPDH_Processes[$i][1] = $PID Then Return $i
	Next
	Return -1
EndFunc