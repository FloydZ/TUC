#cs
================================ NewsTicker - Eigenschaften========================================

- Nachrichten werden endlos, nacheinander in einem Tickerfeld angezeigt.
- Text- und Hintergrundfarbe, Textstyle, Font und Fontattribute sind frei einstellbar.
- Die L�nge des Tickers ist so zu bemessen, dass die l�ngste Nachricht dargestellt werden kann.
- Bewegt man den Cursor auf den Ticker wird dieser ausgeblendet, die Nachricht wird sofort in
  voller L�nge angezeigt und der Ticker stoppt.
- Nach Verlassen des Tickers wird der Cursor wieder sichtbar und die n�chste Nachricht tickert.
- Die Nachrichten lassen sich auch mit einer Referenz, z.B. mit einem Web-Link verkn�pfen.
- Dann wird der Cursor �ber dem Ticker als Hand angezeigt.
- Dem Klick auf das Ctrl ($hTicker[0]) kann dann die die _GetRef Funktion zugeordnet werden
  um einen hinterlegten Web-Link z.B. im Standard-Browser aufzurufen oder ein hinterlegtes
  Programm auszuf�hren.
- Um ein Flickern zu vermeiden, ist in der GUI der Ex-Style "$WS_EX_COMPOSITED" zu setzen.


================================ FUNKTIONS�BERSICHT ===============================================

_GUICtrlNewsTicker_Create($iLeft, $iTop, $iWidth, $iHeight, $iForeColor, $iBackColor=-2)

	Erstellt das Newsticker-Ctrl. Als Ctrl-Variable MUSS "$hTicker" verwendet werden.
	Grund: Aktualisierung erfolgt in (parameterloser) Adlib-Funktion.
	Die Variable muss Global deklariert werden.
	BackColor ist stamdardm��ig auf Transparenz gesetzt.
	Font, Style und Farben lassen sich auch sp�ter, wie beim Label, mit der ID ($hTicker[0]) �ndern.


_GUICtrlNewsTicker_NewsSet(ByRef $aID, $sNews, $sDelim=Default, $iLinkMode=0)

	Dem Ctrl werden die Nachrichten zugeordnet.
	�bergeben werden sie in einem String, getrennt durch Opt('DataSeparatorChar'), i.d.R. '|'.
	Optional kann ein eigener Trenner �bergeben werden um z.B. direkt aus einer Datei einzulesen.
	Es k�nnen auch Nachrichten mit hinterlegter Referenz genutzt werden ($iLinkMode=1).
	Hier muss jede Nachricht so aufgebaut sein:
	'NACHRICHT href="WEB-LINK"' oder 'href="DATEIPFAD"'.
	Einfache Anf�hrungszeichen d�rfen f�r die Referenzabgrenzung NICHT genutzt werden.
	Es ist auch m�glich nur eine Einzelnachricht an den Ticker zu �bergeben.
	Wird diese Funktion erneut aufgerufen, werden die alten Nachrichten damit ersetzt.


_GUICtrlNewsTicker_SetState(ByRef $aID, $iState=-1, $iDelayMsg=-1, $iDelayChar=-1)

	Hier wird der Status des Ctrl gesetzt:
	- $iState  0/1  inaktiv/aktiv
	- $iDelayMsg    Verz�gerung zwischen 2 Nachrichten (ms)
	- $iDelayChar   Verz�gerung zwischen 2 Zeichen (ms), Minimum ist 20
	Wird ein Parameter mit -1 �bergeben, so wird dieser Parameter nicht ver�ndert.


_GUICtrlNewsTicker_GetRef()

	Sind die Nachrichten im Link-Modus hinterlegt, wird die aktuell im Ticker angezeigte Nachricht
	abgefragt und die zugeh�rige Referenz (Web-Link, Programmpfad etc.) zur�ckgegeben.

