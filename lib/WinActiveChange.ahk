; https://autohotkey.com/board/topic/66726-method-to-detect-active-window-change/
WinActiveChange(wParam, hwnd) {
	static RulesEnabled
	
	if (wParam != 32772) ; only listen for HSHELL_RUDEAPPACTIVATED
		return
	
	WinGet, ProcessPath, ProcessPath, ahk_id %hwnd%
	
	for Process, Info in GameRules {
		if (SubStr(ProcessPath, 1, StrLen(Process)) = Process) { ; apply rules to any exe in the dir if only a dir is specified
			
			if RulesEnabled
				DisableRules()
			
			if !StrLen(Info.Title) { ; save window title if not there yet
				WinGetTitle, Title, ahk_id %hwnd%
				GameRules[Process].Title := Title
				Info.Title := Title
				JSONSave("GameRules", GameRules)
				Big.UpdateGameList()
			}
			
			ApplyRules(Info), RulesEnabled := true
			return
		}
	}
	
	if RulesEnabled ; no windows matched, disable rules
		DisableRules(), RulesEnabled := false
}

ApplyRules(Info) {
	p("Applying game rules for " Info.Title)
	
	if !Settings.NvAPI_InitFail
		for Index, Screen in Settings.VibrancyScreens
			NvAPI.SetDVCLevelEx(Info.Vibrancy, Screen - 1)
	
	if Info.BlockWinKey
		new Hotkey("LWin", "scaryvoid")
	
	if Info.BlockAltTab
		new Hotkey("!Tab", "scaryvoid")
}

scaryvoid:
return

DisableRules() {
	p("Disabling game rules")
	
	if !Settings.NvAPI_InitFail
		Loop % SysGet("MonitorCount")
			NvAPI.SetDVCLevelEx(Settings.VibrancyDefault, A_Index - 1)
	
	Hotkey.GetGlobal("LWin").Delete()
	Hotkey.GetGlobal("!Tab").Delete()
}