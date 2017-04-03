Class BinderGUI extends GUI {
	static DDLAssignments := "Built-in|Multimedia|Imgur|Mouse Function|Launch Application"
	static EditAssignments := "Send Text|Launch Website|Launch File/Program"
	static WIDTH := 180, HEIGHT := 215, CONTROL_HEIGHT := 26
	
	AddButton() {
		Key := this.GuiControlGet(, Binder.MainHotkeyHWND)
		EditText := this.GetText("Edit1")
		Rebind := this.GuiControlGet(, Binder.BindHotkeyHWND)
		
		if !StrLen(Key) && this.ShowHotkey {
			TrayTip, % AppName, Please input a Hotkey.
			return
		}
		
		; create nugget
		if (this.Assignment ~= this.DDLAssignments) { ; assignment used a dll control, get the data from it
			
			for Index, Action in Actions.List[this.Assignment]
				if (Action.Desc = this.Function)
					Bind := Action
			
		} else if (this.Assignment ~= this.EditAssignments) { ; assignment used an edit control
			
			if !StrLen(EditText) {
				SoundPlay, *-64
				return
			}
			
			if (this.Assignment = "Launch Website")
				Bind := {Desc:"Website: " EditText, Func:"Run", Param:[EditText]}
			else if (this.Assignment = "Send Text")
				Bind := {Desc:"Send Text: " EditText, Func:"SendRaw", Param:[EditText]}
			else if (this.Assignment = "Launch File/Program") {
				SplitPath, EditText, OutFileName
				Bind := {Desc:"Launch: " OutFileName, Func:"Run", Param:[EditText]}
			}
			
		} else if (this.Assignment = "Rebind Key") {
			if !StrLen(Rebind) {
				SoundPlay, *-64
				return
			} Bind := {Desc:"Rebound to: " HotkeyToString(Rebind), Func:"Send", Param:[Rebind]}
		} else if (this.Assignment = "Launch Application") {
			; todo
		}
		
		if !IsObject(Bind) || !StrLen(Bind.Desc) { ; throw an error if we don't have a bind object
			Error("Unable to create Bind nugget", A_ThisFunc, "Key: " key "`nAssignment: " this.Assignment "`nFunction: " this.Function "`nEdit: " EditText "`nRebind: " Rebind)
			TrayTip, Error, Unable to create create nugget.`nAn error log has been saved.
			this.Close()
		} else
			this.Close(Bind, Key)
	}
	
	HotkeyChange() {
		Key := this.GuiControlGet(, Binder.MainHotkeyHWND)
		
		if IsObject(Keybinds[Key]) {
			this.KeyInUse := true
			this.Control(, "Static1", "KEY IN USE!")
			this.Font("cRed")
			this.Control("Font", "Static1")
		} else if this.KeyInUse {
			this.KeyInUse := false
			this.SetText("Static1", "Key:")
			this.Font("cBlack")
			this.Control("Font", "Static1")
		}
	}
	
	AssignmentDDL() {
		this.Assignment := this.GetText("ComboBox1")
		this.SetAssignment(this.Assignment)
	}
	
	FunctionDDL() {
		this.Function := this.GetText("ComboBox2")
	}
	
	SetAssignment(Assignment) { ; Static3
		if (Assignment ~= this.DDLAssignments) { ; function needs a ddl control
			for Index, Functions in Actions.List[Assignment], DDLList:=""
				DDLList .= Functions.Desc "|"
			this.SetText(Binder.AssignmentTextHWND, "Function:")
			this.Control("Text", "ComboBox2", "|" DDLList)
			this.Control("Choose", "ComboBox2", 1)
			this.ControlShow("ComboBox2")
			this.Function := Actions.List[Assignment][1].Desc
		} else if (Assignment ~= this.EditAssignments) { ; function needs an edit control
			this.SetText("Edit1")
			this.ControlShow("Edit1")
			if (Assignment = "Send Text")
				this.SetText(Binder.AssignmentTextHWND, "Text to Send:")
			else if (Assignment = "Launch Website")
				this.SetText(Binder.AssignmentTextHWND, "Website URL:")
			else if (Assignment = "Launch File/Program") {
				this.SetText(Binder.AssignmentTextHWND, "Select file:")
				this.ControlShow("Button1") ; hide 'em all
				this.Control("Show", "Edit1")
				this.Control("Enable", "Edit1")
				this.Control("Move", "Edit1", "w" this.WIDTH - 16 - this.CONTROL_HEIGHT)
				this.Control("+ReadOnly", "Edit1")
			}
		} else if (Assignment = "Rebind Key") {
			this.SetText(Binder.AssignmentTextHWND, "Rebind to:")
			this.ControlShow(Binder.BindHotkeyHWND)
		} 
	}
	
	ControlShow(SelectControl) {
		if (SelectControl = "Edit1") {
			this.Control("Move", "Edit1", "w" this.WIDTH - 12)
			this.Control("-ReadOnly", "Edit1")
		}
		for Index, Control in ["ComboBox2", "Edit1", Binder.BindHotkeyHWND, "Button1"] {
			this.Control(SelectControl=Control?"Show":"Hide", Control)
			this.Control(SelectControl=Control?"Enable":"Disable", Control)
		} 
	}
	
	SelectFile() {
		this.Disable()
		this.Options("+OwnDialogs")
		FileSelectFile, out, S, % A_ProgramFiles, Select a file:
		if ErrorLevel
			return this.Enable()
		this.SetText("Edit1", out)
		ControlSend, Edit1, {End}, % this.ahkid
		this.Enable()
	}
	
	DeletePress() {
		ControlGetFocus, ctrl, % this.ahkid
		
		if (ctrl != "msctls_hotkey321")
			return
		
		if GetKeyState("CTRL", "P")
			Key .= "^"
		if GetKeyState("SHIFT", "P")
			Key .= "+"
		if GetKeyState("ALT", "P")
			Key .= "!"
		
		Key .= "Del"
		
		Binder.SetText("msctls_hotkey321", Key)
		
		; check if in use
		this.HotkeyChange()
		
	}
	
	/*
		if InStr(Hotkey, "^")
			ret := "CTRL + ", i++
		if InStr(Hotkey, "+")
			ret .= "SHIFT + ", i++
		if InStr(Hotkey, "!")
			ret .= "ALT + ", i++
	*/
	
	Close(Bind := "", Key := "") {
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", 60, "UInt", "0x90000")
		WinActivate("ahk_id" this.Owner)
		
		this.Destroy()
		
		this.Callback.Call(Bind, Key)
	}
	
	Escape() {
		this.Close()
	}
}

CreateNugget(Callback, ShowHotkey := true, Owner := "") {
	
	; list of assignments
	AssignmentList := [	  "Multimedia"
					, "Imgur"
					, "Built-in"
					, "Mouse Function"
					, "Send Text"
					, "Rebind Key"
					, "Launch File/Program"
					, "Launch Website"
					, "Launch Application"]
	
	; parse assignments for the ddl control
	for Index, Assignment in AssignmentList
		AssignmentDDL .= Assignment "|"
	
	Binder := new BinderGUI()
	
	Binder.Font("s10", Settings.Font)
	Binder.Margin(6, 4)
	
	Binder.ShowHotkey := ShowHotkey
	Binder.Callback := Callback
	Binder.Owner := Owner
	
	WIDTH := Binder.WIDTH
	HEIGHT := Binder.HEIGHT
	CONTROL_HEIGHT := Binder.CONTROL_HEIGHT
	
	; main hotkey control
	if ShowHotkey {
		Binder.Add("Text", "Center x0 w" WIDTH, "Key:")
		Binder.MainHotkeyHWND := Binder.Add("Hotkey", "x6 yp+25 w" WIDTH-12 " Center",, Binder.HotkeyChange.Bind(Binder))
	}
	
	Binder.Add("Text", "x0 w" WIDTH " Center", "Assignment:")
	Binder.Add("DropDownList", "x6 w" WIDTH-12 " h" CONTROL_HEIGHT " Choose1 R99", AssignmentDDL, Binder.AssignmentDDL.Bind(Binder))
	Binder.Add("Text", "x6 yp+" 8+CONTROL_HEIGHT " w" WIDTH-12 " h1 0x08") ; separator
	Binder.AssignmentTextHWND := Binder.Add("Text", "x0 w" WIDTH " Center", "Function:")
	
	Binder.Add("DropDownList", "x6 w" WIDTH-12 " h" CONTROL_HEIGHT " Choose1 Hidden R99",, Binder.FunctionDDL.Bind(Binder))
	Binder.EditHWND := Binder.Add("Edit", "x6 yp w" WIDTH-12 " h" CONTROL_HEIGHT)
	Binder.Font("s9", "Wingdings")
	Binder.Add("Button", "x" WIDTH - 6 - CONTROL_HEIGHT " yp-1 w" CONTROL_HEIGHT " h" CONTROL_HEIGHT + 2, "1", Binder.SelectFile.Bind(Binder))
	Binder.Font("s10", Settings.Font)
	Binder.BindHotkeyHWND := Binder.Add("Hotkey", "x6 yp+1 w" WIDTH - 12 " h" CONTROL_HEIGHT " w" WIDTH-12)
	
	Binder.Margin(6, 10)
	Binder.Add("Text", "x6 yp+" 8+CONTROL_HEIGHT " w" WIDTH-12 " h1 0x08") ; separator
	Binder.Add("Button", "x6 yp+8 h" CONTROL_HEIGHT, "Cancel", Binder.Close.Bind(Binder))
	Binder.Add("Button", "xp" WIDTH - (ShowHotkey?95:61) " yp h" CONTROL_HEIGHT, ShowHotkey?"Add Keybind":"Create", Binder.AddButton.Bind(Binder))
	Binder.Options("+Owner" Owner " -Caption +Border +AlwaysOnTop") ; remove border and caption and make BigGUI the owner
	
	; set initial values
	Binder.SetAssignment("Multimedia"), Binder.Assignment := "Multimedia", Binder.Function := "Play/Pause"
	
	FrameShadow(Binder.hwnd)
	
	Hotkey.Bind("*Delete", Binder.DeletePress.Bind(Binder), Binder.hwnd)
	
	if (OwnerPos := WinGetPos("ahk_id" Owner))
		Binder.Show("x" OwnerPos.X + OwnerPos.W/2 - 182/2 " y" OwnerPos.Y + OwnerPos.H/2 - 218/2 + 15 " w" WIDTH " h" HEIGHT)
	else
		Binder.Show()
	
}