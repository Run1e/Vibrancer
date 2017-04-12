; removes grey border around buttons
CtlColorBtns() {
	static init := OnMessage(0x0135, "CtlColorBtns")
	return DllCall("gdi32.dll\CreateSolidBrush", "uint", 0xFFFFFF, "uptr")
}

Run(file) {
	if FileExist(file)
		SplitPath, file,, dir
	try
		run, % file, % dir
	catch e
		return false
	return true
}

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		TrayTip, % AppName " " AppVersionString, % Title
	else
		TrayTip, % Title, % Msg
}

pa(array, depth=5, indentLevel:="   ") { ; tidbit, this has saved my life
	try {
		for k,v in Array {
			lst.= indentLevel "[" k "]"
			if (IsObject(v) && depth>1)
				lst.="`n" pa(v, depth-1, indentLevel . "    ")
			else
				lst.=" => " v
			lst.="`n"
		} return rtrim(lst, "`r`n `t")	
	} return
}

m(x*) {
	for a, b in x
		text .= (IsObject(b)?pa(b):b) "`n"
	MsgBox, 0, % AppName, % text
}

pas(array, seperator:=", ", depth=5, indentLevel:="") {
	return StrReplace(pa(array, depth, indentLevel), "`n", seperator)
}

as(arr) {
	return ArraySize(arr)
}

ArraySize(arr) {
	return NumGet(&arr, 4*A_PtrSize)
}

SysGet(sub, param3 := "") {
	SysGet, out, % sub, % param3
	return out
}


ObjFullyClone(obj) {
	nobj := obj.Clone()
	for k,v in nobj
		if IsObject(v)
			nobj[k] := A_ThisFunc.(v)
	return nobj
}

FileRead(file) {
	FileRead, out, % file
	return out
}

WinActivate(win) {
	WinActivate % win
}

HotkeyToString(Hotkey) {
	i:=0
	if InStr(Hotkey, "^")
		ret := "Ctrl + ", i++
	if InStr(Hotkey, "+")
		ret .= "Shift + ", i++
	if InStr(Hotkey, "!")
		ret .= "Alt + ", i++
	ret .= SubStr(Hotkey, i+1)
	StringUpper, ret, ret
	return ret
}

StringReplace(hay, needle, repl) {
	StringReplace, hay, hay, % needle, % repl
	return hay
}

Random(min, max) {
	Random, out, % min, % max
	return out
}

RegRead(root, sub, value) {
	RegRead, output, % root, % sub, % value
	return output
}

; https://autohotkey.com/boards/viewtopic.php?t=9093
WinGetPos(hwnd) {
	WinGetPos, x, y, w, h, % hwnd
	if ErrorLevel
		return false
	return {x:x, y:y, w:w, h:h}
}

SetCueBanner(HWND, STRING) { ; thaaanks tidbit
	static EM_SETCUEBANNER := 0x1501
	if (A_IsUnicode) ; thanks just_me! http://www.autohotkey.com/community/viewtopic.php?t=81973
		return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", false, "WStr", STRING)
	else {
		if !(HWND + 0) {
			GuiControlGet, CHWND, HWND, %HWND%
			HWND := CHWND
		} VarSetCapacity(WSTRING, (StrLen(STRING) * 2) + 1)
		DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, UInt, &STRING, Int, -1, UInt, &WSTRING, Int, StrLen(STRING) + 1)
		DllCall("SendMessageW", "UInt", HWND, "UInt", EM_SETCUEBANNER, "UInt", SHOWALWAYS, "UInt", &WSTRING)
		return
	}
}

Cursor(cursor := "") {
	static p, curs := {"IDC_ARROW": 32512, "IDC_IBEAM": 32513, "IDC_WAIT":32514, "IDC_CROSS":32515
	, "IDC_UPARROW":32516, "IDC_SIZE":32640, "IDC_ICON":32641, "IDC_SIZENWSE":32642
	, "IDC_SIZENESW":32643, "IDC_SIZEWE":32644, "IDC_SIZENS":32645, "IDC_SIZEALL":32646
	, "IDC_NO":32648, "IDC_HAND":32649, "IDC_APPSTARTING":32650, "IDC_HELP":32651}
	if !cursor
		return DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS := 0x57, UInt, 0, UInt ,0, UInt, 0)
	else if (p = cursor)
		return
	hndl := DllCall("LoadCursor", Uint, 0, Int, p := curs[cursor])
	for a, b in [32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651]
		DllCall("SetSystemCursor", Uint, hndl, Int, b)
}