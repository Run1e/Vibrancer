; found base code somewhere, I cleaned up it *drastically*
ShowCursor(Show) {
	static Init := false, DefaultCurs := [], BlankCurs := []
	static SysCurs := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
	
	if !Init {
		VarSetCapacity(AndMask, 32*4, 0xFF)
		VarSetCapacity(XorMask, 32*4, 0)
		for Index, Curs in SysCurs {
			DefaultCurs[A_Index] := DllCall("CopyImage", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", Curs), "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
			BlankCurs[A_Index] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", &AndMask, "Ptr", &XorMask)
		}
	}
	
	for Index, Curs in SysCurs
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", (Show ? DefaultCurs : BlankCurs)[A_Index], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", Curs)
}


/*
	showcursor(x) {
		
	}
*/

; https://autohotkey.com/boards/viewtopic.php?t=29793 ty jNizM
GetCursorInfo() ; https://msdn.microsoft.com/en-us/library/ms648381(v=vs.85).aspx
{
	NumPut(VarSetCapacity(CURSORINFO, 16 + A_PtrSize, 0), CURSORINFO, "uint")
	if !(DllCall("user32\GetCursorInfo", "ptr", &CURSORINFO))
		return A_LastError
	return NumGet(CURSORINFO, 8, "ptr") ; hCursor
}

; removes grey border around buttons
CtlColorBtns() {
	static init := OnMessage(0x0135, "CtlColorBtns")
	return DllCall("gdi32.dll\CreateSolidBrush", "uint", 0xFFFFFF, "uptr")
}

ImageButtonApply(hwnd) {
	static RoundPx := 2
	static ButtonStyle:= [[3, "0xEEEEEE", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; normal
					, [3, "0xFFFFFF", "0xDDDDDD", "Black", RoundPx,, "Gray"] ; hover
					, [3, "White", "White", "Black", RoundPx,, "Gray"] ; click
					, [3, "Gray", "Gray", "0x505050", RoundPx,, "Gray"]] ; disabled
	
	If !ImageButton.Create(hwnd, ButtonStyle*)
		MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
}

Run(File) {
	if FileExist(File)
		SplitPath, File,, Dir
	try {
		Run, % File, % Dir
		return true
	} catch e
		return false
}

TrayTip(Title, Msg := "") {
	if !StrLen(Msg)
		Msg := Title, Title := AppName " " AppVersionString
	if Func("Event").Call("TrayTip", Title, Msg)
		return
	TrayTip, % Title, % Msg
}

as(arr) {
	return ArraySize(arr)
}

ArraySize(arr) {
	return NumGet(&arr, 4*A_PtrSize)
}

QPC(R := 0) { ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
	static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
	return !DllCall("QueryPerformanceCounter", "Int64P" , Q) + (R ? (P:=Q)/F : (Q-P)/F)
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

RandB64(length) {
	static pool := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	Loop % length
		str .= SubStr(pool, Random(1, 64), 1)
	return str
}

RegRead(root, sub, value) {
	RegRead, output, % root, % sub, % value
	return output
}

; https://autohotkey.com/board/topic/27849-solved-animated-gui-windows-causing-clipboard-set-error/
Clipboard(clip) {
	DllCall("OpenClipboard", uint, 0)
	DllCall("EmptyClipboard")
	DllCall("CloseClipboard")
	clipboard := clip
}

; https://autohotkey.com/boards/viewtopic.php?t=9093
WinGetPos(hwnd) {
	WinGetPos, x, y, w, h, % hwnd
	if ErrorLevel
		return false
	return {x:x, y:y, w:w, h:h}
}

; unsure who wrote the original funciton. however I cleaned it up drastically
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
		DllCall("SetSystemCursor", Uint, CursorHandle, Int, ID)
}

RunClipboardKeybindText() {
	for Key, Bind in Keybinds.Data()
		if (Bind.Func = "RunClipboard")
			return "`nClipboard Keybind: " HotkeyToString(Key)
}

reload() {
	reload
}

hexblend(c1, c2) {
	if (InStr(c1, "0x") = 1)
		c1:=SubStr(c1, 3)
	if (InStr(c2, "0x") = 1)
		c2:=SubStr(c2, 3)
	Loop 3 {
		a := hex2int("0x" SubStr(c1, (1 + (A_Index-1)*2), 2))
		b := hex2int("0x" SubStr(c2, (1 + (A_Index-1)*2), 2))
		x := int2hex(Round((a+b)/2))
		out .= SubStr(x, 3)
	} return "0x" out
}

Int2Hex(i) {
	def:=A_FormatInteger
	if (i = 0) || (i = "")
		return 00
	add := i < 16
	SetFormat, Integer, H
	x:=i
	SetFormat, Integer, % def
	return "0x" (add?0:"") SubStr(x, 3)
}

Hex2Int(h) {
	return h+0
}