===================================================================================================
#ce
;===============================================================================
; Function Name:   _GUICtrlNewsTicker_Create($iLeft, $iTop, $iWidth, $iHeight, $iForeColor, $iBackColor=-2)
; Description:     Erstellt den Newticker in einem Stadard Label-Ctrl
; Parameter(s):    $iLeft, $iTop, $iWidth, $iHeight   Position, Gr��e des Ctrl
;                  $iForeColor   Textfarbe
;                  $iBackColor   Hintergrundfarbe (Standard = -2, transparent)
; Requirement(s):  Globale Variable mit Namen "$hTicker" (GENAU DIESER NAME) zur Aufnahme des Returnwertes
; Return Value(s): Array mit 11 Elementen, Ctrl-ID an "$hTicker[0]"
;                  [ID,Status,MsgDelay,CharDelay,$aMsg,$iMsgIndex,$iCharIndex,$sCurrMsg,$iTickCount,$iPause,$iLinkMode]
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func _GUICtrlNewsTicker_Create($iLeft, $iTop, $iWidth, $iHeight, $iForeColor, $iBackColor=-2)
	Local $aID[11] = [GUICtrlCreateLabel('', $iLeft, $iTop , $iWidth , $iHeight, 0x1000), 0, 1500, 40, 0, 0, -1, '', 0, 0, 0]
	GUICtrlSetColor($aID[0], $iForeColor)
	GUICtrlSetBkColor($aID[0], $iBackColor)
	AdlibRegister('__MouseOverTicker')
	Return $aID
EndFunc  ;==>_GUICtrlNewsTicker_Create

;===============================================================================
; Function Name:   _GUICtrlNewsTicker_NewsSet(ByRef $aID, $sNews, $sDelim=Default, $iLinkMode=0)
; Description:     Ordnet dem Ticker Nachrichten zu
;                  Erneuter Aufruf ersetzt alte Werte
; Parameter(s):    $aID        die Ticker-Variable "$hTicker"
;                  $sNews      Nachrichtenstring, eine oder mehrere (getrennt durch $sDelim)
;                  $sDelim     Nachrichtentrenner, Standard = Opt('GUIDataSeparatorChar'), i.d.R. "|"
;                  $iLinkMode  erm�glicht mit jeder Nachricht eine (nicht sichtbare) Referenz zu �bergeben,
;                              z.B. Web-Link, Programmpfad; Aufbau: 'NACHRICHT href="REFERENZ"'
;                              1 = mit Referenz / 0 = keine Referenz (Standard)
;                              Abfrage der Referenz mit _GUICtrlNewsTicker_GetRef()
; Return Value(s): Anzahl der �bergebenen Nachrichten
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func _GUICtrlNewsTicker_NewsSet(ByRef $aID, $sNews, $sDelim=Default, $iLinkMode=0)
	Local $aMsg[1], $aSplit, $aLinkMsg, $pattern = "(.*)(?:href=\x22)(.*)(?:\x22)"
	If Not StringLen($sNews) Then Return 0
	_GUICtrlNewsTicker_SetState($aID, 0)
	If IsKeyword($sDelim) Or $sDelim = -1 Then $sDelim = Opt('GUIDataSeparatorChar')
	If Not $iLinkMode Then
		If Not StringInStr($sNews, $sDelim) Then
			$aSplit = StringSplit($sNews, '', 2)
			ReDim $aSplit[UBound($aSplit)+1]
			$aSplit[UBound($aSplit)-1] = $sNews
			$aMsg[0] = $aSplit
		Else
			$aMsg = StringSplit($sNews, $sDelim, 3)
			For $i = 0 To UBound($aMsg) -1
				$aSplit = StringSplit($aMsg[$i], '', 2)
				ReDim $aSplit[UBound($aSplit)+1]
				$aSplit[UBound($aSplit)-1] = $aMsg[$i]
				$aMsg[$i] = $aSplit
			Next
		EndIf
	Else
		If Not StringInStr($sNews, $sDelim) Then
			$aLinkMsg = StringRegExp($sNews, $pattern, 1)
			$aSplit = StringSplit($aLinkMsg[0], '', 2)
			ReDim $aSplit[UBound($aSplit)+2]
			$aSplit[UBound($aSplit)-2] = $aLinkMsg[1]
			$aSplit[UBound($aSplit)-1] = $aLinkMsg[0]
			$aMsg[0] = $aSplit
		Else
			$aMsg = StringSplit($sNews, $sDelim, 3)
			For $i = 0 To UBound($aMsg) -1
				$aLinkMsg = StringRegExp($aMsg[$i], $pattern, 1)
				$aSplit = StringSplit($aLinkMsg[0], '', 2)
				ReDim $aSplit[UBound($aSplit)+2]
				$aSplit[UBound($aSplit)-2] = $aLinkMsg[1]
				$aSplit[UBound($aSplit)-1] = $aLinkMsg[0]
				$aMsg[$i] = $aSplit
			Next
		EndIf
	EndIf
	$aID[4] = $aMsg
	$aID[5] = 0
	$aID[6] = -1
	$aID[7] = ''
	$aID[9] = 0
	$aID[10] = $iLinkMode
	_GUICtrlNewsTicker_SetState($aID, 1)
	Return UBound($aMsg)
