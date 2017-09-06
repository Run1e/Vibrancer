Class ImgurSettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		
		CloseOnCopy := this.ControlGet("Checked",, "Button1")
		CloseOnOpen := this.ControlGet("Checked",, "Button2")
		UseGifv := this.ControlGet("Checked",, "Button3")
		
		Loop 3 {
			if this.ControlGet("Checked",, "Button" (3 + A_Index)) {
				CopyOnUpload := {1:2, 2:1, 3:0}[A_Index]
				break
			} else if (A_Index = 4) ; wut how
				break
		}
		
		Settings.CloseOnCopy := CloseOnCopy
		Settings.CloseOnOpen := CloseOnOpen
		Settings.UseGifv := UseGifv
		Settings.CopyOnUpload := CopyOnUpload
		
		Settings.Save(true)
		
		this.Close()
	}
	
	; close gui
	Close(OpenMain := true) {
		this.Destroy()
		SetGUI := ""
	}
}

Settings() {
	if IsObject(SetGUI)
		return SetGUI.Activate()
	
	SetGUI := new ImgurSettingsGUI("Imgur Settings", "-MinimizeBox")
	
	SetGUI.Font("s10", "Segoe UI Light")
	SetGUI.Color("FFFFFF")
	SetGui.Margin(6, 6)
	
	; vibrancer controls
	SetGUI.Add("Checkbox", "xm+6 w120 Checked" Settings.CloseOnCopy, "Close on Copy")
	SetGUI.Add("Checkbox", "xp yp+22 wp Disabled Checked" Settings.CloseOnOpen, "Close on Open")
	SetGUI.Add("Checkbox", "xp yp+22 wp Checked" Settings.UseGifv, "Copy gif as gifv")
	SetGUI.Add("Text",, "Copy to clipboard:")
	SetGUI.Add("Radio", "Checked" (Settings.CopyOnUpload = 2 ? true : false), "Always")
	SetGUI.Add("Radio", "Checked" (Settings.CopyOnUpload = 1 ? true : false), "When minimized")
	SetGUI.Add("Radio", "Checked" (Settings.CopyOnUpload = 0 ? true : false), "Never")
	
	; bottom buttons
	SetGUI.Add("Button", "xm w130", "Purge images", Func("PurgeImages"))
	SetGUI.Add("Button", "xm w130", "Save", SetGUI.Save.Bind(SetGUI))
	
	SetGUI.Show()
	
	SetGUI.SetIcon(Vib.Call("Icon"))
}