;Search.au3


;-----------------------------------------------------------------------------------------------------------------------
;	Function		_LV_Search($LV, $#include <CreateGUI.au3>
;					What2Find [, $CaseSens=True [, $Partial=False]])
;	Description		search a term in every item and subitem of a given ListView
;	Parameter		$LV				ListView -ID
;					$What2Find		Search term
;					$CaseSens       Casesensitivity True (default) or False
;					$Partial        Partialsearch, Casesens will set to False also if given True
;	Return			Success			Array[0] = LV-Index
;									Array[1] = SubItem-Index
;					Failure			Return -1 and set @error : 	1 - ListView is empty
;																2 - $What2Find was not found
;	Requirements	#include <GuiListView.au3>



Func _LV_Search($LV, $What2Find, $CaseSens = True, $Partial = False)
	$count = _GUICtrlListView_GetItemCount($LV)
	Local $aOut[2] = [-1, 0]
	If $count < 1 Then
		SetError(1)
		Return -1
	EndIf
	If $Partial Then $CaseSens = False
	$countSub = _GUICtrlListView_GetColumnCount($LV)
	For $i = 0 To $count - 1
		For $k = 0 To $countSub - 1
			If $CaseSens Then
				If _GUICtrlListView_GetItemText($LV, $i, $k) == $What2Find Then
					$aOut[0] = $i
					$aOut[1] = $k
					Return $aOut
				EndIf
			Else
				If Not $Partial Then
					If _GUICtrlListView_GetItemText($LV, $i, $k) = $What2Find Then
						$aOut[0] = $i
						$aOut[1] = $k
						Return $aOut
					EndIf
				Else
					If StringInStr(_GUICtrlListView_GetItemText($LV, $i, $k), $What2Find, 1) Then
						$aOut[0] = $i
						$aOut[1] = $k
						Return $aOut
					EndIf
				EndIf
			EndIf
		Next
	Next
	SetError(2)
	Return -1
EndFunc ;==>_LV_Search


Func _SearchText($1, $2, $case = 0)
	GUISetState(@SW_SHOW, $Form)
EndFunc ;==>_SearchText

