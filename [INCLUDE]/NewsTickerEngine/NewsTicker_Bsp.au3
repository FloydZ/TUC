#cs
================================ NewsTicker - Eigenschaften========================================

- Nachrichten werden endlos, nacheinander in einem Tickerfeld angezeigt.
- Text- und Hintergrundfarbe, Textstyle, Font und Fontattribute sind frei einstellbar.
- Die Länge des Tickers ist so zu bemessen, dass die längste Nachricht dargestellt werden kann.
- Bewegt man den Cursor auf den Ticker wird dieser ausgeblendet, die Nachricht wird sofort in
  voller Länge angezeigt und der Ticker stoppt.
- Nach Verlassen des Tickers wird der Cursor wieder sichtbar und die nächste Nachricht tickert.
- Die Nachrichten lassen sich auch mit einer Referenz, z.B. mit einem Web-Link verknüpfen.
- Dann wird der Cursor über dem Ticker als Hand angezeigt.
- Dem Klick auf das Ctrl ($hTicker[0]) kann dann die die _GetRef Funktion zugeordnet werden
  um einen hinterlegten Web-Link z.B. im Standard-Browser aufzurufen oder ein hinterlegtes
  Programm auszuführen.
- Um ein Flickern zu vermeiden, ist in der GUI der Ex-Style "$WS_EX_COMPOSITED" zu setzen.


================================ FUNKTIONSÜBERSICHT ===============================================

_GUICtrlNewsTicker_Create($iLeft, $iTop, $iWidth, $iHeight, $iForeColor, $iBackColor=-2)

	Erstellt das Newsticker-Ctrl. Als Ctrl-Variable MUSS "$hTicker" verwendet werden.
	Grund: Aktualisierung erfolgt in (parameterloser) Adlib-Funktion.
	Die Variable muss Global deklariert werden.
	BackColor ist stamdardmäßig auf Transparenz gesetzt.
	Font, Style und Farben lassen sich auch später, wie beim Label, mit der ID ($hTicker[0]) ändern.


_GUICtrlNewsTicker_NewsSet(ByRef $aID, $sNews, $sDelim=Default, $iLinkMode=0)

	Dem Ctrl werden die Nachrichten zugeordnet.
	Übergeben werden sie in einem String, getrennt durch Opt('DataSeparatorChar'), i.d.R. '|'.
	Optional kann ein eigener Trenner übergeben werden um z.B. direkt aus einer Datei einzulesen.
	Es können auch Nachrichten mit hinterlegter Referenz genutzt werden ($iLinkMode=1).
	Hier muss jede Nachricht so aufgebaut sein:
	'NACHRICHT href="WEB-LINK"' oder 'href="DATEIPFAD"'.
	Einfache Anführungszeichen dürfen für die Referenzabgrenzung NICHT genutzt werden.
	Es ist auch möglich nur eine Einzelnachricht an den Ticker zu übergeben.
	Wird diese Funktion erneut aufgerufen, werden die alten Nachrichten damit ersetzt.


_GUICtrlNewsTicker_SetState(ByRef $aID, $iState=-1, $iDelayMsg=-1, $iDelayChar=-1)

	Hier wird der Status des Ctrl gesetzt:
	- $iState  0/1  inaktiv/aktiv
	- $iDelayMsg    Verzögerung zwischen 2 Nachrichten (ms)
	- $iDelayChar   Verzögerung zwischen 2 Zeichen (ms), Minimum ist 20
	Wird ein Parameter mit -1 übergeben, so wird dieser Parameter nicht verändert.


_GUICtrlNewsTicker_GetRef()

	Sind die Nachrichten im Link-Modus hinterlegt, wird die aktuell im Ticker angezeigte Nachricht
	abgefragt und die zugehörige Referenz (Web-Link, Programmpfad etc.) zurückgegeben.

===================================================================================================
#ce

#include 'NewsTicker.au3'

