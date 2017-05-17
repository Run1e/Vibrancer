; https://autohotkey.com/board/topic/66726-method-to-detect-active-window-change/
WinActiveChange(wParam, hwnd) {
	static RulesEnabled
	
	if (wParam != 32772) ; only listen for HSHELL_RUDEAPPACTIVATED
		return
	
	WinGet, ProcessPath, ProcessPath, ahk_id %hwnd%
	
	for Process, Info in GameRules.Data() {
		if (SubStr(ProcessPath, 1, StrLen(Process)) = Process) { ; apply rules to any exe in the dir if only a dir is specified
			
			if RulesEnabled
				DisableRules()
			
			if !StrLen(Info.Title) { ; save window title if not there yet
				WinGetTitle, Title, ahk_id %hwnd%
				GameRules[Process].Title := Title
				Info.Title := Title
				GameRules.Save()
				Big.UpdateGameList()
			}
			
			ApplyRules(Process), RulesEnabled := true
			return
		}
	}
	
	if RulesEnabled {
		if !Event("RulesDisable")
			DisableRules(), RulesEnabled := false
	}
}

ApplyRules(Process) {
	Info := GameRules[Process]
	
	if Event("RulesEnable", Process, Info)
		return
	
	if !Settings.NvAPI_InitFail
		for Index, Screen in Settings.VibrancyScreens
			NvAPI.SetDVCLevelEx(Info.Vibrancy, Screen - 1)
	
	if Info.BlockWinKey
		new Hotkey("LWin", "")
	
	if Info.BlockAltTab
		new Hotkey("!Tab", "")
}

DisableRules() {
	if !Settings.NvAPI_InitFail
		Loop % SysGet("MonitorCount")
			NvAPI.SetDVCLevelEx(Settings.VibrancyDefault, A_Index - 1)
		
	Hotkey.GetKey("LWin").Delete()
	Hotkey.GetKey("!Tab").Delete()
}