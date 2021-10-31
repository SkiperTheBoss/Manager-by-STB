DebugOBS:
Gui, DebugOBS:Margin, 5, 5
Gui, % "DebugOBS:+HwndDebugOBS -SysMenu" A_Space (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")

Gui, DebugOBS:Add, Tab, w525 h290, Process|Window|Position|Styles|Extended Styles|Control

Gui, DebugOBS:Tab, Process
Gui, DebugOBS:Add, Text, x15 y+15 w100, Process ID:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Process_ID ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Process Path:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 r4 vDebugOBS_Process_Path ReadOnly,

Gui, DebugOBS:Tab, Window
; Gui, DebugOBS:Add, Text, x5 y+5 w100, Window ID:
; Gui, DebugOBS:Add, Text, x5 y+5 w100, Window Class:
Gui, DebugOBS:Add, Text, x15 y+15 w100, Window Count:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_Count ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Window List:
Gui, DebugOBS:Add, ListView, x+5 yp-3 w400 r10 vDebugOBS_Window_List ReadOnly Grid -Multi NoSort gDebugOBS_Window_List, Title|ID|Class
Gui, DebugOBS:Add, Text, x15 y+5 w100, Selected Title:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Selected_Window_Title ReadOnly

Gui, DebugOBS:Tab, Position
Gui, DebugOBS:Add, Checkbox, x15 y+15 w100 Checked vDebugOBS_Window_Position_Auto_Update gDebugOBS_Window_Position_Auto_Update, Auto-Update
Gui, DebugOBS:Add, Text, x15 y+15 w100, Position v1:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_Position_v1 ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Position v2:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_Position_v2 ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Position v3:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_Position_v3 ReadOnly,

SetFormat, Integer, Hex
DebugOBS_ListBox_Styles :=
For Key, Value in WS
    DebugOBS_ListBox_Styles .= Key A_Tab Format("0x{:08X}", Value) "|"
SetFormat, Integer, Dec

Gui, DebugOBS:Tab, Style
Gui, DebugOBS:Add, Text, x15 y+15 w100, Style:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_Style ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Table:
Gui, DebugOBS:Add, ListBox, x+5 yp-3 w400 r14 vDebugOBS_Window_Styles +0x108 -E0x200 T160 HwndhDebugOBS_Window_Styles gDebugOBS_Window_Styles, % DebugOBS_ListBox_Styles
Gui, DebugOBS:Add, Button, x118 y+16 w100 h20 gDebugOBS_Window_Style_Apply, Apply
Gui, DebugOBS:Add, Button, x+5 yp w100 h20 gDebugOBS_Window_Style_Reset, Reset

SetFormat, Integer, Hex
DebugOBS_ListBox_ExStyles :=
For Key, Value in WSEx
    DebugOBS_ListBox_ExStyles .= Key A_Tab Format("0x{:08X}", Value) "|"
SetFormat, Integer, Dec

Gui, DebugOBS:Tab, Extended Styles
Gui, DebugOBS:Add, Text, x15 y+15 w100, ExStyle:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Window_ExStyle ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Table:
Gui, DebugOBS:Add, ListBox, x+5 yp-3 w400 r14 vDebugOBS_Window_ExStyles +0x108 -E0x200 T160 HwndhDebugOBS_Window_ExStyles gDebugOBS_Window_ExStyles, % DebugOBS_ListBox_ExStyles
Gui, DebugOBS:Add, Button, x118 y+16 w100 h20 gDebugOBS_Window_ExStyle_Apply, Apply
Gui, DebugOBS:Add, Button, x+5 yp w100 h20 gDebugOBS_Window_ExStyle_Reset, Reset

Gui, DebugOBS:Tab, Control
Gui, DebugOBS:Add, Text, x15 y+15 w100, Control Count:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Control_Count ReadOnly,
Gui, DebugOBS:Add, Text, x15 y+5 w100, Control List:
Gui, DebugOBS:Add, ListView, x+5 yp-3 w400 r10 vDebugOBS_Control_List ReadOnly Grid -Multi NoSort gDebugOBS_Control_List, Control|Text|ID
Gui, DebugOBS:Add, Text, x15 y+5 w100, Parent:
Gui, DebugOBS:Add, Edit, x+5 yp-3 w400 vDebugOBS_Control_Parent ReadOnly

Gui, DebugOBS:Show,, Debug OBS

Gui, DebugOBS:Submit, NoHide

DebugOBS_exRight := new Dock(Manager, DebugOBS)
DebugOBS_exRight.Position("R")

SetTimer, DebugOBS_Timer, % 1000 / 60
If (DebugOBS_Window_Position_Auto_Update)
        SetTimer, DebugOBS_Update_Window_Position, % 1000 / 60
return

DebugOBS_Window_List:
Gui, DebugOBS:Submit, NoHide
Gui, DebugOBS:Default
Gui, DebugOBS:ListView, DebugOBS_Window_List

If (A_GuiControl == "DebugOBS_Window_List" AND A_GuiControlEvent == "DoubleClick")
{
    LV_GetText(DebugOBS_Selected_Title, A_EventInfo, 1)
    LV_GetText(DebugOBS_Selected_ID, A_EventInfo, 2)

    WinGetTitle, GetTitle, % "ahk_id" A_Space DebugOBS_Selected_ID
    If (DebugOBS_Selected_Title == GetTitle)
    {
        WinGet, DebugOBS_GetControlListHWND, ControlListHwnd, % "ahk_id" A_Space DebugOBS_Selected_ID
        WinGet, DebugOBS_Get_Window_Style, Style, % "ahk_id" A_Space DebugOBS_Selected_ID
        DebugOBS_Get_Window_Style_Last := DebugOBS_Get_Window_Style
        WinGet, DebugOBS_Get_Window_ExStyle, ExStyle, % "ahk_id" A_Space DebugOBS_Selected_ID
        DebugOBS_Get_Window_ExStyle_Last := DebugOBS_Get_Window_ExStyle
        GuiControl, DebugOBS:, DebugOBS_Window_Style, % Format("0x{:08X}", DebugOBS_Get_Window_Style)
        GuiControl, DebugOBS:, DebugOBS_Window_ExStyle, % Format("0x{:08X}", DebugOBS_Get_Window_ExStyle)
        DebugOBS_GetControlListHWND := StrSplit(DebugOBS_GetControlListHWND, "`n")
        GuiControl, DebugOBS:, DebugOBS_Control_Count, % DebugOBS_GetControlListHWND.Count()
        GuiControl, DebugOBS:, DebugOBS_Selected_Window_Title, % DebugOBS_Selected_Title
        GuiControl, DebugOBS:, DebugOBS_Control_Parent,
        Gui, DebugOBS:ListView, DebugOBS_Control_List
        LV_Delete()
        Loop % DebugOBS_GetControlListHWND.Count()
        {
            WinGetTitle, Text, % "ahk_id" A_Space DebugOBS_GetControlListHWND[A_Index]
            WinGetClass, Control, % "ahk_id" A_Space DebugOBS_GetControlListHWND[A_Index]
            LV_Add("", Control, Text, DebugOBS_GetControlListHWND[A_Index])
            LV_ModifyCol(1, 120)
            LV_ModifyCol(2, 120)
            LV_ModifyCol(3, 120)
        }

        GoSub, DebugOBS_Window_Style_List
        GoSub, DebugOBS_Window_ExStyle_List
        GoSub, DebugOBS_Update_Window_Position
    }
}
return

DebugOBS_Window_Style_List:
ControlGet, GetList, List,,, % "ahk_id" A_Space hDebugOBS_Window_Styles

GetList := StrSplit(GetList, "`n")

; TODO instead of reset whole list i would prefer to check each one...
GuiControl, DebugOBS:Choose, DebugOBS_Window_Styles, 0
Loop % GetList.Count()
{
    Style := StrSplit(GetList[A_Index], A_Tab).2
    If (DebugOBS_Get_Window_Style & Style)
        GuiControl, DebugOBS:Choose, DebugOBS_Window_Styles, % A_Index
}
return

DebugOBS_Window_Styles:
Gui, DebugOBS:Submit, NoHide
If (A_GuiControl = "DebugOBS_Window_Styles" AND A_GuiControlEvent = "Normal")
{
    SetFormat, Integer, Hex
    GuiControlGet, GetList, DebugOBS:, DebugOBS_Window_Styles
    GetList := StrSplit(GetList, "|")

    Sum := 0
    Loop % GetList.Count()
    {
        Style := StrSplit(GetList[A_Index], A_Tab).2
        Sum += Style
    }

    GuiControl, DebugOBS:, DebugOBS_Window_Style, % Format("0x{:08X}", Sum)
    SetFormat, Integer, Dec
}
return

DebugOBS_Window_Style_Apply:
Gui, DebugOBS:Submit, NoHide
If (DebugOBS_Selected_ID)
    WinSet, Style, % DebugOBS_Window_Style, % "ahk_id" A_Space DebugOBS_Selected_ID
return

DebugOBS_Window_Style_Reset:
If (DebugOBS_Selected_ID)
{
    GuiControl, DebugOBS:, DebugOBS_Window_Style, % DebugOBS_Get_Window_Style_Last
    ; WinSet, Style, % DebugOBS_Get_Window_Style_Last, % "ahk_id" A_Space DebugOBS_Selected_ID
    GoSub, DebugOBS_Window_Style_List
}
return

DebugOBS_Window_ExStyle_List:
ControlGet, GetList, List,,, % "ahk_id" A_Space hDebugOBS_Window_ExStyles

GetList := StrSplit(GetList, "`n")

; TODO instead of reset whole list i would prefer to check each one...
GuiControl, DebugOBS:Choose, DebugOBS_Window_ExStyles, 0
Loop % GetList.Count()
{
    ExStyle := StrSplit(GetList[A_Index], A_Tab).2
    If (DebugOBS_Get_Window_ExStyle & ExStyle)
        GuiControl, DebugOBS:Choose, DebugOBS_Window_ExStyles, % A_Index
}
return

DebugOBS_Window_ExStyles:
Gui, DebugOBS:Submit, NoHide
If (A_GuiControl = "DebugOBS_Window_ExStyles" AND A_GuiControlEvent = "Normal")
{
    SetFormat, Integer, Hex
    GuiControlGet, GetList, DebugOBS:, DebugOBS_Window_ExStyles
    GetList := StrSplit(GetList, "|")

    Sum := 0
    Loop % GetList.Count()
    {
        ExStyle := StrSplit(GetList[A_Index], A_Tab).2
        Sum += ExStyle
    }

    GuiControl, DebugOBS:, DebugOBS_Window_ExStyle, % Format("0x{:08X}", Sum)
    SetFormat, Integer, Dec
}
return

DebugOBS_Window_ExStyle_Apply:
Gui, DebugOBS:Submit, NoHide
If (DebugOBS_Selected_ID)
    WinSet, ExStyle, % DebugOBS_Window_ExStyle, % "ahk_id" A_Space DebugOBS_Selected_ID
return

DebugOBS_Window_ExStyle_Reset:
If (DebugOBS_Selected_ID)
{
    GuiControl, DebugOBS:, DebugOBS_Window_ExStyle, % DebugOBS_Get_Window_ExStyle_Last
    ; WinSet, ExStyle, % DebugOBS_Get_Window_ExStyle_Last, % "ahk_id" A_Space DebugOBS_Selected_ID
    GoSub, DebugOBS_Window_ExStyle_List
}
return

DebugOBS_Control_List:
Gui, DebugOBS:Submit, NoHide
Gui, DebugOBS:Default
Gui, DebugOBS:ListView, DebugOBS_Control_List

If (A_GuiControl == "DebugOBS_Control_List" AND A_GuiControlEvent == "DoubleClick")
{
    LV_GetText(DebugOBS_Selected_Control_ID, A_EventInfo, 3)
    DebugOBS_Get_Parent := GetParent(DebugOBS_Selected_Control_ID)
    WinGetClass, DebugOBS_Get_Parent_Control, % "ahk_id" A_Space DebugOBS_Get_Parent
    GuiControl, DebugOBS:, DebugOBS_Control_Parent, % DebugOBS_Get_Parent A_Space "(" DebugOBS_Get_Parent_Control ")"
}
return

; If checkbox is true the Position gets automatically updated
DebugOBS_Window_Position_Auto_Update:
Gui, DebugOBS:Submit, NoHide
If (DebugOBS_Window_Position_Auto_Update)
    SetTimer, DebugOBS_Update_Window_Position, % 1000 / 60
else
    SetTimer, DebugOBS_Update_Window_Position, Off
return

; Get current Position of the Window
DebugOBS_Update_Window_Position:
; Gui, DebugOBS:Submit, NoHide
If (DebugOBS_Selected_ID)
{
    WinGetTitle, GetTitle, % "ahk_id" A_Space DebugOBS_Selected_ID
    ; ToolTip % DebugOBS_Selected_Title "`n" GetTitle
    If (DebugOBS_Selected_Title == GetTitle)
    {
        WinGetPos, DebugOBS_Get_Window_Position_v1_X, DebugOBS_Get_Window_Position_v1_Y, DebugOBS_Get_Window_Position_v1_Width, DebugOBS_Get_Window_Position_v1_Height, % "ahk_id" A_Space DebugOBS_Selected_ID
        WinGetPos(DebugOBS_Selected_ID, DebugOBS_Get_Window_Position_v2_X, DebugOBS_Get_Window_Position_v2_Y, DebugOBS_Get_Window_Position_v2_Width, DebugOBS_Get_Window_Position_v2_Height)
        WinGetPosEx(DebugOBS_Selected_ID, DebugOBS_Get_Window_Position_v3_X, DebugOBS_Get_Window_Position_v3_Y, DebugOBS_Get_Window_Position_v3_Width, DebugOBS_Get_Window_Position_v3_Height, DebugOBS_Get_Window_Position_v3_OffSet_X, DebugOBS_Get_Window_Position_v3_OffSet_Y)
        Pos_v1 := "X:" A_Space DebugOBS_Get_Window_Position_v1_X ";" A_Space "Y:" A_Space DebugOBS_Get_Window_Position_v1_Y ";" A_Space "Width:" A_Space DebugOBS_Get_Window_Position_v1_Width ";" A_Space "Height:" A_Space DebugOBS_Get_Window_Position_v1_Height
        Pos_v2 := "X:" A_Space DebugOBS_Get_Window_Position_v2_X ";" A_Space "Y:" A_Space DebugOBS_Get_Window_Position_v2_Y ";" A_Space "Width:" A_Space DebugOBS_Get_Window_Position_v2_Width ";" A_Space "Height:" A_Space DebugOBS_Get_Window_Position_v2_Height
        Pos_v3 := "X:" A_Space DebugOBS_Get_Window_Position_v3_X ";" A_Space "Y:" A_Space DebugOBS_Get_Window_Position_v3_Y ";" A_Space "Width:" A_Space DebugOBS_Get_Window_Position_v3_Width ";" A_Space "Height:" A_Space DebugOBS_Get_Window_Position_v3_Height ";" A_Space "Offset X:" A_Space DebugOBS_Get_Window_Position_v3_OffSet_X ";" A_Space "Offset Y:" A_Space DebugOBS_Get_Window_Position_v3_OffSet_Y
        If (Pos_v1 != DebugOBS_Window_Position_v1)
            GuiControl, DebugOBS:, DebugOBS_Window_Position_v1, % Pos_v1
        If (Pos_v2 != DebugOBS_Window_Position_v2)
            GuiControl, DebugOBS:, DebugOBS_Window_Position_v2, % Pos_v2
        If (Pos_v3 != DebugOBS_Window_Position_v3)
            GuiControl, DebugOBS:, DebugOBS_Window_Position_v3, % Pos_v3
    }
}
return

; Auto-Update the Process Tab
DebugOBS_Timer:
Gui, DebugOBS:Submit, NoHide

If (FileExist(SettingsData["OBS"]["Path"] "\" SettingsData["OBS"]["Execute"]))
{
    Process, Exist, % SettingsData["OBS"]["Execute"]
    Get_OBS_Process_ID := ErrorLevel
    If (Get_OBS_Process_ID != DebugOBS_Process_ID AND Get_OBS_Process_ID != false)
    {
        Gui, DebugOBS:Font, cGreen
        GuiControl, DebugOBS:Font, DebugOBS_Process_ID
        GuiControl, DebugOBS:, DebugOBS_Process_ID, % Get_OBS_Process_ID
    }
    else If (Get_OBS_Process_ID == false)
    {
        Gui, DebugOBS:Font, cRed
        GuiControl, DebugOBS:Font, DebugOBS_Process_ID
        GuiControl, DebugOBS:, DebugOBS_Process_ID, no found
    }

    WinGet, Get_OBS_Process_Path, ProcessPath, % "ahk_pid" A_Space Get_OBS_Process_ID
    ; ToolTip % Get_OBS_Process_Path
    If (Get_OBS_Process_Path != DebugOBS_Process_Path AND Get_OBS_Process_Path != false)
    {
        Gui, DebugOBS:Font, cGreen
        GuiControl, DebugOBS:Font, DebugOBS_Process_Path
        GuiControl, DebugOBS:, DebugOBS_Process_Path, % Get_OBS_Process_Path
    }
    else If (Get_OBS_Process_Path == false)
    {
        Gui, DebugOBS:Font, cRed
        GuiControl, DebugOBS:Font, DebugOBS_Process_ID
        GuiControl, DebugOBS:, DebugOBS_Process_ID, no found
    }
    WinGet, DebugOBS_Get_Window_List, List, % "ahk_pid" A_Space Get_OBS_Process_ID
    If (DebugOBS_Get_Window_List != DebugOBS_Window_Count)
        GuiControl, DebugOBS:, DebugOBS_Window_Count, % DebugOBS_Get_Window_List
    else If (DebugOBS_Get_Window_List == false AND DebugOBS_Get_Window_List != DebugOBS_Get_Window_Count)
        GuiControl, DebugOBS:, DebugOBS_Window_Count, 0
    Gui, DebugOBS:Default
    Gui, DebugOBS:ListView, DebugOBS_Window_List

    If (DebugOBS_Get_Window_List)
    {
        DebugOBS_Get_Window_List_All_A := Array()
        DebugOBS_Get_Window_List_All_B := Array()

        ; Put each Window in Array A
        Loop % DebugOBS_Get_Window_List
            DebugOBS_Get_Window_List_All_A.Push(DebugOBS_Get_Window_List%A_Index%)

        ; Put each Window from the ListView in Array B
        Loop % LV_GetCount()
        {
            LV_GetText(DebugOBS_Get_Window_Title, A_Index, 2)
            If (DebugOBS_Get_Window_Title)
                DebugOBS_Get_Window_List_All_B.Push(DebugOBS_Get_Window_Title)
        }

        ; Compare Array A and Array B and put in new Array C
        Loop % DebugOBS_Get_Window_List_All_A.Count() > DebugOBS_Get_Window_List_All_B.Count() ? DebugOBS_Get_Window_List_All_A.Count() : DebugOBS_Get_Window_List_All_B.Count()
        {
            ; If Value has not found in Array A remove it from ListView
            If (!HasVal(DebugOBS_Get_Window_List_All_A, ABC := DebugOBS_Get_Window_List_All_B[A_Index]))
            {
                Loop % LV_GetCount()
                {
                    LV_GetText(DebugOBS_Get_Window_Title, A_Index, 2)
                    If (DebugOBS_Get_Window_Title == ABC)
                        LV_Delete(A_Index)
                }
            }

            ; If Value has not found in Array B add it to ListView
            If (!HasVal(DebugOBS_Get_Window_List_All_B, DebugOBS_Get_Window_List_All_A[A_Index]))
            {
                WinGetTitle, DebugOBS_Get_Window_Title, % "ahk_id" A_Space DebugOBS_Get_Window_List_All_A[A_Index]
                WinGetClass, DebugOBS_Get_Window_Class, % "ahk_id" A_Space DebugOBS_Get_Window_List_All_A[A_Index]
                If (DebugOBS_Get_Window_List_All_A[A_Index])
                {
                    LV_Add("", DebugOBS_Get_Window_Title, DebugOBS_Get_Window_List_All_A[A_Index], DebugOBS_Get_Window_Class)
                    LV_ModifyCol(1, 120)
                    LV_ModifyCol(2, 120)
                    LV_ModifyCol(3, 120)
                }
            }
        }
    }
    else
        LV_Delete()
}
return

DebugOBSGuiSize:
AutoXYWH("w", "DebugOBS_Process_ID", "DebugOBS_Process_Path", "DebugOBS_Window_Count")
AutoXYWH("wh", "DebugOBS_Window_List")
return
