ApplySettings() {
	
	Shortcut := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\" AppName ".lnk"
	
	if Settings.StartUp
		FileCreateShortcut, % A_ScriptFullPath, % Shortcut, % A_WorkingDir
	else if FileExist(Shortcut)
		FileDelete % Shortcut
}