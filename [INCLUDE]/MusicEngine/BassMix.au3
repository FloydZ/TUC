#include-once
#include "Bass.au3"

Global $_ghBassMixDll = -1
Global $BASS_MIX_DLL_UDF_VER = "2.4.6.0"

Global Const $BASS_CONFIG_MIXER_FILTER = 0x10600
Global Const $BASS_CONFIG_MIXER_BUFFER = 0x10601
Global Const $BASS_CONFIG_SPLIT_BUFFER = 0x10610
Global Const $BASS_MIXER_END = 0x10000
Global Const $BASS_MIXER_NONSTOP = 0x20000
Global Const $BASS_MIXER_RESUME = 0x1000
Global Const $BASS_MIXER_FILTER = 0x1000
Global Const $BASS_MIXER_BUFFER = 0x2000
Global Const $BASS_MIXER_MATRIX = 0x10000
Global Const $BASS_MIXER_PAUSE = 0x20000
Global Const $BASS_MIXER_DOWNMIX = 0x400000
Global Const $BASS_MIXER_NORAMPIN = 0x800000
Global Const $BASS_MIXER_ENV_FREQ = 1
Global Const $BASS_MIXER_ENV_VOL = 2
Global Const $BASS_MIXER_ENV_PAN = 3
Global Const $BASS_MIXER_ENV_LOOP = 0x10000
Global Const $BASS_SYNC_MIXER_ENVELOPE = 0x10200
Global Const $BASS_CTYPE_STREAM_MIXER = 0x10800
Global Const $BASS_CTYPE_STREAM_SPLIT = 0x10801
Global Const $BASS_MIXER_NODE = "uint64 pos; float value"


; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_MIX_Startup
; Description ...: Starts up BASS functions.
; Syntax.........: _BASS_MIX_Startup($sBassMixDLL)
; Parameters ....:  -	$sBassMixDLL	-	The relative path to BassMix.dll.
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- $BASS_ERR_DLL_NO_EXIST	-	File could not be found.
;								  If the version of this UDF is not compatabile with this version of Bass, then the following
;								  error will be displayed to the user.  This can be disabled by setting
;										$BASS_STARTUP_BYPASS_VERSIONCHECK = 1
;								  This is the error show to the user:
;									 	This version of Bass.au3 is not made for Bass.dll VX.X.X.X.  Please update.
; Author ........: Prog@ndy
; Modified.......: Brett Francis (BrettF)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_MIX_Startup($sBassMixDLL = "")
	If Not $sBassMixDLL Then $sBassMixDLL = @ScriptDir & "\BassMix.dll"
	;Check if bass has already been started up.
	If $_ghBassMixDll <> -1 Then Return True
	;Check if $sBassMixDLL exists.
	If Not FileExists($sBassMixDLL) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)
	;is dll 32bit or 64bit?
	Local $sBit = __BASS_LibraryGetArch($sBassMixDLL)
	Select
		Case $sBit = "32" And @AutoItX64
			ConsoleWrite(@CRLF & "!BassMix.dll is for 32bit only!" & @CRLF & "Run/compile Script at 32bit" & @CRLF)
		Case $sBit = "64" And Not @AutoItX64
			ConsoleWrite(@CRLF & "!BassMix.dll is for 64bit only!" & @CRLF & "use 32bit version of BassMix.dll" & @CRLF)
	EndSelect
	;Check to make sure that the version of Bass.DLL is compatabile with this UDF version.  If not we will throw a text error.
	;Then we will exit the program
	If $BASS_STARTUP_BYPASS_VERSIONCHECK Then
		If _VersionCompare(FileGetVersion($sBassMixDLL), $BASS_MIX_DLL_UDF_VER) = -1 Then
			MsgBox(0, "ERROR", "This version of BASSMIX.au3 is made for Bassmix.dll V" & $BASS_MIX_DLL_UDF_VER & ".  Please update")
			Exit
		EndIf
	EndIf
	;Open the DLL
	$_ghBassMixDll = DllOpen($sBassMixDLL)

	;Check if the DLL was opened correctly.
	Return $_ghBassMixDll <> -1
