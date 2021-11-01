#SingleInstance force
#Persistent
; #NoTrayIcon
#NoEnv

#Include %A_ScriptDir%\include\AutoXYWH.ahk
#Include %A_ScriptDir%\include\WinGetPosEx.ahk
#Include %A_ScriptDir%\include\WinGetPos.ahk
#Include %A_ScriptDir%\include\SetParent.ahk
#Include %A_ScriptDir%\include\JSON.ahk
#Include %A_ScriptDir%\include\OBS.ahk
#Include %A_ScriptDir%\include\OBSCommand.ahk
#Include %A_ScriptDir%\include\CLI.ahk
#Include %A_ScriptDir%\include\Dock.ahk
#Include %A_ScriptDir%\include\Array.ahk
#Include %A_ScriptDir%\include\Borders.ahk
#Include %A_ScriptDir%\include\Display.ahk
#Include %A_ScriptDir%\include\ClipCursor.ahk
#Include %A_ScriptDir%\include\SystemCursor.ahk
#Include %A_ScriptDir%\include\WS.ahk
#Include %A_ScriptDir%\include\IsFullscreen.ahk
#Include %A_ScriptDir%\include\ScreenCapture.ahk

; OnExit, Exit

Menu, Tray, NoStandard
Menu, Tray, Add, &Show, ManagerGuiShow
Menu, Tray, Default, &Show
Menu, Tray, Add, &Exit, Exit
; Menu, Tray, NoIcon
Menu, Tray, Click, 1

GroupAdd, OBS_Previews, Windowed Projector (Program)
GroupAdd, OBS_Previews, Windowed Projector (Preview)
GroupAdd, OBS_Previews, Fullscreen Projector (Program)
GroupAdd, OBS_Previews, Fullscreen Projector (Preview)

OBS_Preview_List := Array()
OBS_Preview_List.Push("Windowed Projector (Program)")
OBS_Preview_List.Push("Windowed Projector (Preview)")
OBS_Preview_List.Push("Fullscreen Projector (Program)")
OBS_Preview_List.Push("Fullscreen Projector (Preview)")

If (FileExist(SettingsPath := A_ScriptDir "\settings.json")) ; Check if SettingsData has any content...
{
    SettingsFile := FileOpen(SettingsPath, "r", "UTF-8-RAW")
    SettingsData := JSON.Load(SettingsFile.Read())
    SettingsFile.Close()
}
else
{
    MsgBox, 16, Error, Missing settings.json file!
    ExitApp
}

If (FileExist(WindowsPath := A_ScriptDir "\windows.json")) ; Check if WindowsData has any content...
{
    WindowsFile := FileOpen(WindowsPath, "r", "UTF-8-RAW")
    WindowsData := JSON.Load(WindowsFile.Read())
    WindowsFile.Close()
}
else
{
    MsgBox, 16, Error Missing windows.json file!
    ExitApp
}

If (SettingsData["Debug"]["LastWindow"]["ID"] AND SettingsData["Debug"]["LastWindow"]["IsAttach"])
{
    MsgBox, 36, Info, Would you like to deattach the last Window?
    IfMsgBox, Yes
        SetParentByHWND(false, SettingsData["Debug"]["LastWindow"]["ID"])
}


; All GUI Names in an Array - Importen to simulate Owner!
Global GuiGroup := Array("Manager", "Status", "DebugControl", "DebugWindow", "DebugOBS", "Window_ClipCursor_Settings", "OBSCommandTitleMenu", "Window_Auto_Focus_Setting")

Menu, SubMenu, Add, &AlwaysOnTop, AlwaysOnTop
Menu, SubMenu, % (SettingsData["General"]["AlwaysOnTop"] ? "Check" : "Uncheck"), &AlwaysOnTop
Menu, SubMenu, Add, &Debug, ToggleDebug
Menu, SubMenu, % (SettingsData["Debug"]["Enabled"] ? "Check" : "Uncheck"), &Debug
Menu, SubMenu, Add, &Reload, Reload
Menu, SubMenu, Add, &Exit, Exit
Menu, Menu, Add, &File, :SubMenu
Menu, Menu, Add, &Settings, :SubMenu
Menu, Menu, Disable, &Settings

