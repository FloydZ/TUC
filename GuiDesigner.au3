#Include <GUIConstants.au3>
#Include <Constants.au3>

; Create Edit Window
Dim $CtrlType, $BtnText, $BtnXPos, $BtnYPos, $ChkText, $ChkXPos, $ChkYPos, $InpText, $InpXPos, $InpYPos, $LblText, $LblXPos, $LblYPos, $RadText, $RadXPos, $RadYPos, $CmbText, $CmbXPos, $CmbYPos
Dim $EdtText, $EdtXPos, $EdtYPos, $MnuText, $MnuSub1, $MnuSub2, $ImgFile, $ImgXPos, $ImgYPos
$CreateWindow = GUICreate("Autoit GUI Designer", 400, 330)
$File = GUICtrlCreateMenu("File")
$Exit = GuiCtrlCreateMenuItem("Exit", $File)
$Options = GUICtrlCreateMenu("Options")
$ManualEdit = GUICtrlCreateMenuItem("Manual Edit", $Options)
GUICtrlCreateLabel("GUI Name", 10, 28)
$GUIName = GUICtrlCreateInput("", 70, 25, 100)
GUICtrlCreateLabel("Bk Color", 10, 68)
$GUIBkColor = GUICtrlCreateInput("", 55, 65, 50)
GUICtrlCreateLabel("GUI Width", 120, 68)
$GUIWidth = GUICtrlCreateInput("", 175, 65, 50)
GUICtrlCreateLabel("GUI Height", 240, 68)
$GUIHeight = GUICtrlCreateInput("", 300, 65, 50)
$GUIAddCtrl = GUICtrlCreateCombo("", 130, 115, 140)
GUICtrlSetData(-1,"Select A Control To Add|Button|CheckBox|InputField|Label|Radio|Combo|EditWindow|Menu|Image", "Select A Control To Add")
$SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
$Browse = GuiCtrlCreatelabel("", 1, 1)
GUISetState(@SW_SHOW, $CreateWindow)


While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $Exit
            Exit
        Case $ManualEdit
            OpenEdit()
        Case $SaveWin
            SaveWin($CtrlType)
        Case $Browse
            $ImgFile = FileOpenDialog("Select an Image", @DesktopDir, "Images (*.jpg;*.bmp;*.gif)")
        Case $GUIAddCtrl
            $AddCtrl = GUICtrlRead($GUIAddCtrl)
            Switch $AddCtrl
            Case "Button"
                AddButton()
            Case "CheckBox"
                AddCheck()
            Case "InputField"
                AddInput()
            Case "Label"
                AddLabel()
            Case "Radio"
                AddRadio()
            Case "Combo"
                AddCombo()
            Case "EditWindow"
                AddEdit()
            Case "Menu"
                AddMenu()
            Case "Image"
                AddImage()
            EndSwitch
        EndSwitch
    WEnd