EndFunc   ;==>_BASS_MIX_Startup



; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelFlags()
; Description ...: Modifies and retrieves a channel's mixer flags.
; Syntax.........: Func _BASS_Mixer_ChannelFlags($handle, $flags, $mask)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$flags 			-	A combination of these flags.
;							-	$BASS_MIXER_BUFFER	Buffer the sample data, for use by BASS_Mixer_ChannelGetData  and BASS_Mixer_ChannelGetLevel.
;							-	$BASS_MIXER_FILTER	Filter the sample data when resampling.
;							-	$BASS_MIXER_LIMIT	Limit the mixer processing to the amount of data available from this source. This flag can only be applied to one source per mixer, so it will automatically be removed from any other source of the same mixer.
;							-	$BASS_MIXER_NORAMPIN	Don't ramp-in the start, including after seeking (BASS_Mixer_ChannelSetPosition).
;							-	$BASS_MIXER_PAUSE	Pause processing of the source.
;							-	$BASS_STREAM_AUTOFREE	Automatically free the source channel when it ends.
;							-	$BASS_SPEAKER_xxx	Speaker assignment flags.
;					-	$mask 			-	The flags (as above) to modify. Flags that are not included in this are left as they are, so it can be set to 0 in order to just retrieve the current flags. To modify the speaker flags, any of the BASS_SPEAKER_
; Return values .: Success      - the channel's updated flags are returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelFlags($handle, $flags, $mask)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "dword", "BASS_Mixer_ChannelFlags", "dword", $handle, "dword", $flags, "dword", $mask)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelFlags

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetData()
; Description ...: Retrieves the immediate sample data (or an FFT representation of it) of a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelGetData($handle, $buffer, $length)
; Parameters ....:  -	$handle 			-	The channel handle.
;					-	$buffer 			-	Location to write the data.
;					-	$length 			-	Number of bytes wanted, and/or the following flags.
;							-	$BASS_DATA_FLOAT	Return floating-point sample data.
;							-	$BASS_DATA_FFT256	256 sample FFT (returns 128 floating-point values)
;							-	$BASS_DATA_FFT512	512 sample FFT (returns 256 floating-point values)
;							-	$BASS_DATA_FFT1024	1024 sample FFT (returns 512 floating-point values)
;							-	$BASS_DATA_FFT2048	2048 sample FFT (returns 1024 floating-point values)
;							-	$BASS_DATA_FFT4096	4096 sample FFT (returns 2048 floating-point values)
;							-	$BASS_DATA_FFT8192	8192 sample FFT (returns 4096 floating-point values)
;							-	$BASS_DATA_FFT_INDIVIDUAL	Use this flag to request separate FFT data for each channel. The size of the data returned (as listed above) is multiplied by the number channels.
;							-	$BASS_DATA_FFT_NOWINDOW	This flag can be used to prevent a Hanning window being applied to the sample data when performing an FFT.
;							-	$BASS_DATA_AVAILABLE	Query the amount of data the channel has buffered. buffer is ignored when using this flag.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetData($handle, $buffer, $length)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "dword", "BASS_Mixer_ChannelGetData", "dword", $handle, "ptr", $buffer, "dword", $length)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelGetData

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetEnvelopePos()
; Description ...: Retrieves the current position and value of an envelope on a channel.
; Syntax.........: Func _BASS_Mixer_ChannelGetEnvelopePos($handle, $type)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$type 			-	The envelope to get the position/value of. One of the following.
;							-	$BASS_MIXER_ENV_FREQ	Sample rate.
;							-	$BASS_MIXER_ENV_VOL	Volume.
;							-	$BASS_MIXER_ENV_PAN	Panning/balance.
; Return values .: Success      - Array:  $aReturn[0]: envelope position
;                                         $aReturn[1]: envelope value
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetEnvelopePos($handle, $type)
	Local $value
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "uint64", "BASS_Mixer_ChannelGetEnvelopePos", "dword", $handle, "dword", $type, "float*", $value)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = -1 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Local $aReturn[2]
	$aReturn[0] = $BASS_ret_[0]
	$aReturn[1] = $BASS_ret_[3]
	Return $aReturn
