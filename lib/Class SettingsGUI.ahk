Class SettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		
		StartUp := this.ControlGet("Checked",, "Button4")
		VibrancyDefault := this.GetText("Edit1")
		
		Settings.StartUp := StartUp
		Settings.VibrancyDefault := VibrancyDefault
		
		Rules.VibAll(VibrancyDefault)
		
		Settings.Save()
		ApplySettings()
		this.Close()
	}
	
	InputPastebinKey() {
		InputBox, Key, Pastebin Developer API Key, Input your Developer API Key here:,, 280, 130,,,,, % Settings.PastebinKey
		if !ErrorLevel
			Settings.PastebinKey := Key
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
	
	SetGUI := new SettingsGUI("Settings")
	
	if Big.IsVisible {
		Big.Close()
		SetGUI.OpenMainOnClose := true
	}
	
	SetGUI.Font("s10", Settings.Font)
	SetGUI.Color("FFFFFF")
	SetGui.Margin(6, 10)
	
	; groupboxes
	SetGUI.Add("Groupbox", "xm y2 h142 w180", AppName)
	;SetGUI.Add("Groupbox", "xm y+6 h136 w180", "Imgur")
	
	; bottom buttons
	SetGUI.Add("Button", "x6 w181", "Report a bug", Func("BugReport"))
	SetGUI.Add("Button", "x6", "Check for updates", Func("CheckForUpdates"))
	SetGUI.Add("Button", "x137 yp w50", "Save", SetGUI.Save.Bind(SetGUI))
	
	; power play controls
	SetGUI.Add("Checkbox", "xm+12 y26 w150 Checked" Settings.StartUp, "Launch on Startup")
	SetGUI.Add("Text",, "Desktop Vibrancy: ")
	SetGUI.Add("Edit", "x125 yp-2 w49 Number -Wrap Limit")
	SetGUI.Add("UpDown", "Range0-100", Settings.VibrancyDefault)
	SetGUI.Add("Button", "xm+12 yp+34 w156", "Set Pastebin API Key", SetGUI.InputPastebinKey.Bind(SetGUI))
	SetGUI.Font("s8")
	SetGUI.Add("Link", "yp+36", "<a href=""https://pastebin.com/api"">Get your Developer API Key here</a>")
	SetGUI.Font("s10")
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon("gear"))
}