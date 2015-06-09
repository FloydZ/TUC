#include-once
#include <GdiPlus.au3>

; #FUNCTION# ======================================================================================
; Name ..........: _WinAPI_RemoveFontMemResourceEx()
; Description ...: Removes the fonts added from a memory image file.
; Syntax ........: _WinAPI_RemoveFontMemResourceEx($hFont)
; Parameters ....: $hFont    - [in] A handle to the font-resource.
; Return values .: Success   - True
;                  Failure   - False
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ RemoveFontMemResourceEx
; Example .......:
; =================================================================================================

Func _WinAPI_RemoveFontMemResourceEx($hFont)
	Local $aResult = DllCall('gdi32.dll', 'boolean', 'RemoveFontMemResourceEx', 'handle', $hFont)
	If @error Then Return SetError(@error, 0, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_RemoveFontMemResourceEx


; #FUNCTION# ======================================================================================
; Name ..........: _WinAPI_AddFontMemResourceEx()
; Description ...: Adds the font resource from a memory image to the system.
; Syntax ........: _WinAPI_AddFontMemResourceEx($pbFont, $cbFont, $pdv, $pcFonts)
; Parameters ....: $pbFont   - [in] A pointer to a font resource.
;                  $cbFont   - [in] The number of bytes in the font resource that is pointed to by pbFont.
;                  $pdv      - [in] Reserved. Must be 0.
;                  $pcFonts  - [in] A pointer to a variable that specifies the number of fonts installed.
; Return values .: Success   - the return value specifies the handle to the font added.
;                  Failure   - 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ AddFontMemResourceEx
; Example .......:
; =================================================================================================

Func _WinAPI_AddFontMemResourceEx($pbFont, $cbFont, $pdv=0, $pcFonts=0)
	Local $aResult = DllCall('gdi32.dll', 'handle', 'AddFontMemResourceEx', 'ptr', $pbFont, 'dword', $cbFont, 'ptr', $pdv, 'dword*', $pcFonts)
	If @error Then Return SetError(@error, 0, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_AddFontMemResourceEx


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_CreateFontFamilyFromName()
; Description ...: Creates a FontFamily object based on a specified font family.
; Syntax ........: _GDIPlus_CreateFontFamilyFromName($sFontname[, $hCollection = 0])
; Parameters ....: $sFontname   - [in] Name of the font family. For example, Arial.ttf is the name of the Arial font family.
;                  $hCollection - [optional] [in] Pointer to the PrivateFontCollection object to delete. (default:0)
; Return values .: Success      - a pointer to the new FontFamily object.
;                  Failure      - 0
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipCreateFontFamilyFromName
; Example .......:
; =================================================================================================

Func _GDIPlus_CreateFontFamilyFromName($sFontname, $hCollection = 0)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipCreateFontFamilyFromName', 'wstr', $sFontname, 'ptr', $hCollection, 'ptr*', 0)
	If @error Then Return SetError(1, 0, 0)
	Return SetError($aResult[0], 0, $aResult[3])
EndFunc   ;==>_GDIPlus_CreateFontFamilyFromName


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_DeletePrivateFontCollection()
; Description ...: Deletes the specified PrivateFontCollection object.
; Syntax ........: _GDIPlus_DeletePrivateFontCollection($hCollection)
; Parameters ....: $hCollection - [in] Pointer to the PrivateFontCollection object to delete.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipDeletePrivateFontCollection
; Example .......:
; =================================================================================================

Func _GDIPlus_DeletePrivateFontCollection($hCollection)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipDeletePrivateFontCollection', 'ptr*', $hCollection)
	If @error Then Return SetError(1, 0, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_GDIPlus_DeletePrivateFontCollection


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_NewPrivateFontCollection()
; Description ...: Creates an PrivateFontCollection object.
; Syntax ........: _GDIPlus_NewPrivateFontCollection()
; Parameters ....:
; Return values .: Success      - a pointer to the PrivateFontCollection object.
;                  Failure      - 0
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipNewPrivateFontCollection
; Example .......:
; =================================================================================================

Func _GDIPlus_NewPrivateFontCollection()
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipNewPrivateFontCollection', 'ptr*', 0)
	If @error Then Return SetError(1, 0, 0)
	Return SetError($aResult[0], 0, $aResult[1])
EndFunc   ;==>_GDIPlus_NewPrivateFontCollection


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_PrivateAddMemoryFont()
; Description ...: Adds a font file from memory to the private font collection.
; Syntax ........: _GDIPlus_PrivateAddMemoryFont($hCollection, $pMemory, $iLength)
; Parameters ....: $hCollection - [in] Pointer to the font collection object.
;                  $pMemory     - [in] A pointer to a font resource.
;                  $iLength     - [in] The number of bytes in the font resource that is pointed to by $pMemory.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipPrivateAddMemoryFont
; Example .......:
; =================================================================================================

Func _GDIPlus_PrivateAddMemoryFont($hCollection, $pMemory, $iLength)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipPrivateAddMemoryFont', 'ptr', $hCollection, 'ptr', $pMemory, 'int', $iLength)
	If @error Then Return SetError(1, 0, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_GDIPlus_PrivateAddMemoryFont