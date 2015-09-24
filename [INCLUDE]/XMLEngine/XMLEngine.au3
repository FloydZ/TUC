#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#Include <GuiListView.au3>
#include "_XMLDomWrapper.au3"
#Include <String.au3>

DirCreate(@TempDir & "\TUP\SignatureEngine")
;FileInstall("C:\Users\\Desktop\MeineScripts\FinalPacker\Engine\SignatureEngine\IMAGE_FILE_MACHINE_AMD64.xml",@TempDir & "\TUP\SignatureEngine\")
;FileInstall("C:\Users\\Desktop\MeineScripts\FinalPacker\Engine\SignatureEngine\IMAGE_FILE_MACHINE_I386.xml",@TempDir & "\TUP\SignatureEngine\")
;FileInstall("C:\Users\\Desktop\MeineScripts\FinalPacker\Engine\SignatureEngine\IMAGE_FILE_MACHINE_IA64.xml",@TempDir & "\TUP\SignatureEngine\")
;FileInstall("C:\Users\\Desktop\MeineScripts\FinalPacker\Engine\SignatureEngine\PLATFORM_INDEPENDENT.xml",@TempDir & "\TUP\SignatureEngine\")

Dim $IMAGE_FILE_MACHINE_I386 = @ScriptDir & "\IMAGE_FILE_MACHINE_I386.XML"
Dim $IMAGE_FILE_MACHINE_AMD64 = @ScriptDir & "\IMAGE_FILE_MACHINE_AMD64.XML"
Dim $IMAGE_FILE_MACHINE_IA64 = @ScriptDir & "\IMAGE_FILE_MACHINE_IA64.XML"
Dim $PLATFORM_INDEPENDENT = @ScriptDir & "\PLATFORM_INDEPENDENT.XML"
Dim $value[2799][2]

;_Get_Signature($IMAGE_FILE_MACHINE_I386,1,"")


Func _Get_Signature($IMAGE,$Format,$Listview)
ConsoleWrite("Starting to load the " & $IMAGE &  " Database")
_XMLFileOpen($IMAGE)
;Von rechts teilen wo das erste " " ist
$Timer_for_Calc_Signature = TimerInit()
$Return = _XMLGetChildren("SIGNATURES")
;ReDim $Names[$max]
For $x = 1 to $Return [0][0]

	$pos =  StringInStr($Return[$x][1]," ","",-1)

	$value[$x][0] = StringLeft($Return[$x][1],$pos)
		;ConsoleWrite($value[$x][1]); NAME
	$value[$x][1] = StringRight($Return[$x][1],StringLen($Return[$x][1]) - StringInStr($Return[$x][1]," ","",-1))
		;ConsoleWrite($value[$x][1] & @lf) ; ENTRYPE
		;zurückgegeben werden hex zahlen die aneinander gereit sind
		; also wird alle zwei ziffern ein " " eingefügt
	If $Format = 1 Then
		For $y = 2 To StringLen($value[$x][1]) * 2 Step 3
			$value[$x][1] = _StringInsert($value[$x][1]," ",$y)
			
		Next
	Endif
	IniWrite(@ScriptDir & "\packsig1.ini",$value[$x][0],"Signature",$value[$x][1])
Next

;@ScriptDir & "\packsig1.ini"
ConsoleWrite("Loaded the " & $IMAGE & " Database" & @lf)
ConsoleWrite("Timer needed to load the Signatures = " & Round(TimerDiff($Timer_for_Calc_Signature)/1000,2) & "s" & @lf)
EndFunc

Func _GetSignature2($File)
$Sections = IniReadSectionNames($File)
Dim $SIG[$Sections[0]][3]
For $x = 1 to $Sections[0]
	$Read = IniRead($File, $Sections[$x],"Signature","00")
	$EP = IniRead($File, $Sections[$x],"ep_only","00")
	
	$SIG[$x][0] = $Sections[$x]
	$SIG[$x][1] = $Read
	$SIG[$x][2] = $EP
	ConsoleWrite($x & @lf)
	If $x = 879 Then _ArrayDisplay($SIG)
Next
_ArrayDisplay($SIG)
EndFunc






Func _Get_Entry($NR,$Edit)
GUICtrlSetData($Edit,$value[$NR][1])
EndFunc