EndFunc   ;==>_BASS_Mixer_ChannelGetEnvelopePos

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetLevel()
; Description ...: Retrieves the level (peak amplitude) of a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelGetLevel($handle)
; Parameters ....:  -	$handle 		-	The channel handle.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetLevel($handle)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "dword", "BASS_Mixer_ChannelGetLevel", "dword", $handle)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelGetLevel

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetMatrix()
; Description ...: Retrieves a channel's mixing matrix, if it has one.
; Syntax.........: Func _BASS_Mixer_ChannelGetMatrix($handle, $matrix)
; Parameters ....:  -	$handle 			-	The channel handle.
;					-	$matrix 			-	optional - Pointer to a DllStruct to write the matrix.
; Return values .: Success      - If $matrix is DllStruct: Returns True
;                               - else Returns Array: $aReturn[0][0]: number of destination (mixer) channels
;                                                     $aReturn[0][1]: number of source channels (source stream)
;                                                     $aReturn[1][1]: value of first dest / first source
;                                                     $aReturn[1][2]: value of first dest / second source
;                                                     $aReturn[2][1]: value of second dest / first source
;                                                     $aReturn[2][2]: value of second dest / second source
;                                                      ...
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetMatrix($handle, $matrix = 0)
	If $matrix And IsPtr($matrix) Then
		Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelGetMatrix", "dword", $handle, "ptr", $matrix)
		If @error Then Return SetError(1, 1, 0)
		If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
		Return $BASS_ret_[0]
	Else
		Local $iSChans, $iDChans, $hMixer, $aSInfo, $aDInfo
		$hMixer = _BASS_Mixer_ChannelGetMixer($handle)
		$aSInfo = _BASS_ChannelGetInfo($handle)
		$aDInfo = _BASS_ChannelGetInfo($hMixer)
		If Not IsArray($aSInfo) Or Not IsArray($aDInfo) Then Return SetError(1, 0, 0)
		Local $aReturn[$aDInfo[1] + 1][$aSInfo[1] + 1]
		$aReturn[0][0] = $aDInfo[1]
		$aReturn[0][1] = $aSInfo[1]
		Local $tStruct = DllStructCreate("float[" & $aDInfo[1] * $aSInfo[1] & "]")
		Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelGetMatrix", "dword", $handle, "ptr", DllStructGetPtr($tStruct))
		If @error Then Return SetError(1, 1, 0)
		If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
		For $i = 1 To $aDInfo[1]
			For $j = 1 To $aSInfo[1]
				$aReturn[$i][$j] = DllStructGetData($tStruct, 1, ($i - 1) * $aSInfo[1] + $j)
			Next
		Next
		Return $aReturn
	EndIf
