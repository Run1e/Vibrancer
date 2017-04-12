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
			
			ApplyRules(Info), RulesEnabled := true
			
			if !StrLen(Info.Title) { ; save window title if not there yet
				WinGetTitle, Title, ahk_id %hwnd%
				GameRules[Process].Title := Title
				JSONSave("GameRules", GameRules)
				Big.UpdateGameList()
				
				; I'm having inconsistensies making the 'nice way' work, so I just refresh the while stupid listview instead
				
				;Big.SetDefault()
				;Big.Control("ListView", Big.GameListViewHWND)
				;LV_Modify(A_Index, "Col1", Title)
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
	SysGet, MonitorCount, MonitorCount
	Loop % MonitorCount
		NvAPI.SetDVCLevelEx(Settings.VibrancyDefault, A_Index-1)
	Hotkey.Disable("LWin")
	Hotkey.Disable("!Tab")
}