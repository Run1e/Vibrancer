; unsure who wrote the original function. however I cleaned it up drastically
Cursor(Cursor := "") {
	static Cursors := 	{ "IDC_ARROW":32512		, "IDC_IBEAM":32513	, "IDC_WAIT":32514		, "IDC_CROSS":32515
					, "IDC_UPARROW":32516	, "IDC_SIZE":32640	, "IDC_ICON":32641		, "IDC_SIZENWSE":32642
					, "IDC_SIZENESW":32643	, "IDC_SIZEWE":32644, "IDC_SIZENS":32645	, "IDC_SIZEALL":32646
					, "IDC_NO":32648		, "IDC_HAND":32649	, "IDC_APPSTARTING":32650, "IDC_HELP":32651}
	
	if !StrLen(Cursor)
		return DllCall(  "SystemParametersInfo"
					, UInt, 0x57 ; SPI_SETCURSORS
					, UInt, 0
					, UInt, 0
					, UInt, 0)
	
	CursorHandle := DllCall("LoadCursor", Uint, 0, Int, Cursors[cursor])
	
	for Index, ID in [32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651]
		DllCall("SetSystemCursor", "Ptr", CursorHandle, Int, ID)
}

; found base code somewhere, I cleaned up it *drastically*
ShowCursor(Show) {
	static Init := false
	static DefaultCurs := []
	static BlankCurs := []
	static SysCurs := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
	
	if !Init {
		VarSetCapacity(AndMask, 32*4, 0xFF)
		VarSetCapacity(XorMask, 32*4, 0)
		for Index, Curs in SysCurs {
			DefaultCurs[A_Index] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", Curs), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
			BlankCurs[A_Index] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &AndMask, "Ptr", &XorMask)
		} Init := true
	}
	
	for Index, Curs in SysCurs
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", (Show ? DefaultCurs : BlankCurs)[A_Index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", Curs)
}