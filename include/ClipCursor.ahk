ClipCursor(Confine := true, x1 := 0, y1 := 0, x2 := 1, y2 := 1) {
    VarSetCapacity(R,16,0), NumPut(x1,&R+0), NumPut(y1,&R+4), NumPut(x2,&R+8), NumPut(y2, &R+12)
    return Confine ? DllCall("ClipCursor", UInt, &R) : DllCall("ClipCursor")
}

; WORK IN PROGRESS
GetClipCursor(ByRef X1, ByRef Y1, ByRef X2, ByRef Y2) {
    VarSetCapacity(rcOldClip, 16, 0) ; previous area for ClipCursor
    return DllCall("User32.dll\GetClipCursor", "Ptr", &rcOldClip) ; Record the area in which the cursor can move.
}
