; https://autohotkey.com/board/topic/66726-method-to-detect-active-window-change/
WinActiveChange(wParam, hwnd) {
	static HSHELL_RUDEAPPACTIVATED := 32772, RulesEnabled
	
	if (wParam != HSHELL_RUDEAPPACTIVATED) ; only listen for HSHELL_RUDEAPPACTIVATED
		return
	
	WinGet, ProcessPath, ProcessPath, ahk_id %hwnd%
	
	for Process, Info in GameRules {
		if (SubStr(ProcessPath, 1, StrLen(Process)) = Process) { ; apply rules to any exe in the dir if only a dir is specified
			
			if RulesEnabled
				DisableRules()
			
			ApplyRules(Info), RulesEnabled := true
			
			if !StrLen(Info.Title) { ; save window title if not there yet
				WinGetTitle, Title, ahk_id %hwnd%
				GameRules[Process].Title := Title
				JSONSave("GameRules", GameRules)
				Big.SetDefault()
				Big.Control("ListView", Big.GameListViewHWND)
				LV_Modify(A_Index, "Col1", Title)
			}
			
			return
		}
	}
	
	if RulesEnabled ; no windows matched, disable rules
		DisableRules(), RulesEnabled := false
}

ApplyRules(Info) {
	if !Settings.NvAPI_Fail
		NvAPI.SetDVCLevelEx(Info.Vibrancy, Settings.VibrancyScreen)
	
	if Info.BlockWinKey
		Hotkey.Bind("LWin", "returnlabel")
	
	if Info.BlockAltTab
		Hotkey.Bind("!Tab", "returnlabel")
}

DisableRules() {
	NvAPI.SetDVCLevelEx(Settings.VibrancyDefault, Settings.VibrancyScreen)
	Hotkey.Disable("LWin")
	Hotkey.Disable("!Tab")
}