; Functions
Func SaveWin($CtrlType)
    $Reading = FileOpen(@ScriptDir & "\CodeFile.au3", 0)
    $Reading = FileRead($Reading)
    FileClose($Reading)
    $Writing = FileOpen(@ScriptDir & "\CodeFile.au3", 1)
    If StringInStr($Reading, "$MainWindow") = 0 Then
        $GUIName = GuiCtrlRead($GUIName)
        $GUIBkColor = GuiCtrlRead($GUIBkColor)
        $GUIWidth = GuiCtrlRead($GUIWidth)
        $GUIHeight = GuiCtrlRead($GUIHeight)
        $GUIData = "$MainWindow = GUICreate('" & $GUIName & "', " & $GUIWidth & ", " & $GUIHeight & ")"
        FileWriteLine($Writing, $GUIData)
        If $GUIBkColor <> "" Then
            $BkColorSet = "GUICtrlSetBkColor($MainWindow, " & $GUIBkColor & ")"
            FileWriteLine($Writing, $BkColorSet)
        Else
        EndIf
    EndIf
    If $CtrlType == "Button" Then
        $BtnText = GUICtrlRead($BtnText)
        $BtnXPos = GUICtrlRead($BtnXPos)
        $BtnYPos = GUICtrlRead($BtnYPos)
        Dim $BtnData = "$" & $BtnText & " = GUICtrlCreateButton('" & $BtnText & "', " & $BtnXPos & ", " & $BtnYPos & ")"
        FileWriteLine($Writing, $BtnData)
        MsgBox(0, "Done", "Button Created")
    ElseIf $CtrlType == "CheckBox" Then
        $ChkText = GUICtrlRead($ChkText)
        $ChkXPos = GUICtrlRead($ChkXPos)
        $ChkYPos = GUICtrlRead($ChkYPos)
        Dim $ChkData = "$" & $ChkText & " = GUICtrlCreateCheckbox('" & $ChkText & "', " & $ChkXPos & ", " & $ChkYPos & ")"
        FileWriteLine($Writing, $ChkData)
        MsgBox(0, "Done", "CheckBox Created")
    ElseIf $CtrlType == "Input" Then
        $InpText = GUICtrlRead($InpText)
        $InpXPos = GUICtrlRead($InpXPos)
        $InpYPos = GUICtrlRead($InpYPos)
        Dim $InpData = "$" & $InpText & " = GUICtrlCreateInput('" & $InpText & "', " & $InpXPos & ", " & $InpYPos & ")"
        FileWriteLine($Writing, $InpData)
        MsgBox(0, "Done", "Input Created")
    ElseIf $CtrlType == "Label" Then
        $LblText = GUICtrlRead($LblText)
        $LblXPos = GUICtrlRead($LblXPos)
        $LblYPos = GUICtrlRead($LblYPos)
        Dim $LblData = "GUICtrlCreateLabel('" & $LblText & "', " & $LblXPos & ", " & $LblYPos & ")"
        FileWriteLine($Writing, $LblData)
        MsgBox(0, "Done", "Label Created")
    ElseIf $CtrlType == "Radio" then
        $RadText = GUICtrlRead($RadText)
        $RadXPos = GUICtrlRead($RadXPos)
        $RadYPos = GUICtrlRead($RadYPos)
        Dim $RadData = "$" & $RadText & " = GUICtrlCreateRadio('" & $RadText & "', " & $RadXPos & ", " & $RadYPos & ")"
        FileWriteLine($Writing, $RadData)
        MsgBox(0, "Done", "Radio Created")
    ElseIf $CtrlType == "Combo" Then
        $CmbText = GUICtrlRead($CmbText)
        $CmbXPos = GUICtrlRead($CmbXPos)
        $CmbYPos = GUICtrlRead($CmbYPos)
        Dim $CmbData = "$" & $CmbText & " = GUICtrlCreateCombo('" & $CmbText & "', " & $CmbXPos & ", " & $CmbYPos & ")"
        Dim $CmdAddData = "GUICtrlSetData(-1, 'More1|More2|More3')"
        FileWriteLine($Writing, $CmbData)
        ;FileWriteLine($Writing, $CmbAddData)
        MsgBox(0, "Done", "Combo Created")
    ElseIf $CtrlType == "EditWindow" Then
        $EdtText = GUICtrlRead($EdtText)
        $EdtXPos = GUICtrlRead($EdtXPos)
        $EdtYPos = GUICtrlRead($EdtYPos)
        Dim $EdtData = "GUICtrlCreateEdit('" & $EdtText & "', " & $EdtXPos & ", " & $EdtYPos & ")"
        FileWriteLine($Writing, $EdtData)
        MsgBox(0, "Done", "Edit Window Created")
    ElseIf $CtrlType == "Menu" Then
        $MnuText = GUICtrlRead($MnuText)
        $MnuSub1 = GUICtrlRead($MnuSub1)
        $MnuSub2 = GUICtrlRead($MnuSub2)
        Dim $MnuData = "GUICtrlCreateMenu('" & $MnuText & "')"
        Dim $MnuSub1Data = "GUICtrlCreateMenuItem('" & $MnuSub1 & "', $" & $MnuText & ")"
        Dim $MnuSub1Data = "GUICtrlCreateMenuItem('" & $MnuSub2 & "', $" & $MnuText & ")"
        FileWriteLine($Writing, $MnuData)
        FileWriteLine($Writing, $MnuSub1Data)
        ;FileWriteLine($Writing, $MnuSub2Data)
        MsgBox(0, "Done", "Menu Created")
    ElseIf $CtrlType == "Image" Then
        $ImgFile = GUICtrlRead($ImgFile)
        $ImgXPos = GUICtrlRead($ImgXPos)
        $ImgYPos = GUICtrlRead($ImgYPos)
        Dim $ImgData = "GUICtrlCreatePic('" & $ImgFile & "', " & $ImgXPos & ", " & $ImgYPos & ")"
        FileWriteLine($Writing, $ImgData)
        MsgBox(0, "Done", "Image Created")
    EndIf
        FileClose($Writing)
        GUIDelete($CreateWindow)
        RemakeGUI1()
EndFunc