EndFunc  ;==>_GUICtrlNewsTicker_NewsSet

;===============================================================================
; Function Name:   _GUICtrlNewsTicker_SetState(ByRef $aID, $iState=-1, $iDelayMsg=-1, $iDelayChar=-1)
; Description:	   Setzt Status (aktiv/inaktiv) und Verz�gerungszeiten
; Parameter(s):	   $aID         die Ticker-Variable "$hTicker"
;                  $iState      0 = inaktiv, 1 = aktiv, -1 = keine �nderung (Standard)
;                  $iDelayMsg   Verz�gerung zwischen 2 Nachrichten (ms), -1 = keine �nderung (Standard)
;                  $iDelayChar  Verz�gerung zwischen 2 Zeichen (ms), -1 = keine �nderung (Standard)
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func _GUICtrlNewsTicker_SetState(ByRef $aID, $iState=-1, $iDelayMsg=-1, $iDelayChar=-1) ; $iState: 1=Start, 0=Stop
	Local $oldState = $aID[1]
	If $iState <> -1 Then $aID[1] = $iState
	If $iDelayMsg <> -1 Then $aID[2] = $iDelayMsg
	If $iDelayChar <> -1 Then $aID[3] = $iDelayChar
	If $aID[3] < 20 Then $aID[3] = 20                     ; Mindest Zeichendelay von 20 ms
	If $oldState = 0 And $iState = 1 Then
		AdlibRegister('__GUICtrlNewsTicker_Run', $aID[3]) ; Aufruf mit Zeichen-Delay
	ElseIf $oldState = 1 And $iState = 0 Then
		AdlibUnRegister('__GUICtrlNewsTicker_Run')
	EndIf
EndFunc  ;==>_GUICtrlNewsTicker_SetState

;===============================================================================
; Function Name:   _GUICtrlNewsTicker_GetRef()
; Description:     Gibt die einer Nachricht angef�gte Referenz (Web-Link, Programmpfad, etc.) zur�ck.
;                  Es wird die aktuell im Ticker angezeigte Nachricht abgefragt.
; Return Value(s): im Link-Modus: Die hinterlegte Referenz
;                  sonst: Leerstring und @error = 1
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func _GUICtrlNewsTicker_GetRef()
	If Not IsDeclared('hTicker') Then Local $hTicker
	If Not $hTicker[10] Then Return SetError(1,0,'')
	Local $aMsg = $hTicker[4], $currNews = $aMsg[$hTicker[5]]
	Return $currNews[UBound($currNews)-2]
