; https://autohotkey.com/boards/viewtopic.php?t=29793 ty jNizM
GetCursorInfo() { ; https://msdn.microsoft.com/en-us/library/ms648381(v=vs.85).aspx
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

Run(File, WorkingDir := "") {
	if FileExist(File) && (WorkingDir = "")
		SplitPath, File,, WorkingDir
	try
		Run, % File, % WorkingDir
	catch Exception
		throw Exception
}

as(arr) {
	return ArraySize(arr)
}

ArraySize(arr) {
	return NumGet(&arr, 4*A_PtrSize)
}

QPC(R := 0) { ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
	static P := 0, F := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P", F)
	return !DllCall("QueryPerformanceCounter", "Int64P" , Q) + (R ? (P := Q) / F : (Q - P) / F)
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

/*
	; https://autohotkey.com/board/topic/60706-native-zip-and-unzip-xpvista7-ahk-l/
	Unz(sZip, sUnz) {
		fso := ComObjCreate("Scripting.FileSystemObject")
		If Not fso.FolderExists(sUnz)  ; http://www.autohotkey.com/forum/viewtopic.php?p=402574
			fso.CreateFolder(sUnz)
		psh  := ComObjCreate("Shell.Application")
		zippedItems := psh.Namespace( sZip ).items().count
		psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
		Loop {
			sleep 50
			unzippedItems := psh.Namespace( sUnz ).items().count
			IfEqual,zippedItems,%unzippedItems%
			break
		}
	}
*/

WinActivate(win) {
	WinActivate % win
}

HotkeyToString(Key) {
	for Index, Pre in [["~", "P"], ["*", "W"]]
		if (Pos := InStr(Key, Pre.1))
			Prefixes .= Pre.2, Key := StrReplace(Key, Pre.1, "")
	for Index, Mod in [["^", "CTRL"], ["+", "SHIFT"], ["!", "ALT"], ["#", "WIN"]]
		if (Pos := InStr(Key, Mod.1))
			Out .= Mod.2 " + ", Key := StrReplace(Key, Mod.1, "")
	StringUpper, Out, % Out . Key
	if StrLen(Prefixes)
		Out := "(" Prefixes ") " Out
	return Out
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
		return 0x00
	add := i < 16
	SetFormat, Integer, H
	x:=i
	SetFormat, Integer, % def
	return "0x" (add?0:"") SubStr(x, 3)
}

Hex2Int(h) {
	return h+0
}