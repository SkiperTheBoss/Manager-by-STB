class Borders
{
	__new()
	{
		Gui, 1:-Caption -Border +ToolWindow +AlwaysOnTop +hwndhGui1 +Disabled +LastFound
		Gui, 1:Color, 255
		Gui, 1:Show, Hide w20 h20
		WinSet, Transparent, 100

		Gui, 2:-Caption -Border +ToolWindow +AlwaysOnTop +hwndhGui2 +Disabled +LastFound
		Gui, 2:Color, 255
		Gui, 2:Show, Hide w20 h20
		WinSet, Transparent, 100

		Gui, 3:-Caption -Border +ToolWindow +AlwaysOnTop +hwndhGui3 +Disabled +LastFound
		Gui, 3:Color, 255
		Gui, 3:Show, Hide w20 h20
		WinSet, Transparent, 100

		Gui, 4:-Caption -Border +ToolWindow +AlwaysOnTop +hwndhGui4 +Disabled +LastFound
		Gui, 4:Color, 255
		Gui, 4:Show, Hide w20 h20
		WinSet, Transparent, 100
	}

	Show()
	{
		Gui, 1:Show
		Gui, 2:Show
		Gui, 3:Show
		Gui, 4:Show
	}

	Hide()
	{
		Gui, 1:Hide
		Gui, 2:Hide
		Gui, 3:Hide
		Gui, 4:Hide
	}

	Move(X_Start, Y_Start, Width, Height)
	{
		X_Start += -20
		Y_Start += -20
		X_End := X_Start + Width + 40
		Y_End := Y_Start + Height + 40

		If (X_Start AND Y_Start AND X_End AND Y_End)
		{
			Gui, 1:Show, % "NoActivate" A_Space
						. "x" (X_Start > X_End ? X_End : X_Start) A_Space
						. "y" (Y_Start > Y_End ? Y_End : Y_Start) A_Space
						. "w" (X_Start > X_End ? X_Start - X_End : X_End - X_Start) A_Space

			Gui, 2:Show, % "NoActivate" A_Space
						. "x" (X_Start > X_End ? X_End : X_Start) A_Space
						. "y" (Y_Start > Y_End ? Y_End + 20 : Y_Start + 20) A_Space
						. "h" (Y_Start > Y_End ? Y_Start - Y_End - 40 : Y_End - Y_Start - 40)

			Gui, 3:Show, % "NoActivate" A_Space
						. "x" (X_Start > X_End ?  X_Start - 20 : X_End - 20) A_Space
						. "y" (Y_Start > Y_End ? Y_End + 20 : Y_Start + 20) A_Space
						. "h" (Y_Start > Y_End ? Y_Start - Y_End - 40 : Y_End - Y_Start - 40)

			Gui, 4:Show, % "NoActivate" A_Space
						. "x" (X_Start > X_End ? X_End : X_Start) A_Space
						. "y" (Y_Start > Y_End ? Y_Start - 20 : Y_End - 20) A_Space
						. "w" (X_Start > X_End ? X_Start - X_End : X_End - X_Start) A_Space
		}
	}
}