EndFunc   ;==>_BASS_Mixer_ChannelGetMatrix

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetMixer()
; Description ...: Retrieves the mixer that a channel is plugged into.
; Syntax.........: Func _BASS_Mixer_ChannelGetMixer($handle)
; Parameters ....:  -	$handle 			-	The channel handle.
; Return values .: Success      - the mixer stream's handle is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetMixer($handle)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "hwnd", "BASS_Mixer_ChannelGetMixer", "dword", $handle)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelGetMixer

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelGetPosition()
; Description ...: Retrieves the playback position of a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelGetPosition($handle, $mode)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$mode 			-	How to retrieve the position. One of the following.
;							-	$BASS_POS_BYTE	Get the position in bytes.
;							-	$BASS_POS_MUSIC_ORDER	Get the position in orders and rows... LOWORD = order, HIWORD = row * scaler (BASS_ATTRIB_MUSIC_PSCALER). (HMUSIC only)
;							-	$other modes may be supported by add-ons, see the documentation.
; Return values .: Success      - the channel's position is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelGetPosition($handle, $mode)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "uint64", "BASS_Mixer_ChannelGetPosition", "dword", $handle, "dword", $mode)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = -1 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelGetPosition

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelRemove()
; Description ...: Unplugs a channel from a mixer.
; Syntax.........: Func _BASS_Mixer_ChannelRemove($handle)
; Parameters ....:  -	$handle 			-	The handle of the channel to unplug.
; Return values .: Success      - Returns TRUE
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelRemove($handle)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelRemove", "dword", $handle)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelRemove

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelRemoveSync()
; Description ...: Removes a synchronizer from a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelRemoveSync($handle, $sync)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$sync 			-	Handle of the synchronizer to remove.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelRemoveSync($handle, $sync)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelRemoveSync", "dword", $handle, "hwnd", $sync)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelRemoveSync

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelSetEnvelope()
; Description ...: Sets an envelope to modify the sample rate, volume or pan of a channel over a period of time.
; Syntax.........: Func _BASS_Mixer_ChannelSetEnvelope($handle, $type, $nodes)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$type 			-	The attribute to modify with the envelope. One of the following.
;							-	$BASS_MIXER_ENV_FREQ	Sample rate.
;							-	$BASS_MIXER_ENV_VOL	Volume.
;							-	$BASS_MIXER_ENV_PAN	Panning/balance.
;							-	$BASS_MIXER_ENV_LOOP	Loop the envelope. This is a flag and can be used in combination with any of the above.
;					-	$nodes          -   Array:     $aNodes[0][0]: number of elements
;                                                      $aNodes[1][0]: position in bytes of first node
;                                                      $aNodes[1][0]: value of first node
;                                                       ...
;                                                      $aNodes[n][0]: position in bytes of "n" node
;                                                      $aNodes[n][0]: value of "n" node
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelSetEnvelope($handle, $type, $nodes)
	If IsArray($nodes) And UBound($nodes, 2) = 2 Then
		Local $sStruct = ""
		For $i = 1 To $nodes[0][0]
			$sStruct &= "uint64;float;"
		Next
		Local $tNodes = DllStructCreate($sStruct)
		Local $count = $nodes[0][0]
		For $i = 1 To $count
			DllStructSetData($tNodes, $i * 2 - 1, $nodes[$i][0])
			DllStructSetData($tNodes, $i * 2, $nodes[$i][1])
		Next
		$nodes = DllStructGetPtr($tNodes)
	Else
		Return SetError(1, 1, 0)
	EndIf
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelSetEnvelope", "dword", $handle, "dword", $type, "ptr", $nodes, "dword", $count)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelSetEnvelope

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelSetEnvelopePos()
; Description ...: Sets the current position of an envelope on a channel.
; Syntax.........: Func _BASS_Mixer_ChannelSetEnvelopePos($handle, $type, $pos)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$type 			-	The envelope to set the position of. One of the following.
;							-	$BASS_MIXER_ENV_FREQ	Sample rate.
;							-	$BASS_MIXER_ENV_VOL	Volume.
;							-	$BASS_MIXER_ENV_PAN	Panning/balance.
;					-	$pos 			-	The new envelope position, in bytes. If this is beyond the end of the envelope it will be capped or looped, depending on whether the envelope has looping enabled.
; Return values .: Success      - the current position of the envelope is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelSetEnvelopePos($handle, $type, $pos)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelSetEnvelopePos", "dword", $handle, "dword", $type, "uint64", $pos)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelSetEnvelopePos

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelSetMatrix()
; Description ...: Sets a channel's mixing matrix, if it has one.
; Syntax.........: Func _BASS_Mixer_ChannelSetMatrix($handle, $matrix)
; Parameters ....:  -	$handle 			-	The channel handle.
;					-	$matrix 			-	Array of the matrix OR
;                                               Pointer to a DllStruct of the matrix.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......: if $matrix is an Array:
;                               $matrix[0][0]: number of destination (mixer) channels
;                               $matrix[0][1]: number of source channels (source stream)
;                               $matrix[1][1]: value of first dest / first source
;                               $matrix[1][2]: value of first dest / second source
;                               $matrix[1][3]: value of first dest / third source
;                                ...
;                               $matrix[2][1]: value of second dest / first source
;                               $matrix[2][2]: value of second dest / second source
;                                ...
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelSetMatrix($handle, $matrix)
	Select
		Case IsPtr($matrix)
			Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelSetMatrix", "dword", $handle, "ptr", $matrix)
			If @error Then Return SetError(1, 1, 0)
			If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
			Return $BASS_ret_[0]
		Case IsArray($matrix)
			Local $tStruct = DllStructCreate("float[" & $matrix[0][0] * $matrix[0][1] & "]")
			For $i = 1 To $matrix[0][0]
				For $j = 1 To $matrix[0][1]
					DllStructSetData($tStruct, 1, $matrix[$i][$j], ($i - 1) * $matrix[0][1] + $j)
				Next
			Next
			Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelSetMatrix", "dword", $handle, "ptr", DllStructGetPtr($tStruct))
			If @error Then Return SetError(1, 1, 0)
			If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
			Return $BASS_ret_[0]
		Case Else
			Return SetError(1, 0, 0)
	EndSelect
