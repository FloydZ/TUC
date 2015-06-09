#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#Include <GuiSlider.au3>
#include "Bass.au3"
#include "BASSFX.au3"
#include "BassMix.au3"
#include "BassExt.au3"

DirCreate(@TempDir & "\TUP\MusicEngine")

;FileInstall("C:\Users\omasgehstock\Desktop\Meine Scripte\FinalPacker\Engine\MusicEngine\bass.dll",@TempDir & "\TUP\MusicEngine\")
;FileInstall("C:\Users\omasgehstock\Desktop\Meine Scripte\FinalPacker\Engine\MusicEngine\bass_fx.dll",@TempDir & "\TUP\MusicEngine\")
;FileInstall("C:\Users\omasgehstock\Desktop\Meine Scripte\FinalPacker\Engine\MusicEngine\basscd.dll",@TempDir & "\TUP\MusicEngine\")
;FileInstall("C:\Users\omasgehstock\Desktop\Meine Scripte\FinalPacker\Engine\MusicEngine\bassExt.dll",@TempDir & "\TUP\MusicEngine\")
;FileInstall("C:\Users\omasgehstock\Desktop\Meine Scripte\FinalPacker\Engine\MusicEngine\bassmix.dll",@TempDir & "\TUP\MusicEngine\")



Func _Set_Bar($MusicHandle, $Name)

EndFunc ;==>_Set_Bar

Func _Set_Icon()

EndFunc ;==>_Set_Icon

Func _GetBPM_ForListView()

EndFunc ;==>_GetBPM_ForListView



Func _CreateMusic($File,$Mode)

EndFunc

Func _PlayMusic($Mixer)
	_BASS_ChannelPlay($Mixer, True)
	$Playingstatus = 1
EndFunc

Func _PauseMusic($Mixer)
	_BASS_ChannelPause($Mixer)
	$Playingstatus = 0

EndFunc

Func _SetEqualizer($Lo, $Mi, $Hi)

EndFunc

Func _RemoveEqualizer($Lo = False, $Mi = False, $Hi = False)

EndFunc

Func _ReleaseEqualizer()
	
EndFunc

Func _SetVolumen($hMixer,$Vol)

EndFunc

Func _IsPlaying($hMixer)
	
EndFunc

Func _SetPan($Side,$pan)


EndFunc

Func _SetPosition($hMixer,$Pos)
	
EndFunc


Func _Crossfader($Crossfader,$Left,$Right)

EndFunc

Func _PitchControle($musichandle, $mode,$pitch)

EndFunc
#cs
Func _Set3DEnv()
_BASS_Get3DFactors($dist,$roll,$Double)
If @error Then ConsoleWrite("Error: " & @error)
ConsoleWrite("Dist: " & $dist & @lf)
ConsoleWrite("Roll: " & $roll & @LF)
ConsoleWrite("Double: " & $Double & @lf)
EndFunc

#ce