Global $hTicker ; es muß genau diese Controlbezeichnung verwendet werden, da Auswertung/Änderung der Daten in Adlib-Funktion!
Local $hGUI, $btStartStop, $btNewsSet, $btLinkNews, $currNews = 1, $sLink
Local $sNews_1 = _
'01  - Das NewsTicker-Ctrl wird wie ein Label erstellt.|' & _
'02  - Statt der Styles werden Text- und Hintergrundfarbe übergeben.|' & _
'03  - Mit der "_NewsSet"-Funktion werden die Texte gesetzt.|' & _
'04  - Standardmäßig werden die Nachrichten mit der Pipe getrennt.|' & _
'05  - Ein individuelles Trennzeichen kann optional übergeben werden.|' & _
'06  - Die "_Create"-Funktion gibt ein Array zurück mit der Ctrl-ID an Array[0].|' & _
'07  - Über die Ctrl-ID können im Nachhinein, wie beim Label, Font, Style und Farben geändert werden.|' & _
'08  - Da an die Adlib-Funktion keine Parameter übergeben werden können,|' & _
'09  - ist die Globale Deklaration der Variablen "$hTicker" mit genau diesem Namen notwendig.|' & _
'10  - Mit der Funktion "_SetState" wird der Ticker aktiviert/deaktiviert.|' & _
'11  - Weiterhin lassen sich die Verzögerungen zwischen Zeichenanzeige und neuer Nachricht setzen.|' & _
'12  - Die Zeichenverzögerung sollte ca. 40 (ms) betragen. Als Minimum sind 20 ms möglich.|' & _
'13  - Beim Erstellen werden die Delays auf 40 (f. Zeichen) und 1500 (f. Nachrichtenwechsel) gesetzt.|' & _
'14  - Um neue Nachrichten zu setzen, die Funktion "_NewsSet" mit den neuen Daten aufrufen.|' & _
'15  - Die alten Daten werden dann durch die neuen ersetzt.'
Local $sNews_2 = _
'01  - Dies sind weitere News.|' & _
'02  - Die Anzahl der einzelnen Nachrichten ist fast unbegrenzt (Arraylimit).|' & _
'03  - Es kann auch nur eine einzelne Nachricht verwendet werden.|' & _
'04  - Man kann auch News aus einer Datei lesen und dann @CRLF als Trennzeichen übergeben.|' & _
'05  - z.B. mit: _GUICtrlNewsTicker_NewsSet( $hTicker, FileRead( "Dateipfad" ), @CRLF )|' & _
'06  - Bewegt man den Cursor auf den Ticker, hält dieser an und der Cursor wird ausgeblendet.|' & _
'07  - Es wird dann sofort die gesamte Nachricht sichtbar.|' & _
'08  - Beim Verlassen des Tickerbereiches läuft dieser weiter, der Cursor wird wieder sichtbar.'
Local $sLinkNews = _
'Meine Lieblingsseite ist: AutoIt href="http://www.autoit.de/index.php?page=Portal"|' & _
'Hier findet ihr die "AutoIt-Mutterseite" href="http://www.autoitscript.com/forum/index.php?"|' & _
'Hier ist der Aufruf zum Windows-Rechner hinterlegt. href="' & @SystemDir & '\calc.exe"|' & _
'Und hier kann "Solitair" gestartet werden. href="' & @SystemDir & '\sol.exe ' & '"'

$hGUI = GUICreate('Test News-Ticker ', 525, 350, -1, -1, -1, 0x02000000) ; $WS_EX_COMPOSITED
$btStartStop = GUICtrlCreateButton('Start/Stop Ticker', 10, 20, 100, 20)
$btNewsSet = GUICtrlCreateButton('News wechseln', 10, 50, 100, 20)
$btLinkNews = GUICtrlCreateButton('Link News', 10, 80, 100, 20)
$hTicker = _GUICtrlNewsTicker_Create(1, 332, 523, 17, 0xFF0000, 0xFFFF00)
GUICtrlSetFont($hTicker[0], Default, 400, Default, 'Comic Sans MS')
_GUICtrlNewsTicker_NewsSet($hTicker, $sNews_1)


GUISetState()
_GUICtrlNewsTicker_SetState($hTicker, 1, 1000)

While True
	Switch GUIGetMsg()
		Case -3
			_GUICtrlNewsTicker_SetState($hTicker, 0)
			Exit
		Case $btStartStop
			If $hTicker[1] = 0 Then
				_GUICtrlNewsTicker_SetState($hTicker, 1)
			Else
				_GUICtrlNewsTicker_SetState($hTicker, 0)
			EndIf
		Case $btNewsSet
			If $currNews = 1 Then
				_GUICtrlNewsTicker_NewsSet($hTicker, $sNews_2)
				GUICtrlSetBkColor($hTicker[0], 0xFFFFFF)
				GUICtrlSetColor($hTicker[0], 0x0000FF)
				$currNews = 2
			Else
				_GUICtrlNewsTicker_NewsSet($hTicker, $sNews_1)
				GUICtrlSetBkColor($hTicker[0], 0xFFFF00)
				GUICtrlSetColor($hTicker[0], 0xFF0000)
				$currNews = 1
			EndIf
		Case $btLinkNews
			_GUICtrlNewsTicker_NewsSet($hTicker, $sLinkNews, -1, 1)
			GUICtrlSetBkColor($hTicker[0], 0x0000FF)
			GUICtrlSetColor($hTicker[0], 0xFFFFFF)
		Case $hTicker[0]
			$sLink = _GUICtrlNewsTicker_GetRef()
			If Not @error Then
				ConsoleWrite($sLink & @CRLF)
				If StringInStr($sLink, 'www.', 1) Then
					; eigentlich sollte: ShellExecute($sLink) funktionieren
					; bei meinem Windows bringt das aber einen PSAPI.Dll-Fehler (Prozedureinsprungpunkt nicht gefunden)
				Else
					ShellExecute($sLink)
				EndIf
			EndIf
	EndSwitch
WEnd