EndFunc  ;==>_GUICtrlNewsTicker_GetRef

;===============================================================================
; Function Name:   __GUICtrlNewsTicker_Run()
; Description:     Interne Funktion zur Darstellung der Nachrichten im Ticker
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func __GUICtrlNewsTicker_Run()
	If Not IsDeclared('hTicker') Then Local $hTicker
	Local $aMsg = $hTicker[4], $iMsgIndex = $hTicker[5], $iCharIndex = $hTicker[6], $sCurrMsg = $hTicker[7]
	Local $aCurrNews, $aRet, $iTickCount = $hTicker[8], $UbCurrNews
	If $iTickCount > 0 Then
		$aRet = DllCall("kernel32.dll", "dword", "GetTickCount")
		If $aRet[0] - $iTickCount < $hTicker[2] Then ; Pause zwischen 2 Nachrichten
			Return
		Else
			$hTicker[8] = 0
			$sCurrMsg = ''
		EndIf
	EndIf
	$aCurrNews = $aMsg[$iMsgIndex]
	$iCharIndex += 1
	$UbCurrNews = UBound($aCurrNews)-1
	If $hTicker[10] Then $UbCurrNews -= 2
	If $iCharIndex = $UbCurrNews Then
		$iMsgIndex += 1
		If $iMsgIndex = UBound($aMsg) Then $iMsgIndex = 0 ; alle Nachrichten von vorn
		$hTicker[5] = $iMsgIndex
		$iCharIndex = -1
		$hTicker[6] = $iCharIndex
		$aRet = DllCall("kernel32.dll", "dword", "GetTickCount")
		$hTicker[8] = $aRet[0]	                          ; Timer setzen f�r Nachrichtenpause
		Return
	EndIf
	$hTicker[6] = $iCharIndex
	$sCurrMsg &= $aCurrNews[$iCharIndex]
	$hTicker[7] = $sCurrMsg
	GUICtrlSetData($hTicker[0], $sCurrMsg)
EndFunc  ;==>__GUICtrlNewsTicker_Run

;===============================================================================
; Function Name:   __MouseOverTicker()
; Description:     Interne Funktion zur Regelung des Ctrl-Verhaltens, wenn die
;                  Maus im Ctrl-Bereich ist
;                 - Cursorwechsel
;                 - sofortige Vervollst�ndigung Nachrichtentext
;                 - Anhalten des Tickers
; Author(s):       BugFix (bugfix@autoit.de)
;===============================================================================
Func __MouseOverTicker()
	If Not IsDeclared('hTicker') Then Local $hTicker
	If Not $hTicker[1] Then Return
	Local $aMsg, $aCurrNews, $sCurrMsg, $aCursor = GUIGetCursorInfo(), $iCursor = 16, $iDiff = 1
	If Not IsArray($aCursor) Then Return
	If Not $hTicker[9] And $aCursor[4] = $hTicker[0] Then
		$hTicker[9] = 1
		AdlibUnRegister('__GUICtrlNewsTicker_Run')
		If $hTicker[10] Then $iCursor = 0
		GUICtrlSetCursor($hTicker[0], $iCursor)
		$aMsg = $hTicker[4]
		$aCurrNews = $aMsg[$hTicker[5]]
		$sCurrMsg = $aCurrNews[UBound($aCurrNews)-1]
		If $hTicker[10] Then $iDiff = 2
		$hTicker[6] = StringLen($sCurrMsg)-$iDiff
		GUICtrlSetData($hTicker[0], $sCurrMsg)
	ElseIf $hTicker[9] And $aCursor[4] = $hTicker[0] Then
		Return
	Else
		AdlibRegister('__GUICtrlNewsTicker_Run', $hTicker[3])
		$hTicker[9] = 0
		GUICtrlSetCursor($hTicker[0], -1)
	EndIf
EndFunc  ;==>__MouseOverTicker


