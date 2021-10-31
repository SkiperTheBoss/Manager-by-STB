DisplayScale(Width, Height)
{
    Loop
    {
        First := Width / Height  * A_Index
        If (First == Round(First))
        {
            First := Round(First)
            break
        }
    }

    Loop
    {
        Second := Height / Width * A_Index
        If (Second == Round(Second))
        {
            Second := Round(Second)
            break
        }
    }
    return First ":" Second
}
