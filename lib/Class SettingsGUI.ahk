Class SettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		
		Beep := this.ControlGet("Checked",, "Button5")
		VibrancyDefault := this.GetText("Edit1")
		CloseOnCopy := this.ControlGet("Checked",, "Button7")
		CloseOnOpen := this.ControlGet("Checked",, "Button8")
		UseGifv := this.ControlGet("Checked",, "Button9")
		ListViewMax := this.GetText("Edit2")
		
		if (ListViewMax < 10) {
			TrayTip("Invalid parameter", "Please select a value higher than 10 as Image list limit.")
			return
		}
		
		if (ListViewMax != Settings.Imgur.ListViewMax) {
			Settings.Imgur.ListViewMax := ListViewMax
			Tooltip Working..
			Big.UpdateImgurList()
			Tooltip
		}
		
		Settings.Beep := Beep
		Settings.VibrancyDefault := VibrancyDefault
		DisableRules() ; set new vibrancy
		
		Settings.Imgur.CloseOnCopy := CloseOnCopy
		Settings.Imgur.CloseOnOpen := CloseOnOpen
		Settings.Imgur.UseGifv := UseGifv
		
		JSONSave("Settings", Settings)
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
		
		for Key in Keybinds
			Hotkey.Enable(Key)
	}
}

Settings() {
	
	for Key in Keybinds
		Hotkey.Disable(Key)
	
	SetGUI := new SettingsGUI("Settings")
	
	if WinExist(Big.ahkid) {
		Big.Hide()
		SetGUI.OpenMainOnClose := true
	}
	
	SetGUI.Font("s10", Settings.Font)
	SetGUI.Color("FFFFFF")
	
	; groupboxes
	SetGUI.Add("Groupbox", "xm h140 w180", AppName)
	SetGUI.Add("Groupbox", "xm y+6 h134 w180", "Imgur")
	
	; bottom buttons
	SetGUI.Add("Button",, "Check for updates", Func("CheckForUpdates"))
	SetGUI.Add("Button", "x143 yp w50", "Save", SetGUI.Save.Bind(SetGUI))
	
	; power play controls
	SetGUI.Add("Checkbox", "xm+12 y34 Checked" Settings.Beep, "Beep!")
	SetGUI.Add("Text",, "Desktop Vibrancy: ")
	SetGUI.Add("Edit", "x130 yp-2 w49 Number -Wrap Limit")
	SetGUI.Add("UpDown", "Range0-100", Settings.VibrancyDefault)
	SetGUI.Add("Button", "xm+12 yp+30 w156", "Set Pastebin API Key", SetGUI.InputPastebinKey.Bind(SetGUI))
	SetGUI.Font("s8")
	SetGUI.Add("Link",, "<a href=""https://pastebin.com/api"">Get your Developer API Key here</a>")
	SetGUI.Font("s10")
	
	; imgur controls
	SetGUI.Add("Checkbox", "xm+12 y180 Checked" Settings.Imgur.CloseOnCopy, "Close on copy")
	SetGUI.Add("Checkbox", "Checked" Settings.Imgur.CloseOnOpen, "Close on open")
	SetGUI.Add("Checkbox", "Checked" Settings.Imgur.UseGifv, "Link to .gifv")
	SetGUI.Add("Text",, "Image list limit: ")
	SetGUI.Add("Edit", "x114 yp-2 w33 Number -Wrap Limit", Settings.Imgur.ListViewMax)
	
	; imgur section
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon("gear"))
	
}

/*
	{ Beep: false
	, Font: "Segoe UI Light"
	, Color: {Selection: "44C6F6", Tab: "FE9A2E", Dark: "353535"} ; FE9A2E
	, GuiState: {ActiveTab: 1, GameListPos: 1, BindListPos: 1}
	, Imgur: {CloseOnOpen: true, CloseOnCopy: true, ListViewMax:100, UseGifv:true}
	, VibrancyScreen: SysGet("MonitorPrimary") - 1 ; proper arrays apparently start at 0. who would've known.
	, VibrancyDefault: 50}
*/