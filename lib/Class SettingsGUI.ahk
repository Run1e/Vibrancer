Class SettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		
		StartUp := this.ControlGet("Checked",, "Button5")
		VibrancyDefault := this.GetText("Edit1")
		
		Settings.StartUp := StartUp
		Settings.VibrancyDefault := VibrancyDefault
		
		Rules.VibAll(VibrancyDefault)
		
		Settings.Save(true)
		ApplySettings()
		
		this.Close()
	}
	
	; close gui
	Close(OpenMain := true) {
		this.Destroy()
		
		SetGUI := "" ; remove global ref
		
		if this.OpenMainOnClose && OpenMain
			Big.Open()
	}
}

Settings() {
	if IsObject(SetGUI)
		return SetGUI.Activate()
	
	SetGUI := new SettingsGUI("Settings (" AppVersionString ")")
	
	if Big.IsVisible {
		Big.Close()
		SetGUI.OpenMainOnClose := true
	}
	
	SetGUI.Font("s10", Settings.Font)
	SetGUI.Color("FFFFFF")
	SetGui.Margin(6, 10)
	
	; groupboxes
	SetGUI.Add("Groupbox", "xm y2 h84 w180", AppName)
	;SetGUI.Add("Groupbox", "xm y+6 h136 w180", "newsection")
	
	; bottom buttons
	SetGUI.Add("Button", "x6 w181", "Report a bug", Func("BugReport"))
	SetGUI.Add("Button", "x6", "Check for Updates", Func("CheckForUpdates"))
	SetGUI.Add("Button", "x127 yp w60", "Save", SetGUI.Save.Bind(SetGUI))
	
	; vibrancer controls
	SetGUI.Add("Checkbox", "xm+12 y26 w150 Checked" Settings.StartUp, "Launch on Startup")
	SetGUI.Add("Text",, "Desktop Vibrancy: ")
	SetGUI.Add("Edit", "x125 yp-2 w49 Number -Wrap Limit")
	SetGUI.Add("UpDown", "Range0-100", Settings.VibrancyDefault)
	SetGUI.Font("s10")
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon())
}