DebugWindow:
Gui, DebugWindow:Margin, 5, 5
Gui, % "DebugWindow:+HwndDebugWindow -SysMenu" A_Space (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")

Gui, DebugWindow:Add, Tab, w525 h290, Process|Window|Position|Styles|Extended Styles|Control

Gui, DebugWindow:Tab, Process
Gui, DebugWindow:Add, Text, x15 y+5 w100, Process ID:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Process_ID ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100 vDebugWindow_Process_Path_Text, Process Path:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 r4 vDebugWindow_Process_Path ReadOnly,

Gui, DebugWindow:Tab, Window
; Gui, DebugWindow:Add, Text, x5 y+5 w100, Window ID:
; Gui, DebugWindow:Add, Text, x5 y+5 w100, Window Class:
Gui, DebugWindow:Add, Text, x15 y+15 w100, Window Count:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_Count ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Window List:
Gui, DebugWindow:Add, ListView, x+5 yp-3 w400 r10 vDebugWindow_Window_List ReadOnly Grid -Multi NoSort gDebugWindow_Window_List, Title|ID|Class
Gui, DebugWindow:Add, Text, x15 y+5 w100, Selected Title:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Selected_Window_Title ReadOnly

Gui, DebugWindow:Tab, Position
Gui, DebugWindow:Add, Checkbox, x15 y+15 w100 Checked vDebugWindow_Window_Position_Auto_Update gDebugWindow_Window_Position_Auto_Update, Auto-Update
Gui, DebugWindow:Add, Text, x15 y+15 w100, Position v1:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_Position_v1 ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Position v2:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_Position_v2 ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Position v3:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_Position_v3 ReadOnly,

SetFormat, Integer, Hex
DebugWindow_ListBox_Styles :=
For Key, Value in WS
    DebugWindow_ListBox_Styles .= Key A_Tab Format("0x{:08X}", Value) "|"
SetFormat, Integer, Dec

Gui, DebugWindow:Tab, Style
Gui, DebugWindow:Add, Text, x15 y+15 w100, Style:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_Style ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Table:
Gui, DebugWindow:Add, ListBox, x+5 yp-3 w400 r14 vDebugWindow_Window_Styles +0x108 -E0x200 T160 HwndhDebugWindow_Window_Styles gDebugWindow_Window_Styles, % DebugWindow_ListBox_Styles
Gui, DebugWindow:Add, Button, x118 y+16 w100 h20 gDebugWindow_Window_Style_Apply, Apply
Gui, DebugWindow:Add, Button, x+5 yp w100 h20 gDebugWindow_Window_Style_Reset, Reset

SetFormat, Integer, Hex
DebugWindow_ListBox_ExStyles :=
For Key, Value in WSEx
    DebugWindow_ListBox_ExStyles .= Key A_Tab Format("0x{:08X}", Value) "|"
SetFormat, Integer, Dec

Gui, DebugWindow:Tab, Extended Styles
Gui, DebugWindow:Add, Text, x15 y+15 w100, ExStyle:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Window_ExStyle ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Table:
Gui, DebugWindow:Add, ListBox, x+5 yp-3 w400 r14 vDebugWindow_Window_ExStyles +0x108 -E0x200 T160 HwndhDebugWindow_Window_ExStyles gDebugWindow_Window_ExStyles, % DebugWindow_ListBox_ExStyles
Gui, DebugWindow:Add, Button, x118 y+16 w100 h20 gDebugWindow_Window_ExStyle_Apply, Apply
Gui, DebugWindow:Add, Button, x+5 yp w100 h20 gDebugWindow_Window_ExStyle_Reset, Reset

Gui, DebugWindow:Tab, Control
Gui, DebugWindow:Add, Text, x15 y+15 w100, Control Count:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Control_Count ReadOnly,
Gui, DebugWindow:Add, Text, x15 y+5 w100, Control List:
Gui, DebugWindow:Add, ListView, x+5 yp-3 w400 r10 vDebugWindow_Control_List ReadOnly Grid -Multi NoSort gDebugWindow_Control_List, Control|Text|ID
Gui, DebugWindow:Add, Text, x15 y+5 w100, Parent:
Gui, DebugWindow:Add, Edit, x+5 yp-3 w400 vDebugWindow_Control_Parent ReadOnly

Gui, DebugWindow:Show,, Debug Window

Gui, DebugWindow:Submit, NoHide

DebugWindow_exLeft := new Dock(Manager, DebugWindow)
DebugWindow_exLeft.Position("L")

SetTimer, DebugWindow_Timer, % 1000 / 60
    If (DebugWindow_Window_Position_Auto_Update)
        SetTimer, DebugWindow_Update_Window_Position, % 1000 / 60
return

DebugWindow_Window_List:
Gui, DebugWindow:Submit, NoHide
Gui, DebugWindow:Default
Gui, DebugWindow:ListView, DebugWindow_Window_List

If (A_GuiControl == "DebugWindow_Window_List" AND A_GuiControlEvent == "DoubleClick")
{
    LV_GetText(DebugWindow_Selected_Title, A_EventInfo, 1)
    LV_GetText(DebugWindow_Selected_ID, A_EventInfo, 2)

    WinGetTitle, GetTitle, % "ahk_id" A_Space DebugWindow_Selected_ID
    If (DebugWindow_Selected_Title == GetTitle)
    {
        WinGet, DebugWindow_GetControlListHWND, ControlListHwnd, % "ahk_id" A_Space DebugWindow_Selected_ID
        WinGet, DebugWindow_Get_Window_Style, Style, % "ahk_id" A_Space DebugWindow_Selected_ID
        DebugWindow_Get_Window_Style_Last := DebugWindow_Get_Window_Style
        WinGet, DebugWindow_Get_Window_ExStyle, ExStyle, % "ahk_id" A_Space DebugWindow_Selected_ID
        DebugWindow_Get_Window_ExStyle_Last := DebugWindow_Get_Window_ExStyle
        GuiControl, DebugWindow:, DebugWindow_Window_Style, % Format("0x{:08X}", DebugWindow_Get_Window_Style)
        GuiControl, DebugWindow:, DebugWindow_Window_ExStyle, % Format("0x{:08X}", DebugWindow_Get_Window_ExStyle)
        DebugWindow_GetControlListHWND := StrSplit(DebugWindow_GetControlListHWND, "`n")
        GuiControl, DebugWindow:, DebugWindow_Control_Count, % DebugWindow_GetControlListHWND.Count()
        GuiControl, DebugWindow:, DebugWindow_Selected_Window_Title, % DebugWindow_Selected_Title
        GuiControl, DebugWindow:, DebugWindow_Control_Parent,
        Gui, DebugWindow:ListView, DebugWindow_Control_List
        LV_Delete()
        Loop % DebugWindow_GetControlListHWND.Count()
        {
            WinGetTitle, Text, % "ahk_id" A_Space DebugWindow_GetControlListHWND[A_Index]
            WinGetClass, Control, % "ahk_id" A_Space DebugWindow_GetControlListHWND[A_Index]
            LV_Add("", Control, Text, DebugWindow_GetControlListHWND[A_Index])
            LV_ModifyCol(1, 120)
            LV_ModifyCol(2, 120)
            LV_ModifyCol(3, 120)
        }

        GoSub, DebugWindow_Window_Style_List
        GoSub, DebugWindow_Window_ExStyle_List
        GoSub, DebugWindow_Update_Window_Position
    }
}
return

DebugWindow_Window_Style_List:
ControlGet, GetList, List,,, % "ahk_id" A_Space hDebugWindow_Window_Styles

GetList := StrSplit(GetList, "`n")

; TODO instead of reset whole list i would prefer to check each one...
GuiControl, DebugWindow:Choose, DebugWindow_Window_Styles, 0
Loop % GetList.Count()
{
    Style := StrSplit(GetList[A_Index], A_Tab).2
    If (DebugWindow_Get_Window_Style & Style)
        GuiControl, DebugWindow:Choose, DebugWindow_Window_Styles, % A_Index
}
return

DebugWindow_Window_Styles:
Gui, DebugWindow:Submit, NoHide
If (A_GuiControl = "DebugWindow_Window_Styles" AND A_GuiControlEvent = "Normal")
{
    SetFormat, Integer, Hex
    GuiControlGet, GetList, DebugWindow:, DebugWindow_Window_Styles
    GetList := StrSplit(GetList, "|")

    Sum := 0
    Loop % GetList.Count()
    {
        Style := StrSplit(GetList[A_Index], A_Tab).2
        Sum += Style
    }

    GuiControl, DebugWindow:, DebugWindow_Window_Style, % Format("0x{:08X}", Sum)
    SetFormat, Integer, Dec
}
return

DebugWindow_Window_Style_Apply:
Gui, DebugWindow:Submit, NoHide
If (DebugWindow_Selected_ID)
    WinSet, Style, % DebugWindow_Window_Style, % "ahk_id" A_Space DebugWindow_Selected_ID
return

DebugWindow_Window_Style_Reset:
If (DebugWindow_Selected_ID)
{
    GuiControl, DebugWindow:, DebugWindow_Window_Style, % DebugWindow_Get_Window_Style_Last
    ; WinSet, Style, % DebugWindow_Get_Window_Style_Last, % "ahk_id" A_Space DebugWindow_Selected_ID
    GoSub, DebugWindow_Window_Style_List
}
return

DebugWindow_Window_ExStyle_List:
ControlGet, GetList, List,,, % "ahk_id" A_Space hDebugWindow_Window_ExStyles

GetList := StrSplit(GetList, "`n")

; TODO instead of reset whole list i would prefer to check each one...
GuiControl, DebugWindow:Choose, DebugWindow_Window_ExStyles, 0
Loop % GetList.Count()
{
    ExStyle := StrSplit(GetList[A_Index], A_Tab).2
    If (DebugWindow_Get_Window_ExStyle & ExStyle)
        GuiControl, DebugWindow:Choose, DebugWindow_Window_ExStyles, % A_Index
}
return

DebugWindow_Window_ExStyles:
Gui, DebugWindow:Submit, NoHide
If (A_GuiControl = "DebugWindow_Window_ExStyles" AND A_GuiControlEvent = "Normal")
{
    SetFormat, Integer, Hex
    GuiControlGet, GetList, DebugWindow:, DebugWindow_Window_ExStyles
    GetList := StrSplit(GetList, "|")

    Sum := 0
    Loop % GetList.Count()
    {
        ExStyle := StrSplit(GetList[A_Index], A_Tab).2
        Sum += ExStyle
    }

    GuiControl, DebugWindow:, DebugWindow_Window_ExStyle, % Format("0x{:08X}", Sum)
    SetFormat, Integer, Dec
}
return

DebugWindow_Window_ExStyle_Apply:
Gui, DebugWindow:Submit, NoHide
If (DebugWindow_Selected_ID)
    WinSet, ExStyle, % DebugWindow_Window_ExStyle, % "ahk_id" A_Space DebugWindow_Selected_ID
return

DebugWindow_Window_ExStyle_Reset:
If (DebugWindow_Selected_ID)
{
    GuiControl, DebugWindow:, DebugWindow_Window_ExStyle, % DebugWindow_Get_Window_ExStyle_Last
    ; WinSet, ExStyle, % DebugWindow_Get_Window_ExStyle_Last, % "ahk_id" A_Space DebugWindow_Selected_ID
    GoSub, DebugWindow_Window_ExStyle_List
}
return

DebugWindow_Control_List:
Gui, DebugWindow:Submit, NoHide
Gui, DebugWindow:Default
Gui, DebugWindow:ListView, DebugWindow_Control_List

If (A_GuiControl == "DebugWindow_Control_List" AND A_GuiControlEvent == "DoubleClick")
{
    LV_GetText(DebugWindow_Selected_Control_ID, A_EventInfo, 3)
    DebugWindow_Get_Parent := GetParent(DebugWindow_Selected_Control_ID)
    WinGetClass, DebugWindow_Get_Parent_Control, % "ahk_id" A_Space DebugWindow_Get_Parent
    GuiControl, DebugWindow:, DebugWindow_Control_Parent, % DebugWindow_Get_Parent A_Space "(" DebugWindow_Get_Parent_Control ")"
}
return

; If checkbox is true the Position gets automatically updated
DebugWindow_Window_Position_Auto_Update:
Gui, DebugWindow:Submit, NoHide
If (DebugWindow_Window_Position_Auto_Update)
    SetTimer, DebugWindow_Update_Window_Position, % 1000 / 60
else
    SetTimer, DebugWindow_Update_Window_Position, Off
return

; Get current Position of the Window
DebugWindow_Update_Window_Position:
; Gui, DebugWindow:Submit, NoHide
If (DebugWindow_Selected_ID)
{
    WinGetTitle, GetTitle, % "ahk_id" A_Space DebugWindow_Selected_ID
    ; ToolTip % DebugWindow_Selected_Title "`n" GetTitle
    If (DebugWindow_Selected_Title == GetTitle)
    {
        WinGetPos, DebugWindow_Get_Window_Position_v1_X, DebugWindow_Get_Window_Position_v1_Y, DebugWindow_Get_Window_Position_v1_Width, DebugWindow_Get_Window_Position_v1_Height, % "ahk_id" A_Space DebugWindow_Selected_ID
        WinGetPos(DebugWindow_Selected_ID, DebugWindow_Get_Window_Position_v2_X, DebugWindow_Get_Window_Position_v2_Y, DebugWindow_Get_Window_Position_v2_Width, DebugWindow_Get_Window_Position_v2_Height)
        WinGetPosEx(DebugWindow_Selected_ID, DebugWindow_Get_Window_Position_v3_X, DebugWindow_Get_Window_Position_v3_Y, DebugWindow_Get_Window_Position_v3_Width, DebugWindow_Get_Window_Position_v3_Height, DebugWindow_Get_Window_Position_v3_OffSet_X, DebugWindow_Get_Window_Position_v3_OffSet_Y)
        Pos_v1 := "X:" A_Space DebugWindow_Get_Window_Position_v1_X ";" A_Space "Y:" A_Space DebugWindow_Get_Window_Position_v1_Y ";" A_Space "Width:" A_Space DebugWindow_Get_Window_Position_v1_Width ";" A_Space "Height:" A_Space DebugWindow_Get_Window_Position_v1_Height
        Pos_v2 := "X:" A_Space DebugWindow_Get_Window_Position_v2_X ";" A_Space "Y:" A_Space DebugWindow_Get_Window_Position_v2_Y ";" A_Space "Width:" A_Space DebugWindow_Get_Window_Position_v2_Width ";" A_Space "Height:" A_Space DebugWindow_Get_Window_Position_v2_Height
        Pos_v3 := "X:" A_Space DebugWindow_Get_Window_Position_v3_X ";" A_Space "Y:" A_Space DebugWindow_Get_Window_Position_v3_Y ";" A_Space "Width:" A_Space DebugWindow_Get_Window_Position_v3_Width ";" A_Space "Height:" A_Space DebugWindow_Get_Window_Position_v3_Height ";" A_Space "Offset X:" A_Space DebugWindow_Get_Window_Position_v3_OffSet_X ";" A_Space "Offset Y:" A_Space DebugWindow_Get_Window_Position_v3_OffSet_Y
        If (Pos_v1 != DebugWindow_Window_Position_v1)
            GuiControl, DebugWindow:, DebugWindow_Window_Position_v1, % Pos_v1
        If (Pos_v2 != DebugWindow_Window_Position_v2)
            GuiControl, DebugWindow:, DebugWindow_Window_Position_v2, % Pos_v2
        If (Pos_v3 != DebugWindow_Window_Position_v3)
            GuiControl, DebugWindow:, DebugWindow_Window_Position_v3, % Pos_v3
    }
}
return

; Auto-Update the Process Tab
DebugWindow_Timer:
Gui, Manager:Submit, NoHide
Gui, DebugWindow:Submit, NoHide

WinGet, DebugWindow_Process_ID_by_Title, PID, % Get_Window_Title
If (DebugWindow_Process_ID_by_Title != DebugWindow_Process_ID AND DebugWindow_Process_ID_by_Title)
{
    Gui, DebugWindow:Font, cGreen
    GuiControl, DebugWindow:Font, DebugWindow_Process_ID
    GuiControl, DebugWindow:, DebugWindow_Process_ID, % DebugWindow_Process_ID_by_Title
}
else If (!DebugWindow_Process_ID_by_Title)
{
    Gui, DebugWindow:Font, cRed
    GuiControl, DebugWindow:Font, DebugWindow_Process_ID
    GuiControl, DebugWindow:, DebugWindow_Process_ID, not found
}
WinGet, DebugWindow_Get_Process_Path, ProcessPath, % Get_Window_Title
If (DebugWindow_Get_Process_Path != DebugWindow_Process_Path AND Get_Select_Window_Mode == 1 AND DebugWindow_Get_Process_Path)
{
    Gui, DebugWindow:Font, cGreen
    GuiControl, DebugWindow:Font, DebugWindow_Process_Path
    GuiControl, DebugWindow:, DebugWindow_Process_Path, % DebugWindow_Get_Process_Path
}
else If (WindowsData[Get_Window_Title]["Path"] "\" WindowsData[Get_Window_Title]["Execute"] != DebugWindow_Process_Path AND Get_Select_Window_Mode == 2 AND (WindowsData[Get_Window_Title]["Path"] "\" WindowsData[Get_Window_Title]["Execute"]))
{
    Gui, DebugWindow:Font
    GuiControl, DebugWindow:Font, DebugWindow_Process_Path
    GuiControl, DebugWindow:, DebugWindow_Process_Path, % WindowsData[Get_Window_Title]["Path"] "\" WindowsData[Get_Window_Title]["Execute"]
}
else If (!DebugWindow_Get_Process_Path AND Get_Select_Window_Mode == 1 OR !(WindowsData[Get_Window_Title]["Path"] "\" WindowsData[Get_Window_Title]["Execute"]) AND Get_Select_Window_Mode == 2)
{
    Gui, DebugWindow:Font, cRed
    GuiControl, DebugWindow:Font, DebugWindow_Process_Path
    GuiControl, DebugWindow:, DebugWindow_Process_Path, not found
}

WinGet, DebugWindow_Get_Window_List, List, % "ahk_pid" A_Space DebugWindow_Process_ID_by_Title
If (DebugWindow_Get_Window_List != DebugWindow_Window_Count)
    GuiControl, DebugWindow:, DebugWindow_Window_Count, % DebugWindow_Get_Window_List
else If (DebugWindow_Get_Window_List == false AND DebugWindow_Get_Window_List != DebugWindow_Get_Window_Count)
    GuiControl, DebugWindow:, DebugWindow_Window_Count, 0
Gui, DebugWindow:Default
Gui, DebugWindow:ListView, DebugWindow_Window_List
If (DebugWindow_Get_Window_List)
{
    DebugWindow_Get_Window_List_All_A := Array()
    DebugWindow_Get_Window_List_All_B := Array()

    ; Put each Window in Array A
    Loop % DebugWindow_Get_Window_List
        DebugWindow_Get_Window_List_All_A.Push(DebugWindow_Get_Window_List%A_Index%)

    ; Put each Window from the ListView in Array B
    Loop % LV_GetCount()
    {
        LV_GetText(DebugWindow_Get_Window_Title, A_Index, 2)
        If (DebugWindow_Get_Window_Title)
            DebugWindow_Get_Window_List_All_B.Push(DebugWindow_Get_Window_Title)
    }

    ; Compare Array A and Array B and remove no equal entrys
    Loop % DebugWindow_Get_Window_List_All_A.Count() > DebugWindow_Get_Window_List_All_B.Count() ? DebugWindow_Get_Window_List_All_A.Count() : DebugWindow_Get_Window_List_All_B.Count()
    {
        ; If Value has not found in Array A remove it from ListView
        If (!HasVal(DebugWindow_Get_Window_List_All_A, ABC := DebugWindow_Get_Window_List_All_B[A_Index]))
        {
            Loop % LV_GetCount()
            {
                LV_GetText(DebugWindow_Get_Window_Title, A_Index, 2)
                If (DebugWindow_Get_Window_Title == ABC)
                    LV_Delete(A_Index)
            }
        }

        ; If Value has not found in Array B add it to ListView
        If (!HasVal(DebugWindow_Get_Window_List_All_B, DebugWindow_Get_Window_List_All_A[A_Index]))
        {
            WinGetTitle, DebugWindow_Get_Window_Title, % "ahk_id" A_Space DebugWindow_Get_Window_List_All_A[A_Index]
            WinGetClass, DebugWindow_Get_Window_Class, % "ahk_id" A_Space DebugWindow_Get_Window_List_All_A[A_Index]
            If (DebugWindow_Get_Window_List_All_A[A_Index])
            {
                LV_Add("", DebugWindow_Get_Window_Title, DebugWindow_Get_Window_List_All_A[A_Index], DebugWindow_Get_Window_Class)
                LV_ModifyCol(1, 120)
                LV_ModifyCol(2, 120)
                LV_ModifyCol(3, 120)
            }
        }
    }
}
else
    LV_Delete()
return

DebugWindowGuiSize:
AutoXYWH("w", "DebugWindow_Process_ID", "DebugWindow_Process_Path", "DebugWindow_Window_Count")
AutoXYWH("wh", "DebugWindow_Window_List")
return
