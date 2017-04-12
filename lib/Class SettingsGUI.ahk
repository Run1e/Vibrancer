Class SettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		
		StartUp := this.ControlGet("Checked",, "Button5")
		VibrancyDefault := this.GetText("Edit1")
		CloseOnCopy := this.ControlGet("Checked",, "Button7")
		CloseOnOpen := this.ControlGet("Checked",, "Button8")
		UseGifv := this.ControlGet("Checked",, "Button9")
		ListViewMax := this.GetText("Edit2")
		
		if (ListViewMax < 10)
			return TrayTip("Invalid parameter", "Please select a value higher than 10 as Image list limit.")
		
		if (ListViewMax != Settings.Imgur.ListViewMax) {
			Settings.Imgur.ListViewMax := ListViewMax
			Tooltip Working..
			Big.UpdateImgurList()
			Tooltip
		}
		
		Settings.StartUp := StartUp
		Settings.VibrancyDefault := VibrancyDefault
		DisableRules() ; set new vibrancy
		
		Settings.Imgur.CloseOnCopy := CloseOnCopy
		Settings.Imgur.CloseOnOpen := CloseOnOpen
		Settings.Imgur.UseGifv := UseGifv
		
		JSONSave("Settings", Settings)
		ApplySettings()
		this.Close()
	}
	
	InputPastebinKey() {
		InputBox, Key, Pastebin Developer API Key, Input your Developer API Key here:,, 280, 130
		if !ErrorLevel
			Settings.PastebinKey := Key
	}
	
	; close gui
	Close() {
		this.Destroy()
		
		SetGUI := "" ; remove global ref
		
		if this.OpenMainOnClose
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
	SetGUI.Add("Groupbox", "xm y+6 h134 w180", "Imgur")
	
	; bottom buttons
	SetGUI.Add("Button",, "Check for updates", Func("CheckForUpdates"))
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
	
	SetGui.Margin(6, 8)
	; imgur controls
	SetGUI.Add("Checkbox", "xm+12 y176 Checked" Settings.Imgur.CloseOnCopy, "Close on copy")
	SetGUI.Add("Checkbox", "Checked" Settings.Imgur.CloseOnOpen, "Close on open")
	SetGUI.Add("Checkbox", "Checked" Settings.Imgur.UseGifv, "Link to .gifv")
	SetGUI.Add("Text",, "Image list limit: ")
	SetGUI.Add("Edit", "x110 yp-2 w33 Number -Wrap Limit", Settings.Imgur.ListViewMax)
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon("gear"))
}