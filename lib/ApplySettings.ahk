﻿ApplySettings() {
	
	Shortcut := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\" App.Name ".lnk"
	
	if Settings.StartUp
		FileCreateShortcut, % A_ScriptDir "\Vibrancer.exe", % Shortcut, % A_WorkingDir
	else if FileExist(Shortcut)
		FileDelete % Shortcut
}