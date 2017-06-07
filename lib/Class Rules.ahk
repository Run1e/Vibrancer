Class Rules {
	static Enabled := false
	
	Enable(Process) {
		Event("RulesEnable", Process, Info := GameRules[Process])
		
		this.Enabled := true
		this.Process := Process
		
		for Index, Screen in Settings.VibrancyScreens
			this.Vib(Info.Vibrancy, Screen)
		
		if Info.BlockWinKey
			new Hotkey("LWin", "")
		if Info.BlockAltTab
			new Hotkey("!Tab", "")
	}
	
	Disable() {
		Event("RulesDisable")
		
		this.Enabled := false
		this.Process := ""
		
		this.VibAll(Settings.VibrancyDefault)
		
		Hotkey.GetKey("LWin").Delete()
		Hotkey.GetKey("!Tab").Delete()
	}
	
	Vib(Vibrancy, Screen := 1) {
		if !Settings.NvAPI_InitFail
			NvAPI.SetDVCLevelEx(Vibrancy, Screen - 1)
	}
	
	VibAll(Vibrancy) {
		Loop % SysGet("MonitorCount")
			this.Vib(Vibrancy, A_Index)
	}
	
	WinChange(wParam, hwnd) {
		if !(wParam ~= "^(4|32772)$") ; HSHELL_WINDOWACTIVATED and HSHELL_RUDEAPPACTIVATED
			return
		
		WinGet, ProcessPath, ProcessPath, ahk_id %hwnd%
		
		for Process, Info in GameRules.Data() {
			if (SubStr(ProcessPath, 1, StrLen(Process)) = Process) { ; apply rules to any exe in the dir if only a dir is specified
				
				if (this.Process = Process)
					return
				
				if this.Enabled
					this.Disable()
				
				if !StrLen(Info.Title) { ; save window title if not there yet
					WinGetTitle, Title, ahk_id %hwnd%
					GameRules[Process].Title := Title
					Info.Title := Title
					GameRules.Save()
					Big.UpdateGameList()
				}
				
				return this.Enable(Process)
			}
		}
		
		if this.Enabled
			this.Disable()
	}
	
}