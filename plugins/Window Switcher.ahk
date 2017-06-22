; Quickly change active window
; RUNIE
#SingleInstance force
#NoEnv
#NoTrayIcon
SetBatchLines -1
DetectHiddenWindows Off

#Include %A_ScriptDir%
#Include ..\lib\third-party\Class LV_Colors.ahk
#Include ..\lib\third-party\LV_EX.ahk
#Include ..\lib\Class GUI.ahk
#Include ..\lib\Class Hotkey.ahk
#Include ..\lib\Functions.ahk

#Include ..\lib\plugin\BindSection.ahk

try
	Vib := ComObjActive("{40677552-fdbd-444d-a9dd-6dce43b0cd56}")
catch e
	ExitApp

Vib.OnExit(Func("Exit"))

; bind section
Binds := new BindSection(Vib, "Window Switcher", "WinSwitch")
Binds.AddFunc("Open", Func("Toggle"))
Binds.AddBind("Open GUI", "Open")
Binds.Register()

Vib.Finished()

; === CONFIGURATION ===
Key := "^!I"
Width := 500
MaxItems := 15
LargeIcons := true
CenterText := false
MoveUp := 120
Color := "404040"
SelColor := "44C6F6"
Prefix := "."
AllowDupe := true
FadeTime := 50
IgnoreEquals := "^(NVIDIA GeForce Overlay|Program Manager|Settings)$"
; === END CONFIGURATION ===

global Vib, Key, Width, MaxItems, Color, MoveUp, LargeIcons, FontSize, IgnoreEquals, Prefix, AllowDupe, FadeTime

; set up gui
Switcher := new Switcher("Window Switcher", "-Caption +Border +ToolWindow")
Switcher.Margin(0, 0)
Switcher.Color(Color, Color)
Switcher.Font("s11 cWhite")
Switcher.Edit := Switcher.Add("Edit", "w" Width " h26 -Border -Multi " (CenterText ? "Center" : ""),, Switcher.Input.Bind(Switcher))
Switcher.LV := new Gui.ListView(Switcher, "x0 y26 w" Width " h100  -HDR -Multi +LV0x10000 +LV0x4000 -E0x200 AltSubmit -TabStop", "title|exe", Switcher.ListViewAction.Bind(Switcher))
Switcher.CLV := new LV_Colors(Switcher.LV.hwnd)
Switcher.CLV.SelectionColors("0x" SelColor, "0xFFFFFF")
Switcher.IL := new Gui.ImageList(,, LargeIcons)
Switcher.LV.SetImageList(Switcher.IL.ID)
Switcher.Icons := []

; bind hotkeys
new Hotkey("Enter", Switcher.Go.Bind(Switcher), Switcher.ahkid)
new Hotkey("Delete", Switcher.Stop.Bind(Switcher), Switcher.ahkid)
new Hotkey("Up", Switcher.Move.Bind(Switcher, -1), Switcher.ahkid)
new Hotkey("Down", Switcher.Move.Bind(Switcher, +1), Switcher.ahkid)
new Hotkey("^Backspace", Switcher.CtrlBackspace.Bind(Switcher), Switcher.ahkid)
return

Toggle() {
	Switcher.Toggle()
}

Exit() {
	ExitApp
}