Func AddButton()
    $CtrlType = "Button"
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $BtnText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $BtnXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $BtnYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddCheck()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $ChkText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $ChkXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $ChkYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddInput()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $InpText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $InpXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $InpYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddLabel()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $LblText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $LblXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $LblYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddRadio()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $RadText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $RadXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $RadYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddCombo()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $CmbText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $CmbXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $CmbYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddEdit()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $EdtText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $EdtXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $EdtYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddMenu()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("Text", 10, 153)
    $MnuText = GUICtrlCreateInput("", 50, 150, 100)
    GUICtrlCreateLabel("Item1", 165, 153)
    $MnuSub1 = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Item2", 265, 153)
    $MnuSub2 = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func AddImage()
    GUIDelete($CreateWindow)
    RemakeGUI()
    GUICtrlCreateLabel("File", 10, 153)
    $Browse = GUICtrlCreateButton("Browse", 50, 150)
    GUICtrlCreateLabel("X Pos", 165, 153)
    $ImgXPos = GUICtrlCreateInput("", 200, 150, 50)
    GUICtrlCreateLabel("Y Pos", 265, 153)
    $ImgYPos = GUICtrlCreateInput("", 300, 150, 50)
    $SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
EndFunc

Func RemakeGUI1()
$CreateWindow = GUICreate("Autoit GUI Designer", 400, 330)
$File = GUICtrlCreateMenu("File")
$Exit = GuiCtrlCreateMenuItem("Exit", $File)
$Options = GUICtrlCreateMenu("Options")
$ManualEdit = GUICtrlCreateMenuItem("Manual Edit", $Options)
GUICtrlCreateLabel("GUI Name", 10, 28)
$GUIName = GUICtrlCreateInput("", 70, 25, 100)
GUICtrlCreateLabel("Bk Color", 10, 68)
$GUIBkColor = GUICtrlCreateInput("", 55, 65, 50)
GUICtrlCreateLabel("GUI Width", 120, 68)
$GUIWidth = GUICtrlCreateInput("", 175, 65, 50)
GUICtrlCreateLabel("GUI Height", 240, 68)
$GUIHeight = GUICtrlCreateInput("", 300, 65, 50)
$GUIAddCtrl = GUICtrlCreateCombo("", 130, 115, 140)
GUICtrlSetData(-1,"Select A Control To Add|Button|CheckBox|InputField|Label|RadioC|Combo|EditWindow|Menu|Image", "Select A Control To Add")
$SaveWin = GuiCtrlCreateButton(" Save Data ", 160, 270)
GUISetState(@SW_SHOW, $CreateWindow)
EndFunc

Func RemakeGUI()
$CreateWindow = GUICreate("Autoit GUI Designer", 400, 330)
$File = GUICtrlCreateMenu("File")
$Exit = GuiCtrlCreateMenuItem("Exit", $File)
$Options = GUICtrlCreateMenu("Options")
$ManualEdit = GUICtrlCreateMenuItem("Manual Edit", $Options)
GUICtrlCreateLabel("GUI Name", 10, 28)
$GUIName = GUICtrlCreateInput("", 70, 25, 100)
GUICtrlCreateLabel("Bk Color", 10, 68)
$GUIBkColor = GUICtrlCreateInput("", 55, 65, 50)
GUICtrlCreateLabel("GUI Width", 120, 68)
$GUIWidth = GUICtrlCreateInput("", 175, 65, 50)
GUICtrlCreateLabel("GUI Height", 240, 68)
$GUIHeight = GUICtrlCreateInput("", 300, 65, 50)
$GUIAddCtrl = GUICtrlCreateCombo("", 130, 115, 140)
GUICtrlSetData(-1,"Select A Control To Add|Button|CheckBox|InputField|Label|Radio|Combo|EditWindow|Menu|Image", "Select A Control To Add")
GUISetState(@SW_SHOW, $CreateWindow)
EndFunc

Func OpenEdit()
    $GUIName = GuiCtrlRead($GUIName)
    $CodeFile = FileOpen(@ScriptDir & "\CodeFile.au3", 0)
    $CodeFile = FileRead($CodeFile)
    $Edit = GUICreate("Edit", 500, 400)
    $EditBox = GUICtrlCreateEdit($CodeFile, 5, 5, 490, 360)
    FileClose($CodeFile)
    $SaveMan = GUICtrlCreateButton("  Save  ", 225, 370)
    GUISetState(@SW_SHOW, $Edit)

    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $SaveMan
                $EditBox = GUICtrlRead($EditBox)
                $WriteCode = FileOpen(@ScriptDir & "\CodeFile.au3", 2)
                FileWrite($WriteCode, $EditBox)
                FileClose($WriteCode)
                MsgBox(0, "File saved", "Script Saved.")
            Case $GUI_EVENT_CLOSE
                GUISetState(@SW_HIDE,$Edit)
                ExitLoop
        EndSwitch
    WEnd
EndFunc