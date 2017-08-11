Class SettingsGUI extends GUI {
	
	; save settings and close
	Save() {
		if StrLen(this.NewLangChoice) {
			Settings.Language := this.NewLangChoice
			SetLanguage()
		}
		
		StartUp := this.ControlGet("Checked",, "Button5")
		VibrancyDefault := this.GetText("Edit1")
		
		Settings.StartUp := StartUp
		Settings.VibrancyDefault := VibrancyDefault
		
		Rules.VibAll(VibrancyDefault)
		
		Settings.Save(true)
		ApplySettings()
		
		this.Close()
	}
	
	NewLang() {
		this.NewLangChoice := this.GetText("ComboBox1")
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
	
	SetGUI := new SettingsGUI(Lang.SETTINGS.SETTINGS " (" AppVersionString ")")
	
	if Big.IsVisible {
		Big.Close()
		SetGUI.OpenMainOnClose := true
	}
	
	SetGUI.Font("s10", Settings.Font)
	SetGUI.Color("FFFFFF")
	SetGui.Margin(6, 10)
	
	; groupboxes
	SetGUI.Add("Groupbox", "xm y2 h145 w180", AppName)
	;SetGUI.Add("Groupbox", "xm y+6 h136 w180", "newsection")
	
	; bottom buttons
	SetGUI.Add("Button", "x6 w181", Lang.SETTINGS.REPORT_BUG, Func("BugReport"))
	SetGUI.Add("Button", "x6", Lang.SETTINGS.CHECK_FOR_UPDATES, Func("CheckForUpdates"))
	SetGUI.Add("Button", "x127 yp w60", Lang.SETTINGS.SAVE, SetGUI.Save.Bind(SetGUI))
	
	; vibrancer controls
	SetGUI.Add("Text", "xm+12 y26 w150", Lang.SETTINGS.SELECT_LANG)
	Loop, Files, language\*.ini
	{
		langs .= "|" SubStr(A_LoopFileName, 1, -4)
		if (SubStr(A_LoopFileName, 1, -4) = Settings.Language)
			Sel := A_Index
	}
	SetGUI.Add("DropDownList", "w160 Choose" Sel, SubStr(langs, 2), SetGUI.NewLang.Bind(SetGUI))
	SetGUI.Add("Checkbox", "xp w150 yp+32 Checked" Settings.StartUp, Lang.SETTINGS.STARTUP)
	SetGUI.Add("Text",, Lang.SETTINGS.DESK_VIB)
	SetGUI.Add("Edit", "x125 yp-2 w49 Number -Wrap Limit")
	SetGUI.Add("UpDown", "Range0-100", Settings.VibrancyDefault)
	SetGUI.Font("s10")
	
	SetGUI.Options("-MinimizeBox")
	SetGUI.Show()
	
	SetGUI.SetIcon(Icon())
}