Class Switcher extends Gui {
	Input(x*) {
		GuiControlGet, text,, % this.Edit
		this.LV.Delete()
		if (SubStr(text, 1, 1) = Prefix) {
			;this.LV.Add("Icon0", "Reload", "COMMAND")
			this.LV.Add("Icon0", "Exit", "COMMAND")
			this.SizeCtrl()
			return
		}
		for Index, Info in Fuzzy(text, this.List, "Search") ; search over this.list with the needle text, in the attribute Title
			this.LV.Add("Icon" this.Icons[Info.Exe], Info.Title, Info.hwnd)
		this.SizeCtrl()
	}
	
	ListViewAction(x*) {
		if (x.2 = "DoubleClick")
			this.Go()
	}
	
	Go() {
		Selected := this.LV.GetNext()
		ID := this.LV.GetText(Selected, 2)
		if (ID = "COMMAND") {
			text := this.LV.GetText(Selected, 1)
			Command(text)
			this.Close()
			return
		}
		this.Close()
		WinActivate % "ahk_id" ID
	}
	
	Stop() {
		Selected := this.LV.GetNext()
		ID := this.LV.GetText(Selected, 2)
		this.LV.Delete(Selected)
		this.SizeCtrl(Selected)
		for Index, Thing in this.List {
			if (Thing.hwnd = ID) {
				this.List.Remove(Index)
				break
		}} WinClose % "ahk_id" id
	}
	
	Move(Dir) {
		Selected := this.LV.GetNext()
		Count := this.LV.GetCount()
		New := Selected + Dir
		if (New < 1) || (New > Count)
			return
		this.LV.Modify(New, "Select Vis")
		this.Control("Focus", this.Edit)
	}
	
	Open() {
		if this.IsVisible
			return
		this.List := []
		this.LV.Delete()
		WinGet windows, List
		Added := []
		Loop %windows%
		{
			ID := windows%A_Index%
			if !WinExist("ahk_id" ID) || (this.ahkid = "ahk_id" id)
				continue
			WinGetTitle Title, % "ahk_id" ID
			WinGet, ProcessName, ProcessName, % "ahk_id" ID
			ProcessName := StrSplit(ProcessName, ".").1
			WinGet, Exe, ProcessPath, % "ahk_id" ID
			if StrLen(Exe) && StrLen(Title) && !(Title ~= IgnoreEquals) && (!Added.HasKey(Title)) {
				if !this.Icons.HasKey(Exe)
					Icon := this.Icons[Exe] := this.IL.Add(Exe)
				else
					Icon := this.Icons[Exe]
				if !Icon
					continue
				this.List.Push({Title:Title, Exe:Exe, hwnd:ID, Search:(Title " " ProcessName)})
				if !AllowDupe
					Added[Title] := true
				this.LV.Add("Icon" Icon, Title, ID)
			}
		} this.SizeCtrl()
		this.Show("Hide") ; "activate"
		this.Animate("FADE_IN", FadeTime)
		this.Show()
		this.Control("Focus", this.Edit)
		this.LV.Modify(1, "Select Vis Focus")
	}
	
	SizeCtrl(Pos := 1) {
		static VERT_SCROLL, ROW_HEIGHT
		if !VERT_SCROLL
			SysGet, VERT_SCROLL, 2
		if !ROW_HEIGHT
			ROW_HEIGHT := LV_EX_GetRowHeight(this.LV.hwnd)
		this.LV.Redraw(false)
		Count := this.LV.GetCount()
		this.LV.ModifyCol(1, Width - ((Count > MaxItems) ? VERT_SCROLL : 0))
		this.Pos(A_ScreenWidth/2 - Width/2, A_ScreenHeight/2 - MoveUp,, 26 + (MaxItems > Count ? Count : MaxItems) * ROW_HEIGHT)
		this.Control("Move", this.LV.hwnd, "h" (ROW_HEIGHT * (MaxItems > Count ? Count : MaxItems)))
		this.LV.Modify((Pos>Count?Count:Pos), "Select Vis")
		this.LV.ModifyCol(2, 0)
		this.LV.Redraw(true)
	}
	
	Close() {
		if !this.IsVisible
			return
		this.SetText(this.Edit, "")
		this.Hide()
	}
	
	Toggle() {
		this[this.IsVisible ? "Close" : "Open"]()
	}
	
	CtrlBackspace() {
		this.Control("-Redraw", "Edit1")
		ControlSend, Edit1, ^+{Left}{Backspace}, % this.ahkid
		this.Control("+Redraw", "Edit1")
	}
	
	Escape() {
		this.Close()
	}
}

Command(cmd) {
	if (cmd = "reload")
		reload
	if (cmd = "Exit")
		ExitApp
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
	MsgBox, 0, msgbox, % text
}

Fuzzy(input, arr, att) {
	
	arren:=[]
	input := StrReplace(input, " ", "")
	
	if !StrLen(input) { ; input is empty, just return the array
		for id, item in arr
			arren.Insert(item)
		return arren
	}
	
	for id, item in arr {
		taken:=[], needle:="i)", limit:=false
		name:=StrReplace(item[att], " ", "")
		Loop, Parse, input
			taken[A_LoopField] := (StrLen(taken[A_LoopField])?taken[A_LoopField]+1:1)
		for char, hits in taken {
			StrReplace(name, char, char, found)
			if (found<hits) {
				limit:=true
				break
			} needle .= "(?=.*\Q" char "\E)"
		} if RegExMatch(name, needle) && !limit
			arren.Insert(item)
	}
	
	for index, item in arren, outline := [] { ; get outlines based on spaces
		for num, word in StrSplit(item[att], " ") {
			outline[item.id] .= SubStr(word, 1, 1)
			continue
		}
	}
	
	for index, item in arren, i:=0 ; contains
		if InStr(item[att], input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; outline
		if InStr(RegExReplace(item[att], "[^A-Z0-9]"), input) || InStr(outline[item.id], input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start (contains)
		if (SubStr(item[att], InStr(item[att], input) - 1, 1) = " ") && InStr(item.name, input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start
		if (InStr(item[att], input) = 1)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; outline is equal to input
		if (outline[item.id] = input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start and ONLY word
		if (InStr(item[att], input) = 1) && !InStr(item[att], " ")
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	return arren
}