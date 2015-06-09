#include "TIG.au3"
Opt('GuiOnEventMode', 1);               Black       Green       Pink       Yellow       Blue        Red        Purple       Orange     Gray
Local $Color, $Invert, $aColors[9] = [0xFF000000, 0xFF00FF00, 0xFFF004DE, 0xFFFFFF00, 0xFF00ACFF, 0xFFFF0000, 0xFF8000FF, 0xFFFF8000, 0xFFADADAD]
Local $GUI = GUICreate('TrayIcon', 200, 50)
GUISetOnEvent(-3, '_Exit', $GUI)
GUISetState()

_TIG_CreateTrayGraph(0, 1000)

While 1
    $Color = $aColors[Random(0,8,1)]
    $Invert = _Invert($Color)
    _TIG_SetBackGoundColor($Color)
    _TIG_SetBarColor($Invert)
    For $i = 0 To 16
        _TIG_UpdateTrayGraph(Random(0, 1000, 1))
        Sleep(100)
    Next
WEnd

Func _Exit()
    Exit
EndFunc   ;==>_Exit

;Returns Invert of ARGB value
Func _Invert($iValue)
    Return '0x' & Hex(BitOR(0xFF000000,(0xFFFFFFFF-$iValue)),8)
EndFunc