Gui, Manager:Menu, Menu
Gui, Manager:Margin, 5, 5
Gui, % "Manager:+hwndManager" A_Space (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")

Gui, Manager:Add, Radio, % "x5 y5 gManager_Refresh_Window_List vGet_Select_Window_Mode hwndhGet_Select_Window_Mode1" A_Space (SettingsData["General"]["SelectMode"] = 1 ? "Checked" : ""), Dedect Window
Gui, Manager:Add, Radio, % "x+5 yp gManager_Refresh_Window_List hwndhGet_Select_Window_Mode2" A_Space (SettingsData["General"]["SelectMode"] = 2 ? "Checked" : ""), Windows File
Gui, Manager:Add, DropDownList, x5 y+5 w200 r10 vGet_Window_Title,

Gui, Manager:Add, Button, x5 y+5 w200 gManager_Refresh_Window_List vRefresh, Reload / Refresh
Gui, Manager:Add, Button, x5 y+5 w200 gLock vLock, Lock

; OBS
Gui, Manager:Add, GroupBox, x5 y+10 w200 h100, OBS
Gui, Manager:Add, Checkbox, % "x15 yp+20 vOBS_Auto_Start" A_Space (SettingsData["OBS"]["Auto_Start"] ? "Checked" : ""), Auto-Start
Gui, Manager:Add, Checkbox, % "x15 y+5 w110 h16 vOBS_Auto_Preview" A_Space (SettingsData["OBS"]["Projector"]["Auto_Start"] ? "Checked" : ""), Auto-Open Preview
Gui, Manager:Add, Button, % "x138 yp-2 w60 h15 Checked gOBS_Preview_Settings", Settings
Gui, Manager:Add, Checkbox, % "x15 y+5 vOBS_Prevent_Close gOBS_Prevent_Close" A_Space (SettingsData["OBS"]["Prevent"]["Keys"] ? "Checked" : ""), Prevent from closing
Gui, Manager:Add, Checkbox, % "x15 y+5 vOBS_Prevent_Rightclick" A_Space (SettingsData["OBS"]["Prevent"]["Keys"] ? "" : "Disabled") A_Space (SettingsData["OBS"]["Prevent"]["Rightclick"] ? "Checked" : ""), Prevent from Rightclick

; OBSCommand
Gui, Manager:Add, GroupBox, x5 y+20 w200 h60, OBSCommand (Work in Progress)
Gui, Manager:Add, Checkbox, % "x15 yp+20 vOBS_Set_Title" A_Space (SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["Enabled"] ? "Checked" : ""), Change Title
Gui, Manager:Add, Button, % "x+40 yp-2 w60 h15 gOBSCommand_Title_Settings", Settings
Gui, Manager:Add, Checkbox, % "x15 yp+20 Disabled", Switch Scene
Gui, Manager:Add, Button, % "x+34 yp-2 w60 h15 Disabled", Settings

; Miscellaneous
Gui, Manager:Add, GroupBox, x5 y+20 w200 h45, Miscellaneous
Gui, Manager:Add, Checkbox, % "x15 yp+20 vWindow_Hide_Cursor" A_Space (SettingsData["General"]["SystemCursor"]["Enabled"] ? "Checked" : ""), Hide Cursor
Gui, Manager:Add, Button, % "x+44 yp-2 w60 h15 gWindow_Hide_Cursor_Setting", Settings

; Window
Gui, Manager:Add, GroupBox, x5 y+20 w200 h310, Window
Gui, Manager:Add, Checkbox, % "x15 yp+20 vWindow_Auto_Start" A_Space (SettingsData["Window"]["Auto_Start"] ? "Checked" : ""), Auto-Start
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Auto_Attach" A_Space (SettingsData["Window"]["Auto_Attach"] ? "Checked" : ""), Auto-Attach
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Auto_Focus" A_Space (SettingsData["Window"]["Auto_Focus"] ? "Checked" : ""), Auto-Focus
Gui, Manager:Add, Button, % "x+44 yp-2 w60 h15 gWindow_Auto_Focus_Setting", Settings
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Block_Keys" A_Space (SettingsData["Window"]["Block_Keys"] ? "Checked" : ""), Block ALT+F4
Gui, Manager:Add, Checkbox, % "x15 y+5 w110 vWindow_Change_Style" A_Space (SettingsData["Window"]["Style"] ? "Checked" : ""), Change Style
Gui, Manager:Add, Button, % "x+10 yp-2 w60 h15 Disabled", Settings
Gui, Manager:Add, Checkbox, % "x15 y+5 w110 vWindow_Change_ExStyle" A_Space (SettingsData["Window"]["ExStyle"] ? "Checked" : ""), Change ExStyle
Gui, Manager:Add, Button, % "x+10 yp-2 w60 h15 Disabled", Settings
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Display_Mode Disabled" A_Space (SettingsData["Window"]["Display_Mode"] ? "Checked" : ""), Fullscreen to Window
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_ClipCursor" A_Space (SettingsData["Window"]["ClipCursor"] ? "Checked" : ""), Restrict Mouse Area
Gui, Manager:Add, Button, % "x+2 yp-2 w60 h15 gWindow_ClipCursor_Settings", Settings
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Change_Size gManager_Change_Size" A_Space (SettingsData["Window"]["Size"] ? "Checked" : ""), Change Size
Gui, Manager:Add, Checkbox, % "x15 y+5 vWindow_Move_to_Position gManager_Move_to_Position" A_Space (SettingsData["Window"]["Move"] ? "Checked" : ""), Move to Position
Gui, Manager:Add, Text, x15 y+10, Position and Size
Gui, Manager:Add, Text, x35 y+10 w5, X:
Gui, Manager:Add, Edit, % "x+5 yp-3 w50 Center vManager_Window_Set_X" A_Space (SettingsData["Window"]["Move"] ? "" : "Disabled"), % SettingsData["Window"]["Set"]["Pos"]["X"] ? SettingsData["Window"]["Set"]["Pos"]["X"] : 0
Gui, Manager:Add, Text, x130 yp+3 w5, Y:
Gui, Manager:Add, Edit, % "x+5 yp-3 w50 Center vManager_Window_Set_Y" A_Space (SettingsData["Window"]["Move"] ? "" : "Disabled"), % SettingsData["Window"]["Set"]["Pos"]["Y"] ? SettingsData["Window"]["Set"]["Pos"]["Y"] : 0
Gui, Manager:Add, Text, x14 y+10 w5, Width:
Gui, Manager:Add, Edit, % "x+5 yp-3 w50 Center vManager_Window_Set_Width gManager_Scale" A_Space (SettingsData["Window"]["Size"] ? "" : "Disabled"), % SettingsData["Window"]["Set"]["Size"]["Width"] ? SettingsData["Window"]["Set"]["Size"]["Width"] : 0
Gui, Manager:Add, Text, x106 yp+3 w5, Height:
Gui, Manager:Add, Edit, % "x+5 yp-3 w50 Center vManager_Window_Set_Height gManager_Scale" A_Space (SettingsData["Window"]["Size"] ? "" : "Disabled"), % SettingsData["Window"]["Set"]["Size"]["Height"] ? SettingsData["Window"]["Set"]["Size"]["Height"] : 0
Gui, Manager:Add, Text, x15 y+10, Scale:
Gui, Manager:Add, Edit, x+5 yp-3 w50 Center vManager_Window_Get_Scale ReadOnly,

Gui, Manager:Add, Button, x5 y+15 w200 vStart gStart Disabled Default, Start
Gui, Manager:Add, Button, x5 y+5 w200 vKill_Window_Process gKill_Window_Process Disabled, Kill Window Process
Gui, Manager:Show, w210 y100, Manager

; Status GUI Settings
Gui, Status:Margin, 5, 5
Gui, % "Status:+HwndStatus -SysMenu" A_Space (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")

; Status GUI Controls
; Window
Gui, Status:Add, GroupBox, x5 y5 w200 h120, Window
Gui, Status:Add, Text, x15 yp+20, Process: %A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Window_Process, ...
Gui, Status:Add, Text, x15 yp+20, Selected:%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Window_Selected, ...
Gui, Status:Add, Text, x15 yp+20, Position:%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Window_Position, ...
Gui, Status:Add, Text, x15 yp+20, Size:%A_Tab%%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Window_Size, ...
Gui, Status:Add, Text, x15 yp+20, Attach:%A_Tab%%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Window_Attach, ...

; OBS
Gui, Status:Add, GroupBox, x5 y+10 w200 h120, OBS
Gui, Status:Add, Text, x15 yp+20, Process: %A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_OBS_Process, ...
Gui, Status:Add, Text, x15 yp+20, Selected:%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_OBS_Selected, ...
Gui, Status:Add, Text, x15 yp+20, Position:%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_OBS_Position, ...
Gui, Status:Add, Text, x15 yp+20, Size:%A_Tab%%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_OBS_Size, ...
Gui, Status:Add, Text, x15 yp+20, Attach:%A_Tab%%A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_OBS_Attach, ...

; Hotkeys
Gui, Status:Add, GroupBox, x5 y+10 w200 h85, Hotkeys
Gui, Status:Add, Text, x15 yp+20, Hide Cursor: %A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Hotkey_Hide_Cursor, disabled
Gui, Status:Add, Text, x15 yp+20, Auto-Focus: %A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Hotkey_Auto_Focus, disabled
Gui, Status:Add, Text, x15 yp+20, Mouse Restrict: %A_Tab%
Gui, Status:Add, Text, x+5 yp w200 vStatus_Hotkey_Mouse_Restrict, disabled

; Status Show GUI
Gui, Status:Show, w310 h340, Status

/*
; Red Show GUI (Test)
Gui, Red:Color, Red
Gui, Red:-Caption -Border -SysMenu +Owner +ToolWindow
Gui, Red:Show, x0 y0 w1920 h1080 NoActivate, Test
*/

GoSub, Manager_Scale
GoSub, Manager_Refresh_Window_List
GuiControl, Manager:ChooseString, Get_Window_Title, % SettingsData["General"]["LastSelect"]

If (SettingsData["Debug"]["Enabled"])
{
    ; DebugControl GUI Settings
    Gui, DebugControl:Margin, 5, 5
    Gui, % "DebugControl:+HwndDebugControl -SysMenu" A_Space (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")

    ; DebugControl GUI Controls
    Gui, DebugControl:Add, Button, x5 y+5 w200 gDebugControl_SetParent Disabled vDebugControl_SetParent Default, SetParent
    Gui, DebugControl:Add, Button, x5 y+5 w95 gDebugControl_SetPosition Disabled vDebugControl_SetPosition, Set Position
    Gui, DebugControl:Add, Button, x+10 yp w95 gDebugControl_SetSize Disabled vDebugControl_SetSize, Set Size
    Gui, DebugControl:Add, Button, x5 y+5 w200 gDebugControl_Test vDebugControl_Test, Start Test

    ; DebugControl Show GUI
    Gui, DebugControl:Show, w210, Debug Control

    GoSub, DebugWindow
    GoSub, DebugOBS

    ;Gui, Manager:Submit, NoHide

    If (SettingsData["General"]["Borders"])
    {
        Borders := new Borders
        SetTimer, Borders, % 1000 / 60
    }

    DebugControl_exBottom := new Dock(Manager, DebugControl)
    DebugControl_exBottom.Position("Bottom")
    ; exDock.CloseCallback := Func("CloseCallback")
}

If (SettingsData["Debug"]["Enabled"])
{
    DebugOBS_exBottom := new Dock(DebugOBS, Status)
    DebugOBS_exBottom.Position("Bottom")
}
else
{
    exBottom := new Dock(Manager, Status)
    exBottom.Position("Right")
}

/*
; NOT SURE YET IF I STILL NEED IT
; Sets up the hook to tell Windows to run ShellMessage function in this script when a Shell Hook event occurs
DllCall("RegisterShellHookWindow", UInt, A_ScriptHwnd)
MsgNum := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")

OnMessage(MsgNum, "ShellMessage")
*/

; NEEDS a REWORK to go to all Hotkey's dynamically...
If (SettingsData["HotKeys"]["ClipCursor"])
    Hotkey, % "~" SettingsData["HotKeys"]["ClipCursor"], Toggle_MouseRestrict
If (SettingsData["HotKeys"]["Auto_Focus"])
    Hotkey, % "~" SettingsData["HotKeys"]["Auto_Focus"], Toggle_Auto_Focus
If (SettingsData["HotKeys"]["Hide_Cursor"])
    Hotkey, % "~" SettingsData["HotKeys"]["Hide_Cursor"], Toggle_Hide_Cursor
return

; Create a Function to change Game Settings with all kind of Methode like...
; Replace Strings - Search and replace a String
; RegEx - Change Entry in the Register
; IniRead - Change Value in the IniFile
; JSON - Change Object and replace File
; Copy and Paste preset File
; any other format

1::
GoSub, Change_Settings
return

Change_Settings:
Gui, Manager:Submit, NoHide
For Path, Data in WindowsData[Get_Window_Title]["Settings"]
{
    If (Path)
    {
        ; Register Methode
        If (Data["Methode"] = "Register")
        {
            For Type, Content in Data["Set"]
            {
                For Key, Value in Content
                {
                    If (Type AND Path AND Key AND Value)
                        RegWrite, % Type, % Path, % Key, % Value
                }
            }
        }

        ; StringReplace Methode
        If (Data["Methode"] = "StringReplace")
        {
            ; File must exist...
            If (FileExist(Path))
            {
                ; Open File
                SettingFile := FileOpen(Path, "rw", "UTF-8-RAW")
                ; Get Content of File
                SettingData := SettingFile.Read()
                ; Start Position of Pointer
                SettingPos := 1
                ; Split Content of the File after each Line into a Object
                SettingLine := StrSplit(SettingData, "`n")

                For Key, Value in Data["Set"]
                {
                    ; Going trough each Line
                    Loop % SettingLine.Count()
                    {
                        If (InStr(SettingLine[A_Index], Key))
                        {
                            NewStr := RegExMatch(SettingData, "\w+\b", UOV, SettingPos + StrLen(Key))
                            If (Value AND UOV) ; Make sure Value and UOV has any content...
                                SettingData := RegExReplace(SettingData, UOV, Value,, 1, NewStr)
                        }

                        ; Set Pointer to the end of current Content of the Line
                        SettingPos += StrLen(SettingLine[A_Index] (SettingLine.Count() = A_Index ? "" : "`n"))
                    }
                    ; Reset Position
                    SettingPos := 1
                }

                ; Reset Pointer
                SettingFile.Seek(false)
                ; Write new File
                SettingFile.Write(SettingData)

                ; Close File
                SettingFile.Close()
            }
        }
    }
}
return

; GUI for Hide Cursor Setting
Window_Hide_Cursor_Setting:
GUI_Toggle("Window_Hide_Cursor_Setting", "+Disabled")
If (SettingsData["HotKeys"]["Hide_Cursor"])
    HotKey, % SettingsData["HotKeys"]["Hide_Cursor"], Off

Gui, Window_Hide_Cursor_Setting:+OwnerManager
Gui, Window_Hide_Cursor_Setting:Margin, 5, 5
Gui, Window_Hide_Cursor_Setting:Add, Text, x5 y5, Hotkey:
Gui, Window_Hide_Cursor_Setting:Add, Hotkey, x5 y+5 w200 vHotKey_Set_Hide_Cursor, % SettingsData["HotKeys"]["Hide_Cursor"]

Gui, Window_Hide_Cursor_Setting:Add, Text, x5 y+8, Interval:
Gui, Window_Hide_Cursor_Setting:Add, Edit, x+5 yp-3 w40 h20 Number
Gui, Window_Hide_Cursor_Setting:Add, UpDown
Gui, Window_Hide_Cursor_Setting:Add, Text, x+5 yp, :
Gui, Window_Hide_Cursor_Setting:Add, Edit, x+5 yp w40 h20 Number
Gui, Window_Hide_Cursor_Setting:Add, UpDown
Gui, Window_Hide_Cursor_Setting:Add, Text, x+5 yp, :
Gui, Window_Hide_Cursor_Setting:Add, Edit, x+5 yp w40 h20 Number
Gui, Window_Hide_Cursor_Setting:Add, UpDown

Gui, Window_Hide_Cursor_Setting:Add, Button, x5 y+5 w200 h20 gWindow_Hide_Cursor_Setting_Save, Save
Gui, Window_Hide_Cursor_Setting:Show, w210 h100, Auto-Focus Settings
return

; Save Settings for Hide Cursor
Window_Hide_Cursor_Setting_Save:
GUI_Toggle("Window_Hide_Cursor_Setting", "-Disabled")
Gui, Window_Hide_Cursor_Setting:Submit, NoHide
Gui, Window_Hide_Cursor_Setting:Destroy

If (HotKey_Set_Hide_Cursor)
{
    SettingsData["HotKeys"]["Hide_Cursor"] := HotKey_Set_Hide_Cursor
    HotKey, %  "~" SettingsData["HotKeys"]["Hide_Cursor"], Toggle_Hide_Cursor
    HotKey, % SettingsData["HotKeys"]["Hide_Cursor"], On
}
return

; Close the Hide Cursor
Window_Hide_Cursor_SettingGuiClose:
GUI_Toggle("Window_Hide_Cursor_Setting", "-Disabled")
Gui, Window_Hide_Cursor_Setting:Destroy

If (SettingsData["HotKeys"]["Hide_Cursor"])
    HotKey, % SettingsData["HotKeys"]["Hide_Cursor"], On
return

; Hotkey for Hide Cursor
Toggle_Hide_Cursor:
ToggleHM := ToggleHM ? false : true
GuiControl, % "Manager:", Window_Hide_Cursor, % ToggleHM ? 1 : 0
If (!ToggleHM)
    SystemCursor(1)
return

Window_Auto_Focus_Setting:
GUI_Toggle("Window_Auto_Focus_Setting", "+Disabled")
If (SettingsData["HotKeys"]["Auto_Focus"])
    HotKey, % SettingsData["HotKeys"]["Auto_Focus"], Off

Gui, Window_Auto_Focus_Setting:+OwnerManager
Gui, Window_Auto_Focus_Setting:Margin, 5, 5
Gui, Window_Auto_Focus_Setting:Add, Text, x5 y5, Hotkey:
Gui, Window_Auto_Focus_Setting:Add, Hotkey, x5 y+5 w200 vHotKey_Set_Auto_Focus, % SettingsData["HotKeys"]["Auto_Focus"]
Gui, Window_Auto_Focus_Setting:Add, Button, x5 y+5 w200 h20 gWindow_Auto_Focus_Setting_Save, Save
Gui, Window_Auto_Focus_Setting:Show, w210 h75, Auto-Focus Settings
return

Window_Auto_Focus_Setting_Save:
GUI_Toggle("Window_Auto_Focus_Setting", "-Disabled")
Gui, Window_Auto_Focus_Setting:Submit, NoHide
Gui, Window_Auto_Focus_Setting:Destroy

If (HotKey_Set_Auto_Focus)
{
    SettingsData["HotKeys"]["Auto_Focus"] := HotKey_Set_Auto_Focus
    HotKey, %  "~" SettingsData["HotKeys"]["Auto_Focus"], Toggle_Auto_Focus
    HotKey, % SettingsData["HotKeys"]["Auto_Focus"], On
}
return

Window_Auto_Focus_SettingGuiClose:
GUI_Toggle("Window_Auto_Focus_Setting", "-Disabled")
Gui, Window_Auto_Focus_Setting:Destroy

If (SettingsData["HotKeys"]["Auto_Focus"])
    HotKey, % SettingsData["HotKeys"]["Auto_Focus"], On
return

Toggle_Auto_Focus:
ToggleAF := ToggleAF ? false : true
GuiControl, % "Manager:", Window_Auto_Focus, % ToggleAF ? 1 : 0
return

Manager_Change_Size:
Gui, Manager:Submit, NoHide
GuiControl, % "Manager:" (Window_Change_Size ? "Enable" : "Disable"), Manager_Window_Set_Width
GuiControl, % "Manager:" (Window_Change_Size ? "Enable" : "Disable"), Manager_Window_Set_Height
return

Manager_Move_to_Position:
Gui, Manager:Submit, NoHide
GuiControl, % "Manager:" (Window_Move_to_Position ? "Enable" : "Disable"), Manager_Window_Set_X
GuiControl, % "Manager:" (Window_Move_to_Position ? "Enable" : "Disable"), Manager_Window_Set_Y
return

OBS_Preview_Settings:
GUI_Toggle("OBSPreviewMenu", "+Disabled")

SysGet, MonitorCount, MonitorCount
MonitorsName :=
Loop % MonitorCount
{
    SysGet, MonitorName, MonitorName, % A_Index
    SysGet, MonitorResolution, Monitor, % A_Index
    MonitorName := MonitorName A_Space "[" MonitorResolutionRight - MonitorResolutionLeft "x" MonitorResolutionBottom - MonitorResolutionTop "]"
    MonitorsName .= (MonitorsName ? (MonitorCount = A_Index ? MonitorName : MonitorName "|") : (MonitorCount = 1 ? MonitorName "||" : (A_Index = 1 ? MonitorName "||" : MonitorName "|")))
}

Gui, OBSPreviewMenu:+OwnerManager
Gui, OBSPreviewMenu:Margin, 5, 5
Gui, OBSPreviewMenu:Add, Text, x5 y5, Display:
Gui, OBSPreviewMenu:Add, DropDownList, x5 y+5 w200 h20 r10 AltSubmit vOBS_Preview_Settings_Save, % MonitorsName
Gui, OBSPreviewMenu:Add, Button, x5 y+5 w200 h20 gOBS_Preview_Settings_Save, Save
Gui, OBSPreviewMenu:Show, w210 h75, OBS Preview Menu

If (SettingsData["OBS"]["Projector"]["Monitor"] + 1)
    GuiControl, OBSPreviewMenu:Choose, OBS_Preview_Settings_Save, % SettingsData["OBS"]["Projector"]["Monitor"] + 1
return

OBS_Preview_Settings_Save:
GUI_Toggle("OBSPreviewMenu", "-Disabled")
Gui, OBSPreviewMenu:Submit, NoHide
Gui, OBSPreviewMenu:Destroy

SettingsData["OBS"]["Projector"]["Monitor"] := OBS_Preview_Settings_Save - 1
return

OBSPreviewMenuGuiClose:
GUI_Toggle("OBSPreviewMenu", "-Disabled")
Gui, OBSPreviewMenu:Destroy
return

OBSCommand_Title_Settings:
GUI_Toggle("OBSCommandTitleMenu", "+Disabled")

OBS := new OBS(A_AppData "\obs-studio")

Gui, OBSCommandTitleMenu:+OwnerManager
Gui, OBSCommandTitleMenu:Margin, 5, 5
Gui, OBSCommandTitleMenu:Add, Text, w100 x5 y5, Scene Collection:
Gui, OBSCommandTitleMenu:Add, DropDownList, x+5 yp-3 w200 h20 r20 vOBSCommandTitleMenu_Select_Scene_Collection gOBSCommandTitleMenu_Get_SourceList, % OBS.getScene_CollectionList()
Gui, OBSCommandTitleMenu:Add, Text, w100 x5 y+5, Source:
Gui, OBSCommandTitleMenu:Add, DropDownList, x+5 yp-3 w200 h20 r20 vOBSCommandTitleMenu_Select_Source
Gui, OBSCommandTitleMenu:Add, Button, x5 y+5 w305 h20 gOBSCommandTitleMenu_Save, Save
Gui, OBSCommandTitleMenu:Show,, OBSCommand Title

GuiControl, OBSCommandTitleMenu:ChooseString, OBSCommandTitleMenu_Select_Scene_Collection, % OBS.getCurrentSceneCollection
GoSub, OBSCommandTitleMenu_Get_SourceList
return

OBSCommandTitleMenu_Save:
GUI_Toggle("OBSCommandTitleMenu", "-Disabled")
Gui, OBSCommandTitleMenu:Submit, NoHide
Gui, OBSCommandTitleMenu:Destroy

If (OBSCommandTitleMenu_Select_Scene_Collection AND OBSCommandTitleMenu_Select_Source)
{
    SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["scene_collection"] := OBSCommandTitleMenu_Select_Scene_Collection
    SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["sourceName"] := OBSCommandTitleMenu_Select_Source
}
return

OBSCommandTitleMenu_Get_SourceList:
Gui, OBSCommandTitleMenu:Submit, NoHide
GuiControl, OBSCommandTitleMenu:, OBSCommandTitleMenu_Select_Source, % "|" OBS.getSourceList(OBSCommandTitleMenu_Select_Scene_Collection, "Text")
ChooseString := SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["sourceName"] ? SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["sourceName"] : false
If (SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["scene_collection"] = OBSCommandTitleMenu_Select_Scene_Collection)
    GuiControl, % "OBSCommandTitleMenu:" (ChooseString ? "ChooseString" : "Choose"), OBSCommandTitleMenu_Select_Source, % ChooseString ? ChooseString : 1
else
    GuiControl, OBSCommandTitleMenu:Choose, OBSCommandTitleMenu_Select_Source, 1
return

OBSCommandTitleMenuGuiClose:
GUI_Toggle("OBSCommandTitleMenu", "-Disabled")
Gui, OBSCommandTitleMenu:Destroy
return

Window_ClipCursor_Settings:
GUI_Toggle("Window_ClipCursor_Settings", "+Disabled")
If (SettingsData["HotKeys"]["ClipCursor"])
    HotKey, % SettingsData["HotKeys"]["ClipCursor"], Off

Gui, Window_ClipCursor_Settings:+OwnerManager
Gui, Window_ClipCursor_Settings:Margin, 5, 5
Gui, Window_ClipCursor_Settings:Add, Text, x5 y5, Hotkey:
Gui, Window_ClipCursor_Settings:Add, Hotkey, x5 y+5 w200 vHotKey_Set_Mouse_Restrict, % SettingsData["HotKeys"]["ClipCursor"]
Gui, Window_ClipCursor_Settings:Add, Button, x5 y+5 w200 h20 gWindow_ClipCursor_Settings_Save, Save
Gui, Window_ClipCursor_Settings:Show, w210 h75, ClipCursor Settings
return

Window_ClipCursor_Settings_Save:
GUI_Toggle("Window_ClipCursor_Settings", "-Disabled")
Gui, Window_ClipCursor_Settings:Submit, NoHide
Gui, Window_ClipCursor_Settings:Destroy

If (HotKey_Set_Mouse_Restrict)
{
    SettingsData["HotKeys"]["ClipCursor"] := HotKey_Set_Mouse_Restrict
    HotKey, %  "~" SettingsData["HotKeys"]["ClipCursor"], Toggle_MouseRestrict
    HotKey, % SettingsData["HotKeys"]["ClipCursor"], On
}
return

Window_ClipCursor_SettingsGuiClose:
GUI_Toggle("Window_ClipCursor_Settings", "-Disabled")
Gui, Window_ClipCursor_Settings:Destroy

If (SettingsData["HotKeys"]["ClipCursor"])
    HotKey, % SettingsData["HotKeys"]["ClipCursor"], On
return

Toggle_MouseRestrict:
ToggleMR := ToggleMR ? false : true
GuiControl, % "Manager:", Window_ClipCursor, % ToggleMR ? 1 : 0
If (!ToggleMR)
    ClipCursor(false)
return

/*
~1::
Gui, Layer1:Color, 00FF00
Gui, Layer1:-SysMenu -Border +ToolWindow -Caption +hwndhLayer1 +Disabled +AlwaysOnTop
Gui, Layer1:Font, s72
Gui, Layer1:Add, Text, vTText, LOOLL
Gui, Layer1:Show, w1600 h900 Hide, Layer1
return

~2::
SetParentByHWND(WinExist(OBS_Window_Title), hLayer1)
aysdt

~3::
Gui, Layer1:Show, % "x" Manager_Window_Set_X A_Space "y" Manager_Window_Set_Y A_Space "NoActivate", Layer1
WinSet, TransColor, 00FF00, % "ahk_id" A_Space hLayer1
WinSet, Top,, "ahk_id" A_Space hLayer1
return

~4::
GuiControl, Layer1:, TText, % A_TickCount
return
*/

Kill_Window_Process:
If (Window_Get_Window_ProcessID OR Window_Get_Window_Process_ID)
{
    Process, Close, % "ahk_id" A_Space Window_Get_Window_ProcessID ? Window_Get_Window_ProcessID : Window_Get_Window_Process_ID
    Window_IsAttach := false
    GuiControl, Manager:Disabled, Kill_Window_Process
}
If (Window_Window_Title)
{
    Process, Close, % "ahk_id" A_Space WinExist(Window_Window_Title)
    Window_IsAttach := false
    GuiControl, Manager:Disabled, Kill_Window_Process
}
return

Manager_Scale:
Gui, Manager:Submit, NoHide
If (Manager_Window_Set_Width, Manager_Window_Set_Height)
    GuiControl, Manager:, Manager_Window_Get_Scale, % DisplayScale(Manager_Window_Set_Width, Manager_Window_Set_Height)
return

Start:
Gui, Manager:Submit, NoHide
ToggleStart := ToggleStart ? false : true

GuiControl, % "Manager:" (ToggleStart ? "Disable" : "Enable"), Lock
GuiControl, Manager:, Start, % (ToggleStart ? "Stop" : "Start")

SetTimer, OBS_Start, % ToggleStart ? 1000 : "Off"
SetTimer, Window_Start, % ToggleStart ? 1000 : "Off"
SetTimer, SystemCursor, % ToggleStart ? 1000 : "Off"

If (!ToggleStart)
{
    If (Window_Window_ID)
    {
        SetParentByHWND(false, Window_Window_ID)
        Window_IsAttach := false
    }

    Gui, Status:Font
    ; Window
    GuiControl, Status:Font, Status_Window_Process
    GuiControl, Status:Text, Status_Window_Process, % "..."
    GuiControl, Status:Font, Status_Window_Selected
    GuiControl, Status:Text, Status_Window_Selected, % "..."
    GuiControl, Status:Font, Status_Window_Position
    GuiControl, Status:Text, Status_Window_Position, % "..."
    GuiControl, Status:Font, Status_Window_Size
    GuiControl, Status:Text, Status_Window_Size, % "..."
    GuiControl, Status:Font, Status_Window_Attach
    GuiControl, Status:Text, Status_Window_Attach, % "..."
    ; OBS
    GuiControl, Status:Font, Status_OBS_Process
    GuiControl, Status:Text, Status_OBS_Process, % "..."
    GuiControl, Status:Font, Status_OBS_Selected
    GuiControl, Status:Text, Status_OBS_Selected, % "..."
    GuiControl, Status:Font, Status_OBS_Position
    GuiControl, Status:Text, Status_OBS_Position, % "..."
    GuiControl, Status:Font, Status_OBS_Size
    GuiControl, Status:Text, Status_OBS_Size, % "..."
    GuiControl, Status:Font, Status_OBS_Attach
    GuiControl, Status:Text, Status_OBS_Attach, % "..."

    ClipCursor(false)
    SystemCursor(1)

    Gui, Status:Font
    GuiControl, Status:Font, Status_Hotkey_Mouse_Restrict
    GuiControl, Status:, Status_Hotkey_Mouse_Restrict, % "disabled"
}
return

SystemCursor:
Gui, Manager:Submit, NoHide
If (Window_Hide_Cursor)
{
    If (A_TimeIdlePhysical > SettingsData["General"]["SystemCursor"]["Time"])
        SystemCursor(0)
    else
        SystemCursor(1)

}
return

OBS_Start:
Gui, Manager:Submit, NoHide

If (!ToggleStart)
{
    SetTimer, OBS_Start, Off
    return
}

; Check if OBS exist...
If (FileExist(SettingsData["OBS"]["Path"] "\" SettingsData["OBS"]["Execute"]))
{
    SetTimer, OBS_Start, Off

    ; Create a new OBSCommand Class if not exist...
    If !(OBSCommand["IP"] AND OBSCommand["Port"] AND OBSCommand["Password"])
    {
        OBSCommand := new OBSCommand(SettingsData["OBS"]["Plugins"]["OBSCommand"]["Path"] "\" SettingsData["OBS"]["Plugins"]["OBSCommand"]["Execute"]
                    , SettingsData["OBS"]["Plugins"]["OBSCommand"]["IP"]
                    , SettingsData["OBS"]["Plugins"]["OBSCommand"]["Port"]
                    , SettingsData["OBS"]["Plugins"]["OBSCommand"]["Password"])
    }

    ; Check if Process already exist...
    Process, Exist, % SettingsData["OBS"]["Execute"]
    If (!(OBS_ProcessID := ErrorLevel) AND OBS_Auto_Start)
    {
        Run, % """" SettingsData["OBS"]["Path"] "\" SettingsData["OBS"]["Execute"] """" A_Space SettingsData["OBS"]["Parameters"], % SettingsData["OBS"]["Path"],, OBS_ProcessID
        Gui, Status:Font
        GuiControl, Status:Font, Status_OBS_Process
        GuiControl, Status:Text, Status_OBS_Process, % "starting..."
    }

    ; If Proces exist...
    If (OBS_ProcessID_LastFound != OBS_ProcessID AND OBS_ProcessID)
    {
        ; Remember Process ID even if not anymore exist...
        OBS_ProcessID_LastFound := OBS_ProcessID
        ; Update Status
        Gui, Status:Font, cGreen
        GuiControl, Status:Font, Status_OBS_Process
        GuiControl, Status:Text, Status_OBS_Process, % "running... (" OBS_ProcessID ")"
    }
    else If !(OBS_ProcessID)
    {
        Gui, Status:Font
        GuiControl, Status:Font, Status_OBS_Process
        GuiControl, Status:Text, Status_OBS_Process, % "waiting..."
    }
    ; SetTimer, OBS_Start, 1000

    ; If Process exist...
    If (OBS_ProcessID)
    {
        GoSub, OBS_Get_Window_List

        ; Update Status if Window exist...
        If (WinExist(OBS_Window_Title))
        {
            Gui, Status:Font, cGreen
            GuiControl, Status:Font, Status_OBS_Selected
            GuiControl, Status:Text, Status_OBS_Selected, % OBS_Window_Title

            WinGetPosEx(WinExist(OBS_Window_Title), OBS_Get_Window_X, OBS_Get_Window_Y, OBS_Get_Window_Width, OBS_Get_Window_Height, OBS_Get_Window_OffSet_X, OBS_Get_Window_OffSet_Y)
            Gui, Status:Font, cGreen
            GuiControl, Status:Font, Status_OBS_Position
            GuiControl, Status:Text, Status_OBS_Position, % "X:" A_Space OBS_Get_Window_X A_Space "Y:" A_Space OBS_Get_Window_Y
            Gui, Status:Font, cGreen
            GuiControl, Status:Font, Status_OBS_Size
            GuiControl, Status:Text, Status_OBS_Size, % "Width:" A_Space OBS_Get_Window_Width A_Space "Height:" A_Space OBS_Get_Window_Height

            If (OBSCommand["IP"] AND OBSCommand["Port"] AND OBSCommand["Password"] AND WinExist(OBS_Window_Title) AND OBS_Set_Title AND Window_Window_Title AND SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["sourceName"])
                OBSCommand.ChangeText(SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["sourceName"], Window_Window_Title)
        }
        else
        {
            GoSub, OBS_Preview
        }
    }

    /* LAST BAUSTELLE
    If (WinExist(OBS_Window_Title) AND Window_Change_Size)
    {
        Win
    }
    */
    SetTimer, OBS_Start, 1000
}
return

OBS_Get_Window_List:
If (OBS_ProcessID)
{
    WinGet, OBS_Window_List, List, % "ahk_pid" A_Space OBS_ProcessID
    OBS_Window_Title_List := Object()

    Loop % OBS_Window_List
    {
        i := A_Index
        ID := OBS_Window_List%A_Index%
        WinGetTitle, OBS_Get_Window_Title, % "ahk_id" A_Space ID
        Loop % OBS_Preview_List.Count()
        {
            If (OBS_Get_Window_Title == OBS_Preview_List[A_Index])
            {
                sOBS_Window_Title := OBS_Preview_List[A_Index]
                OBS_Window_Title_List[i] := ID
            }
        }
    }

    ; If more then 1 Preview exist...
    If (OBS_Window_Title_List.Count() > 1)
    {
        ; Close all of it until one
        Loop % OBS_Window_Title_List.Count()
        {
            ; The first one gonna be the selected Preview
            If (A_Index == 1)
                OBS_Window_Title := sOBS_Window_Title
            else
                WinClose, % "ahk_id" A_Space OBS_Window_Title_List[A_Index]
        }
    }
    else
        OBS_Window_Title := sOBS_Window_Title
}
return

OBS_Preview:
If (FileExist(SettingsData["OBS"]["Plugins"]["OBSCommand"]["Path"] "\" SettingsData["OBS"]["Plugins"]["OBSCommand"]["Execute"])
    AND SettingsData["OBS"]["Projector"]["Enabled"]
    AND OBS_Auto_Preview)
{
    Gui, Status:Font
    GuiControl, Status:Font, Status_OBS_Selected
    GuiControl, Status:Text, Status_OBS_Selected, ...

    ; If exist open Projector
    If (OBSCommand["IP"] AND OBSCommand["Port"] AND OBSCommand["Password"] AND !WinExist(OBS_Window_Title))
    {
        OBSCommand.OpenProjector(SettingsData["OBS"]["Projector"]["Type"], SettingsData["OBS"]["Projector"]["Monitor"])
        Gui, Status:Font
        GuiControl, Status:Font, Status_OBS_Selected
        GuiControl, Status:Text, Status_OBS_Selected, open new Projector...
        OBS_Window_List_TickCount_Start := A_TickCount
        ; Wait until Window got found...
        while(!OBS_Window_List)
        {
            ; After 10 seconds break it
            If (Round((A_TickCount - OBS_Window_List_TickCount_Start)) >= 10)
                break

            GoSub, OBS_Get_Window_List
        }
    }
}
else
{
    Gui, Status:Font
    GuiControl, Status:Font, Status_OBS_Selected
    GuiControl, Status:Text, Status_OBS_Selected, ...
}
return

Window_Start:
Gui, Manager:Submit, NoHide

If (!ToggleStart)
{
    SetTimer, Window_Start, Off
    return
}

If (Get_Window_Title)
{
    SetTimer, Window_Start, Off
    Window_Get_Window_Title := Get_Window_Title

    If (Get_Select_Window_Mode == 1)
    {
        WinGet, Window_Get_Window_Process_ID_by_Title, PID, % "ahk_id" A_Space WinExist(Window_Window_Title)
        WinGet, Window_Get_Window_Process_Name, ProcessName, % "ahk_id" A_Space WinExist(Window_Window_Title)
        WinGet, Window_Get_Window_Process_Path, ProcessPath, % "ahk_id" A_Space WinExist(Window_Window_Title)
    }
    else If (Get_Select_Window_Mode == 2 AND WindowsData[Window_Get_Window_Title])
    {
        WindowData := WindowsData[Window_Get_Window_Title]
    }

    ; Check if Window exist...
    If (FileExist(Get_Select_Window_Mode == 1 ? Window_Get_Window_Process_Path : WindowData["Path"] "\" WindowData["Execute"]))
    {
        ; Check if Process already exist...
        Process, Exist, % WindowData["Shipping"] ? WindowData["Shipping"] : WindowData["Execute"]
        Window_Get_Window_ProcessID := ErrorLevel
        ; If not restart Window...
        If (!(Window_Get_Window_ProcessID := ErrorLevel) AND Window_Auto_Start)
        {
            If (WindowData["Steam"]["AppID"])
            {
                RegRead, SteamExecute, % "HKEY_CURRENT_USER\SOFTWARE\Valve\Steam", SteamExe
                RegRead, SteamPath, % "HKEY_CURRENT_USER\SOFTWARE\Valve\Steam", SteamPath
                RegRead, SteamGameInstalled, % "HKEY_CURRENT_USER\SOFTWARE\Valve\Steam\Apps\" WindowData["Steam"]["AppID"], Installed
                If (SteamGameInstalled)
                    Run, % """" SteamExecute """" A_Space "-applaunch" A_Space WindowData["Steam"]["AppID"] A_Space WindowData["Parameters"], % SteamPath,, Window_ProcessID
                else
                    MsgBox, 16, Error, Game is not installed!
            }
            else
                Run, % """" WindowData["Path"] "\" WindowData["Execute"] """" A_Space WindowData["Parameters"], % WindowData["Path"],, Window_ProcessID

            Gui, Status:Font
            GuiControl, Status:Font, Status_Window_Process
            GuiControl, Status:Text, Status_Window_Process, % "starting..."
        }

        ; If Proces exist...
        If (Window_ProcessID_LastFound != Window_Get_Window_ProcessID AND Window_Get_Window_ProcessID)
        {
            ; Remember Process ID even if not anymore exist...
            Window_ProcessID_LastFound := Window_Get_Window_ProcessID
            ; Update Status
            Gui, Status:Font, cGreen
            GuiControl, Status:Font, Status_Window_Process
            GuiControl, Status:Text, Status_Window_Process, % "running... (" Window_Get_Window_ProcessID ")"
        }
        else If !(Window_Get_Window_ProcessID)
        {
            Window_IsAttach := false
            ClipCursor(false)

            Gui, Status:Font
            GuiControl, Status:Font, Status_Window_Process
            GuiControl, Status:Text, Status_Window_Process, % "..."
            GuiControl, Status:Font, Status_Window_Selected
            GuiControl, Status:Text, Status_Window_Selected, % "..."
            GuiControl, Status:Font, Status_Window_Position
            GuiControl, Status:Text, Status_Window_Position, % "..."
            GuiControl, Status:Font, Status_Window_Size
            GuiControl, Status:Text, Status_Window_Size, % "..."
            GuiControl, Status:Font, Status_Window_Attach
            GuiControl, Status:Text, Status_Window_Attach, % "..."
            GuiControl, Status:Font, Status_Hotkey_Mouse_Restrict
            GuiControl, Status:Text, Status_Hotkey_Mouse_Restrict, % "disabled"
        }

        ; If Process exist...
        If (Window_Get_Window_ProcessID)
        {
            GoSub, Window_Get_Window_List

            ; Update Kill Process Button
            If (Window_Window_ID OR Window_Window_Title)
                GuiControl, Manager:Enabled, Kill_Window_Process
            else
                GuiControl, Manager:Disabled, Kill_Window_Process

            ; Update Status if Window exist...
            If (Window_Window_ID)
            {
                Gui, Status:Font, cGreen
                GuiControl, Status:Font, Status_Window_Selected
                GuiControl, Status:Text, Status_Window_Selected, % Window_Window_Title

                WinGetPosEx(Window_Window_ID, Window_Get_Window_X, Window_Get_Window_Y, Window_Get_Window_Width, Window_Get_Window_Height, Window_Get_Window_OffSet_X, Window_Get_Window_OffSet_Y)

                Gui, Status:Font, cGreen
                GuiControl, Status:Font, Status_Window_Position
                GuiControl, Status:Text, Status_Window_Position, % "X:" A_Space Window_Get_Window_X A_Space "Y:" A_Space Window_Get_Window_Y
                Gui, Status:Font, cGreen
                GuiControl, Status:Font, Status_Window_Size
                GuiControl, Status:Text, Status_Window_Size, % "Width:" A_Space Window_Get_Window_Width A_Space "Height:" A_Space Window_Get_Window_Height
            }

            ; Update Attach Window
            If (Window_Window_ControlName)
            {
                Gui, Status:Font, cGreen
                GuiControl, Status:Font, Status_OBS_Attach
                GuiControl, Status:Text, Status_OBS_Attach, % Window_Window_ControlName
            }
            else
            {
                Gui, Status:Font
                GuiControl, Status:Font, Status_OBS_Attach
                GuiControl, Status:Text, Status_OBS_Attach, % "..."
            }
        }

        WinGetPosEx(Window_Window_ID, Window_Window_Get_Pos_X, Window_Window_Get_Pos_Y, Window_Window_Get_Pos_Width, Window_Window_Get_Pos_Height)

        /*
        ; Force it to Window Mode
        If (Abs(Window_Window_Get_Pos_X - OBS_Get_Window_X) != Manager_Window_Set_X
            OR Abs(Window_Window_Get_Pos_Y - OBS_Get_Window_Y) != Manager_Window_Set_Y
            OR Window_Window_Get_Pos_Width != Manager_Window_Set_Width
            OR Window_Window_Get_Pos_Height != Manager_Window_Set_Height)
        {
            If (Window_Window_ID AND Window_Window_Title AND Window_Display_Mode)
                FullscreenToWindow("ahk_id" A_Space Window_Window_ID, Manager_Window_Set_X, Manager_Window_Set_Y, Manager_Window_Set_Width, Manager_Window_Set_Height)
        }
        */

        ; Change Style of the Window
        If (Window_Window_ID AND Window_Window_Title AND Window_Change_Style)
        {
            NewStyle := false
            For Key, Value in WindowData["Style"]
            {
                If (WS.HasKey(Key) AND Value == true)
                    NewStyle += WS[Key]
            }

            WinGet, Window_Get_Style, Style, % "ahk_id" A_Space Window_Window_ID
            If (Window_Get_Style != NewStyle)
                WinSet, Style, % NewStyle, % "ahk_id" A_Space Window_Window_ID
        }

        ; Change ExStyle of the Window
        If (Window_Window_ID AND Window_Window_Title AND Window_Change_ExStyle)
        {
            NewExStyle := false
            For Key, Value in WindowData["Style"]
            {
                If (WSEx.HasKey(Key) AND Value == true)
                    NewExStyle += WSEx[Key]
            }

            WinGet, Window_Get_ExStyle, ExStyle, % "ahk_id" A_Space Window_Window_ID
            If (Window_Get_ExStyle != NewExStyle)
                WinSet, ExStyle, % NewExStyle, % "ahk_id" A_Space Window_Window_ID
        }

        ; Move Window to Position
        If (Window_Window_ID AND Window_Window_Title AND Window_Move_to_Position)
        {
            WinGetPosEx(Window_Window_ID, Window_Get_Pos_X, Window_Get_Pos_Y, Window_Get_Pos_Width, Window_Get_Pos_Height)
            If (Abs(Window_Get_Pos_X - OBS_Get_Window_X) != Manager_Window_Set_X OR Abs(Window_Get_Pos_Y - OBS_Get_Window_Y) != Manager_Window_Set_Y)
                WinMove, % "ahk_id" A_Space Window_Window_ID,, % Manager_Window_Set_X, % Manager_Window_Set_Y, % Window_Get_Pos_Width, % Window_Get_Pos_Height
        }

        ; Change the Size of the Window
        If (Window_Window_ID AND Window_Window_Title AND Window_Change_Size)
        {
            WinGetPosEx(Window_Window_ID, Window_Get_Pos_X, Window_Get_Pos_Y, Window_Get_Pos_Width, Window_Get_Pos_Height)
            If (Window_Get_Pos_Width != Manager_Set_Width OR Window_Get_Pos_Height != Manager_Set_Height)
                WinMove, % "ahk_id" A_Space Window_Window_ID,, % Abs(Window_Get_Pos_X - OBS_Get_Window_X), % Abs(Window_Get_Pos_Y - OBS_Get_Window_Y), % Manager_Window_Set_Width, % Manager_Window_Set_Height
        }

        ; Automatically focus Window
        If (Window_Window_ID AND Window_Window_Title AND Window_Auto_Focus)
        {
            If (!WinActive("ahk_id" A_Space Window_Window_ID))
                WinActivate, % "ahk_id" A_Space Window_Window_ID
        }

        ; Set Cursor restricting
        If (Window_Window_ID AND Window_Window_Title AND Window_ClipCursor)
        {
            WinGetPosEx(Window_Window_ID, Window_Get_Pos_X, Window_Get_Pos_Y, Window_Get_Pos_Width, Window_Get_Pos_Height)
            If (Window_Get_Pos_X OR Window_Get_Pos_Y OR Window_Get_Pos_Width OR Window_Get_Pos_Height)
            {
                ClipCursor(true, Round(Window_Get_Pos_X), Round(Window_Get_Pos_Y), Round(Window_Get_Pos_X+Window_Get_Pos_Width), Round(Window_Get_Pos_Y+Window_Get_Pos_Height))
                Gui, Status:Font, cGreen
                GuiControl, Status:Font, Status_Hotkey_Mouse_Restrict
                GuiControl, Status:, Status_Hotkey_Mouse_Restrict, % "Enabled"
            }
        }

        ; Free Cursor restricting
        If (!Window_ClipCursor)
        {
            ClipCursor(false)
            Gui, Status:Font
            GuiControl, Status:Font, Status_Hotkey_Mouse_Restrict
            GuiControl, Status:, Status_Hotkey_Mouse_Restrict, % "disabled"
        }

        WinGet, sControlList, ControlListHwnd, % "ahk_id" A_Space Window_IsAttach A_Space "ahk_id" A_Space WinExist(OBS_Window_Title)
        sControlList := StrSplit(sControlList, "`n")
        If (!sControlList.Count())
            Window_IsAttach := false

        ; Attach Window to OBS
        If (Window_Window_ID AND WinExist(OBS_Window_Title) AND Window_Auto_Attach AND !Window_IsAttach)
            Window_IsAttach := SetParentByHWND(WinExist(OBS_Window_Title), Window_Window_ID)
            Gui, Status:Font, cGreen
            GuiControl, Status:Font, Status_Window_Attach
            GuiControl, Status:, Status_Window_Attach, % Window_IsAttach

        SetTimer, Window_Start, 1000
    }
}
return

Window_Get_Window_List:
If (Window_Get_Window_ProcessID)
{
    WinGet, Window_Window_List, List, % "ahk_pid" A_Space Window_Get_Window_ProcessID
    Window_Window_Title_List := Object()
    Window_Window_ControlList := Object()

    If (!Window_Window_List AND OBS_Window_Title)
    {
        ; WinGetTitle, sTitle, % "ahk_id" A_Space ControlList[1] A_Space OBS_Window_Title
        ; WinGetClass, sClass, % "ahk_id" A_Space ControlList[1] A_Space OBS_Window_Title
        WinGet, ControlList, ControlListHwnd, % "ahk_id" A_Space WinExist(OBS_Window_Title)
        ControlList := StrSplit(ControlList, "`n")

        For Key, Value in ControlList
        {
            WinGetClass, ControlName, % "ahk_id" A_Space Value A_Space OBS_Window_Title
            If (InStr(ControlName, "AutoHotkey"))
                ControlList.Delete(Key)a
        }

        WinGetClass, ControlName, % "ahk_id" A_Space ControlList[1] A_Space OBS_Window_Title
        WinGet, sID, ID, % "ahk_id" A_Space ControlList[1] A_Space OBS_Window_Title

        Window_Window_Title_List[1] := sID
        Window_Window_ControlList[1] := ControlName
    }
    else If (!Window_Window_ID AND !OBS_Window_Title)
        return ; If no ID's at all and OBS Title found return...
    else
    {
        Loop % Window_Window_List
        {
            i := A_Index
            ID := Window_Window_List%A_Index%
            WinGetTitle, Window_Get_Window_Title, % "ahk_id" A_Space ID
            Window_Window_Title_List[i] := ID
        }
    }

    ; If more then 1 Windodw exist...
    If (Window_Window_Title_List.Count() > 1)
    {
        ; Close all of it until one
        Loop % Window_Window_Title_List.Count()
        {
            ; The first one gonna be the selected Windodw
            If (A_Index == 1)
            {
                WinGetTitle, sWindow_Window_Title, % "ahk_id" A_Space Window_Window_Title_List[A_Index]
                WinGetClass, Window_Window_Class, % "ahk_id" A_Space Window_Window_Title_List[A_Index]
                WinGet, sWindow_Window_ID, ID, % "ahk_id" A_Space Window_Window_Title_List[A_Index]
                Window_Window_Title := sWindow_Window_Title
                Window_Window_ID := sWindow_Window_ID
                Window_Window_ControlName := Window_Window_ControlList[A_Index]
            }
            else
                WinClose, % "ahk_id" A_Space Window_Window_Title_List[A_Index]
        }
    }
    else
    {
        WinGetTitle, sWindow_Window_Title, % "ahk_id" A_Space Window_Window_Title_List[1]
        WinGetClass, Window_Window_Class, % "ahk_id" A_Space Window_Window_Title_List[1]
        WinGet, sWindow_Window_ID, ID, % "ahk_id" A_Space Window_Window_Title_List[1]
        Window_Window_Title := sWindow_Window_Title
        Window_Window_ID := sWindow_Window_ID
        Window_Window_ControlName := Window_Window_ControlList[1]
    }
}
return

Window_Run:
return

Lock:
Gui, Manager:Submit, NoHide
Gui, DebugWindow:Submit, NoHide
Gui, DebugOBS:Submit, NoHide
Gui, DebugControl:Submit, NoHide

If SettingsData["Debug"]["Enabled"] AND !(DebugWindow_Selected_ID AND DebugOBS_Selected_ID)
{
    MsgBox, 16, Error, Require to select a Window and OBS-Window!
    return
}

ToggleLock := ToggleLock ? false : true
DebugControl_IsAttach := ToggleLock ? true : false
GuiControl, % "Manager:" (ToggleLock ? "Disable" : "Enable"), Refresh
GuiControl, % "Manager:" (ToggleLock ? "Disable" : "Enable"), % hGet_Select_Window_Mode1
GuiControl, % "Manager:" (ToggleLock ? "Disable" : "Enable"), % hGet_Select_Window_Mode2
GuiControl, % "Manager:" (ToggleLock ? "Disable" : "Enable"), Get_Window_Title
If (SettingsData["Debug"]["Enabled"])
{
    GuiControl, % "DebugControl:" (ToggleLock ? "Enable" : "Disable"), DebugControl_SetParent
    GuiControl, % "DebugControl:" (ToggleLock ? "Enable" : "Disable"), DebugControl_SetPosition
    GuiControl, % "DebugControl:" (ToggleLock ? "Enable" : "Disable"), DebugControl_SetSize
}
GuiControl, % "Manager:" (ToggleLock ? "Enable" : "Disable"), Start
GuiControl, Manager:, Lock, % (ToggleLock ? "Unlock" : "Lock")

If (ToggleLock)
{
    If (Get_Window_Title)
    {
        Window_Get_Window_Title := Get_Window_Title

        If (Get_Select_Window_Mode == 1)
        {
            /*
            WinGet, Window_Get_Window_Process_ID_by_Title, PID, % WinExist(Window_Window_Title)
            WinGet, Window_Get_Window_Process_Name, ProcessName, % WinExist(Window_Window_Title)
            WinGet, Window_Get_Window_Process_Path, ProcessPath, % WinExist(Window_Window_Title)
            */
        }
        else If (Get_Select_Window_Mode == 2 AND WindowsData[Window_Get_Window_Title])
        {
            /*
            Process, Exist, % WindowsData[Window_Get_Window_Title]["Execute"]
            Window_Get_Window_Process_ID := ErrorLevel
            */
        }
    }
}
return

; --------------------------------------------
; ------------------- Test -------------------
; --------------------------------------------

DebugControl_Test:
ToggleTest := (ToggleTest ? false : true)
GuiControl, DebugControl:, DebugControl_Test, % ToggleTest ? "Stop Test" : "Start Test"

Last_X := 1920 - DebugWindow_Get_Window_Position_X_Ex
Last_Y := DebugWindow_Get_Window_Position_Y_Ex
Last_W := DebugWindow_Get_Window_Position_Width_Ex
Last_H := DebugWindow_Get_Window_Position_Height_Ex

SetTimer, DebugControl_Test_Timer, % ToggleTest ? (1000 / 60) : "Off"
return

DebugControl_Test_Timer:
New_pW := (100 / 1920) * DebugOBS_Get_Window_Position_Width_Ex ; Pixel percent (%)
New_W := (1920 / 100) * New_pW ; Pixel
New_pH := (100 / 1080) * DebugOBS_Get_Window_Position_Height_Ex ; Pixel percent (%)
New_H := (1080 / 100) * New_pH ; Pixel

New_W := (Last_W / 100) * New_pW
New_H := (Last_H / 100) * New_pH

;Width := Width <= Height ? Width : DisplayHeigh(Height)
;Height := Height <= Width ? Height : DisplayHeigh(Width)

ToolTip % Last_X "`n" Last_Y
WinMove, % "ahk_id" A_Space DebugWindow_Selected_ID,, % Last_X, % Last_Y, % New_W, % New_H
return

DisplayHeigh(Width)
{
    DisplayHeigh := Width * 9 / 16
    return Round(DisplayHeigh)
}

DisplayWidth(Height)
{
    DisplayWidth := Height * 16 / 9
    return Round(DisplayWidth)
}

; --------------------------------------------
; ------------------- Test -------------------
; --------------------------------------------

DebugControl_SetPosition:
Gui, DebugControl:Submit, NoHide

If (WinExist("ahk_id" A_Space DebugWindow_Selected_ID) AND Manager_Window_Set_X AND Manager_Window_Set_Y)
    WinMove, % "ahk_id" A_Space DebugWindow_Selected_ID,, % Manager_Window_Set_X, % Manager_Window_Set_Y
return

DebugControl_SetSize:
Gui, DebugControl:Submit, NoHide

If (WinExist("ahk_id" A_Space DebugWindow_Selected_ID) AND Manager_Set_Width AND Manager_Set_Height)
{
    ; WinGetPos, Get_X, Get_Y,,, % "ahk_id" A_Space DebugWindow_Selected_ID
    WinMove, % "ahk_id" A_Space DebugWindow_Selected_ID,, % Manager_Window_Set_X, % Manager_Window_Set_Y, % Manager_Window_Set_Width, % Manager_Window_Set_Height
}
return

DebugControl_SetParent:
Gui, DebugWindow:Submit, NoHide
Gui, DebugOBS:Submit, NoHide
Gui, DebugControl:Submit, NoHide
; ToolTip % DebugWindow_Selected_Window_Title A_Space "(" DebugWindow_Selected_ID ")" "`n" DebugOBS_Selected_Window_Title A_Space "(" DebugOBS_Selected_ID ")"

ToggleParent := ToggleParent ? false : true
If (DebugWindow_Selected_ID AND DebugOBS_Selected_ID)
{
    ToggleCloseButton(DebugOBS_Selected_ID, ToggleParent ? false : true)
    WinGetTitle, Get_Window_Title, % "ahk_id" A_Space DebugWindow_Selected_ID
    DebugWindow_Selected_Window := Get_Window_Title

    ; AttachID := DebugWindow_Selected_ID
    GuiControl, % "DebugControl:" (ToggleParent ? "Disable" : "Enable"), Lock
    GuiControl, DebugControl:, DebugControl_SetParent, % (ToggleParent ? "Deattach" : "SetParent")
    ; DebugWindow_Process_ID := DebugWindow_Selected_ID
    ; DebugWindow_Process_ID_by_Title := DebugWindow_Selected_ID
    GoSub, Save
    SetParentByHWND(ToggleParent ? DebugOBS_Selected_ID : false, DebugWindow_Selected_ID)
}
return

Borders:
Gui, DebugWindow:Submit, NoHide
If (ID := WinActive("ahk_id" WinExist(DebugWindow_Selected_Window_Title)))
{
    ;WinGetPos, X, Y, Width, Height, % "ahk_id" A_Space ID
    WinGetPos(ID, X, Y, Width, Height)
    Borders.Move(X, Y, Width, Height)
} else
    Borders.Hide()
return

OBS_Prevent_Close:
Gui, Manager:Submit, NoHide
If (OBS_Prevent_Close)
    GuiControl, Manager:Enable, OBS_Prevent_Rightclick
else
    GuiControl, Manager:Disable, OBS_Prevent_Rightclick
return

ManagerGuiSize:
If (A_EventInfo = 1)
	Gui, Manager:Show, Hide
; Menu, Tray, Rename, Hide, Show
return

ManagerGuiShow:
Gui, Manager:Show
Return

; Close Manager Window
ManagerGuiClose:
Gui, Manager:Submit, NoHide
Gui, Manager:Destroy
GoSub, Exit
return

; Set all Window always on top
AlwaysOnTop:
Menu, SubMenu, % SettingsData["General"]["AlwaysOnTop"] ? "Uncheck" : "Check", &AlwaysOnTop

SettingsData["General"]["AlwaysOnTop"] := SettingsData["General"]["AlwaysOnTop"] ? false : true

Gui, % "Manager:" (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")
Gui, % "Status:" (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")
Gui, % "DebugWindow:" (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")
Gui, % "DebugOBS:" (SettingsData["General"]["AlwaysOnTop"] ? "+AlwaysOnTop" : "-AlwaysOnTop")
return

; Toggle Debug
ToggleDebug:
Menu, SubMenu, % SettingsData["Debug"]["Enabled"] ? "Uncheck" : "Check", &Debug
SettingsData["Debug"]["Enabled"] := SettingsData["Debug"]["Enabled"] ? false : true
return

; Refresh the List
Manager_Refresh_Window_List:
Gui, Manager:Submit, NoHide
Gui, DebugWindow:Submit, NoHide

If (Get_Select_Window_Mode == 1)
{
    GuiControl, DebugWindow:, DebugWindow_Process_Path_Text, Process Path:
    Get_Window_List :=
    WinGet, List, List

    Loop % List
    {
        WinGetTitle, Title, % "ahk_id" A_Space List%A_Index%
        If (Title)
            Get_Window_List .= Get_Window_List ? (A_Index = List ? Title : Title "|") : Title "|"
    }

    If (Get_Window_List)
    {
        GuiControl, Manager:, Get_Window_Title, % "|" Get_Window_List
        GuiControl, Manager:Choose, Get_Window_Title, 1
    }
}
else If (Get_Select_Window_Mode == 2)
{
    GuiControl, DebugWindow:, DebugWindow_Process_Path_Text, Windows File Path:
    Get_Window_List :=
    WindowsFile := FileOpen(A_ScriptDir "\windows.json", "r", "UTF-8-RAW")
    WindowsData := JSON.Load(WindowsFile.Read())
    WindowsFile.Close()

    For Title, Data in WindowsData
        Get_Window_List .= Get_Window_List ? (A_Index = WindowsData.Count() ? Title : Title "|") : Title "|"

    If (Get_Window_List)
    {
        GuiControl, Manager:, Get_Window_Title, % "|" Get_Window_List
        GuiControl, Manager:Choose, Get_Window_Title, 1
    }
}
return

; Save in settings.json
Save:
Gui, Manager:Submit, NoHide
; Last
SettingsData["General"]["LastSelect"] := Get_Window_Title

; General
SettingsData["General"]["SelectMode"] := Get_Select_Window_Mode ? Get_Select_Window_Mode : 1

; OBS
SettingsData["OBS"]["Auto_Start"] := OBS_Auto_Start
SettingsData["OBS"]["Projector"]["Auto_Start"] := OBS_Auto_Preview
SettingsData["OBS"]["Prevent"]["Rightclick"] := OBS_Prevent_Rightclick ? OBS_Prevent_Rightclick : 0
SettingsData["OBS"]["Prevent"]["Keys"] := OBS_Prevent_Close ? OBS_Prevent_Close : 0

; OBSCommand
SettingsData["OBS"]["Plugins"]["OBSCommand"]["Set"]["Title"]["Enabled"] := OBS_Set_Title

; Miscellaneous
SettingsData["General"]["SystemCursor"]["Enabled"] := Window_Hide_Cursor

; Debug
SettingsData["Debug"]["LastWindow"]["ID"] := DebugWindow_Selected_ID ? DebugWindow_Selected_ID : 0
SettingsData["Debug"]["LastWindow"]["IsAttach"] := DebugControl_IsAttach ? DebugControl_IsAttach : 0

; -- Window --

; General
SettingsData["Window"]["Auto_Start"] := Window_Auto_Start
SettingsData["Window"]["Auto_Attach"] := Window_Auto_Attach
SettingsData["Window"]["Auto_Focus"] := Window_Auto_Focus
SettingsData["Window"]["Block_Keys"] := Window_Block_Keys
SettingsData["Window"]["Style"] := Window_Change_Style
SettingsData["Window"]["ExStyle"] := Window_Change_ExStyle
SettingsData["Window"]["Display_Mode"] := Window_Display_Mode
SettingsData["Window"]["Size"] := Window_Change_Size
SettingsData["Window"]["Move"] := Window_Move_to_Position
SettingsData["Window"]["ClipCursor"] := Window_ClipCursor

; HotKey
; SettingsData["Hotkeys"]["ClipCursor"] := HotKey_Set_Mouse_Restrict

; Position
SettingsData["Window"]["Set"]["Pos"]["X"] := Manager_Window_Set_X ? Manager_Window_Set_X : 0
SettingsData["Window"]["Set"]["Pos"]["Y"] := Manager_Window_Set_Y ? Manager_Window_Set_Y : 0
; Size
SettingsData["Window"]["Set"]["Size"]["Width"] := Manager_Window_Set_Width ? Manager_Window_Set_Width : 0
SettingsData["Window"]["Set"]["Size"]["Height"] := Manager_Window_Set_Height ? Manager_Window_Set_Height : 0

; Write into File
SettingsFile := FileOpen(SettingsPath, "w", "UTF-8-RAW")
SettingsFile.Write(JSON.Dump(SettingsData,,4))
SettingsFile.Close()
return

; Reload the App
Reload:
Reload

; Exit the App
Exit:
If (DebugControl_IsAttach AND DebugWindow_Selected_ID)
    SetParentByHWND(false, DebugWindow_Selected_ID) ; Debug - Deattach the selected Window before exiting...
If (Window_IsAttach AND Window_Window_ID)
    SetParentByHWND(false, Window_Window_ID) ; ; Deattach the selected Window before exiting...
GoSub, Save
ExitApp

; Prevents closing OBS Preview / Program with Escape and Alt+F4 / Rightclick Context Menu > Close
#If WinActive("ahk_group OBS_Previews") AND WinGetID("ahk_group OBS_Previews") = MouseGetPosWin() AND OBS_Prevent_Close AND ToggleStart
    OR WinGetID("ahk_group OBS_Previews") = MouseGetPosWin() AND OBS_Prevent_Close AND ToggleStart
    OR WinActive(Window_Window_Title) AND Window_Block_Keys AND ToggleStart
*RButton::
If (!OBS_Prevent_Rightclick OR WinActive(Window_Window_Title) = MouseGetPosWin()) ; need alternative to disable only the "Close" Item at the Menu because we need to detach the Game before
    Send {RButton}
*ESC::
    If (WinActive(Window_Window_Title))
        Send {ESC}
*!F4::
return
#If

WinGetID(Window)
{
	WinGet, ID, ID, % Window
	return ID
}

MouseGetPosWin()
{
	MouseGetPos,,, Win
	return Win
}

/*
Not sure if i still need it...
ShellMessage(wParam, lParam) ; Gets all Shell Hook messages
{
	If (wParam = 0x0001) ; WM_CREATE
	{
		wId:= lParam ; wID is Window Handle
		WinGetTitle, wTitle, ahk_id %wId% ; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId% ; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute

        ; Only act on the specific Window
		If (wClass = "Qt5152QWindowIcon" AND wTitle = "Windowed Projector (Preview)"
        OR wClass = "Qt5152QWindowIcon" AND wTitle = "Windowed Projector (Program)")
			ToggleCloseButton(wId, false)
	}
}
*/

GUI_Toggle(GUI, Toggle := "-Disabled") {
    Loop % GuiGroup.Count()
    {
        If (GuiGroup[A_Index] != GUI)
            Gui, % GuiGroup[A_Index] ":" Toggle
    }
}

; by Skan https://autohotkey.com/board/topic/80593-how-to-disable-grey-out-the-close-button/
ToggleCloseButton(Hwnd, Boolean := false)
{
	hSysManager:=DllCall("GetSystemMenu","Int",Hwnd,"Int",Boolean)
	nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
	DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
	DllCall("DrawMenuBar","Int",Hwnd)
}

; NEED A REWORK
FullscreenToWindow(ID, X := 10, Y := 10, Width := 1600, Height := 900, Debug := false)
{
    ; WinGet, ID, ID, % "ahk_id" A_Space ID
    WinGetPos(ID, Get_X, Get_Y, Get_Width, Get_Height)

    SysGet, MonitorPrimary, MonitorPrimary
    SysGet, MonitorCount, MonitorCount

    Monitor := Object()
    Loop % MonitorCount
    {
        SysGet, MonitorPos, Monitor, % A_Index

        Monitor[A_Index] := Object()
        Monitor["Total"] := Object()
        Monitor[A_Index]["Pos"] := Object()

        Monitor[A_Index]["Pos"]["Left"] := MonitorPosLeft
        Monitor[A_Index]["Pos"]["Right"] := MonitorPosRight
        Monitor[A_Index]["Pos"]["Top"] := MonitorPosTop
        Monitor[A_Index]["Pos"]["Bottom"] := MonitorPosBottom

        Monitor[A_Index]["Width"] := MonitorPosLeft > MonitorPosRight ? MonitorPosLeft - MonitorPosRight : MonitorPosRight - MonitorPosLeft
        Monitor[A_Index]["Height"] := MonitorPosTop > MonitorPosBottom ? MonitorPosTop - MonitorPosBottom : MonitorPosBottom - MonitorPosTop

        Monitor["Total"]["Left"] := (Monitor[A_Index]["Pos"]["Left"] > MonitorPosLeft) ? MonitorPosLeft : Monitor[A_Index]["Pos"]["Left"]
        Monitor["Total"]["Right"] := (Monitor[A_Index]["Pos"]["Right"] > MonitorPosRight) ? MonitorPosRight : Monitor[A_Index]["Pos"]["Right"]
        Monitor["Total"]["Top"] := (Monitor[A_Index]["Pos"]["Top"] > MonitorPosTop) ? MonitorPosTop : Monitor[A_Index]["Pos"]["Top"]
        Monitor["Total"]["Bottom"] := (Monitor[A_Index]["Pos"]["Bottom"] > MonitorPosBottom) ? MonitorPosBottom : Monitor[A_Index]["Pos"]["Bottom"]
    }

    Loop % MonitorCount
        If (Get_X >= Monitor[A_Index]["Pos"]["Left"] AND Get_Width <= Monitor[A_Index]["Pos"]["Right"] AND Get_Y >= Monitor[A_Index]["Pos"]["Top"] AND Get_Height <= Monitor[A_Index]["Pos"]["Bottom"])
            Selected := A_Index

    If (Get_X == Monitor[Selected]["Pos"]["Left"] AND Get_Width == Monitor[Selected]["Width"] AND Get_Y == Monitor[Selected]["Pos"]["Top"] AND Get_Height == Monitor[Selected]["Height"])
    {
        Loop
        {
            If (!WinActive("ahk_id" A_Space ID))
                WinActivate, % "ahk_id" A_Space ID

            If (WinActive("ahk_id" A_Space ID))
            {
                SendInput !{Enter}

                WinMove, % "ahk_id" A_Space ID,, % Monitor[Selected]["Width"] - Get_Width - X, % Y, % Width, % Height
                WinGetPos(ID, Get_X, Get_Y, Get_Width, Get_Height)

                If (Get_Width == Width AND Get_Height == Height)
                    break
            }
        }
    }

    Data := "---Window---" "`n"
            . "Index:" A_Tab A_Tab Selected "`n"
            . "X:" A_Tab A_Tab Get_X "`n"
            . "Y:" A_Tab A_Tab Get_Y "`n"
            . "W:" A_Tab A_Tab Get_Width "`n"
            . "H:" A_Tab A_Tab Get_Height "`n"
            . "---Monitor---" "`n"
            . "Count:" A_Tab A_Tab MonitorCount "`n"
            . JSON.Dump(Monitor,,4) "`n"
            /*
            . "Left:" A_Tab A_Tab Monitor[Selected]["Pos"]["Left"] "`n"
            . "Right:" A_Tab A_Tab Monitor[Selected]["Pos"]["Right"] "`n"
            . "Top:" A_Tab A_Tab Monitor[Selected]["Pos"]["Top"] "`n"
            . "Bottom:" A_Tab A_Tab Monitor[Selected]["Pos"]["Bottom"] "`n`n"
            . "Width:" A_Tab A_Tab Monitor[Selected]["Width"] "`n"
            . "Height:" A_Tab A_Tab Monitor[Selected]["Height"] "`n`n"
            */
            . "Total Left:" A_Tab Monitor["Total"]["Left"] "`n"
            . "Total Right:" A_Tab Monitor["Total"]["Right"] "`n"
            . "Total Top:" A_Tab Monitor["Total"]["Top"] "`n"
            . "Total Bottom:" A_Tab Monitor["Total"]["Bottom"]

    If (Debug)
        ToolTip % Data
}

#Include %A_ScriptDir%\include\DebugWindow.ahk
#Include %A_ScriptDir%\include\DebugOBS.ahk