EndFunc   ;==>_BASS_Mixer_ChannelSetMatrix

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelSetPosition()
; Description ...: Sets the playback position of a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelSetPosition($handle, $pos, $mode)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$pos 			-	The position, in units determined by the
;					-	$mode 			-	How to set the position. One of the following, with optional flags.
;							-	$BASS_POS_BYTE	The position is in bytes, which will be rounded down to the nearest sample boundary.
;							-	$BASS_POS_MUSIC_ORDER	The position is in orders and rows... use MAKELONG(order,row). (HMUSIC only)
;							-	$BASS_MUSIC_POSRESET	Flag: Stop all notes. This flag is applied automatically if it has been set on the channel, eg. via BASS_ChannelFlags. (HMUSIC)
;							-	$BASS_MUSIC_POSRESETEX	Flag: Stop all notes and reset bpm/etc. This flag is applied automatically if it has been set on the channel, eg. via BASS_ChannelFlags. (HMUSIC)
;							-	$BASS_MIXER_NORAMPIN	Flag: Don't ramp-in the start after seeking. This flag is applied automatically if it has been set on the channel, eg. via BASS_Mixer_ChannelFlags.
;							-	$other modes & flags may be supported by add-ons, see the documentation.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelSetPosition($handle, $pos, $mode)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_ChannelSetPosition", "dword", $handle, "uint64", $pos, "dword", $mode)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_ChannelSetPosition

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_ChannelSetSync()
; Description ...: Sets up a synchronizer on a mixer source channel.
; Syntax.........: Func _BASS_Mixer_ChannelSetSync($handle, $type, $param, $user)
; Parameters ....:  -	$handle 		-	The channel handle.
;					-	$type 			-	The type of sync. This can be one of the standard sync types, as available via
;					-	$param 			-	The sync parameter.
;					-	$user 			-	User instance data to pass to the callback function.
; Return values .: Success      - the new synchronizer's handle is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_ChannelSetSync($handle, $type, $param, $proc = 0, $user = 0)
	Local $proc_s = -1
	If IsString($proc) Then
		$proc_s = DllCallbackRegister($proc, "ptr", "dword;dword;dword;ptr")
		$proc = DllCallbackGetPtr($proc_s)
	EndIf
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "hwnd", "BASS_Mixer_ChannelSetSync", "dword", $handle, "dword", $type, "uint64", $param, "ptr", $proc, "ptr", $user)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	If $BASS_ret_[0] = 0 Then
		If $proc_s <> -1 Then DllCallbackFree($proc_s)
		Return SetError(_BASS_ErrorGetCode(), 0, 0)
	EndIf
	Return SetExtended($proc_s, $BASS_ret_[0])
