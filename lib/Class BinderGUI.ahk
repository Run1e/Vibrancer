Class BinderGUI extends GUI {
	static IgnoreAssignmentList := "^(Built-in)$"
	
	AddButton() {
		Key := this.GuiControlGet(, Binder.MainHotkeyHWND)
		EditText := this.GetText("Edit1")
		
		if !StrLen(Key)
			return TrayTip("Please input a Hotkey.")
		
		if this.Wildcard
			Key := "*" . Key
		if this.Passthrough
			Key := "~" . Key
		
		; check if key exists, and if yes, does the user wanna overwrite it
		if !this.HotkeyCheck(Key)
			return
		
		; assignment used a dll control, get the data from it
		if Binds.List.HasKey(this.Assignment) {
			for Index, Action in Binds.List[this.Assignment] {
				if (Action.Desc = this.Function) {
					Bind := ObjFullyClone(Action)
					if (this.Assignment = "Launch Application")
						Bind.Desc := "Launch: " Action.Desc
					else
						Bind.Desc := (this.Assignment ~= this.IgnoreAssignmentList ? "" : this.Assignment ": ") Action.Desc
				}
			}
		}
		
		; assignment used an edit control
		else {
			if !StrLen(EditText) {
				SoundPlay, *-64
				return
			}
			
			if (this.Assignment = "Launch Website") {
				if !RegExMatch(EditText, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$")
					return TrayTip("Keybind creation failed", "Website is not a valid URL")
				Bind := {Desc:"Website: " EditText, Func:"Run", Param:[EditText]}
			}
			
			else if (this.Assignment = "Launch File/Program") {
				if !StrLen(this.CustomFileName)
					SplitPath, EditText, FileName
				else
					FileName := this.CustomFileName
				Bind := {Desc:"Launch: " FileName, Func:"Run", Param:[EditText]}
			}
		}
		
		; throw an error if we don't have a bind object
		if !IsObject(Bind) || !StrLen(Bind.Desc) {
			Error("Unable to create bind", A_ThisFunc, "Key: " key "`nAssignment: " this.Assignment "`nFunction: " this.Function "`nEdit: " EditText)
			TrayTip("Unable to create create bind.`nAn error log has been saved.")
			this.Close()
		} else
			this.Close(Bind, Key)
	}
	
	; checks if key exists in the saved keybinds data
	KeyExists(Key) {
		for SavedKey in Keybinds.Data() {
			if (StrReplace(StrReplace(SavedKey, "*", ""), "~", "") = StrReplace(StrReplace(Key, "*", ""), "~", ""))
				return SavedKey
		} return false
	}
	
	GetKey() {
		Key := this.GuiControlGet(, Binder.MainHotkeyHWND)
		if this.Wildcard
			Key := "*" . Key
		if this.Passthrough
			Key := "~" . Key
		return Key
	}
	
	HotkeyChange() {
		Key := this.GetKey()
		
		if this.KeyExists(Key) {
			this.KeyInUse := true
			this.Control(, "Static1", "KEY IN USE!")
			this.Font("cRed")
			this.Control("Font", "Static1")
		} else {
			this.KeyInUse := false
			this.SetText("Static1", "Key:")
			this.Font("cBlack")
			this.Control("Font", "Static1")
		}
	}
	
	; check for dupe hotkey
	HotkeyCheck(Key) {
		ret := true
		if (SavedKey := this.KeyExists(Key)) { ; key is already bound
			this.Options("-AlwaysOnTop")
			this.Disable()
			MsgBox, 52, Duplicate Hotkey, % "This key is already in use!`n`nPrevious function: " Keybinds[SavedKey].Desc "`n`nOverwrite previous function?"
			this.Options("+AlwaysOnTop")
			this.Enable()
			ifMsgBox no
			return false
			else
				Keybinds.Delete(SavedKey)
		} return ret
	}
	
	AssignmentDDL() {
		this.Assignment := this.GetText("ComboBox1")
		this.SetAssignment(this.Assignment)
	}
	
	FunctionDDL() {
		this.Function := this.GetText("ComboBox2")
	}
	
	SetAssignment(Assignment) { ; Static3
		if Binds.List.HasKey(Assignment) { ; function needs a ddl control
			for Index, Functions in Binds.List[Assignment], DDLList:=""
				DDLList .= Functions.Desc "|"
			this.SetText(Binder.AssignmentTextHWND, "Function:")
			this.Control("Text", "ComboBox2", "|" DDLList)
			this.Control("Choose", "ComboBox2", 1)
			this.ControlShow("ComboBox2")
			this.Function := Binds.List[Assignment].1.Desc
		} else { ; function needs an edit control
			this.SetText("Edit1")
			this.ControlShow("Edit1")
			if (Assignment = "Launch Website")
				this.SetText(Binder.AssignmentTextHWND, "Website URL:")
			else if (Assignment = "Launch File/Program") {
				this.SetText(Binder.AssignmentTextHWND, "Select file:")
				this.ControlShow("Button3") ; hide 'em all
				this.Control("Show", "Edit1")
				this.Control("Enable", "Edit1")
				this.Control("Move", "Edit1", "w" this.WIDTH - 16 - this.CONTROL_HEIGHT)
				this.Control("+ReadOnly", "Edit1")
			}
		}
	}
	
	ControlShow(SelectControl) {
		if (SelectControl = "Edit1") {
			this.Control("Move", "Edit1", "w" this.WIDTH - 12)
			this.Control("-ReadOnly", "Edit1")
		}
		for Index, Control in ["ComboBox2", "Edit1", Binder.BindHotkeyHWND, "Button3"] {
			this.Control(SelectControl=Control?"Show":"Hide", Control)
			this.Control(SelectControl=Control?"Enable":"Disable", Control)
		} 
	}
	
	SelectFile() {
		this.Disable()
		this.Options("-AlwaysOnTop")
		AppSelect(this.SelectFileCallback.Bind(this), this.hwnd, true)
	}
	
	SelectFileCallback(Info) {
		
		Big.Options("+AlwaysOnTop")
		this.Options("+AlwaysOnTop")
		this.Enable()
		this.Activate()
		
		if !IsObject(Info)
			return
		
		this.CustomFileName := Info.DisplayName
		
		this.SetText("Edit1", Info.Run)
		ControlSend, Edit1, {End}, % this.ahkid
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
		
		Key .= "Delete"
		
		Binder.SetText("msctls_hotkey321", Key)
		
		; check if in use
		this.HotkeyChange()
	}
	
	PassthroughChange() {
		this.Passthrough := this.ControlGet("Checked",, "Button1")
	}
	
	WildcardChange() {
		this.Wildcard := this.ControlGet("Checked",, "Button2")
	}
	
	Close(Bind := "", ID := "") {
		DllCall("AnimateWindow", "UInt", this.hwnd, "Int", 60, "UInt", "0x90000")
		WinActivate("ahk_id" this.Owner)
		
		this.Destroy()
		
		if IsObject(Bind)
			Event("BindCallback", ID, Bind)
		
		this.Callback.Call(Bind, ID)
	}
	
	Escape() {
		this.Close()
	}
}

CreateNugget(Callback, Owner := "") {
	
	; list of assignments
	for Class, BindList in Binds.List
		Assignments .= Class "|"
	Assignments .= "Launch File/Program|Launch Website"
	
	Binder := new BinderGUI("Binder", "+Owner" Owner " +AlwaysOnTop -Caption +Border")
	
	Binder.Font("s10", Settings.Font)
	Binder.Margin(6, 4)
	
	Binder.Callback := Callback
	Binder.Owner := Owner
	
	Binder.WIDTH := WIDTH := 180
	Binder.HEIGHT := HEIGHT := 247
	Binder.CONTROL_HEIGHT := CONTROL_HEIGHT := 26
	
	Binder.Add("Text", "Center x0 w" WIDTH, "Key:")
	
	Binder.MainHotkeyHWND := Binder.Add("Hotkey", "x6 yp+25 w" WIDTH - 12 " Center",, Binder.HotkeyChange.Bind(Binder))
	; Binder.Add("Button", "x" 6 + WIDTH - 38 " yp-1 w" 27 " h" 27, "M", Binder.EditModifiers.Bind(Binder))
	
	Binder.Add("Checkbox", "x8 yp+32", "Passthrough", Binder.PassthroughChange.Bind(Binder))
	Binder.Add("Checkbox", "x" WIDTH/2 + 10 " yp", "Wildcard", Binder.WildcardChange.Bind(Binder))
	
	Binder.Add("Text", "x6 yp+" CONTROL_HEIGHT " w" WIDTH-12 " h1 0x08") ; separator
	
	Binder.Add("Text", "x0 w" WIDTH " Center", "Assignment:")
	Binder.Add("DropDownList", "x6 w" WIDTH - 12 " h" CONTROL_HEIGHT " Choose1 R99", Assignments, Binder.AssignmentDDL.Bind(Binder))
	
	Binder.Add("Text", "x6 yp+" 8+CONTROL_HEIGHT " w" WIDTH - 12 " h1 0x08") ; separator
	
	Binder.AssignmentTextHWND := Binder.Add("Text", "x0 w" WIDTH " Center", "Function:")
	Binder.Add("DropDownList", "x6 w" WIDTH - 12 " h" CONTROL_HEIGHT " Choose1 Hidden R99",, Binder.FunctionDDL.Bind(Binder))
	Binder.EditHWND := Binder.Add("Edit", "x6 yp w" WIDTH - 12 " h" CONTROL_HEIGHT)
	Binder.Font("s9", "Wingdings")
	Binder.Add("Button", "x" WIDTH - 6 - CONTROL_HEIGHT " yp-1 w" CONTROL_HEIGHT " h" CONTROL_HEIGHT + 2, "1", Binder.SelectFile.Bind(Binder))
	Binder.Font("s10", Settings.Font)
	
	Binder.Margin(6, 10)
	Binder.Add("Text", "x6 yp+" 8 + CONTROL_HEIGHT " w" WIDTH - 12 " h1 0x08") ; separator
	Binder.Add("Button", "x6 yp+8 h" CONTROL_HEIGHT, "Cancel", Binder.Close.Bind(Binder))
	Binder.Add("Button", "xp" WIDTH - 61 " yp h" CONTROL_HEIGHT, HotkeyMode?"Add Keybind":"Create", Binder.AddButton.Bind(Binder))
	
	; set initial values
	Binder.Assignment := "Built-in"
	Binder.SetAssignment(Binder.Assignment)
	
	FrameShadow(Binder.hwnd)
	
	new Hotkey("*Delete", Binder.DeletePress.Bind(Binder), Binder.ahkid)
	
	if (OwnerPos := WinGetPos("ahk_id" Owner))
		Binder.Show("x" OwnerPos.X + OwnerPos.W/2 - 182/2 " y" OwnerPos.Y + OwnerPos.H/2 - 218/2 - 15 " w" WIDTH " h" HEIGHT)
	else
		Binder.Show()
}