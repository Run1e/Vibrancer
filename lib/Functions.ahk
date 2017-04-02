Run(file) {
	if FileExist(file)
		SplitPath, file,, dir
	try
		run, % file, % dir
	catch e
		return false
	return true
}

TrayTip(Title, Msg) {
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

pas(array, seperator:=", ", depth=5, indentLevel:="") {
	return StrReplace(pa(array, depth, indentLevel), "`n", seperator)
}

pap(array) {
	m(pa(array))
}

m(x*){
	for a,b in x
		text.=b "`n"
	MsgBox,0, % AppName, % text
}

SysGet(sub, param3 := "") {
	SysGet, out, % sub, % param3
	return out
}

ArraySize(arr) {
	return NumGet(&arr, 4*A_PtrSize)
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

HotkeyToString(hotkey, caps := true) {
	i:=0
	if InStr(Hotkey, "^")
		ret := "CTRL + ", i++
	if InStr(Hotkey, "+")
		ret .= "SHIFT + ", i++
	if InStr(Hotkey, "!")
		ret .= "ALT + ", i++
	add := SubStr(Hotkey, i+1)
	if caps
		StringUpper, add, add
	return ret . add
}

StringToHotkey(string) {
	mod := {SHIFT:"+",CTRL:"^", ALT:"!"}
	for a, b in mod
		string := StrReplace(string, a, b)
	return StrReplace(string, " + ", "")
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

POST(URL, POST := "", TIMEOUT_SECONDS := 5, PROXY := "") {
	static HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	
	; check for internet connection
	if !DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
		return false
	
	; open the URL and set header
	HTTP.Open("POST", URL, true)
	HTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	
	; set proxy if specified or the internet explorer settings have it set
	RegRead ProxyEnable, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyEnable
	if PROXY
		HTTP.SetProxy(2, PROXY)
	else if ProxyEnable {
		RegRead ProxyServer, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Internet Settings, ProxyServer
		HTTP.SetProxy(2, ProxyServer)
	}
	
	; make the POST string if it's specified as an object
	if IsObject(POST)
		for Key, Value in POST
			POST .= (A_Index > 1 ? "&" : "") Key "=" UriEncode(Value)
	
	; send
	HTTP.Send(POST)
	
	try {
		if HTTP.WaitForResponse(TIMEOUT_SECONDS)
			return HTTP.ResponseText
	} catch e
		return false
	return false
}

UriEncode(Uri) { ; thanks to GeekDude for providing this function!
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
	StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	while Code := NumGet(Var, A_Index - 1, "UChar")
		if (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
	else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	return, Res
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