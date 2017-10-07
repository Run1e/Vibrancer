﻿Class Rules {
	static Enabled := false
	
	Listen() {
		DllCall("RegisterShellHookWindow", "ptr", Big.hwnd)
		OnMessage(this.Msg := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), this.WinChange.Bind(this))
	}
	
	UnListen() {
		OnMessage(this.Msg, "")
	}
	
	Enable(Process) {
		Event("RulesEnable", Process, Info := GameRules[Process])
		
		p("Rules.Enable: " Process)
		
		this.Enabled := true
		this.Process := Process
		
		this.VibSelected(Info.Vibrancy)
		
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
		Event("Vibrancing", {Vibrancy: Vibrancy, Screen: Screen})
		if !Settings.NvAPI_InitFail {
			Result := NvAPI.SetDVCLevelEx(Vibrancy, Screen - 1)
		}
	}
	
	VibSelected(Vibrancy) {
		for Index, Screen in Settings.VibrancyScreens
			this.Vib(Vibrancy, Screen)
	}
	
	VibAll(Vibrancy) {
		Loop % SysGet("MonitorCount")
			this.Vib(Vibrancy, A_Index)
	}
	
	WinChange(wParam, hwnd) {
		if !(wParam ~= "^(4|32772)$") ; HSHELL_WINDOWACTIVATED and HSHELL_RUDEAPPACTIVATED
			return
		
		WinGet, ProcessPath, ProcessPath, ahk_id %hwnd%
		
		p("Rules.WinChange: " ProcessPath)
		
		for Process, Info in GameRules.Object() {
			if (SubStr(ProcessPath, 1, StrLen(Process)) = Process) { ; apply rules to any exe in the dir if only a dir is specified
				
				if (this.Process = Process)
					return
				
				if this.Enabled
					this.Disable()
				
				if !StrLen(Info.Title) { ; save window title if not there yet
					WinGetTitle, Title, ahk_id %hwnd%
					GameRules[Process].Title := Title
					Info.Title := Title
					GameRules.Save(true)
					Big.UpdateGameList(Process)
				}
				
				return this.Enable(Process)
			}
		}
		
		if this.Enabled
			this.Disable()
	}
	
}