EndFunc   ;==>_BASS_Mixer_ChannelSetSync

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_GetVersion()
; Description ...: Retrieves the version of BASSmix that is loaded.
; Syntax.........: Func _BASS_Mixer_GetVersion()
; Parameters ....:  -
; Return values .: Success      - Returns The BASSmix version. For example, 0x02040103 (hex), would be version 2.4.1.3
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_GetVersion()
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "dword", "BASS_Mixer_GetVersion")
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_GetVersion

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_StreamAddChannel()
; Description ...: Plugs a channel into a mixer.
; Syntax.........: Func _BASS_Mixer_StreamAddChannel($handle, $channel, $flags)
; Parameters ....:  -	$handle 			-	The mixer handle.
;					-	$channel 			-	The handle of the channel to plug into the mixer... a HMUSIC, HSTREAM or HRECORD.
;					-	$flags 			-	Any combination of these flags.
;							-	$BASS_MIXER_MATRIX	Creates a channel matrix, allowing the source's channels to be sent to any of the mixer output channels, at any levels. The matrix can be retrieved and modified via the BASS_Mixer_ChannelGetMatrix  and BASS_Mixer_ChannelSetMatrix  functions. The matrix will initially contain a one-to-one mapping, eg. left out = left in, right out = right in, etc...
;							-	$BASS_MIXER_DOWNMIX	If the source has more channels than the mixer output (and the mixer is stereo or mono), then a channel matrix is created, initialized with the appropriate downmixing matrix. Note the source data is assumed to follow the standard channel ordering, as described in the STREAMPROC documentation.
;							-	$BASS_MIXER_BUFFER	Buffer the sample data, for use by BASS_Mixer_ChannelGetData and BASS_Mixer_ChannelGetLevel. This increases memory requirements, so should not be enabled needlessly. The size of the buffer can be controlled via the BASS_CONFIG_MIXER_BUFFER config option.
;							-	$BASS_MIXER_FILTER	Filter the sample data when resampling, to reduce aliasing. This improves the sound quality, particularly when resampling to or from a low sample rate, but requires more processing. The precision of the filtering can be controlled via the BASS_CONFIG_MIXER_FILTER config option.
;							-	$BASS_MIXER_LIMIT	Limit the mixer processing to the amount of data available from this source, while the source is active (not ended). If the source stalls, then the mixer will too, rather than continuing to mix other sources, as it would normally do. This flag can only be applied to one source per mixer, so it will automatically be removed from any other source of the same mixer.
;							-	$BASS_MIXER_NORAMPIN	Don't ramp-in the start, including after seeking (BASS_Mixer_ChannelSetPosition). This is useful for gap-less playback, where a source channel is intended to seamlessly follow another. This does not affect volume and pan changes, which are always ramped.
;							-	$BASS_MIXER_PAUSE	Pause processing of the source. Use BASS_Mixer_ChannelFlags to resume processing.
;							-	$BASS_STREAM_AUTOFREE	Automatically free the source channel when it ends. This allows you to add a channel to a mixer and forget about it, as it will automatically be freed when it has reached the end, or when the source is removed from the mixer or when the mixer is freed.
;							-	$BASS_SPEAKER_xxx	Speaker assignment flags. Ignored when using the BASS_MIXER_MATRIX or BASS_MIXER_DOWNMIX flag. The BASS_Init BASS_DEVICE_NOSPEAKER flag has effect here.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_StreamAddChannel($handle, $channel, $flags)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_StreamAddChannel", "hwnd", $handle, "dword", $channel, "dword", $flags)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_StreamAddChannel

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_StreamAddChannelEx()
; Description ...: Plugs a channel into a mixer, optionally delaying the start and limiting the length.
; Syntax.........: Func _BASS_Mixer_StreamAddChannelEx($handle, $channel, $length)
; Parameters ....:  -	$handle 			-	The mixer handle.
;					-	$channel 			-	The handle of the channel to plug into the mixer... a HMUSIC, HSTREAM or HRECORD.
;					-	$flags	 			-	Any combination of these flags.
;							-	$BASS_MIXER_MATRIX	Creates a channel matrix, allowing the source's channels to be sent to any of the mixer output channels, at any levels. The matrix can be retrieved and modified via the BASS_Mixer_ChannelGetMatrix  and BASS_Mixer_ChannelSetMatrix  functions. The matrix will initially contain a one-to-one mapping, eg. left out = left in, right out = right in, etc...
;							-	$BASS_MIXER_DOWNMIX	If the source has more channels than the mixer output (and the mixer is stereo or mono), then a channel matrix is created, initialized with the appropriate downmixing matrix. Note the source data is assumed to follow the standard channel ordering, as described in the STREAMPROC documentation.
;							-	$BASS_MIXER_BUFFER	Buffer the sample data, for use by BASS_Mixer_ChannelGetData and BASS_Mixer_ChannelGetLevel. This increases memory requirements, so should not be enabled needlessly. The size of the buffer can be controlled via the BASS_CONFIG_MIXER_BUFFER config option.
;							-	$BASS_MIXER_FILTER	Filter the sample data when resampling, to reduce aliasing. This improves the sound quality, particularly when resampling to or from a low sample rate, but requires more processing. The precision of the filtering can be controlled via the BASS_CONFIG_MIXER_FILTER config option.
;							-	$BASS_MIXER_LIMIT	Limit the mixer processing to the amount of data available from this source, while the source is active (not ended). If the source stalls, then the mixer will too, rather than continuing to mix other sources, as it would normally do. This flag can only be applied to one source per mixer, so it will automatically be removed from any other source of the same mixer.
;							-	$BASS_MIXER_NORAMPIN	Don't ramp-in the start, including after seeking (BASS_Mixer_ChannelSetPosition). This is useful for gap-less playback, where a source channel is intended to seamlessly follow another. This does not affect volume and pan changes, which are always ramped.
;							-	$BASS_MIXER_PAUSE	Pause processing of the source. Use BASS_Mixer_ChannelFlags to resume processing.
;							-	$BASS_STREAM_AUTOFREE	Automatically free the source channel when it ends. This allows you to add a channel to a mixer and forget about it, as it will automatically be freed when it has reached the end, or when the source is removed from the mixer or when the mixer is freed.
;							-	$BASS_SPEAKER_xxx	Speaker assignment flags. Ignored when using the BASS_MIXER_MATRIX or BASS_MIXER_DOWNMIX flag. The BASS_Init BASS_DEVICE_NOSPEAKER flag has effect here.
;					-	$start	 			-	Delay (in bytes) before the channel is mixed in.
;					-	$length 			-	The maximum amount of data (in bytes) to mix... 0 = no limit. Once this end point is reached, the channel will be removed from the mixer.

; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_StreamAddChannelEx($handle, $channel, $flags, $start, $length)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Mixer_StreamAddChannelEx", "hwnd", $handle, "dword", $channel, "uint64", $length)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_StreamAddChannelEx

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Mixer_StreamCreate()
; Description ...: Creates a mixer stream.
; Syntax.........: Func _BASS_Mixer_StreamCreate($freq, $chans, $flags)
; Parameters ....:  -	$freq 			-	The sample rate of the mixer output.
;					-	$chans 			-	The number of channels... 1 = mono, 2 = stereo, 4 = quadraphonic, 6 = 5.1, 8 = 7.1.
;					-	$flags 			-	Any combination of these flags.
;							-	$BASS_SAMPLE_8BITS Produce 8 - bit output. If neither this Or the BASS_SAMPLE_FLOAT flags are specified, Then the stream is 16 - bit.
;							-	$BASS_SAMPLE_FLOAT Produce 32 - bit floating - point output. WDM drivers Or the BASS_STREAM_DECODE flag are required To use this flag In Windows. See Floating - point channels For more info.
;							-	$BASS_SAMPLE_SOFTWARE Force the stream To Not use hardware mixing. Note this only applies To playback of the mixer's output; the mixing of the source channels is always performed by BASSmix.
;							-	$BASS_SAMPLE_3D Use 3D functionality. This requires that the BASS_DEVICE_3D flag was specified when calling BASS_Init, And the stream must be mono(chans = 1). The SPEAKER flags can Not be used together With this flag.
;							-	$BASS_SAMPLE_FX
;							-	$requires DirectX 8 Or above Enable the old implementation of DirectX 8 effects. See the DX8 effect implementations section For details. Use BASS_ChannelSetFX To add effects To the stream.
;							-	$BASS_MIXER_END End the stream when there are no active(including stalled) source channels, Else it is never - ending.
;							-	$BASS_MIXER_NONSTOP Don't stop producing output when there are no active source channels, else it will be stalled until there are active sources.
;							-	$BASS_MIXER_RESUME When stalled, resume the mixer immediately upon a new Or unpaused source, Else it will be resumed at the Next update cycle.
;							-	$BASS_STREAM_AUTOFREE Automatically free the stream when playback ends.
;							-	$BASS_STREAM_DECODE Mix the sample data, without playing it. Use BASS_ChannelGetData To retrieve the mixed sample data. The BASS_SAMPLE_3D, BASS_STREAM_AUTOFREE And SPEAKER flags can Not be used together With this flag. The BASS_SAMPLE_SOFTWARE, BASS_SAMPLE_FX And BASS_MIXER_RESUME flags are also ignored.
;							-	$BASS_SPEAKER_xxx Speaker assignment flags. These flags have no effect when the stream is more than stereo.
; Return values .: Success      - the new stream's handle is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Mixer_StreamCreate($freq, $chans, $flags)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "hwnd", "BASS_Mixer_StreamCreate", "dword", $freq, "dword", $chans, "dword", $flags)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Mixer_StreamCreate

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Split_StreamCreate()
; Description ...: Creates a splitter stream.
; Syntax.........: Func _BASS_Split_StreamCreate($channel, $flags, $chanmap)
; Parameters ....:  -	$channel 		-	The handle of the channel to split... a HMUSIC, HSTREAM or HRECORD.
;					-	$flags 			-	Any combination of these flags.
;							-	$BASS_SAMPLE_SOFTWARE Force the stream To Not use hardware mixing.
;							-	$BASS_SAMPLE_3D Use 3D functionality. This requires that the BASS_DEVICE_3D flag was specified when calling BASS_Init, And the stream must be mono. The SPEAKER flags can Not be used together With this flag.
;							-	$BASS_SAMPLE_FX
;							-	$requires DirectX 8 Or above Enable the old implementation of DirectX 8 effects. See the DX8 effect implementations section For details. Use BASS_ChannelSetFX To add effects To the stream.
;							-	$BASS_STREAM_AUTOFREE Automatically free the stream when playback ends.
;							-	$BASS_STREAM_DECODE Render the sample data, without playing it. Use BASS_ChannelGetData To retrieve the sample data. The BASS_SAMPLE_3D, BASS_STREAM_AUTOFREE And SPEAKER flags can Not be used together With this flag. The BASS_SAMPLE_SOFTWARE And BASS_SAMPLE_FX flags are also ignored.
;							-	$BASS_SPEAKER_xxx Speaker assignment flags. These flags have no effect when the stream is more than stereo.
;					-	$chanmap 		-	Channel mapping... pointer to an array of channel indexes (0=first, -1=end of array), NULL = a 1:1 mapping of the source.
; Return values .: Success      - the new stream's handle is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Split_StreamCreate($channel, $flags, $chanmap)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "hwnd", "BASS_Split_StreamCreate", "dword", $channel, "dword", $flags, "ptr", $chanmap)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Split_StreamCreate

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Split_StreamGetSource()
; Description ...: Retrieves the source of a splitter stream.
; Syntax.........: Func _BASS_Split_StreamGetSource($handle)
; Parameters ....:  -	$handle 			-	The splitter stream handle.
; Return values .: Success      - the source channel's handle is returned.
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Split_StreamGetSource($handle)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "dword", "BASS_Split_StreamGetSource", "hwnd", $handle)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = $BASS_DWORD_ERR Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Split_StreamGetSource

; #FUNCTION# ====================================================================================================================
; Name...........: Func _BASS_Split_StreamReset()
; Description ...: Resets a splitter stream or all splitter streams of a source.
; Syntax.........: Func _BASS_Split_StreamReset($handle)
; Parameters ....:  -	$handle 			-	The splitter or source handle.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_Split_StreamReset($handle)
	Local $BASS_ret_ = DllCall($_ghBassMixDll, "int", "BASS_Split_StreamReset", "dword", $handle)
	If @error Then Return SetError(1, 1, 0)
	If $BASS_ret_[0] = 0 Then Return SetError(_BASS_ErrorGetCode(), 0, 0)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_Split_StreamReset