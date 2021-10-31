SetParentByHWND(HWND1, HWND2)
{
	If (HWND1)
		WinGetTitle, WinTitle, % "ahk_id" A_Space HWND1
	else
		WinTitle := false
	Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "uint",0, "str", WinTitle)
	return DllCall("SetParent", "uint", HWND2, "uint", Parent_Handle)

}

GetParent(HWND)
{
	SetFormat, Integer, Hex
	return DllCall("GetParent", UInt, HWND)
}

/*
SetParentByClass(Class1, Class2)
{
	Parent_Handle := DllCall("FindWindowEx", "uint",0, "uint",0, "str", Class1, "uint",0)
	return DllCall("SetParent", "uint", Class2, "uint", Parent_Handle)
}
*/

SetParentByTitle(Title1, Title2)
{
	WinGet, WinID, ID, % Title2
	Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "uint",0, "str", Title1)
	return DllCall("SetParent", "uint", WinID, "uint", Parent_Handle)
}
