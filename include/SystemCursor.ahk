SystemCursor(Toggle := 1)
{
    If (Toggle == 1)
        DllCall("ShowCursor", Int, Toggle)
    else
        DllCall("ShowCursor", Int, Toggle)
}
